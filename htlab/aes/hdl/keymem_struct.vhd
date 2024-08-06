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
-- VHDL Architecture AES_Web_lib.keymem.symbol
--
-- Created: by - Hans 22/05/2005
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY keymem IS
   PORT( 
      addrmux  : IN     std_logic;
      addrmux0 : IN     std_logic_vector (3 DOWNTO 0);
      addrmux1 : IN     std_logic_vector (3 DOWNTO 0);
      clk      : IN     std_logic;
      din128   : IN     std_logic_vector (127 DOWNTO 0);
      we       : IN     std_logic;
      dout128  : OUT    std_logic_vector (127 DOWNTO 0)
   );

-- Declarations

END keymem ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ARCHITECTURE struct OF keymem IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL dout  : std_logic_vector(3 DOWNTO 0);
   SIGNAL dout0 : std_logic_vector(63 DOWNTO 0);
   SIGNAL dout1 : std_logic_vector(63 DOWNTO 0);
   SIGNAL dout2 : std_logic_vector(63 DOWNTO 0);
   SIGNAL dout3 : std_logic_vector(63 DOWNTO 0);


   -- ModuleWare signal declarations(v1.5) for instance 'I0' of 'ramsp'
   TYPE MW_I0RAM_TYPE IS ARRAY (((2**4) -1) DOWNTO 0) OF std_logic_vector(63 DOWNTO 0);
   SIGNAL mw_I0ram_table : MW_I0RAM_TYPE := (OTHERS => "0000000000000000000000000000000000000000000000000000000000000000");
   SIGNAL mw_I0addr_reg: std_logic_vector(3 DOWNTO 0);

   -- ModuleWare signal declarations(v1.5) for instance 'I4' of 'ramsp'
   TYPE MW_I4RAM_TYPE IS ARRAY (((2**4) -1) DOWNTO 0) OF std_logic_vector(63 DOWNTO 0);
   SIGNAL mw_I4ram_table : MW_I4RAM_TYPE := (OTHERS => "0000000000000000000000000000000000000000000000000000000000000000");
   SIGNAL mw_I4addr_reg: std_logic_vector(3 DOWNTO 0);

   -- ModuleWare signal declarations(v1.5) for instance 'I2' of 'split'
   SIGNAL mw_I2temp_din : std_logic_vector(127 DOWNTO 0);


BEGIN

   -- ModuleWare code(v1.5) for instance 'I3' of 'merge'
   dout128 <= dout2 & dout1;

   -- ModuleWare code(v1.5) for instance 'I1' of 'mux'
   i1combo_proc: PROCESS(addrmux0, addrmux1, addrmux)
   BEGIN
      CASE addrmux IS
      WHEN '0'|'L' => dout <= addrmux0;
      WHEN '1'|'H' => dout <= addrmux1;
      WHEN OTHERS => dout <= (OTHERS => 'X');
      END CASE;
   END PROCESS i1combo_proc;

   -- ModuleWare code(v1.5) for instance 'I0' of 'ramsp'
   --attribute block_ram : boolean;
   --attribute block_ram of mem : signal is false;
   i0ram_p_proc: PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk='1') THEN
         IF (we = '1' OR we = 'H') THEN
            mw_I0ram_table(CONV_INTEGER(unsigned(dout))) <= dout3;
         END IF;
         mw_I0addr_reg <= dout;
      END IF;
   END PROCESS i0ram_p_proc;
   dout2 <= mw_I0ram_table(CONV_INTEGER(unsigned(mw_I0addr_reg)));

   -- ModuleWare code(v1.5) for instance 'I4' of 'ramsp'
   --attribute block_ram : boolean;
   --attribute block_ram of mem : signal is false;
   i4ram_p_proc: PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk='1') THEN
         IF (we = '1' OR we = 'H') THEN
            mw_I4ram_table(CONV_INTEGER(unsigned(dout))) <= dout0;
         END IF;
         mw_I4addr_reg <= dout;
      END IF;
   END PROCESS i4ram_p_proc;
   dout1 <= mw_I4ram_table(CONV_INTEGER(unsigned(mw_I4addr_reg)));

   -- ModuleWare code(v1.5) for instance 'I2' of 'split'
   mw_I2temp_din <= din128;
   i2combo_proc: PROCESS (mw_I2temp_din)
   VARIABLE itemp: std_logic_vector(127 DOWNTO 0);
   BEGIN
      itemp := mw_I2temp_din(127 DOWNTO 0);
      dout0 <= itemp(63 DOWNTO 0);
      dout3 <= itemp(127 DOWNTO 64);
   END PROCESS i2combo_proc;

   -- Instance port mappings.

END struct;
