-------------------------------------------------------------------------------
-- Title      : CAN Bus UVVM BFM
-- Project    :
-------------------------------------------------------------------------------
-- File       : can_uvvm_bfm_pkg.vhd
-- Author     : Simon Voigt Nesbø  <simon@simon-ThinkPad-T450s>
-- Company    :
-- Created    : 2018-06-20
-- Last update: 2024-02-23
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Bus Functional Model (BFM) for CAN Bus for use with
--              Bitvis UVVM test benches
-------------------------------------------------------------------------------
-- Copyright (c) 2018
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-10-02  1.1      svn     Added can_uvvm_recv_error_flag
-- 2018-06-20  1.0      svn	Created
-------------------------------------------------------------------------------
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library work;
use work.can_bfm_pkg.all;


package can_uvvm_bfm_pkg is
  constant C_SCOPE           : string  := "CAN UVVM BFM";

-- Configuration record to be assigned in the test harness.
  type t_can_uvvm_bfm_config is record
    can_config                  : can_bfm_config_t;
    max_wait_cycles             : integer;
    max_wait_cycles_severity    : t_alert_level;
    arb_lost_severity           : t_alert_level;
    bit_error_severity          : t_alert_level;
    ack_missing_severity        : t_alert_level;
    error_flag_severity         : t_alert_level;
    crc_error_severity          : t_alert_level;
    form_error_severity         : t_alert_level;
    error_flag_timeout_severity : t_alert_level;
    id_for_bfm                  : t_msg_id;
    id_for_bfm_wait             : t_msg_id;
    id_for_bfm_poll             : t_msg_id;
  end record;

  constant C_CAN_UVVM_BFM_CONFIG_DEFAULT : t_can_uvvm_bfm_config := (
    can_config                  => C_CAN_BFM_CONFIG_DEFAULT,
    max_wait_cycles             => 1000,
    max_wait_cycles_severity    => failure,
    arb_lost_severity           => warning,
    bit_error_severity          => failure,
    ack_missing_severity        => failure,
    error_flag_severity         => failure,
    crc_error_severity          => failure,
    form_error_severity         => failure,
    error_flag_timeout_severity => failure,
    id_for_bfm                  => ID_BFM,
    id_for_bfm_wait             => ID_BFM_WAIT,
    id_for_bfm_poll             => ID_BFM_POLL
    );


  -- Transmit a CAN frame
  -- The upper 18 bits of arbitration ID are ignored if extended_id is not set
  -- in the config.
  -- If remote_request is set high, a remote request frame will be sent,
  -- and any specified data is ignored.
  procedure can_uvvm_write (
    constant arb_id_a         : in  std_logic_vector(C_ARB_ID_A_SIZE-1 downto 0);
    constant arb_id_b         : in  std_logic_vector(C_ARB_ID_B_SIZE-1 downto 0);
    constant extended_id      : in  std_logic;
    constant remote_request   : in  std_logic;
    constant data             : in  can_payload_t;
    constant data_length      : in  natural;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal can_tx             : out std_logic;
    signal can_rx             : in  std_logic;
    variable can_tx_status    : out can_tx_status_t;
    constant can_rx_error_gen : in  can_rx_error_gen_t    := C_CAN_RX_NO_ERROR_GEN;
    constant config           : in  t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
    constant scope            : in  string                := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel        := shared_msg_id_panel;
    constant proc_name        : in  string                := "can_uvvm_write"
    );


  -- Wait for an incoming CAN frame
  -- The upper 18 bits of arbitration ID are ignored if extended_id is not set
  -- in the config.
  -- The remote_frame output will be set high if the incoming frame
  -- was a remote frame request.
  -- Data is only valid if the remote_frame output is low
  procedure can_uvvm_read (
    variable arb_id_a       : out std_logic_vector(C_ARB_ID_A_SIZE-1 downto 0);
    variable arb_id_b       : out std_logic_vector(C_ARB_ID_B_SIZE-1 downto 0);
    variable extended_id    : out std_logic;
    variable remote_frame   : out std_logic;
    variable data           : out can_payload_t;
    variable data_length    : out natural;
    constant msg            : in  string;
    signal clk              : in  std_logic;
    signal can_tx           : out std_logic;
    signal can_rx           : in  std_logic;
    variable timeout        : out std_logic;
    constant config         : in  t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
    constant scope          : in  string                := C_SCOPE;
    constant msg_id_panel   : in  t_msg_id_panel        := shared_msg_id_panel;
    constant proc_name      : in  string                := "can_uvvm_read"
    );


  -- Wait for an incoming CAN frame, and compare incoming data to data_exp
  -- The upper 18 bits of arbitration ID are ignored if extended_id is not set
  -- in the config.
  -- If remote_expect is set high, the procedure will expect to receive a
  -- remote frame request
  -- If remote_request is set high, this procedure will first send a
  -- remote frame request and then wait for any incoming CAN message
  -- Setting both remote_expect and remote_request high is illlegal
  procedure can_uvvm_check (
    constant arb_id_a_exp    : in  std_logic_vector(C_ARB_ID_A_SIZE-1 downto 0);
    constant arb_id_b_exp    : in  std_logic_vector(C_ARB_ID_B_SIZE-1 downto 0);
    constant extended_id     : in  std_logic;
    constant remote_expect   : in  std_logic;
    constant remote_request  : in  std_logic;
    constant data_exp        : in  can_payload_t;
    constant data_length_exp : in  natural;
    constant msg             : in  string;
    signal clk               : in  std_logic;
    signal can_tx            : out std_logic;
    signal can_rx            : in  std_logic;
    constant alert_level     : in  t_alert_level         := error;
    constant config          : in  t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
    constant scope           : in  string                := C_SCOPE;
    constant msg_id_panel    : in  t_msg_id_panel        := shared_msg_id_panel
    );


  -- Wait for an incoming CAN active error flag
  -- The active error flag is detected by looking for the first sequence of 6
  -- dominant bits.
  -- If the active error flag is not received within the timeout (in bauds),
  -- an alert of severity specified by config.error_flag_timeout_severity
  -- will be given.
  procedure can_uvvm_recv_active_error_flag (
    constant timeout_baud_periods : in natural;
    constant msg                  : in string;
    signal   can_rx               : in std_logic;
    constant config               : in t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
    constant scope                : in string                := C_SCOPE;
    constant msg_id_panel         : in t_msg_id_panel        := shared_msg_id_panel;
    constant proc_name            : in string                := "can_uvvm_recv_active_error_flag"
    );

  -- Wait for a sequence of 6 recessive (low) bits, ie. CAN passive error flag
  -- If the active error flag is not received within the timeout (in bauds),
  -- an alert of severity specified by config.error_flag_timeout_severity
  -- will be given.
  procedure can_uvvm_recv_passive_error_flag (
    constant timeout_baud_periods : in natural;
    constant msg                  : in string;
    signal   can_rx               : in std_logic;
    constant config               : in t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
    constant scope                : in string                := C_SCOPE;
    constant msg_id_panel         : in t_msg_id_panel        := shared_msg_id_panel
    );

