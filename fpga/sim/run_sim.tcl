# fpga/sim/run_sim.tcl
# Simulation run script for NΞBKISØ FPGA verification

# Set simulation time units
set_units -time ns

# Create simulation libraries
create_lib work
create_lib nebkiso_lib

# Compile all design files
proc compile_design {} {
    # Packages first
    vcom -work nebkiso_lib ../src/hdl/core/nebkiso_pkg.vhd
    vcom -work nebkiso_lib ../src/hdl/core/nebkiso_types.vhd
    
    # Core components
    vcom -work work ../src/hdl/core/clock_manager.vhd
    
    # Interfaces
    vcom -work work ../src/hdl/interfaces/spi_peripheral.vhd
    vcom -work work ../src/hdl/interfaces/i2c_controller.vhd
    vcom -work work ../src/hdl/interfaces/uart_controller.vhd
    
    # Safety components
    vcom -work work ../src/hdl/safety/safety_monitor.vhd
    vcom -work work ../src/hdl/safety/ventilation_controller.vhd
    
    # Sensor components
    vcom -work work ../src/hdl/sensors/sensor_hub.vhd
    vcom -work work ../src/hdl/sensors/flow_sensor_interface.vhd
}

# Compile testbench files
proc compile_testbench {} {
    vcom -work work ../src/testbench/nebkiso_tb_pkg.vhd
    vcom -work work ../src/testbench/safety_monitor_tb.vhd
    vcom -work work ../src/testbench/sensor_hub_tb.vhd
}

# Run specific testbench
proc run_test {testbench_name} {
    vsim -t 1ns -novopt work.${testbench_name}
    
    # Load wave format
    do wave_${testbench_name}.do
    
    # Run simulation
    run 1 ms
    
    # Generate coverage report
    coverage report -details -file reports/${testbench_name}_coverage.rpt
}

# Main simulation flow
compile_design
compile_testbench

# Run all tests
foreach testbench {safety_monitor_tb sensor_hub_tb} {
    run_test $testbench
}
