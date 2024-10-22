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

module audo_up_top #(
    parameter integer  INST_W                       = 32,
    parameter integer  INST_ADDR_W                  = 5,
    parameter integer  IFIFO_ADDR_W                 = 10,
    parameter integer  BUF_TYPE_W                   = 2,
    parameter integer  OP_CODE_W                    = 5,
    parameter integer  OP_SPEC_W                    = 6,
    parameter integer  LOOP_ID_W                    = 5,

  // Systolic Array
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
    parameter integer  AXI_DATA_WIDTH               = 256,

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
  // AXI-Lite

  // Instruction Mem
    parameter integer  IMEM_ADDR_W                  = 12,
  // Systolic Array

    //parameter          DTYPE                        = "FXP", // FXP for dnnweaver2, FP32 for single precision, FP16 for half-precision
    //配置数据位宽
    parameter CONFIG_DATA_WIDTH = 8,

    //AXI参数
    parameter AXIS_DATA_WIDTH     = 32,
    parameter AXIS_ADDR_WIDTH     = 32,
    
    //inst from ddr max leng
    parameter integer  MAX_LENGTH_FROMDDR_B         = 1024*32,
    parameter integer  MAX_LENGTH_FROMDDR_WIDTH     = $clog2(MAX_LENGTH_FROMDDR_B),
    parameter integer  ASR_MIC_CH_NUM                    =1, //
    parameter integer  SL_MIC_CH_NUM                     =4,
    parameter integer  CAM0_SENSOR_DATA_WIDTH            =24
)
(
      output                  o_led,
          // ASR mic_if
    output                                              o_ws_asr,
	output                                              o_sck_asr,
	input[ASR_MIC_CH_NUM-1:0]                           i_sdi_asr,
    //cam0_if
    input                                               i_cam0_clk,
    input                                               i_cam0_vs,
    input                                               i_cam0_hs,
    input                                               i_cam0_de,
    input [CAM0_SENSOR_DATA_WIDTH-1:0]                  i_cam0_rgb,
    //cfg_cam0_if
    output                                               o_cam0_hpd,
    inout                                                io_cam0_hdmi_scl,
    inout                                                io_cam0_hdmi_sda,
    inout                                                io_cam0_cfg_scl,
    inout                                                io_cam0_cfg_sda,
    output                                               o_cam0_rstn 
      
    );
     wire [1:0]                                    i_ctl;                                      
     wire [AXI_ADDR_WIDTH-1:0]                      i_mm2s_vddn_ddrbase;//address base ab0     
     wire [MAX_LENGTH_FROMDDR_WIDTH-1:0]            i_mm2s_vddn_leng;//data lengthe            
     wire [AXI_ADDR_WIDTH-1:0]                      i_mm2s_addn_ddrbase;//address base ab0     
     wire [MAX_LENGTH_FROMDDR_WIDTH-1:0]            i_mm2s_addn_leng;//data lengthe     
     
    wire [1:0]                                            i_video2ddr_ctl;   //bit0:en,bit1:en_pingpangbuf: 
    wire [AXI_ADDR_WIDTH-1:0]                             i_hdwr2ddr_base;    //todo                        
    wire [AXI_ADDR_WIDTH-1:0]                             i_Video2ddr_base_a;//address base fb0             
    wire [AXI_ADDR_WIDTH-1:0]                             i_Video2ddr_base_b;//address base fb0              
     //mic_important poaaram
       

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
  wire [41:0]cl_ddr1_araddr;
  wire [1:0]cl_ddr1_arburst;
  wire [3:0]cl_ddr1_arcache;
  wire [0:0]cl_ddr1_arid;
  wire [7:0]cl_ddr1_arlen;
  wire [0:0]cl_ddr1_arlock;
  wire [2:0]cl_ddr1_arprot;
  wire [3:0]cl_ddr1_arqos;
  wire cl_ddr1_arready;
  wire [2:0]cl_ddr1_arsize;
  wire cl_ddr1_arvalid;
  wire [41:0]cl_ddr1_awaddr;
  wire [1:0]cl_ddr1_awburst;
  wire [3:0]cl_ddr1_awcache;
  wire [0:0]cl_ddr1_awid;
  wire [7:0]cl_ddr1_awlen;
  wire [0:0]cl_ddr1_awlock;
  wire [2:0]cl_ddr1_awprot;
  wire [3:0]cl_ddr1_awqos;
  wire cl_ddr1_awready;
  wire [2:0]cl_ddr1_awsize;
  wire cl_ddr1_awvalid;
  wire [0:0]cl_ddr1_bid;
  wire cl_ddr1_bready;
  wire [1:0]cl_ddr1_bresp;
  wire cl_ddr1_bvalid;
  wire [255:0]cl_ddr1_rdata;
  wire [0:0]cl_ddr1_rid;
  wire cl_ddr1_rlast;
  wire cl_ddr1_rready;
  wire [1:0]cl_ddr1_rresp;
  wire cl_ddr1_rvalid;
  wire [255:0]cl_ddr1_wdata;
  wire cl_ddr1_wlast;
  wire cl_ddr1_wready;
  wire [31:0]cl_ddr1_wstrb;
  wire cl_ddr1_wvalid;
  wire [41:0]cl_ddr2_araddr;
  wire [1:0]cl_ddr2_arburst;
  wire [3:0]cl_ddr2_arcache;
  wire [0:0]cl_ddr2_arid;
  wire [7:0]cl_ddr2_arlen;
  wire [0:0]cl_ddr2_arlock;
  wire [2:0]cl_ddr2_arprot;
  wire [3:0]cl_ddr2_arqos;
  wire cl_ddr2_arready;
  wire [2:0]cl_ddr2_arsize;
  wire cl_ddr2_arvalid;
  wire [41:0]cl_ddr2_awaddr;
  wire [1:0]cl_ddr2_awburst;
  wire [3:0]cl_ddr2_awcache;
  wire [0:0]cl_ddr2_awid;
  wire [7:0]cl_ddr2_awlen;
  wire [0:0]cl_ddr2_awlock;
  wire [2:0]cl_ddr2_awprot;
  wire [3:0]cl_ddr2_awqos;
  wire cl_ddr2_awready;
  wire [2:0]cl_ddr2_awsize;
  wire cl_ddr2_awvalid;
  wire [0:0]cl_ddr2_bid;
  wire cl_ddr2_bready;
  wire [1:0]cl_ddr2_bresp;
  wire cl_ddr2_bvalid;
  wire [255:0]cl_ddr2_rdata;
  wire [0:0]cl_ddr2_rid;
  wire cl_ddr2_rlast;
  wire cl_ddr2_rready;
  wire [1:0]cl_ddr2_rresp;
  wire cl_ddr2_rvalid;
  wire [255:0]cl_ddr2_wdata;
  wire cl_ddr2_wlast;
  wire cl_ddr2_wready;
  wire [31:0]cl_ddr2_wstrb;
  wire cl_ddr2_wvalid;
  wire [41:0]cl_ddr3_araddr;
  wire [1:0]cl_ddr3_arburst;
  wire [3:0]cl_ddr3_arcache;
  wire [0:0]cl_ddr3_arid;
  wire [7:0]cl_ddr3_arlen;
  wire [0:0]cl_ddr3_arlock;
  wire [2:0]cl_ddr3_arprot;
  wire [3:0]cl_ddr3_arqos;
  wire cl_ddr3_arready;
  wire [2:0]cl_ddr3_arsize;
  wire cl_ddr3_arvalid;
  wire [41:0]cl_ddr3_awaddr;
  wire [1:0]cl_ddr3_awburst;
  wire [3:0]cl_ddr3_awcache;
  wire [0:0]cl_ddr3_awid;
  wire [7:0]cl_ddr3_awlen;
  wire [0:0]cl_ddr3_awlock;
  wire [2:0]cl_ddr3_awprot;
  wire [3:0]cl_ddr3_awqos;
  wire cl_ddr3_awready;
  wire [2:0]cl_ddr3_awsize;
  wire cl_ddr3_awvalid;
  wire [0:0]cl_ddr3_bid;
  wire cl_ddr3_bready;
  wire [1:0]cl_ddr3_bresp;
  wire cl_ddr3_bvalid;
  wire [255:0]cl_ddr3_rdata;
  wire [0:0]cl_ddr3_rid;
  wire cl_ddr3_rlast;
  wire cl_ddr3_rready;
  wire [1:0]cl_ddr3_rresp;
  wire cl_ddr3_rvalid;
  wire [255:0]cl_ddr3_wdata;
  wire cl_ddr3_wlast;
  wire cl_ddr3_wready;
  wire [31:0]cl_ddr3_wstrb;
  wire cl_ddr3_wvalid;
  wire [41:0]cl_ddr4_araddr;
  wire [1:0]cl_ddr4_arburst;
  wire [3:0]cl_ddr4_arcache;
  wire [0:0]cl_ddr4_arid;
  wire [7:0]cl_ddr4_arlen;
  wire [0:0]cl_ddr4_arlock;
  wire [2:0]cl_ddr4_arprot;
  wire [3:0]cl_ddr4_arqos;
  wire cl_ddr4_arready;
  wire [2:0]cl_ddr4_arsize;
  wire cl_ddr4_arvalid;
  wire [41:0]cl_ddr4_awaddr;
  wire [1:0]cl_ddr4_awburst;
  wire [3:0]cl_ddr4_awcache;
  wire [0:0]cl_ddr4_awid;
  wire [7:0]cl_ddr4_awlen;
  wire [0:0]cl_ddr4_awlock;
  wire [2:0]cl_ddr4_awprot;
  wire [3:0]cl_ddr4_awqos;
  wire cl_ddr4_awready;
  wire [2:0]cl_ddr4_awsize;
  wire cl_ddr4_awvalid;
  wire [0:0]cl_ddr4_bid;
  wire cl_ddr4_bready;
  wire [1:0]cl_ddr4_bresp;
  wire cl_ddr4_bvalid;
  wire [255:0]cl_ddr4_rdata;
  wire [0:0]cl_ddr4_rid;
  wire cl_ddr4_rlast;
  wire cl_ddr4_rready;
  wire [1:0]cl_ddr4_rresp;
  wire cl_ddr4_rvalid;
  wire [255:0]cl_ddr4_wdata;
  wire cl_ddr4_wlast;
  wire cl_ddr4_wready;
  wire [31:0]cl_ddr4_wstrb;
  wire cl_ddr4_wvalid;
  
  wire [41:0]cl_ddr5_araddr;
  wire [1:0]cl_ddr5_arburst;
  wire [3:0]cl_ddr5_arcache;
  wire [0:0]cl_ddr5_arid;
  wire [7:0]cl_ddr5_arlen;
  wire [0:0]cl_ddr5_arlock;
  wire [2:0]cl_ddr5_arprot;
  wire [3:0]cl_ddr5_arqos;
  wire cl_ddr5_arready;
  wire [2:0]cl_ddr5_arsize;
  wire cl_ddr5_arvalid;
  wire [31:0]cl_ddr5_rdata;
  wire [0:0]cl_ddr5_rid;
  wire cl_ddr5_rlast;
  wire cl_ddr5_rready;
  wire [1:0]cl_ddr5_rresp;
  wire cl_ddr5_rvalid;
  //s_axi_6
  wire [41:0]cl_ddr6_awaddr;
  wire [1:0]cl_ddr6_awburst;
  wire [3:0]cl_ddr6_awcache;
  wire [0:0]cl_ddr6_awid;
  wire [7:0]cl_ddr6_awlen;
  wire [0:0]cl_ddr6_awlock;
  wire [2:0]cl_ddr6_awprot;
  wire [3:0]cl_ddr6_awqos;
  wire cl_ddr6_awready;
  wire [2:0]cl_ddr6_awsize;
  wire cl_ddr6_awvalid;
  wire [0:0]cl_ddr6_bid;
  wire cl_ddr6_bready;
  wire [1:0]cl_ddr6_bresp;
  wire cl_ddr6_bvalid;
  wire [255:0]cl_ddr6_wdata;
  wire cl_ddr6_wlast;
  wire cl_ddr6_wready;
  wire [31:0]cl_ddr6_wstrb;
  wire cl_ddr6_wvalid;
  
  wire clk;
  wire [31:0]pci_cl_ctrl_araddr;
  wire [2:0]pci_cl_ctrl_arprot;
  wire pci_cl_ctrl_arready;
  wire pci_cl_ctrl_arvalid;
  wire [31:0]pci_cl_ctrl_awaddr;
  wire [2:0]pci_cl_ctrl_awprot;
  wire pci_cl_ctrl_awready;
  wire pci_cl_ctrl_awvalid;
  wire pci_cl_ctrl_bready;
  wire [1:0]pci_cl_ctrl_bresp;
  wire pci_cl_ctrl_bvalid;
  wire [31:0]pci_cl_ctrl_rdata;
  wire pci_cl_ctrl_rready;
  wire [1:0]pci_cl_ctrl_rresp;
  wire pci_cl_ctrl_rvalid;
  wire [31:0]pci_cl_ctrl_wdata;
  wire pci_cl_ctrl_wready;
  wire [3:0]pci_cl_ctrl_wstrb;
  wire pci_cl_ctrl_wvalid;
  wire [0:0]reset;
  wire [0:0]resetn;

  wire [31:0]M01_AXI_0_araddr;
  wire [2:0]M01_AXI_0_arprot;
  wire M01_AXI_0_arready;
  wire M01_AXI_0_arvalid;
  wire [31:0]M01_AXI_0_awaddr;
  wire [2:0]M01_AXI_0_awprot;
  wire M01_AXI_0_awready;
  wire M01_AXI_0_awvalid;
  wire M01_AXI_0_bready;
  wire [1:0]M01_AXI_0_bresp;
  wire M01_AXI_0_bvalid;
  wire [31:0]M01_AXI_0_rdata;
  wire M01_AXI_0_rready;
  wire [1:0]M01_AXI_0_rresp;
  wire M01_AXI_0_rvalid;
  wire [31:0]M01_AXI_0_wdata;
  wire M01_AXI_0_wready;
  wire [3:0]M01_AXI_0_wstrb;
  wire M01_AXI_0_wvalid;
  
  design_1 design_1_i
       (
       .M01_AXI_0_araddr(M01_AXI_0_araddr),
        .M01_AXI_0_arprot(M01_AXI_0_arprot),
        .M01_AXI_0_arready(M01_AXI_0_arready),
        .M01_AXI_0_arvalid(M01_AXI_0_arvalid),
        .M01_AXI_0_awaddr(M01_AXI_0_awaddr),
        .M01_AXI_0_awprot(M01_AXI_0_awprot),
        .M01_AXI_0_awready(M01_AXI_0_awready),
        .M01_AXI_0_awvalid(M01_AXI_0_awvalid),
        .M01_AXI_0_bready(M01_AXI_0_bready),
        .M01_AXI_0_bresp(M01_AXI_0_bresp),
        .M01_AXI_0_bvalid(M01_AXI_0_bvalid),
        .M01_AXI_0_rdata(M01_AXI_0_rdata),
        .M01_AXI_0_rready(M01_AXI_0_rready),
        .M01_AXI_0_rresp(M01_AXI_0_rresp),
        .M01_AXI_0_rvalid(M01_AXI_0_rvalid),
        .M01_AXI_0_wdata(M01_AXI_0_wdata),
        .M01_AXI_0_wready(M01_AXI_0_wready),
        .M01_AXI_0_wstrb(M01_AXI_0_wstrb),
        .M01_AXI_0_wvalid(M01_AXI_0_wvalid),
       .cl_ddr0_araddr(cl_ddr0_araddr),
        .cl_ddr0_arburst(cl_ddr0_arburst),
        .cl_ddr0_arcache(cl_ddr0_arcache),
        .cl_ddr0_arid(cl_ddr0_arid),
        .cl_ddr0_arlen(cl_ddr0_arlen),
        .cl_ddr0_arlock(cl_ddr0_arlock),
        .cl_ddr0_arprot(cl_ddr0_arprot),
        .cl_ddr0_arqos(cl_ddr0_arqos),
        .cl_ddr0_arready(cl_ddr0_arready),
        .cl_ddr0_arsize(cl_ddr0_arsize),
        .cl_ddr0_arvalid(cl_ddr0_arvalid),
        .cl_ddr0_awaddr(cl_ddr0_awaddr),
        .cl_ddr0_awburst(cl_ddr0_awburst),
        .cl_ddr0_awcache(cl_ddr0_awcache),
        .cl_ddr0_awid(cl_ddr0_awid),
        .cl_ddr0_awlen(cl_ddr0_awlen),
        .cl_ddr0_awlock(cl_ddr0_awlock),
        .cl_ddr0_awprot(cl_ddr0_awprot),
        .cl_ddr0_awqos(cl_ddr0_awqos),
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
        
        .cl_ddr1_araddr(cl_ddr1_araddr),
        .cl_ddr1_arburst(cl_ddr1_arburst),
        .cl_ddr1_arcache(cl_ddr1_arcache),
        .cl_ddr1_arid(cl_ddr1_arid),
        .cl_ddr1_arlen(cl_ddr1_arlen),
        .cl_ddr1_arlock(cl_ddr1_arlock),
        .cl_ddr1_arprot(cl_ddr1_arprot),
        .cl_ddr1_arqos(cl_ddr1_arqos),
        .cl_ddr1_arready(cl_ddr1_arready),
        .cl_ddr1_arsize(cl_ddr1_arsize),
        .cl_ddr1_arvalid(cl_ddr1_arvalid),
        .cl_ddr1_awaddr(cl_ddr1_awaddr),
        .cl_ddr1_awburst(cl_ddr1_awburst),
        .cl_ddr1_awcache(cl_ddr1_awcache),
        .cl_ddr1_awid(cl_ddr1_awid),
        .cl_ddr1_awlen(cl_ddr1_awlen),
        .cl_ddr1_awlock(cl_ddr1_awlock),
        .cl_ddr1_awprot(cl_ddr1_awprot),
        .cl_ddr1_awqos(cl_ddr1_awqos),
        .cl_ddr1_awready(cl_ddr1_awready),
        .cl_ddr1_awsize(cl_ddr1_awsize),
        .cl_ddr1_awvalid(cl_ddr1_awvalid),
        .cl_ddr1_bid(cl_ddr1_bid),
        .cl_ddr1_bready(cl_ddr1_bready),
        .cl_ddr1_bresp(cl_ddr1_bresp),
        .cl_ddr1_bvalid(cl_ddr1_bvalid),
        .cl_ddr1_rdata(cl_ddr1_rdata),
        .cl_ddr1_rid(cl_ddr1_rid),
        .cl_ddr1_rlast(cl_ddr1_rlast),
        .cl_ddr1_rready(cl_ddr1_rready),
        .cl_ddr1_rresp(cl_ddr1_rresp),
        .cl_ddr1_rvalid(cl_ddr1_rvalid),
        .cl_ddr1_wdata(cl_ddr1_wdata),
        .cl_ddr1_wlast(cl_ddr1_wlast),
        .cl_ddr1_wready(cl_ddr1_wready),
        .cl_ddr1_wstrb(cl_ddr1_wstrb),
        .cl_ddr1_wvalid(cl_ddr1_wvalid),
        
        .cl_ddr2_araddr(cl_ddr2_araddr),
        .cl_ddr2_arburst(cl_ddr2_arburst),
        .cl_ddr2_arcache(cl_ddr2_arcache),
        .cl_ddr2_arid(cl_ddr2_arid),
        .cl_ddr2_arlen(cl_ddr2_arlen),
        .cl_ddr2_arlock(cl_ddr2_arlock),
        .cl_ddr2_arprot(cl_ddr2_arprot),
        .cl_ddr2_arqos(cl_ddr2_arqos),
        .cl_ddr2_arready(cl_ddr2_arready),
        .cl_ddr2_arsize(cl_ddr2_arsize),
        .cl_ddr2_arvalid(cl_ddr2_arvalid),
        .cl_ddr2_awaddr(cl_ddr2_awaddr),
        .cl_ddr2_awburst(cl_ddr2_awburst),
        .cl_ddr2_awcache(cl_ddr2_awcache),
        .cl_ddr2_awid(cl_ddr2_awid),
        .cl_ddr2_awlen(cl_ddr2_awlen),
        .cl_ddr2_awlock(cl_ddr2_awlock),
        .cl_ddr2_awprot(cl_ddr2_awprot),
        .cl_ddr2_awqos(cl_ddr2_awqos),
        .cl_ddr2_awready(cl_ddr2_awready),
        .cl_ddr2_awsize(cl_ddr2_awsize),
        .cl_ddr2_awvalid(cl_ddr2_awvalid),
        .cl_ddr2_bid(cl_ddr2_bid),
        .cl_ddr2_bready(cl_ddr2_bready),
        .cl_ddr2_bresp(cl_ddr2_bresp),
        .cl_ddr2_bvalid(cl_ddr2_bvalid),
        .cl_ddr2_rdata(cl_ddr2_rdata),
        .cl_ddr2_rid(cl_ddr2_rid),
        .cl_ddr2_rlast(cl_ddr2_rlast),
        .cl_ddr2_rready(cl_ddr2_rready),
        .cl_ddr2_rresp(cl_ddr2_rresp),
        .cl_ddr2_rvalid(cl_ddr2_rvalid),
        .cl_ddr2_wdata(cl_ddr2_wdata),
        .cl_ddr2_wlast(cl_ddr2_wlast),
        .cl_ddr2_wready(cl_ddr2_wready),
        .cl_ddr2_wstrb(cl_ddr2_wstrb),
        .cl_ddr2_wvalid(cl_ddr2_wvalid),
        
        .cl_ddr3_araddr(cl_ddr3_araddr),
        .cl_ddr3_arburst(cl_ddr3_arburst),
        .cl_ddr3_arcache(cl_ddr3_arcache),
        .cl_ddr3_arid(cl_ddr3_arid),
        .cl_ddr3_arlen(cl_ddr3_arlen),
        .cl_ddr3_arlock(cl_ddr3_arlock),
        .cl_ddr3_arprot(cl_ddr3_arprot),
        .cl_ddr3_arqos(cl_ddr3_arqos),
        .cl_ddr3_arready(cl_ddr3_arready),
        .cl_ddr3_arsize(cl_ddr3_arsize),
        .cl_ddr3_arvalid(cl_ddr3_arvalid),
        .cl_ddr3_awaddr(cl_ddr3_awaddr),
        .cl_ddr3_awburst(cl_ddr3_awburst),
        .cl_ddr3_awcache(cl_ddr3_awcache),
        .cl_ddr3_awid(cl_ddr3_awid),
        .cl_ddr3_awlen(cl_ddr3_awlen),
        .cl_ddr3_awlock(cl_ddr3_awlock),
        .cl_ddr3_awprot(cl_ddr3_awprot),
        .cl_ddr3_awqos(cl_ddr3_awqos),
        .cl_ddr3_awready(cl_ddr3_awready),
        .cl_ddr3_awsize(cl_ddr3_awsize),
        .cl_ddr3_awvalid(cl_ddr3_awvalid),
        .cl_ddr3_bid(cl_ddr3_bid),
        .cl_ddr3_bready(cl_ddr3_bready),
        .cl_ddr3_bresp(cl_ddr3_bresp),
        .cl_ddr3_bvalid(cl_ddr3_bvalid),
        .cl_ddr3_rdata(cl_ddr3_rdata),
        .cl_ddr3_rid(cl_ddr3_rid),
        .cl_ddr3_rlast(cl_ddr3_rlast),
        .cl_ddr3_rready(cl_ddr3_rready),
        .cl_ddr3_rresp(cl_ddr3_rresp),
        .cl_ddr3_rvalid(cl_ddr3_rvalid),
        .cl_ddr3_wdata(cl_ddr3_wdata),
        .cl_ddr3_wlast(cl_ddr3_wlast),
        .cl_ddr3_wready(cl_ddr3_wready),
        .cl_ddr3_wstrb(cl_ddr3_wstrb),
        .cl_ddr3_wvalid(cl_ddr3_wvalid),
        
        .cl_ddr4_araddr(cl_ddr4_araddr),
        .cl_ddr4_arburst(cl_ddr4_arburst),
        .cl_ddr4_arcache(cl_ddr4_arcache),
        .cl_ddr4_arid(cl_ddr4_arid),
        .cl_ddr4_arlen(cl_ddr4_arlen),
        .cl_ddr4_arlock(cl_ddr4_arlock),
        .cl_ddr4_arprot(cl_ddr4_arprot),
        .cl_ddr4_arqos(cl_ddr4_arqos),
        .cl_ddr4_arready(cl_ddr4_arready),
        .cl_ddr4_arsize(cl_ddr4_arsize),
        .cl_ddr4_arvalid(cl_ddr4_arvalid),
        .cl_ddr4_awaddr(cl_ddr4_awaddr),
        .cl_ddr4_awburst(cl_ddr4_awburst),
        .cl_ddr4_awcache(cl_ddr4_awcache),
        .cl_ddr4_awid(cl_ddr4_awid),
        .cl_ddr4_awlen(cl_ddr4_awlen),
        .cl_ddr4_awlock(cl_ddr4_awlock),
        .cl_ddr4_awprot(cl_ddr4_awprot),
        .cl_ddr4_awqos(cl_ddr4_awqos),
        .cl_ddr4_awready(cl_ddr4_awready),
        .cl_ddr4_awsize(cl_ddr4_awsize),
        .cl_ddr4_awvalid(cl_ddr4_awvalid),
        .cl_ddr4_bid(cl_ddr4_bid),
        .cl_ddr4_bready(cl_ddr4_bready),
        .cl_ddr4_bresp(cl_ddr4_bresp),
        .cl_ddr4_bvalid(cl_ddr4_bvalid),
        .cl_ddr4_rdata(cl_ddr4_rdata),
        .cl_ddr4_rid(cl_ddr4_rid),
        .cl_ddr4_rlast(cl_ddr4_rlast),
        .cl_ddr4_rready(cl_ddr4_rready),
        .cl_ddr4_rresp(cl_ddr4_rresp),
        .cl_ddr4_rvalid(cl_ddr4_rvalid),
        .cl_ddr4_wdata(cl_ddr4_wdata),
        .cl_ddr4_wlast(cl_ddr4_wlast),
        .cl_ddr4_wready(cl_ddr4_wready),
        .cl_ddr4_wstrb(cl_ddr4_wstrb),
        .cl_ddr4_wvalid(cl_ddr4_wvalid),
        
        .cl_ddr5_araddr(cl_ddr5_araddr),
        .cl_ddr5_arburst(cl_ddr5_arburst),
        .cl_ddr5_arcache(cl_ddr5_arcache),
        .cl_ddr5_arid(cl_ddr5_arid),
        .cl_ddr5_arlen(cl_ddr5_arlen),
        .cl_ddr5_arlock(cl_ddr5_arlock),
        .cl_ddr5_arprot(cl_ddr5_arprot),
        .cl_ddr5_arqos(cl_ddr5_arqos),
        .cl_ddr5_arready(cl_ddr5_arready),
        .cl_ddr5_arsize(cl_ddr5_arsize),
        .cl_ddr5_arvalid(cl_ddr5_arvalid),
        .cl_ddr5_rdata(cl_ddr5_rdata),
        .cl_ddr5_rid(cl_ddr5_rid),
        .cl_ddr5_rlast(cl_ddr5_rlast),
        .cl_ddr5_rready(cl_ddr5_rready),
        .cl_ddr5_rresp(cl_ddr5_rresp),
        .cl_ddr5_rvalid(cl_ddr5_rvalid),
        //
        .cl_ddr6_awaddr(cl_ddr6_awaddr),
        .cl_ddr6_awburst(cl_ddr6_awburst),
        .cl_ddr6_awcache(cl_ddr6_awcache),
        .cl_ddr6_awid(cl_ddr6_awid),
        .cl_ddr6_awlen(cl_ddr6_awlen),
        .cl_ddr6_awlock(cl_ddr6_awlock),
        .cl_ddr6_awprot(cl_ddr6_awprot),
        .cl_ddr6_awqos(cl_ddr6_awqos),
        .cl_ddr6_awready(cl_ddr6_awready),
        .cl_ddr6_awsize(cl_ddr6_awsize),
        .cl_ddr6_awvalid(cl_ddr6_awvalid),
        .cl_ddr6_bid(cl_ddr6_bid),
        .cl_ddr6_bready(cl_ddr6_bready),
        .cl_ddr6_bresp(cl_ddr6_bresp),
        .cl_ddr6_bvalid(cl_ddr6_bvalid),
        .cl_ddr6_wdata(cl_ddr6_wdata),
        .cl_ddr6_wlast(cl_ddr6_wlast),
        .cl_ddr6_wready(cl_ddr6_wready),
        .cl_ddr6_wstrb(cl_ddr6_wstrb),
        .cl_ddr6_wvalid(cl_ddr6_wvalid),
        
        .clk(clk),
        .pci_cl_ctrl_araddr(pci_cl_ctrl_araddr),
        .pci_cl_ctrl_arprot(pci_cl_ctrl_arprot),
        .pci_cl_ctrl_arready(pci_cl_ctrl_arready),
        .pci_cl_ctrl_arvalid(pci_cl_ctrl_arvalid),
        .pci_cl_ctrl_awaddr(pci_cl_ctrl_awaddr),
        .pci_cl_ctrl_awprot(pci_cl_ctrl_awprot),
        .pci_cl_ctrl_awready(pci_cl_ctrl_awready),
        .pci_cl_ctrl_awvalid(pci_cl_ctrl_awvalid),
        .pci_cl_ctrl_bready(pci_cl_ctrl_bready),
        .pci_cl_ctrl_bresp(pci_cl_ctrl_bresp),
        .pci_cl_ctrl_bvalid(pci_cl_ctrl_bvalid),
        .pci_cl_ctrl_rdata(pci_cl_ctrl_rdata),
        .pci_cl_ctrl_rready(pci_cl_ctrl_rready),
        .pci_cl_ctrl_rresp(pci_cl_ctrl_rresp),
        .pci_cl_ctrl_rvalid(pci_cl_ctrl_rvalid),
        .pci_cl_ctrl_wdata(pci_cl_ctrl_wdata),
        .pci_cl_ctrl_wready(pci_cl_ctrl_wready),
        .pci_cl_ctrl_wstrb(pci_cl_ctrl_wstrb),
        .pci_cl_ctrl_wvalid(pci_cl_ctrl_wvalid),
        .reset(reset),
        .resetn(resetn));         
 assign              o_led  =       cl_ddr0_rvalid;          

 //setging

