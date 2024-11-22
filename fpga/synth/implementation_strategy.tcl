# Implementation strategy for NΞBKISØ

# Global optimization settings
set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE ExtraTimingOpt [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE HigherDelayCost [get_runs impl_1]

# Safety-critical path optimization
create_pblock safety_logic
add_cells_to_pblock [get_pblocks safety_logic] [get_cells -hierarchical *safety_monitor*]
add_cells_to_pblock [get_pblocks safety_logic] [get_cells -hierarchical *ventilation_controller*]
set_property CONTAIN_ROUTING true [get_pblocks safety_logic]
set_property HD.PARTITION 1 [get_pblocks safety_logic]

# Clock optimization
create_clock_region_constraints
set_clock_uncertainty 0.1 [get_clocks]
set_max_delay -datapath_only 5 -from [get_cells -hierarchical *safety*] -to [get_cells -hierarchical *emergency*]

# Power optimization
set_power_opt -exclude_cells [get_cells -hierarchical *safety*]
set_switching_activity -toggle_rate 10.0 -static_probability 0.5 -type register
set_switching_activity -toggle_rate 2.0 -static_probability 0.1 -type lut
