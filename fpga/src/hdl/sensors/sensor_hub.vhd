library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_pkg.all;

entity sensor_hub is
    port (
        -- System signals
        clk           : in  std_logic;
        rst           : in  std_logic;
        
        -- -- I2C interfaces for sensors
        scl           : inout std_logic_vector(3 downto 0);
        sda           : inout std_logic_vector(3 downto 0);
        
        -- ADC interfaces
        adc_spi_sclk  : out std_logic;
        adc_spi_mosi  : out std_logic;
        adc_spi_miso  : in  std_logic;
        adc_spi_cs_n  : out std_logic_vector(7 downto 0);
        
        -- Processed sensor data outputs
        voc_data      : out std_logic_vector(11 downto 0);
        aq_data       : out std_logic_vector(11 downto 0);
        pressure_data : out std_logic_vector(11 downto 0);
        temp_data     : out std_logic_vector(11 downto 0);
        flow_data     : out std_logic_vector(7 downto 0);
        
        -- Calibration interface
        cal_mode      : in  std_logic;
        cal_data      : in  std_logic_vector(15 downto 0);
        cal_addr      : in  std_logic_vector(7 downto 0);
        cal_wr        : in  std_logic;
        
        -- Status outputs
        sensor_status : out std_logic_vector(7 downto 0);
        error_flags   : out std_logic_vector(7 downto 0)
    );
end entity sensor_hub;

architecture behavioral of sensor_hub is
    -- Constants for thresholds and timing
    constant THRESHOLD_VOC    : unsigned(11 downto 0) := x"800";  -- VOC threshold
    constant THRESHOLD_AQ     : unsigned(11 downto 0) := x"800";  -- Air quality threshold
    constant THRESHOLD_PRESS  : unsigned(11 downto 0) := x"800";  -- Pressure threshold
    constant THRESHOLD_TEMP   : unsigned(11 downto 0) := x"800";  -- Temperature threshold
    constant TIMEOUT_VALUE    : unsigned(15 downto 0) := x"FFFF"; -- Sampling timeout
    constant ADC_BITS        : integer := 12;                     -- ADC resolution
    constant SPI_CYCLES      : integer := 16;                     -- SPI transaction cycles

    -- Internal signals for sensor data buffers
    type sensor_buffer_type is array (0 to 7) of unsigned(11 downto 0);
    signal voc_buffer      : sensor_buffer_type := (others => (others => '0'));
    signal aq_buffer       : sensor_buffer_type := (others => (others => '0'));
    signal pressure_buffer : sensor_buffer_type := (others => (others => '0'));
    signal temp_buffer     : sensor_buffer_type := (others => (others => '0'));
    signal voc_data_internal : std_logic_vector(11 downto 0);
    signal aq_data_internal  : std_logic_vector(11 downto 0);
        
    -- Calibration data storage
    type cal_data_array is array (0 to 7) of unsigned(7 downto 0);
    signal cal_storage : cal_data_array := (others => to_unsigned(1, 8)); -- Default gain of 1
    
    -- State machine types and control
    type sample_state_type is (
        IDLE,
        SAMPLE_VOC,
        SAMPLE_AQ,
        SAMPLE_PRESSURE,
        SAMPLE_TEMP,
        PROCESS_DATA
    );
    signal current_state    : sample_state_type;
    signal sample_counter   : unsigned(2 downto 0) := (others => '0');
    signal buffer_index     : unsigned(2 downto 0) := (others => '0');

    -- SPI control signals
    signal spi_active      : std_logic := '0';
    signal spi_done        : std_logic := '0';
    signal spi_counter     : unsigned(4 downto 0) := (others => '0');
    signal spi_data_out    : std_logic_vector(15 downto 0);
    signal spi_data_in     : std_logic_vector(15 downto 0);
    signal current_channel : unsigned(2 downto 0) := (others => '0');
    
    -- Status signals
    signal sampling_active    : std_logic := '0';
    signal processing_active : std_logic := '0';
    signal sample_timeout    : unsigned(15 downto 0) := (others => '0');
    signal adc_valid         : std_logic := '0';

    -- Helper function to check if in sampling state
    function is_sampling(state : sample_state_type) return boolean is
    begin
        return state = SAMPLE_VOC or 
               state = SAMPLE_AQ or 
               state = SAMPLE_PRESSURE or 
               state = SAMPLE_TEMP;
    end function;

    -- Add chip select control signal here in declarations
    signal cs_control      : std_logic_vector(7 downto 0);

