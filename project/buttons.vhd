library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity buttons is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        p1_up : in STD_LOGIC;
        p1_down : in STD_LOGIC;
        p2_up : in STD_LOGIC;
        p2_down : in STD_LOGIC;
        p1 : out STD_LOGIC_VECTOR(7 downto 0);
        p2 : out STD_LOGIC_VECTOR(7 downto 0)
    );
end buttons;

architecture Behavioral of buttons is

    -- horna pozicia palky
    signal p1_pos : integer range 0 to 5 := 2;
    signal p2_pos : integer range 0 to 5 := 2;

begin

    -- pohyb hracov
    process(clk, rst)
    begin
        if rst = '1' then
            p1_pos <= 2;
            p2_pos <= 2;

        elsif rising_edge(clk) then

            -- hrac 1
            if p1_up = '1' and p1_down = '0' then
                if p1_pos > 0 then
                    p1_pos <= p1_pos - 1;
                end if;

            elsif p1_down = '1' and p1_up = '0' then
                if p1_pos < 5 then
                    p1_pos <= p1_pos + 1;
                end if;
            end if;

            -- hrac 2
            if p2_up = '1' and p2_down = '0' then
                if p2_pos > 0 then
                    p2_pos <= p2_pos - 1;
                end if;

            elsif p2_down = '1' and p2_up = '0' then
                if p2_pos < 5 then
                    p2_pos <= p2_pos + 1;
                end if;
            end if;

        end if;
    end process;

    -- vystup pre hraca 1
    p1 <= "00000111" when p1_pos = 0 else
          "00001110" when p1_pos = 1 else
          "00011100" when p1_pos = 2 else
          "00111000" when p1_pos = 3 else
          "01110000" when p1_pos = 4 else
          "11100000";

    -- vystup pre hraca 2
    p2 <= "00000111" when p2_pos = 0 else
          "00001110" when p2_pos = 1 else
          "00011100" when p2_pos = 2 else
          "00111000" when p2_pos = 3 else
          "01110000" when p2_pos = 4 else
          "11100000";

end Behavioral;
