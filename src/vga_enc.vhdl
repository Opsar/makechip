library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity tt_um_vga_example is
  port (
    ui_in   : in std_logic_vector(7 downto 0);
    uo_out  : out std_logic_vector(7 downto 0);
    uio_in  : in std_logic_vector(7 downto 0);
    uio_out : out std_logic_vector(7 downto 0);
    uio_oe  : out std_logic_vector(7 downto 0);
    ena     : in std_logic;
    clk     : in std_logic;
    rst_n   : in std_logic
  );
end tt_um_vga_example;

architecture rtl of tt_um_vga_example is

  signal hsync, vsync : std_logic;
  signal R, G, B      : std_logic_vector(1 downto 0);
  signal video_active : std_logic;
  signal pix_x, pix_y : std_logic_vector(9 downto 0);
begin

  uo_out <= hsync & B(0) & G(0) & R(0) & vsync & B(1) & G(1) & R(1);

  vga_sync_gen_inst : entity work.vga_sync_gen
    port map
    (
      clk        => clk,
      reset      => rst_n,
      hsync      => hsync,
      vsync      => vsync,
      display_on => video_active,
      hpos       => pix_x,
      vpos       => pix_y
    );

  R <= (pix_x(0) & pix_y(4)) when video_active = '1' else
    "00";
  G <= (pix_x(1) & pix_y(2)) when video_active = '1' else
    "00";
  B <= (pix_x(2) & pix_y(3)) when video_active = '1' else
    "00";

  uio_oe  <= "00000000";
  uio_out <= "00000000";

end architecture;