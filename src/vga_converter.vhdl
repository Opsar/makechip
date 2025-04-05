library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_converter is 
    port(
        clk, rst   : in std_logic;
        x_pos, y_pos: out   std_logic_vector(2 downto 0);
        hsync      : out std_logic;
        vsync      : out std_logic;
        display_on : out std_logic;
        hpos       : in std_logic_vector(9 downto 0);
        vpos       : in std_logic_vector(9 downto 0)
    );
end entity;
architecture Behavioral of vga_converter is
    component vga_sync_gen
        port (
            clk        : in std_logic;
            reset      : in std_logic;
            hsync      : out std_logic;
            vsync      : out std_logic;
            display_on : out std_logic;
            hpos       : out std_logic_vector(9 downto 0);
            vpos       : out std_logic_vector(9 downto 0)
        );
    end component;

    signal pix_x: std_logic_vector(9 downto 0);
    signal pix_y: std_logic_vector(9 downto 0);

    signal pix_x_int: integer;
    signal pix_y_int: integer;



begin

    process(clk, rst)
    begin
    if rising_edge(clk) then

        pix_x_int <= to_integer(unsigned(hpos))/80;
        pix_y_int <= to_integer(unsigned(vpos))/60;

    end if;
    end process;
    process(clk)
    begin
        if rising_edge(clk) then
            x_pos <= std_logic_vector(to_unsigned(pix_x_int, x_pos'length));
            y_pos <= std_logic_vector(to_unsigned(pix_y_int, y_pos'length));
        end if;
    end process;
    V0: vga_sync_gen port map(
        clk => clk,
        reset => rst,
        hsync => hsync,
        vsync => vsync,
        display_on => display_on,
        hpos => pix_x,
        vpos => pix_y
    );

end architecture;

