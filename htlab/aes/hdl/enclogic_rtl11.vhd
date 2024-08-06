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

ENTITY AES_logic IS
   PORT( 
      clk       : IN     std_logic;
      clr_temp  : IN     std_logic;
      din       : IN     std_logic_vector (127 DOWNTO 0);
      dkey_out  : IN     std_logic_vector (127 DOWNTO 0);
      ekey_out  : IN     std_logic_vector (127 DOWNTO 0);
      enc_dec   : IN     std_logic;
      ftfs_out  : IN     std_logic_vector (31 DOWNTO 0);
      ld        : IN     std_logic;
      ld_din    : IN     std_logic;
      resetn    : IN     std_logic;
      sel       : IN     std_logic_vector (3 DOWNTO 0);
      sel_dmux  : IN     std_logic;
      sel_imux  : IN     std_logic;
      dout      : OUT    std_logic_vector (127 DOWNTO 0);
      ftfs_addr : OUT    std_logic_vector (7 DOWNTO 0);
      ftsel     : OUT    std_logic_vector (1 DOWNTO 0)
   );

-- Declarations

END AES_logic ;

--
ARCHITECTURE rtl OF AES_logic IS

signal  din_s           : std_logic_vector(127 downto 0);   -- re-ordered input vector

signal  imux_s          : std_logic_vector(127 downto 0);   -- output from input mux
signal  dmux_s          : std_logic_vector(127 downto 0);   -- output from data mux
signal  xorkey_s        : std_logic_vector(127 downto 0);   -- output from input key and dmux_s

signal  inputreg_s      : std_logic_vector(127 downto 0);   -- Input Register
signal  resultreg_s     : std_logic_vector(127 downto 0);   -- Result/Accu Register

signal  xorout_s        : std_logic_vector(31 downto 0);    -- Output XOR & temp_s

signal  temp_s          : std_logic_vector(31 downto 0);    -- Temp XOR result register
signal  sel_dec_s       : std_logic_vector(3 downto 0);     -- Byte select for decode
signal  sel_s           : std_logic_vector(3 downto 0);     -- Byte select signal
 

BEGIN

-- Change byte ordering before processing  
din_s   <= din;
ftsel   <= sel(1 downto 0);

dmux_s  <= din_s when sel_dmux='0' else resultreg_s;
xorkey_s<= (ekey_out XOR dmux_s) when enc_dec='0' else (dkey_out XOR dmux_s); 
imux_s  <= xorkey_s when sel_imux='0' else resultreg_s;

----------------------------------------------------------------------------
-- Input Register
----------------------------------------------------------------------------
process (clk, resetn)
    begin 
        if resetn='0' then
            inputreg_s <= (others => '0');
        elsif rising_edge(clk) then
            if (ld_din='1') then  
                inputreg_s <= imux_s;
            end if; 
        end if; 
end process;  

-- Change byte ordering before connecting to outside world  
dout <= inputreg_s;

----------------------------------------------------------------------------
-- Temp XOR Register
----------------------------------------------------------------------------
process (clk, resetn)
    begin 
        if resetn='0' then
            temp_s <= (others => '0');
        elsif rising_edge(clk) then
            if (clr_temp='1') then
                temp_s <= (others => '0');
            elsif (sel(1 downto 0)="00") then
                temp_s <= ftfs_out;
            else
                temp_s <= xorout_s;
            end if; 
        end if; 
end process;  

----------------------------------------------------------------------------
-- Result/Accu Register
----------------------------------------------------------------------------
--ldsel_s <= ld_din&sel(3 downto 2);                            -- combine Load Datain signal and word select

process (clk, resetn)
    begin 
        if resetn='0' then
            resultreg_s <= (others => '0');
        elsif rising_edge(clk) then
            if (ld='1') then  
                case sel(3 downto 2) is 
                    when "11"   => resultreg_s <= resultreg_s(127 downto 32) & xorout_s; 
                    when "10"   => resultreg_s <= resultreg_s(127 downto 64) & xorout_s & resultreg_s(31 downto 0);
                    when "01"   => resultreg_s <= resultreg_s(127 downto 96) & xorout_s & resultreg_s(63 downto 0);
                    when others => resultreg_s <= xorout_s & resultreg_s(95 downto 0);
                end case;
            end if; 
        end if; 
end process;  


xorout_s <= ftfs_out XOR temp_s;

-- Decode Translation table, translate encode byte select to decode byte select
process (sel)
    begin
        case sel is 
            when "0000" => sel_dec_s <= "0000"; -- 
            when "0001" => sel_dec_s <= "1001"; -- 
            when "0010" => sel_dec_s <= "0010"; --
            when "0011" => sel_dec_s <= "1011"; -- 
            when "0100" => sel_dec_s <= "0100"; -- 
            when "0101" => sel_dec_s <= "1101"; --         
            when "0110" => sel_dec_s <= "0110"; -- 
            when "0111" => sel_dec_s <= "1111"; -- 
            when "1000" => sel_dec_s <= "1000"; --  
            when "1001" => sel_dec_s <= "0001"; --  
            when "1010" => sel_dec_s <= "1010"; --  
            when "1011" => sel_dec_s <= "0011"; --  
            when "1100" => sel_dec_s <= "1100"; --     
            when "1101" => sel_dec_s <= "0101"; -- 
            when "1110" => sel_dec_s <= "1110"; -- 
            when others => sel_dec_s <= "0111"; --   
        end case;    
end process;

sel_s <= sel when enc_dec='0' else sel_dec_s;

-- Byte Select Register
process (sel_s,inputreg_s)
    begin
        case sel_s is 
            when "0000" => ftfs_addr <= inputreg_s(127 downto 120); --15        
            when "0001" => ftfs_addr <= inputreg_s(87 downto 80);   --10        
            when "0010" => ftfs_addr <= inputreg_s(47 downto 40);   --5     
            when "0011" => ftfs_addr <= inputreg_s(7 downto 0);     --0         
            when "0100" => ftfs_addr <= inputreg_s(95 downto 88);   --11        
            when "0101" => ftfs_addr <= inputreg_s(55 downto 48);   --6                                                                        
            when "0110" => ftfs_addr <= inputreg_s(15 downto 8);    --1     
            when "0111" => ftfs_addr <= inputreg_s(103 downto 96);  --12                                                        
            when "1000" => ftfs_addr <= inputreg_s(63 downto 56);   --7                                                            
            when "1001" => ftfs_addr <= inputreg_s(23 downto 16);   --2            
            when "1010" => ftfs_addr <= inputreg_s(111 downto 104); --13                                                                
            when "1011" => ftfs_addr <= inputreg_s(71 downto 64);   --8                
            when "1100" => ftfs_addr <= inputreg_s(31 downto 24);   --3                                                                
            when "1101" => ftfs_addr <= inputreg_s(119 downto 112); --14                                                        
            when "1110" => ftfs_addr <= inputreg_s(79 downto 72);   --9                                                     
            when others => ftfs_addr <= inputreg_s(39 downto 32);   --4                                                      
                               
        end case;    
end process;

END ARCHITECTURE rtl;
