 --=======================================================================================
-- Verficat Saving Matrixes 
--=========================================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Components_Pkg.all;

entity Main_Controller is
    generic (
        DATA_WIDTH      : integer := 8;
        ADDRESS_BITS    : integer := 5;
        MATRIX_SIZE     : integer := 4;
        N               : integer := 8;
        LATENCY         : integer range 1 to 8 := 1;
        IS_SIGNED       : boolean := true
    );
    port (
        CLK ,DISPLAY    : in  std_logic;
        RST             : in  std_logic;
        START           : in  std_logic;
        DIN             : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        DIN_VALID       : in  std_logic;
        RESULT          : out std_logic_vector(2*DATA_WIDTH downto 0); -- 2 * DATA_WIDTH bits
        DATA_REQUEST    : out std_logic;
        RESULT_READY    : out std_logic;
        GOT_ALL_MATRICES: out std_logic
    );
end entity;


architecture Behavioral of Main_Controller is
    -- Internal signals
    signal done              : std_logic := '0';
    signal result_ready1     : std_logic := '0';
    signal cal_counter       : integer range 0 to 32 := 0;
    signal i                 : integer := 0;
    signal j                 : integer := 16;
    signal clock_count       : integer range 0 to 1 := 0;
    signal result_mat_place  : integer range 0 to 17 := 0;
    signal matrix_index      : std_logic_vector(2*DATA_WIDTH downto 0) := (others => '0');
    signal DISPLAY_COUNT     : integer range 0 to 16 := 0;
    --signal RESULT_SIG        : std_logic_vector(2*DATA_WIDTH downto 0) := (others => '0');

    -- State types
    type state_type1 is (IDL, MAT1, MAT2, CAL, DISP);
    type state_type2 is (cal_read, cal_calc, cal_write);

    -- State signals
    signal main_state        : state_type1 := IDL;
    signal cal_state         : state_type2 := cal_read;
    signal address_counter   : integer range 0 to 32 := 0;

    -- RAM-related signals
    signal ram_data          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_wren          : std_logic := '0';
    signal ram_address       : std_logic_vector(ADDRESS_BITS-1 downto 0) := (others => '0');
    signal ram_byteena       : std_logic_vector(DATA_WIDTH/8-1 downto 0) := (others => '0');
    signal ram_q             : std_logic_vector(DATA_WIDTH-1 downto 0);
	 
	 
	 signal final_ram_data   : std_logic_vector(3*DATA_WIDTH-1 downto 0) := (others => '0'); -- Updated
    signal final_ram_wren   : std_logic := '0';
    signal final_ram_address: std_logic_vector(ADDRESS_BITS-1 downto 0) := (others => '0');
    signal final_ram_byteena: std_logic_vector((3*DATA_WIDTH)/8-1 downto 0) := (others => '0'); -- Updated
    signal final_ram_q      : std_logic_vector(3*DATA_WIDTH-1 downto 0); -- Updated

    -- Multiplier-related signals
    type data_array is array (0 to 3) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type result_array is array (0 to 3) of std_logic_vector(2*DATA_WIDTH-1 downto 0);
    type valid_array is array (0 to 3) of std_logic;

    signal a, b              : data_array := (others => (others => '0'));
    signal mult_result       : result_array := (others => (others => '0'));
    signal mult_din_valid    : valid_array := (others => '0');
    signal mult_dout_valid   : valid_array := (others => '0');

    -- Calculation array signals
	 type integer_array is array (0 to 16) of integer;-- uncorect it 15

    type byte_array is array (0 to 31) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type matrix_indexes is array (0 to 16) of std_logic_vector(DATA_WIDTH*2 downto 0);--15
    signal cal_array         : byte_array := (others => (others => '0'));
    signal matrix            : matrix_indexes := (others => (others => '0'));
	 signal integer_matrix    : integer_array := (others => 0 );
	 signal from_disply_START : std_logic := '0';
	 --signal k : std_logic := '0';
	 signal delay_counter : integer range 0 to 5 := 0;
	 

