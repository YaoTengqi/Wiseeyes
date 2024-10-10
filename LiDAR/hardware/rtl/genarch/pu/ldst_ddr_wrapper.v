//
// Wrapper for memory
//
// Hardik Sharma
// (hsharma@gatech.edu)

`timescale 1ns/1ps
module ldst_ddr_wrapper #(
  // Internal Parameters
    parameter integer  MEM_ID                       = 0,
    parameter integer  STORE_ENABLED                = MEM_ID == 1 ? 1 : 0,
    parameter integer  MEM_REQ_W                    = 16,
    parameter integer  LOOP_ITER_W                  = 16,
    parameter integer  ADDR_STRIDE_W                = 16,
    parameter integer  LOOP_ID_W                    = 5,
    parameter integer  BUF_TYPE_W                   = 2,
    parameter integer  NUM_TAGS                     = 4,
    parameter integer  TAG_W                        = $clog2(NUM_TAGS),
    parameter integer  SIMD_DATA_WIDTH              = 256,
    parameter integer  MEM_TYPE_WIDTH               = 2,                                                                                //edit by sy 0702
    parameter integer  STRIDE_TYPE_WIDTH               = 4,                                                                               //edit by sy 0702    
  // AXI
    parameter integer  AXI_ID_WIDTH                 = 1,
    parameter integer  AXI_ADDR_WIDTH               = 42,
    parameter integer  AXI_DATA_WIDTH               = 64,
    parameter integer  AXI_BURST_WIDTH              = 8,
    parameter integer  WSTRB_W                      = AXI_DATA_WIDTH/8
) (
    input  wire                                         clk,
    input  wire                                         reset,

    input  wire                                         pu_block_start,
    input  wire                                         start,
    output wire                                         done,

    input  wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        st_base_addr,
    input  wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        st1_base_addr,                                                                                          //edit by sy 0618
    input  wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        ld0_base_addr,
    input  wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        ld1_base_addr,

    output wire                                        st1_data_required,                                                                                                    //edit by sy 0618
  // Programming
    input  wire                                         cfg_loop_stride_v,
    input  wire  [ ADDR_STRIDE_W        -1 : 0 ]        cfg_loop_stride,
    input  wire  [ STRIDE_TYPE_WIDTH         -1 : 0 ]        cfg_loop_stride_type,

    input  wire  [ LOOP_ITER_W          -1 : 0 ]        cfg_loop_iter,
    input  wire                                         cfg_loop_iter_v,
    input  wire  [ 3                    -1 : 0 ]        cfg_loop_iter_type,

    input  wire                                         cfg_mem_req_v,
    input  wire  [ MEM_TYPE_WIDTH                    -1 : 0 ]        cfg_mem_req_type,
    input wire  [STRIDE_TYPE_WIDTH -1 :0]          upsample_num,                                                                                                      //edit by sy 0706
  // Master Interface Write Address
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        pu_ddr_awaddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        pu_ddr_awlen,
    output wire  [ 3                    -1 : 0 ]        pu_ddr_awsize,
    output wire  [ 2                    -1 : 0 ]        pu_ddr_awburst,
    output wire                                         pu_ddr_awvalid,
    input  wire                                         pu_ddr_awready,
  // Master Interface Write Data
    output wire  [ AXI_DATA_WIDTH       -1 : 0 ]        pu_ddr_wdata,
    output wire  [ WSTRB_W              -1 : 0 ]        pu_ddr_wstrb,
    output wire                                         pu_ddr_wlast,
    output wire                                         pu_ddr_wvalid,
    input  wire                                         pu_ddr_wready,
  // Master Interface Write Response
    input  wire  [ 2                    -1 : 0 ]        pu_ddr_bresp,
    input  wire                                         pu_ddr_bvalid,
    output wire                                         pu_ddr_bready,
  // Master Interface Read Address
    output wire  [ 1                    -1 : 0 ]        pu_ddr_arid,
    output wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        pu_ddr_araddr,
    output wire  [ AXI_BURST_WIDTH      -1 : 0 ]        pu_ddr_arlen,
    output wire  [ 3                    -1 : 0 ]        pu_ddr_arsize,
    output wire  [ 2                    -1 : 0 ]        pu_ddr_arburst,
    output wire                                         pu_ddr_arvalid,
    input  wire                                         pu_ddr_arready,
  // Master Interface Read Data
    input  wire  [ 1                    -1 : 0 ]        pu_ddr_rid,
    input  wire  [ AXI_DATA_WIDTH       -1 : 0 ]        pu_ddr_rdata,
    input  wire  [ 2                    -1 : 0 ]        pu_ddr_rresp,
    input  wire                                         pu_ddr_rlast,
    input  wire                                         pu_ddr_rvalid,
    output wire                                         pu_ddr_rready,

  // LD0
    output wire                                         ddr_ld0_stream_write_req,
    input  wire                                         ddr_ld0_stream_write_ready,
    output wire  [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_ld0_stream_write_data,

  // LD1
    output wire                                         ddr_ld1_stream_write_req,
    input  wire                                         ddr_ld1_stream_write_ready,
    output wire  [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_ld1_stream_write_data,

  // Stores
    output wire                                         ddr_st_stream_read_req,
    input  wire                                         ddr_st_stream_read_ready,
    input  wire  [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_st_stream_read_data

);

//==============================================================================
// Localparams
//==============================================================================
//==============================================================================

//==============================================================================
// Wires/Regs
//==============================================================================
    wire                                        st_done;
    wire [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_ld0_data;
    wire [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_ld1_data;
  // Loads
    wire                                        mem_write_req;
    wire                                        mem_write_ready;
    wire [ AXI_DATA_WIDTH       -1 : 0 ]        mem_write_data;
    wire [ AXI_ID_WIDTH         -1 : 0 ]        mem_write_id;

    wire                                        ld0_req_buf_almost_full;
    wire                                        ld0_req_buf_almost_empty;

    wire [ AXI_ID_WIDTH         -1 : 0 ]        ld_req_id;
    
                                                                                                                                                                                                   //edit by sy 0618 begin
    wire [ MEM_REQ_W            -1 : 0 ]        st_req_size;
    
    wire                                        st_ready;
    wire                                        st_addr_req;
    wire [ AXI_ADDR_WIDTH       -1 : 0 ]        st_addr;
        
    wire                                        st0_stall;
    wire [ AXI_ADDR_WIDTH       -1 : 0 ]        st0_addr;
    wire                                        st0_addr_req;
    wire                                        st0_addr_valid;
    wire [ ADDR_STRIDE_W        -1 : 0 ]        st0_stride;
    wire                                        st0_stride_v;
    wire                                        st0_ready;
    reg  [ LOOP_ID_W            -1 : 0 ]        st0_loop_id_counter;
    wire                                        st0_loop_iter_v;
    wire [ LOOP_ITER_W          -1 : 0 ]        st0_loop_iter;
    wire                                        st0_loop_done;
    wire                                        st0_loop_init;
    wire                                        st_loop_enter;
    wire                                        st_loop_exit;
    wire [ LOOP_ID_W            -1 : 0 ]        st0_loop_index;
    wire                                        st0_loop_index_valid;
    wire                                        st0_loop_index_step;

    wire                                        st1_stall;
    wire [ AXI_ADDR_WIDTH       -1 : 0 ]        st1_addr;
    wire                                        st1_addr_req;
    wire                                        st1_addr_valid;
    wire [ ADDR_STRIDE_W        -1 : 0 ]        st1_stride;
    wire                                        st1_stride_v;
    wire                                        st1_ready;
    reg  [ LOOP_ID_W            -1 : 0 ]        st1_loop_id_counter;
    wire                                        st1_loop_iter_v;
    wire [ LOOP_ITER_W          -1 : 0 ]        st1_loop_iter;
    wire                                        st1_loop_done;
    wire                                        st1_loop_init;
    wire                                        st1_loop_enter;
    wire                                        st1_loop_exit;
    wire [ LOOP_ID_W            -1 : 0 ]        st1_loop_index;
    wire                                        st1_loop_index_valid;
    wire                                        st1_loop_index_step;
//edit by sy 0618 end

    wire [ AXI_ADDR_WIDTH       -1 : 0 ]        ld_addr;
    wire                                        ld_addr_req;
    wire                                        ld_ready;
    wire                                        ld_done;
    wire [ MEM_REQ_W            -1 : 0 ]        ld_req_size;

    wire                                        ld0_stall;
    wire [ AXI_ADDR_WIDTH       -1 : 0 ]        ld0_addr;
    wire                                        ld0_addr_req;
    wire [ ADDR_STRIDE_W        -1 : 0 ]        ld0_stride;
    wire                                        ld0_stride_v;
    reg                                         ld0_required;
    wire                                        ld0_ready;
    reg  [ LOOP_ID_W            -1 : 0 ]        ld0_loop_id_counter;
    wire                                        ld0_loop_iter_v;
    wire [ LOOP_ITER_W          -1 : 0 ]        ld0_loop_iter;
    wire                                        ld0_loop_done;
    wire                                        ld0_loop_init;
    wire                                        ld0_loop_enter;
    wire                                        ld0_loop_exit;
    wire [ LOOP_ID_W            -1 : 0 ]        ld0_loop_index;
    wire                                        ld0_loop_index_valid;
    wire                                        ld0_loop_index_step;

    wire                                        ld1_stall;
    wire [ AXI_ADDR_WIDTH       -1 : 0 ]        ld1_addr;
    wire                                        ld1_addr_req;
    wire [ ADDR_STRIDE_W        -1 : 0 ]        ld1_stride;
    wire                                        ld1_stride_v;
    reg                                         ld1_required;
    wire                                        ld1_ready;
    reg  [ LOOP_ID_W            -1 : 0 ]        ld1_loop_id_counter;
    wire                                        ld1_loop_iter_v;
    wire [ LOOP_ITER_W          -1 : 0 ]        ld1_loop_iter;
    wire                                        ld1_loop_done;
    wire                                        ld1_loop_init;
    wire                                        ld1_loop_enter;
    wire                                        ld1_loop_exit;
    wire [ LOOP_ID_W            -1 : 0 ]        ld1_loop_index;
    wire                                        ld1_loop_index_valid;
    wire                                        ld1_loop_index_step;
    reg                                         st1_required;
    
    wire                                        mem_read_req;
    wire                                        mem_read_ready;
    wire [ AXI_DATA_WIDTH       -1 : 0 ]   mem_read_data;
   //upsample                                                                                                                                                               //edit by sy 0706
   reg                                         upsample_required;   
   reg [3-1 : 0]                           upsample_state;
   wire [3-1 : 0]                           upsample_state_q;   
   wire [3-1 : 0]                           _upsample_state;      
   reg  [STRIDE_TYPE_WIDTH + STRIDE_TYPE_WIDTH -1 :0]          _upsample_num;
   reg [STRIDE_TYPE_WIDTH + STRIDE_TYPE_WIDTH -1 :0]      upsample_compute;
   wire                                         _ddr_st_stream_read_req;
   wire                                         _ddr_st_stream_read_ready;
   reg  [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_st_stream_read_data_reg;
   wire  [ AXI_DATA_WIDTH       -1 : 0 ]       _ddr_st_stream_read_data;
   wire                                         st1_start;
//==============================================================================                          //edit by sy 0618 end

//==============================================================================
// LD/ST required
//==============================================================================
  always @(posedge clk)
  begin
    if (reset)
      ld0_required <= 1'b0;
    else begin
      if (pu_block_start)
        ld0_required <= 1'b0;
      else if (cfg_mem_req_v && cfg_mem_req_type == 2)
        ld0_required <= 1'b1;
    end
  end

  always @(posedge clk)
  begin
    if (reset)
      ld1_required <= 1'b0;
    else begin
      if (pu_block_start)
        ld1_required <= 1'b0;
      else if (cfg_mem_req_v && cfg_mem_req_type == 3)
        ld1_required <= 1'b1;
    end
  end

  always @(posedge clk)                                                                                                                         //edit by sy 0705 begin
  begin
    if (reset)
      upsample_required <= 1'b0;
    else begin
      if (pu_block_start) 
        upsample_required <= 1'b0;
      else if (cfg_mem_req_v && cfg_mem_req_type == 1) begin
        upsample_required <= 1'b1;
        _upsample_num <= upsample_num * upsample_num -2'd2; 
        end
    end
  end                                                                                                                                                       //edit by sy 0705 end

  always @(posedge clk)
  begin
    if (reset)
      st1_required <= 1'b0;
    else begin
      if (pu_block_start)
        st1_required <= 1'b0;
      else if (cfg_mem_req_v && cfg_mem_req_type == 0)
        st1_required <= 1'b1;
    end
  end
//=====upsample==================================================================    edit by sy 0705 begin

    assign _upsample_state = upsample_state;
    register_sync_with_enable #(3) stage2_fwd_rs0(clk, reset, 1'b1, _upsample_state, upsample_state_q);  

  always @(posedge clk)
    if (reset)
      upsample_state <= 1'b0;
    else begin
    case (upsample_state)
      0: begin
        if (start)
            upsample_state <= 3'd1;
         end
      1: begin
        if (~st_done)
            if(upsample_required) begin
                upsample_state <= 3'd3;
                upsample_compute <= _upsample_num;
                end
            else    
                upsample_state <= 3'd2;
         end         
      2: begin
        if (st_done)
          upsample_state <= 1'b0;
         end   
      3: begin
        if(_ddr_st_stream_read_req)
          upsample_state <= 3'd4;
        else if(st_done)
          upsample_state <= 1'b0;
      end           
      4: begin
        if(_ddr_st_stream_read_req) begin
          ddr_st_stream_read_data_reg <= ddr_st_stream_read_data;
          upsample_state <= 3'd5;
          end
         end              
      5: begin
        if(_ddr_st_stream_read_req)
          upsample_state <= 3'd6;
      end                            
      6: begin
        if(_ddr_st_stream_read_req) begin       
          if(upsample_compute == 1'd0) begin
            upsample_state <= 3'd3;
            upsample_compute <= _upsample_num;
            end
          else begin
            upsample_state <= 3'd5;
            upsample_compute <= upsample_compute - 1'b1;
            end
        end         
      end
    endcase
  end

assign _ddr_st_stream_read_data = upsample_state_q == 3'd5 ? ddr_st_stream_read_data_reg:ddr_st_stream_read_data;
assign ddr_st_stream_read_req = _ddr_st_stream_read_req && (upsample_state == 3'd3 || upsample_state == 3'd4 || upsample_state == 3'd2);
assign _ddr_st_stream_read_ready = ddr_st_stream_read_ready || (upsample_state == 3'd5) || (upsample_state == 3'd6);
                                                                                                                                                                                                 // edit by sy 0705 end
//==============================================================================
// Assigns
//==============================================================================
    assign st1_data_required = st1_required;

    assign st1_stride_v  = cfg_loop_stride_v && (cfg_loop_stride_type == 4);                                                                                //edit by sy 0618
    assign st0_stride_v  = cfg_loop_stride_v && (cfg_loop_stride_type == 1);
    assign ld0_stride_v = cfg_loop_stride_v && (cfg_loop_stride_type == 2);
    assign ld1_stride_v = cfg_loop_stride_v && (cfg_loop_stride_type == 3);

    assign st0_stall  = ~st0_ready;
    assign st1_stall  = ~st1_ready;                                                                                                                                                     //edit by sy 0618
    
    assign ld0_stall = ld0_required && ~ld0_ready;
    assign ld1_stall = ld1_required && ~ld1_ready;
    assign st0_addr_req = st0_addr_valid && ~st0_stall;
    assign st1_addr_req = st1_addr_valid && ~st1_stall;                                                                                                                 //edit by sy 0618
//==============================================================================

//==============================================================================
// FSM for Loads
//==============================================================================
    reg                                         ld_addr_state_d;
    reg                                         ld_addr_state_q;
  always @(posedge clk)
  begin
    if (reset)
      ld_addr_state_q <= 1'b0;
    else
      ld_addr_state_q <= ld_addr_state_d;
  end
  always @(*)
  begin
    ld_addr_state_d = ld_addr_state_q;
    case (ld_addr_state_q)
      0: begin
        if (ld0_required && ld0_addr_req && ld_ready)
          ld_addr_state_d = 1'b1;
      end
      1: begin
        if (ld1_required && ld1_addr_req && ld_ready)
          ld_addr_state_d = 1'b0;
      end
    endcase
  end

    assign ld0_ready = ld_ready && ld_addr_state_q == 1'b0;
    assign ld1_ready = ld_ready && ld_addr_state_q == 1'b1;

    assign ld_req_size = SIMD_DATA_WIDTH / AXI_DATA_WIDTH;
    assign ld_addr = ld_addr_state_q == 1'b0 ? ld0_addr : ld1_addr;
    assign ld_addr_req = (ld_addr_state_q == 1'b0 ? ld0_addr_req && ld0_required : ld1_addr_req && ld1_required) && ld_ready;
    assign ld_req_id = ld_addr_state_q;

    assign ddr_ld0_stream_write_req = mem_write_id == 1'b0 && mem_write_req;
    assign ddr_ld0_stream_write_data = mem_write_data;

    assign ddr_ld1_stream_write_req = mem_write_id == 1'b1 && mem_write_req;
    assign ddr_ld1_stream_write_data = mem_write_data;

    // assign mem_write_ready = mem_write_id == 1'b0 ? ddr_ld0_stream_write_ready : ddr_ld1_stream_write_ready;
    assign mem_write_ready = ddr_ld0_stream_write_ready && ddr_ld1_stream_write_ready;
    // assign mem_write_ready = (ddr_ld0_stream_write_ready || ~ld0_required) &&
                             // (ddr_ld1_stream_write_ready || ~ld1_required);
//==============================================================================

//==============================================================================
// FSM for Stores
//==============================================================================                                                edit by sy 0618 begin
    reg       [3-1:0]                                  st_addr_state_d;
    reg       [3-1:0]                                  st_addr_state_q;
  always @(posedge clk)
  begin
    if (reset)
      st_addr_state_q <= 1'b0;
    else
      st_addr_state_q <= st_addr_state_d;
  end
  always @(*)
  begin
    st_addr_state_d = st_addr_state_q;
    case (st_addr_state_q)
      0: begin
        if(start) begin
            if (st1_required)  
                st_addr_state_d = 3'd1;
            else 
                st_addr_state_d = 3'd5;  
        end
      end      
      1: begin
        if (st1_required && st1_addr_valid && st_ready)
          st_addr_state_d = 3'd2;
        else if(st0_loop_done)
          st_addr_state_d = 3'd0;              
      end
      2: begin
        if (st1_required && st1_addr_valid && st_ready)
          st_addr_state_d = 3'd3;
      end      
       3: begin
        if (st1_addr_valid && st_ready)
          st_addr_state_d = 3'd4;
      end         
       4: begin
        if (st1_addr_valid && st_ready)
          st_addr_state_d = 3'd5;
      end               
      5: begin
        if (st1_required && st0_addr_valid && st_ready)
          st_addr_state_d = 3'd1;
        else if(st0_loop_done)
          st_addr_state_d = 3'd0;  
      end
    endcase
  end

    assign st0_ready = st_ready && st_addr_state_q == 3'd5;
    assign st1_ready = st_ready && (st_addr_state_q == 2'd1 ||st_addr_state_q == 2'd2 ||st_addr_state_q == 2'd3||st_addr_state_q == 3'd4);

    assign st_req_size = SIMD_DATA_WIDTH / AXI_DATA_WIDTH;
    assign st_addr = (st_addr_state_q == 3'd5 ||st_addr_state_q == 3'd0 ) ? st0_addr : st1_addr;
    assign st_addr_req = (st_addr_state_q == 3'd5 ? st0_addr_req : st1_addr_req && st1_required) && st_ready;

//==============================================================================                                                edit by sy 0618 end
  reg [2-1:0] st_state_d;
  reg [2-1:0] st_state_q;
  reg [5-1:0] wait_cycles_d;
  reg [5-1:0] wait_cycles_q;
  localparam integer ST_IDLE = 0;
  localparam integer ST_BUSY = 1;
  localparam integer ST_WAIT = 2;
  localparam integer ST_DONE = 3;

  always @(posedge clk)
  begin
    if (reset) begin
      st_state_q <= ST_IDLE;
      wait_cycles_q <= 0;
    end else begin
      st_state_q <= st_state_d;
      wait_cycles_q <= wait_cycles_d;
    end
  end

  always @(*)
  begin
    st_state_d = st_state_q;
    wait_cycles_d = wait_cycles_q;
    case (st_state_q)
      ST_IDLE: begin
        if (start)
          st_state_d = ST_BUSY;
      end
      ST_BUSY: begin
        if (st0_loop_done) begin
          st_state_d = ST_WAIT;
          wait_cycles_d = 4;
        end
      end
      ST_WAIT: begin
        if (wait_cycles_q != 0)
          wait_cycles_d = wait_cycles_d - 1'b1;
        else if (st_done)
          st_state_d = ST_DONE;
      end
      ST_DONE: begin
        st_state_d = ST_IDLE;
      end
    endcase
  end

  assign done = st_state_q == ST_DONE;
//==============================================================================

//==============================================================================
// Loop controller - ST0
//==============================================================================
  always@(posedge clk)
  begin
    if (reset)
      st0_loop_id_counter <= 'b0;
    else begin
      if (cfg_loop_iter_v && cfg_loop_iter_type == 1)
        st0_loop_id_counter <= st0_loop_id_counter + 1'b1;
      else if (start)
        st0_loop_id_counter <= 'b0;
    end
  end

    assign st0_loop_iter_v = cfg_loop_iter_v && cfg_loop_iter_type == 1;
    assign st0_loop_iter = cfg_loop_iter;

  controller_fsm #(
    .LOOP_ID_W                      ( LOOP_ID_W                      ),
    .LOOP_ITER_W                    ( LOOP_ITER_W                    ),
    .IMEM_ADDR_W                    ( LOOP_ID_W                      )
  ) loop_ctrl_st (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .stall                          ( st0_stall                       ), //input
    .cfg_loop_iter_v                ( st0_loop_iter_v                 ), //input
    .cfg_loop_iter                  ( st0_loop_iter                   ), //input
    .cfg_loop_iter_loop_id          ( st0_loop_id_counter             ), //input
    .start                          ( start                          ), //input
    .done                           ( st0_loop_done                   ), //output
    .loop_init                      ( st0_loop_init                   ), //output
    .loop_enter                     ( st_loop_enter                  ), //output
    .loop_last_iter                 (                                ), //output
    .loop_exit                      ( st_loop_exit                   ), //output
    .loop_index                     ( st0_loop_index                  ), //output
    .loop_index_valid               ( st0_loop_index_valid            )  //output
  );
//==============================================================================

//==============================================================================
// Address generators - ST0
//==============================================================================
    assign st0_stride = cfg_loop_stride * SIMD_DATA_WIDTH / 8;
    assign st0_loop_index_step = st0_loop_index_valid && ~st0_stall;
  mem_walker_stride #(
    .ADDR_WIDTH                     ( AXI_ADDR_WIDTH                 ),
    .ADDR_STRIDE_W                  ( ADDR_STRIDE_W                  ),
    .LOOP_ID_W                      ( LOOP_ID_W                      )
  ) mws_st (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .base_addr                      ( st_base_addr                   ), //input
    .loop_ctrl_done                 ( st0_loop_done                   ), //input
    .loop_index                     ( st0_loop_index                  ), //input
    .loop_index_valid               ( st0_loop_index_step             ), //input
    .loop_init                      ( st0_loop_init                   ), //input
    .loop_enter                     ( st_loop_enter                  ), //input
    .loop_exit                      ( st_loop_exit                   ), //input
    .cfg_addr_stride_v              ( st0_stride_v                    ), //input
    .cfg_addr_stride                ( st0_stride                      ), //input
    .addr_out                       ( st0_addr                        ), //output
    .addr_out_valid                 ( st0_addr_valid                  )  //output
  );
//==============================================================================

//==============================================================================
// Loop controller - ST1                                                                                                                                                   edit by sy 0618 begin
//==============================================================================
  always@(posedge clk)
  begin
    if (reset)
      st1_loop_id_counter <= 'b0;
    else begin
      if (cfg_loop_iter_v && cfg_loop_iter_type == 4)
        st1_loop_id_counter <= st1_loop_id_counter + 1'b1;
      else if (start)
        st1_loop_id_counter <= 'b0;
    end
  end

    assign st1_loop_iter_v = cfg_loop_iter_v && cfg_loop_iter_type == 4;
    assign st1_loop_iter = cfg_loop_iter;
    assign st1_start = start && st1_required;

  controller_fsm #(
    .LOOP_ID_W                      ( LOOP_ID_W                      ),
    .LOOP_ITER_W                    ( LOOP_ITER_W                    ),
    .IMEM_ADDR_W                    ( LOOP_ID_W                      )
  ) loop_ctrl_st1 (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .stall                          ( st1_stall                       ), //input
    .cfg_loop_iter_v                ( st1_loop_iter_v                 ), //input
    .cfg_loop_iter                  ( st1_loop_iter                   ), //input
    .cfg_loop_iter_loop_id          ( st1_loop_id_counter             ), //input
    .start                          ( st1_start                          ), //input                                         //edit by sy 0722
    .done                           ( st1_loop_done                   ), //output
    .loop_init                      ( st1_loop_init                   ), //output
    .loop_enter                     ( st1_loop_enter                  ), //output
    .loop_last_iter                 (                                ), //output
    .loop_exit                      ( st1_loop_exit                   ), //output
    .loop_index                     ( st1_loop_index                  ), //output
    .loop_index_valid               ( st1_loop_index_valid            )  //output
  );
//==============================================================================

//==============================================================================
// Address generators - ST1
//==============================================================================
    assign st1_stride = cfg_loop_stride * SIMD_DATA_WIDTH / 8;
    assign st1_loop_index_step = st1_loop_index_valid && ~st1_stall;
  mem_walker_stride #(
    .ADDR_WIDTH                     ( AXI_ADDR_WIDTH                 ),
    .ADDR_STRIDE_W                  ( ADDR_STRIDE_W                  ),
    .LOOP_ID_W                      ( LOOP_ID_W                      )
  ) mws_st1 (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .base_addr                      ( st1_base_addr                   ), //input
    .loop_ctrl_done                 ( st1_loop_done                   ), //input
    .loop_index                     ( st1_loop_index                  ), //input
    .loop_index_valid               ( st1_loop_index_step             ), //input
    .loop_init                      ( st1_loop_init                   ), //input
    .loop_enter                     ( st1_loop_enter                  ), //input
    .loop_exit                      ( st1_loop_exit                   ), //input
    .cfg_addr_stride_v              ( st1_stride_v                    ), //input
    .cfg_addr_stride                ( st1_stride                      ), //input
    .addr_out                       ( st1_addr                        ), //output
    .addr_out_valid                 ( st1_addr_valid                  )  //output
  );
//==============================================================================                                    edit by sy 0618 end

//==============================================================================
// Loop controller - LD0
//==============================================================================
  always@(posedge clk)
  begin
    if (reset)
      ld0_loop_id_counter <= 'b0;
    else begin
      if (cfg_loop_iter_v && cfg_loop_iter_type == 2)
        ld0_loop_id_counter <= ld0_loop_id_counter + 1'b1;
      else if (start)
        ld0_loop_id_counter <= 'b0;
    end
  end

    assign ld0_loop_iter_v = cfg_loop_iter_v && cfg_loop_iter_type == 2;
    assign ld0_loop_iter = cfg_loop_iter;

  controller_fsm #(
    .LOOP_ID_W                      ( LOOP_ID_W                      ),
    .LOOP_ITER_W                    ( LOOP_ITER_W                    ),
    .IMEM_ADDR_W                    ( LOOP_ID_W                      )
  ) loop_ctrl_ld0 (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .stall                          ( ld0_stall                      ), //input
    .cfg_loop_iter_v                ( ld0_loop_iter_v                ), //input
    .cfg_loop_iter                  ( ld0_loop_iter                  ), //input
    .cfg_loop_iter_loop_id          ( ld0_loop_id_counter            ), //input
    .start                          ( start                          ), //input
    .done                           ( ld0_loop_done                  ), //output
    .loop_init                      ( ld0_loop_init                  ), //output
    .loop_enter                     ( ld0_loop_enter                 ), //output
    .loop_last_iter                 (                                ), //output
    .loop_exit                      ( ld0_loop_exit                  ), //output
    .loop_index                     ( ld0_loop_index                 ), //output
    .loop_index_valid               ( ld0_loop_index_valid           )  //output
  );
//==============================================================================

//==============================================================================
// Address generators - LD0
//==============================================================================
    assign ld0_loop_index_step = ld0_loop_index_valid && ~ld0_stall;
    assign ld0_stride = cfg_loop_stride * SIMD_DATA_WIDTH / 8;
  mem_walker_stride #(
    .ADDR_WIDTH                     ( AXI_ADDR_WIDTH                 ),
    .ADDR_STRIDE_W                  ( ADDR_STRIDE_W                  ),
    .LOOP_ID_W                      ( LOOP_ID_W                      )
  ) mws_ld0 (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .base_addr                      ( ld0_base_addr                  ), //input
    .loop_ctrl_done                 ( ld0_loop_done                  ), //input
    .loop_index                     ( ld0_loop_index                 ), //input
    .loop_index_valid               ( ld0_loop_index_step            ), //input
    .loop_init                      ( ld0_loop_init                  ), //input
    .loop_enter                     ( ld0_loop_enter                 ), //input
    .loop_exit                      ( ld0_loop_exit                  ), //input
    .cfg_addr_stride_v              ( ld0_stride_v                   ), //input
    .cfg_addr_stride                ( ld0_stride                     ), //input
    .addr_out                       ( ld0_addr                       ), //output
    .addr_out_valid                 ( ld0_addr_req                   )  //output
  );
//==============================================================================

//==============================================================================
// Loop controller - LD1
//==============================================================================
  always@(posedge clk)
  begin
    if (reset)
      ld1_loop_id_counter <= 'b0;
    else begin
      if (cfg_loop_iter_v && cfg_loop_iter_type == 3)
        ld1_loop_id_counter <= ld1_loop_id_counter + 1'b1;
      else if (start)
        ld1_loop_id_counter <= 'b0;
    end
  end

    assign ld1_loop_iter_v = cfg_loop_iter_v && cfg_loop_iter_type == 3;
    assign ld1_loop_iter = cfg_loop_iter;

  controller_fsm #(
    .LOOP_ID_W                      ( LOOP_ID_W                      ),
    .LOOP_ITER_W                    ( LOOP_ITER_W                    ),
    .IMEM_ADDR_W                    ( LOOP_ID_W                      )
  ) loop_ctrl_ld1 (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .stall                          ( ld1_stall                      ), //input
    .cfg_loop_iter_v                ( ld1_loop_iter_v                ), //input
    .cfg_loop_iter                  ( ld1_loop_iter                  ), //input
    .cfg_loop_iter_loop_id          ( ld1_loop_id_counter            ), //input
    .start                          ( start                          ), //input
    .done                           ( ld1_loop_done                  ), //output
    .loop_init                      ( ld1_loop_init                  ), //output
    .loop_enter                     ( ld1_loop_enter                 ), //output
    .loop_last_iter                 (                                ), //output
    .loop_exit                      ( ld1_loop_exit                  ), //output
    .loop_index                     ( ld1_loop_index                 ), //output
    .loop_index_valid               ( ld1_loop_index_valid           )  //output
  );
//==============================================================================

//==============================================================================
// Address generators - LD1
//==============================================================================
    assign ld1_loop_index_step = ld1_loop_index_valid && ~ld1_stall;
    assign ld1_stride = cfg_loop_stride * SIMD_DATA_WIDTH / 8;
  mem_walker_stride #(
    .ADDR_WIDTH                     ( AXI_ADDR_WIDTH                 ),
    .ADDR_STRIDE_W                  ( ADDR_STRIDE_W                  ),
    .LOOP_ID_W                      ( LOOP_ID_W                      )
  ) mws_ld1 (
    .clk                            ( clk                            ), //input
    .reset                          ( reset                          ), //input
    .base_addr                      ( ld1_base_addr                  ), //input
    .loop_ctrl_done                 ( ld1_loop_done                  ), //input
    .loop_index                     ( ld1_loop_index                 ), //input
    .loop_index_valid               ( ld1_loop_index_step            ), //input
    .loop_init                      ( ld1_loop_init                  ), //input
    .loop_enter                     ( ld1_loop_enter                 ), //input
    .loop_exit                      ( ld1_loop_exit                  ), //input
    .cfg_addr_stride_v              ( ld1_stride_v                   ), //input
    .cfg_addr_stride                ( ld1_stride                     ), //input
    .addr_out                       ( ld1_addr                       ), //output
    .addr_out_valid                 ( ld1_addr_req                   )  //output
  );
//==============================================================================

//==============================================================================
// AXI4 Memory Mapped interface
//==============================================================================
  wire [AXI_ID_WIDTH-1:0] st_addr_req_id;
  assign st_addr_req_id = 0;
  axi_master #(
    .TX_SIZE_WIDTH                  ( MEM_REQ_W                      ),
    .AXI_DATA_WIDTH                 ( AXI_DATA_WIDTH                 ),
    .AXI_ADDR_WIDTH                 ( AXI_ADDR_WIDTH                 ),
    .AXI_BURST_WIDTH                ( AXI_BURST_WIDTH                )
  ) u_axi_mm_master (
    .clk                            ( clk                            ),
    .reset                          ( reset                          ),
    .m_axi_awaddr                   ( pu_ddr_awaddr                  ),
    .m_axi_awlen                    ( pu_ddr_awlen                   ),
    .m_axi_awsize                   ( pu_ddr_awsize                  ),
    .m_axi_awburst                  ( pu_ddr_awburst                 ),
    .m_axi_awvalid                  ( pu_ddr_awvalid                 ),
    .m_axi_awready                  ( pu_ddr_awready                 ),
    .m_axi_wdata                    ( pu_ddr_wdata                   ),
    .m_axi_wstrb                    ( pu_ddr_wstrb                   ),
    .m_axi_wlast                    ( pu_ddr_wlast                   ),
    .m_axi_wvalid                   ( pu_ddr_wvalid                  ),
    .m_axi_wready                   ( pu_ddr_wready                  ),
    .m_axi_bresp                    ( pu_ddr_bresp                   ),
    .m_axi_bvalid                   ( pu_ddr_bvalid                  ),
    .m_axi_bready                   ( pu_ddr_bready                  ),
    .m_axi_arid                     ( pu_ddr_arid                    ),
    .m_axi_araddr                   ( pu_ddr_araddr                  ),
    .m_axi_arlen                    ( pu_ddr_arlen                   ),
    .m_axi_arsize                   ( pu_ddr_arsize                  ),
    .m_axi_arburst                  ( pu_ddr_arburst                 ),
    .m_axi_arvalid                  ( pu_ddr_arvalid                 ),
    .m_axi_arready                  ( pu_ddr_arready                 ),
    .m_axi_rid                      ( pu_ddr_rid                     ),
    .m_axi_rdata                    ( pu_ddr_rdata                   ),
    .m_axi_rresp                    ( pu_ddr_rresp                   ),
    .m_axi_rlast                    ( pu_ddr_rlast                   ),
    .m_axi_rvalid                   ( pu_ddr_rvalid                  ),
    .m_axi_rready                   ( pu_ddr_rready                  ),
    // Buffer
    .mem_write_id                   ( mem_write_id                   ),
    .mem_write_req                  ( mem_write_req                  ),
    .mem_write_data                 ( mem_write_data                 ),
    .mem_write_ready                ( mem_write_ready                ),
    .mem_read_req                   ( _ddr_st_stream_read_req         ),                                                                                //edit by sy 0705
    .mem_read_data                  ( _ddr_st_stream_read_data        ),
    .mem_read_ready                 ( _ddr_st_stream_read_ready       ),
    // AXI RD Req
    .rd_req_id                      ( ld_req_id                      ),
    .rd_req                         ( ld_addr_req                    ),
    .rd_done                        ( ld_done                        ),
    .rd_ready                       ( ld_ready                       ),
    .rd_req_size                    ( ld_req_size                    ),
    .rd_addr                        ( ld_addr                        ),
    // AXI WR Req
    .wr_req_id                      ( st_addr_req_id                 ),
    .wr_req                         ( st_addr_req                    ),
    .wr_ready                       ( st_ready                       ),
    .wr_req_size                    ( st_req_size                    ),
    .wr_addr                        ( st_addr                        ),
    .wr_done                        ( st_done                        )
  );
//==============================================================================

//==============================================================================
// VCD
//==============================================================================
`ifdef COCOTB_TOPLEVEL_pu_ld_obuf_wrapper
initial begin
  $dumpfile("pu_ld_obuf_wrapper.vcd");
  $dumpvars(0, pu_ld_obuf_wrapper);
end
`endif
//==============================================================================
endmodule
