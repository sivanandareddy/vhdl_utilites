----------------------------------------------------------------------------------
-- Company: RRCAT indore
-- Engineer: T. Sivananda Reddy 
-- 
-- Create Date:    18:09:19 12/10/2013 
-- Design Name: 
-- Module Name:    envelope_gen - Behavioral 
-- Project Name: Three phase pulse burst generator
-- Target Devices: 
-- Tool versions: 
-- Description: This generates a master envelope pulse using the pulse train
-- from channel 1. The output of this module is used to trim of the pulses of
-- the other channels.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity envelope_gen is
    Port ( RST : in  STD_LOGIC;
           CH1_OUT : in STD_LOGIC; 
           PULSE_OUT : in  STD_LOGIC;
           SYS_CLK : in  STD_LOGIC;
           PULSE_COUNT : in  STD_LOGIC_VECTOR (15 downto 0);
           ENV_OUT : out  STD_LOGIC);
end envelope_gen;

architecture Behavioral of envelope_gen is
signal SET  : std_logic;
signal RESET  : std_logic;
signal ENV_OUT_PREV : std_logic;
begin

  -- purpose: to latch the channel output on the falling edge of the pulse out
  -- type   : sequential
  -- inputs : PULSE_OUT, RST, CH1_out, PULSE_COUNT
  -- outputs: set, reset
  latch_ch_out: process (PULSE_OUT, RST) is
  begin  -- process latch_ch_out
    if RST = '0' then                   -- asynchronous reset (active low)
      RESET <= '0';
      SET <= '0';
    elsif PULSE_OUT'event and PULSE_OUT = '0' then  -- falling clock edge
      SET <= CH1_OUT;
      if PULSE_COUNT = "0000000000000001" then
        RESET <= '1';
      else
        RESET <= '0';
      end if;
    end if;
  end process latch_ch_out;

  -- purpose: sr flip flop to generate the envelop pulse
  -- type   : sequential
  -- inputs : SYS_CLK, RST, set, reset
  -- outputs: ENV_OUT
  sr_ff: process (SYS_CLK, RST) is
  begin  -- process sr_ff
    if RST = '0' then                   -- asynchronous reset (active low)
      ENV_OUT <= '0';
      ENV_OUT_PREV <= '0';
    elsif SYS_CLK'event and SYS_CLK = '1' then  -- rising clock edge
      if (SET = '0' and RESET = '0') then
        ENV_OUT <= ENV_OUT_PREV;
      elsif (SET = '1' and RESET = '0') then
        ENV_OUT <= '1';
        ENV_OUT_PREV <= '1';
      elsif (SET = '0' and RESET = '1') then
        ENV_OUT <= '0';
        ENV_OUT_PREV <= '0';
      elsif (SET = '1' and RESET = '1') then
        ENV_OUT <= '0';
      end if;
    end if;
  end process sr_ff;


end Behavioral;

