-------------------------------------------------------------------------------
--  HTL80186 - CPU core                                                      --
--  Copyright (C) 2002-2011 HT-LAB                                           --
--                                                                           --
--  Web          : http://www.ht-lab.com                                     --
--  Contact      : support@ht-lab.com                                        --
--  Sales        : sales@ht-lab.com                                          --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Please review the terms of the license agreement before using this file.  --
-- If you are not an authorized user, please destroy this source code file   --
-- and notify HT-Lab immediately that you inadvertently received an un-      --
-- authorized copy.                                                          --
-------------------------------------------------------------------------------
-- Project       : HTL80186                                                  --
-- Module        : Data Register File                                        --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 0.1  01/12/2007   Created HT-LAB                          --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY I80186;
USE I80186.cpu86pack.ALL;

ENTITY dataregfile IS
   PORT( 
      dibus      : IN     std_logic_vector (15 DOWNTO 0);
      selalua    : IN     std_logic_vector (3 DOWNTO 0);
      selalub    : IN     std_logic_vector (3 DOWNTO 0);
      seldreg    : IN     std_logic_vector (2 DOWNTO 0);
      w          : IN     std_logic;
      wrd        : IN     std_logic;
      alu_inbusa : OUT    std_logic_vector (15 DOWNTO 0);
      alu_inbusb : OUT    std_logic_vector (15 DOWNTO 0);
      bp_s       : OUT    std_logic_vector (15 DOWNTO 0);
      bx_s       : OUT    std_logic_vector (15 DOWNTO 0);
      di_s       : OUT    std_logic_vector (15 DOWNTO 0);
      si_s       : OUT    std_logic_vector (15 DOWNTO 0);
      reset      : IN     std_logic;
      clk        : IN     std_logic;
      data_in    : IN     std_logic_vector (15 DOWNTO 0);
      mdbus_in   : IN     std_logic_vector (15 DOWNTO 0);
      sp_s       : OUT    std_logic_vector (15 DOWNTO 0);
      ax_s       : OUT    std_logic_vector (15 DOWNTO 0);
      cx_s       : OUT    std_logic_vector (15 DOWNTO 0);
      dx_s       : OUT    std_logic_vector (15 DOWNTO 0)
   );
END dataregfile ;

architecture rtl of dataregfile is
 
    signal  axreg_s     : std_logic_vector(15 downto 0);
    signal  cxreg_s     : std_logic_vector(15 downto 0);
    signal  dxreg_s     : std_logic_vector(15 downto 0);
    signal  bxreg_s     : std_logic_vector(15 downto 0);
    signal  spreg_s     : std_logic_vector(15 downto 0);
    signal  bpreg_s     : std_logic_vector(15 downto 0);
    signal  sireg_s     : std_logic_vector(15 downto 0);
    signal  direg_s     : std_logic_vector(15 downto 0);

    signal  seldreg_s   : std_logic_vector(3 downto 0); -- w & seldreg
    signal  selalua_s   : std_logic_vector(4 downto 0); -- w & dibus & selalua
    signal  selalub_s   : std_logic_vector(4 downto 0); -- w & dibus & selalub

    signal  alu_inbusb_s: std_logic_vector (15 downto 0);

