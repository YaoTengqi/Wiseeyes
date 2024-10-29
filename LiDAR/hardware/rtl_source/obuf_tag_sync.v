//
// Tag logic for double buffering
//
// Hardik Sharma
// (hsharma@gatech.edu)

`timescale 1ns/1ps
module obuf_tag_sync #(
    parameter integer  NUM_TAGS                     = 2,
    parameter integer  TAG_W                        = $clog2(NUM_TAGS),
    parameter integer  STORE_ENABLED                = 1
)
(
    input  wire                                         clk,
    input  wire                                         reset,
    input  wire                                         block_done_prev,
    input  wire                                         tag_req_prev,
    input  wire                                         tag_reuse_prev,
    input  wire                                         tag_bias_prev_sw_prev,
    input  wire                                         tag_ddr_pe_sw_prev,                         //edit by pxq 0710
    output wire                                         tag_ready,
    output wire  [ TAG_W                -1 : 0 ]        tag,
    output wire                                         tag_done,
  //
   // input wire                                            obuf_tag_req,                   //edit by pxq 0708
    input  wire                                         compute_tag_done,
    output wire                                         compute_tag_ready,
    output wire                                         compute_bias_prev_sw,
    output wire  [ TAG_W                -1 : 0 ]        compute_tag,
    input  wire                                         ldmem_tag_done,
    output wire                                         ldmem_tag_ready,
    output wire  [ TAG_W                -1 : 0 ]        ldmem_tag,
    input  wire  [ TAG_W                -1 : 0 ]        raw_stmem_tag,
    output wire                                         raw_stmem_tag_ready,
    output wire                                         stmem_ddr_pe_sw,
    input  wire                                         stmem_tag_done,
    output wire                                         stmem_tag_ready,
    output wire  [ TAG_W                -1 : 0 ]        stmem_tag
);

//==============================================================================
// Wires/Regs
//==============================================================================
    reg  [ TAG_W                -1 : 0 ]        prev_tag;
    reg  [ TAG_W                -1 : 0 ]        tag_alloc;
    reg  [ TAG_W                -1 : 0 ]        ldmem_tag_alloc;
    reg  [ TAG_W                -1 : 0 ]        compute_tag_alloc;
    reg  [ TAG_W                -1 : 0 ]        stmem_tag_alloc;
    reg  [ 2                    -1 : 0 ]        tag0_state_d;
    reg  [ 2                    -1 : 0 ]        tag0_state_q;
    reg  [ 2                    -1 : 0 ]        tag1_state_d;
    reg  [ 2                    -1 : 0 ]        tag1_state_q;

    wire next_compute_tag;

    wire [ NUM_TAGS             -1 : 0 ]        local_next_compute_tag;
    wire [ NUM_TAGS             -1 : 0 ]        local_tag_ready;
    wire [ NUM_TAGS             -1 : 0 ]        local_compute_tag_ready;
//    wire [ NUM_TAGS             -1 : 0 ]        local_compute_tag_reuse;
    wire [ NUM_TAGS             -1 : 0 ]        local_bias_prev_sw;
    wire [ NUM_TAGS             -1 : 0 ]        local_stmem_ddr_pe_sw;
    wire [ NUM_TAGS             -1 : 0 ]        local_ldmem_tag_ready;
    wire [ NUM_TAGS             -1 : 0 ]        local_stmem_tag_ready;

    localparam integer  TAG_FREE                     = 0;
    localparam integer  TAG_LDMEM                    = 1;
    localparam integer  TAG_COMPUTE                  = 2;
    localparam integer  TAG_STMEM                    = 3;

//    wire                                        compute_tag_reuse;

    wire                                        cache_hit;
    wire                                        cache_flush;
//==============================================================================




//==================================================================================                         edit by pxq 0710

/*
*The FIFO stores the  tag_req requests
*/
wire wr_req_buf_pop;
wire wr_req_buf_rd_ready;
wire [4-1 :0] wr_req_buf_data_out;
wire wr_req_buf_push;
wire wr_req_buf_wr_ready;
wire [4-1:0] wr_req_buf_data_in;
wire wr_req_buf_almost_full;
wire wr_req_buf_almost_empty;

wire tag_req_sw;
wire tag_reuse_sw;
wire tag_ddr_pe_sw_sw;
wire tag_bias_prev_sw_sw;
wire block_done_sw;
wire tag_ready_dly;

wire tag_req;
wire tag_reuse;
wire tag_bias_prev_sw;
wire tag_ddr_pe_sw;

reg tag_req_dly;
reg tag_reuse_dly;
reg tag_bias_prev_sw_dly;
reg tag_ddr_pe_sw_dly;
reg block_done_dly;

reg block_done;

wire tag_ready_dly1;
wire tag_ready_dly2;

//=========================================================================       edit by pxq 0727

reg [3-1    : 0 ]            tag_req_state_d;
reg [3-1    : 0 ]            tag_req_state_q;

localparam integer  TAG_IDLE = 0;
localparam integer  TAG_BUSY = 1;
localparam integer  TAG_DLY1 = 2;
localparam integer  TAG_DLY2 = 3;
localparam integer  TAG_DLY3 = 4;
localparam integer  TAG_DONE = 5;

always @(*) begin
  tag_req_state_d=tag_req_state_q;

  case (tag_req_state_q)
  TAG_IDLE:begin
    if(wr_req_buf_rd_ready&&tag_ready)begin
      tag_req_state_d=TAG_BUSY;
      end
  end 
  TAG_BUSY:begin
    tag_req_state_d=TAG_DLY1;
  end
  TAG_DLY1:begin
    tag_req_state_d=TAG_DLY2;
  end
  TAG_DLY2:begin
    tag_req_state_d=TAG_DLY3;
  end
  TAG_DLY3:begin
    tag_req_state_d=TAG_DONE;
  end
  TAG_DONE:begin
    tag_req_state_d=TAG_IDLE;
  end
  endcase

end

always @(posedge clk) begin
  if(reset)begin
    tag_req_state_q=TAG_IDLE;
  end else begin
      tag_req_state_q<=tag_req_state_d;
  end
end


//========================================================================= edit by pxq

always @(posedge clk) begin
  tag_req_dly<=tag_req_prev;
  tag_reuse_dly<=tag_reuse_prev;
end

always @(posedge clk) begin
  tag_bias_prev_sw_dly<='b1;   //tag_bias_prev_sw_dly<=tag_bias_prev_sw_prev;
  tag_ddr_pe_sw_dly<='b1;      //tag_ddr_pe_sw_dly<=tag_ddr_pe_sw_prev;
end




always @(posedge clk) begin
  if(block_done_prev)begin
    block_done_dly<=block_done_prev;
  end

block_done<=block_done_dly&&tag_ready_dly2&&~wr_req_buf_rd_ready;                //edit by pxq 0729

  if(block_done_dly&&tag_ready_dly2&&~wr_req_buf_rd_ready)begin
    
    block_done_dly<=0;
  end
end


register_sync #(1) tag_ready_delay1 (clk, reset, tag_ready, tag_ready_dly1);
register_sync #(1) tag_ready_delay2 (clk, reset, tag_ready_dly1,tag_ready_dly2);

assign wr_req_buf_data_in={tag_req_dly,tag_reuse_dly,tag_bias_prev_sw_dly,tag_ddr_pe_sw_dly};
assign wr_req_buf_push=wr_req_buf_wr_ready?tag_req_dly:0;

assign {tag_req_sw,tag_reuse_sw,tag_bias_prev_sw_sw,tag_ddr_pe_sw_sw}=wr_req_buf_data_out;
//assign wr_req_buf_pop=wr_req_buf_rd_ready?(tag_ready&&tag_ready_dly1):0;                                  // edit by pxq 0726
assign wr_req_buf_pop=tag_req_state_q==TAG_BUSY;                                  // edit by pxq 0726
  fifo #(
    .DATA_WIDTH                     ( 4                       ),
    .ADDR_WIDTH                     ( 4                              )
  ) tag_req_buf (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .s_read_req                     ( wr_req_buf_pop                 ), //input
    .s_read_ready                   ( wr_req_buf_rd_ready            ), //output
    .s_read_data                    ( wr_req_buf_data_out            ), //output
    .s_write_req                    ( wr_req_buf_push                ), //input
    .s_write_ready                  ( wr_req_buf_wr_ready            ), //output
    .s_write_data                   ( wr_req_buf_data_in             ), //input
    .almost_full                    ( wr_req_buf_almost_full         ), //output
    .almost_empty                   ( wr_req_buf_almost_empty        )  //output
  );


assign tag_req=tag_ready_dly?tag_req_sw:0;
assign tag_reuse=tag_ready_dly?tag_reuse_sw:0;
assign tag_bias_prev_sw=tag_bias_prev_sw_sw;
assign tag_ddr_pe_sw=tag_ddr_pe_sw_sw;

//assign block_done=block_done_prev;
register_sync #(1)
  buf_read_data_delay (clk, reset, wr_req_buf_pop, tag_ready_dly);

//================================================================================

//==============================================================================
// Tag allocation
//==============================================================================

    assign cache_hit = tag_reuse;
    assign cache_flush = (tag_req && ~tag_reuse) || block_done;

  always @(posedge clk)
  begin
    if (reset)
      tag_alloc <= 'b0;
    else if (tag_req && tag_ready && ~cache_hit) begin
      if (tag_alloc == NUM_TAGS-1)
        tag_alloc <= 'b0;
      else
        tag_alloc <= tag_alloc + 1'b1;
    end
  end
  always @(posedge clk)
  begin
    if (reset)
      prev_tag <= 'b0;
    else if (tag_req && tag_ready && ~cache_hit) begin
      prev_tag <= tag_alloc;
    end
  end

  always @(posedge clk)
  begin
    if (reset)
      ldmem_tag_alloc <= 'b0;
    else if (ldmem_tag_done)
      if (ldmem_tag_alloc == NUM_TAGS-1)
        ldmem_tag_alloc <= 'b0;
      else
        ldmem_tag_alloc <= ldmem_tag_alloc + 1'b1;
  end

  always @(posedge clk)
  begin
    if (reset)
      compute_tag_alloc <= 'b0;
    else if (next_compute_tag)
      if (compute_tag_alloc == NUM_TAGS-1)
        compute_tag_alloc <= 'b0;
      else
        compute_tag_alloc <= compute_tag_alloc + 1'b1;
  end

  always @(posedge clk)
  begin
    if (reset)
      stmem_tag_alloc <= 'b0;
    else if (stmem_tag_done)
      if (stmem_tag_alloc == NUM_TAGS-1)
        stmem_tag_alloc <= 'b0;
      else
        stmem_tag_alloc <= stmem_tag_alloc + 1'b1;
  end

    assign tag_done = &local_tag_ready;

    // Buffer hit/miss logic
    assign tag = tag_reuse ? prev_tag: tag_alloc;
    assign tag_ready = local_tag_ready[prev_tag] || local_tag_ready[tag_alloc];

    assign next_compute_tag = local_next_compute_tag[compute_tag_alloc];

    assign ldmem_tag = ldmem_tag_alloc;
    assign compute_tag = compute_tag_alloc;
    assign stmem_tag = stmem_tag_alloc;

    assign ldmem_tag_ready = local_ldmem_tag_ready[ldmem_tag];
    assign compute_tag_ready = local_compute_tag_ready[compute_tag];
    assign compute_bias_prev_sw = local_bias_prev_sw[compute_tag];
    assign stmem_ddr_pe_sw = local_stmem_ddr_pe_sw[stmem_tag];
    assign stmem_tag_ready = local_stmem_tag_ready[stmem_tag];

    assign raw_stmem_tag_ready = local_stmem_tag_ready[raw_stmem_tag];

//    assign compute_tag_reuse = local_compute_tag_reuse[compute_tag];

  genvar t;
  generate
    for (t=0; t<NUM_TAGS; t=t+1)
    begin: TAG_GEN

    wire                                        _tag_flush;


    wire                                        _next_compute_tag;

    wire                                        _tag_req;
    wire                                        _tag_reuse;
    wire                                        _tag_bias_prev_sw;
    wire                                        _tag_ddr_pe_sw;
    wire                                        _tag_ready;
    wire                                        _tag_done;
    wire                                        _compute_tag_done;
    wire                                        _compute_bias_prev_sw;
    wire                                        _compute_tag_ready;
//    wire                                        _compute_tag_reuse;
    wire                                        _ldmem_tag_done;
    wire                                        _ldmem_tag_ready;
    wire                                        _stmem_tag_done;
    wire                                        _stmem_tag_ready;
    wire                                        _stmem_ddr_pe_sw;
    wire                                        _obuf_tag_req;

    assign _obuf_tag_req=tag_req&&tag==t;
    assign _tag_reuse = tag_reuse && compute_tag_alloc == t;

    assign _tag_req = tag_req && ~tag_reuse && tag_ready && tag == t;
    assign _tag_bias_prev_sw = tag_bias_prev_sw;
    assign _tag_ddr_pe_sw = tag_ddr_pe_sw;
      // assign _tag_done = tag_done && tag == t;
    assign _ldmem_tag_done = ldmem_tag_done && ldmem_tag == t;
    assign _compute_tag_done = compute_tag_done && compute_tag == t;
    assign _stmem_tag_done = stmem_tag_done && stmem_tag == t;

    assign local_tag_ready[t] = _tag_ready;
    assign local_ldmem_tag_ready[t] = _ldmem_tag_ready;
    assign local_compute_tag_ready[t] = _compute_tag_ready;
//    assign local_compute_tag_reuse[t] = _compute_tag_reuse;
    assign local_bias_prev_sw[t] = _compute_bias_prev_sw;
    assign local_stmem_tag_ready[t] = _stmem_tag_ready;
    assign local_stmem_ddr_pe_sw[t] = _stmem_ddr_pe_sw;

    assign local_next_compute_tag[t] = _next_compute_tag;

    assign _tag_flush = cache_flush && prev_tag == t;

      obuf_tag_logic local_tag (
    .clk                            ( clk                            ), // input
    .reset                          ( reset                          ), // input
    .next_compute_tag               ( _next_compute_tag              ), // output
    .next_sync_compute_tag               ( next_compute_tag              ), // input                        edit by sy 0507
    .tag_req                        ( _tag_req                       ), // input
    .tag_reuse                      ( _tag_reuse                     ), // input
    .tag_bias_prev_sw               ( _tag_bias_prev_sw              ), // input
    .tag_ddr_pe_sw                  ( _tag_ddr_pe_sw                 ), // input
    .tag_ready                      ( _tag_ready                     ), // output
    .tag_done                       ( _tag_done                      ), // output
    .tag_flush                      ( _tag_flush                     ), // input
   // .obuf_tag_req            (_obuf_tag_req),//input                                                 edit by pxq0708
    .compute_tag_done               ( _compute_tag_done              ), // input
//    .compute_tag_reuse              ( _compute_tag_reuse             ), // input
    .compute_bias_prev_sw           ( _compute_bias_prev_sw          ), // output
    .compute_tag_ready              ( _compute_tag_ready             ), // output
    .ldmem_tag_done                 ( _ldmem_tag_done                ), // input
    .ldmem_tag_ready                ( _ldmem_tag_ready               ), // output
    .stmem_ddr_pe_sw                ( _stmem_ddr_pe_sw               ), // output
    .stmem_tag_done                 ( _stmem_tag_done                ), // input
    .stmem_tag_ready                ( _stmem_tag_ready               ) // output
        );

    end
  endgenerate
//==============================================================================

//=============================================================
// VCD
//=============================================================
`ifdef COCOTB_TOPLEVEL_tag_logic
initial begin
  $dumpfile("tag_logic.vcd");
  $dumpvars(0, tag_logic);
end
`endif
//=============================================================
endmodule
