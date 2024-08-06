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
-- VHDL Architecture AES_Web_lib.AES_encdec.symbol
--
-- Created: by - Hans 22/05/2005
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY AES_encdec IS
   PORT( 
      clk          : IN     std_logic;
      din          : IN     std_logic_vector (127 DOWNTO 0);
      dkey_out     : IN     std_logic_vector (127 DOWNTO 0);
      ekey_out     : IN     std_logic_vector (127 DOWNTO 0);
      enc_dec      : IN     std_logic;
      ftfs_out     : IN     std_logic_vector (31 DOWNTO 0);
      key_done     : IN     std_logic;
      ld_data      : IN     std_logic;
      resetn       : IN     std_logic;
      busy         : OUT    std_logic;
      data_valid   : OUT    std_logic;
      dout         : OUT    std_logic_vector (127 DOWNTO 0);
      ftfs_addr    : OUT    std_logic_vector (7 DOWNTO 0);
      ftsel        : OUT    std_logic_vector (1 DOWNTO 0);
      key_addr     : OUT    std_logic_vector (3 DOWNTO 0);
      key_addr_mux : OUT    std_logic;
      sel_ft_fs    : OUT    std_logic
   );

-- Declarations

END AES_encdec ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

LIBRARY AES_Web_lib;

ARCHITECTURE struct OF AES_encdec IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL clr_temp : std_logic;
   SIGNAL ld       : std_logic;
   SIGNAL ld_din   : std_logic;
   SIGNAL sel      : std_logic_vector(3 DOWNTO 0);
   SIGNAL sel_dmux : std_logic;
   SIGNAL sel_imux : std_logic;


   -- Component Declarations
   COMPONENT AES_fsm
   PORT (
      clk          : IN     std_logic ;
      key_done     : IN     std_logic ;
      ld_data      : IN     std_logic ;
      resetn       : IN     std_logic ;
      busy         : OUT    std_logic ;
      clr_temp     : OUT    std_logic ;
      data_valid   : OUT    std_logic ;
      key_addr     : OUT    std_logic_vector (3 DOWNTO 0);
      key_addr_mux : OUT    std_logic ;
      ld           : OUT    std_logic ;
      ld_din       : OUT    std_logic ;
      sel          : OUT    std_logic_vector (3 DOWNTO 0);
      sel_dmux     : OUT    std_logic ;
      sel_ft_fs    : OUT    std_logic ;
      sel_imux     : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT AES_logic
   PORT (
      clk       : IN     std_logic ;
      clr_temp  : IN     std_logic ;
      din       : IN     std_logic_vector (127 DOWNTO 0);
      dkey_out  : IN     std_logic_vector (127 DOWNTO 0);
      ekey_out  : IN     std_logic_vector (127 DOWNTO 0);
      enc_dec   : IN     std_logic ;
      ftfs_out  : IN     std_logic_vector (31 DOWNTO 0);
      ld        : IN     std_logic ;
      ld_din    : IN     std_logic ;
      resetn    : IN     std_logic ;
      sel       : IN     std_logic_vector (3 DOWNTO 0);
      sel_dmux  : IN     std_logic ;
      sel_imux  : IN     std_logic ;
      dout      : OUT    std_logic_vector (127 DOWNTO 0);
      ftfs_addr : OUT    std_logic_vector (7 DOWNTO 0);
      ftsel     : OUT    std_logic_vector (1 DOWNTO 0)
   );
   END COMPONENT;

   -- Optional embedded configurations
   FOR ALL : AES_fsm USE ENTITY AES_Web_lib.AES_fsm;
   FOR ALL : AES_logic USE ENTITY AES_Web_lib.AES_logic;


BEGIN

   -- Instance port mappings.
   I1 : AES_fsm
      PORT MAP (
         clk          => clk,
         key_done     => key_done,
         ld_data      => ld_data,
         resetn       => resetn,
         busy         => busy,
         clr_temp     => clr_temp,
         data_valid   => data_valid,
         key_addr     => key_addr,
         key_addr_mux => key_addr_mux,
         ld           => ld,
         ld_din       => ld_din,
         sel          => sel,
         sel_dmux     => sel_dmux,
         sel_ft_fs    => sel_ft_fs,
         sel_imux     => sel_imux
      );
   I0 : AES_logic
      PORT MAP (
         clk       => clk,
         clr_temp  => clr_temp,
         din       => din,
         dkey_out  => dkey_out,
         ekey_out  => ekey_out,
         enc_dec   => enc_dec,
         ftfs_out  => ftfs_out,
         ld        => ld,
         ld_din    => ld_din,
         resetn    => resetn,
         sel       => sel,
         sel_dmux  => sel_dmux,
         sel_imux  => sel_imux,
         dout      => dout,
         ftfs_addr => ftfs_addr,
         ftsel     => ftsel
      );

END struct;
