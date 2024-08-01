-------------------------------------------------------------------------------
--  HTL80186 - CPU core                                                      --
--  Copyright (C) 2002-2017 HT-LAB                                           --
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
-- Module        : cpu186                                                    --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 1.0  05/21/02   Created HT-LAB                            --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY I80186;
USE I80186.cpu86instr.ALL;
USE I80186.cpu86pack.ALL;

ENTITY cpu186 IS
   PORT( 
      clk        : IN     std_logic;
      dbus_in    : IN     std_logic_vector (15 DOWNTO 0);
      hold       : IN     std_logic;
      intr       : IN     std_logic;
      nmi        : IN     std_logic;
      por        : IN     std_logic;
      ready      : IN     std_logic;
      test       : IN     std_logic;
      turbo186   : IN     std_logic;
      abus       : OUT    std_logic_vector (23 DOWNTO 0);
      ale        : OUT    std_logic;
      bhe        : OUT    std_logic;
      dbus_out   : OUT    std_logic_vector (15 DOWNTO 0);
      hlda       : OUT    std_logic;
      inta       : OUT    std_logic;
      iret       : OUT    std_logic;                       -- ver 1.4, IRET being executed
      lock       : OUT    std_logic;
      proc_error : OUT    std_logic;
      qs         : OUT    std_logic_vector (1 DOWNTO 0);
      rdn        : OUT    std_logic;
      resoutn    : OUT    std_logic;
      s          : OUT    std_logic_vector (6 DOWNTO 0);
      wrn        : OUT    std_logic
   );

-- Declarations

END cpu186 ;



LIBRARY I80186;

