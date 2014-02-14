----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:06:59 06/20/2013 
-- Design Name: 
-- Module Name:    ROM_programmer_top_module - Behavioral 
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

entity ROM_programmer_top_module is
   Port ( CLK_50MHZ : in  STD_LOGIC;
           NF_A : out  STD_LOGIC_VECTOR (21 downto 0);  -- Address
           NF_D : inout  STD_LOGIC_VECTOR (14 downto 0);  -- Data
           NF_CE : out  STD_LOGIC;      -- Chip Enable
           NF_OE : out  STD_LOGIC;      -- Output Enable
           NF_RP : out  STD_LOGIC;      -- Reset flash when set to 0
           NF_STS : in  STD_LOGIC;      -- input status signal from ROM
           NF_WE : out  STD_LOGIC;      -- Write Enable when set to 0
           NF_WP : out  STD_LOGIC;      -- Write Protect when set to 0
           NF_BYTE : out  STD_LOGIC;     -- Byte mode(x8) when 0;
                                        -- word mode(x16) when 1;
           RS232_DCE_RXD : in STD_LOGIC;  -- female D9 connector RX pin
           RS232_DCE_TXD : out STD_LOGIC;  -- female D9 connector TX pin

           SW  : in STD_LOGIC_VECTOR(3 downto 0);  -- input switches
           --RX_CLK_N     : out STD_LOGIC;  -- output for test points
           RX_N         : out STD_LOGIC_VECTOR(5 downto 0);  -- output for test
                                                             -- pins
           RST : in STD_LOGIC;          --reset
           LED : out  STD_LOGIC_VECTOR (7 downto 0));  -- LED to show output
end ROM_programmer_top_module;

architecture Behavioral of ROM_programmer_top_module is
  component m29dw323dt_flash_programmer
    port (
      flash_oe   : out   std_logic;
      flash_ce   : out   std_logic;
      flash_we   : out   std_logic;
      flash_byte : out   std_logic;
      flash_wp   : out   std_logic;
      flash_rp   : out   std_logic;
      flash_sts  : in    std_logic;
      flash_a    : out   std_logic_vector(21 downto 0);
      flash_d    : inout std_logic_vector(7 downto 0);
      tx_female  : out   std_logic;
      rx_female  : in    std_logic;
      sw         : in    std_logic_vector(1 downto 0);
      led        : out   std_logic_vector(7 downto 0);
      j2_30      : out   std_logic;
      j2_26      : out   std_logic;
      j2_22      : out   std_logic;
      j2_14      : out   std_logic;
      RST        : in    std_logic;
      clk        : in    std_logic);
  end component;

begin
  m29dw323dt_flash_programmer_1: m29dw323dt_flash_programmer
    port map (
      flash_oe   => NF_OE,
      flash_ce   => NF_CE,
      flash_we   => NF_WE,
      flash_byte => NF_BYTE,
      flash_wp   => NF_WP,
      flash_rp   => NF_RP,
      flash_sts  => NF_STS,
      flash_a    => NF_A,
      flash_d    => NF_D(7 downto 0),
      tx_female  => RS232_DCE_TXD,
      rx_female  => RS232_DCE_RXD,
      sw         => SW(1 downto 0),
      led        => LED,
      j2_30      => RX_N(5),
      j2_26      => RX_N(4),
      j2_22      => RX_N(3),
      j2_14      => RX_N(2),
      RST        => RST,
      clk        => CLK_50MHZ);

 -- NF_D(14 downto 8) <= (others => 'open');
   NF_D(14 downto 8) <= "ZZZZZZZ";
end Behavioral;

