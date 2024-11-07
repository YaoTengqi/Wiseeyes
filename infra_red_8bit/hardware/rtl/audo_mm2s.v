`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/15 14:06:36
// Design Name: 
// Module Name: audo_mm2s
// data in:ch0 hardware and audo; hardware size <=64MB; sigle ->fb;hardware->i_audo2ddr_base_hardware;
// data in:ch1 4Mic audo ->fb[0..1];->localacc_add;
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
//`define DOWNLOAD_HARDWARE_EN,fix len=8192*8 bit
//`define DOWNLOAD_HARDWARE_EN,fix len=8192*8 bit
//i_mm2s_base:must at the n*4k the first;for 00:3fff
//////////////////////////////////////////////////////////////////////////////////
module audo_mm2s #(
    parameter integer  AXI_ADDR_WIDTH               = 42,      
    parameter integer  AXI_ID_WIDTH                 = 1,  
    parameter integer  AXI_DATA_WIDTH               = 256 ,
    //parameter integer  MEM_DATA_WIDTH               = 256,
    parameter integer  LD_RDID                      = 'd0,
    //src
    parameter integer  AUDO_FB_CAP                  = 8192*8,
    parameter integer  MEM_ADDR_WIDTH               = AUDO_FB_CAP/AXI_DATA_WIDTH,                           
    parameter integer  RX_SIZE_WIDTH                = $clog2((1<<MEM_ADDR_WIDTH)*AXI_DATA_WIDTH/AXI_DATA_WIDTH)+1,
    //dst
    parameter integer  MAX_LENGTH_FROMDDR_B         = 1024*1024*32,
    parameter integer  MAX_LENGTH_FROMDDR_WIDTH     = $clog2(MAX_LENGTH_FROMDDR_B*8/AXI_DATA_WIDTH)
)
(
    input                                                   clk,
    input                                                   reset,
    
    // reg
    //bit0:to ddr en,bit1:en_pingpangbuf;b[3:2]:VDNN in: 00:none,01:n1ch,1X:audo from ddr;
    //b[5:4]:ADNN in: 00:none,01:n4ch,1X:audo from ddr;
   
    input                                                   i_start,   
    output                                                  o_done,   
    input  [AXI_ADDR_WIDTH-1:0]                             i_mm2s_base,//address base ab0   
    input  [MAX_LENGTH_FROMDDR_WIDTH-1:0]                   i_mm2s_leng,//data lengthe


    output  [MEM_ADDR_WIDTH-1:0]                            o_mem_wadd,
    //output  [AXI_DATA_WIDTH-1:0]                            o_mem_wdata,
    output                                                  o_mem_wreq,
    output                                                  o_frame_start,
    //**************************************************
        // mm2s
    output  [ AXI_ID_WIDTH         -1 : 0 ]                 o_mm2s_req_id,
    output  [ RX_SIZE_WIDTH        -1 : 0 ]                 o_mm2s_size,
    output  [AXI_ADDR_WIDTH-1:0]                            o_mm2s_addr,
    output                                                  o_mm2s_addr_req,
    input                                                   i_mm2s_done,
    input                                                   i_mm2s_addr_ready,
    
    input  [ AXI_ID_WIDTH         -1 : 0 ]                  i_mm2s_get_id,
    //input  [AXI_DATA_WIDTH-1:0]                             i_mm2s_data,
    input                                                   i_mm2s_data_req,
    output                                                  o_mm2s_data_ready,    
    //
    input                                                   i_DNN_IDLE 
    );
     //单次读取轮数，最大256，
   localparam   M_1READ_LEN                                 =256;// (1<<MEM_ADDR_WIDTH)*8/AXI_DATA_WIDTH;//AUDO_FB_CAP/AXI_DATA_WIDTH;   
   //localparam   M_RADD_ADJUST                               = $clog2(M_1READ_LEN*AXI_DATA_WIDTH/8); 
   localparam   M_RADD_ADJUST                               = $clog2(AXI_DATA_WIDTH/8);
   //localparam   M_1READ_LEN                                 = 2;
  // localparam   CNT_WIDTH                                   =$clog2(M_1READ_LEN);
   
  
  
   localparam   S_IDLE                                      =4'b0000;
   localparam   S_ADD_T                                     =4'b0001;
   localparam   S_DATA_T                                    =4'b0010;
   localparam   S_PAGE_T                                    =4'b0100;
   localparam   S_DONE_T                                    =4'b1000;
   reg [3:0]                                                r_rstat_q;
    //reg  [MEM_DATA_WIDTH-1:0]                               r_wdata;
   //assign 
   reg [MAX_LENGTH_FROMDDR_WIDTH-1:0]                       r_read_cnt;
   wire [MAX_LENGTH_FROMDDR_WIDTH+M_RADD_ADJUST-1:0]         w_read_cnt_adj;
   reg [1:0]                                                 r_start;
   //reg                                                      busy;
   //wire                                                     w_start_posedge;
   wire                                                     w_mm2s_data_transmit_one_ok;
   
   //reg [MAX_LENGTH_FROMDDR_WIDTH-1:0]                       r_len;            
   //reg                                                      r_start_ok;
   //reg                                                      r_mm2s_addr_req;
   reg [1:0]                                             r_check_done_shr;
   wire                                                  w_mm2s_done_posedge;
   
   wire                                                  w_r_start_is_S_IDLE;
   
   wire                                                  w_mem_wr_valid;
   
   //m_axi
   assign      o_mm2s_data_ready    =     r_rstat_q[1];
   assign      o_mm2s_size          =     M_1READ_LEN;  
   assign      o_mm2s_addr          =     w_read_cnt_adj+i_mm2s_base;  
   assign      o_mm2s_req_id        =     LD_RDID;
   
   assign      o_mm2s_addr_req      =     r_rstat_q[0];
   // host if
   //assign      o_done               =     r_rstat_q[3];
   assign      o_done               =     w_r_start_is_S_IDLE && r_start[1]&& r_start[0] && i_start;
   //rxd 1data flag;
   assign      w_mm2s_data_transmit_one_ok     =  o_mm2s_data_ready && i_mm2s_data_req && (LD_RDID ==i_mm2s_get_id);   
   // r_start == S_IDLE
   assign      w_r_start_is_S_IDLE             =      !(|r_rstat_q);
   //reg []
   always @(posedge clk)  begin
        if(reset)     r_start  <=   'd0;
         else         r_start  <=   {r_start[0],i_start};        
         end
   //page
