export DESIGN_NICKNAME = config_b
export DESIGN_NAME = config_b_top
export PLATFORM = sky130hd

export VERILOG_FILES = $(sort $(wildcard /ptg/rtl/imported/from-rtl-to-pixels-ad35514/*.sv)) \
	/ptg/flow/phase1/config-b/config_b_top.sv
export SDC_FILE = /ptg/constraints/config-b-mission.sdc

export CLOCK_PORT = clk
export CLOCK_PERIOD = 10.30

# Configuration A's measured geometry is held fixed for all primary variants.
export DIE_AREA = 0 0 263.770 263.770
export CORE_AREA = 1.380 2.720 262.660 261.120
# A used 50% CORE_UTILIZATION only to derive its now-frozen explicit geometry.
# Pinned ORFS treats utilization and explicit die/core areas as exclusive
# floorplan initialization methods; B therefore fixes the geometry directly.
export PLACE_DENSITY_LB_ADDON = 0.25
export PLACE_DENSITY = 0.60
export SYNTH_HDL_FRONTEND = slang

# Select the pinned platform's qualified OPENROAD_CLKGATE implementation.
export VERILOG_DEFINES += -D OPENROAD_CLKGATE
