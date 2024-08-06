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
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity AES_io is
  port( clk         : in     std_logic;
        resetn      : in     std_logic;

        -- uProcessor Interface signals
        dbus        : inout  std_logic_vector(7 downto 0);
        addr        : in     std_logic_vector(6 downto 0);
        we          : in     std_logic;                 -- Active low Write Strobe
        rd          : in     std_logic;                 -- Active low Read Strobe
        cs          : in     std_logic;                 -- Active low chip select
        int         : out    std_logic;                 -- Active high Interrupt

        -- AES Core Interface Signals
        dout_core   : in     std_logic_vector(127 downto 0);  -- 128 bits output
        din_core    : out    std_logic_vector(127 downto 0);  -- 128 bits input
        ld_data     : out    std_logic;                 -- Active high Load Data
        ld_key      : out    std_logic;                 -- Active high Load Key
        enc_dec     : out    std_logic;                 -- Encrypt(0)/Decrypt(1) select
        busy        : in     std_logic;                 -- Active high Busy signal
        data_valid  : in     std_logic;                 -- Active high Data Valid signal
        dkey_done   : in     std_logic;                 -- Active high Encryption Key done signal
        ekey_done   : in     std_logic;                 -- Active high Decryption Key done signal
        status65    : in     std_logic_vector(1 downto 0)); -- 2 free status bits (7 downto 6)
end entity AES_io;

architecture rtl of AES_io is

signal input_reg    : std_logic_vector(127 downto 0);

signal din_s        : std_logic_vector(7 downto 0);
signal dout_s       : std_logic_vector(7 downto 0);
signal enc_dec_s    : std_logic;

signal dbusout_s    : std_logic_vector(7 downto 0);

signal status_reg   : std_logic_vector(7 downto 0);
signal control_reg  : std_logic_vector(4 downto 0);

signal int_s        : std_logic;                        -- Interrupt signal

signal we_s         : std_logic;                        -- Write strobe validated by CS signals
signal rd_s         : std_logic;                        -- Read strobe validated by CS signals


signal shift_data_s : std_logic_vector(2 downto 0);     -- Used to create 4 clock delay
signal shift_key_s  : std_logic_vector(2 downto 0);     -- Used to create 4 clock delay             
signal ld_data_s    : std_logic;
signal ld_key_s     : std_logic;
signal ldkeyp_s     : std_logic;
signal wr_data_s    : std_logic;                        -- write strobe Data/key register

signal iv_reg       : std_logic_vector(127 downto 0);   -- CBC mode
signal wr_iv_s      : std_logic;                        -- write strobe IV register pulse
signal output_reg   : std_logic_vector(127 downto 0);   -- CBC mode
signal ivxorin_s    : std_logic_vector(127 downto 0);   -- IV XOR input -> input_core
signal ivxorout_s   : std_logic_vector(127 downto 0);   -- IV XOR output_core -> output
signal data_valid_s : std_logic;                        -- data_valid pulse
signal dkey_done_s  : std_logic;                        -- dkey_done pulse
signal ekey_done_s  : std_logic;                        -- ekey_done pulse

signal ffa_s        : std_logic_vector(2 downto 0);     -- used for rising edge detect
signal ffb_s        : std_logic_vector(2 downto 0);     -- used for rising edge detect
signal tbit_s       : std_logic;                        -- toggle bit, changes to 1 after first write to IV

signal dout_core_s  : std_logic_vector(127 downto 0);   -- output from output mux.

constant dontcare   : std_logic_vector(4 downto 0):=(others => '-');

alias ecb_cbc       : std_logic is control_reg(4);      -- bit 4 controls the mode, default to ecb

begin

-- Read/Write strobes
we_s <= '0' when (we='0' AND cs='0') else '1';
rd_s <= '0' when (rd='0' AND cs='0') else '1';
 
wr_data_s <= '0' when (we_s='0' AND addr(6 downto 5)/="11") else '1';  -- Data and Key register
wr_iv_s   <= '0' when (we_s='0' AND addr(6 downto 4)="110") else '1';   -- IV register

dbusout_s <= status_reg when addr(6 downto 4)="111" else dout_s;

process (rd_s, dbusout_s)
    begin
        case rd_s is
            when '0'    =>  dbus <= dbusout_s;          -- Read from AES core 
            when others =>  dbus <= (others => 'Z');    -- Write to AES core
        end case;       
end process;

din_s <= dbus;                                          -- Write to AES core


