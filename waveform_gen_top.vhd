-------------------------------------------------------------------------------
-- Name: T. Sivananda Reddy
-- Email: sivananda.redteam@gmail.com
-- filename: waveform_gen_top.vhd
-- Description: This file integrates all the components of the waveform
-- generation mechanism
-- Dependencies: ch_sub_system.vhd
--               time_count_max_loader.vhd
--               pulser.vhd
--               memory_controller.vhd
--               memory_interface.vhd
--               envelope_gen.vhd
--               envelope_clip.vhd
--               dead_time_controller.vhd
--               gaurd.vhd
-- SYS_CLK is assumed to be 50 MHz
-- H bride switch configuration
--       _________________________ V_BUS
--       |             |
--       \ A1          \ A2'
--       |____LOAD_____|          Phase A lly there is phase B and phase C
--       |             |
--       \ A1'         \ A2
--       |_____________|__________ GND
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity waveform_gen_top is

  generic (
    SAFETY_TIME : std_logic_vector (15 downto 0) := "0000010011100010";  -- safe on time of the IGBT 25us (i.e. 25us x 50MHz = 1250)
    DEAD_TIME   : std_logic_vector (15 downto 0) := "0000000001100100");  -- dead gap between the swithes of the same leg is 2us (i.e. 2us x 50MHz  =  100)

  port (
    RST         : in  std_logic;        -- active low reset
    SYS_CLK     : in  std_logic;  -- system clock 50 MHz using the on board clock
    TRIG_IN        : in  std_logic;  -- input trigger to generate pulse burst
    FAULT       : in  std_logic;        -- fault active high
    DEBUG       : out std_logic_vector (15 downto 0);
    ---------------------------------------------------------------------------
    -- Connected to memory glue logic
    ---------------------------------------------------------------------------
    ADDR_ROM    : out std_logic_vector (20 downto 0);  -- address lines to connect to another mem interface glue logic
    DATA_ROM    : in  std_logic_vector (15 downto 0);  -- data lines comming from another mem interface glue logic
    CE_ROM      : out std_logic;  -- chip enable signal to another mem interface glue logic
    ---------------------------------------------------------------------------
    -- connected to output triggering circuit
    ---------------------------------------------------------------------------
    OUT_CH1     : out std_logic;        -- channel 1 out A1
    OUT_CH1_NOT : out std_logic;        -- channel 1 not out A1'
    OUT_CH2     : out std_logic;        -- channel 2 out A2
    OUT_CH2_NOT : out std_logic;        -- channel 2 not out A2'

    OUT_CH3     : out std_logic;        -- channel 3 out B1
    OUT_CH3_NOT : out std_logic;        -- channel 3 not out B1'
    OUT_CH4     : out std_logic;        -- channel 4 out B2
    OUT_CH4_NOT : out std_logic;        -- channel 4 not out B2'

    OUT_CH5     : out std_logic;        -- channel 5 out C1
    OUT_CH5_NOT : out std_logic;        -- channel 5 not out C1'
    OUT_CH6     : out std_logic;        -- channel 6 out C2
    OUT_CH6_NOT : out std_logic);       -- channel 6 not out C2'
end entity waveform_gen_top;

