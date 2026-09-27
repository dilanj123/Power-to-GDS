export DESIGN_NICKNAME = ptg_upf_floorplan_smoke
export DESIGN_NAME = ptg_upf_floorplan_smoke
export PLATFORM = sky130hd

export VERILOG_FILES = /ptg/flow/phase0/upf-two-domain-floorplan-smoke/ptg_upf_floorplan_smoke.v
export SDC_FILE = /ptg/flow/phase0/upf-two-domain-floorplan-smoke/constraint.sdc

export CLOCK_PORT = clk_i
export CLOCK_PERIOD = 10.0

export POST_SYNTH_TCL = /ptg/flow/phase0/upf-two-domain-floorplan-smoke/post_synth_upf.tcl
export PRE_FLOORPLAN_TCL = /ptg/flow/phase0/upf-two-domain-floorplan-smoke/pre_floorplan_upf.tcl

export OPENROAD_HIERARCHICAL = 1

# Fixed geometry only for this Gate-0 qualification smoke.
export DIE_AREA = 0 0 100 100
export CORE_AREA = 10 10 90 90
