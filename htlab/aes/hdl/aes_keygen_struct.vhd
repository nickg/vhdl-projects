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
-- VHDL Architecture AES_Web_lib.AES_keygen.symbol
--
-- Created: by - Hans 22/05/2005
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY AES_keygen IS
   PORT( 
      clk           : IN     std_logic;
      dkey_addr     : IN     std_logic_vector (3 DOWNTO 0);
      dkey_addr_mux : IN     std_logic;
      ekey_addr     : IN     std_logic_vector (3 DOWNTO 0);
      ekey_addr_mux : IN     std_logic;
      fsbout        : IN     std_logic_vector (7 DOWNTO 0);
      key           : IN     std_logic_vector (127 DOWNTO 0);
      ktout         : IN     std_logic_vector (31 DOWNTO 0);
      ld_key        : IN     std_logic;
      resetn        : IN     std_logic;
      busy          : OUT    std_logic;
      dkey_done     : OUT    std_logic;
      dkey_out      : OUT    std_logic_vector (127 DOWNTO 0);
      ekey_done     : OUT    std_logic;
      ekey_out      : OUT    std_logic_vector (127 DOWNTO 0);
      fsb_addr      : OUT    std_logic_vector (7 DOWNTO 0);
      kt_addr       : OUT    std_logic_vector (7 DOWNTO 0);
      ktsel         : OUT    std_logic_vector (1 DOWNTO 0)
   );

-- Declarations

END AES_keygen ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

LIBRARY AES_Web_lib;