begin

    -- RAM instance
	    final_ram_inst: entity work.matrix_ram
        generic map (
            DATA_WIDTH => 3*DATA_WIDTH, -- Updated to 24 bits or 3 * DATA_WIDTH
            ADDRESS_BITS => ADDRESS_BITS
        )
        port map (
            CLK => CLK,
            RST => RST,
            DATA => final_ram_data,
            WREN => final_ram_wren,
            ADDRESS => final_ram_address,
            BYTEENA => final_ram_byteena,
            Q => final_ram_q
        );
    ram_inst: entity work.matrix_ram
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDRESS_BITS => ADDRESS_BITS
        )
        port map (
            CLK => CLK,
            RST => RST,
            DATA => ram_data,
            WREN => ram_wren,
            ADDRESS => ram_address,
            BYTEENA => ram_byteena,
            Q => ram_q
        );

    -- Multipliers generation
    gen_multipliers: for i in 0 to 3 generate
        mult_inst: entity work.my_multiplier
            generic map(
                N => N,
                LATENCY => LATENCY,
                IS_SIGNED => IS_SIGNED
            )
            port map (
                CLK => CLK,
                DIN_VALID => mult_din_valid(i),
                A => a(i),
                B => b(i),
                Q => mult_result(i),
                DOUT_VALID => mult_dout_valid(i)
            );
    end generate;

    -- Main process
    process (CLK, RST)
    begin
        if RST = '1' then
            -- Reset logic
            main_state <= IDL;
           cal_state <= cal_calc;
            address_counter <= 0;
            ram_wren <= '0';
            matrix_index <= (others => '0');
            DATA_REQUEST <= '0';
            done <= '0';
            result_ready1 <= '0';
				clock_count <= 0 ; 
				from_disply_START<='0';
				matrix_index <= (others => '0');
				DISPLAY_COUNT <= 0 ;
				delay_counter <= 0;
				                        DISPLAY_COUNT <= 0;
                        main_state <= IDL;
                        done <= '0';
                        main_state <= IDL;
                        cal_state <= cal_read;
								result_ready1 <= '0';
				--k<='0';

        elsif rising_edge(CLK) then
            case main_state is
                when IDL =>
                    -- Reset all signals in IDL state
						  matrix_index <= (others => '0');
                    address_counter <= 0;
                    ram_data <= (others => '0');
                    ram_wren <= '0';
                    ram_address <= (others => '0');
                    ram_byteena <= (others => '0');
                    a <= (others => (others => '0'));
                    b <= (others => (others => '0'));
                    mult_din_valid <= (others => '0');
                    cal_array <= (others => (others => '0'));
                    DATA_REQUEST <= '0';
                    done <= '0';
                    result_ready1 <= '0';
						  clock_count <= 0 ; 
						  j<= 16;
						  i<=0;
						  DISPLAY_COUNT <= 0 ;
						  main_state <= IDL; 
						  result_mat_place <= 0;
                   if delay_counter < 5 then
								  delay_counter <= delay_counter + 1;
							 elsif START = '1' then
								  main_state <= MAT1;
								  DATA_REQUEST <= '1';
								  delay_counter <= 0; -- Reset the delay counter
							 end if;

                when MAT1 =>
                    -- Matrix 1 loading state logic
                    if address_counter < 16 then
                        DATA_REQUEST <= '0';
                        if DIN_VALID = '1' then
                            ram_wren <= '1';
                            ram_address <= std_logic_vector(to_unsigned(address_counter, ADDRESS_BITS));
                            ram_byteena <= (others => '1');
                            ram_data <= DIN;
                            cal_array(address_counter) <= DIN;
                            address_counter <= address_counter + 1;
                        end if;
                    else
                        main_state <= MAT2;
                       -- done <= '0';
                        DATA_REQUEST <= '1';
                    end if;

                when MAT2 =>
                    -- Matrix 2 loading state logic
                    if address_counter < 32 then
                        DATA_REQUEST <= '0';
                        if DIN_VALID = '1' then
                            ram_wren <= '1';
                            ram_address <= std_logic_vector(to_unsigned(address_counter, ADDRESS_BITS));
                            ram_byteena <= (others => '1');
                            ram_data <= DIN;
                            cal_array(address_counter) <= DIN;
                            address_counter <= address_counter + 1;
                        end if;
                    else
                        ram_wren <= '0';
                        done <= '1';
                    end if;

                    if START = '1' and done = '1' then
                        main_state <= CAL;
                        cal_state <= cal_read;
								address_counter <= 0;
                    end if;

                when CAL =>
					  if result_ready1 = '1' and START = '1' then
                                main_state <= DISP;
                                cal_state <= cal_read;
                                result_mat_place <= 0;
										  result_ready1 <= '1';
						else
                    case cal_state is
                        when cal_read =>
                            -- Reading data for calculation
                           -- mult_din_valid <= (others => '0');
                            cal_counter <= 0;
                            cal_state <= cal_calc;

                        when cal_calc =>
                            -- Performing the calculation
									 if i < 16 then
                                    a(0) <= cal_array(i);
                                    a(1) <= cal_array(i + 1);
                                    a(2) <= cal_array(i + 2);
                                    a(3) <= cal_array(i + 3);
                                    --i <= i + 4;
												 
													 
											   b(0) <= cal_array(j);
											   b(1) <= cal_array(j + 4);
											   b(2) <= cal_array(j + 8);
											   b(3) <= cal_array(j + 12);
											   j <= j + 1;
											   mult_din_valid <= (others => '1');
												cal_state <= cal_write;
												
                                
										  -- mult_din_valid <= (others => '1');
                            else
                               -- mult_din_valid <= (others => '0');
                                i <= 0;
											-- cal_state <= cal_write;
                            end if;

                        when cal_write =>
                            -- Writing the result of the calculation
									 
                            final_ram_wren <= '1';
                            final_ram_address <= std_logic_vector(to_unsigned(result_mat_place, ADDRESS_BITS));
                            final_ram_byteena <= (others => '1');

                            -- Prepare the data to be written
                            
                                if result_mat_place < 17  and mult_dout_valid= "1111" then
										  
                                    matrix(result_mat_place) <= std_logic_vector(
                                        to_signed(
                                            to_integer(signed(mult_result(0))) +
                                            to_integer(signed(mult_result(1))) +
                                            to_integer(signed(mult_result(2))) +
                                            to_integer(signed(mult_result(3))),
                                            17
                                        )
                                    );
												final_ram_data(16 DOWNTO 0) <= matrix(result_mat_place);
												integer_matrix(result_mat_place) <=    to_integer(signed(mult_result(0))) +
                                            to_integer(signed(mult_result(1))) +
                                            to_integer(signed(mult_result(2))) +
                                            to_integer(signed(mult_result(3)));
                                    result_mat_place <= result_mat_place + 1;
                                    cal_state <= cal_calc;
											elsif result_mat_place = 17 then
												result_ready1 <= '1';
												main_state <= DISP;
												--matrix_index <= matrix(1);
												--DISPLAY_COUNT <= DISPLAY_COUNT + 1;
												

                                end if;
										  if j =20 then
										  
												 cal_state <= cal_calc;
                                    j <= 16;
                                    i <= i+4;
											end if ;
								                           
                    end case;
						  end if;

                when DISP =>
					 
                    if DISPLAY = '1' then
                        if DISPLAY_COUNT < 16 then
                            matrix_index <= matrix(DISPLAY_COUNT+1);
                            DISPLAY_COUNT <= DISPLAY_COUNT + 1;
                        else
                            DISPLAY_COUNT <= 0;
                        end if;
							end if;
							
							if DISPLAY_COUNT = 16 then 
							 DISPLAY_COUNT <= 0;
                      end if;
							
						  if START = '1' then
                        DISPLAY_COUNT <= 0;
                        main_state <= IDL;
                        done <= '0';
                        main_state <= IDL;
                        cal_state <= cal_read;
								result_ready1 <= '0';
								from_disply_START <= '1' ;
								end if;
						  
            end case;
        end if;
    end process;

    GOT_ALL_MATRICES <= done;
    RESULT <= matrix_index;
    RESULT_READY <= result_ready1;

end Behavioral;
