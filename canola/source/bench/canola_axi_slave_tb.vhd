-------------------------------------------------------------------------------
-- Title      : UVVM Testbench for Canola CAN Controller AXI-lite slave
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_axi_slave_tb.vhd
-- Author     : Simon Voigt Nesbo (svn@hvl.no)
-- Company    : Western Norway University of Applied Sciences
-- Created    : 2019-12-17
-- Last update: 2020-08-26
-- Platform   :
-- Target     :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: UVVM testbench for AXI-lite slave version
--              of the Canola CAN controller
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                  Description
-- 2019-12-17  1.0      svn                     Created
-------------------------------------------------------------------------------

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_axilite;
use bitvis_vip_axilite.axilite_bfm_pkg.all;

library work;
use work.axi_pkg.all;
use work.canola_axi_slave_pif_pkg.all;
use work.canola_pkg.all;
use work.canola_tb_pkg.all;
use work.can_bfm_pkg.all;
use work.can_uvvm_bfm_pkg.all;

-- test bench entity
entity canola_axi_slave_tb is
  generic (
    G_TMR_TOP_MODULE_EN : boolean := false;  -- Use canola_axi_slave_tmr instead of canola_axi_slave
    G_SEE_MITIGATION_EN : boolean := false); -- Enable TMR in canola_axi_slave_tmr
end canola_axi_slave_tb;

architecture tb of canola_axi_slave_tb is

  constant C_CLK_PERIOD : time       := 6.25 ns; -- 160 Mhz
  constant C_CLK_FREQ   : integer    := 1e9 ns / C_CLK_PERIOD;

  constant C_CAN_BAUD_PERIOD  : time    := 1000 ns;  -- 1 MHz
  constant C_CAN_BAUD_FREQ    : integer := 1e9 ns / C_CAN_BAUD_PERIOD;

  -- Indicates where in a bit the Rx sample point should be
  -- Real value from 0.0 to 1.0.
  constant C_CAN_SAMPLE_POINT : real    := 0.7;

  constant C_TIME_QUANTA_CLOCK_SCALE_VAL : natural := 3;

  constant C_DATA_LENGTH_MAX : natural := 1000;
  constant C_NUM_ITERATIONS  : natural := 100;

  constant C_BUS_REG_WIDTH : natural := 32;

  -- Generate a clock with a given period,
  -- based on clock_gen from Bitvis IRQC testbench
  procedure clock_gen(
    signal clock_signal          : inout std_logic;
    signal clock_ena             : in    boolean;
    constant clock_period        : in    time
    ) is
    variable v_first_half_clk_period : time;
  begin
    loop
      if not clock_ena then
        wait until clock_ena;
      end if;

      v_first_half_clk_period := clock_period / 2;

      wait for v_first_half_clk_period;
      clock_signal <= not clock_signal;
      wait for (clock_period - v_first_half_clk_period);
      clock_signal <= not clock_signal;
    end loop;
  end;

  signal s_clock_ena      : boolean   := false;
  signal s_can_baud_clk   : std_logic := '0';

  signal s_reset            : std_logic := '0';
  signal s_clk              : std_logic := '0';

  -- Signals for CAN controller
  signal s_can_ctrl_tx       : std_logic;
  signal s_can_ctrl_rx       : std_logic;
  signal s_can_rx_valid_irq  : std_logic;
  signal s_can_tx_done_irq   : std_logic;
  signal s_can_tx_failed_irq : std_logic;
  signal s_can_axi_clk       : std_logic;
  signal s_can_axi_areset_n  : std_logic;
  signal s_can_axi_awaddr    : std_logic_vector(C_CANOLA_AXI_SLAVE_ADDR_WIDTH-1 downto 0);
  signal s_can_axi_awvalid   : std_logic;
  signal s_can_axi_awready   : std_logic;
  signal s_can_axi_wdata     : std_logic_vector(C_CANOLA_AXI_SLAVE_DATA_WIDTH-1 downto 0);
  signal s_can_axi_wvalid    : std_logic;
  signal s_can_axi_wready    : std_logic;
  signal s_can_axi_bresp     : std_logic_vector(1 downto 0);
  signal s_can_axi_bvalid    : std_logic;
  signal s_can_axi_bready    : std_logic;
  signal s_can_axi_araddr    : std_logic_vector(C_CANOLA_AXI_SLAVE_ADDR_WIDTH-1 downto 0);
  signal s_can_axi_arvalid   : std_logic;
  signal s_can_axi_arready   : std_logic;
  signal s_can_axi_rdata     : std_logic_vector(C_CANOLA_AXI_SLAVE_DATA_WIDTH-1 downto 0);
  signal s_can_axi_rresp     : std_logic_vector(1 downto 0);
  signal s_can_axi_rvalid    : std_logic;
  signal s_can_axi_rready    : std_logic;

  -- CAN signals used by BFM
  signal s_can_bfm_tx        : std_logic                      := '1';
  signal s_can_bfm_rx        : std_logic                      := '1';

  -- Shared CAN bus signal
  signal s_can_bus_signal    : std_logic;

  -- Used by p_can_ctrl_irq which monitors interrupts
  -- from the CAN controller and sets these persistent flags
  signal s_got_rx_valid_irq  : std_logic := '0';
  signal s_got_tx_done_irq   : std_logic := '0';
  signal s_got_tx_failed_irq : std_logic := '0';
  signal s_irq_reset         : std_logic := '0';

  constant C_AXI_BUS_ADDR_WIDTH : natural := 32;
  constant C_AXI_BUS_DATA_WIDTH : natural := 32;

  signal s_axi_bfm_if : t_axilite_if(write_address_channel(awaddr(C_AXI_BUS_ADDR_WIDTH-1 downto 0)),
                                     write_data_channel(wdata(C_AXI_BUS_DATA_WIDTH-1 downto 0),
                                                        wstrb((C_AXI_BUS_DATA_WIDTH/8)-1 downto 0)),
                                     read_address_channel(araddr(C_AXI_BUS_ADDR_WIDTH-1 downto 0)),
                                     read_data_channel(rdata(C_AXI_BUS_DATA_WIDTH-1 downto 0)))
    := init_axilite_if_signals(C_AXI_BUS_DATA_WIDTH, C_AXI_BUS_ADDR_WIDTH);

  constant C_AXILITE_BFM_CONFIG : t_axilite_bfm_config := (
    max_wait_cycles            => 100,
    max_wait_cycles_severity   => TB_FAILURE,
    clock_period               => C_CLK_PERIOD,
    clock_period_margin        => 10 ps,
    clock_margin_severity      => NO_ALERT,
    setup_time                 => 1.5 ns,
    hold_time                  => 1.5 ns,
    bfm_sync                   => SYNC_ON_CLOCK_ONLY,
    expected_response          => OKAY,
    expected_response_severity => TB_FAILURE,
    protection_setting         => UNPRIVILIGED_UNSECURE_DATA,
    num_aw_pipe_stages         => 1,
    num_w_pipe_stages          => 1,
    num_ar_pipe_stages         => 1,
    num_r_pipe_stages          => 1,
    num_b_pipe_stages          => 1,
    id_for_bfm                 => ID_BFM,
    id_for_bfm_wait            => ID_BFM_WAIT,
    id_for_bfm_poll            => ID_BFM_POLL
    );

