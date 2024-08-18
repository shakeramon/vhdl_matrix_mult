library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Main_Controller is
end tb_Main_Controller;

architecture Behavioral of tb_Main_Controller is
    -- Component Declaration for the Unit Under Test (UUT)
    component Main_Controller
        generic (
            DATA_WIDTH      : integer := 8;
            ADDRESS_BITS    : integer := 5;
            MATRIX_SIZE     : integer := 4;
            N               : integer := 8;
            LATENCY         : integer range 1 to 8 := 1;
            IS_SIGNED       : boolean := true
        );
        port (
            CLK             : in  std_logic;
            RST             : in  std_logic;
            START           : in  std_logic;
            DISPLAY         : in  std_logic;
            DIN             : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            DIN_VALID       : in  std_logic;
            RESULT          : out std_logic_vector(2*DATA_WIDTH downto 0);  -- Updated width
            DATA_REQUEST    : out std_logic;
            RESULT_READY    : out std_logic;
            GOT_ALL_MATRICES: out std_logic
        );
    end component;

    -- Test Bench Signals
    signal CLK             : std_logic := '0';
    signal RST             : std_logic := '0';
    signal START           : std_logic := '0';
    signal DISPLAY         : std_logic := '0';
    signal DIN             : std_logic_vector(8-1 downto 0) := (others => '0');
    signal DIN_VALID       : std_logic := '0';
    signal RESULT          : std_logic_vector(2*8 downto 0);  -- Updated width
    signal DATA_REQUEST    : std_logic;
    signal RESULT_READY    : std_logic;
    signal GOT_ALL_MATRICES: std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: Main_Controller
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
            RST             => RST,
            START           => START,
            DISPLAY         => DISPLAY,
            DIN             => DIN,
            DIN_VALID       => DIN_VALID,
            RESULT          => RESULT,
            DATA_REQUEST    => DATA_REQUEST,
            RESULT_READY    => RESULT_READY,
            GOT_ALL_MATRICES=> GOT_ALL_MATRICES
        );

    -- Clock Process
    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus Process
    stimulus: process
    begin
        -- Initialize Inputs
        RST <= '1';
        START <= '1';
        DISPLAY <= '0';
        DIN_VALID <= '0';
        DIN <= (others => '0');

        -- Wait for global reset to finish
        wait for 2*CLK_PERIOD;
        RST <= '0';
        wait for CLK_PERIOD;

        -- Load the identity matrix into the controller
        START <= '1';
        DIN_VALID <= '1';
        for i in 0 to 15 loop
            if (i mod 4) = (i / 4) then
                DIN <= "00000001"; -- Load 1 for diagonal elements
            else
                DIN <= "00000000"; -- Load 0 for non-diagonal elements
            end if;
            wait for CLK_PERIOD;
        end loop;
        DIN_VALID <= '0';

        -- Load the 0 to 15 matrix into the controller
        wait for CLK_PERIOD;
        DIN_VALID <= '1';
        for i in 0 to 15 loop
            DIN <= std_logic_vector(to_unsigned(i, 8));
            wait for CLK_PERIOD;
        end loop;
        DIN_VALID <= '0';

        -- Simulate Display Operation
        wait for 100*CLK_PERIOD;
        DISPLAY <= '1';
        wait for 16*CLK_PERIOD;
        DISPLAY <= '0';

        -- End Simulation
        wait;
    end process;

end Behavioral;
