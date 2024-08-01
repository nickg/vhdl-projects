-------------------------------------------------------------------------------
--  HTL80186 - CPU core                                                      --
--  Copyright (C) 2002-2013 HT-LAB                                           --
--                                                                           --
--  Web          : http://www.ht-lab.com                                     --
--  Contact      : support@ht-lab.com                                        --
--  Sales        : sales@ht-lab.com                                          --
-------------------------------------------------------------------------------
-- Please review the terms of the license agreement before using this file.  --
-- If you are not an authorized user, please destroy this source code file   --
-- and notify HT-Lab immediately that you inadvertently received an un-      --
-- authorized copy.                                                          --
-------------------------------------------------------------------------------
-- Project       : Demo FreeDOS                                              --
-- Purpose       : Top Level                                                 --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 0.1  01/12/2007   Created HT-LAB                          --
--               : 0.79 14/01/2009                                           --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.NUMERIC_STD.all;

ENTITY demo188 IS
   PORT( 
      clk        : IN     std_logic;
      cpu_resetn : IN     std_logic;
      flash_cs_n : OUT    std_logic;
      flash_oe_n : OUT    std_logic;
      flash_we_n : OUT    std_logic;
      fse_a      : OUT    std_logic_vector (22 DOWNTO 0);
      iom        : OUT    std_logic;
      sram_cs_n  : OUT    std_logic;
      sram_oe_n  : OUT    std_logic;
      sram_we_n  : OUT    std_logic;
      wrn        : OUT    std_logic;
      fse_d      : INOUT  std_logic_vector (7 DOWNTO 0)
   );
END demo188;

