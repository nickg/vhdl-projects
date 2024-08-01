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
-- Module        : formatter                                                    --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 1.0  05/21/02   Created HT-LAB                            --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY formatter IS
   PORT(
      lutbus   : IN     std_logic_vector (15 DOWNTO 0);
      mux_addr : OUT    std_logic_vector (2 DOWNTO 0);
      mux_data : OUT    std_logic_vector (3 DOWNTO 0);
      mux_reg  : OUT    std_logic_vector (2 DOWNTO 0);
      nbreq    : OUT    std_logic_vector (2 DOWNTO 0)
   );

-- Declarations

END formatter ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY I80186;

ARCHITECTURE rtl OF formatter IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL dout   : std_logic_vector(15 DOWNTO 0);
   SIGNAL dout4  : std_logic_vector(7 DOWNTO 0);
   SIGNAL dout5  : std_logic_vector(7 DOWNTO 0);
   SIGNAL muxout : std_logic_vector(7 DOWNTO 0);


   -- ModuleWare signal declarations(v1.9) for instance 'I0' of 'split'
   SIGNAL mw_I0temp_din : std_logic_vector(15 DOWNTO 0);

   -- Component Declarations
   COMPONENT a_table
   PORT (
      addr : IN     std_logic_vector (15 DOWNTO 0);
      dout : OUT    std_logic_vector (2 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT d_table
   PORT (
      addr : IN     std_logic_vector (15 DOWNTO 0);
      dout : OUT    std_logic_vector (3 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT m_table
   PORT (
      ireg   : IN     std_logic_vector (7 DOWNTO 0);
      modrrm : IN     std_logic_vector (7 DOWNTO 0);
      muxout : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT n_table
   PORT (
      addr : IN     std_logic_vector (15 DOWNTO 0);
      dout : OUT    std_logic_vector (2 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT r_table
   PORT (
      addr : IN     std_logic_vector (15 DOWNTO 0);
      dout : OUT    std_logic_vector (2 DOWNTO 0)
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : a_table USE ENTITY I80186.a_table;
   FOR ALL : d_table USE ENTITY I80186.d_table;
   FOR ALL : m_table USE ENTITY I80186.m_table;
   FOR ALL : n_table USE ENTITY I80186.n_table;
   FOR ALL : r_table USE ENTITY I80186.r_table;
   -- pragma synthesis_on


BEGIN

   -- ModuleWare code(v1.9) for instance 'I1' of 'merge'
   dout <= dout4 & muxout;

   -- ModuleWare code(v1.9) for instance 'I0' of 'split'
   mw_I0temp_din <= lutbus;
   i0combo_proc: PROCESS (mw_I0temp_din)
   VARIABLE temp_din: std_logic_vector(15 DOWNTO 0);
   BEGIN
      temp_din := mw_I0temp_din(15 DOWNTO 0);
      dout5 <= temp_din(7 DOWNTO 0);
      dout4 <= temp_din(15 DOWNTO 8);
   END PROCESS i0combo_proc;

   -- Instance port mappings.
   I2 : a_table
      PORT MAP (
         addr => dout,
         dout => mux_addr
      );
   I3 : d_table
      PORT MAP (
         addr => dout,
         dout => mux_data
      );
   I6 : m_table
      PORT MAP (
         ireg   => dout4,
         modrrm => dout5,
         muxout => muxout
      );
   I4 : n_table
      PORT MAP (
         addr => dout,
         dout => nbreq
      );
   I5 : r_table
      PORT MAP (
         addr => dout,
         dout => mux_reg
      );

END rtl;
