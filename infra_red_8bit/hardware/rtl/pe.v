//
// Precision configurable PE
//
// Hardik Sharma
// (hsharma@gatech.edu)

`timescale 1ns/1ps
module pe #(
  parameter          PE_MODE                      = "FMA",
  parameter integer  ACT_WIDTH                    = 16,
  parameter integer  WGT_WIDTH                    = 16,
  parameter integer  ARRAY_N                      = 32,
  parameter integer  MULT_OUT_WIDTH               = ACT_WIDTH + WGT_WIDTH + 2,  
  parameter integer  WGT_WIDTH_8BIT               = 8,
  parameter integer  ACT_WIDTH_8BIT               = 8,
  parameter integer  MULT_IN_A_WIDTH               = 25,  
  parameter integer  MULT_OUT_8B_WIDTH            = WGT_WIDTH_8BIT + ACT_WIDTH_8BIT +$clog2(ARRAY_N),  
  parameter integer  PE_OUT_WIDTH                 = 48

) (
  input                                               clk,
  input                                               reset,
  input        [ ACT_WIDTH            -1 : 0 ]        a,
  input        [ WGT_WIDTH            -1 : 0 ]        b,
  input       signed [ PE_OUT_WIDTH   -1 : 0 ]        c,
  output wire  [ PE_OUT_WIDTH         -1 : 0 ]        out,
  input                                               choose_8bit  //0-16bit , 1-8bit
  //==================================================
);

  wire signed [ MULT_OUT_WIDTH        -1 : 0 ]        mult_out;
  wire signed [ PE_OUT_WIDTH          -1 : 0 ]        mult_out_input;

  wire signed [ MULT_IN_A_WIDTH             -1 : 0 ]        _a;
  wire signed [ WGT_WIDTH             -1 : 0 ]        _b; 

  wire  [MULT_IN_A_WIDTH              -1 : 0 ]        _8b_a;
  wire  [MULT_IN_A_WIDTH         -1 : 0 ]        _8b_a1;
  wire  [MULT_IN_A_WIDTH         -1 : 0 ]        _8b_a2;

  wire signed [ACT_WIDTH      -1 : 0 ]        result_8bit_1;
  wire signed [ACT_WIDTH      -1 : 0 ]        result_8bit_2;

  wire [ACT_WIDTH_8BIT -1 : 0 ] correct1; 
  wire [ACT_WIDTH_8BIT -1 : 0 ] correct2; 
  
  assign _8b_a1 = a[7:0];
  assign _8b_a = {a[15:8],9'b0,a[7:0]};

  assign _a = choose_8bit ? _8b_a : a;
  assign _b = b;
  
  assign mult_out = _a * _b;
  
  // assign correct1 = a[7] ? (mult_out[15:8] + b[7:0]) : mult_out[15:8];
  assign correct2 = a[15] ? (mult_out[32:25] + b[7:0]) : mult_out[32:25];

  // assign result_8bit_1 = {correct1 , mult_out[7:0]};
  assign result_8bit_1 = mult_out[15:0];
  assign result_8bit_2 = {correct2 , mult_out[24:17]} + mult_out[16];


  //test begin--------------------------------------------------------------------------------
  wire signed [ 24         -1 : 0 ]        out1;
  wire signed [ 24         -1 : 0 ]        out2;
  wire signed [ 8           : 0 ]        test_a1;
  wire signed [ 8           : 0 ]        test_a2;
  wire signed [ 8          -1 : 0 ]        test_b;
  wire signed [ 16          -1 : 0 ]       test_out1;
  wire signed [ 16          -1 : 0 ]       test_out2;
  wire signed [ 24         -1 : 0 ]        test_c1;
  wire signed [ 24         -1 : 0 ]        test_c2;
  reg signed [ 24         -1 : 0 ]        test_add_out1;
  reg signed [ 24         -1 : 0 ]        test_add_out2;    
  
  wire mult_result1;
  wire mult_result2;
  wire add_result1;
  wire add_result2;
  //mult
  assign test_a1 = {1'b0,a[7:0]};
  assign test_a2 = {1'b0,a[15:8]};
  assign test_b = b;
  assign test_out1 = test_a1 * test_b;
  assign test_out2 = test_a2 * test_b;
  assign mult_result1 = (result_8bit_1 == test_out1 ? 1'b1 : 1'b0)||(~choose_8bit);
  assign mult_result2 = (result_8bit_2 == test_out2 ? 1'b1 : 1'b0)||(~choose_8bit);
  //add
  assign test_c1=c[23:0];
  assign test_c2=c[47:24];
  
  always@(posedge clk)begin
    if(reset)begin
      test_add_out1<='b0;
      test_add_out2<='b0;
    end
    else begin
      test_add_out1<=test_out1+test_c1;
      test_add_out2<=test_out2+test_c2;
    end
  end  
   
  assign out1=$signed(out[23:0]);
  assign out2=$signed(out[47:24]);

  assign add_result1 = out1 == test_add_out1 ? 1'b1 : 1'b0;
  assign add_result2 = out2 == test_add_out2 ? 1'b1 : 1'b0;  
  //test end------------------------------------------------------------------------------------------


  wire signed [ PE_OUT_WIDTH/2         -1 : 0 ] c1;
  wire signed [ PE_OUT_WIDTH/2         -1 : 0 ] c2;
  reg  signed [ PE_OUT_WIDTH           -1 : 0 ] _out;
  reg signed [ PE_OUT_WIDTH/2         -1 : 0 ] _out1;
  reg signed [ PE_OUT_WIDTH/2         -1 : 0 ] _out2;
  assign c1 = c[PE_OUT_WIDTH/2-1 : 0];
  assign c2 = c[PE_OUT_WIDTH-1:PE_OUT_WIDTH/2];

  always@(posedge clk)begin
    if(reset)begin
      _out<='b0;
    end
    else if(choose_8bit)begin
      _out1 <= result_8bit_1 + c1;
      _out2 <= result_8bit_2 + c2;
    end
    else 
      _out <= mult_out + c;
  end
  assign out = choose_8bit ? {_out2,_out1} : _out;

endmodule


