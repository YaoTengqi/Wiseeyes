`timescale 1ns / 1ps
module pu_alu #(
    parameter integer  DATA_WIDTH                   = 16,
    parameter integer  ACC_DATA_WIDTH               = 64,
    parameter integer  IMM_WIDTH                    = 16,
    parameter integer  FN_WIDTH                     = 2
) (
    input  wire                                         clk,
    input  wire                                         fn_valid,
    input  wire  [ FN_WIDTH             -1 : 0 ]        fn,
    input  wire  [ IMM_WIDTH            -1 : 0 ]        imm,
    input  wire  [ ACC_DATA_WIDTH       -1 : 0 ]        alu_in0,
    input  wire                                         alu_in1_src,
    input  wire  [ DATA_WIDTH           -1 : 0 ]        alu_in1,
    output wire  [ ACC_DATA_WIDTH       -1 : 0 ]        alu_out
);

    reg  signed [ ACC_DATA_WIDTH           -1 : 0 ]        alu_out_d;
    reg  signed [ ACC_DATA_WIDTH           -1 : 0 ]        alu_out_q;

  // Instruction types
    localparam integer  FN_NOP                       = 0;
    localparam integer  FN_ADD                       = 1;
    localparam integer  FN_SUB                       = 2;
    localparam integer  FN_MUL                       = 3;
    localparam integer  FN_MVHI                      = 4;

    localparam integer  FN_MAX                       = 5;
    localparam integer  FN_MIN                       = 6;

    localparam integer  FN_RSHIFT                    = 7;

    wire signed [ DATA_WIDTH           -1 : 0 ]        _alu_in1;
    wire signed [ DATA_WIDTH           -1 : 0 ]        _alu_in0;

    wire signed[ ACC_DATA_WIDTH           -1 : 0 ]        add_out;
    wire signed[ ACC_DATA_WIDTH           -1 : 0 ]        sub_out;
    wire signed[ ACC_DATA_WIDTH           -1 : 0 ]        mul_out;
    wire signed[ ACC_DATA_WIDTH           -1 : 0 ]        max_out;
    wire signed[ ACC_DATA_WIDTH           -1 : 0 ]        min_out;
    wire signed[ ACC_DATA_WIDTH           -1 : 0 ]        rshift_out;
    wire signed[ ACC_DATA_WIDTH       -1 : 0 ]        _rshift_out;
    wire [ DATA_WIDTH           -1 : 0 ]        mvhi_out;
    wire                                        gt_out;

    wire [ 5                    -1 : 0 ]        shift_amount;

    assign _alu_in1 = alu_in1_src ? imm : alu_in1;
    assign _alu_in0 = alu_in0;
    assign add_out = _alu_in0 + _alu_in1;
    assign sub_out = _alu_in0 - _alu_in1;
    assign mul_out = _alu_in0 * _alu_in1;
    assign gt_out = _alu_in0 > _alu_in1;
    assign max_out = gt_out ? _alu_in0 : _alu_in1;
    assign min_out = ~gt_out ? _alu_in0 : _alu_in1;
    assign mvhi_out = {imm, 16'b0};
//EDIT YT
    assign shift_amount = _alu_in1;

    assign _rshift_out = $signed(alu_in0) >>> shift_amount;

    wire signed [ DATA_WIDTH           -1 : 0 ]        _max;
    wire signed [ DATA_WIDTH           -1 : 0 ]        _min;
    wire                                        overflow;
    wire                                        sign;

    assign overflow = (_rshift_out > _max) || (_rshift_out < _min);
    assign sign = $signed(alu_in0) < 0;

    assign _max = (1 << (DATA_WIDTH - 1)) - 1;
    assign _min = -(1 << (DATA_WIDTH - 1));

    assign rshift_out = overflow ? sign ? _min : _max : _rshift_out;

    reg [ FN_WIDTH                    -1 : 0 ]        fn_dly1;
    reg [ FN_WIDTH                    -1 : 0 ]        fn_dly2;
    reg [10-1:0] amounts='h10;//{0+16}Shift_amounts_store
    reg [5-1:0] shift='d0;//Shift_amount
    reg need_shift='b0;
    wire [5                           -1 : 0 ]        shift_amount2;
    wire signed[ ACC_DATA_WIDTH       -1 : 0 ]        _rshift_out2;
    wire signed[ ACC_DATA_WIDTH       -1 : 0 ]        rshift_out2;
    wire                                              overflow2;
    wire                                              sign2;

    wire second_th = fn_dly2=='d3 && fn=='d3;
    always @(*) begin
      if(fn=='d2) begin
        need_shift <='b1;
        shift <= amounts[5+:5];//shift 0
        end
      else if(fn=='d3 && second_th=='b1)begin
        need_shift <='b1;
        shift <= amounts[0+:5];//shift 16d
        end
      else begin
        need_shift <='b0;
        shift <= 'd0;
      end
    end
    assign sign2 = $signed(alu_out_d) < 0;
    assign overflow2 = (_rshift_out2 > _max) || (_rshift_out2 < _min);
    assign shift_amount2 = shift;
    assign _rshift_out2 = alu_out_d >>> shift_amount2;
    assign rshift_out2 = overflow2 ? sign2 ? _min : _max : _rshift_out2;
//END


    always @(*)
    begin
      case (fn)
        FN_NOP: alu_out_d = alu_in0;
        FN_ADD: alu_out_d = add_out;
        FN_SUB: alu_out_d = sub_out;
        FN_MUL: alu_out_d = mul_out;
        FN_MVHI: alu_out_d = mvhi_out;
        FN_MAX: alu_out_d = max_out;
        FN_MIN: alu_out_d = min_out;
        FN_RSHIFT: alu_out_d = rshift_out;
        default: alu_out_d = 'bx;
      endcase
    end

    always @(posedge clk)
    begin
      if (fn_valid)
        begin                                                           //edit yt
          fn_dly2  <= fn_dly1;
          fn_dly1  <= fn;
          if(need_shift=='b1)begin
            alu_out_q <= rshift_out2;
          end
          else begin
            alu_out_q <= alu_out_d;
          end
          
      end
    end
      assign alu_out = alu_out_q;
endmodule

