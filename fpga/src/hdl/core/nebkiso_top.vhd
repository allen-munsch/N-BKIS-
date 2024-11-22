library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_pkg.all;
use work.nebkiso_types.all;

entity nebkiso_top is
    port (
        -- System clocks and reset
        clk_in          : in  std_logic;
        ext_rst_n       : in  std_logic;
        
        -- Watchdog interface
        watchdog_kick   : out std_logic;
        watchdog_error  : in  std_logic;
        
        -- External sensor interfaces
        -- SPI ADC
        adc_spi_sclk    : out std_logic;
        adc_spi_mosi    : out std_logic;
        adc_spi_miso    : in  std_logic;
        adc_spi_cs_n    : out std_logic_vector(7 downto 0);
        
        -- I2C Sensors
        scl             : inout std_logic_vector(3 downto 0);
        sda             : inout std_logic_vector(3 downto 0);
        
        -- Flow sensors
        flow_pulse      : in  std_logic_vector(7 downto 0);
        
        -- Safety outputs (dual redundant)
        emergency_stop_a : out std_logic;
        emergency_stop_b : out std_logic;
        ventilation_on_a : out std_logic;
        ventilation_on_b : out std_logic;
        chamber_shut_a   : out std_logic_vector(NUM_CHAMBERS-1 downto 0);
        chamber_shut_b   : out std_logic_vector(NUM_CHAMBERS-1 downto 0);
        
        -- System status and control
        operational_mode : in  std_logic_vector(1 downto 0);
        self_test_req   : in  std_logic;
        error_reset     : in  std_logic;
        
        -- Calibration interface
        cal_mode        : in  std_logic;
        cal_data        : in  std_logic_vector(15 downto 0);
        cal_addr        : in  std_logic_vector(7 downto 0);
        cal_wr          : in  std_logic;
        
        -- Threshold settings
        voc_threshold    : in std_logic_vector(11 downto 0);
        aq_threshold     : in std_logic_vector(11 downto 0);
        press_threshold  : in std_logic_vector(11 downto 0);
        temp_threshold   : in std_logic_vector(11 downto 0);
        flow_threshold   : in std_logic_vector(7 downto 0);
        
        -- External communication interface
        uart_rx         : in  std_logic;
        uart_tx         : out std_logic;
        
        -- Status outputs
        system_status   : out std_logic_vector(7 downto 0);
        error_code      : out std_logic_vector(7 downto 0);
        heartbeat       : out std_logic
    );
end nebkiso_top;

architecture behavioral of nebkiso_top is
    -- Internal clock signals
    signal clk_sys      : std_logic;
    signal clk_sample   : std_logic;
    signal clk_control  : std_logic;
    signal pll_locked   : std_logic;
    
    -- Internal reset management
    signal rst_n_sync   : std_logic;
    signal system_rst   : std_logic;
    signal safety_rst   : std_logic;
    
    -- Watchdog signals
    signal watchdog_counter : unsigned(23 downto 0);
    signal watchdog_timeout : std_logic;
    
    -- Sensor data
    signal voc_data     : std_logic_vector(11 downto 0);
    signal aq_data      : std_logic_vector(11 downto 0);
    signal press_data   : std_logic_vector(11 downto 0);
    signal temp_data    : std_logic_vector(11 downto 0);
    signal flow_data    : std_logic_vector(7 downto 0);
    
    -- Safety monitor signals (dual redundant)
    signal emergency_stop_int_a : std_logic;
    signal emergency_stop_int_b : std_logic;
    signal ventilation_on_int_a : std_logic;
    signal ventilation_on_int_b : std_logic;
    
    -- Error handling
    signal error_status : std_logic_vector(15 downto 0);
    signal error_counter : unsigned(7 downto 0);
    
    -- System state
    signal current_state : system_state_type;
    signal self_test_active : std_logic;
    signal sensor_status : std_logic_vector(7 downto 0);
    
    -- Heartbeat generator
    signal heartbeat_counter : unsigned(24 downto 0);
    
