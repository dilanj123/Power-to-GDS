current_design config_a_top

set clk_period 10.30
set io_delay 2.06
set io_latency 1.095

create_clock -name core_clock -period $clk_period [get_ports clk]
create_clock -name vclk_core_clock -period $clk_period
set_clock_latency $io_latency [get_clocks core_clock]
set_clock_latency $io_latency [get_clocks vclk_core_clock]

# The same frozen 20%-of-10.30-ns I/O budget is mapped to all non-clock
# inputs and all outputs. Reset and APB/stream ports remain timed. No exceptions.
set non_clock_inputs [all_inputs -no_clocks]
set_input_delay $io_delay -clock vclk_core_clock $non_clock_inputs
set_output_delay $io_delay -clock vclk_core_clock [all_outputs]
