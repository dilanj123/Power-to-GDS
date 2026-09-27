export DESIGN_NICKNAME = ptg_upf_smoke
export DESIGN_NAME = ptg_upf_smoke
export PLATFORM = sky130hd

export VERILOG_FILES = /ptg/flow/phase0/upf-two-domain-smoke/ptg_sw_domain.v
export SDC_FILE = /ptg/flow/phase0/upf-two-domain-smoke/constraint.sdc

export CLOCK_PORT = clk_i
export CLOCK_PERIOD = 10.0

export POST_SYNTH_TCL = /ptg/flow/phase0/upf-two-domain-smoke/post_synth_upf.tcl

# Preserve hierarchy so PD_SW can reference u_sw.
export OPENROAD_HIERARCHICAL = 1

# Gate-0 smoke only; geometry is not under evaluation here.
export CORE_UTILIZATION = 40
