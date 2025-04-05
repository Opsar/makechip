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
    component ps2_rx
        port(
            clk, reset: in std_logic;
            ps2d, ps2c: in std_logic;
            rx_en: in std_logic;
            rx_done_tick: out std_logic;
            dout: out std_logic_vector(7 downto 0)
	    );
    end component;

    signal rx_done_tick: std_logic;
    signal rx_en: std_logic;

    signal key_bus: std_logic_vector(7 downto 0);


begin

    U0  :   ps2_rx port map(
                clk => clk, rst_n => reset,
                ui_in(0) => ps2d, ui_in(1) => ps2c, dout => key_bus, 
                rx_en => rx_en, rx_done_tick => rx_done_tick
            );


    --uo_out <= std_logic_vector(unsigned(ui_in) + unsigned(uio_in));
    uo_out <= not (ui_in and uio_in);
    uio_out <= "00000000";
    uio_oe <= "00000000";

end Behavioral;