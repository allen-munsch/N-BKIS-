# Clock definitions
create_clock -period 10.000 -name clk_100mhz [get_ports clk_in]
create_clock -period 125.000 -name spi_sclk [get_ports spi_sclk]
create_clock -period 2500.000 -name i2c_scl [get_ports scl[0]]

# Clock groups (asynchronous clock domains)
set_clock_groups -asynchronous \
    -group [get_clocks clk_100mhz] \
    -group [get_clocks spi_sclk] \
    -group [get_clocks i2c_scl]

# Input delays
set_input_delay -clock [get_clocks spi_sclk] -max 2.000 [get_ports spi_mosi]
set_input_delay -clock [get_clocks spi_sclk] -min 0.500 [get_ports spi_mosi]
set_input_delay -clock [get_clocks i2c_scl] -max 100.000 [get_ports sda*]
set_input_delay -clock [get_clocks i2c_scl] -min 25.000 [get_ports sda*]

# Output delays
set_output_delay -clock [get_clocks spi_sclk] -max 2.000 [get_ports spi_miso]
set_output_delay -clock [get_clocks spi_sclk] -min 0.500 [get_ports spi_miso]

# Clock uncertainty
set_clock_uncertainty 0.100 [get_clocks clk_100mhz]
set_clock_uncertainty 0.200 [get_clocks spi_sclk]
set_clock_uncertainty 1.000 [get_clocks i2c_scl]

# Maximum delays for critical paths
set_max_delay 5.000 -from [get_pins safety_monitor/*/C] -to [get_pins */emergency_stop_reg/D]
set_max_delay 8.000 -from [get_pins sensor_hub/*/C] -to [get_pins */sensor_data_reg*/D]

# Multicycle paths for slower interfaces
set_multicycle_path 2 -setup -from [get_pins */i2c_controller/*/C] -to [get_pins */i2c_data_reg*/D]
set_multicycle_path 1 -hold -from [get_pins */i2c_controller/*/C] -to [get_pins */i2c_data_reg*/D]

# False paths for crossing clock domains with proper synchronizers
set_false_path -from [get_pins */sync_reg[0]/C] -to [get_pins */sync_reg[1]/D]
