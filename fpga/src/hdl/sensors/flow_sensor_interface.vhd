library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity flow_sensor_interface is
    port (
        -- System signals
        clk          : in  std_logic;
        rst          : in  std_logic;
        
        -- Flow sensor inputs (frequency-based)
        flow_pulse   : in  std_logic_vector(7 downto 0);
        
        -- Processed outputs
        flow_rate    : out std_logic_vector(15 downto 0);
        flow_valid   : out std_logic;
        
        -- Calibration
        cal_factor   : in  std_logic_vector(15 downto 0);
        
        -- Status
        sensor_error : out std_logic
    );
end flow_sensor_interface;

architecture behavioral of flow_sensor_interface is
    -- Pulse counting registers
    type pulse_counter_array is array (0 to 7) of unsigned(15 downto 0);
    signal pulse_counters : pulse_counter_array;
    signal measurement_interval : unsigned(15 downto 0);
    
begin
    -- Pulse counting process
    process(clk, rst)
    begin
        if rst = '1' then
            pulse_counters <= (others => (others => '0'));
            measurement_interval <= (others => '0');
            flow_valid <= '0';
            sensor_error <= '0';
        elsif rising_edge(clk) then
            -- Count pulses for each sensor
            for i in 0 to 7 loop
                if flow_pulse(i) = '1' then
                    pulse_counters(i) <= pulse_counters(i) + 1;
                end if;
            end loop;
            
            -- Measurement interval timing
            if measurement_interval = x"FFFF" then
                -- Calculate flow rate
                flow_rate <= std_logic_vector(
                    pulse_counters(0) * unsigned(cal_factor)
                );
                flow_valid <= '1';
                
                -- Reset counters
                pulse_counters <= (others => (others => '0'));
                measurement_interval <= (others => '0');
                
                -- Check for sensor errors (no pulses during interval)
                if pulse_counters(0) = 0 then
                    sensor_error <= '1';
                else
                    sensor_error <= '0';
                end if;
            else
                measurement_interval <= measurement_interval + 1;
                flow_valid <= '0';
            end if;
        end if;
    end process;
end behavioral;