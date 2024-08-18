library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity matrix_ram_tb is
end entity;


architecture behave of matrix_ram_tb is

	constant C_MEM_DATA_WIDTH	: integer := 32;
	constant C_MEM_ADDRESS_BITS	: integer := 6;
	constant C_CLK_PERIOD		: time := 10 ns;
	constant C_MEM_SIZE			: integer := 2**C_MEM_ADDRESS_BITS;
	
	component matrix_ram is
	generic (
		DATA_WIDTH      : integer := 8;
		ADDRESS_BITS    : integer := 6
	);
	port (
		CLK             : in    std_logic;
		RST             : in    std_logic;
		DATA            : in    std_logic_vector(DATA_WIDTH-1 downto 0);    -- data to memory
		WREN            : in    std_logic;                                  -- active high write enable
		ADDRESS         : in    std_logic_vector(ADDRESS_BITS-1 downto 0);  -- address to memory
		BYTEENA         : in    std_logic_vector(DATA_WIDTH/8-1 downto 0);  -- active high byte enable
		Q               : out   std_logic_vector(DATA_WIDTH-1 downto 0)     -- data from memory
	);
	end component;

	signal clk				: std_logic := '0';
    signal rst              : std_logic := '0';
    signal data_to_mem      : std_logic_vector(C_MEM_DATA_WIDTH-1 downto 0);
    signal mem_wr           : std_logic := '0';
    signal mem_address      : std_logic_vector(C_MEM_ADDRESS_BITS-1 downto 0) := (others=>'0');
    signal mem_be           : std_logic_vector(C_MEM_DATA_WIDTH/8-1 downto 0) := (others=>'0');
 
begin



	dut: matrix_ram
	generic map (
		DATA_WIDTH      => C_MEM_DATA_WIDTH,
		ADDRESS_BITS    => C_MEM_ADDRESS_BITS
	)
	port map (
		CLK             => clk,
		RST             => rst,
		DATA            => data_to_mem,
		WREN            => mem_wr,
		ADDRESS         => mem_address,
		BYTEENA         => mem_be,
		Q               => open
	);
	
	process
	begin
		wait for 10 us;
		
		for i in 0 to C_MEM_SIZE-1 loop
			wait for 1 us;
			wait until rising_edge(clk);
			data_to_mem <= (others=>'1');--conv_std_logic_vector(i, data_to_mem'length);
			mem_wr <= '1';
			wait until rising_edge(clk);
			mem_wr <= '0';
			mem_address <= mem_address + 1;
		
		end loop;
		
		wait for 100 us;
		mem_address <= (others=>'0');
		
		for i in 0 to C_MEM_SIZE-1 loop
			wait for 1 us;
			wait until rising_edge(clk);
			mem_address <= mem_address + 1;
		end loop;
		
		wait for 100 us;
		report "End of Simulation" & LF
		severity failure;
		
	end process;
	
	mem_be <= "1001"; --(others=>'1');

	clk <= not clk after C_CLK_PERIOD / 2;
	rst <= '1', '0' after 12 ns;
	

end architecture;