----------------------------------------------------------------------------
-- Set Encrypt/Decrypt bit depending on which address is written to
--
-- 000-xxxx Write data for Encryption
-- 001-xxxx Trigger Encryption
--
-- 010-xxxx Write data for Decryption
-- 011-xxxx Trigger Decryption
--
-- 100-xxxx Write data for Key Expand
-- 101-xxxx Trigger Key Expand
--
-- 110-xxxx Write to IV register (CBC mode only)
--
-- 111-xxxx Write to Control register
-- 111-xxxx Read from Status register
----------------------------------------------------------------------------

-- ld_data and ld_key should be asserted for 4 clock cycles.

-- Trigger convert by writing to address 16..23
ld_data_s<='1' when (we_s='0' AND (addr(6 downto 4)="001" OR addr(6 downto 4)="011")) else '0';

-- Trigger key expand by writing to address 24..31
ldkeyp_s<='1' when (we_s='0' AND addr(6 downto 4)="101") else '0';
 
process (clk, resetn)
    begin 
        if resetn='0' then
            shift_data_s <= "000";
            shift_key_s  <= "000";                  
        elsif rising_edge(clk) then 
            shift_data_s <= shift_data_s(1 downto 0) & ld_data_s;
            shift_key_s  <= shift_key_s (1 downto 0) & ldkeyp_s;                                               
        end if; 
end process; 

ld_data <= ld_data_s OR shift_data_s(2) OR shift_data_s(1) OR shift_data_s(0);
ld_key_s<= ldkeyp_s  OR shift_key_s(2)  OR shift_key_s(1)  OR shift_key_s(0);
ld_key  <= ld_key_s;

-- enc_dec is decoded from the write address
process (clk, resetn)
    begin 
        if resetn='0' then
            enc_dec_s <= '0';                       -- defaults to encryption
        elsif rising_edge(clk) then                                                
            if (we_s='0') then
                if addr(6 downto 5)="00" then
                    enc_dec_s<='0';                 -- enable encryption
                elsif addr(6 downto 5)="01" then
                    enc_dec_s<='1';                 -- enable decryption
                end if;                               
            end if; 
        end if; 
end process; 

enc_dec <= enc_dec_s;                               -- Connect to AES core

----------------------------------------------------------------------------
-- input into the aes core, registered
----------------------------------------------------------------------------
process (clk, resetn)
    begin 
        if resetn='0' then
            input_reg <= (others => '0');
        elsif rising_edge(clk) then                                                
            if (wr_data_s='0') then  
                case addr(4 downto 0) is 
                    when "00000"  => input_reg <= input_reg(127 downto 8)  & din_s; 
                    when "00001"  => input_reg <= input_reg(127 downto 16) & din_s & input_reg(7  downto 0);
                    when "00010"  => input_reg <= input_reg(127 downto 24) & din_s & input_reg(15 downto 0); 
                    when "00011"  => input_reg <= input_reg(127 downto 32) & din_s & input_reg(23 downto 0); 
                        
                    when "00100"  => input_reg <= input_reg(127 downto 40) & din_s & input_reg(31 downto 0); 
                    when "00101"  => input_reg <= input_reg(127 downto 48) & din_s & input_reg(39 downto 0); 
                    when "00110"  => input_reg <= input_reg(127 downto 56) & din_s & input_reg(47 downto 0); 
                    when "00111"  => input_reg <= input_reg(127 downto 64) & din_s & input_reg(55 downto 0); 

                    when "01000"  => input_reg <= input_reg(127 downto 72) & din_s & input_reg(63 downto 0); 
                    when "01001"  => input_reg <= input_reg(127 downto 80) & din_s & input_reg(71  downto 0);
                    when "01010"  => input_reg <= input_reg(127 downto 88) & din_s & input_reg(79 downto 0); 
                    when "01011"  => input_reg <= input_reg(127 downto 96) & din_s & input_reg(87 downto 0); 
                        
                    when "01100"  => input_reg <= input_reg(127 downto 104) & din_s & input_reg(95 downto 0); 
                    when "01101"  => input_reg <= input_reg(127 downto 112) & din_s & input_reg(103 downto 0); 
                    when "01110"  => input_reg <= input_reg(127 downto 120) & din_s & input_reg(111 downto 0); 
                    when "01111"  => input_reg <= din_s & input_reg(119 downto 0); 
                    when others   => input_reg <= input_reg; 
                end case;
            end if; 
        end if; 
