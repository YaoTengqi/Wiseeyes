`timescale 1ns / 1ps
module simd_pu_core #(
  // Instruction width for PU controller
    parameter integer  INST_WIDTH                   = 32,
  // Data width
    parameter integer  DATA_WIDTH                   = 16,
    parameter integer  HALF_DATA_WIDTH              = DATA_WIDTH/2,//edit 0830
    parameter integer  ACC_DATA_WIDTH               = 32,
    parameter integer  ACC_DATA_HALF_WIDTH          = ACC_DATA_WIDTH/2,
    parameter integer  OBUF_LVALID_DATA_WIDTH       = 30, 
    parameter integer  OBUF_HVALID_DATA_WIDTH       = 32,  
    parameter integer  SIMD_LANES                   = 1,
    parameter integer  SIMD_DATA_WIDTH              = SIMD_LANES * DATA_WIDTH,
    parameter integer  SIMD_INTERIM_WIDTH           = SIMD_LANES * ACC_DATA_WIDTH,
    parameter integer  OBUF_AXI_DATA_WIDTH          = 256,

    parameter integer  AXI_DATA_WIDTH               = 64,

    parameter integer  SRC_ADDR_WIDTH               = 4,
    parameter integer  RF_ADDR_WIDTH                = SRC_ADDR_WIDTH-1,

    parameter integer  OP_WIDTH                     = 3,
    parameter integer  FN_WIDTH                     = 3,
    parameter integer  IMM_WIDTH                    = 16,
    //edit yt SY
    parameter integer  QU_WIDTH                     = 8,
    parameter integer  QU_SIMD_DATA_WIDTH           = SIMD_LANES * QU_WIDTH,
    parameter integer  ARRAY_M                      = 2,
    parameter integer  OBUF_DATA_WIDTH              = ARRAY_M * ACC_DATA_WIDTH
    //edit end
)
(
    input  wire                                         clk,
    input  wire                                         reset,
    input  wire                                         choose_8bit,

    input  wire                                         alu_fn_valid,
    input  wire  [ FN_WIDTH             -1 : 0 ]        alu_fn,
    input  wire  [ IMM_WIDTH            -1 : 0 ]        alu_imm,

    input  wire  [ SRC_ADDR_WIDTH       -1 : 0 ]        alu_in0_addr,
    input  wire                                         alu_in1_src,
    input  wire  [ SRC_ADDR_WIDTH       -1 : 0 ]        alu_in1_addr,
    input  wire  [ SRC_ADDR_WIDTH       -1 : 0 ]        alu_out_addr,

  // From controller
    input  wire                                         obuf_ld_stream_read_req,
    output wire                                         obuf_ld_stream_read_ready,
    input  wire                                         ddr_ld0_stream_read_req,
    output wire                                         ddr_ld0_stream_read_ready,
    input  wire                                         ddr_ld1_stream_read_req,
    output wire                                         ddr_ld1_stream_read_ready,
    input  wire                                         ddr_st_stream_write_req,
    output wire                                         ddr_st_stream_write_ready,

    input wire                                          st1_data_required,//edit by sy 
//    input wire                                          dsp_mult,//edit by sy 0813
  // From DDR
    input  wire                                         ddr_st_stream_read_req,
    output wire  [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_st_stream_read_data,
    output wire                                         ddr_st_stream_read_ready,

    input  wire                                         ddr_ld0_stream_write_req,
    input  wire  [ AXI_DATA_WIDTH*2       -1 : 0 ]        ddr_ld0_stream_write_data,//edit yt
    output wire                                         ddr_ld0_stream_write_ready,

    input  wire                                         ddr_ld1_stream_write_req,
    input  wire  [ AXI_DATA_WIDTH*2       -1 : 0 ]        ddr_ld1_stream_write_data,//edit yt
    output wire                                         ddr_ld1_stream_write_ready,

  // From OBUF
    input  wire                                         obuf_ld_stream_write_req,
    input  wire  [ OBUF_DATA_WIDTH      -1 : 0 ]        obuf_ld_stream_write_data,
    output wire                                         obuf_ld_stream_write_ready,

    output wire  [ INST_WIDTH           -1 : 0 ]        obuf_ld_stream_read_count,
    output wire  [ INST_WIDTH           -1 : 0 ]        obuf_ld_stream_write_count,
    output wire  [ INST_WIDTH           -1 : 0 ]        ddr_st_stream_read_count,
    output wire  [ INST_WIDTH           -1 : 0 ]        ddr_st_stream_write_count,
    output wire  [ INST_WIDTH           -1 : 0 ]        ld0_stream_counts,
    output wire  [ INST_WIDTH           -1 : 0 ]        ld1_stream_counts,

    input  wire                                         cfg_rs_num_v,
    input  wire  [ IMM_WIDTH            -1 : 0 ]        rshift_num,
    
    input  wire                                         st_fifo_extra_read_req,
    input  wire                                         ddr_st_done //edit yt
);

//==============================================================================
// Localparams
//==============================================================================
//==============================================================================

//==============================================================================
// Wires & Regs
//==============================================================================
    // wire [ SIMD_INTERIM_WIDTH   -1 : 0 ]        alu_in0_data;
    // wire [ SIMD_INTERIM_WIDTH   -1 : 0 ]        alu_in1_data;

    wire [ SIMD_INTERIM_WIDTH   -1 : 0 ]        obuf_ld_stream_read_data;

    reg  [ SIMD_DATA_WIDTH      -1 : 0 ]        ddr_ld0_stream_read_data; //edit yt
    wire [ SIMD_DATA_WIDTH      -1 : 0 ]        ddr_ld0_stream_read_data_fix;//edit 0830
    wire                                        ld0_req_buf_write_ready;
    wire                                        ld0_req_buf_almost_full;
    wire                                        ld0_req_buf_almost_empty;

    reg  [ SIMD_DATA_WIDTH      -1 : 0 ]        ddr_ld1_stream_read_data; //edit yt
    wire [ SIMD_DATA_WIDTH      -1 : 0 ]        ddr_ld1_stream_read_data_fix;//edit 0830
    wire                                        ld1_req_buf_write_ready;
    wire                                        ld1_req_buf_almost_full;
    wire                                        ld1_req_buf_almost_empty;

    wire                                        st_req_buf_almost_full;
    wire                                        st_req_buf_almost_empty;
    wire [ SIMD_DATA_WIDTH      -1 : 0 ]        ddr_st_stream_write_data;
    wire [ SIMD_DATA_WIDTH      -1 : 0 ]        _ddr_st_stream_write_data;//edit by sy 0813
    wire [ SIMD_DATA_WIDTH      -1 : 0 ]        ddr_st_stream_write_data_reg;//edit by sy 0813  

    wire                                        st_fifo_full_read_req;

    wire [ FN_WIDTH             -1 : 0 ]        alu_fn_stage2[SIMD_LANES-1:0];
    wire  [SIMD_LANES-1:0]                                      alu_fn_valid_stage2;
    wire                                        alu_fn_valid_stage3;
    wire [ IMM_WIDTH            -1 : 0 ]        alu_imm_stage2[SIMD_LANES-1:0];
    wire                                        alu_in1_src_stage2;
    wire [ SRC_ADDR_WIDTH       -1 : 0 ]        alu_in0_addr_stage2;
    wire [ SRC_ADDR_WIDTH       -1 : 0 ]        alu_in1_addr_stage2;

    wire                                        ld_req_buf_almost_full;
    wire                                        ld_req_buf_almost_empty;

    // wire                                        alu_in0_req;
    // wire                                        alu_in1_req;
    wire [ SIMD_INTERIM_WIDTH   -1 : 0 ]        alu_out;
    //reg  [ SIMD_INTERIM_WIDTH   -1 : 0 ]        alu_out_fwd;

  // // chaining consecutive ops
  //   wire                                        chain_rs0;
  //   wire                                        chain_rs1;
  //   wire                                        chain_rs0_stage2;
  //   wire                                        chain_rs1_stage2;

  // // forwarding between ops
  //   wire                                        fwd_rs0;
  //   wire                                        fwd_rs1;
  //   wire                                        fwd_rs0_stage2;
  //   wire                                        fwd_rs1_stage2;

  //   wire [ SRC_ADDR_WIDTH       -1 : 0 ]        alu_out_addr_stage2;
  //   wire [ SRC_ADDR_WIDTH       -1 : 0 ]        alu_out_addr_stage3;

  // PU Store1 FIFO - edit by sy begin
    wire  [ FN_WIDTH             -1 : 0 ]        alu_fn_stage3;
    wire ddr_st1_stream_write_req;
    wire ddr_st1_stream_write_req_dly1;
    wire _ddr_st_stream_write_req;//edit by sy 0618 end
    wire [ OBUF_DATA_WIDTH      -1 : 0 ]        _obuf_ld_stream_write_data;
    wire [ OBUF_DATA_WIDTH      -1 : 0 ]        obuf_ld_stream_write_data_reg;    
    wire [DATA_WIDTH -1 :0 ] _ddr_ld0_stream_read_data [SIMD_LANES -1 : 0 ]; 
    wire [DATA_WIDTH -1 :0 ] _ddr_ld1_stream_read_data [SIMD_LANES -1 : 0 ]; 
    genvar i;
//==============================================================================

//==============================================================================
// Chaining/Forwarding logic
//==============================================================================
    // assign chain_rs0 = alu_fn_valid && alu_fn_valid_stage2 && (alu_in0_addr[2:0] == alu_out_addr_stage2[2:0]);
    // assign chain_rs1 = alu_fn_valid && alu_fn_valid_stage2 && (alu_in1_addr[2:0] == alu_out_addr_stage2[2:0]);

    // assign fwd_rs0 = (alu_fn_valid && alu_fn_valid_stage3 && (alu_in0_addr == alu_out_addr_stage3));
    // assign fwd_rs1 = (alu_fn_valid && alu_fn_valid_stage3 && (alu_in1_addr == alu_out_addr_stage3));
//==============================================================================

//==============================================================================
// Registers
//==============================================================================
  // register_sync_with_enable #(1) stage2_chain_rs0
  // (clk, reset, 1'b1, chain_rs0, chain_rs0_stage2);

  // register_sync_with_enable #(1) stage2_chain_rs1
  // (clk, reset, 1'b1, chain_rs1, chain_rs1_stage2);

  // register_sync_with_enable #(1) stage2_fwd_rs0
  // (clk, reset, 1'b1, fwd_rs0, fwd_rs0_stage2);

  // register_sync_with_enable #(1) stage2_fwd_rs1
  // (clk, reset, 1'b1, fwd_rs1, fwd_rs1_stage2);

  // register_sync_with_enable #(SRC_ADDR_WIDTH) stage2_alu_out_addr
  // (clk, reset, 1'b1, alu_out_addr, alu_out_addr_stage2);
  // register_sync_with_enable #(SRC_ADDR_WIDTH) stage3_alu_out_addr
  // (clk, reset, 1'b1, alu_out_addr_stage2, alu_out_addr_stage3);
//==============================================================================

//==============================================================================
// Assigns
//==============================================================================
//==============================================================================

//==============================================================================
// PU OBUF LD FIFO
//==============================================================================
    assign obuf_ld_stream_write_ready = ~ld_req_buf_almost_full;
  fifo_asymmetric_16 #(
    .WR_DATA_WIDTH                  ( OBUF_DATA_WIDTH                ),//edit yt
    .RD_DATA_WIDTH                  ( SIMD_INTERIM_WIDTH             ),
    .WR_ADDR_WIDTH                  ( 6                              ),
    .RD_ADDR_WIDTH                  ( 6                             )
  ) ld_req_buf (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .s_write_req                    ( obuf_ld_stream_write_req       ), //input
    .s_write_data                   ( obuf_ld_stream_write_data_reg  ), //input
    .s_write_ready                  (                                ), //output
    .s_read_req                     ( obuf_ld_stream_read_req        ), //input
    .s_read_ready                   ( obuf_ld_stream_read_ready      ), //output
    .s_read_data                    ( obuf_ld_stream_read_data       ), //output
    .almost_full                    ( ld_req_buf_almost_full         ), //output
    .almost_empty                   ( ld_req_buf_almost_empty        )  //output
  );
//==============================================================================

//==============================================================================
// PU Store FIFO
//==============================================================================

    assign ddr_st_stream_write_ready = ~st_req_buf_almost_full;
    assign ddr_st1_stream_write_req = st1_data_required && alu_fn_valid_stage3 && alu_fn_stage3 == 'd4;//edit yt
    assign _ddr_st_stream_write_req = ddr_st_stream_write_req || ddr_st1_stream_write_req;

    //TODO: edit yt
    assign st_fifo_full_read_req = ddr_st_stream_read_req || st_fifo_extra_read_req;

    assign ddr_st_stream_write_data_reg = choose_8bit ? _ddr_st_stream_write_data : ddr_st_stream_write_data;
    assign obuf_ld_stream_write_data_reg = choose_8bit ? _obuf_ld_stream_write_data : obuf_ld_stream_write_data;
generate
for (i=0; i<SIMD_LANES; i=i+1)
begin
    assign ddr_st_stream_write_data[i*DATA_WIDTH+:DATA_WIDTH] = alu_out[i*ACC_DATA_WIDTH+:DATA_WIDTH];
    assign _ddr_st_stream_write_data[i*QU_WIDTH+:QU_WIDTH] = alu_out[i*ACC_DATA_WIDTH+:QU_WIDTH];//edit by sy 0825
    assign _ddr_st_stream_write_data[(i*QU_WIDTH + QU_SIMD_DATA_WIDTH)+:QU_WIDTH] = alu_out[i*ACC_DATA_WIDTH + ACC_DATA_HALF_WIDTH +:QU_WIDTH];//edit by sy 0825
    
    assign _obuf_ld_stream_write_data[i*ACC_DATA_WIDTH +: ACC_DATA_HALF_WIDTH] = $signed(obuf_ld_stream_write_data[i*ACC_DATA_WIDTH +: OBUF_LVALID_DATA_WIDTH]);
    assign _obuf_ld_stream_write_data[i*ACC_DATA_WIDTH + ACC_DATA_HALF_WIDTH +: ACC_DATA_HALF_WIDTH] = $signed(obuf_ld_stream_write_data[i*ACC_DATA_WIDTH + OBUF_HVALID_DATA_WIDTH +: OBUF_LVALID_DATA_WIDTH]);
end
endgenerate

    wire         _ddr_st_stream_write_req_dly1;
    register_sync_with_enable #(1) _ddr_st_stream_write_req_dly    
    (clk, reset, 1'b1, _ddr_st_stream_write_req, _ddr_st_stream_write_req_dly1);

  fifo_asymmetric_16 #(
    .WR_DATA_WIDTH                  ( SIMD_DATA_WIDTH                ),
    .RD_DATA_WIDTH                  ( AXI_DATA_WIDTH                 ),
    .WR_ADDR_WIDTH                  ( 6                              ),
    .RD_ADDR_WIDTH                  ( 6                              )         
  ) st_req_buf (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .s_write_req                    ( _ddr_st_stream_write_req_dly1       ), //input edit by sy
    .s_write_data                   ( ddr_st_stream_write_data_reg   ), //output edit by sy 0813
    .s_write_ready                  (                                ), //output
    .s_read_req                     ( st_fifo_full_read_req          ),//ddr_st_stream_read_req         ), //input
    .s_read_ready                   ( ddr_st_stream_read_ready       ), //output
    .s_read_data                    ( ddr_st_stream_read_data        ), //input
    .almost_full                    ( st_req_buf_almost_full         ), //output
    .almost_empty                   ( st_req_buf_almost_empty        )  //output
  );
//==============================================================================

//==============================================================================
// PU LD0 FIFO
//==============================================================================
//edit yt
  reg [ SIMD_DATA_WIDTH      -1 : 0 ]        ddr_ld0_data=0; 
  assign ddr_ld0_stream_read_ready = ddr_ld0_data != 0 || alu_fn == 'd7;
  assign ddr_ld0_stream_write_ready = 1;

  always @(posedge clk ) begin
    if(ddr_st_done)begin
      ddr_ld0_data <= 0;
    end
    else if(ddr_ld0_stream_write_req)begin
      ddr_ld0_data <= ddr_ld0_stream_write_data;
    end
  end

  always @(posedge clk ) begin
    if(ddr_ld0_stream_read_req)begin
      ddr_ld0_stream_read_data <= ddr_ld0_data;
    end
  end

//edit end



  // assign ddr_ld0_stream_write_ready = ~ld0_req_buf_almost_full;

  // generate//edit 0830
  //   for (i=0; i<SIMD_LANES; i=i+1)
  //   begin
  //       assign _ddr_ld0_stream_read_data[i] = $signed(ddr_ld0_stream_read_data[i*HALF_DATA_WIDTH+:HALF_DATA_WIDTH]);
  //       assign ddr_ld0_stream_read_data_fix[i*DATA_WIDTH+:DATA_WIDTH] = choose_8bit ? _ddr_ld0_stream_read_data[i]: 
  //                                                                                     ddr_ld0_stream_read_data[i*DATA_WIDTH+:DATA_WIDTH] ;
  //   end 
  // endgenerate

  // fifo_asymmetric #(
  //   .RD_DATA_WIDTH                  ( SIMD_DATA_WIDTH                ),
  //   .WR_DATA_WIDTH                  ( AXI_DATA_WIDTH                 ),
  //   .RD_ADDR_WIDTH                  ( 6                              )
  // ) ld0_req_buf (
  //   .clk                            ( clk                            ), //input
  //   .reset                          ( reset                          ), //input
  //   .s_write_req                    ( ddr_ld0_stream_write_req       ), //input                                                                                             
  //   .s_write_data                   ( ddr_ld0_stream_write_data      ), //output
  //   .s_write_ready                  ( ld0_req_buf_write_ready        ), //output
  //   .s_read_req                     ( ddr_ld0_stream_read_req        ), //input
  //   .s_read_ready                   ( ddr_ld0_stream_read_ready      ), //output
  //   .s_read_data                    ( ddr_ld0_stream_read_data       ), //input
  //   .almost_full                    ( ld0_req_buf_almost_full        ), //output
  //   .almost_empty                   ( ld0_req_buf_almost_empty       )  //output
  // );
`ifdef COCOTB_SIM
  integer ld0_total_writes;
  always @(posedge clk)
  begin
    if (reset)
      ld0_total_writes <= 0;
    else if (ddr_ld0_stream_write_req && ddr_ld0_stream_write_ready)
      ld0_total_writes <= ld0_total_writes + 1;
  end

  integer ld0_total_reads;
  always @(posedge clk)
  begin
    if (reset)
      ld0_total_reads <= 0;
    else if (ddr_ld0_stream_read_req && ddr_ld0_stream_read_ready)
      ld0_total_reads <= ld0_total_reads + 1;
  end
