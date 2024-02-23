-------------------------------------------------------------------------------
-- Title      : Package for Canola CAN controller testbenches
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_tb_pkg.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2019-06-26
-- Last update: 2020-01-06
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Package with common functions etc. used in the testbenches for
--              the Canola CAN controller
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-07-22  1.0      svn     Created
-- 2019-09-19  1.1      svn     Add check_value for can_error_state_t
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library work;
use work.canola_pkg.all;

package canola_tb_pkg is

  procedure generate_random_frame_size (
    variable rand_frame_size : out   natural;
    constant max_size        : in    natural;
    variable seed1           : inout positive;
    variable seed2           : inout positive);

  -- Fill a std_logic_vector with random data for testing BTL
  -- The desired length must be large enough to hold the EOF and SOF
  -- fields of a CAN frame, and the vector will begin with a SOF bit and end
  -- with the EOF bits. The bits in between will be random.
  procedure generate_random_data_for_btl (
    signal   data        : out   std_logic_vector;
    constant data_length : in    natural;
    variable seed1       : inout positive;
    variable seed2       : inout positive);

  -- Random sequence used when testing for ACK
  constant C_ACK_TEST_SEQUENCE              : std_logic_vector := "01100101111111";
  constant C_ACK_TEST_SEQUENCE_EXP          : std_logic_vector := "01100001111111";
  constant C_ACK_TEST_SEQUENCE_ACK_SLOT_IDX : natural          := 5;


  impure function check_value(
    constant value        : can_error_state_t;
    constant exp          : can_error_state_t;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
    ) return boolean;


  procedure check_value(
    constant value       : can_error_state_t;
    constant exp         : can_error_state_t;
    constant alert_level : t_alert_level;
    constant msg         : string;
    constant scope       : string          := C_TB_SCOPE_DEFAULT;
    constant msg_id      : t_msg_id        := ID_POS_ACK;
    constant msg_id_panel: t_msg_id_panel  := shared_msg_id_panel;
    constant caller_name : string          := "check_value()"
    );


  procedure check_value(
    constant value       : can_msg_t;
    constant exp         : can_msg_t;
    constant alert_level : t_alert_level;
    constant msg         : string;
    constant scope       : string          := C_TB_SCOPE_DEFAULT;
    constant msg_id      : t_msg_id        := ID_POS_ACK;
    constant msg_id_panel: t_msg_id_panel  := shared_msg_id_panel;
    constant caller_name : string          := "check_value()"
    );

end canola_tb_pkg;