architecture Behaviour of waveform_gen_top is

  component ch_sub_system is
    generic (
      iCH_BASE_ADDR : integer range 0 to 2**16 - 1);
    port (
      RST           : in  std_logic;
      ALL_TRIGED    : in  std_logic;
      TRIG          : in  std_logic;
      LOAD_DONE     : in  std_logic;
      SYS_CLK       : in  std_logic;
      CH_OUT        : out std_logic;
      TRIGED        : out std_logic;
      LOAD          : out std_logic;
      PULSE_OUT_ENV : out std_logic;
      DATA          : in  std_logic_vector (15 downto 0);
      ADDR          : out std_logic_vector (15 downto 0);
      PULSE_COUNT   : out std_logic_vector (15 downto 0);
      TIME_COUNT    : out std_logic_vector (15 downto 0));
  end component ch_sub_system;

  component dead_time_controller is
    port (
      PULSE_IN  : in  std_logic;
      RST       : in  std_logic;
      SYS_CLK   : in  std_logic;
      DEAD_TIME : in  std_logic_vector (15 downto 0);
      PULSE_OUT : out std_logic);
  end component dead_time_controller;

  component memory_controller is
    port (
      SYS_CLK       : in  std_logic;
      RST           : in  std_logic;
      LOAD          : out std_logic;
      ADDR          : out std_logic_vector (15 downto 0);
      DATA          : in  std_logic_vector (15 downto 0);
      LOAD_OVER     : in  std_logic;
      LOAD_CH1      : in  std_logic;
      LOAD_DONE_CH1 : out std_logic;
      ADDR_CH1      : in  std_logic_vector (15 downto 0);
      DATA_CH1      : out std_logic_vector (15 downto 0);
      LOAD_CH2      : in  std_logic;
      LOAD_DONE_CH2 : out std_logic;
      ADDR_CH2      : in  std_logic_vector (15 downto 0);
      DATA_CH2      : out std_logic_vector (15 downto 0);
      LOAD_CH3      : in  std_logic;
      LOAD_DONE_CH3 : out std_logic;
      ADDR_CH3      : in  std_logic_vector (15 downto 0);
      DATA_CH3      : out std_logic_vector (15 downto 0);
      LOAD_CH4      : in  std_logic;
      LOAD_DONE_CH4 : out std_logic;
      ADDR_CH4      : in  std_logic_vector (15 downto 0);
      DATA_CH4      : out std_logic_vector (15 downto 0);
      LOAD_CH5      : in  std_logic;
      LOAD_DONE_CH5 : out std_logic;
      ADDR_CH5      : in  std_logic_vector (15 downto 0);
      DATA_CH5      : out std_logic_vector (15 downto 0);
      LOAD_CH6      : in  std_logic;
      LOAD_DONE_CH6 : out std_logic;
      ADDR_CH6      : in  std_logic_vector (15 downto 0);
      DATA_CH6      : out std_logic_vector (15 downto 0));
  end component memory_controller;

  component memory_interface is
    port (
      RST       : in  std_logic;
      SYS_CLK   : in  std_logic;
      ADDR      : in  std_logic_vector(20 downto 0);
      DATA      : out std_logic_vector(15 downto 0);
      ADDR_ROM  : out std_logic_vector(20 downto 0);
      DATA_ROM  : in  std_logic_vector(15 downto 0);
      LOAD      : in  std_logic;
      LOAD_OVER : out std_logic;
      CE_ROM    : out std_logic);
  end component memory_interface;

  component envelope_gen is
    port (
      RST         : in  std_logic;
      CH1_OUT     : in  std_logic;
      PULSE_OUT   : in  std_logic;
      SYS_CLK     : in  std_logic;
      PULSE_COUNT : in  std_logic_vector (15 downto 0);
      ENV_OUT     : out std_logic);
  end component envelope_gen;

  component envelope_clip is
    port (
      ENV_IN     : in  std_logic;
      PULSES_IN  : in  std_logic_vector (11 downto 0);
      PULSES_OUT : out std_logic_vector (11 downto 0));
  end component envelope_clip;

  component gaurd is
    port (
      SAFETY_TIME : in  std_logic_vector (15 downto 0);
      PULSE_IN    : in  std_logic;
      FAULT       : in  std_logic;
      PULSE_OUT   : out std_logic;
      RST         : in  std_logic;
      SYS_CLK     : in  std_logic);
  end component gaurd;

  component monostable is
    port (
      PULSE_WIDTH : in  std_logic_vector(15 downto 0);
      TRIGGER     : in  std_logic;
      SYS_CLK     : in  std_logic;
      RST         : in  std_logic;
      OUTPUT      : out std_logic);
  end component monostable;

  signal LOAD_DONE_CH1, LOAD_DONE_CH2, LOAD_DONE_CH3, LOAD_DONE_CH4, LOAD_DONE_CH5, LOAD_DONE_CH6 : std_logic;  -- internal signal to connect the channel sub system and the memory controller
  signal DATA_CH1, DATA_CH2, DATA_CH3, DATA_CH4, DATA_CH5, DATA_CH6                               : std_logic_vector (15 downto 0);  -- internal signal to connect the channel sub system and the memory controller
  signal ALL_TRIGED                                                                               : std_logic;  -- internal signal to connect the
  -- channel sub sys to mem controller
  signal LOAD_CH1, LOAD_CH2, LOAD_CH3, LOAD_CH4, LOAD_CH5, LOAD_CH6                               : std_logic;  -- internal signal to connect the channel sub system and the memory controller
  signal ADDR_CH1, ADDR_CH2, ADDR_CH3, ADDR_CH4, ADDR_CH5, ADDR_CH6                               : std_logic_vector (15 downto 0);  -- internal signal to connect the channel sub system and the memory controller
  signal TRIGED_CH1, TRIGED_CH2, TRIGED_CH3, TRIGED_CH4, TRIGED_CH5, TRIGED_CH6                   : std_logic;  -- to generate all triggered signal by anding all the triggered signals from inndividual channels
  signal PULSE_OUT_ENV                                                                            : std_logic;  -- internal signal to be connected to envelope_gen module
  signal CH1, CH2, CH3, CH4, CH5, CH6                                                             : std_logic;  -- internal signal to connect the channel sub system to dead time controller
  signal CH1_NOT, CH2_NOT, CH3_NOT, CH4_NOT, CH5_NOT, CH6_NOT : std_logic;  -- signal to connect to not signal of CH1
  signal DT_CH1, DT_CH2, DT_CH3, DT_CH4, DT_CH5, DT_CH6                                           : std_logic;  -- internal signal from Dead time controller to envelope clipper
  signal DT_NOT_CH1, DT_NOT_CH2, DT_NOT_CH3, DT_NOT_CH4, DT_NOT_CH5, DT_NOT_CH6                   : std_logic;  -- internal signal from Dead time controller to envelope clipper
  signal ADDR_int                                                                                 : std_logic_vector (20 downto 0);  -- internal signal
                                        -- connected to mem
                                        -- ctrl and mem interface
  signal PULSE_COUNT_CH1                                                                          : std_logic_vector (15 downto 0);  -- to channel 1 sub system and envelope generator
 -- signal ADDR                                                                                     : std_logic_vector (15 downto 0);
  signal ENV_OUT                                                                                  : std_logic;  -- to connect the envelope generator and envelope clipper
  --signal PULSE_COUNT  : std_logic_vector (15 downto 0);  -- singal to debugging the channel subsystem can be removed in the release
  --signal TIME_COUNT : std_logic_vector (15 downto 0);  -- singal to debugging the channel subsystem can be removed in the release
  signal PULSES_IN, PULSES_OUT                                                                    : std_logic_vector (11 downto 0);  -- to connect gaurd and indvidual channels to envelope clipper
  signal ADDR, DATA : std_logic_vector (15 downto 0);  -- signal to connect memory controller and memory interface
  signal LOAD, LOAD_OVER : std_logic;   -- signal to connect memory controller and memory interface
  signal TRIG : std_logic;              -- signal from trigger to limit the trigger pulse width
