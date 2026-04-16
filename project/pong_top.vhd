library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pong_top is
    Port (
        clk          : in  STD_LOGIC;
        rst          : in  STD_LOGIC;
        btnu         : in  STD_LOGIC;
        btnl         : in  STD_LOGIC;
        btnd         : in  STD_LOGIC;
        btnr         : in  STD_LOGIC;
        spi_data_out : out STD_LOGIC;
        spi_clk_out  : out STD_LOGIC;
        spi_cs_1     : out STD_LOGIC;
        spi_cs_2     : out STD_LOGIC
    );
end pong_top;

architecture Behavioral of pong_top is

    component debounce is
        Port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            btn_in    : in  STD_LOGIC;
            btn_state : out STD_LOGIC;
            btn_press : out STD_LOGIC
        );
    end component;

    component buttons is
        Port (
            clk     : in  STD_LOGIC;
            rst     : in  STD_LOGIC;
            p1_up   : in  STD_LOGIC;
            p1_down : in  STD_LOGIC;
            p2_up   : in  STD_LOGIC;
            p2_down : in  STD_LOGIC;
            p1      : out STD_LOGIC_VECTOR(7 downto 0);
            p2      : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component ALU is
        Port (
            rst        : in  STD_LOGIC;
            clk        : in  STD_LOGIC;
            bat1_array : in  STD_LOGIC_VECTOR(7 downto 0);
            bat2_array : in  STD_LOGIC_VECTOR(7 downto 0);
            ball_x     : out STD_LOGIC_VECTOR(3 downto 0);
            ball_y     : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    component matrix is
        Port (
            clk    : in  STD_LOGIC;
            rst    : in  STD_LOGIC;
            btn_P1 : in  STD_LOGIC_VECTOR(7 downto 0);
            btn_P2 : in  STD_LOGIC_VECTOR(7 downto 0);
            alu_Y  : in  STD_LOGIC_VECTOR(2 downto 0);
            alu_X  : in  STD_LOGIC_VECTOR(3 downto 0);
            spi_Y  : in  STD_LOGIC_VECTOR(2 downto 0);
            spi_X  : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component spi_top is
        Port (
            clk             : in  STD_LOGIC;
            rst             : in  STD_LOGIC;
            matrix_data_in  : in  STD_LOGIC_VECTOR(15 downto 0);
            matrix_addr_out : out STD_LOGIC_VECTOR(2 downto 0);
            spi_data_out    : out STD_LOGIC;
            spi_clk_out     : out STD_LOGIC;
            spi_cs_1        : out STD_LOGIC;
            spi_cs_2        : out STD_LOGIC
        );
    end component;

    signal p1_up_db    : STD_LOGIC;
    signal p1_down_db  : STD_LOGIC;
    signal p2_up_db    : STD_LOGIC;
    signal p2_down_db  : STD_LOGIC;

    signal btn_press_l : STD_LOGIC;
    signal btn_press_d : STD_LOGIC;
    signal btn_press_u : STD_LOGIC;
    signal btn_press_r : STD_LOGIC;

    signal p1_sig      : STD_LOGIC_VECTOR(7 downto 0);
    signal p2_sig      : STD_LOGIC_VECTOR(7 downto 0);
    signal ball_x_sig  : STD_LOGIC_VECTOR(3 downto 0);
    signal ball_y_sig  : STD_LOGIC_VECTOR(2 downto 0);

    signal spi_row_sig : STD_LOGIC_VECTOR(2 downto 0);
    signal spi_data_sig: STD_LOGIC_VECTOR(15 downto 0);

begin

    -- BTN mapping
    -- Player 1: btnl = up, btnd = down
    -- Player 2: btnu = up, btnr = down

    db_p1_up : debounce
        port map (
            clk       => clk,
            rst       => rst,
            btn_in    => btnl,
            btn_state => p1_up_db,
            btn_press => btn_press_l
        );

    db_p1_down : debounce
        port map (
            clk       => clk,
            rst       => rst,
            btn_in    => btnd,
            btn_state => p1_down_db,
            btn_press => btn_press_d
        );

    db_p2_up : debounce
        port map (
            clk       => clk,
            rst       => rst,
            btn_in    => btnu,
            btn_state => p2_up_db,
            btn_press => btn_press_u
        );

    db_p2_down : debounce
        port map (
            clk       => clk,
            rst       => rst,
            btn_in    => btnr,
            btn_state => p2_down_db,
            btn_press => btn_press_r
        );

    inst_buttons : buttons
        port map (
            clk     => clk,
            rst     => rst,
            p1_up   => p1_up_db,
            p1_down => p1_down_db,
            p2_up   => p2_up_db,
            p2_down => p2_down_db,
            p1      => p1_sig,
            p2      => p2_sig
        );

    inst_alu : ALU
        port map (
            rst        => rst,
            clk        => clk,
            bat1_array => p1_sig,
            bat2_array => p2_sig,
            ball_x     => ball_x_sig,
            ball_y     => ball_y_sig
        );

    inst_matrix : matrix
        port map (
            clk    => clk,
            rst    => rst,
            btn_P1 => p1_sig,
            btn_P2 => p2_sig,
            alu_Y  => ball_y_sig,
            alu_X  => ball_x_sig,
            spi_Y  => spi_row_sig,
            spi_X  => spi_data_sig
        );

    inst_spi_top : spi_top
        port map (
            clk             => clk,
            rst             => rst,
            matrix_data_in  => spi_data_sig,
            matrix_addr_out => spi_row_sig,
            spi_data_out    => spi_data_out,
            spi_clk_out     => spi_clk_out,
            spi_cs_1        => spi_cs_1,
            spi_cs_2        => spi_cs_2
        );

end Behavioral;