package body canola_tb_pkg is

  procedure generate_random_frame_size (
    variable rand_frame_size : out   natural;
    constant max_size        : in    natural;
    variable seed1           : inout positive;
    variable seed2           : inout positive)
  is
    variable rand_real    : real;
  begin
    uniform(seed1, seed2, rand_real);

    rand_frame_size := integer(round(rand_real*real(max_size)));

    -- Make sure frame is at least large enough for SOF, EOF bits and a data bit
    if rand_frame_size < C_EOF_LENGTH+2 then
      rand_frame_size := rand_frame_size + C_EOF_LENGTH + 2;
    end if;

    if rand_frame_size > max_size then
      rand_frame_size := max_size;
    end if;
  end procedure generate_random_frame_size;

  -- Fill a std_logic_vector with random data for testing BTL
  -- The desired length must be large enough to hold the EOF and SOF
  -- fields of a CAN frame, and the vector will begin with a SOF bit and end
  -- with the EOF bits. The bits in between will be random.
  procedure generate_random_data_for_btl (
    signal   data        : out   std_logic_vector;
    constant data_length : in    natural;
    variable seed1       : inout positive;
    variable seed2       : inout positive)
  is
    variable rand_real           : real;
    variable rand_sl             : std_logic;
    variable rand_data           : std_logic_vector(0 to data'length-1)     := (others => '0');
    variable count               : natural                                  := 0;
    variable recessive_bit_count : natural                                  := 0;
    variable dominant_bit_count  : natural                                  := 0;
  begin

    assert data_length >= 2 + C_EOF_LENGTH
      report "Data length must at least include SOF, EOF and a data bit"
      severity error;

    assert data_length <= data'length
      report "Desired data length larger than data vector size"
      severity error;

    -- Fill first bit with C_SOF_VALUE
    rand_data(0)       := C_SOF_VALUE;  -- '0' - dominant
    count              := 1;
    dominant_bit_count := 1;

    while count < data_length loop
      if data_length - count > C_EOF_LENGTH + 1 then
        ---------------------------------------------------------------------
        -- Fill bits in between SOF and EOF with random data
        ---------------------------------------------------------------------
        uniform(seed1, seed2, rand_real);
        if rand_real >= 0.5 then
          if recessive_bit_count < 5 then
            rand_data(count) := '1';
          else
            -- Don't allow more than 5 consecutive bits of same value
            rand_data(count) := '0';
          end if;
        else
          if dominant_bit_count < 5 then
            rand_data(count) := '0';
          else
            -- Don't allow more than 5 consecutive bits of same value
            rand_data(count) := '1';
          end if;
        end if;

        if rand_data(count) /= rand_data(count-1) then
          recessive_bit_count := 0;
          dominant_bit_count  := 0;
        end if;

        if rand_data(count) = '1' then
          recessive_bit_count := recessive_bit_count + 1;
        else
          dominant_bit_count := dominant_bit_count + 1;
        end if;
      elsif data_length - count = C_EOF_LENGTH + 1 then
        ---------------------------------------------------------------------
        -- Make sure last bit before EOF is dominant,
        -- so that BTL does not think frame ended before it did
        ---------------------------------------------------------------------
        rand_data(count) := '0';

        if dominant_bit_count = 5 then
          -- If there was a sequence of 5 dominant bits before this bit,
          -- Just flip the previous bit
          rand_data(count-1) := '1';
        end if;
      else
        ---------------------------------------------------------------------
        -- Fill last C_EOF_SIZE bits with C_EOF_VALUE
        ---------------------------------------------------------------------
        rand_data(count) := C_EOF_VALUE;
      end if;

      count := count + 1;
    end loop;

    data <= rand_data;

    -- Update data next delta cycle
    wait for 0 ns;
  end procedure generate_random_data_for_btl;


  impure function check_value(
    constant value        : can_error_state_t;
    constant exp          : can_error_state_t;
    constant alert_level  : t_alert_level;
    constant msg          : string;
    constant scope        : string         := C_TB_SCOPE_DEFAULT;
    constant msg_id       : t_msg_id       := ID_POS_ACK;
    constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
    constant caller_name  : string         := "check_value()"
    ) return boolean is
    constant v_value_str : string := can_error_state_t'image(value);
    constant v_exp_str   : string := can_error_state_t'image(exp);
  begin
    if value = exp then
      log(msg_id, caller_name & " => OK, for can_error_state_t " & v_value_str & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      return true;
    else
      alert(alert_level, caller_name & " => Failed. can_error_state_t was " & v_value_str & ". Expected " & v_exp_str & ". " & LF & msg, scope);
      return false;
    end if;
  end;


  procedure check_value(
    constant value       : can_error_state_t;
    constant exp         : can_error_state_t;
    constant alert_level : t_alert_level;
    constant msg         : string;
    constant scope       : string          := C_TB_SCOPE_DEFAULT;
    constant msg_id      : t_msg_id        := ID_POS_ACK;
    constant msg_id_panel: t_msg_id_panel  := shared_msg_id_panel;
    constant caller_name : string          := "check_value()"
    ) is
    variable v_check_ok  : boolean;
  begin
    v_check_ok := check_value(value, exp, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
  end;


  procedure check_value(
    constant value       : can_msg_t;
    constant exp         : can_msg_t;
    constant alert_level : t_alert_level;
    constant msg         : string;
    constant scope       : string          := C_TB_SCOPE_DEFAULT;
    constant msg_id      : t_msg_id        := ID_POS_ACK;
    constant msg_id_panel: t_msg_id_panel  := shared_msg_id_panel;
    constant caller_name : string          := "check_value()"
    ) is
  begin
    check_value(value.ext_id, exp.ext_id, error, msg & " - Extended ID bit");
    check_value(value.arb_id_a, exp.arb_id_a, error, msg & " - Arb. ID A");

    if exp.ext_id = '1' then
      check_value(value.arb_id_b, exp.arb_id_b, error, msg & " - Arb. ID B");
    end if;

    check_value(value.remote_request, exp.remote_request, error, msg & " - RTR bit");

    check_value(value.data_length, exp.data_length, error, msg & " - DLC");

    -- Don't check data for remote frame requests
    if exp.remote_request = '0' then
      for idx in 0 to to_integer(unsigned(exp.data_length))-1 loop
        check_value(value.data(idx),
                    exp.data(idx),
                    error,
                    msg & " - Payload " & to_string(idx, 1));
      end loop;
    end if;
  end;

end package body canola_tb_pkg;
