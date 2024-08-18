library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
--use IEEE.std_logic_arith.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
 
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
 
entity bin2bcd_12bit_sync is
port ( 
    binIN       	: in    std_logic_vector(15 downto 0);     -- this is the binary number
    ones        	: out   std_logic_vector(3 downto 0);      -- this is the unity digit
    tenths      	: out   std_logic_vector(3 downto 0);      -- this is the tens digit
    hunderths   	: out   std_logic_vector(3 downto 0);      -- this is the hundreds digit
    thousands   	: out   std_logic_vector(3 downto 0);      -- 
    tensofthousands	: out   std_logic_vector(3 downto 0);      -- 
	CLK         	: in    std_logic                           -- clock input
);
end bin2bcd_12bit_sync;
 
architecture Behavioral of bin2bcd_12bit_sync is
	
	signal reg_in		: std_logic_vector(binIN'left downto binIN'right) := (others=>'0');
--	signal reg_out		: std_logic_vector(15 downto 0);
	signal bcd_out		: std_logic_vector(19 downto 0);
	
begin
 
bcd1: process(reg_in)
 
  -- temporary variable
  variable temp: STD_LOGIC_VECTOR (15 downto 0);
  -- variable to store the output BCD number
  -- organized as follows
  -- thousands = bcd(15 downto 12)
  -- hunderths = bcd(11 downto 8)
  -- tenths = bcd(7 downto 4)
  -- units = bcd(3 downto 3)
  variable BCD: STD_LOGIC_VECTOR (19 downto 0) := (others => '0');
 
-- by
-- https://en.wikipedia.org/wiki/Double_dabble
  begin
		--zero the bcd variable
 	--	for i in 0 to 15 loop
			bcd := (others=>'0');
    --	end loop;
 
		-- read input into temp variable
		temp := reg_in;
 
		--cycle 12 times as we have 12 input bits
		--this could be optimized, we dont need to check and add 3 for the 
		--first 3 iterations as the number can never be >4
		for i in 0 to 15 loop
 
			if bcd(3 downto 0) > 4 then	
				bcd(3 downto 0) := bcd(3 downto 0) + 3;
			end if;
 
			if bcd(7 downto 4) > 4 then	
				bcd(7 downto 4) := bcd(7 downto 4) + 3;
			end if;
 
			if bcd(11 downto 8) > 4 then	
				bcd(11 downto 8) := bcd(11 downto 8) + 3;
			end if;

			if bcd(15 downto 12) > 4 then	
				bcd(15 downto 12) := bcd(15 downto 12) + 3;
			end if;
 
		-- thousands can´t newer be >4 for a 12 bit input number
--			if bcd(15 downto 12) > 4 then	
--		   	bcd(15 downto 12) := bcd(15 downto 12) + 3;
--			end if;
 
		--shift bcd left by 1 bit
		bcd(19 downto 1) := bcd(18 downto 0);
		-- copy MSB of temp into LSB of bcd
		bcd(0 downto 0):= temp(15 downto 15);
		--shift temp left by 1 bit
		temp(15 downto 1) := temp(14 downto 0);
	
		end loop;
 
	--	set outputs
	
	bcd_out <= bcd;
	
--	ones <= bcd(3 downto 0);	
--	tenths <= bcd(7 downto 4);		
--	hunderths <= bcd(11 downto 8);		
--	thousands <= bcd(15 downto 12);			
 
  end process bcd1;
  
	process(CLK)
	begin
		if rising_edge(CLK) then
			ones        	<= bcd_out(3 downto 0);
			tenths      	<= bcd_out(7 downto 4);
			hunderths   	<= bcd_out(11 downto 8);
			thousands   	<= bcd_out(15 downto 12);
			tensofthousands	<= bcd_out(19 downto 16);
			reg_in      	<= binIN;
		end if;
	end process;
	
end Behavioral;
