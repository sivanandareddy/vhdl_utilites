----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:03:39 07/19/2012 
-- Design Name: 
-- Module Name:    clk_divide - Behavioral 
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

entity clk_divide is
		generic ( divison : integer  := 4);
		Port ( clk_in : in  STD_LOGIC;
           clk_out : out  STD_LOGIC);
end clk_divide;

architecture Behavioral of clk_divide is
signal int_clk : std_logic := '0';        -- internal clock signal
begin
clk_divi_proc : process(clk_in)
variable DivCnt : integer := 0 ;
begin

if(clk_in='1' and clk_in'event) then -- Clock
 
  if(DivCnt=((divison-1)/2)) then
       DivCnt := 0;
   else	DivCnt := DivCnt + 1;
  end if; 	  
  if(DivCnt=((divison-1)/2)) then
    int_clk <= not int_clk;
  end if;	  
  
 end if;
clk_out <= int_clk;
end process clk_divi_proc; 




end Behavioral;

