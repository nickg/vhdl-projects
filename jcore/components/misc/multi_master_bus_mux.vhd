library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu2j0_pack.all;
use work.bus_mux_pkg.all;
-- This entity connects two data bus masters (m1 and m2) with one data bus
-- slave. The two masters have a fixed priority. If both m1 and m2 raise their
-- EN lines in the same cycle, then M1 will always win and perform it's read or
-- write first while M2 must wait. If M1 continually has read or writes, then
-- M2 can be starve, so take care when choosing the bus master order
entity multi_master_bus_mux is port (
  rst : in std_logic;
  clk : in std_logic;
  m1_i : out cpu_data_i_t;
  m1_o : in cpu_data_o_t;
  m2_i : out cpu_data_i_t;
  m2_o : in cpu_data_o_t;
  slave_i : in cpu_data_i_t;
  slave_o : out cpu_data_o_t
  );
end multi_master_bus_mux;
architecture a of multi_master_bus_mux is
  type state_t is (M1, M2);
  type bus_mux_reg_t is record
    state : state_t;
    m1 : cpu_data_i_t;
    m2 : cpu_data_i_t;
    slave : cpu_data_o_t;
    slave_ack : std_logic;
  end record;
  constant BUS_MUX_RESET : bus_mux_reg_t := (state => M1,
                                             m1 => ((others => '0'), '0'),
                                             m2 => ((others => '0'), '0'),
                                             slave => ('0', (others => '0'), '0', '0', "0000",
                                                       (others => '0')),
                                             slave_ack => '0');
  signal this_c : bus_mux_reg_t;
  signal this_r : bus_mux_reg_t := BUS_MUX_RESET;
begin
  p1 : process(this_r, m1_o, m2_o, slave_i)
    variable this : bus_mux_reg_t;
  begin
     this := this_r;
    if (m1_o.en = '1' or m2_o.en = '0') and
      (this.state = M1 or (this.state = M2 and this.slave_ack = '1'))
    then
      this.state := M1;
      this.m1.ack := slave_i.ack;
      this.m2.ack := '0';
      this.slave := m1_o;
    else
      -- Only switch to M2 if m1.en = '0' and m2.en = '1'.
      -- Only stay in M2 if previous state was M2 and ack = '0'.
      this.state := M2;
      this.m1.ack := '0';
      this.m2.ack := slave_i.ack;
      this.slave := m2_o;
    end if;
    this.slave_ack := slave_i.ack;
    this.m1.d := slave_i.d;
    this.m2.d := slave_i.d;
    this_c <= this;
  end process;
  p1_r0 : process(clk, rst)
  begin
     if rst='1' then
        this_r <= BUS_MUX_RESET;
     elsif clk='1' and clk'event then
        this_r <= this_c;
     end if;
  end process;
  m1_i <= this_c.m1;
  m2_i <= this_c.m2;
  slave_o <= this_c.slave;
end a;