//   always @(posedge clk)  begin
//        if(reset)                     r_len  <=   'd0;
//        //r_rstat_q ==S_IDLE
//        else if(w_r_start_is_S_IDLE)  r_len  <=   'd0;
//        ////r_rstat_q ==S_PAGE_T
//         else if(r_rstat_q[2])        r_len  <=   r_len + M_1READ_LEN*AXI_DATA_WIDTH/8; 
//         else                         r_len  <=   r_len;
//         end
         
   always @(posedge clk)  r_check_done_shr    <=  {r_check_done_shr[0],i_mm2s_done};
   assign   w_mm2s_done_posedge     =   (!r_check_done_shr[1])&&(!r_check_done_shr[0])&&i_mm2s_done;
   //1 FSM
   always @(posedge clk)begin
      if(reset) r_rstat_q <= S_IDLE;
      //else if(r_start[1] == 'd0)
      else begin 
        //r_rstat_q  <= r_rstat_q;
        case (r_rstat_q)//011
          S_IDLE:if((!r_start[1])&&r_start[0]&&i_start )    r_rstat_q  <= S_ADD_T;
          S_ADD_T:if(i_mm2s_addr_ready && o_mm2s_addr_req)  r_rstat_q  <= S_DATA_T;
          S_DATA_T:if(w_mm2s_done_posedge)                  r_rstat_q  <= S_PAGE_T;
          S_PAGE_T:if(  w_read_cnt_adj >=  i_mm2s_leng) 
                                                            r_rstat_q  <= S_DONE_T;
                     else   if(i_DNN_IDLE)                  r_rstat_q  <= S_ADD_T;
          //S_DONE_T:                              r_rstat_q  <= S_IDLE;
          default:                                          r_rstat_q  <= S_IDLE;
        endcase 
      end
   
   end
   
   always @(posedge clk)begin
         if(reset)                                        r_read_cnt <='d0;
         else if(w_r_start_is_S_IDLE)                     r_read_cnt <='d0;
         else if(w_mm2s_data_transmit_one_ok)             r_read_cnt <='d1 + r_read_cnt;  
         else                                             r_read_cnt <= r_read_cnt;
   end 
  assign  w_read_cnt_adj         =  r_read_cnt<<M_RADD_ADJUST;
  assign  w_mem_wr_valid          =  w_read_cnt_adj <  i_mm2s_leng? 1 : 0;

   //***********************************************************************************
   assign      o_mem_wreq         =    w_mm2s_data_transmit_one_ok && w_mem_wr_valid;
   //assign      o_mem_wdata      =    i_mm2s_data;
   assign      o_mem_wadd         =    r_read_cnt[MEM_ADDR_WIDTH-1:0];
   assign      o_frame_start      =    w_r_start_is_S_IDLE&&(!r_start[1])&&r_start[0]&&i_start;   
endmodule
