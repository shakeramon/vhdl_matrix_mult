library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_multiplier is
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
end entity;

architecture behave of my_multiplier is

	type slv_array is array(1 to LATENCY) of std_logic_vector(N*2-1 downto 0);

	signal res			: slv_array; --std_logic_vector(N*2-1 downto 0);
	signal din_valid_d	: std_logic_vector(1 to LATENCY);
	
	--signal res_delayed	: slv_array;

begin

	process(CLK)
		
	begin
		if rising_edge(CLK) then
			
			if DIN_VALID = '1' then
				if IS_SIGNED then
					--res(1) <= std_logic_vector(to_signed(to_integer(signed(A)) * to_integer(signed(B)), 2*N));
					res(1) <= std_logic_vector(signed(A) * signed(B));
				else
					--res(1) <= std_logic_vector(to_unsigned(to_integer(unsigned(A)) * to_integer(unsigned(B)), 2*N));
					res(1) <= std_logic_vector(unsigned(A) * unsigned(B));
				end if;
			end if;
			
			din_valid_d(1) <= DIN_VALID;
			
			if LATENCY > 1 then
				for i in 2 to LATENCY loop
					res(i) <= res(i-1);
					din_valid_d(i) <= din_valid_d(i-1);
				end loop;
			end if;
			
		end if;
	end process;
			
	Q <= res(LATENCY);
	DOUT_VALID <= din_valid_d(LATENCY);
	
end architecture;

