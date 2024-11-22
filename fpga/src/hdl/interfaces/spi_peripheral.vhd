library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_pkg.all;

entity spi_peripheral is
    port (
        -- System signals
        clk         : in  std_logic;
        rst         : in  std_logic;
        -- SPI signals
        spi_sclk    : in  std_logic;
        spi_mosi    : in  std_logic;
        spi_miso    : out std_logic;
        spi_cs_n    : in  std_logic;
        -- Internal interface
        data_in     : in  std_logic_vector(31 downto 0);
        data_out    : out std_logic_vector(31 downto 0);
        addr        : out std_logic_vector(7 downto 0);
        wr_en       : out std_logic;
        rd_en       : out std_logic;
        busy        : out std_logic
    );
end spi_peripheral;

architecture behavioral of spi_peripheral is
    type spi_state_type is (IDLE, COMMAND, ADDRESS, DATA, COMPLETE);
    signal state : spi_state_type;
    signal bit_counter : integer range 0 to 31;
    signal shift_reg : std_logic_vector(31 downto 0);
begin
    process(spi_sclk, spi_cs_n)
    begin
        if spi_cs_n = '1' then
            state <= IDLE;
            bit_counter <= 0;
            busy <= '0';
        elsif rising_edge(spi_sclk) then
            case state is
                when IDLE =>
                    state <= COMMAND;
                    busy <= '1';
                    
                when COMMAND =>
                    shift_reg <= shift_reg(30 downto 0) & spi_mosi;
                    if bit_counter = 7 then
                        state <= ADDRESS;
                        bit_counter <= 0;
                        -- Extract command type
                        wr_en <= shift_reg(7);
                        rd_en <= not shift_reg(7);
                    else
                        bit_counter <= bit_counter + 1;
                    end if;
                    
                when ADDRESS =>
                    shift_reg <= shift_reg(30 downto 0) & spi_mosi;
                    if bit_counter = 7 then
                        state <= DATA;
                        bit_counter <= 0;
                        addr <= shift_reg(7 downto 0);
                    else
                        bit_counter <= bit_counter + 1;
                    end if;
                    
                when DATA =>
                    shift_reg <= shift_reg(30 downto 0) & spi_mosi;
                    if bit_counter = 31 then
                        state <= COMPLETE;
                        data_out <= shift_reg;
                    else
                        bit_counter <= bit_counter + 1;
                    end if;
                    
                when COMPLETE =>
                    state <= IDLE;
                    busy <= '0';
            end case;
        end if;
    end process;

    -- MISO output
    spi_miso <= data_in(bit_counter) when rd_en = '1' else '0';
end behavioral;