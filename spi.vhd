----------------------------------------------------------------------------------
-- Modul: spi
-- Popis: Synchronní SPI vysílač s generováním SPI hodin.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi is
    Port ( 
        clk          : in  STD_LOGIC; -- Hlavní hodiny FPGA
        rst          : in  STD_LOGIC;
        ce           : in  STD_LOGIC; -- Clock enable ze zpomalovače (clk_en)
        addres       : in  STD_LOGIC; -- Výběr matice: '0' = CS1, '1' = CS2
        spi_start    : in  STD_LOGIC;
        data_in      : in  STD_LOGIC_VECTOR (15 downto 0);
        data_out     : out STD_LOGIC; -- MOSI
        spi_clk_out  : out STD_LOGIC; -- Hodiny pro matici (SCK)
        cs_1         : out STD_LOGIC;
        cs_2         : out STD_LOGIC;
        spi_complete : out STD_LOGIC
    );
end spi;

architecture Behavioral of spi is

    -- Stavy FSM pro bezpečné vygenerování SPI hodin (SCK)
    type state_type is (IDLE, SHIFT_LOW, SHIFT_HIGH, DONE);
    signal current_state : state_type;

    signal current_bit_index : integer range 0 to 15;
    signal shift_reg         : std_logic_vector(15 downto 0);
    
begin

    transmit : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state     <= IDLE;             
                cs_1              <= '1';             
                cs_2              <= '1';             
                spi_complete      <= '0';
                data_out          <= '0'; 
                spi_clk_out       <= '0'; -- Výchozí stav hodin v nečinnosti
                current_bit_index <= 0;               
                shift_reg         <= (others => '0'); 

            elsif ce = '1' then -- Celý proces reaguje pouze na "tiknutí" ze zpomalovače
                
                case current_state is
                    when IDLE =>
                        spi_complete <= '0';
                        cs_1         <= '1';             
                        cs_2         <= '1';
                        data_out     <= '0';
                        spi_clk_out  <= '0';

                        if spi_start = '1' then
                            current_state <= SHIFT_LOW;
                            shift_reg     <= data_in;       
                            current_bit_index <= 0; -- Posíláme od nultého bitu nahoru
                        end if;

                    when SHIFT_LOW =>
                        -- Fáze 1: Hodiny jsou dole, nastavíme data na výstup
                        spi_clk_out  <= '0';
                        
                        -- Výběr zařízení podle adresy
                        if addres = '0' then
                            cs_1 <= '0'; cs_2 <= '1';
                        else
                            cs_1 <= '1'; cs_2 <= '0';
                        end if;
                        
                        data_out <= shift_reg(current_bit_index);
                        current_state <= SHIFT_HIGH;

                    when SHIFT_HIGH =>
                        -- Fáze 2: Hodiny jdou nahoru (zde si přijímač přečte bit)
                        spi_clk_out <= '1';
                        
                        if current_bit_index = 15 then
                            current_state <= DONE;
                        else
                            current_bit_index <= current_bit_index + 1;
                            current_state <= SHIFT_LOW;
                        end if;
                        
                    when DONE =>
                        -- Ukončení přenosu
                        spi_clk_out  <= '0';
                        spi_complete <= '1';
                        cs_1         <= '1';
                        cs_2         <= '1';
                        current_state <= IDLE;

                    when others =>
                        current_state <= IDLE;
                end case;
            end if;
        end if;
    end process transmit;
end Behavioral;