library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--library work;
--use work.data_generator_pack.all;

entity data_generator_tb is
end entity;

architecture sim of data_generator_tb is

	constant C_CLK_PERIOD	: time := 20 ns;

	component data_generator is
	port (
		CLK				: in    std_logic;	-- system clock
		RST				: in    std_logic;	-- active high reset
		DATA_REQUEST	: in    std_logic;	-- active high, 1 CLK duration
		DOUT			: out   std_logic_vector(7 downto 0); -- data
		DOUT_VALID		: out   std_logic	-- active high data valid
	);
	end component;

	signal clk				: std_logic := '0';
	signal rst    			: std_logic := '1';
	signal data_request    	: std_logic := '0';

begin


	dut: data_generator
	port map (
		CLK				=> clk,
		RST				=> rst,
		DATA_REQUEST	=> data_request,
		DOUT			=> open,
		DOUT_VALID		=> open
	);


	clk <= not clk after C_CLK_PERIOD/2;
	rst <= '1', '0' after 41 ns;
	
	process
	begin
	
		data_request <= '0';
		wait for 10 us;
		for j in 1 to 2 loop
			for i in 1 to 2 loop
				wait until rising_edge(clk);
				data_request <= '1';
				wait until rising_edge(clk);
				data_request <= '0';
				wait for 10 us;
			end loop;
			wait for 100 us;
			
		end loop;
		
		wait for 100 us;
		
		report "End of Simulation" & LF
		severity failure;
	end process;
		
		

end architecture;