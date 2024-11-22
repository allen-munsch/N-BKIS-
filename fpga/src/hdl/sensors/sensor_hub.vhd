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
end sensor_hub;

architecture behavioral of sensor_hub is
    type sensor_state_type is (INIT, CALIBRATE, SAMPLE, PROCESS);
    signal current_state : sensor_state_type;
    
    -- Calibration data storage
    type cal_data_array is array (0 to 255) of std_logic_vector(15 downto 0);
    signal cal_storage : cal_data_array;
    
    -- Sensor sampling counters
    signal sample_counter : unsigned(15 downto 0);
    signal sensor_select : unsigned(2 downto 0);
    
    -- Moving average buffers
    type avg_buffer is array (0 to 7) of unsigned(15 downto 0);
    signal voc_buffer : avg_buffer;
    signal aq_buffer : avg_buffer;
    signal pressure_buffer : avg_buffer;
    signal temp_buffer : avg_buffer;
    
begin
    process(clk, rst)
        variable avg_sum : unsigned(18 downto 0);
    begin
        if rst = '1' then
            current_state <= INIT;
            sensor_select <= (others => '0');
            sample_counter <= (others => '0');
            sensor_status <= (others => '0');
            error_flags <= (others => '0');
        elsif rising_edge(clk) then
            case current_state is
                when INIT =>
                    -- Initialize sensors
                    if sensor_select = 7 then
                        current_state <= CALIBRATE;
                        sensor_select <= (others => '0');
                    else
                        sensor_select <= sensor_select + 1;
                    end if;
                    
                when CALIBRATE =>
                    -- Apply calibration data
                    if cal_mode = '1' and cal_wr = '1' then
                        cal_storage(to_integer(unsigned(cal_addr))) <= cal_data;
                    end if;
                    
                    if sensor_select = 7 then
                        current_state <= SAMPLE;
                        sensor_select <= (others => '0');
                    else
                        sensor_select <= sensor_select + 1;
                    end if;
                    
                when SAMPLE =>
                    -- Sample each sensor type
                    case to_integer(sensor_select) is
                        when 0 => -- VOC
                            voc_buffer(to_integer(sample_counter(2 downto 0))) <= 
                                unsigned(cal_storage(0)) * unsigned(adc_read(0));
                        when 1 => -- Air Quality
                            aq_buffer(to_integer(sample_counter(2 downto 0))) <= 
                                unsigned(cal_storage(1)) * unsigned(adc_read(1));
                        when 2 => -- Pressure
                            pressure_buffer(to_integer(sample_counter(2 downto 0))) <= 
                                unsigned(cal_storage(2)) * unsigned(adc_read(2));
                        when 3 => -- Temperature
                            temp_buffer(to_integer(sample_counter(2 downto 0))) <= 
                                unsigned(cal_storage(3)) * unsigned(adc_read(3));
                        when others =>
                            null;
                    end case;
                    
                    if sensor_select = 3 then
                        current_state <= PROCESS;
                        sensor_select <= (others => '0');
                    else
                        sensor_select <= sensor_select + 1;
                    end if;
                    
                when PROCESS =>
                    -- Calculate moving averages
                    avg_sum := (others => '0');
                    
                    -- VOC average
                    for i in 0 to 7 loop
                        avg_sum := avg_sum + voc_buffer(i);
                    end loop;
                    voc_data <= std_logic_vector(avg_sum(18 downto 7));
                    
                    -- Similar processing for other sensors
                    -- Reset for next sampling cycle
                    sample_counter <= sample_counter + 1;
                    current_state <= SAMPLE;
                    
            end case;
        end if;
    end process;
    
    -- ADC read function (simplified)
    function adc_read(channel : integer) return std_logic_vector is
        variable result : std_logic_vector(11 downto 0);
    begin
        -- Actual implementation would handle SPI communication
        return result;
    end function;
end behavioral;