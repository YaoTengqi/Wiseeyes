verdiDockWidgetDisplay -dock widgetDock_WelcomePage
verdiWindowResize -win $_Verdi_1 -10 "39" "1920" "997"
verdiSetPrefEnv -bDisplayWelcome "off"
verdiDockWidgetHide -dock widgetDock_WelcomePage
verdiWindowResize -win $_Verdi_1 -10 "39" "1920" "997"
wvCreateWindow
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 \
           {/home/listen/Workspace/DNNAccelerator/DNNAccel/sim/test_yolo_demo/waveform.fsdb}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/dut_top_u"
wvSetPosition -win $_nWave2 {("G1" 179)}
wvSetPosition -win $_nWave2 {("G1" 179)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_arready} \
{/tb/dut_top_u/cl_ddr0_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_arvalid} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_awready} \
{/tb/dut_top_u/cl_ddr0_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_awvalid} \
{/tb/dut_top_u/cl_ddr0_bready} \
{/tb/dut_top_u/cl_ddr0_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_bvalid} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_rlast} \
{/tb/dut_top_u/cl_ddr0_rready} \
{/tb/dut_top_u/cl_ddr0_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_rvalid} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wlast} \
{/tb/dut_top_u/cl_ddr0_wready} \
{/tb/dut_top_u/cl_ddr0_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr0_wvalid} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_arready} \
{/tb/dut_top_u/cl_ddr1_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_arvalid} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_awready} \
{/tb/dut_top_u/cl_ddr1_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_awvalid} \
{/tb/dut_top_u/cl_ddr1_bready} \
{/tb/dut_top_u/cl_ddr1_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_bvalid} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_rlast} \
{/tb/dut_top_u/cl_ddr1_rready} \
{/tb/dut_top_u/cl_ddr1_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_rvalid} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wlast} \
{/tb/dut_top_u/cl_ddr1_wready} \
{/tb/dut_top_u/cl_ddr1_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr1_wvalid} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_arready} \
{/tb/dut_top_u/cl_ddr2_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_arvalid} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_awready} \
{/tb/dut_top_u/cl_ddr2_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_awvalid} \
{/tb/dut_top_u/cl_ddr2_bready} \
{/tb/dut_top_u/cl_ddr2_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_bvalid} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_rlast} \
{/tb/dut_top_u/cl_ddr2_rready} \
{/tb/dut_top_u/cl_ddr2_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_rvalid} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wlast} \
{/tb/dut_top_u/cl_ddr2_wready} \
{/tb/dut_top_u/cl_ddr2_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr2_wvalid} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_arready} \
{/tb/dut_top_u/cl_ddr3_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_arvalid} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_awready} \
{/tb/dut_top_u/cl_ddr3_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_awvalid} \
{/tb/dut_top_u/cl_ddr3_bready} \
{/tb/dut_top_u/cl_ddr3_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_bvalid} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_rlast} \
{/tb/dut_top_u/cl_ddr3_rready} \
{/tb/dut_top_u/cl_ddr3_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_rvalid} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wlast} \
{/tb/dut_top_u/cl_ddr3_wready} \
{/tb/dut_top_u/cl_ddr3_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr3_wvalid} \
{/tb/dut_top_u/cl_ddr4_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_arready} \
{/tb/dut_top_u/cl_ddr4_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_arvalid} \
{/tb/dut_top_u/cl_ddr4_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_awready} \
{/tb/dut_top_u/cl_ddr4_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_awvalid} \
{/tb/dut_top_u/cl_ddr4_bready} \
{/tb/dut_top_u/cl_ddr4_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_bvalid} \
{/tb/dut_top_u/cl_ddr4_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_rlast} \
{/tb/dut_top_u/cl_ddr4_rready} \
{/tb/dut_top_u/cl_ddr4_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_rvalid} \
{/tb/dut_top_u/cl_ddr4_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_wlast} \
{/tb/dut_top_u/cl_ddr4_wready} \
{/tb/dut_top_u/cl_ddr4_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr4_wvalid} \
{/tb/dut_top_u/clk} \
{/tb/dut_top_u/pci_cl_ctrl_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_arready} \
{/tb/dut_top_u/pci_cl_ctrl_arvalid} \
{/tb/dut_top_u/pci_cl_ctrl_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_awready} \
{/tb/dut_top_u/pci_cl_ctrl_awvalid} \
{/tb/dut_top_u/pci_cl_ctrl_bready} \
{/tb/dut_top_u/pci_cl_ctrl_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_bvalid} \
{/tb/dut_top_u/pci_cl_ctrl_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rready} \
{/tb/dut_top_u/pci_cl_ctrl_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rvalid} \
{/tb/dut_top_u/pci_cl_ctrl_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wready} \
{/tb/dut_top_u/pci_cl_ctrl_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wvalid} \
{/tb/dut_top_u/pci_cl_data_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_arburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_arlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_arready} \
{/tb/dut_top_u/pci_cl_data_arsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_arvalid} \
{/tb/dut_top_u/pci_cl_data_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_awburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_awlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_awready} \
{/tb/dut_top_u/pci_cl_data_awsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_awvalid} \
{/tb/dut_top_u/pci_cl_data_bready} \
{/tb/dut_top_u/pci_cl_data_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_bvalid} \
{/tb/dut_top_u/pci_cl_data_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_rlast} \
{/tb/dut_top_u/pci_cl_data_rready} \
{/tb/dut_top_u/pci_cl_data_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_rvalid} \
{/tb/dut_top_u/pci_cl_data_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_wlast} \
{/tb/dut_top_u/pci_cl_data_wready} \
{/tb/dut_top_u/pci_cl_data_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_data_wvalid} \
{/tb/dut_top_u/reset} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 \
           62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 \
           84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 \
           105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 \
           122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 \
           139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 \
           156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 \
           173 174 175 176 177 178 179 )} 
