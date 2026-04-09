library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity buttons_tb is
end buttons_tb;

architecture Behavioral of buttons_tb is

    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal p1_up : STD_LOGIC := '0';
    signal p1_down : STD_LOGIC := '0';
    signal p2_up : STD_LOGIC := '0';
    signal p2_down : STD_LOGIC := '0';
    signal p1 : STD_LOGIC_VECTOR(7 downto 0);
    signal p2 : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- instancia modulu
    uut: entity work.buttons
        port map (
            clk => clk,
            rst => rst,
            p1_up => p1_up,
            p1_down => p1_down,
            p2_up => p2_up,
            p2_down => p2_down,
            p1 => p1,
            p2 => p2
        );

    -- clock
    process
    begin
        while true loop
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
    end process;

    -- test
    process
    begin
        -- reset
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        wait for 20 ns;

        -- p1 hore
        p1_up <= '1';
        wait for 100 ns;
        p1_up <= '0';
        

        wait for 100 ns;

        -- p1 dole
        p1_down <= '1';
        wait for 100 ns;
        p1_down <= '0';

        wait for 20 ns;

        -- p2 hore
        p2_up <= '1';
        wait for 40 ns;
        p2_up <= '0';

        wait for 20 ns;

        -- p2 dole
        p2_down <= '1';
        wait for 40 ns;
        p2_down <= '0';

        wait for 20 ns;

        -- naraz obe tlacidla
        p1_up <= '1';
        p1_down <= '1';
        wait for 40 ns;
        p1_up <= '0';
        p1_down <= '0';

        wait;
    end process;

end Behavioral;
