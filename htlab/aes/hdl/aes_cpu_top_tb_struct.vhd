-------------------------------------------------------------------------------
--                                                                           --
--  AES86 - VHDL 128bits AES IP Core                                         --
--                                                                           --
--  AES86 is released as open-source under the GNU GPL license. This means   --
--  that designs based on AES86 must be distributed in full source code      --
--  under the same license.                                                  --
--                                                                           --
-------------------------------------------------------------------------------
--																			 --
--  This library is free software; you can redistribute it and/or            --
--  modify it under the terms of the GNU Lesser General Public               --
--  License as published by the Free Software Foundation; either             --
--  version 2.1 of the License, or (at your option) any later version.       --
--                                                                           --
--  This library is distributed in the hope that it will be useful,          --
--  but WITHOUT ANY WARRANTY; without even the implied warranty of           --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        --
--  Lesser General Public License for more details.                          --
--                                                                           --
--  Full details of the license can be found in the file "copying.txt".      --
--                                                                           --
--  You should have received a copy of the GNU Lesser General Public         --
--  License along with this library; if not, write to the Free Software      --
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA  --
--                                                                           --
-------------------------------------------------------------------------------
--
-- VHDL Architecture AES_Web_lib.AES_cpu_top_tb.symbol
--
-- Created: by - Hans 23/05/2005
-------------------------------------------------------------------------------


ENTITY AES_cpu_top_tb IS
-- Declarations

END AES_cpu_top_tb ;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
LIBRARY std;
USE std.TEXTIO.ALL;
LIBRARY AES_WEB_LIB;
USE AES_WEB_LIB.AES_pack.ALL;
-- LIBRARY modelsim_lib;
-- USE modelsim_lib.util.ALL;

LIBRARY AES_Web_lib;

ARCHITECTURE struct OF AES_cpu_top_tb IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL addr   : std_logic_vector(6 DOWNTO 0);
   SIGNAL clk    : std_logic;
   SIGNAL csn    : std_logic;
   SIGNAL dbus   : std_logic_vector(7 DOWNTO 0);
   SIGNAL int    : std_logic;
   SIGNAL rdn    : std_logic;
   SIGNAL resetn : std_logic;
   SIGNAL wen    : std_logic;


   -- ModuleWare signal declarations(v1.5) for instance 'I2' of 'clk'
   SIGNAL mw_I2clk : std_logic;

   -- ModuleWare signal declarations(v1.5) for instance 'I3' of 'pulse'
   SIGNAL mw_I3pulse : std_logic :='0';

   -- Component Declarations
   COMPONENT AES_cpu_top
   PORT (
      addr   : IN     std_logic_vector (6 DOWNTO 0);
      clk    : IN     std_logic ;
      csn    : IN     std_logic ;
      rdn    : IN     std_logic ;
      resetn : IN     std_logic ;
      wen    : IN     std_logic ;
      int    : OUT    std_logic ;
      dbus   : INOUT  std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT AES_cpu_top_tester
   GENERIC (
      FULL_TEST : integer                      := 1;
      TESTS     : std_logic_vector(3 downto 0) := "1000"
   );
   PORT (
      clk    : IN     std_logic ;
      int    : IN     std_logic ;
      resetn : IN     std_logic ;
      addr   : OUT    std_logic_vector (6 DOWNTO 0);
      csn    : OUT    std_logic ;
      rdn    : OUT    std_logic ;
      wen    : OUT    std_logic ;
      dbus   : INOUT  std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;

   -- Optional embedded configurations
   FOR ALL : AES_cpu_top USE ENTITY AES_Web_lib.AES_cpu_top;
   FOR ALL : AES_cpu_top_tester USE ENTITY AES_Web_lib.AES_cpu_top_tester;


BEGIN

   -- ModuleWare code(v1.5) for instance 'I2' of 'clk'
   i2clk_proc: PROCESS
   BEGIN
      LOOP
         mw_I2clk <= '0', '1' AFTER 50 ns;
         WAIT FOR 100 ns;
      END LOOP;
      WAIT;
   END PROCESS i2clk_proc;
   clk <= mw_I2clk;

   -- ModuleWare code(v1.5) for instance 'I3' of 'pulse'
   resetn <= mw_I3pulse;
   i3pulse_proc: PROCESS
   BEGIN
      WAIT FOR 55 ns;
      mw_I3pulse <= 
         '0',
         '1' AFTER 120 ns;
      WAIT;
    END PROCESS i3pulse_proc;

   -- Instance port mappings.
   I0 : AES_cpu_top
      PORT MAP (
         addr   => addr,
         clk    => clk,
         csn    => csn,
         rdn    => rdn,
         resetn => resetn,
         wen    => wen,
         int    => int,
         dbus   => dbus
      );
   I1 : AES_cpu_top_tester
      GENERIC MAP (
         FULL_TEST => 1,
         TESTS     => "1000"
      )
      PORT MAP (
         clk    => clk,
         int    => int,
         resetn => resetn,
         addr   => addr,
         csn    => csn,
         rdn    => rdn,
         wen    => wen,
         dbus   => dbus
      );

END struct;
