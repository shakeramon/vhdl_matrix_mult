library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
library work;
use work.data_generator_pack.all;

entity data_generator is
port (
	CLK				: in    std_logic;	-- system clock
	RST				: in    std_logic;	-- active high reset
	DATA_REQUEST	: in    std_logic;	-- active high, 1 CLK duration
	DOUT			: out   std_logic_vector(7 downto 0); -- data
	DOUT_VALID		: out   std_logic	-- active high data valid
);
end entity;

architecture behave of data_generator is

	constant C_NUM_OF_ELEMENTS	: integer := 16;
	constant C_NUM_OF_MATRICES	: integer := data_generator_array'length/C_NUM_OF_ELEMENTS;

	signal data_generator_tx_sm		: data_generator_tx_sm_states := st_idle;
	signal elements_count    		: integer range 0 to C_NUM_OF_ELEMENTS-1;
	signal mat_count				: integer range 0 to C_NUM_OF_MATRICES-1;

begin

	process(CLK, RST)
	begin
		if RST = '1' then
			data_generator_tx_sm <= st_idle;
			elements_count <= 0;
			mat_count <= 0;
			DOUT_VALID <= '0';
			DOUT <= (others=>'0');
		elsif rising_edge(CLK) then
			
			case data_generator_tx_sm is
			
				when st_idle =>
					if DATA_REQUEST = '1' then
						data_generator_tx_sm <= st_transmit;
					end if;
					elements_count <= 0;
					DOUT_VALID <= '0';
					
				when st_transmit =>
					if elements_count < C_NUM_OF_ELEMENTS-1 then
						
						elements_count <= elements_count + 1;
					else
						data_generator_tx_sm <= st_idle;
						if mat_count < C_NUM_OF_MATRICES-1 then
							mat_count <= mat_count + 1;
						else
							mat_count <= 0;
						end if;
						
					end if;
					
					DOUT <= std_logic_vector(to_signed(data_generator_array(mat_count*C_NUM_OF_ELEMENTS+elements_count), DOUT'length));
					DOUT_VALID <= '1';
					
			end case;
		
		end if;
	end process;

end architecture;