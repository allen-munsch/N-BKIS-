library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package nebkiso_pkg is
    -- System constants
    constant NUM_CHAMBERS : integer := 150;
    constant CHAMBER_SELECT_BITS : integer := 8;
    constant NUM_VOC_SENSORS : integer := 4;
    constant NUM_AIR_QUALITY_SENSORS : integer := 4;
    constant MAX_SEQUENCE_STEPS : integer := 1024;
    
    -- Type definitions
    type chamber_array is array (0 to NUM_CHAMBERS-1) of std_logic_vector(7 downto 0);
    type flow_array is array (0 to NUM_CHAMBERS-1) of std_logic_vector(7 downto 0);
    type sequence_step is record
        chamber_id : std_logic_vector(CHAMBER_SELECT_BITS-1 downto 0);
        intensity : std_logic_vector(7 downto 0);
        duration : std_logic_vector(15 downto 0);
    end record;
    type sequence_array is array (0 to MAX_SEQUENCE_STEPS-1) of sequence_step;
end package;