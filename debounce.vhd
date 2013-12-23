----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:59:12 07/19/2012 
-- Design Name: 
-- Module Name:    debounce - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: the module is used for switch debouncing connect sys_clk to 50 Mhz
--
-- Dependencies: clk_divide.vhd
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

entity debounce is
    Port ( SYS_CLK : in  STD_LOGIC;
           SW_IN : in  STD_LOGIC;
           SW_OUT : out  STD_LOGIC);
end debounce;

architecture Behavioral of debounce is

component clk_divide
	generic( divison : integer :=4);
	port( clk_in : in std_logic;
			clk_out : out std_logic);
end component;
signal clk_int : std_logic;
signal Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7 : std_logic; 
begin
div1: clk_divide
	generic map(divison => 20000)
	port map(	clk_in => SYS_CLK,
					clk_out => clk_int);
debouncer : process(clk_int)
begin
	if (rising_edge(clk_int)) then 
		Q0 <= SW_IN;
		Q1 <= Q0;
		Q2 <= Q1;
		Q3 <= Q2;
		Q4 <= Q3;
		Q5 <= Q4;
		Q6 <= Q5;
		Q7 <= Q6;
	end if;
end process debouncer;

SW_OUT <= Q0 and Q1 and Q2 and Q3 and Q4 and Q5 and Q6 and Q7;

end Behavioral;

