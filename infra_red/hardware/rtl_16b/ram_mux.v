/*
        8bit/16bit共用一个RAM，通过此MUX进行选择
*/
`timescale 1ns / 1ns
module ram_mux #(
)(
// add for 8bit/16bit ibuf
  input wire [ 14       -1 : 0 ]        tag_mem_write_addr_ibuf,
  input wire mem_write_req_in_ibuf,
  input wire  [256  -1 : 0]                                mem_write_data_in_ibuf,
  input wire [ 13       -1 : 0 ]        tag_buf_read_addr_ibuf,
  input  wire                                         buf_read_req_ibuf,
  output wire [ 512       -1 : 0 ]        _buf_read_data_ibuf,

    // add for 8bit/16bit bbuf
    input wire [ 11       -1 : 0 ]        tag_mem_write_addr_bbuf,
    input wire                                        mem_write_req_bbuf,
    input wire [ 256       -1 : 0 ]        mem_write_data_bbuf,
    input wire [ 9       -1 : 0 ]        tag_buf_read_addr_bbuf,
    input  wire                                         buf_read_req_bbuf,
    output wire [ 1024       -1 : 0 ]        _buf_read_data_bbuf,

   // add for 8bit/16bit wbuf
   input wire [ 12       -1 : 0 ]        tag_mem_write_addr_wbuf,
   input wire                                        mem_write_req_dly_wbuf,
   input wire [ 256       -1 : 0 ]        _mem_write_data_wbuf,
   input wire [ 11       -1 : 0 ]        tag_buf_read_addr_wbuf,
   input  wire                                         buf_read_req_wbuf,
   output wire  [ 512       -1 : 0 ]        buf_read_data_wbuf,

   // add for 8bit/16bit obuf
    input wire [ 15       -1 : 0 ]        tag_mem_write_addr_obuf,
    input wire                                        mem_write_req_obuf,
    input wire [ 256       -1 : 0 ]        mem_write_data_obuf,
    input wire [ 15       -1 : 0 ]        tag_mem_read_addr_obuf,
    input wire                                        mem_read_req_obuf,
    output wire [ 256       -1 : 0 ]        mem_read_data_obuf,
    output wire [ 2048       -1 : 0 ]        pu_read_data_obuf,
    input wire [ 12       -1 : 0 ]        tag_buf_write_addr_obuf,
    input wire   buf_write_req_obuf,
    input wire  [ 2048       -1 : 0 ]        buf_write_data_obuf,
    input wire [ 12       -1 : 0 ]        tag_buf_read_addr_obuf,
    input  wire                                         buf_read_req_obuf,
    output wire [ 2048       -1 : 0 ]        _buf_read_data_obuf
);

ibuf #( 
    ) ibuf_ram (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .mem_write_addr                 ( tag_mem_write_addr_ibuf             ),
    .mem_write_req                  ( mem_write_req_in_ibuf                  ),
    .mem_write_data                 ( mem_write_data_in_ibuf                ),//edit by pxq 0816
    .buf_read_addr                  ( tag_buf_read_addr_ibuf              ),
    .buf_read_req                   ( buf_read_req_ibuf                   ),
    .buf_read_data                  ( _buf_read_data_ibuf                 )
);

bbuf #(
) bbuf_ram (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .mem_write_addr                 ( tag_mem_write_addr_bbuf             ),
    .mem_write_req                  ( mem_write_req_bbuf                  ),
    .mem_write_data                 ( mem_write_data_bbuf            ),
    .buf_read_addr                  ( tag_buf_read_addr_bbuf              ),
    .buf_read_req                   ( buf_read_req_bbuf                   ),
    .buf_read_data                  ( _buf_read_data_bbuf                 )
);

wbuf #(
) wbuf_ram (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .mem_write_addr                 ( tag_mem_write_addr_wbuf             ),
    .mem_write_req                  ( mem_write_req_dly_wbuf              ),//edit by sy 0820
    .mem_write_data                 ( _mem_write_data_wbuf                ),//edit by sy 0820
    .buf_read_addr                  ( tag_buf_read_addr_wbuf              ),
    .buf_read_req                   ( buf_read_req_wbuf                   ),
    .buf_read_data                  ( buf_read_data_wbuf                 )
);

obuf #(
) obuf_ram (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),    
    .mem_read_req                   ( mem_read_req_obuf                   ),
    .mem_read_addr                  ( tag_mem_read_addr_obuf              ),
    .mem_read_data                  ( mem_read_data_obuf                  ),
    .mem_write_req                  ( mem_write_req_obuf                  ),
    .mem_write_addr                 ( tag_mem_write_addr_obuf             ),
    .mem_write_data                 ( mem_write_data_obuf                 ),
    .pu_read_data                   ( pu_read_data_obuf                   ), //edit yt
    //.obuf_fifo_write_req_limit      ( obuf_fifo_write_req_limit      ), //edit yt
    .buf_write_addr                 ( tag_buf_write_addr_obuf             ),//edit by pxq
    .buf_write_req                  ( buf_write_req_obuf                  ),//edit by pxq
    .buf_write_data                 ( buf_write_data_obuf                 ),//edit by pxq
    .buf_read_addr                  ( tag_buf_read_addr_obuf              ),
    .buf_read_req                   ( buf_read_req_obuf                   ),
    .buf_read_data                  ( _buf_read_data_obuf                 )
  );

endmodule