wvSetPosition -win $_nWave2 {("G1" 179)}
wvSetPosition -win $_nWave2 {("G1" 179)}
wvSetPosition -win $_nWave2 {("G1" 179)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_arready} \
{/tb/dut_top_u/cl_ddr0_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_arvalid} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_awready} \
{/tb/dut_top_u/cl_ddr0_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_awvalid} \
{/tb/dut_top_u/cl_ddr0_bready} \
{/tb/dut_top_u/cl_ddr0_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_bvalid} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_rlast} \
{/tb/dut_top_u/cl_ddr0_rready} \
{/tb/dut_top_u/cl_ddr0_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_rvalid} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wlast} \
{/tb/dut_top_u/cl_ddr0_wready} \
{/tb/dut_top_u/cl_ddr0_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr0_wvalid} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_arready} \
{/tb/dut_top_u/cl_ddr1_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_arvalid} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_awready} \
{/tb/dut_top_u/cl_ddr1_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_awvalid} \
{/tb/dut_top_u/cl_ddr1_bready} \
{/tb/dut_top_u/cl_ddr1_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_bvalid} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_rlast} \
{/tb/dut_top_u/cl_ddr1_rready} \
{/tb/dut_top_u/cl_ddr1_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_rvalid} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wlast} \
{/tb/dut_top_u/cl_ddr1_wready} \
{/tb/dut_top_u/cl_ddr1_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr1_wvalid} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_arready} \
{/tb/dut_top_u/cl_ddr2_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_arvalid} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_awready} \
{/tb/dut_top_u/cl_ddr2_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_awvalid} \
{/tb/dut_top_u/cl_ddr2_bready} \
{/tb/dut_top_u/cl_ddr2_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_bvalid} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_rlast} \
{/tb/dut_top_u/cl_ddr2_rready} \
{/tb/dut_top_u/cl_ddr2_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_rvalid} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wlast} \
{/tb/dut_top_u/cl_ddr2_wready} \
{/tb/dut_top_u/cl_ddr2_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr2_wvalid} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_arready} \
{/tb/dut_top_u/cl_ddr3_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_arvalid} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_awready} \
{/tb/dut_top_u/cl_ddr3_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_awvalid} \
{/tb/dut_top_u/cl_ddr3_bready} \
{/tb/dut_top_u/cl_ddr3_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_bvalid} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_rlast} \
{/tb/dut_top_u/cl_ddr3_rready} \
{/tb/dut_top_u/cl_ddr3_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_rvalid} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wlast} \
{/tb/dut_top_u/cl_ddr3_wready} \
{/tb/dut_top_u/cl_ddr3_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr3_wvalid} \
{/tb/dut_top_u/cl_ddr4_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_arready} \
{/tb/dut_top_u/cl_ddr4_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_arvalid} \
{/tb/dut_top_u/cl_ddr4_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_awready} \
{/tb/dut_top_u/cl_ddr4_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_awvalid} \
{/tb/dut_top_u/cl_ddr4_bready} \
{/tb/dut_top_u/cl_ddr4_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_bvalid} \
{/tb/dut_top_u/cl_ddr4_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_rlast} \
{/tb/dut_top_u/cl_ddr4_rready} \
{/tb/dut_top_u/cl_ddr4_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_rvalid} \
{/tb/dut_top_u/cl_ddr4_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_wlast} \
{/tb/dut_top_u/cl_ddr4_wready} \
{/tb/dut_top_u/cl_ddr4_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr4_wvalid} \
{/tb/dut_top_u/clk} \
{/tb/dut_top_u/pci_cl_ctrl_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_arready} \
{/tb/dut_top_u/pci_cl_ctrl_arvalid} \
{/tb/dut_top_u/pci_cl_ctrl_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_awready} \
{/tb/dut_top_u/pci_cl_ctrl_awvalid} \
{/tb/dut_top_u/pci_cl_ctrl_bready} \
{/tb/dut_top_u/pci_cl_ctrl_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_bvalid} \
{/tb/dut_top_u/pci_cl_ctrl_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rready} \
{/tb/dut_top_u/pci_cl_ctrl_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rvalid} \
{/tb/dut_top_u/pci_cl_ctrl_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wready} \
{/tb/dut_top_u/pci_cl_ctrl_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wvalid} \
{/tb/dut_top_u/pci_cl_data_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_arburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_arlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_arready} \
{/tb/dut_top_u/pci_cl_data_arsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_arvalid} \
{/tb/dut_top_u/pci_cl_data_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_awburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_awlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_awready} \
{/tb/dut_top_u/pci_cl_data_awsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_awvalid} \
{/tb/dut_top_u/pci_cl_data_bready} \
{/tb/dut_top_u/pci_cl_data_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_bvalid} \
{/tb/dut_top_u/pci_cl_data_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_rlast} \
{/tb/dut_top_u/pci_cl_data_rready} \
{/tb/dut_top_u/pci_cl_data_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_rvalid} \
{/tb/dut_top_u/pci_cl_data_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_wlast} \
{/tb/dut_top_u/pci_cl_data_wready} \
{/tb/dut_top_u/pci_cl_data_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_data_wvalid} \
{/tb/dut_top_u/reset} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 \
           62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 \
           84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 \
           105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 \
           122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 \
           139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 \
           156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 \
           173 174 175 176 177 178 179 )} 
