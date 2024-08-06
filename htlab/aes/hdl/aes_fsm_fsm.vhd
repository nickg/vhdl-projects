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
-- VHDL Architecture AES_Web_lib.AES_fsm.interface
--
-- Created: by - Hans 22/05/2005
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY AES_fsm IS
   PORT( 
      clk          : IN     std_logic;
      key_done     : IN     std_logic;
      ld_data      : IN     std_logic;
      resetn       : IN     std_logic;
      busy         : OUT    std_logic;
      clr_temp     : OUT    std_logic;
      data_valid   : OUT    std_logic;
      key_addr     : OUT    std_logic_vector (3 DOWNTO 0);
      key_addr_mux : OUT    std_logic;
      ld           : OUT    std_logic;
      ld_din       : OUT    std_logic;
      sel          : OUT    std_logic_vector (3 DOWNTO 0);
      sel_dmux     : OUT    std_logic;
      sel_ft_fs    : OUT    std_logic;
      sel_imux     : OUT    std_logic
   );

-- Declarations

END AES_fsm ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.STD_LOGIC_UNSIGNED.all;
 
ARCHITECTURE fsm OF AES_fsm IS

   TYPE STATE_TYPE IS (
      s0,
      s1,
      LDKEY,
      sx,
      s2,
      XORRK,
      s4,
      s3,
      s5,
      s6,
      DVALID,
      s8
   );
 
   -- State vector declaration
   ATTRIBUTE state_vector : string;
   ATTRIBUTE state_vector OF fsm : ARCHITECTURE IS "current_state";

   -- Declare current and next state signals
   SIGNAL current_state : STATE_TYPE;
   SIGNAL next_state : STATE_TYPE;

   -- Declare any pre-registered internal signals
   SIGNAL key_addr_cld : std_logic_vector (3 DOWNTO 0);
   SIGNAL key_addr_mux_cld : std_logic ;
   SIGNAL sel_cld : std_logic_vector (3 DOWNTO 0);
   SIGNAL sel_ft_fs_cld : std_logic ;

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
         key_addr_cld <= (OTHERS => '0');
         key_addr_mux_cld <= '0';
         sel_cld <= (OTHERS => '0');
         sel_ft_fs_cld <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
         current_state <= next_state;

         -- Combined Actions
         CASE current_state IS
            WHEN s1 => 
               key_addr_mux_cld <= '1' ;
            WHEN LDKEY => 
               key_addr_cld <= key_addr_cld +'1';
            WHEN sx => 
               sel_cld <= sel_cld+'1';
            WHEN s2 => 
               sel_cld <= sel_cld +'1';
            WHEN XORRK => 
               key_addr_cld <= key_addr_cld +'1';
            WHEN s4 => 
               sel_ft_fs_cld<='1';
            WHEN s3 => 
               sel_cld <= sel_cld +'1';
            WHEN s5 => 
               sel_cld <= sel_cld +'1';
            WHEN DVALID => 
               key_addr_cld <= (others => '0');
               key_addr_mux_cld<='0';
               sel_cld <= (others =>'0');
               sel_ft_fs_cld<='0';
            WHEN OTHERS =>
               NULL;
         END CASE;
      END IF;
   END PROCESS clocked_proc;
 
   -----------------------------------------------------------------
   nextstate_proc : PROCESS ( 
      current_state,
      key_addr_cld,
      key_done,
      ld_data,
      sel_cld
   )
   -----------------------------------------------------------------
   BEGIN
      CASE current_state IS
         WHEN s0 => 
            IF ( key_done = '1'  AND  ld_data = '1' ) THEN 
               next_state <= s1;
            ELSE
               next_state <= s0;
            END IF;
         WHEN s1 => 
            next_state <= s8;
         WHEN LDKEY => 
            next_state <= sx;
         WHEN sx => 
            IF (sel_cld(1 downto 0)="10") THEN 
               next_state <= s2;
            ELSE
               next_state <= sx;
            END IF;
         WHEN s2 => 
            IF (sel_cld/="1111") THEN 
               next_state <= sx;
            ELSIF (sel_cld="1111") THEN 
               next_state <= XORRK;
            ELSE
               next_state <= s2;
            END IF;
         WHEN XORRK => 
            IF (key_addr_cld="1001") THEN 
               next_state <= s4;
            ELSIF (key_addr_cld/="1001") THEN 
               next_state <= sx;
            ELSE
               next_state <= XORRK;
            END IF;
         WHEN s4 => 
            next_state <= s3;
         WHEN s3 => 
            IF (sel_cld(1 downto 0)="10") THEN 
               next_state <= s5;
            ELSE
               next_state <= s3;
            END IF;
         WHEN s5 => 
            IF (sel_cld/="1111") THEN 
               next_state <= s3;
            ELSIF (sel_cld="1111") THEN 
               next_state <= s6;
            ELSE
               next_state <= s5;
            END IF;
         WHEN s6 => 
            next_state <= DVALID;
         WHEN DVALID => 
            IF (key_done='0') THEN 
               next_state <= s0;
            ELSIF (key_done='1' AND ld_data='1') THEN 
               next_state <= s1;
            ELSE
               next_state <= DVALID;
            END IF;
         WHEN s8 => 
            next_state <= LDKEY;
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
      clr_temp <= '0';
      data_valid <= '0';
      ld <= '0';
      ld_din <= '0';
      sel_dmux <= '0';
      sel_imux <= '0';

      -- Combined Actions
      CASE current_state IS
         WHEN s0 => 
            busy<='0';
         WHEN LDKEY => 
            ld<='1';
            ld_din<='1';
            clr_temp<='1';
         WHEN s2 => 
            ld <='1';
         WHEN XORRK => 
            sel_dmux <= '1' ;
            sel_imux <= '0' ;
            ld_din<='1';
         WHEN s5 => 
            ld <='1';
         WHEN s6 => 
            sel_dmux <= '1' ;
            sel_imux <= '0' ;
            ld_din<='1';
         WHEN DVALID => 
            data_valid <= '1';
            busy<='0';
         WHEN OTHERS =>
            NULL;
      END CASE;
   END PROCESS output_proc;
 
   -- Concurrent Statements
   -- Clocked output assignments
   key_addr <= key_addr_cld;
   key_addr_mux <= key_addr_mux_cld;
   sel <= sel_cld;
   sel_ft_fs <= sel_ft_fs_cld;
END fsm;
