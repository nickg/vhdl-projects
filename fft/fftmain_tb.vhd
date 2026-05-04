library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fftmain_tb is
end entity;

architecture test of fftmain_tb is
    component fftmain is
        port (
            i_clk : in std_logic;
            i_reset : in std_logic;
            i_ce : in std_logic;
            i_sample : in std_logic_vector ( 31 downto 0 );
            o_result : out std_logic_vector ( 45 downto 0 );
            o_sync : out std_logic );
    end component;

    signal i_clk    : std_logic := '0';
    signal i_reset  : std_logic := '1';
    signal i_sample : std_logic_vector (31 downto 0) := (others => '0');
    signal o_result : std_logic_vector (45 downto 0);
    signal o_re, o_im : std_logic_vector (22 downto 0);

    constant zeros : std_logic_vector (31 downto 0) := (others => '0');

    signal o_sync   : std_logic;

    signal sync_cnt: integer := 0;
    signal i: integer := 0;
    
    type slv_array is array (0 to 193) of std_logic_vector(47 downto 0);

    constant golden : slv_array := (
        x"3FCD927FFD5C",
x"3FC9A4FFFA51",
x"3FC18AFFF634",
x"3FB10C7FEF7C",
x"3F88757FE0BA",
x"3EBE257F9AF6",
x"01417D8075C9",
x"0061318028B4",
x"003643801994",
x"002452801308",
x"001A99000F55",
x"00148E800CEE",
x"00107D000B40",
x"000D940009FB",
x"000B6A0008FF",
x"0009C1000834",
x"00087080078C",
x"0007628006FF",
x"000685800688",
x"0005CF00061F",
x"0005348005C4",
x"0004B2000574",
x"00044200052B",
x"0003E00004ED",
x"00038D0004B4",
x"00034200047D",
x"00030300044F",
x"0002C7000422",
x"0002950003F8",
x"0002658003D3",
x"00023D0003B2",
x"000216800391",
x"0001F5000373",
x"0001D7000359",
x"0001BA00033C",
x"0001A0000325",
x"00018880030D",
x"0001740002F5",
x"00015E0002E4",
x"00014C0002CE",
x"00013C8002BD",
x"00012B8002AB",
x"00011D00029C",
x"00011100028C",
x"00010400027C",
x"0000F780026C",
x"0000EC00025F",
x"0000E2000252",
x"0000D9800247",
x"0000CF80023B",
x"0000C7000230",
x"0000BE800223",
x"0000B6000217",
x"0000B000020F",
x"0000A8000204",
x"0000A30001FB",
x"00009C0001F2",
x"0000968001E8",
x"0000908001E3",
x"00008B0001D9",
x"0000878001D0",
x"0000820001C6",
x"00007E8001C0",
x"0000790001B9",
x"0000758001B3",
x"0000720001AB",
x"00006E8001A6",
x"00006A0001A0",
x"000067000199",
x"000064000193",
x"00006080018E",
x"00005E000188",
x"00005A800184",
x"00005780017E",
x"000056000177",
x"000053000174",
x"00005080016E",
x"00004E000169",
x"00004D000164",
x"00004900015F",
x"00004780015C",
x"000046800158",
x"000044800155",
x"00004180014F",
x"00003F80014A",
x"00003E000148",
x"00003C000144",
x"00003B000141",
x"00003980013D",
x"000038000138",
x"000037000134",
x"000035000131",
x"00003380012E",
x"00003300012B",
x"000030800128",
x"000030000125",
x"00002F800122",
x"00002E00011F",
x"00002D80011B",
x"00002A000119",
x"00002A800116",
x"00002A000112",
x"000028800110",
x"00002800010E",
x"00002680010D",
x"000026000108",
x"000024000106",
x"000022000105",
x"000023000102",
x"000022000100",
x"0000218000FD",
x"00001F8000FA",
x"0000208000FA",
x"00001F0000F4",
x"00001E0000F1",
x"00001C8000EF",
x"00001C8000EE",
x"00001B8000EE",
x"00001B0000EC",
x"00001C0000E7",
x"00001A8000E8",
x"0000198000E7",
x"0000190000E2",
x"00001A0000E5",
x"0000188000E0",
x"0000170000DD",
x"0000170000DE",
x"0000168000DB",
x"0000158000D9",
x"0000150000D9",
x"0000130000D8",
x"0000138000D4",
x"0000148000D3",
x"0000138000D1",
x"0000130000CE",
x"0000128000CD",
x"0000120000CB",
x"0000110000C9",
x"0000108000C8",
x"0000100000C7",
x"00000F0000C7",
x"00000F0000C4",
x"0000108000C3",
x"00000E0000C4",
x"00000E0000C0",
x"00000E0000BE",
x"00000E8000BE",
x"00000D0000BE",
x"00000C0000BA",
x"00000E0000BA",
x"00000E0000B8",
x"00000C0000B9",
x"00000D8000B4",
x"00000B0000B8",
x"00000C0000B2",
x"00000B0000B3",
x"00000C0000B1",
x"00000C0000B1",
x"00000B0000B0",
x"00000B0000AF",
x"00000A0000AD",
x"00000A0000AE",
x"0000090000AD",
x"00000A0000A9",
x"0000088000A8",
x"0000090000A8",
x"0000088000A6",
x"0000098000A5",
x"0000078000A6",
x"0000068000A3",
x"0000080000A2",
x"0000078000A0",
x"0000068000A0",
x"0000078000A0",
x"0000070000A0",
x"00000780009E",
x"00000700009D",
x"00000680009C",
x"00000500009C",
x"00000580009A",
x"000006000099",
x"000005000099",
x"000005800095",
x"000005000096",
x"000005800096",
x"000004800096",
x"000004800095",
x"000003800094",
x"000004000093",
x"000004800093",
x"000003800094",
x"000004000090",
x"000003000090",
x"00000400008E"
        );

begin

    i_clk <= not i_clk after 5 ns;

    u: component fftmain
        port map (
            i_clk => i_clk,
            i_reset => i_reset,
            i_ce => '1',
            i_sample => i_sample,
            o_result => o_result,
            o_sync => o_sync );
    o_re <= o_result(45 downto 23);
    o_im <= o_result(22 downto 0);

    stim: process is
        variable phase : real := 0.0;
    begin
        for i in 1 to 10 loop
            wait until falling_edge(i_clk);
        end loop;

        i_reset <= '0';
        wait until falling_edge(i_clk);

        loop
            i_sample <= std_logic_vector(to_signed(integer(sin(phase) * (2.0**12)), 16)) & zeros(15 downto 0);
            wait until falling_edge(i_clk);
            if o_sync = '1' then
                sync_cnt <= sync_cnt+1;
            end if;
--            if (sync_cnt=3) then
            if (i=193) then
                exit;
            end if;
            if (sync_cnt>=2) then
--                report "o:" & to_hstring(o_result);
--                report "g:" & to_hstring(golden(i));
                assert o_result = golden(i)(45 downto 0);
                i <= i+1;
            end if;
            phase := phase + 0.01;
        end loop;
        std.env.finish;
        wait;
    end process;

end architecture;
