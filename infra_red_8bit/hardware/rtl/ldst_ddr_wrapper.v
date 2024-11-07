//last edit yt
//11-25
//content: reg set 0
`timescale 1ns/1ps
module ldst_ddr_wrapper #(
  // Internal Parameters
    parameter integer  MEM_ID                       = 0,
    parameter integer  STORE_ENABLED                = MEM_ID == 1 ? 1 : 0,
    parameter integer  MEM_REQ_W                    = 16,
    parameter integer  LOOP_ITER_W                  = 16,
    parameter integer  ADDR_STRIDE_W                = 16,
    parameter integer  IMM_WIDTH                    = 16, //edit yt1028
    parameter integer  LOOP_ID_W                    = 5,
    parameter integer  BUF_TYPE_W                   = 2,
    parameter integer  NUM_TAGS                     = 4,
    parameter integer  TAG_W                        = $clog2(NUM_TAGS),
    parameter integer  SIMD_DATA_WIDTH              = 256,
    parameter integer  SIMD_8B_DATA_WIDTH           = SIMD_DATA_WIDTH/2,
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
    
    input  wire                                         choose_8bit,
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

    input  wire                                         cfg_block_padding_v,//edit yt1028
    input  wire  [ IMM_WIDTH            -1 : 0 ]        diff_rows,//edit yt1028
    input  wire                                         st_addr_valid_pd,

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
    output wire  [ AXI_DATA_WIDTH*2       -1 : 0 ]        ddr_ld0_stream_write_data,

  // LD1
    output wire                                         ddr_ld1_stream_write_req,
    input  wire                                         ddr_ld1_stream_write_ready,
    output wire  [ AXI_DATA_WIDTH*2       -1 : 0 ]        ddr_ld1_stream_write_data,
  //ST fifo
    output wire                                         st_fifo_extra_read_req,

  // Stores
    output wire                                         ddr_st_stream_read_req,
    input  wire                                         ddr_st_stream_read_ready,
    input  wire  [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_st_stream_read_data,
    input  wire                                         ddr_ld0_stream_read_req,//edit yt
    input  wire                                         ddr_ld1_stream_read_req //edit yt

);
  wire st_read_req_inside;
  wire                                         ddr_ld0_stream_write_req_inside;
  wire  [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_ld0_stream_write_data_inside;
  wire                                         ddr_ld1_stream_write_req_inside;
  wire  [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_ld1_stream_write_data_inside;
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
   //upsample
   reg                                         upsample_required;   
   reg [3-1 : 0]                           upsample_state;
   wire [3-1 : 0]                           upsample_state_q;   
   wire [3-1 : 0]                           _upsample_state;      
   reg  [STRIDE_TYPE_WIDTH + STRIDE_TYPE_WIDTH -1 :0]          _upsample_num;
   reg [STRIDE_TYPE_WIDTH + STRIDE_TYPE_WIDTH -1 :0]      upsample_compute;
   wire                                         _ddr_st_stream_read_req;
   wire                                         _ddr_st_stream_read_ready;
   reg  [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_st_stream_read_data_reg;

   reg  [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_st_stream_read_data_reg1=0;
   reg  [ AXI_DATA_WIDTH       -1 : 0 ]        ddr_st_stream_read_data_reg2=0;
   wire  [ AXI_DATA_WIDTH       -1 : 0 ]       _ddr_st_stream_read_data;
   wire  [ AXI_DATA_WIDTH       -1 : 0 ]       _ddr_st_stream_read_data_norm;
   wire  [ AXI_DATA_WIDTH       -1 : 0 ]       _ddr_st_stream_read_data_blck;
   wire  [ AXI_DATA_WIDTH       -1 : 0 ]       _ddr_st_stream_read_data_upsample;
   wire  [ AXI_DATA_WIDTH       -1 : 0 ]       _ddr_st_stream_read_data_not_upsample;
   wire                                         st1_start;
   //block signal
   wire                                         block_padding_mask;
   wire                                         block_data;

  wire                         block_all_done;
  reg                          ddr_st_read_req_without_extra_dly=0;
  wire st_addr_req_inside;
  wire data_req_inside;
  wire block_data_stage2;
  wire st_done_inside;
  wire block_required;

  reg st_read_data_write_ptr;
  reg [STRIDE_TYPE_WIDTH + STRIDE_TYPE_WIDTH -1 :0]      upsample_tmp_cnt;
  wire data_need_blocking;
  reg upsample_block_area;
  reg [5-1:0] extra_read_cnt;
//==============================================================================                          //edit by sy 0618 end
//====edit yt
  always @(posedge clk ) begin
    if(reset)
      extra_read_cnt <= 0;
    else if(upsample_tmp_cnt == 'd4 && extra_read_cnt=='hf)
      extra_read_cnt <= 0;
    else if(st_fifo_extra_read_req && upsample_required)
      extra_read_cnt <= extra_read_cnt + 1'b1;
  end

  always @(posedge clk ) begin
    if(reset)
      st_read_data_write_ptr <= 0;
    else if(st0_loop_iter_v || upsample_tmp_cnt == 'd4 && extra_read_cnt == 'hf)
      st_read_data_write_ptr <= 0;
    else if(ddr_st_read_req_without_extra_dly)
      st_read_data_write_ptr <= ~st_read_data_write_ptr;
  end
  always @(posedge clk)begin
    if(reset)
      ddr_st_read_req_without_extra_dly <= 'b0;
    else
      ddr_st_read_req_without_extra_dly <= ddr_st_stream_read_req;
  end

  // always @(posedge clk)begin
  //   if(ddr_st_read_req_without_extra_dly)begin
  //     ddr_st_stream_read_data_reg1 <= ddr_st_stream_read_data;
  //     ddr_st_stream_read_data_reg2 <= ddr_st_stream_read_data_reg1;
  //   end
  // end

  always @(posedge clk)begin
    if(reset)
      ddr_st_stream_read_data_reg1 <= 'b0;
    else if(ddr_st_read_req_without_extra_dly && (st_read_data_write_ptr==0) )
      ddr_st_stream_read_data_reg1 <= ddr_st_stream_read_data;
  end

  always @(posedge clk)begin
    if(reset)
      ddr_st_stream_read_data_reg2 <= 'b0;
    else if(ddr_st_read_req_without_extra_dly && (st_read_data_write_ptr==1) )
      ddr_st_stream_read_data_reg2 <= ddr_st_stream_read_data;
  end
//==============================================================================
// LD/ST required
//==============================================================================
  // always @(posedge clk)
  // begin
  //   if (reset)
  //     ld0_required <= 1'b0;
  //   else begin
  //     if (pu_block_start)
  //       ld0_required <= 1'b0;
  //     else if (cfg_mem_req_v && cfg_mem_req_type == 2)
  //       ld0_required <= 1'b1;
  //   end
  // end

  // always @(posedge clk)
  // begin
  //   if (reset)
  //     ld1_required <= 1'b0;
  //   else begin
  //     if (pu_block_start)
  //       ld1_required <= 1'b0;
  //     else if (cfg_mem_req_v && cfg_mem_req_type == 3)
  //       ld1_required <= 1'b1;
  //   end
  // end

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
        if(_ddr_st_stream_read_req)begin
          upsample_state <= 3'd4;
        end
        else if(st_done)
          upsample_state <= 1'b0;
      end           
      4: begin
        if(_ddr_st_stream_read_req) begin
          upsample_state <= 3'd5;
        end
      end              
      5: begin
        if(_ddr_st_stream_read_req)begin
          upsample_state <= 3'd6;
        end
      end                            
      6: begin
        if(_ddr_st_stream_read_req)begin//_ddr_st_stream_read_req) begin       
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
always @(posedge clk ) begin
    if(reset)
      upsample_tmp_cnt <= 0;
    else if(upsample_state == 0)
      upsample_tmp_cnt <= 'd8;
    else if(upsample_tmp_cnt == 'd4 && extra_read_cnt == 'hf)
      upsample_tmp_cnt <= 'd8;
    else if(_ddr_st_stream_read_req)begin
      if(upsample_tmp_cnt == 0)
        upsample_tmp_cnt <= 'd7;
      else
        upsample_tmp_cnt <= upsample_tmp_cnt - 1'b1;
    end
  end

  always @(posedge clk ) begin
    if(reset)
      upsample_block_area <= 0;
    else if(data_need_blocking && upsample_required)
      upsample_block_area <= 1;
    else if(upsample_block_area && upsample_tmp_cnt ==4 && data_need_blocking==0)
      upsample_block_area <= 0;
  end
  wire blck_data_cond;
  wire ddr_st_stream_read_req_upsample;
  wire ddr_st_stream_read_req_not_upsample;

  assign blck_data_cond = ~upsample_block_area && (upsample_tmp_cnt == 'd7 || upsample_tmp_cnt == 3'd0 || upsample_tmp_cnt == 'd8) || upsample_block_area && (upsample_tmp_cnt == 'd3 || upsample_tmp_cnt == 3'd7);
  assign _ddr_st_stream_read_data_norm = (upsample_tmp_cnt == 'd7 || upsample_tmp_cnt=='d6) ? ddr_st_stream_read_data : upsample_tmp_cnt[0] ? ddr_st_stream_read_data_reg1 : ddr_st_stream_read_data_reg2 ;
  assign _ddr_st_stream_read_data_blck = blck_data_cond  ? ddr_st_stream_read_data : upsample_tmp_cnt >= 3'd4 ? ddr_st_stream_read_data_reg1 : ddr_st_stream_read_data_reg2 ;
  assign _ddr_st_stream_read_data_upsample = upsample_block_area ? _ddr_st_stream_read_data_blck : _ddr_st_stream_read_data_norm;
  assign _ddr_st_stream_read_data = upsample_required ? _ddr_st_stream_read_data_upsample : _ddr_st_stream_read_data_not_upsample;
  assign ddr_st_stream_read_req_upsample = _ddr_st_stream_read_req && (upsample_tmp_cnt == 'd0 || upsample_tmp_cnt== 'd7&&(~upsample_block_area) || upsample_block_area && upsample_tmp_cnt=='d4  || upsample_tmp_cnt == 'd8);
  assign _ddr_st_stream_read_ready = ddr_st_stream_read_ready || (upsample_state == 3'd5) || (upsample_state == 3'd6);


  assign _ddr_st_stream_read_data_not_upsample = upsample_state_q == 3'd5 ? ddr_st_stream_read_data_reg2 : upsample_state_q == 3'd6 ? ddr_st_stream_read_data_reg1 : ddr_st_stream_read_data;
  assign ddr_st_stream_read_req_not_upsample = _ddr_st_stream_read_req && (upsample_state == 3'd3 || upsample_state == 3'd4 || upsample_state == 3'd2);
  assign ddr_st_stream_read_req = upsample_required ? ddr_st_stream_read_req_upsample : ddr_st_stream_read_req_not_upsample;
//==============================================================================
// Assigns
//==============================================================================
    assign st1_data_required = st1_required;

    assign st1_stride_v  = cfg_loop_stride_v && (cfg_loop_stride_type == 4);                                                                                //edit by sy 0618
    assign st0_stride_v  = cfg_loop_stride_v && (cfg_loop_stride_type == 1);
    // assign ld0_stride_v = cfg_loop_stride_v && (cfg_loop_stride_type == 2);
    // assign ld1_stride_v = cfg_loop_stride_v && (cfg_loop_stride_type == 3);

    assign st0_stall  = ~st0_ready;
    assign st1_stall  = ~st1_ready;                                                                                                                                                     //edit by sy 0618
    
    // assign ld0_stall = ld0_required && ~ld0_ready;
    // assign ld1_stall = ld1_required && ~ld1_ready;
    assign st0_addr_req = st0_addr_valid && ~st0_stall;
    assign st1_addr_req = st1_addr_valid && ~st1_stall;                                                                                                                 //edit by sy 0618
//==============================================================================

//==============================================================================
// FSM for Loads
//==============================================================================
    reg                                         ld_addr_state_d;
    reg                                         ld_addr_state_q;
//==============================================================================

//==============================================================================
// FSM for Stores
//==============================================================================                                                edit by sy 0618 begin
    reg       [5-1:0]                                  st_addr_state_d;
    reg       [5-1:0]                                  st_addr_state_q;
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
                st_addr_state_d = 6'd1;
            else 
                st_addr_state_d = 6'd10;  
        end
      end      
      1: begin
        if (st1_required && st1_addr_valid && st_ready)
          st_addr_state_d = 6'd2;
        else if(st0_loop_done)
          st_addr_state_d = 6'd0;              
      end
      2: begin
        if (st1_required && st1_addr_valid && st_ready)
          st_addr_state_d = 6'd3;
      end      
       3: begin
        if (st1_addr_valid && st_ready)
          st_addr_state_d = 6'd4;
      end         
       4: begin
        if (st1_addr_valid && st_ready)
          if(choose_8bit)
            st_addr_state_d = 6'd5;
          else
            st_addr_state_d = 6'd10;
      end               
       5: begin
        if (st1_addr_valid && st_ready)
          st_addr_state_d = 6'd6;
      end         
       6: begin
        if (st1_addr_valid && st_ready)
          st_addr_state_d = 6'd7;
      end        
       7: begin
        if (st1_addr_valid && st_ready)
          st_addr_state_d = 6'd8;
      end         
       8: begin
        if (st1_addr_valid && st_ready)
          st_addr_state_d = 6'd9;
      end        
       9: begin
        if (st1_required && st0_addr_valid && st_ready)
          st_addr_state_d = 6'd10;
      end      
      10: begin
        if (st1_required && st0_addr_valid && st_ready)
          st_addr_state_d = 3'd1;
        else if(st0_loop_done)
          st_addr_state_d = 3'd0;  
      end
    endcase
  end

    assign st0_ready = st_ready && (st_addr_state_q == 6'd9 || st_addr_state_q == 6'd10);
    assign st1_ready = st_ready && st_addr_state_q != 2'd0 && st_addr_state_q != 6'd9 && st_addr_state_q != 6'd10;

//    assign st_req_size = SIMD_DATA_WIDTH / AXI_DATA_WIDTH;
    assign st_req_size = choose_8bit ? SIMD_8B_DATA_WIDTH / AXI_DATA_WIDTH :SIMD_DATA_WIDTH / AXI_DATA_WIDTH;
    assign st_addr = ( st_addr_state_q == 6'd9 || st_addr_state_q == 6'd10 || st_addr_state_q == 3'd0 ) ? st0_addr : st1_addr;
    assign st_addr_req = ( ( st_addr_state_q == 6'd9 || st_addr_state_q == 6'd10 )? st0_addr_req : st1_addr_req && st1_required) && st_ready;

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
    assign st0_stride = choose_8bit ? cfg_loop_stride * SIMD_8B_DATA_WIDTH / 8 : cfg_loop_stride * SIMD_DATA_WIDTH / 8;
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
    assign st1_stride = choose_8bit ? cfg_loop_stride * SIMD_8B_DATA_WIDTH / 8 : cfg_loop_stride * SIMD_DATA_WIDTH / 8;
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
//   wire pu_ddr_wvalid_inside;
//   wire pu_ddr_awvalid_inside;
//   wire pu_ddr_wready_inside;
//   wire pu_ddr_awready_inside;
  
//   wire data_valid_and;
//   wire addr_valid_and;
// //edit yt1028
//   block_padding#(
//     .IMM_WIDTH                      ( IMM_WIDTH                       ),
//     .LOOP_ITER_W                    ( LOOP_ITER_W                     )
//   ) blockpding (
//     .clk                            ( clk                             ),
//     .cfg_block_padding_v            ( cfg_block_padding_v             ),
//     .diff_rows                      ( diff_rows                       ),
//     .cfg_loop_iter_st_v             ( st0_loop_iter_v                 ),
//     .cfg_loop_iter_st               ( st0_loop_iter                   ),
//     .cfg_loop_iter_st1_v            ( st1_loop_iter_v                 ),
//     .st_addr_valid_pd               ( st_addr_valid_pd                ),
//     .data_valid                     ( data_valid_and                  ),   //pu_ddr_wvalid_inside            ),
//     .addr_valid                     ( addr_valid_and                  ),
//     .upsample_required              ( upsample_required               ),
//     .block_data                     ( block_data                      ),
//     .block_mask                     ( block_padding_mask              )//TODO: remain test 
//   );

//   assign data_valid_and = pu_ddr_wvalid_inside && pu_ddr_wready_inside;
//   assign addr_valid_and = pu_ddr_awvalid_inside && pu_ddr_awready_inside;

//   assign pu_ddr_wvalid = pu_ddr_wvalid_inside && (~block_data);
//   assign pu_ddr_awvalid = pu_ddr_awvalid_inside && (~block_padding_mask);
//   assign pu_ddr_wready_inside = pu_ddr_wready || (block_data && pu_ddr_wvalid_inside);//TODO: test
//   assign pu_ddr_awready_inside = pu_ddr_awready || (block_padding_mask && pu_ddr_awvalid_inside);

//==================================================================================
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


register_sync_with_enable #(1) block_data_dly(clk, reset, 1'b1, block_data, block_data_stage2);
//edit yt1028
  block_padding#(
    .IMM_WIDTH                      ( IMM_WIDTH                       ),
    .LOOP_ITER_W                    ( LOOP_ITER_W                     )
  ) blockpding (
    .clk                            ( clk                             ),
    .reset                          ( reset                           ),
    .cfg_block_padding_v            ( cfg_block_padding_v             ),
    .diff_rows                      ( diff_rows                       ),
    .cfg_loop_iter_st_v             ( st0_loop_iter_v                 ),
    .cfg_loop_iter_st               ( st0_loop_iter                   ),
    .cfg_loop_iter_st1_v            ( st1_loop_iter_v                 ),
    .st_addr_valid_pd               ( st_addr_valid_pd                ),
    .data_valid                     ( data_req_inside                 ),//ddr_st_stream_read_req          ),   //pu_ddr_wvalid_inside            ),
    .addr_valid                     ( st_addr_req                     ),
    .upsample_required              ( upsample_required               ),
    .block_data                     ( block_data                      ),
    .block_required                 ( block_required),
    .data_need_blocking             ( data_need_blocking              ),
    .all_done                       ( block_all_done                  ),
    .block_mask                     ( block_padding_mask              )
  );

  assign data_req_inside = ddr_st_stream_read_req || st_fifo_extra_read_req;
  assign st_addr_req_inside = st_addr_req && (~block_padding_mask);
  assign st_fifo_extra_read_req = block_data==1'b1 && block_data_stage2 == 1'b0;
  //assign st_read_req_inside = _ddr_st_stream_read_req || st_fifo_extra_read_req;
  assign st_done = st_done_inside && ((~block_required) || ( block_all_done && block_required));

//==============================================================================
// Loop controller - LD0  //edit yt
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
    .m_axi_awready                  ( pu_ddr_awready                 ),//pu_ddr_awready                 ),
    .m_axi_wdata                    ( pu_ddr_wdata                   ),
    .m_axi_wstrb                    ( pu_ddr_wstrb                   ),
    .m_axi_wlast                    ( pu_ddr_wlast                   ),
    .m_axi_wvalid                   ( pu_ddr_wvalid                  ),
    .m_axi_wready                   ( pu_ddr_wready                  ),//pu_ddr_wready ),
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
    .mem_read_req                   ( _ddr_st_stream_read_req        ),                                                                                //edit by sy 0705
    .mem_read_data                  ( _ddr_st_stream_read_data       ),
    .mem_read_ready                 ( _ddr_st_stream_read_ready      ),
    // AXI RD Req
    .rd_req_id                      ( ld_req_id                      ),
    .rd_req                         ( ld_addr_req                    ),
    .rd_done                        ( ld_done                        ),
    .rd_ready                       ( ld_ready                       ),
    .rd_req_size                    ( ld_req_size                    ),
    .rd_addr                        ( ld_addr                        ),
    // AXI WR Req
    .wr_req_id                      ( st_addr_req_id                 ),
    .wr_req                         ( st_addr_req_inside                    ),
    .wr_ready                       ( st_ready                       ),
    .wr_req_size                    ( st_req_size                    ),
    .wr_addr                        ( st_addr                        ),
    .wr_done                        ( st_done_inside                        )
  );
//==============================================================================
reg [15:0]st_addr_count;
reg [15:0]aw_count;
reg [15:0]w_count;


  always@(posedge clk)
  begin
    if (reset)
      st_addr_count <= 'b0;
    else begin
      if (start)
        st_addr_count <= 'b0;
      else if (st_addr_req)
        st_addr_count <= st_addr_count + 1'b1;
    end
  end
  
  //   always@(posedge clk)
  // begin
  //   if (reset)
  //     aw_count <= 'b0;
  //   else begin
  //     if (start)
  //       aw_count <= 'b0;
  //     else if (pu_ddr_awvalid_inside)
  //       aw_count <= aw_count + 1'b1;
  //   end
  // end
  
  //   always@(posedge clk)
  // begin
  //   if (reset)
  //     w_count <= 'b0;
  //   else begin
  //     if (start)
  //       w_count <= 'b0;
  //     else if (pu_ddr_wvalid_inside)
  //       w_count <= w_count + 1'b1;
  //   end
  // end
  
  
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
