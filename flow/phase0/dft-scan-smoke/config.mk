export DESIGN_NICKNAME = ptg_dft_scan_smoke
export DESIGN_NAME = ptg_dft_scan_smoke
export PLATFORM = sky130hd

export VERILOG_FILES = /ptg/flow/phase0/dft-scan-smoke/ptg_dft_scan_smoke.v
export SDC_FILE = /ptg/flow/phase0/dft-scan-smoke/constraint.sdc

export CLOCK_PORT = clk
export CLOCK_PERIOD = 10.0

export POST_SYNTH_TCL = /ptg/flow/phase0/dft-scan-smoke/post_synth_dft.tcl
export POST_GLOBAL_PLACE_TCL = /ptg/flow/phase0/dft-scan-smoke/post_global_place_dft.tcl

# Fixed small geometry for this isolated capability smoke.
export DIE_AREA = 0 0 120 120
export CORE_AREA = 10 10 110 110
