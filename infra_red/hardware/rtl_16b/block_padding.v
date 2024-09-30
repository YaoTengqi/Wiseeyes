//valid
//edit yt1106
`timescale 1ns/1ps
module block_padding #(
    parameter integer  IMM_WIDTH                    = 16,
    parameter integer  LOOP_ITER_W                  = 16
)(
    input wire                                  clk,
    input wire                                  reset,
    input wire                                  cfg_block_padding_v,        //from genpu_ctrl st
    input wire [ IMM_WIDTH         -1 : 0 ]     diff_rows,                   //from genpu_ctrl st
    input wire                                  cfg_loop_iter_st_v,         //from ldst_ddr
    input wire                                  cfg_loop_iter_st1_v,         //from ldst_ddr
    (*MARK_DEBUG ="true"*)input wire [ LOOP_ITER_W       -1 : 0 ]     cfg_loop_iter_st,           //from ldst_ddr
    input wire                                  st_addr_valid_pd, //ctrl
    input wire                                  data_valid,
    input wire                                  addr_valid,
    input wire                                  upsample_required, 
    output wire                                 block_required,
    output wire                                 all_done,
    output wire                                 data_need_blocking,
    output wire                                 block_data,
    output wire                                 block_mask                  //output 1 for blocking
);

    localparam integer  IMAGE_UP_PART                 = 0;
    localparam integer  IMAGE_DOWN_PART               = 1;
    (*MARK_DEBUG ="true"*)reg     [ IMM_WIDTH             -1    : 0 ]     rows_diff=0;
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W           -1    : 0 ]     width_st=0; //cols - after padding
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W           -1    : 0 ]     height_st=0;//rows - after
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W           -1    : 0 ]     oc_st=0;//rows - after
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W           -1    : 0 ]     width_st_q=0; //cols - after padding
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W           -1    : 0 ]     height_st_q=0;//rows - after
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W           -1    : 0 ]     oc_st_q=0;//rows - after 
    
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W*2         -1    : 0 ]     data_legal_points=0;//rows left
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W*2         -1    : 0 ]     addr_legal_points=0;//rows left

    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W*2         -1    : 0 ]     data_full_points=0;//rows left
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W*2         -1    : 0 ]     addr_full_points=0;//rows left

    (*MARK_DEBUG ="true"*)reg     [ 3                     -1    : 0 ]     state_d=0;
    (*MARK_DEBUG ="true"*)reg     [ 3                     -1    : 0 ]     state_q=0; 


    //wire                                            block_required;
    wire                                            st0_addr_down_up_judge;//after up image valid sent, counter[0] = 1 , after down sent counter[0]= 0
    wire                                            st0_data_down_up_judge;
    wire                                            st1_addr_down_up_judge;//after up image valid sent, counter[0] = 1 , after down sent counter[0]= 0
    wire                                            st1_data_down_up_judge;

    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W*2         -1    : 0 ]     st0_addr_cnt=0;//rows left
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W*2         -1    : 0 ]     st1_addr_cnt=0;//rows left
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W*2         -1    : 0 ]     st0_data_cnt=0;//rows left
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W*2         -1    : 0 ]     st1_data_cnt=0;//rows left
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W           -1    : 0 ]     oc_addr_cnt=0;//rows - after
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W           -1    : 0 ]     oc_data_cnt=0;//rows - after
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W           -1    : 0 ]     tmp_addr_cnt=0;
    (*MARK_DEBUG ="true"*)reg     [ LOOP_ITER_W           -1    : 0 ]     tmp_data_cnt=0;
    (*MARK_DEBUG ="true"*)reg                                             st1_exist=0;
    //if st1_exist: pooling+branch
    //else: pooling or conv
    (*MARK_DEBUG ="true"*)wire                                            block_data_8b;

    (*MARK_DEBUG ="true"*)wire                                            block_addr_8b;


//=============================================================
    assign st0_addr_down_up_judge = st0_addr_cnt[0];
    assign st0_data_down_up_judge = st0_data_cnt[0];
    assign st1_addr_down_up_judge = st1_addr_cnt[0];
    assign st1_data_down_up_judge = st1_data_cnt[0]; 
    assign all_done = oc_data_cnt > oc_st_q;
    assign data_need_blocking = st0_data_cnt > data_legal_points;

    assign block_required = rows_diff != 'd0 ;

    //8b考虑上下图片
    assign block_data_8b = (st0_data_cnt >= data_legal_points && (st0_data_down_up_judge == IMAGE_DOWN_PART) || st1_data_cnt >= data_legal_points*4 && (st1_data_down_up_judge == IMAGE_DOWN_PART) ) && block_required   && (oc_data_cnt <= oc_st);
    assign block_data = block_data_8b ;

    assign block_addr_8b = (st0_addr_cnt >= addr_legal_points && (st0_addr_down_up_judge == IMAGE_DOWN_PART) || st1_addr_cnt >= addr_legal_points*4 && (st1_addr_down_up_judge == IMAGE_DOWN_PART) ) && block_required   && (oc_addr_cnt <= oc_st); // >= not >
    assign block_mask = block_addr_8b ;
//=============================================================
// data selection/ counters
//=============================================================

    always @(posedge clk ) begin
        if(reset)
            tmp_addr_cnt <= 0;
        else if(cfg_block_padding_v)
            tmp_addr_cnt <= 0;
        else if(st1_exist == 1'b1 )begin//&& choose_8bit == 1'b1)begin//8b
            if(addr_valid) begin// && (tmp_addr_cnt <= 9) )begin
                tmp_addr_cnt <= tmp_addr_cnt + 1'd1;
            end
            else if(tmp_addr_cnt >= 'd10)begin
                tmp_addr_cnt <= tmp_addr_cnt - 'd10;
            end  
            // else if(addr_valid && (tmp_addr_cnt == 8 || tmp_addr_cnt==9) )begin
            //     tmp_addr_cnt <= tmp_addr_cnt + 1'd1;
            // end

        end
    end

    always @(posedge clk ) begin
        if(reset)
            st0_addr_cnt <= 0;
        else if(cfg_block_padding_v || st_addr_valid_pd || st0_addr_cnt == addr_full_points)begin
            st0_addr_cnt <= 1'b0;
        end
        else if(addr_valid && st1_exist == 1'b0)begin
            st0_addr_cnt <= st0_addr_cnt + 1'd1;
        end
        else if(st1_exist == 1'b1  && addr_valid && ( tmp_addr_cnt == 8 || tmp_addr_cnt==9))begin //8 1000  --- 9 1001 --- 10 1010
            st0_addr_cnt <= st0_addr_cnt + 1'd1;
        end
        // else if(st0_addr_cnt == full_points)begin //for oc change
        //     st0_addr_cnt <= 0;
        // end

    end

    always @(posedge clk ) begin
        if(reset)
            st1_addr_cnt <= 0;
        else if(cfg_block_padding_v || st_addr_valid_pd || st1_addr_cnt == addr_full_points*4)begin
            st1_addr_cnt <= 1'b0;
        end
        else if(st1_exist == 1'b1 && addr_valid && (tmp_addr_cnt != 8 && tmp_addr_cnt != 9) )begin
            st1_addr_cnt <= st1_addr_cnt + 1'd1;
        end
        // else if(st1_addr_cnt == full_points*4)begin //for oc change
        //     st1_addr_cnt <= 0;
        // end
    end



    always @(posedge clk ) begin
        if(reset)
            tmp_data_cnt <= 0;
        else if(cfg_block_padding_v)
            tmp_data_cnt <= 0;
        else if(st1_exist == 1'b1)begin 
             if(data_valid)begin// && (tmp_data_cnt <= 9) )begin
                tmp_data_cnt <= tmp_data_cnt + 1'd1;
            end
            else if(tmp_data_cnt >= 'd10)begin
                tmp_data_cnt <= tmp_data_cnt -  'd10;
            end
            //else if(data_valid && (tmp_data_cnt == 8 || tmp_data_cnt==9) )begin
            //    tmp_data_cnt <= tmp_data_cnt + 1'd1;
            //end
        end
    end

    always @(posedge clk ) begin
        if(reset)
            st0_data_cnt <= 0;
        else if(cfg_block_padding_v ||st_addr_valid_pd || st0_data_cnt == data_full_points)begin
            st0_data_cnt <= 1'b0;
        end
        else if(data_valid && st1_exist == 1'b0)begin
            st0_data_cnt <= st0_data_cnt + 1'd1;
        end
        else if(st1_exist == 1'b1 && data_valid && (tmp_data_cnt == 8 || tmp_data_cnt==9)  )begin
            st0_data_cnt <= st0_data_cnt + 1'd1;
        end
        // else if(st0_data_cnt == full_points)begin //for oc change
        //   st0_data_cnt <= 1'b0;
        // end

    end

    always @(posedge clk ) begin
        if(reset)
            st1_data_cnt <= 0;
        else if(cfg_block_padding_v ||st_addr_valid_pd || st1_data_cnt == data_full_points*4)begin
            st1_data_cnt <= 1'b0;
        end
        else if(st1_exist == 1'b1 && data_valid && (tmp_data_cnt != 8 && tmp_data_cnt != 9) )begin
            st1_data_cnt <= st1_data_cnt + 1'd1;
        end
        // else if(st1_data_cnt == full_points*4)begin //for oc change
        //   st1_data_cnt <= 1'b0;
        // end
    end



    always @(posedge clk ) begin
        if(reset)
            oc_addr_cnt <= 1'd0;
        else if(cfg_block_padding_v || st_addr_valid_pd)begin
            oc_addr_cnt <= 1'd0;
        end
        else if(st0_addr_cnt == addr_full_points)begin //for oc change
          oc_addr_cnt <= oc_addr_cnt + 1'd1;
        end
    end


    always @(posedge clk ) begin
        if(reset)
            oc_data_cnt <= 1'b0;
        else if(cfg_block_padding_v ||st_addr_valid_pd)begin
            oc_data_cnt <= 1'b0;
        end
        else if(st0_data_cnt == data_full_points)begin //for oc change
          oc_data_cnt <= oc_data_cnt + 1'd1;
        end
    end




    //================================================================================================================
    //CFG
    always @(posedge clk ) begin
        if(reset)
            st1_exist <= 1'b0;
        else if(cfg_loop_iter_st_v)begin
            st1_exist <= 1'd0;
        end
        else if(cfg_loop_iter_st1_v) begin
            st1_exist <= 1'd1;
        end
    end

    always @(posedge clk ) begin
        if(state_q == 'd4)begin
            data_legal_points <= width_st_q * ( height_st_q - rows_diff ) * 2'd2;//width_st * ( height_st - rows_diff ) * 2'd2;
            data_full_points <= width_st_q * height_st_q * 2'd2;
            addr_legal_points <= width_st_q * ( height_st_q - rows_diff ) * (2'd2 + upsample_required * 'd6) ;//width_st * ( height_st - rows_diff ) * 2'd2;
            addr_full_points <= width_st_q * height_st_q *  (2'd2 + upsample_required * 'd6);
        end
    end

    always @(posedge clk ) begin
        if(reset)
            rows_diff <= 0;
        if(cfg_block_padding_v)begin
            rows_diff <= diff_rows;
        end
    end

//    always @(posedge clk) begin
//        state_q <= state_d;
//        width_st_q <= width_st;
//        height_st_q <= height_st;
//        oc_st_q <= oc_st;
//    end

    always @(posedge clk ) begin
        if(reset)begin
            width_st_q <= 0;
        end
        else if(cfg_block_padding_v)
            width_st_q <=0;
        else
            width_st_q <= width_st;
    end
    
    always @(posedge clk ) begin
        if(reset)begin
            height_st_q <= 0;
        end
        else if(cfg_block_padding_v)
            height_st_q <=0;
        else
            height_st_q <= height_st;
    end
    
    always @(posedge clk ) begin
        if(reset)begin
            state_q <= 0;
        end
        else if(cfg_block_padding_v)
            state_q <=0;
        else
            state_q <= state_d;
    end
    
    always @(posedge clk ) begin
        if(reset)begin
            oc_st_q <= 0;
        end
        else if(cfg_block_padding_v)
            oc_st_q <=0;
        else
            oc_st_q <= oc_st;
    end
    
    //get loop cfg of st in ldst_ddr_wrapper
    //state 5 and 6 for upsample loop cfg specially
    always @(*) begin
        state_d = state_q;
        width_st = width_st_q;
        height_st = height_st_q;
        oc_st = oc_st_q;
        case (state_q)
        0: begin//up down
            if(upsample_required == 1'b1 && cfg_loop_iter_st_v)begin
                state_d = 3'd5;
            end
            else if(upsample_required == 1'b0 && cfg_loop_iter_st_v)begin
                state_d = 3'd1;
            end
        end
        1: begin//width
            if(cfg_loop_iter_st_v)begin
                state_d = 3'd2;
                width_st = cfg_loop_iter_st + 1'd1;
            end
        end
        2:begin//height
            if(cfg_loop_iter_st_v)begin
                state_d = 3'd3;
                height_st = cfg_loop_iter_st + 1'd1;
            end
        end
        3:begin//oc
            if(cfg_loop_iter_st_v)begin
                state_d = 3'd4;
                oc_st = cfg_loop_iter_st ;
            end
        end
        4:begin//b
            if(cfg_loop_iter_st_v)begin
                state_d = 3'd0;
            end
        end
        5:begin//upsample right
            if(cfg_loop_iter_st_v)begin
                state_d = 3'd6;
            end
        end
        6:begin//upsample left
            if(cfg_loop_iter_st_v)begin
                state_d = 3'd1;
            end
        end
        endcase//case (state_q)
    end//always @(*) begin
//=============================================================

    

endmodule






