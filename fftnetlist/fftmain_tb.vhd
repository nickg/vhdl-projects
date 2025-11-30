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
    signal o_sync   : std_logic;
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

    stim: process is
        variable phase : real := 0.0;
    begin
        for i in 1 to 10 loop
            wait until falling_edge(i_clk);
        end loop;

        i_reset <= '0';
        wait until falling_edge(i_clk);

        loop
            i_sample <= std_logic_vector(to_signed(integer(sin(phase) * (2.0**30)), 32));
            wait until falling_edge(i_clk);
            if o_sync = '1' then
                report to_hstring(o_result);
                assert o_result = X"00C7557E7A8E";
                exit;
            end if;
            phase := phase + 0.01;
        end loop;
        std.env.finish;
        wait;
    end process;

end architecture;
