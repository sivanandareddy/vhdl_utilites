-- KCPSM3 reference design
--    PicoBlaze performing programming of ST Microelectronics M29DW323DT FLASH 
--    Memory on the Spartan-3A Starter Kit.
--
-- Ken Chapman - Xilinx Ltd - 15th January 2007.
--
--
-- Note : The ST FLASH device can be used in 8-bit or 16-bit modes. In this 
--        design the memory is used in 8-bit (Byte) mode. When operating in
--        this mode the device uses the 15th data bit (DQ15/A-1)to form the 
--        least significant bit of the address. This in turn makes 'A0' into bit1
--        of the address etc. In this design the address should be treated as 
--        being absolute for the byte mode and this detail is resolved in the 
--        pin connections specified in the UCF file. This also correlates with 
--        the naming of the memory address signals shown in the PCB schematic.
--
-- The design is set up for a 50MHz system clock and UART communications of 19200, 
-- 38400, 57600 and 115200 Baud can be selected using the SW0 and SW1 switches.
-- Communication is 8-bit, no parity, 1 stop-bit with no flow control. 
--
--
-- Important : Any jumpers installed in J1 and J46 must be removed to isolate   
--             the SPI FLASH and Platform FLASH devices which otherwise share 
--             the least significant bit of the data bus connecting to the 
--             M29DW323DT memory. Given that the parallel FLASH memory will
--             probably then be used for Spartan-3A configuration, the appropriate 
--             two jumpers should be installed in J26 to select BPI-UP mode.
--
------------------------------------------------------------------------------------
--
-- NOTICE:
--
-- Copyright Xilinx, Inc. 2007.   This code may be contain portions patented by other 
-- third parties.  By providing this core as one possible implementation of a standard,
-- Xilinx is making no representation that the provided implementation of this standard 
-- is free from any claims of infringement by any third party.  Xilinx expressly 
-- disclaims any warranty with respect to the adequacy of the implementation, including 
-- but not limited to any warranty or representation that the implementation is free 
-- from claims of any third party.  Furthermore, Xilinx is providing this core as a 
-- courtesy to you and suggests that you contact all third parties to obtain the 
-- necessary rights to use this implementation.
--
------------------------------------------------------------------------------------
--Revesion 1.0 - Shantanu Sarkar - DATE 25 MAY 09
--In the Toplevel VHDL Module I have changed a little. The Interrupt will be generated 
--whenever the UART receiver FIFO is Half_Full.
--Revision 1.1 - Sivananda Reddy - Date 13 FEB 2014
-- The reset siganl is taken out to make manual reset when needed rather than
-- connected to GND;
------------------------------------------------------------------------------------
--
-- Library declarations
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
------------------------------------------------------------------------------------
--
--
entity m29dw323dt_flash_programmer is
    Port (    flash_oe : out std_logic;
              flash_ce : out std_logic;
              flash_we : out std_logic;
            flash_byte : out std_logic;
              flash_wp : out std_logic;
              flash_rp : out std_logic;
             flash_sts : in std_logic;                       --Pull up on input (see UCF file) 
               flash_a : out std_logic_vector(21 downto 0);  --See note at top of file.
               flash_d : inout std_logic_vector(7 downto 0);
             tx_female : out std_logic;
             rx_female : in std_logic;
                    sw : in std_logic_vector(1 downto 0);    --Pull ups on inputs (see UCF file)
                   led : out std_logic_vector(7 downto 0);
                 j2_30 : out std_logic;
                 j2_26 : out std_logic;
                 j2_22 : out std_logic;
                 j2_14 : out std_logic;
                 RST   : in std_logic;  -- revision 1.1 reset pin is added 
                   clk : in std_logic);
    end m29dw323dt_flash_programmer;


--
------------------------------------------------------------------------------------
--
-- Start of test architecture
--
architecture Behavioral of m29dw323dt_flash_programmer is
--
------------------------------------------------------------------------------------

