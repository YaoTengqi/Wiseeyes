# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ACC_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ARRAY_M" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ARRAY_N" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_BURST_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_ID_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BBUF_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BBUF_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BBUF_CAPACITY_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BBUF_WSTRB_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BIAS_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BUF_TYPE_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CTRL_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CTRL_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CTRL_WSTRB_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IBUF_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IBUF_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IBUF_CAPACITY_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IBUF_WSTRB_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IFIFO_ADDR_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INST_ADDR_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INST_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INST_BURST_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INST_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INST_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INST_WSTRB_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "LOOP_ID_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_TAGS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OBUF_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OBUF_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OBUF_CAPACITY_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OBUF_WSTRB_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OP_CODE_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OP_SPEC_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PU_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PU_WSTRB_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WBUF_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WBUF_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WBUF_CAPACITY_BITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WBUF_WSTRB_W" -parent ${Page_0}


}

proc update_PARAM_VALUE.ACC_WIDTH { PARAM_VALUE.ACC_WIDTH } {
	# Procedure called to update ACC_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACC_WIDTH { PARAM_VALUE.ACC_WIDTH } {
	# Procedure called to validate ACC_WIDTH
	return true
}

proc update_PARAM_VALUE.ARRAY_M { PARAM_VALUE.ARRAY_M } {
	# Procedure called to update ARRAY_M when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ARRAY_M { PARAM_VALUE.ARRAY_M } {
	# Procedure called to validate ARRAY_M
	return true
}

proc update_PARAM_VALUE.ARRAY_N { PARAM_VALUE.ARRAY_N } {
	# Procedure called to update ARRAY_N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ARRAY_N { PARAM_VALUE.ARRAY_N } {
	# Procedure called to validate ARRAY_N
	return true
}

