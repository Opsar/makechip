library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tt_um_example is
    port (
        ui_in   : in  std_logic_vector(7 downto 0);
        uo_out  : out std_logic_vector(7 downto 0);
        uio_in  : in  std_logic_vector(7 downto 0);
        uio_out : out std_logic_vector(7 downto 0);
        uio_oe  : out std_logic_vector(7 downto 0);
        ena     : in  std_logic;
        clk     : in  std_logic;
        rst_n   : in  std_logic
    );
end tt_um_example;

architecture Behavioral of tt_um_example is
    component KBD_ENC
        port ( clk	                : in std_logic;			-- system clock (100 MHz)
	        rst		        : in std_logic;			-- reset signal
         PS2KeyboardCLK	        : in std_logic; 		-- USB keyboard PS2 clock
         PS2KeyboardData	: in std_logic;			-- USB keyboard PS2 data
         data			: out std_logic_vector(7 downto 0); 	-- tile data
         ps2_code_new   : out std_logic
    );
    end component;

    component vga_converter
    port(
        clk, rst   : in std_logic;
        x_pos, y_pos: out   std_logic_vector(2 downto 0);
        hsync      : out std_logic;
        vsync      : out std_logic;
        display_on : out std_logic;
        hpos       : in std_logic_vector(9 downto 0);
        vpos       : in std_logic_vector(9 downto 0)
    );
    end component;

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

    signal key_bus, key_reg: std_logic_vector(7 downto 0);
    signal ps2_code_new: std_logic;
    signal hsync, vsync: std_logic;
    signal R, G, B: std_logic_vector(1 downto 0);
    signal video_active: std_logic;
    signal pix_x, pix_y: std_logic_vector(2 downto 0);
    signal hpos, vpos: std_logic_vector(9 downto 0);



begin

    uo_out <= hsync & B(0) & G(0) & R(0) & vsync & B(1) & G(1) & R(1);
    uio_oe <= "00000000";
    uio_out <= "00000000";
    process(clk)
    begin

    -- Colour logic here
    if video_active = '1' then
        R <= "11";
        G <= "11";
        B <= "11";
    else
        R <= "00";
        G <= "00";
        B <= "00";
    end if;
    end process;

    U0  :   KBD_ENC port map(
                clk => clk, rst => rst_n,
                PS2KeyboardData => ui_in(0), PS2KeyboardCLK => ui_in(1), data => key_bus, 
                ps2_code_new => ps2_code_new
            );

    V0  :   vga_converter port map(
        clk => clk, rst => rst_n, x_pos => pix_x, y_pos => pix_y, 
        vsync => vsync, hsync => hsync, display_on => video_active, hpos => hpos,
        vpos => vpos
    );

    V1  :   vga_sync_gen port map(
        clk => clk, reset => rst_n, hsync => hsync, vsync => vsync, 
        display_on => video_active, hpos => hpos, vpos => vpos
    );
    process(clk, rst_n)
    begin
        if rst_n = '1' then
            key_reg <= (others => '0');
        elsif rising_edge(clk) and ps2_code_new = '1' then
            key_reg <= key_bus;
        end if;
    end process;

    -- uo_out <= key_reg;

end Behavioral;