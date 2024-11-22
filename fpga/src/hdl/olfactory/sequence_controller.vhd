library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_olfactory_pkg.all;

entity sequence_controller is
    port (
        -- System signals
        clk               : in  std_logic;
        rst               : in  std_logic;
        
        -- Sequence control
        sequence_start    : in  std_logic;
        sequence_stop     : in  std_logic;
        sequence_pause    : in  std_logic;
        
        -- Sequence memory interface
        sequence_addr     : out std_logic_vector(9 downto 0);  -- Up to 1024 steps
        sequence_data     : in  sequence_step_type;
        
        -- Control outputs
        cartridge_enables : out std_logic_vector(NUM_CARTRIDGES-1 downto 0);
        flow_rates        : out cartridge_array;
        temp_target       : out std_logic_vector(TEMP_PRECISION-1 downto 0);
        pressure_target   : out std_logic_vector(PRESSURE_PRECISION-1 downto 0);
        
        -- Status signals
        sequence_active   : out std_logic;
        step_complete    : out std_logic;
        sequence_done    : out std_logic;
        sequence_error   : out std_logic;
        current_step     : out std_logic_vector(9 downto 0)
    );
end sequence_controller;

architecture behavioral of sequence_controller is
    type seq_state_type is (IDLE, LOAD_STEP, EXECUTE, WAIT_COMPLETE, NEXT_STEP);
    signal state : seq_state_type;
    signal step_timer : unsigned(TIMING_PRECISION-1 downto 0);
    signal step_counter : unsigned(9 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            step_timer <= (others => '0');
            step_counter <= (others => '0');
            sequence_active <= '0';
            sequence_done <= '0';
            sequence_error <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if sequence_start = '1' then
                        state <= LOAD_STEP;
                        sequence_active <= '1';
                        step_counter <= (others => '0');
                    end if;
                
                when LOAD_STEP =>
                    sequence_addr <= std_logic_vector(step_counter);
                    state <= EXECUTE;
                
                when EXECUTE =>
                    -- Load step parameters
                    cartridge_enables <= sequence_data.cartridge_enables;
                    flow_rates <= sequence_data.flow_rates;
                    temp_target <= sequence_data.temp_target;
                    pressure_target <= sequence_data.pressure_target;
                    step_timer <= unsigned(sequence_data.duration);
                    state <= WAIT_COMPLETE;
                    step_complete <= '0';
                
                when WAIT_COMPLETE =>
                    if sequence_pause = '1' then
                        -- Hold current state
                        null;
                    elsif sequence_stop = '1' then
                        state <= IDLE;
                        sequence_active <= '0';
                    elsif step_timer = 0 then
                        state <= NEXT_STEP;
                        step_complete <= '1';
                    else
                        step_timer <= step_timer - 1;
                    end if;
                
                when NEXT_STEP =>
                    if step_counter = MAX_SEQUENCE_STEPS-1 then
                        state <= IDLE;
                        sequence_done <= '1';
                        sequence_active <= '0';
                    else
                        step_counter <= step_counter + 1;
                        state <= LOAD_STEP;
                    end if;
            end case;
            
            current_step <= std_logic_vector(step_counter);
        end if;
    end process;
end behavioral;