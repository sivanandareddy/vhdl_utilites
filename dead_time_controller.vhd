----------------------------------------------------------------------------------
-- Company:  RRCAT
-- Engineer: T. Sivananda reddy
-- 
-- Create Date:    17:36:30 12/13/2013 
-- Design Name: 
-- Module Name:    dead_time_controller - Behavioral 
-- Project Name:  Three phase pulse burst generator
-- Target Devices: 
-- Tool versions: 
-- Description: This creates dead time for the gate triggering pulses. This
-- actually strips of the first few micro seconds of the pulse (which is
-- decided by the dead time)
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
-- TODO: Need to draw the waveforms for this model.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dead_time_controller is
  port (PULSE_IN  : in  std_logic;
        RST       : in  std_logic;
        SYS_CLK   : in  std_logic;
        DEAD_TIME : in  std_logic_vector (15 downto 0);
        PULSE_OUT : out std_logic);
end dead_time_controller;

architecture Behavioral of dead_time_controller is

  component monostable is
    port (
      PULSE_WIDTH : in  std_logic_vector(15 downto 0);
      TRIGGER     : in  std_logic;
      SYS_CLK     : in  std_logic;
      RST         : in  std_logic;
      OUTPUT      : out std_logic);
  end component monostable;

  signal q1, q0   : std_logic;
  signal MONO_OUT : std_logic;

begin

  monostable_1 : monostable
    port map (
      PULSE_WIDTH => DEAD_TIME,
      TRIGGER     => PULSE_IN,
      SYS_CLK     => SYS_CLK,
      RST         => RST,
      OUTPUT      => MONO_OUT);

  -- purpose: process to delay the signal for two clock cycles
  -- type   : sequential
  -- inputs : SYS_CLK, RST, PULSE_IN
  -- outputs: q1
  delay_2clks : process (SYS_CLK, RST) is
  begin  -- process delay_2clks
    if RST = '0' then                   -- asynchronous reset (active low)
      q1 <= '0';
      q0 <= '0';
    elsif SYS_CLK'event and SYS_CLK = '1' then  -- rising clock edge
      q0 <= PULSE_IN;
      q1 <= q0;
    end if;
  end process delay_2clks;

  PULSE_OUT <= q1 and (not MONO_OUT);

end Behavioral;

