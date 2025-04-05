library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync_gen is
  port (
    clk        : in std_logic;
    reset      : in std_logic;
    hsync      : out std_logic;
    vsync      : out std_logic;
    display_on : out std_logic;
    hpos       : out std_logic_vector(9 downto 0);
    vpos       : out std_logic_vector(9 downto 0)
  );
end entity;

architecture rtl of vga_sync_gen is
  -- Horizontal constants
  constant h_display : integer := 640; -- Horizontal display width
  constant h_back    : integer := 48; -- Horizontal left border
  constant h_front   : integer := 16; -- Horizontal right border
  --constant h_sync    : integer := 96; -- Horizontal sync width

  -- Vertical constants
  constant v_display : integer := 480; -- Vertical display height
  --constant v_top     : integer := 33; -- Vertical top border
  constant v_bottom  : integer := 10; -- Vertical bottom border
  --constant v_sync    : integer := 2; -- Vertical sync lines

  -- Derived constants
  constant h_sync_start : integer := h_display + h_front;
  constant h_sync_end   : integer := h_display + h_front + 96 - 1;
  constant h_max        : integer := h_display + h_back + h_front + 96 - 1;
  constant v_sync_start : integer := v_display + v_bottom;
  constant v_sync_end   : integer := v_display + v_bottom + 2 - 1;
  constant v_max        : integer := v_display + 33 + v_bottom + 2 - 1;

  signal hmaxxed, vmaxxed   : std_logic;
  signal hpos_cnt, vpos_cnt : unsigned(9 downto 0) := to_unsigned(0, 10);
begin
  hmaxxed <= '1' when (hpos_cnt = h_max or reset = '0') else
    '0';
  vmaxxed <= '1' when (vpos_cnt = v_max or reset = '0') else
    '0';

  hpos <= std_logic_vector(hpos_cnt);
  vpos <= std_logic_vector(vpos_cnt);

  -- Horizontal counter
  process (clk)
  begin
    if rising_edge(clk) then
        if (hpos_cnt >= h_sync_start and hpos_cnt <= h_sync_end) then
            hsync <= '1';
        else
            hsync <= '0';
        end if;
      if hmaxxed = '1' then
        hpos_cnt <= to_unsigned(0, 10);
      else
        hpos_cnt <= hpos_cnt + 1;
      end if;
    end if;
  end process;

  -- Vertical counter
  process (clk)
  begin
    if rising_edge(clk) then
      if (vpos_cnt >= v_sync_start and vpos_cnt <= v_sync_end) then
        vsync <= '1';
      else
        vsync <= '0';
      end if;
      if hmaxxed = '1' then
        if vmaxxed = '1' then
          vpos_cnt <= to_unsigned(0, 10);
        else
          vpos_cnt <= vpos_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  display_on <= '1' when ((hpos_cnt<h_display) and (vpos_cnt<v_display)) else '0';
end architecture;