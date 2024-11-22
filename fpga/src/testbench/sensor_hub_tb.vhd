library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_pkg.all;

entity sensor_hub_tb is
end entity sensor_hub_tb;

architecture sim of sensor_hub_tb is
    -- Clock period definitions
    constant CLK_PERIOD : time := 10 ns;
    
    -- Test thresholds and limits
    constant VOC_NORMAL     : std_logic_vector(11 downto 0) := x"400";  -- Normal VOC level
    constant VOC_HIGH       : std_logic_vector(11 downto 0) := x"900";  -- Above threshold
    constant AQ_NORMAL      : std_logic_vector(11 downto 0) := x"300";
    constant PRESS_NORMAL   : std_logic_vector(11 downto 0) := x"500";
    constant TEMP_NORMAL    : std_logic_vector(11 downto 0) := x"400";
    
    -- Component signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal scl : std_logic_vector(3 downto 0);
    signal sda : std_logic_vector(3 downto 0);
    signal adc_spi_sclk : std_logic;
    signal adc_spi_mosi : std_logic;
    signal adc_spi_miso : std_logic := '0';
    signal adc_spi_cs_n : std_logic_vector(7 downto 0);
    signal voc_data : std_logic_vector(11 downto 0);
    signal aq_data : std_logic_vector(11 downto 0);
    signal pressure_data : std_logic_vector(11 downto 0);
    signal temp_data : std_logic_vector(11 downto 0);
    signal flow_data : std_logic_vector(7 downto 0);
    signal cal_mode : std_logic := '0';
    signal cal_data : std_logic_vector(15 downto 0) := (others => '0');
    signal cal_addr : std_logic_vector(7 downto 0) := (others => '0');
    signal cal_wr : std_logic := '0';
    signal sensor_status : std_logic_vector(7 downto 0);
    signal error_flags : std_logic_vector(7 downto 0);

    -- Test control signals
    signal test_phase : integer := 0;
    signal error_count : integer := 0;
    signal test_done : boolean := false;

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

    -- ADC response simulation process
    adc_sim: process
        variable adc_value : std_logic_vector(11 downto 0);
    begin
        wait until falling_edge(adc_spi_cs_n(0)); -- Wait for VOC sensor select
        
        case test_phase is
            when 0 => -- Normal operation
                adc_value := VOC_NORMAL;
            when 1 => -- High VOC test
                adc_value := VOC_HIGH;
            when others =>
                adc_value := (others => '0');
        end case;
        
        -- Simulate ADC response
        for i in 11 downto 0 loop
            wait until falling_edge(adc_spi_sclk);
            adc_spi_miso <= adc_value(i);
            wait until rising_edge(adc_spi_sclk);
        end loop;
        
        wait until rising_edge(adc_spi_cs_n(0));
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Reset phase
        rst <= '1';
        wait for CLK_PERIOD*10;
        rst <= '0';
        wait for CLK_PERIOD*2;
        
        -- Test Phase 0: Normal Operation
        test_phase <= 0;
        report "Starting normal operation test";
        wait for CLK_PERIOD*100;
        
        -- Verify normal readings
        assert unsigned(voc_data) <= x"800"
            report "VOC level should be normal" severity error;            

        -- Test Phase 1: High VOC Test
        test_phase <= 1;
        report "Starting high VOC test";
        wait for CLK_PERIOD*100;
        
        -- Verify error detection
        assert error_flags(0) = '1' 
            report "High VOC should trigger error flag" severity error;
            
        -- End simulation
        test_done <= true;
        wait for CLK_PERIOD*100;
        report "Simulation completed with " & integer'image(error_count) & " errors";
        wait;
    end process;
    
    -- Monitor process
    monitor_proc: process(clk)
    begin
        if rising_edge(clk) then
            -- Monitor VOC levels
            if unsigned(voc_data) > x"800" then
                report "VOC data overflow detected: " & 
                      integer'image(to_integer(unsigned(voc_data)))
                      severity note;
            end if;
            
            -- Count errors
            if error_flags /= x"00" then
                error_count <= error_count + 1;
            end if;
        end if;
    end process;

end architecture sim;