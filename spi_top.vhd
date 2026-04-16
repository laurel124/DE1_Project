library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Přidáno pro matematické přičtení adresy

entity spi_top is
    Port (
        clk             : in  STD_LOGIC;
        rst             : in  STD_LOGIC;
        
        -- Rozhraní matice/paměti (16 bitů = 8 bitů pro matici 1 + 8 bitů pro matici 2)
        -- Předpokládáme: data(15 downto 8) = matice 1, data(7 downto 0) = matice 2
        matrix_data_in  : in  STD_LOGIC_VECTOR(15 downto 0); 
        matrix_addr_out : out STD_LOGIC_VECTOR(2 downto 0);
        
        -- Fyzické piny ven z FPGA
        spi_data_out    : out STD_LOGIC;
        spi_clk_out     : out STD_LOGIC; -- Tento pin půjde do hodinových vstupů LED matic
        spi_cs_1        : out STD_LOGIC;
        spi_cs_2        : out STD_LOGIC
    );
end spi_top;

architecture Behavioral of spi_top is

    -- =======================================================================
    -- DEKLARACE KOMPONENT
    -- =======================================================================
    
    component clk_en is
        generic (
            G_MAX : positive := 5
        );
        Port ( 
            clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
            ce  : out STD_LOGIC
        );
    end component;

    component counter is
        generic (
            G_BITS : positive := 3
        );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            en  : in  std_logic;
            cnt : out std_logic_vector(G_BITS - 1 downto 0)
        );
    end component;

    component spi is
        Port ( 
            clk          : in  STD_LOGIC;
            rst          : in  STD_LOGIC;
            ce           : in  STD_LOGIC;
            addres       : in  STD_LOGIC;
            spi_start    : in  STD_LOGIC;
            data_in      : in  STD_LOGIC_VECTOR (15 downto 0);
            data_out     : out STD_LOGIC;
            spi_clk_out  : out STD_LOGIC;
            cs_1         : out STD_LOGIC;
            cs_2         : out STD_LOGIC;
            spi_complete : out STD_LOGIC
        );
    end component;

    -- FSM stavy pro řízení dvou SPI přenosů
    type t_state is (SET_MATRIX, START_SPI_1, WAIT_SPI_1, START_SPI_2, WAIT_SPI_2);
    signal current_state, next_state : t_state;

    -- Interní propojovací signály
    signal s_ce          : std_logic;
    signal s_row_addr    : std_logic_vector(2 downto 0);
    signal s_cnt_en      : std_logic;
    signal s_cnt_en_pulse: std_logic; -- Přidán signál pro korektní čítání
    
    signal s_spi_start   : std_logic;
    signal s_spi_comp    : std_logic;
    signal s_spi_addres  : std_logic;
    signal s_spi_data_in : std_logic_vector(15 downto 0);

    signal s_matrix_addr_4bit : std_logic_vector(3 downto 0); -- Přidán 4bitový vektor adresy

begin

    -- Výstup řádku pro externí logiku/paměť
    matrix_addr_out <= s_row_addr;
    
    -- MAX7219 používá pro řádky adresy 1 až 8 (adresa 0 je No-Op!)
    -- Proto vezmeme 3-bitový čítač (0-7), uděláme z něj 4-bitové číslo a přičteme 1
    s_matrix_addr_4bit <= std_logic_vector(unsigned("0" & s_row_addr) + 1);

    -- Tímto zajistíme, že čítač se zvedne PŘESNĚ o 1. 
    -- Povolení se uplatní jen při společném hodinovém taktu (s_ce).
    s_cnt_en_pulse <= s_cnt_en and s_ce;

    -- =======================================================================
    -- INSTANCOVÁNÍ PODŘÍZENÝCH MODULŮ
    -- =======================================================================
    inst_clk_en : clk_en
        generic map (G_MAX => 5) 
        port map (
            clk => clk,
            rst => rst,
            ce  => s_ce
        );

    inst_counter : counter
        generic map (G_BITS => 3)
        port map (
            clk => clk,
            rst => rst,
            en  => s_cnt_en_pulse, -- Použití našeho 1-taktového pulzu!
            cnt => s_row_addr
        );

    inst_spi : spi
        port map (
            clk          => clk,
            rst          => rst,
            ce           => s_ce,
            addres       => s_spi_addres,
            spi_start    => s_spi_start,
            data_in      => s_spi_data_in,
            data_out     => spi_data_out,
            spi_clk_out  => spi_clk_out,
            cs_1         => spi_cs_1,
            cs_2         => spi_cs_2,
            spi_complete => s_spi_comp
        );

    -- =======================================================================
    -- HLAVNÍ STAVOVÝ AUTOMAT (FSM)
    -- =======================================================================
    
    p_fsm_seq : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= SET_MATRIX;
            elsif s_ce = '1' then 
                current_state <= next_state;
            end if;
        end if;
    end process;

    p_fsm_comb : process(current_state, s_spi_comp, s_row_addr, matrix_data_in)
    begin
        -- Výchozí hodnoty (data_in a addres už nenulujeme, musíme je držet!)
        next_state    <= current_state; 
        s_spi_start   <= '0';
        s_cnt_en      <= '0';
        
        -- Důležité: Výchozí hodnoty zachovávají bezpečný stav, ale v logice 
        -- je specifikujeme plně pro každý stav.
        s_spi_addres  <= '0'; 
        s_spi_data_in <= (others => '0');

        case current_state is

            when SET_MATRIX =>
                next_state <= START_SPI_1;

            when START_SPI_1 =>
                -- SPRÁVNÉ POŘADÍ BÍTŮ PRO MAX7219: 4 nuly & 4 bity adresy & 8 bitů dat
                s_spi_data_in <= "0000" & s_matrix_addr_4bit & matrix_data_in(15 downto 8);
                s_spi_addres  <= '0'; -- Výběr CS1
                s_spi_start   <= '1';
                next_state    <= WAIT_SPI_1;

            when WAIT_SPI_1 =>
                -- Ve fázi čekání držíme data i adresu nastavenou na CS1
                s_spi_data_in <= "0000" & s_matrix_addr_4bit & matrix_data_in(15 downto 8);
                s_spi_addres  <= '0'; 
                
                if s_spi_comp = '1' then
                    next_state <= START_SPI_2;
                end if;

            when START_SPI_2 =>
                -- SPRÁVNÉ POŘADÍ BÍTŮ PRO MAX7219: 4 nuly & 4 bity adresy & 8 bitů dat
                s_spi_data_in <= "0000" & s_matrix_addr_4bit & matrix_data_in(7 downto 0);
                s_spi_addres  <= '1'; -- Výběr CS2
                s_spi_start   <= '1';
                next_state    <= WAIT_SPI_2;

            when WAIT_SPI_2 =>
                -- Ve fázi čekání držíme data i adresu na CS2
                s_spi_data_in <= "0000" & s_matrix_addr_4bit & matrix_data_in(7 downto 0);
                s_spi_addres  <= '1'; 
                
                if s_spi_comp = '1' then
                    s_cnt_en   <= '1';         -- Požadavek na posun řádku
                    next_state <= SET_MATRIX;
                end if;

            when others =>
                next_state <= SET_MATRIX;

        end case;
    end process;

end Behavioral;