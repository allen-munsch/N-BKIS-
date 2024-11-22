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
        
        -- Sequence interface
        sequence_data       : in  sequence_step_type;
        
        -- Zone configuration
        num_zones          : in  std_logic_vector(3 downto 0);
        zone_enables       : in  std_logic_vector(15 downto 0);
        distribution_mode  : in  std_logic_vector(1 downto 0);
        target_zone        : in  std_logic_vector(3 downto 0);
        intensity_map      : in  std_logic_vector(127 downto 0);
        main_flow_in       : in  std_logic_vector(7 downto 0);
        
        -- Cartridge interface
        cartridge_valves    : out std_logic_vector(NUM_CARTRIDGES-1 downto 0);
        cartridge_pumps     : out std_logic_vector(NUM_CARTRIDGES-1 downto 0);
        cartridge_sensors   : in  std_logic_vector(NUM_CARTRIDGES*8-1 downto 0);
        
        -- Environment sensors/controls
        temperature         : in  std_logic_vector(TEMP_PRECISION-1 downto 0);
        humidity           : in  std_logic_vector(7 downto 0);
        humidity_target    : in  std_logic_vector(7 downto 0);
        pressure           : in  std_logic_vector(PRESSURE_PRECISION-1 downto 0);
        filter_status      : in  std_logic_vector(1 downto 0);
        
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
    -- Rest of the architecture remains the same as before
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
    -- Component instantiations with all required ports connected
    sequence_ctrl : entity work.sequence_controller
        port map (
            clk              => clk,
            rst              => rst,
            sequence_start   => sequence_start,
            sequence_stop    => sequence_stop,
            sequence_pause   => sequence_pause,
            sequence_data    => sequence_data,
            cartridge_enables=> cartridge_enables,
            flow_rates       => flow_rates,
            temp_target      => temp_target,
            pressure_target  => pressure_target,
            sequence_active  => sequence_active,
            sequence_done    => open,
            sequence_error   => sequence_error,
            current_step     => open
        );
    
    cartridge_ctrl : entity work.cartridge_controller
        port map (
            clk             => clk,
            rst             => rst,
            cartridge_sel   => "00000",  -- Default to first cartridge
            flow_rate       => flow_rates(0),
            enable          => cartridge_enables(0),
            valve_controls  => cartridge_valves,
            pump_controls   => cartridge_pumps,
            flow_sensors    => cartridge_sensors(NUM_CARTRIDGES-1 downto 0),
            cartridge_status=> open
        );
    
    env_ctrl : entity work.environment_controller
        port map (
            clk               => clk,
            rst               => rst,
            temp_target       => temp_target,
            humidity_target   => humidity_target,
            pressure_target   => pressure_target,
            temperature       => temperature,
            humidity         => humidity,
            pressure         => pressure,
            heater_control    => heater_control,
            cooler_control    => cooler_control,
            humidifier_control=> humidifier_control,
            filter_status    => filter_status,
            env_error        => env_error
        );
    
    spatial_ctrl : entity work.spatial_controller
        port map (
            clk              => clk,
            rst              => rst,
            num_zones        => num_zones,
            zone_enables     => zone_enables,
            distribution_mode=> distribution_mode,
            target_zone      => target_zone,
            intensity_map    => intensity_map,
            main_flow_in     => main_flow_in,
            zone_valves      => zone_valves,
            zone_flows       => zone_flows,
            zone_sensors     => zone_sensors,
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