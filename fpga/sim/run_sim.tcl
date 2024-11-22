# Updated simulation run script for NΞBKISŌ FPGA verification

# Set simulation time units
set_units -time ns

# Create simulation libraries
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compile procedure for olfactory system
proc compile_olfactory {} {
    puts "Compiling olfactory system files..."
    
    # Compile package first
    vcom -2008 -work work ../src/hdl/olfactory/nebkiso_olfactory_pkg.vhd
    
    # Compile design files
    vcom -2008 -work work ../src/hdl/olfactory/environment_controller.vhd
    vcom -2008 -work work ../src/hdl/olfactory/cartridge_controller.vhd
    vcom -2008 -work work ../src/hdl/olfactory/mixing_chamber_controller.vhd
    vcom -2008 -work work ../src/hdl/olfactory/sequence_controller.vhd
    vcom -2008 -work work ../src/hdl/olfactory/spatial_controller.vhd
    vcom -2008 -work work ../src/hdl/olfactory/olfactory_sequencer_top.vhd
}

# Compile all design files
proc compile_design {} {
    puts "Compiling core packages..."
    # Packages first
    vcom -2008 -work work ../src/hdl/core/nebkiso_pkg.vhd
    vcom -2008 -work work ../src/hdl/core/nebkiso_types.vhd
    
    puts "Compiling core components..."
    # Core components
    vcom -2008 -work work ../src/hdl/core/clock_manager.vhd
    
    puts "Compiling interfaces..."
    # Interfaces
    vcom -2008 -work work ../src/hdl/interfaces/spi_peripheral.vhd
    vcom -2008 -work work ../src/hdl/interfaces/i2c_controller.vhd
    vcom -2008 -work work ../src/hdl/interfaces/uart_controller.vhd
    
    puts "Compiling safety components..."
    # Safety components
    vcom -2008 -work work ../src/hdl/safety/safety_monitor.vhd
    vcom -2008 -work work ../src/hdl/safety/ventilation_controller.vhd
    
    puts "Compiling sensor components..."
    # Sensor components
    vcom -2008 -work work ../src/hdl/sensors/sensor_hub.vhd
    vcom -2008 -work work ../src/hdl/sensors/flow_sensor_interface.vhd
    
    # Compile olfactory system
    compile_olfactory
}

# Compile testbench files
proc compile_testbench {} {
    puts "Compiling testbench files..."
    vcom -2008 -work work ../src/testbench/nebkiso_tb_pkg.vhd
    vcom -2008 -work work ../src/testbench/environment_controller_tb.vhd
    vcom -2008 -work work ../src/testbench/olfactory_sequencer_tb.vhd
}

# Run specific testbench
proc run_test {testbench_name} {
    puts "Running testbench: $testbench_name"
    vsim -t 1ns -voptargs=+acc work.${testbench_name}
    
    # Load wave format if exists
    if {[file exists "wave_${testbench_name}.do"]} {
        do wave_${testbench_name}.do
    } else {
        # Add basic waves
        add wave -noupdate -divider {System Signals}
        add wave -noupdate /*/clk
        add wave -noupdate /*/rst
        add wave -noupdate -divider {Test Signals}
        add wave -noupdate /*
    }
    
    # Run simulation
    run 1 ms
    
    # Generate coverage report
    coverage report -details -file reports/${testbench_name}_coverage.rpt
}

# Create results directory
file mkdir reports

# Main simulation flow
puts "Starting NΞBKISŌ simulation..."
compile_design
compile_testbench

# Run environment controller test
run_test environment_controller_tb

puts "Simulation complete. Check the Wave window for results."