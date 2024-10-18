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
  input wire [ 14       -1 : 0 ]        ibuf_mem_write_addr,
  input wire ibuf_mem_write_req,
  input wire  [256  -1 : 0]                                ibuf_mem_write_data,
  input wire [ 13       -1 : 0 ]        ibuf_mem_read_addr,
  input  wire                                         ibuf_mem_read_req,
  output wire [ 512       -1 : 0 ]        ibuf_mem_read_data,

// add for 8bit/16bit bbuf
  input wire [ 11       -1 : 0 ]       bbuf_mem_write_addr,
  input wire                                        bbuf_mem_write_req,
  input wire [ 256       -1 : 0 ]        bbuf_mem_write_data,
  input wire [ 9       -1 : 0 ]        bbuf_mem_read_addr,
  input  wire                                         bbuf_mem_read_req,
  output wire [ 1024       -1 : 0 ]        bbuf_mem_read_data,

 // add for 8bit/16bit wbuf
  input wire [ 12       -1 : 0 ]        wbuf_mem_write_addr,
  input wire                                        wbuf_mem_write_req,
  input wire [ 256       -1 : 0 ]        wbuf_mem_write_data,
  input wire [ 11       -1 : 0 ]        wbuf_mem_read_addr,
  input  wire                                         wbuf_mem_read_req,
  output wire  [ 512       -1 : 0 ]        wbuf_mem_read_data,

// add for 8bit/16bit obuf
  input wire [ 15       -1 : 0 ]        obuf_mem_write_addr,
  input wire                                        obuf_mem_write_req,
  input wire [ 256       -1 : 0 ]        obuf_mem_write_data,
  input wire [ 15       -1 : 0 ]        obuf_mem_read_addr,
  input wire                                        obuf_mem_read_req,
  output wire [ 256       -1 : 0 ]        obuf_mem_read_data,
  input wire [ 12       -1 : 0 ]        obuf_pu_write_addr,
  input wire   obuf_pu_write_req,
  input wire  [ 2048       -1 : 0 ]        obuf_pu_write_data,
  input wire [ 12       -1 : 0 ]        obuf_pu_read_addr,
  input  wire                                         obuf_pu_read_req,
  output wire [ 2048       -1 : 0 ]        obuf_pu_read_data,
  output wire [ 2048       -1 : 0 ]   _obuf_mem_read_data,

