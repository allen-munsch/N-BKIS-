# GHDL configuration
GHDL=ghdl
GHDLFLAGS=--std=08
WORKDIR=work

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
$(SENSORS_DIR)/sensor_hub.vhd \
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
$(SENSORS_DIR)/sensor_hub.vhd \
$(SENSORS_DIR)/flow_sensor_interface.vhd

# Olfactory files
OLFACTORY_FILES = \
$(OLFACTORY_DIR)/environment_controller.vhd \
$(OLFACTORY_DIR)/spatial_controller.vhd \
$(OLFACTORY_DIR)/sequence_controller.vhd \
$(OLFACTORY_DIR)/mixing_chamber_controller.vhd \
$(OLFACTORY_DIR)/olfactory_sequencer_top.vhd

# All source files
SOURCES = $(PACKAGES) $(CORE_FILES) $(INTERFACE_FILES) $(SAFETY_FILES) $(SENSOR_FILES) $(OLFACTORY_FILES)

# Testbench files
TESTBENCH_FILES = \
$(TB_DIR)/nebkiso_tb_pkg.vhd \
$(TB_DIR)/safety_monitor_tb.vhd \
$(TB_DIR)/sensor_hub_tb.vhd

.PHONY: all clean work analyze test

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
	@echo "Analyzing core files..."
	@for file in $(CORE_FILES); do \
		echo "Compiling $$file"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $$file; \
	done
	@echo "Analyzing interface files..."
	@for file in $(INTERFACE_FILES); do \
		echo "Compiling $$file"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $$file; \
	done
	@echo "Analyzing safety files..."
	@for file in $(SAFETY_FILES); do \
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

test: analyze
	@echo "Analyzing testbench files..."
	@for file in $(TESTBENCH_FILES); do \
		echo "Compiling $$file"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $$file; \
	done

clean:
	@rm -rf $(WORKDIR)
	@rm -f *.o
	@rm -f *.cf
	@rm -f *.vcd