export DESIGN_NICKNAME = config_a
export DESIGN_NAME = config_a_top
export PLATFORM = sky130hd

export VERILOG_FILES = $(sort $(wildcard /ptg/rtl/imported/from-rtl-to-pixels-ad35514/*.sv)) \
    /ptg/flow/phase1/config-a_top.sv
export SDC_FILE = /ptg/constraints/config-a-mission.sdc

export CLOCK_PORT = clk
export CLOCK_PERIOD = 10.30

# Hold the project's frozen conventional floorplan policy. A's resolved
# geometry is recorded and frozen only after the actual floorplan is generated.
export CORE_UTILIZATION = 50
export PLACE_DENSITY_LB_ADDON = 0.25
export SYNTH_HDL_FRONTEND = slang
