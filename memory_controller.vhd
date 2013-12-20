----------------------------------------------------------------------------------
-- Company: RRCAT indore
-- Engineer: T. Sivananda Reddy
-- 
-- Create Date:    16:27:36 12/09/2013 
-- Design Name: 
-- Module Name:    memory_controller - Behavioral 
-- Project Name:  Three phase pulse burst generator
-- Target Devices: 
-- Tool versions: 
-- Description: Sharing memory in round robin fashion to all channels
--              that are rsiing the requests
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.02 - File Created
-- Additional Comments: 
-- waiting for 2 macine cycles state is change to only one machine cycle
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory_controller is

  port (
    SYS_CLK       : in  std_logic;
    RST           : in  std_logic;
    LOAD          : out std_logic;
    ADDR          : out std_logic_vector (15 downto 0);
    DATA          : in  std_logic_vector (15 downto 0);
    LOAD_OVER     : in  std_logic;  -- above are connections to memory interface
    -- channel 1
    LOAD_CH1      : in  std_logic;
    LOAD_DONE_CH1 : out std_logic;
    ADDR_CH1      : in  std_logic_vector (15 downto 0);
    DATA_CH1      : out std_logic_vector (15 downto 0);
    -- channel 2
    LOAD_CH2      : in  std_logic;
    LOAD_DONE_CH2 : out std_logic;
    ADDR_CH2      : in  std_logic_vector (15 downto 0);
    DATA_CH2      : out std_logic_vector (15 downto 0);
    -- channel 3
    LOAD_CH3      : in  std_logic;
    LOAD_DONE_CH3 : out std_logic;
    ADDR_CH3      : in  std_logic_vector (15 downto 0);
    DATA_CH3      : out std_logic_vector (15 downto 0);
    -- channel 4
    LOAD_CH4      : in  std_logic;
    LOAD_DONE_CH4 : out std_logic;
    ADDR_CH4      : in  std_logic_vector (15 downto 0);
    DATA_CH4      : out std_logic_vector (15 downto 0);
    -- channel 5
    LOAD_CH5      : in  std_logic;
    LOAD_DONE_CH5 : out std_logic;
    ADDR_CH5      : in  std_logic_vector (15 downto 0);
    DATA_CH5      : out std_logic_vector (15 downto 0);
    -- channel 6
    LOAD_CH6      : in  std_logic;
    LOAD_DONE_CH6 : out std_logic;
    ADDR_CH6      : in  std_logic_vector (15 downto 0);
    DATA_CH6      : out std_logic_vector (15 downto 0));

end entity memory_controller;

architecture Behavioral of memory_controller is
  type state_type is (CHECK_CH1_STATE, CHECK_CH2_STATE, CHECK_CH3_STATE,
                      CHECK_CH4_STATE, CHECK_CH5_STATE, CHECK_CH6_STATE,
                      LOAD_CH1_STATE, LOAD_CH2_STATE, LOAD_CH3_STATE,
                      LOAD_CH4_STATE, LOAD_CH5_STATE, LOAD_CH6_STATE,
                      WAIT_CH1_DATA_STATE, WAIT_CH2_DATA_STATE, WAIT_CH3_DATA_STATE,
                      WAIT_CH4_DATA_STATE, WAIT_CH5_DATA_STATE, WAIT_CH6_DATA_STATE,
                      WAIT_FOR_2MC_CH1_STATE, WAIT_FOR_2MC_CH2_STATE, WAIT_FOR_2MC_CH3_STATE,
                      WAIT_FOR_2MC_CH4_STATE, WAIT_FOR_2MC_CH5_STATE, WAIT_FOR_2MC_CH6_STATE);
  signal STATE       : state_type;
  signal iWAIT_COUNT : integer range 0 to 7;
