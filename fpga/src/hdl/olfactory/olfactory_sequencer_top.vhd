library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_pkg.all;
use work.nebkiso_olfactory_pkg.all;

entity olfactory_sequencer_top is
    port (
        -- System signals
        clk                 : in  std_logic;
        rst                 : in  std_logic;
        
        -- Control interface
        sequence_start      : in  std_logic;
        sequence_stop       : in  std_logic;
        sequence_pause      : in  std_logic;
        operation_mode      : in  std_logic_vector(1 downto 0);
        
        -- Cartridge interface
        cartridge_valves    : out std_logic_vector(NUM_CARTRIDGES-1 downto 0);
        cartridge_pumps     : out std_logic_vector(NUM_CARTRIDGES-1 downto 0);
        cartridge_sensors   : in  std_logic_vector(NUM_CARTRIDGES*8-1 downto 0);
        
        -- Environment sensors
        temperature         : in  std_logic_vector(TEMP_PRECISION-1 downto 0);
        humidity           : in  std_logic_vector(7 downto 0);
        pressure           : in  std_logic_vector(PRESSURE_PRECISION-1 downto 0);
        
        -- Environment control
        heater_control      : out std_logic_vector(7 downto 0);
        cooler_control      : out std_logic_vector(7 downto 0);
        humidifier_control  : out std_logic_vector(7 downto 0);
        ventilation_control : out std_logic_vector(7 downto 0);
        
        -- Mixing chamber
        mixer_speed         : out std_logic_vector(7 downto 0);
        mixer_mode          : out std_logic_vector(1 downto 0);
        
        -- Zone control
        zone_valves         : out std_logic_vector(15 downto 0);
        zone_flows          : out std_logic_vector(127 downto 0);
        zone_sensors        : in  std_logic_vector(127 downto 0);
        
        -- Status and monitoring
        system_status       : out std_logic_vector(7 downto 0);
        error_code         : out std_logic_vector(7 downto 0);
        sequence_active    : out std_logic;
        emergency_stop     : out std_logic
    );
end olfactory_sequencer_top;

architecture behavioral of olfactory_sequencer_top is
    -- Internal signals for interconnection
    signal cartridge_enables : std_logic_vector(NUM_CARTRIDGES-1 downto 0);
    signal flow_rates : cartridge_array;
    signal temp_target : std_logic_vector(TEMP_PRECISION-1 downto 0);
    signal pressure_target : std_logic_vector(PRESSURE_PRECISION-1 downto 0);
    signal mixing_active : std_logic;
    signal env_error : std_logic;
    signal sequence_error : std_logic;
    signal distribution_active : std_logic;
    
begin
    -- Sequence controller instance
    sequence_ctrl : entity work.sequence_controller
        port map (
            clk => clk,
            rst => rst,
            sequence_start => sequence_start,
            sequence_stop => sequence_stop,
            sequence_pause => sequence_pause,
            cartridge_enables => cartridge_enables,
            flow_rates => flow_rates,
            temp_target => temp_target,
            pressure_target => pressure_target,
            sequence_active => sequence_active,
            sequence_error => sequence_error
        );
    
    -- Cartridge controller instance
    cartridge_ctrl : entity work.cartridge_controller
        port map (
            clk => clk,
            rst => rst,
            cartridge_sel => cartridge_enables,
            flow_rate => flow_rates(0),  -- First flow rate
            valve_controls => cartridge_valves,
            pump_controls => cartridge_pumps,
            flow_sensors => cartridge_sensors(7 downto 0)  -- First sensor
        );
    
    -- Environment controller instance
    env_ctrl : entity work.environment_controller
        port map (
            clk => clk,
            rst => rst,
            temp_target => temp_target,
            pressure_target => pressure_target,
            temperature => temperature,
            humidity => humidity,
            pressure => pressure,
            heater_control => heater_control,
            cooler_control => cooler_control,
            humidifier_control => humidifier_control,
            env_error => env_error
        );
    
    -- Mixing chamber controller instance
    mixing_ctrl : entity work.mixing_chamber_controller
        port map (
            clk => clk,
            rst => rst,
            mixing_mode => mixing_mode_type'val(to_integer(unsigned(operation_mode))),
            mixer_speed => mixer_speed,
            temp_target => temp_target,
            pressure_target => pressure_target
        );
    
    -- Spatial distribution controller instance
    spatial_ctrl : entity work.spatial_controller
        port map (
            clk => clk,
            rst => rst,
            zone_valves => zone_valves,
            zone_flows => zone_flows,
            zone_sensors => zone_sensors,
            distribution_active => distribution_active
        );
    
    -- Status monitoring process
    process(clk, rst)
    begin
        if rst = '1' then
            system_status <= (others => '0');
            error_code <= (others => '0');
            emergency_stop <= '0';
        elsif rising_edge(clk) then
            -- System status composition
            system_status <= sequence_active & 
                           mixing_active &
                           distribution_active &
                           env_error &
                           sequence_error &
                           "000";
            
            -- Error code handling
            if env_error = '1' then
                error_code <= x"01";  -- Environment error
            elsif sequence_error = '1' then
                error_code <= x"02";  -- Sequence error
            else
                error_code <= x"00";  -- No error
            end if;
            
            -- Emergency stop condition
            emergency_stop <= env_error or sequence_error;
        end if;
    end process;
end behavioral;