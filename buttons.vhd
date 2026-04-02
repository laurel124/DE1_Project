library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pingpong is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           p1_up : in STD_LOGIC;
           p1_down : in STD_LOGIC;
           p2_up : in STD_LOGIC;
           p2_down : in STD_LOGIC;
           p1 : out std_logic_vector(7 downto 0) --poloha hraca vo vertikalnej bocnej strane matice
           p2 : out std_logic_vector(7 downto 0)        
end pingpong;

architecture Behavioral of pingpong is

begin


end Behavioral;
