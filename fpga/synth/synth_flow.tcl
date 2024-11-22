# fpga/synth/synth_flow.tcl
# NΞBKISØ FPGA Synthesis Flow

# Set part and design parameters
set_param general.maxThreads 8
set_part xc7z020clg484-1

# Create synthesis project
create_project nebkiso_synth ./nebkiso_synth -force

# Set synthesis settings
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.KEEP_EQUIVALENT_REGISTERS true [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FSM_EXTRACTION one_hot [get_runs synth_1]

# Add source files
add_files ../src/hdl/core/nebkiso_pkg.vhd
add_files ../src/hdl/core/nebkiso_types.vhd
add_files ../src/hdl/core/clock_manager.vhd
add_files ../src/hdl/interfaces/spi_peripheral.vhd
add_files ../src/hdl/interfaces/i2c_controller.vhd
add_files ../src/hdl/safety/safety_monitor.vhd
add_files ../src/hdl/safety/ventilation_controller.vhd
add_files ../src/hdl/sensors/sensor_hub.vhd
add_files ../src/hdl/sensors/flow_sensor_interface.vhd

# Add constraints
add_files -fileset constrs_1 ../src/constraints/timing.xdc
add_files -fileset constrs_1 ../src/constraints/pinout.xdc
add_files -fileset constrs_1 ../src/constraints/physical.xdc

# Set top level
set_property top nebkiso_top [current_fileset]
update_compile_order -fileset sources_1

# Define implementation strategy
source implementation_strategy.tcl

# Run synthesis
launch_runs synth_1
wait_on_run synth_1

# Check timing and generate reports
open_run synth_1
report_timing_summary -file reports/post_synth_timing.rpt
report_utilization -file reports/post_synth_utilization.rpt
report_power -file reports/post_synth_power.rpt

