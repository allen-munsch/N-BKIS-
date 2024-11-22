library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

package nebkiso_tb_pkg is
    -- Simulation constants
    constant CLK_PERIOD : time := 10 ns;  -- 100MHz
    constant SPI_PERIOD : time := 125 ns; -- 8MHz
    constant I2C_PERIOD : time := 2500 ns; -- 400kHz
    
    -- Test data types
    type test_sequence is record
        voc_level : std_logic_vector(11 downto 0);
        aq_level : std_logic_vector(11 downto 0);
        pressure : std_logic_vector(11 downto 0);
        temperature : std_logic_vector(11 downto 0);
        flow_rate : std_logic_vector(7 downto 0);
    end record;
    
    -- Test sequences
    constant NORMAL_OPERATION : test_sequence := (
        voc_level => x"200",
        aq_level => x"300",
        pressure => x"500",
        temperature => x"400",
        flow_rate => x"50"
    );
    
    constant EMERGENCY_CONDITION : test_sequence := (
        voc_level => x"FFF",
        aq_level => x"FFF",
        pressure => x"FFF",
        temperature => x"FFF",
        flow_rate => x"00"
    );
    
    -- Test procedures
    procedure check_safety_response(
        signal clk : in std_logic;
        signal emergency_stop : in std_logic;
        signal ventilation_on : in std_logic;
        expected_emergency : in std_logic;
        expected_ventilation : in std_logic;
        test_name : in string
    );
end package;

package body nebkiso_tb_pkg is
    procedure check_safety_response(
        signal clk : in std_logic;
        signal emergency_stop : in std_logic;
        signal ventilation_on : in std_logic;
        expected_emergency : in std_logic;
        expected_ventilation : in std_logic;
        test_name : in string
    ) is
    begin
        wait until rising_edge(clk);
        wait for CLK_PERIOD/4;
        
        assert emergency_stop = expected_emergency
            report test_name & ": Emergency stop mismatch. Expected " & 
                   std_logic'image(expected_emergency) & " but got " & 
                   std_logic'image(emergency_stop)
            severity error;
            
        assert ventilation_on = expected_ventilation
            report test_name & ": Ventilation control mismatch. Expected " & 
                   std_logic'image(expected_ventilation) & " but got " & 
                   std_logic'image(ventilation_on)
            severity error;
    end procedure;
end package body;

