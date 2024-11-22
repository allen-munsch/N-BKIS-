-- fpga/src/hdl/safety/ventilation_controller.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ventilation_controller is
    port (
        -- System signals
        clk             : in  std_logic;
        rst             : in  std_logic;
        
        -- Control inputs
        ventilation_req : in  std_logic;
        emergency_stop  : in  std_logic;
        
        -- Sensor inputs
        air_quality     : in  std_logic_vector(11 downto 0);
        flow_sensor     : in  std_logic_vector(7 downto 0);
        
        -- Control outputs
        fan_speed       : out std_logic_vector(7 downto 0);
        damper_position : out std_logic_vector(7 downto 0);
        
        -- Status
        vent_active     : out std_logic;
        vent_error      : out std_logic
    );
end ventilation_controller;

architecture behavioral of ventilation_controller is
    type vent_state_type is (IDLE, STARTUP, RUNNING, SHUTDOWN, ERROR);
    signal current_state : vent_state_type;
    signal speed_target : unsigned(7 downto 0);
    signal damper_target : unsigned(7 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
            fan_speed <= (others => '0');
            damper_position <= (others => '0');
            vent_active <= '0';
            vent_error <= '0';
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    if ventilation_req = '1' or emergency_stop = '1' then
                        current_state <= STARTUP;
                        vent_active <= '1';
                    end if;

                when STARTUP =>
                    -- Gradual fan speed increase
                    if unsigned(fan_speed) < speed_target then
                        fan_speed <= std_logic_vector(unsigned(fan_speed) + 1);
                    else
                        current_state <= RUNNING;
                    end if;
                    -- Open damper
                    damper_position <= (others => '1');

                when RUNNING =>
                    -- Monitor flow sensor for proper operation
                    if unsigned(flow_sensor) < 10 then  -- Minimum flow threshold
                        vent_error <= '1';
                        current_state <= ERROR;
                    elsif ventilation_req = '0' and emergency_stop = '0' then
                        current_state <= SHUTDOWN;
                    end if;

                when SHUTDOWN =>
                    -- Gradual fan speed decrease
                    if unsigned(fan_speed) > 0 then
                        fan_speed <= std_logic_vector(unsigned(fan_speed) - 1);
                    else
                        damper_position <= (others => '0');
                        current_state <= IDLE;
                        vent_active <= '0';
                    end if;

                when ERROR =>
                    fan_speed <= (others => '0');
                    damper_position <= (others => '1');  -- Fully open in error
                    if rst = '1' then
                        current_state <= IDLE;
                        vent_error <= '0';
                    end if;
            end case;
        end if;
    end process;
end behavioral;