-------------------------------------------------------------------------------
-- Author : T. Sivananda Reddy
-- Date of Creation : 27.06.2013
-- Purpose : interface between memory and memory controller like glue logic
-- email : sivananda.redteam@gmail.com
-- revision 0.02 ver revised on 10.12.2013
-- revision comments : The SYS_CLK is added in to the combinational process
--                     The can be removed during implementation
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity memory_interface is

  port (
    RST       : in  std_logic;
    SYS_CLK   : in  std_logic;          -- system clock 50 MHZ
    ADDR      : in  std_logic_vector(20 downto 0);
    DATA      : out std_logic_vector(15 downto 0);
    ADDR_ROM  : out std_logic_vector(20 downto 0);
    DATA_ROM  : in  std_logic_vector(15 downto 0);
    LOAD      : in  std_logic;
    LOAD_OVER : out std_logic;
    CE_ROM    : out std_logic);

end memory_interface;


architecture behav of memory_interface is

  signal load_over_mono : std_logic;    -- output from monostable
  signal latch_mono     : std_logic;  -- latch signal to latch the data from ROM on the falling edge of the pulse
  signal q0, q1         : std_logic;
  component monostable
    port (
      PULSE_WIDTH : in  std_logic_vector(15 downto 0);
      TRIGGER     : in  std_logic;
      SYS_CLK     : in  std_logic;
      RST         : in  std_logic;
      OUTPUT      : out std_logic);
  end component;

begin  -- behav

  -- purpose: this process latcht the address from input on to the output lines when the logic is high
  -- type   : combinational
  -- inputs : LOAD
  -- outputs: ADDR_ROM
  addr_latch : process (LOAD, SYS_CLK)
  begin  -- process addr_latch
    if LOAD = '1' then
      ADDR_ROM <= ADDR;
    else
      ADDR_ROM <= (others => '1');      -- when the LOAD = 0 point the address
                                        -- to top of the ROM
    end if;
  end process addr_latch;

  -- purpose: process to delay the LOAD signal by two clock cycles
  -- type   : combinational
  -- inputs : SYS_CLK
  -- outputs: CE_ROM
  delay_load : process (SYS_CLK)
  begin  -- process delay_load
    if rising_edge(SYS_CLK) then
      q0     <= LOAD;
      q1     <= q0;
      CE_ROM <= q1;
    end if;
  end process delay_load;

  -- purpose: this process latches the data after 8 clock cycles
  -- type   : combinational
  -- inputs : latch_mono
  -- outputs: DATA
  latch_data : process (latch_mono)
  begin  -- process latch_data
    if falling_edge(latch_mono) then
      DATA <= DATA_ROM;
    end if;
  end process latch_data;

  monostable_1 : monostable
    port map (
      PULSE_WIDTH => "0000000000001100",  -- value is 12
      TRIGGER     => LOAD,
      SYS_CLK     => SYS_CLK,
      RST         => RST,
      OUTPUT      => load_over_mono);

  LOAD_OVER <= not load_over_mono;

  monostable_2 : monostable
    port map (
      PULSE_WIDTH => "0000000000001000",  -- value is 8
      TRIGGER     => LOAD,
      SYS_CLK     => SYS_CLK,
      RST         => RST,
      OUTPUT      => latch_mono);


end behav;
