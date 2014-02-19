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
-- Version: 2 Entirely new envelope generator is created
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
           ENV_WIDTH : in STD_LOGIC_VECTOR (31 downto 0);
           SYS_CLK : in  STD_LOGIC;
           ENV_OUT : out  STD_LOGIC);
end envelope_gen;

architecture Behavioral of envelope_gen is
  component monostable is
    generic (
      BUS_WIDTH : integer);
    port (
      PULSE_WIDTH : in  std_logic_vector((BUS_WIDTH-1) downto 0);
      TRIGGER     : in  std_logic;
      SYS_CLK     : in  std_logic;
      RST         : in  std_logic;
      OUTPUT      : out std_logic);
  end component monostable;
  signal DELAY_PULSE  : std_logic;      -- delayed pulse
  signal TRIG_int : std_logic;          -- internal trigger to monostable_envelope
  signal q2, q1, q0, DELAY_PULSE_D : std_logic;  -- for delaying the signal by 3 clock cycles

begin
  monostable_env: entity work.monostable
    generic map (
      BUS_WIDTH => 32)
    port map (
      PULSE_WIDTH => ENV_WIDTH,
      TRIGGER     => TRIG_int,
      SYS_CLK     => SYS_CLK,
      RST         => RST,
      OUTPUT      => ENV_OUT);

  monostable_delay: entity work.monostable
    generic map (
      BUS_WIDTH => 16)
    port map (
      PULSE_WIDTH => conv_std_logic_vector(432,16),
      TRIGGER     => CH1_OUT,
      SYS_CLK     => SYS_CLK,
      RST         => RST,
      OUTPUT      => DELAY_PULSE);

  -- purpose: to delay the output of monostable by 3 clock cycles
  -- type   : sequential
  -- inputs : SYS_CLK, RST, DELAY_PULSE
  -- outputs: DELAY_PULSE_D
  delaying: process (SYS_CLK, RST) is
  begin  -- process delaying
    if RST = '0' then                   -- asynchronous reset (active low)
      q0 <= '0';
      q1 <= '0';
      q2 <= '0';
      DELAY_PULSE_D <= '0';
    elsif SYS_CLK'event and SYS_CLK = '1' then  -- rising clock edge
      q0 <= DELAY_PULSE;
      q1 <= q0;
      q2 <= q1;
      DELAY_PULSE_D <= q2;
    end if;
  end process delaying;

  TRIG_int <= (not DELAY_PULSE) and DELAY_PULSE_D;
  --ENV_OUT <= TRIG_int;
end Behavioral;

