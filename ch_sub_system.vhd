----------------------------------------------------------------------------------
-- Company: 
-- Engineer: T. Sivananda Reddy
-- 
-- Create Date:    12:30:44 12/09/2013 
-- Design Name: 
-- Module Name:    ch_sub_system - Behavioral 
-- Project Name:  Three phase pulse burst generator
-- Target Devices: 
-- Tool versions: 
-- Description: This integrates all the components to generate a pulse that
-- is to be given to dead time controller block
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

entity ch_sub_system is
  generic (
    iCH_BASE_ADDR : integer range 0 to 2**16 - 1 := 1);  -- default value of channel base address in ROM
  port (RST         : in  std_logic;
        ALL_TRIGED  : in  std_logic;
        TRIG        : in  std_logic;
        LOAD_DONE   : in  std_logic;
        SYS_CLK     : in  std_logic;
        CH_OUT      : out std_logic;
        TRIGED      : out std_logic;
        LOAD        : out std_logic;
	PULSE_OUT_ENV: out std_logic;
        DATA        : in  std_logic_vector (15 downto 0);
        ADDR        : out std_logic_vector (15 downto 0);
        PULSE_COUNT : out std_logic_vector (15 downto 0);
        TIME_COUNT  : out std_logic_vector (15 downto 0));
end ch_sub_system;

architecture Behavioral of ch_sub_system is

  component pulser is
    port (
      RST            : in  std_logic;
      START          : in  std_logic;
      TIME_COUNT_MAX : in  std_logic_vector (15 downto 0);
      TIME_COUNT     : out std_logic_vector (15 downto 0);
      PULSE_OUT      : out std_logic;
      STARTED        : out std_logic;
      SYS_CLK        : in  std_logic);
  end component pulser;

  component time_count_max_loader is
    generic (
      iCH_BASE_ADDR : integer range 0 to 2**16 - 1);
    port (
      SYS_CLK        : in  std_logic;
      TRIG           : in  std_logic;
      RST            : in  std_logic;
      ALL_TRIGED     : in  std_logic;
      STARTED        : in  std_logic;
      LOAD_DONE      : in  std_logic;
      PULSE_OUT      : in  std_logic;
      DATA           : in  std_logic_vector (15 downto 0);
      TRIGED         : out std_logic;
      START          : out std_logic;
      LOAD           : out std_logic;
      TIME_COUNT_MAX : out std_logic_vector (15 downto 0);
      PULSE_COUNT    : out std_logic_vector (15 downto 0);
      ADDR           : out std_logic_vector (15 downto 0));
  end component time_count_max_loader;

  signal START : std_logic;
  signal TIME_COUNT_MAX : std_logic_vector (15 downto 0);
  signal STARTED : std_logic;
  signal PULSE_OUT : std_logic;
  signal CH_OUT_SIG : std_logic;
begin

  pulser_1 : pulser
    port map (
      RST            => RST,
      START          => START,
      TIME_COUNT_MAX => TIME_COUNT_MAX,
      TIME_COUNT     => TIME_COUNT,
      PULSE_OUT      => PULSE_OUT,
      STARTED        => STARTED,
      SYS_CLK        => SYS_CLK);

  time_count_max_loader_1: time_count_max_loader
    generic map (
      iCH_BASE_ADDR => iCH_BASE_ADDR)
    port map (
      SYS_CLK        => SYS_CLK,
      TRIG           => TRIG,
      RST            => RST,
      ALL_TRIGED     => ALL_TRIGED,
      STARTED        => STARTED,
      LOAD_DONE      => LOAD_DONE,
      PULSE_OUT      => PULSE_OUT,
      DATA           => DATA,
      TRIGED         => TRIGED,
      START          => START,
      LOAD           => LOAD,
      TIME_COUNT_MAX => TIME_COUNT_MAX,
      PULSE_COUNT    => PULSE_COUNT,
      ADDR           => ADDR);

  -- purpose: process to change output when there is pulse out
  -- type   : sequential
  -- inputs : PULSE_OUT, RST
  -- outputs: CH_OUT_SIG
  t_flipflp: process (SYS_CLK, RST) is
  begin  -- process t_flipflp
    if RST = '0' and TRIG = '1'then                   -- asynchronous reset (active low)
      CH_OUT_SIG <= '0';
    elsif SYS_CLK'event and SYS_CLK = '1' then  -- rising clock edge
      if PULSE_OUT = '1' then
        CH_OUT_SIG <= not CH_OUT_SIG;
      end if;
    end if;
  end process t_flipflp;

  CH_OUT <= CH_OUT_SIG;
  PULSE_OUT_ENV <= PULSE_OUT;
  
end Behavioral;

