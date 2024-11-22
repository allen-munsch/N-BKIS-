# Bitstream generation settings for NΞBKISØ

# Security settings
set_property BITSTREAM.CONFIG.SECURITY_LEVEL encrypted [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]

# Configuration settings
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]

# Reliability settings
set_property BITSTREAM.CONFIG.CRC YES [current_design]
set_property BITSTREAM.CONFIG.NEXT_CONFIG_ADDR 0x0 [current_design]
set_property BITSTREAM.CONFIG.NEXT_CONFIG_NEW_MODE YES [current_design]

# Generate bitstream
write_bitstream -force ./output/nebkiso.bit
write_debug_probes ./output/nebkiso.ltx
