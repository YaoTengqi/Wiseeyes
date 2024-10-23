#coding=utf-8
import array
import queue
import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge, ReadOnly, Lock
from cocotb.drivers import BusDriver
from cocotb.result import ReturnValue
from cocotb.binary import BinaryValue


async def showSimTime(dut,scale=50,unit='us'):
    while True:
        await Timer(scale, units=unit)
        dut._log.info('simulation time print')

class AXI4LiteMasterExt(BusDriver):
    """AXI4-Lite Master.

    TODO: Kill all pending transactions if reset is asserted.
    """

    _signals = ["AWVALID", "AWADDR", "AWREADY",        # Write address channel
                "WVALID", "WREADY", "WDATA", "WSTRB",  # Write data channel
                "BVALID", "BREADY", "BRESP",           # Write response channel
                "ARVALID", "ARADDR", "ARREADY",        # Read address channel
                "RVALID", "RREADY", "RRESP", "RDATA"]  # Read data channel

    def __init__(self, entity, name, clock, **kwargs):
        BusDriver.__init__(self, entity, name, clock, **kwargs)

        # Drive some sensible defaults (setimmediatevalue to avoid x asserts)
        self.bus.AWVALID.setimmediatevalue(0)
        self.bus.WVALID.setimmediatevalue(0)
        self.bus.ARVALID.setimmediatevalue(0)
        self.bus.BREADY.setimmediatevalue(1)
        self.bus.RREADY.setimmediatevalue(1)

        # Mutex for each channel that we master to prevent contention
        self.write_address_busy = Lock("%s_wabusy" % name)
        self.read_address_busy = Lock("%s_rabusy" % name)
        self.write_data_busy = Lock("%s_wbusy" % name)

    @cocotb.coroutine
    def _send_write_address(self, address, delay=0):
        """
        Send the write address, with optional delay (in clocks)
        """
        yield self.write_address_busy.acquire()
        for cycle in range(delay):
            yield RisingEdge(self.clock)

        self.bus.AWADDR <= address
        self.bus.AWVALID <= 1

        while True:
            yield ReadOnly()
            if self.bus.AWREADY.value:
                break
            yield RisingEdge(self.clock)
        yield RisingEdge(self.clock)
        self.bus.AWVALID <= 0
        self.write_address_busy.release()

    @cocotb.coroutine
    def _send_write_data(self, data, delay=0, byte_enable=0xF):
        """Send the write address, with optional delay (in clocks)."""
        yield self.write_data_busy.acquire()
        for cycle in range(delay):
            yield RisingEdge(self.clock)

        self.bus.WDATA <= data
        self.bus.WVALID <= 1
        self.bus.WSTRB <= byte_enable

        while True:
            yield ReadOnly()
            if self.bus.WREADY.value:
                break
            yield RisingEdge(self.clock)
        yield RisingEdge(self.clock)
        self.bus.WVALID <= 0
        self.write_data_busy.release()

    @cocotb.coroutine
    def write(
        self, address: int, value: int, byte_enable: int = 0xf,
        address_latency: int = 0, data_latency: int = 0, sync: bool = True
    ) -> BinaryValue:
        """Write a value to an address.

        Args:
            address: The address to write to.
            value: The data value to write.
            byte_enable: Which bytes in value to actually write.
                Default is to write all bytes.
            address_latency: Delay before setting the address (in clock cycles).
                Default is no delay.
            data_latency: Delay before setting the data value (in clock cycles).
                Default is no delay.
            sync: Wait for rising edge on clock initially.
                Defaults to True.

        Returns:
            The write response value.

        Raises:
            AXIProtocolError: If write response from AXI is not ``OKAY``.
        """
        if sync:
            yield RisingEdge(self.clock)

        c_addr = cocotb.fork(self._send_write_address(address,
                                                      delay=address_latency))
        c_data = cocotb.fork(self._send_write_data(value,
                                                   byte_enable=byte_enable,
                                                   delay=data_latency))

        if c_addr:
            yield c_addr.join()
        if c_data:
            yield c_data.join()

        # Wait for the response
        while True:
            yield ReadOnly()
            if self.bus.BVALID.value and self.bus.BREADY.value:
                result = self.bus.BRESP.value
                break
            yield RisingEdge(self.clock)

        yield RisingEdge(self.clock)

        if int(result):
            raise AXIProtocolError("Write to address 0x%08x failed with BRESP: %d"
                                   % (address, int(result)))

        return result

    @cocotb.coroutine
    def read(self, address: int, sync: bool = True) -> BinaryValue:
        """Read from an address.

        Args:
            address: The address to read from.
            sync: Wait for rising edge on clock initially.
                Defaults to True.

        Returns:
            The read data value.

        Raises:
            AXIProtocolError: If read response from AXI is not ``OKAY``.
        """
        #self.entity._log.info('reveive a read operation addr = {},sync={}'.format(address,sync))
        if sync:
            yield RisingEdge(self.clock)
        
        self.bus.ARADDR <= address
        self.bus.ARVALID <= 1

        while True:
            #yield ReadOnly()
            if self.bus.ARREADY.value:
                #self.entity._log.info('reveive a arvalid')
                break
            yield RisingEdge(self.clock)

        #self.entity._log.info('wait clock begin')
        yield RisingEdge(self.clock)
        self.bus.ARVALID <= 0
        #self.entity._log.info('wait clock end')

        while True:
            #yield ReadOnly()
            if self.bus.RVALID.value and self.bus.RREADY.value:
                #self.entity._log.info('reveive a rvalid')
                data = self.bus.RDATA.value
                result = self.bus.RRESP.value
                break
            yield RisingEdge(self.clock)
        #self.entity._log.info('address={},rvalid={},rdata={}'.format(address,self.bus.RVALID.value,data))
        if int(result):
            raise AXIProtocolError("Read address 0x%08x failed with RRESP: %d" %
                                   (address, int(result)))

        return data

    def __len__(self):
        return 2**len(self.bus.ARADDR)

