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
-- VHDL Architecture AES_Web_lib.ekeyfsm.interface
--
-- Created: by - Hans 22/05/2005
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY ekeyfsm IS
   PORT( 
      clk         : IN     std_logic;
      ld_key      : IN     std_logic;
      resetn      : IN     std_logic;
      busy        : OUT    std_logic;
      dkey_done   : OUT    std_logic;
      dkey_mux    : OUT    std_logic;
      ekey_done   : OUT    std_logic;
      key_inp_mux : OUT    std_logic;
      ld          : OUT    std_logic;
      ld_rk3      : OUT    std_logic;
      ldd         : OUT    std_logic;
      round_daddr : OUT    std_logic_vector (3 DOWNTO 0);
      round_eaddr : OUT    std_logic_vector (3 DOWNTO 0);
      sel_rk3     : OUT    std_logic_vector (1 DOWNTO 0);
      sel_sk      : OUT    std_logic_vector (3 DOWNTO 0);
      wr_dmem     : OUT    std_logic
   );

-- Declarations

END ekeyfsm ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.STD_LOGIC_UNSIGNED.all;
 
ARCHITECTURE fsm OF ekeyfsm IS

   TYPE STATE_TYPE IS (
      s0,
      s1,
      s2,
      s3,
      s4,
      s5,
      WR0,
      s6,
      s7,
      s8,
      s10,
      s11,
      RD10,
      RD9,
      RDx
   );
 
   -- State vector declaration
   ATTRIBUTE state_vector : string;
   ATTRIBUTE state_vector OF fsm : ARCHITECTURE IS "current_state";

   -- Declare current and next state signals
   SIGNAL current_state : STATE_TYPE;
   SIGNAL next_state : STATE_TYPE;

   -- Declare any pre-registered internal signals
   SIGNAL ekey_done_cld : std_logic ;
   SIGNAL round_daddr_cld : std_logic_vector (3 DOWNTO 0);
   SIGNAL round_eaddr_cld : std_logic_vector (3 DOWNTO 0);
   SIGNAL sel_rk3_cld : std_logic_vector (1 DOWNTO 0);
   SIGNAL sel_sk_cld : std_logic_vector (3 DOWNTO 0);