//  assign cl_ddr0_arcache ='d3;
//  assign cl_ddr0_arlock  ='d0;
//  assign cl_ddr0_arprot  ='d0;
//  assign cl_ddr0_arqos   ='d0;
  
//  assign cl_ddr1_arcache ='d3;
//  assign cl_ddr1_arlock  ='d0;
//  assign cl_ddr1_arprot  ='d0;
//  assign cl_ddr1_arqos   ='d0;
  
//  assign cl_ddr2_arcache ='d3;
//  assign cl_ddr2_arlock  ='d0;
//  assign cl_ddr2_arprot  ='d0;
//  assign cl_ddr2_arqos   ='d0;
  
//  assign cl_ddr3_arcache ='d3;
//  assign cl_ddr3_arlock  ='d0;
//  assign cl_ddr3_arprot  ='d0;
//  assign cl_ddr3_arqos   ='d0;
  
//  assign cl_ddr4_arcache ='d3;
//  assign cl_ddr4_arlock  ='d0;
//  assign cl_ddr4_arprot  ='d0;
//  assign cl_ddr4_arqos   ='d0;
  
  assign cl_ddr5_arcache ='d3;
  assign cl_ddr5_arlock  ='d0;
  assign cl_ddr5_arprot  ='d0;
  assign cl_ddr5_arqos   ='d0;


