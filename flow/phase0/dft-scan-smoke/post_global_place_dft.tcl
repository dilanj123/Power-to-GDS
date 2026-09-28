puts "PTG_DFT_POST_GLOBAL_PLACE=ENTER"
report_dft_config
report_dft_plan -verbose
puts "PTG_DFT_PLAN_REPORTED=PASS"
execute_dft_plan
puts "PTG_DFT_EXECUTE_PLAN=APPLIED"
puts "PTG_DFT_SCAN_PORT_PLACEMENT=ENTER"
log_cmd place_pins \
  -hor_layers $::env(IO_PLACER_H) \
  -ver_layers $::env(IO_PLACER_V) \
  {*}[env_var_or_empty PLACE_PINS_ARGS]
puts "PTG_DFT_SCAN_PORT_PLACEMENT=APPLIED"
