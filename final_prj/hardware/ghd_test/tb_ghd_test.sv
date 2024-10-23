`timescale 1ns/1ps

module tb #(

    parameter INST_W                       = 32,
    parameter INST_ADDR_W                  = 5,
    parameter IFIFO_ADDR_W                 = 10,
    parameter BUF_TYPE_W                   = 2,
    parameter OP_CODE_W                    = 5,
    parameter OP_SPEC_W                    = 6,
    parameter LOOP_ID_W                    = 5,

    parameter ARRAY_N                      = 32,
    parameter ARRAY_M                      = 32,

    parameter DATA_WIDTH                   = 16,
    parameter BIAS_WIDTH                   = 32,
    parameter ACC_WIDTH                    = 64,

    parameter NUM_TAGS                     = 2,
    parameter IBUF_CAPACITY_BITS           = ARRAY_N * DATA_WIDTH * 4096 / NUM_TAGS,
    parameter WBUF_CAPACITY_BITS           = ARRAY_N * ARRAY_M * DATA_WIDTH * 512 / NUM_TAGS,
    parameter OBUF_CAPACITY_BITS           = ARRAY_M * ACC_WIDTH * 4096 / NUM_TAGS,
    parameter BBUF_CAPACITY_BITS           = ARRAY_M * BIAS_WIDTH * 4096 / NUM_TAGS,

    parameter IBUF_ADDR_WIDTH              = $clog2(IBUF_CAPACITY_BITS / ARRAY_N / DATA_WIDTH),
    parameter WBUF_ADDR_WIDTH              = $clog2(WBUF_CAPACITY_BITS / ARRAY_N / ARRAY_M / DATA_WIDTH),
    parameter OBUF_ADDR_WIDTH              = $clog2(OBUF_CAPACITY_BITS / ARRAY_M / ACC_WIDTH),
    parameter BBUF_ADDR_WIDTH              = $clog2(BBUF_CAPACITY_BITS / ARRAY_M / BIAS_WIDTH),

    parameter AXI_ADDR_WIDTH               = 42,
    parameter AXI_BURST_WIDTH              = 8,
    parameter IBUF_AXI_DATA_WIDTH          = 256,
    parameter IBUF_WSTRB_W                 = IBUF_AXI_DATA_WIDTH/8,
    parameter OBUF_AXI_DATA_WIDTH          = 256,
    parameter OBUF_WSTRB_W                 = OBUF_AXI_DATA_WIDTH/8,
    parameter PU_AXI_DATA_WIDTH            = 256,
    parameter PU_WSTRB_W                   = PU_AXI_DATA_WIDTH/8,
    parameter WBUF_AXI_DATA_WIDTH          = 256,
    parameter WBUF_WSTRB_W                 = WBUF_AXI_DATA_WIDTH/8,
    parameter BBUF_AXI_DATA_WIDTH          = 256,
    parameter BBUF_WSTRB_W                 = BBUF_AXI_DATA_WIDTH/8,
    parameter AXI_ID_WIDTH                 = 1,
    parameter INST_ADDR_WIDTH              = 32,
    parameter INST_DATA_WIDTH              = 32,
    parameter INST_WSTRB_WIDTH             = INST_DATA_WIDTH/8,
    parameter INST_BURST_WIDTH             = 8,
    parameter CTRL_ADDR_WIDTH              = 32,
    parameter CTRL_DATA_WIDTH              = 32,
    parameter CTRL_WSTRB_WIDTH             = CTRL_DATA_WIDTH/8
);
reg clk;
reg reset;

wire                                         PCI_CL_CTRL_AWVALID	;
wire  [ CTRL_ADDR_WIDTH      -1 : 0 ]        PCI_CL_CTRL_AWADDR		;
wire                                         PCI_CL_CTRL_AWREADY	;
wire                                         PCI_CL_CTRL_WVALID		;
wire  [ CTRL_DATA_WIDTH      -1 : 0 ]        PCI_CL_CTRL_WDATA		;
wire  [ CTRL_WSTRB_WIDTH     -1 : 0 ]        PCI_CL_CTRL_WSTRB		;
wire                                         PCI_CL_CTRL_WREADY		;
wire                                         PCI_CL_CTRL_BVALID		;
wire  [ 2                    -1 : 0 ]        PCI_CL_CTRL_BRESP		;
wire                                         PCI_CL_CTRL_BREADY		;
wire                                         PCI_CL_CTRL_ARVALID	;
wire  [ CTRL_ADDR_WIDTH      -1 : 0 ]        PCI_CL_CTRL_ARADDR		;
wire                                         PCI_CL_CTRL_ARREADY	;
wire                                         PCI_CL_CTRL_RVALID		;
wire  [ CTRL_DATA_WIDTH      -1 : 0 ]        PCI_CL_CTRL_RDATA		;
wire  [ 2                    -1 : 0 ]        PCI_CL_CTRL_RRESP		;
wire                                         PCI_CL_CTRL_RREADY		;

wire  [ INST_ADDR_WIDTH      -1 : 0 ]        PCI_CL_DATA_AWADDR		;
wire  [ INST_BURST_WIDTH     -1 : 0 ]        PCI_CL_DATA_AWLEN		;
wire  [ 3                    -1 : 0 ]        PCI_CL_DATA_AWSIZE		;
wire  [ 2                    -1 : 0 ]        PCI_CL_DATA_AWBURST	;
wire                                         PCI_CL_DATA_AWVALID	;
wire                                         PCI_CL_DATA_AWREADY	;
wire  [ INST_DATA_WIDTH      -1 : 0 ]        PCI_CL_DATA_WDATA		;
wire  [ INST_WSTRB_WIDTH     -1 : 0 ]        PCI_CL_DATA_WSTRB		;
wire                                         PCI_CL_DATA_WLAST		;
wire                                         PCI_CL_DATA_WVALID		;
wire                                         PCI_CL_DATA_WREADY		;
wire  [ 2                    -1 : 0 ]        PCI_CL_DATA_BRESP		;
wire                                         PCI_CL_DATA_BVALID		;
wire                                         PCI_CL_DATA_BREADY		;
wire  [ INST_ADDR_WIDTH      -1 : 0 ]        PCI_CL_DATA_ARADDR		;
wire  [ INST_BURST_WIDTH     -1 : 0 ]        PCI_CL_DATA_ARLEN		;
wire  [ 3                    -1 : 0 ]        PCI_CL_DATA_ARSIZE		;
wire  [ 2                    -1 : 0 ]        PCI_CL_DATA_ARBURST	;
wire                                         PCI_CL_DATA_ARVALID	;
wire                                         PCI_CL_DATA_ARREADY	;
wire  [ INST_DATA_WIDTH      -1 : 0 ]        PCI_CL_DATA_RDATA		;
wire  [ 2                    -1 : 0 ]        PCI_CL_DATA_RRESP		;
wire                                         PCI_CL_DATA_RLAST		;
wire                                         PCI_CL_DATA_RVALID		;
wire                                         PCI_CL_DATA_RREADY		;

wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        CL_DDR0_AWADDR		;
wire  [ AXI_BURST_WIDTH      -1 : 0 ]        CL_DDR0_AWLEN		;
wire  [ 3                    -1 : 0 ]        CL_DDR0_AWSIZE		;
wire  [ 2                    -1 : 0 ]        CL_DDR0_AWBURST		;
wire                                         CL_DDR0_AWVALID		;
wire                                         CL_DDR0_AWREADY		;
wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        CL_DDR0_WDATA		;
wire  [ IBUF_WSTRB_W         -1 : 0 ]        CL_DDR0_WSTRB		;
wire                                         CL_DDR0_WLAST		;
wire                                         CL_DDR0_WVALID		;
wire                                         CL_DDR0_WREADY		;
wire  [ 2                    -1 : 0 ]        CL_DDR0_BRESP		;
wire                                         CL_DDR0_BVALID		;
wire                                         CL_DDR0_BREADY		;
wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        CL_DDR0_ARADDR		;
wire  [ AXI_BURST_WIDTH      -1 : 0 ]        CL_DDR0_ARLEN		;
wire  [ 3                    -1 : 0 ]        CL_DDR0_ARSIZE		;
wire  [ 2                    -1 : 0 ]        CL_DDR0_ARBURST		;
wire                                         CL_DDR0_ARVALID		;
wire  [ AXI_ID_WIDTH         -1 : 0 ]        CL_DDR0_ARID		;
wire                                         CL_DDR0_ARREADY		;
wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        CL_DDR0_RDATA		;
wire  [ AXI_ID_WIDTH         -1 : 0 ]        CL_DDR0_RID		;
wire  [ 2                    -1 : 0 ]        CL_DDR0_RRESP		;
wire                                         CL_DDR0_RLAST		;
wire                                         CL_DDR0_RVALID		;
wire                                         CL_DDR0_RREADY		;
wire                                         CL_DDR0_ARPROT		;
wire                                         CL_DDR0_AWPROT		;

wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        CL_DDR1_AWADDR		;
wire  [ AXI_BURST_WIDTH      -1 : 0 ]        CL_DDR1_AWLEN		;
wire  [ 3                    -1 : 0 ]        CL_DDR1_AWSIZE		;
wire  [ 2                    -1 : 0 ]        CL_DDR1_AWBURST		;
wire                                         CL_DDR1_AWVALID		;
wire                                         CL_DDR1_AWREADY		;
wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        CL_DDR1_WDATA		;
wire  [ IBUF_WSTRB_W         -1 : 0 ]        CL_DDR1_WSTRB		;
wire                                         CL_DDR1_WLAST		;
wire                                         CL_DDR1_WVALID		;
wire                                         CL_DDR1_WREADY		;
wire  [ 2                    -1 : 0 ]        CL_DDR1_BRESP		;
wire                                         CL_DDR1_BVALID		;
wire                                         CL_DDR1_BREADY		;
wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        CL_DDR1_ARADDR		;
wire  [ AXI_BURST_WIDTH      -1 : 0 ]        CL_DDR1_ARLEN		;
wire  [ 3                    -1 : 0 ]        CL_DDR1_ARSIZE		;
wire  [ 2                    -1 : 0 ]        CL_DDR1_ARBURST		;
wire                                         CL_DDR1_ARVALID		;
wire  [ AXI_ID_WIDTH         -1 : 0 ]        CL_DDR1_ARID		;
wire                                         CL_DDR1_ARREADY		;
wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        CL_DDR1_RDATA		;
wire  [ AXI_ID_WIDTH         -1 : 0 ]        CL_DDR1_RID		;
wire  [ 2                    -1 : 0 ]        CL_DDR1_RRESP		;
wire                                         CL_DDR1_RLAST		;
wire                                         CL_DDR1_RVALID		;
wire                                         CL_DDR1_RREADY		;
wire                                         CL_DDR1_ARPROT		;
wire                                         CL_DDR1_AWPROT		;

wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        CL_DDR2_AWADDR		;
wire  [ AXI_BURST_WIDTH      -1 : 0 ]        CL_DDR2_AWLEN		;
wire  [ 3                    -1 : 0 ]        CL_DDR2_AWSIZE		;
wire  [ 2                    -1 : 0 ]        CL_DDR2_AWBURST		;
wire                                         CL_DDR2_AWVALID		;
wire                                         CL_DDR2_AWREADY		;
wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        CL_DDR2_WDATA		;
wire  [ IBUF_WSTRB_W         -1 : 0 ]        CL_DDR2_WSTRB		;
wire                                         CL_DDR2_WLAST		;
wire                                         CL_DDR2_WVALID		;
wire                                         CL_DDR2_WREADY		;
wire  [ 2                    -1 : 0 ]        CL_DDR2_BRESP		;
wire                                         CL_DDR2_BVALID		;
wire                                         CL_DDR2_BREADY		;
wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        CL_DDR2_ARADDR		;
wire  [ AXI_BURST_WIDTH      -1 : 0 ]        CL_DDR2_ARLEN		;
wire  [ 3                    -1 : 0 ]        CL_DDR2_ARSIZE		;
wire  [ 2                    -1 : 0 ]        CL_DDR2_ARBURST		;
wire                                         CL_DDR2_ARVALID		;
wire  [ AXI_ID_WIDTH         -1 : 0 ]        CL_DDR2_ARID		;
wire                                         CL_DDR2_ARREADY		;
wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        CL_DDR2_RDATA		;
wire  [ AXI_ID_WIDTH         -1 : 0 ]        CL_DDR2_RID		;
wire  [ 2                    -1 : 0 ]        CL_DDR2_RRESP		;
wire                                         CL_DDR2_RLAST		;
wire                                         CL_DDR2_RVALID		;
wire                                         CL_DDR2_RREADY		;
wire                                         CL_DDR2_ARPROT		;
wire                                         CL_DDR2_AWPROT		;

wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        CL_DDR3_AWADDR		;
wire  [ AXI_BURST_WIDTH      -1 : 0 ]        CL_DDR3_AWLEN		;
wire  [ 3                    -1 : 0 ]        CL_DDR3_AWSIZE		;
wire  [ 2                    -1 : 0 ]        CL_DDR3_AWBURST		;
wire                                         CL_DDR3_AWVALID		;
wire                                         CL_DDR3_AWREADY		;
wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        CL_DDR3_WDATA		;
wire  [ IBUF_WSTRB_W         -1 : 0 ]        CL_DDR3_WSTRB		;
wire                                         CL_DDR3_WLAST		;
wire                                         CL_DDR3_WVALID		;
wire                                         CL_DDR3_WREADY		;
wire  [ 2                    -1 : 0 ]        CL_DDR3_BRESP		;
wire                                         CL_DDR3_BVALID		;
wire                                         CL_DDR3_BREADY		;
wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        CL_DDR3_ARADDR		;
wire  [ AXI_BURST_WIDTH      -1 : 0 ]        CL_DDR3_ARLEN		;
wire  [ 3                    -1 : 0 ]        CL_DDR3_ARSIZE		;
wire  [ 2                    -1 : 0 ]        CL_DDR3_ARBURST		;
wire                                         CL_DDR3_ARVALID		;
wire  [ AXI_ID_WIDTH         -1 : 0 ]        CL_DDR3_ARID		;
wire                                         CL_DDR3_ARREADY		;
wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        CL_DDR3_RDATA		;
wire  [ AXI_ID_WIDTH         -1 : 0 ]        CL_DDR3_RID		;
wire  [ 2                    -1 : 0 ]        CL_DDR3_RRESP		;
wire                                         CL_DDR3_RLAST		;
wire                                         CL_DDR3_RVALID		;
wire                                         CL_DDR3_RREADY		;
wire                                         CL_DDR3_ARPROT		;
wire                                         CL_DDR3_AWPROT		;

wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        CL_DDR4_AWADDR		;
wire  [ AXI_BURST_WIDTH      -1 : 0 ]        CL_DDR4_AWLEN		;
wire  [ 3                    -1 : 0 ]        CL_DDR4_AWSIZE		;
wire  [ 2                    -1 : 0 ]        CL_DDR4_AWBURST		;
wire                                         CL_DDR4_AWVALID		;
wire                                         CL_DDR4_AWREADY		;
wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        CL_DDR4_WDATA		;
wire  [ IBUF_WSTRB_W         -1 : 0 ]        CL_DDR4_WSTRB		;
wire                                         CL_DDR4_WLAST		;
wire                                         CL_DDR4_WVALID		;
wire                                         CL_DDR4_WREADY		;
wire  [ 2                    -1 : 0 ]        CL_DDR4_BRESP		;
wire                                         CL_DDR4_BVALID		;
wire                                         CL_DDR4_BREADY		;
wire  [ AXI_ADDR_WIDTH       -1 : 0 ]        CL_DDR4_ARADDR		;
wire  [ AXI_BURST_WIDTH      -1 : 0 ]        CL_DDR4_ARLEN		;
wire  [ 3                    -1 : 0 ]        CL_DDR4_ARSIZE		;
wire  [ 2                    -1 : 0 ]        CL_DDR4_ARBURST		;
wire                                         CL_DDR4_ARVALID		;
wire  [ AXI_ID_WIDTH         -1 : 0 ]        CL_DDR4_ARID		;
wire                                         CL_DDR4_ARREADY		;
wire  [ IBUF_AXI_DATA_WIDTH  -1 : 0 ]        CL_DDR4_RDATA		;
wire  [ AXI_ID_WIDTH         -1 : 0 ]        CL_DDR4_RID		;
wire  [ 2                    -1 : 0 ]        CL_DDR4_RRESP		;
wire                                         CL_DDR4_RLAST		;
wire                                         CL_DDR4_RVALID		;
wire                                         CL_DDR4_RREADY		;
wire                                         CL_DDR4_ARPROT		;
wire                                         CL_DDR4_AWPROT		;


initial $monitor("\r\nWBUF_ADDR_WIDTH=%d\r\n",dut_top_u.WBUF_ADDR_WIDTH);
cl_wrapper #(
    .INST_W                       (INST_W                  ),
    .INST_ADDR_W                  (INST_ADDR_W             ),
    .IFIFO_ADDR_W                 (IFIFO_ADDR_W            ),
    .BUF_TYPE_W                   (BUF_TYPE_W              ),
    .OP_CODE_W                    (OP_CODE_W               ),
    .OP_SPEC_W                    (OP_SPEC_W               ),
    .LOOP_ID_W                    (LOOP_ID_W               ),
    .ARRAY_N                      (ARRAY_N                 ),
    .ARRAY_M                      (ARRAY_M                 ),
    .DATA_WIDTH                   (DATA_WIDTH              ),
    .BIAS_WIDTH                   (BIAS_WIDTH              ),
    .ACC_WIDTH                    (ACC_WIDTH               ),
    .NUM_TAGS                     (NUM_TAGS                ),
    .AXI_ADDR_WIDTH               (AXI_ADDR_WIDTH          ),
    .AXI_BURST_WIDTH              (AXI_BURST_WIDTH         ),
    .IBUF_AXI_DATA_WIDTH          (IBUF_AXI_DATA_WIDTH     ),
    .OBUF_AXI_DATA_WIDTH          (OBUF_AXI_DATA_WIDTH     ),
    .PU_AXI_DATA_WIDTH            (PU_AXI_DATA_WIDTH       ),
    .WBUF_AXI_DATA_WIDTH          (WBUF_AXI_DATA_WIDTH     ),
    .BBUF_AXI_DATA_WIDTH          (BBUF_AXI_DATA_WIDTH     ),
    .AXI_ID_WIDTH                 (AXI_ID_WIDTH            ),
    .INST_ADDR_WIDTH              (INST_ADDR_WIDTH         ),
    .INST_DATA_WIDTH              (INST_DATA_WIDTH         ),
    .INST_BURST_WIDTH             (INST_BURST_WIDTH        ),
    .CTRL_ADDR_WIDTH              (CTRL_ADDR_WIDTH         ),
    .CTRL_DATA_WIDTH              (CTRL_DATA_WIDTH         )
) dut_top_u
(
    .clk    (clk),
    .reset  (reset),
    .pci_cl_ctrl_awvalid	(PCI_CL_CTRL_AWVALID    ),
    .pci_cl_ctrl_awaddr		(PCI_CL_CTRL_AWADDR	),
    .pci_cl_ctrl_awready        (PCI_CL_CTRL_AWREADY    ),
    .pci_cl_ctrl_wvalid	        (PCI_CL_CTRL_WVALID	),
    .pci_cl_ctrl_wdata	        (PCI_CL_CTRL_WDATA	),
    .pci_cl_ctrl_wstrb	        (PCI_CL_CTRL_WSTRB	),
    .pci_cl_ctrl_wready	        (PCI_CL_CTRL_WREADY	),
    .pci_cl_ctrl_bvalid	        (PCI_CL_CTRL_BVALID	),
    .pci_cl_ctrl_bresp	        (PCI_CL_CTRL_BRESP	),
    .pci_cl_ctrl_bready	        (PCI_CL_CTRL_BREADY	),
    .pci_cl_ctrl_arvalid        (PCI_CL_CTRL_ARVALID    ),
    .pci_cl_ctrl_araddr	        (PCI_CL_CTRL_ARADDR	),
    .pci_cl_ctrl_arready        (PCI_CL_CTRL_ARREADY    ),
    .pci_cl_ctrl_rvalid	        (PCI_CL_CTRL_RVALID	),
    .pci_cl_ctrl_rdata	        (PCI_CL_CTRL_RDATA	),
    .pci_cl_ctrl_rresp	        (PCI_CL_CTRL_RRESP	),
    .pci_cl_ctrl_rready	        (PCI_CL_CTRL_RREADY	),

    .pci_cl_data_awvalid	(PCI_CL_DATA_AWVALID    ),
    .pci_cl_data_awaddr		(PCI_CL_DATA_AWADDR	),
    .pci_cl_data_awready        (PCI_CL_DATA_AWREADY    ),
    //.pci_cl_data_wlast	        (PCI_CL_DATA_WLAST	),
    .pci_cl_data_wlast	        (1'b1			),
    .pci_cl_data_wvalid	        (PCI_CL_DATA_WVALID	),
    .pci_cl_data_wdata	        (PCI_CL_DATA_WDATA	),
    .pci_cl_data_wstrb	        (PCI_CL_DATA_WSTRB	),
    .pci_cl_data_wready	        (PCI_CL_DATA_WREADY	),
    .pci_cl_data_bvalid	        (PCI_CL_DATA_BVALID	),
    .pci_cl_data_bresp	        (PCI_CL_DATA_BRESP	),
    .pci_cl_data_bready	        (PCI_CL_DATA_BREADY	),
    .pci_cl_data_arvalid        (PCI_CL_DATA_ARVALID    ),
    .pci_cl_data_araddr	        (PCI_CL_DATA_ARADDR	),
    .pci_cl_data_arready        (PCI_CL_DATA_ARREADY    ),
    .pci_cl_data_rvalid	        (PCI_CL_DATA_RVALID	),
    .pci_cl_data_rdata	        (PCI_CL_DATA_RDATA	),
    .pci_cl_data_rresp	        (PCI_CL_DATA_RRESP	),
    .pci_cl_data_rlast	        (PCI_CL_DATA_RLAST	),
    .pci_cl_data_rready	        (PCI_CL_DATA_RREADY	),

    .cl_ddr0_awaddr		(CL_DDR0_AWADDR		),
    .cl_ddr0_awlen		(CL_DDR0_AWLEN		),
    .cl_ddr0_awsize		(CL_DDR0_AWSIZE		),
    .cl_ddr0_awburst		(CL_DDR0_AWBURST	),
    .cl_ddr0_awvalid		(CL_DDR0_AWVALID	),
    .cl_ddr0_awready		(CL_DDR0_AWREADY	),
    .cl_ddr0_wdata		(CL_DDR0_WDATA		),
    .cl_ddr0_wstrb		(CL_DDR0_WSTRB		),
    .cl_ddr0_wlast		(CL_DDR0_WLAST		),
    .cl_ddr0_wvalid		(CL_DDR0_WVALID		),
    .cl_ddr0_wready		(CL_DDR0_WREADY		),
    .cl_ddr0_bresp		(CL_DDR0_BRESP		),
    .cl_ddr0_bvalid		(CL_DDR0_BVALID		),
    .cl_ddr0_bready		(CL_DDR0_BREADY		),
    .cl_ddr0_araddr		(CL_DDR0_ARADDR		),
    .cl_ddr0_arlen		(CL_DDR0_ARLEN		),
    .cl_ddr0_arsize		(CL_DDR0_ARSIZE		),
    .cl_ddr0_arburst		(CL_DDR0_ARBURST	),
    .cl_ddr0_arvalid		(CL_DDR0_ARVALID	),
    .cl_ddr0_arid		(CL_DDR0_ARID		),
    .cl_ddr0_arready		(CL_DDR0_ARREADY	),
    .cl_ddr0_rdata		(CL_DDR0_RDATA		),
    .cl_ddr0_rid		(CL_DDR0_RID		),
    .cl_ddr0_rresp		(CL_DDR0_RRESP		),
    .cl_ddr0_rlast		(CL_DDR0_RLAST		),
    .cl_ddr0_rvalid		(CL_DDR0_RVALID		),
    .cl_ddr0_rready		(CL_DDR0_RREADY		),

    .cl_ddr1_awaddr		(CL_DDR1_AWADDR		),
    .cl_ddr1_awlen		(CL_DDR1_AWLEN		),
    .cl_ddr1_awsize		(CL_DDR1_AWSIZE		),
    .cl_ddr1_awburst		(CL_DDR1_AWBURST	),
    .cl_ddr1_awvalid		(CL_DDR1_AWVALID	),
    .cl_ddr1_awready		(CL_DDR1_AWREADY	),
    .cl_ddr1_wdata		(CL_DDR1_WDATA		),
    .cl_ddr1_wstrb		(CL_DDR1_WSTRB		),
    .cl_ddr1_wlast		(CL_DDR1_WLAST		),
    .cl_ddr1_wvalid		(CL_DDR1_WVALID		),
    .cl_ddr1_wready		(CL_DDR1_WREADY		),
    .cl_ddr1_bresp		(CL_DDR1_BRESP		),
    .cl_ddr1_bvalid		(CL_DDR1_BVALID		),
    .cl_ddr1_bready		(CL_DDR1_BREADY		),
    .cl_ddr1_araddr		(CL_DDR1_ARADDR		),
    .cl_ddr1_arlen		(CL_DDR1_ARLEN		),
    .cl_ddr1_arsize		(CL_DDR1_ARSIZE		),
    .cl_ddr1_arburst		(CL_DDR1_ARBURST	),
    .cl_ddr1_arvalid		(CL_DDR1_ARVALID	),
    .cl_ddr1_arid		(CL_DDR1_ARID		),
    .cl_ddr1_arready		(CL_DDR1_ARREADY	),
    .cl_ddr1_rdata		(CL_DDR1_RDATA		),
    .cl_ddr1_rid		(CL_DDR1_RID		),
    .cl_ddr1_rresp		(CL_DDR1_RRESP		),
    .cl_ddr1_rlast		(CL_DDR1_RLAST		),
    .cl_ddr1_rvalid		(CL_DDR1_RVALID		),
    .cl_ddr1_rready		(CL_DDR1_RREADY		),

    .cl_ddr2_awaddr		(CL_DDR2_AWADDR		),
    .cl_ddr2_awlen		(CL_DDR2_AWLEN		),
    .cl_ddr2_awsize		(CL_DDR2_AWSIZE		),
    .cl_ddr2_awburst		(CL_DDR2_AWBURST	),
    .cl_ddr2_awvalid		(CL_DDR2_AWVALID	),
    .cl_ddr2_awready		(CL_DDR2_AWREADY	),
    .cl_ddr2_wdata		(CL_DDR2_WDATA		),
    .cl_ddr2_wstrb		(CL_DDR2_WSTRB		),
    .cl_ddr2_wlast		(CL_DDR2_WLAST		),
    .cl_ddr2_wvalid		(CL_DDR2_WVALID		),
    .cl_ddr2_wready		(CL_DDR2_WREADY		),
    .cl_ddr2_bresp		(CL_DDR2_BRESP		),
    .cl_ddr2_bvalid		(CL_DDR2_BVALID		),
    .cl_ddr2_bready		(CL_DDR2_BREADY		),
    .cl_ddr2_araddr		(CL_DDR2_ARADDR		),
    .cl_ddr2_arlen		(CL_DDR2_ARLEN		),
    .cl_ddr2_arsize		(CL_DDR2_ARSIZE		),
    .cl_ddr2_arburst		(CL_DDR2_ARBURST	),
    .cl_ddr2_arvalid		(CL_DDR2_ARVALID	),
    .cl_ddr2_arid		(CL_DDR2_ARID		),
    .cl_ddr2_arready		(CL_DDR2_ARREADY	),
    .cl_ddr2_rdata		(CL_DDR2_RDATA		),
    .cl_ddr2_rid		(CL_DDR2_RID		),
    .cl_ddr2_rresp		(CL_DDR2_RRESP		),
    .cl_ddr2_rlast		(CL_DDR2_RLAST		),
    .cl_ddr2_rvalid		(CL_DDR2_RVALID		),
    .cl_ddr2_rready		(CL_DDR2_RREADY		),

    .cl_ddr3_awaddr		(CL_DDR3_AWADDR		),
    .cl_ddr3_awlen		(CL_DDR3_AWLEN		),
    .cl_ddr3_awsize		(CL_DDR3_AWSIZE		),
    .cl_ddr3_awburst		(CL_DDR3_AWBURST	),
    .cl_ddr3_awvalid		(CL_DDR3_AWVALID	),
    .cl_ddr3_awready		(CL_DDR3_AWREADY	),
    .cl_ddr3_wdata		(CL_DDR3_WDATA		),
    .cl_ddr3_wstrb		(CL_DDR3_WSTRB		),
    .cl_ddr3_wlast		(CL_DDR3_WLAST		),
    .cl_ddr3_wvalid		(CL_DDR3_WVALID		),
    .cl_ddr3_wready		(CL_DDR3_WREADY		),
    .cl_ddr3_bresp		(CL_DDR3_BRESP		),
    .cl_ddr3_bvalid		(CL_DDR3_BVALID		),
    .cl_ddr3_bready		(CL_DDR3_BREADY		),
    .cl_ddr3_araddr		(CL_DDR3_ARADDR		),
    .cl_ddr3_arlen		(CL_DDR3_ARLEN		),
    .cl_ddr3_arsize		(CL_DDR3_ARSIZE		),
    .cl_ddr3_arburst		(CL_DDR3_ARBURST	),
    .cl_ddr3_arvalid		(CL_DDR3_ARVALID	),
    .cl_ddr3_arid		(CL_DDR3_ARID		),
    .cl_ddr3_arready		(CL_DDR3_ARREADY	),
    .cl_ddr3_rdata		(CL_DDR3_RDATA		),
    .cl_ddr3_rid		(CL_DDR3_RID		),
    .cl_ddr3_rresp		(CL_DDR3_RRESP		),
    .cl_ddr3_rlast		(CL_DDR3_RLAST		),
    .cl_ddr3_rvalid		(CL_DDR3_RVALID		),
    .cl_ddr3_rready		(CL_DDR3_RREADY		),

    .cl_ddr4_awaddr		(CL_DDR4_AWADDR		),
    .cl_ddr4_awlen		(CL_DDR4_AWLEN		),
    .cl_ddr4_awsize		(CL_DDR4_AWSIZE		),
    .cl_ddr4_awburst		(CL_DDR4_AWBURST	),
    .cl_ddr4_awvalid		(CL_DDR4_AWVALID	),
    .cl_ddr4_awready		(CL_DDR4_AWREADY	),
    .cl_ddr4_wdata		(CL_DDR4_WDATA		),
    .cl_ddr4_wstrb		(CL_DDR4_WSTRB		),
    .cl_ddr4_wlast		(CL_DDR4_WLAST		),
    .cl_ddr4_wvalid		(CL_DDR4_WVALID		),
    .cl_ddr4_wready		(CL_DDR4_WREADY		),
    .cl_ddr4_bresp		(CL_DDR4_BRESP		),
    .cl_ddr4_bvalid		(CL_DDR4_BVALID		),
    .cl_ddr4_bready		(CL_DDR4_BREADY		),
    .cl_ddr4_araddr		(CL_DDR4_ARADDR		),
    .cl_ddr4_arlen		(CL_DDR4_ARLEN		),
    .cl_ddr4_arsize		(CL_DDR4_ARSIZE		),
    .cl_ddr4_arburst		(CL_DDR4_ARBURST	),
    .cl_ddr4_arvalid		(CL_DDR4_ARVALID	),
    .cl_ddr4_arid		(CL_DDR4_ARID		),
    .cl_ddr4_arready		(CL_DDR4_ARREADY	),
    .cl_ddr4_rdata		(CL_DDR4_RDATA		),
    .cl_ddr4_rid		(CL_DDR4_RID		),
    .cl_ddr4_rresp		(CL_DDR4_RRESP		),
    .cl_ddr4_rlast		(CL_DDR4_RLAST		),
    .cl_ddr4_rvalid		(CL_DDR4_RVALID		),
    .cl_ddr4_rready		(CL_DDR4_RREADY		)
);

`ifdef FSDB
initial begin
    //$fsdbAutoSwitchDumpfile(3000,"waveform.fsdb",15);
    #100ns;
    $fsdbDumpfile("waveform.fsdb");
    $fsdbDumpvars(0,"tb");
    $fsdbDumpMDA("tb");
    $fsdbDumpon;
end
`else

`ifndef VERILATOR // traced differently
  // Dump waves
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end
`endif
`endif

endmodule
