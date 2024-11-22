# Temperature and Power Constraints
set_operating_conditions -grade industrial
set_max_operating_temperature 85.0
set_max_fanout 20 [get_nets *]

# Power optimization
set_power_opt -clocks true
set_power_opt -exclusive_sets true
set_switching_activity -toggle_rate 10.0 [get_nets -hierarchical *clk*]
set_switching_activity -toggle_rate 2.0 [get_nets -hierarchical *]

# Area Constraints
create_pblock safety_zone
add_cells_to_pblock [get_pblocks safety_zone] [get_cells -hierarchical *safety_monitor*]
add_cells_to_pblock [get_pblocks safety_zone] [get_cells -hierarchical *emergency*]
resize_pblock [get_pblocks safety_zone] -add {SLICE_X0Y0:SLICE_X20Y50}

# Configuration and Programming
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

# DRC Constraints
set_property SEVERITY {Warning} [get_drc_checks TIMING-*]
set_property SEVERITY {Error} [get_drc_checks NSTD-*]
