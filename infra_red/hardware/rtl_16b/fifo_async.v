`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/30 10:46:39
// Design Name: 
// Module Name: audo_pan
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
// IN_WIDTH *2^N =OUT_WIDTH; 
// 数据对qi 4clk;
// 其他 3个clk
//////////////////////////////////////////////////////////////////////////////////
module fifo_async #(

parameter   data_depth = 256,

parameter integer IN_WIDTH    =16,
parameter integer OUT_WIDTH   =256,

parameter   addr_width = $clog2(data_depth)
)(
input                            rst,
input                            clr,
input                            wr_clk,
input                            i_wr_en,
input      [IN_WIDTH-1:0]        i_din,         
input                            rd_clk,
input                            rd_en,
output reg                       valid,
output reg [OUT_WIDTH-1:0]       dout,
output                           empty,
output                           full
//output     [addr_width-1:0]      data_num  
);


reg    [addr_width:0]    wr_ptr;//地址指针，比地址多一位，MSB用于检测在同一圈
reg    [addr_width:0]    rd_ptr;
wire   [addr_width-1:0]  wr_addr;//RAM 地址
wire   [addr_width-1:0]  rd_addr;

wire   [addr_width:0]    wr_ptr_gray;//地址指针对应的格雷码
reg    [addr_width:0]    r_wr_ptr_gray_d1;
reg    [addr_width:0]    r_wr_ptr_gray_d2;
wire   [addr_width:0]    rd_ptr_gray;
reg    [addr_width:0]    r_rd_ptr_gray_d1;
reg    [addr_width:0]    r_rd_ptr_gray_d2;
reg [OUT_WIDTH-1:0] r_ram [data_depth-1:0];
//*******************数据位宽对齐
wire [OUT_WIDTH-1:0]      din;
wire                      wr_en;
generate 
if(OUT_WIDTH>IN_WIDTH) begin
   if(  (1<< $clog2( OUT_WIDTH/IN_WIDTH ) )*IN_WIDTH==OUT_WIDTH )
    begin
     fifo_16to256 #(
     .IN_WIDTH(IN_WIDTH),
     .OUT_WIDTH(  OUT_WIDTH )
     ) u_fifo_64to256(
     .clk(  wr_clk       ),
     .reset(rst          ),
     .clr(  clr          ),
     .force_out('d0      ),
     .i_wr_req(i_wr_en     ),
     .i_data(i_din         ),
     
     //out
     .o_rd_req(  wr_en   ),
     .o_data(     din    )  
     );
   end 
   end 
else if(OUT_WIDTH == IN_WIDTH)begin
   assign  din   =     i_din;
   assign  wr_en =   i_wr_en;
 end 
endgenerate
//=========================================================write fifo 
wire     rd_valid;
wire     wr_valid;
assign   wr_valid  =  wr_en && (~full);
assign   rd_valid  =  rd_en && (~empty);
always@(posedge wr_clk) begin
	       if(rst)   	          r_ram[0] <= {OUT_WIDTH{1'h0}};//fifo复位后输出总线上是0
	       else if(clr)           r_ram[0] <= {OUT_WIDTH{1'h0}};
	       else if(wr_valid)      r_ram[wr_addr] <= din;
	       else     	          r_ram[wr_addr] <= r_ram[wr_addr];
	       end   
//========================================================read_fifo
always@(posedge rd_clk) begin
      if(rst) begin
            dout  <= {OUT_WIDTH{1'h0}};
            valid <= 1'b0;
            end
      else if(clr) begin
            dout  <= {OUT_WIDTH{1'h0}};
            valid <= 1'b0;
            end
      else if(rd_valid)  begin
            dout  <= r_ram[rd_addr];
            valid <= 1'b1;
            end
      else begin
            dout  <=   {OUT_WIDTH{1'h0}};//fifo复位后输出总线上是0，并非ram中真的复位，只是让总线为0；
            valid <= 1'b0;
            end
     end
assign wr_addr = wr_ptr[addr_width-1-:addr_width];
assign rd_addr = rd_ptr[addr_width-1-:addr_width];
//=============================================================格雷码同步化
always@(posedge wr_clk ) begin
      r_rd_ptr_gray_d1 <= rd_ptr_gray;
      r_rd_ptr_gray_d2 <= r_rd_ptr_gray_d1;
      end
always@(posedge wr_clk or posedge rst) begin
      if(rst)                  wr_ptr <= 'h0;         
      else if(clr)             wr_ptr <= 'h0;
      else if(wr_valid)        wr_ptr <= wr_ptr + 1;
      else                     wr_ptr <= wr_ptr;
      end
//=========================================================rd_clk
always@(posedge rd_clk )begin
      r_wr_ptr_gray_d1 <= wr_ptr_gray;
      r_wr_ptr_gray_d2 <= r_wr_ptr_gray_d1;
      end
always@(posedge rd_clk or posedge rst)   begin
      if(rst)                 rd_ptr <= 'h0;
      else if(clr)            rd_ptr <= 'h0;
      else if(rd_valid)       rd_ptr <= rd_ptr + 1;
      else                    rd_ptr <= rd_ptr;
      end

//========================================================== translation gary code
assign wr_ptr_gray = (wr_ptr >> 1) ^ wr_ptr;
assign rd_ptr_gray = (rd_ptr >> 1) ^ rd_ptr;

assign full = (wr_ptr_gray == {~(r_rd_ptr_gray_d2[addr_width-:2]),r_rd_ptr_gray_d2[addr_width-2:0]}) ;//高两位不同
assign empty = ( rd_ptr_gray == r_wr_ptr_gray_d2 );

//reg    [addr_width:0]    r_wr_rdclk_ptr;//地址指针，比地址多一位，MSB用于检测在同一圈  
//always@(posedge rd_clk ) r_wr_rdclk_ptr <= ((r_rd_ptr_gray_d2 >> 1) ^ r_rd_ptr_gray_d2);// - rd_ptr;
//assign                   data_num       = r_wr_rdclk_ptr;
endmodule