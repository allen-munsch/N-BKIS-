# Waveform configuration for safety monitor testbench

# Add clock and reset
add wave -noupdate -divider {System Signals}
add wave -noupdate -format Logic /safety_monitor_tb/clk
add wave -noupdate -format Logic /safety_monitor_tb/rst

# Add sensor inputs
add wave -noupdate -divider {Sensor Inputs}
add wave -noupdate -format Analog-Step -height 74 -max 4095 /safety_monitor_tb/voc_levels
add wave -noupdate -format Analog-Step -height 74 -max 4095 /safety_monitor_tb/air_quality
add wave -noupdate -format Analog-Step -height 74 -max 4095 /safety_monitor_tb/pressure_levels
add wave -noupdate -format Analog-Step -height 74 -max 4095 /safety_monitor_tb/temperature
add wave -noupdate -format Analog-Step -height 74 -max 255 /safety_monitor_tb/flow_sensors

# Add control outputs
add wave -noupdate -divider {Control Outputs}
add wave -noupdate -format Logic /safety_monitor_tb/emergency_stop
add wave -noupdate -format Logic /safety_monitor_tb/ventilation_on
add wave -noupdate -format Logic /safety_monitor_tb/chamber_shutdown

# Add status signals
add wave -noupdate -divider {Status}
add wave -noupdate -format Literal -radix hexadecimal /safety_monitor_tb/safety_status
add wave -noupdate -format Literal -radix hexadecimal /safety_monitor_tb/error_code

# Configure wave window
configure wave -namecolwidth 200
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

