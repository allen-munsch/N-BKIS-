library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_pkg.all;
use work.nebkiso_types.all;

entity safety_monitor is
    port (
        -- System signals
        clk              : in  std_logic;
        rst              : in  std_logic;
        
        -- Sensor inputs
        voc_levels       : in  std_logic_vector(11 downto 0);
        air_quality      : in  std_logic_vector(11 downto 0);
        pressure_levels  : in  std_logic_vector(11 downto 0);
        temperature      : in  std_logic_vector(11 downto 0);
        flow_sensors     : in  std_logic_vector(7 downto 0);
        
        -- Threshold settings
        voc_threshold    : in  std_logic_vector(11 downto 0);
        aq_threshold     : in  std_logic_vector(11 downto 0);
        press_threshold  : in  std_logic_vector(11 downto 0);
        temp_threshold   : in  std_logic_vector(11 downto 0);
        flow_threshold   : in  std_logic_vector(7 downto 0);
        
        -- Control outputs
        emergency_stop   : out std_logic;
        ventilation_on   : out std_logic;
        chamber_shutdown : out std_logic_vector(NUM_CHAMBERS-1 downto 0);
        
        -- Status outputs
        safety_status    : out std_logic_vector(7 downto 0);
        error_code      : out std_logic_vector(7 downto 0);
        error_location  : out std_logic_vector(7 downto 0)
    );
end safety_monitor;

architecture behavioral of safety_monitor is
    type monitor_state_type is (CHECK_VOC, CHECK_AQ, CHECK_PRESSURE, CHECK_TEMP, CHECK_FLOW);
    signal current_state : monitor_state_type;
    signal violation_counter : unsigned(3 downto 0);
    signal persistent_violation : std_logic;
    
    -- Internal signals for outputs
    signal emergency_stop_int : std_logic;
    signal ventilation_on_int : std_logic;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= CHECK_VOC;
            emergency_stop_int <= '0';
            ventilation_on_int <= '0';
            chamber_shutdown <= (others => '0');
            violation_counter <= (others => '0');
            persistent_violation <= '0';
            error_code <= (others => '0');
            error_location <= (others => '0');
            
        elsif rising_edge(clk) then
            case current_state is
                when CHECK_VOC =>
                    if unsigned(voc_levels) > unsigned(voc_threshold) then
                        ventilation_on_int <= '1';
                        violation_counter <= violation_counter + 1;
                        error_code <= x"01";
                        error_location <= x"00";  -- VOC sensor location
                    else
                        violation_counter <= (others => '0');
                    end if;
                    current_state <= CHECK_AQ;

                when CHECK_AQ =>
                    if unsigned(air_quality) > unsigned(aq_threshold) then
                        ventilation_on_int <= '1';
                        violation_counter <= violation_counter + 1;
                        error_code <= x"02";
                        error_location <= x"01";  -- AQ sensor location
                    end if;
                    current_state <= CHECK_PRESSURE;

                when CHECK_PRESSURE =>
                    if unsigned(pressure_levels) > unsigned(press_threshold) then
                        chamber_shutdown <= (others => '1');
                        error_code <= x"03";
                        error_location <= x"02";  -- Pressure sensor location
                        emergency_stop_int <= '1';
                    end if;
                    current_state <= CHECK_TEMP;

                when CHECK_TEMP =>
                    if unsigned(temperature) > unsigned(temp_threshold) then
                        chamber_shutdown <= (others => '1');
                        error_code <= x"04";
                        error_location <= x"03";  -- Temperature sensor location
                        emergency_stop_int <= '1';
                    end if;
                    current_state <= CHECK_FLOW;

                when CHECK_FLOW =>
                    if unsigned(flow_sensors) < unsigned(flow_threshold) then
                        error_code <= x"05";
                        error_location <= x"04";  -- Flow sensor location
                    end if;
                    current_state <= CHECK_VOC;

                when others =>
                    current_state <= CHECK_VOC;
            end case;

            -- Persistent violation check
            if violation_counter > x"8" then  -- More than 8 consecutive violations
                persistent_violation <= '1';
                emergency_stop_int <= '1';
            end if;

            -- Update safety status
            safety_status <= persistent_violation & 
                           emergency_stop_int & 
                           ventilation_on_int & 
                           "00000";  -- Reserved bits
        end if;
    end process;

    -- Drive output ports
    emergency_stop <= emergency_stop_int;
    ventilation_on <= ventilation_on_int;

end behavioral;