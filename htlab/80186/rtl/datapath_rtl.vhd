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
-- Module        : datapath                                                  --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 1.0  05/21/02   Created HT-LAB                            --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.STD_LOGIC_UNSIGNED.all;
USE ieee.std_logic_arith.ALL;

LIBRARY I80186;
USE I80186.cpu86pack.ALL;

ENTITY datapath IS
   PORT( 
      clk        : IN     std_logic;
      clrop      : IN     std_logic;
      instr      : IN     instruction_type;
      mdbus_in   : IN     std_logic_vector (15 DOWNTO 0);
      memio      : IN     std_logic;
      path       : IN     path_in_type;
      reset      : IN     std_logic;
      wrpath     : IN     write_in_type;
      dbusdp_out : OUT    std_logic_vector (15 DOWNTO 0);
      eabus      : OUT    std_logic_vector (15 DOWNTO 0);
      segbus     : OUT    std_logic_vector (15 DOWNTO 0);
      status     : OUT    status_out_type
   );

-- Declarations

END datapath ;



LIBRARY I80186;

ARCHITECTURE rtl OF datapath IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL alu_ccbus  : std_logic_vector(2 DOWNTO 0);
   SIGNAL alu_inbusa : std_logic_vector(15 DOWNTO 0);
   SIGNAL alu_inbusb : std_logic_vector(15 DOWNTO 0);
   SIGNAL alubus     : std_logic_vector(15 DOWNTO 0);
   SIGNAL aluopr     : std_logic_vector(6 DOWNTO 0);
   SIGNAL ax_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL bp_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL bx_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL ccbus      : std_logic_vector(15 DOWNTO 0);
   SIGNAL cs_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL cx_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL data_in    : std_logic_vector(15 DOWNTO 0);
   SIGNAL di_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL dibus      : std_logic_vector(15 DOWNTO 0);
   SIGNAL dimux      : std_logic_vector(2 DOWNTO 0);
   SIGNAL disp       : std_logic_vector(15 DOWNTO 0);
   SIGNAL dispmux    : std_logic_vector(2 DOWNTO 0);
   SIGNAL div_err    : std_logic;
   SIGNAL domux      : std_logic_vector(1 DOWNTO 0);
   SIGNAL ds_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL dx_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL ea         : std_logic_vector(15 DOWNTO 0);
   SIGNAL eamux      : std_logic_vector(3 DOWNTO 0);
   SIGNAL es_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL ipbus      : std_logic_vector(15 DOWNTO 0);
   SIGNAL ipfault    : std_logic_vector(15 DOWNTO 0);
   SIGNAL ipreg      : std_logic_vector(15 DOWNTO 0);
   SIGNAL nbreq      : std_logic_vector(2 DOWNTO 0);
   SIGNAL opflag_s   : std_logic;
   SIGNAL opmux      : std_logic_vector(1 DOWNTO 0);
   SIGNAL rm         : std_logic_vector(2 DOWNTO 0);
   SIGNAL s43        : std_logic_vector(1 DOWNTO 0);
   SIGNAL sdbus      : std_logic_vector(15 DOWNTO 0);
   SIGNAL segop      : std_logic_vector(2 DOWNTO 0);
   SIGNAL selalua    : std_logic_vector(3 DOWNTO 0);
   SIGNAL selalub    : std_logic_vector(3 DOWNTO 0);
   SIGNAL seldreg    : std_logic_vector(2 DOWNTO 0);
   SIGNAL selds      : std_logic;
   SIGNAL selsreg    : std_logic_vector(1 DOWNTO 0);
   SIGNAL si_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL sibus      : std_logic_vector(15 DOWNTO 0);
   SIGNAL simux      : std_logic_vector(1 DOWNTO 0);
   SIGNAL sp_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL ss_s       : std_logic_vector(15 DOWNTO 0);
   SIGNAL w          : std_logic;
   SIGNAL wralu      : std_logic;
   SIGNAL wrcc       : std_logic;
   SIGNAL wrd        : std_logic;
   SIGNAL wrip       : std_logic;
   SIGNAL wrop       : std_logic;
   SIGNAL wrs        : std_logic;
   SIGNAL wrtemp     : std_logic;
   SIGNAL xmod       : std_logic_vector(1 DOWNTO 0);

   -- Implicit buffer signal declarations
   SIGNAL eabus_internal : std_logic_vector (15 DOWNTO 0);


