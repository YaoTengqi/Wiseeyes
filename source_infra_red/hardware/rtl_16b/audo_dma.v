`timescale 1ns / 1ns
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
module audo_dma #(
    parameter integer  AXI_ADDR_WIDTH               = 42, 
    parameter integer  IN_DATA_WIDTH                = 64,
    parameter          MAX_HARDWARE_SIZE            = 64*1024*1024,
    parameter integer  TX_SIZE_WIDTH                = 8,     
    parameter integer  AXI_DATA_WIDTH               = 256, 
    parameter integer  AXI_BURST_WIDTH              = 8,
    parameter integer  BURST_LEN                    = 1 << AXI_BURST_WIDTH,
    parameter integer  MEM_ID                       = 0,
    parameter integer  AXI_ARID                     = MEM_ID,
    parameter integer  AXI_RID                      = MEM_ID,
    parameter integer  AXI_AWID                     = MEM_ID,    
    
    parameter integer  MEM_ADDR_W                   = 8,
    parameter integer  MEM_DATA_W                   = AXI_DATA_WIDTH,
    parameter integer  AXI_SUPPORTS_WRITE           = 1,
    parameter integer  AXI_SUPPORTS_READ            = 1,    
    parameter integer  C_OFFSET_WIDTH               = AXI_ADDR_WIDTH < 16 ? AXI_ADDR_WIDTH - 1 : 16,
    parameter integer  WSTRB_W                      = AXI_DATA_WIDTH/8,
    parameter integer  AXI_ID_WIDTH                 = 1,    
    parameter integer  HARDWARE_S2MM_EN             = 0,
    //audo dnn from ddr max leng
    parameter integer  MAX_LENGTH_FROMDDR_B         = 1024*1024*32,
    parameter integer  MAX_LENGTH_FROMDDR_WIDTH     = $clog2(MAX_LENGTH_FROMDDR_B*8/AXI_DATA_WIDTH),
    
    parameter integer  PART_S2MM_EN     = 1,
    parameter integer  PART_MM2S_EN     = 1
)
( //golble
    input                                           clk,
    input                                           reset,
    //sensor 
    input                                           i_frame_start,
    input                                           i_de,
    input                                           i_hdware,
    input [IN_DATA_WIDTH-1:0]                       i_data,
    
    //to nxt memory
    output  [MEM_ADDR_W-1:0]                            o_mem_wadd,
    //output  [AXI_DATA_WIDTH-1:0]                    o_mem_wdata,
    output  [IN_DATA_WIDTH-1:0]                    o_mem_wdata,
    output                                         o_mem_wreq,
    output                                         o_frame_start,
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
    input  [AXI_ADDR_WIDTH-1:0]                      i_mm2s_ddrbase,//address base ab0
    input  [MAX_LENGTH_FROMDDR_WIDTH-1:0]            i_mm2s_leng,//data lengthe
    input  [AXI_ADDR_WIDTH-1:0]                      i_s2mm_ddrbase,//address base ab0    
    input  [AXI_ADDR_WIDTH-1:0]                      i_s2mm_ddrbase_hardware,//address base hardware
    output                                           o_s2mm_int_posedge,
    output                                           o_mm2s_int_posedge,
    output                                           o_hdware_int_posedge,
    input                                            i_DNN_IDLE
    );
    //
    localparam   mm2s_RX_SIZE_WIDTH                = $clog2((1<<MEM_ADDR_W)*MEM_DATA_W/AXI_DATA_WIDTH)+1;
    localparam   MEM_REQ_W                         = MEM_ADDR_W;
    
    localparam   MM2S_DATA_WIDTH                   = IN_DATA_WIDTH;
    localparam   MM2S_DATA_RSIZE                   =$clog2(IN_DATA_WIDTH/8);
    wire                                        w_s2mm_en,w_out_from;
    
    //axi
    wire                                                 w_mm2s_rd_req;
    wire [ AXI_ID_WIDTH         -1 : 0 ]                 w_mm2s_rd_req_id;
    wire                                                 w_mm2s_rd_done;
    wire [ mm2s_RX_SIZE_WIDTH            -1 : 0 ]        w_mm2s_rd_req_size;
    wire                                                 w_mm2s_rd_ready;
    wire [ AXI_ADDR_WIDTH       -1 : 0 ]                 w_mm2s_rd_addr;
    //
    wire                                                mem_write_req;
    wire [ AXI_DATA_WIDTH       -1 : 0 ]                mem_write_data;
   
    wire                                                mem_write_ready;
    wire [ AXI_ID_WIDTH         -1 : 0 ]                mem_write_id;
    
    wire                                                w_local_write_req;
    wire   [AXI_DATA_WIDTH-1:0]                         w_localdata;
   
    wire                                                w_clr;
    wire                                                w_force_out;
   
//to ddr s2mm
        wire  [ TX_SIZE_WIDTH        -1 : 0 ]                 w_s2mm_size;
        wire  [AXI_ADDR_WIDTH-1:0]                            w_s2mm_addr;
        wire                                                  w_s2mm_addr_req;
        wire                                                  w_s2mm_done;
        wire                                                  w_s2mm_addr_ready;
        
        wire  [AXI_DATA_WIDTH-1:0]                            w_s2mm_data;
        wire                                                  w_s2mm_data_req;
        wire                                                  w_s2mm_data_ready;       
   //from ddr
    wire  [MEM_ADDR_W-1:0]                     w_mm2s_wadd;
    wire  [IN_DATA_WIDTH-1:0]                 w_mm2s_wdata;
    wire                                       w_mm2s_wreq;
    
    wire                                        w_s2mm_int_posedge;
    wire                                        w_mm2s_done;
    
    //2021-07-28 add for add sync
//    reg [IN_DATA_WIDTH : 0 ]     r_out_mem_shr;
//    wire                         w_sl_sync_local;
//    //dont use r_out_mem_shr[IN_DATA_WIDTH]
//    reg                          r_sl_sync_local;
    wire                         w_frame_start_dma;
    //axi adjust
   assign o_m_axi_arsize          =MM2S_DATA_RSIZE;
    
   assign {w_s2mm_en,w_out_from}  = i_ctl;
   //check hdware
 
  //int
   //assign o_mm2s_int_posedge     = w_out_from && w_mm2s_done;
   assign o_s2mm_int_posedge     = w_s2mm_int_posedge && w_s2mm_en;
   //assign o_s2mm_int_posedge     = w_s2mm_en  && w_s2mm_data_ready && w_s2mm_addr_done;
   //data to 256 bit;
   generate
   if(HARDWARE_S2MM_EN ==0)begin
     assign  w_clr       ='d0;
     assign  w_force_out ='d0;
     assign  o_hdware_int_posedge = 'd0;
     end
     else begin  // hdware
     reg                                         r_is_hardware;
     wire                                        w_hardware_start,w_hardware_end;
     
     always @(posedge clk) r_is_hardware  <= i_hdware;
     
     assign   w_hardware_start      = (!r_is_hardware) && i_hdware;
     assign   w_hardware_end        = (r_is_hardware)  && (!i_hdware);
     
     assign   w_clr                 = w_hardware_start||w_hardware_end;
     assign   w_force_out           = w_clr;
     assign   o_hdware_int_posedge  = w_hardware_end;
     
     end
   endgenerate
   
 fifo_16to256 #(
 .IN_WIDTH(IN_DATA_WIDTH)
 ) u_fifo_64to256(
 .clk(clk),
 .reset(reset),
 .clr(w_clr),
 .force_out(w_force_out),
 .i_wr_req(i_de),
 .i_data(i_data),
 
 //out
 .o_rd_req(w_local_write_req),
 .o_data(w_localdata)
 );
    
 
 audo_s2mm #(
    .AXI_DATA_WIDTH(  AXI_DATA_WIDTH                 ),
    .AXI_ADDR_WIDTH(  AXI_ADDR_WIDTH                 ),
    .IN_DATA_WIDTH(   AXI_DATA_WIDTH                 ),             
    .TX_SIZE_WIDTH(   TX_SIZE_WIDTH                  )
)
  u_audo_s2mm(
    .clk(                                      clk),//
    .reset(                                  reset),//
    .i_s2mm_en(                     w_s2mm_en     ),
    .o_page_done(             w_s2mm_int_posedge  ),
    .i_s2mm_base(                   i_s2mm_ddrbase),
    .i_s2mm_base_hardware( i_s2mm_ddrbase_hardware),
    .i_is_hardware(                       i_hdware),
    //.i_hs(video_hs_o),
    .i_de(                       w_local_write_req),
    //.i_clk_cam(                       clk_cam),
    .i_data(                           w_localdata),
   // .o_fbptr(                                ),
    
    .o_s2mm_size(              w_s2mm_size            ),
    .o_s2mm_addr(              w_s2mm_addr            ),
    .i_s2mm_addr_req(          w_s2mm_addr_req        ),
    .i_s2mm_done(         w_s2mm_done                 ),
    .o_s2mm_addr_ready(        w_s2mm_addr_ready      ),
    
    
    .o_s2mm_data(              w_s2mm_data            ),
    .i_s2mm_data_req(          w_s2mm_data_req        ),
    .o_s2mm_data_ready(        w_s2mm_data_ready      )
    //.i_s2mm_data_done(         o_m_axi_wlast          )
 );
 
 
 
 
 //out to dnn 
 //from ddr  (mm2s)
   // wire                                       w_start;
generate 
 if(PART_MM2S_EN ==1)begin
//int
assign o_mm2s_int_posedge     = w_out_from && w_mm2s_done;          
audo_mm2s #(
  .AXI_DATA_WIDTH(  IN_DATA_WIDTH                 ),
  .MAX_LENGTH_FROMDDR_B(MAX_LENGTH_FROMDDR_B                ),  
  .MAX_LENGTH_FROMDDR_WIDTH(MAX_LENGTH_FROMDDR_WIDTH        ),
  .LD_RDID(               AXI_ARID                          ),
  .MEM_ADDR_WIDTH(        MEM_ADDR_W                        ),
  .RX_SIZE_WIDTH(         MEM_ADDR_W+1                )
)u0_audo_mm2s 
  (
    .clk(                clk                                 ),
    .reset(              reset                               ),
  
    .i_start(            w_out_from                          ),   
    .o_done(             w_mm2s_done                         ),   
    .i_mm2s_base(        i_mm2s_ddrbase                      ),//address base ab0    
    .i_mm2s_leng(        i_mm2s_leng                         ),
    .o_mem_wadd(         w_mm2s_wadd                          ),
   // .o_mem_wdata(        w_mm2s_wdata                       ),//opt
    .o_mem_wreq(         w_mm2s_wreq                          ),
    .o_frame_start(      w_frame_start_dma                    ),
     // mm2s
    .o_mm2s_req_id(        w_mm2s_rd_req_id                  ),
    .o_mm2s_size(          w_mm2s_rd_req_size                ),
    .o_mm2s_addr(          w_mm2s_rd_addr                    ),
    .o_mm2s_addr_req(      w_mm2s_rd_req                     ),
    .i_mm2s_done(          w_mm2s_rd_done                    ),
    .i_mm2s_addr_ready(    w_mm2s_rd_ready                   ),
    
    .i_mm2s_get_id(        mem_write_id                      ),
    //.i_mm2s_data(          mem_write_data                    ),//opt
    .i_mm2s_data_req(      mem_write_req                     ),
    .o_mm2s_data_ready(	   mem_write_ready       			 ),
    
    .i_DNN_IDLE(           i_DNN_IDLE                        )  
  );
  ////opt
  assign w_mm2s_wdata   =  mem_write_data[IN_DATA_WIDTH-1:0];
  end else begin
  assign o_mm2s_int_posedge     = 'd0;
 end
endgenerate 
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
    .m_axi_arsize                   ( /*o_m_axi_arsize*/                 ),
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
    .mem_write_data                 ( mem_write_data                    ),
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
    .wr_done                        (  w_s2mm_done                     )
  );
 
 //from local
 //gen add
//  reg  [ MEM_ADDR_W           -1 : 0 ]        r_local_addr;
//  always @(posedge clk)begin
//  if(reset)                      r_local_addr <='d0;
//     else if(w_clr)              r_local_addr <='d0;
//     else  if(w_local_write_req) r_local_addr <= r_local_addr + 'd1;
//     else                        r_local_addr <= r_local_addr; 
//  end
// mux_2_1 #(
//     .WIDTH(   MEM_ADDR_W +  1 +AXI_DATA_WIDTH                                                ) 
//     )u_out_select(
//       .sel(            w_out_from                                                             ),
//       .data_in({w_mm2s_wreq,w_mm2s_wadd,w_mm2s_wdata,w_local_write_req,r_local_addr,w_localdata} ),
//       .data_out(      {o_mem_wreq,o_mem_wadd,o_mem_wdata}                                     )
//     );
//*****************************2021-07-28 add:add sync 
generate 
 if(PART_MM2S_EN ==1)begin
 mux_2_1 #(
     .WIDTH(   2 +IN_DATA_WIDTH                                         ) 
     )u_out_select(
       .sel(           w_out_from                                       ),
       .data_in({w_frame_start_dma,w_mm2s_wreq,w_mm2s_wdata,i_frame_start,i_de,i_data} ),
       .data_out(      {o_frame_start,o_mem_wreq,o_mem_wdata}           )
     );
 end else begin
 end
endgenerate
//    //本地数据 打1拍，
//    always @(posedge clk)begin
    
//       if(w_out_from)r_out_mem_shr <= {w_mm2s_wreq,w_mm2s_wdata};
//          else       r_out_mem_shr <= {i_de,i_data};
     
//    end
//    assign       {o_mem_wreq,o_mem_wdata}   = r_out_mem_shr;
    
//    always @(posedge clk)  r_sl_sync_local <= i_de;
    
//    assign       w_sl_sync_local            =  !r_sl_sync_local && i_de;
    //
endmodule
