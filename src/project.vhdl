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

    signal key_bus, key_reg: std_logic_vector(7 downto 0);
    signal ps2_code_new: std_logic;


begin

    U0  :   KBD_ENC port map(
                clk => clk, rst => rst_n,
                PS2KeyboardData => ui_in(0), PS2KeyboardCLK => ui_in(1), data => key_bus, 
                ps2_code_new => ps2_code_new
            );
    process(clk, rst_n)
    begin
        if rst_n = '1' then
            key_reg <= (others => 0);
        elsif rising_edge(clk) and ps2_code_new = '1' then
            key_reg <= key_bus;
        end if;
    end process;

    uo_out <= key_reg;
    uio_out(0) <= ps2_code_new;
end Behavioral;