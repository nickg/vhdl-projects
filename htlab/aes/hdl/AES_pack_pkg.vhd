-------------------------------------------------------------------------------
--                                                                           --
--  AES86 - VHDL 128bits AES IP Core                                         --
--                                                                           --
--  AES86 is released as open-source under the GNU GPL license. This means   --
--  that designs based on AES86 must be distributed in full source code      --
--  under the same license.                                                  --
--                                                                           --
-------------------------------------------------------------------------------
--                                                                           --
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
-- VHDL Package Header AES_lib.AES_pack
--
-- Created: by - Hans 22/05/2005
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE AES_pack IS

-- ***********************************************************************************
-- signals (constants) use in the testbench "write_dma_cycle" procedure
-- ***********************************************************************************
signal WR_FRAME_TRIGGER : integer := 17;            -- Write 1 extra byte to trigger the process
signal WR_FRAME         : integer := 16;            -- Used for IV register write

-- ***********************************************************************************
-- Set Encrypt/Decrypt bit depending on which address is written to
-- 000-xxxx Write data for Encryption
-- 001-xxxx Trigger Encryption
-- 010-xxxx Write data for decryption
-- 011-xxxx Trigger Decryption
-- 100-xxxx Write data for Key Expand
-- 101-xxxx Trigger Key Expand
-- 110-xxxx Write to IV register (CBC mode only)
-- 111-xxxx Write to Control register
-- 111-xxxx Read from Status register
-- ***********************************************************************************
signal WR_ENC_ADDR      : std_logic_vector(6 downto 0):= "0000000";     -- Encrypt address
signal WR_DEC_ADDR      : std_logic_vector(6 downto 0):= "0100000";     -- Write data for decryption
signal WR_KEY_ADDR      : std_logic_vector(6 downto 0):= "1000000";     -- Write data for Key Expand
signal WR_IV_ADDR       : std_logic_vector(6 downto 0):= "1100000";     -- Write to IV register (CBC mode only)
signal WR_CTRL_ADDR     : std_logic_vector(6 downto 0):= "1110000";     -- Write to Control register
signal RD_STATUS_ADDR   : std_logic_vector(6 downto 0):= "1110000";     -- Read from Status register
signal RD_OUT_ADDR      : std_logic_vector(6 downto 0):= "0000000";     -- Read Output/Result Register


-- pragma synthesis_off
function std_to_hex(Vec : std_logic_vector) return string;

type array_vector is array(0 to 1) of std_logic_vector(127 downto 0); 
type array_int is array(0 to 1) of integer range 0 to 399; 

-- The first vector contains the correct results for 2 interations. The second vectors contains the results
-- for the full 400 iterations. The used vector is controlled by the FULL_TEST generic (1=full test, 0=shortened)

constant TEST_ITERATIONS: array_int :=(1,399);          -- 2 and 400 interations    

-- ECB Encrypt Test Results
constant TEST1_RESULTS: array_vector:=(X"0AC15A9AFBB24D54AD99E987208272E2",X"A04377ABE259B0D0B5BA2D40A501971B"); -- 2, 400 iterations

-- ECB Decrypt Test Results
constant TEST2_RESULTS: array_vector:=(X"E3FD51123B48A2E2AB1DB29894202222",X"F5BF8B37136F2E1F6BEC6F572021E3BA"); -- 2, 400 iterations

-- CBC Encrypt Test Results
constant TEST3_RESULTS: array_vector:=(X"192D9B3AA10BB2F7846CCBA0085C657A",X"2F844CBF78EBA70DA7A49601388F1AB6"); -- 2, 400 iterations

-- CBC Decrypt Test Results
constant TEST4_RESULTS: array_vector:=(X"F5372F9735C5685F1DA362AF6ECB2940",X"9B8FB71E035CEFF9CBFA1346E5ACEFE0"); -- 2, 400 iterations

-- pragma synthesis_on                


END AES_pack;
