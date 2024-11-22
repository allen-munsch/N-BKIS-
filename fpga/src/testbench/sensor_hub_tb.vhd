library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_pkg.all;
use work.nebkiso_tb_pkg.all;

entity sensor_hub_tb is
end sensor_hub_tb;

architecture behavioral of sensor_hub_tb is
    -- Clock and reset
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    
    -- I2C interfaces
    signal scl : std_logic_vector(3 downto 0) := (others => 'Z');
    signal sda : std_logic_vector(3 downto 0) := (others => 'Z');
    
    -- SPI interfaces
    signal adc_spi_sclk : std_logic;
    signal adc_spi_mosi : std_logic;
    signal adc_spi_miso : std_logic := '0';
    signal adc_spi_cs_n : std_logic_vector(7 downto 0);
    
    -- Sensor data outputs
    signal voc_data : std_logic_vector(11 downto 0);
    signal aq_data : std_logic_vector(11 downto 0);
    signal pressure_data : std_logic_vector(11 downto 0);
    signal temp_data : std_logic_vector(11 downto 0);
    signal flow_data : std_logic_vector(7 downto 0);
    
    -- Calibration interface
    signal cal_mode : std_logic := '0';
    signal cal_data : std_logic_vector(15 downto 0) := (others => '0');
    signal cal_addr : std_logic_vector(7 downto 0) := (others => '0');
    signal cal_wr : std_logic := '0';
    
    -- Status outputs
    signal sensor_status : std_logic_vector(7 downto 0);
    signal error_flags : std_logic_vector(7 downto 0);
    
begin
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2;
    
    -- DUT instantiation
    DUT: entity work.sensor_hub
    port map (
        clk => clk,
        rst => rst,
        scl => scl,
        sda => sda,
        adc_spi_sclk => adc_spi_sclk,
        adc_spi_mosi => adc_spi_mosi,
        adc_spi_miso => adc_spi_miso,
        adc_spi_cs_n => adc_spi_cs_n,
        voc_data => voc_data,
        aq_data => aq_data,
        pressure_data => pressure_data,
        temp_data => temp_data,
        flow_data => flow_data,
        cal_mode => cal_mode,
        cal_data => cal_data,
        cal_addr => cal_addr,
        cal_wr => cal_wr,
        sensor_status => sensor_status,
        error_flags => error_flags
    );

    -- Test stimulus process
    test_proc: process
    begin
        report "Starting sensor hub tests...";
        
        -- Initialize
        wait for CLK_PERIOD * 2;
        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        
        -- Test Case 1: Normal Operation
        report "Test Case 1: Normal Operation";
        wait for CLK_PERIOD * 100;
        
        -- Test Case 2: Calibration
        report "Test Case 2: Calibration Mode";
        cal_mode <= '1';
        cal_addr <= x"00";  -- First calibration register
        cal_data <= x"0002";  -- Gain of 2
        cal_wr <= '1';
        wait for CLK_PERIOD * 2;
        cal_wr <= '0';
        wait for CLK_PERIOD * 100;
        
        -- Test Case 3: Read with new calibration
        report "Test Case 3: Reading with Calibration";
        cal_mode <= '0';
        wait for CLK_PERIOD * 100;
        
        -- End simulation
        report "Sensor hub tests completed";
        wait;
    end process;

end behavioral;