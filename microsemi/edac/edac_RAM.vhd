-- Version: 9.2 9.2.4.3

library ieee;
use ieee.std_logic_1164.all;
library Axcelerator;
use Axcelerator.all;

entity edac_RAM is 
    port( axwdata : in std_logic_vector(35 downto 0); axrdata : 
        out std_logic_vector(35 downto 0);axwe, axre : in 
        std_logic; axwaddr : in std_logic_vector(10 downto 0); 
        axraddr : in std_logic_vector(10 downto 0);clk : in 
        std_logic) ;
end edac_RAM;


architecture DEF_ARCH of  edac_RAM is

    component RAM64K36
    generic (MEMORYFILE:string := "");

        port(WCLK, RCLK, DEPTH0, DEPTH1, DEPTH2, DEPTH3, WEN, WW0, 
        WW1, WW2, WRAD0, WRAD1, WRAD2, WRAD3, WRAD4, WRAD5, WRAD6, 
        WRAD7, WRAD8, WRAD9, WRAD10, WRAD11, WRAD12, WRAD13, 
        WRAD14, WRAD15, WD0, WD1, WD2, WD3, WD4, WD5, WD6, WD7, 
        WD8, WD9, WD10, WD11, WD12, WD13, WD14, WD15, WD16, WD17, 
        WD18, WD19, WD20, WD21, WD22, WD23, WD24, WD25, WD26, 
        WD27, WD28, WD29, WD30, WD31, WD32, WD33, WD34, WD35, REN, 
        RW0, RW1, RW2, RDAD0, RDAD1, RDAD2, RDAD3, RDAD4, RDAD5, 
        RDAD6, RDAD7, RDAD8, RDAD9, RDAD10, RDAD11, RDAD12, 
        RDAD13, RDAD14, RDAD15 : in std_logic := 'U'; RD0, RD1, 
        RD2, RD3, RD4, RD5, RD6, RD7, RD8, RD9, RD10, RD11, RD12, 
        RD13, RD14, RD15, RD16, RD17, RD18, RD19, RD20, RD21, 
        RD22, RD23, RD24, RD25, RD26, RD27, RD28, RD29, RD30, 
        RD31, RD32, RD33, RD34, RD35 : out std_logic) ;
    end component;

    component VCC
        port( Y : out std_logic);
    end component;

    component GND
        port( Y : out std_logic);
    end component;

    signal VCC_1_net, GND_1_net : std_logic ;
    begin   

    VCC_2_net : VCC port map(Y => VCC_1_net);
    GND_2_net : GND port map(Y => GND_1_net);
    RAMBLOCK_0_inst : RAM64K36
      port map(WCLK => clk, RCLK => clk, DEPTH0 => VCC_1_net, 
        DEPTH1 => VCC_1_net, DEPTH2 => VCC_1_net, DEPTH3 => 
        GND_1_net, WEN => axwe, WW0 => GND_1_net, WW1 => 
        GND_1_net, WW2 => VCC_1_net, WRAD0 => axwaddr(0), 
        WRAD1 => axwaddr(1), WRAD2 => axwaddr(2), WRAD3 => 
        axwaddr(3), WRAD4 => axwaddr(4), WRAD5 => axwaddr(5), 
        WRAD6 => axwaddr(6), WRAD7 => axwaddr(7), WRAD8 => 
        axwaddr(8), WRAD9 => axwaddr(9), WRAD10 => axwaddr(10), 
        WRAD11 => GND_1_net, WRAD12 => GND_1_net, WRAD13 => 
        GND_1_net, WRAD14 => GND_1_net, WRAD15 => GND_1_net, 
        WD0 => axwdata(0), WD1 => axwdata(1), WD2 => axwdata(2), 
        WD3 => axwdata(3), WD4 => axwdata(4), WD5 => axwdata(5), 
        WD6 => axwdata(6), WD7 => axwdata(7), WD8 => axwdata(8), 
        WD9 => axwdata(9), WD10 => axwdata(10), WD11 => 
        axwdata(11), WD12 => axwdata(12), WD13 => axwdata(13), 
        WD14 => axwdata(14), WD15 => axwdata(15), WD16 => 
        axwdata(16), WD17 => axwdata(17), WD18 => GND_1_net, 
        WD19 => GND_1_net, WD20 => GND_1_net, WD21 => GND_1_net, 
        WD22 => GND_1_net, WD23 => GND_1_net, WD24 => GND_1_net, 
        WD25 => GND_1_net, WD26 => GND_1_net, WD27 => GND_1_net, 
        WD28 => GND_1_net, WD29 => GND_1_net, WD30 => GND_1_net, 
        WD31 => GND_1_net, WD32 => GND_1_net, WD33 => GND_1_net, 
        WD34 => GND_1_net, WD35 => GND_1_net, REN => axre, RW0 => 
        GND_1_net, RW1 => GND_1_net, RW2 => VCC_1_net, RDAD0 => 
        axraddr(0), RDAD1 => axraddr(1), RDAD2 => axraddr(2), 
        RDAD3 => axraddr(3), RDAD4 => axraddr(4), RDAD5 => 
        axraddr(5), RDAD6 => axraddr(6), RDAD7 => axraddr(7), 
        RDAD8 => axraddr(8), RDAD9 => axraddr(9), RDAD10 => 
        axraddr(10), RDAD11 => GND_1_net, RDAD12 => GND_1_net, 
        RDAD13 => GND_1_net, RDAD14 => GND_1_net, RDAD15 => 
        GND_1_net, RD0 => axrdata(0), RD1 => axrdata(1), RD2 => 
        axrdata(2), RD3 => axrdata(3), RD4 => axrdata(4), RD5 => 
        axrdata(5), RD6 => axrdata(6), RD7 => axrdata(7), RD8 => 
        axrdata(8), RD9 => axrdata(9), RD10 => axrdata(10), 
        RD11 => axrdata(11), RD12 => axrdata(12), RD13 => 
        axrdata(13), RD14 => axrdata(14), RD15 => axrdata(15), 
        RD16 => axrdata(16), RD17 => axrdata(17), RD18 => OPEN , 
        RD19 => OPEN , RD20 => OPEN , RD21 => OPEN , RD22 => 
        OPEN , RD23 => OPEN , RD24 => OPEN , RD25 => OPEN , 
        RD26 => OPEN , RD27 => OPEN , RD28 => OPEN , RD29 => 
        OPEN , RD30 => OPEN , RD31 => OPEN , RD32 => OPEN , 
        RD33 => OPEN , RD34 => OPEN , RD35 => OPEN );
    RAMBLOCK_1_inst : RAM64K36
      port map(WCLK => clk, RCLK => clk, DEPTH0 => VCC_1_net, 
        DEPTH1 => VCC_1_net, DEPTH2 => VCC_1_net, DEPTH3 => 
        GND_1_net, WEN => axwe, WW0 => GND_1_net, WW1 => 
        GND_1_net, WW2 => VCC_1_net, WRAD0 => axwaddr(0), 
        WRAD1 => axwaddr(1), WRAD2 => axwaddr(2), WRAD3 => 
        axwaddr(3), WRAD4 => axwaddr(4), WRAD5 => axwaddr(5), 
        WRAD6 => axwaddr(6), WRAD7 => axwaddr(7), WRAD8 => 
        axwaddr(8), WRAD9 => axwaddr(9), WRAD10 => axwaddr(10), 
        WRAD11 => GND_1_net, WRAD12 => GND_1_net, WRAD13 => 
        GND_1_net, WRAD14 => GND_1_net, WRAD15 => GND_1_net, 
        WD0 => axwdata(18), WD1 => axwdata(19), WD2 => 
        axwdata(20), WD3 => axwdata(21), WD4 => axwdata(22), 
        WD5 => axwdata(23), WD6 => axwdata(24), WD7 => 
        axwdata(25), WD8 => axwdata(26), WD9 => axwdata(27), 
        WD10 => axwdata(28), WD11 => axwdata(29), WD12 => 
        axwdata(30), WD13 => axwdata(31), WD14 => axwdata(32), 
        WD15 => axwdata(33), WD16 => axwdata(34), WD17 => 
        axwdata(35), WD18 => GND_1_net, WD19 => GND_1_net, 
        WD20 => GND_1_net, WD21 => GND_1_net, WD22 => GND_1_net, 
        WD23 => GND_1_net, WD24 => GND_1_net, WD25 => GND_1_net, 
        WD26 => GND_1_net, WD27 => GND_1_net, WD28 => GND_1_net, 
        WD29 => GND_1_net, WD30 => GND_1_net, WD31 => GND_1_net, 
        WD32 => GND_1_net, WD33 => GND_1_net, WD34 => GND_1_net, 
        WD35 => GND_1_net, REN => axre, RW0 => GND_1_net, RW1 => 
        GND_1_net, RW2 => VCC_1_net, RDAD0 => axraddr(0), 
        RDAD1 => axraddr(1), RDAD2 => axraddr(2), RDAD3 => 
        axraddr(3), RDAD4 => axraddr(4), RDAD5 => axraddr(5), 
        RDAD6 => axraddr(6), RDAD7 => axraddr(7), RDAD8 => 
        axraddr(8), RDAD9 => axraddr(9), RDAD10 => axraddr(10), 
        RDAD11 => GND_1_net, RDAD12 => GND_1_net, RDAD13 => 
        GND_1_net, RDAD14 => GND_1_net, RDAD15 => GND_1_net, 
        RD0 => axrdata(18), RD1 => axrdata(19), RD2 => 
        axrdata(20), RD3 => axrdata(21), RD4 => axrdata(22), 
        RD5 => axrdata(23), RD6 => axrdata(24), RD7 => 
        axrdata(25), RD8 => axrdata(26), RD9 => axrdata(27), 
        RD10 => axrdata(28), RD11 => axrdata(29), RD12 => 
        axrdata(30), RD13 => axrdata(31), RD14 => axrdata(32), 
        RD15 => axrdata(33), RD16 => axrdata(34), RD17 => 
        axrdata(35), RD18 => OPEN , RD19 => OPEN , RD20 => OPEN , 
        RD21 => OPEN , RD22 => OPEN , RD23 => OPEN , RD24 => 
        OPEN , RD25 => OPEN , RD26 => OPEN , RD27 => OPEN , 
        RD28 => OPEN , RD29 => OPEN , RD30 => OPEN , RD31 => 
        OPEN , RD32 => OPEN , RD33 => OPEN , RD34 => OPEN , 
        RD35 => OPEN );
end DEF_ARCH;