signal opreg_s  : std_logic_vector(1 downto 0); -- Override Segment Register
signal eam_s : std_logic_vector(15 downto 0);
signal segsel_s : std_logic_vector(5 downto 0); -- segbus select
signal int0cs_s : std_logic;

   -- Component Declarations
   COMPONENT ALU
   PORT (
      alu_inbusa : IN     std_logic_vector (15 DOWNTO 0);
      alu_inbusb : IN     std_logic_vector (15 DOWNTO 0);
      aluopr     : IN     std_logic_vector (6 DOWNTO 0);
      ax_s       : IN     std_logic_vector (15 DOWNTO 0);
      clk        : IN     std_logic ;
      --    cx_s       : IN     std_logic_vector (15 DOWNTO 0);
      dx_s       : IN     std_logic_vector (15 DOWNTO 0);
      reset      : IN     std_logic ;
      w          : IN     std_logic ;
      wralu      : IN     std_logic ;
      wrcc       : IN     std_logic ;
      wrtemp     : IN     std_logic ;
      alu_ccbus  : OUT    std_logic_vector (2 DOWNTO 0);
      alubus     : OUT    std_logic_vector (15 DOWNTO 0);
      ccbus      : OUT    std_logic_vector (15 DOWNTO 0);
      div_err    : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT dataregfile
   PORT (
      dibus      : IN     std_logic_vector (15 DOWNTO 0);
      selalua    : IN     std_logic_vector (3 DOWNTO 0);
      selalub    : IN     std_logic_vector (3 DOWNTO 0);
      seldreg    : IN     std_logic_vector (2 DOWNTO 0);
      w          : IN     std_logic ;
      wrd        : IN     std_logic ;
      alu_inbusa : OUT    std_logic_vector (15 DOWNTO 0);
      alu_inbusb : OUT    std_logic_vector (15 DOWNTO 0);
      bp_s       : OUT    std_logic_vector (15 DOWNTO 0);
      bx_s       : OUT    std_logic_vector (15 DOWNTO 0);
      di_s       : OUT    std_logic_vector (15 DOWNTO 0);
      si_s       : OUT    std_logic_vector (15 DOWNTO 0);
      reset      : IN     std_logic ;
      clk        : IN     std_logic ;
      data_in    : IN     std_logic_vector (15 DOWNTO 0);
      mdbus_in   : IN     std_logic_vector (15 DOWNTO 0);
      sp_s       : OUT    std_logic_vector (15 DOWNTO 0);
      ax_s       : OUT    std_logic_vector (15 DOWNTO 0);
      cx_s       : OUT    std_logic_vector (15 DOWNTO 0);
      dx_s       : OUT    std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT ipregister
   PORT (
      clk     : IN     std_logic ;
      ipbus   : IN     std_logic_vector (15 DOWNTO 0);
      reset   : IN     std_logic ;
      wrip    : IN     std_logic ;
      ipreg   : OUT    std_logic_vector (15 DOWNTO 0);
      ipfault : OUT    std_logic_vector (15 DOWNTO 0) -- Fault IP address (used for DIV/BOUND)
   );
   END COMPONENT;
   COMPONENT segregfile
   PORT (
      selsreg : IN     std_logic_vector (1 DOWNTO 0);
      sibus   : IN     std_logic_vector (15 DOWNTO 0);
      wrs     : IN     std_logic ;
      reset   : IN     std_logic ;
      clk     : IN     std_logic ;
      sdbus   : OUT    std_logic_vector (15 DOWNTO 0);
      dimux   : IN     std_logic_vector (2 DOWNTO 0);
      es_s    : OUT    std_logic_vector (15 DOWNTO 0);
      cs_s    : OUT    std_logic_vector (15 DOWNTO 0);
      ss_s    : OUT    std_logic_vector (15 DOWNTO 0);
      ds_s    : OUT    std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : ALU USE ENTITY I80186.ALU;
   FOR ALL : dataregfile USE ENTITY I80186.dataregfile;
   FOR ALL : ipregister USE ENTITY I80186.ipregister;
   FOR ALL : segregfile USE ENTITY I80186.segregfile;
   -- pragma synthesis_on


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   dimux   <= path.datareg_input(6 downto 4);                              -- Data Register Input Path
   w       <= path.datareg_input(3);
   seldreg <= path.datareg_input(2 downto 0);
   
   -- selalua(4) & selalub(4) & aluopr(7) 
   selalua <= path.alu_operation(14 downto 11);                             -- ALU Path
   selalub <= path.alu_operation(10 downto 7);
   aluopr  <= path.alu_operation(6 downto 0);
   
   domux   <= path.dbus_output;                                            -- Data Output Path
   
   simux   <= path.segreg_input(3 downto 2);                               -- Segment Register Input Path
   selsreg <= path.segreg_input(1 downto 0);
   
   dispmux <= path.ea_output(9 downto 7);                                  -- select ipreg addition
   eamux   <= path.ea_output(6 downto 3);                                     -- 4 bits 
   segop   <= path.ea_output(2 downto 0);                                  -- segop(2)=Segment override flag disable signal

   -- HDL Embedded Text Block 2 eb2
   wrd   <= wrpath.wrd;                                                    -- Write Strobes
   wralu <= wrpath.wralu;
   wrcc  <= wrpath.wrcc;
   wrs   <= wrpath.wrs;
   wrip  <= wrpath.wrip;
   wrop  <= wrpath.wrop;
   wrtemp<= wrpath.wrtemp;

   -- HDL Embedded Text Block 3 eb3
   status.ax       <= ax_s;
   status.cx_one   <= '1' when (cx_s=X"0001") else '0';
   status.cx_zero  <= '1' when (cx_s=X"0000") else '0';
   status.cl       <= cx_s(7 downto 0);                                    -- 5 bits used for shift/rotate, 8 bits for 8086
   status.flag     <= ccbus;
   status.div_err  <= div_err;                                             -- Divider overflow
   status.alu_ccbus<= alu_ccbus;                                           -- Unlatched ZF/SF/OF flags used for BOUND instr. 
   status.s543     <= ccbus(9) & s43;                                      -- IF and Segment Status signals S3 and S4

   -- HDL Embedded Text Block 4 eb4
   disp    <= instr.disp;
   data_in <= instr.data;
   nbreq   <= instr.nb;
   rm      <= instr.rm;
   xmod    <= instr.xmod;

   -- HDL Embedded Text Block 5 calcea
   ----------------------------------------------------------------------------
   -- Determine effective address         (eb5   5)
   -- rm      action
   -- 000 ea =   BX + SI    + disp
   -- 001 ea =   BX + DI    + disp
   -- 010 ea =   BP + SI    + disp      
   -- 011 ea =   BP + DI    + disp      
   -- 100 ea =   SI         + disp
   -- 101 ea =   DI         + disp
   -- 110 ea =   BP         + disp   (except   when mod=00   then ea=disphigh,displow)
   -- 111 ea =   BX         + disp
   --
   -- selds='1' when BP is   NOT   referenced    (use DS in   this case, else   use   SS)
   -- xmod=mod
   ----------------------------------------------------------------------------
   process(rm,ax_s,bx_s,cx_s,dx_s,bp_s,sp_s,si_s,di_s,disp,xmod)
       begin   
           case rm is
               when "000" => 
                   if xmod="11" then 
                       eam_s <= ax_s;
                   else 
                       eam_s <= bx_s + si_s + disp;   
                   end if;
                   selds<='1';
               when "001" => 
                   if xmod="11" then 
                       eam_s <= cx_s;
                   else 
                       eam_s <= bx_s + di_s + disp;
                   end if;       
                   selds<='1';
               when "010" => 
                   if xmod="11" then 
                       eam_s <= dx_s;
                   else 
                       eam_s <= bp_s + si_s + disp;  
                   end if;     
                   selds<='0';                 
               when "011" => 
                   if xmod="11" then 
                       eam_s <= bx_s;
                   else 
                       eam_s <= bp_s + di_s + disp;   
                   end if;
                   selds<='0';
               when "100" => 
                   if xmod="11" then 
                       eam_s <= sp_s;        
                   else 
                       eam_s <= si_s + disp; 
                   end if;          
                   selds<='1';
               when "101" => 
                   if xmod="11" then 
                       eam_s <= bp_s;
                   else 
                       eam_s <= di_s + disp;      
                   end if;
                   selds<='1';
               when "110" => 
                   if xmod="00" then 
                       eam_s <= disp;
                       selds <='1';
                   elsif xmod="11" then 
                       eam_s <= si_s;   
                       selds <='1';         
                   else 
                       eam_s <= bp_s + disp; 
                       selds <='0';                                        -- Use SS  
                   end if;
   
               when   others=> 
                   if xmod="11" then 
                       eam_s <= di_s;
                   else 
                       eam_s <= bx_s + disp;   
                   end if;             
                   selds<='1';    
           end case;
   end process;
   
   ea<=eam_s;

   -- HDL Embedded Text Block 7 simux
   process(data_in,eabus_internal,alubus,mdbus_in,simux) 
      begin
         case simux is 
            when "00"   => sibus <= data_in;  
            when "01"   => sibus <= eabus_internal;       
            when "10"   => sibus <= alubus;   
            when others => sibus <= mdbus_in;    
         end case;
   end process;

   -- HDL Embedded Text Block 8 ipmux
   process(dispmux,nbreq,disp,mdbus_in,ipreg,eabus_internal,opflag_s,ipfault)               
      begin
      case dispmux is
            when "000"   => ipbus <= ("0000000000000"&nbreq) + ipreg;
            when "001"   => ipbus <= (("0000000000000"&nbreq)+disp) + ipreg;
          --when "010"   => ipbus <= mdbus_in;      
            when "011"   => ipbus <= disp;                                 -- disp contains new IP value
            when "100"   => ipbus <= eabus_internal;                                -- ipbus=effective address
          
          --when "101"   => ipbus <= ipreg;                                -- bodge to get ipreg onto ipbus
            when "101"   => if (opflag_s='1') then                         -- Segment Override is used                                  
                               ipbus <= ipfault;                           -- Fault IP address used for DIV/Bound 
                            else 
                               ipbus <= ("0000000000000"&nbreq) + ipreg;
                            end if;      
            when others  => ipbus <= mdbus_in;                             -- (31 downto 16), only used for "int x" instruction              
      end case;   
   end process;

   -- HDL Embedded Text Block 9 eb8
   -- Modified for 80186
   process(domux, alubus,ccbus, dibus, ipbus)
      begin
         case domux is 
            when "00"   => dbusdp_out <= alubus;                           -- Even 
            when "01"   => dbusdp_out <= ccbus;
            when "10"   => dbusdp_out <= dibus;
            when others => dbusdp_out <= ipbus;                            -- CALL Instruction
         end case;
   end process;

   -- HDL Embedded Text Block 10 segoverride
                                     
   -- Write Prefix Register
   process(clk,reset)                                                    -- segoverride 10      
      begin                    
           if (reset = '1') then                    
              opreg_s <= "01";                                         -- Default CS Register 
              opflag_s<= '0';                                          -- Clear Override Prefix Flag                      
            elsif rising_edge(clk) then                                
               if wrop='1' then                    
                  opreg_s <= segop(1 downto 0);                        -- Set override register 
                  opflag_s<= '1';                                      -- segop(2);         -- Set flag
               elsif clrop='1' then                    
                  opreg_s <= "11";                                     -- Default Data Segment Register  
                  opflag_s<= '0';                          
               end if;
         end if;
   end process;
   
   process (opflag_s,opreg_s,selds,eamux,segop)
      begin
         if opflag_s='1' and segop(2)='0' then                         -- Prefix register set and disable override not set?
            opmux <= opreg_s(1 downto 0);                              -- Set mux to override prefix reg
         elsif eamux(3)='1' then                        
             opmux <= eamux(1 downto 0);                        
         elsif eamux(0)='0' then                        
            opmux <= "01";                                             -- Select CS for IP
         else                        
            opmux <= '1'&selds;                                        -- DS if selds=1 else SS      
         end if;                        
   end process;

   -- HDL Embedded Text Block 11 drmux
   process(dimux, data_in,alubus,mdbus_in,sdbus,eabus_internal) 
      begin
         case dimux is 
            when "000"   => dibus <= data_in;                              -- Operand
            when "001"   => dibus <= eabus_internal;                                -- Offset  
            when "010"   => dibus <= alubus;                               -- Output ALU
            when "011"   => dibus <= mdbus_in;                             -- Memory Bus
            when others  => dibus <= sdbus;                                -- Segment registers
         end case;
   end process;

   -- HDL Embedded Text Block 12 eb9
   -- Segment Output Mux                              
   -- int0cs_s is asserted during an int instruction. eamux is either 0110 or 0111
   int0cs_s <= '1' when eamux(3 downto 1)="011" else '0';
   segsel_s <= memio & int0cs_s & eamux(2 downto 1) & opmux;                  -- 5 bits
      
   -- S43 combines S4 and S3, valid during T2,T3,Tw,T4           
   process(segsel_s,es_s,cs_s,ss_s,ds_s)                                     -- Segment Output Mux 
      begin
         case segsel_s is 
            when "100000" => segbus <= es_s; s43<="00";                     -- 00**, opmux select register
            when "100001" => segbus <= cs_s; s43<="10";                      
            when "100010" => segbus <= ss_s; s43<="01";                               
            when "100011" => segbus <= ds_s; s43<="11";                    
                                       
            when "100100" => segbus <= es_s; s43<="00";                     -- 01**, opmux select register
            when "100101" => segbus <= cs_s; s43<="10";                      
            when "100110" => segbus <= ss_s; s43<="01";                               
            when "100111" => segbus <= ds_s; s43<="11";                    
                                   
            when "101000" => segbus <= ss_s; s43<="01";                     -- 10**=SS, used for PUSH& POP
            when "101001" => segbus <= ss_s; s43<="01";                    
            when "101010" => segbus <= ss_s; s43<="01";                    
            when "101011" => segbus <= ss_s; s43<="01";                    
                                   
            when "101100" => segbus <= es_s; s43<="00";                     -- 01**, opmux select register
            when "101101" => segbus <= cs_s; s43<="10";                      
            when "101110" => segbus <= ss_s; s43<="01";            
            when "101111" => segbus <= ds_s; s43<="11";  
                                                                           -- IN/OUT instruction 0x0000:PORT/DX
                                                                           -- and interrupts (CS=0)
            when others   => segbus <= ZEROVECTOR_C(15 downto 0); s43<="10";   
         end case;                                              
   end process;

   -- HDL Embedded Text Block 13 eb10
   -- Offset Mux          
   -- Note ea*4 required if non-32 bits memory access is used.
   -- Currently CS &IP are read in one go (fits 32 bits)
   process(ipreg,ea,sp_s,dx_s,eamux,si_s,di_s,bx_s,ax_s,bp_s) 
      begin
         case eamux is 
            when "0000"  => eabus_internal <= ipreg;  
            when "0001"  => eabus_internal <= ea;    
            when "0010"  => eabus_internal <= dx_s;   
            when "0011"  => eabus_internal <= ea + X"0002";                         -- for call mem32/int
            when "0100"  => eabus_internal <= sp_s;                                 -- 10* select SP_S 
            when "0101"  => eabus_internal <= sp_s;  
            when "0110"  => eabus_internal <= ea(13 downto 0)&"00";             
            when "0111"  => eabus_internal <=(ea(13 downto 0)&"00") + X"0002";      -- for int   
            when "1000"  => eabus_internal <= di_s;                                 -- Select ES:DI 
            when "1001"  => eabus_internal <= ea;                                   -- added for JMP SI instruction
            when "1010"  => eabus_internal <= bp_s;                                 -- Added for ENTER instruction
            when "1011"  => eabus_internal <= si_s;                                 -- Select DS:SI
   --       when "1100"  =>
   --       when "1101"  =>
   --       when "1110"  =>
            when "1111"  => eabus_internal <= bx_s + (X"00"&ax_s(7 downto 0));      -- XLAT instruction
            when others  => eabus_internal <= DONTCARE(15 downto 0);
         end case;
   end process;


   -- Instance port mappings.
   I6 : ALU
      PORT MAP (
         alu_inbusa => alu_inbusa,
         alu_inbusb => alu_inbusb,
         aluopr     => aluopr,
         ax_s       => ax_s,
         clk        => clk,
         dx_s       => dx_s,
         reset      => reset,
         w          => w,
         wralu      => wralu,
         wrcc       => wrcc,
         wrtemp     => wrtemp,
         alu_ccbus  => alu_ccbus,
         alubus     => alubus,
         ccbus      => ccbus,
         div_err    => div_err
      );
   I0 : dataregfile
      PORT MAP (
         dibus      => dibus,
         selalua    => selalua,
         selalub    => selalub,
         seldreg    => seldreg,
         w          => w,
         wrd        => wrd,
         alu_inbusa => alu_inbusa,
         alu_inbusb => alu_inbusb,
         bp_s       => bp_s,
         bx_s       => bx_s,
         di_s       => di_s,
         si_s       => si_s,
         reset      => reset,
         clk        => clk,
         data_in    => data_in,
         mdbus_in   => mdbus_in,
         sp_s       => sp_s,
         ax_s       => ax_s,
         cx_s       => cx_s,
         dx_s       => dx_s
      );
   I9 : ipregister
      PORT MAP (
         clk     => clk,
         ipbus   => ipbus,
         reset   => reset,
         wrip    => wrip,
         ipreg   => ipreg,
         ipfault => ipfault
      );
   I15 : segregfile
      PORT MAP (
         selsreg => selsreg,
         sibus   => sibus,
         wrs     => wrs,
         reset   => reset,
         clk     => clk,
         sdbus   => sdbus,
         dimux   => dimux,
         es_s    => es_s,
         cs_s    => cs_s,
         ss_s    => ss_s,
         ds_s    => ds_s
      );

   -- Implicit buffered output assignments
   eabus <= eabus_internal;

END rtl;
