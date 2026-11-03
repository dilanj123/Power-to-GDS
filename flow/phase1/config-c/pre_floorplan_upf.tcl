puts "PTG_C_PRE_FLOORPLAN_UPF=ENTER"
# Bounded area attempt inside the frozen A core. A did not record resolved
# PD_SW coordinates; this is an experiment, not an accepted domain region.
set_domain_area PD_SW -area {1.840 5.440 262.200 258.400}
puts "PTG_C_PRE_FLOORPLAN_UPF=AREA_SET_TO_CORE_INTERIOR"
