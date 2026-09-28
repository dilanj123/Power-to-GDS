puts "PTG_DFT_POST_SYNTH=ENTER"
set_dft_config -max_length 8 -clock_mixing no_mix
report_dft_config
scan_replace
puts "PTG_DFT_SCAN_REPLACE=APPLIED"
