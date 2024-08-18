library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package Components_Pkg is
    constant DATA_WIDTH : integer := 8;

    -- Type Definitions
    type state_type1 is (IDL, MAT1, MAT2, CAL, DISP);
    type state_type2 is (cal_read, cal_calc, cal_write);

    type data_array is array (0 to 3) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type result_array is array (0 to 3) of std_logic_vector(DATA_WIDTH*2-1 downto 0);
    type valid_array is array (0 to 3) of std_logic;

    type byte_array is array (0 to 63) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type bit_16_array is array (0 to 15) of std_logic_vector(2*DATA_WIDTH downto 0);

    -- RAM COMPONENT
    component matrix_ram
        generic (
            DATA_WIDTH      : integer := 8;
            ADDRESS_BITS    : integer := 6
        );
        port (
            CLK             : in    std_logic;
            RST             : in    std_logic;
            DATA            : in    std_logic_vector(DATA_WIDTH-1 downto 0);
            WREN            : in    std_logic;
            ADDRESS         : in    std_logic_vector(ADDRESS_BITS-1 downto 0);
            BYTEENA         : in    std_logic_vector(DATA_WIDTH/8-1 downto 0);
            Q               : out   std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    -- MULTIPLIER COMPONENT
    component my_multiplier
        generic (
            N             : integer := 8;
            LATENCY       : integer range 1 to 8 := 1;
            IS_SIGNED     : boolean := false
        );
        port (
            CLK           : in    std_logic;  -- system clock
            DIN_VALID     : in    std_logic;
            A             : in    std_logic_vector(N-1 downto 0);
            B             : in    std_logic_vector(N-1 downto 0);
            Q             : out   std_logic_vector(N*2-1 downto 0);
            DOUT_VALID    : out   std_logic
        );
    end component;

    -- Function declaration for adding two unsigned vectors
    function add_vectors(a, b : std_logic_vector) return std_logic_vector;

    -- Function declaration for adding four signed binary numbers
    function add_four_signed(
        a, b, c, d : signed
    ) return signed;

end package Components_Pkg;

package body Components_Pkg is

    -- Function implementation for adding two unsigned vectors
    function add_vectors(a, b : std_logic_vector) return std_logic_vector is
        variable result : std_logic_vector(a'range);
    begin
        result := std_logic_vector(unsigned(a) + unsigned(b));
        return result;
    end function add_vectors;

    -- Function implementation for adding four signed binary numbers
    function add_four_signed(
        a, b, c, d : signed
    ) return signed is
        variable result : signed(a'length downto 0);  -- Extra bit for overflow handling
    begin
        result := signed('0' & a) + signed('0' & b) + signed('0' & c) + signed('0' & d);
        return result(result'length-2 downto 0); -- Return result truncated to original width
    end function add_four_signed;

end package body Components_Pkg;