proc update_PARAM_VALUE.AXI_ADDR_WIDTH { PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to update AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ADDR_WIDTH { PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to validate AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.AXI_BURST_WIDTH { PARAM_VALUE.AXI_BURST_WIDTH } {
	# Procedure called to update AXI_BURST_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_BURST_WIDTH { PARAM_VALUE.AXI_BURST_WIDTH } {
	# Procedure called to validate AXI_BURST_WIDTH
	return true
}

proc update_PARAM_VALUE.AXI_ID_WIDTH { PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to update AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ID_WIDTH { PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to validate AXI_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.BBUF_ADDR_WIDTH { PARAM_VALUE.BBUF_ADDR_WIDTH } {
	# Procedure called to update BBUF_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BBUF_ADDR_WIDTH { PARAM_VALUE.BBUF_ADDR_WIDTH } {
	# Procedure called to validate BBUF_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.BBUF_AXI_DATA_WIDTH { PARAM_VALUE.BBUF_AXI_DATA_WIDTH } {
	# Procedure called to update BBUF_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BBUF_AXI_DATA_WIDTH { PARAM_VALUE.BBUF_AXI_DATA_WIDTH } {
	# Procedure called to validate BBUF_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.BBUF_CAPACITY_BITS { PARAM_VALUE.BBUF_CAPACITY_BITS } {
	# Procedure called to update BBUF_CAPACITY_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BBUF_CAPACITY_BITS { PARAM_VALUE.BBUF_CAPACITY_BITS } {
	# Procedure called to validate BBUF_CAPACITY_BITS
	return true
}

proc update_PARAM_VALUE.BBUF_WSTRB_W { PARAM_VALUE.BBUF_WSTRB_W } {
	# Procedure called to update BBUF_WSTRB_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BBUF_WSTRB_W { PARAM_VALUE.BBUF_WSTRB_W } {
	# Procedure called to validate BBUF_WSTRB_W
	return true
}

proc update_PARAM_VALUE.BIAS_WIDTH { PARAM_VALUE.BIAS_WIDTH } {
	# Procedure called to update BIAS_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BIAS_WIDTH { PARAM_VALUE.BIAS_WIDTH } {
	# Procedure called to validate BIAS_WIDTH
	return true
}

proc update_PARAM_VALUE.BUF_TYPE_W { PARAM_VALUE.BUF_TYPE_W } {
	# Procedure called to update BUF_TYPE_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BUF_TYPE_W { PARAM_VALUE.BUF_TYPE_W } {
	# Procedure called to validate BUF_TYPE_W
	return true
}

proc update_PARAM_VALUE.CTRL_ADDR_WIDTH { PARAM_VALUE.CTRL_ADDR_WIDTH } {
	# Procedure called to update CTRL_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CTRL_ADDR_WIDTH { PARAM_VALUE.CTRL_ADDR_WIDTH } {
	# Procedure called to validate CTRL_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.CTRL_DATA_WIDTH { PARAM_VALUE.CTRL_DATA_WIDTH } {
	# Procedure called to update CTRL_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CTRL_DATA_WIDTH { PARAM_VALUE.CTRL_DATA_WIDTH } {
	# Procedure called to validate CTRL_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.CTRL_WSTRB_WIDTH { PARAM_VALUE.CTRL_WSTRB_WIDTH } {
	# Procedure called to update CTRL_WSTRB_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CTRL_WSTRB_WIDTH { PARAM_VALUE.CTRL_WSTRB_WIDTH } {
	# Procedure called to validate CTRL_WSTRB_WIDTH
	return true
}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.IBUF_ADDR_WIDTH { PARAM_VALUE.IBUF_ADDR_WIDTH } {
	# Procedure called to update IBUF_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IBUF_ADDR_WIDTH { PARAM_VALUE.IBUF_ADDR_WIDTH } {
	# Procedure called to validate IBUF_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.IBUF_AXI_DATA_WIDTH { PARAM_VALUE.IBUF_AXI_DATA_WIDTH } {
	# Procedure called to update IBUF_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IBUF_AXI_DATA_WIDTH { PARAM_VALUE.IBUF_AXI_DATA_WIDTH } {
	# Procedure called to validate IBUF_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.IBUF_CAPACITY_BITS { PARAM_VALUE.IBUF_CAPACITY_BITS } {
	# Procedure called to update IBUF_CAPACITY_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IBUF_CAPACITY_BITS { PARAM_VALUE.IBUF_CAPACITY_BITS } {
	# Procedure called to validate IBUF_CAPACITY_BITS
	return true
}

proc update_PARAM_VALUE.IBUF_WSTRB_W { PARAM_VALUE.IBUF_WSTRB_W } {
	# Procedure called to update IBUF_WSTRB_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IBUF_WSTRB_W { PARAM_VALUE.IBUF_WSTRB_W } {
	# Procedure called to validate IBUF_WSTRB_W
	return true
}

proc update_PARAM_VALUE.IFIFO_ADDR_W { PARAM_VALUE.IFIFO_ADDR_W } {
	# Procedure called to update IFIFO_ADDR_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IFIFO_ADDR_W { PARAM_VALUE.IFIFO_ADDR_W } {
	# Procedure called to validate IFIFO_ADDR_W
	return true
}

proc update_PARAM_VALUE.INST_ADDR_W { PARAM_VALUE.INST_ADDR_W } {
	# Procedure called to update INST_ADDR_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INST_ADDR_W { PARAM_VALUE.INST_ADDR_W } {
	# Procedure called to validate INST_ADDR_W
	return true
}

proc update_PARAM_VALUE.INST_ADDR_WIDTH { PARAM_VALUE.INST_ADDR_WIDTH } {
	# Procedure called to update INST_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INST_ADDR_WIDTH { PARAM_VALUE.INST_ADDR_WIDTH } {
	# Procedure called to validate INST_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.INST_BURST_WIDTH { PARAM_VALUE.INST_BURST_WIDTH } {
	# Procedure called to update INST_BURST_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INST_BURST_WIDTH { PARAM_VALUE.INST_BURST_WIDTH } {
	# Procedure called to validate INST_BURST_WIDTH
	return true
}

proc update_PARAM_VALUE.INST_DATA_WIDTH { PARAM_VALUE.INST_DATA_WIDTH } {
	# Procedure called to update INST_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INST_DATA_WIDTH { PARAM_VALUE.INST_DATA_WIDTH } {
	# Procedure called to validate INST_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.INST_W { PARAM_VALUE.INST_W } {
	# Procedure called to update INST_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INST_W { PARAM_VALUE.INST_W } {
	# Procedure called to validate INST_W
	return true
}

proc update_PARAM_VALUE.INST_WSTRB_WIDTH { PARAM_VALUE.INST_WSTRB_WIDTH } {
	# Procedure called to update INST_WSTRB_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INST_WSTRB_WIDTH { PARAM_VALUE.INST_WSTRB_WIDTH } {
	# Procedure called to validate INST_WSTRB_WIDTH
	return true
}

proc update_PARAM_VALUE.LOOP_ID_W { PARAM_VALUE.LOOP_ID_W } {
	# Procedure called to update LOOP_ID_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LOOP_ID_W { PARAM_VALUE.LOOP_ID_W } {
	# Procedure called to validate LOOP_ID_W
	return true
}

proc update_PARAM_VALUE.NUM_TAGS { PARAM_VALUE.NUM_TAGS } {
	# Procedure called to update NUM_TAGS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_TAGS { PARAM_VALUE.NUM_TAGS } {
	# Procedure called to validate NUM_TAGS
	return true
}

proc update_PARAM_VALUE.OBUF_ADDR_WIDTH { PARAM_VALUE.OBUF_ADDR_WIDTH } {
	# Procedure called to update OBUF_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OBUF_ADDR_WIDTH { PARAM_VALUE.OBUF_ADDR_WIDTH } {
	# Procedure called to validate OBUF_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.OBUF_AXI_DATA_WIDTH { PARAM_VALUE.OBUF_AXI_DATA_WIDTH } {
	# Procedure called to update OBUF_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OBUF_AXI_DATA_WIDTH { PARAM_VALUE.OBUF_AXI_DATA_WIDTH } {
	# Procedure called to validate OBUF_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.OBUF_CAPACITY_BITS { PARAM_VALUE.OBUF_CAPACITY_BITS } {
	# Procedure called to update OBUF_CAPACITY_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OBUF_CAPACITY_BITS { PARAM_VALUE.OBUF_CAPACITY_BITS } {
	# Procedure called to validate OBUF_CAPACITY_BITS
	return true
}

proc update_PARAM_VALUE.OBUF_WSTRB_W { PARAM_VALUE.OBUF_WSTRB_W } {
	# Procedure called to update OBUF_WSTRB_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OBUF_WSTRB_W { PARAM_VALUE.OBUF_WSTRB_W } {
	# Procedure called to validate OBUF_WSTRB_W
	return true
}

proc update_PARAM_VALUE.OP_CODE_W { PARAM_VALUE.OP_CODE_W } {
	# Procedure called to update OP_CODE_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OP_CODE_W { PARAM_VALUE.OP_CODE_W } {
	# Procedure called to validate OP_CODE_W
	return true
}

proc update_PARAM_VALUE.OP_SPEC_W { PARAM_VALUE.OP_SPEC_W } {
	# Procedure called to update OP_SPEC_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OP_SPEC_W { PARAM_VALUE.OP_SPEC_W } {
	# Procedure called to validate OP_SPEC_W
	return true
}

proc update_PARAM_VALUE.PU_AXI_DATA_WIDTH { PARAM_VALUE.PU_AXI_DATA_WIDTH } {
	# Procedure called to update PU_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PU_AXI_DATA_WIDTH { PARAM_VALUE.PU_AXI_DATA_WIDTH } {
	# Procedure called to validate PU_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.PU_WSTRB_W { PARAM_VALUE.PU_WSTRB_W } {
	# Procedure called to update PU_WSTRB_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PU_WSTRB_W { PARAM_VALUE.PU_WSTRB_W } {
	# Procedure called to validate PU_WSTRB_W
	return true
}

proc update_PARAM_VALUE.WBUF_ADDR_WIDTH { PARAM_VALUE.WBUF_ADDR_WIDTH } {
	# Procedure called to update WBUF_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WBUF_ADDR_WIDTH { PARAM_VALUE.WBUF_ADDR_WIDTH } {
	# Procedure called to validate WBUF_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.WBUF_AXI_DATA_WIDTH { PARAM_VALUE.WBUF_AXI_DATA_WIDTH } {
	# Procedure called to update WBUF_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WBUF_AXI_DATA_WIDTH { PARAM_VALUE.WBUF_AXI_DATA_WIDTH } {
	# Procedure called to validate WBUF_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.WBUF_CAPACITY_BITS { PARAM_VALUE.WBUF_CAPACITY_BITS } {
	# Procedure called to update WBUF_CAPACITY_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WBUF_CAPACITY_BITS { PARAM_VALUE.WBUF_CAPACITY_BITS } {
	# Procedure called to validate WBUF_CAPACITY_BITS
	return true
}

proc update_PARAM_VALUE.WBUF_WSTRB_W { PARAM_VALUE.WBUF_WSTRB_W } {
	# Procedure called to update WBUF_WSTRB_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WBUF_WSTRB_W { PARAM_VALUE.WBUF_WSTRB_W } {
	# Procedure called to validate WBUF_WSTRB_W
	return true
}


proc update_MODELPARAM_VALUE.INST_W { MODELPARAM_VALUE.INST_W PARAM_VALUE.INST_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INST_W}] ${MODELPARAM_VALUE.INST_W}
}

proc update_MODELPARAM_VALUE.INST_ADDR_W { MODELPARAM_VALUE.INST_ADDR_W PARAM_VALUE.INST_ADDR_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INST_ADDR_W}] ${MODELPARAM_VALUE.INST_ADDR_W}
}

