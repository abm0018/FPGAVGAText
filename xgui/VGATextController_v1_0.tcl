# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CBITS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEBUGENABLE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HBACK_CC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HFRONT_CC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HRES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HSYNC_CC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "VRES" -parent ${Page_0}


}

proc update_PARAM_VALUE.CBITS { PARAM_VALUE.CBITS } {
	# Procedure called to update CBITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CBITS { PARAM_VALUE.CBITS } {
	# Procedure called to validate CBITS
	return true
}

proc update_PARAM_VALUE.DEBUGENABLE { PARAM_VALUE.DEBUGENABLE } {
	# Procedure called to update DEBUGENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEBUGENABLE { PARAM_VALUE.DEBUGENABLE } {
	# Procedure called to validate DEBUGENABLE
	return true
}

proc update_PARAM_VALUE.HBACK_CC { PARAM_VALUE.HBACK_CC } {
	# Procedure called to update HBACK_CC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HBACK_CC { PARAM_VALUE.HBACK_CC } {
	# Procedure called to validate HBACK_CC
	return true
}

proc update_PARAM_VALUE.HFRONT_CC { PARAM_VALUE.HFRONT_CC } {
	# Procedure called to update HFRONT_CC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HFRONT_CC { PARAM_VALUE.HFRONT_CC } {
	# Procedure called to validate HFRONT_CC
	return true
}

proc update_PARAM_VALUE.HRES { PARAM_VALUE.HRES } {
	# Procedure called to update HRES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HRES { PARAM_VALUE.HRES } {
	# Procedure called to validate HRES
	return true
}

proc update_PARAM_VALUE.HSYNC_CC { PARAM_VALUE.HSYNC_CC } {
	# Procedure called to update HSYNC_CC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HSYNC_CC { PARAM_VALUE.HSYNC_CC } {
	# Procedure called to validate HSYNC_CC
	return true
}

proc update_PARAM_VALUE.VRES { PARAM_VALUE.VRES } {
	# Procedure called to update VRES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VRES { PARAM_VALUE.VRES } {
	# Procedure called to validate VRES
	return true
}


proc update_MODELPARAM_VALUE.DEBUGENABLE { MODELPARAM_VALUE.DEBUGENABLE PARAM_VALUE.DEBUGENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEBUGENABLE}] ${MODELPARAM_VALUE.DEBUGENABLE}
}

proc update_MODELPARAM_VALUE.VRES { MODELPARAM_VALUE.VRES PARAM_VALUE.VRES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VRES}] ${MODELPARAM_VALUE.VRES}
}

proc update_MODELPARAM_VALUE.HRES { MODELPARAM_VALUE.HRES PARAM_VALUE.HRES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HRES}] ${MODELPARAM_VALUE.HRES}
}

proc update_MODELPARAM_VALUE.HBACK_CC { MODELPARAM_VALUE.HBACK_CC PARAM_VALUE.HBACK_CC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HBACK_CC}] ${MODELPARAM_VALUE.HBACK_CC}
}

proc update_MODELPARAM_VALUE.HFRONT_CC { MODELPARAM_VALUE.HFRONT_CC PARAM_VALUE.HFRONT_CC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HFRONT_CC}] ${MODELPARAM_VALUE.HFRONT_CC}
}

proc update_MODELPARAM_VALUE.HSYNC_CC { MODELPARAM_VALUE.HSYNC_CC PARAM_VALUE.HSYNC_CC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HSYNC_CC}] ${MODELPARAM_VALUE.HSYNC_CC}
}

proc update_MODELPARAM_VALUE.CBITS { MODELPARAM_VALUE.CBITS PARAM_VALUE.CBITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CBITS}] ${MODELPARAM_VALUE.CBITS}
}

