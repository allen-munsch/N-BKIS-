library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package nebkiso_olfactory_pkg is
    -- Constants for molecular dispensing system
    constant NUM_CARTRIDGES : integer := 32;
    constant FLOW_PRECISION : integer := 12;  -- 0.01ml precision (12-bit)
    constant TEMP_PRECISION : integer := 12;  -- 0.1°C precision
    constant PRESSURE_PRECISION : integer := 12;  -- 0.01 atm precision
    
    -- Sequence timing constants
    constant MAX_SEQUENCE_STEPS : integer := 1024;
    constant TIMING_PRECISION : integer := 32;  -- millisecond precision timer
    
    -- Types for sequence control
    type cartridge_array is array (0 to NUM_CARTRIDGES-1) of std_logic_vector(FLOW_PRECISION-1 downto 0);
    
    type sequence_step_type is record
        cartridge_enables : std_logic_vector(NUM_CARTRIDGES-1 downto 0);
        flow_rates : cartridge_array;
        duration : std_logic_vector(TIMING_PRECISION-1 downto 0);
        temp_target : std_logic_vector(TEMP_PRECISION-1 downto 0);
        pressure_target : std_logic_vector(PRESSURE_PRECISION-1 downto 0);
    end record;
    
    -- Mixing modes
    type mixing_mode_type is (
        LAMINAR_FLOW,    -- For gentle mixing
        TURBULENT_MIX,   -- For rapid homogenization
        GRADIENT_BLEND,  -- For creating spatial gradients
        PHASE_SEPARATION -- For layered effects
    );
    
    -- Environment control constants
    constant MIN_TEMP : integer := 100;    -- 10.0°C
    constant MAX_TEMP : integer := 400;    -- 40.0°C
    constant MIN_PRESSURE : integer := 800; -- 0.8 atm
    constant MAX_PRESSURE : integer := 1200; -- 1.2 atm
    
    -- Flow control constants
    constant MIN_FLOW_RATE : integer := 1;   -- 0.01ml/s
    constant MAX_FLOW_RATE : integer := 1000; -- 10.00ml/s
    
    -- Component interfaces
    component cartridge_controller is
        port (
            clk             : in  std_logic;
            rst             : in  std_logic;
            cartridge_sel   : in  std_logic_vector(4 downto 0);
            flow_rate       : in  std_logic_vector(FLOW_PRECISION-1 downto 0);
            enable          : in  std_logic;
            valve_controls  : out std_logic_vector(NUM_CARTRIDGES-1 downto 0);
            pump_controls   : out std_logic_vector(NUM_CARTRIDGES-1 downto 0);
            flow_sensors    : in  std_logic_vector(NUM_CARTRIDGES-1 downto 0);
            cartridge_status: out std_logic_vector(NUM_CARTRIDGES-1 downto 0)
        );
    end component;
    
    component mixing_chamber_controller is
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
    end component;

    -- Common functions
    function to_milliliters(flow_value: std_logic_vector) return real;
    function to_celsius(temp_value: std_logic_vector) return real;
    function to_atmospheres(press_value: std_logic_vector) return real;
    
end package nebkiso_olfactory_pkg;

package body nebkiso_olfactory_pkg is
    -- Function implementations
    function to_milliliters(flow_value: std_logic_vector) return real is
    begin
        return real(to_integer(unsigned(flow_value))) * 0.01;
    end function;
    
    function to_celsius(temp_value: std_logic_vector) return real is
    begin
        return real(to_integer(unsigned(temp_value))) * 0.1;
    end function;
    
    function to_atmospheres(press_value: std_logic_vector) return real is
    begin
        return real(to_integer(unsigned(press_value))) * 0.01;
    end function;
end package body;