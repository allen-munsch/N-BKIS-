# GHDL configuration
GHDL=ghdl
GHDLFLAGS=--std=08
WORKDIR=work
VCD_FILE=wave.vcd

# Simulation configuration
STOP_TIME=2ms
SAFETY_VCD=safety_monitor.vcd
SENSOR_VCD=sensor_hub.vcd

# Source directories
CORE_DIR=../src/hdl/core
SAFETY_DIR=../src/hdl/safety
SENSORS_DIR=../src/hdl/sensors
INTERFACES_DIR=../src/hdl/interfaces
OLFACTORY_DIR=../src/hdl/olfactory
TB_DIR=../src/testbench

# Package files
PACKAGES = \
$(CORE_DIR)/nebkiso_pkg.vhd \
$(CORE_DIR)/nebkiso_types.vhd \
$(OLFACTORY_DIR)/nebkiso_olfactory_pkg.vhd

# Core files
CORE_FILES = \
$(CORE_DIR)/clock_manager.vhd \
$(SAFETY_DIR)/safety_monitor.vhd \
$(CORE_DIR)/nebkiso_top.vhd

# Interface files
INTERFACE_FILES = \
$(INTERFACES_DIR)/spi_peripheral.vhd \
$(INTERFACES_DIR)/i2c_controller.vhd \
$(INTERFACES_DIR)/uart_controller.vhd

# Safety files
SAFETY_FILES = \
$(SAFETY_DIR)/safety_monitor.vhd \
$(SAFETY_DIR)/ventilation_controller.vhd

# Sensor files
SENSOR_FILES = \
$(SENSORS_DIR)/flow_sensor_interface.vhd \
$(SENSORS_DIR)/sensor_hub.vhd

# Olfactory files
OLFACTORY_FILES = \
$(OLFACTORY_DIR)/environment_controller.vhd \
$(OLFACTORY_DIR)/spatial_controller.vhd \
$(OLFACTORY_DIR)/sequence_controller.vhd \
$(OLFACTORY_DIR)/mixing_chamber_controller.vhd \
$(OLFACTORY_DIR)/cartridge_controller.vhd \
$(OLFACTORY_DIR)/olfactory_sequencer_top.vhd

# All source files
SOURCES = $(PACKAGES) $(CORE_FILES) $(INTERFACE_FILES) $(SAFETY_FILES) $(SENSOR_FILES) $(OLFACTORY_FILES)

# Testbench files
TESTBENCH_FILES = \
$(TB_DIR)/nebkiso_tb_pkg.vhd \
$(TB_DIR)/safety_monitor_tb.vhd \
$(TB_DIR)/sensor_hub_tb.vhd

# Define available testbenches
TESTBENCHES = safety_monitor_tb sensor_hub_tb

# FPGA synthesis configuration
FPGA_TYPE = hx1k
FPGA_PKG = vq100
PCF_FILE = pins.pcf
# Default top entity
TOP_ENTITY ?= nebkiso_top

.PHONY: all clean work analyze test sim_safety sim_sensor sim_all view_wave synth pnr bitstream program fpga

all: work analyze

work:
	@if [ ! -d "$(WORKDIR)" ]; then \
		mkdir -p $(WORKDIR); \
	fi


analyze: work
	@echo "Analyzing packages first..."
	@for file in $(PACKAGES); do \
		echo "Compiling $$file"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $$file; \
	done
	@echo "Analyzing interface files..."
	@for file in $(INTERFACE_FILES); do \
		echo "Compiling $$file"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $$file; \
	done
	@echo "Analyzing sensor files..."
	@for file in $(SENSOR_FILES); do \
		echo "Compiling $$file"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $$file; \
	done
	@echo "Analyzing olfactory files..."
	@for file in $(OLFACTORY_FILES); do \
		echo "Compiling $$file"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $$file; \
	done
	@echo "Analyzing safety files..."
	@for file in $(SAFETY_FILES); do \
		echo "Compiling $$file"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $$file; \
	done
	@echo "Analyzing core files last..."
	@for file in $(CORE_FILES); do \
		echo "Compiling $$file"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $$file; \
	done

# Add a target to examine package contents
show_pkg:
	@echo "Examining nebkiso_pkg.vhd contents..."
	$(GHDL) -s $(GHDLFLAGS) $(CORE_DIR)/nebkiso_pkg.vhd

test: analyze
	@echo "Analyzing testbench files..."
	@for file in $(TESTBENCH_FILES); do \
		echo "Compiling $$file"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $$file; \
	done

sim_safety: test
	@echo "Elaborating and running safety monitor simulation..."
	$(GHDL) -e $(GHDLFLAGS) --workdir=$(WORKDIR) safety_monitor_tb
	$(GHDL) -r $(GHDLFLAGS) --workdir=$(WORKDIR) safety_monitor_tb --vcd=$(SAFETY_VCD) --stop-time=$(STOP_TIME)
	@echo "Simulation completed. Run 'make view_safety' to view waveforms."

sim_sensor: test
	@echo "Elaborating and running sensor hub simulation..."
	$(GHDL) -e $(GHDLFLAGS) --workdir=$(WORKDIR) sensor_hub_tb
	$(GHDL) -r $(GHDLFLAGS) --workdir=$(WORKDIR) sensor_hub_tb --vcd=$(SENSOR_VCD) --stop-time=$(STOP_TIME)
	@echo "Simulation completed. Run 'make view_sensor' to view waveforms."

