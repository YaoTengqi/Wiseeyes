`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/15 14:06:36
// Design Name: 
// Module Name: audo_s2mm
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
//////////////////////////////////////////////////////////////////////////////////
module audo_s2mm #(
    parameter integer  AXI_ADDR_WIDTH               = 42, 
    parameter integer  IN_DATA_WIDTH                = 64,
    parameter          MAX_HARDWARE_SIZE            = 64*1024*1024,
    parameter integer  TX_SIZE_WIDTH                = 8,     
    parameter integer  AXI_DATA_WIDTH               = 256,
    parameter integer  AUDO_DDRBUF_SIZE_B             = 1024*8                           
     
)
(
    input                                                   clk,
    input                                                   reset,
    
    // reg
    //bit0:to ddr en,bit1:en_pingpangbuf;b[3:2]:VDNN in: 00:none,01:n1ch,1X:audo from ddr;
    //b[5:4]:ADNN in: 00:none,01:n4ch,1X:audo from ddr;
   
    input                                                  i_s2mm_en,  
    output                                                 o_page_done, 
    
    input  [AXI_ADDR_WIDTH-1:0]                             i_s2mm_base,//address base ab0    
    input  [AXI_ADDR_WIDTH-1:0]                             i_s2mm_base_hardware,//address base hardware
    //audo if                                                   
    input                                                   i_is_hardware,         // hardware 
    input                                                   i_de,               //   
    input  [IN_DATA_WIDTH-1:0]                              i_data,
   // input                                                 i_de_n1ch,               //   
 //   input  [AUDO_WIDTH-1:0]                               i_data_n1ch,
   // to camif    
    //to local memory

   // output  [AXI_ADDR_WIDTH-1:0]                            o_mem_wadd_n1ch,
  //  output  [AXI_DATA_WIDTH-1:0]                            o_mem_wdata_n1ch,
  //  output                                                  o_mem_wreq_n1ch,
    
//    output  [AXI_ADDR_WIDTH-1:0]                            o_mem_wadd,
//    output  [AXI_DATA_WIDTH-1:0]                            o_mem_wdata,
//    output                                                  o_mem_wreq,
    //**************************************************
        // s2mm
    output  [ TX_SIZE_WIDTH        -1 : 0 ]                 o_s2mm_size,
    output  [AXI_ADDR_WIDTH-1:0]                            o_s2mm_addr,
    input                                                   i_s2mm_addr_req,
    input                                                   i_s2mm_done,
    output                                                  o_s2mm_addr_ready,
    
    
    output  [AXI_DATA_WIDTH-1:0]                            o_s2mm_data,
    input                                                   i_s2mm_data_req,
    output                                                  o_s2mm_data_ready,
    
    input                                                   i_s2mm_data_done
    );
   localparam   M_AXI_AWLEN                                 = 32;   
   localparam   CNT_WIDTH                                   =$clog2(AXI_DATA_WIDTH/IN_DATA_WIDTH);   
   localparam   OBUF_CNT_WIDTH                              =$clog2(M_AXI_AWLEN);   
   localparam   DDRBASE_GEN_WIDTH                           =$clog2(AUDO_DDRBUF_SIZE_B*8/M_AXI_AWLEN/AXI_DATA_WIDTH);
   
    localparam   DDR_PAGR_ADD                               =$clog2(M_AXI_AWLEN*AXI_DATA_WIDTH/8);  
    wire   [AXI_DATA_WIDTH-1:0]                            w_data;
    //reg   [CNT_WIDTH-1:0]         r_dotbuf_write_cnt;

    reg [AXI_DATA_WIDTH-1:0]                               r_out_buf[0:M_AXI_AWLEN-1];
    //more 1bit
    reg [OBUF_CNT_WIDTH:0]                                 r_out_buf_write_cnt='d0;
    reg [OBUF_CNT_WIDTH:0]                                 r_out_buf_read_cnt ='d0;
   
   //reg                                                      r_ptr_cnt;
   //reg  [7:0]                                               r_prt_ctl; //bit0:en,bit1:en_pingpangbuf:
   //reg  [AXI_ADDR_WIDTH-1:0]                                r_s2mm_addr; 
   reg  [DDRBASE_GEN_WIDTH-1:0]                             r_audo_ddr_page_addr;
   //reg                                                        r_audo_ddr_page_addr;
   reg                                                      r_half_page_shr;
   reg                                                      r_is_hardware;
   wire                                                     w_hardware_start;
   wire                                                     w_hardware_end;
   wire                                                     w_s2mm_ctlen;
   
   
   wire                                                     w_de;
   //reg                                                      r_dot_2obuf_en;
   //wire                                                     w_dot_2obuf_en;
   wire                                                     w_wr_outbuf_req;
   
   wire                                                     w_s2mm_en_posedge;
   wire                                                     w_s2mm_en;
   reg                                                      r_s2mm_en_shr ='d0;
   
   reg                                                      r_mem_read_req; //outbuf
   reg  [AXI_DATA_WIDTH-1:0]                                r_mem_read_data;

   
   //reg   [11:0]                                            r_dot_buf_cnt0,r_dot_buf_cnt; 

   wire                                                      w_s2mm_data_transmit_one_ok;
   
   reg [1:0]                                             r_check_done_shr;
   wire                                                  w_s2mm_done_posedge;
   //wire                                                      	

    assign            w_s2mm_ctlen    				         = i_s2mm_en;

    assign            o_s2mm_addr_ready                         = w_s2mm_en_posedge;
    assign            w_s2mm_en_posedge                          = w_s2mm_ctlen && w_s2mm_en && (!r_s2mm_en_shr);
   

    //assign            o_s2mm_addr                               = i_is_hardware?r_s2mm_addr:{i_s2mm_base[AXI_ADDR_WIDTH-1:DDR_PAGR_ADD+DDRBASE_GEN_WIDTH],r_audo_ddr_page_addr,i_s2mm_base[DDR_PAGR_ADD-1:0]}; 
    assign            o_s2mm_addr                               = {i_s2mm_base[AXI_ADDR_WIDTH-1:DDR_PAGR_ADD+DDRBASE_GEN_WIDTH],r_audo_ddr_page_addr,i_s2mm_base[DDR_PAGR_ADD-1:0]};
    assign            o_s2mm_size                               = M_AXI_AWLEN; 
    assign            o_s2mm_data                               = r_mem_read_req? r_mem_read_data:'d0;
    assign            o_s2mm_data_ready                         = r_mem_read_req&&w_s2mm_ctlen&&(!o_s2mm_addr_ready);
    assign            w_de                                       = i_de;
    
    assign            w_s2mm_data_transmit_one_ok               = o_s2mm_data_ready & i_s2mm_data_req;

    //assign            o_page_done                               = r_audo_ddr_page_addr[1];
    //--adjust 1/2 intreupt
   assign            o_page_done                               =  r_half_page_shr ^r_audo_ddr_page_addr[DDRBASE_GEN_WIDTH-1];
    //assign            w_dot_2obuf_en            =  w_s2mm_ctlen && (&r_dotbuf_write_cnt); 
    //always @(posedge clk) r_dot_2obuf_en <= w_dot_2obuf_en;    
   // assign            w_dot_2obuf_en_posedge    =  (!r_dot_2obuf_en)&&w_dot_2obuf_en;
    //reg               w_outbuf_wr_over;   
       
    assign            w_s2mm_en                 = r_out_buf_write_cnt[OBUF_CNT_WIDTH];// (w_outbuf_wr_over ^r_out_buf_write_cnt[OBUF_CNT_WIDTH])&&(r_out_buf_write_cnt[OBUF_CNT_WIDTH-1:0]==0);//r_out_buf_write_cnt>=M_AXI_AWLEN-1;//||(r_out_buf_read_cnt!=M_AXI_AWLEN-1);
    
    
    
    always @(posedge clk) r_is_hardware <= i_is_hardware;    
    assign   w_hardware_start    =(!r_is_hardware) && i_is_hardware;
    assign   w_hardware_end      =(r_is_hardware) && (!i_is_hardware);
       
    always @(posedge clk)  r_check_done_shr    <=  {r_check_done_shr[0],i_s2mm_done};
    assign   w_s2mm_done_posedge     =   (!r_check_done_shr[1])&&(!r_check_done_shr[0])&& i_s2mm_done;
   always@(posedge clk)begin
   if(reset)                                      r_audo_ddr_page_addr    <= 'd0;
   else if(w_hardware_start||w_hardware_end)      r_audo_ddr_page_addr    <= 'd0;
   else if(w_s2mm_done_posedge)                   r_audo_ddr_page_addr    <= r_audo_ddr_page_addr +1;
   else                                           r_audo_ddr_page_addr    <= r_audo_ddr_page_addr;
   end
   always@(posedge clk)begin
       if(reset)                                      r_half_page_shr    <= 'd0;
       else if(w_hardware_start||w_hardware_end)      r_half_page_shr    <= 'd0;       
       else                                           r_half_page_shr    <= r_audo_ddr_page_addr[DDRBASE_GEN_WIDTH-1];
       end
   
   //to 256
 generate 
  if(AXI_DATA_WIDTH/IN_DATA_WIDTH >1)begin
 fifo_16to256 #(
 .IN_WIDTH(IN_DATA_WIDTH)
 ) u_fifo_64to256(
 .clk(clk),
 .reset(reset),
 .clr('d0),
 .force_out('d0),
 .i_wr_req(i_de),
 .i_data(i_data),
 
 //out
 .o_rd_req(w_wr_outbuf_req),
 .o_data(w_data)
 );
 end
 else begin
 assign w_wr_outbuf_req = i_de;
 assign w_data          = i_data;
 end
endgenerate
    //*********************************************************************************
    //to outbuf


   
     always @(posedge clk)begin
       if(w_wr_outbuf_req) 
          r_out_buf[r_out_buf_write_cnt[OBUF_CNT_WIDTH-1:0]]   <= w_data;       
       end
    always @(posedge clk) begin
       if(reset)                                  r_out_buf_write_cnt    <='d0;
       else if(w_hardware_start)                  r_out_buf_write_cnt    <='d0;
       else if(w_wr_outbuf_req &&w_s2mm_ctlen)    r_out_buf_write_cnt    <= r_out_buf_write_cnt[OBUF_CNT_WIDTH-1:0] + 'd1;       
       else                                       r_out_buf_write_cnt    <= {1'd0,r_out_buf_write_cnt[OBUF_CNT_WIDTH-1:0]};
       end
//    always @(posedge clk) begin
//       if(reset)         w_outbuf_wr_over ='d0;
//        else             w_outbuf_wr_over =r_out_buf_write_cnt[OBUF_CNT_WIDTH];
//       end
    //to m_axi
    //gen base  hdware
//    always @(posedge clk) begin
//      if(reset)     r_s2mm_addr <= i_s2mm_base_hardware; //default fba
//      else if(w_hardware_start)
//                    r_s2mm_addr <= i_s2mm_base_hardware;
                    
//      else if( w_s2mm_done_posedge && r_mem_read_req ) 
//                    r_s2mm_addr <= r_s2mm_addr + AXI_DATA_WIDTH/8*M_AXI_AWLEN;      
//      else          r_s2mm_addr <= r_s2mm_addr; //this err
//    end
      //gen w_s2mm_en
     always @(posedge clk) begin
       if(reset)                                              r_mem_read_req          <= 'd0;
       else if(w_s2mm_en)                                     r_mem_read_req          <= 1'd1;
       //else if(r_out_buf_read_cnt>=M_AXI_AWLEN-1)             r_mem_read_req          <= 1'd0;
       else if(r_out_buf_read_cnt[OBUF_CNT_WIDTH])            r_mem_read_req          <= 1'd0;
       else                                                   r_mem_read_req          <= r_mem_read_req;
       end   
    always @(posedge clk) r_s2mm_en_shr <=  w_s2mm_en; 
    
     always @(posedge clk) begin
       r_mem_read_data     <= r_out_buf[r_out_buf_read_cnt[OBUF_CNT_WIDTH-1:0]];
       end

    
    always @(posedge clk) begin
       if(reset)                                                r_out_buf_read_cnt    <= 'd0;
       else  if(w_s2mm_en_posedge)                              r_out_buf_read_cnt    <= 'd0;
       else if(r_mem_read_req &&w_s2mm_data_transmit_one_ok)    r_out_buf_read_cnt    <= r_out_buf_read_cnt[OBUF_CNT_WIDTH-1:0] + 1'd1;
       //else                                                     r_out_buf_read_cnt    <= 'd0;
       end  
endmodule
