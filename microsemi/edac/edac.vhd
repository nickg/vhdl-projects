library IEEE;
use IEEE.std_logic_1164.all;
library axcelerator;
entity edac is
  port(WDATA : in std_logic_vector(15 downto 0);
       WADDR : in std_logic_vector(10 downto 0);
       RADDR : in std_logic_vector(10 downto 0);
       WE : in std_logic;
       RE : in std_logic;
       RSTN : in std_logic;
       CLK : in std_logic;
       STOP_SCRUB : in std_logic;
       RDATA : out std_logic_vector(15 downto 0);
       SLOWDOWN : out std_logic;
       ERROR : out std_logic;
       CORRECTABLE : out std_logic;
       SCRUB_CORRECTED : out std_logic;
       CADDR : out std_logic_vector(10 downto 0);
       SCRUB_DONE : out std_logic;
       TMOUTFLG : out std_logic);
end edac;

architecture behavioral of edac is


-- Ports for Backend RAM
signal  axwe      : std_logic;
signal  axre      : std_logic;
signal  axwaddr   : std_logic_vector(11 downto 0);
signal  axraddr   : std_logic_vector(11 downto 0);
signal  axwdata   : std_logic_vector(35 downto 0);
signal  axrdata   : std_logic_vector(35 downto 0);
signal  dummy1    : std_logic_vector(12 downto 0);
signal  dummy2    : std_logic;
signal  gnd_1_net : std_logic;
signal  vcc_1_net : std_logic;

component GND
         port(y               : out std_logic);
end component;

component VCC
         port(y               : out std_logic);
end component;

-- AX RAM
component edac_RAM
    port(axwdata         : in std_logic_vector(35 downto 0);
         axrdata         : out std_logic_vector(35 downto 0);
         axwaddr         : in std_logic_vector(10 downto 0);
         axraddr         : in std_logic_vector(10 downto 0);
         axwe,axre,clk   : in std_logic);
end component;

component edaci
    port(clk             : in std_logic;
         we              : in std_logic;
         re              : in std_logic;
         waddr           : in std_logic_vector(11 downto 0);
         raddr           : in std_logic_vector(11 downto 0);
         wdata           : in std_logic_vector(28 downto 0);
         rstn            : in std_logic;
         tmout           : in std_logic_vector(41 downto 0);
         rds             : in std_logic_vector(3 downto 0);
         stop_scrub      : in std_logic;
         bypass          : in std_logic;
         wp              : in std_logic_vector(6 downto 0);
         rdata           : out std_logic_vector(28 downto 0);
         rp              : out std_logic_vector(6 downto 0);
         slowdown        : out std_logic;
         scrub_corrected : out std_logic;
         caddr           : out std_logic_vector(11 downto 0);
         error           : out std_logic;
         scrub_done      : out std_logic;
         tmoutflg        : out std_logic;
         correctable     : out std_logic;
         axwe            : out std_logic;
         axre            : out std_logic;
         axwaddr         : out std_logic_vector(11 downto 0);
         axraddr         : out std_logic_vector(11 downto 0);
         axwdata         : out std_logic_vector(35 downto 0);
         axrdata         : in std_logic_vector(35 downto 0)
         );
end component;

for all: gnd use entity axcelerator.gnd;
for all: vcc use entity axcelerator.vcc;

begin

uGND : GND
   port map(y=>gnd_1_net);

uVCC : VCC
   port map(y=>vcc_1_net);

uaxram : edac_RAM
   port map(
        clk=>CLK,
        axwe=>axwe,
        axre=>axre,
        axwaddr=>axwaddr(10 downto 0),
        axraddr=>axraddr(10 downto 0),
        axwdata=>axwdata,
        axrdata=>axrdata
        );