--
-- declaration of KCPSM3
--
  component kcpsm3 
    Port (      address : out std_logic_vector(9 downto 0);
            instruction : in std_logic_vector(17 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end component;
--
-- declaration of program ROM
--
  component progctrl
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                    clk : in std_logic);
    end component;
--
-- declaration of UART transmitter with integral 16 byte FIFO buffer
--  
  component uart_tx
    Port (              data_in : in std_logic_vector(7 downto 0);
                   write_buffer : in std_logic;
                   reset_buffer : in std_logic;
                   en_16_x_baud : in std_logic;
                     serial_out : out std_logic;
                    buffer_full : out std_logic;
               buffer_half_full : out std_logic;
                            clk : in std_logic);
    end component;
--
-- declaration of UART Receiver with integral 16 byte FIFO buffer
--
  component uart_rx
    Port (            serial_in : in std_logic;
                       data_out : out std_logic_vector(7 downto 0);
                    read_buffer : in std_logic;
                   reset_buffer : in std_logic;
                   en_16_x_baud : in std_logic;
            buffer_data_present : out std_logic;
                    buffer_full : out std_logic;
               buffer_half_full : out std_logic;
                            clk : in std_logic);
  end component;
--
-- 'Bucket Brigade' FIFO 
--
component bbfifo_16x8 
    Port (       data_in : in std_logic_vector(7 downto 0);
                data_out : out std_logic_vector(7 downto 0);
                   reset : in std_logic;               
                   write : in std_logic; 
                    read : in std_logic;
                    full : out std_logic;
               half_full : out std_logic;
            data_present : out std_logic;
                     clk : in std_logic);
    end component;
--
--
------------------------------------------------------------------------------------
--
-- Signals used to connect KCPSM3 to program ROM and I/O logic
--
signal  address         : std_logic_vector(9 downto 0);
signal  instruction     : std_logic_vector(17 downto 0);
signal  port_id         : std_logic_vector(7 downto 0);
signal  out_port        : std_logic_vector(7 downto 0);
signal  in_port         : std_logic_vector(7 downto 0);
signal  write_strobe    : std_logic;
signal  read_strobe     : std_logic;
signal  interrupt       : std_logic :='0';
signal  interrupt_ack   : std_logic;
signal  kcpsm3_reset    : std_logic;
--
-- Signals for connection of peripherals
--
signal      status_port : std_logic_vector(7 downto 0);
--
--
-- Signals for UART connections including extension FIFO buffers
--
signal            write_to_uart : std_logic;
signal                  tx_full : std_logic;
signal             tx_half_full : std_logic;
signal           read_from_uart : std_logic;
signal                  rx_data : std_logic_vector(7 downto 0);
signal          rx_data_present : std_logic;
signal                  rx_full : std_logic;
signal             rx_half_full : std_logic;
signal     stage1_fifo_data_out : std_logic_vector(7 downto 0);
signal     stage2_fifo_data_out : std_logic_vector(7 downto 0);
signal        stage2_fifo_write : std_logic;
signal        stage3_fifo_write : std_logic;
signal stage1_fifo_data_present : std_logic;
signal stage2_fifo_data_present : std_logic;
signal    stage1_fifo_half_full : std_logic;
signal   stage2_fifo_full       : std_logic;
signal    stage3_fifo_full      : std_logic;
signal    stage3_fifo_half_full : std_logic;
--
--
-- Signals for UART Baud rate generation
--
signal        baud_count : std_logic_vector(4 downto 0) := "00000";
signal    en_16_x_115200 : std_logic := '0';
signal baud_divide_count : std_logic_vector(2 downto 0) := "000";
signal       baud_select : std_logic:= '0';
signal      en_16_x_baud : std_logic:= '0';
--
--
-- Signals to connect to FLASH memory 
--
signal flash_read       : std_logic;
signal write_data       : std_logic_vector(7 downto 0);
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin
  --
  --
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Set 8-bit mode of operation for FLASH memory  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- The FLASH memory can be used in 8-bit or 16-bit modes. Since PicoBlaze is an 8-bit 
  -- processor and the configuration from parallel flash is conducted using an 8-bit interface, 
  -- this design forces the 8-bit data mode.
  --
  -- As a result, the 32Mbit memory is organised as 4,194,304 bytes accessed using a 22-bit address.
  --
  flash_byte <= '0';   -- All communication is byte based
  flash_wp <= '1';     -- Disable any hardware write protection of FLASH
  flash_rp <= '1';     -- Active Low FLASH reset (High makes device able to work)
  --
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Bidirectional data interface for FLASH memory  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- To read the FLASH memory the output enable (OE) signal must be driven Low on the memory and 
  -- the pins on the Spartan-3E must become inputs (i.e. the output buffers must be high impedance).
  --
  --
  flash_oe <= not(flash_read);  --active Low output enable
  --
  flash_d <= write_data when (flash_read='0') else "ZZZZZZZZ";
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 and the program memory 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  processor: kcpsm3
    port map(      address => address,
               instruction => instruction,
                   port_id => port_id,
              write_strobe => write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     reset => kcpsm3_reset,
                       clk => clk);
 
  program_rom: progctrl
    port map(      address => address,
               instruction => instruction,
                       clk => clk);

  kcpsm3_reset <= RST;                  -- revision 1.1 reset pin is taken out
                                        -- for manual reseting


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Interrupt 
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Revesion 1.0 - Shantanu Sarkar - DATE 25 MAY 09
  -- In the Toplevel VHDL Module I have changed a little. The Interrupt will be generated 
  -- whenever the UART receiver FIFO is Half_Full.     

  --
  -- Interrupt is used to detect if the UART receiver becomes HALF full.
  --

  interrupt_control: process(clk)
  begin
    if clk'event and clk='1' then

      -- processor interrupt waits for an acknowledgement
      if interrupt_ack='1' then
         interrupt <= '0';
        elsif rx_half_full='1' then  -- elsif rx_full='1' then
         interrupt <= '1';
        else
         interrupt <= interrupt;
      end if;

    end if; 
  end process interrupt_control;

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 input ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- UART FIFO status signals to form a bus
  -- Also the status signal (STS) from the FLASH memory although not currently used in program

  status_port <= flash_sts & "00" & rx_full & rx_half_full & rx_data_present & tx_full & tx_half_full;

  --
  -- The inputs connect via a pipelined multiplexer
  --

  input_ports: process(clk)
  begin
    if clk'event and clk='1' then

      case port_id(1 downto 0) is

        
        -- read status signals at address 00 hex
        when "00" =>    in_port <= status_port;

        -- read UART receive data at address 01 hex
        when "01" =>    in_port <= rx_data;

        -- read FLASH memory data at address 02 hex
        when "10" =>    in_port <= flash_d;

        -- Don't care used for all other addresses to ensure minimum logic implementation
        when others =>    in_port <= "XXXXXXXX";  

      end case;

      -- Form read strobe for UART receiver FIFO buffer at address 01 hex.
      -- The fact that the read strobe will occur after the actual data is read by 
      -- the KCPSM3 is acceptable because it is really means 'I have read you'!
 
      if (read_strobe='1' and port_id(1 downto 0)="01") then 
        read_from_uart <= '1';
       else 
        read_from_uart <= '0';
      end if;

    end if;

  end process input_ports;


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 output ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  -- adding the output registers to the processor
   
  output_ports: process(clk)
  begin

    if clk'event and clk='1' then
      if write_strobe='1' then

        -- The 24-bit address to the FLASH memory requires 3 ports.

        -- Address [21:16] at port 80 hex 
        if port_id(7)='1' then
          flash_a(21 downto 16) <= out_port(5 downto 0);
        end if;

        -- Address [15:8] at port 40 hex 
        if port_id(6)='1' then
          flash_a(15 downto 8) <= out_port;
        end if;

        -- Address [7:0] at port 20 hex 
        if port_id(5)='1' then
          flash_a(7 downto 0) <= out_port;
        end if;

        -- Data to be written to FLASH at port 10 hex 
        if port_id(4)='1' then
          write_data <= out_port;
        end if;

        -- FLASH control signals at port 08 hex 
        if port_id(3)='1' then
          flash_read <= out_port(0);  -- Active High and used to control data bus direction and OE
          flash_ce <= out_port(1);    -- Active Low FLASH device enable
          flash_we <= out_port(2);    -- Active Low FLASH write enable
        end if;

      end if;

    end if; 

  end process output_ports;

  --
  -- write to UART transmitter FIFO buffer at address 04 hex.
  -- This is a combinatorial decode because the FIFO is the 'port register'.
  --

  write_to_uart <= '1' when (write_strobe='1' and port_id(2)='1') else '0';


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- UART  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
  -- Each contains an embedded 16-byte FIFO buffer.
  --

  transmit: uart_tx 
  port map (              data_in => out_port, 
                     write_buffer => write_to_uart,
                     reset_buffer => '0',
                     en_16_x_baud => en_16_x_baud,
                       serial_out => tx_female,
                      buffer_full => tx_full,
                 buffer_half_full => tx_half_full,
                              clk => clk );

  --
  -- The receiver FIFO is extended by an additional two stages of 16 bytes to provide a total depth of 48. This ensures 
  -- that the FIFO does not overflow when receiving an MCS file from the PC even if the FLASH memory is operating at 
  -- slowest specified rate. 
  --
  -- The FIFO is constructed in 'bucket brigade' style which means that the data is always from one FIFO stage to the next 
  -- providing there is space available. In this way the last stage will always be ready to provide any data that has been 
  -- received and it is the last stage from which PicoBlaze reads received data.
  --
  -- The entire 48 deep FIFO is full when the first stage becomes full as this means that there is no space to pass data .
  -- on to the following stages.
  --

  fifo_control: process(clk)
  begin
    if clk'event and clk='1' then

      -- Stage 2 is written when there is data in stage 1 and stage 2 is not full.
      -- This transfer of data also results in the corresponding read from stage 1. The transfer control signal is a single
      -- cycle pulse to give time for the data present output of stage 1 to respond to read event and go Low if possible.   

      stage2_fifo_write <= stage1_fifo_data_present and not(stage2_fifo_full) and not(stage2_fifo_write);

      -- Stage 3 is written when there is data in stage 2 and stage 3 is not full.
      -- This transfer of data also results in the corresponding read from stage 2. The transfer control signal is a single
      -- cycle pulse to give time for the data present output of stage 2 to respond to read event and go Low if possible.   

      stage3_fifo_write <= stage2_fifo_data_present and not(stage3_fifo_full) and not(stage3_fifo_write);

    end if;
  end process fifo_control;

  receive: uart_rx
  port map (            serial_in => rx_female,
                         data_out => stage1_fifo_data_out,
                      read_buffer => stage2_fifo_write,
                     reset_buffer => '0',
                     en_16_x_baud => en_16_x_baud,
              buffer_data_present => stage1_fifo_data_present,
                      buffer_full => rx_full,                     --48 deep FIFO full if all stages are full (16+16+16)
                 buffer_half_full => stage1_fifo_half_full,
                              clk => clk );  

  rx_buf_stage2: bbfifo_16x8 
  port map (       data_in => stage1_fifo_data_out,
                  data_out => stage2_fifo_data_out,
                     reset => '0',             
                     write => stage2_fifo_write,
                      read => stage3_fifo_write,
                      full => stage2_fifo_full,
                 half_full => rx_half_full,                      --48 deep FIFO is half if stage 2 is half full (16+8)
              data_present => stage2_fifo_data_present,
                       clk => clk);

  rx_buf_stage3: bbfifo_16x8 
  port map (       data_in => stage2_fifo_data_out,
                  data_out => rx_data,
                     reset => '0',              
                     write => stage3_fifo_write,
                      read => read_from_uart,
                      full => stage3_fifo_full,
                 half_full => stage3_fifo_half_full,
              data_present => rx_data_present,
                       clk => clk);

  

  --
  -- Set the UART baud rate to 19200, 38400, 57600 or 115200 using the SW0 and SW1 switches.
  --
  -- The en_16_x_baud has to be 16 times the desired baud rate so should be close to 1843200Hz
  -- for a baud rate of 115200. This is achieved by generating a pulse once every 27 cycles at 
  -- 50MHz. The slower baud rates require further division by 2, 3 and 6.
  --


  -- Counter to generate enable pulses once every 27 clock cycles 

  baud_115200_counter: process(clk)
  begin
    if clk'event and clk='1' then
      if baud_count(4 downto 1) = "1101" then      -- Efficient 4-input decode of value 26
         baud_count <= "00000";
         en_16_x_115200 <= '1';
       else
         baud_count <= baud_count + 1;
         en_16_x_115200 <= '0';
      end if;
    end if;
  end process baud_115200_counter;


  -- Counter used to divide enable pulses by 2, 3 or 6 

  baud_divide_counter: process(clk)
  begin
    if clk'event and clk='1' then
      if en_16_x_115200 = '1' then
        if baud_select = '1' then  
          baud_divide_count <= "000";
         else
          baud_divide_count <= baud_divide_count + 1;
        end if;
      end if;
    end if;
  end process baud_divide_counter;


  --Combinatorial multiplexer to select desired baud rate 

  baud_selector: process(sw, baud_divide_count)
  begin
    case sw(1 downto 0) is

      -- Baud rate 19200 when switches set to "00".
      -- Division by 6 required and so detecting when bits 0 and 2 of the 
      --   counter are High reveals a count value of 5 ("101") and this is 
      --   used to reset the counter to achieve a 0,1,2,3,4,5,0,1,2... sequence
      --   that divides by 6.
      -- Enable pulses are generated when the counter reaches 5.
      when "00" =>    baud_select <= baud_divide_count(0) and baud_divide_count(2);

      -- Baud rate 38400 when switches set to "01".
      -- Division by 3 required and so bit1 of the counter is used to reset 
      --   the counter to achieve a 0,1,2,0,1,2 sequence that divides by 3.
      -- Enable pulses are generated when the counter reaches 2.
      when "01" =>    baud_select <= baud_divide_count(1);

      -- Baud rate 57600 when switches set to "10".
      -- Division by 2 required and bit0 of counter toggles such as to 
      --   allow one enable pulse and then stop the next to half the rate.
      when "10" =>    baud_select <= baud_divide_count(0);

      -- Baud rate 115200 when switches set to "11".
      -- No counter division required and pulses generated continuously.
      when "11" =>    baud_select <= '1';

      -- All cases are covered but don't care state always ensures minimum logic.
      when others =>  baud_select <= 'X'; 

    end case;
  end process baud_selector;


  -- Combine the selector with 115200 enable pulses to generate final baud rate control signal 

  baud_enable: process(clk)
  begin
    if clk'event and clk='1' then
      en_16_x_baud <= en_16_x_115200 and baud_select;
    end if;
  end process baud_enable;


  --
  -- Test points and communication status LEDs 
  --

  j2_30 <= en_16_x_115200;
  j2_26 <= baud_select;
  j2_22 <= en_16_x_baud;
  j2_14 <= clk;
 
  led(0) <= sw(0);                       -- Confirms switch selection
  led(1) <= sw(1);

  led(2) <= rx_full;                     -- Bar type display of receiver FIFO being filled
  led(3) <= stage1_fifo_half_full;
  led(4) <= stage2_fifo_full;
  led(5) <= rx_half_full;
  led(6) <= stage3_fifo_full;
  led(7) <= stage3_fifo_half_full;
  --
  ----------------------------------------------------------------------------------------------------------------------------------

end Behavioral;

------------------------------------------------------------------------------------------------------------------------------------
--
-- END OF FILE m29dw323dt_flash_programmer.vhd
--
------------------------------------------------------------------------------------------------------------------------------------

