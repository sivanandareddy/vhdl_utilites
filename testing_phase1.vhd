--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:20:40 12/09/2013
-- Design Name:   
-- Module Name:   /media/WORK_SPACE/Xilinx_ws/Three_phase_pulse_burst/testing_phase1/testing_phase1.vhd
-- Project Name:  testing_phase1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: memory_controller
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY testing_phase1 IS
END testing_phase1;
 
ARCHITECTURE behavior OF testing_phase1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT memory_controller
    PORT(
         SYS_CLK : in std_logic;
         RST   : in std_logic;
         LOAD : OUT  std_logic;
         ADDR : OUT  std_logic_vector(15 downto 0);
         DATA : IN  std_logic_vector(15 downto 0);
         LOAD_OVER : IN  std_logic;
         LOAD_CH1 : IN  std_logic;
         LOAD_DONE_CH1 : OUT  std_logic;
         ADDR_CH1 : IN  std_logic_vector(15 downto 0);
         DATA_CH1 : OUT  std_logic_vector(15 downto 0);
         LOAD_CH2 : IN  std_logic;
         LOAD_DONE_CH2 : OUT  std_logic;
         ADDR_CH2 : IN  std_logic_vector(15 downto 0);
         DATA_CH2 : OUT  std_logic_vector(15 downto 0);
         LOAD_CH3 : IN  std_logic;
         LOAD_DONE_CH3 : OUT  std_logic;
         ADDR_CH3 : IN  std_logic_vector(15 downto 0);
         DATA_CH3 : OUT  std_logic_vector(15 downto 0);
         LOAD_CH4 : IN  std_logic;
         LOAD_DONE_CH4 : OUT  std_logic;
         ADDR_CH4 : IN  std_logic_vector(15 downto 0);
         DATA_CH4 : OUT  std_logic_vector(15 downto 0);
         LOAD_CH5 : IN  std_logic;
         LOAD_DONE_CH5 : OUT  std_logic;
         ADDR_CH5 : IN  std_logic_vector(15 downto 0);
         DATA_CH5 : OUT  std_logic_vector(15 downto 0);
         LOAD_CH6 : IN  std_logic;
         LOAD_DONE_CH6 : OUT  std_logic;
         ADDR_CH6 : IN  std_logic_vector(15 downto 0);
         DATA_CH6 : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    component ROM_model is
      port (
        DATA_ROM : out std_logic_vector(15 downto 0);
        ADDR_ROM : in  std_logic_vector(20 downto 0);
        CE_ROM   : in  std_logic);
    end component ROM_model;

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

    component ch_sub_system is
      generic (
        iCH_BASE_ADDR : integer range 0 to 2**16 - 1);
      port (
        RST         : in  std_logic;
        ALL_TRIGED  : in  std_logic;
        TRIG        : in  std_logic;
        LOAD_DONE   : in  std_logic;
        SYS_CLK     : in  std_logic;
        CH_OUT      : out std_logic;
        TRIGED      : out std_logic;
        LOAD        : out std_logic;
        DATA        : in  std_logic_vector (15 downto 0);
        ADDR        : out std_logic_vector (15 downto 0);
        PULSE_COUNT : out std_logic_vector (15 downto 0);
        TIME_COUNT  : out std_logic_vector (15 downto 0));
    end component ch_sub_system;
    

   --Inputs
   signal DATA : std_logic_vector(15 downto 0) := (others => '0');
   signal LOAD_OVER : std_logic := '0';
   signal LOAD_CH1 : std_logic := '0';
   signal ADDR_CH1 : std_logic_vector(15 downto 0) := (others => '0');
   signal LOAD_CH2 : std_logic := '0';
   signal ADDR_CH2 : std_logic_vector(15 downto 0) := (others => '0');
   signal LOAD_CH3 : std_logic := '0';
   signal ADDR_CH3 : std_logic_vector(15 downto 0) := (others => '0');
   signal LOAD_CH4 : std_logic := '0';
   signal ADDR_CH4 : std_logic_vector(15 downto 0) := (others => '0');
   signal LOAD_CH5 : std_logic := '0';
   signal ADDR_CH5 : std_logic_vector(15 downto 0) := (others => '0');
   signal LOAD_CH6 : std_logic := '0';
   signal ADDR_CH6 : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal LOAD : std_logic;
   signal ADDR : std_logic_vector(15 downto 0);
   signal LOAD_DONE_CH1 : std_logic;
   signal DATA_CH1 : std_logic_vector(15 downto 0);
   signal LOAD_DONE_CH2 : std_logic;
   signal DATA_CH2 : std_logic_vector(15 downto 0);
   signal LOAD_DONE_CH3 : std_logic;
   signal DATA_CH3 : std_logic_vector(15 downto 0);
   signal LOAD_DONE_CH4 : std_logic;
   signal DATA_CH4 : std_logic_vector(15 downto 0);
   signal LOAD_DONE_CH5 : std_logic;
   signal DATA_CH5 : std_logic_vector(15 downto 0);
   signal LOAD_DONE_CH6 : std_logic;
   signal DATA_CH6 : std_logic_vector(15 downto 0);

   signal DATA_ROM : std_logic_vector (15 downto 0);
   signal ADDR_ROM  : std_logic_vector (20 downto 0);
   signal temp_addr : std_logic_vector (20 downto 0);
   signal CE_ROM : std_logic;
   signal TRIGED : std_logic_vector (5 downto 0);
   signal CH_OUT : std_logic_vector (5 downto 0);
   signal ALL_TRIGED : std_logic;
   signal PULSE_COUNT : std_logic_vector (15 downto 0);
   signal TIME_COUNT : std_logic_vector (15 downto 0);
   signal TRIG : std_logic;
   signal RST : std_logic := '0';
   signal SYS_CLK : std_logic := '0';

  constant SYS_CLK_period : TIME := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memory_controller PORT MAP (
          RST => RST,
          SYS_CLK => SYS_CLK,
          LOAD => LOAD,
          ADDR => ADDR,
          DATA => DATA,
          LOAD_OVER => LOAD_OVER,
          LOAD_CH1 => LOAD_CH1,
          LOAD_DONE_CH1 => LOAD_DONE_CH1,
          ADDR_CH1 => ADDR_CH1,
          DATA_CH1 => DATA_CH1,
          LOAD_CH2 => LOAD_CH2,
          LOAD_DONE_CH2 => LOAD_DONE_CH2,
          ADDR_CH2 => ADDR_CH2,
          DATA_CH2 => DATA_CH2,
          LOAD_CH3 => LOAD_CH3,
          LOAD_DONE_CH3 => LOAD_DONE_CH3,
          ADDR_CH3 => ADDR_CH3,
          DATA_CH3 => DATA_CH3,
          LOAD_CH4 => LOAD_CH4,
          LOAD_DONE_CH4 => LOAD_DONE_CH4,
          ADDR_CH4 => ADDR_CH4,
          DATA_CH4 => DATA_CH4,
          LOAD_CH5 => LOAD_CH5,
          LOAD_DONE_CH5 => LOAD_DONE_CH5,
          ADDR_CH5 => ADDR_CH5,
          DATA_CH5 => DATA_CH5,
          LOAD_CH6 => LOAD_CH6,
          LOAD_DONE_CH6 => LOAD_DONE_CH6,
          ADDR_CH6 => ADDR_CH6,
          DATA_CH6 => DATA_CH6
        );

   ROM_model_1: ROM_model
     port map (
       DATA_ROM => DATA_ROM,
       ADDR_ROM => ADDR_ROM,
       CE_ROM   => CE_ROM);

   memory_interface_1: memory_interface
     port map (
       RST       => RST,
       SYS_CLK   => SYS_CLK,
       ADDR      => temp_addr,
       DATA      => DATA,
       ADDR_ROM  => ADDR_ROM,
       DATA_ROM  => DATA_ROM,
       LOAD      => LOAD,
       LOAD_OVER => LOAD_OVER,
       CE_ROM    => CE_ROM);

   ch_sub_system_1: ch_sub_system
     generic map (
       iCH_BASE_ADDR => 1)
     port map (
       RST         => RST,
       ALL_TRIGED  => ALL_TRIGED,
       TRIG        => TRIG,
       LOAD_DONE   => LOAD_DONE_CH1,
       SYS_CLK     => SYS_CLK,
       CH_OUT      => CH_OUT(0),
       TRIGED      => TRIGED(0),
       LOAD        => LOAD_CH1,
       DATA        => DATA_CH1,
       ADDR        => ADDR_CH1,
       PULSE_COUNT => PULSE_COUNT,
       TIME_COUNT  => TIME_COUNT);

   ch_sub_system_2: ch_sub_system
     generic map (
       iCH_BASE_ADDR => 2)
     port map (
       RST         => RST,
       ALL_TRIGED  => ALL_TRIGED,
       TRIG        => TRIG,
       LOAD_DONE   => LOAD_DONE_CH2,
       SYS_CLK     => SYS_CLK,
       CH_OUT      => CH_OUT(1),
       TRIGED      => TRIGED(1),
       LOAD        => LOAD_CH2,
       DATA        => DATA_CH2,
       ADDR        => ADDR_CH2,
       PULSE_COUNT => open,
       TIME_COUNT  => open);

   ch_sub_system_3: ch_sub_system
     generic map (
       iCH_BASE_ADDR => 3)
     port map (
       RST         => RST,
       ALL_TRIGED  => ALL_TRIGED,
       TRIG        => TRIG,
       LOAD_DONE   => LOAD_DONE_CH3,
       SYS_CLK     => SYS_CLK,
       CH_OUT      => CH_OUT(2),
       TRIGED      => TRIGED(2),
       LOAD        => LOAD_CH3,
       DATA        => DATA_CH3,
       ADDR        => ADDR_CH3,
       PULSE_COUNT => open,
       TIME_COUNT  => open);

   ch_sub_system_4: ch_sub_system
     generic map (
       iCH_BASE_ADDR => 4)
     port map (
       RST         => RST,
       ALL_TRIGED  => ALL_TRIGED,
       TRIG        => TRIG,
       LOAD_DONE   => LOAD_DONE_CH4,
       SYS_CLK     => SYS_CLK,
       CH_OUT      => CH_OUT(3),
       TRIGED      => TRIGED(3),
       LOAD        => LOAD_CH4,
       DATA        => DATA_CH4,
       ADDR        => ADDR_CH4,
       PULSE_COUNT => open,
       TIME_COUNT  => open);

   ch_sub_system_5: ch_sub_system
     generic map (
       iCH_BASE_ADDR => 5)
     port map (
       RST         => RST,
       ALL_TRIGED  => ALL_TRIGED,
       TRIG        => TRIG,
       LOAD_DONE   => LOAD_DONE_CH5,
       SYS_CLK     => SYS_CLK,
       CH_OUT      => CH_OUT(4),
       TRIGED      => TRIGED(4),
       LOAD        => LOAD_CH5,
       DATA        => DATA_CH5,
       ADDR        => ADDR_CH5,
       PULSE_COUNT => open,
       TIME_COUNT  => open);

   ch_sub_system_6: ch_sub_system
     generic map (
       iCH_BASE_ADDR => 6)
     port map (
       RST         => RST,
       ALL_TRIGED  => ALL_TRIGED,
       TRIG        => TRIG,
       LOAD_DONE   => LOAD_DONE_CH6,
       SYS_CLK     => SYS_CLK,
       CH_OUT      => CH_OUT(5),
       TRIGED      => TRIGED(5),
       LOAD        => LOAD_CH6,
       DATA        => DATA_CH6,
       ADDR        => ADDR_CH6,
       PULSE_COUNT => open,
       TIME_COUNT  => open);
 
   -- No clocks detected in port list. Replace SYS_CLK below with 
   -- appropriate port name 
 
   
 
   SYS_CLK_process :process
   begin
		SYS_CLK <= '0';
		wait for SYS_CLK_period/2;
		SYS_CLK <= '1';
		wait for SYS_CLK_period/2;
   end process;
 
   ALL_TRIGED <= TRIGED(0) and TRIGED(1) and TRIGED (2) and
                 TRIGED(3) and TRIGED(4) and TRIGED (5);
   temp_addr <= "00000" & ADDR;
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      wait for 100 ns;	
      RST <= '1';
      wait for 20 ns;
      TRIG <= '1';
      wait for SYS_CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
