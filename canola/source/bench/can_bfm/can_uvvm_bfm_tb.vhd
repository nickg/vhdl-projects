use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.can_bfm_pkg.all;
use work.can_uvvm_bfm_pkg.all;
use work.can_register_pkg.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_wishbone;
use bitvis_vip_wishbone.wb_bfm_pkg.all;

entity can_uvvm_bfm_tb is
end entity can_uvvm_bfm_tb;

architecture tb of can_uvvm_bfm_tb is
  constant C_CLK_PERIOD : time       := 25000 ps; -- 40 Mhz
  constant C_CLK_FREQ   : integer := 1e9 ns / C_CLK_PERIOD;

  constant WB_DATA_WIDTH : natural := 8;
  constant WB_ADDR_WIDTH : natural := 8;

  -- Copied from Bitvis IRQC testbench
  procedure clock_gen(
    signal   clock_signal  : inout std_logic;
    signal   clock_ena     : in    boolean;
    constant clock_period  : in    time
    ) is
    variable v_first_half_clk_period : time := C_CLK_PERIOD / 2;
  begin
    loop
      if not clock_ena then
        wait until clock_ena;
      end if;
      wait for v_first_half_clk_period;
      clock_signal <= not clock_signal;
      wait for (clock_period - v_first_half_clk_period);
      clock_signal <= not clock_signal;
    end loop;
  end;

  signal clock_ena : boolean   := false;
  signal clk       : std_logic := '0';
  signal reset     : std_logic := '0';

  -- Shared CAN bus signal
  signal can_bus_signal    : std_logic;

  -- CAN signals used by BFM
  signal can_bfm_tx        : std_logic := '1';
  signal can_bfm_rx        : std_logic := '1';

  -- CAN signals used by OpenCores CAN Controller
  signal can_ctrl_tx         : std_logic := '1';
  signal can_ctrl_rx         : std_logic := '1';
  signal can_ctrl_irq_n      : std_logic := '1';
  signal can_ctrl_bus_off_on : std_logic := '0';

  -- Wishbone interface for CAN controller
  signal wbm_can_ctrl_if : t_wbm_if (dat_o(WB_DATA_WIDTH-1 downto 0), addr_o(WB_ADDR_WIDTH-1 downto 0),
                                     dat_i(WB_DATA_WIDTH-1 downto 0)) := init_wbm_if_signals(8, 8);


