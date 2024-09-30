`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/02 09:19:21
// Design Name: 
// Module Name: s2mm_tp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tp #(
    parameter integer  NUM_TAGS                     = 2,
    parameter integer  ADDR_WIDTH                   = 42,
    parameter integer  ARRAY_N                      = 2,
    parameter integer  ARRAY_M                      = 2,

  // Precision
    parameter integer  DATA_WIDTH                   = 16,
    parameter integer  BIAS_WIDTH                   = 32,
    parameter integer  ACC_WIDTH                    = 64,

  // Buffers
    parameter integer  IBUF_CAPACITY_BITS           = ARRAY_N * DATA_WIDTH * 2048,
    parameter integer  WBUF_CAPACITY_BITS           = ARRAY_N * ARRAY_M * DATA_WIDTH * 512,
    parameter integer  OBUF_CAPACITY_BITS           = ARRAY_M * ACC_WIDTH * 2048,
    parameter integer  BBUF_CAPACITY_BITS           = ARRAY_M * BIAS_WIDTH * 2048,

  // Buffer Addr Width
    parameter integer  IBUF_ADDR_WIDTH              = $clog2(IBUF_CAPACITY_BITS / ARRAY_N / DATA_WIDTH),
    parameter integer  WBUF_ADDR_WIDTH              = $clog2(WBUF_CAPACITY_BITS / ARRAY_N / ARRAY_M / DATA_WIDTH),
    parameter integer  OBUF_ADDR_WIDTH              = $clog2(OBUF_CAPACITY_BITS / ARRAY_M / ACC_WIDTH),
    parameter integer  BBUF_ADDR_WIDTH              = $clog2(BBUF_CAPACITY_BITS / ARRAY_M / BIAS_WIDTH),

  // Instructions
    parameter integer  INST_ADDR_WIDTH              = 32,
    parameter integer  INST_DATA_WIDTH              = 32,
    parameter integer  INST_WSTRB_WIDTH             = INST_DATA_WIDTH / 8,
    parameter integer  INST_BURST_WIDTH             = 8,
    parameter integer  LOOP_ITER_W                  = 16,
    parameter integer  ADDR_STRIDE_W                = 32,
    parameter integer  MEM_REQ_W                    = 16,
    parameter integer  BUF_TYPE_W                   = 2,
    parameter integer  LOOP_ID_W                    = 5,
  // AGU
    parameter integer  OFFSET_W                     = ADDR_WIDTH,
  // AXI
    parameter integer  AXI_ADDR_WIDTH               = 42,
    parameter integer  AXI_ID_WIDTH                 = 1,
    parameter integer  AXI_BURST_WIDTH              = 8,
    parameter integer  TID_WIDTH                    = 4,
    parameter integer  IBUF_AXI_DATA_WIDTH          = 256,
    parameter integer  IBUF_WSTRB_W                 = IBUF_AXI_DATA_WIDTH/8,
    parameter integer  WBUF_AXI_DATA_WIDTH          = 64,
    parameter integer  WBUF_WSTRB_W                 = WBUF_AXI_DATA_WIDTH/8,
    parameter integer  OBUF_AXI_DATA_WIDTH          = 256,
    parameter integer  OBUF_WSTRB_W                 = OBUF_AXI_DATA_WIDTH/8,
    parameter integer  PU_AXI_DATA_WIDTH            = 256,
    parameter integer  PU_WSTRB_W                   = PU_AXI_DATA_WIDTH/8,
    parameter integer  BBUF_AXI_DATA_WIDTH          = 256,
    parameter integer  BBUF_WSTRB_W                 = BBUF_AXI_DATA_WIDTH/8,
  // AXI-Lite
    parameter integer  CTRL_ADDR_WIDTH              = 32,
    parameter integer  CTRL_DATA_WIDTH              = 32,
    parameter integer  CTRL_WSTRB_WIDTH             = CTRL_DATA_WIDTH/8,
  // Instruction Mem
    parameter integer  IMEM_ADDR_W                  = 7,
  // Systolic Array
    parameter integer  TAG_W                        = $clog2(NUM_TAGS),
    parameter          DTYPE                        = "FXP", // FXP for dnnweaver2, FP32 for single precision, FP16 for half-precision
    parameter integer  WBUF_DATA_WIDTH              = ARRAY_N * ARRAY_M * DATA_WIDTH,
    parameter integer  BBUF_DATA_WIDTH              = ARRAY_M * BIAS_WIDTH,
    parameter integer  IBUF_DATA_WIDTH              = ARRAY_N * DATA_WIDTH,
    parameter integer  OBUF_DATA_WIDTH              = ARRAY_M * ACC_WIDTH,

  // Buffer Addr width for PU access to OBUF
    parameter integer  PU_OBUF_ADDR_WIDTH           = OBUF_ADDR_WIDTH + $clog2(OBUF_DATA_WIDTH / OBUF_AXI_DATA_WIDTH),
    parameter integer  VIDEO_IN_WIDTH               = 24
)(
      
    );
    integer tt;
    wire      led;
//always #10  force  uut.clk =    ~uut.clk;
reg bvalid;
//always @(posedge uut.clk) bvalid <= uut.cl_ddr0_wlast;
   reg  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr0_araddr;
    reg  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr0_arlen;
    reg  [ 3                    -1 : 0 ]        cl_ddr0_arsize;
    reg  [ 2                    -1 : 0 ]        cl_ddr0_arburst;
    reg                                         cl_ddr0_arvalid;
    reg  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr0_arid;
    wire                                         cl_ddr0_arready,cl_ddr0_arready0;
  // Master Interface Read Data
    wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        cl_ddr0_rdata;
    wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr0_rid;
    wire  [ 2                    -1 : 0 ]        cl_ddr0_rresp;
    wire                                         cl_ddr0_rlast,cl_ddr0_rlast0;
    wire                                         cl_ddr0_rvalid,cl_ddr0_rvalid0;
    reg                                          cl_ddr0_rready,cl_ddr0_rready0;
    
    wire  clk,reset;
initial begin
//force uut.reset  =1;
//@(posedge uut.clk);
//@(posedge uut.clk);
//@(posedge uut.clk);
//@(posedge uut.clk);
//force uut.reset  =0;
////force uut.cl_ddr0_wready  =1;
////force uut.cl_ddr0_bvalid  =bvalid;
//////force uut.cl_ddr0_bresp   =0;
////force uut.cl_ddr0_awready  =1;
end 
//  initial begin
//   clk ='d0;
//   reset ='d1; 
//   repeat(5) @(posedge clk);
//   reset ='d0; 
// end
// always #10 clk <= ~clk;   
initial begin
cl_ddr0_arvalid ='d0;
cl_ddr0_arid    ='d0;
cl_ddr0_arburst ='d1;
cl_ddr0_arlen   ='d0;
cl_ddr0_arsize  ='d5;
cl_ddr0_araddr  =42'd0;
cl_ddr0_rready  ='d0;
wait(reset  =='d0);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
//force uut.reset  =0;
cl_ddr0_araddr  =42'h000_1000;
cl_ddr0_arlen   ='d4;
cl_ddr0_arvalid ='d1;
//cl_ddr0_arvalid0 ='d1;
wait(cl_ddr0_arready);
@(posedge clk);
cl_ddr0_arvalid ='d0;
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
cl_ddr0_rready ='d1;
@(posedge clk);
wait(cl_ddr0_rlast);
//$stop;
//force uut.cl_ddr0_bvalid  =bvalid;
////force uut.cl_ddr0_bresp   =0;
//force uut.cl_ddr0_awready  =1;
end

design_1 uut
       (.cl_ddr0_araddr(cl_ddr0_araddr),
        .cl_ddr0_arburst(cl_ddr0_arburst),
        .cl_ddr0_arcache('d3),
        .cl_ddr0_arid(cl_ddr0_arid),
        .cl_ddr0_arlen(cl_ddr0_arlen),
        .cl_ddr0_arlock('d0),
        .cl_ddr0_arprot('d0),
        .cl_ddr0_arqos('d0),
        .cl_ddr0_arready(cl_ddr0_arready),
        .cl_ddr0_arsize(cl_ddr0_arsize),
        .cl_ddr0_arvalid(cl_ddr0_arvalid),
//        .cl_ddr0_awaddr(cl_ddr0_awaddr),
//        .cl_ddr0_awburst(cl_ddr0_awburst),
        .cl_ddr0_awcache('d3),
//        .cl_ddr0_awid(cl_ddr0_awid),
//        .cl_ddr0_awlen(cl_ddr0_awlen),
        .cl_ddr0_awlock('d0),
        .cl_ddr0_awprot('d0),
        .cl_ddr0_awqos('d0),
//        .cl_ddr0_awready(cl_ddr0_awready),
//        .cl_ddr0_awsize(cl_ddr0_awsize),
//        .cl_ddr0_awvalid(cl_ddr0_awvalid),
//        .cl_ddr0_bid(cl_ddr0_bid),
//        .cl_ddr0_bready(cl_ddr0_bready),
//        .cl_ddr0_bresp(cl_ddr0_bresp),
//        .cl_ddr0_bvalid(cl_ddr0_bvalid),
        .cl_ddr0_rdata(cl_ddr0_rdata),
        .cl_ddr0_rid(cl_ddr0_rid),
        .cl_ddr0_rlast(cl_ddr0_rlast),
        .cl_ddr0_rready(cl_ddr0_rready),
        .cl_ddr0_rresp(cl_ddr0_rresp),
        .cl_ddr0_rvalid(cl_ddr0_rvalid),
//        .cl_ddr0_wdata(cl_ddr0_wdata),
//        .cl_ddr0_wlast(cl_ddr0_wlast),
//        .cl_ddr0_wready(cl_ddr0_wready),
//        .cl_ddr0_wstrb(cl_ddr0_wstrb),
//        .cl_ddr0_wvalid(cl_ddr0_wvalid),
        .clk(clk),
        .reset(reset));
        
//   //wire                                         cl_ddr0_arready0;
//   axi_bram_ctrl_0   uutest
//   (.s_axi_aclk(    clk                                   ),
//    .s_axi_aresetn(   ~reset                                   ),
//   // .s_axi_awaddr(                                       ),
//   // .s_axi_awlen(                                       ),
//   // .s_axi_awsize(                                       ),
//   // .s_axi_awburst(                                       ),
//   // .s_axi_awlock(                                       ),
//   // .s_axi_awcache(                                       ),
//   // .s_axi_awprot(                                       ),
//   // .s_axi_awvalid(                                       ),
//   // .s_axi_awready(                                       ),
//   // .s_axi_wdata(                                       ),
//   // .s_axi_wstrb(                                       ),
//   // .s_axi_wlast(                                       ),
//   // .s_axi_wvalid(                                       ),
//   // .s_axi_wready(                                       ),
//   // .s_axi_bresp(                                       ),
//   // .s_axi_bvalid(                                       ),
//   // .s_axi_bready(                                       ),
//    .s_axi_araddr(    cl_ddr0_araddr[14:0]                                   ),
//    .s_axi_arlen(     cl_ddr0_arlen                                 ),
//    .s_axi_arsize(    cl_ddr0_arsize                                   ),
//    .s_axi_arburst(   cl_ddr0_arburst                                    ),
//    .s_axi_arlock(    'd0                                   ),
//    .s_axi_arcache(   'd3                                    ),
//    .s_axi_arprot(    'd0                                   ),
//    .s_axi_arvalid(   cl_ddr0_arvalid                                    ),
//    .s_axi_arready(   cl_ddr0_arready0                                    ),
//    .s_axi_rdata(                                       ),
//    .s_axi_rresp(                                       ),
//    .s_axi_rlast(     cl_ddr0_rlast0                                 ),
//    .s_axi_rvalid(    cl_ddr0_rvalid0                                   ),
//    .s_axi_rready(	  cl_ddr0_rready0																		)
//    );    
//video_up uut(led);
// localparam tt_data_WIDTH =64;
// reg         reset,clk;
// reg[tt_data_WIDTH-1:0]     rt_data;
// reg           rt_req;
// wire[255:0]   wt_data;
// wire          wt_req;
 
// initial begin
//   clk ='d0;
//   reset ='d1; 
//   repeat(5) @(posedge clk);
//   reset ='d0; 
// end
// always #10 clk <= ~clk;
 
//  always @(posedge clk)begin
//   if(reset) rt_data <= 'd0;
//    else     rt_data <= 'd1 + rt_data;
//  end
//  always @(posedge clk)begin
//   if(reset) rt_req <= 'd0;
//    else     rt_req <= 'd1;
//  end
 
// fifo_16to256 #(
// .IN_WIDTH(tt_data_WIDTH)
// ) uut(
// .clk(clk),
// .reset(reset),
 
// .i_wr_req(rt_req),
// .i_data(rt_data),
 
// //out
// .o_rd_req(wt_req),
// .o_data(wt_data)
// );
//   tt = $time;
//  if($time >1000) $stop;
endmodule

