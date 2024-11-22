library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_olfactory_pkg.all;

entity environment_controller is
    port (
        -- System signals
        clk               : in  std_logic;
        rst               : in  std_logic;
        
        -- Environment targets
        temp_target       : in  std_logic_vector(TEMP_PRECISION-1 downto 0);
        humidity_target   : in  std_logic_vector(7 downto 0);  -- 0-100%
        pressure_target   : in  std_logic_vector(PRESSURE_PRECISION-1 downto 0);
        
        -- Sensor inputs
        temperature       : in  std_logic_vector(TEMP_PRECISION-1 downto 0);
        humidity         : in  std_logic_vector(7 downto 0);
        pressure         : in  std_logic_vector(PRESSURE_PRECISION-1 downto 0);
        
        -- Control outputs
        heater_control    : out std_logic_vector(7 downto 0);
        cooler_control    : out std_logic_vector(7 downto 0);
        humidifier_control: out std_logic_vector(7 downto 0);
        dehumidifier_control: out std_logic_vector(7 downto 0);
        pressure_control  : out std_logic_vector(7 downto 0);
        
        -- Filter control
        hepa_filter_enable: out std_logic;
        carbon_filter_enable: out std_logic;
        filter_status    : in  std_logic_vector(1 downto 0);
        
        -- Status outputs
        temp_stable      : out std_logic;
        humidity_stable  : out std_logic;
        pressure_stable  : out std_logic;
        env_error        : out std_logic
    );
end environment_controller;

architecture behavioral of environment_controller is
    -- PID control signals for temperature
    signal temp_error : signed(TEMP_PRECISION-1 downto 0);
    signal temp_integral : signed(TEMP_PRECISION+3 downto 0);
    signal temp_derivative : signed(TEMP_PRECISION-1 downto 0);
    signal prev_temp_error : signed(TEMP_PRECISION-1 downto 0);
    
    -- Control parameters
    constant KP_TEMP : signed(7 downto 0) := to_signed(4, 8);
    constant KI_TEMP : signed(7 downto 0) := to_signed(2, 8);
    constant KD_TEMP : signed(7 downto 0) := to_signed(1, 8);
    
    -- Status monitoring thresholds
    constant TEMP_THRESHOLD : unsigned(7 downto 0) := x"02";     -- 0.2°C
    constant HUMID_THRESHOLD : unsigned(7 downto 0) := x"02";    -- 2%
    constant PRESS_THRESHOLD : unsigned(7 downto 0) := x"02";    -- 0.02 atm
    
begin
    process(clk, rst)
        variable temp_control : signed(TEMP_PRECISION+3 downto 0);
    begin
        if rst = '1' then
            heater_control <= (others => '0');
            cooler_control <= (others => '0');
            humidifier_control <= (others => '0');
            dehumidifier_control <= (others => '0');
            pressure_control <= (others => '0');
            hepa_filter_enable <= '1';
            carbon_filter_enable <= '1';
            temp_stable <= '0';
            humidity_stable <= '0';
            pressure_stable <= '0';
            env_error <= '0';
        elsif rising_edge(clk) then
            -- Temperature PID control
            temp_error <= signed(temp_target) - signed(temperature);
            temp_integral <= temp_integral + temp_error;
            temp_derivative <= temp_error - prev_temp_error;
            prev_temp_error <= temp_error;
            
            -- Calculate PID output
            temp_control := (KP_TEMP * temp_error) + 
                          (KI_TEMP * temp_integral(TEMP_PRECISION+3 downto 4)) +
                          (KD_TEMP * temp_derivative);
            
            -- Apply temperature control
            if temp_control > 0 then
                heater_control <= std_logic_vector(unsigned(temp_control(7 downto 0)));
                cooler_control <= (others => '0');
            else
                cooler_control <= std_logic_vector(unsigned(-temp_control(7 downto 0)));
                heater_control <= (others => '0');
            end if;
            
            -- Humidity control
            if unsigned(humidity) < unsigned(humidity_target) then
                humidifier_control <= std_logic_vector(unsigned(humidity_target) - unsigned(humidity));
                dehumidifier_control <= (others => '0');
            else
                dehumidifier_control <= std_logic_vector(unsigned(humidity) - unsigned(humidity_target));
                humidifier_control <= (others => '0');
            end if;
            
            -- Pressure control
            if unsigned(pressure) < unsigned(pressure_target) then
                pressure_control <= std_logic_vector(unsigned(pressure_target(7 downto 0)));
            else
                pressure_control <= (others => '0');
            end if;
            
            -- Filter management
            hepa_filter_enable <= '1';  -- Always on for safety
            carbon_filter_enable <= '1'; -- Always on for molecular filtration
            
            -- Stability detection
            if abs(signed(temp_target) - signed(temperature)) < signed(TEMP_THRESHOLD) then
                temp_stable <= '1';
            else
                temp_stable <= '0';
            end if;
            
            if abs(signed(humidity_target) - signed(humidity)) < signed(HUMID_THRESHOLD) then
                humidity_stable <= '1';
            else
                humidity_stable <= '0';
            end if;
            
            if abs(signed(pressure_target) - signed(pressure)) < signed(PRESS_THRESHOLD) then
                pressure_stable <= '1';
            else
                pressure_stable <= '0';
            end if;
            
            -- Error detection
            env_error <= '0';
            if filter_status /= "11" then  -- Filter error
                env_error <= '1';
            end if;
            if abs(signed(temp_target) - signed(temperature)) > signed(TEMP_THRESHOLD & x"0") then
                env_error <= '1';  -- Major temperature deviation
            end if;
            if unsigned(pressure) < unsigned(pressure_target) - x"100" then
                env_error <= '1';  -- Significant pressure loss
            end if;
        end if;
    end process;
end behavioral;