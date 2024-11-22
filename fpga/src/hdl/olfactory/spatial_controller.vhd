library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_olfactory_pkg.all;

entity spatial_controller is
    port (
        -- System signals
        clk              : in  std_logic;
        rst              : in  std_logic;
        
        -- Zone configuration
        num_zones        : in  std_logic_vector(3 downto 0);  -- Up to 16 zones
        zone_enables     : in  std_logic_vector(15 downto 0);
        
        -- Distribution control
        distribution_mode: in  std_logic_vector(1 downto 0);  -- 00:Even, 01:Gradient, 10:Targeted
        target_zone      : in  std_logic_vector(3 downto 0);
        intensity_map    : in  std_logic_vector(127 downto 0);  -- 8-bit intensity for 16 zones
        
        -- Flow control
        main_flow_in     : in  std_logic_vector(7 downto 0);
        
        -- Outputs per zone
        zone_valves      : out std_logic_vector(15 downto 0);
        zone_flows       : out std_logic_vector(127 downto 0);
        
        -- Feedback
        zone_sensors     : in  std_logic_vector(127 downto 0);
        
        -- Status
        distribution_active : out std_logic;
        zone_status     : out std_logic_vector(15 downto 0)
    );
end spatial_controller;

architecture behavioral of spatial_controller is
    type distribution_state is (INIT, CALCULATE, UPDATE, MONITOR);
    signal state : distribution_state;
    
    -- Zone control arrays
    type zone_array is array (0 to 15) of unsigned(7 downto 0);
    signal flow_targets : zone_array;
    signal flow_current : zone_array;
begin
    process(clk, rst)
        variable total_flow : unsigned(11 downto 0);
        variable zone_index : integer range 0 to 15;
    begin
        if rst = '1' then
            state <= INIT;
            zone_valves <= (others => '0');
            distribution_active <= '0';
        elsif rising_edge(clk) then
            case state is
                when INIT =>
                    -- Reset all zones
                    zone_valves <= (others => '0');
                    state <= CALCULATE;
                    distribution_active <= '1';
                
                when CALCULATE =>
                    case distribution_mode is
                        when "00" =>  -- Even distribution
                            for i in 0 to 15 loop
                                if zone_enables(i) = '1' then
                                    flow_targets(i) <= unsigned(main_flow_in);
                                else
                                    flow_targets(i) <= (others => '0');
                                end if;
                            end loop;
                            
                        when "01" =>  -- Gradient
                            -- Implement gradient distribution algorithm
                            for i in 0 to 15 loop
                                if zone_enables(i) = '1' then
                                    flow_targets(i) <= unsigned(intensity_map(i*8+7 downto i*8));
                                end if;
                            end loop;
                            
                        when others =>  -- Targeted
                            -- Implement targeted distribution
                            for i in 0 to 15 loop
                                if i = to_integer(unsigned(target_zone)) then
                                    flow_targets(i) <= unsigned(main_flow_in);
                                else
                                    flow_targets(i) <= (others => '0');
                                end if;
                            end loop;
                    end case;
                    state <= UPDATE;
                
                when UPDATE =>
                    -- Update valve positions based on flow targets
                    for i in 0 to 15 loop
                        if zone_enables(i) = '1' then
                            zone_valves(i) <= '1';
                            zone_flows(i*8+7 downto i*8) <= std_logic_vector(flow_targets(i));
                        end if;
                    end loop;
                    state <= MONITOR;
                
                when MONITOR =>
                    -- Monitor and adjust flows
                    for i in 0 to 15 loop
                        if zone_enables(i) = '1' then
                            flow_current(i) <= unsigned(zone_sensors(i*8+7 downto i*8));
                            -- Set status based on flow matching
                            if unsigned(zone_sensors(i*8+7 downto i*8)) = flow_targets(i) then
                                zone_status(i) <= '1';
                            else
                                zone_status(i) <= '0';
                            end if;
                        end if;
                    end loop;
                    state <= CALCULATE;
            end case;
        end if;
    end process;
end behavioral;