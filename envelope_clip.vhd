----------------------------------------------------------------------------------
-- Company: 
-- Engineer: T. Sivananda Reddy
-- 
-- Create Date:    14:49:39 12/16/2013 
-- Design Name: 
-- Module Name:    envelope_clip - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity envelope_clip is
    Port ( ENV_IN : in  STD_LOGIC;
           PULSES_IN : in  STD_LOGIC_VECTOR (11 downto 0);
           PULSES_OUT : out  STD_LOGIC_VECTOR (11 downto 0));
end envelope_clip;

architecture Behavioral of envelope_clip is

begin
anding: for i in 11 downto 0 generate
  PULSES_OUT(i) <= ENV_IN and PULSES_IN(i);
end generate anding;

end Behavioral;

