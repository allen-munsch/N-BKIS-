library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.nebkiso_pkg.all;

package nebkiso_types is
    -- System states
    type system_state_type is (
        INIT,
        IDLE,
        CALIBRATING,
        RUNNING,
        EMERGENCY,
        CLEANING,
        FAULT
    );

    -- Control modes
    type control_mode_type is (
        MANUAL,
        SEQ_MODE,  -- Renamed from SEQUENCE to avoid keyword conflict
        INTERACTIVE,
        CALIBRATION
    );

    -- Error codes
    type error_code_type is (
        NO_ERROR,
        PRESSURE_ERROR,
        TEMPERATURE_ERROR,
        FLOW_ERROR,
        VOC_ERROR,
        AIR_QUALITY_ERROR,
        SEQUENCE_ERROR,
        COMMUNICATION_ERROR
    );
end package;