begin

  -- Set up clock generators
  clock_gen(s_clk, s_clock_ena, C_CLK_PERIOD);
  clock_gen(s_can_baud_clk, s_clock_ena, C_CAN_BAUD_PERIOD);

  s_can_axi_clk      <= s_clk;
  s_can_axi_areset_n <= not s_reset;

  s_can_bus_signal <= 'H';
  s_can_bus_signal <= '0' when s_can_ctrl_tx = '0' else 'Z';
  s_can_bus_signal <= '0' when s_can_bfm_tx  = '0' else 'Z';
  s_can_ctrl_rx    <= '1' ?= s_can_bus_signal;
  s_can_bfm_rx     <= '1' ?= s_can_bus_signal;

  -- Connect AXI BFM interface to AXI interfaces for Canola AXI slave
  s_can_axi_awaddr  <= s_axi_bfm_if.write_address_channel.awaddr;
  s_can_axi_awvalid <= s_axi_bfm_if.write_address_channel.awvalid;
  s_can_axi_wdata   <= s_axi_bfm_if.write_data_channel.wdata;
  s_can_axi_wvalid  <= s_axi_bfm_if.write_data_channel.wvalid;
  s_can_axi_bready  <= s_axi_bfm_if.write_response_channel.bready;
  s_can_axi_araddr  <= s_axi_bfm_if.read_address_channel.araddr;
  s_can_axi_arvalid <= s_axi_bfm_if.read_address_channel.arvalid;
  s_can_axi_rready  <= s_axi_bfm_if.read_data_channel.rready;


  s_axi_bfm_if.write_address_channel.awready <= s_can_axi_awready;
  s_axi_bfm_if.write_data_channel.wready     <= s_can_axi_wready;
  s_axi_bfm_if.read_address_channel.arready  <= s_can_axi_arready;
  s_axi_bfm_if.write_response_channel.bresp  <= s_can_axi_bresp;
  s_axi_bfm_if.write_response_channel.bvalid <= s_can_axi_bvalid;
  s_axi_bfm_if.read_data_channel.rdata       <= s_can_axi_rdata;
  s_axi_bfm_if.read_data_channel.rresp       <= s_can_axi_rresp;
  s_axi_bfm_if.read_data_channel.rvalid      <= s_can_axi_rvalid;

  s_axi_bfm_if.write_address_channel.awprot <= (others => '0');
  s_axi_bfm_if.write_data_channel.wstrb     <= (others => '0');


  -----------------------------------------------------------------------------
  -- Generate instances of canola_axi_slave when G_TMR_TOP_MODULE_EN is not set
  -----------------------------------------------------------------------------
  if_not_TMR_generate : if not G_TMR_TOP_MODULE_EN generate
    INST_canola_axi_slave : entity work.canola_axi_slave
      port map (
        CAN_RX            => s_can_ctrl_rx,
        CAN_TX            => s_can_ctrl_tx,
        CAN_RX_VALID_IRQ  => s_can_rx_valid_irq,
        CAN_TX_DONE_IRQ   => s_can_tx_done_irq,
        CAN_TX_FAILED_IRQ => s_can_tx_failed_irq,
        axi_clk           => s_can_axi_clk,
        axi_reset         => s_reset,
        axi_aresetn       => s_can_axi_areset_n,
        axi_awaddr        => s_can_axi_awaddr,
        axi_awvalid       => s_can_axi_awvalid,
        axi_awready       => s_can_axi_awready,
        axi_wdata         => s_can_axi_wdata,
        axi_wvalid        => s_can_axi_wvalid,
        axi_wready        => s_can_axi_wready,
        axi_bresp         => s_can_axi_bresp,
        axi_bvalid        => s_can_axi_bvalid,
        axi_bready        => s_can_axi_bready,
        axi_araddr        => s_can_axi_araddr,
        axi_arvalid       => s_can_axi_arvalid,
        axi_arready       => s_can_axi_arready,
        axi_rdata         => s_can_axi_rdata,
        axi_rresp         => s_can_axi_rresp,
        axi_rvalid        => s_can_axi_rvalid,
        axi_rready        => s_can_axi_rready);
  end generate if_not_TMR_generate;

  -----------------------------------------------------------------------------
  -- Generate instances of canola_axi_slave_tmr when G_TMR_TOP_MODULE_EN is set
  -----------------------------------------------------------------------------
  if_TMR_generate : if G_TMR_TOP_MODULE_EN generate
    INST_canola_axi_slave_tmr : entity work.canola_axi_slave_tmr
      generic map (
        G_SEE_MITIGATION_EN  => G_SEE_MITIGATION_EN,
        G_MISMATCH_OUTPUT_EN => false
        )
      port map (
        CAN_RX                  => s_can_ctrl_rx,
        CAN_TX                  => s_can_ctrl_tx,
        CAN_RX_VALID_IRQ        => s_can_rx_valid_irq,
        CAN_TX_DONE_IRQ         => s_can_tx_done_irq,
        CAN_TX_FAILED_IRQ       => s_can_tx_failed_irq,
        VOTER_MISMATCH_LOGIC    => open,
        VOTER_MISMATCH_COUNTERS => open,
        axi_clk                 => s_can_axi_clk,
        axi_reset               => s_reset,
        axi_aresetn             => s_can_axi_areset_n,
        axi_awaddr              => s_can_axi_awaddr,
        axi_awvalid             => s_can_axi_awvalid,
        axi_awready             => s_can_axi_awready,
        axi_wdata               => s_can_axi_wdata,
        axi_wvalid              => s_can_axi_wvalid,
        axi_wready              => s_can_axi_wready,
        axi_bresp               => s_can_axi_bresp,
        axi_bvalid              => s_can_axi_bvalid,
        axi_bready              => s_can_axi_bready,
        axi_araddr              => s_can_axi_araddr,
        axi_arvalid             => s_can_axi_arvalid,
        axi_arready             => s_can_axi_arready,
        axi_rdata               => s_can_axi_rdata,
        axi_rresp               => s_can_axi_rresp,
        axi_rvalid              => s_can_axi_rvalid,
        axi_rready              => s_can_axi_rready);
  end generate if_TMR_generate;


  -- Monitor CAN controller interrupts and set persistent flags
  p_can_ctrl_irq : process (s_can_rx_valid_irq, s_can_tx_done_irq,
                            s_can_tx_failed_irq, s_irq_reset) is
  begin
    if s_irq_reset = '1' then
      s_got_rx_valid_irq  <= '0';
      s_got_tx_done_irq   <= '0';
      s_got_tx_failed_irq <= '0';
    else

      if s_can_rx_valid_irq = '1' then
        s_got_rx_valid_irq <= '1';
      end if;

      if s_can_tx_done_irq = '1' then
        s_got_tx_done_irq <= '1';
      end if;

      if s_can_tx_failed_irq = '1' then
        s_got_tx_failed_irq <= '1';
      end if;
    end if;
  end process p_can_ctrl_irq;


  p_main: process
    constant C_SCOPE          : string                := C_TB_SCOPE_DEFAULT;
    variable v_can_bfm_config : t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
    variable v_can_bfm_tx     : std_logic             := '1';
    variable v_can_bfm_rx     : std_logic             := '1';

    variable v_xmit_arb_id       : std_logic_vector(28 downto 0);
    variable v_xmit_ext_id       : std_logic                      := '0';
    variable v_xmit_data         : work.can_bfm_pkg.can_payload_t := (others => x"00");
    variable v_xmit_data_length  : natural;
    variable v_xmit_remote_frame : std_logic;
    variable v_xmit_arb_lost     : std_logic     := '0';

    variable v_recv_arb_id       : std_logic_vector(28 downto 0);
    variable v_recv_data         : work.can_bfm_pkg.can_payload_t;
    variable v_recv_ext_id       : std_logic     := '0';
    variable v_recv_remote_frame : std_logic     := '0';
    variable v_recv_data_length  : natural       := 0;
    variable v_recv_timeout      : std_logic;

    variable v_can_tx_status    : can_tx_status_t;
    variable v_can_rx_error_gen : can_rx_error_gen_t := C_CAN_RX_NO_ERROR_GEN;

    variable v_arb_lost_count       : std_logic_vector(C_BUS_REG_WIDTH-1 downto 0);
    variable v_ack_recv_count       : std_logic_vector(C_BUS_REG_WIDTH-1 downto 0);
    variable v_tx_error_count       : std_logic_vector(C_BUS_REG_WIDTH-1 downto 0);
    variable v_rx_msg_count         : std_logic_vector(C_BUS_REG_WIDTH-1 downto 0);
    variable v_rx_crc_error_count   : std_logic_vector(C_BUS_REG_WIDTH-1 downto 0);
    variable v_rx_form_error_count  : std_logic_vector(C_BUS_REG_WIDTH-1 downto 0);
    variable v_rx_stuff_error_count : std_logic_vector(C_BUS_REG_WIDTH-1 downto 0);
    variable v_receive_error_count  : unsigned(C_ERROR_COUNT_LENGTH-1 downto 0);

    variable v_rand_baud_delay : natural;
    variable v_rand_real       : real;

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

    -- Pulse a signal for a number of clock cycles.
    -- Source: irqc_tb.vhd from Bitvis UVVM 1.4.0
    procedure pulse(
      signal   target        : inout  std_logic_vector;
      constant pulse_value   : in     std_logic_vector;
      signal   clock_signal  : in     std_logic;
      constant num_periods   : in     natural;
      constant msg           : in     string) is
    begin
      if num_periods > 0 then
        wait until falling_edge(clock_signal);
        target <= pulse_value;
        for i in 1 to num_periods loop
          wait until falling_edge(clock_signal);
        end loop;
      else
        target <= pulse_value;
        wait for 0 ns;  -- Delta cycle only
      end if;
      target(target'range) <= (others => '0');
      log(ID_SEQUENCER_SUB, "Pulsed to " & to_string(pulse_value, HEX, AS_IS, INCL_RADIX) & ". " & msg, C_SCOPE);
    end;


    -- Log overloads for simplification
    procedure log(
      msg   : string) is
    begin
      log(ID_SEQUENCER, msg, C_SCOPE);
    end;

    variable seed1         : positive := 53267458;
    variable seed2         : positive := 90832486;
    variable v_count       : natural;
    variable v_test_num    : natural;
    variable v_data_length : natural;


    procedure axilite_write(
      constant addr_value         : in  t_canola_axi_slave_addr;
      constant data_value         : in  std_logic_vector;
      constant msg                : in  string) is
    begin
      axilite_write(unsigned(addr_value),
                    data_value,
                    msg,
                    s_can_axi_clk,
                    s_axi_bfm_if,
                    C_SCOPE,
                    shared_msg_id_panel,
                    C_AXILITE_BFM_CONFIG);
    end procedure axilite_write;


    procedure axilite_read(
      constant addr_value         : in  t_canola_axi_slave_addr;
      variable data_value         : out std_logic_vector;
      constant msg                : in  string) is
    begin
      axilite_read(unsigned(addr_value),
                   data_value,
                   msg,
                   s_can_axi_clk,
                   s_axi_bfm_if,
                   C_SCOPE,
                   shared_msg_id_panel,
                   C_AXILITE_BFM_CONFIG);
    end procedure axilite_read;


    procedure axilite_check(
      constant addr_value         : in  t_canola_axi_slave_addr;
      constant data_exp           : in  std_logic_vector;
      constant msg                : in  string) is
    begin
      axilite_check(unsigned(addr_value),
                    data_exp,
                    msg,
                    s_can_axi_clk,
                    s_axi_bfm_if,
                    error,
                    C_SCOPE,
                    shared_msg_id_panel,
                    C_AXILITE_BFM_CONFIG);
    end procedure axilite_check;


    procedure axilite_check(
      constant addr_value         : in  t_canola_axi_slave_addr;
      constant data_exp           : in  natural;
      constant msg                : in  string) is
    begin
      axilite_check(unsigned(addr_value),
                    std_logic_vector(to_unsigned(data_exp, C_CANOLA_AXI_SLAVE_DATA_WIDTH)),
                    msg,
                    s_can_axi_clk,
                    s_axi_bfm_if,
                    error,
                    C_SCOPE,
                    shared_msg_id_panel,
                    C_AXILITE_BFM_CONFIG);
    end procedure axilite_check;


    procedure read_msg_from_controller is
      variable v_rx_msg_id_reg         : t_canola_axi_slave_data;
      variable v_rx_payload_length_reg : t_canola_axi_slave_data;
      variable v_rx_payload0_reg       : t_canola_axi_slave_data;
      variable v_rx_payload1_reg       : t_canola_axi_slave_data;
    begin
      axilite_read(C_ADDR_RX_MSG_ID, v_rx_msg_id_reg, "Read RX_MSG_ID register");
      axilite_read(C_ADDR_RX_PAYLOAD_LENGTH, v_rx_payload_length_reg, "Read RX_PAYLOAD_LENGTH register");
      axilite_read(C_ADDR_RX_PAYLOAD_0, v_rx_payload0_reg, "Read RX_PAYLOAD_0 register");
      axilite_read(C_ADDR_RX_PAYLOAD_1, v_rx_payload1_reg, "Read RX_PAYLOAD_1 register");

      -- Ideally these ranges shouldn't be hardcoded, but the UART tool used to
      -- generate the AXI slave does not generate range constants to be used
      -- with the registers
      v_recv_ext_id                                                     := v_rx_msg_id_reg(0);
      v_recv_remote_frame                                               := v_rx_msg_id_reg(1);
      v_recv_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH) := v_rx_msg_id_reg(30 downto 20);
      v_recv_arb_id(C_ID_B_LENGTH-1 downto 0)                           := v_rx_msg_id_reg(19 downto 2);

      v_recv_data_length := to_integer(unsigned(v_rx_payload_length_reg));

      v_recv_data(0) := v_rx_payload0_reg(7 downto 0);
      v_recv_data(1) := v_rx_payload0_reg(15 downto 8);
      v_recv_data(2) := v_rx_payload0_reg(23 downto 16);
      v_recv_data(3) := v_rx_payload0_reg(31 downto 24);
      v_recv_data(4) := v_rx_payload1_reg(7 downto 0);
      v_recv_data(5) := v_rx_payload1_reg(15 downto 8);
      v_recv_data(6) := v_rx_payload1_reg(23 downto 16);
      v_recv_data(7) := v_rx_payload1_reg(31 downto 24);
    end procedure read_msg_from_controller;


    procedure write_msg_to_controller is
      variable v_tx_msg_id_reg         : t_canola_axi_slave_data;
      variable v_tx_payload_length_reg : t_canola_axi_slave_data;
      variable v_tx_payload0_reg       : t_canola_axi_slave_data;
      variable v_tx_payload1_reg       : t_canola_axi_slave_data;
    begin
      -- Ideally these ranges shouldn't be hardcoded, but the UART tool used to
      -- generate the AXI slave does not generate range constants to be used
      -- with the registers
      v_tx_msg_id_reg(0)            := v_xmit_ext_id;
      v_tx_msg_id_reg(1)            := v_xmit_remote_frame;
      v_tx_msg_id_reg(30 downto 20) := v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH);
      v_tx_msg_id_reg(19 downto 2)  := v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0);

      v_tx_payload_length_reg                          := (others => '0');
      v_tx_payload_length_reg(C_DLC_LENGTH-1 downto 0) := std_logic_vector(to_unsigned(v_xmit_data_length, C_DLC_LENGTH));

      v_tx_payload0_reg(7 downto 0)   := v_xmit_data(0);
      v_tx_payload0_reg(15 downto 8)  := v_xmit_data(1);
      v_tx_payload0_reg(23 downto 16) := v_xmit_data(2);
      v_tx_payload0_reg(31 downto 24) := v_xmit_data(3);
      v_tx_payload1_reg(7 downto 0)   := v_xmit_data(4);
      v_tx_payload1_reg(15 downto 8)  := v_xmit_data(5);
      v_tx_payload1_reg(23 downto 16) := v_xmit_data(6);
      v_tx_payload1_reg(31 downto 24) := v_xmit_data(7);

      axilite_write(C_ADDR_TX_MSG_ID, v_tx_msg_id_reg, "Write TX_MSG_ID register");
      axilite_write(C_ADDR_TX_PAYLOAD_LENGTH, v_tx_payload_length_reg, "Write TX_PAYLOAD_LENGTH register");
      axilite_write(C_ADDR_TX_PAYLOAD_0, v_tx_payload0_reg, "Write TX_PAYLOAD_0 register");
      axilite_write(C_ADDR_TX_PAYLOAD_1, v_tx_payload1_reg, "Write TX_PAYLOAD_1 register");
    end procedure write_msg_to_controller;


    -- Todo 1: Put this in a package file?
    -- Todo 2: Define one message type for use both with BFM and RTL code,
    --         and define can_payload_t in one place..
    procedure generate_random_can_message (
      variable arb_id             : out std_logic_vector(28 downto 0);
      variable data               : out work.can_bfm_pkg.can_payload_t;
      variable data_length        : out natural;
      variable remote_frame       : out std_logic;
      constant extended_id        : in  std_logic := '0';
      constant allow_remote_frame : in  std_logic := '1'
      ) is
      variable rand_real : real;
      variable rand_id   : natural;
      variable rand_byte : natural;
    begin
      uniform(seed1, seed2, rand_real);
      data_length := natural(round(rand_real * real(8)));

      uniform(seed1, seed2, rand_real);
      if rand_real > 0.5 and allow_remote_frame = '1' then
        remote_frame := '1';
      else
        remote_frame := '0';
      end if;

      uniform(seed1, seed2, rand_real);
      if extended_id = '1' then
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
            rand_byte      := natural(round(rand_real * real(255)));
            data(byte_num) := std_logic_vector(to_unsigned(rand_byte, 8));
          else
            data(byte_num) := x"00";
          end if;
        end loop;  -- byte_num
      end if;

    end procedure generate_random_can_message;


    function resize_data (
      constant slv_in : std_logic_vector)
      return std_logic_vector is
    begin
      return std_logic_vector(resize(unsigned(slv_in), C_CANOLA_AXI_SLAVE_DATA_WIDTH));
    end function resize_data;

  begin
    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);

    if G_TMR_TOP_MODULE_EN and G_SEE_MITIGATION_EN then
      set_log_file_name("log/canola_axi_slave_tb_tmr_wrap_tmr_log.txt");
    elsif G_TMR_TOP_MODULE_EN and not G_SEE_MITIGATION_EN then
      set_log_file_name("log/canola_axi_slave_tb_tmr_wrap_no_tmr_log.txt");
    else
      set_log_file_name("log/canola_axi_slave_tb_no_tmr_log.txt");
    end if;


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Start simulation of CAN controller", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_can_bfm_config.can_config.clock_period := C_CLK_PERIOD;

    s_clock_ena <= true;                -- to start clock generator
    pulse(s_reset, s_clk, 10, "Pulsed reset-signal - active for 10 cycles");

    wait until rising_edge(s_clk);
    wait until rising_edge(s_clk);

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #1: Check default/reset values of registers", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    axilite_check(C_ADDR_STATUS,
                  resize_data(c_canola_axi_slave_ro_regs.STATUS.ERROR_STATE &
                              c_canola_axi_slave_ro_regs.STATUS.TX_FAILED &
                              c_canola_axi_slave_ro_regs.STATUS.TX_DONE &
                              c_canola_axi_slave_ro_regs.STATUS.TX_BUSY &
                              c_canola_axi_slave_ro_regs.STATUS.RX_MSG_VALID),
                  "Check STATUS register");

    axilite_check(C_ADDR_CONTROL,
                  resize_data("" & c_canola_axi_slave_pulse_regs.CONTROL.TX_START),
                  "Check CONTROL register");

    axilite_check(C_ADDR_CONFIG,
                  resize_data(c_canola_axi_slave_rw_regs.CONFIG.TX_RETRANSMIT_EN &
                              c_canola_axi_slave_rw_regs.CONFIG.BTL_TRIPLE_SAMPLING_EN),
                  "Check CONFIG register");

    axilite_check(C_ADDR_BTL_PROP_SEG,
                  resize_data(c_canola_axi_slave_rw_regs.BTL_PROP_SEG),
                  "Check BTL_PROP_SEG register");

    axilite_check(C_ADDR_BTL_PHASE_SEG1,
                  resize_data(c_canola_axi_slave_rw_regs.BTL_PHASE_SEG1),
                  "Check BTL_PHASE_SEG1 register");

    axilite_check(C_ADDR_BTL_PHASE_SEG2,
                  resize_data(c_canola_axi_slave_rw_regs.BTL_PHASE_SEG2),
                  "Check BTL_PHASE_SEG2 register");

    axilite_check(C_ADDR_BTL_SYNC_JUMP_WIDTH,
                  resize_data(c_canola_axi_slave_rw_regs.BTL_SYNC_JUMP_WIDTH),
                  "Check BTL_SYNC_JUMP_WIDTH register");

    axilite_check(C_ADDR_TIME_QUANTA_CLOCK_SCALE,
                  resize_data(c_canola_axi_slave_rw_regs.TIME_QUANTA_CLOCK_SCALE),
                  "Check TIME_QUANTA_CLOCK_SCALE register");

    axilite_check(C_ADDR_TRANSMIT_ERROR_COUNT,
                  resize_data(c_canola_axi_slave_ro_regs.TRANSMIT_ERROR_COUNT),
                  "Check TRANSMIT_ERROR_COUNT register");

    axilite_check(C_ADDR_RECEIVE_ERROR_COUNT,
                  resize_data(c_canola_axi_slave_ro_regs.RECEIVE_ERROR_COUNT),
                  "Check RECEIVE_ERROR_COUNT register");

    axilite_check(C_ADDR_TX_MSG_SENT_COUNT,
                  resize_data(c_canola_axi_slave_ro_regs.TX_MSG_SENT_COUNT),
                  "Check TX_MSG_SENT_COUNT register");

    axilite_check(C_ADDR_TX_ACK_ERROR_COUNT,
                  resize_data(c_canola_axi_slave_ro_regs.TX_ACK_ERROR_COUNT),
                  "Check TX_ACK_ERROR_COUNT register");

    axilite_check(C_ADDR_TX_ARB_LOST_COUNT,
                  resize_data(c_canola_axi_slave_ro_regs.TX_ARB_LOST_COUNT),
                  "Check TX_ARB_LOST_COUNT register");

    axilite_check(C_ADDR_TX_BIT_ERROR_COUNT,
                  resize_data(c_canola_axi_slave_ro_regs.TX_BIT_ERROR_COUNT),
                  "Check TX_BIT_ERROR_COUNT register");

    axilite_check(C_ADDR_TX_RETRANSMIT_COUNT,
                  resize_data(c_canola_axi_slave_ro_regs.TX_RETRANSMIT_COUNT),
                  "Check TX_RETRANSMIT_COUNT register");

    axilite_check(C_ADDR_RX_MSG_RECV_COUNT,
                  resize_data(c_canola_axi_slave_ro_regs.RX_MSG_RECV_COUNT),
                  "Check RX_MSG_RECV_COUNT register");

    axilite_check(C_ADDR_RX_CRC_ERROR_COUNT,
                  resize_data(c_canola_axi_slave_ro_regs.RX_CRC_ERROR_COUNT),
                  "Check RX_CRC_ERROR_COUNT register");

    axilite_check(C_ADDR_RX_FORM_ERROR_COUNT,
                  resize_data(c_canola_axi_slave_ro_regs.RX_FORM_ERROR_COUNT),
                  "Check RX_FORM_ERROR_COUNT register");

    axilite_check(C_ADDR_RX_STUFF_ERROR_COUNT,
                  resize_data(c_canola_axi_slave_ro_regs.RX_STUFF_ERROR_COUNT),
                  "Check RX_STUFF_ERROR_COUNT register");


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #2: Basic ID msg from BFM to Canola CAN controller", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num    := 0;
    v_xmit_ext_id := '0';

    while v_test_num < C_NUM_ITERATIONS loop
      pulse(s_irq_reset, s_clk, 1, "Reset IRQ flags");

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      wait until rising_edge(s_clk);

      can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     v_xmit_data,
                     v_xmit_data_length,
                     "Send random message with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     v_can_tx_status,
                     C_CAN_RX_NO_ERROR_GEN,
                     v_can_bfm_config);

      wait until s_got_rx_valid_irq = '1' for 10*C_CAN_BAUD_PERIOD;

      check_value(s_got_rx_valid_irq, '1', error, "Check that CAN controller received msg.");
      read_msg_from_controller;
      check_value(v_recv_ext_id, v_xmit_ext_id, error, "Check extended ID bit");

      if v_xmit_ext_id = '1' then
        check_value(v_recv_arb_id, v_xmit_arb_id, error, "Check received ID");
      else
        -- Only check the relevant ID bits for non-extended ID
        check_value(v_recv_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                    v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                    error,
                    "Check received ID");
      end if;

      check_value(v_recv_remote_frame, v_xmit_remote_frame, error, "Check received RTR bit");
      check_value(v_recv_data_length, v_xmit_data_length, error, "Check data length");

      -- Don't check data for remote frame requests
      if v_xmit_remote_frame = '0' then
        for idx in 0 to v_xmit_data_length-1 loop
          check_value(v_recv_data(idx), v_xmit_data(idx), error, "Check received data");
        end loop;
      end if;

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    axilite_check(C_ADDR_RX_MSG_RECV_COUNT, C_NUM_ITERATIONS, "Check number of received messages");

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #3: Basic ID msg from Canola CAN controller to BFM", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num    := 0;
    v_xmit_ext_id := '0';

    while v_test_num < C_NUM_ITERATIONS loop
      pulse(s_irq_reset, s_clk, 1, "Reset IRQ flags");

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      write_msg_to_controller;

      axilite_write(C_ADDR_CONTROL, x"00000001", "Start transmit");

      can_uvvm_check(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     '0', -- Don't send remote request and expect response
                     v_xmit_data,
                     v_xmit_data_length,
                     "Receive and check message with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     error,
                     v_can_bfm_config);

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    axilite_check(C_ADDR_TX_MSG_SENT_COUNT, C_NUM_ITERATIONS, "Check number of messages sent");
    axilite_check(C_ADDR_TX_ACK_ERROR_COUNT, 0, "Check ACK error count is zero");

    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #4: Extended ID msg from BFM to Canola CAN controller", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num    := 0;
    v_xmit_ext_id := '1';

    while v_test_num < C_NUM_ITERATIONS loop
      pulse(s_irq_reset, s_clk, 1, "Reset IRQ flags");

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      wait until rising_edge(s_clk);

      can_uvvm_write(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     v_xmit_data,
                     v_xmit_data_length,
                     "Send random message with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     v_can_tx_status,
                     C_CAN_RX_NO_ERROR_GEN,
                     v_can_bfm_config);

      wait until s_got_rx_valid_irq = '1' for 10*C_CAN_BAUD_PERIOD;

      check_value(s_got_rx_valid_irq, '1', error, "Check that CAN controller received msg.");
      read_msg_from_controller;
      check_value(v_recv_ext_id, v_xmit_ext_id, error, "Check extended ID bit");

      if v_xmit_ext_id = '1' then
        check_value(v_recv_arb_id, v_xmit_arb_id, error, "Check received ID");
      else
        -- Only check the relevant ID bits for non-extended ID
        check_value(v_recv_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                    v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                    error,
                    "Check received ID");
      end if;

      check_value(v_recv_remote_frame, v_xmit_remote_frame, error, "Check received RTR bit");
      check_value(v_recv_data_length, v_xmit_data_length, error, "Check data length");

      -- Don't check data for remote frame requests
      if v_xmit_remote_frame = '0' then
        for idx in 0 to v_xmit_data_length-1 loop
          check_value(v_recv_data(idx), v_xmit_data(idx), error, "Check received data");
        end loop;
      end if;

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    axilite_check(C_ADDR_RX_MSG_RECV_COUNT, C_NUM_ITERATIONS*2, "Check number of received messages");


    -----------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test #5: Extended ID msg from Canola CAN controller to BFM", C_SCOPE);
    -----------------------------------------------------------------------------------------------
    v_test_num    := 0;
    v_xmit_ext_id := '1';

    while v_test_num < C_NUM_ITERATIONS loop
      pulse(s_irq_reset, s_clk, 1, "Reset IRQ flags");

      generate_random_can_message (v_xmit_arb_id,
                                   v_xmit_data,
                                   v_xmit_data_length,
                                   v_xmit_remote_frame,
                                   v_xmit_ext_id);

      write_msg_to_controller;

      axilite_write(C_ADDR_CONTROL, x"00000001", "Start transmit");

      can_uvvm_check(v_xmit_arb_id(C_ID_A_LENGTH+C_ID_B_LENGTH-1 downto C_ID_B_LENGTH),
                     v_xmit_arb_id(C_ID_B_LENGTH-1 downto 0),
                     v_xmit_ext_id,
                     v_xmit_remote_frame,
                     '0', -- Don't send remote request and expect response
                     v_xmit_data,
                     v_xmit_data_length,
                     "Receive and check message with CAN BFM",
                     s_clk,
                     s_can_bfm_tx,
                     s_can_bfm_rx,
                     error,
                     v_can_bfm_config);

      wait until rising_edge(s_can_baud_clk);
      wait until rising_edge(s_can_baud_clk);

      v_test_num := v_test_num + 1;
    end loop;

    axilite_check(C_ADDR_TX_MSG_SENT_COUNT, C_NUM_ITERATIONS*2, "Check number of messages sent");
    axilite_check(C_ADDR_TX_ACK_ERROR_COUNT, 0, "Check ACK error count is zero");

    -----------------------------------------------------------------------------------------------
    -- Simulation complete
    -----------------------------------------------------------------------------------------------
    wait for 10000 ns;            -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

end process p_main;

end tb;
