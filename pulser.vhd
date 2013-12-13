----------------------------------------------------------------------------------
-- Company: RRCAT. Indore
-- Engineer: T. Sivananda Reddy
-- 
-- Create Date:    17:47:42 12/03/2013 
-- Design Name:         
-- Module Name:    pulser - RTL
-- Project Name:   Three phase pulse burst generator
-- Target Devices: general
-- Tool versions: Xilinx 13.1
-- Description: This is like a counter which will generate a output pulse
--              PULSE_OUT when the counter is zero
--              STARTED pulse when the counter is at max position
--              see waveform_pulser_tb.pdf in the same folder for
--              better understanding.
-- 
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

entity pulser is
    Port ( RST : in  STD_LOGIC;
           START : in  STD_LOGIC;
           TIME_COUNT_MAX : in  STD_LOGIC_VECTOR (15 downto 0);
           TIME_COUNT : out  STD_LOGIC_VECTOR (15 downto 0);
           PULSE_OUT : out  STD_LOGIC;
           STARTED : out  STD_LOGIC;
           SYS_CLK : in  STD_LOGIC);
end pulser;

architecture RTL of pulser is
  type state_type is (WAIT_FOR_START_STATE,
                      LOAD_TIME_COUNT_MAX_STATE,
                      DEC_TIME_COUNT_STATE_1,
                      DEC_TIME_COUNT_STATE_2,
                      PULSE_ON_STATE);                -- state naming
  signal STATE : state_type;            -- current state of the state machine
  signal iTIME_COUNT : integer range 0 to 2**16 - 1;         -- interger type to do arthematic
  signal iTIME_COUNT_MAX : integer range 0 to 2**16 - 1;  -- integer type to do airthematics

begin

  TIME_COUNT <= conv_std_logic_vector(iTIME_COUNT,16);
  iTIME_COUNT_MAX <= conv_integer(TIME_COUNT_MAX);
  
  -- purpose: To change the state of the pulse according to the timer
  -- type   : sequential
  -- inputs : SYS_CLK, RST, iTIME_COUNT_MAX
  -- outputs: iTIME_COUNT
  state_mac: process (SYS_CLK, RST) is
  begin  -- process state_mac
    if RST = '0' then                   -- asynchronous reset (active low)
      STATE <= WAIT_FOR_START_STATE;
    elsif SYS_CLK'event and SYS_CLK = '1' then  -- rising clock edge
      case STATE is
        -----------------------------------------------------------------------
        when WAIT_FOR_START_STATE =>
          iTIME_COUNT <= 0;
          if START = '1' then
            STATE <= LOAD_TIME_COUNT_MAX_STATE;
          end if;
        -----------------------------------------------------------------------
        when LOAD_TIME_COUNT_MAX_STATE =>
          iTIME_COUNT <= iTIME_COUNT_MAX;
          STATE <= DEC_TIME_COUNT_STATE_1;
        -----------------------------------------------------------------------
        when DEC_TIME_COUNT_STATE_1 =>
          iTIME_COUNT <= iTIME_COUNT - 1;
          STATE <= DEC_TIME_COUNT_STATE_2;
        -----------------------------------------------------------------------
        when DEC_TIME_COUNT_STATE_2 =>
          iTIME_COUNT <= iTIME_COUNT - 1;
          if iTIME_COUNT <= 1 then
            STATE <= PULSE_ON_STATE;
          end if;
        -----------------------------------------------------------------------
        when PULSE_ON_STATE =>
         -- iTIME_COUNT <= iTIME_COUNT - 1;
          if iTIME_COUNT = 0 then
            STATE  <= WAIT_FOR_START_STATE;
          end if;
        -----------------------------------------------------------------------
        when others => null;
      end case;
    end if;
  end process state_mac;

  -- purpose: output of different states in the state machine
  -- type   : combinational
  -- inputs : STATE
  -- outputs: PULSE_OUT, STARTED
  state_output: process (STATE) is
  begin  -- process state_output
    case STATE is
      -------------------------------------------------------------------------
      when WAIT_FOR_START_STATE =>
        PULSE_OUT <= '0';
        STARTED <= '0';
      -------------------------------------------------------------------------
      when LOAD_TIME_COUNT_MAX_STATE =>
        PULSE_OUT <= '0';
        STARTED <= '0';
      -------------------------------------------------------------------------
      when DEC_TIME_COUNT_STATE_1 =>
        PULSE_OUT <= '0';
        STARTED <= '1';
      -------------------------------------------------------------------------
      when DEC_TIME_COUNT_STATE_2 =>
        PULSE_OUT <= '0';
        STARTED <= '0';
      -------------------------------------------------------------------------
      when PULSE_ON_STATE =>
        PULSE_OUT <= '1';
        STARTED <= '0';
      -------------------------------------------------------------------------
      when others => null;
    end case;
  end process state_output;


end RTL;

