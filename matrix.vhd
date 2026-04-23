----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2026 04:41:51 PM
-- Design Name: 
-- Module Name: matrix - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity matrix is
    Port ( clk    : in std_logic ;
           rst    : in std_logic;
           btn_P1 : in STD_LOGIC_VECTOR (7 downto 0);
           btn_P2 : in STD_LOGIC_VECTOR (7 downto 0);
           alu_Y : in STD_LOGIC_VECTOR (2 downto 0);
           alu_X : in STD_LOGIC_VECTOR (3 downto 0);
           spi_Y : in STD_LOGIC_VECTOR (2 downto 0);
           spi_X : out STD_LOGIC_VECTOR (15 downto 0));
end matrix;

architecture Behavioral of matrix is


type MAT is array (7 downto 0) of std_logic_vector(15 downto 0);
signal mat_table : MAT;


    
begin

   p_matrix : process(clk)
        variable tmp : MAT;
        variable x_idx : integer;
        variable y_idx : integer;
        variable s_idx : integer; -- pomocná proměnná pro spi_Y
    begin
        if rising_edge(clk) then
            if rst = '1' then
                mat_table <= (others => (others => '0'));
                spi_X <= (others => '0');
            else
                -- 1) Vynulování tmp
                tmp := (others => (others => '0'));

                -- 2) Levý hráč
                for i in 0 to 7 loop
                    if btn_P1(i) = '1' then tmp(i)(0) := '1'; end if;
                end loop;

                -- 3) Pravý hráč
                for i in 0 to 7 loop
                    if btn_P2(i) = '1' then tmp(i)(15) := '1'; end if;
                end loop;

                -- 4) Míček
                x_idx := to_integer(unsigned(alu_X)) + 1;
                y_idx := to_integer(unsigned(alu_Y));

                if (x_idx >= 0 and x_idx <= 15 and y_idx >= 0 and y_idx <= 7) then
                    tmp(y_idx)(x_idx) := '1';
                end if;

                -- Uložení do signálu
                mat_table <= tmp;

                s_idx := to_integer(unsigned(spi_Y));
                
                for i in 0 to 7 loop
                    -- Prvních 8 bitů (15 downto 8) bude sloupec spi_Y
                    spi_X(i + 8) <= tmp(i)(s_idx);
                    
                    -- Druhých 8 bitů (7 downto 0) bude sloupec spi_Y + 8
                    spi_X(i)     <= tmp(i)(s_idx + 8);
                end loop;

 
            end if;
        end if;
    end process;
-- Ten původní řádek spi_X <= ... zde už nebude.

end Behavioral;
