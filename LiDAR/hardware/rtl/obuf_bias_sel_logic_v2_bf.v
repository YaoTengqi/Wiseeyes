//edit yt 
//edit time: 0810
`timescale 1ns/1ps
module obuf_bias_sel_logic_v2 #(
    parameter integer  LOOP_ID_W                    = 5,
    parameter integer  ADDR_STRIDE_W                = 16,
    parameter integer  ADDR_STRIDE_W_BASE           = 32
) (
    input  wire                                         clk,
    input  wire                                         reset,
    input  wire                                         done,
    input  wire                                         compute_done,
    input  wire                                         com_loop_exit,
    input  wire                                         base_obuf_stride_v,
    input  wire                                         com_obuf_stride_v, 
    input  wire                                         com_cfg_loop_iter_v, 
    input  wire  [ ADDR_STRIDE_W        -1 : 0 ]        com_obuf_stride,
    input  wire  [ ADDR_STRIDE_W_BASE   -1 : 0 ]        base_obuf_stride,
    input  wire  [ LOOP_ID_W            -1 : 0 ]        com_loop_index,
    output wire                                         obuf_bias_sel_out 
);
    reg  [ LOOP_ID_W            -1 : 0 ]        base_loop_id;
    reg  [ LOOP_ID_W            -1 : 0 ]        base_loop_id_stable;
    reg  [ LOOP_ID_W            -1 : 0 ]        com_loop_id;
    reg  [ LOOP_ID_W            -1 : 0 ]        com_loop_id_stable;
    reg                                         obuf_bias_sel_out_reg=1'b0;
    reg                                         obuf_bias_sel_out_reg_dly=1'b0;
    

    assign obuf_bias_sel_out = obuf_bias_sel_out_reg_dly;

    always @(posedge clk ) begin
      if(reset)
        obuf_bias_sel_out_reg_dly <= 1'b0;
      else
        obuf_bias_sel_out_reg_dly <= obuf_bias_sel_out_reg;
    end
//=============================================================
// base/com_loop_id transit logic
//=============================================================
    always @(posedge clk)
    begin
      if (reset)
        base_loop_id <= 1'b0;
      else if (done) 
        base_loop_id <= 1'b0;
      else if (base_obuf_stride_v)
        base_loop_id <= base_loop_id + 1'b1;
    end
    
    always @(posedge clk)
    begin
      if(base_loop_id != 1'b0)
          base_loop_id_stable <= base_loop_id;
    end

    always @(posedge clk)
    begin
      if (reset)
        com_loop_id <= 1'b0;
      else if (done)
        com_loop_id <= 1'b0;
      else if (com_obuf_stride_v)
        com_loop_id <= com_loop_id + 1'b1;
    end
    
    always @(posedge clk)
    begin
      if(com_loop_id != 1'b0)
        com_loop_id_stable <= com_loop_id;
    end
    

//=============================================================
// Capture first value of obuf_v_stride using base_obuf_stride_v
//=============================================================
    reg obuf_zero = 1'b0;
    reg enable_obuf = 1'b1;
    always @(posedge clk) begin
      if(reset || done)
        enable_obuf <= 1'b1;
      else if(base_obuf_stride_v && enable_obuf)
        enable_obuf <= 1'b0;//set enable to 0 and save first obuf_stride value 
    end

    always @(posedge clk) begin
      if(base_obuf_stride_v && enable_obuf)begin
        if(base_obuf_stride == 'b0)
          obuf_zero <= 1'b1;
        else
          obuf_zero <= 1'b0;
      end
    end
//=============================================================


//=============================================================
// Capture first value of obuf_v_stride using com_cfg_loop_iter_v
//=============================================================
    reg                                  enable_cfg_obuf = 1'b1;
    reg [ ADDR_STRIDE_W        -1 : 0 ]  iter_value = 'b0;
    reg [ ADDR_STRIDE_W        -1 : 0 ]  iter_cnter = 'b0;

   always @(posedge clk) begin
    if(reset || done)begin
        enable_cfg_obuf <= 1'b1;
    end else if(com_cfg_loop_iter_v && enable_cfg_obuf)begin
        enable_cfg_obuf <= 1'b0;//set enable to 0 and save first obuf_stride value 
    end
   end

    always @(posedge clk) begin
      if(reset)
        iter_value <= 'b0;
      else if(com_cfg_loop_iter_v && enable_cfg_obuf)
        iter_value <= com_obuf_stride;
    end
//=============================================================


//=============================================================
// Level case select  
//=============================================================
    always @(posedge clk) begin
      if(com_cfg_loop_iter_v && enable_cfg_obuf)begin
        iter_cnter <= com_obuf_stride;
      end
      else if(base_loop_id_stable == 'd2 && com_loop_id_stable == 'd4)begin
        //level 1,2,5,6,7,8
        if(obuf_zero)begin
          //level 5678
          if(compute_done)begin
            if(iter_cnter == 'b0)begin
              obuf_bias_sel_out_reg <= 1'b0;//select bias
              iter_cnter <= iter_value;
            end
            else
              iter_cnter <= iter_cnter - 1'b1;
          end
          else if(com_loop_exit && com_loop_index=='d2)
            obuf_bias_sel_out_reg <= 1'b1;//select obuf
        end
        else begin
          //level 12
          if(compute_done)
            obuf_bias_sel_out_reg <= 1'b0;//select bias
          else if(com_loop_exit && com_loop_index=='d2)
            obuf_bias_sel_out_reg <= 1'b1;//select obuf
        end

      end
      else if (base_loop_id_stable == 'd2 && com_loop_id_stable == 'd5) begin
        //level 3
        if(com_loop_exit)begin
          if(com_loop_index =='d4)
            obuf_bias_sel_out_reg <= 1'b0;//select bias
          else if(com_loop_index == 'd2)
            obuf_bias_sel_out_reg <= 1'b1;//select obuf
        end
      end
      else if (base_loop_id_stable == 'd4 && com_loop_id_stable == 'd4) begin
        //level 4
        if(compute_done)begin
          if(iter_cnter == 'b0)begin
            obuf_bias_sel_out_reg <= 1'b0;//select bias
            iter_cnter <= iter_value;
          end
          else
            iter_cnter <= iter_cnter - 1'b1;
        end
        else if(com_loop_exit && com_loop_index=='d2)
          obuf_bias_sel_out_reg <= 1'b1;//select obuf
      end
      else if (com_loop_id_stable == 'd2 || com_loop_id_stable == 'd3) begin
        //level 9 and yolov4 kernel=1 case
        if(compute_done)begin
          if(iter_cnter == iter_value)begin
            obuf_bias_sel_out_reg <= 1'b1;//select bias
            iter_cnter <= iter_cnter - 1'b1;
          end
          else if(iter_cnter > 'b0)
            iter_cnter <= iter_cnter - 1'b1;
          else if(iter_cnter == 'b0)begin
            obuf_bias_sel_out_reg <= 1'b0;//select bias
            iter_cnter <= iter_value;
          end
        end
      end

      else if (base_loop_id_stable == 'd3 && com_loop_id_stable == 'd4) begin
        //level 4
        if(compute_done)begin
          if(iter_cnter == 'b0)begin
            obuf_bias_sel_out_reg <= 1'b0;//select bias
            iter_cnter <= iter_value;
          end
          else
            iter_cnter <= iter_cnter - 1'b1;
        end
        else if(com_loop_exit && com_loop_index=='d2)
          obuf_bias_sel_out_reg <= 1'b1;//select obuf
      end
      else if( base_loop_id_stable == 'd3 && com_loop_id_stable == 'd5) begin
        if(compute_done)begin
          if(iter_cnter == 'b0)begin
            obuf_bias_sel_out_reg <= 1'b0;//select bias
            iter_cnter <= iter_value;
          end
          else
            iter_cnter <= iter_cnter - 1'b1;
        end
        else if(com_loop_exit && com_loop_index=='d4 && (iter_cnter == iter_value))
          obuf_bias_sel_out_reg <= 1'b0;//select bias
        else if(com_loop_exit && com_loop_index=='d2)
          obuf_bias_sel_out_reg <= 1'b1;//select obuf
      end
      else if( base_loop_id_stable == 'd4 && com_loop_id_stable == 'd5) begin
        if(compute_done)begin
          if(iter_cnter == 'b0)begin
            obuf_bias_sel_out_reg <= 1'b0;//select bias
            iter_cnter <= iter_value;
          end
          else
            iter_cnter <= iter_cnter - 1'b1;
        end
        else if(com_loop_exit && com_loop_index=='d4 && (iter_cnter == iter_value))
          obuf_bias_sel_out_reg <= 1'b0;//select bias
        else if(com_loop_exit && com_loop_index=='d2)
          obuf_bias_sel_out_reg <= 1'b1;//select obuf
      end
      else if (base_loop_id_stable == 'd1 && com_loop_id_stable == 'd4) begin
        //level 3
        if(compute_done)
          obuf_bias_sel_out_reg <= 1'b0;//select bias
        else if(com_loop_index == 'd2 && com_loop_exit)
          obuf_bias_sel_out_reg <= 1'b1;//select obuf
      end


    end
//=============================================================

endmodule