begin
    -- Clock management instantiation
    clock_manager_inst : entity work.clock_manager
        port map (
            clk_in      => clk_in,
            rst         => system_rst,
            clk_sys     => clk_sys,
            clk_sample  => clk_sample,
            clk_control => clk_control,
            locked      => pll_locked
        );
        
    -- Reset synchronization and management
    reset_sync_proc : process(clk_sys)
        variable sync_ff : std_logic_vector(2 downto 0);
    begin
        if rising_edge(clk_sys) then
            sync_ff := sync_ff(1 downto 0) & ext_rst_n;
            rst_n_sync <= sync_ff(2);
            
            -- Generate system reset from multiple sources
            if rst_n_sync = '0' or watchdog_timeout = '1' or 
               watchdog_error = '1' or pll_locked = '0' then
                system_rst <= '1';
            else
                system_rst <= '0';
            end if;
            
            -- Additional safety reset includes error conditions
            if system_rst = '1' or error_counter > x"FF" then
                safety_rst <= '1';
            else
                safety_rst <= '0';
            end if;
        end if;
    end process;
    
    -- Sensor hub instantiation
    sensor_hub_inst : entity work.sensor_hub
        port map (
            clk           => clk_sys,
            rst           => system_rst,
            scl           => scl,
            sda           => sda,
            adc_spi_sclk  => adc_spi_sclk,
            adc_spi_mosi  => adc_spi_mosi,
            adc_spi_miso  => adc_spi_miso,
            adc_spi_cs_n  => adc_spi_cs_n,
            cal_mode      => cal_mode,
            cal_data      => cal_data,
            cal_addr      => cal_addr,
            cal_wr        => cal_wr,
            voc_data      => voc_data,
            aq_data       => aq_data,
            pressure_data => press_data,
            temp_data     => temp_data,
            flow_data     => flow_data,
            sensor_status => sensor_status,
            error_flags   => error_status(7 downto 0)
        );
    
    -- Dual redundant safety monitors
    safety_monitor_a : entity work.safety_monitor
        port map (
            clk              => clk_sys,
            rst              => safety_rst,
            voc_levels       => voc_data,
            air_quality      => aq_data,
            pressure_levels  => press_data,
            temperature      => temp_data,
            flow_sensors     => flow_data,
            voc_threshold    => voc_threshold,
            aq_threshold     => aq_threshold,
            press_threshold  => press_threshold,
            temp_threshold   => temp_threshold,
            flow_threshold   => flow_threshold,
            emergency_stop   => emergency_stop_int_a,
            ventilation_on   => ventilation_on_int_a,
            chamber_shutdown => chamber_shut_a,
            safety_status    => open,
            error_code       => error_status(15 downto 8),
            error_location   => open
        );
        
    safety_monitor_b : entity work.safety_monitor
        port map (
            clk              => clk_sys,
            rst              => safety_rst,
            voc_levels       => voc_data,
            air_quality      => aq_data,
            pressure_levels  => press_data,
            temperature      => temp_data,
            flow_sensors     => flow_data,
            voc_threshold    => voc_threshold,
            aq_threshold     => aq_threshold,
            press_threshold  => press_threshold,
            temp_threshold   => temp_threshold,
            flow_threshold   => flow_threshold,
            emergency_stop   => emergency_stop_int_b,
            ventilation_on   => ventilation_on_int_b,
            chamber_shutdown => chamber_shut_b,
            safety_status    => open,
            error_code       => open,
            error_location   => open
        );
    
    -- Watchdog process
    watchdog_proc : process(clk_sys)
    begin
        if rising_edge(clk_sys) then
            if system_rst = '1' then
                watchdog_counter <= (others => '0');
                watchdog_timeout <= '0';
            else
                -- Counter increments every clock cycle
                watchdog_counter <= watchdog_counter + 1;
                
                -- Timeout if counter reaches maximum
                if watchdog_counter = x"FFFFFF" then
                    watchdog_timeout <= '1';
                end if;
                
                -- Reset counter on watchdog kick
                if current_state = RUNNING and error_status = x"0000" then
                    watchdog_counter <= (others => '0');
                    watchdog_timeout <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- Heartbeat generator
    heartbeat_proc : process(clk_sys)
    begin
        if rising_edge(clk_sys) then
            if system_rst = '1' then
                heartbeat_counter <= (others => '0');
                heartbeat <= '0';
            else
                heartbeat_counter <= heartbeat_counter + 1;
                if heartbeat_counter = x"1FFFFFF" then
                    heartbeat_counter <= (others => '0');
                    heartbeat <= not heartbeat;
                end if;
            end if;
        end if;
    end process;
    
    -- State machine process
    state_machine : process(clk_sys)
    begin
        if rising_edge(clk_sys) then
            if system_rst = '1' then
                current_state <= INIT;
            else
                case current_state is
                    when INIT =>
                        if pll_locked = '1' and error_status = x"0000" then
                            current_state <= IDLE;
                        end if;
                        
                    when IDLE =>
                        if cal_mode = '1' then
                            current_state <= CALIBRATING;
                        elsif operational_mode /= "00" and error_status = x"0000" then
                            current_state <= RUNNING;
                        end if;
                        
                    when CALIBRATING =>
                        if cal_mode = '0' then
                            current_state <= IDLE;
                        end if;
                        
                    when RUNNING =>
                        if error_status /= x"0000" then
                            current_state <= FAULT;
                        elsif emergency_stop_int_a = '1' or emergency_stop_int_b = '1' then
                            current_state <= EMERGENCY;
                        end if;
                        
                    when EMERGENCY =>
                        if error_reset = '1' and error_status = x"0000" then
                            current_state <= IDLE;
                        end if;
                        
                    when FAULT =>
                        if error_reset = '1' and error_status = x"0000" then
                            current_state <= IDLE;
                        end if;
                        
                    when others =>
                        current_state <= INIT;
                end case;
            end if;
        end if;
    end process;
    
    -- Safety output voting
    -- Only activate safety outputs if both monitors agree
    emergency_stop_a <= emergency_stop_int_a and emergency_stop_int_b;
    emergency_stop_b <= emergency_stop_int_a and emergency_stop_int_b;
    ventilation_on_a <= ventilation_on_int_a and ventilation_on_int_b;
    ventilation_on_b <= ventilation_on_int_a and ventilation_on_int_b;
    
    -- Status outputs
    system_status <= std_logic_vector(to_unsigned(system_state_type'pos(current_state), 2)) & 
                    sensor_status(3 downto 0) &
                    pll_locked &
                    watchdog_timeout &
                    safety_rst;
    
    -- Error code output
    error_code <= error_status(7 downto 0);
    
    -- Watchdog kick output
    watchdog_kick <= not watchdog_timeout;

end behavioral;