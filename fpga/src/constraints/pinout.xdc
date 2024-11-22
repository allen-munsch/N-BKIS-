# Clock input
set_property PACKAGE_PIN Y9 [get_ports clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports clk_in]

# SPI Interface
set_property PACKAGE_PIN W15 [get_ports spi_sclk]
set_property PACKAGE_PIN T12 [get_ports spi_mosi]
set_property PACKAGE_PIN U12 [get_ports spi_miso]
set_property PACKAGE_PIN T14 [get_ports spi_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports spi_*]

# I2C Interface
set_property PACKAGE_PIN U14 [get_ports {scl[0]}]
set_property PACKAGE_PIN U15 [get_ports {sda[0]}]
set_property PACKAGE_PIN V17 [get_ports {scl[1]}]
set_property PACKAGE_PIN V18 [get_ports {sda[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {s*[*]}]
set_property PULLUP true [get_ports {scl[*]}]
set_property PULLUP true [get_ports {sda[*]}]

# Sensor Interfaces
set_property PACKAGE_PIN V15 [get_ports {adc_spi_cs_n[0]}]
set_property PACKAGE_PIN W14 [get_ports {adc_spi_cs_n[1]}]
set_property PACKAGE_PIN V16 [get_ports adc_spi_sclk]
set_property PACKAGE_PIN V13 [get_ports adc_spi_mosi]
set_property PACKAGE_PIN U16 [get_ports adc_spi_miso]
set_property IOSTANDARD LVCMOS33 [get_ports adc_spi_*]

# Safety-Critical Outputs
set_property PACKAGE_PIN U18 [get_ports emergency_stop]
set_property PACKAGE_PIN U19 [get_ports ventilation_on]
set_property IOSTANDARD LVCMOS33 [get_ports {emergency_*}]
set_property IOSTANDARD LVCMOS33 [get_ports ventilation_*]

# Flow Sensor Inputs
set_property PACKAGE_PIN W19 [get_ports {flow_pulse[0]}]
set_property PACKAGE_PIN W20 [get_ports {flow_pulse[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {flow_pulse[*]}]
