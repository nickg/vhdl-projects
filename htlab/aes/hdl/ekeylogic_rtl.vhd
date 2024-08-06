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
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY ekeylogic IS
   PORT( 
      clk         : IN     std_logic;
      fsbout      : IN     std_logic_vector (7 DOWNTO 0);
      key         : IN     std_logic_vector (127 DOWNTO 0);
      key_inp_mux : IN     std_logic;
      ld          : IN     std_logic;
      ld_rk3      : IN     std_logic;
      resetn      : IN     std_logic;
      round_eaddr : IN     std_logic_vector (3 DOWNTO 0);
      sel_rk3     : IN     std_logic_vector (1 DOWNTO 0);
      fsb_addr    : OUT    std_logic_vector (7 DOWNTO 0);
      round_ekey  : OUT    std_logic_vector (127 DOWNTO 0)
   );

-- Declarations

END ekeylogic ;


ARCHITECTURE rtl OF ekeylogic IS

signal  key_s       : std_logic_vector(127 downto 0);   -- Re-ordered input key 

signal  keyreg_s    : std_logic_vector(127 downto 0);   -- 128 key register
signal  keyinp_s    : std_logic_vector(127 downto 0);   -- Output key input mux
    
signal  rk3reg_s    : std_logic_vector(31 downto 0);    -- 32bits RK3 register

signal  rkx_s       : std_logic_vector(31 downto 0);    -- Output RK0 XOR RCON
signal  rk4_s       : std_logic_vector(31 downto 0);    -- 
signal  rk5_s       : std_logic_vector(31 downto 0);    -- 
signal  rk6_s       : std_logic_vector(31 downto 0);    -- 
signal  rk7_s       : std_logic_vector(31 downto 0);    -- 

signal  rcon_s      : std_logic_vector(31 downto 0);    -- Round LUT output

alias   rk0_s       : std_logic_vector(31 downto 0) is keyreg_s(31 downto 0);
alias   rk1_s       : std_logic_vector(31 downto 0) is keyreg_s(63 downto 32);
alias   rk2_s       : std_logic_vector(31 downto 0) is keyreg_s(95 downto 64);
alias   rk3_s       : std_logic_vector(31 downto 0) is keyreg_s(127 downto 96);

BEGIN
    
-- key    <= X"F7 95 BD 4A 52 E2 9E D7 13 D3 13 FA 20 E9 8D BC";  -- Input
-- key_s  <= X"20 E9 8D BC 13 D3 13 FA 52 E2 9E D7 F7 95 BD 4A";  -- Re-order for logic   
key_s <= key(31 downto 0) & key(63 downto 32) & key(95 downto 64) & key(127 downto 96);

keyinp_s    <= (rk7_s & rk6_s & rk5_s & rk4_s) when key_inp_mux='1' else key_s;

-- Correct re-order swap LSW with MSB
round_ekey  <= keyinp_s(31 downto 0) & keyinp_s(63 downto 32)&   
               keyinp_s(95 downto 64) & keyinp_s(127 downto 96); -- Write to memory
----------------------------------------------------------------------------
-- Input KEY Register
----------------------------------------------------------------------------
process (clk, resetn)
    begin 
        if resetn='0' then
            keyreg_s <= (others => '0');
        elsif rising_edge(clk) then
            if (ld='1') then  
                keyreg_s<= keyinp_s;                    -- Load new value
            end if; 
        end if; 
end process;  


----------------------------------------------------------------------------
-- RK3 Register
----------------------------------------------------------------------------
process (clk, resetn)
    begin 
        if resetn='0' then
            rk3reg_s <= (others => '0');
        elsif rising_edge(clk) then
            if (ld_rk3='1') then  
                case sel_rk3 is 
                    when "11"   => rk3reg_s <= rk3reg_s(31 downto 8) & fsbout;         
                    when "10"   => rk3reg_s <= rk3reg_s(31 downto 16) & fsbout & rk3reg_s(7 downto 0);
                    when "01"   => rk3reg_s <= rk3reg_s(31 downto 24) & fsbout & rk3reg_s(15 downto 0);
                    when others => rk3reg_s <= fsbout & rk3reg_s(23 downto 0);
                end case;
            else
              rk3reg_s <= rk3reg_s;
            end if; 
        end if; 
end process;  

----------------------------------------------------------------------------
-- XOR Chain
----------------------------------------------------------------------------
rkx_s <= rk0_s    XOR rcon_s;
rk4_s <= rk3reg_s XOR rkx_s;
rk5_s <= rk1_s XOR rk4_s;
rk6_s <= rk2_s XOR rk5_s;
rk7_s <= rk3_s XOR rk6_s;

-- Change byte order for FSb address
process (sel_rk3,rk3_s)
    begin
        case sel_rk3 is 
            when "00"   => fsb_addr <= rk3_s(23 downto 16);     -- 2           
            when "01"   => fsb_addr <= rk3_s(15 downto 8);      -- 1
            when "10"   => fsb_addr <= rk3_s(7 downto 0);       -- 0
            when others => fsb_addr <= rk3_s(31 downto 24);     -- 3
        end case;    
end process;

-- Rounding LUT
-- address+1 to correct for round_eaddr offset
process (round_eaddr)
    begin
        case round_eaddr is 
            when "0001" => rcon_s <= X"01000000";    -- round 0        
            when "0010" => rcon_s <= X"02000000";
            when "0011" => rcon_s <= X"04000000";
            when "0100" => rcon_s <= X"08000000";          
            when "0101" => rcon_s <= X"10000000";
            when "0110" => rcon_s <= X"20000000";
            when "0111" => rcon_s <= X"40000000";          
            when "1000" => rcon_s <= X"80000000";
            when "1001" => rcon_s <= X"1B000000";
            when others => rcon_s <= X"36000000";    -- round 9
        end case;    
end process;

END ARCHITECTURE rtl;