end process;  

----------------------------------------------------------------------------
-- toggle_bit, asserted after the first decryption round
----------------------------------------------------------------------------
process (clk, resetn)                                 -- detect rising edge data_valid 
    begin 
        if resetn='0' then
              tbit_s <= '0';
        elsif rising_edge(clk) then    
            if wr_iv_s='0' then                         -- writing to the IV register clears the bit
                tbit_s <= '0';
            elsif data_valid_s='1' then
                tbit_s <= '1';                          -- set when by the first rising edge of data_valid
            end if;                                              
        end if; 
end process; 

----------------------------------------------------------------------------
-- write to IV register
-- 110-xxxx Write to IV register (CBC mode only)
-- If we are in the encode stage and we get a data_valid_s pulse then
-- load cipher_text into IV.
----------------------------------------------------------------------------
process (clk, resetn)
    begin 
        if resetn='0' then
            iv_reg <= (others => '0');
        elsif rising_edge(clk) then    
            if (enc_dec_s='0' and data_valid_s='1') then
                iv_reg <= dout_core;                -- load IV for next iteration   
            elsif (enc_dec_s='1' and data_valid_s='1' and tbit_s='1') then
                iv_reg <= input_reg;                -- load IV for next iteration                                           
            elsif (wr_iv_s='0') then                -- User write to IV register
                case addr(3 downto 0) is 
                    when "0000"  => iv_reg <= iv_reg(127 downto 8)  & din_s; 
                    when "0001"  => iv_reg <= iv_reg(127 downto 16) & din_s & iv_reg(7  downto 0);
                    when "0010"  => iv_reg <= iv_reg(127 downto 24) & din_s & iv_reg(15 downto 0); 
                    when "0011"  => iv_reg <= iv_reg(127 downto 32) & din_s & iv_reg(23 downto 0); 
    
                    when "0100"  => iv_reg <= iv_reg(127 downto 40) & din_s & iv_reg(31 downto 0); 
                    when "0101"  => iv_reg <= iv_reg(127 downto 48) & din_s & iv_reg(39 downto 0); 
                    when "0110"  => iv_reg <= iv_reg(127 downto 56) & din_s & iv_reg(47 downto 0); 
                    when "0111"  => iv_reg <= iv_reg(127 downto 64) & din_s & iv_reg(55 downto 0); 

                    when "1000"  => iv_reg <= iv_reg(127 downto 72) & din_s & iv_reg(63 downto 0); 
                    when "1001"  => iv_reg <= iv_reg(127 downto 80) & din_s & iv_reg(71  downto 0);
                    when "1010"  => iv_reg <= iv_reg(127 downto 88) & din_s & iv_reg(79 downto 0); 
                    when "1011"  => iv_reg <= iv_reg(127 downto 96) & din_s & iv_reg(87 downto 0); 
                        
                    when "1100"  => iv_reg <= iv_reg(127 downto 104) & din_s & iv_reg(95 downto 0); 
                    when "1101"  => iv_reg <= iv_reg(127 downto 112) & din_s & iv_reg(103 downto 0); 
                    when "1110"  => iv_reg <= iv_reg(127 downto 120) & din_s & iv_reg(111 downto 0); 
                    when others  => iv_reg <= din_s & iv_reg(119 downto 0); 
                end case;
            end if; 
        end if; 
end process;  

ivxorin_s <= iv_reg XOR input_reg;          -- Input for encrypt
ivxorout_s <= dout_core XOR iv_reg;         -- output for decrypt

----------------------------------------------------------------------------
-- Input to ECB Core   ecb_cbc=0 => ecb, enc_dec=0 => encrypt
--
-- ecb_cbc & enc_dec   Action
--    0        0         ecb encode
--    0        1         ecb decode
--    1        0         cbc encode use IV XOR input_data (unless writing key)
--    1        1         cbc decode use IV XOR output_core 
----------------------------------------------------------------------------
din_core <= ivxorin_s when (ecb_cbc='1' AND enc_dec_s='0' AND ld_key_s='0') else input_reg;    -- Connect input/iv register to AES core input

dout_core_s <= ivxorout_s when (ecb_cbc='1' AND enc_dec_s='1') else dout_core;    
                           

