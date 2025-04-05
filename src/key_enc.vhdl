--------------------------------------------------------------------------------
-- KBD ENC
-- Anders Nilsson
-- 16-feb-2016
-- Version 1.1


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations

-- entity
entity KBD_ENC is
  port ( clk	                : in std_logic;			-- system clock (100 MHz)
	 rst		        : in std_logic;			-- reset signal
         PS2KeyboardCLK	        : in std_logic; 		-- USB keyboard PS2 clock
         PS2KeyboardData	: in std_logic;			-- USB keyboard PS2 data
         data			: out std_logic_vector(7 downto 0); 	-- tile data
         ps2_code_new   : out std_logic
  );
end KBD_ENC;

-- architecture
architecture behavioral of KBD_ENC is
  signal PS2Clk			: std_logic;			-- Synchronized PS2 clock
  signal PS2Data		: std_logic;			-- Synchronized PS2 data
  signal PS2Clk_Q1, PS2Clk_Q2 	: std_logic;			-- PS2 clock one pulse flip flop
  signal PS2Clk_op 		: std_logic;			-- PS2 clock one pulse

  signal PS2Data_sr 		: std_logic_vector(10 downto 0);-- PS2 data shift register

  signal PS2BitCounter	        : unsigned(3 downto 0);		-- PS2 bit counter

  type state_type is (IDLE, MAKE, BREAK);			-- declare state types for PS2
  signal PS2state : state_type;					-- PS2 state

  signal ScanCode		: std_logic_vector(7 downto 0);	-- scan code


begin

  -- Synchronize PS2-KBD signals
  process(clk)
  begin
    if rising_edge(clk) then
      PS2Clk <= PS2KeyboardCLK;
      PS2Data <= PS2KeyboardData;
    end if;
  end process;


  -- Generate one cycle pulse from PS2 clock, negative edge

  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        PS2Clk_Q1 <= '1';
        PS2Clk_Q2 <= '0';
      else
        PS2Clk_Q1 <= PS2Clk;
        PS2Clk_Q2 <= not PS2Clk_Q1;
      end if;
    end if;
  end process;

  PS2Clk_op <= (not PS2Clk_Q1) and (not PS2Clk_Q2);



  -- PS2 data shift register

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  PS2_data_shift_reg             *
  -- *                                 *
  -- ***********************************
  process(clk) begin
    -- to make every action synchronos
    if rising_edge(clk) then
      -- rest internal values to 0
      if rst = '1' then
        PS2Data_sr <= (others => '0');
        -- on PS2Clk_op pulse shift in the new bit from PS2Data
      elsif PS2Clk_op = '1' then
          PS2Data_sr <= PS2Data & PS2Data_sr(10 downto 1);
      end if;
    end if;
  end process;



  ScanCode <= PS2Data_sr(8 downto 1);

  -- PS2 bit counter
  -- The purpose of the PS2 bit counter is to tell the PS2 state machine when to change state

  -- ***********************************
  -- *                                 *
  -- *  VHDL for :                     *
  -- *  PS2_bit_Counter                *
  -- *                                 *
  -- ***********************************
  process(clk) begin
    -- to make every action synchronos
    if rising_edge(clk) then
      ps2_code_new <= '0';

      -- rest internal value to 0
      if rst = '1' then
        PS2BitCounter <= (others => '0');
        ps2_code_new <= '0';
      elsif PS2Clk_op = '1' and PS2BitCounter < 11 then
        -- add one to counter to reset at 11 becuse of overflow
        PS2BitCounter <= PS2BitCounter + 1;
      elsif PS2BitCounter = 11 then
        PS2BitCounter <= (others => '0');
        ps2_code_new <= '1';
      end if;
    end if;
  end process;


  -- data output is set to be x"1F" (cursor tile index) during WRCUR state, otherwise set as scan code tile index
  data <= ScanCode;


end behavioral;