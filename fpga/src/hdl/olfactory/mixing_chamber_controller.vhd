library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.nebkiso_olfactory_pkg.all;

entity mixing_chamber_controller is
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        mixing_mode     : in  mixing_mode_type;
        temp_target     : in  std_logic_vector(TEMP_PRECISION-1 downto 0);
        pressure_target : in  std_logic_vector(PRESSURE_PRECISION-1 downto 0);
        heater_control  : out std_logic_vector(7 downto 0);
        mixer_speed     : out std_logic_vector(7 downto 0);
        chamber_status  : out std_logic_vector(7 downto 0)
    );
end mixing_chamber_controller;

architecture behavioral of mixing_chamber_controller is
    -- Internal signals for control loops
    signal temp_error     : signed(TEMP_PRECISION-1 downto 0);
    signal press_error    : signed(PRESSURE_PRECISION-1 downto 0);
    signal prev_temp_error: signed(TEMP_PRECISION-1 downto 0);
    signal prev_press_error: signed(PRESSURE_PRECISION-1 downto 0);
    
    -- Internal signals for control outputs
    signal heater_control_int : std_logic_vector(7 downto 0);
    signal mixer_speed_int    : std_logic_vector(7 downto 0);
    
    -- Control parameters
    constant KP_TEMP      : signed(7 downto 0) := to_signed(4, 8);
    constant KI_TEMP      : signed(7 downto 0) := to_signed(2, 8);
    constant KD_TEMP      : signed(7 downto 0) := to_signed(1, 8);
    
    -- Status flags
    signal temp_stable    : std_logic;
    signal press_stable   : std_logic;
    signal mixing_active  : std_logic;
    
begin
    -- Main control process
    process(clk, rst)
        variable temp_control : signed(15 downto 0);
        variable mixer_control: unsigned(7 downto 0);
    begin
        if rst = '1' then
            heater_control_int <= (others => '0');
            mixer_speed_int <= (others => '0');
            chamber_status <= (others => '0');
            temp_stable <= '0';
            press_stable <= '0';
            mixing_active <= '0';
            
        elsif rising_edge(clk) then
            -- Temperature control loop
            temp_error <= signed(temp_target) - signed(temp_error);
            
            -- PID calculation for temperature
            temp_control := (KP_TEMP * temp_error) + 
                          (KI_TEMP * (temp_error + prev_temp_error)) +
                          (KD_TEMP * (temp_error - prev_temp_error));
            
            prev_temp_error <= temp_error;
            
            -- Apply temperature control
            if temp_control > 0 then
                heater_control_int <= std_logic_vector(unsigned(temp_control(7 downto 0)));
            else
                heater_control_int <= (others => '0');
            end if;
            
            -- Mixing speed control based on mode
            case mixing_mode is
                when LAMINAR_FLOW =>
                    mixer_control := x"40";  -- ~25% speed
                    
                when TURBULENT_MIX =>
                    mixer_control := x"FF";  -- Maximum speed
                    
                when GRADIENT_BLEND =>
                    mixer_control := x"80";  -- ~50% speed
                    
                when PHASE_SEPARATION =>
                    mixer_control := x"20";  -- ~12.5% speed
                    
                when others =>
                    mixer_control := x"00";  -- Stop mixer
            end case;
            
            mixer_speed_int <= std_logic_vector(mixer_control);
            
            -- Stability detection
            if abs(temp_error) < 4 then  -- Within 0.4°C
                temp_stable <= '1';
            else
                temp_stable <= '0';
            end if;
            
            if abs(press_error) < 4 then  -- Within 0.04 atm
                press_stable <= '1';
            else
                press_stable <= '0';
            end if;
            
            -- Check if mixing is active based on control values
            if unsigned(heater_control_int) /= 0 or unsigned(mixer_speed_int) /= 0 then
                mixing_active <= '1';
            else
                mixing_active <= '0';
            end if;
            
            -- Update chamber status
            chamber_status <= mixing_active & 
                            temp_stable &
                            press_stable &
                            std_logic_vector(to_unsigned(mixing_mode_type'pos(mixing_mode), 2)) &
                            "000";  -- Reserved
        end if;
    end process;

    -- Drive output ports from internal signals
    heater_control <= heater_control_int;
    mixer_speed <= mixer_speed_int;
    
end behavioral;