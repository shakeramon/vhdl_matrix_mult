library ieee;
use ieee.std_logic_1164.all;

package data_generator_pack is

	type data_generator_array_type is array (natural range <>) of integer range -128 to 127;
	type data_generator_tx_sm_states is
	(
		st_idle,
		st_transmit
	);
		
		
	constant data_generator_array : data_generator_array_type(0 to 95) := 
	(
		1,   2,   3,   4,
		5,   6,   7,   8,
		9,   10,  11,  12,
		13,  14,  15,  16,
		 
		17,  18,  19,  20,
		21,  22,  23,  24,
		25,  26,  27,  28,
		29,  30,  31,  32,
		
        4,   -38,   -13,   -32,
        62,   24,    30,    6,
        21,   -4,   -20,    53,
        43,   43,   -24,    35,

		28,    94,  113,   124,
		66,  -113,   68,   117,
		25,  -117,   38,    85,
		103, -19,   -82,   -38,

		-59,    52,    81,   107,
		-38,   -63,    34,  -110,
		13,    80,   -32,   -71,
		-12,   -48,   -72,     3,
		
		16,    -3,    31,  -112,
		14,   -81,   -80,  -96,
		50,   -75,    -8,   -13,
		-2,   -37,    38 ,  -31
		
	);
		 
	

end package;