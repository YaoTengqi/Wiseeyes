`timescale 1ns/1ps
module cl_wrapper #(
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
    
    // Instruction Mem
    parameter integer  IMEM_ADDR_W                  = 7,
  // Systolic Array
    parameter integer  TAG_W                        = $clog2(NUM_TAGS),
    parameter          DTYPE                        = "FXP", // FXP for dnnweaver2, FP32 for single precision, FP16 for half-precision
    parameter integer  WBUF_DATA_WIDTH              = ARRAY_M *WEIGHT_ROW_NUM * DATA_WIDTH,                                                           //edit by sy
    parameter integer  BBUF_DATA_WIDTH              = ARRAY_M * BIAS_WIDTH,
    parameter integer  IBUF_DATA_WIDTH              = ARRAY_N * DATA_WIDTH,
    parameter integer  OBUF_DATA_WIDTH              = ARRAY_M * ACC_WIDTH,

  // Buffer Addr width for PU access to OBUF
    parameter integer  PU_OBUF_ADDR_WIDTH           = OBUF_ADDR_WIDTH + $clog2(OBUF_DATA_WIDTH / OBUF_AXI_DATA_WIDTH),
    //cam_in info
    // sensor out posedge and negedge 
    parameter integer  CAM0_IN_DATA_WIDTH           =48,
    parameter integer  CAM0_SENSOR_DATA_WIDTH       =24,
     //inst from ddr max leng
    parameter integer  MAX_LENGTH_FROMDDR_B         = 1024*32,
    parameter integer  MAX_LENGTH_FROMDDR_WIDTH     = $clog2(MAX_LENGTH_FROMDDR_B),
    parameter integer  ASR_MIC_CH_NUM                    =1, //
    parameter integer  SL_MIC_CH_NUM                     =4,
    parameter integer  AXI_DATA_WIDTH               = 64,

      // Buffer
    parameter integer  BUF_DATA_WIDTH               = DATA_WIDTH * ARRAY_M,
    parameter integer  BUF_ADDR_W                   = 16,
    parameter integer  MEM_ADDR_W                   = BUF_ADDR_W + $clog2(BUF_DATA_WIDTH / AXI_DATA_WIDTH),
    parameter integer  TAG_BUF_ADDR_W               = BUF_ADDR_W + TAG_W,
    parameter integer  TAG_MEM_ADDR_W               = MEM_ADDR_W + TAG_W
)(
   input  wire                                         clk,
    input  wire                                         reset,

  // PCIe -> CL_wrapper AXI4-Lite interface
    // Slave Write address
    input  wire                                         pci_cl_ctrl_awvalid,
    input  wire  [ CTRL_ADDR_WIDTH      -1 : 0 ]        pci_cl_ctrl_awaddr,
    output wire                                         pci_cl_ctrl_awready,
    // Slave Write data
    input  wire                                         pci_cl_ctrl_wvalid,
    input  wire  [ CTRL_DATA_WIDTH      -1 : 0 ]        pci_cl_ctrl_wdata,
    input  wire  [ CTRL_WSTRB_WIDTH     -1 : 0 ]        pci_cl_ctrl_wstrb,
    output wire                                         pci_cl_ctrl_wready,
    //Write response
    output wire                                         pci_cl_ctrl_bvalid,
    output wire  [ 2                    -1 : 0 ]        pci_cl_ctrl_bresp,
    input  wire                                         pci_cl_ctrl_bready,
    //Read address
    input  wire                                         pci_cl_ctrl_arvalid,
    input  wire  [ CTRL_ADDR_WIDTH      -1 : 0 ]        pci_cl_ctrl_araddr,
    output wire                                         pci_cl_ctrl_arready,
    //Read data/response
    output wire                                         pci_cl_ctrl_rvalid,
    output wire  [ CTRL_DATA_WIDTH      -1 : 0 ]        pci_cl_ctrl_rdata,
    output wire  [ 2                    -1 : 0 ]        pci_cl_ctrl_rresp,
    input  wire                                         pci_cl_ctrl_rready,

 // PCIe -> CL_wrapper AXI4 interface
   // Slave Interface Write Address
   input  wire  [ INST_ADDR_WIDTH      -1 : 0 ]        pci_cl_data_awaddr,
   input  wire  [ INST_BURST_WIDTH     -1 : 0 ]        pci_cl_data_awlen,
   input  wire  [ 3                    -1 : 0 ]        pci_cl_data_awsize,
   input  wire  [ 2                    -1 : 0 ]        pci_cl_data_awburst,
   input  wire                                         pci_cl_data_awvalid,
   output wire                                         pci_cl_data_awready,
 // Slave Interface Write Data
   input  wire  [ INST_DATA_WIDTH      -1 : 0 ]        pci_cl_data_wdata,
   input  wire  [ INST_WSTRB_WIDTH     -1 : 0 ]        pci_cl_data_wstrb,
   input  wire                                         pci_cl_data_wlast,
   input  wire                                         pci_cl_data_wvalid,
   output wire                                         pci_cl_data_wready,
 // Slave Interface Write Response
   output wire  [ 2                    -1 : 0 ]        pci_cl_data_bresp,
   output wire                                         pci_cl_data_bvalid,
   input  wire                                         pci_cl_data_bready,
 // Slave Interface Read Address
   input  wire  [ INST_ADDR_WIDTH      -1 : 0 ]        pci_cl_data_araddr,
   input  wire  [ INST_BURST_WIDTH     -1 : 0 ]        pci_cl_data_arlen,
   input  wire  [ 3                    -1 : 0 ]        pci_cl_data_arsize,
   input  wire  [ 2                    -1 : 0 ]        pci_cl_data_arburst,
   input  wire                                         pci_cl_data_arvalid,
   output wire                                         pci_cl_data_arready,
 // Slave Interface Read Data
   output wire  [ INST_DATA_WIDTH      -1 : 0 ]        pci_cl_data_rdata,
   output wire  [ 2                    -1 : 0 ]        pci_cl_data_rresp,
   output wire                                         pci_cl_data_rlast,
   output wire                                         pci_cl_data_rvalid,
   input  wire                                         pci_cl_data_rready,

  // CL_wrapper -> DDR0 AXI4 interface
    // Master Interface Write Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr0_awaddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr0_awlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr0_awsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr0_awburst,
    output wire                                         cl_ddr0_awvalid,
    input  wire                                         cl_ddr0_awready,
    // Master Interface Write Data
    output wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        cl_ddr0_wdata,
    output wire  [ IBUF_WSTRB_W         -1 : 0 ]        cl_ddr0_wstrb,
    output wire                                         cl_ddr0_wlast,
    output wire                                         cl_ddr0_wvalid,
    input  wire                                         cl_ddr0_wready,
    // Master Interface Write Response
    input  wire  [ 2                    -1 : 0 ]        cl_ddr0_bresp,
    input  wire                                         cl_ddr0_bvalid,
    output wire                                         cl_ddr0_bready,
    // Master Interface Read Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr0_araddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr0_arlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr0_arsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr0_arburst,
    output wire                                         cl_ddr0_arvalid,
    output wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr0_arid,
    input  wire                                         cl_ddr0_arready,
    // Master Interface Read Data
    input  wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        cl_ddr0_rdata,
    input  wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr0_rid,
    input  wire  [ 2                    -1 : 0 ]        cl_ddr0_rresp,
    input  wire                                         cl_ddr0_rlast,
    input  wire                                         cl_ddr0_rvalid,
    output wire                                         cl_ddr0_rready,

  // CL_wrapper -> DDR1 AXI4 interface
    // Master Interface Write Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr1_awaddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr1_awlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr1_awsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr1_awburst,
    output wire                                         cl_ddr1_awvalid,
    input  wire                                         cl_ddr1_awready,
    // Master Interface Write Data
    output wire  [ OBUF_AXI_DATA_WIDTH  -1 : 0 ]        cl_ddr1_wdata,
    output wire  [ OBUF_WSTRB_W         -1 : 0 ]        cl_ddr1_wstrb,
    output wire                                         cl_ddr1_wlast,
    output wire                                         cl_ddr1_wvalid,
    input  wire                                         cl_ddr1_wready,
    // Master Interface Write Response
    input  wire  [ 2                    -1 : 0 ]        cl_ddr1_bresp,
    input  wire                                         cl_ddr1_bvalid,
    output wire                                         cl_ddr1_bready,
    // Master Interface Read Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr1_araddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr1_arlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr1_arsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr1_arburst,
    output wire                                         cl_ddr1_arvalid,
    output wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr1_arid,
    input  wire                                         cl_ddr1_arready,
    // Master Interface Read Data
    input  wire  [ OBUF_AXI_DATA_WIDTH  -1 : 0 ]        cl_ddr1_rdata,
    input  wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr1_rid,
    input  wire  [ 2                    -1 : 0 ]        cl_ddr1_rresp,
    input  wire                                         cl_ddr1_rlast,
    input  wire                                         cl_ddr1_rvalid,
    output wire                                         cl_ddr1_rready,

  // CL_wrapper -> DDR2 AXI4 interface
    // Master Interface Write Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr2_awaddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr2_awlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr2_awsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr2_awburst,
    output wire                                         cl_ddr2_awvalid,
    input  wire                                         cl_ddr2_awready,
    // Master Interface Write Data
    output wire  [ WBUF_AXI_DATA_WIDTH  -1 : 0 ]        cl_ddr2_wdata,
    output wire  [ WBUF_WSTRB_W         -1 : 0 ]        cl_ddr2_wstrb,
    output wire                                         cl_ddr2_wlast,
    output wire                                         cl_ddr2_wvalid,
    input  wire                                         cl_ddr2_wready,
    // Master Interface Write Response
    input  wire  [ 2                    -1 : 0 ]        cl_ddr2_bresp,
    input  wire                                         cl_ddr2_bvalid,
    output wire                                         cl_ddr2_bready,
    // Master Interface Read Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr2_araddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr2_arlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr2_arsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr2_arburst,
    output wire                                         cl_ddr2_arvalid,
    output wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr2_arid,
    input  wire                                         cl_ddr2_arready,
    // Master Interface Read Data
    input  wire  [ WBUF_AXI_DATA_WIDTH  -1 : 0 ]        cl_ddr2_rdata,
    input  wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr2_rid,
    input  wire  [ 2                    -1 : 0 ]        cl_ddr2_rresp,
    input  wire                                         cl_ddr2_rlast,
    input  wire                                         cl_ddr2_rvalid,
    output wire                                         cl_ddr2_rready,

  // CL_wrapper -> DDR3 AXI4 interface
    // Master Interface Write Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr3_awaddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr3_awlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr3_awsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr3_awburst,
    output wire                                         cl_ddr3_awvalid,
    input  wire                                         cl_ddr3_awready,
    // Master Interface Write Data
    output wire  [ BBUF_AXI_DATA_WIDTH  -1 : 0 ]        cl_ddr3_wdata,
    output wire  [ BBUF_WSTRB_W         -1 : 0 ]        cl_ddr3_wstrb,
    output wire                                         cl_ddr3_wlast,
    output wire                                         cl_ddr3_wvalid,
    input  wire                                         cl_ddr3_wready,
    // Master Interface Write Response
    input  wire  [ 2                    -1 : 0 ]        cl_ddr3_bresp,
    input  wire                                         cl_ddr3_bvalid,
    output wire                                         cl_ddr3_bready,
    // Master Interface Read Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr3_araddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr3_arlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr3_arsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr3_arburst,
    output wire                                         cl_ddr3_arvalid,
    output wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr3_arid,
    input  wire                                         cl_ddr3_arready,
    // Master Interface Read Data
    input  wire  [ BBUF_AXI_DATA_WIDTH  -1 : 0 ]        cl_ddr3_rdata,
    input  wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr3_rid,
    input  wire  [ 2                    -1 : 0 ]        cl_ddr3_rresp,
    input  wire                                         cl_ddr3_rlast,
    input  wire                                         cl_ddr3_rvalid,
    output wire                                         cl_ddr3_rready,


  // CL_wrapper -> DDR3 AXI4 interface
    // Master Interface Write Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr4_awaddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr4_awlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr4_awsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr4_awburst,
    output wire                                         cl_ddr4_awvalid,
    input  wire                                         cl_ddr4_awready,
    // Master Interface Write Data
    output wire  [ PU_AXI_DATA_WIDTH    -1 : 0 ]        cl_ddr4_wdata,
    output wire  [ PU_WSTRB_W           -1 : 0 ]        cl_ddr4_wstrb,
    output wire                                         cl_ddr4_wlast,
    output wire                                         cl_ddr4_wvalid,
    input  wire                                         cl_ddr4_wready,
    // Master Interface Write Response
    input  wire  [ 2                    -1 : 0 ]        cl_ddr4_bresp,
    input  wire                                         cl_ddr4_bvalid,
    output wire                                         cl_ddr4_bready,
    // Master Interface Read Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr4_araddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr4_arlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr4_arsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr4_arburst,
    output wire                                         cl_ddr4_arvalid,
    output wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr4_arid,
    input  wire                                         cl_ddr4_arready,
    // Master Interface Read Data
    input  wire  [ PU_AXI_DATA_WIDTH    -1 : 0 ]        cl_ddr4_rdata,
    input  wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr4_rid,
    input  wire  [ 2                    -1 : 0 ]        cl_ddr4_rresp,
    input  wire                                         cl_ddr4_rlast,
    input  wire                                         cl_ddr4_rvalid,
    output wire                                         cl_ddr4_rready,
    //add for readonly
        // Master Interface Read Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr5_araddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr5_arlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr5_arsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr5_arburst,
    output wire                                         cl_ddr5_arvalid,
    output wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr5_arid,
    input  wire                                         cl_ddr5_arready,
    // Master Interface Read Data
    input  wire  [ INST_DATA_WIDTH    -1 : 0 ]          cl_ddr5_rdata,
    input  wire  [ AXI_ID_WIDTH         -1 : 0 ]        cl_ddr5_rid,
    input  wire  [ 2                    -1 : 0 ]        cl_ddr5_rresp,
    input  wire                                         cl_ddr5_rlast,
    input  wire                                         cl_ddr5_rvalid,
    output wire                                         cl_ddr5_rready,
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        cl_ddr5_awaddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        cl_ddr5_awlen,
    output wire  [ 3                    -1 : 0 ]        cl_ddr5_awsize,
    output wire  [ 2                    -1 : 0 ]        cl_ddr5_awburst,
    output wire                                         cl_ddr5_awvalid,
    input  wire                                         cl_ddr5_awready,
    // Master Interface Write Data
    output wire  [ PU_AXI_DATA_WIDTH    -1 : 0 ]        cl_ddr5_wdata,
    output wire  [ PU_WSTRB_W           -1 : 0 ]        cl_ddr5_wstrb,
    output wire                                         cl_ddr5_wlast,
    output wire                                         cl_ddr5_wvalid,
    input  wire                                         cl_ddr5_wready,
    // Master Interface Write Response
    input  wire  [ 2                    -1 : 0 ]        cl_ddr5_bresp,
    input  wire                                         cl_ddr5_bvalid,
    output wire                                         cl_ddr5_bready
);

//ghd_add_begin
//    wire choose_8bit_out;

    wire acc_clear_pd, acc_clear_lidar;
    wire [IBUF_DATA_WIDTH-1:0] ibuf_read_data_pd, ibuf_read_data_lidar;
    wire [WBUF_DATA_WIDTH-1:0] wbuf_read_data_pd, wbuf_read_data_lidar;
    wire [WBUF_ADDR_WIDTH-1:0] wbuf_read_addr_pd, wbuf_read_addr_lidar;
    wire sys_wbuf_read_req_pd, sys_wbuf_read_req_lidar;
    wire [WBUF_ADDR_WIDTH-1:0] sys_wbuf_read_addr_pd, sys_wbuf_read_addr_lidar;
    wire compute_req_pd, compute_req_lidar;
    wire loop_exit_pd, loop_exit_lidar;
    wire sys_inner_loop_start_pd, sys_inner_loop_start_lidar;
    wire [BBUF_DATA_WIDTH-1:0] bbuf_read_data_pd, bbuf_read_data_lidar;
    wire bias_read_req_pd, bias_read_req_lidar;
    wire [BBUF_ADDR_WIDTH-1:0] bias_read_addr_pd, bias_read_addr_lidar;
    wire sys_bias_read_req_pd, sys_bias_read_req_lidar;
    wire [BBUF_ADDR_WIDTH-1:0] sys_bias_read_addr_pd, sys_bias_read_addr_lidar;
    wire sys_array_c_sel_pd, sys_array_c_sel_lidar;
    wire obuf_write_req_pd, obuf_write_req_lidar;
    wire [OBUF_ADDR_WIDTH-1:0] obuf_write_addr_pd, obuf_write_addr_lidar;
    wire [OBUF_DATA_WIDTH-1:0] obuf_read_data_pd, obuf_read_data_lidar;
    wire [OBUF_ADDR_WIDTH-1:0] obuf_read_addr_pd, obuf_read_addr_lidar;
    wire sys_obuf_read_req_pd, sys_obuf_read_req_lidar;
    wire [OBUF_ADDR_WIDTH-1:0] sys_obuf_read_addr_pd, sys_obuf_read_addr_lidar;
    wire [OBUF_DATA_WIDTH-1:0] sys_obuf_write_data_pd, sys_obuf_write_data_lidar;
    wire sys_obuf_write_req_pd, sys_obuf_write_req_lidar;
    wire [OBUF_ADDR_WIDTH-1:0] sys_obuf_write_addr_pd, sys_obuf_write_addr_lidar;

    wire acc_clear;
    wire [IBUF_DATA_WIDTH-1:0] ibuf_read_data;
    wire [WBUF_DATA_WIDTH-1:0] wbuf_read_data;
    wire [WBUF_ADDR_WIDTH-1:0] wbuf_read_addr;
    wire compute_req;
    wire loop_exit;
    wire sys_inner_loop_start;
//    wire choose_8bit;
    wire [BBUF_DATA_WIDTH-1:0] bbuf_read_data;
    wire bias_read_req;
    wire [BBUF_ADDR_WIDTH-1:0] bias_read_addr;
    wire sys_array_c_sel;
    wire obuf_write_req;
    wire [OBUF_ADDR_WIDTH-1:0] obuf_write_addr;
    wire [OBUF_DATA_WIDTH-1:0] obuf_read_data;
    wire [OBUF_ADDR_WIDTH-1:0] obuf_read_addr;
//ghd_add_end

    // add for 8bit/16bit ibuf
//   wire [ 14       -1 : 0 ]        tag_mem_write_addr_ibuf;
//   wire mem_write_req_in_ibuf;
//   wire  [256  -1 : 0]                                mem_write_data_in_ibuf;
//   wire [ 13       -1 : 0 ]        tag_buf_read_addr_ibuf;
//   wire                                         buf_read_req_ibuf;
//   wire [ 512       -1 : 0 ]        _buf_read_data_ibuf;

//    // add for 8bit/16bit bbuf
//     wire [ 11       -1 : 0 ]        tag_mem_write_addr_bbuf;
//     wire                                        mem_write_req_bbuf;
//     wire [ 256       -1 : 0 ]        mem_write_data_bbuf;
//     wire [ 9       -1 : 0 ]        tag_buf_read_addr_bbuf;
//      wire                                         buf_read_req_bbuf;
//    wire [ 1024       -1 : 0 ]        _buf_read_data_bbuf;

//   // add for 8bit/16bit wbuf
//    wire [ 12       -1 : 0 ]        tag_mem_write_addr_wbuf;
//    wire                                        mem_write_req_dly_wbuf;
//    wire [ 256       -1 : 0 ]        _mem_write_data_wbuf;
//    wire [ 11       -1 : 0 ]        tag_buf_read_addr_wbuf;
//    wire                                         buf_read_req_wbuf;
//    wire  [ 512       -1 : 0 ]        _buf_read_data_wbuf;

//   // add for 8bit/16bit obuf
//     wire [ 15       -1 : 0 ]        tag_mem_write_addr_obuf;
//     wire                                        mem_write_req_obuf;
//     wire [ 256       -1 : 0 ]        mem_write_data_obuf;
//     wire [ 15       -1 : 0 ]        tag_mem_read_addr_obuf;
//     wire                                        mem_read_req_obuf;
//    wire [ 256       -1 : 0 ]        mem_read_data_obuf;
//    wire [ 2048       -1 : 0 ]        pu_read_data_obuf;
//     wire [ 12       -1 : 0 ]        tag_buf_write_addr_obuf;
//     wire   buf_write_req_obuf;
//     wire  [ 2048       -1 : 0 ]        buf_write_data_obuf;
//     wire [ 12       -1 : 0 ]        tag_buf_read_addr_obuf;
//      wire                                         buf_read_req_obuf;
//    wire [ 2048       -1 : 0 ]        _buf_read_data_obuf;
    wire choose_mux_out;

top_wrapper # (
)top_cl_wrapper(   
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
//    .choose_8bit                    ( choose_8bit                    ),//ghd_add    
    .pci_cl_data_awaddr             ( pci_cl_data_awaddr             ),
    .pci_cl_data_awlen              ( pci_cl_data_awlen              ),
    .pci_cl_data_awsize             ( pci_cl_data_awsize             ),
    .pci_cl_data_awburst            ( pci_cl_data_awburst            ),
    .pci_cl_data_awvalid            ( pci_cl_data_awvalid            ),
    .pci_cl_data_awready            ( pci_cl_data_awready            ),
    .pci_cl_data_wdata              ( pci_cl_data_wdata              ),
    .pci_cl_data_wstrb              ( pci_cl_data_wstrb              ),
    .pci_cl_data_wlast              ( pci_cl_data_wlast              ),
    .pci_cl_data_wvalid             ( pci_cl_data_wvalid             ),
    .pci_cl_data_wready             ( pci_cl_data_wready             ),
    .pci_cl_data_bresp              ( pci_cl_data_bresp              ),
    .pci_cl_data_bvalid             ( pci_cl_data_bvalid             ),
    .pci_cl_data_bready             ( pci_cl_data_bready             ),
    .pci_cl_data_araddr             ( pci_cl_data_araddr             ),
    .pci_cl_data_arlen              ( pci_cl_data_arlen              ),
    .pci_cl_data_arsize             ( pci_cl_data_arsize             ),
    .pci_cl_data_arburst            ( pci_cl_data_arburst            ),
    .pci_cl_data_arvalid            ( pci_cl_data_arvalid            ),
    .pci_cl_data_arready            ( pci_cl_data_arready            ),
    .pci_cl_data_rdata              ( pci_cl_data_rdata              ),
    .pci_cl_data_rresp              ( pci_cl_data_rresp              ),
    .pci_cl_data_rlast              ( pci_cl_data_rlast              ),
    .pci_cl_data_rvalid             ( pci_cl_data_rvalid             ),
    .pci_cl_data_rready             ( pci_cl_data_rready             ),

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

    // .o_m_axi_asr_awaddr                 ( cl_ddr5_awaddr                 ),
    // .o_m_axi_asr_awlen                  ( cl_ddr5_awlen                  ),
    // .o_m_axi_asr_awsize                 ( cl_ddr5_awsize                 ),
    // .o_m_axi_asr_awburst                ( cl_ddr5_awburst                ),
    // .o_m_axi_asr_awvalid                ( cl_ddr5_awvalid                ),
    // .i_m_axi_asr_awready                ( cl_ddr5_awready                ),
    // .o_m_axi_asr_wdata                  ( cl_ddr5_wdata                  ),
    // .o_m_axi_asr_wstrb                  ( cl_ddr5_wstrb                  ),
    // .o_m_axi_asr_wlast                  ( cl_ddr5_wlast                  ),
    // .o_m_axi_asr_wvalid                 ( cl_ddr5_wvalid                 ),
    // .i_m_axi_asr_wready                 ( cl_ddr5_wready                 ),
    // .i_m_axi_asr_bresp                  ( cl_ddr5_bresp                  ),
    // .i_m_axi_asr_bvalid                 ( cl_ddr5_bvalid                 ),
    // .o_m_axi_asr_bready                 ( cl_ddr5_bready                 ),
    // .o_m_axi_icash_araddr                 ( cl_ddr5_araddr                 ),
    // .o_m_axi_icash_arlen                  ( cl_ddr5_arlen                  ),
    // .o_m_axi_icash_arsize                 ( cl_ddr5_arsize                 ),
    // .o_m_axi_icash_arburst                ( cl_ddr5_arburst                ),
    // .o_m_axi_icash_arvalid                ( cl_ddr5_arvalid                ),
    // .o_m_axi_icash_arid                   ( cl_ddr5_arid                   ),
    // .i_m_axi_icash_arready                ( cl_ddr5_arready                ),
    // .i_m_axi_icash_rdata                  ( cl_ddr5_rdata                  ),
    // .i_m_axi_icash_rid                    ( cl_ddr5_rid                    ),
    // .i_m_axi_icash_rresp                  ( cl_ddr5_rresp                  ),
    // .i_m_axi_icash_rlast                  ( cl_ddr5_rlast                  ),
    // .i_m_axi_icash_rvalid                 ( cl_ddr5_rvalid                 ),
    // .o_m_axi_icash_rready                 ( cl_ddr5_rready                 ),

 // add for 8bit/16bit ibuf
//  .ibuf_mem_write_addr (tag_mem_write_addr_ibuf),
//  .ibuf_mem_write_req (mem_write_req_in_ibuf),
//  .ibuf_mem_write_data (mem_write_data_in_ibuf),
//  .ibuf_mem_read_addr (tag_buf_read_addr_ibuf),
//  .ibuf_mem_read_req (buf_read_req_ibuf),
//  .ibuf_mem_read_data (_buf_read_data_ibuf),
//  // add for 8bit/16bit bbuf
//  .bbuf_mem_write_addr (tag_mem_write_addr_bbuf),
//  .bbuf_mem_write_req (mem_write_req_bbuf),
//  .bbuf_mem_write_data (mem_write_data_bbuf),
//  .bbuf_mem_read_addr (tag_buf_read_addr_bbuf),
//  .bbuf_mem_read_req (buf_read_req_bbuf),
//  .bbuf_mem_read_data (_buf_read_data_bbuf),
//  // add for 8bit/16bit wbuf
//  .wbuf_mem_write_addr(tag_mem_write_addr_wbuf),
//  .wbuf_mem_write_req (mem_write_req_dly_wbuf),
//  .wbuf_mem_write_data (_mem_write_data_wbuf),
//  .wbuf_mem_read_addr (tag_buf_read_addr_wbuf),
//  .wbuf_mem_read_req (buf_read_req_wbuf),
//  .wbuf_mem_read_data (_buf_read_data_wbuf),
//  // add for 8bit/16bit obuf
//  .obuf_mem_write_addr (tag_mem_write_addr_obuf),
//  .obuf_mem_write_req (mem_write_req_obuf),
//  .obuf_mem_write_data (mem_write_data_obuf),
//  .obuf_mem_read_addr (tag_mem_read_addr_obuf),
//  .obuf_mem_read_req (mem_read_req_obuf),
//  .obuf_mem_read_data (mem_read_data_obuf),
//  .obuf_pu_read_data (pu_read_data_obuf),
//  .obuf_pu_write_addr (tag_buf_write_addr_obuf),
//  .obuf_pu_write_req (buf_write_req_obuf),
//  .obuf_pu_write_data (buf_write_data_obuf),
//  .obuf_pu_read_addr (tag_buf_read_addr_obuf),
//  .obuf_pu_read_req (buf_read_req_obuf),
//  ._obuf_mem_read_data(_buf_read_data_obuf),
  
  // add for choose infra_red or LiDAR data for RAM
   .choose_8bit (choose_mux_out),
   //ghd_add_begin
        .acc_clear(acc_clear_pd),
        .ibuf_read_data(ibuf_read_data_pd),
        .wbuf_read_data(wbuf_read_data_pd),
        .wbuf_read_addr(wbuf_read_addr_pd),
        .sys_wbuf_read_req(sys_wbuf_read_req_pd),
        .sys_wbuf_read_addr(sys_wbuf_read_addr_pd),
        .compute_req(compute_req_pd),
        .loop_exit(loop_exit_pd),
        .sys_inner_loop_start(sys_inner_loop_start_pd),
        .bbuf_read_data(bbuf_read_data_pd),
        .bias_read_req(bias_read_req_pd),
        .bias_read_addr(bias_read_addr_pd),
        .sys_bias_read_req(sys_bias_read_req_pd),
        .sys_bias_read_addr(sys_bias_read_addr_pd),
        .sys_array_c_sel(sys_array_c_sel_pd),
        .obuf_write_req(obuf_write_req_pd),
        .obuf_write_addr(obuf_write_addr_pd),
        .obuf_read_data(obuf_read_data_pd),
        .obuf_read_addr(obuf_read_addr_pd),
        .sys_obuf_read_req(sys_obuf_read_req_pd),
        .sys_obuf_read_addr(sys_obuf_read_addr_pd),
        .sys_obuf_write_data(sys_obuf_write_data_pd),
        .sys_obuf_write_req(sys_obuf_write_req_pd),
        .sys_obuf_write_addr(sys_obuf_write_addr_pd) 
   //ghd_add_end
  );

//ram_mux#(
//)top_mux(
//  .clk                                 ( clk                            ),
//  .reset                          ( reset                          ),
//   // add for 8bit/16bit ibuf
//  .ibuf_mem_write_addr (tag_mem_write_addr_ibuf),
//  .ibuf_mem_write_req (mem_write_req_in_ibuf),
//  .ibuf_mem_write_data (mem_write_data_in_ibuf),
//  .ibuf_mem_read_addr (tag_buf_read_addr_ibuf),
//  .ibuf_mem_read_req (buf_read_req_ibuf),
//  .ibuf_mem_read_data (_buf_read_data_ibuf),
//  // add for 8bit/16bit bbuf
//  .bbuf_mem_write_addr (tag_mem_write_addr_bbuf),
//  .bbuf_mem_write_req (mem_write_req_bbuf),
//  .bbuf_mem_write_data (mem_write_data_bbuf),
//  .bbuf_mem_read_addr (tag_buf_read_addr_bbuf),
//  .bbuf_mem_read_req (buf_read_req_bbuf),
//  .bbuf_mem_read_data (_buf_read_data_bbuf),
//  // add for 8bit/16bit wbuf
//  .wbuf_mem_write_addr(tag_mem_write_addr_wbuf),
//  .wbuf_mem_write_req (mem_write_req_dly_wbuf),
//  .wbuf_mem_write_data (_mem_write_data_wbuf),
//  .wbuf_mem_read_addr (tag_buf_read_addr_wbuf),
//  .wbuf_mem_read_req (buf_read_req_wbuf),
//  .wbuf_mem_read_data (_buf_read_data_wbuf),
//  // add for 8bit/16bit obuf
//  .obuf_mem_write_addr (tag_mem_write_addr_obuf),
//  .obuf_mem_write_req (mem_write_req_obuf),
//  .obuf_mem_write_data (mem_write_data_obuf),
//  .obuf_mem_read_addr (tag_mem_read_addr_obuf),
//  .obuf_mem_read_req (mem_read_req_obuf),
//  .obuf_mem_read_data (mem_read_data_obuf),
//  .obuf_pu_read_data (pu_read_data_obuf),
//  .obuf_pu_write_addr (tag_buf_write_addr_obuf),
//  .obuf_pu_write_req (buf_write_req_obuf),
//  .obuf_pu_write_data (buf_write_data_obuf),
//  .obuf_pu_read_addr (tag_buf_read_addr_obuf),
//  .obuf_pu_read_req (buf_read_req_obuf),
//  ._obuf_mem_read_data(_buf_read_data_obuf),
//  // add for choose infra_red or LiDAR data for RAM
//  .choose_mux_in (choose_mux_out)
//);

    mux_sysytolic_array #(
        .INST_W(INST_W),
        .INST_ADDR_W(INST_ADDR_W),
        .IFIFO_ADDR_W(IFIFO_ADDR_W),
        .BUF_TYPE_W(BUF_TYPE_W),
        .OP_CODE_W(OP_CODE_W),
        .OP_SPEC_W(OP_SPEC_W),
        .LOOP_ID_W(LOOP_ID_W),
        .ARRAY_N(ARRAY_N),
        .ARRAY_M(ARRAY_M),
        .DATA_WIDTH(DATA_WIDTH),
        .BIAS_WIDTH(BIAS_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .WEIGHT_ROW_NUM(WEIGHT_ROW_NUM),
        .NUM_TAGS(NUM_TAGS),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_BURST_WIDTH(AXI_BURST_WIDTH),
        .IBUF_AXI_DATA_WIDTH(IBUF_AXI_DATA_WIDTH),
        .OBUF_AXI_DATA_WIDTH(OBUF_AXI_DATA_WIDTH),
        .PU_AXI_DATA_WIDTH(PU_AXI_DATA_WIDTH),
        .WBUF_AXI_DATA_WIDTH(WBUF_AXI_DATA_WIDTH),
        .BBUF_AXI_DATA_WIDTH(BBUF_AXI_DATA_WIDTH),
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .INST_ADDR_WIDTH(INST_ADDR_WIDTH),
        .INST_DATA_WIDTH(INST_DATA_WIDTH),
        .CTRL_ADDR_WIDTH(CTRL_ADDR_WIDTH),
        .CTRL_DATA_WIDTH(CTRL_DATA_WIDTH)
    ) u_mux_sysytolic_array (
        .clk(clk),
        .reset(reset),
        .choose_8bit_in(choose_mux_out),      
        
        .acc_clear_pd(acc_clear_pd),
        .ibuf_read_data_pd(ibuf_read_data_pd),
        .wbuf_read_data_pd(wbuf_read_data_pd),
        .wbuf_read_addr_pd(wbuf_read_addr_pd),
        .sys_wbuf_read_req_pd(sys_wbuf_read_req_pd),
        .sys_wbuf_read_addr_pd(sys_wbuf_read_addr_pd),
        .compute_req_pd(compute_req_pd),
        .loop_exit_pd(loop_exit_pd),
        .sys_inner_loop_start_pd(sys_inner_loop_start_pd),
        .bbuf_read_data_pd(bbuf_read_data_pd),
        .bias_read_req_pd(bias_read_req_pd),
        .bias_read_addr_pd(bias_read_addr_pd),
        .sys_bias_read_req_pd(sys_bias_read_req_pd),
        .sys_bias_read_addr_pd(sys_bias_read_addr_pd),
        .sys_array_c_sel_pd(sys_array_c_sel_pd),
        .obuf_write_req_pd(obuf_write_req_pd),
        .obuf_write_addr_pd(obuf_write_addr_pd),
        .obuf_read_data_pd(obuf_read_data_pd),
        .obuf_read_addr_pd(obuf_read_addr_pd),
        .sys_obuf_read_req_pd(sys_obuf_read_req_pd),
        .sys_obuf_read_addr_pd(sys_obuf_read_addr_pd),
        .sys_obuf_write_data_pd(sys_obuf_write_data_pd),
        .sys_obuf_write_req_pd(sys_obuf_write_req_pd),
        .sys_obuf_write_addr_pd(sys_obuf_write_addr_pd),

        .acc_clear_lidar(acc_clear_lidar),
        .ibuf_read_data_lidar(ibuf_read_data_lidar),
        .wbuf_read_data_lidar(wbuf_read_data_lidar),
        .wbuf_read_addr_lidar(wbuf_read_addr_lidar),
        .sys_wbuf_read_req_lidar(sys_wbuf_read_req_lidar),
        .compute_req_lidar(compute_req_lidar),
        .loop_exit_lidar(loop_exit_lidar),
        .sys_inner_loop_start_lidar(sys_inner_loop_start_lidar),
        .bbuf_read_data_lidar(bbuf_read_data_lidar),
        .bias_read_req_lidar(bias_read_req_lidar),
        .bias_read_addr_lidar(bias_read_addr_lidar),
        .sys_bias_read_req_lidar(sys_bias_read_req_lidar),
        .sys_bias_read_addr_lidar(sys_bias_read_addr_lidar),
        .sys_array_c_sel_lidar(sys_array_c_sel_lidar),
        .obuf_write_req_lidar(obuf_write_req_lidar),
        .obuf_write_addr_lidar(obuf_write_addr_lidar),
        .obuf_read_data_lidar(obuf_read_data_lidar),
        .obuf_read_addr_lidar(obuf_read_addr_lidar),
        .sys_obuf_read_req_lidar(sys_obuf_read_req_lidar),
        .sys_obuf_read_addr_lidar(sys_obuf_read_addr_lidar),
        .sys_obuf_write_data_lidar(sys_obuf_write_data_lidar),
        .sys_obuf_write_req_lidar(sys_obuf_write_req_lidar),
        .sys_obuf_write_addr_lidar(sys_obuf_write_addr_lidar)

        // .acc_clear(acc_clear),
        // .ibuf_read_data(ibuf_read_data),
        // .wbuf_read_data(wbuf_read_data),
        // .wbuf_read_addr(wbuf_read_addr),
        // .sys_wbuf_read_req(sys_wbuf_read_req),
        // .compute_req(compute_req),
        // .loop_exit(loop_exit),
        // .sys_inner_loop_start(sys_inner_loop_start),
        // .choose_8bit(choose_8bit_out),
        // .bbuf_read_data(bbuf_read_data),
        // .bias_read_req(bias_read_req),
        // .bias_read_addr(bias_read_addr),
        // .sys_bias_read_req(sys_bias_read_req),
        // .sys_bias_read_addr(sys_bias_read_addr),
        // .sys_array_c_sel(sys_array_c_sel),
        // .obuf_write_req(obuf_write_req),
        // .obuf_write_addr(obuf_write_addr),
        // .obuf_read_data(obuf_read_data),
        // .obuf_read_addr(obuf_read_addr),
        // .sys_obuf_read_req(sys_obuf_read_req),
        // .sys_obuf_read_addr(sys_obuf_read_addr),
        // .sys_obuf_write_data(sys_obuf_write_data),
        // .sys_obuf_write_req(sys_obuf_write_req),
        // .sys_obuf_write_addr(sys_obuf_write_addr)
    );

//=============================================================
// VCD
//=============================================================
`ifdef COCOTB_TOPLEVEL_top_wrapper
  initial begin
    $dumpfile("top_wrapper.vcd");
    $dumpvars(0, top_wrapper);
  end
`endif
//=============================================================

endmodule
