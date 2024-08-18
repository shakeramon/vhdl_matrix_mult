library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ALL_Components_Pkg.all;

entity mult_matrices is
    generic (
        G_DERIVATE_RISING_EDGE : boolean := true;
        G_SIG_IN_INIT_VALUE    : std_logic := '0';
        G_RESET_ACTIVE_VALUE   : std_logic := '0'
    );
    port (
        CLK             : in  std_logic;   
        RSTn            : in  std_logic;  
        STARTn          : in  std_logic;
        DISPLAYn        : in  std_logic;
        HEX0            : out std_logic_vector(6 downto 0); 
        HEX1            : out std_logic_vector(6 downto 0); 
        HEX2            : out std_logic_vector(6 downto 0); 
        HEX3            : out std_logic_vector(6 downto 0); 
        LEDS_1E4        : out std_logic_vector(3 downto 0); 
        LED_SIGN        : out std_logic;
        LEDG            : out std_logic_vector(3 downto 1) -- Adjusted width to match standard use of 3 LEDs
    );
end entity;

architecture Behavioral of mult_matrices is

    -- Signal declarations for interconnections
    signal bcd_digits          : std_logic_vector(15 downto 0);
    signal data_request        : std_logic;
    signal data_out            : std_logic_vector(7 downto 0);
    signal data_out_valid      : std_logic;

    signal main_ctrl_result    : std_logic_vector(16 downto 0);
    signal main_ctrl_result_ready : std_logic;
	 signal GOT_ALL_MATRICES1  : std_logic;

    signal num_convert_dout    : std_logic_vector(15 downto 0);
    signal num_convert_sign    : std_logic;

    signal bcd_outputs         : std_logic_vector(4*7-1 downto 0);

    signal leds_1e4_internal   : std_logic_vector(3 downto 0); -- Internal signal for LEDS_1E4

    -- Signals for synchronized inputs using sync_diff components
    signal sync_RSTn           : std_logic;
    signal sync_STARTn         : std_logic;
    signal sync_DISPLAYn       : std_logic;

    -- Intermediate signal for inverted DISPLAYn
    signal inv_DISPLAYn        : std_logic;
	 

begin
	LEDG (1 downto 1) <= "1";
    -- Synchronize RSTn signal
    sync_RSTn <= not (RSTn);

    -- Assign the inverted value to the intermediate signal
    inv_DISPLAYn <= not DISPLAYn;

    -- Instantiate sync_diff components for synchronization of STARTn and DISPLAYn signals
    U_sync_START: sync_diff
        generic map (
            G_DERIVATE_RISING_EDGE  => true,
            G_SIG_IN_INIT_VALUE     => '0',
            G_RESET_ACTIVE_VALUE    => '1'
        )
        port map (
            CLK       => CLK,
            RST       =>sync_RSTn ,
            SIG_IN    => STARTn,
            SIG_OUT   => sync_STARTn
        );

    U_sync_DISPLAY: sync_diff
        generic map (
            G_DERIVATE_RISING_EDGE  => true,
            G_SIG_IN_INIT_VALUE     => '0',
            G_RESET_ACTIVE_VALUE    => '1'
        )
        port map (
            CLK       => CLK,
            RST       => sync_RSTn,
            SIG_IN    => DISPLAYn,
            SIG_OUT   => sync_DISPLAYn
        );

    -- Instantiate bin2bcd_12bit_sync component
    U1: bin2bcd_12bit_sync
        port map (
            binIN           => num_convert_dout,
            ones            => bcd_digits(3 downto 0),
            tenths          => bcd_digits(7 downto 4),
            hunderths       => bcd_digits(11 downto 8),
            thousands       => bcd_digits(15 downto 12),
            tensofthousands => leds_1e4_internal,
            CLK             => CLK
        );

    -- Instantiate bcd_to_7seg components for HEX displays
    gen_7seg: for i in 0 to 3 generate
        U7SEG: bcd_to_7seg
            port map (
                BCD_IN      => bcd_digits((i+1)*4-1 downto i*4),
                SHUTDOWNn   => main_ctrl_result_ready,
                D_OUT       => bcd_outputs((i+1)*7-1 downto i*7)
            );
    end generate;

    -- Assign outputs to HEX displays
    HEX0 <= bcd_outputs(6 downto 0);
    HEX1 <= bcd_outputs(13 downto 7);
    HEX2 <= bcd_outputs(20 downto 14);
    HEX3 <= bcd_outputs(27 downto 21);

    -- Instantiate data_generator component
    U6: data_generator
        port map (
            CLK             => CLK,
            RST             => sync_RSTn,
            DATA_REQUEST    => data_request,
            DOUT            => data_out,
            DOUT_VALID      => data_out_valid
        );

    -- Instantiate Main_Controller component
    U7: Main_Controller
        generic map (
            DATA_WIDTH      => 8,
            ADDRESS_BITS    => 5,
            MATRIX_SIZE     => 4,
            N               => 8,
            LATENCY         => 1,
            IS_SIGNED       => true
        )
        port map (
            CLK             => CLK,
            RST             => sync_RSTn,
            START           => sync_STARTn,
            DISPLAY         => sync_DISPLAYn,
            DIN             => data_out,
            DIN_VALID       => data_out_valid,
            RESULT          => main_ctrl_result,
            DATA_REQUEST    => data_request,
            RESULT_READY    => main_ctrl_result_ready,
				GOT_ALL_MATRICES => GOT_ALL_MATRICES1
        );
		LEDG(3)<=main_ctrl_result_ready;
		LEDG(2) <= GOT_ALL_MATRICES1;
		LEDG(1) <='1';
		
		
    -- Instantiate num_convert component
    U8: num_convert
        port map (
            CLK             => CLK,
            RST             => sync_RSTn,
            DIN             => main_ctrl_result(16 downto 0),
            DIN_VALID       => '1',
            DOUT            => num_convert_dout,
            SIGN            => num_convert_sign
        );

    -- LED Outputs
    LEDS_1E4 <= leds_1e4_internal; -- Connect internal signal to output port
    LED_SIGN <= num_convert_sign; -- Directly connect to the sign output of num_convert
    --LEDG <= (others => '0'); -- Example output for LEDG, all LEDs off
		--LEDG(1) <= main_ctrl_result_ready;
end Behavioral;