proc update_MODELPARAM_VALUE.IFIFO_ADDR_W { MODELPARAM_VALUE.IFIFO_ADDR_W PARAM_VALUE.IFIFO_ADDR_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IFIFO_ADDR_W}] ${MODELPARAM_VALUE.IFIFO_ADDR_W}
}

proc update_MODELPARAM_VALUE.BUF_TYPE_W { MODELPARAM_VALUE.BUF_TYPE_W PARAM_VALUE.BUF_TYPE_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BUF_TYPE_W}] ${MODELPARAM_VALUE.BUF_TYPE_W}
}

proc update_MODELPARAM_VALUE.OP_CODE_W { MODELPARAM_VALUE.OP_CODE_W PARAM_VALUE.OP_CODE_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OP_CODE_W}] ${MODELPARAM_VALUE.OP_CODE_W}
}

proc update_MODELPARAM_VALUE.OP_SPEC_W { MODELPARAM_VALUE.OP_SPEC_W PARAM_VALUE.OP_SPEC_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OP_SPEC_W}] ${MODELPARAM_VALUE.OP_SPEC_W}
}

proc update_MODELPARAM_VALUE.LOOP_ID_W { MODELPARAM_VALUE.LOOP_ID_W PARAM_VALUE.LOOP_ID_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LOOP_ID_W}] ${MODELPARAM_VALUE.LOOP_ID_W}
}

