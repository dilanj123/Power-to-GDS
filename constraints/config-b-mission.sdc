current_design config_b_top

set clk_period 10.30
set io_delay 2.06
set io_latency 1.095

create_clock -name core_clock -period $clk_period [get_ports clk]
create_clock -name vclk_core_clock -period $clk_period
set_clock_latency $io_latency [get_clocks core_clock]
set_clock_latency $io_latency [get_clocks vclk_core_clock]

# The functional registers use the ICG output as a divide-by-one generated
# clock. The source and mission timing relationship are the ungated AON clock.
create_generated_clock -name func_clock -source [get_ports clk] \
    -divide_by 1 [get_nets func_clk]

# Preserve A's absolute I/O budgets and constrain the B control interface too.
set non_clock_inputs [all_inputs -no_clocks]
set_input_delay $io_delay -clock vclk_core_clock $non_clock_inputs
set_output_delay $io_delay -clock vclk_core_clock [all_outputs]
