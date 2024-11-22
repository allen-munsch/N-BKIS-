# Add waves for sensor_hub_tb
add wave -noupdate -divider {System Signals}
add wave -noupdate /sensor_hub_tb/clk
add wave -noupdate /sensor_hub_tb/rst

add wave -noupdate -divider {SPI Interface}
add wave -noupdate /sensor_hub_tb/adc_spi_sclk
add wave -noupdate /sensor_hub_tb/adc_spi_mosi
add wave -noupdate /sensor_hub_tb/adc_spi_miso
add wave -noupdate -expand /sensor_hub_tb/adc_spi_cs_n

add wave -noupdate -divider {Sensor Data}
add wave -noupdate -format Analog-Step -height 74 -max 4095 /sensor_hub_tb/voc_data
add wave -noupdate -format Analog-Step -height 74 -max 4095 /sensor_hub_tb/aq_data
add wave -noupdate -format Analog-Step -height 74 -max 4095 /sensor_hub_tb/pressure_data
add wave -noupdate -format Analog-Step -height 74 -max 4095 /sensor_hub_tb/temp_data
add wave -noupdate -format Analog-Step -height 74 -max 255 /sensor_hub_tb/flow_data

add wave -noupdate -divider {Status & Control}
add wave -noupdate /sensor_hub_tb/cal_mode
add wave -noupdate /sensor_hub_tb/cal_wr
add wave -noupdate /sensor_hub_tb/cal_addr
add wave -noupdate /sensor_hub_tb/cal_data
add wave -noupdate /sensor_hub_tb/sensor_status
add wave -noupdate /sensor_hub_tb/error_flags

add wave -noupdate -divider {Internal Signals}
add wave -noupdate /sensor_hub_tb/DUT/current_state
add wave -noupdate /sensor_hub_tb/DUT/sample_counter
add wave -noupdate /sensor_hub_tb/DUT/sensor_select