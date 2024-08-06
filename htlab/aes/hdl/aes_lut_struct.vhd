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
-- VHDL Architecture AES_Web_lib.AES_lut.symbol
--
-- Created: by - Hans 22/05/2005
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY AES_lut IS
   PORT( 
      lut_addr : IN     std_logic_vector (7 DOWNTO 0);
      lut_sel  : IN     std_logic_vector (5 DOWNTO 0);
      lut_out  : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END AES_lut ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

LIBRARY AES_Web_lib;

ARCHITECTURE struct OF AES_lut IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL fsbout      : std_logic_vector(7 DOWNTO 0);
   SIGNAL ftout       : std_logic_vector(31 DOWNTO 0);
   SIGNAL rsbout      : std_logic_vector(7 DOWNTO 0);
   SIGNAL rtaddr      : std_logic_vector(7 DOWNTO 0);
   SIGNAL rtout       : std_logic_vector(31 DOWNTO 0);
   SIGNAL sel_rt_addr : std_logic;


   -- Component Declarations
   COMPONENT FSb_table
   PORT (
      addr : IN     std_logic_vector (7 DOWNTO 0);
      dout : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FT_table
   PORT (
      addr : IN     std_logic_vector (7 DOWNTO 0);
      dout : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT RSb_table
   PORT (
      addr : IN     std_logic_vector (7 DOWNTO 0);
      dout : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT RT_table
   PORT (
      addr : IN     std_logic_vector (7 DOWNTO 0);
      dout : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;

   -- Optional embedded configurations
   FOR ALL : FSb_table USE ENTITY AES_Web_lib.FSb_table;
   FOR ALL : FT_table USE ENTITY AES_Web_lib.FT_table;
   FOR ALL : RSb_table USE ENTITY AES_Web_lib.RSb_table;
   FOR ALL : RT_table USE ENTITY AES_Web_lib.RT_table;


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- eb1 1
   --
   -- dkey_done ekey_done enc_dec
   --      0       0        *         Encrypt Key Expand, select FSB LUT
   --      0       1        *         Decrypt Key Expand, select RT(FSB) LUT
   --      1       0        *         illegal
   --      1       1        0/1       Encrypt/Decrypt key expand done, use enc_dec to select LUT
   --
   process (lut_sel, ftout, fsbout, rtout, rsbout)
      begin
         case lut_sel is
                                       -- Generate encrypt key     "00----"
            when "000000"  => lut_out <= X"000000" & fsbout;   -- address is fsb_addr (encrypt selected, lut_sel[2:0]=000)
            when "001000"  => lut_out <= X"000000" & fsbout;   -- address is fsb_addr (decrypt selected, lut_sel[2:0]=000)
   
   
                                                   -- Generate decrypt key, Change RT address multiplexer "01--.."
                                       -- lut_sel[2]=0, lut_sel[1:0]=ktsel
            when "010000"  => lut_out <= rtout;    -- 3 2 1 0, no byte swap, rtout is actually rt(fsbout)
            when "010001"  => lut_out <= rtout(7 downto 0) & rtout(31 downto 24) & rtout(23 downto 16) & rtout(15 downto 8);--0 3 2 1
            when "010010"  => lut_out <= rtout(15 downto 8) & rtout(7 downto 0) & rtout(31 downto 24) & rtout(23 downto 16);-- 1 0 3 2
            when "010011"  => lut_out <= rtout(23 downto 16) & rtout(15 downto 8) & rtout(7 downto 0) & rtout(31 downto 24);-- 2 1 0 3
                                       -- Same if decrypt is selected
            when "011000"  => lut_out <= rtout;    -- 3 2 1 0, no byte swap, rtout is actually rt(fsbout)
            when "011001"  => lut_out <= rtout(7 downto 0) & rtout(31 downto 24) & rtout(23 downto 16) & rtout(15 downto 8);--0 3 2 1
            when "011010"  => lut_out <= rtout(15 downto 8) & rtout(7 downto 0) & rtout(31 downto 24) & rtout(23 downto 16);-- 1 0 3 2
            when "011011"  => lut_out <= rtout(23 downto 16) & rtout(15 downto 8) & rtout(7 downto 0) & rtout(31 downto 24);-- 2 1 0 3
   
   
                                       -- Encrypt stage, lut_sel[2]=sel_ft_rt
                                       -- lut_sel[1:0]=select
            when "110000"  => lut_out <= ftout; -- 3 2 1 0, Encode, no byte swap
            when "110001"  => lut_out <= ftout(7 downto 0) & ftout(31 downto 24) & ftout(23 downto 16) & ftout(15 downto 8);--0 3 2 1
            when "110010"  => lut_out <= ftout(15 downto 8) & ftout(7 downto 0) & ftout(31 downto 24) & ftout(23 downto 16);-- 1 0 3 2
            when "110011"  => lut_out <= ftout(23 downto 16) & ftout(15 downto 8) & ftout(7 downto 0) & ftout(31 downto 24);-- 2 1 0 3
            when "110100"  => lut_out <= fsbout & X"000000"; 
            when "110101"  => lut_out <= X"00" & fsbout & X"0000";
            when "110110"  => lut_out <= X"0000" & fsbout & X"00";
            when "110111"  => lut_out <= X"000000" & fsbout;
                                       -- Decrypt stage, lut_sel[2]=sel_ft_rt
                                       -- lut_sel[1:0]=select
            when "111000"  => lut_out <= rtout; -- 3 2 1 0, Decode, no byte swap
            when "111001"  => lut_out <= rtout(7 downto 0) & rtout(31 downto 24) & rtout(23 downto 16) & rtout(15 downto 8);--0 3 2 1
            when "111010"  => lut_out <= rtout(15 downto 8) & rtout(7 downto 0) & rtout(31 downto 24) & rtout(23 downto 16);-- 1 0 3 2
            when "111011"  => lut_out <= rtout(23 downto 16) & rtout(15 downto 8) & rtout(7 downto 0) & rtout(31 downto 24);-- 2 1 0 3
            when "111100"  => lut_out <= rsbout & X"000000"; 
            when "111101"  => lut_out <= X"00" & rsbout & X"0000";
            when "111110"  => lut_out <= X"0000" & rsbout & X"00";
            when "111111"  => lut_out <= X"000000" & rsbout; 
   
            when others    => lut_out <= "--------------------------------";         
           end case;
   end process;                                    
                                        
   sel_rt_addr <= (NOT lut_sel(5)) AND lut_sel(4) ; -- connect to ekey_done/dkey_done   (only 1 when dkey processing)


   -- ModuleWare code(v1.5) for instance 'I2' of 'mux'
   i2combo_proc: PROCESS(lut_addr, fsbout, sel_rt_addr)
   BEGIN
      CASE sel_rt_addr IS
      WHEN '0'|'L' => rtaddr <= lut_addr;
      WHEN '1'|'H' => rtaddr <= fsbout;
      WHEN OTHERS => rtaddr <= (OTHERS => 'X');
      END CASE;
   END PROCESS i2combo_proc;

   -- Instance port mappings.
   I0 : FSb_table
      PORT MAP (
         addr => lut_addr,
         dout => fsbout
      );
   I4 : FT_table
      PORT MAP (
         addr => lut_addr,
         dout => ftout
      );
   I3 : RSb_table
      PORT MAP (
         addr => lut_addr,
         dout => rsbout
      );
   I1 : RT_table
      PORT MAP (
         addr => rtaddr,
         dout => rtout
      );

END struct;
