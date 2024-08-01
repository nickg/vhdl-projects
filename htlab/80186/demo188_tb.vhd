-------------------------------------------------------------------------------
--  HTL80186 - CPU core                                                      --
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
-- Project       : Demo FreeDOS                                              --
-- Purpose       : Test Bench                                                --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 0.1  01/12/2007   Created HT-LAB                          --
--               : 0.79 14/01/2009                                           --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY std;
USE std.textio.ALL;

ENTITY demo188_tb IS
END demo188_tb;


ARCHITECTURE struct OF demo188_tb IS

    -- Internal signal declarations
    SIGNAL CE2        : std_logic       := '1';                 -- high-active Chip-Enable of the SRAM device; defaults to '1'  (active)
    constant LOADFLASH0 : string(1 TO 14) := "loadflash0.dat";
    constant LOADFNAMED : string(1 TO 14) := "loadfnamed.dat";
    SIGNAL abus       : std_logic_vector(19 DOWNTO 0);
    SIGNAL clk        : std_logic;
    SIGNAL cpu_resetn : std_logic;
    SIGNAL dbus_out   : std_logic_vector(15 DOWNTO 0);
    SIGNAL dout4      : std_logic;
    SIGNAL flash_cs_n : std_logic;
    SIGNAL flash_oe_n : std_logic;
    SIGNAL flash_we_n : std_logic;
    SIGNAL fse_a      : std_logic_vector(22 DOWNTO 0);
    SIGNAL fse_d      : std_logic_vector(7 DOWNTO 0);           -- bidirectional data bus to/from the SRAM device
    SIGNAL iom        : std_logic;
    SIGNAL nWE        : std_logic       := '1';                 -- low-active Write-Enable of the SRAM device; defaults to '1' (inactive)
    SIGNAL sram_cs_n  : std_logic;
    SIGNAL sram_oe_n  : std_logic;
    SIGNAL sram_we_n  : std_logic;
    SIGNAL wrn        : std_logic;

    SIGNAL mw_U_1clk : std_logic;

    SIGNAL mw_U_2pulse : std_logic :='0';

    -- Component Declarations
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
    COMPONENT sram
    GENERIC (
      clear_on_power_up       : boolean := FALSE;
      download_on_power_up    : boolean := TRUE;
      trace_ram_load          : boolean := TRUE;
      enable_nWE_only_control : boolean := TRUE;
      download_filename :     string     := "loadfname.dat";           -- name of the download source file
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
      nCE               : IN     std_logic  := '1';                       -- low-active Chip-Enable of the SRAM device; defaults TO '1' (inactive)
      nOE               : IN     std_logic  := '1';                       -- low-active Output-Enable of the SRAM device; defaults TO '1' (inactive)
      nWE               : IN     std_logic  := '1';                       -- low-active Write-Enable of the SRAM device; defaults TO '1' (inactive)
      A                 : IN     std_logic_vector (adr_width-1 DOWNTO 0); -- address bus of the SRAM device
      D                 : INOUT  std_logic_vector (width-1 DOWNTO 0);     -- bidirectional data bus to/from the SRAM device
      CE2               : IN     std_logic  := '1';                       -- high-active Chip-Enable of the SRAM device; defaults TO '1'  (active)
      download          : IN     boolean    := FALSE;                     -- A FALSE-to-TRUE transition on this signal downloads the data
      dump              : IN     boolean    := FALSE;                     -- A FALSE-to-TRUE transition on this signal dumps
      dump_start        : IN     natural    := 0;                         -- Written TO the dump-file are the memory words from memory address
      dump_end          : IN     natural    := size-1;                    -- dump_start TO address dump_end (default: all addresses)
      dump_filename     : IN     string     := "dumpfname.dat"            -- name of the dump destination file
    );
    END COMPONENT;

    COMPONENT demo188
    PORT (
      clk        : IN     std_logic ;
      cpu_resetn : IN     std_logic ;
      flash_cs_n : OUT    std_logic ;
      flash_oe_n : OUT    std_logic ;
      flash_we_n : OUT    std_logic ;
      fse_a      : OUT    std_logic_vector (22 DOWNTO 0);
      iom        : OUT    std_logic ;
      sram_cs_n  : OUT    std_logic ;
      sram_oe_n  : OUT    std_logic ;
      sram_we_n  : OUT    std_logic ;
      wrn        : OUT    std_logic ;
      fse_d      : INOUT  std_logic_vector (7 DOWNTO 0)
    );
    END COMPONENT;



BEGIN

    abus<= fse_a(19 downto 0);
    dbus_out <= X"00"& fse_d;

    u_1clk_proc: PROCESS
    BEGIN
      LOOP
         mw_U_1clk <= '0', '1' AFTER 19.38 ns;
         WAIT FOR 38.76 ns;
      END LOOP;
      WAIT;
    END PROCESS u_1clk_proc;
    clk <= mw_U_1clk;

    cpu_resetn <= mw_U_2pulse;
    u_2pulse_proc: PROCESS
    BEGIN
      mw_U_2pulse <=
         '0',
         '1' AFTER 580 ns;
      WAIT;
    END PROCESS u_2pulse_proc;

    CE2 <= '1';
    nWE <= '1';
    dout4 <= '1';

    -- Instance port mappings.
    U_3 : port_mon_debug
      GENERIC MAP (
         MAXCHAR_C => 80
      )
      PORT MAP (
         mio      => iom,
         resoutn  => cpu_resetn,
         wrn      => wrn,
         dbus_out => dbus_out,
         abus     => abus(19 DOWNTO 0)
      );
    U_21 : sram
      GENERIC MAP (
         clear_on_power_up       => TRUE,
         download_on_power_up    => TRUE,
         trace_ram_load          => FALSE,
         enable_nWE_only_control => FALSE,
         download_filename => LOADFNAMED,
         size                    => 1048576,
         adr_width               => 20,
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
         nCE               => sram_cs_n,
         nOE               => sram_oe_n,
         nWE               => sram_we_n,
         A                 => fse_a(19 DOWNTO 0),
         D                 => fse_d,
         CE2               => dout4,
         download          => OPEN,
         dump              => OPEN,
         dump_start        => OPEN,
         dump_end          => OPEN,
         dump_filename     => OPEN
      );
    U_22 : sram
      GENERIC MAP (
         clear_on_power_up       => FALSE,
         download_on_power_up    => TRUE,
         trace_ram_load          => FALSE,
         enable_nWE_only_control => FALSE,
         download_filename => LOADFLASH0,
         size                    => 524288,
         adr_width               => 19,
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
         nCE               => flash_cs_n,
         nOE               => flash_oe_n,
         nWE               => nWE,
         A                 => fse_a(18 DOWNTO 0),
         D                 => fse_d,
         CE2               => CE2,
         download          => OPEN,
         dump              => OPEN,
         dump_start        => OPEN,
         dump_end          => OPEN,
         dump_filename     => OPEN
      );

    U_0 : demo188
      PORT MAP (
         clk        => clk,
         cpu_resetn => cpu_resetn,
         flash_cs_n => flash_cs_n,
         flash_oe_n => flash_oe_n,
         flash_we_n => flash_we_n,
         fse_a      => fse_a,
         iom        => iom,
         sram_cs_n  => sram_cs_n,
         sram_oe_n  => sram_oe_n,
         sram_we_n  => sram_we_n,
         wrn        => wrn,
         fse_d      => fse_d
      );

END struct;
