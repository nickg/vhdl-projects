library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.can_bfm_pkg.all;


entity can_bfm_tb is
end entity can_bfm_tb;

architecture tb of can_bfm_tb is
  signal clk               : std_logic := '0';
  signal can_bus_signal    : std_logic;

  signal can_tx1           : std_logic := '1';
  signal can_rx1           : std_logic := '1';

  signal can_tx2           : std_logic := '1';
  signal can_rx2           : std_logic := '1';

  signal arb_id_xmit  : std_logic_vector(28 downto 0);
  signal data_xmit    : can_payload_t;

  signal data_length_xmit  : natural;

begin  -- architecture tb

  can_bus_signal <= 'H';
  can_bus_signal <= '0' when can_tx1 = '0' else 'Z';
  can_bus_signal <= '0' when can_tx2 = '0' else 'Z';
  can_rx1        <= '1' ?= can_bus_signal;
  can_rx2        <= '1' ?= can_bus_signal;


  proc_tb_bit_stuff_on: process is
    variable seed1     : positive := 12345;
    variable seed2     : positive := 6789;
    variable rand_real : real;
    variable rand_size : natural;
    variable rand_byte : natural;
    variable rand_id   : natural;
    variable can_bit_stuffing1 : std_logic := '0';
    variable can_sample_point1 : std_logic := '0';
    variable arb_lost     : std_logic := '0';
    variable ack_received : std_logic := '0';
  begin
    data_length_xmit <= 8;

    data_xmit(0) <= x"11";
    data_xmit(1) <= x"22";
    data_xmit(2) <= x"33";
    data_xmit(3) <= x"44";
    data_xmit(4) <= x"55";
    data_xmit(5) <= x"66";
    data_xmit(6) <= x"77";
    data_xmit(7) <= x"88";

    arb_id_xmit(10 downto 0) <= "10111011000";
    arb_id_xmit(28 downto 11) <= (others => '0');

    wait for 15200 ns;

    can_write(arb_id_xmit,
              '0',                      -- Remote request off
              '0',                      -- Extended ID off
              data_xmit,
              data_length_xmit,
              clk,
              can_tx1,
              can_rx1,
              can_bit_stuffing1,
              can_sample_point1,
              arb_lost,
              ack_received,
              '1',                      -- Bit stuffing enabled
              20 ns);

    -- Send random CAN frames
    loop
      wait for 10 us;

      -- Generate random frame
      uniform(seed1, seed2, rand_real);
      rand_size := natural(round(rand_real * real(8)));
      data_length_xmit <= rand_size;

      uniform(seed1, seed2, rand_real);
      --rand_id := natural(round(rand_real * real(2**11-1)));
      --arb_id_xmit(10 downto 0) <= std_logic_vector(to_unsigned(rand_id, 11));
      rand_id := natural(round(rand_real * real(2**29-1)));
      arb_id_xmit(28 downto 0) <= std_logic_vector(to_unsigned(rand_id, 29));

      for byte_num in 0 to 7 loop
        if byte_num < rand_size then
          uniform(seed1, seed2, rand_real);
          rand_byte := natural(round(rand_real * real(255)));
          data_xmit(byte_num) <= std_logic_vector(to_unsigned(rand_byte, 8));
        else
          data_xmit(byte_num) <= x"00";
        end if;
      end loop;  -- byte_num

      -- Wait for a clock cycle to allow signals to update
      -- before calling can_write()
      wait until rising_edge(clk);

      can_write(arb_id_xmit,
                '0',                      -- Remote request off
                '1',                      -- Extended ID off
                data_xmit,
                rand_size,
                clk,
                can_tx1,
                can_rx1,
                can_bit_stuffing1,
                can_sample_point1,
                arb_lost,
                ack_received,
                '1',                      -- Bit stuffing enabled
                20 ns);
    end loop;

  end process proc_tb_bit_stuff_on;

  proc_tb_bit_stuff_off: process is
    variable can_bit_stuffing2 : std_logic := '0';
    variable can_sample_point2 : std_logic := '0';
    variable arb_id_recv       : std_logic_vector(28 downto 0);
    variable remote_frame_recv : std_logic := '0';
    variable extended_id_recv  : std_logic := '0';
    variable data_recv         : can_payload_t;
    variable data_length_recv  : natural;
    variable timeout_recv      : std_logic := '0';
    variable crc_error_recv    : std_logic := '0';
  begin
    wait for 15200 ns;

    loop
      can_read(
        arb_id_recv,
        remote_frame_recv,
        extended_id_recv,
        data_recv,
        data_length_recv,
        100000,
        clk,
        can_rx2,
        can_tx2,
        can_bit_stuffing2,
        can_sample_point2,
        '1',
        timeout_recv,
        crc_error_recv,
        20 ns);

      wait until rising_edge(clk);

      assert data_length_recv = data_length_xmit report "TB: Received data length did not match transmit length" severity failure;

      assert data_recv = data_xmit report "TB: Received data did not match transmitted data" severity failure;

      wait until rising_edge(clk);

      --wait for 1 us;
    end loop;


    wait;
  end process proc_tb_bit_stuff_off;

  proc_clk: process is
  begin  -- process clk_proc
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process proc_clk;

end architecture tb;
