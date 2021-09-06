entity toplevel is
end entity;

library ieee;
use ieee.std_logic_1164.all;

architecture test of toplevel is
    signal io_asyncReset        : std_logic := '1';
    signal io_mainClk           : std_logic := '0';
    signal io_jtag_tms          : std_logic;
    signal io_jtag_tdi          : std_logic;
    signal io_jtag_tdo          : std_logic;
    signal io_jtag_tck          : std_logic;
    signal io_gpioA_read        : std_logic_vector(31 downto 0);
    signal io_gpioA_write       : std_logic_vector(31 downto 0);
    signal io_gpioA_writeEnable : std_logic_vector(31 downto 0);
    signal io_uart_txd          : std_logic;
    signal io_uart_rxd          : std_logic;

    signal running              : boolean := true;
begin

    io_mainClk <= not io_mainClk after 5 ns when running;
    io_asyncReset <= '0' after 20 ns;

    running <= false after 1 ms;

    uut: entity work.Murax
        port map (
            io_asyncReset        => io_asyncReset,
            io_mainClk           => io_mainClk,
            io_jtag_tms          => io_jtag_tms,
            io_jtag_tdi          => io_jtag_tdi,
            io_jtag_tdo          => io_jtag_tdo,
            io_jtag_tck          => io_jtag_tck,
            io_gpioA_read        => io_gpioA_read,
            io_gpioA_write       => io_gpioA_write,
            io_gpioA_writeEnable => io_gpioA_writeEnable,
            io_uart_txd          => io_uart_txd,
            io_uart_rxd          => io_uart_rxd );

end architecture;
