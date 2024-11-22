library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_olfactory_pkg.all;

entity cartridge_controller is
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        cartridge_sel   : in  std_logic_vector(4 downto 0);
        flow_rate       : in  std_logic_vector(FLOW_PRECISION-1 downto 0);
        enable          : in  std_logic;
        valve_controls  : out std_logic_vector(NUM_CARTRIDGES-1 downto 0);
        pump_controls   : out std_logic_vector(NUM_CARTRIDGES-1 downto 0);
        flow_sensors    : in  std_logic_vector(NUM_CARTRIDGES-1 downto 0);
        cartridge_status: out std_logic_vector(NUM_CARTRIDGES-1 downto 0)
    );
end cartridge_controller;

architecture behavioral of cartridge_controller is
    signal flow_error : std_logic_vector(NUM_CARTRIDGES-1 downto 0);
    signal valve_state : std_logic_vector(NUM_CARTRIDGES-1 downto 0);
    signal pump_state : std_logic_vector(NUM_CARTRIDGES-1 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            valve_controls <= (others => '0');
            pump_controls <= (others => '0');
            cartridge_status <= (others => '0');
            flow_error <= (others => '0');
        elsif rising_edge(clk) then
            -- Reset all controls
            valve_controls <= (others => '0');
            pump_controls <= (others => '0');
            
            -- Enable selected cartridge if valid
            if enable = '1' and unsigned(cartridge_sel) < NUM_CARTRIDGES then
                valve_controls(to_integer(unsigned(cartridge_sel))) <= '1';
                pump_controls(to_integer(unsigned(cartridge_sel))) <= '1';
            end if;
            
            -- Check flow sensors and update status
            for i in 0 to NUM_CARTRIDGES-1 loop
                if valve_state(i) = '1' and flow_sensors(i) = '0' then
                    flow_error(i) <= '1';
                else
                    flow_error(i) <= '0';
                end if;
            end loop;
            
            -- Update status (1 = OK, 0 = Error)
            cartridge_status <= not flow_error;
            
            -- Save current state for next cycle
            valve_state <= valve_controls;
            pump_state <= pump_controls;
        end if;
    end process;
end behavioral;