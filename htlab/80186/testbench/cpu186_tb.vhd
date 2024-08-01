-------------------------------------------------------------------------------
--  HTL80186 - Simple Testbench                                              --
--  Copyright (C) 2002-2013 HT-LAB                                           --
--                                                                           --
--  Web          : http://www.ht-lab.com                                     --
--  Contact      : support@ht-lab.com                                        --
--  Sales        : sales@ht-lab.com                                          --
-------------------------------------------------------------------------------
-- Please review the terms of the license agreement before using this file.  --
-- If you are not an authorized user, please destroy this source code file   --
-- and notify HT-Lab immediately that you inadvertently received an un-      --
-- authorized copy.                                                          --
-------------------------------------------------------------------------------
-- Project       : HTL80186                                                  --
-- Purpose       : Simple Testbench                                          --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 1.0  05/21/02   Created HT-LAB                            --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY cpu186_tb IS
END cpu186_tb;

ARCHITECTURE struct OF cpu186_tb IS

   -- Internal signal declarations
   SIGNAL LOADPROMH : string(1 TO 13) := "loadpromh.dat";
   SIGNAL LOADPROML : string(1 TO 13) := "loadproml.dat";
   SIGNAL LOADSRAMH : string(1 TO 13) := "loadsramh.dat";
   SIGNAL LOADSRAML : string(1 TO 13) := "loadsraml.dat";
   SIGNAL abus      : std_logic_vector(23 DOWNTO 0);
   SIGNAL ale       : std_logic;
   SIGNAL bhe       : std_logic;
   SIGNAL clk       : std_logic;
   SIGNAL csramn    : std_logic;
   SIGNAL csromn    : std_logic;
   SIGNAL dbus      : std_logic_vector(15 DOWNTO 0);
   SIGNAL dbus_in   : std_logic_vector(15 DOWNTO 0);
   SIGNAL dbus_out  : std_logic_vector(15 DOWNTO 0);
   SIGNAL dout      : std_logic;
   SIGNAL dout1     : std_logic;
   SIGNAL dout2     : std_logic;
   SIGNAL dout3     : std_logic;
   SIGNAL dout4     : std_logic;
   SIGNAL dout5     : std_logic;
   SIGNAL dout6     : std_logic;
   SIGNAL dout7     : std_logic;
   SIGNAL error     : std_logic;
   SIGNAL inta      : std_logic;
   SIGNAL mio       : std_logic;
   SIGNAL nWE       : std_logic:= '1';
   SIGNAL nWE1      : std_logic:= '1';
   SIGNAL por       : std_logic;
   SIGNAL rdn       : std_logic:= '1';
   SIGNAL ready     : std_logic;
   SIGNAL resoutn   : std_logic;
   SIGNAL s         : std_logic_vector(6 DOWNTO 0);
   SIGNAL wrn       : std_logic;
   SIGNAL wrnh      : std_logic:= '1';
   SIGNAL wrnl      : std_logic:= '1';


   SIGNAL mw_I3clk  : std_logic;
   SIGNAL mw_I7pulse: std_logic:='0';

   -- HTL80186 Processor
   COMPONENT cpu186
   port( 
       clk        : in     std_logic;
       dbus_in    : in     std_logic_vector (15 downto 0);
       hold       : in     std_logic;
       intr       : in     std_logic;
       nmi        : in     std_logic;
       por        : in     std_logic;
       ready      : in     std_logic;
       test       : in     std_logic;
       turbo186   : in     std_logic;
       abus       : out    std_logic_vector (23 downto 0);
       ale        : out    std_logic;
       bhe        : out    std_logic;
       dbus_out   : out    std_logic_vector (15 downto 0);
       hlda       : out    std_logic;
       inta       : out    std_logic;
       iret       : out    std_logic;                       -- ver 1.4, IRET being executed
       lock       : out    std_logic;
       proc_error : out    std_logic;
       qs         : out    std_logic_vector (1 downto 0);
       rdn        : out    std_logic;
       resoutn    : out    std_logic;
       s          : out    std_logic_vector (6 downto 0);
       wrn        : out    std_logic
   );
   END COMPONENT;
   
   -- Debug Port Monitor
   COMPONENT port_mon_debug
   GENERIC (
      MAXCHAR_C : integer := 40
   );
   PORT (
      abus     : IN     std_logic_vector (19 DOWNTO 0);
      dbus_out : IN     std_logic_vector (15 DOWNTO 0);
      mio      : IN     std_logic;
      resoutn  : IN     std_logic;
      wrn      : IN     std_logic
   );
   END COMPONENT;
   
   -- Simple RAM model
   COMPONENT sram
   GENERIC (
      clear_on_power_up       : boolean := FALSE;
      download_on_power_up    : boolean := TRUE;
      trace_ram_load          : boolean := TRUE;
      enable_nWE_only_control : boolean := TRUE;
      size                    : INTEGER := 8;
      adr_width               : INTEGER := 3;
      width                   : INTEGER := 8;
      tAA_max                 : TIME    := 20 NS;
      tOHA_min                : TIME    := 3 NS;
      tACE_max                : TIME    := 20 NS;
      tDOE_max                : TIME    := 8 NS;
      tLZOE_min               : TIME    := 0 NS;
      tHZOE_max               : TIME    := 8 NS;
      tLZCE_min               : TIME    := 3 NS;
      tHZCE_max               : TIME    := 10 NS;
      tWC_min                 : TIME    := 20 NS;
      tSCE_min                : TIME    := 18 NS;
      tAW_min                 : TIME    := 15 NS;
      tHA_min                 : TIME    := 0 NS;
      tSA_min                 : TIME    := 0 NS;
      tPWE_min                : TIME    := 13 NS;
      tSD_min                 : TIME    := 10 NS;
      tHD_min                 : TIME    := 0 NS;
      tHZWE_max               : TIME    := 10 NS;
      tLZWE_min               : TIME    := 0 NS
   );
   PORT (
      -- in file specified by download_filename to the RAM
      download_filename : IN     string     := "loadfname.dat";           -- name of the download source file
      nCE               : IN     std_logic  := '1';                       -- low-active Chip-Enable of the SRAM device; defaults TO '1' (inactive)
      nOE               : IN     std_logic  := '1';                       -- low-active Output-Enable of the SRAM device; defaults TO '1' (inactive)
      nWE               : IN     std_logic  := '1';                       -- low-active Write-Enable of the SRAM device; defaults TO '1' (inactive)
      A                 : IN     std_logic_vector (adr_width-1 DOWNTO 0); -- address bus of the SRAM device
      D                 : INOUT  std_logic_vector (width-1 DOWNTO 0);     -- bidirectional data bus to/from the SRAM device
      CE2               : IN     std_logic  := '1';                       -- high-active Chip-Enable of the SRAM device; defaults TO '1'  (active)
      download          : IN     boolean    := FALSE;                     -- A FALSE-to-TRUE transition on this signal downloads the data
      --            Passing the filename via a port of type
      -- ********** string may cause a problem with some
      -- WATCH OUT! simulators. The string signal assigned
      -- ********** to the port at least should have the
      --            same length as the default value.
      dump              : IN     boolean    := FALSE;                     -- A FALSE-to-TRUE transition on this signal dumps
      -- the current content of the memory to the file
      -- specified by dump_filename.
      dump_start        : IN     natural    := 0;                         -- Written TO the dump-file are the memory words from memory address
      dump_end          : IN     natural    := size-1;                    -- dump_start TO address dump_end (default: all addresses)
      dump_filename     : IN     string     := "dumpfname.dat"            -- name of the dump destination file
      -- (See note at port  download_filename)
   );
   END COMPONENT;