begin

  -- purpose: the memory controller state machine
  -- type   : sequential
  -- inputs : SYS_CLK, RST, LOAD_OVER, LOAD_CH(x),DATA
  -- outputs: DATA_CH(x)
  state_mac : process (SYS_CLK, RST) is
  begin  -- process state_mac
    if RST = '0' then                   -- asynchronous reset (active low)
      STATE <= CHECK_CH1_STATE;
    elsif SYS_CLK'event and SYS_CLK = '1' then  -- rising clock edge
      case STATE is
        -----------------------------------------------------------------------
        -- channel 1
        -----------------------------------------------------------------------
        when CHECK_CH1_STATE =>
          if LOAD_CH1 = '1' then
            STATE <= LOAD_CH1_STATE;
          else
            STATE <= CHECK_CH2_STATE;
          end if;
        when LOAD_CH1_STATE =>
          STATE <= WAIT_CH1_DATA_STATE;
        when WAIT_CH1_DATA_STATE =>
          DATA_CH1    <= DATA;
          iWAIT_COUNT <= 2;
          if LOAD_OVER = '1' then
            STATE <= WAIT_FOR_2MC_CH1_STATE;
          end if;
        when WAIT_FOR_2MC_CH1_STATE =>
          iWAIT_COUNT <= iWAIT_COUNT - 1;
          STATE       <= CHECK_CH2_STATE;
        --if iWAIT_COUNT = 1 then
        --  STATE <= CHECK_CH2_STATE;
        --end if;
        -----------------------------------------------------------------------
        -- channel 2
        -----------------------------------------------------------------------
        when CHECK_CH2_STATE =>
          if LOAD_CH2 = '1' then
            STATE <= LOAD_CH2_STATE;
          else
            STATE <= CHECK_CH3_STATE;
          end if;
        when LOAD_CH2_STATE =>
          STATE <= WAIT_CH2_DATA_STATE;
        when WAIT_CH2_DATA_STATE =>
          DATA_CH2    <= DATA;
          iWAIT_COUNT <= 2;
          if LOAD_OVER = '1' then
            STATE <= WAIT_FOR_2MC_CH2_STATE;
          end if;
        when WAIT_FOR_2MC_CH2_STATE =>
          iWAIT_COUNT <= iWAIT_COUNT - 1;
          STATE       <= CHECK_CH3_STATE;
        --if iWAIT_COUNT = 1 then
        --  STATE <= CHECK_CH3_STATE;
        --end if;
        -----------------------------------------------------------------------
        -- channel 3
        -----------------------------------------------------------------------
        when CHECK_CH3_STATE =>
          if LOAD_CH3 = '1' then
            STATE <= LOAD_CH3_STATE;
          else
            STATE <= CHECK_CH4_STATE;
          end if;
        when LOAD_CH3_STATE =>
          STATE <= WAIT_CH3_DATA_STATE;
        when WAIT_CH3_DATA_STATE =>
          DATA_CH3    <= DATA;
          iWAIT_COUNT <= 2;
          if LOAD_OVER = '1' then
            STATE <= WAIT_FOR_2MC_CH3_STATE;
          end if;
        when WAIT_FOR_2MC_CH3_STATE =>
          iWAIT_COUNT <= iWAIT_COUNT - 1;
          STATE       <= CHECK_CH4_STATE;
        --if iWAIT_COUNT = 1 then
        --  STATE <= CHECK_CH4_STATE;
        --end if;
        -----------------------------------------------------------------------
        -- channel 4
        -----------------------------------------------------------------------
        when CHECK_CH4_STATE =>
          if LOAD_CH4 = '1' then
            STATE <= LOAD_CH4_STATE;
          else
            STATE <= CHECK_CH5_STATE;
          end if;
        when LOAD_CH4_STATE =>
          STATE <= WAIT_CH4_DATA_STATE;
        when WAIT_CH4_DATA_STATE =>
          DATA_CH4    <= DATA;
          iWAIT_COUNT <= 2;
          if LOAD_OVER = '1' then
            STATE <= WAIT_FOR_2MC_CH4_STATE;
          end if;
        when WAIT_FOR_2MC_CH4_STATE =>
          iWAIT_COUNT <= iWAIT_COUNT - 1;
          STATE       <= CHECK_CH5_STATE;
        --if iWAIT_COUNT = 1 then
        --  STATE <= CHECK_CH5_STATE;
        --end if;
        -----------------------------------------------------------------------
        -- channel 5
        -----------------------------------------------------------------------
        when CHECK_CH5_STATE =>
          if LOAD_CH5 = '1' then
            STATE <= LOAD_CH5_STATE;
          else
            STATE <= CHECK_CH6_STATE;
          end if;
        when LOAD_CH5_STATE =>
          STATE <= WAIT_CH5_DATA_STATE;
        when WAIT_CH5_DATA_STATE =>
          DATA_CH5    <= DATA;
          iWAIT_COUNT <= 2;
          if LOAD_OVER = '1' then
            STATE <= WAIT_FOR_2MC_CH5_STATE;
          end if;
        when WAIT_FOR_2MC_CH5_STATE =>
          iWAIT_COUNT <= iWAIT_COUNT - 1;
          STATE       <= CHECK_CH6_STATE;
        --if iWAIT_COUNT = 1 then
        --  STATE <= CHECK_CH6_STATE;
        --end if;
        ---------------------------------------------------------------------
        -- channel 6
        ---------------------------------------------------------------------
        when CHECK_CH6_STATE =>
          if LOAD_CH6 = '1' then
            STATE <= LOAD_CH6_STATE;
          else
            STATE <= CHECK_CH1_STATE;
          end if;
        when LOAD_CH6_STATE =>
          STATE <= WAIT_CH6_DATA_STATE;
        when WAIT_CH6_DATA_STATE =>
          DATA_CH6    <= DATA;
          iWAIT_COUNT <= 2;
          if LOAD_OVER = '1' then
            STATE <= WAIT_FOR_2MC_CH6_STATE;
          end if;
        when WAIT_FOR_2MC_CH6_STATE =>
          iWAIT_COUNT <= iWAIT_COUNT - 1;
          STATE       <= CHECK_CH1_STATE;
        --if iWAIT_COUNT = 1 then
        --  STATE <= CHECK_CH6_STATE;
        --end if;
        when others => null;
      end case;
    end if;
  end process state_mac;

  -- purpose: state outputs
  -- type   : combinational
  -- inputs : STATE
  -- outputs: LOAD, LOAD_DONE_CH(x), ADDR
  process (STATE) is
  begin  -- process
    case STATE is
      -------------------------------------------------------------------------
      -- channel 1
      -------------------------------------------------------------------------
      when CHECK_CH1_STATE =>
        LOAD          <= '0';
        ADDR          <= ADDR_CH1;
        LOAD_DONE_CH6 <= '0';
        LOAD_DONE_CH1 <= '0';
      when LOAD_CH1_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH1;
      when WAIT_CH1_DATA_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH1;
      when WAIT_FOR_2MC_CH1_STATE =>
        LOAD          <= '0';
        ADDR          <= "0000000000000000";
        LOAD_DONE_CH1 <= '1';
      -----------------------------------------------------------------------
      -- channel 2
      -----------------------------------------------------------------------
      when CHECK_CH2_STATE =>
        LOAD          <= '0';
        ADDR          <= ADDR_CH2;
        LOAD_DONE_CH1 <= '0';
        LOAD_DONE_CH2 <= '0';
      when LOAD_CH2_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH2;
      when WAIT_CH2_DATA_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH2;
      when WAIT_FOR_2MC_CH2_STATE =>
        LOAD          <= '0';
        ADDR          <= "0000000000000000";
        LOAD_DONE_CH2 <= '1';
      -----------------------------------------------------------------------
      -- channel 3
      -----------------------------------------------------------------------
      when CHECK_CH3_STATE =>
        LOAD          <= '0';
        ADDR          <= ADDR_CH3;
        LOAD_DONE_CH2 <= '0';
        LOAD_DONE_CH3 <= '0';
      when LOAD_CH3_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH3;
      when WAIT_CH3_DATA_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH3;
      when WAIT_FOR_2MC_CH3_STATE =>
        LOAD          <= '0';
        ADDR          <= "0000000000000000";
        LOAD_DONE_CH3 <= '1';
      -------------------------------------------------------------------------
      -- channel 4
      -------------------------------------------------------------------------
      when CHECK_CH4_STATE =>
        LOAD          <= '0';
        ADDR          <= ADDR_CH4;
        LOAD_DONE_CH3 <= '0';
        LOAD_DONE_CH4 <= '0';
      when LOAD_CH4_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH4;
      when WAIT_CH4_DATA_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH4;
      when WAIT_FOR_2MC_CH4_STATE =>
        LOAD          <= '0';
        ADDR          <= "0000000000000000";
        LOAD_DONE_CH4 <= '1';
      -------------------------------------------------------------------------
      -- channel 5
      ------------------------------------------------------------------------
      when CHECK_CH5_STATE =>
        LOAD          <= '0';
        ADDR          <= ADDR_CH5;
        LOAD_DONE_CH4 <= '0';
        LOAD_DONE_CH5 <= '0';
      when LOAD_CH5_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH5;
      when WAIT_CH5_DATA_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH5;
      when WAIT_FOR_2MC_CH5_STATE =>
        LOAD          <= '0';
        ADDR          <= "0000000000000000";
        LOAD_DONE_CH5 <= '1';
      -------------------------------------------------------------------------
      -- channel 6
      -------------------------------------------------------------------------
      when CHECK_CH6_STATE =>
        LOAD          <= '0';
        ADDR          <= ADDR_CH6;
        LOAD_DONE_CH5 <= '0';
        LOAD_DONE_CH6 <= '0';
      when LOAD_CH6_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH6;
      when WAIT_CH6_DATA_STATE =>
        LOAD <= '1';
        ADDR <= ADDR_CH6;
      when WAIT_FOR_2MC_CH6_STATE =>
        LOAD          <= '0';
        ADDR          <= "0000000000000000";
        LOAD_DONE_CH6 <= '1';
      when others => null;
    end case;
  end process;

end Behavioral;

