library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_controller is
    generic (
        CLKS_PER_BIT : integer := 868  -- 100MHz / 115200 baud
    );
    port (
        -- System signals
        clk      : in  std_logic;
        rst      : in  std_logic;
        -- UART signals
        rx       : in  std_logic;
        tx       : out std_logic;
        -- Data interface
        tx_data  : in  std_logic_vector(7 downto 0);
        tx_start : in  std_logic;
        tx_busy  : out std_logic;
        rx_data  : out std_logic_vector(7 downto 0);
        rx_done  : out std_logic
    );
end uart_controller;

architecture behavioral of uart_controller is
    type uart_state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal tx_state : uart_state_type;
    signal rx_state : uart_state_type;
    
    -- Additional signals for RX
    signal rx_clk_count : integer range 0 to CLKS_PER_BIT-1;
    signal rx_bit_index : integer range 0 to 7;
    signal rx_buffer    : std_logic_vector(7 downto 0);
    signal rx_sync      : std_logic_vector(1 downto 0);  -- For metastability prevention
    
    -- Additional signals for TX
    signal tx_clk_count : integer range 0 to CLKS_PER_BIT-1;
    signal tx_bit_index : integer range 0 to 7;
    signal tx_buffer    : std_logic_vector(7 downto 0);
    
begin
    -- UART TX process
    tx_proc: process(clk, rst)
    begin
        if rst = '1' then
            tx_state <= IDLE;
            tx <= '1';        -- Line idles high
            tx_busy <= '0';
            tx_clk_count <= 0;
            tx_bit_index <= 0;
            tx_buffer <= (others => '0');
            
        elsif rising_edge(clk) then
            case tx_state is
                when IDLE =>
                    tx <= '1';
                    tx_busy <= '0';
                    tx_clk_count <= 0;
                    tx_bit_index <= 0;
                    
                    if tx_start = '1' then
                        tx_state <= START_BIT;
                        tx_busy <= '1';
                        tx_buffer <= tx_data;
                    end if;
                    
                when START_BIT =>
                    tx <= '0';  -- Start bit is low
                    
                    if tx_clk_count = CLKS_PER_BIT-1 then
                        tx_state <= DATA_BITS;
                        tx_clk_count <= 0;
                    else
                        tx_clk_count <= tx_clk_count + 1;
                    end if;
                    
                when DATA_BITS =>
                    tx <= tx_buffer(tx_bit_index);
                    
                    if tx_clk_count = CLKS_PER_BIT-1 then
                        tx_clk_count <= 0;
                        
                        if tx_bit_index = 7 then
                            tx_state <= STOP_BIT;
                            tx_bit_index <= 0;
                        else
                            tx_bit_index <= tx_bit_index + 1;
                        end if;
                    else
                        tx_clk_count <= tx_clk_count + 1;
                    end if;
                    
                when STOP_BIT =>
                    tx <= '1';  -- Stop bit is high
                    
                    if tx_clk_count = CLKS_PER_BIT-1 then
                        tx_state <= IDLE;
                    else
                        tx_clk_count <= tx_clk_count + 1;
                    end if;
            end case;
        end if;
    end process;
    
    -- UART RX process
    rx_proc: process(clk, rst)
    begin
        if rst = '1' then
            rx_state <= IDLE;
            rx_done <= '0';
            rx_data <= (others => '0');
            rx_clk_count <= 0;
            rx_bit_index <= 0;
            rx_buffer <= (others => '0');
            rx_sync <= (others => '1');  -- Initialize to idle state
            
        elsif rising_edge(clk) then
            -- Metastability prevention
            rx_sync <= rx_sync(0) & rx;
            rx_done <= '0';  -- Pulse rx_done for one clock only
            
            case rx_state is
                when IDLE =>
                    rx_clk_count <= 0;
                    rx_bit_index <= 0;
                    
                    if rx_sync(1) = '0' then  -- Start bit detected
                        rx_state <= START_BIT;
                    end if;
                    
                when START_BIT =>
                    if rx_clk_count = CLKS_PER_BIT/2 then  -- Sample in middle of start bit
                        if rx_sync(1) = '0' then  -- Confirm start bit
                            rx_clk_count <= 0;
                            rx_state <= DATA_BITS;
                        else
                            rx_state <= IDLE;  -- False start bit
                        end if;
                    else
                        rx_clk_count <= rx_clk_count + 1;
                    end if;
                    
                when DATA_BITS =>
                    if rx_clk_count = CLKS_PER_BIT-1 then  -- Sample in middle of data bit
                        rx_clk_count <= 0;
                        rx_buffer(rx_bit_index) <= rx_sync(1);
                        
                        if rx_bit_index = 7 then
                            rx_state <= STOP_BIT;
                            rx_bit_index <= 0;
                        else
                            rx_bit_index <= rx_bit_index + 1;
                        end if;
                    else
                        rx_clk_count <= rx_clk_count + 1;
                    end if;
                    
                when STOP_BIT =>
                    if rx_clk_count = CLKS_PER_BIT-1 then
                        if rx_sync(1) = '1' then  -- Valid stop bit
                            rx_data <= rx_buffer;
                            rx_done <= '1';
                        end if;
                        rx_state <= IDLE;
                        rx_clk_count <= 0;
                    else
                        rx_clk_count <= rx_clk_count + 1;
                    end if;
            end case;
        end if;
    end process;
    
end behavioral;