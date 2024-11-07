`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/17 12:47:23
// Design Name: 
// Module Name: audo_dma
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
// MEM : dma dest buf；
//
//////////////////////////////////////////////////////////////////////////////////
module icash_dma #(
    parameter integer  AXI_ADDR_WIDTH               = 42, 
   // parameter integer  IN_DATA_WIDTH                = 64,

    parameter integer  TX_SIZE_WIDTH                = 8,     
    parameter integer  AXI_DATA_WIDTH               = 256, 
    parameter integer  AXI_BURST_WIDTH              = 8,
    parameter integer  BURST_LEN                    = 1 << AXI_BURST_WIDTH,
    parameter integer  MEM_ID                       = 0,
    parameter integer  AXI_ARID                     = MEM_ID,
    parameter integer  AXI_RID                      = MEM_ID,
    parameter integer  AXI_AWID                     = MEM_ID,    
    
    parameter integer  MEM_ADDR_W                   = 11,
    parameter integer  MEM_DATA_W                   = AXI_DATA_WIDTH,
    parameter integer  AXI_SUPPORTS_WRITE           = 1,
    parameter integer  AXI_SUPPORTS_READ            = 1,    
    parameter integer  C_OFFSET_WIDTH               = AXI_ADDR_WIDTH < 16 ? AXI_ADDR_WIDTH - 1 : 16,
    parameter integer  WSTRB_W                      = AXI_DATA_WIDTH/8,
    parameter integer  AXI_ID_WIDTH                 = 1,    
   // parameter integer  HARDWARE_S2MM_EN             = 0,
    //audo dnn from ddr max leng
    parameter integer  MAX_LENGTH_FROMDDR_B         = 1024*32,
    parameter integer  MAX_LENGTH_FROMDDR_WIDTH     = $clog2(MAX_LENGTH_FROMDDR_B)
)
( //golble
    input                                           clk,
    input                                           reset,
  
    //to nxt memory
    output  [MEM_ADDR_W-1:0]                        o_mem_wadd,
    output  [AXI_DATA_WIDTH-1:0]                    o_mem_wdata,
    output                                          o_mem_wreq,
    output                                          o_mem_lock,
    //**************************************************
    // Master Interface Write Address
    output   [ AXI_ADDR_WIDTH       -1 : 0 ]        o_m_axi_awaddr,
    output   [ AXI_BURST_WIDTH      -1 : 0 ]        o_m_axi_awlen,
    output   [ 3                    -1 : 0 ]        o_m_axi_awsize,
    output   [ 2                    -1 : 0 ]        o_m_axi_awburst,
    output                                          o_m_axi_awvalid,
    input                                           i_m_axi_awready,
    // Master Interface Write Data
    output   [ AXI_DATA_WIDTH       -1 : 0 ]        o_m_axi_wdata,
    output   [ WSTRB_W              -1 : 0 ]        o_m_axi_wstrb,
    output                                          o_m_axi_wlast,
    output                                          o_m_axi_wvalid,
    input                                           i_m_axi_wready,
    // Master Interface Write Response
    input    [ 2                    -1 : 0 ]        i_m_axi_bresp,
    input                                           i_m_axi_bvalid,
    output                                          o_m_axi_bready,
    // Master Interface Read Address
    output   [ AXI_ID_WIDTH         -1 : 0 ]        o_m_axi_arid,
    output   [ AXI_ADDR_WIDTH       -1 : 0 ]        o_m_axi_araddr,
    output   [ AXI_BURST_WIDTH      -1 : 0 ]        o_m_axi_arlen,
    output   [ 3                    -1 : 0 ]        o_m_axi_arsize,
    output   [ 2                    -1 : 0 ]        o_m_axi_arburst,
    output                                          o_m_axi_arvalid,
    input                                           i_m_axi_arready,
    // Master Interface Read Data
    input    [ AXI_ID_WIDTH         -1 : 0 ]        i_m_axi_rid,
    input    [ AXI_DATA_WIDTH       -1 : 0 ]        i_m_axi_rdata,
    input    [ 2                    -1 : 0 ]        i_m_axi_rresp,
    input                                           i_m_axi_rlast,
    input                                           i_m_axi_rvalid,
    output                                          o_m_axi_rready,
    //host ctrl
        //bit0:to ddr en;b1:DNN in: 0:local,1:from ddr;
    
    input  [1:0]                                     i_ctl,
    input  [AXI_ADDR_WIDTH-1:0]                      i_mm2s_vddn_ddrbase,//address base ab0
    input  [MAX_LENGTH_FROMDDR_WIDTH-1:0]            i_mm2s_vddn_leng,//data lengthe
    input  [AXI_ADDR_WIDTH-1:0]                      i_mm2s_addn_ddrbase,//address base ab0
    input  [MAX_LENGTH_FROMDDR_WIDTH-1:0]            i_mm2s_addn_leng,//data lengthe
   // output                                           o_s2mm_int_posedge,
    //output                                           o_mm2s_int_posedge,
    //output                                           o_hdware_int_posedge,
    input                                           i_DNN_IDLE,
    output                                          o_done,
    // status={busying,o_cash_ready,o_cur_vdnnh_annl}
    // status={01X} is run,other is err or stop        
    output                                          busying,
    output                                          o_cash_ready,
    output                                          o_cur_vdnnh_annl
    
    
    );
    //
    localparam   mm2s_RX_SIZE_WIDTH                = $clog2((1<<MEM_ADDR_W)*MEM_DATA_W/AXI_DATA_WIDTH)+1;
    localparam   MEM_REQ_W                         = MEM_ADDR_W;
    
    localparam   MM2S_DATA_RSIZE                   =$clog2(MEM_DATA_W/8);
    wire                                        w_mm2s_en,w_vdnnh_annl;
    
    
    reg [1:0]                                        r_mm2s_en_check_shr;
    reg                                              r_cur_vdnnh_annl,r_cur_vdnnh_annl0;
    reg [1:0]                                        r_vdnnh_annl_check_shr;  
    wire                                             w_mm2s_event,w_vdnnh_annl_posedge,w_vdnnh_annl_negedge; //posedge and nosedge
    wire                                             w_mm2s_en_posedge;
    reg                                              r_do1task;
    wire                                             w_do1task_mm2s_en;
    reg                                              r_cash_ready ='d0;
    //axi
    wire                                        w_mm2s_rd_req;
    wire [ AXI_ID_WIDTH         -1 : 0 ]        w_mm2s_rd_req_id;
    wire                                        w_mm2s_rd_done;
    wire [ mm2s_RX_SIZE_WIDTH  -1 : 0 ]         w_mm2s_rd_req_size;
    wire                                        w_mm2s_rd_ready;
    wire [ AXI_ADDR_WIDTH       -1 : 0 ]        w_mm2s_rd_addr;
    //
    wire                                        mem_write_req;
    //wire [ AXI_DATA_WIDTH       -1 : 0 ]        mem_write_data;
   
    wire                                        mem_write_ready;
    wire [ AXI_ID_WIDTH         -1 : 0 ]        mem_write_id;
    
      

   
//to ddr s2mm
        wire  [ TX_SIZE_WIDTH        -1 : 0 ]                 w_s2mm_size;
        wire  [AXI_ADDR_WIDTH-1:0]                            w_s2mm_addr;
        wire                                                  w_s2mm_addr_req;
        wire                                                  w_s2mm_addr_done;
        wire                                                  w_s2mm_addr_ready;
        
        wire  [AXI_DATA_WIDTH-1:0]                            w_s2mm_data;
        wire                                                  w_s2mm_data_req;
        wire                                                  w_s2mm_data_ready;       
   //from ddr

    wire                                           w_s2mm_done;
    wire                                           w_s2mm_int_posedge;
    
    wire  [AXI_ADDR_WIDTH-1:0]                      w_mm2s_ddn_ddrbase;//address base ab0
    wire  [MAX_LENGTH_FROMDDR_WIDTH-1:0]            w_mm2s_ddn_leng;//data lengthe
    
   assign o_m_axi_arsize          =MM2S_DATA_RSIZE;
    
   assign {w_mm2s_en,w_vdnnh_annl}  = i_ctl;
   //check hdware get leng and base
   assign w_mm2s_ddn_ddrbase = w_vdnnh_annl?i_mm2s_vddn_ddrbase : i_mm2s_addn_ddrbase;
   assign w_mm2s_ddn_leng    = w_vdnnh_annl?i_mm2s_vddn_leng    : i_mm2s_addn_leng;
  //int
   //assign o_mm2s_int_posedge     = w_vdnnh_annl && o_done;
 //  assign o_s2mm_int_posedge     = i_mm2s_vddn_leng && w_mm2s_en;
   //assign o_s2mm_int_posedge     = w_mm2s_en  && w_s2mm_data_ready && w_s2mm_addr_done;
   //data to 256 bit;
  always @(posedge clk)begin
  if(reset)                  r_cur_vdnnh_annl  <= 'd0;
   else if(r_cash_ready)     r_cur_vdnnh_annl  <= r_cur_vdnnh_annl0;
   else                      r_cur_vdnnh_annl  <= r_cur_vdnnh_annl;
end
  assign    o_cur_vdnnh_annl       = r_cur_vdnnh_annl;
  always @(posedge clk)begin
  if(reset)                  r_cur_vdnnh_annl0  <= 'd0;
   else if(w_mm2s_event)     r_cur_vdnnh_annl0   <= w_vdnnh_annl;
   else                      r_cur_vdnnh_annl0   <= r_cur_vdnnh_annl0;
end
  always @(posedge clk)begin
  if(reset) r_mm2s_en_check_shr  <= 'd0;
   else     r_mm2s_en_check_shr  <= w_mm2s_en;
end
  assign w_mm2s_en_posedge     = (!r_mm2s_en_check_shr)&& w_mm2s_en;
  //assign busying               = w_do1task_mm2s_en;
  assign busying               = w_mm2s_event||r_do1task;
always @(posedge clk)begin
  if(reset) r_vdnnh_annl_check_shr <= 'd0;
   else r_vdnnh_annl_check_shr  <= {r_vdnnh_annl_check_shr[0],w_vdnnh_annl};
end
   assign w_vdnnh_annl_posedge  = (!r_vdnnh_annl_check_shr[1])&&(r_vdnnh_annl_check_shr[0])&& w_vdnnh_annl;
   assign w_vdnnh_annl_negedge  = r_vdnnh_annl_check_shr[1]&&r_vdnnh_annl_check_shr[0]&& (!w_vdnnh_annl);
   assign w_mm2s_event    = (w_vdnnh_annl_posedge||w_vdnnh_annl_negedge||w_mm2s_en_posedge)&&w_mm2s_en;
  always@(posedge clk)begin
        if(reset)                        r_do1task <='d0;
           else   if(w_mm2s_event)       r_do1task <='d1;
           else if(o_done)               r_do1task <='d0;
  end
  always@(posedge clk)begin
        if(reset)                        r_cash_ready <='d0;
           else   if(w_mm2s_event)       r_cash_ready <='d0;
           else if(o_done)               r_cash_ready <='d1;
  end
 assign o_cash_ready   = r_cash_ready;
 
 assign w_do1task_mm2s_en = r_do1task && i_DNN_IDLE;
 
 assign o_mem_lock        = ~w_do1task_mm2s_en;
 //out to dnn 
 //from ddr  (mm2s)
   // wire                                       w_start;

          
  audo_mm2s #(
  .MAX_LENGTH_FROMDDR_B(MAX_LENGTH_FROMDDR_B                ),
  .MAX_LENGTH_FROMDDR_WIDTH(MAX_LENGTH_FROMDDR_WIDTH        ),
  .AXI_DATA_WIDTH(        AXI_DATA_WIDTH                    ),
  .LD_RDID(               AXI_ARID                          ),
  .MEM_ADDR_WIDTH(        MEM_ADDR_W                        ),
  .RX_SIZE_WIDTH(         mm2s_RX_SIZE_WIDTH                )
  )u0_audo_mm2s 
  (
    .clk(                clk                                 ),
    .reset(              reset                               ),
  
    .i_start(            w_do1task_mm2s_en                   ),   
    .o_done(             o_done                              ),   
    .i_mm2s_base(        w_mm2s_ddn_ddrbase                 ),//address base ab0    
    .i_mm2s_leng(        w_mm2s_ddn_leng                    ),
    .o_mem_wadd(         o_mem_wadd                         ),
    //.o_mem_wdata(        o_mem_wdata                        ),
    .o_mem_wreq(         o_mem_wreq                         ),

     // mm2s
    .o_mm2s_req_id(        w_mm2s_rd_req_id                  ),
    .o_mm2s_size(          w_mm2s_rd_req_size                ),
    .o_mm2s_addr(          w_mm2s_rd_addr                    ),
    .o_mm2s_addr_req(      w_mm2s_rd_req                     ),
    .i_mm2s_done(          w_mm2s_rd_done                    ),
    .i_mm2s_addr_ready(    w_mm2s_rd_ready                   ),
    
    .i_mm2s_get_id(        mem_write_id                      ),
    //.i_mm2s_data(          mem_write_data                    ),
    .i_mm2s_data_req(      mem_write_req                     ),
    .o_mm2s_data_ready(	   mem_write_ready       			 ),
    
    .i_DNN_IDLE(           i_DNN_IDLE                        )  
  );
  
 //m_axi_if
 axi_master #(
    .TX_SIZE_WIDTH                  ( TX_SIZE_WIDTH                  ),
    .RX_SIZE_WIDTH                  ( mm2s_RX_SIZE_WIDTH             ),
    .AXI_DATA_WIDTH                 ( AXI_DATA_WIDTH                 ),
    .AXI_ADDR_WIDTH                 ( AXI_ADDR_WIDTH                 ),
    .AXI_BURST_WIDTH                ( AXI_BURST_WIDTH                )
  ) u_axi_mm_master (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .m_axi_awaddr                   ( o_m_axi_awaddr                 ),
    .m_axi_awlen                    ( o_m_axi_awlen                      ),
    .m_axi_awsize                   ( o_m_axi_awsize                     ),
    .m_axi_awburst                  ( o_m_axi_awburst                    ),
    .m_axi_awvalid                  ( o_m_axi_awvalid                    ),
    .m_axi_awready                  ( i_m_axi_awready                    ),
    .m_axi_wdata                    ( o_m_axi_wdata                      ),
    .m_axi_wstrb                    ( o_m_axi_wstrb                      ),
    .m_axi_wlast                    ( o_m_axi_wlast                      ),
    .m_axi_wvalid                   ( o_m_axi_wvalid                     ),
    .m_axi_wready                   ( i_m_axi_wready                     ),
    .m_axi_bresp                    ( i_m_axi_bresp                      ),
    .m_axi_bvalid                   ( i_m_axi_bvalid                     ),
    .m_axi_bready                   ( o_m_axi_bready                     ),
    .m_axi_araddr                   ( o_m_axi_araddr                     ),
    .m_axi_arid                     ( o_m_axi_arid                       ),
    .m_axi_arlen                    ( o_m_axi_arlen                      ),
    .m_axi_arsize                   ( /*o_m_axi_arsize*/                     ),
    .m_axi_arburst                  ( o_m_axi_arburst                    ),
    .m_axi_arvalid                  ( o_m_axi_arvalid                    ),
    .m_axi_arready                  ( i_m_axi_arready                    ),
    .m_axi_rdata                    ( i_m_axi_rdata                      ),
    .m_axi_rid                      ( i_m_axi_rid                        ),
    .m_axi_rresp                    ( i_m_axi_rresp                      ),
    .m_axi_rlast                    ( i_m_axi_rlast                      ),
    .m_axi_rvalid                   ( i_m_axi_rvalid                     ),
    .m_axi_rready                   ( o_m_axi_rready                     ),
    //from  ddr to local mem
    .mem_write_id                   ( mem_write_id                      ),
    .mem_write_req                  ( mem_write_req                     ),
    .mem_write_data                 ( o_mem_wdata                       ),
    .mem_write_ready                ( mem_write_ready                   ),

    .rd_req_id                      ( w_mm2s_rd_req_id                  ),
    .rd_req                         ( w_mm2s_rd_req                     ),
    .rd_done                        ( w_mm2s_rd_done                    ),
    .rd_ready                       ( w_mm2s_rd_ready                   ),
    .rd_req_size                    ( w_mm2s_rd_req_size                ),
    .rd_addr                        ( w_mm2s_rd_addr                    ),
    // from local mem to ddr
    //
    .mem_read_data                  ( w_s2mm_data                      ),
    .mem_read_req                   ( w_s2mm_data_req                  ),
    .mem_read_ready                 ( w_s2mm_data_ready                ),
        
    .wr_req                         (  w_s2mm_addr_ready               ),
    .wr_req_id                      (  /*w_s2mm_wr_req_id*/AXI_AWID    ),
    .wr_ready                       (  w_s2mm_addr_req                 ),
    .wr_req_size                    (  w_s2mm_size                     ),
    .wr_addr                        (  w_s2mm_addr                     ),
    .wr_done                        (  w_s2mm_addr_done                )
  );
 

endmodule
