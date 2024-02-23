-------------------------------------------------------------------------------
-- Title      : Error Management Logic (EML) for CAN bus
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_eml.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2019-07-10
-- Last update: 2020-09-04
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Error Management Logic (EML) for the Canola CAN controller
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-07-10  1.0      svn     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.canola_pkg.all;

entity canola_eml is
  port (
    CLK   : in std_logic;
    RESET : in std_logic;

    -- Error and success inputs should all be pulsed
    RX_STUFF_ERROR                   : in std_logic;
    RX_CRC_ERROR                     : in std_logic;
    RX_FORM_ERROR                    : in std_logic;
    RX_ACTIVE_ERROR_FLAG_BIT_ERROR   : in std_logic;
    RX_OVERLOAD_FLAG_BIT_ERROR       : in std_logic;
    RX_DOMINANT_BIT_AFTER_ERROR_FLAG : in std_logic;
    TX_BIT_ERROR                     : in std_logic;
    TX_ACK_ERROR                     : in std_logic;
    TX_ACTIVE_ERROR_FLAG_BIT_ERROR   : in std_logic;
    TRANSMIT_SUCCESS                 : in std_logic;
    RECEIVE_SUCCESS                  : in std_logic;
    RECV_11_RECESSIVE_BITS           : in std_logic;  -- Received/detected a sequence of
                                                      -- 11 recessive bits.

    -- Interface to saturating counter modules for
    -- Transmit Error Counter (TEC) and Receive Error Counter (REC)
    TEC_COUNT_VALUE           : in  std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
    TEC_COUNT_INCR            : out std_logic_vector(C_ERROR_COUNT_INCR_LENGTH-1 downto 0);
    TEC_COUNT_UP              : out std_logic;
    TEC_COUNT_DOWN            : out std_logic;
    TEC_CLEAR                 : out std_logic;
    TEC_SET                   : out std_logic;
    TEC_SET_VALUE             : out std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
    REC_COUNT_VALUE           : in  std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
    REC_COUNT_INCR            : out std_logic_vector(C_ERROR_COUNT_INCR_LENGTH-1 downto 0);
    REC_COUNT_UP              : out std_logic;
    REC_COUNT_DOWN            : out std_logic;
    REC_CLEAR                 : out std_logic;
    REC_SET                   : out std_logic;
    REC_SET_VALUE             : out std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);

    -- Interface to up_counter module for counter for
    -- received sequences of 11 consecutive recessive bits
    RECESSIVE_BIT_COUNT_VALUE : in  std_logic_vector(C_ERROR_COUNT_LENGTH-1 downto 0);
    RECESSIVE_BIT_COUNT_UP    : out std_logic;
    RECESSIVE_BIT_COUNT_CLEAR : out std_logic;

    ERROR_STATE             : out std_logic_vector(C_CAN_ERROR_STATE_BITSIZE-1 downto 0)
    );

end entity canola_eml;

architecture rtl of canola_eml is

  signal s_error_state                    : can_error_state_t;
  attribute fsm_encoding                  : string;
  attribute fsm_encoding of s_error_state : signal is "sequential";