//==========LiDAR===========
// add for 8bit/16bit ibuf
  input wire [ 14       -1 : 0 ]        LiDAR_ibuf_mem_write_addr,
  input wire LiDAR_ibuf_mem_write_req,
  input wire  [256  -1 : 0]                                LiDAR_ibuf_mem_write_data,
  input wire [ 13       -1 : 0 ]        LiDAR_ibuf_mem_read_addr,
  input  wire                                         LiDAR_ibuf_mem_read_req,
  output wire [ 512       -1 : 0 ]        LiDAR_ibuf_mem_read_data,
  // add for 8bit/16bit bbuf
  input wire [ 11       -1 : 0 ]        LiDAR_bbuf_mem_write_addr,
  input wire                                        LiDAR_bbuf_mem_write_req,
  input wire [ 256       -1 : 0 ]        LiDAR_bbuf_mem_write_data,
  input wire [ 9       -1 : 0 ]       LiDAR_bbuf_mem_read_addr,
  input  wire                                         LiDAR_bbuf_mem_read_req,
  output wire [ 1024       -1 : 0 ]        LiDAR_bbuf_mem_read_data,
  // add for 8bit/16bit wbuf
  input wire [ 12       -1 : 0 ]        LiDAR_wbuf_mem_write_addr,
  input wire                                        LiDAR_wbuf_mem_write_req,
  input wire [ 256       -1 : 0 ]        LiDAR_wbuf_mem_write_data,
  input wire [ 11       -1 : 0 ]        LiDAR_wbuf_mem_read_addr,
  input  wire                                         LiDAR_wbuf_mem_read_req,
  output wire  [ 512       -1 : 0 ]        LiDAR_wbuf_mem_read_data,
  // add for 8bit/16bit obuf
  input wire [ 15       -1 : 0 ]        LiDAR_obuf_mem_write_addr,
  input wire                                        LiDAR_obuf_mem_write_req,
  input wire [ 256       -1 : 0 ]        LiDAR_obuf_mem_write_data,
  input wire [ 15       -1 : 0 ]        LiDAR_obuf_mem_read_addr,
  input wire                                        LiDAR_obuf_mem_read_req,
  output wire [ 256       -1 : 0 ]        LiDAR_obuf_mem_read_data,
  input wire [ 12       -1 : 0 ]        LiDAR_obuf_pu_write_addr,
  input wire   LiDAR_obuf_pu_write_req,
  input wire  [ 2048       -1 : 0 ]        LiDAR_obuf_pu_write_data,
  input wire [ 12       -1 : 0 ]        LiDAR_obuf_pu_read_addr,
  input  wire                                        LiDAR_obuf_pu_read_req,
  output wire [ 2048       -1 : 0 ]        LiDAR_obuf_pu_read_data,
  

    input wire choose_mux_in
);


  // choose for 8bit/16bit ibuf
  wire [ 14       -1 : 0 ]        choosed_ibuf_tag_mem_write_addr;
  wire choosed_ibuf_mem_write_req_in;
  wire  [256  -1 : 0]                                choosed_ibuf_mem_write_data_in;
  wire [ 13       -1 : 0 ]        choosed_ibuf_tag_buf_read_addr;
  wire                                        choosed_ibuf_buf_read_req;
  wire [ 512       -1 : 0 ]        choosed_ibuf__buf_read_data;

    // choose for 8bit/16bit bbuf
  wire [ 11       -1 : 0 ]       choosed_bbuf_tag_mem_write_addr;
  wire                                        choosed_bbuf_mem_write_req;
  wire [ 256       -1 : 0 ]        choosed_bbuf_mem_write_data;
  wire [ 9       -1 : 0 ]        choosed_bbuf_tag_buf_read_addr;
  wire                                         choosed_bbuf_buf_read_req;
  wire [ 1024       -1 : 0 ]        choosed_bbuf__buf_read_data;

   // choose for 8bit/16bit wbuf
  wire [ 12       -1 : 0 ]        choosed_wbuf_tag_mem_write_addr;
  wire                                        choosed_wbuf_mem_write_req_dly;
  wire [ 256       -1 : 0 ]        choosed_wbuf__mem_write_data;
  wire [ 11       -1 : 0 ]        choosed_wbuf_tag_buf_read_addr;
  wire                                         choosed_wbuf_buf_read_req;
  wire  [ 512       -1 : 0 ]        choosed_wbuf__buf_read_data;

   // choose for 8bit/16bit obuf
  wire [ 15       -1 : 0 ]        choosed_obuf_tag_mem_write_addr;
  wire                                        choosed_obuf_mem_write_req;
  wire [ 256       -1 : 0 ]        choosed_obuf_mem_write_data;
  wire [ 15       -1 : 0 ]        choosed_obuf_tag_mem_read_addr;
  wire                                        choosed_obuf_mem_read_req;
  wire [ 256       -1 : 0 ]        choosed_obuf_mem_read_data;
  wire [ 2048       -1 : 0 ]        choosed_obuf_pu_read_data;
  wire [ 12       -1 : 0 ]        choosed_obuf_tag_buf_write_addr;
  wire   choosed_obuf_buf_write_req;
  wire  [ 2048       -1 : 0 ]        choosed_obuf_buf_write_data;
  wire [ 12       -1 : 0 ]        choosed_obuf_tag_buf_read_addr;
  wire                                         choosed_obuf_buf_read_req;
  wire [ 2048       -1 : 0 ]        choosed_obuf__buf_read_data;

  //  // choose_reg for 8bit/16bit ibuf
  // reg [ 14       -1 : 0 ]        reg_choosed_ibuf_tag_mem_write_addr;
  // reg reg_choosed_ibuf_mem_write_req_in;
  // reg  [256  -1 : 0]                                reg_choosed_ibuf_mem_write_data_in;
  // reg [ 13       -1 : 0 ]        reg_choosed_ibuf_tag_buf_read_addr;
  // reg                                        reg_choosed_ibuf_buf_read_req;
  // reg [ 512       -1 : 0 ]        reg_choosed_ibuf__buf_read_data;

  //   // choose_reg for 8bit/16bit bbuf
  // reg [ 11       -1 : 0 ]       reg_choosed_bbuf_tag_mem_write_addr;
  // reg                                        reg_choosed_bbuf_mem_write_req;
  // reg [ 256       -1 : 0 ]        reg_choosed_bbuf_mem_write_data;
  // reg [ 9       -1 : 0 ]        reg_choosed_bbuf_tag_buf_read_addr;
  // reg                                         reg_choosed_bbuf_buf_read_req;
  // reg [ 1024       -1 : 0 ]        reg_choosed_bbuf__buf_read_data;

  //  // choose_reg for 8bit/16bit wbuf
  // reg [ 12       -1 : 0 ]        reg_choosed_wbuf_tag_mem_write_addr;
  // reg                                        reg_choosed_wbuf_mem_write_req_dly;
  // reg [ 256       -1 : 0 ]        reg_choosed_wbuf__mem_write_data;
  // reg [ 11       -1 : 0 ]        reg_choosed_wbuf_tag_buf_read_addr;
  // reg                                         reg_choosed_wbuf_buf_read_req;
  // reg  [ 512       -1 : 0 ]        reg_choosed_wbuf__buf_read_data;

  //  // choose_reg for 8bit/16bit obuf
  // reg [ 15       -1 : 0 ]        reg_choosed_obuf_tag_mem_write_addr;
  // reg                                        reg_choosed_obuf_mem_write_req;
  // reg [ 256       -1 : 0 ]        reg_choosed_obuf_mem_write_data;
  // reg [ 15       -1 : 0 ]        reg_choosed_obuf_tag_mem_read_addr;
  // reg                                       reg_choosed_obuf_mem_read_req;
  // reg [ 256       -1 : 0 ]        reg_choosed_obuf_mem_read_data;
  // reg [ 2048       -1 : 0 ]        reg_choosed_obuf_pu_read_data;
  // reg [ 12       -1 : 0 ]        reg_choosed_obuf_tag_buf_write_addr;
  // reg   reg_choosed_obuf_buf_write_req;
  // reg  [ 2048       -1 : 0 ]        reg_choosed_obuf_buf_write_data;
  // reg [ 12       -1 : 0 ]        reg_choosed_obuf_tag_buf_read_addr;
  // reg                                         reg_choosed_obuf_buf_read_req;
  // reg [ 2048       -1 : 0 ]        reg_choosed_obuf__buf_read_data; 

 assign choosed_ibuf_tag_mem_write_addr = choose_mux_in? ibuf_mem_write_addr : LiDAR_ibuf_mem_write_addr;
 assign choosed_ibuf_mem_write_req_in = choose_mux_in? ibuf_mem_write_req : LiDAR_ibuf_mem_write_req;
 assign choosed_ibuf_mem_write_data_in = choose_mux_in? ibuf_mem_write_data : LiDAR_ibuf_mem_write_data;
 assign choosed_ibuf_tag_buf_read_addr = choose_mux_in?  ibuf_mem_read_addr : LiDAR_ibuf_mem_read_addr;
 assign choosed_ibuf_buf_read_req = choose_mux_in?  ibuf_mem_read_req : LiDAR_ibuf_mem_read_req;