proc update_MODELPARAM_VALUE.ARRAY_N { MODELPARAM_VALUE.ARRAY_N PARAM_VALUE.ARRAY_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ARRAY_N}] ${MODELPARAM_VALUE.ARRAY_N}
}

proc update_MODELPARAM_VALUE.ARRAY_M { MODELPARAM_VALUE.ARRAY_M PARAM_VALUE.ARRAY_M } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ARRAY_M}] ${MODELPARAM_VALUE.ARRAY_M}
}

proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.BIAS_WIDTH { MODELPARAM_VALUE.BIAS_WIDTH PARAM_VALUE.BIAS_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BIAS_WIDTH}] ${MODELPARAM_VALUE.BIAS_WIDTH}
}

proc update_MODELPARAM_VALUE.ACC_WIDTH { MODELPARAM_VALUE.ACC_WIDTH PARAM_VALUE.ACC_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACC_WIDTH}] ${MODELPARAM_VALUE.ACC_WIDTH}
}

proc update_MODELPARAM_VALUE.NUM_TAGS { MODELPARAM_VALUE.NUM_TAGS PARAM_VALUE.NUM_TAGS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_TAGS}] ${MODELPARAM_VALUE.NUM_TAGS}
}

proc update_MODELPARAM_VALUE.IBUF_CAPACITY_BITS { MODELPARAM_VALUE.IBUF_CAPACITY_BITS PARAM_VALUE.IBUF_CAPACITY_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IBUF_CAPACITY_BITS}] ${MODELPARAM_VALUE.IBUF_CAPACITY_BITS}
}