//=============================================================
// Wires/Regs
//=============================================================
//=============================================================

//=============================================================
// Comb Logic
//=============================================================
//=============================================================

//=============================================================
// DnnWeaver2 Wrapper
//=============================================================

  dnnweaver2_controller #(
    .ARRAY_N                        ( ARRAY_N                        ),
    .ARRAY_M                        ( ARRAY_M                        ),
    .DATA_WIDTH                     ( DATA_WIDTH                     ),
    .BIAS_WIDTH                     ( BIAS_WIDTH                     ),
    .ACC_WIDTH                      ( ACC_WIDTH                      ),
    .WEIGHT_ROW_NUM                 ( WEIGHT_ROW_NUM                 ),                                                                                     //edit by sy 0513

    .IBUF_CAPACITY_BITS             ( IBUF_CAPACITY_BITS             ),
    .WBUF_CAPACITY_BITS             ( WBUF_CAPACITY_BITS             ),
    .OBUF_CAPACITY_BITS             ( OBUF_CAPACITY_BITS             ),
    .BBUF_CAPACITY_BITS             ( BBUF_CAPACITY_BITS             ),

    .AXI_ADDR_WIDTH                 ( AXI_ADDR_WIDTH                 ),
    .AXI_BURST_WIDTH                ( AXI_BURST_WIDTH                ),
    .IBUF_AXI_DATA_WIDTH            ( IBUF_AXI_DATA_WIDTH            ),
    .OBUF_AXI_DATA_WIDTH            ( OBUF_AXI_DATA_WIDTH            ),
    .PU_AXI_DATA_WIDTH              ( PU_AXI_DATA_WIDTH              ),
    .WBUF_AXI_DATA_WIDTH            ( WBUF_AXI_DATA_WIDTH            ),
    .BBUF_AXI_DATA_WIDTH            ( BBUF_AXI_DATA_WIDTH            ),
    .INST_ADDR_WIDTH                ( INST_ADDR_WIDTH                ),
    .INST_DATA_WIDTH                ( INST_DATA_WIDTH                ),
    .CTRL_ADDR_WIDTH                ( CTRL_ADDR_WIDTH                ),
    .CTRL_DATA_WIDTH                ( CTRL_DATA_WIDTH                )
  ) u_dnn (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .resetn                         ( resetn                         ),

    .pci_cl_ctrl_awvalid            ( pci_cl_ctrl_awvalid            ),
    .pci_cl_ctrl_awaddr             ( pci_cl_ctrl_awaddr             ),
    .pci_cl_ctrl_awready            ( pci_cl_ctrl_awready            ),
    .pci_cl_ctrl_wvalid             ( pci_cl_ctrl_wvalid             ),
    .pci_cl_ctrl_wdata              ( pci_cl_ctrl_wdata              ),
    .pci_cl_ctrl_wstrb              ( pci_cl_ctrl_wstrb              ),
    .pci_cl_ctrl_wready             ( pci_cl_ctrl_wready             ),
    .pci_cl_ctrl_bvalid             ( pci_cl_ctrl_bvalid             ),
    .pci_cl_ctrl_bresp              ( pci_cl_ctrl_bresp              ),
    .pci_cl_ctrl_bready             ( pci_cl_ctrl_bready             ),
    .pci_cl_ctrl_arvalid            ( pci_cl_ctrl_arvalid            ),
    .pci_cl_ctrl_araddr             ( pci_cl_ctrl_araddr             ),
    .pci_cl_ctrl_arready            ( pci_cl_ctrl_arready            ),
    .pci_cl_ctrl_rvalid             ( pci_cl_ctrl_rvalid             ),
    .pci_cl_ctrl_rdata              ( pci_cl_ctrl_rdata              ),
    .pci_cl_ctrl_rresp              ( pci_cl_ctrl_rresp              ),
    .pci_cl_ctrl_rready             ( pci_cl_ctrl_rready             ),

    .cl_ddr0_awaddr                 ( cl_ddr0_awaddr                 ),
    .cl_ddr0_awlen                  ( cl_ddr0_awlen                  ),
    .cl_ddr0_awsize                 ( cl_ddr0_awsize                 ),
    .cl_ddr0_awburst                ( cl_ddr0_awburst                ),
    .cl_ddr0_awvalid                ( cl_ddr0_awvalid                ),
    .cl_ddr0_awready                ( cl_ddr0_awready                ),
    .cl_ddr0_wdata                  ( cl_ddr0_wdata                  ),
    .cl_ddr0_wstrb                  ( cl_ddr0_wstrb                  ),
    .cl_ddr0_wlast                  ( cl_ddr0_wlast                  ),
    .cl_ddr0_wvalid                 ( cl_ddr0_wvalid                 ),
    .cl_ddr0_wready                 ( cl_ddr0_wready                 ),
    .cl_ddr0_bresp                  ( cl_ddr0_bresp                  ),
    .cl_ddr0_bvalid                 ( cl_ddr0_bvalid                 ),
    .cl_ddr0_bready                 ( cl_ddr0_bready                 ),
    .cl_ddr0_araddr                 ( cl_ddr0_araddr                 ),
    .cl_ddr0_arlen                  ( cl_ddr0_arlen                  ),
    .cl_ddr0_arsize                 ( cl_ddr0_arsize                 ),
    .cl_ddr0_arburst                ( cl_ddr0_arburst                ),
    .cl_ddr0_arvalid                ( cl_ddr0_arvalid                ),
    .cl_ddr0_arid                   ( cl_ddr0_arid                   ),
    .cl_ddr0_arready                ( cl_ddr0_arready                ),
    .cl_ddr0_rdata                  ( cl_ddr0_rdata                  ),
    .cl_ddr0_rid                    ( cl_ddr0_rid                    ),
    .cl_ddr0_rresp                  ( cl_ddr0_rresp                  ),
    .cl_ddr0_rlast                  ( cl_ddr0_rlast                  ),
    .cl_ddr0_rvalid                 ( cl_ddr0_rvalid                 ),
    .cl_ddr0_rready                 ( cl_ddr0_rready                 ),

    .cl_ddr1_awaddr                 ( cl_ddr1_awaddr                 ),
    .cl_ddr1_awlen                  ( cl_ddr1_awlen                  ),
    .cl_ddr1_awsize                 ( cl_ddr1_awsize                 ),
    .cl_ddr1_awburst                ( cl_ddr1_awburst                ),
    .cl_ddr1_awvalid                ( cl_ddr1_awvalid                ),
    .cl_ddr1_awready                ( cl_ddr1_awready                ),
    .cl_ddr1_wdata                  ( cl_ddr1_wdata                  ),
    .cl_ddr1_wstrb                  ( cl_ddr1_wstrb                  ),
    .cl_ddr1_wlast                  ( cl_ddr1_wlast                  ),
    .cl_ddr1_wvalid                 ( cl_ddr1_wvalid                 ),
    .cl_ddr1_wready                 ( cl_ddr1_wready                 ),
    .cl_ddr1_bresp                  ( cl_ddr1_bresp                  ),
    .cl_ddr1_bvalid                 ( cl_ddr1_bvalid                 ),
    .cl_ddr1_bready                 ( cl_ddr1_bready                 ),
    .cl_ddr1_araddr                 ( cl_ddr1_araddr                 ),
    .cl_ddr1_arlen                  ( cl_ddr1_arlen                  ),
    .cl_ddr1_arsize                 ( cl_ddr1_arsize                 ),
    .cl_ddr1_arburst                ( cl_ddr1_arburst                ),
    .cl_ddr1_arvalid                ( cl_ddr1_arvalid                ),
    .cl_ddr1_arid                   ( cl_ddr1_arid                   ),
    .cl_ddr1_arready                ( cl_ddr1_arready                ),
    .cl_ddr1_rdata                  ( cl_ddr1_rdata                  ),
    .cl_ddr1_rid                    ( cl_ddr1_rid                    ),
    .cl_ddr1_rresp                  ( cl_ddr1_rresp                  ),
    .cl_ddr1_rlast                  ( cl_ddr1_rlast                  ),
    .cl_ddr1_rvalid                 ( cl_ddr1_rvalid                 ),
    .cl_ddr1_rready                 ( cl_ddr1_rready                 ),

    .cl_ddr2_awaddr                 ( cl_ddr2_awaddr                 ),
    .cl_ddr2_awlen                  ( cl_ddr2_awlen                  ),
    .cl_ddr2_awsize                 ( cl_ddr2_awsize                 ),
    .cl_ddr2_awburst                ( cl_ddr2_awburst                ),
    .cl_ddr2_awvalid                ( cl_ddr2_awvalid                ),
    .cl_ddr2_awready                ( cl_ddr2_awready                ),
    .cl_ddr2_wdata                  ( cl_ddr2_wdata                  ),
    .cl_ddr2_wstrb                  ( cl_ddr2_wstrb                  ),
    .cl_ddr2_wlast                  ( cl_ddr2_wlast                  ),
    .cl_ddr2_wvalid                 ( cl_ddr2_wvalid                 ),
    .cl_ddr2_wready                 ( cl_ddr2_wready                 ),
    .cl_ddr2_bresp                  ( cl_ddr2_bresp                  ),
    .cl_ddr2_bvalid                 ( cl_ddr2_bvalid                 ),
    .cl_ddr2_bready                 ( cl_ddr2_bready                 ),
    .cl_ddr2_araddr                 ( cl_ddr2_araddr                 ),
    .cl_ddr2_arlen                  ( cl_ddr2_arlen                  ),
    .cl_ddr2_arsize                 ( cl_ddr2_arsize                 ),
    .cl_ddr2_arburst                ( cl_ddr2_arburst                ),
    .cl_ddr2_arvalid                ( cl_ddr2_arvalid                ),
    .cl_ddr2_arid                   ( cl_ddr2_arid                   ),
    .cl_ddr2_arready                ( cl_ddr2_arready                ),
    .cl_ddr2_rdata                  ( cl_ddr2_rdata                  ),
    .cl_ddr2_rid                    ( cl_ddr2_rid                    ),
    .cl_ddr2_rresp                  ( cl_ddr2_rresp                  ),
    .cl_ddr2_rlast                  ( cl_ddr2_rlast                  ),
    .cl_ddr2_rvalid                 ( cl_ddr2_rvalid                 ),
    .cl_ddr2_rready                 ( cl_ddr2_rready                 ),

    .cl_ddr3_awaddr                 ( cl_ddr3_awaddr                 ),
    .cl_ddr3_awlen                  ( cl_ddr3_awlen                  ),
    .cl_ddr3_awsize                 ( cl_ddr3_awsize                 ),
    .cl_ddr3_awburst                ( cl_ddr3_awburst                ),
    .cl_ddr3_awvalid                ( cl_ddr3_awvalid                ),
    .cl_ddr3_awready                ( cl_ddr3_awready                ),
    .cl_ddr3_wdata                  ( cl_ddr3_wdata                  ),
    .cl_ddr3_wstrb                  ( cl_ddr3_wstrb                  ),
    .cl_ddr3_wlast                  ( cl_ddr3_wlast                  ),
    .cl_ddr3_wvalid                 ( cl_ddr3_wvalid                 ),
    .cl_ddr3_wready                 ( cl_ddr3_wready                 ),
    .cl_ddr3_bresp                  ( cl_ddr3_bresp                  ),
    .cl_ddr3_bvalid                 ( cl_ddr3_bvalid                 ),
    .cl_ddr3_bready                 ( cl_ddr3_bready                 ),
    .cl_ddr3_araddr                 ( cl_ddr3_araddr                 ),
    .cl_ddr3_arlen                  ( cl_ddr3_arlen                  ),
    .cl_ddr3_arsize                 ( cl_ddr3_arsize                 ),
    .cl_ddr3_arburst                ( cl_ddr3_arburst                ),
    .cl_ddr3_arvalid                ( cl_ddr3_arvalid                ),
    .cl_ddr3_arid                   ( cl_ddr3_arid                   ),
    .cl_ddr3_arready                ( cl_ddr3_arready                ),
    .cl_ddr3_rdata                  ( cl_ddr3_rdata                  ),
    .cl_ddr3_rid                    ( cl_ddr3_rid                    ),
    .cl_ddr3_rresp                  ( cl_ddr3_rresp                  ),
    .cl_ddr3_rlast                  ( cl_ddr3_rlast                  ),
    .cl_ddr3_rvalid                 ( cl_ddr3_rvalid                 ),
    .cl_ddr3_rready                 ( cl_ddr3_rready                 ),

    .cl_ddr4_awaddr                 ( cl_ddr4_awaddr                 ),
    .cl_ddr4_awlen                  ( cl_ddr4_awlen                  ),
    .cl_ddr4_awsize                 ( cl_ddr4_awsize                 ),
    .cl_ddr4_awburst                ( cl_ddr4_awburst                ),
    .cl_ddr4_awvalid                ( cl_ddr4_awvalid                ),
    .cl_ddr4_awready                ( cl_ddr4_awready                ),
    .cl_ddr4_wdata                  ( cl_ddr4_wdata                  ),
    .cl_ddr4_wstrb                  ( cl_ddr4_wstrb                  ),
    .cl_ddr4_wlast                  ( cl_ddr4_wlast                  ),
    .cl_ddr4_wvalid                 ( cl_ddr4_wvalid                 ),
    .cl_ddr4_wready                 ( cl_ddr4_wready                 ),
    .cl_ddr4_bresp                  ( cl_ddr4_bresp                  ),
    .cl_ddr4_bvalid                 ( cl_ddr4_bvalid                 ),
    .cl_ddr4_bready                 ( cl_ddr4_bready                 ),
    .cl_ddr4_araddr                 ( cl_ddr4_araddr                 ),
    .cl_ddr4_arlen                  ( cl_ddr4_arlen                  ),
    .cl_ddr4_arsize                 ( cl_ddr4_arsize                 ),
    .cl_ddr4_arburst                ( cl_ddr4_arburst                ),
    .cl_ddr4_arvalid                ( cl_ddr4_arvalid                ),
    .cl_ddr4_arid                   ( cl_ddr4_arid                   ),
    .cl_ddr4_arready                ( cl_ddr4_arready                ),
    .cl_ddr4_rdata                  ( cl_ddr4_rdata                  ),
    .cl_ddr4_rid                    ( cl_ddr4_rid                    ),
    .cl_ddr4_rresp                  ( cl_ddr4_rresp                  ),
    .cl_ddr4_rlast                  ( cl_ddr4_rlast                  ),
    .cl_ddr4_rvalid                 ( cl_ddr4_rvalid                 ),
    .cl_ddr4_rready                 ( cl_ddr4_rready                 ),
    //
//    .cl_ddr5_arid(        cl_ddr5_arid                    ),
//    .cl_ddr5_araddr(       cl_ddr5_araddr                 ),
//    .cl_ddr5_arlen(        cl_ddr5_arlen                  ),
//    .cl_ddr5_arsize(       cl_ddr5_arsize                 ),
//    .cl_ddr5_arburst(     cl_ddr5_arburst                 ),
//    .cl_ddr5_arvalid(     cl_ddr5_arvalid                 ),
//    .cl_ddr5_arready(     cl_ddr5_arready                 ),
//    // Master Interface Read Data
//    .cl_ddr5_rid(         cl_ddr5_rid                     ),
//    .cl_ddr5_rdata(       cl_ddr5_rdata                   ),
//    .cl_ddr5_rresp(       cl_ddr5_rresp                   ),
//    .cl_ddr5_rlast(       cl_ddr5_rlast                   ),
//    .cl_ddr5_rvalid(      cl_ddr5_rvalid                  ),
//    .cl_ddr5_rready(      cl_ddr5_rready                  )
    .o_m_axi_icash_arid(        cl_ddr5_arid                   ),
    .o_m_axi_icash_araddr(      cl_ddr5_araddr                 ),
    .o_m_axi_icash_arlen(       cl_ddr5_arlen                  ),
    .o_m_axi_icash_arsize(      cl_ddr5_arsize                 ),
    .o_m_axi_icash_arburst(     cl_ddr5_arburst                ),
    .o_m_axi_icash_arvalid(     cl_ddr5_arvalid                ),
    .i_m_axi_icash_arready(     cl_ddr5_arready                ),
    // Master Interface Read Data
    .i_m_axi_icash_rid(         cl_ddr5_rid                    ),
    .i_m_axi_icash_rdata(       cl_ddr5_rdata                  ),
    .i_m_axi_icash_rresp(       cl_ddr5_rresp                  ),
    .i_m_axi_icash_rlast(       cl_ddr5_rlast                  ),
    .i_m_axi_icash_rvalid(      cl_ddr5_rvalid                 ),
    .o_m_axi_icash_rready(      cl_ddr5_rready                 ),
    //m_axi4_asr write only
    .o_m_axi_asr_awid(      cl_ddr6_awid                                          ),
    .o_m_axi_asr_awburst(   cl_ddr6_awburst                                       ),
    .o_m_axi_asr_wstrb(     cl_ddr6_wstrb                                         ),    
        
    .o_m_axi_asr_awcache(   cl_ddr6_awcache                                       ),
    .o_m_axi_asr_awlock(    cl_ddr6_awlock                                        ),
    .o_m_axi_asr_awprot(    cl_ddr6_awprot                                        ),
    .o_m_axi_asr_awqos(     cl_ddr6_awqos                                         ),
        
    .o_m_axi_asr_awlen(      cl_ddr6_awlen                                        ),
    .i_m_axi_asr_awready(    cl_ddr6_awready                                      ),
    .o_m_axi_asr_awsize(     cl_ddr6_awsize                                       ),
    .o_m_axi_asr_awaddr(     cl_ddr6_awaddr                                       ),
    .o_m_axi_asr_awvalid(    cl_ddr6_awvalid                                      ),
        
    .o_m_axi_asr_wdata(      cl_ddr6_wdata                                        ),
    .o_m_axi_asr_wlast(      cl_ddr6_wlast                                        ),
    .i_m_axi_asr_wready(     cl_ddr6_wready                                       ),
    .o_m_axi_asr_wvalid(     cl_ddr6_wvalid                                       ),
        
    .i_m_axi_asr_bid(        cl_ddr6_bid                                          ),
    .o_m_axi_asr_bready(     cl_ddr6_bready                                       ),
    .i_m_axi_asr_bresp(      cl_ddr6_bresp                                        ),
    .i_m_axi_asr_bvalid(     cl_ddr6_bvalid                                       ),
    //************************************
    .o_ws_asr(               o_ws_asr                                             ),
    .o_sck_asr(              o_sck_asr                                            ),
    .i_sdi_asr(              i_sdi_asr                                            ),
    //*************************************
    .i_ctl                          (i_ctl),
    .i_mm2s_vddn_ddrbase            (i_mm2s_vddn_ddrbase),
    .i_mm2s_vddn_leng               (i_mm2s_vddn_leng),
    .i_mm2s_addn_ddrbase            (i_mm2s_addn_ddrbase),
    .i_mm2s_addn_leng               (i_mm2s_addn_leng),
    
    .i_video2ddr_ctl(i_video2ddr_ctl),
    .i_Video2ddr_base_a(i_Video2ddr_base_a),
    .i_Video2ddr_base_b(i_Video2ddr_base_b),
    //cam0_if sensor
    // add 20210819
    .i_cam0_clk(            i_cam0_clk                                                                                      ),
    .i_cam0_vs(             i_cam0_vs                                                                                       ),
    .i_cam0_hs(             i_cam0_hs                                                                                       ),
    .i_cam0_de(             i_cam0_de                                                                                       ),
    .i_cam0_rgb(            i_cam0_rgb                                                                                      ),
    //cfg_cam0_if
    .o_cam0_hpd(            o_cam0_hpd                                                                                      ),
    .io_cam0_hdmi_scl(      io_cam0_hdmi_scl                                                                                ),
    .io_cam0_hdmi_sda(      io_cam0_hdmi_sda                                                                                ),
    .io_cam0_cfg_scl(       io_cam0_cfg_scl                                                                                 ),
    .io_cam0_cfg_sda(       io_cam0_cfg_sda                                                                                 ),
    .o_cam0_rstn(           o_cam0_rstn                                                                                     )    
  );