BEGIN

   -----------------------------------------------------------------
   clocked_proc : PROCESS ( 
      clk,
      resetn
   )
   -----------------------------------------------------------------
   BEGIN
      IF (resetn = '0') THEN
         current_state <= s0;
         -- Default Reset Values
         ekey_done_cld <= '0';
         round_daddr_cld <= (OTHERS => '0');
         round_eaddr_cld <= (OTHERS => '0');
         sel_rk3_cld <= (OTHERS => '0');
         sel_sk_cld <= (OTHERS => '0');
      ELSIF (clk'EVENT AND clk = '1') THEN
         current_state <= next_state;

         -- Combined Actions
         CASE current_state IS
            WHEN s0 => 
               ekey_done_cld <= '0';
            WHEN s1 => 
               round_eaddr_cld <= round_eaddr_cld + '1';
            WHEN s2 => 
               sel_rk3_cld <= sel_rk3_cld + '1';
            WHEN s4 => 
               if (round_eaddr_cld/="1010") then round_eaddr_cld <= round_eaddr_cld + '1'; end if;
            WHEN s5 => 
               ekey_done_cld <= '1' ; 
            WHEN WR0 => 
               round_daddr_cld <= round_daddr_cld + '1';
               round_eaddr_cld<="1001";
            WHEN s6 => 
               sel_sk_cld <= sel_sk_cld + '1';
            WHEN s7 => 
               sel_sk_cld <= sel_sk_cld + '1';
            WHEN s8 => 
               round_daddr_cld <= round_daddr_cld + '1';
               round_eaddr_cld <= round_eaddr_cld - '1';
            WHEN s11 => 
               round_daddr_cld <= (others => '0');
               round_eaddr_cld <= (others => '0');
               sel_rk3_cld <= (others => '0');
               sel_sk_cld <= (others => '0');
            WHEN OTHERS =>
               NULL;
         END CASE;
      END IF;
   END PROCESS clocked_proc;
 
   -----------------------------------------------------------------
   nextstate_proc : PROCESS ( 
      current_state,
      ld_key,
      round_daddr_cld,
      round_eaddr_cld,
      sel_rk3_cld,
      sel_sk_cld
   )
   -----------------------------------------------------------------
   BEGIN
      CASE current_state IS
         WHEN s0 => 
            IF ( ld_key = '1' ) THEN 
               next_state <= s1;
            ELSE
               next_state <= s0;
            END IF;
         WHEN s1 => 
            next_state <= s2;
         WHEN s2 => 
            IF (sel_rk3_cld/="11") THEN 
               next_state <= s3;
            ELSIF (sel_rk3_cld="11") THEN 
               next_state <= s4;
            ELSE
               next_state <= s2;
            END IF;
         WHEN s3 => 
            next_state <= s2;
         WHEN s4 => 
            IF (round_eaddr_cld="1010") THEN 
               next_state <= s5;
            ELSIF (round_eaddr_cld /= "1010") THEN 
               next_state <= s2;
            ELSE
               next_state <= s4;
            END IF;
         WHEN s5 => 
            next_state <= RD10;
         WHEN WR0 => 
            next_state <= RD9;
         WHEN s6 => 
            IF (sel_sk_cld(1 downto 0) = "10") THEN 
               next_state <= s7;
            ELSE
               next_state <= s6;
            END IF;
         WHEN s7 => 
            IF (sel_sk_cld/="1111") THEN 
               next_state <= s6;
            ELSIF (sel_sk_cld="1111") THEN 
               next_state <= s8;
            ELSE
               next_state <= s7;
            END IF;
         WHEN s8 => 
            next_state <= RDx;
         WHEN s10 => 
            next_state <= s11;
         WHEN s11 => 
            IF (ld_key='1') THEN 
               next_state <= s0;
            ELSE
               next_state <= s11;
            END IF;
         WHEN RD10 => 
            next_state <= WR0;
         WHEN RD9 => 
            next_state <= s6;
         WHEN RDx => 
            IF (round_daddr_cld /= "1010") THEN 
               next_state <= s6;
            ELSIF (round_daddr_cld = "1010") THEN 
               next_state <= s10;
            ELSE
               next_state <= RDx;
            END IF;
         WHEN OTHERS =>
            next_state <= s0;
      END CASE;
   END PROCESS nextstate_proc;
 
   -----------------------------------------------------------------
   output_proc : PROCESS ( 
      current_state
   )
   -----------------------------------------------------------------
   BEGIN
      -- Default Assignment
      busy <= '1';
      dkey_done <= '0';
      dkey_mux <= '0';
      key_inp_mux <= '1';
      ld <= '0';
      ld_rk3 <= '0';
      ldd <= '0';
      wr_dmem <= '0';

      -- Combined Actions
      CASE current_state IS
         WHEN s0 => 
            key_inp_mux<='0';
            busy<='0';
         WHEN s1 => 
            ld <= '1' ; 
            key_inp_mux<='0';
         WHEN s2 => 
            ld_rk3 <= '1' ;
         WHEN s4 => 
            ld<='1';
         WHEN WR0 => 
            dkey_mux <= '1';
            wr_dmem<= '1';
         WHEN s7 => 
            ldd <= '1';
         WHEN s8 => 
            wr_dmem<= '1';
         WHEN s10 => 
            wr_dmem<='1';
            dkey_mux<='1';
         WHEN s11 => 
            dkey_done<='1';
            busy<='0';
         WHEN OTHERS =>
            NULL;
      END CASE;
   END PROCESS output_proc;
 
   -- Concurrent Statements
   -- Clocked output assignments
   ekey_done <= ekey_done_cld;
   round_daddr <= round_daddr_cld;
   round_eaddr <= round_eaddr_cld;
   sel_rk3 <= sel_rk3_cld;
   sel_sk <= sel_sk_cld;
END fsm;