//  assign choosed_ibuf__buf_read_data = choose_mux_in? ibuf_mem_read_data : LiDAR_ibuf_mem_read_data;
 assign ibuf_mem_read_data = choosed_ibuf__buf_read_data;
 assign LiDAR_ibuf_mem_read_data = choosed_ibuf__buf_read_data;

assign  choosed_bbuf_tag_mem_write_addr = choose_mux_in? bbuf_mem_write_addr : LiDAR_bbuf_mem_write_addr;
assign  choosed_bbuf_mem_write_req = choose_mux_in? bbuf_mem_write_req : LiDAR_bbuf_mem_write_req;
assign  choosed_bbuf_mem_write_data = choose_mux_in? bbuf_mem_write_data : LiDAR_bbuf_mem_write_data;
assign  choosed_bbuf_tag_buf_read_addr = choose_mux_in? bbuf_mem_read_addr : LiDAR_bbuf_mem_read_addr;
assign  choosed_bbuf_buf_read_req = choose_mux_in? bbuf_mem_read_req : LiDAR_bbuf_mem_read_req;
assign  bbuf_mem_read_data = choosed_bbuf__buf_read_data;
assign LiDAR_bbuf_mem_read_data = choosed_bbuf__buf_read_data;

assign choosed_wbuf_tag_mem_write_addr = choose_mux_in? wbuf_mem_write_addr : LiDAR_wbuf_mem_write_addr;
assign choosed_wbuf_mem_write_req_dly = choose_mux_in? wbuf_mem_write_req : LiDAR_wbuf_mem_write_req;
assign choosed_wbuf__mem_write_data = choose_mux_in? wbuf_mem_write_data : LiDAR_wbuf_mem_write_data;
assign choosed_wbuf_tag_buf_read_addr = choose_mux_in? wbuf_mem_read_addr : LiDAR_wbuf_mem_read_addr;
assign choosed_wbuf_buf_read_req = choose_mux_in? wbuf_mem_read_req : LiDAR_wbuf_mem_read_req;
// assign choosed_wbuf__buf_read_data = choose_mux_in? wbuf_mem_read_data : LiDAR_wbuf_mem_read_data;
assign wbuf_mem_read_data = choosed_wbuf__buf_read_data;
assign LiDAR_wbuf_mem_read_data = choosed_wbuf__buf_read_data;

