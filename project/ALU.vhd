library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ALU is

    Port ( rst : in STD_LOGIC;

           clk : in STD_LOGIC;

           bat1_array : in STD_LOGIC_VECTOR (7 downto 0);

           bat2_array : in STD_LOGIC_VECTOR (7 downto 0);

           ball_x : out STD_LOGIC_VECTOR (3 downto 0);

           ball_y : out STD_LOGIC_VECTOR (2 downto 0));

end ALU;

architecture Behavioral of ALU is
    -- Vnitřní signály pro pozici
    signal b_x : integer range 0 to 13 := 7;
    signal b_y : integer range 0 to 7 := 3;
    
    -- Pohybový vektor (bit 1: směr X, bit 0: směr Y)
    -- X: 0 = doleva, 1 = doprava | Y: 0 = dolů, 1 = nahoru
    signal direction : std_logic_vector(1 downto 0) := "10";
    
    -- Skóre hráčů
    signal score1, score2 : integer range 0 to 15 := 0;
    
    -- Čítač pro zpomalení pohybu
    signal clk_divider : integer := 0;
    constant SPEED : integer := 5; -- Upravit
begin

    process1 : process(clk)        
        variable next_x : integer;
        variable next_y : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                b_x <= 7; 
                b_y <= 3; 
                direction <= "10"; 
                score1 <= 0;
                score2 <= 0; 
                clk_divider <= 0;
            else
                if clk_divider < SPEED then
                    clk_divider <= clk_divider + 1; -- Počítáme takty
                else
                    clk_divider <= 0; -- Dosáhli jsme SPEED, nulujeme a hýbeme kuličkou
                
                    -- 1. Načteme aktuální stav do proměnných
                    next_x := b_x;
                    next_y := b_y;

                    -- 2. Logika pro Y (steny)
                    if next_y = 0 then direction(0) <= '1'; next_y := next_y + 1;
                    elsif next_y = 7 then direction(0) <= '0'; next_y := next_y - 1;
                    elsif direction(0) = '1' then next_y := next_y + 1;
                    else next_y := next_y - 1;
                    end if;

                    -- 3. Logika pro X (pálky)
                    if next_x = 0 then
                        if bat1_array(b_y) = '1' then direction(1) <= '1'; next_x := 1;
                        else 
                            next_x := 7; next_y := 3; 
                            score2 <= score2 + 1;
                            direction <= "10";
                        end if;
                    elsif next_x = 13 then
                        if bat2_array(b_y) = '1' then direction(1) <= '0'; next_x := 12;
                        else 
                            next_x := 7; next_y := 3;
                            score1 <= score1 + 1;
                            direction <= "00";
                        end if;
                    elsif direction(1) = '1' then next_x := next_x + 1;
                    else next_x := next_x - 1;
                    end if;

                    -- 4. Zapíšeme výsledek zpět do signálů (vždy v rozsahu 0-13)
                    b_x <= next_x;
                    b_y <= next_y;
            	end if;
            end if;
        end if;
    end process;

    -- Převod vnitřních integerů na výstupní STD_LOGIC_VECTOR
    ball_x <= std_logic_vector(to_unsigned(b_x, 4));
    ball_y <= std_logic_vector(to_unsigned(b_y, 3));

end Behavioral;
