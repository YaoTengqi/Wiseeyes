//edit yt 
//edit time: 0810
//real v21
`timescale 1ns/1ps
module obuf_bias_sel_logic_v2 #(
    parameter integer  LOOP_ID_W                    = 5,
    parameter integer  ADDR_STRIDE_W                = 16,
    parameter integer  BBUF_ADDR_WIDTH              = 8,
    parameter integer  ADDR_WIDTH              =42,
    parameter integer  OBUF_ADDR_WIDTH              = 8,
    parameter integer  ADDR_STRIDE_W_BASE           = 32
) (
    input  wire                                         clk,
    input  wire                                         reset,
    //input  wire                                         done,
    input  wire                                         start,
    (* MARK_DEBUG="true" *)input  wire                                         compute_done,
//    (* MARK_DEBUG="true" *)input  wire                                         com_loop_exit,
//    input  wire                                         base_obuf_stride_v,
//    input  wire                                         com_obuf_stride_v, 
//    input  wire                                         com_cfg_loop_iter_v, 
//    input  wire  [ ADDR_STRIDE_W        -1 : 0 ]        com_obuf_stride,
//    input  wire  [ ADDR_STRIDE_W_BASE   -1 : 0 ]        base_obuf_stride,
    input  wire  [ OBUF_ADDR_WIDTH      -1 : 0 ]        obuf_ld_addr,  
    input  wire                                         obuf_ld_addr_v,
    input  wire  [ BBUF_ADDR_WIDTH      -1 : 0 ]        bias_ld_addr,
    input  wire                                         bias_ld_addr_v,
//    (* MARK_DEBUG="true" *)input  wire  [ LOOP_ID_W            -1 : 0 ]        com_loop_index,
    (* MARK_DEBUG="true" *)output wire                                         obuf_bias_sel_out,
    input  wire  [ ADDR_WIDTH           -1 : 0 ]        obuf_tile_base_addr,
    input  wire                                         obuf_tile_base_addr_v,
    input  wire                                         base_loop_enter,
    //====================================================================  edit by pxq 1028
    //input wire                                          i_is_run_adnn,
    input wire                                          i_decoder_done,
    input wire                                          cfg_loop_iter_v, //input
    input wire [ LOOP_ID_W            -1 : 0 ]          cfg_loop_iter_loop_id //input 
);
    reg base_loop_enter_dly;
    (* MARK_DEBUG="true" *)reg compute_done_dly;
    (* MARK_DEBUG="true" *)wire fifo_read_req;
    (* MARK_DEBUG="true" *)wire fifo_read_ready;
    
    reg [ADDR_WIDTH -1 : 0] obuf_tile_base_addr_last;
    reg [BBUF_ADDR_WIDTH -1 : 0] bbuf_base_addr_last;
    wire bias_sel_init;
    
    wire sel_info_fifo_write_req;
    
    (* MARK_DEBUG="true" *)wire bias_init_read_data;
    
    always@(posedge clk)begin
      if(reset)
        compute_done_dly <= 0;
      else
        compute_done_dly <= compute_done;
    end

    always@(posedge clk)begin
      if(reset)
        base_loop_enter_dly <= 0;
      else
        base_loop_enter_dly <= base_loop_enter;
    end

    always @(posedge clk) begin
      if(reset)
        bbuf_base_addr_last<= 'b0;
      else if(i_decoder_done || cfg_loop_iter_v)
        bbuf_base_addr_last<='b0;
      else
        bbuf_base_addr_last<=bias_ld_addr;
    end
    //=============================================================================edit by pxq 1201

    always @(posedge clk) begin
      if(reset)begin
        obuf_tile_base_addr_last<= 'b0;
      end
      else if(i_decoder_done || cfg_loop_iter_v)begin
        obuf_tile_base_addr_last<='b0;
      end
      else if(obuf_tile_base_addr_v)begin
        obuf_tile_base_addr_last<=obuf_tile_base_addr;
      end
    end

    assign bias_sel_init = (obuf_tile_base_addr == obuf_tile_base_addr_last)? 1:0;
    assign sel_info_fifo_write_req = obuf_tile_base_addr_v && (obuf_tile_base_addr_last!= 0);
    
    assign fifo_read_req = compute_done && fifo_read_ready;
    fifo #(
        .DATA_WIDTH                     ( 1                       ),
        .ADDR_WIDTH                     ( 2                              )
    ) bias_init_sel_fifo (
        .clk                            ( clk                            ), //input
        .reset                          ( reset                          ), //input
        .s_read_req                     ( fifo_read_req),//bias_init_read_req                 ), //input
        .s_read_ready                   ( fifo_read_ready            ), //output
        .s_read_data                    (     bias_init_read_data       ), //output
        .s_write_req                    (  sel_info_fifo_write_req),//obuf_tile_base_addr_v                 ), //input
        .s_write_ready                  (             ), //output
        .s_write_data                   (   bias_sel_init             )//input
      );

//=========================================================================test use
wire i_is_run_adnn = 'b0;
//=============================================================================
//    reg     [ LOOP_ID_W            -1 : 0 ]        base_loop_id;
//    (* MARK_DEBUG="true" *)reg     [ LOOP_ID_W            -1 : 0 ]        base_loop_id_stable;
//    reg     [ LOOP_ID_W            -1 : 0 ]        com_loop_id;
//    (* MARK_DEBUG="true" *)reg     [ LOOP_ID_W            -1 : 0 ]        com_loop_id_stable;
//    reg                                            obuf_bias_sel_out_reg=1'b0;
//    reg                                            obuf_bias_sel_out_reg_dly2=1'b0;
//    reg                                            obuf_bias_sel_out_reg_dly=1'b0;
//    reg                                            obuf_zero_d = 0;
//    (* MARK_DEBUG="true" *)reg                                            obuf_zero_q = 0;
//    reg     [ ADDR_STRIDE_W        -1 : 0 ]        iter_value_d = 'b0;
//    reg     [ ADDR_STRIDE_W        -1 : 0 ]        iter_cnter_d = 'b0;

//    reg signed [ ADDR_STRIDE_W        -1 : 0 ]     iter_value_q = 'b0;
//    (* MARK_DEBUG="true" *)reg signed [ ADDR_STRIDE_W        -1 : 0 ]     iter_cnter_q = 'b0;

//    (* MARK_DEBUG="true" *)reg     [4                     -1    : 0 ]     bias_state_d=0;
//    reg     [4                     -1    : 0 ]     bias_state_q=0; 
//    wire                                           level3_enable;


//    localparam integer  GET_ITER_INFO              = 0 ;
//    localparam integer  GET_OBUFZ_INFO             = 1;
//    localparam integer  BIAS_LAYER_JUDGE           = 2;
//    localparam integer  BIAS_LEVEL1                = 3;
//    localparam integer  BIAS_LEVEL2                = 4;
//    localparam integer  BIAS_LEVEL458              = 5;
//    localparam integer  BIAS_LEVEL9_conv1          = 6;
//    localparam integer  BIAS_LEVEL3                = 7;
//    localparam integer  BIAS_sound_sp              = 8;


    reg[8-1 : 0] current_layer;

    always @(posedge clk) begin
    if(reset)begin
      current_layer<='b0;
    end
    if(i_decoder_done)begin
      current_layer<='b0;
    end
    if( cfg_loop_iter_loop_id==0&&cfg_loop_iter_v)begin
      current_layer<=current_layer+1;
    end
end

//    assign level3_enable = iter_cnter_q == iter_value_q;
////=============================================================
//// OUTPUT delay
////=============================================================
//    assign obuf_bias_sel_out = (current_layer ==1&&(~i_is_run_adnn))? 0: obuf_bias_sel_out_reg_dly2;

//    always @(posedge clk ) begin
//      if(reset || cfg_loop_iter_v)
//        obuf_bias_sel_out_reg_dly <= 'b0;
//      else
//        obuf_bias_sel_out_reg_dly <= obuf_bias_sel_out_reg;
//    end

//    always @(posedge clk ) begin
//      if(reset || cfg_loop_iter_v)
//        obuf_bias_sel_out_reg_dly2 <= 'b0;
//      else
//        obuf_bias_sel_out_reg_dly2 <= obuf_bias_sel_out_reg_dly;
//    end
////=============================================================
//// base/com_loop_id transit logic
////=============================================================
//    always @(posedge clk)begin
//      if (reset)
//        base_loop_id <= 1'b0;
//      else if (done)
//          base_loop_id <= 1'b0;
//      else if (base_obuf_stride_v)
//          base_loop_id <= base_loop_id + 1'b1;
//    end

//    always @(posedge clk ) begin
//      if(reset)
//        base_loop_id_stable <= 1'b0;
//      else if(base_loop_id != 1'b0)
//        base_loop_id_stable <= base_loop_id;
//    end


//    always @(posedge clk)
//    begin
//      if (reset)
//        com_loop_id <= 1'b0;
//      else if (done)
//        com_loop_id <= 1'b0;
//      else if (com_obuf_stride_v)
//        com_loop_id <= com_loop_id + 1'b1;
//    end

//    always @(posedge clk ) begin
//      if(reset)
//        com_loop_id_stable <= 'b0;
//      if(com_loop_id != 1'b0)
//        com_loop_id_stable <= com_loop_id;
//    end
    
    


////=============================================================
//// FSM for bias selection
////=============================================================
//  always @(posedge clk) begin
//    if (reset)
//      bias_state_q <= 1'b0;
//    else
//      bias_state_q <= bias_state_d;
//  end

//  always @(posedge clk) begin
//    if (reset)
//      iter_value_q <= 1'b0;
//    else
//      iter_value_q <= iter_value_d;
//  end

//  always @(posedge clk) begin
//    if (reset)
//      iter_cnter_q <= 1'b0;
//    else
//      iter_cnter_q <= iter_cnter_d;
//  end

//  always @(posedge clk) begin
//    if (reset)
//      obuf_zero_q <= 1'b0;
//    else
//      obuf_zero_q <= obuf_zero_d;
//  end

//  always @(*) begin
//    bias_state_d = bias_state_q;
//    iter_value_d = iter_value_q;
//    iter_cnter_d = iter_cnter_q;
//    obuf_zero_d = obuf_zero_q;
//    obuf_bias_sel_out_reg = obuf_bias_sel_out_reg_dly;
//    case (bias_state_q)
//      GET_ITER_INFO: begin//0
//        if(com_cfg_loop_iter_v)begin
//          iter_value_d = com_obuf_stride;
//          iter_cnter_d = com_obuf_stride;
//          bias_state_d = GET_OBUFZ_INFO;
//        end
//        else if(compute_done_dly && (bias_init_read_data==0) )//edit yt
//          obuf_bias_sel_out_reg = 0;
//        else if(start)
//          bias_state_d = BIAS_LAYER_JUDGE;
//      end

//      GET_OBUFZ_INFO: begin//1
//        if(base_obuf_stride_v)begin
//          obuf_zero_d = base_obuf_stride == 0;
//          bias_state_d = BIAS_LAYER_JUDGE;
//          obuf_bias_sel_out_reg = 1'b0;//select bias default
//        end
//      end

//      BIAS_LAYER_JUDGE: begin //2
//        if(start) begin
//          casez ({base_loop_id_stable , com_loop_id_stable})
//            {5'b????? , 5'd2 }:
//              bias_state_d = BIAS_LEVEL9_conv1;
//            {5'b????? , 5'd3 }:
//              bias_state_d = BIAS_LEVEL9_conv1;
//            {5'd2 , 5'd4 }:
//              bias_state_d = obuf_zero_q? BIAS_LEVEL458 : BIAS_LEVEL1;//12 58 
//            {5'd2 , 5'd5 }:
//              bias_state_d = BIAS_LEVEL3;//BIAS_LEVEL2;
//            {5'd3 , 5'd5 }:
//              bias_state_d = BIAS_LEVEL3; 
//            {5'd3 , 5'd4 }:
//              bias_state_d = BIAS_LEVEL458;
//            {5'd4 , 5'd4 }:
//              bias_state_d = BIAS_LEVEL458;
//            {5'd1 , 5'd4 }:
//              bias_state_d = BIAS_LEVEL1;
//            {5'd4 , 5'd5}:
//              bias_state_d = BIAS_LEVEL3;
//            {5'd1 , 5'd5}:
//              bias_state_d = BIAS_LEVEL3;
//            default: 
//              bias_state_d = BIAS_LAYER_JUDGE;
//          endcase
//        end
//      end

//      BIAS_LEVEL1: begin//3
//        if(com_loop_exit && (com_loop_index=='d2) )begin
//          obuf_bias_sel_out_reg = 1'b1;//select obuf
//        end
//        else if(done)begin
//          //obuf_bias_sel_out_reg = 1'b0;//select bias
//          bias_state_d = GET_ITER_INFO;
//        end
//        else if(compute_done_dly && (bias_init_read_data==0) )//edit yt
//          obuf_bias_sel_out_reg = 0;

//      end

//      BIAS_LEVEL2: begin//4
//        if(done && obuf_zero_q)
//          bias_state_d = BIAS_sound_sp;
//        else if(com_loop_exit)begin
//          if(com_loop_index=='d4)begin
//            bias_state_d = GET_ITER_INFO;
//            obuf_bias_sel_out_reg = 1'b0;
//          end
//          else if(com_loop_index=='d2)
//            obuf_bias_sel_out_reg = 1'b1;//select obuf
//        end
//        // else if(compute_done_dly && (bias_init_read_data==0) )begin//edit yt
//        //   obuf_bias_sel_out_reg = 0;
//        // end
//      end

//      BIAS_sound_sp: begin//8
//        if(compute_done_dly && (bias_init_read_data==0) )begin//edit yt
//          obuf_bias_sel_out_reg = 0;
//          bias_state_d = GET_ITER_INFO;
//        end
//      end

//      BIAS_LEVEL3: begin//7
//        if(done)begin
//          if(iter_cnter_q == 'b0)begin
//            bias_state_d = GET_ITER_INFO;
//            //obuf_bias_sel_out_reg = 1'b0;//select bias
//            iter_cnter_d = iter_value_q;
//          end
//          else
//            iter_cnter_d = iter_cnter_q - 1'b1;
//        end
//        else if(com_loop_index =='d4 && com_loop_exit && level3_enable)begin
//          obuf_bias_sel_out_reg = 1'b0;//select bias
//          bias_state_d = GET_ITER_INFO;
//        end
//        else if(com_loop_index == 2'd2 && com_loop_exit)
//          obuf_bias_sel_out_reg = 1'b1;//select obuf
//        else if(compute_done_dly && (bias_init_read_data==0) )begin//edit yt
//          obuf_bias_sel_out_reg = 0;
//          bias_state_d = GET_ITER_INFO;
//        end
//      end


//      BIAS_LEVEL458: begin//5
//        if(done)begin
//          if(iter_cnter_q == 'b0)begin
//            bias_state_d = GET_ITER_INFO;
//            //obuf_bias_sel_out_reg = 1'b0;//select bias
//            iter_cnter_d = iter_value_q;
//          end
//          else
//            iter_cnter_d = iter_cnter_q - 1'b1;
//        end
//        else if(com_loop_exit && (com_loop_index=='d2) )
//          obuf_bias_sel_out_reg = 1'b1;//select obuf
//        else if(compute_done_dly && (bias_init_read_data==0) )begin//edit yt
//          bias_state_d = GET_ITER_INFO;
//          obuf_bias_sel_out_reg = 0;
//        end
//      end


//      BIAS_LEVEL9_conv1: begin//6
//        if(done)begin
//          if(iter_cnter_q == iter_value_q)begin
//            obuf_bias_sel_out_reg = 1'b1;//select bias
//            iter_cnter_d = iter_cnter_q - 1'b1;
//          end
//          else if(iter_cnter_q > 'b0)
//            iter_cnter_d = iter_cnter_q - 1'b1;
//          else if(iter_cnter_q == 'b0)begin
//            bias_state_d = GET_ITER_INFO;
//            //obuf_bias_sel_out_reg = 1'b0;//select bias
//            iter_cnter_d = iter_value_q;
//          end
//        end
//        else if(compute_done_dly && (bias_init_read_data==0) )//edit yt
//          obuf_bias_sel_out_reg = 0;
//      end
      
//    endcase//case (bias_state_q)
//  end//always @(*) begin
//================================
//TEST AREA
  reg fresh_round;
  reg skip_once;
  reg [OBUF_ADDR_WIDTH -1:0] addr_array[32];

  wire end_of_block ;
  wire new_bias_addr;
  wire write_req;
  reg  write_req_dly;
  reg  [ OBUF_ADDR_WIDTH      -1 : 0 ]        obuf_ld_addr_dly;  

  reg [5             -1:0]   write_ptr;
  wire[5             -1:0]   read_ptr;
  reg test_sel_out;



//================================================================================
  assign write_req = fresh_round && write_ptr == bias_ld_addr && base_loop_enter_dly;//obuf_ld_addr_v ;
  assign new_bias_addr = bbuf_base_addr_last != bias_ld_addr ;//&& bias_ld_addr_v;
  assign end_of_block = compute_done_dly && (bias_init_read_data==0) ;
  assign read_ptr = write_ptr==0 ? 0 :write_ptr -1;
  //添加obuf的第一个地址进去，跟0地址相同的时候拉高
  //读read—dly且data=0 写地址回溯，回到第一行

  assign obuf_bias_sel_out =  (current_layer ==1&&(~i_is_run_adnn))? 0:  test_sel_out;

  always@(posedge clk)begin
    if(reset)
      write_req_dly <= 0;
    else
      write_req_dly <= write_req;
  end

  always@(posedge clk)begin
    if(reset)
      obuf_ld_addr_dly <= 0;
    else
      obuf_ld_addr_dly <= obuf_ld_addr;
  end

  always@(posedge clk)begin
    if(reset)
      skip_once <= 0;
    else if( (obuf_ld_addr==addr_array[0] || obuf_ld_addr == addr_array[read_ptr]) && obuf_ld_addr_v )
      skip_once <= 0;
    else if( write_req_dly==1 && obuf_ld_addr_dly == addr_array[read_ptr] && obuf_ld_addr_v)
      skip_once <= 0;
    else if(write_req)
      skip_once <= 1;
  end

  always@(posedge clk)begin
    if(reset)
      write_ptr <= 0;
    else if(end_of_block || cfg_loop_iter_v)
      write_ptr <= 0;
    else if(write_req)
      write_ptr <= write_ptr +1;
  end

  always@(posedge clk)begin
    if(reset)
      addr_array[0] <= 'd20;
    else if(end_of_block || cfg_loop_iter_v)
      addr_array[0] <= 'd20;
    else if(write_req)
      addr_array[write_ptr] <= bias_ld_addr;
  end



  always @(posedge clk) begin
    if (reset)
      test_sel_out <= 1'b0;
    else if(end_of_block || cfg_loop_iter_v || write_req)
      test_sel_out <= 1'b0;
    // else if(bbuf_base_addr_last != bias_ld_addr)
    //   test_sel_out <= 1'b0;
    else if(compute_done_dly)
      if(bias_init_read_data==0)
        test_sel_out <= 1'b0;
      else
        test_sel_out <= 1'b1;
    else if((obuf_ld_addr==addr_array[0] || obuf_ld_addr== addr_array[read_ptr]) && skip_once==0 )//raw ==first_addr
      test_sel_out <= 1'b1;

  end

  always @(posedge clk) begin
    if (reset)
      fresh_round <= 1'b0;
    else if(end_of_block || cfg_loop_iter_v || new_bias_addr)
      fresh_round <= 1'b1;
    else if (write_req)//(obuf_ld_addr_v && fresh_round == 1)
      fresh_round <= 1'b0;
  end



endmodule