assign choosed_obuf_tag_mem_write_addr = choose_mux_in? obuf_mem_write_addr : LiDAR_obuf_mem_write_addr;
assign choosed_obuf_mem_write_req = choose_mux_in? obuf_mem_write_req : LiDAR_obuf_mem_write_req;
assign choosed_obuf_mem_write_data = choose_mux_in? obuf_mem_write_data : LiDAR_obuf_mem_write_data;
assign choosed_obuf_tag_mem_read_addr = choose_mux_in? obuf_mem_read_addr : LiDAR_obuf_mem_read_addr;
assign choosed_obuf_mem_read_req = choose_mux_in? obuf_mem_read_req : LiDAR_obuf_mem_read_req;
// assign choosed_obuf_mem_read_data = choose_mux_in? obuf_mem_read_data : LiDAR_obuf_mem_read_data;
assign obuf_mem_read_data = choosed_obuf_mem_read_data;
assign LiDAR_obuf_mem_read_data = choosed_obuf_mem_read_data;
// assign choosed_obuf_pu_read_data = choose_mux_in? obuf_pu_read_data : LiDAR_obuf_pu_read_data;
assign obuf_pu_read_data = choosed_obuf_pu_read_data;
assign LiDAR_obuf_pu_read_data = choosed_obuf_pu_read_data;
assign choosed_obuf_tag_buf_write_addr = choose_mux_in? obuf_pu_write_addr : LiDAR_obuf_pu_write_addr;
assign choosed_obuf_buf_write_req = choose_mux_in? obuf_pu_write_req : LiDAR_obuf_pu_write_req;
assign choosed_obuf_buf_write_data = choose_mux_in? obuf_pu_write_data : LiDAR_obuf_pu_write_data;
assign choosed_obuf_tag_buf_read_addr = choose_mux_in? obuf_pu_read_addr : LiDAR_obuf_pu_read_addr;
assign choosed_obuf_buf_read_req = choose_mux_in? obuf_pu_read_req : LiDAR_obuf_pu_read_req;
// assign choosed_obuf__buf_read_data = choose_mux_in? obuf_pu_read_data : LiDAR_obuf_pu_read_data; 
// assign obuf_pu_read_data = choosed_obuf__buf_read_data;
assign _obuf_mem_read_data = choosed_obuf__buf_read_data;
assign LiDAR_obuf_pu_read_data = choosed_obuf__buf_read_data;


// always @(posedge clk) begin
//   if(choose_mux_in) begin  
//     // choose for 8bit/16bit ibuf
//     reg_choosed_ibuf_tag_mem_write_addr = ibuf_mem_write_addr;
//     reg_choosed_ibuf_mem_write_req_in = ibuf_mem_write_req;
//     reg_choosed_ibuf_mem_write_data_in = ibuf_mem_write_data;
//     reg_choosed_ibuf_tag_buf_read_addr = ibuf_mem_read_addr;
//     reg_choosed_ibuf_buf_read_req = ibuf_mem_read_req;
//     reg_choosed_ibuf__buf_read_data = ibuf_mem_read_data;

//       // choose for 8bit/16bit bbuf
//     reg_choosed_bbuf_tag_mem_write_addr = bbuf_mem_write_addr;
//     reg_choosed_bbuf_mem_write_req = bbuf_mem_write_req;
//     reg_choosed_bbuf_mem_write_data = bbuf_mem_write_data;
//     reg_choosed_bbuf_tag_buf_read_addr = bbuf_mem_read_req;
//     reg_choosed_bbuf_buf_read_req = bbuf_mem_read_req;
//     reg_choosed_bbuf__buf_read_data = bbuf_mem_read_data;

