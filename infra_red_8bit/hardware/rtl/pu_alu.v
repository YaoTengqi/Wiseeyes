`timescale 1ns / 1ps
//edit 0820
module pu_alu #(
    parameter integer  DATA_WIDTH                   = 16,
    parameter integer  ACC_DATA_WIDTH               = 64,
    parameter integer  HALF_ACC_DATA_WIDTH          = 32,
    parameter integer  IMM_WIDTH                    = 16,
    parameter integer  FN_WIDTH                     = 2
) (
    input  wire                                         clk,
    input  wire                                         fn_valid,
    input  wire        [ FN_WIDTH             -1 : 0 ]        fn,
    input  wire signed [ IMM_WIDTH            -1 : 0 ]        imm,
    input  wire signed [ ACC_DATA_WIDTH       -1 : 0 ]        obuf_data,
    input  wire                                         choose_8bit,//0-16b , 1-8b
    input  wire                                         cfg_rs_num_v,
    input  wire signed [ IMM_WIDTH            -1 : 0 ]        rshift_num,
    output wire  [ ACC_DATA_WIDTH       -1 : 0 ]        alu_out
);

    //edit yt
    reg  signed                       [ IMM_WIDTH                -1 : 0 ]        right_shift_imm=0;
    reg  signed                       [ ACC_DATA_WIDTH           -1 : 0 ]        alu_out_d=0;
    reg  signed [ ACC_DATA_WIDTH           -1 : 0 ]        alu_out_q=0;
    reg  signed [ ACC_DATA_WIDTH           -1 : 0 ]        alu_out_q_dly=0;
  // Instruction types
    //localparam integer  FN_NOP                      = 0;
    localparam integer  FN_MUL                      = 3;//FOR TC
    localparam integer  FN_CAL                      = 4;//FOR TC+RL
    localparam integer  FN_MAX                       = 5;



    wire signed [ HALF_ACC_DATA_WIDTH           -1 : 0 ]        _alu_in0_h32;
    wire signed [ HALF_ACC_DATA_WIDTH           -1 : 0 ]        _alu_in0_l32;

    wire signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_l;//32*16 => 48
    wire signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_l_all_bit;
    wire signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_l_ls;
    wire signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_l_rs;

    wire signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_h;
    wire signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_h_all_bit;
    wire signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_h_ls;
    wire signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_h_rs;

    wire signed[ ACC_DATA_WIDTH                           -1 : 0 ]        mul_out;

    wire signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_l_45;//32*16 => 48
    wire signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_h_45;//32*16 => 48

    wire                                                        out_range_l0;
    wire                                                        out_range_h0;
    wire                                                        out_range_l255;
    wire                                                        out_range_h255;

    wire                                                        out_range_ln;
    wire                                                        out_range_hn;
    wire                                                        out_range_lp;
    wire                                                        out_range_hp;//h/l neg&pos

    wire                                                        out_range_0_16;
    wire                                                        out_range_255_16;                                                   

    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        rshift_out_l;
    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        rshift_out_h;
    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        rshift_out_l_linear;
    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        rshift_out_h_linear;

    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        rshift_out0_l;
    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        rshift_out0_h;

    wire signed[ ACC_DATA_WIDTH                 -1 : 0 ]        rshift_out_16b;
    wire signed[ ACC_DATA_WIDTH                 -1 : 0 ]        rshift_out;

    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        relu_out_l;
    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        relu_out_h;
    wire signed[ ACC_DATA_WIDTH                 -1 : 0 ]        relu_out_16;
    wire signed[ ACC_DATA_WIDTH                 -1 : 0 ]        relu_out;

    reg  signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_l_45_d;//32*16 => 48
    reg  signed[ HALF_ACC_DATA_WIDTH+IMM_WIDTH            -1 : 0 ]        mul_out_h_45_d;//32*16 => 48

    assign _alu_in0_h32 = obuf_data[63:32]; 
    assign _alu_in0_l32 = obuf_data[31:0]; 
//======================================================================================
//===tc
    assign mul_out_l = _alu_in0_l32 *$signed( imm );
    assign mul_out_h = _alu_in0_h32 *$signed( imm );
    assign mul_out = obuf_data; //>>> right_shift_imm;

    assign mul_out_l_all_bit  = {48{mul_out_l[47]}};
    assign mul_out_h_all_bit  = {48{mul_out_h[47]}};
    assign mul_out_l_ls = mul_out_l_all_bit << (48-right_shift_imm);
    assign mul_out_h_ls = mul_out_h_all_bit << (48-right_shift_imm);
    assign mul_out_l_rs = {~mul_out_l[47],mul_out_l_ls[46:0]} >> (48-right_shift_imm);
    assign mul_out_h_rs = {~mul_out_h[47],mul_out_h_ls[46:0]} >> (48-right_shift_imm);

    // assign mul_out_l_45 =$signed( mul_out_l + {~mul_out_l[47], {19{mul_out_l[47]}}} );
    // assign mul_out_h_45 =$signed( mul_out_h + {~mul_out_h[47], {19{mul_out_h[47]}}} );
    assign mul_out_l_45 =$signed( mul_out_l + mul_out_l_rs );
    assign mul_out_h_45 =$signed( mul_out_h + mul_out_h_rs );

    always @(posedge clk)begin
    	mul_out_l_45_d   <=  mul_out_l_45 ;
    	mul_out_h_45_d   <=  mul_out_h_45 ;
    end
    
    assign rshift_out_l = mul_out_l_45_d >>> right_shift_imm;//>>> 'd20;
    assign rshift_out_h = mul_out_h_45_d >>> right_shift_imm;//'d20;

    assign rshift_out_l_linear = out_range_ln? $signed(-128) : out_range_lp ? $signed (127) : rshift_out_l; 
    assign rshift_out_h_linear = out_range_hn? $signed(-128) : out_range_hp ? $signed (127) : rshift_out_h; 

    assign rshift_out_16b = mul_out >>> right_shift_imm;
    // assign rshift_out = choose_8bit ? {rshift_out_h , rshift_out_l} :  rshift_out_16b;
    assign rshift_out = choose_8bit ? {rshift_out_h_linear , rshift_out_l_linear} :  rshift_out_16b;
//======================================================================================
//===relu
    assign out_range_l0 = rshift_out_l < $signed(0);
    assign out_range_h0 = rshift_out_h < $signed(0);
    assign out_range_l255 = rshift_out_l > $signed(255);
    assign out_range_h255 = rshift_out_h > $signed(255);
    assign out_range_0_16 = rshift_out_16b < $signed(0);
    assign out_range_ln = rshift_out_l < $signed(-128);
    assign out_range_hn = rshift_out_h < $signed(-128);
    assign out_range_lp = rshift_out_l > $signed(127);
    assign out_range_hp = rshift_out_h > $signed(127);

    assign out_range_255_16 = rshift_out_16b > $signed(65535);

    assign relu_out_l = out_range_l0 ? 0 : (out_range_l255 ? 255 : rshift_out_l );
    assign relu_out_h = out_range_h0 ? 0 : (out_range_h255 ? 255 : rshift_out_h ); 
    assign relu_out_16 = out_range_0_16 ? 0 : out_range_255_16 ? 255 : rshift_out_16b; //>>> right_shift_imm;
    assign relu_out = choose_8bit ? {relu_out_h , relu_out_l} : relu_out_16;

//======================================================================================
//===rmax
    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        max_out_l;
    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        max_out_h;
    wire signed[ ACC_DATA_WIDTH                 -1 : 0 ]        max_out_16;
    wire signed[ ACC_DATA_WIDTH                 -1 : 0 ]        max_out;


    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        alu_out_q_l;
    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        alu_out_q_h;
    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        alu_out_q_dly_l;
    wire signed[ HALF_ACC_DATA_WIDTH            -1 : 0 ]        alu_out_q_dly_h;

    assign alu_out_q_l = alu_out_q [31:0];
    assign alu_out_q_h = alu_out_q [63:32];

    assign alu_out_q_dly_l = alu_out_q_dly [31:0];
    assign alu_out_q_dly_h = alu_out_q_dly [63:32];

    assign max_out_l = alu_out_q_l > alu_out_q_dly_l ? alu_out_q_l : alu_out_q_dly_l;
    assign max_out_h = alu_out_q_h > alu_out_q_dly_h ? alu_out_q_h : alu_out_q_dly_h;
    assign max_out = choose_8bit ? {max_out_h , max_out_l} : max_out_16;
    assign max_out_16 = alu_out_q > alu_out_q_dly ? alu_out_q : alu_out_q_dly;
//=============================================================================================

    always @(posedge clk)begin
      if(cfg_rs_num_v)
        right_shift_imm <= rshift_num;
    end

    wire [ FN_WIDTH             -1 : 0 ] fn_dly1;
    register_sync_with_enable #(FN_WIDTH) fn_dly
    (clk, reset, 1'b1, fn, fn_dly1);

    always @(*)
    begin
      case (fn_dly1)
        FN_CAL: alu_out_d = relu_out;
        FN_MUL: alu_out_d = rshift_out;
        FN_MAX: alu_out_d = max_out;
        default: alu_out_d = 'b0;
      endcase
    end

    wire fn_valid_dly1;
    register_sync_with_enable #(1) fn_valid_dly
    (clk, reset, 1'b1, fn_valid, fn_valid_dly1);

    always @(posedge clk)
    begin
      if (fn_valid_dly1)
        alu_out_q <= alu_out_d;
    end

    always @(posedge clk ) begin
      if (fn_valid_dly1)
        alu_out_q_dly <= alu_out_q;
    end


    assign alu_out = alu_out_q;
endmodule

