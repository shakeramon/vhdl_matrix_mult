library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity bin2bcd_12bit_sync_tb is
end entity;


architecture sim of bin2bcd_12bit_sync_tb is

	component bin2bcd_12bit_sync is
	port (
		binIN       	: in    std_logic_vector(15 downto 0);     -- this is the binary number
		ones        	: out   std_logic_vector(3 downto 0);      -- this is the unity digit
		tenths      	: out   std_logic_vector(3 downto 0);      -- this is the tens digit
		hunderths   	: out   std_logic_vector(3 downto 0);      -- this is the hundreds digit
		thousands   	: out   std_logic_vector(3 downto 0);      -- 
		tensofthousands	: out   std_logic_vector(3 downto 0);      -- 
		CLK         	: in    std_logic                           -- clock input
	);
	end component;
	
	signal clk		: std_logic := '0';
	signal binIN	: std_logic_vector(15 downto 0) := (others=>'0');
	
	
begin


	dut: bin2bcd_12bit_sync
	port map (
		binIN       	=> binIN,
		ones        	=> open,
		tenths      	=> open,
		hunderths   	=> open,
		thousands   	=> open,
		tensofthousands	=> open,
		CLK         	=> clk
	);

	clk <= not clk after 10 ns;

	process
	begin
		wait for 10 us;
		binIN <= conv_std_logic_vector(12345, binIN'length);
		wait for 10 us;
		binIN <= conv_std_logic_vector(65535, binIN'length);
		wait for 10 us;
		binIN <= conv_std_logic_vector(54321, binIN'length);
		wait for 10 us;
		binIN <= conv_std_logic_vector(11111, binIN'length);
		wait for 10 us;
		binIN <= conv_std_logic_vector(23232, binIN'length);

		wait;
	end process;

end architecture;