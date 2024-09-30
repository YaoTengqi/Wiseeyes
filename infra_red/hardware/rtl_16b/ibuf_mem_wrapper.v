//
// Wrapper for memory
//
// Hardik Sharma
// (hsharma@gatech.edu)

`timescale 1ns/1ps
module ibuf_mem_wrapper #(
  // Internal Parameters
    parameter integer  MEM_ID                       = 0,
    parameter integer  MEM_REQ_W                    = 16,
    parameter integer  ADDR_WIDTH                   = 8,
    parameter integer  DATA_WIDTH                   = 32,
    parameter integer  LOOP_ITER_W                  = 16,
    parameter integer  ADDR_STRIDE_W                = 32,
    parameter integer  LOOP_ID_W                    = 5,
    parameter integer  BUF_TYPE_W                   = 2,
    parameter integer  NUM_TAGS                     = 4,
    parameter integer  TAG_W                        = $clog2(NUM_TAGS),

  // AXI
    parameter integer  AXI_ADDR_WIDTH               = 42,
    parameter integer  AXI_ID_WIDTH                 = 1,
    parameter integer  AXI_DATA_WIDTH               = 256,
    parameter integer  AXI_BURST_WIDTH              = 8,
    parameter integer  WSTRB_W                      = AXI_DATA_WIDTH/8,

  // Buffer
    parameter integer  ARRAY_N                      = 2,
    parameter integer  ARRAY_M                      = MEM_ID == 2 ? ARRAY_N : 1,
    parameter integer  BUF_DATA_WIDTH               = DATA_WIDTH * ARRAY_N * ARRAY_M,
    parameter integer  BUF_ADDR_W                   = 16,
    parameter integer  MEM_ADDR_W                   = BUF_ADDR_W + $clog2(BUF_DATA_WIDTH / AXI_DATA_WIDTH),
    parameter integer  TAG_BUF_ADDR_W               = BUF_ADDR_W + TAG_W,
    parameter integer  TAG_MEM_ADDR_W               = MEM_ADDR_W + TAG_W,
    //add for asr data write
    parameter integer  IBUF_ADDR_WIDTH              = MEM_ADDR_W,  //edit by pxq 20210813
    parameter integer  IBUF_DATA_WIDTH            = 256,
    //add for video dma s2mm 2021-07-22
    parameter          TX_SIZE_WIDTH                = 8,
    //=================================================================================== first layer parameter modify ecit by pxq 0830(FIRST LAYER)
    parameter integer   TILE_ROW_COUNT  = 17 ,//GIVE BY OP
    parameter integer   TILE_LINE_COUNT  = 7 ,// GIVE BY PARAM
    parameter integer   INPUT_CHANNEL = 3,// -->GIVE BY PARAM
    parameter integer     INPUT_WIDTH = 16 ,//-->GIVE BY PARAM
    parameter integer   LINE_DATA_WIDTH =  TILE_ROW_COUNT* INPUT_WIDTH *INPUT_CHANNEL ,//GIVE BY OP
    parameter integer  TILE_LINE_EXTEND_COUNT = 2
) (
    input  wire                                         clk,
    input  wire                                         reset,

    input  wire                                         tag_req,
    input  wire                                         tag_reuse,
    input  wire                                         tag_bias_prev_sw,
    input  wire                                         tag_ddr_pe_sw,
    output wire                                         tag_ready,
    output wire                                         tag_done,
    input  wire                                         compute_done,
    input  wire                                         block_done,
    //input  wire  [ ADDR_WIDTH           -1 : 0 ]        tag_base_ld_addr,

    (* MARK_DEBUG="true" *)output wire                                         compute_ready,
    output wire                                         compute_bias_prev_sw,

  // Programming
    input  wire                                         cfg_loop_stride_v,
    input  wire  [ ADDR_STRIDE_W        -1 : 0 ]        cfg_loop_stride,
    input  wire  [ LOOP_ID_W            -1 : 0 ]        cfg_loop_stride_loop_id,
    input  wire  [ BUF_TYPE_W           -1 : 0 ]        cfg_loop_stride_id,
    input  wire  [ 2                    -1 : 0 ]        cfg_loop_stride_type,

    input  wire                                         cfg_loop_iter_v,
    input  wire  [ LOOP_ITER_W          -1 : 0 ]        cfg_loop_iter,
    input  wire  [ LOOP_ID_W            -1 : 0 ]        cfg_loop_iter_loop_id,

    input  wire                                         cfg_mem_req_v,
    input  wire  [ BUF_TYPE_W           -1 : 0 ]        cfg_mem_req_id,
    input  wire  [ MEM_REQ_W            -1 : 0 ]        cfg_mem_req_size,
    input  wire  [ LOOP_ID_W            -1 : 0 ]        cfg_mem_req_loop_id,
    input  wire  [ 2                    -1 : 0 ]        cfg_mem_req_type,

  // Systolic Array
    output wire  [ BUF_DATA_WIDTH       -1 : 0 ]        buf_read_data,
    // input  wire                                         buf_read_req,
    input  wire  [ BUF_ADDR_W           -1 : 0 ]        buf_read_addr,
    // asr data write if*****************************************************
    //add for asr data write 2021-08-13
    input[ IBUF_DATA_WIDTH-1  : 0 ]                     i_data_adnn, //add for asr data write 2021-08-13 data
    input[ IBUF_ADDR_WIDTH-1  : 0 ]                     i_add_adnn,  //add for asr data write 2021-08-13 add
    input                                               i_valid_adnn,//add for asr data write 2021-08-13 req
    
    //input                                               i_is_run_adnn,//add for asr data write 2021-08-13 status
    input                                               i_frame_adnn,//add for asr data write 2021-08-13  start
    input                                               i_frame_data_ready_adnn,//add for asr data write 2021-08-13 finish
    //*******************************************************************************************
  // CL_wrapper -> DDR AXI4 interface
    // Master Interface Write Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        mws_awaddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        mws_awlen,
    output wire  [ 3                    -1 : 0 ]        mws_awsize,
    output wire  [ 2                    -1 : 0 ]        mws_awburst,
    output wire                                         mws_awvalid,
    input  wire                                         mws_awready,
    // Master Interface Write Data
    output wire  [ AXI_DATA_WIDTH       -1 : 0 ]        mws_wdata,
    output wire  [ WSTRB_W              -1 : 0 ]        mws_wstrb,
    output wire                                         mws_wlast,
    output wire                                         mws_wvalid,
    input  wire                                         mws_wready,
    // Master Interface Write Response
    input  wire  [ 2                    -1 : 0 ]        mws_bresp,
    input  wire                                         mws_bvalid,
    output wire                                         mws_bready,
    // Master Interface Read Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        mws_araddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        mws_arlen,
    output wire  [ 3                    -1 : 0 ]        mws_arsize,
    output wire  [ 2                    -1 : 0 ]        mws_arburst,
    output wire                                         mws_arvalid,
    output wire  [ AXI_ID_WIDTH         -1 : 0 ]        mws_arid,
    input  wire                                         mws_arready,
    // Master Interface Read Data
    input  wire  [ AXI_DATA_WIDTH       -1 : 0 ]        mws_rdata,
    input  wire  [ 2                    -1 : 0 ]        mws_rresp,
    input  wire                                         mws_rlast,
    input  wire                                         mws_rvalid,
    input  wire  [ AXI_ID_WIDTH         -1 : 0 ]        mws_rid,
    output wire                                         mws_rready,
        //add for video dma s2mm 2021-07-22
    input  [ TX_SIZE_WIDTH        -1 : 0 ]                 i_s2mem_size,
    input  [AXI_ADDR_WIDTH-1:0]                            i_s2mem_addr,
    output                                                 o_s2mem_addr_req,
    output                                                 o_s2mem_addr_done,
    input                                                  i_s2mem_addr_ready,
    
    
    input  [AXI_DATA_WIDTH-1:0]                            i_s2mem_data,
    output                                                 o_s2mem_data_req,
    input                                                  i_s2mem_data_ready,
    //============================================================= IO modify edit by pxq0813
    input wire                                             i_decoder_done,  
    //================================================================
    //======================================================================== IBUF IO MODIFY EDIT BY PXQ 0812
    input wire                                          choose_8bit,  // 0--16bit   1-- 8bit
    input wire [ADDR_WIDTH              -1 : 0 ]        tag_base_ld_addr_eight_bit,
    input  wire  [ ADDR_WIDTH           -1 : 0 ]        tag_base_ld_addr,

  // add for 8bit/16bit ibuf
  output wire [ 14       -1 : 0 ]        tag_mem_write_addr_0,
  output wire mem_write_req_in_0,
  output wire  [256 -1 : 0]                                mem_write_data_in_0,
  output wire [ 13       -1 : 0 ]        tag_buf_read_addr,
  input  wire                                         buf_read_req,
  output wire [ 512       -1 : 0 ]        _buf_read_data

);

//===================================================================test use 
(*MARK_DEBUG ="true"*)reg  [8 -1 : 0]   current_layer =0;
//wire choose_8bit = 0 ;
//wire [ADDR_WIDTH              -1 : 0 ]        tag_base_ld_addr_eight_bit = 'b0;
wire  i_is_run_adnn=0;


//==============================================================================
// Localparams
//==============================================================================
    localparam integer  LDMEM_IDLE                   = 0;
    localparam integer  LDMEM_CHECK_RAW              = 1;
    localparam integer  LDMEM_BUSY                   = 2;
    localparam integer  LDMEM_WAIT_0                 = 3;
    localparam integer  LDMEM_WAIT_1                 = 4;
    localparam integer  LDMEM_WAIT_2                 = 5;
    localparam integer  LDMEM_WAIT_3                 = 6;
    localparam integer  LDMEM_DONE                   = 7;
    localparam integer  LDMEM_WAIT_4                 = 8;
    localparam integer  LDMEM_WAIT_5                 = 9;
    localparam integer  LDMEM_WAIT_6                 = 10;
    localparam integer  LDMEM_WAIT_7                 = 11;
    localparam integer  LDMEM_WAIT_8                 = 12;
    

    localparam integer  STMEM_IDLE                   = 0;
    localparam integer  STMEM_DDR                    = 1;
    localparam integer  STMEM_WAIT_0                 = 2;
    localparam integer  STMEM_WAIT_1                 = 3;
    localparam integer  STMEM_WAIT_2                 = 4;
    localparam integer  STMEM_WAIT_3                 = 5;
    localparam integer  STMEM_DONE                   = 6;
    localparam integer  STMEM_PU                     = 7;

    localparam integer  MEM_LD                       = 0;
    localparam integer  MEM_ST                       = 1;
    localparam integer  MEM_RD                       = 2;
    localparam integer  MEM_WR                       = 3;
//==============================================================================

//==============================================================================
// Wires/Regs
//==============================================================================
    wire [ TAG_MEM_ADDR_W       -1 : 0 ]        tag_mem_write_addr;
    // wire [ TAG_BUF_ADDR_W       -1 : 0 ]        tag_buf_read_addr;

    wire                                        compute_tag_done;
    wire                                        compute_tag_reuse;
    wire                                        compute_tag_ready;
    wire [ TAG_W                -1 : 0 ]        compute_tag;
    wire                                        ldmem_tag_done;
    (* MARK_DEBUG="true" *)wire                                        ldmem_tag_ready;
    wire [ TAG_W                -1 : 0 ]        ldmem_tag;
    wire                                        stmem_tag_done;
    wire                                        stmem_tag_ready;
    wire [ TAG_W                -1 : 0 ]        stmem_tag;
    wire                                        stmem_ddr_pe_sw;

    reg  [ 4                    -1 : 0 ]        ldmem_state_d;
    (* MARK_DEBUG="true" *)reg  [ 4                    -1 : 0 ]        ldmem_state_q;

    reg  [ 3                    -1 : 0 ]        stmem_state_d;
    reg  [ 3                    -1 : 0 ]        stmem_state_q;

    wire                                        ld_mem_req_v;
    wire                                        st_mem_req_v;

    wire [ TAG_W                -1 : 0 ]        tag;


    reg                                         ld_iter_v_q;
    reg  [ LOOP_ITER_W          -1 : 0 ]        iter_q;
    reg                                         st_iter_v_q;

    reg  [ LOOP_ID_W            -1 : 0 ]        ld_loop_id_counter;
    reg  [ LOOP_ID_W            -1 : 0 ]        st_loop_id_counter;

    wire [ LOOP_ID_W            -1 : 0 ]        mws_ld_loop_iter_loop_id;
    wire [ LOOP_ITER_W          -1 : 0 ]        mws_ld_loop_iter;
    wire                                        mws_ld_loop_iter_v;
    wire                                        mws_ld_start;
    (* MARK_DEBUG="true" *)wire                                        mws_ld_done;
    wire                                        mws_ld_stall;
    wire                                        mws_ld_init;
    wire                                        mws_ld_enter;
    wire                                        mws_ld_exit;
    wire [ LOOP_ID_W            -1 : 0 ]        mws_ld_index;
    wire                                        mws_ld_index_valid;
    wire                                        mws_ld_step;

    wire                                        mws_st_stall;
    wire                                        mws_st_init;
    wire                                        mws_st_enter;
    wire                                        mws_st_exit;
    wire [ LOOP_ID_W            -1 : 0 ]        mws_st_index;
    wire                                        mws_st_index_valid;
    wire                                        mws_st_step;

    wire                                        ld_stride_v;
    wire [ ADDR_STRIDE_W        -1 : 0 ]        ld_stride;
    wire [ BUF_TYPE_W           -1 : 0 ]        ld_stride_id;
    wire                                        st_stride_v;
    wire [ ADDR_STRIDE_W        -1 : 0 ]        st_stride;
    wire [ BUF_TYPE_W           -1 : 0 ]        st_stride_id;






    reg  [ MEM_REQ_W            -1 : 0 ]        ld_req_size;
    wire                                        ld_req_valid_d;
    reg                                         ld_req_valid_q;
    reg  [ ADDR_WIDTH           -1 : 0 ]        ld_req_addr;

    
    
    wire                                        axi_rd_req;
    wire [ AXI_ID_WIDTH         -1 : 0 ]        axi_rd_req_id;
    (* MARK_DEBUG="true" *)wire                                        axi_rd_done;
    wire [ MEM_REQ_W            -1 : 0 ]        axi_rd_req_size;
    wire                                        axi_rd_ready;
    wire [ AXI_ADDR_WIDTH       -1 : 0 ]        axi_rd_addr;

    wire                                        axi_wr_req;
    wire [ AXI_ID_WIDTH         -1 : 0 ]        axi_wr_req_id;
    wire                                        axi_wr_done;
    wire [ MEM_REQ_W            -1 : 0 ]        axi_wr_req_size;
    wire                                        axi_wr_ready;
    wire [ AXI_ADDR_WIDTH       -1 : 0 ]        axi_wr_addr;

    (* MARK_DEBUG="true" *)wire                                        mem_write_req;
      (* MARK_DEBUG="true" *)  wire [ AXI_DATA_WIDTH       -1 : 0 ]        mem_write_data;
    (* MARK_DEBUG="true" *)reg  [ MEM_ADDR_W           -1 : 0 ]        mem_write_addr;
    wire                                        mem_write_ready;
    wire [ AXI_DATA_WIDTH       -1 : 0 ]        mem_read_data;
    wire                                        mem_read_req;
    wire                                        mem_read_ready;

  // Adding register to buf read data
    // wire [ BUF_DATA_WIDTH       -1 : 0 ]        _buf_read_data;

  // Read-after-write
    reg                                         raw;
    wire [ TAG_W                -1 : 0 ]        raw_stmem_tag;
    wire                                        raw_stmem_tag_ready;
    wire [ ADDR_WIDTH           -1 : 0 ]        raw_stmem_st_addr;
    wire                                        pu_done;
    wire [ AXI_ID_WIDTH         -1 : 0 ]        mem_write_id;
    wire                                        ldmem_ready;
//==============================================================================


//==============================================================================

  //============================================================================== wire modify edit by pxq 0814 (8bit)

    reg  [ ADDR_WIDTH           -1 : 0 ]        tag_ld_addr[0:NUM_TAGS-1];
     (* MARK_DEBUG="true" *)reg  [ ADDR_WIDTH           -1 : 0 ]        tag_ld_addr_eight_bit[0:NUM_TAGS-1];

    wire [ ADDR_WIDTH           -1 : 0 ]        mws_ld_base_addr;
    wire [ ADDR_WIDTH           -1 : 0 ]        mws_ld_base_addr_eight_bit;

   (* MARK_DEBUG="true" *) wire [ ADDR_WIDTH           -1 : 0 ]        ld_addr;
   (* MARK_DEBUG="true" *) wire                                        ld_addr_v;
    (* MARK_DEBUG="true" *) reg [ ADDR_WIDTH           -1 : 0 ]        ld_addr_eight_bit;
    (* MARK_DEBUG="true" *) reg                                        ld_addr_eight_bit_v;

    reg        eight_bit_ldmem_state_d;
    (* MARK_DEBUG="true" *) reg         eight_bit_ldmem_state_q;
    



  reg  eight_bit_write_buf_state_d;
  reg eight_bit_write_buf_state_q;
  reg eight_bit_write_ready;
  reg eight_bit_write_ready_dly;

reg[AXI_DATA_WIDTH -1 : 0]  eight_bit_mem_write_data_L;
reg[AXI_DATA_WIDTH -1 : 0]  eight_bit_mem_write_data_H;
reg [512 -1 : 0] eight_bit_mem_write_data= 'b0;
reg[AXI_DATA_WIDTH -1 : 0] eight_bit_mem_write_data_in = 'b0;

reg eight_bit_mem_write_req = 0;
 reg [512 -1 : 0] eight_bit_mem_write_data_dly;

reg[AXI_DATA_WIDTH -1 : 0]  sixteen_bit_mem_write_data_in;
reg                                                     sixteen_bit_mem_write_req;

 (* MARK_DEBUG="true" *)wire mem_write_req_in ;
    (* MARK_DEBUG="true" *)wire  [AXI_DATA_WIDTH -1 : 0]                                mem_write_data_in;


//==============================================================================wire modify edit by pxq 0830(1layer)
   (* MARK_DEBUG="true" *)reg  first_layer_sw;
  reg [LINE_DATA_WIDTH -1 : 0]   ddr2ibuf_buf [  0 : TILE_LINE_COUNT+1  ];
   (* MARK_DEBUG="true" *)reg [4 - 1 :0 ]          current_input_line;
   (* MARK_DEBUG="true" *)reg [4 - 1 : 0]          current_output_line;
   (* MARK_DEBUG="true" *)reg [ 4 - 1 : 0]          current_count ;
   (* MARK_DEBUG="true" *)reg[ 4 - 1 : 0]          current_row;


  wire [512 -1 : 0] mem_write_fl_data_in;
  reg [MEM_ADDR_W -1 : 0] mem_write_fl_addr_in;
  wire   mem_write_fl_req_in;

  wire [8 - 1 : 0]       line_difference;
  wire fl_stall;
 (* MARK_DEBUG="true" *) wire fl_tile_init_done;

wire [ TAG_MEM_ADDR_W       -1 : 0 ]        tag_mem_write_fl_addr;
// (* MARK_DEBUG="true" *)wire [ TAG_MEM_ADDR_W       -1 : 0 ]        tag_mem_write_addr_0;
// (* MARK_DEBUG="true" *)wire mem_write_req_in_0;
// (* MARK_DEBUG="true" *)wire  [AXI_DATA_WIDTH -1 : 0]                                mem_write_data_in_0;

wire mem_write_fl_req;
reg [ AXI_DATA_WIDTH - 1 : 0 ] ddr2ibuf_in;
reg  fl_ddr2buf_state_q;
reg fl_ddr2buf_state_d;

reg outputline_row_req;

//==========================================================================================1102

    wire  [12     -1 : 0] addr_offset;
    wire [AXI_DATA_WIDTH -12  -1 :0] addr_offset_2;

    reg axi_rd_addr_pretreat_stall;

    (* MARK_DEBUG="true" *)reg axi_rd_req_in_0;
    (* MARK_DEBUG="true" *)reg axi_rd_req_in_1;
    (* MARK_DEBUG="true" *)reg[ AXI_ADDR_WIDTH       -1 : 0 ]   axi_rd_addr_pretreat_0;
    (* MARK_DEBUG="true" *)reg[ AXI_ADDR_WIDTH       -1 : 0 ]   axi_rd_addr_pretreat_1;
    (* MARK_DEBUG="true" *)reg [ MEM_REQ_W            -1 : 0 ]        axi_rd_req_size_0;
    (* MARK_DEBUG="true" *)reg [ MEM_REQ_W            -1 : 0 ]        axi_rd_req_size_1;

    wire [ AXI_ADDR_WIDTH       -1 : 0 ]   axi_rd_addr_pre;

    reg ibuf_ld_addr_stalll;


 (* MARK_DEBUG="true" *)wire axi_rd_req_in;
 (* MARK_DEBUG="true" *)wire [AXI_ADDR_WIDTH - 1 : 0] axi_rd_addr_in;
 (* MARK_DEBUG="true" *)wire  [ MEM_REQ_W            -1 : 0 ]axi_rd_req_size_in ;

reg  ibuf_ld_stall;

   (* MARK_DEBUG="true" *)wire[3-1:0] line_stride,row_stride;

//===============================================================================  axi data pretreatment 16/8bit edit by pxq 1020

localparam integer  FL_LDMEM_DDR_16BIT_IDLE                    = 0;
localparam integer  FL_LDMEM_DDR_16BIT_0                  = 1;
localparam integer  FL_LDMEM_DDR_16BIT_1                 = 2;
localparam integer  FL_LDMEM_DDR_16BIT_2                = 3;
localparam integer  FL_LDMEM_DDR_16BIT_3                 = 4;
localparam integer  FL_LDMEM_DDR_16BIT_4                   = 5;

wire[ 8 -1 :  0] fl_fifo_write_data;
wire  fl_fifo_read_req_16bit;
wire fl_fifo_read_req_8bit;
wire fl_fifo_read_req;
wire fl_fifo_write_req;
assign fl_fifo_write_req = axi_rd_req && first_layer_sw;
(* MARK_DEBUG="true" *) wire[ 8 - 1 : 0] fl_fifo_read_data;

assign fl_fifo_read_req = fl_fifo_read_req_16bit||fl_fifo_read_req_8bit;

(* MARK_DEBUG="true" *)assign fl_fifo_write_data=ld_req_addr[4:0]<<3;// bias
//assign fl_fifo_read_req = fl_16bit_addr_state_d==FL_LDMEM_DDR_16BIT_0;


fifo #(
    .DATA_WIDTH                     ( 8                       ),
    .ADDR_WIDTH                     ( 5                              )
) fl_addr_concat_buf (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .s_read_req                     ( fl_fifo_read_req                 ), //input
    .s_read_ready                   (             ), //output
    .s_read_data                    ( fl_fifo_read_data           ), //output
    .s_write_req                    (  fl_fifo_write_req                 ), //input
    .s_write_ready                  (             ), //output
    .s_write_data                   (   fl_fifo_write_data             )//input
  );

   (* MARK_DEBUG="true" *)reg[4 - 1 :0] fl_16bit_addr_state_d;
   (* MARK_DEBUG="true" *)reg[4- 1: 0 ] fl_16bit_addr_state_q;

reg[5*AXI_DATA_WIDTH -1 : 0] fl_16bit_data_buf;



always @(posedge clk) begin
  if(reset)begin
    fl_16bit_addr_state_q<=0;
  end
  else
  fl_16bit_addr_state_q<=fl_16bit_addr_state_d;
end

always @(posedge clk) begin
  if(fl_16bit_addr_state_d == FL_LDMEM_DDR_16BIT_0&&mem_write_req)begin
    fl_16bit_data_buf[255:0]<=mem_write_data; 
  end
  if(fl_16bit_addr_state_d == FL_LDMEM_DDR_16BIT_1&&mem_write_req)begin
    fl_16bit_data_buf[511:256]<=mem_write_data; 
  end
  if(fl_16bit_addr_state_d == FL_LDMEM_DDR_16BIT_2&&mem_write_req)begin
    fl_16bit_data_buf[767:512]<=mem_write_data; 
  end
  if(fl_16bit_addr_state_d == FL_LDMEM_DDR_16BIT_3&&mem_write_req)begin
    fl_16bit_data_buf[1023:768]<=mem_write_data; 
  end
  if(fl_16bit_addr_state_d == FL_LDMEM_DDR_16BIT_4&&mem_write_req)begin
    fl_16bit_data_buf[1279:1024]<=mem_write_data; 
  end
end

   (* MARK_DEBUG="true" *)wire[AXI_DATA_WIDTH -1 :0] mem_write_data_pretreat_16bit;
   (* MARK_DEBUG="true" *)reg mem_write_data_pretreat_16bit_req;
   (* MARK_DEBUG="true" *)reg[3-1 : 0] mem_write_data_pretreat_count_16bit; 

always @(posedge clk)begin
  if((~choose_8bit)&&mem_write_req&&(fl_16bit_addr_state_d==FL_LDMEM_DDR_16BIT_1||fl_16bit_addr_state_d==FL_LDMEM_DDR_16BIT_2||fl_16bit_addr_state_d==FL_LDMEM_DDR_16BIT_3||fl_16bit_addr_state_d==FL_LDMEM_DDR_16BIT_4   )    )begin
    mem_write_data_pretreat_16bit_req<=1;
     mem_write_data_pretreat_count_16bit<=(fl_16bit_addr_state_d-2);
  end
  else begin
    mem_write_data_pretreat_16bit_req<=0;
    mem_write_data_pretreat_count_16bit<=0;
  end
end

assign mem_write_data_pretreat_16bit = fl_16bit_data_buf[(fl_fifo_read_data+mem_write_data_pretreat_count_16bit*AXI_DATA_WIDTH)+:256];

// always @(posedge clk) begin
//   if(fl_16bit_addr_state_d ==FL_LDMEM_DDR_16BIT_0 &&fl_16bit_addr_state_q == FL_LDMEM_DDR_16BIT_IDLE)begin
//     fl_fifo_read_req_16bit<=1;
//   end
//   else begin
//     fl_fifo_read_req_16bit<=0;
//   end
// end

assign fl_fifo_read_req_16bit =( fl_16bit_addr_state_d ==FL_LDMEM_DDR_16BIT_0 &&fl_16bit_addr_state_q == FL_LDMEM_DDR_16BIT_IDLE) ? 1 : 0;

always@(*) begin
  fl_16bit_addr_state_d=fl_16bit_addr_state_q;
  case(fl_16bit_addr_state_q)
  FL_LDMEM_DDR_16BIT_IDLE:begin
    if((~choose_8bit)&&mem_write_req&&first_layer_sw)begin
      fl_16bit_addr_state_d = FL_LDMEM_DDR_16BIT_0;
    end

  end
  FL_LDMEM_DDR_16BIT_0:begin
    if(mem_write_req)begin

      fl_16bit_addr_state_d=FL_LDMEM_DDR_16BIT_1;
    end

  end
  FL_LDMEM_DDR_16BIT_1:begin
      if(mem_write_req)begin

      fl_16bit_addr_state_d=FL_LDMEM_DDR_16BIT_2;
  end
  end
  FL_LDMEM_DDR_16BIT_2:begin
      if(mem_write_req)begin

      fl_16bit_addr_state_d=FL_LDMEM_DDR_16BIT_3;
     end
    else if(axi_rd_req_size==3)begin
    fl_16bit_addr_state_d=FL_LDMEM_DDR_16BIT_IDLE;
  end
  end
  FL_LDMEM_DDR_16BIT_3:begin
      if(mem_write_req)begin

      fl_16bit_addr_state_d=FL_LDMEM_DDR_16BIT_4;
  end
  end
  FL_LDMEM_DDR_16BIT_4:begin

      fl_16bit_addr_state_d=FL_LDMEM_DDR_16BIT_IDLE;
  end
  default:begin

    fl_16bit_addr_state_d=FL_LDMEM_DDR_16BIT_IDLE;
  end
  endcase 
end

//==========================================8bit prevtreatment
   (* MARK_DEBUG="true" *)reg[4 -1 : 0] fl_8bit_addr_state_d;
   (* MARK_DEBUG="true" *)reg[4 -1 :0] fl_8bit_addr_state_q;



localparam integer  FL_LDMEM_DDR_8BIT_IDLE                    = 0;
localparam integer  FL_LDMEM_DDR_8BIT_1_0                  = 1;
localparam integer  FL_LDMEM_DDR_8BIT_1_1                 = 2;
localparam integer  FL_LDMEM_DDR_8BIT_1_2                = 3;
localparam integer  FL_LDMEM_DDR_8BIT_2_0                 = 4;
localparam integer  FL_LDMEM_DDR_8BIT_2_1                   = 5;
localparam integer  FL_LDMEM_DDR_8BIT_2_2                   = 6;
localparam integer FL_LDMEM_DDR_8BIT_WAIT_2          =7;

always@(posedge clk)begin
  if(reset)begin
    fl_8bit_addr_state_q<=0;
  end
  else
  fl_8bit_addr_state_q<=fl_8bit_addr_state_d;
end

// always @(posedge clk)begin
//   if(fl_8bit_addr_state_q ==0 && fl_8bit_addr_state_d ==FL_LDMEM_DDR_8BIT_1_0)begin
//     fl_fifo_read_req_8bit <=1;
//   end
//   else if(fl_8bit_addr_state_q ==FL_LDMEM_DDR_8BIT_WAIT_2 && fl_8bit_addr_state_d ==FL_LDMEM_DDR_8BIT_2_0)begin
//     fl_fifo_read_req_8bit<=1;
//   end
//   else begin
//     fl_fifo_read_req_8bit<=0;
//   end
// end

assign fl_fifo_read_req_8bit = ((fl_8bit_addr_state_q ==0 && fl_8bit_addr_state_d ==FL_LDMEM_DDR_8BIT_1_0)||(fl_8bit_addr_state_q ==FL_LDMEM_DDR_8BIT_WAIT_2 && fl_8bit_addr_state_d ==FL_LDMEM_DDR_8BIT_2_0))? 1:0 ;
always@(*)begin
  fl_8bit_addr_state_d=fl_8bit_addr_state_q;
  case(fl_8bit_addr_state_q)
FL_LDMEM_DDR_8BIT_IDLE:begin
  if(choose_8bit&&mem_write_req&&first_layer_sw)begin
    fl_8bit_addr_state_d=FL_LDMEM_DDR_8BIT_1_0;
  end
end

FL_LDMEM_DDR_8BIT_1_0:begin
  if(mem_write_req)begin
    fl_8bit_addr_state_d=FL_LDMEM_DDR_8BIT_1_1;
  end

end

FL_LDMEM_DDR_8BIT_1_1:begin
  if(mem_write_req)begin
    fl_8bit_addr_state_d=FL_LDMEM_DDR_8BIT_1_2;
  end
    else if(axi_rd_req_size==2)begin
    fl_8bit_addr_state_d=FL_LDMEM_DDR_8BIT_WAIT_2;
  end
end

FL_LDMEM_DDR_8BIT_1_2:begin
    fl_8bit_addr_state_d=FL_LDMEM_DDR_8BIT_WAIT_2;
  end

FL_LDMEM_DDR_8BIT_WAIT_2:begin
  if(mem_write_req)begin
    fl_8bit_addr_state_d=FL_LDMEM_DDR_8BIT_2_0;
  end
end

FL_LDMEM_DDR_8BIT_2_0:begin
  if(mem_write_req)begin
    fl_8bit_addr_state_d=FL_LDMEM_DDR_8BIT_2_1;
  end

end

FL_LDMEM_DDR_8BIT_2_1:begin
  if(mem_write_req)begin
    fl_8bit_addr_state_d=FL_LDMEM_DDR_8BIT_2_2;
  end
  else if(axi_rd_req_size==2)begin
    fl_8bit_addr_state_d=FL_LDMEM_DDR_8BIT_IDLE;
  end
end

FL_LDMEM_DDR_8BIT_2_2:begin
    fl_8bit_addr_state_d=FL_LDMEM_DDR_8BIT_IDLE;
end


default: begin
  fl_8bit_addr_state_d = FL_LDMEM_DDR_8BIT_IDLE;
end
  endcase
end

reg[3*AXI_DATA_WIDTH - 1 : 0] fl_8bit_data_buf_1;
reg[3*AXI_DATA_WIDTH - 1 : 0] fl_8bit_data_buf_2;

always @(posedge clk) begin
  if(fl_8bit_addr_state_d == FL_LDMEM_DDR_8BIT_1_0&&mem_write_req)begin
    fl_8bit_data_buf_1[255:0]<=mem_write_data; 
  end
  if(fl_8bit_addr_state_d == FL_LDMEM_DDR_8BIT_1_1&&mem_write_req)begin
    fl_8bit_data_buf_1[511:256]<=mem_write_data; 
  end
  if(fl_8bit_addr_state_d == FL_LDMEM_DDR_8BIT_1_2&&mem_write_req)begin
    fl_8bit_data_buf_1[767:512]<=mem_write_data; 
  end
  if(fl_8bit_addr_state_d == FL_LDMEM_DDR_8BIT_2_0&&mem_write_req)begin
    fl_8bit_data_buf_2[255:0]<=mem_write_data; 
  end
  if(fl_8bit_addr_state_d == FL_LDMEM_DDR_8BIT_2_1&&mem_write_req)begin
    fl_8bit_data_buf_2[511:256]<=mem_write_data; 
  end
  if(fl_8bit_addr_state_d == FL_LDMEM_DDR_8BIT_2_2&&mem_write_req)begin
    fl_8bit_data_buf_2[767:512]<=mem_write_data; 
  end
end

   (* MARK_DEBUG="true" *)reg mem_write_data_pretreat_8bit_req_1;
   (* MARK_DEBUG="true" *)wire [AXI_DATA_WIDTH -1 :0] mem_write_data_pretreat_8bit_1;
   (* MARK_DEBUG="true" *)reg[3-1:0] mem_write_data_pretreat_count_8bit_1; 

reg mem_write_data_pretreat_8bit_req_2;
wire [AXI_DATA_WIDTH -1 :0] mem_write_data_pretreat_8bit_2;
reg[3-1:0] mem_write_data_pretreat_count_8bit_2; 

   (* MARK_DEBUG="true" *)reg data_pretreat_8bit_dly_tag;
   (* MARK_DEBUG="true" *)reg[8 - 1 :0] data_8bit_bias_1;
   (* MARK_DEBUG="true" *)reg[8 - 1 :0] data_8bit_bias_2;

   (* MARK_DEBUG="true" *)wire mem_write_data_pretreat_8bit_req;
   (* MARK_DEBUG="true" *)wire[AXI_DATA_WIDTH - 1 :0 ] mem_write_data_pretreat_8bit;


always @(posedge clk) begin
  if(fl_8bit_addr_state_d==FL_LDMEM_DDR_8BIT_1_1)begin
    data_8bit_bias_1<=fl_fifo_read_data;
  end
  
end

always @(posedge clk)begin
  if(fl_8bit_addr_state_d==FL_LDMEM_DDR_8BIT_2_1)begin
    data_8bit_bias_2<=fl_fifo_read_data;
  end
end

assign mem_write_data_pretreat_8bit_1 = fl_8bit_data_buf_1[(data_8bit_bias_1+mem_write_data_pretreat_count_8bit_1*AXI_DATA_WIDTH)+:256];
assign mem_write_data_pretreat_8bit_2 = fl_8bit_data_buf_2[(data_8bit_bias_2+mem_write_data_pretreat_count_8bit_2*AXI_DATA_WIDTH)+:256];

assign mem_write_data_pretreat_8bit_req = mem_write_data_pretreat_8bit_req_1||mem_write_data_pretreat_8bit_req_2;
assign mem_write_data_pretreat_8bit = mem_write_data_pretreat_8bit_req_1? mem_write_data_pretreat_8bit_1: mem_write_data_pretreat_8bit_2;

wire mem_write_data_pretreat_req;
wire[AXI_DATA_WIDTH - 1 : 0] mem_write_data_pretreat;

assign mem_write_data_pretreat_req = (first_layer_sw)? (mem_write_data_pretreat_8bit_req||mem_write_data_pretreat_16bit_req) : mem_write_req;
assign mem_write_data_pretreat = (first_layer_sw) ? (mem_write_data_pretreat_16bit_req? mem_write_data_pretreat_16bit : mem_write_data_pretreat_8bit) : mem_write_data ;


always @(posedge clk)begin
  if(choose_8bit &&fl_8bit_addr_state_d==FL_LDMEM_DDR_8BIT_1_1&&mem_write_req)begin
    mem_write_data_pretreat_8bit_req_1<=1;
    mem_write_data_pretreat_count_8bit_1<=0;
  end
  else if(choose_8bit && mem_write_data_pretreat_8bit_req_2 && (mem_write_data_pretreat_count_8bit_2==0)&&(row_stride ==2))begin
    mem_write_data_pretreat_8bit_req_1<=1;
    mem_write_data_pretreat_count_8bit_1<=1;
  end
  else begin
    mem_write_data_pretreat_8bit_req_1<=0;
  end
end

always @(posedge clk)begin
  if(choose_8bit &&fl_8bit_addr_state_d==FL_LDMEM_DDR_8BIT_2_1&&mem_write_req)begin
    mem_write_data_pretreat_8bit_req_2<=1;
    mem_write_data_pretreat_count_8bit_2<=0;
  end
else if((choose_8bit&&fl_8bit_addr_state_d==FL_LDMEM_DDR_8BIT_2_2&&mem_write_req&&mem_write_data_pretreat_count_8bit_1==1)||data_pretreat_8bit_dly_tag)begin
    mem_write_data_pretreat_8bit_req_2<=1;
    mem_write_data_pretreat_count_8bit_2<=1;
    data_pretreat_8bit_dly_tag<=0;
  end
else if(choose_8bit&&fl_8bit_addr_state_d==FL_LDMEM_DDR_8BIT_2_2&&mem_write_req&&mem_write_data_pretreat_count_8bit_1==0)begin
    data_pretreat_8bit_dly_tag<=1;
    mem_write_data_pretreat_8bit_req_2<=0;
  end
  else begin
    mem_write_data_pretreat_8bit_req_2<=0;
    data_pretreat_8bit_dly_tag<=0;
  end
end

//============================================================================
  // Assigns
//==============================================================================
    assign pu_done= 1'b1;

    assign ld_stride = cfg_loop_stride;
    assign ld_stride_v = cfg_loop_stride_v && cfg_loop_stride_loop_id == 1 + MEM_ID && cfg_loop_stride_type == MEM_LD && cfg_loop_stride_id == MEM_ID;

    assign axi_wr_req = 1'b0;
    assign axi_wr_req_id = 1'b0;
    assign axi_wr_req_size = 0;
    assign axi_wr_addr = 0;
//=============================================================================== first layer optimized edit by pxq 0830 input size 17*17 / 10*10
reg[3-1 :0] stride_temp;

   (* MARK_DEBUG="true" *)reg [11 - 1 :0] single_line_count;

   (* MARK_DEBUG="true" *)reg[8 - 1 :0] tile_row_count;
always @(posedge clk) begin
  if(mws_ld_loop_iter_v&&mws_ld_loop_iter_loop_id==0)begin
    tile_row_count<=mws_ld_loop_iter+1;
  end
end

always@(posedge clk)begin

    single_line_count<= (tile_row_count*48-1)>>8;
  end

always @(posedge clk) begin
  if(reset)begin
    stride_temp<='b0;
  end
  else if(cfg_loop_iter_loop_id == 0 && cfg_loop_iter_v)begin
    stride_temp<= cfg_loop_iter;
  end
end

assign line_stride =row_stride;
assign row_stride=  (tile_row_count - 1) / stride_temp;


always @(posedge clk) begin
  if(current_layer == 1 && (~i_is_run_adnn))begin
    first_layer_sw<=1;
  end
  else
    first_layer_sw<=0;
end

always @(posedge clk) begin

    if(mem_write_req_in &&  current_input_line < TILE_LINE_EXTEND_COUNT )begin//&&first_layer_sw) begin
    ddr2ibuf_buf[current_input_line][current_count*AXI_DATA_WIDTH  +:  AXI_DATA_WIDTH]  <= mem_write_data_in;  //LINE_DATA_WIDTH   -> LINE_DATA_WIDTH;
      ddr2ibuf_buf[current_input_line+TILE_LINE_COUNT][current_count*AXI_DATA_WIDTH +:AXI_DATA_WIDTH]<=mem_write_data_in;
  end
  
  else if(mem_write_req_in)begin
   ddr2ibuf_buf[current_input_line][current_count*AXI_DATA_WIDTH  +:  AXI_DATA_WIDTH] <= mem_write_data_in;  //LINE_DATA_WIDTH   -> LINE_DATA_WIDTH;
  end
  
end

always @(posedge clk) begin
  if(mws_ld_loop_iter_v)begin
    current_count<=0;
  end

  else if(current_count ==  single_line_count  && mem_write_req_in )begin  //edit by pxq
     current_count<=0;
  end
  else if (mem_write_req_in)begin
    current_count<=current_count +1 ;
  end
  
end

always @(posedge clk) begin
  if(mws_ld_loop_iter_v||fl_tile_init_done)begin
    current_input_line<=0;
  end

  else if (current_count== single_line_count &&mem_write_req_in && current_input_line == TILE_LINE_COUNT -1) begin
    current_input_line <=0; 
  end
  else if (current_count== single_line_count   && mem_write_req_in)begin
    current_input_line<=current_input_line +1;
  end

end


always @(posedge clk) begin
  if(mws_ld_loop_iter_v)begin
    current_row <= 0;
  end
  else if(outputline_row_req&&current_row==tile_row_count - 3)begin
    current_row<=0;
  end
  else if(outputline_row_req)begin
    current_row<=current_row + row_stride;
  end
end

always @(posedge clk) begin
  if(mws_ld_loop_iter_v||fl_tile_init_done)begin
    current_output_line<=0;
  end

  else if(outputline_row_req&&current_row==tile_row_count - 3 && (current_output_line + line_stride > TILE_LINE_COUNT -1) )begin
    current_output_line<=current_output_line+line_stride - TILE_LINE_COUNT;
  end
  else if(outputline_row_req && current_row == tile_row_count - 3)begin
   current_output_line<=current_output_line+line_stride;
  end
end

assign line_difference =  current_input_line >= current_output_line ?  current_input_line - current_output_line : current_input_line + TILE_LINE_COUNT - current_output_line ;
assign  fl_stall = line_difference > 4;
assign  fl_tile_init_done = line_difference <= 2 && ldmem_state_q ==  LDMEM_WAIT_2;
// assign mem_write_ready = ~(fl_stall && first_layer_sw);


assign mem_write_fl_req =  (line_difference >=3 && first_layer_sw) ? 1 : 0;

always @(posedge clk) begin
  if(reset)begin
    mem_write_fl_addr_in<='b0;
  end

  else if(mem_write_fl_req_in)begin
    mem_write_fl_addr_in<=mem_write_fl_addr_in+1;
  end

  else if(fl_tile_init_done)begin
    mem_write_fl_addr_in<=0;
  end
end


assign mem_write_fl_req_in = mem_write_fl_req ? 1 : 0;



always @(posedge clk) begin
  if(reset)begin
    fl_ddr2buf_state_q<=0;
  end
  else begin
    fl_ddr2buf_state_q<=fl_ddr2buf_state_d;
  end
end

always @(*)begin
  fl_ddr2buf_state_d = fl_ddr2buf_state_q;
  case (fl_ddr2buf_state_q)
   0 : begin
     if(mem_write_fl_req)begin
       fl_ddr2buf_state_d = 1;
       ddr2ibuf_in = mem_write_fl_data_in[255 : 0] ;
     end
     outputline_row_req = 0;
   end 
     1 : begin
       outputline_row_req =1;
       ddr2ibuf_in = mem_write_fl_data_in[511 : 256];
       fl_ddr2buf_state_d = 0;
     end 
  endcase
end



assign mem_write_fl_data_in ={80'b0, 
ddr2ibuf_buf[(current_output_line+2)][(current_row+2)*48  +: 48 ],
ddr2ibuf_buf[(current_output_line+2)][(current_row+1)*48 +: 48 ],
ddr2ibuf_buf[(current_output_line+2)][(current_row)*48 +: 48 ],
ddr2ibuf_buf[(current_output_line+1)][(current_row+2)*48 +: 48 ],
ddr2ibuf_buf[(current_output_line+1)][(current_row+1)*48 +: 48 ],
ddr2ibuf_buf[(current_output_line+1)][current_row*48 +: 48 ],
ddr2ibuf_buf[current_output_line][(current_row+2)*48 +: 48 ],
ddr2ibuf_buf[current_output_line][(current_row+1)*48 +: 48 ],
ddr2ibuf_buf[current_output_line][current_row*48 +: 48 ]};








assign tag_mem_write_fl_addr ={ldmem_tag,mem_write_fl_addr_in};


//==================================================================================
//==============================================================================eight_bit_sixteen_bit change edit by pxq 0816 (8bit)
    assign mws_ld_base_addr = tag_ld_addr[ldmem_tag];
   assign mws_ld_base_addr_eight_bit = tag_ld_addr_eight_bit[ldmem_tag];
     reg ld_addr_eight_bit_stall;

    always @(posedge clk)
  begin
    if (tag_req && tag_ready) begin
      tag_ld_addr[tag] <= tag_base_ld_addr;
    end
     if(tag_req&&tag_ready&&choose_8bit)begin
      tag_ld_addr_eight_bit[tag] <= tag_base_ld_addr_eight_bit;
    end
  end

    assign mws_ld_stall = ~ldmem_tag_ready || ~axi_rd_ready||ld_addr_eight_bit_v|| ld_addr_eight_bit_stall||ibuf_ld_stall||axi_rd_addr_pretreat_stall;

    //assign mws_ld_stall = ~ldmem_tag_ready || ~axi_rd_ready;
    assign mws_ld_step = mws_ld_index_valid && !mws_ld_stall;

  mem_walker_stride #(
    .ADDR_WIDTH                     ( ADDR_WIDTH                     ),
    .ADDR_STRIDE_W                  ( ADDR_STRIDE_W                  ),
    .LOOP_ID_W                      ( LOOP_ID_W                      )
  ) mws_ld (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .base_addr                      ( mws_ld_base_addr               ), //input
    .loop_ctrl_done                 ( mws_ld_done                    ), //input
    .loop_index                     ( mws_ld_index                   ), //input
    .loop_index_valid               ( mws_ld_step                    ), //input
    .loop_init                      ( mws_ld_init                    ), //input
    .loop_enter                     ( mws_ld_enter                   ), //input
    .loop_exit                      ( mws_ld_exit                    ), //input
    .cfg_addr_stride_v              ( ld_stride_v                    ), //input
    .cfg_addr_stride                ( ld_stride                      ), //input
    .addr_out                       ( ld_addr                        ), //output
    .addr_out_valid                 ( ld_addr_v                      )  //output
  );

reg[42-1 :0] test_use = {{37'b1111111111111111111111111111111111111},{5'b0}};

reg ld_addr_v_dly;
reg[AXI_ADDR_WIDTH - 1 :0] ld_addr_dly;
always @(posedge clk) begin
  if(ld_addr_v) begin
    ibuf_ld_stall<=1;
  end
  else begin
    ibuf_ld_stall<= 0;
  end
end
always @(posedge clk) begin
  ld_addr_v_dly<=ld_addr_v;
end
always @(posedge clk) begin
  if(ld_addr_v)begin
    ld_addr_dly<=ld_addr;
  end
end


  always @(posedge clk) begin
    if(reset)begin
      ld_addr_eight_bit_v<=0;
      ld_addr_eight_bit<=0;
      ld_addr_eight_bit_stall<=0;
    end
    else if (choose_8bit&&axi_rd_ready&&(ld_addr_v_dly||ld_addr_eight_bit_stall)) begin
      ld_addr_eight_bit_v<=1;
      ld_addr_eight_bit<=ld_addr_dly+mws_ld_base_addr_eight_bit;
      ld_addr_eight_bit_stall<=0;
    end
    else if(choose_8bit&&ld_addr_v_dly)begin
      ld_addr_eight_bit_stall<=1;
      ld_addr_eight_bit_v<=0;
    end
    else
      ld_addr_eight_bit_v<=0;

  end


  assign ld_req_valid_d = ld_addr_v||ld_addr_eight_bit_v;
  always @(posedge clk)
  begin
    if (reset) begin
      ld_req_valid_q <= 1'b0;
      ld_req_addr <= 'b0;
    end
    else begin
      ld_req_valid_q <= ld_req_valid_d;
      //ld_req_addr <= ld_addr_eight_bit_v? ld_addr_eight_bit: ld_addr;
      ld_req_addr <= ld_addr_eight_bit_v? ld_addr_eight_bit: ld_addr;
    end
  end

  reg[MEM_REQ_W            -1 : 0] axi_rd_req_size_reg;
  always @(posedge clk) begin
    if(first_layer_sw)begin
      if(choose_8bit)begin
        if(row_stride==1)begin
          axi_rd_req_size_reg<=2;
        end
        else if(row_stride == 2)begin
          axi_rd_req_size_reg<=3;
        end
      end
      else begin
        if(row_stride==1)begin
          axi_rd_req_size_reg<=3;
        end
        else if(row_stride==2)begin
          axi_rd_req_size_reg<=5;
        end
      end
    end
    else if(~first_layer_sw)begin
      if(choose_8bit)begin
        axi_rd_req_size_reg<=1;
      end
      else begin
        axi_rd_req_size_reg<=2;
      end
    end
    else begin
      axi_rd_req_size_reg<=0;
    end
  end

    assign axi_rd_req = ld_req_valid_q;
    assign axi_rd_addr = ld_req_addr&test_use;
    //assign axi_rd_addr = ld_req_addr;//&test_use;
    assign axi_rd_req_size = axi_rd_req_size_reg;

       //====================================================rd_addr pretreat 1102 edit by pxq


assign axi_rd_req_in = axi_rd_req_in_0|| axi_rd_req_in_1;
assign axi_rd_addr_in = axi_rd_req_in_0 ?  axi_rd_addr_pretreat_0: axi_rd_addr_pretreat_1;
assign axi_rd_req_size_in = axi_rd_req_in_0? axi_rd_req_size_0 : axi_rd_req_size_1;

    // always @(posedge clk) begin
    //   if(reset)begin
    //     ibuf_ld_addr_stall_0<=0;
    //   end
    //   else if(ld_addr_v)begin
    //     ibuf_ld_addr_stall_0<=1;
    //   end
    //   else begin
    //     ibuf_ld_addr_stall_0<=0;
    //   end
    // end
    assign axi_rd_addr_pre = ld_addr_v? ( ld_addr & test_use) : (ld_addr_eight_bit&test_use);
    

    assign addr_offset = axi_rd_addr_pre[11:0];
    assign addr_offset_2 = axi_rd_addr_pre[41:12] + 1;

    always @(posedge clk)begin
        if(ld_addr_v||ld_addr_eight_bit_v)begin
            axi_rd_addr_pretreat_0<=axi_rd_addr_pre;
            axi_rd_addr_pretreat_1<={addr_offset_2,{12'b0}};
        end
    end


    always @(posedge clk) begin

//        axi_rd_addr_pretreat_0<=axi_rd_addr_pre;
//        axi_rd_addr_pretreat_1<={addr_offset_2,{12'b0}};

      if(~first_layer_sw&&(ld_addr_v||ld_addr_eight_bit_v))begin
        axi_rd_req_in_0<=1;
        axi_rd_addr_pretreat_stall<=0;
        axi_rd_req_size_0<= axi_rd_req_size_reg;
      end

      else if(first_layer_sw && (ld_addr_v || ld_addr_eight_bit_v))begin

        if(addr_offset == 'hf80&&axi_rd_req_size>=5)begin
          axi_rd_addr_pretreat_stall<=1;
          axi_rd_req_size_0<= 4;
          axi_rd_req_in_0<=1;

          axi_rd_req_size_1 <= axi_rd_req_size_reg - 4;

        end

        else if(addr_offset == 'hfa0&&axi_rd_req_size>=4)begin
          axi_rd_addr_pretreat_stall<=1;
          axi_rd_req_size_0<= 3;
          axi_rd_req_in_0<=1;

          axi_rd_req_size_1 <= axi_rd_req_size_reg - 3;
        end

        else if(addr_offset == 'hfc0&&axi_rd_req_size>=3)begin
          axi_rd_addr_pretreat_stall<=1;
          axi_rd_req_size_0<= 2;
          axi_rd_req_in_0<=1;

          axi_rd_req_size_1 <= axi_rd_req_size_reg - 2;
        end

        else if(addr_offset == 'hfe0&&axi_rd_req_size>=2)begin
          axi_rd_addr_pretreat_stall<=1;
          axi_rd_req_size_0<= 1;
          axi_rd_req_in_0<=1;

          axi_rd_req_size_1 <= axi_rd_req_size_reg - 1;
        end

        else begin
          axi_rd_addr_pretreat_stall<=0;
          axi_rd_req_in_0<=1;
          axi_rd_req_size_0<=axi_rd_req_size_reg;
        end
      end

      else begin
        axi_rd_req_in_0<=0;
        axi_rd_addr_pretreat_stall<=0;
      end
    end


    always @(posedge clk) begin
      if(reset)begin
        axi_rd_req_in_1<=0;
      end
      else if(axi_rd_addr_pretreat_stall)begin
        axi_rd_req_in_1<=1;
      end
      else begin
        axi_rd_req_in_1<=0;
      end
    end

  

//=======================================================s

  

  always @(posedge clk) begin
    if(reset)begin
      eight_bit_ldmem_state_q<=0;
    end
    else 
      eight_bit_ldmem_state_q<=eight_bit_ldmem_state_d;
  end


 always @(posedge clk) begin
   if(reset)begin
     sixteen_bit_mem_write_req<=0;
   end
   else if ((~choose_8bit)&&mem_write_data_pretreat_req) begin
       sixteen_bit_mem_write_req<=1;
       sixteen_bit_mem_write_data_in<=mem_write_data_pretreat;
     end
    else begin
      sixteen_bit_mem_write_req<=0;
    end
   end



   genvar  i;
      generate
        for(i=0;i<32;i=i+1)
        begin:EIGHT_BIT_RESULT_CALCULATE
        always@(posedge clk)begin
        if(eight_bit_write_ready)begin
          eight_bit_mem_write_data[(i*16+8) - 1: i*16] <= eight_bit_mem_write_data_L[i*8+8 - 1 : i*8];
          eight_bit_mem_write_data[(i+1)*16-1 : i*16+8] <= eight_bit_mem_write_data_H[i*8+8 - 1 : i*8];
        end
        end
        end
      endgenerate

      
  always @(*) begin
    eight_bit_ldmem_state_d=eight_bit_ldmem_state_q;
    case (eight_bit_ldmem_state_q)
     0 :  begin
       if(choose_8bit&&mem_write_data_pretreat_req)begin
         eight_bit_ldmem_state_d=1;
       end
     end
    1 :begin
      if(mem_write_data_pretreat_req)begin
      eight_bit_ldmem_state_d=0;
      end
    end 
    endcase
  end

//=====================================================edit by pxq timing optimize 1030
  always@(posedge clk) begin
    if(eight_bit_ldmem_state_d ==1&&eight_bit_ldmem_state_q == 0)begin
      eight_bit_mem_write_data_L<= mem_write_data_pretreat;
      eight_bit_write_ready<=0;
    end
    else if(eight_bit_ldmem_state_q==1&&eight_bit_ldmem_state_d == 0)begin
      eight_bit_write_ready <= 1;
      eight_bit_mem_write_data_H <= mem_write_data_pretreat;
    end
    else begin
      eight_bit_write_ready<=0;
    end
  end


  always @(posedge clk) begin
    eight_bit_write_ready_dly<=eight_bit_write_ready;
  end


always @(posedge clk) begin
  if(reset)begin
    eight_bit_write_buf_state_q<=0;
  end
  else begin
    eight_bit_write_buf_state_q<=eight_bit_write_buf_state_d;
  end
end


always @(*) begin
  eight_bit_write_buf_state_d=eight_bit_write_buf_state_q;
  case (eight_bit_write_buf_state_q)
    0 : begin
      if(eight_bit_write_ready_dly)begin
        eight_bit_write_buf_state_d=1;
      end
    end 
    1 :begin
      eight_bit_write_buf_state_d=0;
    end 
  endcase
  
end

always @(posedge clk) begin
  if(eight_bit_write_buf_state_d == 1)begin
    eight_bit_mem_write_req <= 1;
    eight_bit_mem_write_data_in <= eight_bit_mem_write_data [AXI_DATA_WIDTH - 1 : 0];
  end
  else if (eight_bit_write_buf_state_d == 0 && eight_bit_write_buf_state_q == 1)begin
    eight_bit_mem_write_req<=1;
    eight_bit_mem_write_data_in = eight_bit_mem_write_data [2*AXI_DATA_WIDTH -1 :AXI_DATA_WIDTH];
  end
  else begin
    eight_bit_mem_write_req<=0;
  end
end


assign mem_write_req_in = eight_bit_mem_write_req||sixteen_bit_mem_write_req;
assign  mem_write_data_in = sixteen_bit_mem_write_req? sixteen_bit_mem_write_data_in : eight_bit_mem_write_req ? eight_bit_mem_write_data_in : 0;


// assign mem_write_req_in = mem_write_req;
// assign  mem_write_data_in = mem_write_data;

  always @(posedge clk)
  begin
    if (reset)
      mem_write_addr <= 0;
    else begin
      if (mem_write_req_in)
        mem_write_addr <= mem_write_addr + 1'b1;
      else if (ldmem_state_q == LDMEM_DONE)
        mem_write_addr <= 0;
    end
  end

    assign tag_mem_write_addr = {ldmem_tag, mem_write_addr};





//=============================================================
// Loop controller
//=============================================================
  always@(posedge clk)
  begin
    if (reset)
      ld_loop_id_counter <= 'b0;
    else begin
      if (mws_ld_loop_iter_v)
        ld_loop_id_counter <= ld_loop_id_counter + 1'b1;
      else if (tag_req && tag_ready)
        ld_loop_id_counter <= 'b0;
    end
  end

  always @(posedge clk)
  begin
    if (reset)
      ld_iter_v_q <= 1'b0;
    else begin
      if (cfg_loop_iter_v && cfg_loop_iter_loop_id == 1 + MEM_ID)
        ld_iter_v_q <= 1'b1;
      else if (cfg_loop_iter_v || ld_stride_v)
        ld_iter_v_q <= 1'b0;
    end
  end


  //  assign mws_ld_start = ldmem_state_q == LDMEM_BUSY;
    assign mws_ld_loop_iter_v = ld_stride_v && ld_iter_v_q;
    assign mws_ld_loop_iter = iter_q;
    assign mws_ld_loop_iter_loop_id = ld_loop_id_counter;

  always @(posedge clk)
  begin
    if (reset) begin
      iter_q <= 'b0;
    end
    else if (cfg_loop_iter_v && cfg_loop_iter_loop_id == 1 + MEM_ID) begin
      iter_q <= cfg_loop_iter;
    end
  end

  controller_fsm #(
    .LOOP_ID_W                      ( LOOP_ID_W                      ),
    .LOOP_ITER_W                    ( LOOP_ITER_W                    ),
    .IMEM_ADDR_W                    ( LOOP_ID_W                      )
  ) mws_ld_ctrl (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .stall                          ( mws_ld_stall                   ), //input
    .cfg_loop_iter_v                ( mws_ld_loop_iter_v             ), //input
    .cfg_loop_iter                  ( mws_ld_loop_iter               ), //input
    .cfg_loop_iter_loop_id          ( mws_ld_loop_iter_loop_id       ), //input
    .start                          ( mws_ld_start                   ), //input
    .done                           ( mws_ld_done                    ), //output
    .loop_init                      ( mws_ld_init                    ), //output
    .loop_enter                     ( mws_ld_enter                   ), //output  
    .loop_last_iter                 (                                ), //output
    .loop_exit                      ( mws_ld_exit                    ), //output
    .loop_index                     ( mws_ld_index                   ), //output
    .loop_index_valid               ( mws_ld_index_valid             )  //output
  );
//=============================================================

//==============================================================================
// Memory Request generation
//==============================================================================
    assign ld_mem_req_v = cfg_mem_req_v && cfg_mem_req_loop_id == (1 + MEM_ID) && cfg_mem_req_type == MEM_LD && cfg_mem_req_id == MEM_ID;
  always @(posedge clk)
  begin
    if (reset) begin
      ld_req_size <= 'b0;
//      ld_req_loop_id <= 'b0;
    end
    else if (ld_mem_req_v) begin
      ld_req_size <= cfg_mem_req_size;
//      ld_req_loop_id <= ld_loop_id_counter;
    end
  end

  

    // input[ IBUF_DATA_WIDTH-1  : 0 ]                     i_data_adnn, //add for asr data write 2021-08-13 data
    // input[ IBUF_ADDR_WIDTH-1  : 0 ]                     i_add_adnn,  //add for asr data write 2021-08-13 add
    // input                                               i_valid_adnn,//add for asr data write 2021-08-13 req
    
    // input                                               i_is_run_adnn,//add for asr data write 2021-08-13 status
    // input                                               i_frame_adnn,//add for asr data write 2021-08-13  start
    // input                                               i_frame_data_ready_adnn,//add for asr data write 2021-08-13 finish
    
//===============================================================================  edit by pxq 0813  support audio

wire  [ AXI_DATA_WIDTH    -1 :0 ] mem_write_data_audio;
wire [MEM_ADDR_W           -1 : 0 ]      mem_write_addr_audio;
wire  mem_write_req_audio;
wire  [ TAG_MEM_ADDR_W       -1 : 0  ]        tag_mem_write_addr_audio;


// wire mem_write_req_in;
// wire [TAG_MEM_ADDR_W           -1 : 0 ] tag_mem_write_addr_in;
// wire [ AXI_DATA_WIDTH    -1 :0 ]  mem_write_data_in;



wire tag_init_done;
wire  ibuf_init_done;
wire ibuf_init_start;


reg  [ 4                    -1 : 0 ]        ibuf_init_state_d;
reg  [ 4                    -1 : 0 ]        ibuf_init_state_q;


//reg [8                    -1 : 0 ]   current_layer;

    localparam integer  IBUF_INIT_IDLE                   = 0;
    localparam integer  IBUF_INIT_BUSY              = 1;
    localparam integer  IBUF_INIT_DLY1                  = 2;
    localparam integer  IBUF_INIT_DLY2                 = 3;
    localparam integer  IBUF_INIT_DONE                = 4;
    localparam integer  IBUF_INIT_BUSY_BEFORE  = 5 ;
  

always @(posedge clk) begin
    if(reset)begin
      current_layer<='b0;
    end
    if(i_decoder_done)begin
      current_layer<='b0;
    end
    if(mws_ld_loop_iter_loop_id==0&&mws_ld_loop_iter_v)begin
      current_layer<=current_layer+1;
    end
end


assign mem_write_data_audio=i_data_adnn;
assign mem_write_addr_audio=i_add_adnn;
assign mem_write_req_audio=i_valid_adnn;
assign tag_mem_write_addr_audio={ldmem_tag,mem_write_addr_audio};




//assign tag_init_done=i_frame_data_ready_adnn==1;
assign mws_ld_start = (ldmem_state_q == LDMEM_BUSY&&current_layer!=1)||(ldmem_state_q==LDMEM_BUSY&&~i_is_run_adnn);  //edit by pxq 0810
assign ibuf_init_start=ldmem_state_q==LDMEM_BUSY&&current_layer==1&&i_is_run_adnn;//edit by pxq 0810
assign ibuf_init_done=ibuf_init_state_q==IBUF_INIT_DLY2;


  always @(*)
  begin
   ibuf_init_state_d = ibuf_init_state_q;
    case(ibuf_init_state_q)
      IBUF_INIT_IDLE: begin
        if (ibuf_init_start) begin
          ibuf_init_state_d=IBUF_INIT_BUSY_BEFORE;
        end
      end
      IBUF_INIT_BUSY: begin
        //if (tag_init_done)begin
        
          ibuf_init_state_d = IBUF_INIT_DONE;
        //end    
      end

      IBUF_INIT_DONE: begin
        ibuf_init_state_d = IBUF_INIT_DLY1;
      end

      IBUF_INIT_DLY1: begin
        ibuf_init_state_d = IBUF_INIT_DLY2;
      end

      IBUF_INIT_DLY2: begin
        ibuf_init_state_d = IBUF_INIT_IDLE;
      end

      IBUF_INIT_BUSY_BEFORE:begin
        ibuf_init_state_d=IBUF_INIT_BUSY;
      end
    endcase
  end


 always @(posedge clk)
  begin
    if (reset)
      ibuf_init_state_q <=IBUF_INIT_IDLE;
    else
      ibuf_init_state_q <= ibuf_init_state_d;
  end



// assign mem_write_req_in=mem_write_req||mem_write_req_1;
// assign tag_mem_write_addr_in=mem_write_req?tag_mem_write_addr:mem_write_req_1?tag_mem_write_addr_1:0;
// assign mem_write_data_in=mem_write_req?mem_write_data:mem_write_req_1?mem_write_data_1:0;

assign mem_write_req_in_0 = (current_layer==1||current_layer==0) ? (i_is_run_adnn? mem_write_req_audio:mem_write_fl_req_in ): mem_write_req_in;
assign mem_write_data_in_0 = (current_layer==1||current_layer==0) ? (i_is_run_adnn ? mem_write_data_audio : ddr2ibuf_in) : mem_write_data_in ;
assign tag_mem_write_addr_0 = (current_layer==1||current_layer==0) ? ( i_is_run_adnn ? tag_mem_write_addr_audio:tag_mem_write_fl_addr) : tag_mem_write_addr;
//================================================================================
//==============================================================================
// Tag-based synchronization for double buffering
//==============================================================================
    assign raw_stmem_tag = 0;

  always @(*)
  begin
    ldmem_state_d = ldmem_state_q;
    case(ldmem_state_q)
      LDMEM_IDLE: begin
        if (ldmem_tag_ready) begin
            ldmem_state_d = LDMEM_BUSY;
        end
      end
      LDMEM_BUSY: begin
        if (mws_ld_done||ibuf_init_done)
          ldmem_state_d = LDMEM_WAIT_0;
      end
      LDMEM_WAIT_0: begin
        if (axi_rd_done||(current_layer==1&&i_is_run_adnn))   //edit by pxq 0813
        ldmem_state_d = LDMEM_WAIT_1;
      end
      LDMEM_WAIT_1: begin
        ldmem_state_d = LDMEM_WAIT_4;
      end
      LDMEM_WAIT_4: begin
        ldmem_state_d = LDMEM_WAIT_5;
      end
      LDMEM_WAIT_5: begin
        ldmem_state_d = LDMEM_WAIT_6;
      end
      LDMEM_WAIT_6: begin
        ldmem_state_d = LDMEM_WAIT_7;
      end
      LDMEM_WAIT_7: begin
        ldmem_state_d = LDMEM_WAIT_8;
      end
      LDMEM_WAIT_8: begin
        ldmem_state_d = LDMEM_WAIT_2;
      end
      LDMEM_WAIT_2: begin
        if(fl_tile_init_done|| ~first_layer_sw )  
        ldmem_state_d = LDMEM_WAIT_3;
      end
      LDMEM_WAIT_3: begin
          ldmem_state_d = LDMEM_DONE;
      end
      LDMEM_DONE: begin
        ldmem_state_d = LDMEM_IDLE;
      end
    endcase
  end

  always @(posedge clk)
  begin
    if (reset)
      ldmem_state_q <= LDMEM_IDLE;
    else
      ldmem_state_q <= ldmem_state_d;
  end

  always @(*)
  begin
    stmem_state_d = stmem_state_q;
    case(stmem_state_q)
      STMEM_IDLE: begin
        if (stmem_tag_ready) begin
          stmem_state_d = STMEM_DONE;
        end
      end
      STMEM_DONE: begin
        stmem_state_d = STMEM_IDLE;
      end
    endcase
  end

  always @(posedge clk)
  begin
    if (reset)
      stmem_state_q <= STMEM_IDLE;
    else
      stmem_state_q <= stmem_state_d;
  end

    assign compute_tag_done = compute_done;
    assign compute_ready = compute_tag_ready;

    assign ldmem_tag_done = ldmem_state_q == LDMEM_DONE;
    assign ldmem_ready = ldmem_tag_ready;
  // assign ldmem_tag_done = mws_ld_done;

    assign stmem_tag_done = stmem_state_q == STMEM_DONE;

  tag_sync  #(
    .NUM_TAGS                       ( NUM_TAGS                       )
  )
  mws_tag (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .block_done                     ( block_done                     ),
    .tag_req                        ( tag_req                        ),
    .tag_reuse                      ( tag_reuse                      ),
    .tag_bias_prev_sw               ( tag_bias_prev_sw               ),
    .tag_ddr_pe_sw                  ( tag_ddr_pe_sw                  ), //input
    .tag_ready                      ( tag_ready                      ),
    .tag                            ( tag                            ),
    .tag_done                       ( tag_done                       ),
    .raw_stmem_tag                  ( raw_stmem_tag                  ),
    .raw_stmem_tag_ready            ( raw_stmem_tag_ready            ),
    .compute_tag_done               ( compute_tag_done               ),
    .compute_tag_ready              ( compute_tag_ready              ),
    .compute_bias_prev_sw           ( compute_bias_prev_sw           ),
    .compute_tag                    ( compute_tag                    ),
    .ldmem_tag_done                 ( ldmem_tag_done                 ),
    .ldmem_tag_ready                ( ldmem_tag_ready                ),
    .ldmem_tag                      ( ldmem_tag                      ),
    .stmem_ddr_pe_sw                ( stmem_ddr_pe_sw                ),
    .stmem_tag_done                 ( stmem_tag_done                 ),
    .stmem_tag_ready                ( stmem_tag_ready                ),
    .stmem_tag                      ( stmem_tag                      )
  );
//==============================================================================

  //   ibuf #(
  //   .TAG_W                          ( TAG_W                          ),
  //   .BUF_ADDR_WIDTH                 ( TAG_BUF_ADDR_W                 ),
  //   .ARRAY_N                        ( ARRAY_N                        ),
  //   .MEM_DATA_WIDTH                 ( AXI_DATA_WIDTH                 ),
  //   .DATA_WIDTH                     ( DATA_WIDTH                    )
  // ) buf_ram (
  //   .clk                            ( clk                            ),
  //   .reset                          ( reset                          ),
  //   .mem_write_addr                 ( tag_mem_write_addr_0             ),
  //   .mem_write_req                  ( mem_write_req_in_0                  ),
  //   .mem_write_data                 ( mem_write_data_in_0                 ),//edit by pxq 0816
  //   .buf_read_addr                  ( tag_buf_read_addr              ),
  //   .buf_read_req                   ( buf_read_req                   ),
  //   .buf_read_data                  ( _buf_read_data                 )
  // );


//==============================================================================
// AXI4 Memory Mapped interface
//==============================================================================
// assign mem_write_ready = ~(fl_stall && first_layer_sw&&);

//     assign mem_write_ready =~(i_is_run_adnn&&current_layer==1)||(current_layer>1)|| ~(fl_stall && first_layer_sw&&(~i_is_run_adnn));//edit by pxq 0813
//     assign mem_write_ready = (current_layer>1) ||  fl_stall&&first_layer_sw&&(~i_is_run_adnn) || ~ (i_is_run_adnn&&first_layer_sw)
    assign mem_write_ready = (current_layer>1) ? 1 : i_is_run_adnn? 0 : fl_stall ? 0 : 1;
    assign mem_read_ready = 1'b0;
    assign axi_rd_req_id = 0;
    assign mem_read_data = 0;
  axi_master #(
    .TX_SIZE_WIDTH                  ( MEM_REQ_W                      ),
    .AXI_DATA_WIDTH                 ( AXI_DATA_WIDTH                 ),
    .AXI_ADDR_WIDTH                 ( AXI_ADDR_WIDTH                 ),
    .AXI_BURST_WIDTH                ( AXI_BURST_WIDTH                )
  ) u_axi_mm_master (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .m_axi_awaddr                   ( mws_awaddr                     ),
    .m_axi_awlen                    ( mws_awlen                      ),
    .m_axi_awsize                   ( mws_awsize                     ),
    .m_axi_awburst                  ( mws_awburst                    ),
    .m_axi_awvalid                  ( mws_awvalid                    ),
    .m_axi_awready                  ( mws_awready                    ),
    .m_axi_wdata                    ( mws_wdata                      ),
    .m_axi_wstrb                    ( mws_wstrb                      ),
    .m_axi_wlast                    ( mws_wlast                      ),
    .m_axi_wvalid                   ( mws_wvalid                     ),
    .m_axi_wready                   ( mws_wready                     ),
    .m_axi_bresp                    ( mws_bresp                      ),
    .m_axi_bvalid                   ( mws_bvalid                     ),
    .m_axi_bready                   ( mws_bready                     ),
    .m_axi_araddr                   ( mws_araddr                     ),
    .m_axi_arid                     ( mws_arid                       ),
    .m_axi_arlen                    ( mws_arlen                      ),
    .m_axi_arsize                   ( mws_arsize                     ),
    .m_axi_arburst                  ( mws_arburst                    ),
    .m_axi_arvalid                  ( mws_arvalid                    ),
    .m_axi_arready                  ( mws_arready                    ),
    .m_axi_rdata                    ( mws_rdata                      ),
    .m_axi_rid                      ( mws_rid                        ),
    .m_axi_rresp                    ( mws_rresp                      ),
    .m_axi_rlast                    ( mws_rlast                      ),
    .m_axi_rvalid                   ( mws_rvalid                     ),
    .m_axi_rready                   ( mws_rready                     ),
    // Buffer
    .mem_write_id                   ( mem_write_id                   ),
    .mem_write_req                  ( mem_write_req                  ),
    .mem_write_data                 ( mem_write_data                 ),
    .mem_write_ready                ( mem_write_ready                ),
    .mem_read_data                  ( mem_read_data                 ),
    .mem_read_req                   ( mem_read_req               ),
    .mem_read_ready                 ( mem_read_ready           ),
    // AXI RD Req
    .rd_req_id                      ( axi_rd_req_id                  ),
    .rd_req                         ( axi_rd_req_in                     ),
    .rd_done                        ( axi_rd_done                    ),
    .rd_ready                       ( axi_rd_ready                   ),
    .rd_req_size                    ( axi_rd_req_size_in                ),
    .rd_addr                        ( axi_rd_addr_in                    ),
    // AXI WR Req
    .wr_req                         ( axi_wr_req               ),
    .wr_req_id                      ( axi_wr_req_id              ),
    .wr_ready                       ( axi_wr_ready               ),
    .wr_req_size                    ( axi_wr_req_size                ),
    .wr_addr                        ( axi_wr_addr                    ),
    .wr_done                        ( axi_wr_done               )
  );
//==============================================================================

`ifdef COCOTB_SIM
  integer req_count;
  always @(posedge clk)
  begin
    if (reset) req_count <= 0;
    else req_count = req_count + (tag_req && tag_ready);
  end
`endif //COCOTB_SIM
//==============================================================================
// Dual-port RAM
//==============================================================================
  
    assign tag_buf_read_addr = {compute_tag, buf_read_addr};

  register_sync #(BUF_DATA_WIDTH)
  buf_read_data_delay (clk, reset, _buf_read_data, buf_read_data);



//==============================================================================

`ifdef COCOTB_SIM
  integer wr_req_count=0;
  always @(posedge clk)
    if (reset)
      wr_req_count <= 0;
    else
      wr_req_count <= wr_req_count + axi_wr_req;

  integer rd_req_count=0;
  integer missed_rd_req_count=0;
  always @(posedge clk)
    if (reset)
      rd_req_count <= 0;
    else
      rd_req_count <= rd_req_count + axi_rd_req;
  always @(posedge clk)
    if (reset)
      missed_rd_req_count <= 0;
    else
      missed_rd_req_count <= missed_rd_req_count + (axi_rd_req && ~axi_rd_ready);
`endif


//=============================================================
// VCD
//=============================================================
`ifdef COCOTB_TOPLEVEL_mem_wrapper
initial begin
  $dumpfile("mem_wrapper.vcd");
  $dumpvars(0, mem_wrapper);
end
`endif
//=============================================================
endmodule