/////////////////////////////////////
    tq_controller #(
    .CONFIG_DATA_WIDTH ( CONFIG_DATA_WIDTH ),
    .AXIS_DATA_WIDTH   ( AXIS_DATA_WIDTH   ),
    .AXIS_ADDR_WIDTH   ( AXIS_ADDR_WIDTH   ))
 inst_controller (
    .clk                     ( clk                                   ),
    .resetn                  ( resetn                                ),
    .config_ready            (                                       ),
    .sound_in                (                                       ),
    .dnn_done                (                                       ),
    .dnn_state               (                                       ),
    .sl_valid                (                                       ),
    .sl_result               (                                       ),
    .AWVALID                 ( M01_AXI_0_awvalid                                           ),
    .AWADDR                  ( M01_AXI_0_awaddr                   ),
    .AWPROT                  ( M01_AXI_0_awprot                                            ),
    .WVALID                  ( M01_AXI_0_wvalid                                            ),
    .WDATA                   ( M01_AXI_0_wdata                    ),
    .WSTRB                   ( M01_AXI_0_wstrb                    ),
    .BREADY                  ( M01_AXI_0_bready                                            ),
    .ARVALID                 ( M01_AXI_0_arvalid                                           ),
    .ARADDR                  ( M01_AXI_0_araddr                                  ),
    .ARPROT                  ( M01_AXI_0_arprot                                            ),
    .RREADY                  ( M01_AXI_0_rready                                            ),

    .config_req              (  ),
    .config_data             (  ),
    .rebuild                 (                          ),
    .dma1_ctl                (                          ),
    .dma1_W_base_addr        (                          ),
    .dma1_R_base_addr        (                          ),
    .dma1_R_len              (                          ),
    .dma1_flash_base_addr    (                          ),
    .dma2_ctl                (                  ),
    .dma2_W_base_addr        (                      ),
    .dma2_R_base_addr        (                        ),
    .dma2_R_len              (           ),
    .dma2_flash_base_addr    (                          ),
    .dma3_ctl                ( i_video2ddr_ctl                         ),
    .dma3_W_base0_addr       ( i_Video2ddr_base_a                         ),
    .dma3_W_base1_addr       ( i_Video2ddr_base_b                         ),
    .dma3_flash_base_addr    ( i_hdwr2ddr_base                         ),
    .dma4_ctl                (                          ),
    .dma4_W_base0_addr       (                          ),
    .dma4_W_base1_addr       (                          ),
    .dma4_flash_base_addr    (                          ),
    .dma5_ctl                ( i_ctl                         ),
    .dma5_v_ins_base_addr    ( i_mm2s_vddn_ddrbase                         ),
    .dma5_v_ins_len          ( i_mm2s_vddn_leng                         ),
    .dma5_a_ins_base_addr    ( i_mm2s_addn_ddrbase                         ),
    .dma5_a_ins_len          ( i_mm2s_addn_leng                         ),
    .AWREADY                 ( M01_AXI_0_awready               ),
    .WREADY                  ( M01_AXI_0_wready                ),
    .BVALID                  ( M01_AXI_0_bvalid                ),
    .BRESP                   ( M01_AXI_0_bresp                 ),
    .ARREADY                 ( M01_AXI_0_arready               ),
    .RVALID                  ( M01_AXI_0_rvalid                ),
    .RDATA                   ( M01_AXI_0_rdata                 )
);
//=============================================================

//=============================================================
// VCD
//=============================================================
`ifdef COCOTB_TOPLEVEL_cl_wrapper
  initial begin
    $dumpfile("cl_wrapper.vcd");
    $dumpvars(0, cl_wrapper);
  end
`endif
//=============================================================    
    
endmodule
