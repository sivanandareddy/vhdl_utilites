-------------------------------------------------------------------------------
-- Author : T. Sivananda Reddy
-- Date of creation : 25.06.2013
-- Purpose : To create ROM model for simulations by taking DATA from file
-- revision : 0.02 ver revised on 10.12.2013
-- Revision comments name of the signals are changed to avoid confusion
-------------------------------------------------------------------------------
library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.STD_LOGIC_ARITH.all;
use std.TEXTIO.all;
use ieee.STD_LOGIC_TEXTIO.all;

entity ROM_model is

--  generic (
--    DATA_WIDTH : integer := 16;         -- data bus width of the ROM
--    ADDR_WIDTH : integer := 21         -- Address bus width
----    FILE_NAME  : string  := "PROM_DATA.csv"
--  );  -- data file for the ROM made from libre office calc

  port (
    DATA_ROM : out std_logic_vector(15 downto 0);        -- data out from ROM
    ADDR_ROM : in  std_logic_vector(20 downto 0);        -- address bus in for the rom model
    CE_ROM : in  std_logic);              -- chipselect when high

end ROM_model;

architecture behavioural of ROM_model is

begin  -- behavioural

  -- purpose: to simulate ROM
  -- type   : combinational
  -- inputs : CS_N, ADDR
  -- outputs: DATA
  ROM_PROCESS: process (CE_ROM, ADDR_ROM)

    --constant FILE_NAME : string := "PROM_DATA.csv";
    --constant DATA_WIDTH : integer := 16;
    --constant ADDR_WIDTH : integer := 21;

    type MEMORY is array (0 to 2**21 - 1) of integer range 0 to 2**16 - 1;  -- memory array to store the ROM contents
    variable MEM : MEMORY := (others => 0);  -- memory contents all are set to zero initially
    variable IADDR : integer range 0 to 2**21 - 1;
    variable DATA_TEMP : integer range 0 to  2**16 - 1;
    variable BUF : line;
    variable TADDR : integer range 0 to 2**21 - 1;
    variable TDATA : integer range 0 to  2**16 - 1;
    variable INIT : integer := 0;
    file IN_FILE : text open read_mode is "PROM_DATA.csv";

  begin  -- process ROM_PROCESS

    if INIT = 0 then
      while not (endfile(IN_FILE)) loop
        readline (IN_FILE, BUF);
        read (BUF, TADDR);
        read (BUF, TDATA);
        -- DATA_TEMP := CONV_INTEGER(TDATA);
        MEM(TADDR) := TDATA;
      end loop;
      INIT := 1;
    end if;

    if CE_ROM = '1' then
      IADDR := CONV_INTEGER(ADDR_ROM);
      DATA_TEMP := MEM(IADDR);
      DATA_ROM <= CONV_STD_LOGIC_VECTOR(DATA_TEMP, 16) after 90 ns;
    else
      DATA_ROM <= (others => 'Z');
    end if;
  end process ROM_PROCESS;
  

end behavioural;