ARCHITECTURE struct OF demo188 IS

   -- Architecture declarations
   signal wrnd_s : std_logic;
   signal csromn_s:std_logic;
   signal csflash_s: std_logic;
   signal cssram_s : std_logic;
   signal cshexled0  : std_logic;
   signal cshexled1 : std_logic; 
   signal hexport0 : std_logic_vector(3 downto 0);
   signal hexport1  : std_logic_vector(3 downto 0);

   -- Internal signal declarations
   SIGNAL abus        : std_logic_vector(23 DOWNTO 0);
   SIGNAL abusul      : std_logic_vector(23 DOWNTO 0);
   SIGNAL ale         : std_logic;
   SIGNAL csconfig    : std_logic;
   SIGNAL csflash     : std_logic;
   SIGNAL csromn      : std_logic;
   SIGNAL cssram      : std_logic;
   SIGNAL dbus_config : std_logic_vector(7 DOWNTO 0);
   SIGNAL dbus_in     : std_logic_vector(7 DOWNTO 0);
   SIGNAL dbus_in_cpu : std_logic_vector(7 DOWNTO 0);
   SIGNAL dbus_out    : std_logic_vector(7 DOWNTO 0);
   SIGNAL dbus_rom    : std_logic_vector(7 DOWNTO 0);
   SIGNAL hlda        : std_logic;
   SIGNAL hold        : std_logic;
   SIGNAL intr        : std_logic;
   SIGNAL iom_s       : std_logic;
   SIGNAL membank     : std_logic_vector(7 DOWNTO 0);
   SIGNAL nmi         : std_logic;
   SIGNAL por         : std_logic;
   SIGNAL rdn         : std_logic;
   SIGNAL ready       : std_logic;
   SIGNAL resoutn     : std_logic;
   SIGNAL s           : std_logic_vector(6 DOWNTO 0);
   SIGNAL sel_s       : std_logic_vector(1 DOWNTO 0);
   SIGNAL test        : std_logic;

   -- Implicit buffer signal declarations
   SIGNAL wrn_internal : std_logic;

   -- Component Declarations
   COMPONENT cpu188
   port( 
       clk        : in     std_logic  := 'X';
       dbus_in    : in     std_logic_vector(7 downto 0);
       hold       : in     std_logic;
       intr       : in     std_logic;
       nmi        : in     std_logic;
       por        : in     std_logic;
       ready      : in     std_logic;
       test       : in     std_logic;
       turbo186   : in     std_logic;
       abus       : out    std_logic_vector(23 downto 0);
       ale        : out    std_logic;
       dbus_out   : out    std_logic_vector(7 downto 0);
       hlda       : out    std_logic;
       inta       : out    std_logic;
       iret       : out    std_logic;                       -- ver 1.4, IRET being executed
       lock       : out    std_logic;
       proc_error : out    std_logic;
       qs         : out    std_logic_vector(1 downto 0);
       rdn        : out    std_logic;
       resoutn    : out    std_logic;
       s          : out    std_logic_vector(6 downto 0);
       wrn        : out    std_logic
   );
   END COMPONENT;

   COMPONENT Bootstrap
   PORT (
      abus : IN     std_logic_vector (7 DOWNTO 0);
      dbus : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;


BEGIN

    process(sel_s,dbus_in,dbus_rom,dbus_config)
        begin
           case sel_s is
               when "01"   => dbus_in_cpu <= dbus_rom;  -- BootStrap Loader
               when "10"   => dbus_in_cpu <= dbus_config;-- Config Port
               when others => dbus_in_cpu <= dbus_in;   -- External SRAM        
          end case;         
    end process;
   
    ---------------------------------------------------------
    -- Address bus latch 
    ---------------------------------------------------------
    process(clk)
       begin
           if rising_edge(clk) then
               if ale='1' then
                   if (csflash_s='0') then
                       abus<=membank & abusul(15 downto 0);-- Flash/SDRAM            
                   else
                       abus<="0000"&abusul(19 downto 0);             -- Sram
                   end if;
                end if;
           end if;     
    end process;                                        

    fse_a <= abus(22 downto 0);                         -- External only 23 bits (8Mbyte)

    -- Reset Switch (CPU Reset)
    por <= not cpu_resetn;                        

    --------------------------------------------------------- 
    -- Status
    ---------------------------------------------------------
    process (clk,resoutn)  
       begin
           if resoutn='0' then
               iom_s<='1';
           elsif (rising_edge(clk)) then 
               if ale='1' then
                   iom_s<=NOT s(2);                    -- Block IOM to select IO when
               end if;  
           end if;   
    end process;
   
    iom<=s(2);
   
    -- dbus_in_cpu multiplexer
    sel_s <= csromn & csconfig;
             
    ----------------------------------------------------------------
    -- Config Port
    ----------------------------------------------------------------
    csconfig <= '0' when (abus(15 downto 0)=X"0050" AND iom_s='1') else '1';

    ----------------------------------------------------------------
    -- Bootstrap ROM 256 bytes 
    -- FFFFF-FF=FFF00
    -- s(2) is not valid for the whole cycle so csromn_s must be latched
    ----------------------------------------------------------------
    csromn_s <= '0' when ((abusul(19 downto 8)=X"FFF") AND s(2)='1') else '1';   

    process (clk,resoutn)  
       begin
           if resoutn='0' then
               csromn   <= '1';
           elsif (rising_edge(clk)) then 
               if (ale='1') then
                   csromn <= csromn_s;
               end if;
           end if;
    end process;
   
    ----------------------------------------------------------------
    -- 64Kbyte Flash/SDRAM Area
    -- FLASH E0000-EFFFF 
    -- MEM_BANK=0x55
    -- Note required abusul since ALE latches the address later on
    -- s(2) is not valid for the whole cycle so csflash_s must be latched
    ----------------------------------------------------------------
    csflash_s <= '0' when ((abusul(19 downto 16)=X"E") AND s(2)='1') else '1';

    process (clk,resoutn)  
       begin
           if resoutn='0' then
               membank <= (others => '0');
               csflash <= '1';
           elsif (rising_edge(clk)) then 
               if (abus(15 downto 0)=X"0055" AND iom_s='1' AND wrn_internal='0') then
                   membank<=dbus_out;      -- A23..0, Max 16Mbyte
               end if;
               if (ale='1') then
                   csflash <= csflash_s;
               end if;
           end if;
    end process;

    flash_cs_n <= csflash;
    flash_we_n <= wrn_internal;
    flash_oe_n <= rdn;
   
    ----------------------------------------------------------------
    -- 1Mbyte SRAM - csromn - csflash - cssdram & iom_s
    -- 00000-FFFFF
    ----------------------------------------------------------------
    cssram_s <= '0' when (csromn_s='1' AND csflash_s='1' AND s(2)='1') else '1'; 

    process (clk,resoutn)  
       begin
           if resoutn='0' then
               cssram <= '1';
           elsif (rising_edge(clk)) then 
               if ale='1' then
                   cssram <= cssram_s; 
               end if;
           end if;
    end process;

    sram_cs_n <= cssram;
    sram_oe_n <= rdn;
    sram_we_n <= wrn_internal;    

    -- Delay wrn_internal by 0.5 clock cycles to get some extra hold time on the databus
    -- This shouldn't be necessary but for some reason Quartus refuses
    -- to change wrn_internal into a registered output.  (fast output enable register)
    process(clk,resoutn)
    begin
       if resoutn='0' then
           wrnd_s <= '1';
       elsif falling_edge(clk) then
           wrnd_s<=wrn_internal;
       end if;
    end process;

    process (wrnd_s,wrn_internal,dbus_out)   
       begin       
           if (wrn_internal='0' OR wrnd_s='0') then
               fse_d<= dbus_out; -- drive port
           else
               fse_d<= (others => 'Z');
           end if;     
    end process;   
    dbus_in <= fse_d;
       
    dbus_config <= "10000101";
    test  <= '0';
    hold  <= '0';
    intr  <= '0';
    nmi   <= '0';
    ready <= '1';

    -- Instance port mappings.
    U_0 : cpu188
      PORT MAP (
         clk        => clk,
         dbus_in    => dbus_in_cpu,
         hold       => hold,
         intr       => intr,
         nmi        => nmi,
         por        => por,
         ready      => ready,
         test       => test,
         turbo186   => test,            -- '0', disabled
         abus       => abusul,
         ale        => ale,
         dbus_out   => dbus_out,
         hlda       => hlda,
         inta       => OPEN,
         iret       => OPEN,
         lock       => OPEN,
         proc_error => OPEN,
         qs         => OPEN,
         rdn        => rdn,
         resoutn    => resoutn,
         s          => s,
         wrn        => wrn_internal
      );
    U_7 : Bootstrap
      PORT MAP (
         abus => abus(7 DOWNTO 0),
         dbus => dbus_rom
      );

    wrn <= wrn_internal;

END struct;
