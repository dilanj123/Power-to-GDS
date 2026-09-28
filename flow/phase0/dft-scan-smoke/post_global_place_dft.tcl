puts "PTG_DFT_POST_GLOBAL_PLACE=ENTER"
report_dft_config
report_dft_plan -verbose
puts "PTG_DFT_PLAN_REPORTED=PASS"
execute_dft_plan
puts "PTG_DFT_EXECUTE_PLAN=APPLIED"