begin  -- architecture tb

  can_bus_signal <= 'H';
  can_bus_signal <= '0' when can_bfm_tx = '0' else 'Z';
  can_bus_signal <= '0' when can_ctrl_tx = '0' else 'Z';
  can_bfm_rx     <= '1' ?= can_bus_signal;
  can_ctrl_rx    <= '1' ?= can_bus_signal;

  -- Set upt clock generator
  clock_gen(clk, clock_ena, C_CLK_PERIOD);


  iCAN_CTRL : entity work.can_top
    port map
    (
      clk_i      => clk,
      rx_i       => can_ctrl_rx,
      tx_o       => can_ctrl_tx,
      bus_off_on => can_ctrl_bus_off_on,
      irq_on     => can_ctrl_irq_n,
      clkout_o   => open,
      wb_clk_i   => clk,
      wb_rst_i   => reset,
      wb_dat_i   => wbm_can_ctrl_if.dat_o,
      wb_dat_o   => wbm_can_ctrl_if.dat_i,
      wb_cyc_i   => wbm_can_ctrl_if.cyc_o,
      wb_stb_i   => wbm_can_ctrl_if.stb_o,
      wb_we_i    => wbm_can_ctrl_if.we_o,
      wb_adr_i   => wbm_can_ctrl_if.addr_o,
      wb_ack_o   => wbm_can_ctrl_if.ack_i
      );


  p_main: process
    constant C_SCOPE     : string  := C_TB_SCOPE_DEFAULT;

    -- Pulse a signal for a number of clock cycles.
    -- Source: irqc_tb.vhd from Bitvis UVVM 1.4.0
    procedure pulse(
      signal   target          : inout std_logic;
      signal   clock_signal    : in    std_logic;
      constant num_periods     : in    natural;
      constant msg             : in    string
    ) is
    begin
      if num_periods > 0 then
        wait until falling_edge(clock_signal);
        target  <= '1';
        for i in 1 to num_periods loop
          wait until falling_edge(clock_signal);
        end loop;
      else
        target  <= '1';
        wait for 0 ns;  -- Delta cycle only
      end if;
      target  <= '0';
      log(ID_SEQUENCER_SUB, msg, C_SCOPE);
    end;


    -- Log overloads for simplification
    procedure log(
      msg   : string) is
    begin
      log(ID_SEQUENCER, msg, C_SCOPE);
    end;

    procedure init_wishbone_signals is
    begin
      wbm_can_ctrl_if.dat_o  <= (others => '0');
      wbm_can_ctrl_if.addr_o <= (others => '0');
      wbm_can_ctrl_if.we_o   <= '0';
      wbm_can_ctrl_if.cyc_o  <= '0';
      wbm_can_ctrl_if.stb_o  <= '0';
      log(ID_SEQUENCER_SUB, "Wishbone signals initialized", C_SCOPE);
    end;

    ---------------------------------------------------------------------------
    -- Procedures for wb_bfm
    ---------------------------------------------------------------------------
    procedure wb_check (
      constant addr_value       : in  natural;
      constant data_exp         : in  std_logic_vector;
      constant alert_level      : in  t_alert_level             := error;
      constant msg              : in  string;
      signal   wb_if            : inout t_wbm_if;
      constant scope            : in  string                    := C_SCOPE;
      constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
      constant config           : in  t_wb_bfm_config           := C_WB_BFM_CONFIG_DEFAULT
    ) is
    begin
      wb_check(std_logic_vector(to_unsigned(addr_value, WB_ADDR_WIDTH)), data_exp, error, msg, clk, wb_if, scope, msg_id_panel, config);
    end procedure wb_check;

    procedure wb_write (
      constant addr_value       : in  natural;
      constant data_value       : in  std_logic_vector;
      constant msg              : in  string;
      signal   wb_if            : inout t_wbm_if;
      constant scope            : in  string                    := C_SCOPE;
      constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
      constant config           : in  t_wb_bfm_config           := C_WB_BFM_CONFIG_DEFAULT
    ) is
    begin
      wb_write(std_logic_vector(to_unsigned(addr_value, WB_ADDR_WIDTH)), data_value, msg, clk, wb_if, scope, msg_id_panel, config);
    end procedure wb_write;

    procedure wb_read (
      constant addr_value       : in  natural;
      variable data_value       : out std_logic_vector;
      constant msg              : in  string;
      signal   wb_if            : inout t_wbm_if;
      constant scope            : in  string                    := C_SCOPE;
      constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
      constant config           : in  t_wb_bfm_config           := C_WB_BFM_CONFIG_DEFAULT;
      constant proc_name        : in  string                    := "wb_read"  -- overwrite if called from other procedure like wb_check
    ) is
    begin
      wb_read(std_logic_vector(to_unsigned(addr_value, WB_ADDR_WIDTH)), data_value, msg, clk, wb_if, scope, msg_id_panel, config);
    end procedure wb_read;


    variable seed1     : positive := 12345;
    variable seed2     : positive := 6789;

    procedure generate_random_can_message (
      variable arb_id       : out std_logic_vector(28 downto 0);
      variable data         : out can_payload_t;
      variable data_length  : out natural;
      variable remote_frame : out std_logic;
      constant extended_id  : in  boolean := false
      ) is
      variable rand_real : real;
      variable rand_id   : natural;
      variable rand_byte : natural;
    begin
      uniform(seed1, seed2, rand_real);
      data_length := natural(round(rand_real * real(8)));

      uniform(seed1, seed2, rand_real);
      if rand_real > 0.5 then
        remote_frame := '1';
      else
        remote_frame := '0';
      end if;

      uniform(seed1, seed2, rand_real);
      if extended_id = true then
        rand_id             := natural(round(rand_real * real(2**29-1)));
        arb_id(28 downto 0) := std_logic_vector(to_unsigned(rand_id, 29));
      else
        rand_id              := natural(round(rand_real * real(2**11-1)));
        arb_id(28 downto 11) := (others => '0');
        arb_id(10 downto 0)  := std_logic_vector(to_unsigned(rand_id, 11));
      end if;

      if remote_frame = '0' then
        for byte_num in 0 to 7 loop
          if byte_num < data_length then
            uniform(seed1, seed2, rand_real);
            rand_byte           := natural(round(rand_real * real(255)));
            data(byte_num) := std_logic_vector(to_unsigned(rand_byte, 8));
          else
            data(byte_num) := x"00";
          end if;
        end loop;  -- byte_num
      end if;

    end procedure generate_random_can_message;

    procedure can_ctrl_enable_basic_mode_operation (
      constant acceptance_code : in std_logic_vector(7 downto 0);
      constant acceptance_mask : in std_logic_vector(7 downto 0)
      ) is
    begin
      log(ID_LOG_HDR, "Check that CAN controller is in RESET mode", C_SCOPE);
      ------------------------------------------------------------
      wb_check(C_CAN_CMR, x"FF", error, "Reading CMR should return FF in basic mode", wbm_can_ctrl_if);
      wb_check(C_CAN_BM_CR, "001----1", error, "Check that reset request bit is set (reset mode)", wbm_can_ctrl_if);


      log(ID_LOG_HDR, "Setting up CAN controller acceptance code and mask", C_SCOPE);
      ------------------------------------------------------------
      wb_write(C_CAN_BM_ACR, acceptance_code, "CAN acceptance code", wbm_can_ctrl_if);
      wb_write(C_CAN_BM_AMR, acceptance_mask, "CAN acceptance mask", wbm_can_ctrl_if);

      wb_check(C_CAN_BM_ACR, acceptance_code, error, "CAN acceptance code", wbm_can_ctrl_if);
      wb_check(C_CAN_BM_AMR, acceptance_mask, error, "CAN acceptance mask", wbm_can_ctrl_if);


      log(ID_LOG_HDR, "Setting up CAN controller bus timing register for 1Mbps", C_SCOPE);
      ------------------------------------------------------------
      wb_write(C_CAN_BTR0, x"01", "4x baud prescale and minimum synch jump width time", wbm_can_ctrl_if);
      wb_write(C_CAN_BTR1, x"25", "7 baud clocks before and 3 after sampling point, tSEG1=6 and tSEG2=3", wbm_can_ctrl_if);

      wb_check(C_CAN_BTR0, x"01", error, "4x baud prescale and minimum synch jump width time", wbm_can_ctrl_if);
      wb_check(C_CAN_BTR1, x"25", error, "7 baud clocks before and 3 after sampling point, tSEG1=6 and tSEG2=3, for CAN0", wbm_can_ctrl_if);


      log(ID_LOG_HDR, "Configure CAN controller for Operation Mode", C_SCOPE);
      ------------------------------------------------------------
      wb_write(C_CAN_BM_CR, "00111110", "Interrupts enabled, operation mode", wbm_can_ctrl_if);
      wb_check(C_CAN_BM_CR, "00111110", error, "Interrupts enabled, operation mode", wbm_can_ctrl_if);
    end procedure can_ctrl_enable_basic_mode_operation;

    procedure can_ctrl_enable_ext_mode_operation(
      -- Todo: Wrong length for acceptance code/mask for extended mode?
      constant acceptance_code : in std_logic_vector(7 downto 0);
      constant acceptance_mask : in std_logic_vector(7 downto 0)) is
    begin
    end procedure can_ctrl_enable_ext_mode_operation;

    procedure can_ctrl_send_basic_mode (
      constant arb_id       : in std_logic_vector(10 downto 0);
      constant data         : in can_payload_t;
      constant data_length  : in natural;
      constant remote_frame : in std_logic;
      constant msg          : in string;
      constant timeout      : in time                  := 1 ms;
      constant scope        : in string                := C_SCOPE;
      constant msg_id_panel : in t_msg_id_panel        := shared_msg_id_panel;
      constant config       : in t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
      variable proc_name    :    string                := "can_ctrl_send_basic_mode")
    is
      variable tx_id1      : std_logic_vector(7 downto 0);
      variable tx_id2      : std_logic_vector(7 downto 0);
      variable can_irq_reg : std_logic_vector(7 downto 0);
      variable v_proc_call : line;
    begin
      wb_read(C_CAN_IR, can_irq_reg, "Read out IR register to clear interrupts", wbm_can_ctrl_if);

      -- Format procedure call string
      write(v_proc_call, to_string("can_ctrl_send_basic_mode(ID:"));
      write(v_proc_call, to_string(arb_id, HEX, AS_IS, INCL_RADIX));
      write(v_proc_call, to_string(", Length:"));
      write(v_proc_call, to_string(data_length, 1));

      -- Format procedure call string for remote frame
      if remote_frame = '1' then
        write(v_proc_call, to_string(", RTR"));
      end if;

      tx_id1 := arb_id(10 downto 3);
      tx_id2 := arb_id(2 downto 0) & remote_frame & std_logic_vector(to_unsigned(data_length, 4));

      wb_write(C_CAN_BM_TXB_ID1, tx_id1, "Set TXID1", wbm_can_ctrl_if);
      wb_write(C_CAN_BM_TXB_ID2, tx_id2, "Set TXID2", wbm_can_ctrl_if);

      -- Write payload bytes to TX buffer and
      -- format procedure call string with data
      if remote_frame = '0' and data_length > 0 then
        write(v_proc_call, to_string(", Data:0x"));

        for byte_num in 0 to data_length-1 loop
          wb_write(C_CAN_BM_TXB_DATA1+byte_num,
                   data(byte_num),
                   "Write byte " & to_string(byte_num, 1) & " to TX buffer.",
                   wbm_can_ctrl_if);

          write(v_proc_call, to_string(data(byte_num), HEX));
        end loop;
      end if;
      write(v_proc_call, to_string(")"));

      wb_write(C_CAN_CMR, x"01", "Request transmission on CAN0", wbm_can_ctrl_if);

      if proc_name = "can_ctrl_send_basic_mode" then
        log(config.id_for_bfm, v_proc_call.all & "=> completed. " & msg, scope, msg_id_panel);
      end if;
    end procedure can_ctrl_send_basic_mode;


    procedure can_ctrl_wait_and_clr_irq(
      variable timeout : in time := 1 ms)
    is
      variable can_irq_reg : std_logic_vector(7 downto 0);
    begin
      if can_ctrl_irq_n = '1' then
        wait until can_ctrl_irq_n = '0' for timeout;
      end if;

      wb_read(C_CAN_IR, can_irq_reg, "Read out IR register to clear interrupts", wbm_can_ctrl_if);
    end procedure can_ctrl_wait_and_clr_irq;

    -- Todo:
    -- Can can controller receive both basic and extended frames when it is
    -- in basic mode? Can one procedure do both, or are two procedures needed?
    procedure can_ctrl_recv_basic_mode (
      variable arb_id       : out std_logic_vector(10 downto 0);
      variable data         : out can_payload_t;
      variable data_length  : out natural;
--      variable extended_mode : out std_logic;
      variable remote_frame : out std_logic;
      constant msg          : in  string;
      constant timeout      : in  time                  := 1 ms;
      constant scope        : in  string                := C_SCOPE;
      constant msg_id_panel : in  t_msg_id_panel        := shared_msg_id_panel;
      constant config       : in  t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
      variable proc_name    :     string                := "can_ctrl_recv_basic_mode")
    is
      variable rx_id1      : std_logic_vector(7 downto 0);
      variable rx_id2      : std_logic_vector(7 downto 0);
      variable can_irq_reg : std_logic_vector(7 downto 0);
      variable v_proc_call : line;
    begin
      -- Wait for interrupt (if it is not active)
      if can_ctrl_irq_n = '1' then
        wait until can_ctrl_irq_n = '0' for timeout;
      end if;

      if can_ctrl_irq_n /= '0' then
        alert(warning, "Timeout while waiting for CAN controller to assert interrupt.", C_SCOPE);
        return;
      end if;

      wb_check(C_CAN_IR, "-------1", error, "Check that receive interrupt was set", wbm_can_ctrl_if);

      wb_read(C_CAN_BM_RXB_ID1, rx_id1, "Read out RXID1", wbm_can_ctrl_if);
      wb_read(C_CAN_BM_RXB_ID2, rx_id2, "Read out RXID2", wbm_can_ctrl_if);

      arb_id(10 downto 3) := rx_id1;
      arb_id(2 downto 0) := rx_id2(7 downto 5);
      remote_frame := rx_id2(4);
      data_length := to_integer(unsigned(rx_id2(3 downto 0)));

      -- Format procedure call string
      write(v_proc_call, to_string("can_ctrl_recv_basic_mode() => ID: "));
      write(v_proc_call, to_string(arb_id, HEX, AS_IS, INCL_RADIX));
      write(v_proc_call, to_string(", Length: "));
      write(v_proc_call, to_string(data_length, 1));

      -- Format procedure call string for remote frame
      if remote_frame = '1' then
        write(v_proc_call, to_string(", RTR"));

      -- Read in data from buffer, and
      -- format procedure call string for data frame
      elsif remote_frame = '0' and data_length > 0 then
        write(v_proc_call, to_string(", Data: 0x"));

        for byte_num in 0 to data_length-1 loop
          wb_read(C_CAN_BM_RXB_DATA1+byte_num,
                  data(byte_num),
                  "Read byte " & to_string(byte_num, 1) & " from RX buffer.",
                  wbm_can_ctrl_if);

          write(v_proc_call, to_string(data(byte_num), HEX));
        end loop;
      end if;

      wb_write(C_CAN_CMR, "00000100", "Release receive buffer", wbm_can_ctrl_if);

      if proc_name = "can_ctrl_recv_basic_mode" then
        log(config.id_for_bfm, v_proc_call.all & ". " & msg, scope, msg_id_panel);
      end if;

    end procedure can_ctrl_recv_basic_mode;


    variable xmit_arb_id       : std_logic_vector(28 downto 0);
    constant xmit_ext_id       : std_logic := '0';
    variable xmit_data         : can_payload_t := (others => x"00");
    variable xmit_data_length  : natural;
    variable xmit_remote_frame : std_logic;
    variable recv_arb_id       : std_logic_vector(28 downto 0);
    variable recv_data         : can_payload_t;
    variable recv_ext_id       : std_logic     := '0';
    variable recv_remote_frame : std_logic     := '0';
    variable recv_data_length  : natural       := 0;
    variable arb_lost          : std_logic     := '0';

  begin
    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    --disable_log_msg(ALL_MESSAGES);
    --enable_log_msg(ID_LOG_HDR);

    log(ID_LOG_HDR, "Start simulation of testbench for CAN bus BFM", C_SCOPE);
    ------------------------------------------------------------

    --set_inputs_passive(VOID);
    clock_ena <= true;   -- to start clock generator
    pulse(reset, clk, 10, "Pulsed reset-signal - active for 250 ns");

    wait for 100 ns;

    can_ctrl_enable_basic_mode_operation(x"AA", x"FF");


    ------------------------------------------------------------
    -- Test data transmission from CAN BFM to CAN controller
    ------------------------------------------------------------
    for rand_test_num in 0 to 99 loop
      wait for 200 ns;

      log(ID_LOG_HDR, "Generate random CAN message and transmit with CAN controller", C_SCOPE);
      ------------------------------------------------------------
      generate_random_can_message (xmit_arb_id,
                                   xmit_data,
                                   xmit_data_length,
                                   xmit_remote_frame,
                                   false);

      can_ctrl_send_basic_mode(xmit_arb_id(10 downto 0),
                               xmit_data,
                               xmit_data_length,
                               xmit_remote_frame,
                               "Send random message from CAN controller");


      log(ID_LOG_HDR, "Receive random message with CAN BFM", C_SCOPE);
      ------------------------------------------------------------
      can_uvvm_check(xmit_arb_id,
                     xmit_ext_id,
                     xmit_remote_frame,
                     '0',               -- Don't send remote frame first
                     xmit_data,
                     xmit_data_length,
                     "Receive and check random message with CAN BFM",
                     clk,
                     can_bfm_tx,
                     can_bfm_rx,
                     error);

    end loop;  -- rand_test_num

    can_ctrl_wait_and_clr_irq;

    ------------------------------------------------------------
    -- Test data transmission from CAN controller to CAN BFM
    ------------------------------------------------------------
    for rand_test_num in 0 to 99 loop
      log(ID_LOG_HDR, "Generate random CAN message and transmit with CAN BFM", C_SCOPE);
      ------------------------------------------------------------
      generate_random_can_message (xmit_arb_id,
                                   xmit_data,
                                   xmit_data_length,
                                   xmit_remote_frame,
                                   false);

      can_uvvm_write(xmit_arb_id,
                     xmit_ext_id,
                     xmit_remote_frame,
                     xmit_data,
                     xmit_data_length,
                     "Send random message with CAN BFM",
                     clk,
                     can_bfm_tx,
                     can_bfm_rx);


      log(ID_LOG_HDR, "Receive random message with CAN controller", C_SCOPE);
      ------------------------------------------------------------
      can_ctrl_recv_basic_mode(recv_arb_id(10 downto 0),
                               recv_data,
                               recv_data_length,
                               recv_remote_frame,
                               "Receive random message from CAN BFM");

      wait for 200 ns;
    end loop;  -- rand_test_num


    wait for 1000 ns;             -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.finish;
    wait;  -- to stop completely

  end process p_main;


end architecture tb;
