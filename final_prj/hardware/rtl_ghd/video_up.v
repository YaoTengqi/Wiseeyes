`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/29 10:52:03
// Design Name: 
// Module Name: video_up
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
//`define TESTMAXIEN

module video_up #(
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
)
(
      output                  o_led
      
    );
     localparam lp_AUDO_FROM_DDRBASE            = 42'h3000_0000;
     localparam lp_HDWARE_2_DDRBASE             = 42'h3500_0000;
     localparam lp_AUDO_2_DDRBASE               = 42'h3000_0000;
     localparam TX_SIZE_WIDTH                = 8;      
     
     
    wire  [ VIDEO_IN_WIDTH       -1 : 0 ]        i_video_data;
    wire                                         i_video_valid;
    wire                                         i_video_hs;
    wire                                         i_video_vs;
   // CL_wrapper -> DDR0 AXI4 interface
  // Master Interface Write Address
   
  

    //vidoe 
                                
  wire [41:0]cl_ddr0_araddr;
  wire [1:0]cl_ddr0_arburst;
  wire [3:0]cl_ddr0_arcache;
  wire [0:0]cl_ddr0_arid;
  wire [7:0]cl_ddr0_arlen;
  wire [0:0]cl_ddr0_arlock;
  wire [2:0]cl_ddr0_arprot;
  wire [3:0]cl_ddr0_arqos;
  wire cl_ddr0_arready;
  wire [2:0]cl_ddr0_arsize;
  wire cl_ddr0_arvalid;
  wire [41:0]cl_ddr0_awaddr;
  wire [1:0]cl_ddr0_awburst;
  wire [3:0]cl_ddr0_awcache;
  wire [0:0]cl_ddr0_awid;
  wire [7:0]cl_ddr0_awlen;
  wire [0:0]cl_ddr0_awlock;
  wire [2:0]cl_ddr0_awprot;
  wire [3:0]cl_ddr0_awqos;
  wire cl_ddr0_awready;
  wire [2:0]cl_ddr0_awsize;
  wire cl_ddr0_awvalid;
  wire [0:0]cl_ddr0_bid;
  wire cl_ddr0_bready;
  wire [1:0]cl_ddr0_bresp;
  wire cl_ddr0_bvalid;
  wire [255:0]cl_ddr0_rdata;
  wire [0:0]cl_ddr0_rid;
  wire cl_ddr0_rlast;
  wire cl_ddr0_rready;
  wire [1:0]cl_ddr0_rresp;
  wire cl_ddr0_rvalid;
  wire [255:0]cl_ddr0_wdata;
  wire cl_ddr0_wlast;
  wire cl_ddr0_wready;
  wire [31:0]cl_ddr0_wstrb;
  wire cl_ddr0_wvalid;
  wire clk;
  wire [0:0]reset;

  dnn_accl_15eg dnn_accl_15eg_i
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
        .cl_ddr0_awaddr(cl_ddr0_awaddr),
        .cl_ddr0_awburst(cl_ddr0_awburst),
        .cl_ddr0_awcache('d3),
        .cl_ddr0_awid(cl_ddr0_awid),
        .cl_ddr0_awlen(cl_ddr0_awlen),
        .cl_ddr0_awlock('d0),
        .cl_ddr0_awprot('d0),
        .cl_ddr0_awqos('d0),
        .cl_ddr0_awready(cl_ddr0_awready),
        .cl_ddr0_awsize(cl_ddr0_awsize),
        .cl_ddr0_awvalid(cl_ddr0_awvalid),
        .cl_ddr0_bid(cl_ddr0_bid),
        .cl_ddr0_bready(cl_ddr0_bready),
        .cl_ddr0_bresp(cl_ddr0_bresp),
        .cl_ddr0_bvalid(cl_ddr0_bvalid),
        .cl_ddr0_rdata(cl_ddr0_rdata),
        .cl_ddr0_rid(cl_ddr0_rid),
        .cl_ddr0_rlast(cl_ddr0_rlast),
        .cl_ddr0_rready(cl_ddr0_rready),
        .cl_ddr0_rresp(cl_ddr0_rresp),
        .cl_ddr0_rvalid(cl_ddr0_rvalid),
        .cl_ddr0_wdata(cl_ddr0_wdata),
        .cl_ddr0_wlast(cl_ddr0_wlast),
        .cl_ddr0_wready(cl_ddr0_wready),
        .cl_ddr0_wstrb(cl_ddr0_wstrb),
        .cl_ddr0_wvalid(cl_ddr0_wvalid),
        .clk(clk),
        .reset(reset));
         
 assign              o_led  =       i_video_vs;          
 //
 wire [23:0]  pixel_data_i;

//RGB接口
wire                    clk_cam;
wire                    w_hs;  
wire                    w_vs;  
wire                    w_de;  
wire [23:0]             w_video_pix	;

clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(clk_cam),     // output clk_out1
    // Status and control signals
    .reset(reset), // input reset
    .locked(),       // output locked
   // Clock in ports
    .clk_in1(clk)      // input clk_in1
);

//video2ddr_base_gen #(
//    .TX_SIZE_WIDTH                   (TX_SIZE_WIDTH                  )
//)
//  u_video_s2mm(
//    .clk(                                 clk),//
//    .reset(                             reset),//
//    .i_video2ddr_ctl(                    2'd3),
//    .i_Video2ddr_base_a(   lp_Video2ddr_base0),
//    .i_Video2ddr_base_b(   lp_Video2ddr_base1),
//    .i_fs_start(                         w_vs),
//    //.i_hs(video_hs_o),
//    .i_de(                               w_de),
//    .i_clk_cam(                       clk_cam),
//    .i_pix_data(                  w_video_pix),
//    .o_fbptr(                                ),
    
//    .o_s2mem_size(              w_s2mem_size            ) ,
//    .o_s2mem_addr(              w_s2mem_addr            ) ,
//    .i_s2mem_addr_req(          w_s2mem_addr_req        ) ,
//    .i_s2mem_addr_done(         w_s2mem_addr_done       ) ,
//    .o_s2mem_addr_ready(        w_s2mem_addr_ready      ) ,
    
    
//    .o_s2mem_data(              w_s2mem_data            ) ,
//    .i_s2mem_data_req(          w_s2mem_data_req        ) ,
//   . o_s2mem_data_ready(        w_s2mem_data_ready      )    
////    .o_mem_read_data(         w_mem_read_data),
////    .o_mem_read_size(         w_mem_read_size),
////    .o_mem_read_addr(         w_mem_read_addr),
////    .o_mem_read_req(           w_mem_read_req)
// );   
 //cam0 if
 sdi_inout_top u_video_driver(
    .clk_cam	(clk_cam),
    .reset		(reset	),
    //.pixel_data_i	(pixel_data_i),   //像素点数�?
					
    //RGB接口       
    .video_hs_o		(	),     //行同步信�?
    .video_vs_o		(w_vs	),     //场同步信�?
    .video_de_o		(w_de	),     //数据使能
    .video_rgb_o	(w_video_pix),    //RGB888颜色数据
	.module_data_de_o()				
    //.pixel_xpos_o	(pixel_xpos_o),   //像素点横坐标
    //.pixel_ypos_o   (pixel_ypos_o) //像素点纵坐标
);   
    
  audo_dma #(
    .AXI_ADDR_WIDTH(                   AXI_ADDR_WIDTH     ),
    .IN_DATA_WIDTH(                     64                ),
    //parameter          MAX_HARDWARE_SIZE            = 64*1024*1024,
    .TX_SIZE_WIDTH(                    8                  ),     
    .AXI_DATA_WIDTH(               BBUF_AXI_DATA_WIDTH    ), 
    .AXI_BURST_WIDTH(              AXI_BURST_WIDTH        ),
    .BURST_LEN(                    1 << AXI_BURST_WIDTH   ),
    
    .AXI_ARID(                      0                     ),
    .AXI_RID(                       0                     ),
    .AXI_AWID(                      0                     ),    
    .MEM_ID(                        0                     ),
    
    .MEM_REQ_W(                    MEM_REQ_W              ),
    .MEM_ADDR_W(                   11                     ),
    
    .AXI_SUPPORTS_WRITE(           1                      ),
    .AXI_SUPPORTS_READ(            1                      ),   
   // .C_OFFSET_WIDTH(              C_OFFSET_WIDTH        ),
   // .WSTRB_W(                     WSTRB_W               ),
    .AXI_ID_WIDTH(                 AXI_ID_WIDTH           ),
    .HARDWARE_S2MM_EN(               0                    )
)u_mic_4ch
( //golble
    .clk(                     clk                         ),
    .reset(                   reset                       ),
    //sensor 
    .i_de(                   'd1                          ),
    .i_hdware(                'd0                         ),
    .i_data(        64'h1234_5678_9ABC_DEF1               ),//64
    
    //to nxt memory
    .o_mem_wadd(                                          ),//  [MEM_ADDR_W-1:0]                    o_mem_wadd,
    .o_mem_wdata(                                         ),//  [AXI_DATA_WIDTH-1:0]                    o_mem_wdata,
    .o_mem_wreq(                                          ),//o_mem_wreq,
    //**************************************************
    // Master Interface Write Address
    .o_m_axi_awaddr(      cl_ddr0_awaddr                  ),
    .o_m_axi_awlen(       cl_ddr0_awlen                   ),
    .o_m_axi_awsize(      cl_ddr0_awsize                  ),
    .o_m_axi_awburst(     cl_ddr0_awburst                 ),
    .o_m_axi_awvalid(     cl_ddr0_awvalid                 ),
    .i_m_axi_awready(     cl_ddr0_awready                 ),
    // Master Interface Write Data
    .o_m_axi_wdata(       cl_ddr0_wdata                   ),
    .o_m_axi_wstrb(       cl_ddr0_wstrb                   ),
    .o_m_axi_wlast(      cl_ddr0_wlast                    ),
    .o_m_axi_wvalid(     cl_ddr0_wvalid                   ),
    .i_m_axi_wready(     cl_ddr0_wready                   ),
    // Master Interface Write Response
    .i_m_axi_bresp(      cl_ddr0_bresp                    ),
    .i_m_axi_bvalid(     cl_ddr0_bvalid                   ),
    .o_m_axi_bready(     cl_ddr0_bready                   ),
    // Master Interface Read Address
    .o_m_axi_arid(        cl_ddr0_arid                    ),
    .o_m_axi_araddr(       cl_ddr0_araddr                 ),
    .o_m_axi_arlen(        cl_ddr0_arlen                  ),
    .o_m_axi_arsize(       cl_ddr0_arsize                 ),
    .o_m_axi_arburst(     cl_ddr0_arburst                 ),
    .o_m_axi_arvalid(     cl_ddr0_arvalid                 ),
    .o_m_axi_arready(     cl_ddr0_arready                 ),
    // Master Interface Read Data
    .i_m_axi_rid(         cl_ddr0_rid                     ),
    .i_m_axi_rdata(       cl_ddr0_rdata                   ),
    .i_m_axi_rresp(       cl_ddr0_rresp                   ),
    .i_m_axi_rlast(       cl_ddr0_rlast                   ),
    .i_m_axi_rvalid(      cl_ddr0_rvalid                  ),
    .o_m_axi_rready(      cl_ddr0_rready                  ),
    //host ctrl
        //bit0:to ddr en;b1:DNN in: 0:local 1:from ddr;
    
    .i_ctl(                   'd3                          ),
    .i_mm2s_ddrbase(          lp_AUDO_FROM_DDRBASE         ),//address base ab0
    .i_s2mm_ddrbase(          lp_AUDO_2_DDRBASE            ),//address base ab0    
    .i_s2mm_ddrbase_hardware( lp_HDWARE_2_DDRBASE          ),//address base hardware
    .o_s2mm_int_posedge(                                   ),
    .o_mm2s_int_posedge(                                   ),
    .o_hdware_int_posedge(                                 )
    );  
    
endmodule
