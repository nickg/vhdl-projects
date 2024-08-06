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
-- VHDL Architecture AES_lib.dkeylogic.rtl
--
-- Created: by - Hans 22/05/2005
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY dkeylogic IS
   PORT( 
      clk        : IN     std_logic;
      dkey_mux   : IN     std_logic;
      ekey_out   : IN     std_logic_vector (127 DOWNTO 0);
      ktout      : IN     std_logic_vector (31 DOWNTO 0);
      ldd        : IN     std_logic;
      resetn     : IN     std_logic;
      sel_sk     : IN     std_logic_vector (3 DOWNTO 0);
      wr_dmem    : IN     std_logic;
      kt_addr    : OUT    std_logic_vector (7 DOWNTO 0);
      ktsel      : OUT    std_logic_vector (1 DOWNTO 0);
      round_dkey : OUT    std_logic_vector (127 DOWNTO 0)
   );

-- Declarations

END dkeylogic ;

ARCHITECTURE rtl OF dkeylogic IS

signal  round_dkey_s: std_logic_vector(127 downto 0);       -- 128 skey output re-ordered

signal  skeyreg_s   : std_logic_vector(127 downto 0);       -- 128 skey register
signal  outmux_s    : std_logic_vector(31 downto 0);        -- Output key mux
signal  temp_s      : std_logic_vector(31 downto 0);        -- 32 bits XOR temp register

BEGIN
    
----------------------------------------------------------------------------
-- Output Result KEY Register
----------------------------------------------------------------------------
process (clk, resetn)
    begin 
        if resetn='0' then
            skeyreg_s <= (others => '0');
        elsif rising_edge(clk) then
            if (ldd='1') then  
                case sel_sk(3 downto 2) is 
                    when "00"   => skeyreg_s <= outmux_s & skeyreg_s(95 downto 0);         
                    when "01"   => skeyreg_s <= skeyreg_s(127 downto 96) & outmux_s & skeyreg_s(63 downto 0);
                    when "10"   => skeyreg_s <= skeyreg_s(127 downto 64) & outmux_s & skeyreg_s(31 downto 0);
                    when others => skeyreg_s <= skeyreg_s(127 downto 32) & outmux_s;
                end case;
            end if; 
        end if; 
end process;  

-- Correct re-order swap LSW with MSB
-- Write output, first and last byte use ekey_out (just copy)
round_dkey_s <= ekey_out when dkey_mux='1' else skeyreg_s;
round_dkey <= round_dkey_s;


----------------------------------------------------------------------------
-- XOR chain
----------------------------------------------------------------------------
outmux_s <= ktout XOR temp_s;


----------------------------------------------------------------------------
-- Temp XOR Register
----------------------------------------------------------------------------
process (clk, resetn)
    begin 
        if resetn='0' then
            temp_s <= (others => '0');
        elsif rising_edge(clk) then
            if (wr_dmem='1') then
                temp_s <= (others => '0');
            elsif (sel_sk(1 downto 0)="00") then
                temp_s <= ktout;
            else
                temp_s <= outmux_s;
            end if; 
        end if; 
        
end process;  


process (sel_sk,ekey_out)
    begin
        case sel_sk is 
            when "0000" => kt_addr <= ekey_out(127 downto 120);        
            when "0001" => kt_addr <= ekey_out(119 downto 112);        
            when "0010" => kt_addr <= ekey_out(111 downto 104);
            when "0011" => kt_addr <= ekey_out(103 downto 96);
            when "0100" => kt_addr <= ekey_out(95 downto 88);          
            when "0101" => kt_addr <= ekey_out(87 downto 80);          
            when "0110" => kt_addr <= ekey_out(79 downto 72);
            when "0111" => kt_addr <= ekey_out(71 downto 64);          
            when "1000" => kt_addr <= ekey_out(63 downto 56);
            when "1001" => kt_addr <= ekey_out(55 downto 48);
            when "1010" => kt_addr <= ekey_out(47 downto 40);
            when "1011" => kt_addr <= ekey_out(39 downto 32);          
            when "1100" => kt_addr <= ekey_out(31 downto 24);
            when "1101" => kt_addr <= ekey_out(23 downto 16);
            when "1110" => kt_addr <= ekey_out(15 downto 8);                
            when others => kt_addr <= ekey_out(7 downto 0);
        end case;    
end process;

ktsel <= sel_sk(1 downto 0);

END ARCHITECTURE rtl;