wvSetPosition -win $_nWave2 {("G1" 179)}
wvGetSignalClose -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 38
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
verdiDockWidgetHide -dock windowDock_nWave_2
wvCreateWindow
verdiDockWidgetSetCurTab -dock widgetDock_<Message>
verdiDockWidgetSetCurTab -dock windowDock_nWave_3
wvCloseWindow -win $_nWave3
verdiDockWidgetDisplay -dock windowDock_nWave_2
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvScrollDown -win $_nWave2 3
wvZoomAll -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/dut_top_u"
wvGetSignalSetScope -win $_nWave2 "/tb/dut_top_u"
wvSetPosition -win $_nWave2 {("G1" 358)}
wvSetPosition -win $_nWave2 {("G1" 358)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_arready} \
{/tb/dut_top_u/cl_ddr0_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_arvalid} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_awready} \
{/tb/dut_top_u/cl_ddr0_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_awvalid} \
{/tb/dut_top_u/cl_ddr0_bready} \
{/tb/dut_top_u/cl_ddr0_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_bvalid} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_rlast} \
{/tb/dut_top_u/cl_ddr0_rready} \
{/tb/dut_top_u/cl_ddr0_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_rvalid} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wlast} \
{/tb/dut_top_u/cl_ddr0_wready} \
{/tb/dut_top_u/cl_ddr0_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr0_wvalid} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_arready} \
{/tb/dut_top_u/cl_ddr1_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_arvalid} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_awready} \
{/tb/dut_top_u/cl_ddr1_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_awvalid} \
{/tb/dut_top_u/cl_ddr1_bready} \
{/tb/dut_top_u/cl_ddr1_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_bvalid} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_rlast} \
{/tb/dut_top_u/cl_ddr1_rready} \
{/tb/dut_top_u/cl_ddr1_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_rvalid} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wlast} \
{/tb/dut_top_u/cl_ddr1_wready} \
{/tb/dut_top_u/cl_ddr1_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr1_wvalid} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_arready} \
{/tb/dut_top_u/cl_ddr2_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_arvalid} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_awready} \
{/tb/dut_top_u/cl_ddr2_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_awvalid} \
{/tb/dut_top_u/cl_ddr2_bready} \
{/tb/dut_top_u/cl_ddr2_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_bvalid} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_rlast} \
{/tb/dut_top_u/cl_ddr2_rready} \
{/tb/dut_top_u/cl_ddr2_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_rvalid} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wlast} \
{/tb/dut_top_u/cl_ddr2_wready} \
{/tb/dut_top_u/cl_ddr2_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr2_wvalid} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_arready} \
{/tb/dut_top_u/cl_ddr3_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_arvalid} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_awready} \
{/tb/dut_top_u/cl_ddr3_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_awvalid} \
{/tb/dut_top_u/cl_ddr3_bready} \
{/tb/dut_top_u/cl_ddr3_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_bvalid} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_rlast} \
{/tb/dut_top_u/cl_ddr3_rready} \
{/tb/dut_top_u/cl_ddr3_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_rvalid} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wlast} \
{/tb/dut_top_u/cl_ddr3_wready} \
{/tb/dut_top_u/cl_ddr3_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr3_wvalid} \
{/tb/dut_top_u/cl_ddr4_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_arready} \
{/tb/dut_top_u/cl_ddr4_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_arvalid} \
{/tb/dut_top_u/cl_ddr4_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_awready} \
{/tb/dut_top_u/cl_ddr4_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_awvalid} \
{/tb/dut_top_u/cl_ddr4_bready} \
{/tb/dut_top_u/cl_ddr4_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_bvalid} \
{/tb/dut_top_u/cl_ddr4_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_rlast} \
{/tb/dut_top_u/cl_ddr4_rready} \
{/tb/dut_top_u/cl_ddr4_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_rvalid} \
{/tb/dut_top_u/cl_ddr4_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_wlast} \
{/tb/dut_top_u/cl_ddr4_wready} \
{/tb/dut_top_u/cl_ddr4_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr4_wvalid} \
{/tb/dut_top_u/clk} \
{/tb/dut_top_u/pci_cl_ctrl_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_arready} \
{/tb/dut_top_u/pci_cl_ctrl_arvalid} \
{/tb/dut_top_u/pci_cl_ctrl_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_awready} \
{/tb/dut_top_u/pci_cl_ctrl_awvalid} \
{/tb/dut_top_u/pci_cl_ctrl_bready} \
{/tb/dut_top_u/pci_cl_ctrl_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_bvalid} \
{/tb/dut_top_u/pci_cl_ctrl_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rready} \
{/tb/dut_top_u/pci_cl_ctrl_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rvalid} \
{/tb/dut_top_u/pci_cl_ctrl_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wready} \
{/tb/dut_top_u/pci_cl_ctrl_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wvalid} \
{/tb/dut_top_u/pci_cl_data_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_arburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_arlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_arready} \
{/tb/dut_top_u/pci_cl_data_arsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_arvalid} \
{/tb/dut_top_u/pci_cl_data_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_awburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_awlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_awready} \
{/tb/dut_top_u/pci_cl_data_awsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_awvalid} \
{/tb/dut_top_u/pci_cl_data_bready} \
{/tb/dut_top_u/pci_cl_data_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_bvalid} \
{/tb/dut_top_u/pci_cl_data_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_rlast} \
{/tb/dut_top_u/pci_cl_data_rready} \
{/tb/dut_top_u/pci_cl_data_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_rvalid} \
{/tb/dut_top_u/pci_cl_data_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_wlast} \
{/tb/dut_top_u/pci_cl_data_wready} \
{/tb/dut_top_u/pci_cl_data_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_data_wvalid} \
{/tb/dut_top_u/reset} \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_arready} \
{/tb/dut_top_u/cl_ddr0_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_arvalid} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_awready} \
{/tb/dut_top_u/cl_ddr0_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_awvalid} \
{/tb/dut_top_u/cl_ddr0_bready} \
{/tb/dut_top_u/cl_ddr0_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_bvalid} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_rlast} \
{/tb/dut_top_u/cl_ddr0_rready} \
{/tb/dut_top_u/cl_ddr0_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_rvalid} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wlast} \
{/tb/dut_top_u/cl_ddr0_wready} \
{/tb/dut_top_u/cl_ddr0_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr0_wvalid} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_arready} \
{/tb/dut_top_u/cl_ddr1_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_arvalid} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_awready} \
{/tb/dut_top_u/cl_ddr1_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_awvalid} \
{/tb/dut_top_u/cl_ddr1_bready} \
{/tb/dut_top_u/cl_ddr1_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_bvalid} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_rlast} \
{/tb/dut_top_u/cl_ddr1_rready} \
{/tb/dut_top_u/cl_ddr1_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_rvalid} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wlast} \
{/tb/dut_top_u/cl_ddr1_wready} \
{/tb/dut_top_u/cl_ddr1_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr1_wvalid} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_arready} \
{/tb/dut_top_u/cl_ddr2_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_arvalid} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_awready} \
{/tb/dut_top_u/cl_ddr2_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_awvalid} \
{/tb/dut_top_u/cl_ddr2_bready} \
{/tb/dut_top_u/cl_ddr2_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_bvalid} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_rlast} \
{/tb/dut_top_u/cl_ddr2_rready} \
{/tb/dut_top_u/cl_ddr2_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_rvalid} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wlast} \
{/tb/dut_top_u/cl_ddr2_wready} \
{/tb/dut_top_u/cl_ddr2_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr2_wvalid} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_arready} \
{/tb/dut_top_u/cl_ddr3_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_arvalid} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_awready} \
{/tb/dut_top_u/cl_ddr3_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_awvalid} \
{/tb/dut_top_u/cl_ddr3_bready} \
{/tb/dut_top_u/cl_ddr3_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_bvalid} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_rlast} \
{/tb/dut_top_u/cl_ddr3_rready} \
{/tb/dut_top_u/cl_ddr3_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_rvalid} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wlast} \
{/tb/dut_top_u/cl_ddr3_wready} \
{/tb/dut_top_u/cl_ddr3_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr3_wvalid} \
{/tb/dut_top_u/cl_ddr4_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_arready} \
{/tb/dut_top_u/cl_ddr4_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_arvalid} \
{/tb/dut_top_u/cl_ddr4_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_awready} \
{/tb/dut_top_u/cl_ddr4_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_awvalid} \
{/tb/dut_top_u/cl_ddr4_bready} \
{/tb/dut_top_u/cl_ddr4_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_bvalid} \
{/tb/dut_top_u/cl_ddr4_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_rlast} \
{/tb/dut_top_u/cl_ddr4_rready} \
{/tb/dut_top_u/cl_ddr4_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_rvalid} \
{/tb/dut_top_u/cl_ddr4_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_wlast} \
{/tb/dut_top_u/cl_ddr4_wready} \
{/tb/dut_top_u/cl_ddr4_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr4_wvalid} \
{/tb/dut_top_u/clk} \
{/tb/dut_top_u/pci_cl_ctrl_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_arready} \
{/tb/dut_top_u/pci_cl_ctrl_arvalid} \
{/tb/dut_top_u/pci_cl_ctrl_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_awready} \
{/tb/dut_top_u/pci_cl_ctrl_awvalid} \
{/tb/dut_top_u/pci_cl_ctrl_bready} \
{/tb/dut_top_u/pci_cl_ctrl_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_bvalid} \
{/tb/dut_top_u/pci_cl_ctrl_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rready} \
{/tb/dut_top_u/pci_cl_ctrl_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rvalid} \
{/tb/dut_top_u/pci_cl_ctrl_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wready} \
{/tb/dut_top_u/pci_cl_ctrl_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wvalid} \
{/tb/dut_top_u/pci_cl_data_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_arburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_arlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_arready} \
{/tb/dut_top_u/pci_cl_data_arsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_arvalid} \
{/tb/dut_top_u/pci_cl_data_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_awburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_awlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_awready} \
{/tb/dut_top_u/pci_cl_data_awsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_awvalid} \
{/tb/dut_top_u/pci_cl_data_bready} \
{/tb/dut_top_u/pci_cl_data_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_bvalid} \
{/tb/dut_top_u/pci_cl_data_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_rlast} \
{/tb/dut_top_u/pci_cl_data_rready} \
{/tb/dut_top_u/pci_cl_data_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_rvalid} \
{/tb/dut_top_u/pci_cl_data_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_wlast} \
{/tb/dut_top_u/pci_cl_data_wready} \
{/tb/dut_top_u/pci_cl_data_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_data_wvalid} \
{/tb/dut_top_u/reset} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 \
           {( "G1" 180 181 182 183 184 185 186 187 188 189 190 \
           191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 \
           208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 \
           225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 \
           242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 \
           259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 \
           276 277 278 279 280 281 282 283 284 285 286 287 288 289 290 291 292 \
           293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 \
           310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 \
           327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 \
           344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 )} 