class AXISlaveExt(BusDriver):
    '''
    AXI4 Slave

    Monitors an internal memory and handles read and write requests.
    '''
    _signals = [
        "ARREADY", "ARVALID", "ARADDR",             # Read address channel
        "ARLEN",   "ARSIZE",  "ARBURST", "ARPROT",

        "RREADY",  "RVALID",  "RDATA",   "RLAST",   # Read response channel
        "RRESP",

        "AWREADY", "AWADDR",  "AWVALID",            # Write address channel
        "AWPROT",  "AWSIZE",  "AWBURST", "AWLEN",
        "WLAST",   "WSTRB",

        "WREADY",  "WVALID",  "WDATA",
        'BRESP','BVALID','BREADY','ARID','RID'
    ]

    # Not currently supported by this driver
    _optional_signals = [
        "RCOUNT",  "WCOUNT",  "RACOUNT", "WACOUNT",
        "ARLOCK",  "AWLOCK",  "ARCACHE", "AWCACHE",
        "ARQOS",   "AWQOS",   "AWID",
        "BID",     "WID"
    ]

    def __init__(self, entity, name, clock, memory, callback=None, event=None,
                 big_endian=False, **kwargs):

        BusDriver.__init__(self, entity, name, clock, **kwargs)
        self.clock = clock
        self.sync_aw_q = queue.Queue()
        self.sync_bresp_q = queue.Queue()
        self.sync_bresp_d = queue.Queue()
        self.sync_ar_q = queue.Queue()

        self.big_endian = big_endian
        self.bus.ARREADY.setimmediatevalue(1)
        self.bus.RVALID.setimmediatevalue(0)
        self.bus.RLAST.setimmediatevalue(0)
        self.bus.RRESP.setimmediatevalue(0)
        self.bus.AWREADY.setimmediatevalue(1)
        self.bus.WREADY.setimmediatevalue(0)

        self.bus.BRESP.setimmediatevalue(0)
        self.bus.BVALID.setimmediatevalue(0)
        self.bus.RID.setimmediatevalue(0)
        self.bus.ARPROT.setimmediatevalue(0)
        self.bus.AWPROT.setimmediatevalue(0)

        self._memory = memory

        self.write_address_busy = Lock("%s_wabusy" % name)
        self.read_address_busy = Lock("%s_rabusy" % name)
        self.write_data_busy = Lock("%s_wbusy" % name)

        cocotb.fork(self._read_data())
        cocotb.fork(self._read_addr())
        cocotb.fork(self._write_data())
        cocotb.fork(self._write_addr())
        cocotb.fork(self._bresp())

    def _size_to_bytes_in_beat(self, AxSIZE):
        if AxSIZE < 7:
            return 2 ** AxSIZE
        return None

    @cocotb.coroutine
    def _write_addr(self):
        clock_re = RisingEdge(self.clock)

        while True:
            while True:
                if self.bus.AWVALID.value:
                    break
                yield clock_re
            _awaddr = int(self.bus.AWADDR)
            _awlen = int(self.bus.AWLEN)
            _awsize = int(self.bus.AWSIZE)
            _awburst = int(self.bus.AWBURST)
            _awprot = int(self.bus.AWPROT)
            burst_length = _awlen + 1
            bytes_in_beat = self._size_to_bytes_in_beat(_awsize)
            if __debug__:
                self.log.debug(
                    "AWADDR  %d\n" % _awaddr +
                    "AWLEN   %d\n" % _awlen +
                    "AWSIZE  %d\n" % _awsize +
                    "AWBURST %d\n" % _awburst +
                    "BURST_LENGTH %d\n" % burst_length +
                    "Bytes in beat %d\n" % bytes_in_beat)
            self.sync_aw_q.put((_awaddr,burst_length,bytes_in_beat,))
            self.sync_bresp_q.put(1)
            yield clock_re

    @cocotb.coroutine
    def _write_data(self):
        clock_re = RisingEdge(self.clock)
        while True:
            while True:
                if self.sync_aw_q.qsize() > 0:
                    _awaddr,burst_length,bytes_in_beat = self.sync_aw_q.get()
                    burst_count = burst_length
                    break
                else:
                    self.bus.WREADY <= 0
                yield clock_re
            yield clock_re
            self.bus.WREADY <= 1
            while True:
                if self.bus.WVALID.value:
                    word = self.bus.WDATA.value
                    word.big_endian = self.big_endian
                    # # 检查是否有未解析的位
                    # if 'x' in word.binstr or 'z' in word.binstr:
                    #     raise ValueError("WDATA contains unresolved bits at address 0x%08x" % _awaddr)                  
                    _burst_diff = burst_length - burst_count
                    _st = _awaddr + (_burst_diff * bytes_in_beat)  # start
                    _end = _awaddr + ((_burst_diff + 1) * bytes_in_beat)  # end
                    self._memory[_st:_end] = array.array('B', word.buff)
                    burst_count -= 1
                    if burst_count == 0:
                        if self.bus.WLAST.value:
                            self.sync_bresp_d.put(1)
                        else:
                            raise AXIProtocolError("Write to address 0x%08x failed with WLAST" %(_awaddr)) 
                        break
                yield clock_re

    @cocotb.coroutine
    def _bresp(self):
        clock_re = RisingEdge(self.clock)
        while True:
            while True:
                if self.sync_bresp_q.qsize() > 0 and self.sync_bresp_d.qsize() > 0:
                    _b = self.sync_bresp_q.get()
                    _d = self.sync_bresp_d.get()
                    break
                yield clock_re
            self.bus.BVALID <= 1
            yield clock_re
            while True:
                #yield ReadOnly()
                if self.bus.BREADY.value:
                    self.bus.BVALID <= 0
                    break
                yield clock_re

    @cocotb.coroutine
    def _read_addr(self):
        clock_re = RisingEdge(self.clock)
        while True:
            while True:
                yield ReadOnly()
                if self.bus.ARVALID.value:
                    break
                yield clock_re
            self.entity._log.debug('read a arvalid')
            _araddr = int(self.bus.ARADDR)
            _arlen = int(self.bus.ARLEN)
            _arsize = int(self.bus.ARSIZE)
            _arburst = int(self.bus.ARBURST)
            _arid = int(self.bus.ARID)
            burst_length = _arlen + 1
            bytes_in_beat = self._size_to_bytes_in_beat(_arsize)

            if __debug__:
                self.log.debug(
                "ARADDR  %d\n" % _araddr +
                "ARLEN   %d\n" % _arlen +
                "ARSIZE  %d\n" % _arsize +
                "ARBURST %d\n" % _arburst +
                "BURST_LENGTH %d\n" % burst_length +
                "Bytes in beat %d\n" % bytes_in_beat +
                "ARID %d\n" % _arid)

            self.sync_ar_q.put((_araddr,burst_length,bytes_in_beat,_arid))
            yield clock_re


    @cocotb.coroutine
    def _read_data(self):
        clock_re = RisingEdge(self.clock)

        while True:
            while True:
                if self.sync_ar_q.qsize() > 0:
                    _araddr,burst_length,bytes_in_beat,_arid = self.sync_ar_q.get()
                    break
                else:
                    self.bus.RLAST <= 0
                    self.bus.RVALID <= 0
                yield clock_re
            self.entity._log.debug('read a arvalid')

            word = BinaryValue(n_bits=bytes_in_beat*8, bigEndian=self.big_endian)

            burst_count = burst_length

            yield clock_re

            self.bus.RVALID <= 1
            while True:
                _burst_diff = burst_length - burst_count
                _st = _araddr + (_burst_diff * bytes_in_beat)
                _end = _araddr + ((_burst_diff + 1) * bytes_in_beat)
                word.buff = self._memory[_st:_end].tobytes()
                self.bus.RDATA <= word
                self.bus.RID <= _arid
                if burst_count == 1:
                    self.bus.RLAST <= 1
                elif burst_count == 0:
                    self.entity._log.debug('burst_count={},rvalid={},rdata={}'.format(burst_count,self.bus.RREADY.value,self.bus.RDATA.value))
                    break
                else:
                    self.bus.RLAST <= 0

                yield clock_re
                while True:
                    #yield ReadOnly()
                    if self.bus.RREADY.value:
                        burst_count -= 1
                        break
                    yield clock_re

