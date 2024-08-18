library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_multiplier_tb is
end entity;


architecture behave of my_multiplier_tb is

	constant CLK_PERIOD		: time := 20 ns;
	constant N				: integer := 8;
	constant LATENCY		: integer := 3;
	constant IS_SIGNED		: boolean := true;
	
	
	component my_multiplier is
	generic (
		N 						: integer := 8;
		LATENCY					: integer range 1 to 8 := 1;
		IS_SIGNED				: boolean := false
	);
	port (
		CLK                     : in    std_logic;  -- system clock
		DIN_VALID				: in    std_logic;
		A   					: in    std_logic_vector(N-1 downto 0);
		B   					: in    std_logic_vector(N-1 downto 0);
		Q						: out   std_logic_vector(N*2-1 downto 0);
		DOUT_VALID				: out   std_logic
	);
	end component;
	
	signal clk  			: std_logic := '1';
	signal a, b				: std_logic_vector(N-1 downto 0);
	signal din_valid		: std_logic := '0';
	
begin

	clk <= not clk after CLK_PERIOD / 2;

	dut: my_multiplier
	generic map (
		N 						=> N,
		LATENCY					=> LATENCY,
		IS_SIGNED				=> IS_SIGNED
	)
	port map (
		CLK                     => clk,
		DIN_VALID               => din_valid,
		A   					=> a,
		B   					=> b,
		Q						=> open
	);

	process
	begin
		wait for 1 us;
		wait until rising_edge(clk);
		
		a <= std_logic_vector(to_unsigned(65, a'length));
		b <= std_logic_vector(to_unsigned(27, a'length));
		din_valid <= '1';
		wait until rising_edge(clk);
		din_valid <= '0';
		
		wait for 1 us;
		wait until rising_edge(clk);

		a <= std_logic_vector(to_unsigned(126, a'length));
		b <= std_logic_vector(to_unsigned(17, a'length));
		din_valid <= '1';
		wait until rising_edge(clk);
		din_valid <= '0';
		
		wait for 1 us;
		wait until rising_edge(clk);

		a <= std_logic_vector(to_signed(-126, a'length));
		b <= std_logic_vector(to_signed(17, a'length));
		din_valid <= '1';
		wait until rising_edge(clk);
		din_valid <= '0';
		
		wait;
		
	end process;
	
end architecture;

