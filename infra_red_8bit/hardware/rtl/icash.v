//
// Instruction Memory
//
// Hardik Sharma
// (hsharma@gatech.edu)
`timescale 1ns/1ps
module icash
#(
    parameter integer  DATA_WIDTH                   = 32,
    parameter integer  SIZE_IN_BITS                 = 1<<12,
    parameter integer  ADDR_WIDTH                   = $clog2(SIZE_IN_BITS/DATA_WIDTH)
  
)
(
  // clk, reset
    input                                           clk,
    input                                           reset,

  // Decoder <- imem
    input                                           i_read_req,
    input    [ ADDR_WIDTH           -1 : 0 ]        i_read_addr,
    output  reg [ DATA_WIDTH           -1 : 0 ]     o_read_data,
    
    input                                           i_write_req,
    input    [ ADDR_WIDTH           -1 : 0 ]        i_write_addr,
    input    [ DATA_WIDTH           -1 : 0 ]        i_write_data    
);

    reg                                           r_write_req;
    reg    [ ADDR_WIDTH           -1 : 0 ]        r_write_addr;
    reg    [ DATA_WIDTH           -1 : 0 ]        r_write_data;
   //(*ram_style ="block"*)
   reg  [ DATA_WIDTH -1 : 0 ] r_icashmem [ 0 : 1<<ADDR_WIDTH ];
    wire [ DATA_WIDTH -1 : 0 ] w32_watch_mem [ 0 : 10]/* synthesis keep="1" */;
   

   genvar i;
   generate 
   for(i=0;i<10;i=i+1)begin:gen_assign
     assign  w32_watch_mem[i] = r_icashmem[i];
     end
   endgenerate
 //write data porta
//  always @(posedge clk)begin  
//    r_write_req   <=i_write_req; 
//    r_write_addr  <=i_write_addr; 
//    r_write_data  <=i_write_data; 
//  end
   always @(posedge clk)r_write_req   <=i_write_req;
   always @(posedge clk)r_write_addr  <=i_write_addr; 
   always @(posedge clk)r_write_data  <=i_write_data;
//  always @(posedge clk)if(r_write_req) mem[r_write_addr] <= r_write_data;
//  always @(posedge clk)begin:write
//  if(i_write_req) mem[i_write_addr] <= i_write_data;
//  end
   always @(posedge clk)begin:write
    if(r_write_req) r_icashmem[r_write_addr] <= r_write_data;
   end
 // reg   [ DATA_WIDTH           -1 : 0 ]        r_read_data;    
  always @(posedge clk)  begin 
     if (i_read_req)  o_read_data <= r_icashmem[i_read_addr];
      else            o_read_data <= {DATA_WIDTH{1'bz}};//32'bz;
  end
 // assign   o_read_data =r_read_data;
//=============================================================


//=============================================================
// VCD
//=============================================================
`ifdef COCOTB_TOPLEVEL_instruction_memory
  initial begin
    $dumpfile("instruction_memory.vcd");
    $dumpvars(0, instruction_memory);
  end
`endif
//=============================================================
endmodule