wvSetPosition -win $_nWave2 {("G1" 358)}
wvSetPosition -win $_nWave2 {("G1" 358)}
wvSetPosition -win $_nWave2 {("G1" 358)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_arready} \
{/tb/dut_top_u/cl_ddr0_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_arvalid} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_awready} \
{/tb/dut_top_u/cl_ddr0_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_awvalid} \
{/tb/dut_top_u/cl_ddr0_bready} \
{/tb/dut_top_u/cl_ddr0_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_bvalid} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_rlast} \
{/tb/dut_top_u/cl_ddr0_rready} \
{/tb/dut_top_u/cl_ddr0_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_rvalid} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wlast} \
{/tb/dut_top_u/cl_ddr0_wready} \
{/tb/dut_top_u/cl_ddr0_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr0_wvalid} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_arready} \
{/tb/dut_top_u/cl_ddr1_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_arvalid} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_awready} \
{/tb/dut_top_u/cl_ddr1_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_awvalid} \
{/tb/dut_top_u/cl_ddr1_bready} \
{/tb/dut_top_u/cl_ddr1_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_bvalid} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_rlast} \
{/tb/dut_top_u/cl_ddr1_rready} \
{/tb/dut_top_u/cl_ddr1_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_rvalid} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wlast} \
{/tb/dut_top_u/cl_ddr1_wready} \
{/tb/dut_top_u/cl_ddr1_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr1_wvalid} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_arready} \
{/tb/dut_top_u/cl_ddr2_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_arvalid} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_awready} \
{/tb/dut_top_u/cl_ddr2_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_awvalid} \
{/tb/dut_top_u/cl_ddr2_bready} \
{/tb/dut_top_u/cl_ddr2_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_bvalid} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_rlast} \
{/tb/dut_top_u/cl_ddr2_rready} \
{/tb/dut_top_u/cl_ddr2_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_rvalid} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wlast} \
{/tb/dut_top_u/cl_ddr2_wready} \
{/tb/dut_top_u/cl_ddr2_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr2_wvalid} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_arready} \
{/tb/dut_top_u/cl_ddr3_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_arvalid} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_awready} \
{/tb/dut_top_u/cl_ddr3_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_awvalid} \
{/tb/dut_top_u/cl_ddr3_bready} \
{/tb/dut_top_u/cl_ddr3_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_bvalid} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_rlast} \
{/tb/dut_top_u/cl_ddr3_rready} \
{/tb/dut_top_u/cl_ddr3_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_rvalid} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wlast} \
{/tb/dut_top_u/cl_ddr3_wready} \
{/tb/dut_top_u/cl_ddr3_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr3_wvalid} \
{/tb/dut_top_u/cl_ddr4_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_arready} \
{/tb/dut_top_u/cl_ddr4_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_arvalid} \
{/tb/dut_top_u/cl_ddr4_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_awready} \
{/tb/dut_top_u/cl_ddr4_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_awvalid} \
{/tb/dut_top_u/cl_ddr4_bready} \
{/tb/dut_top_u/cl_ddr4_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_bvalid} \
{/tb/dut_top_u/cl_ddr4_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_rlast} \
{/tb/dut_top_u/cl_ddr4_rready} \
{/tb/dut_top_u/cl_ddr4_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_rvalid} \
{/tb/dut_top_u/cl_ddr4_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_wlast} \
{/tb/dut_top_u/cl_ddr4_wready} \
{/tb/dut_top_u/cl_ddr4_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr4_wvalid} \
{/tb/dut_top_u/clk} \
{/tb/dut_top_u/pci_cl_ctrl_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_arready} \
{/tb/dut_top_u/pci_cl_ctrl_arvalid} \
{/tb/dut_top_u/pci_cl_ctrl_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_awready} \
{/tb/dut_top_u/pci_cl_ctrl_awvalid} \
{/tb/dut_top_u/pci_cl_ctrl_bready} \
{/tb/dut_top_u/pci_cl_ctrl_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_bvalid} \
{/tb/dut_top_u/pci_cl_ctrl_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rready} \
{/tb/dut_top_u/pci_cl_ctrl_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rvalid} \
{/tb/dut_top_u/pci_cl_ctrl_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wready} \
{/tb/dut_top_u/pci_cl_ctrl_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wvalid} \
{/tb/dut_top_u/pci_cl_data_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_arburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_arlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_arready} \
{/tb/dut_top_u/pci_cl_data_arsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_arvalid} \
{/tb/dut_top_u/pci_cl_data_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_awburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_awlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_awready} \
{/tb/dut_top_u/pci_cl_data_awsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_awvalid} \
{/tb/dut_top_u/pci_cl_data_bready} \
{/tb/dut_top_u/pci_cl_data_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_bvalid} \
{/tb/dut_top_u/pci_cl_data_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_rlast} \
{/tb/dut_top_u/pci_cl_data_rready} \
{/tb/dut_top_u/pci_cl_data_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_rvalid} \
{/tb/dut_top_u/pci_cl_data_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_wlast} \
{/tb/dut_top_u/pci_cl_data_wready} \
{/tb/dut_top_u/pci_cl_data_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_data_wvalid} \
{/tb/dut_top_u/reset} \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_arready} \
{/tb/dut_top_u/cl_ddr0_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_arvalid} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr0_awready} \
{/tb/dut_top_u/cl_ddr0_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr0_awvalid} \
{/tb/dut_top_u/cl_ddr0_bready} \
{/tb/dut_top_u/cl_ddr0_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_bvalid} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr0_rlast} \
{/tb/dut_top_u/cl_ddr0_rready} \
{/tb/dut_top_u/cl_ddr0_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr0_rvalid} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wlast} \
{/tb/dut_top_u/cl_ddr0_wready} \
{/tb/dut_top_u/cl_ddr0_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr0_wvalid} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_arready} \
{/tb/dut_top_u/cl_ddr1_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_arvalid} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr1_awready} \
{/tb/dut_top_u/cl_ddr1_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr1_awvalid} \
{/tb/dut_top_u/cl_ddr1_bready} \
{/tb/dut_top_u/cl_ddr1_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_bvalid} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr1_rlast} \
{/tb/dut_top_u/cl_ddr1_rready} \
{/tb/dut_top_u/cl_ddr1_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr1_rvalid} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wlast} \
{/tb/dut_top_u/cl_ddr1_wready} \
{/tb/dut_top_u/cl_ddr1_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr1_wvalid} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_arready} \
{/tb/dut_top_u/cl_ddr2_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_arvalid} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr2_awready} \
{/tb/dut_top_u/cl_ddr2_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr2_awvalid} \
{/tb/dut_top_u/cl_ddr2_bready} \
{/tb/dut_top_u/cl_ddr2_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_bvalid} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr2_rlast} \
{/tb/dut_top_u/cl_ddr2_rready} \
{/tb/dut_top_u/cl_ddr2_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr2_rvalid} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wlast} \
{/tb/dut_top_u/cl_ddr2_wready} \
{/tb/dut_top_u/cl_ddr2_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr2_wvalid} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_arready} \
{/tb/dut_top_u/cl_ddr3_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_arvalid} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr3_awready} \
{/tb/dut_top_u/cl_ddr3_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr3_awvalid} \
{/tb/dut_top_u/cl_ddr3_bready} \
{/tb/dut_top_u/cl_ddr3_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_bvalid} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr3_rlast} \
{/tb/dut_top_u/cl_ddr3_rready} \
{/tb/dut_top_u/cl_ddr3_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr3_rvalid} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wlast} \
{/tb/dut_top_u/cl_ddr3_wready} \
{/tb/dut_top_u/cl_ddr3_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr3_wvalid} \
{/tb/dut_top_u/cl_ddr4_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_arburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_arid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_arlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_arready} \
{/tb/dut_top_u/cl_ddr4_arsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_arvalid} \
{/tb/dut_top_u/cl_ddr4_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_awburst\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_awlen\[7:0\]} \
{/tb/dut_top_u/cl_ddr4_awready} \
{/tb/dut_top_u/cl_ddr4_awsize\[2:0\]} \
{/tb/dut_top_u/cl_ddr4_awvalid} \
{/tb/dut_top_u/cl_ddr4_bready} \
{/tb/dut_top_u/cl_ddr4_bresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_bvalid} \
{/tb/dut_top_u/cl_ddr4_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_rid\[0:0\]} \
{/tb/dut_top_u/cl_ddr4_rlast} \
{/tb/dut_top_u/cl_ddr4_rready} \
{/tb/dut_top_u/cl_ddr4_rresp\[1:0\]} \
{/tb/dut_top_u/cl_ddr4_rvalid} \
{/tb/dut_top_u/cl_ddr4_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_wlast} \
{/tb/dut_top_u/cl_ddr4_wready} \
{/tb/dut_top_u/cl_ddr4_wstrb\[31:0\]} \
{/tb/dut_top_u/cl_ddr4_wvalid} \
{/tb/dut_top_u/clk} \
{/tb/dut_top_u/pci_cl_ctrl_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_arready} \
{/tb/dut_top_u/pci_cl_ctrl_arvalid} \
{/tb/dut_top_u/pci_cl_ctrl_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_awready} \
{/tb/dut_top_u/pci_cl_ctrl_awvalid} \
{/tb/dut_top_u/pci_cl_ctrl_bready} \
{/tb/dut_top_u/pci_cl_ctrl_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_bvalid} \
{/tb/dut_top_u/pci_cl_ctrl_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rready} \
{/tb/dut_top_u/pci_cl_ctrl_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rvalid} \
{/tb/dut_top_u/pci_cl_ctrl_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wready} \
{/tb/dut_top_u/pci_cl_ctrl_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wvalid} \
{/tb/dut_top_u/pci_cl_data_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_arburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_arlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_arready} \
{/tb/dut_top_u/pci_cl_data_arsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_arvalid} \
{/tb/dut_top_u/pci_cl_data_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_awburst\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_awlen\[7:0\]} \
{/tb/dut_top_u/pci_cl_data_awready} \
{/tb/dut_top_u/pci_cl_data_awsize\[2:0\]} \
{/tb/dut_top_u/pci_cl_data_awvalid} \
{/tb/dut_top_u/pci_cl_data_bready} \
{/tb/dut_top_u/pci_cl_data_bresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_bvalid} \
{/tb/dut_top_u/pci_cl_data_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_rlast} \
{/tb/dut_top_u/pci_cl_data_rready} \
{/tb/dut_top_u/pci_cl_data_rresp\[1:0\]} \
{/tb/dut_top_u/pci_cl_data_rvalid} \
{/tb/dut_top_u/pci_cl_data_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_wlast} \
{/tb/dut_top_u/pci_cl_data_wready} \
{/tb/dut_top_u/pci_cl_data_wstrb\[3:0\]} \
{/tb/dut_top_u/pci_cl_data_wvalid} \
{/tb/dut_top_u/reset} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 \
           {( "G1" 180 181 182 183 184 185 186 187 188 189 190 \
           191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 \
           208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 \
           225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 \
           242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 \
           259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 \
           276 277 278 279 280 281 282 283 284 285 286 287 288 289 290 291 292 \
           293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 \
           310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 \
           327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 \
           344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 )} 