//      // choose for 8bit/16bit wbuf
//     reg_choosed_wbuf_tag_mem_write_addr = wbuf_mem_write_addr;
//     reg_choosed_wbuf_mem_write_req_dly = wbuf_mem_write_req;
//     reg_choosed_wbuf__mem_write_data = wbuf_mem_write_data;
//     reg_choosed_wbuf_tag_buf_read_addr = wbuf_mem_read_addr;
//     reg_choosed_wbuf_buf_read_req = wbuf_mem_read_req;
//     reg_choosed_wbuf__buf_read_data = wbuf_mem_read_data;

//      // choose for 8bit/16bit obuf
//     reg_choosed_obuf_tag_mem_write_addr = obuf_mem_write_addr;
//     reg_choosed_obuf_mem_write_req = obuf_mem_write_req;
//     reg_choosed_obuf_mem_write_data = obuf_mem_write_data;
//     reg_choosed_obuf_tag_mem_read_addr = obuf_mem_read_addr;
//     reg_choosed_obuf_mem_read_req = obuf_mem_read_req;
//     reg_choosed_obuf_mem_read_data = obuf_mem_read_data;
//     reg_choosed_obuf_pu_read_data = obuf_pu_read_data;
//     reg_choosed_obuf_tag_buf_write_addr= obuf_pu_write_addr;
//     reg_choosed_obuf_buf_write_req = obuf_pu_write_req;
//     reg_choosed_obuf_buf_write_data = obuf_pu_write_data;
//     reg_choosed_obuf_tag_buf_read_addr = obuf_pu_read_addr;
//     reg_choosed_obuf_buf_read_req = obuf_pu_read_req;
//     reg_choosed_obuf__buf_read_data = obuf_pu_read_data;
//   end else begin
//     // choose for 8bit/16bit ibuf
//     reg_choosed_ibuf_tag_mem_write_addr = LiDAR_ibuf_tag_mem_write_addr;
//     reg_choosed_ibuf_mem_write_req_in = LiDAR_ibuf_mem_write_req_in;
//     reg_choosed_ibuf_mem_write_data_in = LiDAR_ibuf_mem_write_data_in;
//     reg_choosed_ibuf_tag_buf_read_addr = LiDAR_ibuf_tag_buf_read_addr;
//     reg_choosed_ibuf_buf_read_req = LiDAR_ibuf_buf_read_req;
//     reg_choosed_ibuf__buf_read_data = LiDAR_ibuf__buf_read_data;
//     // choose for 8bit/16bit bbuf
//     reg_choosed_bbuf_tag_mem_write_addr = LiDAR_bbuf_tag_mem_write_addr;
//     reg_choosed_bbuf_mem_write_req = LiDAR_bbuf_mem_write_req;
//     reg_choosed_bbuf_mem_write_data = LiDAR_bbuf_mem_write_data;
//     reg_choosed_bbuf_tag_buf_read_addr = LiDAR_bbuf_tag_buf_read_addr;
//     reg_choosed_bbuf_buf_read_req = LiDAR_bbuf_buf_read_req;
//     reg_choosed_bbuf__buf_read_data = LiDAR_bbuf__buf_read_data;
  
//      // choose for 8bit/16bit wbuf
//     reg_choosed_wbuf_tag_mem_write_addr = LiDAR_wbuf_tag_mem_write_addr;
//     reg_choosed_wbuf_mem_write_req_dly = LiDAR_wbuf_mem_write_req_dly;
//     reg_choosed_wbuf__mem_write_data = LiDAR_wbuf__mem_write_data;
//     reg_choosed_wbuf_tag_buf_read_addr = LiDAR_wbuf_tag_buf_read_addr;
//     reg_choosed_wbuf_buf_read_req = LiDAR_wbuf_buf_read_req;
//     reg_choosed_wbuf__buf_read_data = LiDAR_wbuf__buf_read_data;
  
