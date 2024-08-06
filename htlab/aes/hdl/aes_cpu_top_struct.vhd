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
-- VHDL Architecture AES_Web_lib.AES_cpu_top.symbol
--
-- Created: by - Hans 22/05/2005
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY AES_cpu_top IS
   PORT( 
      addr   : IN     std_logic_vector (6 DOWNTO 0);
      clk    : IN     std_logic;
      csn    : IN     std_logic;
      rdn    : IN     std_logic;
      resetn : IN     std_logic;
      wen    : IN     std_logic;
      int    : OUT    std_logic;
      dbus   : INOUT  std_logic_vector (7 DOWNTO 0)
   );

-- Declarations

END AES_cpu_top ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

LIBRARY AES_Web_lib;

ARCHITECTURE struct OF AES_cpu_top IS

   -- Architecture declarations
   signal lutsel10:std_logic_vector(1 downto 0);

   -- Internal signal declarations
   SIGNAL busy         : std_logic;
   SIGNAL busy_data    : std_logic;
   SIGNAL busy_key     : std_logic;
   SIGNAL data_valid   : std_logic;
   SIGNAL din_core     : std_logic_vector(127 DOWNTO 0);
   SIGNAL dkey_done    : std_logic;
   SIGNAL dkey_out     : std_logic_vector(127 DOWNTO 0);
   SIGNAL dout4        : std_logic_vector(1 DOWNTO 0);
   SIGNAL dout_core    : std_logic_vector(127 DOWNTO 0);
   SIGNAL ekey_done    : std_logic;
   SIGNAL ekey_out     : std_logic_vector(127 DOWNTO 0);
   SIGNAL enc_dec      : std_logic;
   SIGNAL fsb_addr     : std_logic_vector(7 DOWNTO 0);
   SIGNAL fsbout       : std_logic_vector(7 DOWNTO 0);
   SIGNAL ftfs_addr    : std_logic_vector(7 DOWNTO 0);
   SIGNAL ftsel        : std_logic_vector(1 DOWNTO 0);
   SIGNAL key_addr     : std_logic_vector(3 DOWNTO 0);
   SIGNAL key_addr_mux : std_logic;
   SIGNAL kt_addr      : std_logic_vector(7 DOWNTO 0);
   SIGNAL ktsel        : std_logic_vector(1 DOWNTO 0);
   SIGNAL ld_data      : std_logic;
   SIGNAL ld_key       : std_logic;
   SIGNAL lut_addr     : std_logic_vector(7 DOWNTO 0);
   SIGNAL lut_out      : std_logic_vector(31 DOWNTO 0);
   SIGNAL lut_sel      : std_logic_vector(5 DOWNTO 0);
   SIGNAL sel_addr     : std_logic_vector(1 DOWNTO 0);
   SIGNAL sel_ft_fs    : std_logic;


   -- Component Declarations
   COMPONENT AES_encdec
   PORT (
      clk          : IN     std_logic ;
      din          : IN     std_logic_vector (127 DOWNTO 0);
      dkey_out     : IN     std_logic_vector (127 DOWNTO 0);
      ekey_out     : IN     std_logic_vector (127 DOWNTO 0);
      enc_dec      : IN     std_logic ;
      ftfs_out     : IN     std_logic_vector (31 DOWNTO 0);
      key_done     : IN     std_logic ;
      ld_data      : IN     std_logic ;
      resetn       : IN     std_logic ;
      busy         : OUT    std_logic ;
      data_valid   : OUT    std_logic ;
      dout         : OUT    std_logic_vector (127 DOWNTO 0);
      ftfs_addr    : OUT    std_logic_vector (7 DOWNTO 0);
      ftsel        : OUT    std_logic_vector (1 DOWNTO 0);
      key_addr     : OUT    std_logic_vector (3 DOWNTO 0);
      key_addr_mux : OUT    std_logic ;
      sel_ft_fs    : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT AES_io
   PORT (
      addr       : IN     std_logic_vector (6 DOWNTO 0);
      busy       : IN     std_logic;
      clk        : IN     std_logic;
      cs         : IN     std_logic;
      data_valid : IN     std_logic;
      dkey_done  : IN     std_logic;
      dout_core  : IN     std_logic_vector (127 DOWNTO 0);
      ekey_done  : IN     std_logic;
      rd         : IN     std_logic;
      resetn     : IN     std_logic;
      status65   : IN     std_logic_vector (1 DOWNTO 0);
      we         : IN     std_logic;
      din_core   : OUT    std_logic_vector (127 DOWNTO 0);
      enc_dec    : OUT    std_logic;
      int        : OUT    std_logic;
      ld_data    : OUT    std_logic;
      ld_key     : OUT    std_logic;
      dbus       : INOUT  std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT AES_keygen
   PORT (
      clk           : IN     std_logic ;
      dkey_addr     : IN     std_logic_vector (3 DOWNTO 0);
      dkey_addr_mux : IN     std_logic ;
      ekey_addr     : IN     std_logic_vector (3 DOWNTO 0);
      ekey_addr_mux : IN     std_logic ;
      fsbout        : IN     std_logic_vector (7 DOWNTO 0);
      key           : IN     std_logic_vector (127 DOWNTO 0);
      ktout         : IN     std_logic_vector (31 DOWNTO 0);
      ld_key        : IN     std_logic ;
      resetn        : IN     std_logic ;
      busy          : OUT    std_logic ;
      dkey_done     : OUT    std_logic ;
      dkey_out      : OUT    std_logic_vector (127 DOWNTO 0);
      ekey_done     : OUT    std_logic ;
      ekey_out      : OUT    std_logic_vector (127 DOWNTO 0);
      fsb_addr      : OUT    std_logic_vector (7 DOWNTO 0);
      kt_addr       : OUT    std_logic_vector (7 DOWNTO 0);
      ktsel         : OUT    std_logic_vector (1 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT AES_lut
   PORT (
      lut_addr : IN     std_logic_vector (7 DOWNTO 0);
      lut_sel  : IN     std_logic_vector (5 DOWNTO 0);
      lut_out  : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;

   -- Optional embedded configurations
   FOR ALL : AES_encdec USE ENTITY AES_Web_lib.AES_encdec;
   FOR ALL : AES_io USE ENTITY AES_Web_lib.AES_io;
   FOR ALL : AES_keygen USE ENTITY AES_Web_lib.AES_keygen;
   FOR ALL : AES_lut USE ENTITY AES_Web_lib.AES_lut;


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- eb1 1  
   process(fsb_addr, kt_addr, ftfs_addr, sel_addr)
   begin
       case sel_addr is
       when "00"   => lut_addr <= fsb_addr;
       when "01"   => lut_addr <= kt_addr;
       when others => lut_addr <= ftfs_addr;
       end case;
   end process;                                      

   -- HDL Embedded Text Block 2 eb2
   -- eb1 1   
   --key_valid <= ekey_done;   
   busy <= busy_key OR busy_data;                                      

   -- HDL Embedded Text Block 3 eb3
   -- eb1 1
   -- lut address select signal                                        
   sel_addr <= dkey_done & ekey_done;
   
   process (sel_addr,ktsel,ftsel)
        begin 
         case sel_addr is 
            when "00"    => lutsel10 <= "00";
            when "01"    => lutsel10 <= ktsel;
            when others => lutsel10 <= ftsel;
         end case;
   end process;  
   
   lut_sel<= sel_addr & enc_dec & sel_ft_fs & lutsel10;


   -- ModuleWare code(v1.5) for instance 'I9' of 'constval'
   dout4 <= "10";

   -- ModuleWare code(v1.5) for instance 'I6' of 'tap'
   fsbout <= lut_out(7 DOWNTO 0);

   -- Instance port mappings.
   I1 : AES_encdec
      PORT MAP (
         clk          => clk,
         din          => din_core,
         dkey_out     => dkey_out,
         ekey_out     => ekey_out,
         enc_dec      => enc_dec,
         ftfs_out     => lut_out,
         key_done     => dkey_done,
         ld_data      => ld_data,
         resetn       => resetn,
         busy         => busy_data,
         data_valid   => data_valid,
         dout         => dout_core,
         ftfs_addr    => ftfs_addr,
         ftsel        => ftsel,
         key_addr     => key_addr,
         key_addr_mux => key_addr_mux,
         sel_ft_fs    => sel_ft_fs
      );
   I8 : AES_io
      PORT MAP (
         clk        => clk,
         resetn     => resetn,
         dbus       => dbus,
         addr       => addr,
         we         => wen,
         rd         => rdn,
         cs         => csn,
         int        => int,
         dout_core  => dout_core,
         din_core   => din_core,
         ld_data    => ld_data,
         ld_key     => ld_key,
         enc_dec    => enc_dec,
         busy       => busy,
         data_valid => data_valid,
         dkey_done  => dkey_done,
         ekey_done  => ekey_done,
         status65   => dout4
      );
   I0 : AES_keygen
      PORT MAP (
         clk           => clk,
         dkey_addr     => key_addr,
         dkey_addr_mux => key_addr_mux,
         ekey_addr     => key_addr,
         ekey_addr_mux => key_addr_mux,
         fsbout        => fsbout,
         key           => din_core,
         ktout         => lut_out,
         ld_key        => ld_key,
         resetn        => resetn,
         busy          => busy_key,
         dkey_done     => dkey_done,
         dkey_out      => dkey_out,
         ekey_done     => ekey_done,
         ekey_out      => ekey_out,
         fsb_addr      => fsb_addr,
         kt_addr       => kt_addr,
         ktsel         => ktsel
      );
   I2 : AES_lut
      PORT MAP (
         lut_addr => lut_addr,
         lut_sel  => lut_sel,
         lut_out  => lut_out
      );

END struct;