ARCHITECTURE rtl OF cpu186 IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL bound_error  : std_logic;
   SIGNAL clrop        : std_logic;
   SIGNAL dbusdp_out   : std_logic_vector(15 DOWNTO 0);
   SIGNAL decode_state : std_logic;
   SIGNAL divide_error : std_logic;
   SIGNAL dout         : std_logic;
   SIGNAL eabus        : std_logic_vector(15 DOWNTO 0);
   SIGNAL esc_error    : std_logic;
   SIGNAL flush_ack    : std_logic;
   SIGNAL flush_coming : std_logic;
   SIGNAL flush_req    : std_logic;
   SIGNAL halt_opc     : std_logic;                        -- Asserted when HLT instruction executed
   SIGNAL instr        : instruction_type;
   SIGNAL irq_block    : std_logic;
   SIGNAL irq_req      : std_logic;
   SIGNAL mdbus_out    : std_logic_vector(15 DOWNTO 0);
   SIGNAL memio        : std_logic;
   SIGNAL opc_req      : std_logic;
   SIGNAL path         : path_in_type;
   SIGNAL read_req     : std_logic;
   SIGNAL reset        : std_logic;
   SIGNAL rw_ack       : std_logic;
   SIGNAL segbus       : std_logic_vector(15 DOWNTO 0);
   SIGNAL status       : status_out_type;
   SIGNAL step_enable  : std_logic;
   SIGNAL step_pulse   : std_logic;
   SIGNAL valid_opc    : std_logic;
   SIGNAL word         : std_logic;
   SIGNAL write_req    : std_logic;
   SIGNAL wrpath       : write_in_type;

   -- Implicit buffer signal declarations
   SIGNAL proc_error_internal : std_logic;


   -- Component Declarations
   COMPONENT datapath
   PORT (
      clk        : IN     std_logic ;
      clrop      : IN     std_logic ;
      instr      : IN     instruction_type ;
      mdbus_in   : IN     std_logic_vector (15 DOWNTO 0);
      memio      : IN     std_logic ;
      path       : IN     path_in_type ;
      reset      : IN     std_logic ;
      wrpath     : IN     write_in_type ;
      dbusdp_out : OUT    std_logic_vector (15 DOWNTO 0);
      eabus      : OUT    std_logic_vector (15 DOWNTO 0);
      segbus     : OUT    std_logic_vector (15 DOWNTO 0);
      status     : OUT    status_out_type 
   );
   END COMPONENT;
   COMPONENT newbiu
   GENERIC (
      EN8086 : integer := 0      --Set to 1 for 8086
   );
   PORT (
      bound_error  : IN     std_logic ;
      bus8         : IN     std_logic ;
      clk          : IN     std_logic ;
      csbus        : IN     std_logic_vector (15 DOWNTO 0);
      dbus_in      : IN     std_logic_vector (15 DOWNTO 0);
      dbusdp_out   : IN     std_logic_vector (15 DOWNTO 0);
      decode_state : IN     std_logic ;
      divide_error : IN     std_logic ;
      esc_error    : IN     std_logic ;
      flush_coming : IN     std_logic ;
      flush_req    : IN     std_logic ;
      halt         : IN     std_logic ;
      hold         : IN     std_logic ;
      intr         : IN     std_logic ;
      ipbus        : IN     std_logic_vector (15 DOWNTO 0);
      irq_block    : IN     std_logic ;
      memio        : IN     std_logic ;
      nmi          : IN     std_logic ;
      opc_req      : IN     std_logic ;
      proc_error   : IN     std_logic ;
      read_req     : IN     std_logic ;
      ready        : IN     std_logic ;
      reset        : IN     std_logic ;
      status       : IN     status_out_type ;
      turbo186     : IN     std_logic ;
      word         : IN     std_logic ;
      write_req    : IN     std_logic ;
      abus         : OUT    std_logic_vector (23 DOWNTO 0);
      ale          : OUT    std_logic ;
      bhe          : OUT    std_logic ;
      dbus_out     : OUT    std_logic_vector (15 DOWNTO 0);
      flush_ack    : OUT    std_logic ;
      hlda         : OUT    std_logic ;
      instr        : OUT    instruction_type ;
      inta         : OUT    std_logic ;
      irq_req      : OUT    std_logic ;
      mdbus_out    : OUT    std_logic_vector (15 DOWNTO 0);
      qs           : OUT    std_logic_vector (1 DOWNTO 0);
      rdn          : OUT    std_logic ;
      rw_ack       : OUT    std_logic ;
      s            : OUT    std_logic_vector (6 DOWNTO 0);
      valid_opc    : OUT    std_logic ;
      wrn          : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT proc
   GENERIC (
      EN8086 : INTEGER := 0
   );
   PORT (
      clk          : IN     std_logic ;
      flush_ack    : IN     std_logic ;
      instr        : IN     instruction_type ;
      irq_req      : IN     std_logic ;
      reset        : IN     std_logic ;
      rw_ack       : IN     std_logic ;
      status       : IN     status_out_type ;
      step_enable  : IN     std_logic ;
      step_pulse   : IN     std_logic ;
      test         : IN     std_logic ;
      valid_opc    : IN     std_logic ;
      iret_opc     : OUT    std_logic ;      -- ver 1.4, IRET being executed
      halt_opc     : OUT    std_logic ;      -- Asserted when HLT instruction executed
      bound_error  : OUT    std_logic ;
      esc_error    : OUT    std_logic ;
      clrop        : OUT    std_logic ;
      decode_state : OUT    std_logic ;
      divide_error : OUT    std_logic ;
      flush_coming : OUT    std_logic ;
      flush_req    : OUT    std_logic ;
      memio        : OUT    std_logic ;      -- Mem/~IO cycle
      irq_block    : OUT    std_logic ;
      lock         : OUT    std_logic ;
      opc_req      : OUT    std_logic ;
      path         : OUT    path_in_type ;
      proc_error   : OUT    std_logic ;
      read_req     : OUT    std_logic ;
      word         : OUT    std_logic ;
      write_req    : OUT    std_logic ;
      wrpath       : OUT    write_in_type 
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : datapath USE ENTITY I80186.datapath;
   FOR ALL : newbiu USE ENTITY I80186.newbiu;
   FOR ALL : proc USE ENTITY I80186.proc;
   -- pragma synthesis_on


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 2 RES
   -- synchronous reset
   -- Internal use active high, external use active low
   -- Async Asserted, sync negated
   process (clk, por)     
      begin
         if por='1' then
              reset <= '1';
            resoutn <= '0';
         elsif rising_edge(clk) then
              reset <= '0';
            resoutn <= '1';
        end if;         
   end process;

   -- HDL Embedded Text Block 3 Copyright
   -- Copyright 3 
   -- pragma translate_off
   process
      begin
         wait until falling_edge (reset);   
         report "********** HTL80186 ver 1.6";
         report "********** Copyright (c) 2003-2017 HT Lab WWW.HT-LAB.COM";
         wait; 
      end process;
   -- pragma translate_on


   -- ModuleWare code(v1.9) for instance 'I0' of 'gnd'
   dout <= '0';

   -- Instance port mappings.
   CPUDPATH : datapath
      PORT MAP (
         clk        => clk,
         clrop      => clrop,
         instr      => instr,
         mdbus_in   => mdbus_out,
         memio      => memio,
         path       => path,
         reset      => reset,
         wrpath     => wrpath,
         dbusdp_out => dbusdp_out,
         eabus      => eabus,
         segbus     => segbus,
         status     => status
      );
   CPUBIU : newbiu
      GENERIC MAP (
         EN8086 => 0         --Set to 1 for 8086
      )
      PORT MAP (
         bound_error  => bound_error,
         bus8         => dout,
         clk          => clk,
         csbus        => segbus,
         dbus_in      => dbus_in,
         dbusdp_out   => dbusdp_out,
         decode_state => decode_state,
         divide_error => divide_error,
         esc_error    => esc_error,
         flush_coming => flush_coming,
         flush_req    => flush_req,
         halt         => halt_opc,
         hold         => hold,
         intr         => intr,
         ipbus        => eabus,
         irq_block    => irq_block,
         memio        => memio,
         nmi          => nmi,
         opc_req      => opc_req,
         proc_error   => proc_error_internal,
         read_req     => read_req,
         ready        => ready,
         reset        => reset,
         status       => status,
         turbo186     => turbo186,
         word         => word,
         write_req    => write_req,
         abus         => abus,
         ale          => ale,
         bhe          => bhe,
         dbus_out     => dbus_out,
         flush_ack    => flush_ack,
         hlda         => hlda,
         instr        => instr,
         inta         => inta,
         irq_req      => irq_req,
         mdbus_out    => mdbus_out,
         qs           => qs,
         rdn          => rdn,
         rw_ack       => rw_ack,
         s            => s,
         valid_opc    => valid_opc,
         wrn          => wrn
      );
   CPUPROC : proc
      GENERIC MAP (
         EN8086 => 0
      )
      PORT MAP (
         clk          => clk,
         flush_ack    => flush_ack,
         instr        => instr,
         irq_req      => irq_req,
         reset        => reset,
         rw_ack       => rw_ack,
         status       => status,
         step_enable  => step_enable,
         step_pulse   => step_pulse,
         test         => test,
         valid_opc    => valid_opc,
         iret_opc     => iret,
         halt_opc     => halt_opc,
         bound_error  => bound_error,
         esc_error    => esc_error,
         clrop        => clrop,
         decode_state => decode_state,
         divide_error => divide_error,
         flush_coming => flush_coming,
         flush_req    => flush_req,
         memio        => memio,
         irq_block    => irq_block,
         lock         => lock,
         opc_req      => opc_req,
         path         => path,
         proc_error   => proc_error_internal,
         read_req     => read_req,
         word         => word,
         write_req    => write_req,
         wrpath       => wrpath
      );

   -- Implicit buffered output assignments
   proc_error <= proc_error_internal;

END rtl;
