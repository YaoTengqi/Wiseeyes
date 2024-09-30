`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/31 10:02:07
// Design Name: 
// Module Name: video2ddr_base_gen
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


module video2ddr_base_gen #(
    parameter integer  AXI_ADDR_WIDTH               = 42, 
    parameter          COLOR_WIDTH                  = 24,
    parameter          TX_SIZE_WIDTH                = 8, 
    parameter          VIDEO_LINE_DOT_NUM           = 1280, 
    parameter integer  AXI_DATA_WIDTH               = 256                            
     
)
(
    input                                                   clk,
    input                                                   reset,
    
    // reg
    (*MARK_DEBUG="true" *)input  [1:0]                                            i_video2ddr_ctl,   //bit0:en,bit1:en_pingpangbuf:
    output                                                  o_fbptr,           //0:writing fb0,1 wrinting fb1
    (*MARK_DEBUG="true" *)input  [AXI_ADDR_WIDTH-1:0]                             i_Video2ddr_base_a,//address base fb0
    (*MARK_DEBUG="true" *)input  [AXI_ADDR_WIDTH-1:0]                             i_Video2ddr_base_b,//address base fb0
    //video if                                                   
    input                                                   i_fs_start,        // vs

    input                                                   i_de,              //
    input                                                   i_clk_cam,
    input  [COLOR_WIDTH-1:0]                                i_pix_data,

    
    //**************************************************
        //video s2mm
    (*mark_debug ="true"*)output  [ TX_SIZE_WIDTH        -1 : 0 ]                 o_s2mem_size,
    (*mark_debug ="true"*)output  [AXI_ADDR_WIDTH-1:0]                            o_s2mem_addr,
    (*mark_debug ="true"*)input                                                   i_s2mem_addr_req,
    (*mark_debug ="true"*)input                                                   i_s2mem_done,
    (*mark_debug ="true"*)output                                                  o_s2mem_addr_ready,
    
    
    (*mark_debug ="true"*)output  [AXI_DATA_WIDTH-1:0]                            o_s2mem_data,
    (*mark_debug ="true"*)input                                                   i_s2mem_data_req,
    (*mark_debug ="true"*)output                                                  o_s2mem_data_ready
    
    );
  
   //localparam   AXI_M_AXI_AWLEN_VIDEO        = VIDEO_LINE_DOT_NUM*COLOR_WIDTH/AXI_DATA_WIDTH;
   localparam   AXI_M_AXI_AWLEN_VIDEO        =8;//2*32
   localparam   LP_OUTBUF_CNT_WIDTH        =$clog2(AXI_M_AXI_AWLEN_VIDEO);//2*32
  // localparam lp_Video2ddr_base0                 = 'h698b_d000;
   //localparam lp_Video2ddr_base1                 = 'h69b6_d000;  
   localparam   lp_ibuf_DEEP        =32;//2*32
   localparam   lp_ibuf_CNT_WIDTH   =$clog2(lp_ibuf_DEEP);//2*32
//   reg                                                      r_de_camif;
//   reg [3:0]                                                r_de_shr;
   
//  // reg                                                      r_hs_camif;
//  // reg                                                      r_hs_shr,r_hs_shr1;
   
//   reg                                                      r_fs_start_camif;
    reg                                                      r_camif_fs;
   
//   reg  [COLOR_WIDTH-1:0]                                   r_pix_data_camif;
//   reg  [COLOR_WIDTH-1:0]                                   r_pix_data_shr,r_pix_data_shr1;
   
   
   
   
   reg                                                      r_ptr_cnt;
   reg  [1:0]                                               r_prt_ctl; //bit0:en,bit1:en_pingpangbuf:
   reg  [AXI_ADDR_WIDTH-1:0]                                r_s2mem_addr; 
   
  
   (*mark_debug ="true"*)wire                                                     w_fs_camif_posedge;
   (*mark_debug ="true"*)wire                                                     w_fs_posedge;
   wire                                                     w_s2mm_ctl_en;
   wire                                                     w_s2mm_ctl_ppbuf_en;
   
   //(*mark_debug ="true"*)wire                                                     w_ibuf_write_en;
   //(*mark_debug ="true"*)wire                                                     w_obuf_write_en_check;
   //reg                                                      r_obuf_write_en_check_shr;
   //write 3 times
   //n+1
   (*mark_debug ="true"*)reg[2:0]                                                 r_i2o_byte_num;
   (*mark_debug ="true"*)wire                                                     w_obuf_write_en;
   (*mark_debug ="true"*)wire                                                     w_obuf2ddr_en;
   //(*mark_debug ="true"*)wire                                                     w_obuf2ddr_addr_rdy_en;
   (*mark_debug ="true"*)reg                                                      r_obuf2ddr_en_shr;
   
   (*mark_debug ="true"*)reg                                                      r_mem_read_req; //outbuf
   reg  [AXI_DATA_WIDTH-1:0]                                r_mem_read_data;
   reg   [lp_ibuf_CNT_WIDTH:0]                                             r_ibuf_camclk_cnt; 
   
  // (*mark_debug ="true"*)reg   [lp_ibuf_CNT_WIDTH-1:0]   r_ibuf_cnt0,r_ibuf_cnt; 
   //
   wire                                                     w_ibuf_cnt_over_posedge;
   (*mark_debug ="true"*)wire                               w_s2mm_data_transmit_one_ok;
   
   reg[1:0]   r_s2mem_done;
   reg       r_s2mm_done_posedge;
   
   (*mark_debug ="true"*)reg [LP_OUTBUF_CNT_WIDTH:0]                 r_obuf_write_cnt;

    // reg                                          r_obuf_write_cnt_over;
      (*ram_style ="block"*)
    reg   [COLOR_WIDTH-1:0] r_ibuf[0:lp_ibuf_DEEP-1];
     (*ram_style ="block"*)
     reg [AXI_DATA_WIDTH-1:0]  r_obuf[0:AXI_M_AXI_AWLEN_VIDEO-1];

    (*mark_debug ="true"*)reg [LP_OUTBUF_CNT_WIDTH:0]            r_obuf_read_cnt;
   
   assign            {w_s2mm_ctl_en,w_s2mm_ctl_ppbuf_en}         = r_prt_ctl;
   
   //out 
    assign            o_s2mem_addr_ready                         = w_s2mm_ctl_en && w_obuf2ddr_en && (!r_obuf2ddr_en_shr); 
    assign            o_fbptr                                    = r_ptr_cnt;
 
    assign            o_s2mem_addr                               = r_s2mem_addr; 
    assign            o_s2mem_size                               = AXI_M_AXI_AWLEN_VIDEO; 
    assign            o_s2mem_data                               = r_mem_read_data;//r_mem_read_req? r_mem_read_data:'d0;
    assign            o_s2mem_data_ready                         = r_mem_read_req&&w_s2mm_ctl_en&&(!o_s2mem_addr_ready);
    //assign            w_ibuf_write_en                            = //r_de_shr[3]&&(r_ibuf_cnt[0]^r_ibuf_cnt0[0]);// after change save
    
   assign             w_s2mm_data_transmit_one_ok     = o_s2mem_data_ready && i_s2mem_data_req;
    //handle clk_cam data,
//    always @(posedge i_clk_cam) begin
//            r_de_camif                          <=   i_de;
//          //r_de_camif                          <=   i_hs;
//            r_fs_start_camif                    <=   i_fs_start;
//            r_pix_data_camif                    <=   i_pix_data;
//    end
   
   always @(posedge i_clk_cam) begin
       if(reset )r_camif_fs <='d0;
           else  r_camif_fs  <= i_fs_start;           
       end
    assign          w_fs_camif_posedge     = r_camif_fs&& (!i_fs_start);
    
//    wire   w_ibuf_camclk_cnt_ifover;
//     assign  w_ibuf_camclk_cnt_ifover = i_de &&(r_ibuf_camclk_cnt>=lp_ibuf_DEEP-1)&& (!i_fs_start);
         
    always @(posedge i_clk_cam) begin
       if(reset)                            r_ibuf_camclk_cnt <= 'd0;
         else if(i_fs_start)                r_ibuf_camclk_cnt <= 'd0;
         //else if(w_ibuf_camclk_cnt_ifover)  r_ibuf_camclk_cnt <='d0;
         else if(i_de)                      r_ibuf_camclk_cnt <= r_ibuf_camclk_cnt[lp_ibuf_CNT_WIDTH-1:0] + 1'd1;//
         else                               r_ibuf_camclk_cnt <={1'd0,r_ibuf_camclk_cnt[lp_ibuf_CNT_WIDTH-1:0]};
       end
     reg  r_ibuf_camclk_cnt_over;
     
     always @(posedge i_clk_cam) begin
       if(reset)   r_ibuf_camclk_cnt_over <= 'd0;
             else  r_ibuf_camclk_cnt_over <= r_ibuf_camclk_cnt[lp_ibuf_CNT_WIDTH];
        
         //else                               r_ibuf_camclk_cnt_over <= 'd0;// hangtongbu
       end
     always @(posedge i_clk_cam) begin
       if(i_de)begin
            r_ibuf[r_ibuf_camclk_cnt[lp_ibuf_CNT_WIDTH-1:0]]     <= i_pix_data;
            end
       end
//    always @(posedge i_clk_cam) begin
//       if(reset)                            r_ibuf_camclk_cnt_over <= 'd0;
//         else if(w_fs_posedge)              r_ibuf_camclk_cnt_over <= 'd0;
//         //else if(i_de)                    r_ibuf_camclk_cnt <= r_ibuf_camclk_cnt + 1'd1;//
//         else                               r_ibuf_camclk_cnt_over <='d1;
//       end
     

    wire [AXI_DATA_WIDTH*3-1:0] w_line_dot_convert;
    reg [AXI_DATA_WIDTH-1:0] r_i2obuf[0:2];

    genvar m;
    generate 
       for(m=0;m<AXI_DATA_WIDTH*3/COLOR_WIDTH; m = m +1)
         begin:dout_buf_pal
         assign w_line_dot_convert[m*COLOR_WIDTH+:COLOR_WIDTH]    =   r_ibuf[m];
         end
    endgenerate
       //00-111-110-100-000
      //assign w_obuf  = (r_i2o_byte_num==0)?w_line_dot_convert[AXI_DATA_WIDTH*0+:AXI_DATA_WIDTH]:(r_i2o_byte_num=='d3)?w_line_dot_convert[AXI_DATA_WIDTH*1+:AXI_DATA_WIDTH]:w_line_dot_convert[AXI_DATA_WIDTH*2+:AXI_DATA_WIDTH];
     always @(posedge i_clk_cam)begin
         if(r_ibuf_camclk_cnt[lp_ibuf_CNT_WIDTH])
             {r_i2obuf[2],r_i2obuf[1],r_i2obuf[0]} <=  w_line_dot_convert;          
       end
    
    //*********************************************************************************

//    always @(posedge clk) begin
//            r_de_shr                                                    <=   {r_de_shr[2:0],r_de_camif};             
//            {r_ibuf_cnt,r_ibuf_cnt0}                                    <=   {r_ibuf_cnt0,r_ibuf_camclk_cnt}; 
//            {r_fs_start_shr2,r_fs_start_shr1,r_fs_start_shr}            <=   {r_fs_start_shr1,r_fs_start_shr,r_fs_start_camif}; 
//            {r_pix_data_shr1,r_pix_data_shr}                            <=   {r_pix_data_shr,r_pix_data_camif}; 
//    end
      // //==all 1
      reg r_fs__check;
      reg r_ibuf_cnt_over;  
      
      always @(posedge clk) begin
      r_ibuf_cnt_over <= r_ibuf_camclk_cnt_over;
      r_fs__check     <= w_fs_camif_posedge;
      end
     
      //posedge     
     // assign            w_ibuf_cnt_over_posedge    =  (!r_ibuf_cnt_over)&&r_ibuf_camclk_cnt_over;
      assign            w_ibuf_cnt_over_posedge    = r_ibuf_cnt_over &&(!r_ibuf_camclk_cnt_over);
      assign            w_fs_posedge       =  (r_fs__check)&&(!w_fs_camif_posedge);
    
    
     //negedge
    //assign w_ibuf_cnt_over  = r_obuf_write_en_check_shr && (!w_obuf_write_en_check);
    //****************************************************************************** clk remain end
//    reg [1:0]  run1fram;
//    always @(posedge clk) begin
//       if(reset)
//              run1fram    <= 'd2;
//              else if(w_fs_posedge) run1fram <= 1>>run1fram;            
//       end
    //****************write ibuf
     
    //***********************************move ibuf to obuf check 
    //send to axi dont write 
    assign w_obuf_write_en      = (r_i2o_byte_num>0) && ((!r_mem_read_req)||(r_mem_read_req&&(r_obuf_read_cnt>2)))&&(!w_obuf2ddr_en);
    always @(posedge clk) begin
           if(reset)                                        r_i2o_byte_num           <=  'd0; 
           else  if(r_fs__check)                            r_i2o_byte_num           <=  'd0; 
             else if(w_ibuf_cnt_over_posedge)               r_i2o_byte_num           <=  'd7;// save event
              else  if(w_obuf_write_en)                     r_i2o_byte_num           <=  r_i2o_byte_num>>1; //do event;
               else                                         r_i2o_byte_num           <=  r_i2o_byte_num;
    end 
    //*********************************************************************************
   // gen fs_star_posedge
   
  
 

     //WRITE OBUF
     always @(posedge clk)begin
       
           if(w_obuf_write_en) begin
              case (r_i2o_byte_num)
              'd7:  r_obuf[r_obuf_write_cnt[LP_OUTBUF_CNT_WIDTH-1:0]]   <= r_i2obuf[0];
              'd3:  r_obuf[r_obuf_write_cnt[LP_OUTBUF_CNT_WIDTH-1:0]]   <= r_i2obuf[1];
              'd1:  r_obuf[r_obuf_write_cnt[LP_OUTBUF_CNT_WIDTH-1:0]]   <= r_i2obuf[2];
              endcase 
            end else r_obuf[r_obuf_write_cnt[LP_OUTBUF_CNT_WIDTH-1:0]]  <=r_obuf[r_obuf_write_cnt[LP_OUTBUF_CNT_WIDTH-1:0]];
//                else  if(w_obuf_write_en&& (r_i2o_byte_num==3)) r_obuf[r_obuf_write_cnt[LP_OUTBUF_CNT_WIDTH-1:0]]   <= r_i2obuf[1];
//                  else if()
                
               
       end
       // en up +1,num=3 +1,num =1 +1
    always @(posedge clk) begin
       if(reset)                                                r_obuf_write_cnt    <='d0;
       else if(r_fs__check)                                     r_obuf_write_cnt    <='d0;
       else if(w_obuf_write_en)                                 r_obuf_write_cnt    <=  r_obuf_write_cnt[LP_OUTBUF_CNT_WIDTH-1:0] + 'd1;
       else                                                     r_obuf_write_cnt    <=  {1'd0,r_obuf_write_cnt[LP_OUTBUF_CNT_WIDTH-1:0]};
       end
 
//      always @(posedge clk) begin
//       if(reset )            r_obuf_write_cnt_over <= 'd0;
//       else if(r_fs__check )r_obuf_write_cnt_over <= 'd0;
//         else    r_obuf_write_cnt_over <=  r_obuf_write_cnt[LP_OUTBUF_CNT_WIDTH];
//      end

     //s2mm
     //touch check
     // assign            w_obuf2ddr_en              =  r_obuf_write_cnt_over^r_obuf_write_cnt[LP_OUTBUF_CNT_WIDTH];//r_obuf_write_cnt2_over&&(!w_obuf_write_cnt2[LP_OUTBUF_CNT_WIDTH]);
      assign            w_obuf2ddr_en              =  r_obuf_write_cnt[LP_OUTBUF_CNT_WIDTH];//r_obuf_write_cnt2_over&&(!w_obuf_write_cnt2[LP_OUTBUF_CNT_WIDTH]);
      always @(posedge clk) r_obuf2ddr_en_shr      <= w_obuf2ddr_en;

       always @(posedge clk) begin
           if(reset)         r_s2mem_done    <='d0;       
           else              r_s2mem_done    <= {r_s2mem_done[0],i_s2mem_done};       
       end  
       always @(posedge clk) begin
          if(reset)   r_s2mm_done_posedge <= 'd0;
          else r_s2mm_done_posedge <= r_obuf_read_cnt[LP_OUTBUF_CNT_WIDTH];//(!r_s2mem_done[1])&& r_s2mem_done[0] && i_s2mem_done && r_mem_read_req;
       end
       //rec event 
       always @(posedge clk) begin
           if(reset)                                               r_mem_read_req          <= 'd0;
           else if(w_obuf2ddr_en)                                  r_mem_read_req          <= 1'd1;//save event
           else if(r_s2mm_done_posedge||r_fs__check)               r_mem_read_req          <= 1'd0;// done ?
           else                                                    r_mem_read_req          <= r_mem_read_req;//doing
       end
    // gen ddr add
     always @(posedge clk) r_prt_ctl        <= i_video2ddr_ctl;
   //gen fbX
   always @(posedge clk) begin 
    if(reset)r_ptr_cnt                    <= 'd0;
     else if(w_fs_posedge) //posedge fs
             r_ptr_cnt                    <= w_s2mm_ctl_ppbuf_en &&(~r_ptr_cnt);
     else    r_ptr_cnt                    <= r_ptr_cnt;
   end
    //fbx addr      
    always @(posedge clk) begin
      if(reset)             r_s2mem_addr <= i_Video2ddr_base_a; //default fba
      else if(w_fs_posedge) begin //new 1frame data come;
           if(r_ptr_cnt)    r_s2mem_addr <= i_Video2ddr_base_b;
             else           r_s2mem_addr <= i_Video2ddr_base_a;
           end
      else if(r_s2mm_done_posedge)                  
                           r_s2mem_addr <= r_s2mem_addr + AXI_M_AXI_AWLEN_VIDEO*AXI_DATA_WIDTH/8;
           else            r_s2mem_addr <= r_s2mem_addr;      
    end

     always @(posedge clk) begin
       if(reset)                                                r_obuf_read_cnt    <='d0;
       else if(r_fs__check||(!r_mem_read_req))                  r_obuf_read_cnt    <='d0;// keneng huidaozhi kasi
       else if(r_mem_read_req &&w_s2mm_data_transmit_one_ok)    r_obuf_read_cnt    <= r_obuf_read_cnt[LP_OUTBUF_CNT_WIDTH-1:0] + 'd1;   
       else                                                     r_obuf_read_cnt    <= {1'd0,r_obuf_read_cnt[LP_OUTBUF_CNT_WIDTH-1:0]};  
       end 
     // 2 axi
     always @(posedge clk) begin
       if(i_s2mem_data_req) r_mem_read_data     <= r_obuf[r_obuf_read_cnt[LP_OUTBUF_CNT_WIDTH-1:0]];
       end


      
endmodule