ARCHITECTURE struct OF AES_keygen IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL dkey_mux    : std_logic;
   SIGNAL key_inp_mux : std_logic;
   SIGNAL ld          : std_logic;
   SIGNAL ld_rk3      : std_logic;
   SIGNAL ldd         : std_logic;
   SIGNAL round_daddr : std_logic_vector(3 DOWNTO 0);
   SIGNAL round_dkey  : std_logic_vector(127 DOWNTO 0);
   SIGNAL round_eaddr : std_logic_vector(3 DOWNTO 0);
   SIGNAL round_ekey  : std_logic_vector(127 DOWNTO 0);
   SIGNAL sel_rk3     : std_logic_vector(1 DOWNTO 0);
   SIGNAL sel_sk      : std_logic_vector(3 DOWNTO 0);
   SIGNAL wr_dmem     : std_logic;

   -- Implicit buffer signal declarations
   SIGNAL ekey_out_internal : std_logic_vector (127 DOWNTO 0);


   -- Component Declarations
   COMPONENT dkeylogic
   PORT (
      clk        : IN     std_logic ;
      dkey_mux   : IN     std_logic ;
      ekey_out   : IN     std_logic_vector (127 DOWNTO 0);
      ktout      : IN     std_logic_vector (31 DOWNTO 0);
      ldd        : IN     std_logic ;
      resetn     : IN     std_logic ;
      sel_sk     : IN     std_logic_vector (3 DOWNTO 0);
      wr_dmem    : IN     std_logic ;
      kt_addr    : OUT    std_logic_vector (7 DOWNTO 0);
      ktsel      : OUT    std_logic_vector (1 DOWNTO 0);
      round_dkey : OUT    std_logic_vector (127 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT ekeyfsm
   PORT (
      clk         : IN     std_logic ;
      ld_key      : IN     std_logic ;
      resetn      : IN     std_logic ;
      busy        : OUT    std_logic ;
      dkey_done   : OUT    std_logic ;
      dkey_mux    : OUT    std_logic ;
      ekey_done   : OUT    std_logic ;
      key_inp_mux : OUT    std_logic ;
      ld          : OUT    std_logic ;
      ld_rk3      : OUT    std_logic ;
      ldd         : OUT    std_logic ;
      round_daddr : OUT    std_logic_vector (3 DOWNTO 0);
      round_eaddr : OUT    std_logic_vector (3 DOWNTO 0);
      sel_rk3     : OUT    std_logic_vector (1 DOWNTO 0);
      sel_sk      : OUT    std_logic_vector (3 DOWNTO 0);
      wr_dmem     : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT ekeylogic
   PORT (
      clk         : IN     std_logic ;
      fsbout      : IN     std_logic_vector (7 DOWNTO 0);
      key         : IN     std_logic_vector (127 DOWNTO 0);
      key_inp_mux : IN     std_logic ;
      ld          : IN     std_logic ;
      ld_rk3      : IN     std_logic ;
      resetn      : IN     std_logic ;
      round_eaddr : IN     std_logic_vector (3 DOWNTO 0);
      sel_rk3     : IN     std_logic_vector (1 DOWNTO 0);
      fsb_addr    : OUT    std_logic_vector (7 DOWNTO 0);
      round_ekey  : OUT    std_logic_vector (127 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT keymem
   PORT (
      addrmux  : IN     std_logic ;
      addrmux0 : IN     std_logic_vector (3 DOWNTO 0);
      addrmux1 : IN     std_logic_vector (3 DOWNTO 0);
      clk      : IN     std_logic ;
      din128   : IN     std_logic_vector (127 DOWNTO 0);
      we       : IN     std_logic ;
      dout128  : OUT    std_logic_vector (127 DOWNTO 0)
   );
   END COMPONENT;

   -- Optional embedded configurations
   FOR ALL : dkeylogic USE ENTITY AES_Web_lib.dkeylogic;
   FOR ALL : ekeyfsm USE ENTITY AES_Web_lib.ekeyfsm;
   FOR ALL : ekeylogic USE ENTITY AES_Web_lib.ekeylogic;
   FOR ALL : keymem USE ENTITY AES_Web_lib.keymem;


BEGIN

   -- Instance port mappings.
   DLOGIC : dkeylogic
      PORT MAP (
         clk        => clk,
         dkey_mux   => dkey_mux,
         ekey_out   => ekey_out_internal,
         ktout      => ktout,
         ldd        => ldd,
         resetn     => resetn,
         sel_sk     => sel_sk,
         wr_dmem    => wr_dmem,
         kt_addr    => kt_addr,
         ktsel      => ktsel,
         round_dkey => round_dkey
      );
   FSM : ekeyfsm
      PORT MAP (
         clk         => clk,
         ld_key      => ld_key,
         resetn      => resetn,
         busy        => busy,
         dkey_done   => dkey_done,
         dkey_mux    => dkey_mux,
         ekey_done   => ekey_done,
         key_inp_mux => key_inp_mux,
         ld          => ld,
         ld_rk3      => ld_rk3,
         ldd         => ldd,
         round_daddr => round_daddr,
         round_eaddr => round_eaddr,
         sel_rk3     => sel_rk3,
         sel_sk      => sel_sk,
         wr_dmem     => wr_dmem
      );
   ELOGIC : ekeylogic
      PORT MAP (
         clk         => clk,
         fsbout      => fsbout,
         key         => key,
         key_inp_mux => key_inp_mux,
         ld          => ld,
         ld_rk3      => ld_rk3,
         resetn      => resetn,
         round_eaddr => round_eaddr,
         sel_rk3     => sel_rk3,
         fsb_addr    => fsb_addr,
         round_ekey  => round_ekey
      );
   DMEM : keymem
      PORT MAP (
         addrmux  => dkey_addr_mux,
         addrmux0 => round_daddr,
         addrmux1 => dkey_addr,
         clk      => clk,
         din128   => round_dkey,
         we       => wr_dmem,
         dout128  => dkey_out
      );
   EMEM : keymem
      PORT MAP (
         addrmux  => ekey_addr_mux,
         addrmux0 => round_eaddr,
         addrmux1 => ekey_addr,
         clk      => clk,
         din128   => round_ekey,
         we       => ld,
         dout128  => ekey_out_internal
      );

   -- Implicit buffered output assignments
   ekey_out <= ekey_out_internal;

END struct;