view_safety:
	@if [ -f "$(SAFETY_VCD)" ]; then \
		gtkwave $(SAFETY_VCD); \
	else \
		echo "No safety monitor waveform found. Run 'make sim_safety' first."; \
	fi

view_sensor:
	@if [ -f "$(SENSOR_VCD)" ]; then \
		gtkwave $(SENSOR_VCD) wave_sensor_hub_tb.do; \
	else \
		echo "No sensor hub waveform found. Run 'make sim_sensor' first."; \
	fi

sim_all: $(TESTBENCHES)
	@for tb in $(TESTBENCHES); do \
		echo "Running $$tb simulation..."; \
		$(GHDL) -e $(GHDLFLAGS) --workdir=$(WORKDIR) $$tb; \
		$(GHDL) -r $(GHDLFLAGS) --workdir=$(WORKDIR) $$tb --vcd=$$tb.vcd; \
	done

view_wave:
	@if [ -f "$(VCD_FILE)" ]; then \
		gtkwave $(VCD_FILE); \
	else \
		echo "No waveform file found. Run simulation first."; \
	fi

synth: analyze $(TOP_ENTITY).vhdl.gen
	@echo "Synthesizing design..."
	yosys -p "read_verilog $(TOP_ENTITY).vhdl.gen; synth_ice40 -top $(TOP_ENTITY); write_json $(TOP_ENTITY).json"

$(TOP_ENTITY).vhdl.gen: analyze
	@echo "Converting VHDL to Verilog..."
	@echo "Checking work library contents..."
	$(GHDL) -a $(SYNTH_FLAGS) $(PACKAGES)
	$(GHDL) -a $(SYNTH_FLAGS) $(INTERFACE_FILES)
	$(GHDL) -a $(SYNTH_FLAGS) $(SENSOR_FILES)
	$(GHDL) -a $(SYNTH_FLAGS) $(OLFACTORY_FILES)
	$(GHDL) -a $(SYNTH_FLAGS) $(SAFETY_FILES)
	$(GHDL) -a $(SYNTH_FLAGS) $(CORE_FILES)
	@echo "\nTrying to elaborate $(TOP_ENTITY)..."
	$(GHDL) -e $(SYNTH_FLAGS) $(TOP_ENTITY)
	@echo "\nAttempting synthesis..."
	@echo $(GHDL) --synth $(TOP_ENTITY) >| $(TOP_ENTITY).vhdl.gen || (rm -f $(TOP_ENTITY).vhdl.gen && exit 1)
	$(GHDL) --synth $(TOP_ENTITY) >| $(TOP_ENTITY).vhdl.gen || (rm -f $(TOP_ENTITY).vhdl.gen && exit 1)

# Add a verbose synthesis target for debugging
synth_verbose: analyze
	@echo "Attempting verbose synthesis..."
	$(GHDL) -a $(SYNTH_FLAGS) $(PACKAGES)
	$(GHDL) -a $(SYNTH_FLAGS) $(INTERFACE_FILES)
	$(GHDL) -a $(SYNTH_FLAGS) $(SENSOR_FILES)
	$(GHDL) -a $(SYNTH_FLAGS) $(OLFACTORY_FILES)
	$(GHDL) -a $(SYNTH_FLAGS) $(SAFETY_FILES)
	$(GHDL) -a $(SYNTH_FLAGS) $(CORE_FILES)
	$(GHDL) -e $(SYNTH_FLAGS) $(TOP_ENTITY)
	$(GHDL) --synth $(TOP_ENTITY)

# Add this debugging target
check_entity_files:
	@echo "Looking for $(TOP_ENTITY) in source files..."
	@find ../src -type f -name "*.vhd" -exec grep -l "entity $(TOP_ENTITY)" {} \;


check_work:
	$(GHDL) -d

# Try elaborating the top entity to see more detailed errors
elab_check:
	$(GHDL) -e $(GHDLFLAGS) --workdir=$(WORKDIR) $(TOP_ENTITY)


# Add these debugging targets
show_files:
	@echo "Package files:"
	@for file in $(PACKAGES); do echo "  $$file"; done
	@echo "\nCore files:"
	@for file in $(CORE_FILES); do echo "  $$file"; done
	@echo "\nInterface files:"
	@for file in $(INTERFACE_FILES); do echo "  $$file"; done
	@echo "\nSafety files:"
	@for file in $(SAFETY_FILES); do echo "  $$file"; done
	@echo "\nSensor files:"
	@for file in $(SENSOR_FILES); do echo "  $$file"; done
	@echo "\nOlfactory files:"
	@for file in $(OLFACTORY_FILES); do echo "  $$file"; done

check_entity:
	@echo "Checking for entity $(TOP_ENTITY)..."
	$(GHDL) -d $(TOP_ENTITY)

pnr: synth
	@echo "Running place and route..."
	nextpnr-ice40 --$(FPGA_TYPE) --package $(FPGA_PKG) \
		--json $(TOP_ENTITY).json \
		--pcf $(PCF_FILE) \
		--asc $(TOP_ENTITY).asc

bitstream: pnr
	@echo "Generating bitstream..."
	icepack $(TOP_ENTITY).asc $(TOP_ENTITY).bin

program: bitstream
	@echo "Programming FPGA..."
	iceprog $(TOP_ENTITY).bin

fpga: program

clean_fpga:
	rm -f *.json *.asc *.bin *.v

clean: clean_fpga
	@rm -rf $(WORKDIR)
	@rm -f *.o *.cf
	@rm -f $(SAFETY_VCD) $(SENSOR_VCD)
	@rm -f *.vcd