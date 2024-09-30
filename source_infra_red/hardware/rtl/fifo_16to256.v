`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/17 09:45:12
// Design Name: 
// Module Name: fifo_16to256
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


module fifo_16to256 #(
       parameter integer IN_WIDTH    =16,
       parameter integer OUT_WIDTH   =256
)
(
     input                  clk,
     input                  reset,
     input                  clr,
     input                  force_out,
     input                  i_wr_req,
     input  [IN_WIDTH-1:0]  i_data,
     
     output                 o_rd_req,
     output [OUT_WIDTH-1:0] o_data
    );
    localparam             LP_INCNT_WIDTH   =$clog2(OUT_WIDTH/IN_WIDTH);
    
    reg [IN_WIDTH-1:0]       r_data[0:OUT_WIDTH/IN_WIDTH-1];
    
    reg [LP_INCNT_WIDTH-1:0] r_wr_cnt;
    wire                     w_out_chk; 
    reg                      r_outen_shr;
    wire [OUT_WIDTH-1:0] w_data;
    assign w_out_chk   = &r_wr_cnt;
    assign o_rd_req    = (!w_out_chk)&&r_outen_shr||force_out;
    always @(posedge clk) r_outen_shr <= w_out_chk;
    always @(posedge clk) begin
             if(reset)          r_wr_cnt <= 'd0;
             else if(clr)       r_wr_cnt <= 'd0;
             else if(i_wr_req ) r_wr_cnt <= r_wr_cnt+'d1;               
    end
    always @(posedge clk) if(i_wr_req ) r_data[r_wr_cnt] <= i_data;
    

    genvar i;
    generate
     for (i=0;i<OUT_WIDTH/IN_WIDTH; i= i+1)
       begin:pingjie
        assign o_data[i*IN_WIDTH+:IN_WIDTH] = r_data[i];
       end
    endgenerate  
    //always @(posedge clk) if(o_rd_req ) o_data  <= w_data;
    
endmodule