begin
    -- Assign default values to unused ports
    scl <= (others => 'Z');  -- Reserved for future I2C implementation
    sda <= (others => 'Z');  -- Reserved for future I2C implementation
    -- Main control process
    main_proc: process(clk)
        variable avg_sum : unsigned(19 downto 0);  -- Sized for 12-bit values * 8 samples
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset all outputs and internal signals
                current_state <= IDLE;
                sample_counter <= (others => '0');
                buffer_index <= (others => '0');
                voc_data <= (others => '0');
                aq_data <= (others => '0');
                pressure_data <= (others => '0');
                temp_data <= (others => '0');
                flow_data <= (others => '0');
                sampling_active <= '0';
                processing_active <= '0';
                
            else
                -- Handle calibration writes
                if cal_mode = '1' and cal_wr = '1' then
                    if unsigned(cal_addr) < 8 then
                        cal_storage(to_integer(unsigned(cal_addr))) <= unsigned(cal_data(7 downto 0));
                    end if;
                end if;
                
                -- Main state machine
                case current_state is
                    when IDLE =>
                        current_state <= SAMPLE_VOC;
                        sampling_active <= '1';
                        processing_active <= '0';
                        
                    when SAMPLE_VOC =>
                        if adc_valid = '1' then
                            voc_buffer(to_integer(buffer_index)) <= unsigned(spi_data_in(11 downto 0));
                            current_state <= SAMPLE_AQ;
                        end if;
                        
                    when SAMPLE_AQ =>
                        if adc_valid = '1' then
                            aq_buffer(to_integer(buffer_index)) <= unsigned(spi_data_in(11 downto 0));
                            current_state <= SAMPLE_PRESSURE;
                        end if;
                        
                    when SAMPLE_PRESSURE =>
                        if adc_valid = '1' then
                            pressure_buffer(to_integer(buffer_index)) <= unsigned(spi_data_in(11 downto 0));
                            current_state <= SAMPLE_TEMP;
                        end if;
                        
                    when SAMPLE_TEMP =>
                        if adc_valid = '1' then
                            temp_buffer(to_integer(buffer_index)) <= unsigned(spi_data_in(11 downto 0));
                            current_state <= PROCESS_DATA;
                            sampling_active <= '0';
                            processing_active <= '1';
                        end if;
                        
                    when PROCESS_DATA =>
                        -- Process VOC data with calibration
                        avg_sum := (others => '0');
                        for i in 0 to 7 loop
                            avg_sum := avg_sum + (voc_buffer(i) * cal_storage(0));
                        end loop;
                        voc_data_internal <= std_logic_vector(resize(avg_sum(19 downto 3), 12));

                        -- Process AQ data
                        avg_sum := (others => '0');
                        for i in 0 to 7 loop
                            avg_sum := avg_sum + (aq_buffer(i) * cal_storage(1));
                        end loop;
                        aq_data_internal <= std_logic_vector(resize(avg_sum(19 downto 3), 12));

                        -- Process pressure data
                        avg_sum := (others => '0');
                        for i in 0 to 7 loop
                            avg_sum := avg_sum + (pressure_buffer(i) * cal_storage(2));
                        end loop;
                        pressure_data <= std_logic_vector(resize(avg_sum(19 downto 3), 12));

                        -- Process temperature data
                        avg_sum := (others => '0');
                        for i in 0 to 7 loop
                            avg_sum := avg_sum + (temp_buffer(i) * cal_storage(3));
                        end loop;
                        temp_data <= std_logic_vector(resize(avg_sum(19 downto 3), 12));
                        
                        -- Update buffer index and return to IDLE
                        if buffer_index = 7 then
                            buffer_index <= (others => '0');
                        else
                            buffer_index <= buffer_index + 1;
                        end if;
                        
                        current_state <= IDLE;
                        processing_active <= '0';
                end case;
            end if;
        end if;
    end process;

    -- SPI control process
    spi_control: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                spi_counter <= (others => '0');
                spi_active <= '0';
                spi_done <= '0';
                adc_spi_sclk <= '1';
                adc_spi_mosi <= '0';
                adc_valid <= '0';
                
            else
                adc_valid <= '0';  -- Default state
                spi_done <= '0';
                
                if is_sampling(current_state) then
                    -- Start new SPI transaction
                    if spi_active = '0' then
                        spi_active <= '1';
                        spi_counter <= (others => '0');
                        spi_data_out <= x"0000";  -- Command for ADC read
                    elsif spi_active = '1' then
                        -- Generate SPI clock and handle data
                        if spi_counter < SPI_CYCLES then
                            spi_counter <= spi_counter + 1;
                            
                            -- Toggle SPI clock
                            if spi_counter(0) = '0' then
                                adc_spi_sclk <= '0';
                                -- Shift out MOSI data
                                adc_spi_mosi <= spi_data_out(15);
                                spi_data_out <= spi_data_out(14 downto 0) & '0';
                            else
                                adc_spi_sclk <= '1';
                                -- Sample MISO data
                                spi_data_in <= spi_data_in(14 downto 0) & adc_spi_miso;
                            end if;
                        else
                            -- End of transaction
                            spi_active <= '0';
                            spi_done <= '1';
                            adc_valid <= '1';
                            adc_spi_sclk <= '1';
                        end if;
                    end if;
                else
                    -- Idle state
                    spi_active <= '0';
                    adc_spi_sclk <= '1';
                    adc_spi_mosi <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Status monitoring process
    status_monitor: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sensor_status <= (others => '0');
                error_flags <= (others => '0');
                sample_timeout <= (others => '0');
            else
                -- Check for out-of-range values
                if unsigned(voc_data_internal) > THRESHOLD_VOC then
                    sensor_status(0) <= '1';
                    error_flags(0) <= '1';
                else
                    sensor_status(0) <= '0';
                    error_flags(0) <= '0';
                end if;
                
                if unsigned(aq_data_internal) > THRESHOLD_AQ then
                    sensor_status(1) <= '1';
                    error_flags(1) <= '1';
                else
                    sensor_status(1) <= '0';
                    error_flags(1) <= '0';
                end if;
                
                -- Timeout detection
                if is_sampling(current_state) then
                    if spi_done = '0' then
                        sample_timeout <= sample_timeout + 1;
                        if sample_timeout = TIMEOUT_VALUE then
                            error_flags(7) <= '1';  -- Timeout error
                        end if;
                    else
                        sample_timeout <= (others => '0');
                    end if;
                else
                    sample_timeout <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    

    -- Chip select control process
    cs_control_proc: process(rst, current_state)
    begin
        if rst = '1' then
            cs_control <= (others => '1');
        else
            case current_state is
                when SAMPLE_VOC =>
                    cs_control <= "11111110";  -- CS0 active
                when SAMPLE_AQ =>
                    cs_control <= "11111101";  -- CS1 active
                when SAMPLE_PRESSURE =>
                    cs_control <= "11111011";  -- CS2 active
                when SAMPLE_TEMP =>
                    cs_control <= "11110111";  -- CS3 active
                when others =>
                    cs_control <= (others => '1');
            end case;
        end if;
    end process;

    -- Assign chip select output
    adc_spi_cs_n <= cs_control;

end architecture behavioral;