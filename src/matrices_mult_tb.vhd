library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
library std;
use std.textio.all;

entity matrices_mult_tb is
end entity;

architecture behave of matrices_mult_tb is

    constant C_CLK_PRD      : time := 20 ns;
	constant NUM_OF_TESTS	: integer := 3;

    type int_array is array(integer range <>) of integer;

    component mult_matrices is
    port (
		CLK                     : in    std_logic;  -- system clock
		RSTn                    : in    std_logic;  -- asynchronous, active high reset
		
		STARTn                  : in    std_logic;	-- active low
		DISPLAYn				: in    std_logic;	-- active low
		HEX0                    : out   std_logic_vector(6 downto 0);
		HEX1                    : out   std_logic_vector(6 downto 0);
		HEX2                    : out   std_logic_vector(6 downto 0);
		HEX3                    : out   std_logic_vector(6 downto 0);
		LEDS_1E4				: out   std_logic_vector(3 downto 0);
		LED_SIGN                : out   std_logic;
		LEDG                    : out   std_logic_vector(3 downto 1)
    );
    end component;

    function seg7_to_bcd(val_in: std_logic_vector(6 downto 0)) return integer is
    begin
    
        case val_in is
            when "1000000" =>
                return 0;
            when "1111001" =>
                return 1;
            when "0100100" =>
                return 2;
            when "0110000" =>
                return 3;
            when "0011001" =>
                return 4;
            when "0010010" =>
                return 5;
            when "0000010" =>
                return 6;
            when "1111000" =>
                return 7;
            when "0000000" =>
                return 8;
            when "0010000" =>
                return 9;
            when others =>
                return -1;
        end case;
    
    end function;
    
    
    signal clk          : std_logic := '0';
    signal rstn         : std_logic := '0';
    signal start        : std_logic := '1';
    signal display      : std_logic := '1';
    signal hex0         : std_logic_vector(6 downto 0);
    signal hex1         : std_logic_vector(6 downto 0);
    signal hex2         : std_logic_vector(6 downto 0);
	signal hex3         : std_logic_vector(6 downto 0);
    signal led_sign     : std_logic;
    signal ledg         : std_logic_vector(3 downto 1);
	signal leds_1e4		: std_logic_vector(3 downto 0);


begin

    dut: mult_matrices
    port map (
        CLK                   	=> clk,
        RSTn                    => rstn,
        STARTn                  => start,
        DISPLAYn                => display,
        HEX0                    => hex0,
        HEX1                    => hex1,
        HEX2                    => hex2,
        HEX3                    => hex3,
		LEDS_1E4				=> leds_1e4,
		LED_SIGN                => led_sign,
		LEDG                    => ledg
    );
    
    clk <= not clk after C_CLK_PRD / 2;
    rstn <= '0', '1' after 100 ns;
    
    process
    begin
        start <= '1';
        display <= '1';
        wait for 100 us;
        
        for i in 0 to 2 loop
            start <= '0';	-- get matrices
            wait for 100 us;
            start <= '1';
        
            wait for 200 us;
			
            start <= '0';	-- start calculate
            wait for 100 us;
            start <= '1';

            wait for 200 us;

            for j in 0 to 17 loop	-- dispaly
                display <= '0';
                wait for 100 us;
                display <= '1';
                wait for 200 us;
            end loop;
            
            wait for 1 ms;

            start <= '0';	-- back to idle
            wait for 100 us;
            start <= '1';
            wait for 1 ms;
            
        end loop;
        
        report "End of Simulation"
        severity failure;
        
    end process;
    
    
    verify_results: process
        variable expected_values    : int_array(0 to 15);
		variable expected_sign      : int_array(0 to 15);
        file infile                 : text open read_mode is "expected_results.dat";
        variable inline             : line;
        variable errors_counter     : integer := 0;
        variable param_num          : integer := 0;
        variable ones, tens, hunds  : integer := 0;
        variable dut_val            : integer := 0;
		variable thousands   		: integer := 0;
		variable tensofthousands    : integer := 0;
		
    begin
    
        --readline(infile, inline); -- skip first line
        
        for i in 1 to NUM_OF_TESTS loop
            wait until falling_edge(start);
			
            for j in 0 to 15 loop
				readline(infile, inline);
				read(inline, expected_sign(j));
				read(inline, expected_values(j));
            end loop;
            
            param_num := 0;
            
            for k in 0 to 17 loop
                wait until falling_edge(display);
                ones := seg7_to_bcd(hex0);
                tens := seg7_to_bcd(hex1);
                hunds := seg7_to_bcd(hex2);
                thousands := seg7_to_bcd(hex3);
				tensofthousands := conv_integer(leds_1e4);
				dut_val := ones + tens*10 + hunds*100 + thousands*1E3 + tensofthousands*1E4;
                
                if (dut_val = expected_values(param_num)) then
                    report "Value Pass" & LF;
                else
                    report "Value Fail!  " & "Expected=" & integer'image(expected_values(param_num)) & "    Actual=" & integer'image(dut_val) & LF;
                    errors_counter := errors_counter + 1;
                end if;
				
				if (conv_integer(led_sign) = expected_sign(param_num)) then
                    report "Sign Pass" & LF;
                else
                    report "Sign Fail!  " & "Expected=" & integer'image(expected_sign(param_num)) & "    Actual=" & integer'image(conv_integer(led_sign)) & LF;
                    errors_counter := errors_counter + 1;
                end if;
                
                if param_num = 15 then
                    param_num := 0;
                else
                    param_num := param_num + 1;
                end if;
            end loop;

        end loop;
        
        report "Total errors: " & integer'image(errors_counter) & LF;
        
        wait;
    
    end process;

end architecture;