`endif // COCOTB_SIM
//==============================================================================

//==============================================================================
// PU LD1 FIFO
//==============================================================================
//edit yt
  reg [ SIMD_DATA_WIDTH      -1 : 0 ]        ddr_ld1_data=0;
  assign ddr_ld1_stream_read_ready = ddr_ld1_data != 0  || alu_fn == 'd7;
  assign ddr_ld1_stream_write_ready = 1;

  always @(posedge clk ) begin
    if(ddr_st_done)begin
      ddr_ld1_data <= 0;
    end
    else if(ddr_ld1_stream_write_req)begin
      ddr_ld1_data <= ddr_ld1_stream_write_data;
    end
  end
  always @(posedge clk ) begin
    if(ddr_ld1_stream_read_req)begin
      ddr_ld1_stream_read_data <= ddr_ld1_data;
    end
  end

//edit end
  // assign ddr_ld1_stream_write_ready = ~ld1_req_buf_almost_full;
  
  
  // generate//edit 0830
  //   for (i=0; i<SIMD_LANES; i=i+1)
  //   begin
  //       assign _ddr_ld1_stream_read_data[i] = $signed(ddr_ld1_stream_read_data[i*HALF_DATA_WIDTH+:HALF_DATA_WIDTH]);
  //       assign ddr_ld1_stream_read_data_fix[i*DATA_WIDTH+:DATA_WIDTH] = choose_8bit ? _ddr_ld1_stream_read_data[i] :
  //                                                                                     ddr_ld1_stream_read_data[i*DATA_WIDTH+:DATA_WIDTH];
  //   end 
  // endgenerate

  // fifo_asymmetric #(
  //   .RD_DATA_WIDTH                  ( SIMD_DATA_WIDTH                ),
  //   .WR_DATA_WIDTH                  ( AXI_DATA_WIDTH                 ),
  //   .RD_ADDR_WIDTH                  ( 6                              )
  // ) ld1_req_buf (
  //   .clk                            ( clk                            ), //input
  //   .reset                          ( reset                          ), //input
  //   .s_write_req                    ( ddr_ld1_stream_write_req       ), //input
  //   .s_write_data                   ( ddr_ld1_stream_write_data      ), //output
  //   .s_write_ready                  ( ld1_req_buf_write_ready        ), //output
  //   .s_read_req                     ( ddr_ld1_stream_read_req        ), //input
  //   .s_read_ready                   ( ddr_ld1_stream_read_ready      ), //output
  //   .s_read_data                    ( ddr_ld1_stream_read_data       ), //input
  //   .almost_full                    ( ld1_req_buf_almost_full        ), //output
  //   .almost_empty                   ( ld1_req_buf_almost_empty       )  //output
  // );
`ifdef COCOTB_SIM
  integer ld1_total_writes;
  always @(posedge clk)
  begin
    if (reset)
      ld1_total_writes <= 0;
    else if (ddr_ld1_stream_write_req && ddr_ld1_stream_write_ready)
      ld1_total_writes <= ld1_total_writes + 1;
  end

  integer ld1_total_reads;
  always @(posedge clk)
  begin
    if (reset)
      ld1_total_reads <= 0;
    else if (ddr_ld1_stream_read_req && ddr_ld1_stream_read_ready)
      ld1_total_reads <= ld1_total_reads + 1;
  end
