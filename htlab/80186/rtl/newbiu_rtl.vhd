-------------------------------------------------------------------------------
--  HTL80186 - CPU core                                                      --
--  Copyright (C) 2002-2011 HT-LAB                                           --
--                                                                           --
--  Web          : http://www.ht-lab.com                                     --
--  Contact      : support@ht-lab.com                                        --
--  Sales        : sales@ht-lab.com                                          --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Please review the terms of the license agreement before using this file.  --
-- If you are not an authorized user, please destroy this source code file   --
-- and notify HT-Lab immediately that you inadvertently received an un-      --
-- authorized copy.                                                          --
-------------------------------------------------------------------------------
-- Project       : HTL80186                                                  --
-- Module        : newbiu                                                    --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 1.0  05/21/02   Created HT-LAB                            --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY I80186;
USE I80186.cpu86instr.ALL;
USE I80186.cpu86pack.ALL;

ENTITY newbiu IS
   GENERIC(
      EN8086 : integer := 0      --Set to 1 for 8086
   );
   PORT(
      bound_error  : IN     std_logic;
      bus8         : IN     std_logic;
      clk          : IN     std_logic;
      csbus        : IN     std_logic_vector (15 DOWNTO 0);
      dbus_in      : IN     std_logic_vector (15 DOWNTO 0);
      dbusdp_out   : IN     std_logic_vector (15 DOWNTO 0);
      decode_state : IN     std_logic;
      divide_error : IN     std_logic;
      esc_error    : IN     std_logic;
      flush_coming : IN     std_logic;
      flush_req    : IN     std_logic;
      halt         : IN     std_logic;
      hold         : IN     std_logic;
      intr         : IN     std_logic;
      ipbus        : IN     std_logic_vector (15 DOWNTO 0);
      irq_block    : IN     std_logic;
      memio        : IN     std_logic;
      nmi          : IN     std_logic;
      opc_req      : IN     std_logic;
      proc_error   : IN     std_logic;
      read_req     : IN     std_logic;
      ready        : IN     std_logic;
      reset        : IN     std_logic;
      status       : IN     status_out_type;
      turbo186     : IN     std_logic;
      word         : IN     std_logic;
      write_req    : IN     std_logic;
      abus         : OUT    std_logic_vector (23 DOWNTO 0);
      ale          : OUT    std_logic;
      bhe          : OUT    std_logic;
      dbus_out     : OUT    std_logic_vector (15 DOWNTO 0);
      flush_ack    : OUT    std_logic;
      hlda         : OUT    std_logic;
      instr        : OUT    instruction_type;
      inta         : OUT    std_logic;
      irq_req      : OUT    std_logic;
      mdbus_out    : OUT    std_logic_vector (15 DOWNTO 0);
      qs           : OUT    std_logic_vector (1 DOWNTO 0);
      rdn          : OUT    std_logic;
      rw_ack       : OUT    std_logic;
      s            : OUT    std_logic_vector (6 DOWNTO 0);
      valid_opc    : OUT    std_logic;
      wrn          : OUT    std_logic
   );

-- Declarations

END newbiu ;



LIBRARY I80186;