proc update_MODELPARAM_VALUE.WBUF_CAPACITY_BITS { MODELPARAM_VALUE.WBUF_CAPACITY_BITS PARAM_VALUE.WBUF_CAPACITY_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WBUF_CAPACITY_BITS}] ${MODELPARAM_VALUE.WBUF_CAPACITY_BITS}
}

proc update_MODELPARAM_VALUE.OBUF_CAPACITY_BITS { MODELPARAM_VALUE.OBUF_CAPACITY_BITS PARAM_VALUE.OBUF_CAPACITY_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OBUF_CAPACITY_BITS}] ${MODELPARAM_VALUE.OBUF_CAPACITY_BITS}
}

proc update_MODELPARAM_VALUE.BBUF_CAPACITY_BITS { MODELPARAM_VALUE.BBUF_CAPACITY_BITS PARAM_VALUE.BBUF_CAPACITY_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BBUF_CAPACITY_BITS}] ${MODELPARAM_VALUE.BBUF_CAPACITY_BITS}
}

proc update_MODELPARAM_VALUE.IBUF_ADDR_WIDTH { MODELPARAM_VALUE.IBUF_ADDR_WIDTH PARAM_VALUE.IBUF_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IBUF_ADDR_WIDTH}] ${MODELPARAM_VALUE.IBUF_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.WBUF_ADDR_WIDTH { MODELPARAM_VALUE.WBUF_ADDR_WIDTH PARAM_VALUE.WBUF_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WBUF_ADDR_WIDTH}] ${MODELPARAM_VALUE.WBUF_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.OBUF_ADDR_WIDTH { MODELPARAM_VALUE.OBUF_ADDR_WIDTH PARAM_VALUE.OBUF_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OBUF_ADDR_WIDTH}] ${MODELPARAM_VALUE.OBUF_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.BBUF_ADDR_WIDTH { MODELPARAM_VALUE.BBUF_ADDR_WIDTH PARAM_VALUE.BBUF_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BBUF_ADDR_WIDTH}] ${MODELPARAM_VALUE.BBUF_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.AXI_ADDR_WIDTH { MODELPARAM_VALUE.AXI_ADDR_WIDTH PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.AXI_BURST_WIDTH { MODELPARAM_VALUE.AXI_BURST_WIDTH PARAM_VALUE.AXI_BURST_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_BURST_WIDTH}] ${MODELPARAM_VALUE.AXI_BURST_WIDTH}
}

proc update_MODELPARAM_VALUE.IBUF_AXI_DATA_WIDTH { MODELPARAM_VALUE.IBUF_AXI_DATA_WIDTH PARAM_VALUE.IBUF_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IBUF_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.IBUF_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.IBUF_WSTRB_W { MODELPARAM_VALUE.IBUF_WSTRB_W PARAM_VALUE.IBUF_WSTRB_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IBUF_WSTRB_W}] ${MODELPARAM_VALUE.IBUF_WSTRB_W}
}

