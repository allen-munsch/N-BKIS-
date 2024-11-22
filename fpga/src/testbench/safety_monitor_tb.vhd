library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_pkg.all;
use work.nebkiso_tb_pkg.all;

entity safety_monitor_tb is
end safety_monitor_tb;

architecture behavioral of safety_monitor_tb is
    -- Component declarations
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    
    -- Test signals matching safety_monitor ports
    signal voc_levels : std_logic_vector(11 downto 0);
    signal air_quality : std_logic_vector(11 downto 0);
    signal pressure_levels : std_logic_vector(11 downto 0);
    signal temperature : std_logic_vector(11 downto 0);
    signal flow_sensors : std_logic_vector(7 downto 0);
    
    -- Threshold signals
    signal voc_threshold : std_logic_vector(11 downto 0) := x"800";    -- 2048
    signal aq_threshold : std_logic_vector(11 downto 0) := x"800";     -- 2048
    signal press_threshold : std_logic_vector(11 downto 0) := x"A00";  -- 2560
    signal temp_threshold : std_logic_vector(11 downto 0) := x"600";   -- 1536
    signal flow_threshold : std_logic_vector(7 downto 0) := x"20";     -- 32
    
    signal emergency_stop : std_logic;
    signal ventilation_on : std_logic;
    signal chamber_shutdown : std_logic_vector(NUM_CHAMBERS-1 downto 0);
    
    signal safety_status : std_logic_vector(7 downto 0);
    signal error_code : std_logic_vector(7 downto 0);
    signal error_location : std_logic_vector(7 downto 0);
    
begin
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2;
    
    -- DUT instantiation
    DUT: entity work.safety_monitor
    port map (
        clk => clk,
        rst => rst,
        voc_levels => voc_levels,
        air_quality => air_quality,
        pressure_levels => pressure_levels,
        temperature => temperature,
        flow_sensors => flow_sensors,
        voc_threshold => voc_threshold,
        aq_threshold => aq_threshold,
        press_threshold => press_threshold,
        temp_threshold => temp_threshold,
        flow_threshold => flow_threshold,
        emergency_stop => emergency_stop,
        ventilation_on => ventilation_on,
        chamber_shutdown => chamber_shutdown,
        safety_status => safety_status,
        error_code => error_code,
        error_location => error_location
    );
    
    -- Test process
    test_proc: process
    begin
        -- Initialize
        wait for CLK_PERIOD * 2;
        rst <= '0';
        wait for CLK_PERIOD * 2;
        
        -- Test Case 1: Normal Operation
        report "Starting Normal Operation Test";
        voc_levels <= NORMAL_OPERATION.voc_level;        -- Below threshold
        air_quality <= NORMAL_OPERATION.aq_level;        -- Below threshold
        pressure_levels <= NORMAL_OPERATION.pressure;    -- Below threshold
        temperature <= NORMAL_OPERATION.temperature;     -- Below threshold
        flow_sensors <= NORMAL_OPERATION.flow_rate;      -- Above threshold
        
        wait for CLK_PERIOD * 10;
        check_safety_response(clk, emergency_stop, ventilation_on, '0', '0', "Normal Operation");
        
        -- Test Case 2: High VOC Level
        report "Starting High VOC Level Test";
        voc_levels <= x"900";  -- Above VOC threshold
        wait for CLK_PERIOD * 10;
        check_safety_response(clk, emergency_stop, ventilation_on, '0', '1', "High VOC");
        
        -- Test Case 3: Emergency Condition
        report "Starting Emergency Condition Test";
        -- Set all sensors to emergency levels
        voc_levels <= EMERGENCY_CONDITION.voc_level;     -- Very high
        air_quality <= EMERGENCY_CONDITION.aq_level;     -- Very high
        pressure_levels <= EMERGENCY_CONDITION.pressure; -- Very high
        temperature <= EMERGENCY_CONDITION.temperature;  -- Very high
        flow_sensors <= EMERGENCY_CONDITION.flow_rate;   -- Very low
        
        wait for CLK_PERIOD * 10;
        check_safety_response(clk, emergency_stop, ventilation_on, '1', '1', "Emergency");
        
        -- Test Case 4: Recovery
        report "Starting Recovery Test";
        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        -- Return to normal levels
        voc_levels <= NORMAL_OPERATION.voc_level;
        air_quality <= NORMAL_OPERATION.aq_level;
        pressure_levels <= NORMAL_OPERATION.pressure;
        temperature <= NORMAL_OPERATION.temperature;
        flow_sensors <= NORMAL_OPERATION.flow_rate;
        
        wait for CLK_PERIOD * 10;
        check_safety_response(clk, emergency_stop, ventilation_on, '0', '0', "Recovery");
        
        -- Test Case 5: Persistent Violation
        report "Starting Persistent Violation Test";
        -- Keep VOC high for multiple cycles to trigger persistent violation
        voc_levels <= x"900";  -- Above threshold
        wait for CLK_PERIOD * 100;  -- Wait for violation counter to exceed threshold
        check_safety_response(clk, emergency_stop, ventilation_on, '1', '1', "Persistent Violation");
        
        -- End simulation
        report "All tests completed";
        wait;
    end process;
    
end behavioral;