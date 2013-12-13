----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:44:54 12/04/2013 
-- Design Name: 
-- Module Name:    time_count_max_loader - Behavioral 
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

entity time_count_max_loader is
  generic (
    iCH_BASE_ADDR : integer range 0 to 2**16 - 1 := 1);  -- channel base address where the channel data is stored
  port (SYS_CLK        : in  std_logic;
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
end time_count_max_loader;

architecture RTL of time_count_max_loader is
  type state_type is (WAIT_FOR_TRIG_STATE,
                      LOAD_NO_PULSES_STATE,
                      STORE_NO_PULSES_STATE,
                      LOAD_TIME_COUNT_MAX_STATE_1,
                      WAIT_FOR_ALL_LOAD_STATE,
                      WAIT_FOR_ALL_TRIGED_STATE,
                      STORE_TIME_COUNT_MAX_STATE_1,
                      WAIT_FOR_PULSER_START_STATE,
                      DEC_PULSE_COUNT_STATE,
                      LOAD_TIME_COUNT_MAX_STATE_2,
                      STORE_TIME_COUNT_MAX_STATE_2,
                      WAIT_FOR_TIME_COUNT_STATE,
                      START_TIME_COUNT_STATE);         -- state naming
  signal STATE        : state_type;     -- state machine current state
  signal iPULSES_MAX  : integer range 0 to 2**16 - 1;  -- max no of pulses in a single pulse train
  signal iPULSE_COUNT : integer range 0 to 2**16 - 1;  -- no of pulses count
  signal iADDR        : integer range 0 to 2**16 - 1;  -- address in the interger form

begin

  ADDR        <= conv_std_logic_vector(iADDR, 16);
  PULSE_COUNT <= conv_std_logic_vector(iPULSE_COUNT, 16);
  -- purpose: process state machine
  -- type   : sequential
  -- inputs : SYS_CLK, RST,  DATA, iPULSES_MAX, iPULSE_COUNT 
  -- outputs: TIME_COUNT_MAX
  state_mac : process (SYS_CLK, RST) is
  begin  -- process state_mac
    if RST = '0' then                   -- asynchronous reset (active low)
      STATE <= WAIT_FOR_TRIG_STATE;
    elsif SYS_CLK'event and SYS_CLK = '1' then  -- rising clock edge
      case STATE is
        -----------------------------------------------------------------------
        -- S1
        -----------------------------------------------------------------------
        when WAIT_FOR_TRIG_STATE =>
          TIME_COUNT_MAX <= "0000000000000000";
          if TRIG = '1' then
            STATE <= LOAD_NO_PULSES_STATE;
          end if;
        -----------------------------------------------------------------------
        -- S2
        -----------------------------------------------------------------------
        when LOAD_NO_PULSES_STATE =>
          if LOAD_DONE = '1' then
            STATE <= STORE_NO_PULSES_STATE;
          end if;
        -----------------------------------------------------------------------
        -- S3
        -----------------------------------------------------------------------
        when STORE_NO_PULSES_STATE =>
          iPULSES_MAX  <= conv_integer(DATA);
          iPULSE_COUNT <= conv_integer(DATA);
          STATE        <= LOAD_TIME_COUNT_MAX_STATE_1;
        -----------------------------------------------------------------------
        -- S4
        -----------------------------------------------------------------------
        when LOAD_TIME_COUNT_MAX_STATE_1 =>
          if LOAD_DONE = '1' then
            STATE <= WAIT_FOR_ALL_LOAD_STATE;
          end if;
        -----------------------------------------------------------------------
        -- S5
        -----------------------------------------------------------------------
        when WAIT_FOR_ALL_LOAD_STATE =>
          TIME_COUNT_MAX <= DATA;
          if ALL_TRIGED = '1' then
            STATE <= STORE_TIME_COUNT_MAX_STATE_1;
          else
            STATE <= WAIT_FOR_ALL_TRIGED_STATE;
          end if;
        -----------------------------------------------------------------------
        -- S6
        -----------------------------------------------------------------------
        when WAIT_FOR_ALL_TRIGED_STATE =>
          if ALL_TRIGED = '1' then
            STATE <= STORE_TIME_COUNT_MAX_STATE_1;
          end if;
        -----------------------------------------------------------------------
        -- S7
        -----------------------------------------------------------------------
        when STORE_TIME_COUNT_MAX_STATE_1 =>
          STATE <= WAIT_FOR_PULSER_START_STATE;
        -----------------------------------------------------------------------
        -- S8
        -----------------------------------------------------------------------
        when WAIT_FOR_PULSER_START_STATE =>
          if STARTED = '1' then
            STATE <= DEC_PULSE_COUNT_STATE;
          end if;
        -----------------------------------------------------------------------
        -- S9
        -----------------------------------------------------------------------
        when DEC_PULSE_COUNT_STATE =>
          iPULSE_COUNT <= iPULSE_COUNT - 1;
          if iPULSE_COUNT > 0 then
            STATE <= LOAD_TIME_COUNT_MAX_STATE_2;
          end if;
        -----------------------------------------------------------------------
        -- S10
        -----------------------------------------------------------------------
        when LOAD_TIME_COUNT_MAX_STATE_2 =>
          if LOAD_DONE = '1' then
            STATE <= STORE_TIME_COUNT_MAX_STATE_2;
          end if;
        -----------------------------------------------------------------------
        -- S11
        -----------------------------------------------------------------------
        when STORE_TIME_COUNT_MAX_STATE_2 =>
          TIME_COUNT_MAX <= DATA;
          STATE          <= WAIT_FOR_TIME_COUNT_STATE;
        -----------------------------------------------------------------------
        -- S12
        -----------------------------------------------------------------------
        when WAIT_FOR_TIME_COUNT_STATE =>
          if PULSE_OUT = '1' then
            if iPULSE_COUNT = 0 then
              STATE <= WAIT_FOR_TRIG_STATE;
            else
              STATE <= START_TIME_COUNT_STATE;
            end if; 
          end if;
        -----------------------------------------------------------------------
        -- S13
        -----------------------------------------------------------------------
        when START_TIME_COUNT_STATE =>
          STATE <= WAIT_FOR_PULSER_START_STATE;
        when others => null;
      end case;
    end if;
  end process state_mac;

  -- purpose: output of different states in state machine
  -- type   : combinational
  -- inputs : STATE
  -- outputs: START, TRIGED, LOAD, iADDR
  state_output : process (STATE) is
  begin  -- process state_output
    case STATE is
      -------------------------------------------------------------------------
      -- S1
      -------------------------------------------------------------------------
      when WAIT_FOR_TRIG_STATE =>
        START  <= '0';
        TRIGED <= '0';
        LOAD   <= '0';
        iADDR  <= 0;
      -------------------------------------------------------------------------
      -- S2
      -------------------------------------------------------------------------
      when LOAD_NO_PULSES_STATE =>
        LOAD   <= '1';
        iADDR  <= iCH_BASE_ADDR;
        START  <= '0';
        TRIGED <= '0';
      -------------------------------------------------------------------------
      -- S3
      -------------------------------------------------------------------------
      when STORE_NO_PULSES_STATE =>
        LOAD   <= '0';
        iADDR  <= 0;
        START  <= '0';
        TRIGED <= '0';
      -------------------------------------------------------------------------
      -- S4
      -------------------------------------------------------------------------
      when LOAD_TIME_COUNT_MAX_STATE_1 =>
        LOAD   <= '1';
        iADDR  <= iCH_BASE_ADDR + ((iPULSES_MAX - iPULSE_COUNT + 1)*6);
        START  <= '0';
        TRIGED <= '0';
      -------------------------------------------------------------------------
      -- S5
      -------------------------------------------------------------------------
      when WAIT_FOR_ALL_LOAD_STATE =>
        LOAD   <= '0';
        iADDR  <= 0;
        START  <= '0';
        TRIGED <= '1';
      -------------------------------------------------------------------------
      -- S6
      -------------------------------------------------------------------------
      when WAIT_FOR_ALL_TRIGED_STATE =>
        LOAD   <= '0';
        iADDR  <= 0;
        START  <= '0';
        TRIGED <= '1';
      -------------------------------------------------------------------------
      -- S7
      -------------------------------------------------------------------------
      when STORE_TIME_COUNT_MAX_STATE_1 =>
        LOAD   <= '0';
        iADDR  <= 0;
        START  <= '1';
        TRIGED <= '1';
      -------------------------------------------------------------------------
      -- S8
      -------------------------------------------------------------------------
      when WAIT_FOR_PULSER_START_STATE =>
        LOAD   <= '0';
        iADDR  <= 0;
        START  <= '0';
        TRIGED <= '1';
      -------------------------------------------------------------------------
      -- S9
      -------------------------------------------------------------------------
      when DEC_PULSE_COUNT_STATE =>
        LOAD   <= '0';
        iADDR  <= 0;
        START  <= '0';
        TRIGED <= '1';
      -------------------------------------------------------------------------
      -- S10
      -------------------------------------------------------------------------
      when LOAD_TIME_COUNT_MAX_STATE_2 =>
        LOAD   <= '1';
        iADDR  <= iCH_BASE_ADDR + ((iPULSES_MAX - iPULSE_COUNT + 1)*6);
        START  <= '0';
        TRIGED <= '1';
      -------------------------------------------------------------------------
      -- S11
      -------------------------------------------------------------------------
      when STORE_TIME_COUNT_MAX_STATE_2 =>
        LOAD   <= '0';
        iADDR  <= 0;
        START  <= '0';
        TRIGED <= '1';
      -------------------------------------------------------------------------
      -- S12
      -------------------------------------------------------------------------
      when WAIT_FOR_TIME_COUNT_STATE =>
        LOAD   <= '0';
        iADDR  <= 0;
        START  <= '0';
        TRIGED <= '1';
      -------------------------------------------------------------------------
      -- S13
      -------------------------------------------------------------------------
      when START_TIME_COUNT_STATE =>
        LOAD   <= '0';
        iADDR  <= 0;
        START  <= '1';
        TRIGED <= '1';
      when others => null;
    end case;
  end process state_output;
end RTL;

