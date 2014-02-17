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

begin
  monostable_1: entity work.monostable
    generic map (
      BUS_WIDTH => 32)
    port map (
      PULSE_WIDTH => ENV_WIDTH,
      TRIGGER     => CH1_OUT,
      SYS_CLK     => SYS_CLK,
      RST         => RST,
      OUTPUT      => ENV_OUT);
  


end Behavioral;

