# NΞBKISŌ FPGA Simulation Guide

## Directory Structure Setup
First, ensure your directory structure is organized as follows:
```
fpga/
├── sim/
│   ├── run_sim.tcl
│   ├── regression_test.py
│   └── wave_*.do
├── src/
│   ├── hdl/
│   │   ├── core/
│   │   ├── olfactory/
│   │   ├── safety/
│   │   └── sensors/
│   └── testbench/
└── work/           # Will be created by simulator
```

## Running Simulations

### Method 1: Using TCL Script
1. Open ModelSim/QuestaSim terminal
2. Navigate to the simulation directory:
```tcl
cd path/to/fpga/sim
```

3. Run the simulation:
```tcl
vsim -do run_sim.tcl
```

### Method 2: Using Python Regression Script
1. Open terminal
2. Navigate to simulation directory:
```bash
cd path/to/fpga/sim
```

3. Run regression tests:
```bash
python3 regression_test.py
```

### Method 3: Manual Steps
1. Start ModelSim/QuestaSim
2. Create working library:
```tcl
vlib work
vmap work work
```

3. Compile packages first:
```tcl
vcom -2008 -work work ../src/hdl/core/nebkiso_pkg.vhd
vcom -2008 -work work ../src/hdl/core/nebkiso_types.vhd
vcom -2008 -work work ../src/hdl/olfactory/nebkiso_olfactory_pkg.vhd
```

4. Compile design files:
```tcl
vcom -2008 -work work ../src/hdl/olfactory/environment_controller.vhd
vcom -2008 -work work ../src/hdl/olfactory/cartridge_controller.vhd
vcom -2008 -work work ../src/hdl/olfactory/mixing_chamber_controller.vhd
vcom -2008 -work work ../src/hdl/olfactory/sequence_controller.vhd
vcom -2008 -work work ../src/hdl/olfactory/spatial_controller.vhd
vcom -2008 -work work ../src/hdl/olfactory/olfactory_sequencer_top.vhd
```

5. Compile testbenches:
```tcl
vcom -2008 -work work ../src/testbench/environment_controller_tb.vhd
```

6. Start simulation:
```tcl
vsim -voptargs=+acc work.environment_controller_tb
```

7. Load wave configuration:
```tcl
do wave_environment_controller_tb.do
```

8. Run simulation:
```tcl
run -all
```

## Useful TCL Commands During Simulation

```tcl
# Run for specific time
run 1us

# Run until next breakpoint
run -continue

# Add signals to wave window
add wave -radix hexadecimal /environment_controller_tb/DUT/*

# Restart simulation
restart -f

# Quit simulation
quit -sim

# Force signal value
force -freeze /environment_controller_tb/temperature x"400" 0

# Show current simulation time
show time
```

## Visual Wave Analysis
1. After simulation starts, click "Wave" window
2. Right-click signals to change display format
3. Use zoom buttons to examine waveforms
4. Use cursors to measure time differences

## Common Wave Formats
- Logic: Digital signals
- Decimal: Integer values
- Hexadecimal: Bit vectors
- Analog: Analog-like display for DAC/ADC signals

## Debug Tips
1. Use `assert` statements in VHDL for automatic checking
2. Add breakpoints on critical signals
3. Use ModelSim/QuestaSim's dataflow window for signal tracing
4. Check the transcript window for error messages