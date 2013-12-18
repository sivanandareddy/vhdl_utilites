----------------------------------------------------------------------------------
-- Company: 
-- Engineer: T. Sivananda Reddy
-- 
-- Create Date:    14:59:41 12/16/2013 
-- Design Name: 
-- Module Name:    gaurd - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gaurd is
  port (SAFETY_TIME : in  std_logic_vector (15 downto 0);
        PULSE_IN    : in  std_logic;
        FAULT       : in  std_logic;
        PULSE_OUT   : out std_logic;
        RST         : in  std_logic;
        SYS_CLK     : in  std_logic);
end gaurd;

architecture Behavioral of gaurd is

  component monostable is
    port (
      PULSE_WIDTH : in  std_logic_vector(15 downto 0);
      TRIGGER     : in  std_logic;
      SYS_CLK     : in  std_logic;
      RST         : in  std_logic;
      OUTPUT      : out std_logic);
  end component monostable;
  signal OUTPUT : std_logic;
begin

  monostable_1 : monostable
    port map (
      PULSE_WIDTH => SAFTEY_TIME,
      TRIGGER     => PULSE_IN,
      SYS_CLK     => SYS_CLK,
      RST         => RST,
      OUTPUT      => OUTPUT);

  PULSE_OUT <= OUTPUT and PULSE_IN and (not FAULT);

end Behavioral;