begin

    -------------------------------------------------------------------------
    -- 8 registers of 16 bits each
    -------------------------------------------------------------------------
    seldreg_s <= w & seldreg;

    process (clk,reset)
        begin
            if reset='1' then
                axreg_s <= (others => '0');
                cxreg_s <= (others => '0');
                dxreg_s <= (others => '0');
                bxreg_s <= (others => '0');
                spreg_s <= (others => '0');
                bpreg_s <= (others => '0');
                sireg_s <= (others => '0');
                direg_s <= (others => '0');
            elsif rising_edge(clk) then        
                if (wrd='1') then     
                    case seldreg_s is 
                        when "0000" => axreg_s(7 downto 0)  <= dibus(7 downto 0);     -- w=0 8 bits write
                        when "0001" => cxreg_s(7 downto 0)  <= dibus(7 downto 0);
                        when "0010" => dxreg_s(7 downto 0)  <= dibus(7 downto 0);
                        when "0011" => bxreg_s(7 downto 0)  <= dibus(7 downto 0);
                        when "0100" => axreg_s(15 downto 8) <= dibus(7 downto 0);
                        when "0101" => cxreg_s(15 downto 8) <= dibus(7 downto 0);
                        when "0110" => dxreg_s(15 downto 8) <= dibus(7 downto 0);
                        when "0111" => bxreg_s(15 downto 8) <= dibus(7 downto 0); 

                        when "1000" => axreg_s <= dibus;      -- w=1 16 bits write
                        when "1001" => cxreg_s <= dibus;
                        when "1010" => dxreg_s <= dibus;
                        when "1011" => bxreg_s <= dibus;
                        when "1100" => spreg_s <= dibus;
                        when "1101" => bpreg_s <= dibus;
                        when "1110" => sireg_s <= dibus;
                        when others => direg_s <= dibus; 
                    end case;                                                                                                                     
                end if;
            end if;   
    end process;  

    -------------------------------------------------------------------------
    -- Output Port A
    -- selalua="x1xxx" selects mdbus (use 11111)
    -------------------------------------------------------------------------
    selalua_s <= w & selalua;  

    process (selalua_s,axreg_s,cxreg_s,dxreg_s,bxreg_s,spreg_s,bpreg_s,sireg_s,direg_s,mdbus_in,data_in)
        begin
          case selalua_s is                  
                when "00000"    => alu_inbusa <= X"00" & axreg_s(7 downto 0);    -- Select 8 bits MSB=0
                when "00001"    => alu_inbusa <= X"00" & cxreg_s(7 downto 0);
                when "00010"    => alu_inbusa <= X"00" & dxreg_s(7 downto 0);
                when "00011"    => alu_inbusa <= X"00" & bxreg_s(7 downto 0);
                when "00100"    => alu_inbusa <= X"00" & axreg_s(15 downto 8);   -- AH
                when "00101"    => alu_inbusa <= X"00" & cxreg_s(15 downto 8);   -- CH
                when "00110"    => alu_inbusa <= X"00" & dxreg_s(15 downto 8);   -- DH
                when "00111"    => alu_inbusa <= X"00" & bxreg_s(15 downto 8);   -- BH
                when "10000"    => alu_inbusa <= axreg_s;
                when "10001"    => alu_inbusa <= cxreg_s;
                when "10010"    => alu_inbusa <= dxreg_s;
                when "10011"    => alu_inbusa <= bxreg_s;
                when "10100"    => alu_inbusa <= spreg_s;
                when "10101"    => alu_inbusa <= bpreg_s;
                when "10110"    => alu_inbusa <= sireg_s;
                when "10111"    => alu_inbusa <= direg_s;                   
                when "01000"    => alu_inbusa <= X"00"& data_in(7 downto 0);  -- Pass data_in to ALU (port B only) 
                when "11000"    => alu_inbusa <= data_in;                     -- Pass data_in to ALU (port B only)
                when others     => alu_inbusa <= mdbus_in(15 downto 0); -- Pass through
          end case;     
  end process;

    -------------------------------------------------------------------------
    -- Output Port B                                       data_in
    -- selalub="x1xxx" selects mdbus (use 11111)
    -- selalub="01xxx" selects data_in byte
    -- selalub="11xxx" selects data_in word
    -------------------------------------------------------------------------
    selalub_s <= w & selalub;

    process (selalub_s,axreg_s,cxreg_s,dxreg_s,bxreg_s,spreg_s,bpreg_s,sireg_s,direg_s,mdbus_in,data_in)
        begin
          case selalub_s is                  
                when "00000"    => alu_inbusb_s <= X"00" & axreg_s(7 downto 0);
                when "00001"    => alu_inbusb_s <= X"00" & cxreg_s(7 downto 0);
                when "00010"    => alu_inbusb_s <= X"00" & dxreg_s(7 downto 0);
                when "00011"    => alu_inbusb_s <= X"00" & bxreg_s(7 downto 0);
                when "00100"    => alu_inbusb_s <= X"00" & axreg_s(15 downto 8);
                when "00101"    => alu_inbusb_s <= X"00" & cxreg_s(15 downto 8);
                when "00110"    => alu_inbusb_s <= X"00" & dxreg_s(15 downto 8);
                when "00111"    => alu_inbusb_s <= X"00" & bxreg_s(15 downto 8); 
                when "10000"    => alu_inbusb_s <= axreg_s;
                when "10001"    => alu_inbusb_s <= cxreg_s;
                when "10010"    => alu_inbusb_s <= dxreg_s;
                when "10011"    => alu_inbusb_s <= bxreg_s;
                when "10100"    => alu_inbusb_s <= spreg_s;
                when "10101"    => alu_inbusb_s <= bpreg_s;
                when "10110"    => alu_inbusb_s <= sireg_s;
                when "10111"    => alu_inbusb_s <= direg_s;
                when "01000"    => alu_inbusb_s <= X"00"& data_in(7 downto 0);  -- Pass data_in to ALU (port B only) 
                when "11000"    => alu_inbusb_s <= data_in;                     -- Pass data_in to ALU (port B only)
                when "01001"    => alu_inbusb_s <= X"0001";     -- Used for INC/DEC byte function
                when "11001"    => alu_inbusb_s <= X"0001";     -- Used for INC/DEC word function
                when "11010"    => alu_inbusb_s <= X"0002";     -- Used for POP/PUSH function
                when others     => alu_inbusb_s <= mdbus_in(15 downto 0);   -- Pass through 
          end case;     
    end process;

    alu_inbusb <= alu_inbusb_s;                               -- connect to entity

    bx_s <= bxreg_s;                                          -- Used for EA calculation
    bp_s <= bpreg_s;
    si_s <= sireg_s;
    di_s <= direg_s;

    sp_s <= spreg_s;                                          -- Used for eamux, PUSH and POP instructions

    ax_s <= axreg_s;                                          -- Used for datapath FSM
    cx_s <= cxreg_s;
    dx_s <= dxreg_s;                                          -- Used for IN/OUT instructions & Divider

end rtl;
