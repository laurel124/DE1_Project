library ieee;
use ieee.std_logic_1164.all;

entity tb_ALU is
end tb_ALU;

architecture tb of tb_ALU is

    component ALU
        port (rst        : in std_logic;
              clk        : in std_logic;
              bat1_array : in std_logic_vector (7 downto 0);
              bat2_array : in std_logic_vector (7 downto 0);
              ball_x     : out std_logic_vector (3 downto 0);
              ball_y     : out std_logic_vector (2 downto 0));
    end component;

    signal rst        : std_logic;
    signal clk        : std_logic;
    signal bat1_array : std_logic_vector (7 downto 0);
    signal bat2_array : std_logic_vector (7 downto 0);
    signal ball_x     : std_logic_vector (3 downto 0);
    signal ball_y     : std_logic_vector (2 downto 0);

    constant TbPeriod : time := 1000 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : ALU
    port map (rst        => rst,
              clk        => clk,
              bat1_array => bat1_array,
              bat2_array => bat2_array,
              ball_x     => ball_x,
              ball_y     => ball_y);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        bat1_array <= (others => '1');
        bat2_array <= (others => '1');

        -- Reset generation
        -- ***EDIT*** Check that rst is really your reset signal
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- ***EDIT*** Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_ALU of tb_ALU is
    for tb
    end for;
end cfg_tb_ALU;