proc update_MODELPARAM_VALUE.OBUF_AXI_DATA_WIDTH { MODELPARAM_VALUE.OBUF_AXI_DATA_WIDTH PARAM_VALUE.OBUF_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OBUF_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.OBUF_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.OBUF_WSTRB_W { MODELPARAM_VALUE.OBUF_WSTRB_W PARAM_VALUE.OBUF_WSTRB_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OBUF_WSTRB_W}] ${MODELPARAM_VALUE.OBUF_WSTRB_W}
}

proc update_MODELPARAM_VALUE.PU_AXI_DATA_WIDTH { MODELPARAM_VALUE.PU_AXI_DATA_WIDTH PARAM_VALUE.PU_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PU_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.PU_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.PU_WSTRB_W { MODELPARAM_VALUE.PU_WSTRB_W PARAM_VALUE.PU_WSTRB_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PU_WSTRB_W}] ${MODELPARAM_VALUE.PU_WSTRB_W}
}

proc update_MODELPARAM_VALUE.WBUF_AXI_DATA_WIDTH { MODELPARAM_VALUE.WBUF_AXI_DATA_WIDTH PARAM_VALUE.WBUF_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WBUF_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.WBUF_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.WBUF_WSTRB_W { MODELPARAM_VALUE.WBUF_WSTRB_W PARAM_VALUE.WBUF_WSTRB_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WBUF_WSTRB_W}] ${MODELPARAM_VALUE.WBUF_WSTRB_W}
}

proc update_MODELPARAM_VALUE.BBUF_AXI_DATA_WIDTH { MODELPARAM_VALUE.BBUF_AXI_DATA_WIDTH PARAM_VALUE.BBUF_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BBUF_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.BBUF_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.BBUF_WSTRB_W { MODELPARAM_VALUE.BBUF_WSTRB_W PARAM_VALUE.BBUF_WSTRB_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BBUF_WSTRB_W}] ${MODELPARAM_VALUE.BBUF_WSTRB_W}
}

proc update_MODELPARAM_VALUE.AXI_ID_WIDTH { MODELPARAM_VALUE.AXI_ID_WIDTH PARAM_VALUE.AXI_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_ID_WIDTH}] ${MODELPARAM_VALUE.AXI_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.INST_ADDR_WIDTH { MODELPARAM_VALUE.INST_ADDR_WIDTH PARAM_VALUE.INST_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INST_ADDR_WIDTH}] ${MODELPARAM_VALUE.INST_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.INST_DATA_WIDTH { MODELPARAM_VALUE.INST_DATA_WIDTH PARAM_VALUE.INST_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INST_DATA_WIDTH}] ${MODELPARAM_VALUE.INST_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.INST_WSTRB_WIDTH { MODELPARAM_VALUE.INST_WSTRB_WIDTH PARAM_VALUE.INST_WSTRB_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INST_WSTRB_WIDTH}] ${MODELPARAM_VALUE.INST_WSTRB_WIDTH}
}

proc update_MODELPARAM_VALUE.INST_BURST_WIDTH { MODELPARAM_VALUE.INST_BURST_WIDTH PARAM_VALUE.INST_BURST_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INST_BURST_WIDTH}] ${MODELPARAM_VALUE.INST_BURST_WIDTH}
}

proc update_MODELPARAM_VALUE.CTRL_ADDR_WIDTH { MODELPARAM_VALUE.CTRL_ADDR_WIDTH PARAM_VALUE.CTRL_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CTRL_ADDR_WIDTH}] ${MODELPARAM_VALUE.CTRL_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.CTRL_DATA_WIDTH { MODELPARAM_VALUE.CTRL_DATA_WIDTH PARAM_VALUE.CTRL_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CTRL_DATA_WIDTH}] ${MODELPARAM_VALUE.CTRL_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.CTRL_WSTRB_WIDTH { MODELPARAM_VALUE.CTRL_WSTRB_WIDTH PARAM_VALUE.CTRL_WSTRB_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CTRL_WSTRB_WIDTH}] ${MODELPARAM_VALUE.CTRL_WSTRB_WIDTH}
}

