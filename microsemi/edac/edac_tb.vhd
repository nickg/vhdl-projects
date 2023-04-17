library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edac_tb is
end entity;

architecture test of edac_tb is
    signal wdata           : std_logic_vector(15 downto 0) := X"0000";
    signal waddr           : std_logic_vector(10 downto 0) := (others => '0');
    signal raddr           : std_logic_vector(10 downto 0) := (others => '0');
    signal we              : std_logic := '0';
    signal re              : std_logic := '0';
    signal rstn            : std_logic := '0';
    signal clk             : std_logic := '0';
    signal stop_scrub      : std_logic := '1';
    signal rdata           : std_logic_vector(15 downto 0);
    signal slowdown        : std_logic;
    signal error           : std_logic;
    signal correctable     : std_logic;
    signal scrub_corrected : std_logic;
    signal caddr           : std_logic_vector(10 downto 0);
    signal scrub_done      : std_logic;
    signal tmoutflg        : std_logic;

    signal running : boolean := true;
begin

    clk <= not clk after 10 ns when running;

    uut: entity work.edac
        port map (
            wdata           => wdata,
            waddr           => waddr,
            raddr           => raddr,
            we              => we,
            re              => re,
            rstn            => rstn,
            clk             => clk,
            stop_scrub      => stop_scrub,
            rdata           => rdata,
            slowdown        => slowdown,
            error           => error,
            correctable     => correctable,
            scrub_corrected => scrub_corrected,
            caddr           => caddr,
            scrub_done      => scrub_done,
            tmoutflg        => tmoutflg );

    stim: process is
        variable tmp : std_logic_vector(15 downto 0);
    begin
        wait for 100 ns;
        wait until falling_edge(clk);
        rstn <= '1';

        wait for 100 ns;
        wait until falling_edge(clk);

        for repeat in 1 to 10 loop

            for i in 0 to 255 loop
                tmp := std_logic_vector(to_unsigned(i, 16));
                waddr <= tmp(10 downto 0);
                wdata <= tmp;
                wait until falling_edge(clk);
                we <= '1';
                wait until falling_edge(clk);
                we <= '0';
            end loop;

            wait until falling_edge(clk);
            stop_scrub <= '0';
            wait for 10 us;
            wait until falling_edge(clk);
            stop_scrub <= '1';
            wait until falling_edge(clk);

            for i in 0 to 255 loop
                tmp := std_logic_vector(to_unsigned(i, 16));
                raddr <= tmp(10 downto 0);
                re <= '1';
                wait until falling_edge(clk);
                assert rdata = tmp;
                wait until falling_edge(clk);
                re <= '0';
            end loop;

        end loop;

        running <= false;
        wait;
    end process;

end architecture;
