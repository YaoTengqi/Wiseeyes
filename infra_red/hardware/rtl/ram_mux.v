/*
        8bit/16bit共用一个RAM，通过此MUX进行选择
*/
`timescale 1ns / 1ns
module ram_mux #(
    parameter integer  AXI_DATA_WIDTH               = 256,
    parameter integer  INST_W                       = 32,
    parameter integer  INST_ADDR_W                  = 5,
    parameter integer  IFIFO_ADDR_W                 = 10,
    parameter integer  BUF_TYPE_W                   = 2,
    parameter integer  OP_CODE_W                    = 5,
    parameter integer  OP_SPEC_W                    = 6,
    parameter integer  LOOP_ID_W                    = 5,

  // Systolic Array
    parameter integer  TAG_W                        = $clog2(NUM_TAGS),
    parameter integer  ARRAY_N                      = 32,
    parameter integer  ARRAY_M                      = 32,

  // Precision
    parameter integer  DATA_WIDTH                   = 16,
    parameter integer  BIAS_WIDTH                   = 32,
    parameter integer  ACC_WIDTH                    = 64,

  // Buffers
    parameter integer  WEIGHT_ROW_NUM               = 1,                                                                                                                       //edit by sy 0513
    parameter integer  NUM_TAGS                     = 2,
    parameter integer  IBUF_CAPACITY_BITS           = ARRAY_N * DATA_WIDTH * 6144 / NUM_TAGS,
    parameter integer  WBUF_CAPACITY_BITS           = ARRAY_M * WEIGHT_ROW_NUM * DATA_WIDTH * 2048 / NUM_TAGS,
    parameter integer  OBUF_CAPACITY_BITS           = ARRAY_M * ACC_WIDTH * 4096 / NUM_TAGS,                                            //edit by sy 0513
    parameter integer  BBUF_CAPACITY_BITS           = ARRAY_M * BIAS_WIDTH * 512 / NUM_TAGS,

  // Buffer Addr Width
    parameter integer  IBUF_ADDR_WIDTH              = $clog2(IBUF_CAPACITY_BITS / ARRAY_N / DATA_WIDTH),
    parameter integer  WBUF_ADDR_WIDTH              = $clog2(WBUF_CAPACITY_BITS / WEIGHT_ROW_NUM / ARRAY_M / DATA_WIDTH),   //edit by sy 0513
    parameter integer  OBUF_ADDR_WIDTH              = $clog2(OBUF_CAPACITY_BITS / ARRAY_M / ACC_WIDTH),
    parameter integer  BBUF_ADDR_WIDTH              = $clog2(BBUF_CAPACITY_BITS / ARRAY_M / BIAS_WIDTH),

  // AXI DATA
    parameter integer  AXI_ADDR_WIDTH               = 42,
    parameter integer  AXI_BURST_WIDTH              = 8,
    parameter integer  IBUF_AXI_DATA_WIDTH          = 256,
    parameter integer  IBUF_WSTRB_W                 = IBUF_AXI_DATA_WIDTH/8,
    parameter integer  OBUF_AXI_DATA_WIDTH          = 256,
    parameter integer  OBUF_WSTRB_W                 = OBUF_AXI_DATA_WIDTH/8,
    parameter integer  PU_AXI_DATA_WIDTH            = 256,
    parameter integer  PU_WSTRB_W                   = PU_AXI_DATA_WIDTH/8,
    parameter integer  WBUF_AXI_DATA_WIDTH          = 256,
    parameter integer  WBUF_WSTRB_W                 = WBUF_AXI_DATA_WIDTH/8,
    parameter integer  BBUF_AXI_DATA_WIDTH          = 256,
    parameter integer  BBUF_WSTRB_W                 = BBUF_AXI_DATA_WIDTH/8,
    parameter integer  AXI_ID_WIDTH                 = 1,
  // AXI Instructions
    parameter integer  INST_ADDR_WIDTH              = 32,
    parameter integer  INST_DATA_WIDTH              = 32,
    parameter integer  INST_WSTRB_WIDTH             = INST_DATA_WIDTH/8,
    parameter integer  INST_BURST_WIDTH             = 8,
  // AXI-Lite
    parameter integer  CTRL_ADDR_WIDTH              = 32,
    parameter integer  CTRL_DATA_WIDTH              = 32,
    parameter integer  CTRL_WSTRB_WIDTH             = CTRL_DATA_WIDTH/8,

    parameter integer  TAG_BUF_ADDR_W_IBUF               = IBUF_ADDR_WIDTH + TAG_W,
    parameter integer  TAG_BUF_ADDR_W_BBUF               = BBUF_ADDR_WIDTH + TAG_W,
    parameter integer  TAG_BUF_ADDR_W_WBUF               = WBUF_ADDR_WIDTH + TAG_W,
    parameter integer  TAG_BUF_ADDR_W_OBUF               = OBUF_ADDR_WIDTH + TAG_W,
    parameter integer  ARRAY_N_WBUF = WEIGHT_ROW_NUM //edit by sy
)(
  input wire clk,
  input wire reset,
// add for 8bit/16bit ibuf
  input wire [ 14       -1 : 0 ]        tag_mem_write_addr_ibuf,
  input wire mem_write_req_in_ibuf,
  input wire  [256  -1 : 0]                                mem_write_data_in_ibuf,
  input wire [ 13       -1 : 0 ]        tag_buf_read_addr_ibuf,
  input  wire                                         buf_read_req_ibuf,
  output wire [ 512       -1 : 0 ]        _buf_read_data_ibuf,

    // add for 8bit/16bit bbuf
    input wire [ 11       -1 : 0 ]        tag_mem_write_addr_bbuf,
    input wire                                        mem_write_req_bbuf,
    input wire [ 256       -1 : 0 ]        mem_write_data_bbuf,
    input wire [ 9       -1 : 0 ]        tag_buf_read_addr_bbuf,
    input  wire                                         buf_read_req_bbuf,
    output wire [ 1024       -1 : 0 ]        _buf_read_data_bbuf,

   // add for 8bit/16bit wbuf
   input wire [ 12       -1 : 0 ]        tag_mem_write_addr_wbuf,
   input wire                                        mem_write_req_dly_wbuf,
   input wire [ 256       -1 : 0 ]        _mem_write_data_wbuf,
   input wire [ 11       -1 : 0 ]        tag_buf_read_addr_wbuf,
   input  wire                                         buf_read_req_wbuf,
   output wire  [ 512       -1 : 0 ]        _buf_read_data_wbuf,

   // add for 8bit/16bit obuf
    input wire [ 15       -1 : 0 ]        tag_mem_write_addr_obuf,
    input wire                                        mem_write_req_obuf,
    input wire [ 256       -1 : 0 ]        mem_write_data_obuf,
    input wire [ 15       -1 : 0 ]        tag_mem_read_addr_obuf,
    input wire                                        mem_read_req_obuf,
    output wire [ 256       -1 : 0 ]        mem_read_data_obuf,
    output wire [ 2048       -1 : 0 ]        pu_read_data_obuf,
    input wire [ 12       -1 : 0 ]        tag_buf_write_addr_obuf,
    input wire   buf_write_req_obuf,
    input wire  [ 2048       -1 : 0 ]        buf_write_data_obuf,
    input wire [ 12       -1 : 0 ]        tag_buf_read_addr_obuf,
    input  wire                                         buf_read_req_obuf,
    output wire [ 2048       -1 : 0 ]        _buf_read_data_obuf
);

ibuf #( 
    .TAG_W                          ( TAG_W                          ),
    .BUF_ADDR_WIDTH                 ( TAG_BUF_ADDR_W_IBUF                 ),
    .ARRAY_N                        ( ARRAY_N                        ),
    .MEM_DATA_WIDTH                 ( AXI_DATA_WIDTH                 ),
    .DATA_WIDTH                     ( DATA_WIDTH                    )
    ) ibuf_ram (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .mem_write_addr                 ( tag_mem_write_addr_ibuf             ),
    .mem_write_req                  ( mem_write_req_in_ibuf                  ),
    .mem_write_data                 ( mem_write_data_in_ibuf                ),//edit by pxq 0816
    .buf_read_addr                  ( tag_buf_read_addr_ibuf              ),
    .buf_read_req                   ( buf_read_req_ibuf                   ),
    .buf_read_data                  ( _buf_read_data_ibuf                 )
);

bbuf #(
   // Internal Parameters
    .TAG_W                          ( TAG_W                          ),
    .BUF_ADDR_WIDTH                 ( TAG_BUF_ADDR_W_BBUF                 ),
    .ARRAY_M                        ( ARRAY_M                        ),
    .MEM_DATA_WIDTH                 ( AXI_DATA_WIDTH                 ),
    .DATA_WIDTH                     ( 32                     )
) bbuf_ram (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .mem_write_addr                 ( tag_mem_write_addr_bbuf             ),
    .mem_write_req                  ( mem_write_req_bbuf                  ),
    .mem_write_data                 ( mem_write_data_bbuf            ),
    .buf_read_addr                  ( tag_buf_read_addr_bbuf              ),
    .buf_read_req                   ( buf_read_req_bbuf                   ),
    .buf_read_data                  ( _buf_read_data_bbuf                 )
);

wbuf #(
    .TAG_W                          ( TAG_W                          ),
    .BUF_ADDR_WIDTH                 ( TAG_BUF_ADDR_W_WBUF                 ),
    .ARRAY_N                        ( ARRAY_N_WBUF                        ),
    .ARRAY_M                        ( ARRAY_M                        ),
    .MEM_DATA_WIDTH                 ( AXI_DATA_WIDTH                 ),
    .DATA_WIDTH                     ( DATA_WIDTH                     )        
) wbuf_ram (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .mem_write_addr                 ( tag_mem_write_addr_wbuf             ),
    .mem_write_req                  ( mem_write_req_dly_wbuf              ),//edit by sy 0820
    .mem_write_data                 ( _mem_write_data_wbuf                ),//edit by sy 0820
    .buf_read_addr                  ( tag_buf_read_addr_wbuf              ),
    .buf_read_req                   ( buf_read_req_wbuf                   ),
    .buf_read_data                  ( _buf_read_data_wbuf                 )
);

obuf #(
    .TAG_W                          ( TAG_W                          ),
    .BUF_ADDR_WIDTH                 ( TAG_BUF_ADDR_W_OBUF                 ),
    .ARRAY_M                        ( ARRAY_M                        ),
    .MEM_DATA_WIDTH                 ( AXI_DATA_WIDTH                 ),
    .DATA_WIDTH                     ( 64                     )
) obuf_ram (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),    
    .mem_read_req                   ( mem_read_req_obuf                   ),
    .mem_read_addr                  ( tag_mem_read_addr_obuf              ),
    .mem_read_data                  ( mem_read_data_obuf                  ),
    .mem_write_req                  ( mem_write_req_obuf                  ),
    .mem_write_addr                 ( tag_mem_write_addr_obuf             ),
    .mem_write_data                 ( mem_write_data_obuf                 ),
    .pu_read_data                   ( pu_read_data_obuf                   ), //edit yt
    //.obuf_fifo_write_req_limit      ( obuf_fifo_write_req_limit      ), //edit yt
    .buf_write_addr                 ( tag_buf_write_addr_obuf             ),//edit by pxq
    .buf_write_req                  ( buf_write_req_obuf                  ),//edit by pxq
    .buf_write_data                 ( buf_write_data_obuf                 ),//edit by pxq
    .buf_read_addr                  ( tag_buf_read_addr_obuf              ),
    .buf_read_req                   ( buf_read_req_obuf                   ),
    .buf_read_data                  ( _buf_read_data_obuf                 )
  );

endmodule