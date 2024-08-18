library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity matrix_ram is
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
end entity;

architecture behave of matrix_ram is

    type mem_array_type is array (0 to 2**ADDRESS_BITS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    
    signal mem_array    		: mem_array_type;
    signal data_reg             : std_logic_vector(DATA_WIDTH-1 downto 0);      -- data to memory
    signal wren_reg             : std_logic;                                    -- active high write enable
    signal address_reg          : std_logic_vector(ADDRESS_BITS-1 downto 0);    -- address to memory
    signal byteena_reg          : std_logic_vector(DATA_WIDTH/8-1 downto 0);    -- active high byte enable
 
	attribute ramstyle : string;
	attribute ramstyle of mem_array : signal is "M10K";
	
begin

    inputs_regs: process(CLK, RST)
    begin
        if RST = '1' then
            data_reg <= (others=>'0');
            wren_reg <= '0';
            address_reg <= (others=>'0');
            byteena_reg <= (others=>'0');
        elsif rising_edge(CLK) then
            data_reg <= DATA;
            wren_reg <= WREN;
            address_reg <= ADDRESS;
            byteena_reg <= BYTEENA;
        end if;
    end process;
	
	write_mem: process(CLK)
	begin
		if rising_edge(CLK) then
			if wren_reg = '1' then
				for i in 0 to BYTEENA'length-1 loop
					if byteena_reg(i) = '1' then
						mem_array(to_integer(unsigned(address_reg)))((i+1)*8-1 downto i*8) <= data_reg((i+1)*8-1 downto i*8);
					end if;
				end loop;
			end if;
		end if;
	end process;
	
	read_mem: process(address_reg, mem_array)
	begin
		Q <= mem_array(to_integer(unsigned(address_reg)));
	end process;

end architecture;