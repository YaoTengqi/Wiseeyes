import os
import array
import queue
import cocotb
from cocotb.triggers import RisingEdge, ReadOnly, Lock
import numpy as np
from cocotb.drivers.amba import AXI4LiteMaster
from cocotb.drivers.amba import AXI4Slave
from cocotb.drivers.amba import AXIProtocolError
import threading
from dnnweaver2.fpga.AxiSlaveExt import *
from time import sleep

class Singleton(type):
    def __init__(self,*args,**kwargs):
        self.__instance = None
        super().__init__(*args,**kwargs)

    def __call__(self,*args,**kwargs):
        if self.__instance is None:
            self.__instance = super().__call__(*args,**kwargs)
            return self.__instance
        else:
            return self.__instance

class MemoryModule(metaclass=Singleton):
    '''ddr module'''
    def __init__(self,entity=None,fname='fpga_mem'):
        fd = open(fname,'w')
        fd.close()
        self.mem_fd = os.open(fname, os.O_RDWR)
        self.mem_lock = threading.Lock()
        self.mem = {}
        self.axi_sync_q = queue.Queue(maxsize=1)
        self.axi_sync_read_a = queue.Queue(maxsize=1)
        self.axi_sync_read_d = queue.Queue(maxsize=1000)
        if entity != None:
            self.entity = entity

            self.axi_pci_cl_ctrl = AXI4LiteMasterExt(self.entity, "PCI_CL_CTRL", self.entity.clk)
            self.axi_pci_cl_data = AXI4LiteMasterExt(self.entity, "PCI_CL_DATA", self.entity.clk)
            #cocotb.fork(self.axiWriteRead())

    def __getitem__(self,index):
        if isinstance(index,slice):
            (start,stop) = (index.start,index.stop) if index.start < index.stop else (index.stop,index.start)
        else:
            (start,stop) = (index,index)
        self.mem_lock.acquire()
        os.lseek(self.mem_fd, start, 0)
        data = os.read(self.mem_fd, stop-start)
        self.mem_lock.release()
        return array.array('B',data)
            
    def __setitem__(self,index,value):
        if isinstance(index,slice):
            (start,stop) = (index.start,index.stop) if index.start < index.stop else (index.stop,index.start)
        else:
            (start,stop) = (index,index)
        self.mem_lock.acquire()
        os.lseek(self.mem_fd, start, 0)
        os.write(self.mem_fd, value)
        self.mem_lock.release()

    def write(self,namespace,addr,data):
        assert namespace in ('pci_cl_data', 'pci_cl_ctrl', 'ddr')
        if namespace == 'ddr':
            self.mem_lock.acquire()
            os.lseek(self.mem_fd, addr, 0)
            os.write(self.mem_fd, data)
            self.mem_lock.release()
            return addr
        
        addr_tmp = addr
        if type(data) != int and type(data) != np.int32 and type(data) != np.int16 and type(data) != np.int8:
            for d in data:addr_tmp = self.write(namespace,addr_tmp,d)
            return addr_tmp
        else:
            self.axi_sync_q.put(('write',namespace,addr_tmp,data,None))
            return addr_tmp+4

    def read(self,namespace,addr,size=None):
        assert namespace in ('pci_cl_data', 'pci_cl_ctrl', 'ddr')
        if namespace == 'ddr':
            self.mem_lock.acquire()
            os.lseek(self.mem_fd, addr, 0)
            data = os.read(self.mem_fd, int(size))
            self.mem_lock.release()
            self.entity._log.debug('ddr read,namespace={},addr={:x},size={},data={}'.format(namespace,addr,size,data))
            return data

        self.axi_sync_q.put(('read',namespace,addr,None,size))
        self.entity._log.debug('axi read,namespace={},addr={:x},size={},data={}'.format(namespace,addr,size,None))
        #while True:
        #    if self.axi_sync_read_d.qsize() > 0:
        #        break
        #    else:
        #        sleep(0.01)
        data = self.axi_sync_read_d.get()
        self.entity._log.debug('axi read,namespace={},addr={:x},size={},data={}'.format(namespace,addr,size,data))
        return data

    async def axiWriteRead(self):
        while True:
            if self.axi_sync_q.qsize() > 0:
                op,namespace,addr,data,size = self.axi_sync_q.get()
                self.entity._log.debug('axi {},namespace={},addr={:x},data={},size={}'.format(op,namespace,addr,data,size))
                if namespace == 'pci_cl_ctrl':
                    if op == 'read':
                        data = await self.axi_pci_cl_ctrl.read(addr)
                        self.axi_sync_read_d.put(data.get_value())
                    elif op == 'write':
                        await self.axi_pci_cl_ctrl.write(addr,int(data))
                    else:
                        raise AssertionError
                elif namespace == 'pci_cl_data':
                    if op == 'read':
                        r = []
                        for i in range(0,size,4):
                            data = await self.axi_pci_cl_data.read(addr+(i*4))
                            r.append(data.get_value())
                        self.axi_sync_read_d.put(np.array(array.array('i',r)))
                    elif op == 'write':
                        await self.axi_pci_cl_data.write(addr,int(data))
                    else:
                        raise AssertionError
                else:
                    raise AssertionError
            else:
                await RisingEdge(self.entity.clk)
