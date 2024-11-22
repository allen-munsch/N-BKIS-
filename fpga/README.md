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

# FPGA Development Environment Setup for Ubuntu

## Option 1: GHDL + GTKWave (Open Source)
```bash
# Update package list
sudo apt update

# Install GHDL
sudo apt install ghdl

# Install GTKWave
sudo apt install gtkwave

# Install build tools
sudo apt install build-essential

# Verify installations
ghdl --version
gtkwave --version
```

## Option 2: Intel Questa/ModelSim (Free Version)
1. Visit Intel's website and download "Intel Questa Intel FPGA Edition - Starter Edition"
2. Install required 32-bit libraries:
```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install libc6:i386 libncurses5:i386 libstdc++6:i386 libxext6:i386 libxft2:i386 libxml2:i386 libzmq3-dev:i386 libsm6:i386
```

3. Install additional dependencies:
```bash
sudo apt install make gcc graphviz xsltproc freeglut3
```

## Option 3: Open-Source Complete Toolchain
```bash
# Install Yosys (synthesis)
sudo apt install yosys

# Install nextpnr (place and route)
sudo apt install nextpnr

# Install Project Trellis (for Lattice ECP5 FPGAs)
sudo apt install prjtrellis

# Install Project IceStorm (for Lattice iCE40 FPGAs)
sudo apt install icestorm
```

## Recommended Additional Tools
```bash
# Install Visual Studio Code
sudo apt install code

# Install Git
sudo apt install git

# Install Python tools
sudo apt install python3-pip
pip3 install cocotb pytest

# Install waveform viewer
sudo apt install gtkwave
```

## VSCode Extensions
1. Open VSCode
2. Install these extensions:
   - VHDL (by Pedro Henrique)
   - Tcl (by bitwisecook)
   - GitLens
   - Better Comments
   - Error Lens

## Project Setup with GHDL
1. Create a Makefile in your project root:

```makefile
# GHDL configuration
GHDL=ghdl
GHDLFLAGS=--ieee=synopsys --std=08
STOP_TIME=1ms

# Source files
VHDL_FILES = \
    src/hdl/core/nebkiso_pkg.vhd \
    src/hdl/core/nebkiso_types.vhd \
    src/hdl/olfactory/nebkiso_olfactory_pkg.vhd \
    src/hdl/olfactory/environment_controller.vhd \
    src/testbench/environment_controller_tb.vhd

# Work library
WORK_DIR=work
WORK_LIB=$(WORK_DIR)/work-obj08.cf

all: run

# Create work directory
$(WORK_DIR):
	mkdir -p $(WORK_DIR)

# Analyze VHDL files
analyze: $(WORK_DIR)
	$(GHDL) -i $(GHDLFLAGS) --workdir=$(WORK_DIR) $(VHDL_FILES)
	$(GHDL) -m $(GHDLFLAGS) --workdir=$(WORK_DIR) environment_controller_tb

# Run simulation
run: analyze
	$(GHDL) -r $(GHDLFLAGS) --workdir=$(WORK_DIR) environment_controller_tb \
		--vcd=$(WORK_DIR)/wave.vcd --stop-time=$(STOP_TIME)
	gtkwave $(WORK_DIR)/wave.vcd wave_config.gtkw

# Clean build files
clean:
	rm -rf $(WORK_DIR)

.PHONY: all analyze run clean
```

2. Create a basic GTKWave save file (wave_config.gtkw):

```tcl
[*]
[*] GTKWave Analyzer v3.3.100
[*]
[dumpfile] "work/wave.vcd"
[dumpfile_mtime] "Wed Nov  1 12:00:00 2023"
[dumpfile_size] 1000000
[timestart] 0
[size] 1600 900
[pos] -1 -1
*-16.000000 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
[treeopen] environment_controller_tb.
[sst_width] 200
[signals_width] 150
[sst_expanded] 1
[sst_vpaned_height] 300
@28
environment_controller_tb.clk
environment_controller_tb.rst
@22
environment_controller_tb.temperature[11:0]
environment_controller_tb.humidity[7:0]
environment_controller_tb.pressure[11:0]
@28
environment_controller_tb.temp_stable
environment_controller_tb.humidity_stable
environment_controller_tb.pressure_stable
environment_controller_tb.env_error
[pattern_trace] 1
[pattern_trace] 0
```

## Running Simulation
1. With GHDL:
```bash
# From project root
make clean
make run
```

2. With Questa/ModelSim:
```bash
# From fpga/sim directory
vsim -do run_sim.tcl
```

## Troubleshooting
If you encounter:
1. "libfreetype.so.6: cannot open shared object file":
```bash
sudo apt install libfreetype6:i386
```

2. "error while loading shared libraries: libXft.so.2":
```bash
sudo apt install libxft2:i386
```

3. Display issues with Questa/ModelSim:
```bash
export QTWEBENGINE_DISABLE_SANDBOX=1
```

Add to ~/.bashrc:
```bash
# FPGA development environment
export PATH=$PATH:/path/to/questa/bin
export LM_LICENSE_FILE=/path/to/license.dat
export MGLS_LICENSE_FILE=/path/to/license.dat
```