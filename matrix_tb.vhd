-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Thu, 09 Apr 2026 13:34:44 GMT
-- Request id : cfwk-fed377c2-69d7aaf46fb6c

library ieee;
use ieee.std_logic_1164.all;

entity tb_matrix is
end tb_matrix;

architecture tb of tb_matrix is

    component matrix
        port (clk    : in std_logic;
              rst    : in std_logic;
              btn_P1 : in std_logic_vector (7 downto 0);
              btn_P2 : in std_logic_vector (7 downto 0);
              alu_Y  : in std_logic_vector (2 downto 0);
              alu_X  : in std_logic_vector (3 downto 0);
              spi_Y  : in std_logic_vector (2 downto 0);
              spi_X  : out std_logic_vector (15 downto 0));
    end component;

    signal clk    : std_logic;
    signal rst    : std_logic;
    signal btn_P1 : std_logic_vector (7 downto 0);
    signal btn_P2 : std_logic_vector (7 downto 0);
    signal alu_Y  : std_logic_vector (2 downto 0);
    signal alu_X  : std_logic_vector (3 downto 0);
    signal spi_Y  : std_logic_vector (2 downto 0);
    signal spi_X  : std_logic_vector (15 downto 0);

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : matrix
    port map (clk    => clk,
              rst    => rst,
              btn_P1 => btn_P1,
              btn_P2 => btn_P2,
              alu_Y  => alu_Y,
              alu_X  => alu_X,
              spi_Y  => spi_Y,
              spi_X  => spi_X);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        btn_P1 <= b"0000_1110";
        btn_P2 <= b"1110_0000";
        alu_Y <= b"001";
        alu_X <= b"0001";
        spi_Y <= b"111";

        -- Reset generation
        -- ***EDIT*** Check that rst is really your reset signal
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;
        
        alu_X <= b"0000";
        alu_Y <= b"000";
        btn_P1 <= b"0000_0111";
        btn_P2 <= b"0000_0111";
        wait for 50 ns;
        spi_Y <= b"001";
        

        -- ***EDIT*** Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_matrix of tb_matrix is
    for tb
    end for;
end cfg_tb_matrix;