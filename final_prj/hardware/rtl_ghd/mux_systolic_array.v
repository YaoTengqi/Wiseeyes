//
// DnnWeaver v2 controller - Custom Logic (CL) Wrapper
//
// Hardik Sharma
// (hsharma@gatech.edu)

`timescale 1ns/1ps
module mux_sysytolic_array #(
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
  // ghd_add_begin
    parameter integer  LOOP_ITER_W                  = 16,

    parameter integer  WBUF_DATA_WIDTH              = ARRAY_M *WEIGHT_ROW_NUM * DATA_WIDTH,
    parameter integer  BBUF_DATA_WIDTH              = ARRAY_M * BIAS_WIDTH,
    parameter integer  IBUF_DATA_WIDTH              = ARRAY_N * DATA_WIDTH,
    parameter integer  OBUF_DATA_WIDTH              = ARRAY_M * ACC_WIDTH
  // ghd_add_end
) (
    input  wire                                         clk,
    input  wire                                         reset,

    input  wire                                         choose_8bit_in,

    ////pd

    input  wire                                         acc_clear_pd,
    input  wire  [ IBUF_DATA_WIDTH      -1 : 0 ]        ibuf_read_data_pd,
    input  wire  [ WBUF_DATA_WIDTH      -1 : 0 ]        wbuf_read_data_pd,
    input  wire  [ WBUF_ADDR_WIDTH      -1 : 0 ]        wbuf_read_addr_pd,

    output wire                                         sys_wbuf_read_req_pd, 
    output wire  [ WBUF_ADDR_WIDTH      -1 : 0 ]        sys_wbuf_read_addr_pd,       
    input  wire                                         compute_req_pd,
    input  wire                                         loop_exit_pd,             
    input  wire                                         sys_inner_loop_start_pd,

    input  wire  [ BBUF_DATA_WIDTH      -1 : 0 ]        bbuf_read_data_pd,
    input  wire                                         bias_read_req_pd,
    input  wire  [ BBUF_ADDR_WIDTH      -1 : 0 ]        bias_read_addr_pd,
    output wire                                         sys_bias_read_req_pd,
    output wire  [ BBUF_ADDR_WIDTH      -1 : 0 ]        sys_bias_read_addr_pd,
    input  wire                                         sys_array_c_sel_pd,

    input  wire                                         obuf_write_req_pd,
    input  wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        obuf_write_addr_pd,
    input  wire  [ OBUF_DATA_WIDTH      -1 : 0 ]        obuf_read_data_pd,
    input  wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        obuf_read_addr_pd,
    output wire                                         sys_obuf_read_req_pd,
    output wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        sys_obuf_read_addr_pd,

    output wire  [ OBUF_DATA_WIDTH      -1 : 0 ]        sys_obuf_write_data_pd,
    output wire                                         sys_obuf_write_req_pd,
    output wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        sys_obuf_write_addr_pd,

    ////lidar

    input  wire                                         acc_clear_lidar,
    input  wire  [ IBUF_DATA_WIDTH      -1 : 0 ]        ibuf_read_data_lidar,
    input  wire  [ WBUF_DATA_WIDTH      -1 : 0 ]        wbuf_read_data_lidar,
    input  wire  [ WBUF_ADDR_WIDTH      -1 : 0 ]        wbuf_read_addr_lidar,

    output wire                                         sys_wbuf_read_req_lidar, 
    output wire  [ WBUF_ADDR_WIDTH      -1 : 0 ]        sys_wbuf_read_addr_lidar,       
    input  wire                                         compute_req_lidar,
    input  wire                                         loop_exit_lidar,             
    input  wire                                         sys_inner_loop_start_lidar,

    input  wire  [ BBUF_DATA_WIDTH      -1 : 0 ]        bbuf_read_data_lidar,
    input  wire                                         bias_read_req_lidar,
    input  wire  [ BBUF_ADDR_WIDTH      -1 : 0 ]        bias_read_addr_lidar,
    output wire                                         sys_bias_read_req_lidar,
    output wire  [ BBUF_ADDR_WIDTH      -1 : 0 ]        sys_bias_read_addr_lidar,
    input  wire                                         sys_array_c_sel_lidar,

    input  wire                                         obuf_write_req_lidar,
    input  wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        obuf_write_addr_lidar,
    input  wire  [ OBUF_DATA_WIDTH      -1 : 0 ]        obuf_read_data_lidar,
    input  wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        obuf_read_addr_lidar,
    output wire                                         sys_obuf_read_req_lidar,
    output wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        sys_obuf_read_addr_lidar,

    output wire  [ OBUF_DATA_WIDTH      -1 : 0 ]        sys_obuf_write_data_lidar,
    output wire                                         sys_obuf_write_req_lidar,
    output wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        sys_obuf_write_addr_lidar

    ////choise

    // output wire                                         acc_clear,
    // output wire  [ IBUF_DATA_WIDTH      -1 : 0 ]        ibuf_read_data,
    // output wire  [ WBUF_DATA_WIDTH      -1 : 0 ]        wbuf_read_data,
    // output wire  [ WBUF_ADDR_WIDTH      -1 : 0 ]        wbuf_read_addr,

    // input  wire                                         sys_wbuf_read_req, 
    // input  wire  [ WBUF_ADDR_WIDTH      -1 : 0 ]        sys_wbuf_read_addr,       
    // output wire                                         compute_req,
    // output wire                                         loop_exit,             
    // output wire                                         sys_inner_loop_start,

    // output wire                                         choose_8bit,

    // output wire  [ BBUF_DATA_WIDTH      -1 : 0 ]        bbuf_read_data,
    // output wire                                         bias_read_req,
    // output wire  [ BBUF_ADDR_WIDTH      -1 : 0 ]        bias_read_addr,
    // input  wire                                         sys_bias_read_req,
    // input  wire  [ BBUF_ADDR_WIDTH      -1 : 0 ]        sys_bias_read_addr,
    // output wire                                         sys_array_c_sel,

    // output wire                                         obuf_write_req,
    // output wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        obuf_write_addr,
    // output wire  [ OBUF_DATA_WIDTH      -1 : 0 ]        obuf_read_data,
    // output wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        obuf_read_addr,
    // input  wire                                         sys_obuf_read_req,
    // input  wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        sys_obuf_read_addr,

    // input  wire  [ OBUF_DATA_WIDTH      -1 : 0 ]        sys_obuf_write_data,
    // input  wire                                         sys_obuf_write_req,
    // input  wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        sys_obuf_write_addr

);

wire                                         acc_clear;
wire  [ IBUF_DATA_WIDTH      -1 : 0 ]        ibuf_read_data;
wire  [ WBUF_DATA_WIDTH      -1 : 0 ]        wbuf_read_data;
wire  [ WBUF_ADDR_WIDTH      -1 : 0 ]        wbuf_read_addr;

wire                                         sys_wbuf_read_req; 
wire  [ WBUF_ADDR_WIDTH      -1 : 0 ]        sys_wbuf_read_addr;       
wire                                         compute_req;
wire                                         loop_exit;             
wire                                         sys_inner_loop_start;

wire                                         choose_8bit;

wire  [ BBUF_DATA_WIDTH      -1 : 0 ]        bbuf_read_data;
wire                                         bias_read_req;
wire  [ BBUF_ADDR_WIDTH      -1 : 0 ]        bias_read_addr;
wire                                         sys_bias_read_req;
wire  [ BBUF_ADDR_WIDTH      -1 : 0 ]        sys_bias_read_addr;
wire                                         sys_array_c_sel;

wire                                         obuf_write_req;
wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        obuf_write_addr;
wire  [ OBUF_DATA_WIDTH      -1 : 0 ]        obuf_read_data;
wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        obuf_read_addr;
wire                                         sys_obuf_read_req;
wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        sys_obuf_read_addr;

wire  [ OBUF_DATA_WIDTH      -1 : 0 ]        sys_obuf_write_data;
wire                                         sys_obuf_write_req;
wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        sys_obuf_write_addr;


// assign acc_clear               = (choose_8bit_in == 1'b0) ? acc_clear_lidar : acc_clear_pd;
// assign ibuf_read_data          = (choose_8bit_in == 1'b0) ? ibuf_read_data_lidar : ibuf_read_data_pd;
// assign wbuf_read_data          = (choose_8bit_in == 1'b0) ? wbuf_read_data_lidar : wbuf_read_data_pd;
// assign wbuf_read_addr          = (choose_8bit_in == 1'b0) ? wbuf_read_addr_lidar : wbuf_read_addr_pd;
// assign compute_req             = (choose_8bit_in == 1'b0) ? compute_req_lidar : compute_req_pd;
// assign loop_exit               = (choose_8bit_in == 1'b0) ? loop_exit_lidar : loop_exit_pd;
// assign sys_inner_loop_start    = (choose_8bit_in == 1'b0) ? sys_inner_loop_start_lidar : sys_inner_loop_start_pd;
// assign bbuf_read_data          = (choose_8bit_in == 1'b0) ? bbuf_read_data_lidar : bbuf_read_data_pd;
// assign bias_read_req           = (choose_8bit_in == 1'b0) ? bias_read_req_lidar : bias_read_req_pd;
// assign bias_read_addr          = (choose_8bit_in == 1'b0) ? bias_read_addr_lidar : bias_read_addr_pd;
// assign sys_array_c_sel         = (choose_8bit_in == 1'b0) ? sys_array_c_sel_lidar : sys_array_c_sel_pd;
// assign obuf_write_req          = (choose_8bit_in == 1'b0) ? obuf_write_req_lidar : obuf_write_req_pd;
// assign obuf_write_addr         = (choose_8bit_in == 1'b0) ? obuf_write_addr_lidar : obuf_write_addr_pd;
// assign obuf_read_data          = (choose_8bit_in == 1'b0) ? obuf_read_data_lidar : obuf_read_data_pd;
// assign obuf_read_addr          = (choose_8bit_in == 1'b0) ? obuf_read_addr_lidar : obuf_read_addr_pd;
// assign choose_8bit             = choose_8bit_in;

// assign sys_wbuf_read_req_pd    = (choose_8bit_in == 1'b1) ? sys_wbuf_read_req : 1'b0;
// assign sys_wbuf_read_req_lidar = (choose_8bit_in == 1'b0) ? sys_wbuf_read_req : 1'b0;

// assign sys_wbuf_read_addr_pd   = (choose_8bit_in == 1'b1) ? sys_wbuf_read_addr : {WBUF_ADDR_WIDTH{1'b0}};
// assign sys_wbuf_read_addr_lidar= (choose_8bit_in == 1'b0) ? sys_wbuf_read_addr : {WBUF_ADDR_WIDTH{1'b0}};

// assign sys_bias_read_req_pd    = (choose_8bit_in == 1'b1) ? sys_bias_read_req : 1'b0;
// assign sys_bias_read_req_lidar = (choose_8bit_in == 1'b0) ? sys_bias_read_req : 1'b0;

// assign sys_bias_read_addr_pd   = (choose_8bit_in == 1'b1) ? sys_bias_read_addr : {BBUF_ADDR_WIDTH{1'b0}};
// assign sys_bias_read_addr_lidar= (choose_8bit_in == 1'b0) ? sys_bias_read_addr : {BBUF_ADDR_WIDTH{1'b0}};

// assign sys_obuf_read_req_pd    = (choose_8bit_in == 1'b1) ? sys_obuf_read_req : 1'b0;
// assign sys_obuf_read_req_lidar = (choose_8bit_in == 1'b0) ? sys_obuf_read_req : 1'b0;

// assign sys_obuf_read_addr_pd   = (choose_8bit_in == 1'b1) ? sys_obuf_read_addr : {OBUF_ADDR_WIDTH{1'b0}};
// assign sys_obuf_read_addr_lidar= (choose_8bit_in == 1'b0) ? sys_obuf_read_addr : {OBUF_ADDR_WIDTH{1'b0}};

// assign sys_obuf_write_data_pd  = (choose_8bit_in == 1'b1) ? sys_obuf_write_data : {OBUF_DATA_WIDTH{1'b0}};
// assign sys_obuf_write_data_lidar= (choose_8bit_in == 1'b0) ? sys_obuf_write_data : {OBUF_DATA_WIDTH{1'b0}};

// assign sys_obuf_write_req_pd   = (choose_8bit_in == 1'b1) ? sys_obuf_write_req : 1'b0;
// assign sys_obuf_write_req_lidar= (choose_8bit_in == 1'b0) ? sys_obuf_write_req : 1'b0;

// assign sys_obuf_write_addr_pd  = (choose_8bit_in == 1'b1) ? sys_obuf_write_addr : {OBUF_ADDR_WIDTH{1'b0}};
// assign sys_obuf_write_addr_lidar= (choose_8bit_in == 1'b0) ? sys_obuf_write_addr : {OBUF_ADDR_WIDTH{1'b0}};

//ghd_test_begin
assign acc_clear               = acc_clear_pd;
assign ibuf_read_data          = ibuf_read_data_pd;
assign wbuf_read_data          = wbuf_read_data_pd;
assign wbuf_read_addr          = wbuf_read_addr_pd;
assign compute_req             = compute_req_pd;
assign loop_exit               = loop_exit_pd;
assign sys_inner_loop_start    = sys_inner_loop_start_pd;
assign bbuf_read_data          = bbuf_read_data_pd;
assign bias_read_req           = bias_read_req_pd;
assign bias_read_addr          = bias_read_addr_pd;
assign sys_array_c_sel         = sys_array_c_sel_pd;
assign obuf_write_req          = obuf_write_req_pd;
assign obuf_write_addr         = obuf_write_addr_pd;
assign obuf_read_data          = obuf_read_data_pd;
assign obuf_read_addr          = obuf_read_addr_pd;
assign choose_8bit             = choose_8bit_in;

assign sys_wbuf_read_req_pd    = sys_wbuf_read_req;
assign sys_wbuf_read_req_lidar = sys_wbuf_read_req;

assign sys_wbuf_read_addr_pd   = sys_wbuf_read_addr;
assign sys_wbuf_read_addr_lidar= sys_wbuf_read_addr;

assign sys_bias_read_req_pd    = sys_bias_read_req;
assign sys_bias_read_req_lidar = sys_bias_read_req;

assign sys_bias_read_addr_pd   = sys_bias_read_addr;
assign sys_bias_read_addr_lidar= sys_bias_read_addr;

assign sys_obuf_read_req_pd    = sys_obuf_read_req;
assign sys_obuf_read_req_lidar = sys_obuf_read_req;

assign sys_obuf_read_addr_pd   = sys_obuf_read_addr;
assign sys_obuf_read_addr_lidar= sys_obuf_read_addr;

assign sys_obuf_write_data_pd  = sys_obuf_write_data;
assign sys_obuf_write_data_lidar= sys_obuf_write_data;

assign sys_obuf_write_req_pd   = sys_obuf_write_req;
assign sys_obuf_write_req_lidar= sys_obuf_write_req;

assign sys_obuf_write_addr_pd  = sys_obuf_write_addr;
assign sys_obuf_write_addr_lidar= sys_obuf_write_addr;
//ghd_test_end

  systolic_array #(
    .OBUF_ADDR_WIDTH                ( OBUF_ADDR_WIDTH                ),
    .BBUF_ADDR_WIDTH                ( BBUF_ADDR_WIDTH                ),
    .ACT_WIDTH                      ( DATA_WIDTH                     ),
    .WGT_WIDTH                      ( DATA_WIDTH                     ),
    .BIAS_WIDTH                     ( BIAS_WIDTH                     ),
    .ACC_WIDTH                      ( ACC_WIDTH                      ),
    .ARRAY_N                        ( ARRAY_N                        ),
    .ARRAY_M                        ( ARRAY_M                        ),
    .WBUF_ADDR_WIDTH                ( WBUF_ADDR_WIDTH                ),
    .LOOP_ITER_W                    ( LOOP_ITER_W                    )  
  ) sys_array (
    .clk                            ( clk                            ),//input
    .reset                          ( reset                          ),//input
    .acc_clear                      ( acc_clear                      ),//input

    .ibuf_read_data                 ( ibuf_read_data                 ),//input

    .wbuf_read_data                 ( wbuf_read_data                 ),//input
    .wbuf_read_addr                 ( wbuf_read_addr                 ),//input                                                                                               //edit by sy 0518
    .sys_wbuf_read_req              ( sys_wbuf_read_req              ),//output                                                                                                 //edit by sy 0518
    .sys_wbuf_read_addr             ( sys_wbuf_read_addr             ),//output                                                                                                 //edit by sy 0518
    .start                          ( compute_req                    ),//input                                                                                                                                   //edit by sy 0518
    .loop_exit                      ( loop_exit                      ),//input                                                                                                                                   //edit by sy 0518
    .sys_inner_loop_start           ( sys_inner_loop_start           ),//input 

    .choose_8bit                    ( choose_8bit_in                 ),//input   

    .bbuf_read_data                 ( bbuf_read_data                 ),//input  
    .bias_read_req                  ( bias_read_req                  ),//input  
    .bias_read_addr                 ( bias_read_addr                 ),//input  
    .sys_bias_read_req              ( sys_bias_read_req              ),//output 
    .sys_bias_read_addr             ( sys_bias_read_addr             ),//output 
    .bias_prev_sw                   ( sys_array_c_sel                ),//input 

    .obuf_read_data                 ( obuf_read_data                 ),//input
    .obuf_read_addr                 ( obuf_read_addr                 ),//input
    .sys_obuf_read_req              ( sys_obuf_read_req              ),//output 
    .sys_obuf_read_addr             ( sys_obuf_read_addr             ),//output 
    .obuf_write_req                 ( obuf_write_req                 ),//input
    .obuf_write_addr                ( obuf_write_addr                ),//input
    .obuf_write_data                ( sys_obuf_write_data            ),//input
    .sys_obuf_write_req             ( sys_obuf_write_req             ),//output
    .sys_obuf_write_addr            ( sys_obuf_write_addr            ) //output
  );


endmodule