`endif // COCOTB_SIM
//==============================================================================

//==============================================================================
// delays
//==============================================================================

    register_sync_with_enable #(FN_WIDTH) alu_fn_delay_reg2//edit by sy
    (clk, reset, 1'b1, alu_fn_stage2[0], alu_fn_stage3);
    register_sync_with_enable #(1) ddr_st1_stream_write_req_reg1//edit by sy
    (clk, reset, 1'b1, ddr_st1_stream_write_req, ddr_st1_stream_write_req_dly1);

    register_sync_with_enable #(1) alu_fn_valid_delay_reg2
    (clk, reset, 1'b1, alu_fn_valid_stage2[0], alu_fn_valid_stage3);




    // register_sync_with_enable #(1) alu_in1_src_delay_reg1
    // (clk, reset, 1'b1, alu_in1_src, alu_in1_src_stage2);

    // register_sync_with_enable #(SRC_ADDR_WIDTH) alu_in0_addr_delay_reg1
    // (clk, reset, 1'b1, alu_in0_addr, alu_in0_addr_stage2);

    // register_sync_with_enable #(SRC_ADDR_WIDTH) alu_in1_addr_delay_reg1
    // (clk, reset, 1'b1, alu_in1_addr, alu_in1_addr_stage2);

//==============================================================================
// PU ALU
//==============================================================================

generate
for (i=0; i<SIMD_LANES; i=i+1)
begin: ALU_INST
    wire [ ACC_DATA_WIDTH       -1 : 0 ]        local_obuf_data;
    //wire [ DATA_WIDTH           -1 : 0 ]        local_ld0_data;
    //wire [ DATA_WIDTH           -1 : 0 ]        local_ld1_data;
    wire [ ACC_DATA_WIDTH       -1 : 0 ]        local_alu_out;

    assign local_obuf_data = obuf_ld_stream_read_data[i*ACC_DATA_WIDTH+:ACC_DATA_WIDTH];
    //assign local_ld0_data = ddr_ld0_stream_read_data_fix[i*DATA_WIDTH+:DATA_WIDTH];
    //assign local_ld1_data = ddr_ld1_stream_read_data_fix[i*DATA_WIDTH+:DATA_WIDTH];
    assign alu_out[i*ACC_DATA_WIDTH+:ACC_DATA_WIDTH] = local_alu_out;

    register_sync_with_enable #(FN_WIDTH) alu_fn_delay_reg1
    (clk, reset, 1'b1, alu_fn, alu_fn_stage2[i]);
    register_sync_with_enable #(IMM_WIDTH) alu_imm_delay_reg1
    (clk, reset, 1'b1, alu_imm, alu_imm_stage2[i]);
    register_sync_with_enable #(1) alu_fn_valid_delay_reg1
    (clk, reset, 1'b1, alu_fn_valid, alu_fn_valid_stage2[i]);

    pu_alu #(
      .DATA_WIDTH                     ( DATA_WIDTH                     ),
      .ACC_DATA_WIDTH                 ( ACC_DATA_WIDTH                 ),
      .IMM_WIDTH                      ( IMM_WIDTH                      ),
      .FN_WIDTH                       ( FN_WIDTH                       )
    ) scalar_alu (
      .clk                            ( clk                            ), //input
      .fn_valid                       ( alu_fn_valid_stage2[i]            ), //alu_fn_valid_stage2            ), //input
      .fn                             ( alu_fn_stage2[i]               ), //alu_fn_stage2                  ), //input
      .imm                            ( alu_imm_stage2[i]              ), //input
      .obuf_data                      ( local_obuf_data                ), //input
      .alu_out                        ( local_alu_out                  ), //output
      .cfg_rs_num_v                   ( cfg_rs_num_v                   ),//input
      .rshift_num                     ( rshift_num                     ),//input
      .choose_8bit                    ( choose_8bit                    )  //input
      );
  // pu_alu #(
  //   .DATA_WIDTH                     ( DATA_WIDTH                     ),
  //   .ACC_DATA_WIDTH                 ( ACC_DATA_WIDTH                 ),
  //   .IMM_WIDTH                      ( IMM_WIDTH                      ),
  //   .FN_WIDTH                       ( FN_WIDTH                       )
  // ) scalar_alu (
  //   .clk                            ( clk                            ), //input
  //   .fn_valid                       ( alu_fn_valid_stage3            ), //alu_fn_valid_stage2            ), //input
  //   .fn                             ( alu_fn_stage3                  ), //alu_fn_stage2                  ), //input
  //   .imm                            ( alu_imm_stage2                 ), //input
  //   .obuf_data                      ( local_obuf_data                ), //input
  //   .ld0_data                       ( local_ld0_data                 ), //input
  //   .ld1_data                       ( local_ld1_data                 ), //input
  //   .alu_out                        ( local_alu_out                  ), //output
  //   .choose_8bit                    ( choose_8bit                    ) //input
  //);
end
endgenerate

  // always @(posedge clk)
  //   alu_out_fwd <= alu_out;
//==============================================================================

//==============================================================================
// DEBUG Counters
//==============================================================================
    reg  [ 16                   -1 : 0 ]        _obuf_ld_stream_read_count;
    reg  [ 16                   -1 : 0 ]        _obuf_ld_stream_write_count;
    reg  [ 16                   -1 : 0 ]        _ddr_st_stream_read_count;
    reg  [ 16                   -1 : 0 ]        _ddr_st_stream_write_count;

    reg  [ 16                   -1 : 0 ]        _ddr_ld0_stream_read_count;
    reg  [ 16                   -1 : 0 ]        _ddr_ld0_stream_write_count;
    reg  [ 16                   -1 : 0 ]        _ddr_ld1_stream_read_count;
    reg  [ 16                   -1 : 0 ]        _ddr_ld1_stream_write_count;

    wire [ 16                   -1 : 0 ]        _ld_req_buf_fifo_count;
    wire [ 16                   -1 : 0 ]        _st_req_buf_fifo_count;
    wire [ 16                   -1 : 0 ]        _ld0_req_buf_fifo_count;
    wire [ 16                   -1 : 0 ]        _ld1_req_buf_fifo_count;

always @(posedge clk)
begin
  if (reset) begin
    _obuf_ld_stream_read_count <= 0;
    _obuf_ld_stream_write_count <= 0;
    _ddr_st_stream_read_count <= 0;
    _ddr_st_stream_write_count <= 0;
    _ddr_ld0_stream_read_count <= 0;
    _ddr_ld0_stream_write_count <= 0;
    _ddr_ld1_stream_read_count <= 0;
    _ddr_ld1_stream_write_count <= 0;
  end else begin
    if (obuf_ld_stream_read_req)
      _obuf_ld_stream_read_count <= _obuf_ld_stream_read_count + 1'b1;
    if (obuf_ld_stream_write_req)
    _obuf_ld_stream_write_count <= _obuf_ld_stream_write_count + 1'b1;
    if (ddr_st_stream_read_req)
    _ddr_st_stream_read_count <= _ddr_st_stream_read_count + 1'b1;
    if (ddr_st_stream_write_req)
    _ddr_st_stream_write_count <= _ddr_st_stream_write_count + 1'b1;
    if (ddr_ld0_stream_read_req)
      _ddr_ld0_stream_read_count <= _ddr_ld0_stream_read_count + 1'b1;
    if (ddr_ld0_stream_write_req)
      _ddr_ld0_stream_write_count <= _ddr_ld0_stream_write_count + 1'b1;
    if (ddr_ld1_stream_read_req)
      _ddr_ld1_stream_read_count <= _ddr_ld1_stream_read_count + 1'b1;
    if (ddr_ld1_stream_write_req)
      _ddr_ld1_stream_write_count <= _ddr_ld1_stream_write_count + 1'b1;
  end
end

    assign _ld_req_buf_fifo_count = ld_req_buf.fifo_count;
    assign _st_req_buf_fifo_count = st_req_buf.fifo_count;
    assign _ld0_req_buf_fifo_count = 0;//ld0_req_buf.fifo_count; edit yt
    assign _ld1_req_buf_fifo_count = 0;//ld1_req_buf.fifo_count; edit yt



    assign obuf_ld_stream_read_count = {_obuf_ld_stream_read_count, _obuf_ld_stream_write_count};
    assign obuf_ld_stream_write_count = {_ddr_st_stream_read_count, _ddr_st_stream_write_count};
    assign ddr_st_stream_read_count = {_ld_req_buf_fifo_count, _st_req_buf_fifo_count};
    assign ddr_st_stream_write_count = {_ld1_req_buf_fifo_count, _ld0_req_buf_fifo_count};
    assign ld0_stream_counts = {_ddr_ld0_stream_read_count, _ddr_ld0_stream_write_count};
    assign ld1_stream_counts = {_ddr_ld1_stream_read_count, _ddr_ld1_stream_write_count};
//==============================================================================

//==============================================================================
// VCD
//==============================================================================
`ifdef COCOTB_TOPLEVEL_simd_pu_core
  initial begin
    $dumpfile("simd_pu_core.vcd");
    $dumpvars(0, simd_pu_core);
  end
`endif
//==============================================================================

endmodule
