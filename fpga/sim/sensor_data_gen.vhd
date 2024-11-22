# fpga/sim/sensor_data_gen.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_pkg.all;
use work.nebkiso_tb_pkg.all;

entity sensor_data_gen is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        -- Test control
        pattern_sel : in  std_logic_vector(2 downto 0);
        -- Generated sensor data
        voc_out     : out std_logic_vector(11 downto 0);
        aq_out      : out std_logic_vector(11 downto 0);
        press_out   : out std_logic_vector(11 downto 0);
        temp_out    : out std_logic_vector(11 downto 0);
        flow_out    : out std_logic_vector(7 downto 0)
    );
end sensor_data_gen;

architecture behavioral of sensor_data_gen is
    signal counter : unsigned(15 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');
            voc_out <= (others => '0');
            aq_out <= (others => '0');
            press_out <= (others => '0');
            temp_out <= (others => '0');
            flow_out <= (others => '0');
        elsif rising_edge(clk) then
            counter <= counter + 1;
            
            case pattern_sel is
                when "000" => -- Normal operation
                    voc_out <= NORMAL_OPERATION.voc_level;
                    aq_out <= NORMAL_OPERATION.aq_level;
                    press_out <= NORMAL_OPERATION.pressure;
                    temp_out <= NORMAL_OPERATION.temperature;
                    flow_out <= NORMAL_OPERATION.flow_rate;
                
                when "001" => -- Ramping values
                    voc_out <= std_logic_vector(counter(11 downto 0));
                    aq_out <= std_logic_vector(counter(11 downto 0));
                    press_out <= std_logic_vector(counter(11 downto 0));
                    temp_out <= std_logic_vector(counter(11 downto 0));
                    flow_out <= std_logic_vector(counter(7 downto 0));
                
                when "010" => -- Sine wave approximation
                    -- Implement simple sine wave pattern
                    
                when "011" => -- Random fluctuations
                    -- Implement pseudo-random variations
                    
                when "100" => -- Emergency conditions
                    voc_out <= EMERGENCY_CONDITION.voc_level;
                    aq_out <= EMERGENCY_CONDITION.aq_level;
                    press_out <= EMERGENCY_CONDITION.pressure;
                    temp_out <= EMERGENCY_CONDITION.temperature;
                    flow_out <= EMERGENCY_CONDITION.flow_rate;
                
                when others =>
                    -- Default to normal operation
                    voc_out <= NORMAL_OPERATION.voc_level;
                    aq_out <= NORMAL_OPERATION.aq_level;
                    press_out <= NORMAL_OPERATION.pressure;
                    temp_out <= NORMAL_OPERATION.temperature;
                    flow_out <= NORMAL_OPERATION.flow_rate;
            end case;
        end if;
    end process;
end behavioral;