process (clk, resetn)                                 -- detect rising edge data_valid/dkey_done/ekey_done 
    begin 
        if resetn='0' then
              ffa_s <= (others => '0');
              ffb_s <= (others => '0');                           
        elsif rising_edge(clk) then                                                
              ffa_s<= data_valid & dkey_done & ekey_done;
              ffb_s<= ffa_s;
        end if; 
end process; 
data_valid_s <= ffa_s(2) AND (NOT ffb_s(2)); 
dkey_done_s  <= ffa_s(1) AND (NOT ffb_s(1)); 
ekey_done_s  <= ffa_s(0) AND (NOT ffb_s(0)); 

-- Output register, loaded by rising edge of data_valid
process (clk, resetn)
    begin 
        if resetn='0' then
            output_reg <= (others => '0');
        elsif rising_edge(clk) then 
            if (data_valid_s='1') then      -- load on rising edge data valid 
                output_reg <= dout_core_s;                                              
            end if; 
        end if; 
end process;  
                           
                                    
----------------------------------------------------------------------------
-- output from the AES core
----------------------------------------------------------------------------
process (addr, output_reg)
    begin 
        case addr(3 downto 0) is 
            when "0000" => dout_s <= output_reg( 7 downto 0); 
            when "0001" => dout_s <= output_reg(15 downto 8);
            when "0010" => dout_s <= output_reg(23 downto 16);
            when "0011" => dout_s <= output_reg(31 downto 24);
                
            when "0100" => dout_s <= output_reg(39 downto 32); 
            when "0101" => dout_s <= output_reg(47 downto 40);
            when "0110" => dout_s <= output_reg(55 downto 48);
            when "0111" => dout_s <= output_reg(63 downto 56);

            when "1000" => dout_s <= output_reg(71 downto 64); 
            when "1001" => dout_s <= output_reg(79 downto 72);
            when "1010" => dout_s <= output_reg(87 downto 80);
            when "1011" => dout_s <= output_reg(95 downto 88);

            when "1100" => dout_s <= output_reg(103 downto 96); 
            when "1101" => dout_s <= output_reg(111 downto 104);
            when "1110" => dout_s <= output_reg(119 downto 112);
            when others => dout_s <= output_reg(127 downto 120);
        end case;
end process;  

----------------------------------------------------------------------------
-- Control register Address=111-xxxx
-- Enable Interrupt by writing a 1 to the required interrupt source
-- 
--    4        3       2     1     0
--  Mode      Data   DKEY   EKEY  INT
--  ecb_cbc   Valid  Valid  Valid
--            INT    INT    INT
--
-- Example: Enable Data Valid Interrupt control_reg=1001
-- Reading the status register clears the INT bit
----------------------------------------------------------------------------
process (clk, resetn)
    begin 
        if resetn='0' then
            control_reg <= (others => '0');
        elsif rising_edge(clk) then 
            if (rd_s='0' and addr(6 downto 4)="111") then   -- Clear by reading status register 
                control_reg <= control_reg(4 downto 1) & '0';                                              
            elsif (we_s='0' AND addr(6 downto 4)="111") then 
                control_reg <= din_s(4 downto 0); 
            end if; 
        end if; 
end process;  

----------------------------------------------------------------------------
-- Status register  Address=111-xxxx
--
-- 7      6       5       4       3       2       1      0
-- Busy   user    user   Mode    Data    Dkey    Ekey    INT
--                       ecb_cb  Valid   Done    Done    
--                                
----------------------------------------------------------------------------
status_reg<=  busy & status65 & control_reg(4) & data_valid & dkey_done & ekey_done & control_reg(0);

----------------------------------------------------------------------------
-- Interrupt pulse
-- generate interrupt only when appropriate control bits are set.
----------------------------------------------------------------------------
int_s <= '1' when (control_reg(0)='1' AND ((control_reg(3)='1' AND data_valid_s='1') OR 
                                           (control_reg(2)='1' AND dkey_done_s='1') OR
                                           (control_reg(1)='1' AND ekey_done_s='1'))) else '0';

-- Latch interrupt, disable during writing to the control register.
process (clk, resetn)                                    
    begin 
        if resetn='0' then
            int <= '0';
        elsif rising_edge(clk) then 
            if (rd_s='0' and addr(6 downto 4)="111") then   -- Clear by reading status register
                int <= '0';
            elsif NOT(we_s='0' AND addr(6 downto 4)="111") then  -- Set only when we are not writing to ctrl reg
                if int_s='1' then
                    int <= '1';
                end if;
            end if; 
        end if; 
end process; 
   
end architecture rtl;

