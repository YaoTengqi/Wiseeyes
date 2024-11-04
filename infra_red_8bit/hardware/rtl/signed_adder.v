//
// Signed Adder
// Implements: out = a + b
//
// Hardik Sharma
// (hsharma@gatech.edu)

`timescale 1ns/1ps
module signed_adder #(
    parameter integer  DTYPE                        = "FXP",
    parameter          REGISTER_OUTPUT              = "FALSE",
    parameter integer  IN1_WIDTH                    = 20,
    parameter integer  IN2_WIDTH                    = 32,
    parameter integer  OUT_WIDTH                    = 32
) (
    input  wire                                         clk,
    input  wire                                         reset,
    input  wire                                         enable,
    input  wire                                         choose_8bit,
    input  wire  [ IN1_WIDTH            -1 : 0 ]        a,
    input  wire  [ IN2_WIDTH            -1 : 0 ]        b,
    output wire  [ OUT_WIDTH            -1 : 0 ]        out
  );

  generate
    if (DTYPE == "FXP") begin
      reg signed [ OUT_WIDTH-1:0] alu_out;
      reg signed [ OUT_WIDTH/2-1:0] alu_out1;
      reg signed [ OUT_WIDTH/2-1:0] alu_out2;
      wire signed [IN1_WIDTH/2-1 : 0] a1;
      wire signed [IN1_WIDTH/2-1 : 0] a2;
      wire signed [IN2_WIDTH/2-1 : 0] b1;
      wire signed [IN2_WIDTH/2-1 : 0] b2;

      assign a1 = a[IN1_WIDTH/2-1 : 0];
      assign a2 = a[IN1_WIDTH-1:IN1_WIDTH/2];
      assign b1 = b[IN2_WIDTH/2-1 : 0];
      assign b2 = b[IN2_WIDTH-1:IN2_WIDTH/2];

      if (REGISTER_OUTPUT == "TRUE") begin
        always @(posedge clk)
        begin
          if (enable)
            alu_out1 <= a1 + b1;
            alu_out2 <= a2 + b2;              
            alu_out <= a + b;
        end
        assign out = choose_8bit ? {alu_out2,alu_out1} : alu_out;
      end 
        
    end

  endgenerate

endmodule
