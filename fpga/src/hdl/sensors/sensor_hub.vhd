library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_pkg.all;

entity sensor_hub is
    port (
        -- System signals
        clk           : in  std_logic;
        rst           : in  std_logic;
        
        -- I2C interfaces for sensors
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
    -- Internal signals for sensor data
    type sensor_buffer_type is array (0 to 7) of unsigned(11 downto 0);
    signal voc_buffer : sensor_buffer_type := (others => (others => '0'));
    signal aq_buffer : sensor_buffer_type := (others => (others => '0'));
    signal pressure_buffer : sensor_buffer_type := (others => (others => '0'));
    signal temp_buffer : sensor_buffer_type := (others => (others => '0'));
    
    -- Calibration data storage (reduced size)
    type cal_data_array is array (0 to 7) of unsigned(7 downto 0);  -- Smaller calibration values
    signal cal_storage : cal_data_array := (others => to_unsigned(1, 8)); -- Default gain of 1
    
    -- State machine and control
    type sample_state_type is (IDLE, SAMPLE_VOC, SAMPLE_AQ, SAMPLE_PRESSURE, SAMPLE_TEMP, PROCESS_DATA);
    signal current_state : sample_state_type;
    signal sample_counter : unsigned(2 downto 0) := (others => '0');
    signal buffer_index : unsigned(2 downto 0) := (others => '0');

    -- Status signals
    signal sampling_active : std_logic := '0';
    signal processing_active : std_logic := '0';
    
begin
    -- Main control process
    main_proc: process(clk)
        variable avg_sum : unsigned(19 downto 0);  -- Adjusted size: 12 + 8 bits
    begin
        if rising_edge(clk) then
            if rst = '1' then
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
                error_flags <= (others => '0');
            else
                -- Handle calibration writes
                if cal_mode = '1' and cal_wr = '1' then
                    if unsigned(cal_addr) < 8 then
                        cal_storage(to_integer(unsigned(cal_addr))) <= 
                            unsigned(cal_data(7 downto 0));  -- Take only lower byte
                    end if;
                end if;
                
                -- Sensor sampling and processing
                case current_state is
                    when IDLE =>
                        current_state <= SAMPLE_VOC;
                        sampling_active <= '1';
                        processing_active <= '0';
                        
                    when SAMPLE_VOC =>
                        voc_buffer(to_integer(buffer_index)) <= to_unsigned(512, 12);
                        current_state <= SAMPLE_AQ;
                        
                    when SAMPLE_AQ =>
                        aq_buffer(to_integer(buffer_index)) <= to_unsigned(768, 12);
                        current_state <= SAMPLE_PRESSURE;
                        
                    when SAMPLE_PRESSURE =>
                        pressure_buffer(to_integer(buffer_index)) <= to_unsigned(1024, 12);
                        current_state <= SAMPLE_TEMP;
                        
                    when SAMPLE_TEMP =>
                        temp_buffer(to_integer(buffer_index)) <= to_unsigned(1280, 12);
                        current_state <= PROCESS_DATA;
                        sampling_active <= '0';
                        processing_active <= '1';
                        
                    when PROCESS_DATA =>
                        -- Process VOC data with safe scaling
                        avg_sum := (others => '0');
                        for i in 0 to 7 loop
                            if cal_storage(0) /= 0 then  -- Prevent division by zero
                                avg_sum := avg_sum + (voc_buffer(i) * cal_storage(0));
                            else
                                avg_sum := avg_sum + voc_buffer(i);
                            end if;
                        end loop;
                        -- Scale down by 3 bits (divide by 8 for averaging)
                        voc_data <= std_logic_vector(resize(avg_sum(19 downto 3), 12));

                        -- Process other sensors with simple averaging
                        avg_sum := (others => '0');
                        for i in 0 to 7 loop
                            avg_sum := avg_sum + resize(aq_buffer(i), 20);
                        end loop;
                        aq_data <= std_logic_vector(resize(avg_sum(19 downto 3), 12));

                        avg_sum := (others => '0');
                        for i in 0 to 7 loop
                            avg_sum := avg_sum + resize(pressure_buffer(i), 20);
                        end loop;
                        pressure_data <= std_logic_vector(resize(avg_sum(19 downto 3), 12));

                        avg_sum := (others => '0');
                        for i in 0 to 7 loop
                            avg_sum := avg_sum + resize(temp_buffer(i), 20);
                        end loop;
                        temp_data <= std_logic_vector(resize(avg_sum(19 downto 3), 12));
                        
                        -- Update buffer index
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
    
    -- Status output compilation
    sensor_status <= sampling_active & 
                    processing_active &
                    "000000";  -- Reserved bits
    
    -- SPI interface (simplified for simulation)
    adc_spi_sclk <= clk;
    adc_spi_mosi <= '0';
    adc_spi_cs_n <= (others => '1');
    
end behavioral;