begin  -- architecture rtl

  ERROR_STATE <= std_logic_vector(to_unsigned(can_error_state_t'pos(s_error_state),
                                              C_CAN_ERROR_STATE_BITSIZE));

  -- The only value the Receive Error Counter (REC) will be set directly to
  REC_SET_VALUE <= std_logic_vector(to_unsigned(C_REC_SUCCES_ERROR_PASSIVE_JUMP_VALUE,
                                                REC_SET_VALUE'length));

  -- Not used for the Transmit Error Counter (TEC)
  TEC_SET_VALUE <= (others => '0');
  TEC_SET       <= '0';

  proc_error_counters : process(CLK) is
    -- Transmit and receive counter variables are 1 bit larger
    -- than corresponding signals to check for overflow
    -- Counter for sequences of 11 recessive bits should never overflow
    variable v_xmit_error_count_incr : natural;
    variable v_recv_error_count_incr : natural;
  begin
    if rising_edge(CLK) then
      TEC_COUNT_UP              <= '0';
      TEC_COUNT_DOWN            <= '0';
      TEC_CLEAR                 <= '0';
      REC_COUNT_UP              <= '0';
      REC_COUNT_DOWN            <= '0';
      REC_CLEAR                 <= '0';
      REC_SET                   <= '0';
      RECESSIVE_BIT_COUNT_UP    <= '0';
      RECESSIVE_BIT_COUNT_CLEAR <= '0';

      ------------------------------------------------------------------------
      -- Transmit Error Counter (TEC) logic
      ------------------------------------------------------------------------
      if TX_BIT_ERROR = '1' then
        TEC_COUNT_UP            <= '1';
        v_xmit_error_count_incr := C_TEC_BIT_ERROR_INCREASE;

      elsif TX_ACK_ERROR = '1' and s_error_state = ERROR_ACTIVE then
        TEC_COUNT_UP            <= '1';
        v_xmit_error_count_incr := C_TEC_ACK_ERROR_INCREASE;

      elsif TX_ACTIVE_ERROR_FLAG_BIT_ERROR = '1' then
        TEC_COUNT_UP            <= '1';
        v_xmit_error_count_incr := C_TEC_ACTIVE_ERR_FLAG_BIT_ERROR_INCREASE;

      elsif TRANSMIT_SUCCESS = '1' then
        TEC_COUNT_DOWN          <= '1';
        v_xmit_error_count_incr := C_TEC_SUCCESS_DECREASE;
      end if;

      TEC_COUNT_INCR <= std_logic_vector(to_unsigned(v_xmit_error_count_incr,
                                                     TEC_COUNT_INCR'length));

      ------------------------------------------------------------------------
      -- Receive Error Counter (REC) logic
      ------------------------------------------------------------------------
      if RX_STUFF_ERROR = '1' then
        REC_COUNT_UP            <= '1';
        v_recv_error_count_incr := C_REC_STUFF_ERROR_INCREASE;

      elsif RX_CRC_ERROR = '1' then
        REC_COUNT_UP            <= '1';
        v_recv_error_count_incr := C_REC_CRC_ERROR_INCREASE;

      elsif RX_FORM_ERROR = '1' then
        REC_COUNT_UP            <= '1';
        v_recv_error_count_incr := C_REC_FORM_ERROR_INCREASE;

      elsif RX_ACTIVE_ERROR_FLAG_BIT_ERROR = '1' then
        REC_COUNT_UP            <= '1';
        v_recv_error_count_incr := C_REC_ACTIVE_ERR_FLAG_BIT_ERROR_INCREASE;

      elsif RX_OVERLOAD_FLAG_BIT_ERROR = '1' then
        REC_COUNT_UP            <= '1';
        v_recv_error_count_incr := C_REC_OVERLOAD_FLAG_BIT_ERROR_INCREASE;

      elsif RX_DOMINANT_BIT_AFTER_ERROR_FLAG = '1' then
        REC_COUNT_UP            <= '1';
        v_recv_error_count_incr := C_REC_DOMINANT_BIT_AFTER_ERR_FLAG_INCREASE;

      elsif RECEIVE_SUCCESS = '1' then
        if unsigned(REC_COUNT_VALUE) >= C_ERROR_PASSIVE_THRESHOLD then
          -- Note: C_REC_SUCCES_ERROR_PASSIVE_JUMP_VALUE is assigned
          --       to the set value outside this process
          --       We will never set the counter directly to a different value,
          --       so might as well do it outside the process so it can be
          --       hard-wired on the FPGA
          REC_SET <= '1';
        else
          REC_COUNT_DOWN          <= '1';
          v_recv_error_count_incr := C_REC_SUCCES_ERROR_ACTIVE_DECREASE;
        end if;
      end if;

      REC_COUNT_INCR <= std_logic_vector(to_unsigned(v_recv_error_count_incr,
                                                     REC_COUNT_INCR'length));

      ------------------------------------------------------------------------
      -- 11 successive recessive bit counter logic
      ------------------------------------------------------------------------
      if s_error_state = BUS_OFF then
        if unsigned(RECESSIVE_BIT_COUNT_VALUE) = C_11_RECESSIVE_EXIT_BUS_OFF_THRESHOLD then
          -- Clear REC/TEC when exiting BUS OFF
          TEC_CLEAR <= '1';
          REC_CLEAR <= '1';

        elsif RECV_11_RECESSIVE_BITS = '1' then
          RECESSIVE_BIT_COUNT_UP <= '1';
        end if;
      else
        -- Clear counter of 11 recessive bits when we are not in BUS OFF
        RECESSIVE_BIT_COUNT_CLEAR <= '1';
      end if;

    end if;  -- rising_edge(clk)
  end process proc_error_counters;

  ------------------------------------------------------------------------
  -- Update error state based on error counter values
  ------------------------------------------------------------------------
  proc_error_state : process(TEC_COUNT_VALUE, REC_COUNT_VALUE) is
  begin
    if unsigned(TEC_COUNT_VALUE) >= C_BUS_OFF_THRESHOLD then
      s_error_state <= BUS_OFF;

    elsif unsigned(TEC_COUNT_VALUE) >= C_ERROR_PASSIVE_THRESHOLD then
      s_error_state <= ERROR_PASSIVE;

    elsif unsigned(REC_COUNT_VALUE) >= C_ERROR_PASSIVE_THRESHOLD then
      s_error_state <= ERROR_PASSIVE;

    else
      s_error_state <= ERROR_ACTIVE;
    end if;
  end process proc_error_state;

end architecture rtl;
