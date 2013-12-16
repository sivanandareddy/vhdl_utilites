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

entity waveform_gen_top is

  generic (
    SAFETY_TIME : std_logic_vector (15 downto 0) := "0000010011100010";  -- safe on time of the IGBT 25us (i.e. 25us x 50MHz = 1250)
    DEAD_TIME   : std_logic_vector (15 downto 0) := "0000000001100100");  -- dead gap between the swithes of the same leg is 2us (i.e. 2us x 50MHz  =  100)

  port (
    RST      : in  std_logic;           -- active low reset
    SYS_CLK  : in  std_logic;  -- system clock 50 MHz using the on board clock
    TRIG     : in  std_logic;  -- input trigger to generate pulse burst
    ---------------------------------------------------------------------------
    -- Connected to memory glue logic
    ---------------------------------------------------------------------------
    ADDR_ROM : out std_logic_vector (20 downto 0);  -- address lines to connect to another mem interface glue logic
    DATA_ROM : in  std_logic_vector (15 downto 0);  -- data lines comming from another mem interface glue logic
    CE_ROM   : out std_logic;  -- chip enable signal to another mem interface glue logic
    ---------------------------------------------------------------------------
    -- connected to output triggering circuit
    ---------------------------------------------------------------------------
    CH1      : out std_logic;           -- channel 1 out A1
    CH1_NOT  : out std_logic;           -- channel 1 not out A1'
    CH2      : out std_logic;           -- channel 2 out A2
    CH2_NOT  : out std_logic;           -- channel 2 not out A2'

    CH3     : out std_logic;            -- channel 3 out B1
    CH3_NOT : out std_logic;            -- channel 3 not out B1'
    CH4     : out std_logic;            -- channel 4 out B2
    CH4_NOT : out std_logic;            -- channel 4 not out B2'

    CH5     : out std_logic;            -- channel 5 out C1
    CH5_NOT : out std_logic;            -- channel 5 not out C1'
    CH6     : out std_logic;            -- channel 6 out C2
    CH6_NOT : out std_logic);           -- channel 6 not out C2'
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
  
begin  -- architecture Behaviour

  ch_sub_system_1: entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => 1)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH_OUT,
      TRIGED        => TRIGED,
      LOAD          => LOAD,
      PULSE_OUT_ENV => PULSE_OUT_ENV,
      DATA          => DATA,
      ADDR          => ADDR,
      PULSE_COUNT   => PULSE_COUNT,
      TIME_COUNT    => TIME_COUNT);
  ch_sub_system_2: entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => iCH_BASE_ADDR)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH_OUT,
      TRIGED        => TRIGED,
      LOAD          => LOAD,
      PULSE_OUT_ENV => PULSE_OUT_ENV,
      DATA          => DATA,
      ADDR          => ADDR,
      PULSE_COUNT   => PULSE_COUNT,
      TIME_COUNT    => TIME_COUNT);
  ch_sub_system_3: entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => iCH_BASE_ADDR)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH_OUT,
      TRIGED        => TRIGED,
      LOAD          => LOAD,
      PULSE_OUT_ENV => PULSE_OUT_ENV,
      DATA          => DATA,
      ADDR          => ADDR,
      PULSE_COUNT   => PULSE_COUNT,
      TIME_COUNT    => TIME_COUNT);
  ch_sub_system_4: entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => iCH_BASE_ADDR)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH_OUT,
      TRIGED        => TRIGED,
      LOAD          => LOAD,
      PULSE_OUT_ENV => PULSE_OUT_ENV,
      DATA          => DATA,
      ADDR          => ADDR,
      PULSE_COUNT   => PULSE_COUNT,
      TIME_COUNT    => TIME_COUNT);
  ch_sub_system_5: entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => iCH_BASE_ADDR)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH_OUT,
      TRIGED        => TRIGED,
      LOAD          => LOAD,
      PULSE_OUT_ENV => PULSE_OUT_ENV,
      DATA          => DATA,
      ADDR          => ADDR,
      PULSE_COUNT   => PULSE_COUNT,
      TIME_COUNT    => TIME_COUNT);
  ch_sub_system_6: entity work.ch_sub_system
    generic map (
      iCH_BASE_ADDR => iCH_BASE_ADDR)
    port map (
      RST           => RST,
      ALL_TRIGED    => ALL_TRIGED,
      TRIG          => TRIG,
      LOAD_DONE     => LOAD_DONE,
      SYS_CLK       => SYS_CLK,
      CH_OUT        => CH_OUT,
      TRIGED        => TRIGED,
      LOAD          => LOAD,
      PULSE_OUT_ENV => PULSE_OUT_ENV,
      DATA          => DATA,
      ADDR          => ADDR,
      PULSE_COUNT   => PULSE_COUNT,
      TIME_COUNT    => TIME_COUNT);


  dead_time_controller_1: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);
  dead_time_controller_2: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);
  dead_time_controller_3: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);
  dead_time_controller_4: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);
  dead_time_controller_5: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);
  dead_time_controller_6: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);
  dead_time_controller_7: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);
  dead_time_controller_8: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);
  dead_time_controller_9: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);
  dead_time_controller_10: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);
  dead_time_controller_11: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);
  dead_time_controller_12: entity work.dead_time_controller
    port map (
      PULSE_IN  => PULSE_IN,
      RST       => RST,
      SYS_CLK   => SYS_CLK,
      DEAD_TIME => DEAD_TIME,
      PULSE_OUT => PULSE_OUT);

end architecture Behaviour;