BEGIN
   
   process (wrn,dbus_out) --,inta)
      begin  
           case wrn is
               when '0'    => dbus<= dbus_out after 10 ns; -- drive porta
               when '1'    => dbus<= (others => 'Z') after 10 ns;
               when others => dbus<= (others => 'X') after 10 ns;         
           end case;    
   end process;   
   dbus_in <= dbus; -- drive internal dbus    
                    
   assert not ((NOW > 0 ns) and error='1')  report "**** CPU Error flag asserted ****" severity warning;
   

   -- Bootstrap ROM 4Kbytes, split over 2Kbyte ROMS 
   -- FFFFF-FE000
   csromn <= '0' when ((abus(19 downto 12)="11111111") AND mio='1' AND inta='1') else '1';
   
   -- Bootstrap ROM 256 bytes 
   -- FFFFF-FF=FFF00
   --csromn <= '0' when ((abus(19 downto 8)=X"FFF") AND mio='1' AND inta='1') else '1';
   
   -- SRAM 1MByte-4Kbytes for the bootstrap
   csramn <='0' when (csromn='1' AND mio='1' AND inta='1') else '1';
   
   -- Write stobe for lower and upper half of databus
   
   wrnl<='0' when wrn='0' and abus(0)='0' else '1';
   wrnh<='0' when wrn='0' and bhe='0'     else '1';

   -- HDL Embedded Text Block 5 eb5
   -- eb4
   --------------------------------------------------------- 
   -- Status
   -- -----------------------------
   -- S2 S1 S0  Bus Cycle Initiated
   -- 0  0  0   Interrupt Acknowledge
   -- 0  0  1   Read I/O
   -- 0  1  0   Write I/O
   -- 0  1  1   Halt
   -- 1  0  0   Instruction Fetch
   -- 1  0  1   Read Data from Memory
   -- 1  1  0   Write Data to Memory
   -- 1  1  1   Passive (no bus cycle)
   --
   -- M/~IO
   ---------------------------------------------------------
   process (clk,resoutn)  
       begin
           if resoutn='0' then
               mio<='1';
           elsif (rising_edge(clk)) then 
               if ale='1' then
                   mio<=s(2);                    
               end if;  
           end if;   
   end process;

   i3clk_proc: PROCESS
   BEGIN
      LOOP
         mw_I3clk <= '0', '1' AFTER 33.91 ns;
         WAIT FOR 67.82 ns;
      END LOOP;
      WAIT;
   END PROCESS i3clk_proc;
   clk <= mw_I3clk;

   dout4 <= '0';
   dout <= '0';
   dout6 <= '0';
   dout7 <= '0';

   por <= mw_I7pulse;
   i7pulse_proc: PROCESS
   BEGIN
      mw_I7pulse <= 
         '1',
         '0' AFTER 363 ns;
      WAIT;
    END PROCESS i7pulse_proc;

   dout1 <= '1';
   nWE <= '1';
   ready <= '1';
   dout3 <= '1';
   dout2 <= '1';
   dout5 <= '1';
   nWE1 <= '1';

   -- Instance HTL80186 processor
   I0 : cpu186
      PORT MAP (
         clk        => clk,
         dbus_in    => dbus_in,
         hold       => dout,
         intr       => dout7,
         nmi        => dout6,
         por        => por,
         ready      => ready,
         test       => dout4,
		 turbo186   => dout4,			-- '0', disabled
         abus       => abus,
         ale        => ale,
         bhe        => bhe,
         dbus_out   => dbus_out,
         hlda       => OPEN,
         inta       => inta,
		 iret       => OPEN,
         lock       => OPEN,
         proc_error => error,
         qs         => OPEN,
         rdn        => rdn,
         resoutn    => resoutn,
         s          => s,
         wrn        => wrn
      );
   U_4 : port_mon_debug
      GENERIC MAP (
         MAXCHAR_C => 80
      )
      PORT MAP (
         mio      => mio,
         resoutn  => resoutn,
         wrn      => wrn,
         dbus_out => dbus_out,
         abus     => abus(19 downto 0)
      );
   RAMH : sram
      GENERIC MAP (
         clear_on_power_up       => TRUE,
         download_on_power_up    => TRUE,
         trace_ram_load          => FALSE,
         enable_nWE_only_control => FALSE,
         size                    => 131072,
         adr_width               => 17,
         width                   => 8,
         tAA_max                 => 20 NS,
         tOHA_min                => 3 NS,
         tACE_max                => 20 NS,
         tDOE_max                => 8 NS,
         tLZOE_min               => 0 NS,
         tHZOE_max               => 8 NS,
         tLZCE_min               => 3 NS,
         tHZCE_max               => 10 NS,
         tWC_min                 => 20 NS,
         tSCE_min                => 18 NS,
         tAW_min                 => 15 NS,
         tHA_min                 => 0 NS,
         tSA_min                 => 0 NS,
         tPWE_min                => 13 NS,
         tSD_min                 => 10 NS,
         tHD_min                 => 0 NS,
         tHZWE_max               => 10 NS,
         tLZWE_min               => 0 NS
      )
      	  
	-- Instantiate Memory
	PORT MAP (
         download_filename => LOADSRAMH,
         nCE               => csramn,
         nOE               => rdn,
         nWE               => wrnh,
         A                 => abus(17 DOWNTO 1),
         D                 => dbus(15 DOWNTO 8),
         CE2               => dout5,
         download          => OPEN,
         dump              => OPEN,
         dump_start        => OPEN,
         dump_end          => OPEN,
         dump_filename     => OPEN
      );
   RAML : sram
      GENERIC MAP (
         clear_on_power_up       => TRUE,
         download_on_power_up    => TRUE,
         trace_ram_load          => FALSE,
         enable_nWE_only_control => FALSE,
         size                    => 131072,
         adr_width               => 17,
         width                   => 8,
         tAA_max                 => 20 NS,
         tOHA_min                => 3 NS,
         tACE_max                => 20 NS,
         tDOE_max                => 8 NS,
         tLZOE_min               => 0 NS,
         tHZOE_max               => 8 NS,
         tLZCE_min               => 3 NS,
         tHZCE_max               => 10 NS,
         tWC_min                 => 20 NS,
         tSCE_min                => 18 NS,
         tAW_min                 => 15 NS,
         tHA_min                 => 0 NS,
         tSA_min                 => 0 NS,
         tPWE_min                => 13 NS,
         tSD_min                 => 10 NS,
         tHD_min                 => 0 NS,
         tHZWE_max               => 10 NS,
         tLZWE_min               => 0 NS
      )
      
	PORT MAP (
         download_filename => LOADSRAML,
         nCE               => csramn,
         nOE               => rdn,
         nWE               => wrnl,
         A                 => abus(17 DOWNTO 1),
         D                 => dbus(7 DOWNTO 0),
         CE2               => dout2,
         download          => OPEN,
         dump              => OPEN,
         dump_start        => OPEN,
         dump_end          => OPEN,
         dump_filename     => OPEN
      );
   ROMH : sram
      GENERIC MAP (
         clear_on_power_up       => FALSE,
         download_on_power_up    => TRUE,
         trace_ram_load          => FALSE,
         enable_nWE_only_control => FALSE,
         size                    => 2048,
         adr_width               => 11,
         width                   => 8,
         tAA_max                 => 20 NS,
         tOHA_min                => 3 NS,
         tACE_max                => 20 NS,
         tDOE_max                => 8 NS,
         tLZOE_min               => 0 NS,
         tHZOE_max               => 8 NS,
         tLZCE_min               => 3 NS,
         tHZCE_max               => 10 NS,
         tWC_min                 => 20 NS,
         tSCE_min                => 18 NS,
         tAW_min                 => 15 NS,
         tHA_min                 => 0 NS,
         tSA_min                 => 0 NS,
         tPWE_min                => 13 NS,
         tSD_min                 => 10 NS,
         tHD_min                 => 0 NS,
         tHZWE_max               => 10 NS,
         tLZWE_min               => 0 NS
      )

	-- Instantiate ROM's
	PORT MAP (
         download_filename => LOADPROMH,
         nCE               => csromn,
         nOE               => rdn,
         nWE               => nWE1,
         A                 => abus(11 DOWNTO 1),
         D                 => dbus(15 DOWNTO 8),
         CE2               => dout3,
         download          => OPEN,
         dump              => OPEN,
         dump_start        => OPEN,
         dump_end          => OPEN,
         dump_filename     => OPEN
      );
   ROML : sram
      GENERIC MAP (
         clear_on_power_up       => FALSE,
         download_on_power_up    => TRUE,
         trace_ram_load          => FALSE,
         enable_nWE_only_control => FALSE,
         size                    => 2048,
         adr_width               => 11,
         width                   => 8,
         tAA_max                 => 20 NS,
         tOHA_min                => 3 NS,
         tACE_max                => 20 NS,
         tDOE_max                => 8 NS,
         tLZOE_min               => 0 NS,
         tHZOE_max               => 8 NS,
         tLZCE_min               => 3 NS,
         tHZCE_max               => 10 NS,
         tWC_min                 => 20 NS,
         tSCE_min                => 18 NS,
         tAW_min                 => 15 NS,
         tHA_min                 => 0 NS,
         tSA_min                 => 0 NS,
         tPWE_min                => 13 NS,
         tSD_min                 => 10 NS,
         tHD_min                 => 0 NS,
         tHZWE_max               => 10 NS,
         tLZWE_min               => 0 NS
      )     
	PORT MAP (
         download_filename => LOADPROML,
         nCE               => csromn,
         nOE               => rdn,
         nWE               => nWE,
         A                 => abus(11 DOWNTO 1),
         D                 => dbus(7 DOWNTO 0),
         CE2               => dout1,
         download          => OPEN,
         dump              => OPEN,
         dump_start        => OPEN,
         dump_end          => OPEN,
         dump_filename     => OPEN
      );

END struct;