end package can_uvvm_bfm_pkg;


package body can_uvvm_bfm_pkg is

  procedure can_uvvm_write (
    constant arb_id_a         : in  std_logic_vector(C_ARB_ID_A_SIZE-1 downto 0);
    constant arb_id_b         : in  std_logic_vector(C_ARB_ID_B_SIZE-1 downto 0);
    constant extended_id      : in  std_logic;
    constant remote_request   : in  std_logic;
    constant data             : in  can_payload_t;
    constant data_length      : in  natural;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal can_tx             : out std_logic;
    signal can_rx             : in  std_logic;
    variable can_tx_status    : out can_tx_status_t;
    constant can_rx_error_gen : in  can_rx_error_gen_t    := C_CAN_RX_NO_ERROR_GEN;
    constant config           : in  t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
    constant scope            : in  string                := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel        := shared_msg_id_panel;
    constant proc_name        : in  string                := "can_uvvm_write"
    ) is
    variable v_proc_call       : line;
    variable v_arb_id_ext_full : std_logic_vector(C_ARB_ID_A_SIZE+C_ARB_ID_B_SIZE-1 downto 0);
    variable bit_stuff_dbg     : std_logic := '0';
    variable sample_point_dbg  : std_logic := '0';
    variable arb_lost          : std_logic := '0';
    variable bit_error         : std_logic := '0';
    variable ack_received      : std_logic := '0';
  begin
    -- Format procedure call string
    write(v_proc_call, string'("can_uvvm_write(ID:"));

    if extended_id = '1' then
      v_arb_id_ext_full := arb_id_a & arb_id_b;
      write(v_proc_call, to_string(v_arb_id_ext_full, HEX, AS_IS, INCL_RADIX));
    else
      write(v_proc_call, to_string(arb_id_a, HEX, AS_IS, INCL_RADIX));
    end if;

    write(v_proc_call, string'(", Length:"));
    write(v_proc_call, to_string(data_length, 1));

    if remote_request = '1' then
      write(v_proc_call, string'(", RTR"));
    elsif data_length > 0 then
      write(v_proc_call, string'(", Data:0x"));

      for byte_num in 0 to data_length-1 loop
        write(v_proc_call, to_string(data(byte_num), HEX));
      end loop;
    end if;
    write(v_proc_call, string'(")"));

    can_write(arb_id_a,
              arb_id_b,
              remote_request,
              extended_id,
              data,
              data_length,
              clk,
              can_tx,
              can_rx,
              bit_stuff_dbg,
              sample_point_dbg,
              config.can_config,
              can_rx_error_gen,
              can_tx_status);

    if can_tx_status.arbitration_lost then
      alert(config.arb_lost_severity, v_proc_call.all & "=> Failed. Arbitration lost.", scope);

    elsif can_tx_status.crc_error_flag then
      alert(config.crc_error_severity, v_proc_call.all & "=> Failed. Receiver reported CRC error.", scope);

    elsif can_tx_status.form_error_flag then
      alert(config.form_error_severity, v_proc_call.all & "=> Failed. Receiver reported Form error.", scope);

    elsif can_tx_status.got_active_error_flag then
      alert(config.error_flag_severity, v_proc_call.all & "=> Failed. Got active error flag.", scope);

    elsif can_tx_status.bit_error then
      alert(config.bit_error_severity, v_proc_call.all & "=> Failed. Bit error.", scope);

    elsif can_tx_status.ack_missing then
      alert(config.ack_missing_severity, v_proc_call.all & "=> ACK missing.", scope);
    end if;

    if proc_name = "can_uvvm_write" then
      log(config.id_for_bfm, v_proc_call.all & " completed. " & msg, scope, msg_id_panel);
    end if;

  end procedure can_uvvm_write;


  procedure can_uvvm_read (
    variable arb_id_a       : out std_logic_vector(C_ARB_ID_A_SIZE-1 downto 0);
    variable arb_id_b       : out std_logic_vector(C_ARB_ID_B_SIZE-1 downto 0);
    variable extended_id    : out std_logic;
    variable remote_frame   : out std_logic;
    variable data           : out can_payload_t;
    variable data_length    : out natural;
    constant msg            : in  string;
    signal clk              : in  std_logic;
    signal can_tx           : out std_logic;
    signal can_rx           : in  std_logic;
    variable timeout        : out std_logic;
    constant config         : in  t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
    constant scope          : in  string                := C_SCOPE;
    constant msg_id_panel   : in  t_msg_id_panel        := shared_msg_id_panel;
    constant proc_name      : in  string                := "can_uvvm_read"
    )
  is
    variable v_proc_call       : line;
    variable v_arb_id_ext_full : std_logic_vector(C_ARB_ID_A_SIZE+C_ARB_ID_B_SIZE-1 downto 0);
    variable crc_error         : std_logic := '0';
    variable bit_stuff_dbg     : std_logic := '0';
    variable sample_point_dbg  : std_logic := '0';
  begin
    can_read(arb_id_a,
             arb_id_b,
             remote_frame,
             extended_id,
             data,
             data_length,
             config.max_wait_cycles,
             clk,
             can_rx,
             can_tx,
             bit_stuff_dbg, -- bit stuffing debug output not used
             sample_point_dbg, -- sample point debug output not used
             timeout,
             crc_error,
             config.can_config);


    if timeout = '1' then
      alert(config.max_wait_cycles_severity, "can_uvvm_read()=> Failed, timeout.", scope);
    else
      write(v_proc_call, string'("can_uvvm_read()=> ID:"));

      if extended_id = '1' then
        v_arb_id_ext_full := arb_id_a & arb_id_b;
        write(v_proc_call, to_string(v_arb_id_ext_full, HEX, AS_IS, INCL_RADIX));
      else
        write(v_proc_call, to_string(arb_id_a, HEX, AS_IS, INCL_RADIX));
      end if;


      if remote_frame = '1' then
        write(v_proc_call, string'(" RTR"));
      end if;

      write(v_proc_call, string'(" Length:"));
      write(v_proc_call, to_string(data_length, 1));

      if data_length > 0 and remote_frame = '0' then
        write(v_proc_call, string'(" Data: 0x"));

        for byte_num in 0 to data_length-1 loop
          write(v_proc_call, to_string(data(byte_num), HEX));
        end loop;
      end if;

      write(v_proc_call, string'(". "));

      if proc_name = "can_uvvm_read" then
        log(config.id_for_bfm, v_proc_call.all & msg, scope, msg_id_panel);
      end if;
    end if;


  end procedure can_uvvm_read;


  procedure can_uvvm_check (
    constant arb_id_a_exp    : in  std_logic_vector(C_ARB_ID_A_SIZE-1 downto 0);
    constant arb_id_b_exp    : in  std_logic_vector(C_ARB_ID_B_SIZE-1 downto 0);
    constant extended_id     : in  std_logic;
    constant remote_expect   : in  std_logic;
    constant remote_request  : in  std_logic;
    constant data_exp        : in  can_payload_t;
    constant data_length_exp : in  natural;
    constant msg             : in  string;
    signal clk               : in  std_logic;
    signal can_tx            : out std_logic;
    signal can_rx            : in  std_logic;
    constant alert_level     : in  t_alert_level         := error;
    constant config          : in  t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
    constant scope           : in  string                := C_SCOPE;
    constant msg_id_panel    : in  t_msg_id_panel        := shared_msg_id_panel
    )
  is
    constant proc_name   : string := "can_uvvm_check";
    variable v_proc_call : line;
    variable v_error_msg : line;

    variable v_empty_data : can_payload_t;

    variable v_arb_id_a        : std_logic_vector(C_ARB_ID_A_SIZE-1 downto 0);
    variable v_arb_id_b        : std_logic_vector(C_ARB_ID_B_SIZE-1 downto 0);
    variable v_arb_id_ext_full : std_logic_vector(C_ARB_ID_A_SIZE+C_ARB_ID_B_SIZE-1 downto 0);
    variable v_remote_frame    : std_logic;
    variable v_extended_id     : std_logic;
    variable v_data            : can_payload_t;
    variable v_data_length     : natural;
    variable v_timeout         : std_logic;
    variable v_can_tx_status   : can_tx_status_t;
  begin
    if remote_expect = '1' and remote_request = '1' then
      write(v_error_msg, string'(" => Failed. Can not request and expect remote frame"));
      alert(TB_ERROR, v_proc_call.all & v_error_msg.all & LF & msg, scope);
      return;
    end if;

    -- Format procedure call string
    write(v_proc_call, string'("can_uvvm_check(ID:"));

    if extended_id = '1' then
      v_arb_id_ext_full := arb_id_a_exp & arb_id_b_exp;
      write(v_proc_call, to_string(v_arb_id_ext_full, HEX, AS_IS, INCL_RADIX));
    else
      write(v_proc_call, to_string(arb_id_a_exp, HEX, AS_IS, INCL_RADIX));
    end if;

    write(v_proc_call, string'(", Length:"));
    write(v_proc_call, to_string(data_length_exp, 1));

    if remote_request = '1' then
      write(v_proc_call, string'(", send RTR"));
    elsif remote_expect = '1' then
      write(v_proc_call, string'(", expect RTR"));
    elsif data_length_exp > 0 then
      write(v_proc_call, string'(", Data:0x"));

      for byte_num in 0 to data_length_exp-1 loop
        write(v_proc_call, to_string(data_exp(byte_num), HEX));
      end loop;
    end if;
    write(v_proc_call, string'(")"));

    -- Send a remote frame first if requested, and wait for response
    if remote_request = '1' then
      can_uvvm_write (arb_id_a_exp,
                      arb_id_b_exp,
                      extended_id,
                      remote_request,
                      v_empty_data,
                      data_length_exp,
                      msg,
                      clk,
                      can_tx,
                      can_rx,
                      v_can_tx_status,
                      C_CAN_RX_NO_ERROR_GEN,
                      config,
                      scope,
                      msg_id_panel,
                      proc_name);

      if v_can_tx_status.arbitration_lost  then
        alert(alert_level, v_proc_call.all & "=> Failed. Arb lost while sending RTR frame." & LF & msg);
        return;
      elsif v_can_tx_status.ack_missing then
        alert(alert_level, v_proc_call.all & "=> Failed. Ack missing after sending RTR frame." & LF & msg);
        return;
      elsif v_can_tx_status.bit_error then
        alert(alert_level, v_proc_call.all & "=> Failed. Bit error while sending RTR frame." & LF & msg);
        return;
      elsif v_can_tx_status.got_active_error_flag then
        alert(alert_level, v_proc_call.all & "=> Failed. Got active error flag while sending RTR frame." & LF & msg);
        return;
      end if;
    end if;

    -- Read CAN message
    can_uvvm_read(v_arb_id_a,
                  v_arb_id_b,
                  v_extended_id,
                  v_remote_frame,
                  v_data,
                  v_data_length,
                  msg,
                  clk,
                  can_tx,
                  can_rx,
                  v_timeout,
                  config,
                  scope,
                  msg_id_panel,
                  proc_name);

    if v_timeout = '1' then
      log(config.id_for_bfm, v_proc_call.all & "=> Failed, timeout. " & msg, scope, msg_id_panel);
      return;
    end if;

    -- Check if we received basic/extended frame, and what was expected
    if v_extended_id /= extended_id then
      if extended_id = '1' then
        alert(alert_level, v_proc_call.all & "=> Failed. Got basic frame." & LF & msg);
      else
        alert(alert_level, v_proc_call.all & "=> Failed. Got extended frame." & LF & msg);
      end if;
      return;
    end if;

    -- Compare received ID with expected
    if v_extended_id = '1' then
      if v_arb_id_a /= arb_id_a_exp or v_arb_id_b /= arb_id_b_exp then
        v_arb_id_ext_full := v_arb_id_a & v_arb_id_b;
        alert(alert_level, v_proc_call.all & "=> Failed. Got ID:0x" &
              to_string(v_arb_id_ext_full, HEX) & LF & msg);
        return;
      end if;
    else
      if v_arb_id_a /= arb_id_a_exp then
        alert(alert_level, v_proc_call.all & "=> Failed. Got ID:0x" &
              to_string(v_arb_id_a, HEX) & LF & msg);
        return;
      end if;
    end if;

    -- Check if correct data or remote frame was received
    if v_remote_frame /= remote_expect then
      if remote_expect = '1' then
        alert(alert_level, v_proc_call.all & "=> Failed. Got data frame." & LF & msg);
      else
        alert(alert_level, v_proc_call.all & "=> Failed. Got remote frame." & LF & msg);
      end if;
      return;
    end if;

    -- Check data length
    if v_data_length /= data_length_exp then
      alert(alert_level, v_proc_call.all & "=> Failed. Received data length:" &
            to_string(v_data_length, 1));
      return;
    end if;

    -- Compare data if received and not remote frame
    if v_remote_frame = '0' and v_data_length > 0 then
      if v_data(0 to v_data_length-1) /= data_exp(0 to v_data_length-1) then
        write(v_error_msg, string'("=> Failed. Received data:0x"));

        for byte_num in 0 to v_data_length-1 loop
          write(v_error_msg, to_string(v_data(byte_num), HEX));
        end loop;

        alert(alert_level, v_proc_call.all & v_error_msg.all & ". " & LF & msg);
        return;
      end if;
    end if;

    log(config.id_for_bfm, v_proc_call.all & "=> OK.");

  end procedure can_uvvm_check;


  procedure can_uvvm_recv_active_error_flag (
    constant timeout_baud_periods : in natural;
    constant msg                  : in string;
    signal   can_rx               : in std_logic;
    constant config               : in t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
    constant scope                : in string                := C_SCOPE;
    constant msg_id_panel         : in t_msg_id_panel        := shared_msg_id_panel;
    constant proc_name            : in string                := "can_uvvm_recv_active_error_flag"
    )
  is
    variable v_proc_call : line;
    variable v_error_msg : line;

    variable v_bauds_waited    : natural := 0;
    variable v_can_rx_prev     : std_logic;
    variable v_error_flag_started   : boolean   := false;
    variable v_recessive_count : natural   := 0;
    variable v_dominant_count  : natural   := 0;
    constant baud_period       : time      := 1 sec / config.can_config.bit_rate;
    constant num_time_quanta   : natural   := config.can_config.sync_quanta +
                                              config.can_config.prop_quanta +
                                              config.can_config.phase1_quanta +
                                              config.can_config.phase2_quanta;
    constant sample_point_quanta : natural := config.can_config.sync_quanta +
                                              config.can_config.prop_quanta +
                                              config.can_config.phase1_quanta;
    constant sample_point_time : time := (baud_period*sample_point_quanta)/num_time_quanta;

    constant error_flag_length : natural := 6;
  begin

    -- Format procedure call string
    write(v_proc_call, string'("can_uvvm_recv_error_flag() => "));

    if can_rx = '0' then
      v_error_flag_started := true;
      v_can_rx_prev   := '0';
    end if;


    while v_bauds_waited < timeout_baud_periods or v_error_flag_started = true loop

      if v_error_flag_started and v_can_rx_prev = can_rx then
        -- In frame and receiving consecutive bits of same value -> increase counter
        if can_rx = '0' then
          v_dominant_count := v_dominant_count + 1;
        else
          v_recessive_count := v_recessive_count + 1;
        end if;
      elsif v_error_flag_started and v_can_rx_prev /= can_rx then
        -- Bit transition in frame, reset counters
        if can_rx = '0' then
          v_dominant_count     := 1;
          v_recessive_count    := 0;
          v_error_flag_started := true;
        else
          v_dominant_count     := 0;
          v_recessive_count    := 1;
          v_error_flag_started := false;
        end if;
      else
        -- Not in a frame
        v_dominant_count  := 0;
        v_recessive_count := 0;
      end if;


      if v_dominant_count = error_flag_length then
        -- Got active error flag
          log(config.id_for_bfm,
              v_proc_call.all & "Ok. Got active error flag. " & msg,
              scope, msg_id_panel);
          return;
      end if;

      v_can_rx_prev := can_rx;

      -- Wait for next bit
      if not v_error_flag_started then
        -- Wait for first falling edge if we are not in a frame already
        wait until can_rx = '0' for baud_period;

        if can_rx = '0' then
          wait for sample_point_time;
          v_error_flag_started := true;
        end if;
      else
        wait for baud_period;
      end if;

      v_bauds_waited := v_bauds_waited + 1;
    end loop;

    alert(config.error_flag_timeout_severity,
          v_proc_call.all & "Failed. Timeout. " & msg, scope);

  end procedure can_uvvm_recv_active_error_flag;


  procedure can_uvvm_recv_passive_error_flag (
    constant timeout_baud_periods : in natural;
    constant msg                  : in string;
    signal   can_rx               : in std_logic;
    constant config               : in t_can_uvvm_bfm_config := C_CAN_UVVM_BFM_CONFIG_DEFAULT;
    constant scope                : in string                := C_SCOPE;
    constant msg_id_panel         : in t_msg_id_panel        := shared_msg_id_panel
    )
  is
    variable v_proc_call : line;
    variable v_error_msg : line;

    variable v_bauds_waited       : natural := 0;
    variable v_can_rx_prev        : std_logic;
    variable v_error_flag_started : boolean := false;
    variable v_recessive_count    : natural := 0;
    constant baud_period          : time    := 1 sec / config.can_config.bit_rate;
    constant num_time_quanta      : natural := config.can_config.sync_quanta +
                                          config.can_config.prop_quanta +
                                          config.can_config.phase1_quanta +
                                          config.can_config.phase2_quanta;
    constant sample_point_quanta : natural := config.can_config.sync_quanta +
                                              config.can_config.prop_quanta +
                                              config.can_config.phase1_quanta;
    constant sample_point_time : time    := (baud_period*sample_point_quanta)/num_time_quanta;
    constant error_flag_length : natural := 6;
  begin

    -- Format procedure call string
    write(v_proc_call, string'("can_uvvm_recv_error_flag() => "));

    if can_rx = '1' then
      v_error_flag_started := true;
      v_can_rx_prev   := '0';
    end if;


    while v_bauds_waited < timeout_baud_periods+1 or v_error_flag_started = true loop

      if v_error_flag_started and v_can_rx_prev = can_rx then
        -- In frame and receiving consecutive bits of same value -> increase counter
        if can_rx = '1' then
          v_recessive_count := v_recessive_count + 1;
        end if;
      elsif v_error_flag_started and v_can_rx_prev /= can_rx then
        -- Bit transition in frame, reset counters
        if can_rx = '1' then
          v_recessive_count    := 1;
          v_error_flag_started := true;
        else
          v_error_flag_started := false;
        end if;
      else
        -- Not in a frame
        v_recessive_count := 0;
      end if;


      if v_recessive_count = error_flag_length then
        -- Got passive error flag
          log(config.id_for_bfm,
              v_proc_call.all & "Ok. Got passive error flag. " & msg,
              scope, msg_id_panel);
          return;
      end if;

      v_can_rx_prev := can_rx;

      -- Wait for next bit
      if not v_error_flag_started then
        -- Wait for first falling edge if we are not in a frame already
        wait until can_rx = '1' for baud_period;

        if can_rx = '1' then
          wait for sample_point_time;
          v_error_flag_started := true;
        end if;
      else
        wait for baud_period;
      end if;

      v_bauds_waited := v_bauds_waited + 1;
    end loop;

    alert(config.error_flag_timeout_severity,
          v_proc_call.all & "Failed. Timeout. " & msg, scope);

  end procedure can_uvvm_recv_passive_error_flag;

end package body can_uvvm_bfm_pkg;
