-------------------------------------------------------------------------------
-- Author :  T. Sivananda Reddy
-- email : sivananda.redteam@gmail.com
-- Purpose :  Used as monostable multivibrator whose pulse width is
-- PULSE_WIDTH*SYS_CLK period
-- Date of creation : 27.06.2013
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity monostable is
  
  port (
    PULSE_WIDTH : in  std_logic_vector(15 downto 0);
    TRIGGER     : in  std_logic;
    SYS_CLK     : in  std_logic;
    RST         : in  std_logic;
    --debug       : out std_logic;
    OUTPUT      : out std_logic);

end monostable;

architecture behav of monostable is
  
  signal iCOUNT          : integer range 0 to 2**16 - 1;
  signal output_int      : std_logic;   -- internal signal that comes as ouptut
  signal set_count_zero  : std_logic;  -- sets the counter to zero when set to '1'
  signal iMAX            : integer range 0 to 2**16 - 1;
  signal RST_INT         : std_logic;
  signal TRIGGER_DELAYED : std_logic;
  signal q0, q1          : std_logic;
  
begin  -- behav

  set_count_zero <= TRIGGER and (not TRIGGER_DELAYED);
  OUTPUT         <= output_int;
  iMAX           <= CONV_INTEGER(PULSE_WIDTH);

  -- purpose: process to latch the signal
  -- type   : sequential
  -- inputs : TRIGGER, RST, RST_INT
  -- outputs: output_int
  latch : process (TRIGGER, RST, RST_INT)
  begin  -- process latch
    if (RST = '0' or RST_INT = '0') then  -- asynchronous reset (active low)
      output_int <= '0';
    elsif TRIGGER'event and TRIGGER = '1' then  -- rising clock edge
      output_int <= '1';
    end if;
  end process latch;

  -- purpose: process to delay the trigger pulse to generate the pulse only at rising edge
  -- type   : sequential
  -- inputs : SYS_CLK, RST, TRIGGER
  -- outputs: TRIGGER_DELAYED
  delay_trigger : process (SYS_CLK, RST)
  begin  -- process delay_trigger
    --if RST = '0' then                   -- asynchronous reset (active low)
    -- q0 <= '0';
    -- q1 <= '0';
    if SYS_CLK'event and SYS_CLK = '1' then  -- rising clock edge
      q0              <= TRIGGER;
      q1              <= q0;
      TRIGGER_DELAYED <= q1;
    end if;
  end process delay_trigger;

  -- purpose: process to set the internal reset after a particular time
  -- type   : combinational
  -- inputs : SYS_CLK
  -- outputs: RST_INT
  reset_internal : process (SYS_CLK)
  begin  -- process reset_internal
    if rising_edge(SYS_CLK) then
      if (iCOUNT = iMAX) then
        RST_INT <= '0';
      else
        RST_INT <= '1';
      end if;
    end if;
  end process reset_internal;

  -- purpose: counting process for generating pulse
  -- type   : sequential
  -- inputs : SYS_CLK, RST, set_count_zero
  -- outputs: iCOUNT
  counting : process (SYS_CLK, RST)
  begin  -- process counting
    if RST = '0' then                   -- asynchronous reset (active low)
      iCOUNT <= (iMAX + 1);
    elsif SYS_CLK'event and SYS_CLK = '1' then  -- rising clock edge
      if set_count_zero = '1' then
        iCOUNT <= 0;
      elsif (iCOUNT >= 0 and iCOUNT <= iMAX) then
        iCOUNT <= iCOUNT + 1;
      end if;
    end if;
  end process counting;

  --debug <= set_count_zero;

end behav;