wvSetPosition -win $_nWave2 {("G1" 358)}
wvGetSignalClose -win $_nWave2
wvTpfCloseForm -win $_nWave2
wvGetSignalClose -win $_nWave2
wvCloseWindow -win $_nWave2
wvCreateWindow
verdiDockWidgetHide -dock windowDock_nWave_4
verdiDockWidgetDisplay -dock windowDock_nWave_4
verdiDockWidgetMaximize -dock windowDock_nWave_4
wvGetSignalOpen -win $_nWave4
wvGetSignalSetScope -win $_nWave4 "/tb"
wvGetSignalSetScope -win $_nWave4 "/tb/dut_top_u"
wvSetPosition -win $_nWave4 {("G1" 4)}
wvSetPosition -win $_nWave4 {("G1" 4)}
wvAddSignal -win $_nWave4 -clear
wvAddSignal -win $_nWave4 -group {"G1" \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
}
wvAddSignal -win $_nWave4 -group {"G2" \
}
wvSelectSignal -win $_nWave4 {( "G1" 1 2 3 4 )} 
wvSetPosition -win $_nWave4 {("G1" 4)}
wvSetPosition -win $_nWave4 {("G1" 16)}
wvSetPosition -win $_nWave4 {("G1" 16)}
wvAddSignal -win $_nWave4 -clear
wvAddSignal -win $_nWave4 -group {"G1" \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
}
wvAddSignal -win $_nWave4 -group {"G2" \
}
wvSelectSignal -win $_nWave4 {( "G1" 5 6 7 8 9 10 11 12 13 14 15 16 )} 
wvSetPosition -win $_nWave4 {("G1" 16)}
wvSetPosition -win $_nWave4 {("G1" 20)}
wvSetPosition -win $_nWave4 {("G1" 20)}
wvAddSignal -win $_nWave4 -clear
wvAddSignal -win $_nWave4 -group {"G1" \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_wdata\[255:0\]} \
}
wvAddSignal -win $_nWave4 -group {"G2" \
}
wvSelectSignal -win $_nWave4 {( "G1" 17 18 19 20 )} 
wvSetPosition -win $_nWave4 {("G1" 20)}
wvSetPosition -win $_nWave4 {("G1" 24)}
wvSetPosition -win $_nWave4 {("G1" 24)}
wvAddSignal -win $_nWave4 -clear
wvAddSignal -win $_nWave4 -group {"G1" \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_wdata\[255:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wdata\[31:0\]} \
}
wvAddSignal -win $_nWave4 -group {"G2" \
}
wvSelectSignal -win $_nWave4 {( "G1" 21 22 23 24 )} 
wvSetPosition -win $_nWave4 {("G1" 24)}
wvSetPosition -win $_nWave4 {("G1" 28)}
wvSetPosition -win $_nWave4 {("G1" 28)}
wvAddSignal -win $_nWave4 -clear
wvAddSignal -win $_nWave4 -group {"G1" \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_wdata\[255:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_wdata\[31:0\]} \
}
wvAddSignal -win $_nWave4 -group {"G2" \
}
wvSelectSignal -win $_nWave4 {( "G1" 25 26 27 28 )} 
wvSetPosition -win $_nWave4 {("G1" 28)}
wvSetPosition -win $_nWave4 {("G1" 28)}
wvSetPosition -win $_nWave4 {("G1" 28)}
wvAddSignal -win $_nWave4 -clear
wvAddSignal -win $_nWave4 -group {"G1" \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_wdata\[255:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_wdata\[31:0\]} \
}
wvAddSignal -win $_nWave4 -group {"G2" \
}
wvSelectSignal -win $_nWave4 {( "G1" 25 26 27 28 )} 
wvSetPosition -win $_nWave4 {("G1" 28)}
wvSetPosition -win $_nWave4 {("G1" 28)}
wvSetPosition -win $_nWave4 {("G1" 28)}
wvAddSignal -win $_nWave4 -clear
wvAddSignal -win $_nWave4 -group {"G1" \
{/tb/dut_top_u/cl_ddr0_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr0_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr0_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr1_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr1_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr2_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr2_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr3_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr3_wdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_araddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_awaddr\[41:0\]} \
{/tb/dut_top_u/cl_ddr4_rdata\[255:0\]} \
{/tb/dut_top_u/cl_ddr4_wdata\[255:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_ctrl_wdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_araddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_awaddr\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_rdata\[31:0\]} \
{/tb/dut_top_u/pci_cl_data_wdata\[31:0\]} \
}
wvAddSignal -win $_nWave4 -group {"G2" \
}
wvSelectSignal -win $_nWave4 {( "G1" 25 26 27 28 )} 
wvSetPosition -win $_nWave4 {("G1" 28)}
wvGetSignalClose -win $_nWave4
wvSelectSignal -win $_nWave4 {( "G1" 21 )} 
wvSelectSignal -win $_nWave4 {( "G1" 21 22 23 24 25 26 27 28 )} 
wvSelectSignal -win $_nWave4 {( "G1" 22 23 24 25 )} 
wvSelectSignal -win $_nWave4 {( "G1" 23 )} 
wvSelectSignal -win $_nWave4 {( "G1" 22 )} 
wvSelectSignal -win $_nWave4 {( "G1" 21 )} 
wvSelectSignal -win $_nWave4 {( "G1" 21 22 23 24 25 26 27 )} 
wvSelectSignal -win $_nWave4 {( "G1" 21 22 23 24 25 26 27 28 )} 
wvSelectSignal -win $_nWave4 {( "G1" 19 )} 
wvSelectSignal -win $_nWave4 {( "G1" 21 )} 
wvSelectSignal -win $_nWave4 {( "G1" 22 )} 
wvSelectSignal -win $_nWave4 {( "G1" 24 )} 
wvSelectSignal -win $_nWave4 {( "G1" 26 )} 
wvSelectSignal -win $_nWave4 {( "G1" 27 )} 
wvSelectSignal -win $_nWave4 {( "G1" 25 )} 
wvSelectGroup -win $_nWave4 {G1}
wvSelectSignal -win $_nWave4 {( "G1" 1 )} 
wvSelectSignal -win $_nWave4 {( "G1" 27 )} 
wvSelectSignal -win $_nWave4 {( "G1" 21 )} 
wvSelectSignal -win $_nWave4 {( "G1" 21 22 23 24 25 26 27 28 )} 
wvMoveSelected -win $_nWave4
wvSetPosition -win $_nWave4 {("G1" 28)}
wvSelectSignal -win $_nWave4 {( "G1" 23 24 25 26 27 28 )} 
wvSelectSignal -win $_nWave4 {( "G1" 21 )} 
wvZoomAll -win $_nWave4
wvSetCursor -win $_nWave4 100000.000000 -snap {("G1" 22)}
wvSetCursor -win $_nWave4 100000.000000
verdiWindowResize -win $_Verdi_1 "432" "42" "900" "700"
verdiWindowResize -win $_Verdi_1 -8 "42" "1920" "997"
wvSelectStuckSignals -win $_nWave4
wvSetCursor -win $_nWave4 225973616.484224 -snap {("G1" 6)}
wvSetCursor -win $_nWave4 252546983.129427 -snap {("G1" 5)}
wvSetCursor -win $_nWave4 100000.000000 -snap {("G1" 5)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 6962347.141790 -snap {("G1" 26)}
wvSelectSignal -win $_nWave4 {( "G1" 21 )} 
wvSelectSignal -win $_nWave4 {( "G1" 22 )} 
wvSelectSignal -win $_nWave4 {( "G1" 21 22 23 )} 
wvSelectSignal -win $_nWave4 {( "G1" 22 )} 
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 18067871.885770 -snap {("G1" 26)}
wvSetCursor -win $_nWave4 19710979.549388 -snap {("G1" 23)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvSetCursor -win $_nWave4 19872367.665293 -snap {("G1" 21)}
wvSetCursor -win $_nWave4 19814556.996909 -snap {("G1" 22)}
wvSetCursor -win $_nWave4 19686088.844945 -snap {("G1" 22)}
wvSetCursor -win $_nWave4 19716600.031037 -snap {("G1" 23)}
wvSetCursor -win $_nWave4 19695723.956343 -snap {("G1" 24)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvSetCursor -win $_nWave4 19663807.649839 -snap {("G1" 24)}
wvSetCursor -win $_nWave4 19724428.559047 -snap {("G1" 24)}
wvSelectSignal -win $_nWave4 {( "G1" 23 )} 
wvSelectSignal -win $_nWave4 {( "G1" 24 )} 
wvSetCursor -win $_nWave4 19769793.875209 -snap {("G1" 23)}
wvSetCursor -win $_nWave4 19744100.244816 -snap {("G1" 23)}
wvSetCursor -win $_nWave4 19744903.170766 -snap {("G1" 22)}
wvSetCursor -win $_nWave4 19718225.956085 -snap {("G1" 21)}
wvSetCursor -win $_nWave4 19711802.548487 -snap {("G1" 23)}
wvSetCursor -win $_nWave4 19824212.181455 -snap {("G1" 21)}
wvSetCursor -win $_nWave4 19774832.235544 -snap {("G1" 21)}
wvSetCursor -win $_nWave4 19738299.104829 -snap {("G1" 23)}
wvSetCursor -win $_nWave4 20041604.382357 -snap {("G1" 23)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvSetCursor -win $_nWave4 20057231.328654 -snap {("G1" 1)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvSelectSignal -win $_nWave4 {( "G1" 5 )} 
wvSetCursor -win $_nWave4 20068415.522577 -snap {("G1" 6)}
wvSetCursor -win $_nWave4 2013849433.962264
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 19729933.620120 -snap {("G1" 1)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvSetCursor -win $_nWave4 20060613.654248 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20065933.038665 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20069621.479747 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20074514.309753 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20077926.745040 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20057778.321988 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20063599.535123 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20068216.359335 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20058004.144911 -snap {("G1" 5)}
wvSetCursor -win $_nWave4 20062871.883481 -snap {("G1" 5)}
wvSetCursor -win $_nWave4 20066108.678716 -snap {("G1" 5)}
wvSetCursor -win $_nWave4 20064477.735381 -snap {("G1" 5)}
wvSetCursor -win $_nWave4 20058280.150706 -snap {("G1" 5)}
wvSetCursor -win $_nWave4 20065958.130101 -snap {("G1" 7)}
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 20031107.380165 -snap {("G1" 9)}
wvSelectSignal -win $_nWave4 {( "G1" 10 )} 
wvSelectSignal -win $_nWave4 {( "G1" 9 )} 
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSelectSignal -win $_nWave4 {( "G1" 7 )} 
wvSelectSignal -win $_nWave4 {( "G1" 3 )} 
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvSetCursor -win $_nWave4 20184777.370378 -snap {("G1" 3)}
wvSetCursor -win $_nWave4 20184024.627300 -snap {("G1" 3)}
wvSetCursor -win $_nWave4 20191602.240951 -snap {("G1" 3)}
wvSetCursor -win $_nWave4 20207725.997680 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20149907.801865 -snap {("G1" 3)}
wvSetCursor -win $_nWave4 20386688.155310 -snap {("G1" 3)}
wvSetCursor -win $_nWave4 20389648.944750 -snap {("G1" 3)}
wvZoomOut -win $_nWave4
wvZoomIn -win $_nWave4
wvSetCursor -win $_nWave4 20397823.734576 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20400433.243913 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20404849.336637 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20412125.853056 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20409616.709463 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20412828.413263 -snap {("G1" 1)}
wvSetCursor -win $_nWave4 20405652.262586 -snap {("G1" 1)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 20124541.614711 -snap {("G1" 3)}
wvSetRadix -win $_nWave4 -format UDec {("G1" 3)}
wvSelectSignal -win $_nWave4 {( "G1" 2 )} 
wvSelectSignal -win $_nWave4 {( "G1" 3 )} 
wvSetRadix -win $_nWave4 -format Hex {("G1" 3)}
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 21124578.357722 -snap {("G1" 8)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSelectSignal -win $_nWave4 {( "G1" 28 )} 
wvSetCursor -win $_nWave4 6422436.292080 -snap {("G1" 28)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 19858391.621056 -snap {("G1" 23)}
wvSetCursor -win $_nWave4 19627149.066323 -snap {("G1" 23)}
wvSetCursor -win $_nWave4 17777208.628461 -snap {("G1" 26)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
