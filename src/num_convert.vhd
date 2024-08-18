library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity num_convert is
port (
    CLK                     : in    std_logic;  -- system clock
	RST						: in    std_logic;
	DIN						: in    std_logic_vector(16 downto 0);
	DIN_VALID				: in    std_logic;
	DOUT					: out   std_logic_vector(15 downto 0);
	SIGN					: out   std_logic
);
end entity;

architecture behave of num_convert is

begin

	process(CLK, RST)
		variable tmp: signed(16 downto 0);
	begin
		if RST = '1' then
			DOUT <= (others=>'0');
			SIGN <= '0';
		elsif rising_edge(CLK) then
			if DIN_VALID = '1' then
				SIGN <= DIN(16);
				tmp := abs(signed(DIN));
				DOUT <= std_logic_vector(tmp(15 downto 0));
			else
				SIGN <= '0';
			end if;

		
		end if;
	
	end process;


end architecture;
