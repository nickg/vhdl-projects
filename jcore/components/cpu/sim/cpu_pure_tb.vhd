library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.cpu2j0_pack.all;
use work.monitor_pkg.all;
use work.data_bus_pkg.all;
entity cpu_pure_tb is
end;
architecture behaviour of cpu_pure_tb is
  type instrd_bus_i_t is array(instr_bus_device_t'left to instr_bus_device_t'right) of cpu_data_i_t;
  type instrd_bus_o_t is array(instr_bus_device_t'left to instr_bus_device_t'right) of cpu_data_o_t;
  signal instr_master_o : cpu_instruction_o_t;
  signal instr_master_i : cpu_instruction_i_t := (( others => 'Z' ),'0');
  signal instr_slaves_i : instr_bus_i_t;
  signal instr_slaves_o : instr_bus_o_t;
  signal instrd_slaves_i : instrd_bus_i_t;
  signal instrd_slaves_o : instrd_bus_o_t;
  signal data_master_o : cpu_data_o_t;
  signal data_master_i : cpu_data_i_t := (( others => 'Z' ),'0');
  signal data_slaves_i : data_bus_i_t;
  signal data_slaves_o : data_bus_o_t;
  signal sram_d_o : cpu_data_o_t;
  signal debug_i : cpu_debug_i_t := CPU_DEBUG_NOP;
  signal debug_i_cmd : std_logic_vector(1 downto 0) := "00";
  signal debug_o : cpu_debug_o_t;
  signal slp_o : std_logic;
  signal event_i : cpu_event_i_t := NULL_CPU_EVENT_I;
  signal event_o : cpu_event_o_t;
  signal copro_i : cop_i_t;
  signal copro_o : cop_o_t;
  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  constant clk_period : time := 8 ns;
  signal dummy : bit;
  signal pio_data_o : cpu_data_o_t := NULL_DATA_O;
  signal pio_data_i : cpu_data_i_t := (ack => '0', d => (others => '0'));
  signal data_select : data_bus_device_t;
  shared variable ENDSIM : boolean := false;
  signal db_we : std_logic_vector(3 downto 0);
begin
  rst <= '1', '0' after 10 ns;
  clk_gen : process
  begin
    if ENDSIM = false then
      clk <= '0';
      wait for (clk_period / 2);
      clk <= '1';
      wait for (clk_period / 2);
    else
      wait;
    end if;
  end process;
  process (data_master_o)
    variable dev : data_bus_device_t;
  begin
    if data_master_o.en = '0' then
      dev := DEV_NONE;
    else
      dev := decode_data_address(data_master_o.a);
      -- Make SRAM the default. Would prefer not to do this, but not
      -- sure how many things depend on defaulting to SRAM. For example,
      -- my build of sdboot has a 4 byte stack at 0x300000 and loading
      -- it in gdb prints errors.
      if dev = DEV_NONE then
        dev := DEV_SRAM;
      end if;
    end if;
    data_select <= dev;
  end process;
  data_buses(master_i => data_master_i, master_o => data_master_o,
             selected => data_select,
             slaves_i => data_slaves_i, slaves_o => data_slaves_o);
  data_slaves_i(DEV_NONE) <= loopback_bus(data_slaves_o(DEV_NONE));
  data_slaves_i(DEV_SPI) <= loopback_bus(data_slaves_o(DEV_SPI));
  data_slaves_i(DEV_UART0) <= loopback_bus(data_slaves_o(DEV_UART0));
  data_slaves_i(DEV_DDR) <= loopback_bus(data_slaves_o(DEV_DDR));
  pio_data_i.d <= (others => '0');
  pio_data_i.ack <= pio_data_o.en;
  instruction_buses(master_i => instr_master_i, master_o => instr_master_o,
                    selected => decode_instr_address(instr_master_o.a),
                    slaves_i => instr_slaves_i, slaves_o => instr_slaves_o);
  pio_data_o <= data_slaves_o(DEV_PIO);
  data_slaves_i(DEV_PIO) <= pio_data_i;
  with debug_i_cmd select
    debug_i.cmd <=
    BREAK when "00",
    STEP when "01",
    INSERT when "10",
    CONTINUE when others;
  splice_instr_data_bus(instr_slaves_o(DEV_DDR), instr_slaves_i(DEV_DDR),
                        instrd_slaves_o(DEV_DDR), instrd_slaves_i(DEV_DDR));
  cpu1: configuration work.cpu_sim
            port map(clk => clk, rst => rst,
                     db_o => data_master_o, db_i => data_master_i,
                     inst_o => instr_master_o, inst_i => instr_master_i,
                     debug_o => debug_o, debug_i => debug_i,
                     event_i => event_i, event_o => event_o,
                     cop_o => copro_o, cop_i => copro_i);
  copro1: entity work.cpusim_miniaic2(fullrw)
       port map (clk_sys => clk, rst_i => rst, cpa => copro_o, cpy => copro_i);
  mon_mem_bus: bus_monitor generic map (memblock => "data sram")
          port map(clk => clk, rst => rst,
                   cpu_bus_o => data_slaves_o(DEV_SRAM),
                   cpu_bus_i => data_slaves_i(DEV_SRAM));
  mon_instr_sram_bus: bus_monitor generic map (memblock => "instruction sram fetch")
        port map(clk => clk, rst => rst,
                 cpu_bus_o => instrd_slaves_o(DEV_SRAM),
                 cpu_bus_i => instrd_slaves_i(DEV_SRAM));
  mon_instr_ddr_bus: bus_monitor generic map (memblock => "instruction ddr fetch")
        port map(clk => clk, rst => rst,
                 cpu_bus_o => instrd_slaves_o(DEV_DDR),
                 cpu_bus_i => instrd_slaves_i(DEV_DDR));
  sram : entity work.cpu_sram
    port map(clk => clk,
             ibus_i => instr_slaves_o(DEV_SRAM),
             ibus_o => instr_slaves_i(DEV_SRAM),
             db_i => data_slaves_o(DEV_SRAM),
             db_o => data_slaves_i(DEV_SRAM));
  -- intercept and print PIO and UART writes
  process
    variable uart_line : line;
    variable l : line;
    variable c : character;
  begin
    loop
      wait until clk'event and clk = '1';
      if pio_data_o.wr = '1' and pio_data_o.a = x"ABCD0000" then
        write(l, string'("LED: Write "));
        hwrite(l, pio_data_o.d);
        write(l, " at " & time'image(now));
        writeline(output, l);
      end if;
      if data_slaves_o(DEV_UART0).wr = '1' and data_slaves_o(DEV_UART0).a = x"ABCD0104" then
        c := character'val(to_integer(unsigned(data_slaves_o(DEV_UART0).d(7 downto 0))));
        if character'pos(c) = 10 then -- newline
          writeline(output, uart_line);
        else
          write(uart_line, c);
          if c = ';' then
            -- hack to better display the gdb remote protocol messages
            writeline(output, uart_line);
          end if;
        end if;
      end if;
    end loop;
  end process;
end;
