library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_controller is
    port (
        -- System signals
        clk         : in    std_logic;
        rst         : in    std_logic;
        
        -- I2C signals
        scl         : inout std_logic;
        sda         : inout std_logic;
        
        -- Control interface
        ctrl_start  : in    std_logic;  -- Start transaction
        ctrl_stop   : in    std_logic;  -- Stop transaction
        read_en     : in    std_logic;  -- Read enable
        write_en    : in    std_logic;  -- Write enable
        slave_addr  : in    std_logic_vector(6 downto 0);  -- Renamed from addr
        data_in     : in    std_logic_vector(7 downto 0);
        data_out    : out   std_logic_vector(7 downto 0);
        busy        : out   std_logic;
        ack_error   : out   std_logic
    );
end i2c_controller;

architecture behavioral of i2c_controller is
    type i2c_state_type is (IDLE, START, SEND_ADDR, ADDR_ACK, WRITE_DATA, READ_DATA, DATA_ACK, STOP);
    signal state : i2c_state_type;
    
    -- Internal signals
    signal scl_clk      : std_logic;
    signal sda_int      : std_logic;
    signal scl_int      : std_logic;
    signal bit_counter  : integer range 0 to 7;
    signal shift_reg    : std_logic_vector(7 downto 0);
    signal data_phase   : std_logic;  -- '0' for address phase, '1' for data phase
    signal read_mode    : std_logic;  -- Latched read/write mode
    
begin
    -- I2C clock generation (100kHz from 100MHz clock)
    scl_clk_gen: process(clk, rst)
        variable counter : integer range 0 to 499 := 0;
    begin
        if rst = '1' then
            counter := 0;
            scl_clk <= '1';
        elsif rising_edge(clk) then
            if counter = 499 then
                counter := 0;
                scl_clk <= not scl_clk;
            else
                counter := counter + 1;
            end if;
        end if;
    end process;
    
    -- Main I2C state machine
    i2c_fsm: process(scl_clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            busy <= '0';
            ack_error <= '0';
            sda_int <= '1';
            scl_int <= '1';
            bit_counter <= 7;
            data_phase <= '0';
            read_mode <= '0';
            shift_reg <= (others => '0');
            data_out <= (others => '0');
            
        elsif rising_edge(scl_clk) then
            case state is
                when IDLE =>
                    if ctrl_start = '1' then
                        state <= START;
                        busy <= '1';
                        read_mode <= read_en;
                        shift_reg <= slave_addr & read_en;  -- Prepare address + R/W bit
                    else
                        sda_int <= '1';
                        scl_int <= '1';
                        busy <= '0';
                    end if;
                    
                when START =>
                    sda_int <= '0';  -- START condition: SDA goes low while SCL is high
                    state <= SEND_ADDR;
                    bit_counter <= 7;
                    
                when SEND_ADDR =>
                    sda_int <= shift_reg(bit_counter);
                    if bit_counter = 0 then
                        state <= ADDR_ACK;
                    else
                        bit_counter <= bit_counter - 1;
                    end if;
                    
                when ADDR_ACK =>
                    sda_int <= '1';  -- Release SDA for slave ACK
                    if sda = '0' then  -- ACK received
                        if read_mode = '1' then
                            state <= READ_DATA;
                        else
                            state <= WRITE_DATA;
                            shift_reg <= data_in;  -- Load data for writing
                        end if;
                        bit_counter <= 7;
                        data_phase <= '1';
                    else
                        ack_error <= '1';
                        state <= STOP;
                    end if;
                    
                when WRITE_DATA =>
                    sda_int <= shift_reg(bit_counter);
                    if bit_counter = 0 then
                        state <= DATA_ACK;
                    else
                        bit_counter <= bit_counter - 1;
                    end if;
                    
                when READ_DATA =>
                    shift_reg(bit_counter) <= sda;
                    if bit_counter = 0 then
                        state <= DATA_ACK;
                        data_out <= shift_reg;
                    else
                        bit_counter <= bit_counter - 1;
                    end if;
                    
                when DATA_ACK =>
                    if ctrl_stop = '1' then
                        state <= STOP;
                    elsif read_mode = '1' then
                        state <= READ_DATA;
                        bit_counter <= 7;
                    else
                        if data_in = shift_reg then  -- Check if new data to send
                            state <= STOP;
                        else
                            state <= WRITE_DATA;
                            shift_reg <= data_in;
                            bit_counter <= 7;
                        end if;
                    end if;
                    
                when STOP =>
                    sda_int <= '0';
                    if scl_int = '1' then
                        sda_int <= '1';  -- STOP condition: SDA goes high while SCL is high
                        state <= IDLE;
                    end if;
                    
            end case;
        end if;
    end process;
    
    -- I2C pin control
    scl <= '0' when scl_int = '0' else 'Z';
    sda <= '0' when sda_int = '0' else 'Z';
    
end behavioral;