ARCHITECTURE rtl OF newbiu IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL bhe_s      : std_logic;
   SIGNAL biustat    : std_logic_vector(2 DOWNTO 0);
   SIGNAL irq_ack    : std_logic;
   SIGNAL irq_clr    : std_logic;
   SIGNAL irq_cycle2 : std_logic;
   SIGNAL irq_type   : std_logic_vector(3 DOWNTO 0);
   SIGNAL lutbus     : std_logic_vector(15 DOWNTO 0);
   SIGNAL mux_addr   : std_logic_vector(2 DOWNTO 0);
   SIGNAL mux_data   : std_logic_vector(3 DOWNTO 0);
   SIGNAL mux_reg    : std_logic_vector(2 DOWNTO 0);
   SIGNAL nbreq      : std_logic_vector(2 DOWNTO 0);
   SIGNAL oddword    : std_logic;
   SIGNAL opc_ack    : std_logic;
   SIGNAL regcnt     : std_logic_vector(3 DOWNTO 0);
   SIGNAL regnbok    : std_logic;
   SIGNAL rw_cycle   : std_logic;
   SIGNAL rw_cycle2  : std_logic;
   SIGNAL wr_mdbus   : std_logic;
   SIGNAL wrq        : std_logic;

   -- Implicit buffer signal declarations
   SIGNAL flush_ack_internal : std_logic;
   SIGNAL irq_req_internal   : std_logic;


   -- Component Declarations
   COMPONENT biuirq
   GENERIC (
      EN8086 : integer := 0
   );
   PORT (
      bound_error  : IN     std_logic ;
      clk          : IN     std_logic ;
      decode_state : IN     std_logic ;
      divide_error : IN     std_logic ;
      halt         : IN     std_logic ;
      intr         : IN     std_logic ;
      irq_block    : IN     std_logic ;
      irq_clr      : IN     std_logic ;
      nmi          : IN     std_logic ;
      esc_error    : IN     std_logic ;
      proc_error   : IN     std_logic ;
      reset        : IN     std_logic ;
      status       : IN     status_out_type ;
      irq_req      : OUT    std_logic ;
      irq_type     : OUT    std_logic_vector (3 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT formatter
   PORT (
      lutbus   : IN     std_logic_vector (15 DOWNTO 0);
      mux_addr : OUT    std_logic_vector (2 DOWNTO 0);
      mux_data : OUT    std_logic_vector (3 DOWNTO 0);
      mux_reg  : OUT    std_logic_vector (2 DOWNTO 0);
      nbreq    : OUT    std_logic_vector (2 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT newbiufsm
   PORT (
      bhe_s        : IN     std_logic ;
      bus8         : IN     std_logic ;
      clk          : IN     std_logic ;
      flush_coming : IN     std_logic ;
      flush_req    : IN     std_logic ;
      halt         : IN     std_logic ;
      hold         : IN     std_logic ;
      irq_req      : IN     std_logic ;
      irq_type     : IN     std_logic_vector ( 3 DOWNTO 0 );
      memio        : IN     std_logic ;
      oddword      : IN     std_logic ;
      opc_req      : IN     std_logic ;
      read_req     : IN     std_logic ;
      ready        : IN     std_logic ;
      regcnt       : IN     std_logic_vector ( 3 DOWNTO 0 );
      regnbok      : IN     std_logic ;
      reset        : IN     std_logic ;
      write_req    : IN     std_logic ;
      ale          : OUT    std_logic ;
      bhe          : OUT    std_logic ;
      biustat      : OUT    std_logic_vector (2 DOWNTO 0);
      flush_ack    : OUT    std_logic ;
      hlda         : OUT    std_logic ;
      inta         : OUT    std_logic ;
      irq_ack      : OUT    std_logic ;
      irq_clr      : OUT    std_logic ;
      irq_cycle2   : OUT    std_logic ;
      opc_ack      : OUT    std_logic ;
      rdn          : OUT    std_logic ;
      rw_ack       : OUT    std_logic ;
      rw_cycle     : OUT    std_logic ;
      rw_cycle2    : OUT    std_logic ;
      wr_mdbus     : OUT    std_logic ;
      wrn          : OUT    std_logic ;
      wrq          : OUT    std_logic
   );
   END COMPONENT;
   COMPONENT newbiushift
   GENERIC (
      en8086 : INTEGER := 0
   );
   PORT (
      bus8       : IN     std_logic;
      clk        : IN     std_logic;
      csbus      : IN     std_logic_vector (15 DOWNTO 0);
      dbus_in    : IN     std_logic_vector (15 DOWNTO 0);
      dbusdp_out : IN     std_logic_vector (15 DOWNTO 0);
      flush_ack  : IN     std_logic;
      ipbus      : IN     std_logic_vector (15 DOWNTO 0);
      irq_ack    : IN     std_logic;
      irq_cycle2 : IN     std_logic;
      irq_type   : IN     std_logic_vector (3 DOWNTO 0);
      mux_addr   : IN     std_logic_vector (2 DOWNTO 0);
      mux_data   : IN     std_logic_vector (3 DOWNTO 0);
      mux_reg    : IN     std_logic_vector (2 DOWNTO 0);
      nbreq      : IN     std_logic_vector (2 DOWNTO 0);
      opc_ack    : IN     std_logic;
      reset      : IN     std_logic;
      rw_cycle   : IN     std_logic;
      rw_cycle2  : IN     std_logic;
      turbo186   : IN     std_logic;
      word       : IN     std_logic;
      wr_mdbus   : IN     std_logic;
      wrq        : IN     std_logic;
      abus       : OUT    std_logic_vector (23 DOWNTO 0);
      dbus_out   : OUT    std_logic_vector (15 DOWNTO 0);
      instr      : OUT    instruction_type;
      lutbus     : OUT    std_logic_vector (15 DOWNTO 0);
      mdbus_out  : OUT    std_logic_vector (15 DOWNTO 0);
      qs         : OUT    std_logic_vector (1 DOWNTO 0);
      regcnt     : OUT    std_logic_vector (3 DOWNTO 0);
      regnbok    : OUT    std_logic
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : biuirq USE ENTITY I80186.biuirq;
   FOR ALL : formatter USE ENTITY I80186.formatter;
   FOR ALL : newbiufsm USE ENTITY I80186.newbiufsm;
   FOR ALL : newbiushift USE ENTITY I80186.newbiushift;
   -- pragma synthesis_on


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- S2..0 is Bus Cycle Status
   -- S4..3 is Segment Status
   -- S5 Interrupt Enable Flag
   -- S6 always zero.
   s   <= '0' & status.s543 & biustat;

   -- HDL Embedded Text Block 2 eb2
   valid_opc<= opc_ack OR irq_ack;

   -- HDL Embedded Text Block 3 eb3
   oddword <= (word AND ipbus(0)) when bus8='0' else word;                  -- 2 cycles required

   -- word A0
   --  0   0 Byte Transfer BHE=1   D7:0
   --  0   1 Byte Transfer BHE=0, D15:8
   --  1   0 Word Transfer BHE=0
   --  1   1 BHE=?
   -- if 80188 then use constant
   bhe_s <= not(word or ipbus(0)) when bus8='0' else '0';


   -- Instance port mappings.
   U_3 : biuirq
      GENERIC MAP (
         EN8086 => EN8086
      )
      PORT MAP (
         bound_error  => bound_error,
         clk          => clk,
         decode_state => decode_state,
         divide_error => divide_error,
         halt         => halt,
         intr         => intr,
         irq_block    => irq_block,
         irq_clr      => irq_clr,
         nmi          => nmi,
         esc_error    => esc_error,
         proc_error   => proc_error,
         reset        => reset,
         status       => status,
         irq_req      => irq_req_internal,
         irq_type     => irq_type
      );
   U_1 : formatter
      PORT MAP (
         lutbus   => lutbus,
         mux_addr => mux_addr,
         mux_data => mux_data,
         mux_reg  => mux_reg,
         nbreq    => nbreq
      );
   U_0 : newbiufsm
      PORT MAP (
         bhe_s        => bhe_s,
         bus8         => bus8,
         clk          => clk,
         flush_coming => flush_coming,
         flush_req    => flush_req,
         halt         => halt,
         hold         => hold,
         irq_req      => irq_req_internal,
         irq_type     => irq_type,
         memio        => memio,
         oddword      => oddword,
         opc_req      => opc_req,
         read_req     => read_req,
         ready        => ready,
         regcnt       => regcnt,
         regnbok      => regnbok,
         reset        => reset,
         write_req    => write_req,
         ale          => ale,
         bhe          => bhe,
         biustat      => biustat,
         flush_ack    => flush_ack_internal,
         hlda         => hlda,
         inta         => inta,
         irq_ack      => irq_ack,
         irq_clr      => irq_clr,
         irq_cycle2   => irq_cycle2,
         opc_ack      => opc_ack,
         rdn          => rdn,
         rw_ack       => rw_ack,
         rw_cycle     => rw_cycle,
         rw_cycle2    => rw_cycle2,
         wr_mdbus     => wr_mdbus,
         wrn          => wrn,
         wrq          => wrq
      );
   U_2 : newbiushift
      GENERIC MAP (
         en8086 => EN8086
      )
      PORT MAP (
         bus8       => bus8,
         turbo186   => turbo186,
         clk        => clk,
         dbus_in    => dbus_in,
         dbusdp_out => dbusdp_out,
         flush_ack  => flush_ack_internal,
         irq_ack    => irq_ack,
         irq_cycle2 => irq_cycle2,
         irq_type   => irq_type,
         mux_addr   => mux_addr,
         mux_data   => mux_data,
         mux_reg    => mux_reg,
         nbreq      => nbreq,
         opc_ack    => opc_ack,
         reset      => reset,
         rw_cycle   => rw_cycle,
         rw_cycle2  => rw_cycle2,
         word       => word,
         wr_mdbus   => wr_mdbus,
         wrq        => wrq,
         abus       => abus,
         dbus_out   => dbus_out,
         instr      => instr,
         lutbus     => lutbus,
         mdbus_out  => mdbus_out,
         qs         => qs,
         regcnt     => regcnt,
         regnbok    => regnbok,
         csbus      => csbus,
         ipbus      => ipbus
      );

   -- Implicit buffered output assignments
   flush_ack <= flush_ack_internal;
   irq_req   <= irq_req_internal;

END rtl;