//      // choose for 8bit/16bit obuf
//     reg_choosed_obuf_tag_mem_write_addr = LiDAR_obuf_tag_mem_write_addr;
//     reg_choosed_obuf_mem_write_req = LiDAR_obuf_mem_write_req;
//     reg_choosed_obuf_mem_write_data = LiDAR_obuf_mem_write_data;
//     reg_choosed_obuf_tag_mem_read_addr = LiDAR_obuf_tag_mem_read_addr;
//     reg_choosed_obuf_mem_read_req = LiDAR_obuf_mem_read_req;
//     reg_choosed_obuf_mem_read_data = LiDAR_obuf_mem_read_data;
//     reg_choosed_obuf_pu_read_data = LiDAR_obuf_pu_read_data;
//     reg_choosed_obuf_tag_buf_write_addr = LiDAR_obuf_tag_buf_write_addr;
//     reg_choosed_obuf_buf_write_req = LiDAR_obuf_buf_write_req;
//     reg_choosed_obuf_buf_write_data = LiDAR_obuf_buf_write_data;
//     reg_choosed_obuf_tag_buf_read_addr = LiDAR_obuf_tag_buf_read_addr;
//     reg_choosed_obuf_buf_read_req = LiDAR_obuf_buf_read_req;
//     reg_choosed_obuf__buf_read_data = LiDAR_obuf__buf_read_data;
//   end
// end

ibuf #( 
    .TAG_W                          ( TAG_W                          ),
    .BUF_ADDR_WIDTH                 ( TAG_BUF_ADDR_W_IBUF                 ),
    .ARRAY_N                        ( ARRAY_N                        ),
    .MEM_DATA_WIDTH                 ( AXI_DATA_WIDTH                 ),
    .DATA_WIDTH                     ( DATA_WIDTH                    )
    ) ibuf_ram (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .mem_write_addr                 ( choosed_ibuf_tag_mem_write_addr             ),
    .mem_write_req                  ( choosed_ibuf_mem_write_req_in                  ),
    .mem_write_data                 ( choosed_ibuf_mem_write_data_in                ),//edit by pxq 0816
    .buf_read_addr                  ( choosed_ibuf_tag_buf_read_addr              ),
    .buf_read_req                   ( choosed_ibuf_buf_read_req                   ),
    .buf_read_data                  ( choosed_ibuf__buf_read_data                 )
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
    .mem_write_addr                 ( choosed_bbuf_tag_mem_write_addr             ),
    .mem_write_req                  ( choosed_bbuf_mem_write_req                  ),
    .mem_write_data                 ( choosed_bbuf_mem_write_data            ),
    .buf_read_addr                  ( choosed_bbuf_tag_buf_read_addr              ),
    .buf_read_req                   ( choosed_bbuf_buf_read_req                   ),
    .buf_read_data                  ( choosed_bbuf__buf_read_data                 )
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
    .mem_write_addr                 ( choosed_wbuf_tag_mem_write_addr             ),
    .mem_write_req                  ( choosed_wbuf_mem_write_req_dly              ),//edit by sy 0820
    .mem_write_data                 ( choosed_wbuf__mem_write_data                ),//edit by sy 0820
    .buf_read_addr                  ( choosed_wbuf_tag_buf_read_addr              ),
    .buf_read_req                   ( choosed_wbuf_buf_read_req                   ),
    .buf_read_data                  ( choosed_wbuf__buf_read_data                 )
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
    .mem_read_req                   ( choosed_obuf_mem_read_req                   ),
    .mem_read_addr                  ( choosed_obuf_tag_mem_read_addr             ),
    .mem_read_data                  ( choosed_obuf_mem_read_data                  ),
    .mem_write_req                  ( choosed_obuf_mem_write_req                  ),
    .mem_write_addr                 ( choosed_obuf_tag_mem_write_addr             ),
    .mem_write_data                 ( choosed_obuf_mem_write_data                 ),
    .pu_read_data                   ( choosed_obuf_pu_read_data                   ), //edit yt
    .obuf_fifo_write_req_limit      ( obuf_fifo_write_req_limit      ), //edit yt
    .buf_write_addr                 ( choosed_obuf_tag_buf_write_addr             ),//edit by pxq
    .buf_write_req                  ( choosed_obuf_buf_write_req                  ),//edit by pxq
    .buf_write_data                 ( choosed_obuf_buf_write_data                 ),//edit by pxq
    .buf_read_addr                  ( choosed_obuf_tag_buf_read_addr              ),
    .buf_read_req                   ( choosed_obuf_buf_read_req                   ),
    .buf_read_data                  ( choosed_obuf__buf_read_data                 )
  );
endmodule