begin  -- architecture Behaviour

  ch_sub_system_1 : entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => 1)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE_CH1,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH1,
      TRIGED        => TRIGED_CH1,
      LOAD          => LOAD_CH1,
      PULSE_OUT_ENV => PULSE_OUT_ENV,
      DATA          => DATA_CH1,
      ADDR          => ADDR_CH1,
      PULSE_COUNT   => PULSE_COUNT_CH1,
      TIME_COUNT    => open);
  ch_sub_system_2 : entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => 2)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE_CH2,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH2,
      TRIGED        => TRIGED_CH2,
      LOAD          => LOAD_CH2,
      PULSE_OUT_ENV => open,
      DATA          => DATA_CH2,
      ADDR          => ADDR_CH2,
      PULSE_COUNT   => open,
      TIME_COUNT    => open);
  ch_sub_system_3 : entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => 3)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE_CH3,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH3,
      TRIGED        => TRIGED_CH3,
      LOAD          => LOAD_CH3,
      PULSE_OUT_ENV => open,
      DATA          => DATA_CH3,
      ADDR          => ADDR_CH3,
      PULSE_COUNT   => open,
      TIME_COUNT    => open);
  ch_sub_system_4 : entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => 4)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE_CH4,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH4,
      TRIGED        => TRIGED_CH4,
      LOAD          => LOAD_CH4,
      PULSE_OUT_ENV => open,
      DATA          => DATA_CH4,
      ADDR          => ADDR_CH4,
      PULSE_COUNT   => open,
      TIME_COUNT    => open);
  ch_sub_system_5 : entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => 5)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE_CH5,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH5,
      TRIGED        => TRIGED_CH5,
      LOAD          => LOAD_CH5,
      PULSE_OUT_ENV => open,
      DATA          => DATA_CH5,
      ADDR          => ADDR_CH5,
      PULSE_COUNT   => open,
      TIME_COUNT    => open);
  ch_sub_system_6 : entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => 6)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE_CH6,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH6,
      TRIGED        => TRIGED_CH6,
      LOAD          => LOAD_CH6,
      PULSE_OUT_ENV => open,
      DATA          => DATA_CH6,
      ADDR          => ADDR_CH6,
      PULSE_COUNT   => open,
      TIME_COUNT    => open);

  ALL_TRIGED <= TRIGED_CH1 and TRIGED_CH2 and TRIGED_CH3 and TRIGED_CH4 and TRIGED_CH5 and TRIGED_CH6;
  dead_time_controller_1 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH1,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_CH1);
  dead_time_controller_2 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH1_NOT,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_NOT_CH1);
  dead_time_controller_3 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH2,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_CH2);
  dead_time_controller_4 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH2_NOT,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_NOT_CH2);
  dead_time_controller_5 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH3,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_CH3);
  dead_time_controller_6 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH3_NOT,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_NOT_CH3);
  dead_time_controller_7 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH4,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_CH4);
  dead_time_controller_8 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH4_NOT,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_NOT_CH4);
  dead_time_controller_9 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH5,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_CH5);
  dead_time_controller_10 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH5_NOT,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_NOT_CH5);
  dead_time_controller_11 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH6,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_CH6);
  dead_time_controller_12 : entity work.dead_time_controller
    port map (
      PULSE_IN  => CH6_NOT,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => DT_NOT_CH6);

  memory_controller_1 : entity work.memory_controller
    port map (
      SYS_CLK       => SYS_CLK,
      RST           => RST,
      LOAD          => LOAD,
      ADDR          => ADDR,
      DATA          => DATA,
      LOAD_OVER     => LOAD_OVER,
      LOAD_CH1      => LOAD_CH1,
      LOAD_DONE_CH1 => LOAD_DONE_CH1,
      ADDR_CH1      => ADDR_CH1,
      DATA_CH1      => DATA_CH1,
      LOAD_CH2      => LOAD_CH2,
      LOAD_DONE_CH2 => LOAD_DONE_CH2,
      ADDR_CH2      => ADDR_CH2,
      DATA_CH2      => DATA_CH2,
      LOAD_CH3      => LOAD_CH3,
      LOAD_DONE_CH3 => LOAD_DONE_CH3,
      ADDR_CH3      => ADDR_CH3,
      DATA_CH3      => DATA_CH3,
      LOAD_CH4      => LOAD_CH4,
      LOAD_DONE_CH4 => LOAD_DONE_CH4,
      ADDR_CH4      => ADDR_CH4,
      DATA_CH4      => DATA_CH4,
      LOAD_CH5      => LOAD_CH5,
      LOAD_DONE_CH5 => LOAD_DONE_CH5,
      ADDR_CH5      => ADDR_CH5,
      DATA_CH5      => DATA_CH5,
      LOAD_CH6      => LOAD_CH6,
      LOAD_DONE_CH6 => LOAD_DONE_CH6,
      ADDR_CH6      => ADDR_CH6,
      DATA_CH6      => DATA_CH6);

  memory_interface_1 : entity work.memory_interface
    port map (
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      ADDR      => ADDR_int,
      DATA      => DATA,
      ADDR_ROM  => ADDR_ROM,
      DATA_ROM  => DATA_ROM,
      LOAD      => LOAD,
      LOAD_OVER => LOAD_OVER,
      CE_ROM    => CE_ROM);

  ADDR_int <= "00000" & ADDR;

  envelope_gen_1 : entity work.envelope_gen
    port map (
      RST         => RST,
      CH1_OUT     => CH1,
      PULSE_OUT   => PULSE_OUT_ENV,
      SYS_CLK     => SYS_CLK,
      PULSE_COUNT => PULSE_COUNT_CH1,
      ENV_OUT     => ENV_OUT);

  envelope_clip_1 : entity work.envelope_clip
    port map (
      ENV_IN     => ENV_OUT,
      PULSES_IN  => PULSES_IN,
      PULSES_OUT => PULSES_OUT);

  PULSES_IN <= DT_NOT_CH6 & DT_CH6 & DT_NOT_CH5 & DT_CH5 & DT_NOT_CH4 & DT_CH4 &
               DT_NOT_CH3 & DT_CH3 & DT_NOT_CH2 & DT_CH2 & DT_NOT_CH1 & DT_CH1;

  gaurd_1 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(0),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH1,
      RST         => RST,
      SYS_CLK     => SYS_CLK);
  gaurd_2 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(1),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH1_NOT,
      RST         => RST,
      SYS_CLK     => SYS_CLK);
  gaurd_3 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(2),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH2,
      RST         => RST,
      SYS_CLK     => SYS_CLK);
  gaurd_4 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(3),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH2_NOT,
      RST         => RST,
      SYS_CLK     => SYS_CLK);
  gaurd_5 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(4),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH3,
      RST         => RST,
      SYS_CLK     => SYS_CLK);
  gaurd_6 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(5),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH3_NOT,
      RST         => RST,
      SYS_CLK     => SYS_CLK);
  gaurd_7 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(6),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH4,
      RST         => RST,
      SYS_CLK     => SYS_CLK);
  gaurd_8 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(7),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH4_NOT,
      RST         => RST,
      SYS_CLK     => SYS_CLK);
  gaurd_9 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(8),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH5,
      RST         => RST,
      SYS_CLK     => SYS_CLK);
  gaurd_10 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(9),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH5_NOT,
      RST         => RST,
      SYS_CLK     => SYS_CLK);
  gaurd_11 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(10),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH6,
      RST         => RST,
      SYS_CLK     => SYS_CLK);
  gaurd_12 : entity work.gaurd
    port map (
      SAFETY_TIME => SAFETY_TIME,
      PULSE_IN    => PULSES_OUT(11),
      FAULT       => FAULT,
      PULSE_OUT   => OUT_CH6_NOT,
      RST         => RST,
      SYS_CLK     => SYS_CLK);

  monostable_1: entity work.monostable
    port map (
      PULSE_WIDTH => "0000000000001111",
      TRIGGER     => TRIG_IN,
      SYS_CLK     => SYS_CLK,
      RST         => RST,
      OUTPUT      => TRIG);
  --TRIG <= TRIG_IN;

  CH1_NOT <= not CH1;
  CH2_NOT <= not CH2;
  CH3_NOT <= not CH3;
  CH4_NOT <= not CH4;
  CH5_NOT <= not CH5;
  CH6_NOT <= not CH6;
  DEBUG(0) <= ENV_OUT;
  DEBUG(1) <= CH2_NOT;
  DEBUG(2) <= PULSES_OUT(4);
  DEBUG(3) <= PULSES_OUT(5);
end architecture Behaviour;