uedaci : edaci
   port map(
         clk=>CLK,
         we=>WE,
         re=>RE,
         rstn=>RSTN,
         stop_scrub=>STOP_SCRUB,
         axwdata=>axwdata,
         axrdata=>axrdata,
         axwaddr=>axwaddr,
         axraddr=>axraddr,
         axwe=>axwe,
         axre=>axre,
         waddr(0)=>WADDR(0),
         waddr(1)=>WADDR(1),
         waddr(2)=>WADDR(2),
         waddr(3)=>WADDR(3),
         waddr(4)=>WADDR(4),
         waddr(5)=>WADDR(5),
         waddr(6)=>WADDR(6),
         waddr(7)=>WADDR(7),
         waddr(8)=>WADDR(8),
         waddr(9)=>WADDR(9),
         waddr(10)=>WADDR(10),
         waddr(11)=>gnd_1_net,
         raddr(0)=>RADDR(0),
         raddr(1)=>RADDR(1),
         raddr(2)=>RADDR(2),
         raddr(3)=>RADDR(3),
         raddr(4)=>RADDR(4),
         raddr(5)=>RADDR(5),
         raddr(6)=>RADDR(6),
         raddr(7)=>RADDR(7),
         raddr(8)=>RADDR(8),
         raddr(9)=>RADDR(9),
         raddr(10)=>RADDR(10),
         raddr(11)=>gnd_1_net,
         wdata(0)=>WDATA(0),
         wdata(1)=>WDATA(1),
         wdata(2)=>WDATA(2),
         wdata(3)=>WDATA(3),
         wdata(4)=>WDATA(4),
         wdata(5)=>WDATA(5),
         wdata(6)=>WDATA(6),
         wdata(7)=>WDATA(7),
         wdata(8)=>WDATA(8),
         wdata(9)=>WDATA(9),
         wdata(10)=>WDATA(10),
         wdata(11)=>WDATA(11),
         wdata(12)=>WDATA(12),
         wdata(13)=>WDATA(13),
         wdata(14)=>WDATA(14),
         wdata(15)=>WDATA(15),
         wdata(16)=>gnd_1_net,
         wdata(17)=>gnd_1_net,
         wdata(18)=>gnd_1_net,
         wdata(19)=>gnd_1_net,
         wdata(20)=>gnd_1_net,
         wdata(21)=>gnd_1_net,
         wdata(22)=>gnd_1_net,
         wdata(23)=>gnd_1_net,
         wdata(24)=>gnd_1_net,
         wdata(25)=>gnd_1_net,
         wdata(26)=>gnd_1_net,
         wdata(27)=>gnd_1_net,
         wdata(28)=>gnd_1_net,
         rdata(0)=>RDATA(0),
         rdata(1)=>RDATA(1),
         rdata(2)=>RDATA(2),
         rdata(3)=>RDATA(3),
         rdata(4)=>RDATA(4),
         rdata(5)=>RDATA(5),
         rdata(6)=>RDATA(6),
         rdata(7)=>RDATA(7),
         rdata(8)=>RDATA(8),
         rdata(9)=>RDATA(9),
         rdata(10)=>RDATA(10),
         rdata(11)=>RDATA(11),
         rdata(12)=>RDATA(12),
         rdata(13)=>RDATA(13),
         rdata(14)=>RDATA(14),
         rdata(15)=>RDATA(15),
         rdata(16)=>dummy1(0),
         rdata(17)=>dummy1(1),
         rdata(18)=>dummy1(2),
         rdata(19)=>dummy1(3),
         rdata(20)=>dummy1(4),
         rdata(21)=>dummy1(5),
         rdata(22)=>dummy1(6),
         rdata(23)=>dummy1(7),
         rdata(24)=>dummy1(8),
         rdata(25)=>dummy1(9),
         rdata(26)=>dummy1(10),
         rdata(27)=>dummy1(11),
         rdata(28)=>dummy1(12),
         tmout(0)=>vcc_1_net,
         tmout(1)=>vcc_1_net,
         tmout(2)=>vcc_1_net,
         tmout(3)=>vcc_1_net,
         tmout(4)=>vcc_1_net,
         tmout(5)=>vcc_1_net,
         tmout(6)=>vcc_1_net,
         tmout(7)=>vcc_1_net,
         tmout(8)=>vcc_1_net,
         tmout(9)=>vcc_1_net,
         tmout(10)=>vcc_1_net,
         tmout(11)=>vcc_1_net,
         tmout(12)=>vcc_1_net,
         tmout(13)=>vcc_1_net,
         tmout(14)=>vcc_1_net,
         tmout(15)=>vcc_1_net,
         tmout(16)=>vcc_1_net,
         tmout(17)=>vcc_1_net,
         tmout(18)=>vcc_1_net,
         tmout(19)=>vcc_1_net,
         tmout(20)=>vcc_1_net,
         tmout(21)=>vcc_1_net,
         tmout(22)=>vcc_1_net,
         tmout(23)=>vcc_1_net,
         tmout(24)=>vcc_1_net,
         tmout(25)=>vcc_1_net,
         tmout(26)=>vcc_1_net,
         tmout(27)=>vcc_1_net,
         tmout(28)=>vcc_1_net,
         tmout(29)=>vcc_1_net,
         tmout(30)=>vcc_1_net,
         tmout(31)=>vcc_1_net,
         tmout(32)=>vcc_1_net,
         tmout(33)=>vcc_1_net,
         tmout(34)=>vcc_1_net,
         tmout(35)=>vcc_1_net,
         tmout(36)=>vcc_1_net,
         tmout(37)=>vcc_1_net,
         tmout(38)=>vcc_1_net,
         tmout(39)=>vcc_1_net,
         tmout(40)=>vcc_1_net,
         tmout(41)=>vcc_1_net,
         rds(0)=>vcc_1_net,
         rds(1)=>vcc_1_net,
         rds(2)=>vcc_1_net,
         rds(3)=>gnd_1_net,
         rp=>open,
         wp(0)=>gnd_1_net,
         wp(1)=>gnd_1_net,
         wp(2)=>gnd_1_net,
         wp(3)=>gnd_1_net,
         wp(4)=>gnd_1_net,
         wp(5)=>gnd_1_net,
         wp(6)=>gnd_1_net,
         bypass=>gnd_1_net,
         slowdown=>SLOWDOWN,
         error=>ERROR,
         correctable=>CORRECTABLE,
         scrub_corrected=>SCRUB_CORRECTED,
         caddr(0)=>CADDR(0),
         caddr(1)=>CADDR(1),
         caddr(2)=>CADDR(2),
         caddr(3)=>CADDR(3),
         caddr(4)=>CADDR(4),
         caddr(5)=>CADDR(5),
         caddr(6)=>CADDR(6),
         caddr(7)=>CADDR(7),
         caddr(8)=>CADDR(8),
         caddr(9)=>CADDR(9),
         caddr(10)=>CADDR(10),
         caddr(11)=>dummy2,
         scrub_done=>SCRUB_DONE,
         tmoutflg=>TMOUTFLG
         );
end behavioral;

-- _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


-- _GEN_File_Contents_

-- Version:9.2.4.3
-- ACTGENU_CALL:1
-- BATCH:T
-- FAM:Axcelerator
-- OUTFORMAT:VHDL
-- LPMTYPE:LPM_RTRAM
-- LPM_HINT:NONE
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:F
-- DESDIR:C:/msys64/home/nick/smartgen/test\edac
-- GEN_BEHV_MODULE:F
-- AGENIII_IS_SUBPROJECT_LIBERO:F
-- WIDTH:16
-- DEPTH:2048
-- CLKS:1
-- TEST_PORTS:NO
-- FLAG_PORTS:YES
-- RRATE:3FFFFFFFFFF
-- GEN_BHV_VHDL_VAL:T
-- GEN_BHV_SUFFIX:_top

-- _End_Comments_
