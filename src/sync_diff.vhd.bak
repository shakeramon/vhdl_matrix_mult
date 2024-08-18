library ieee;
use ieee.std_logic_1164.all;

entity sync_diff is
generic (
    G_DERIVATE_RISING_EDGE  : boolean := true;
    G_SIG_IN_INIT_VALUE     : std_logic := '0';
    G_RESET_ACTIVE_VALUE    : std_logic := '0'
);
port (
    CLK             : in    std_logic;  -- system clock
    RST             : in    std_logic;  -- asynchronous reset, polarity is according to G_RESET_ACTIVE_VALUE
    SIG_IN          : in    std_logic;  -- async input signal
    SIG_OUT         : out   std_logic   -- synced & derivative output
);
end entity;

architecture behave of sync_diff is

    signal sig_in_d     : std_logic_vector(3 downto 1) := (others=>G_SIG_IN_INIT_VALUE);


begin

    process(CLK, RST)
    begin
        if RST = G_RESET_ACTIVE_VALUE then
            sig_in_d <= (others=>G_SIG_IN_INIT_VALUE);
            SIG_OUT <= '0';
        elsif rising_edge(CLK) then
            -- delay SIG_IN by 1, 2 & 3
            sig_in_d(1) <= SIG_IN;
            sig_in_d(3 downto 2) <= sig_in_d(2 downto 1);
            
            if G_DERIVATE_RISING_EDGE then
                SIG_OUT <= sig_in_d(2) and not sig_in_d(3);
            else
                SIG_OUT <= not sig_in_d(2) and sig_in_d(3);
            end if;
        end if;
    end process;

end architecture;