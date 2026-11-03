export DESIGN_NICKNAME = config_c
export DESIGN_NAME = config_c_top
export PLATFORM = sky130hd

export VERILOG_FILES = $(sort $(wildcard /ptg/rtl/imported/from-rtl-to-pixels-ad35514/*.sv)) \
	/ptg/flow/phase1/config-c/config_c_pmu.sv \
	/ptg/flow/phase1/config-c/config_c_top.sv
export SDC_FILE = /ptg/constraints/config-c-mission.sdc

export CLOCK_PORT = clk
export CLOCK_PERIOD = 10.30
export DIE_AREA = 0 0 263.770 263.770
export CORE_AREA = 1.380 2.720 262.660 261.120
export PLACE_DENSITY_LB_ADDON = 0.25
export PLACE_DENSITY = 0.60
export SYNTH_HDL_FRONTEND = slang
export VERILOG_DEFINES += -D OPENROAD_CLKGATE
export OPENROAD_HIERARCHICAL = 1
export POST_SYNTH_TCL = /ptg/flow/phase1/config-c/post_synth_upf.tcl
export PRE_FLOORPLAN_TCL = /ptg/flow/phase1/config-c/pre_floorplan_upf.tcl
