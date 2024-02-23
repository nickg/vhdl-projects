-------------------------------------------------------------------------------
-- Title      : Bit Stream Processor (BSP) for CAN bus
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : canola_bsp.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2019-07-01
-- Last update: 2020-09-04
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Bit Stream Processor (BSP) for the Canola CAN controller
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-07-01  1.0      svn     Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.canola_pkg.all;
-- To send some data on the Tx interface:
--  * Set BSP_TX_ACTIVE high to indicate that a transmission is starting
-- And then, for each field of data:
--  * Hold BSP_TX_WRITE_EN low.
--  * Setup BSP_TX_DATA with a stream of data, starting at index 0.
--  * Setup BSP_TX_DATA_COUNT with number of bits in BSP_TX_DATA to send
--  * Set BSP_TX_WRITE_EN high, and hold it high until the BSP indicates that all
--    bits have been sent with the BSP_TX_DONE output.
--  * Transmission can then be aborted by setting BSP_TX_WRITE_EN low
--  * If a received bit value does not match the value of the transmitted bit,
--    the BSP_TX_RX_MISMATCH output goes high.
--  * If BSP_TX_BIT_STUFF_EN is high while transmitting, then the BSP will
--    automatically insert stuff bits in the outgoing data stream
--  * Bit mismatch for stuff bits are reported with the
--    BSP_TX_RX_STUFF_MISMATCH output
--
-- To receive data on the Rx interface:
--  * BSP_RX_ACTIVE goes high when the BTL has synced to an incoming CAN
--    message and is receiving
--  * The BSP will automatically remove and discard stuff bits in the received
--    data stream when BSP_RX_BIT_DESTUFF_EN is high
--  * The BSP shifts in data bit by bit, and makes them available at BSP_RX_DATA (LSB first)
--    BSP_RX_DATA_COUNT reflects the number of bits available in BSP_RX_DATA.
--  * The data received in BSP_RX_DATA can be cleared by pulsing
--    BSP_RX_DATA_CLEAR high for one clock cycle
--  * BSP_RX_CRC_CALC outputs the CRC that is calculated for the outgoing data
--    (excluding stuff bits), and is updated for each incoming bit.
--    The CRC value is automatically reset at the beginning of each frame.
--  * To acknowledge an incoming message, BSP_RX_SEND_ACK_PULSE should be
--    pulsed high for a clock cycle immediately after the bit before the ACK
--    slot has been received
--
--  Error flags can be sent at any time by pulsing BSP_SEND_ERROR_FLAG.
--  The BSP will automatically send the right kind of error flag,
--  passive or active, based on the EML's error state.

entity canola_bsp is
  port (
    CLK   : in std_logic;
    RESET : in std_logic;

    -- Interface to Tx FSM
    BSP_TX_DATA              : in  std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
    BSP_TX_DATA_COUNT        : in  std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);
    BSP_TX_WRITE_EN          : in  std_logic;
    BSP_TX_BIT_STUFF_EN      : in  std_logic;  -- Enable bit stuffing on current data
    BSP_TX_RX_MISMATCH       : out std_logic;  -- Mismatch Tx and Rx. Also used
                                               -- for ACK detection
    BSP_TX_RX_STUFF_MISMATCH : out std_logic;  -- Mismatch Tx and Rx for stuff bit
    BSP_TX_DONE              : out std_logic;
    BSP_TX_CRC_CALC_O        : out std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
    BSP_TX_ACTIVE            : in  std_logic;  -- Resets bit stuff counter and CRC

    -- Interface to Rx FSM
    BSP_RX_ACTIVE          : out std_logic;
    BSP_RX_IFS             : out std_logic;  -- High in inter frame spacing period
    BSP_RX_DATA            : out std_logic_vector(0 to C_BSP_DATA_LENGTH-1);
    BSP_RX_DATA_COUNT      : out std_logic_vector(C_BSP_DATA_LEN_BITSIZE-1 downto 0);
    BSP_RX_DATA_CLEAR      : in  std_logic;
    BSP_RX_DATA_OVERFLOW   : out std_logic;
    BSP_RX_BIT_DESTUFF_EN  : in  std_logic;  -- Enable bit destuffing on data
                                             -- that is currently being received
    BSP_RX_STOP            : in std_logic;   -- Tell BSP to stop when we've got EOF
    BSP_RX_CRC_CALC_O      : out std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
    BSP_RX_SEND_ACK        : in  std_logic;  -- Pulsed input

    BSP_RX_ACTIVE_ERROR_FLAG  : out std_logic;  -- Active error flag received
    BSP_RX_PASSIVE_ERROR_FLAG : out std_logic;  -- Passive error flag received
    BSP_SEND_ERROR_FLAG       : in  std_logic;  -- When pulsed, BSP cancels
                                                -- whatever it is doing, and sends
                                                -- an error flag. The type of flag
                                                -- depends on BSP_ERROR_STATE input
    BSP_ERROR_FLAG_DONE             : out std_logic;  -- Pulsed
    BSP_ACTIVE_ERROR_FLAG_BIT_ERROR : out std_logic;  -- Bit error was detected while
                                                      -- transmitting active error flag

    -- Interface to EML
    EML_RECV_11_RECESSIVE_BITS : out std_logic;
    EML_ERROR_STATE            : in  std_logic_vector(C_CAN_ERROR_STATE_BITSIZE-1 downto 0);

    -- Interface to BTL
    BTL_TX_BIT_VALUE           : out std_logic;
    BTL_TX_BIT_VALID           : out std_logic;
    BTL_TX_RDY                 : in  std_logic;
    BTL_TX_DONE                : in  std_logic;
    BTL_RX_BIT_VALUE           : in  std_logic;
    BTL_RX_BIT_VALID           : in  std_logic;
    BTL_RX_SYNCED              : in  std_logic;
    BTL_RX_STOP                : out std_logic;

    -- Tx and Rx FSM state register output/input - for triplication and voting of state
    RX_FSM_STATE_O       : out std_logic_vector(C_BSP_RX_FSM_STATE_BITSIZE-1 downto 0);
    RX_FSM_STATE_VOTED_I : in  std_logic_vector(C_BSP_RX_FSM_STATE_BITSIZE-1 downto 0);
    TX_FSM_STATE_O       : out std_logic_vector(C_BSP_TX_FSM_STATE_BITSIZE-1 downto 0);
    TX_FSM_STATE_VOTED_I : in  std_logic_vector(C_BSP_TX_FSM_STATE_BITSIZE-1 downto 0);

    -- Voted CRC input
    BSP_TX_CRC_CALC_VOTED_I : in std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0);
    BSP_RX_CRC_CALC_VOTED_I : in std_logic_vector(C_CAN_CRC_WIDTH-1 downto 0)
    );

end entity canola_bsp;

architecture rtl of canola_bsp is
  -----------------------------------------------------------------------------
  -- Rx FSM signals
  -----------------------------------------------------------------------------
  signal s_rx_fsm_state_out   : bsp_rx_fsm_state_t := ST_IDLE;
  signal s_rx_fsm_state_voted : bsp_rx_fsm_state_t := ST_IDLE;
  signal s_eml_error_state    : can_error_state_t;

  attribute fsm_encoding                         : string;
  attribute fsm_encoding of s_rx_fsm_state_out   : signal is "sequential";
  attribute fsm_encoding of s_rx_fsm_state_voted : signal is "sequential";
  attribute fsm_encoding of s_eml_error_state    : signal is "sequential";

  signal s_rx_bit               : std_logic;
  signal s_rx_bit_stream_window : std_logic_vector(C_ERROR_FLAG_LENGTH-1 downto 0);
  signal s_rx_update_crc_pulse  : std_logic;
  signal s_rx_restart_crc_pulse : std_logic;
  signal s_rx_data_counter      : natural range 0 to C_BSP_DATA_LENGTH;
  signal s_rx_stop_reg          : std_logic;
  signal s_rx_start_of_frame    : std_logic;

  -- Rx FSM state assertions
  -----------------------------------------------------------------------------
  -- psl default clock is rising_edge(CLK);
  -- psl assert (always {(s_rx_fsm_state_voted = ST_IDLE) and
  --                      BTL_RX_SYNCED = '1' and BTL_RX_STOP = '0'} |=>
  --                    {(s_rx_fsm_state_voted = ST_WAIT_BTL_RX_RDY)} abort RESET);
  -- Todo: Add the rest of them...

  -----------------------------------------------------------------------------
  -- Tx FSM signals
  -----------------------------------------------------------------------------
  signal s_tx_fsm_state_out   : bsp_tx_fsm_state_t := ST_IDLE;
  signal s_tx_fsm_state_voted : bsp_tx_fsm_state_t := ST_IDLE;

  attribute fsm_encoding of s_tx_fsm_state_out   : signal is "sequential";
  attribute fsm_encoding of s_tx_fsm_state_voted : signal is "sequential";

  signal s_tx_restart_crc_pulse    : std_logic;
  signal s_tx_stuff_bit            : std_logic;
  signal s_tx_data_count           : natural range 0 to C_BSP_DATA_LENGTH;
  signal s_tx_write_counter        : natural range 0 to C_BSP_DATA_LENGTH;
  signal s_tx_bit_stream_window    : std_logic_vector(C_STUFF_BIT_THRESHOLD-1 downto 0);
  signal s_tx_error_flag_shift_reg : std_logic_vector(C_ERROR_FLAG_LENGTH-1 downto 0);
  signal s_tx_frame_started        : std_logic;
  signal s_tx_send_error_flag      : std_logic;
  signal s_send_ack                : std_logic;

  -----------------------------------------------------------------------------
  -- Other signals
  -----------------------------------------------------------------------------
  signal s_11_recessive_bit_shift_reg : std_logic_vector(10 downto 0);

begin  -- architecture rtl

  -- Convert Rx FSM state register output to std_logic_vector
  RX_FSM_STATE_O <= std_logic_vector(to_unsigned(bsp_rx_fsm_state_t'pos(s_rx_fsm_state_out),
                                                 C_BSP_RX_FSM_STATE_BITSIZE));

  -- Convert voted Rx FSM state register input from std_logic_vector to bsp_rx_fsm_state_t
  s_rx_fsm_state_voted <= bsp_rx_fsm_state_t'val(to_integer(unsigned(RX_FSM_STATE_VOTED_I)));

  s_eml_error_state <= can_error_state_t'val(to_integer(unsigned(EML_ERROR_STATE)));


  proc_bsp_rx_fsm : process(CLK) is
    variable v_rx_stuff_counter  : natural range 0 to C_STUFF_BIT_THRESHOLD+1;

  begin  -- process proc_rx_fsm
    if rising_edge(CLK) then
      -- Default values
      BTL_RX_STOP               <= '0';
      BSP_RX_ACTIVE_ERROR_FLAG  <= '0';
      BSP_RX_PASSIVE_ERROR_FLAG <= '0';
      BSP_RX_IFS                <= '0';
      s_rx_update_crc_pulse     <= '0';
      s_rx_restart_crc_pulse    <= '0';

      if RESET = '1' then
        BSP_RX_DATA               <= (others => '0');
        BSP_RX_DATA_COUNT         <= (others => '0');
        s_rx_data_counter         <= 0;
        s_rx_stop_reg             <= '0';
        s_rx_start_of_frame       <= '0';

        BSP_RX_DATA_OVERFLOW      <= '0';
        BSP_RX_ACTIVE             <= '0';
      else
        -- The Rx FSM for CAN frames uses this signal to indicate it has processed the BSP data
        if BSP_RX_DATA_CLEAR = '1' then
          BSP_RX_DATA_COUNT      <= (others => '0');
          s_rx_data_counter      <= 0;
          BSP_RX_DATA_OVERFLOW   <= '0';
        else
          -- This delays data count output by one cycle,
          -- which allows data count output to be in sync with CRC output
          BSP_RX_DATA_COUNT      <= std_logic_vector(to_unsigned(s_rx_data_counter, C_BSP_DATA_LEN_BITSIZE));
        end if;

        if BSP_RX_STOP = '1' then
          s_rx_stop_reg <= '1';
        end if;

        case s_rx_fsm_state_voted is
          when ST_IDLE =>
            BSP_RX_ACTIVE       <= '0';
            s_rx_stop_reg       <= '0';
            s_rx_start_of_frame <= '0';

            -- The "bit stream window" is used to detect stuff errors and error flags
            -- Start the window with ones (recessive) at the beginning of a frame
            s_rx_bit_stream_window <= (others => '1');
            s_rx_data_counter      <= 0;
            s_rx_restart_crc_pulse <= '1';

            if BTL_RX_SYNCED = '1' and BTL_RX_STOP = '0' then
              s_rx_start_of_frame <= '1';
              BSP_RX_ACTIVE       <= '1';
              s_rx_fsm_state_out  <= ST_WAIT_BTL_RX_RDY;
            end if;

          when ST_WAIT_BTL_RX_RDY =>
            if BTL_RX_BIT_VALID = '1' then
              s_rx_bit_stream_window <= s_rx_bit_stream_window(C_ERROR_FLAG_LENGTH-2 downto 0) & BTL_RX_BIT_VALUE;
              s_rx_bit               <= BTL_RX_BIT_VALUE;
              s_rx_fsm_state_out     <= ST_PROCESS_BIT;
            end if;

          when ST_PROCESS_BIT =>
            if s_rx_bit_stream_window = C_ACTIVE_ERROR_FLAG_DATA then
              -- Always indicate active error flags and go to idle
              BSP_RX_ACTIVE_ERROR_FLAG <= '1';
              s_rx_bit_stream_window   <= (others => '0');
              s_rx_fsm_state_out       <= ST_WAIT_BUS_IDLE;

            elsif s_rx_stop_reg = '1' then
              -- Rx Frame FSM has told us to stop receiving
              s_rx_bit_stream_window <= (others => '0');
              s_rx_fsm_state_out     <= ST_WAIT_BUS_IDLE;

            elsif s_rx_bit_stream_window = C_PASSIVE_ERROR_FLAG_DATA and BSP_RX_BIT_DESTUFF_EN = '1' then
              -- A passive error flag is just 6 recessive bits, which can
              -- occur during a normal frame. Only an error if we are
              -- expecting bit stuffed data
              BSP_RX_PASSIVE_ERROR_FLAG <= '1';
              s_rx_bit_stream_window    <= (others => '0');
              s_rx_fsm_state_out        <= ST_WAIT_BUS_IDLE;

            elsif BSP_RX_BIT_DESTUFF_EN = '1' then
              s_rx_fsm_state_out            <= ST_BIT_DESTUFF;

            else
              s_rx_fsm_state_out            <= ST_DATA_BIT;
            end if;

          when ST_BIT_DESTUFF =>
            -- Don't destuff bits from before start of frame
            if s_rx_bit_stream_window(5 downto 1) = "11111" and s_rx_start_of_frame = '0' then
              -- Previous 5 bits were all high (recessive), discard current bit as a stuff bit
              -- Note: a sequence of 6 bits (error) would be detected in ST_PROCESS_BIT
              s_rx_fsm_state_out <= ST_WAIT_BTL_RX_RDY;
            elsif s_rx_bit_stream_window(5 downto 1) = "00000" then
              -- Previous 5 bits were all high (recessive), discard current bit as a stuff bit
              -- Note: a sequence of 6 bits (error) would be detected in ST_PROCESS_BIT
              s_rx_fsm_state_out <= ST_WAIT_BTL_RX_RDY;
            else
              s_rx_fsm_state_out <= ST_DATA_BIT;
            end if;

          when ST_DATA_BIT =>
            s_rx_start_of_frame <= '0';

            if s_rx_data_counter < C_BSP_DATA_LENGTH then
              BSP_RX_DATA(s_rx_data_counter) <= s_rx_bit;
              s_rx_data_counter              <= s_rx_data_counter+1;
            else
              BSP_RX_DATA_OVERFLOW <= '1';
            end if;

            s_rx_update_crc_pulse <= '1';
            s_rx_fsm_state_out    <= ST_WAIT_BTL_RX_RDY;

          when ST_WAIT_BUS_IDLE =>
            BSP_RX_IFS <= '1';

            if BTL_RX_BIT_VALID = '1' then
              s_rx_bit_stream_window <= s_rx_bit_stream_window(C_ERROR_FLAG_LENGTH-2 downto 0) & BTL_RX_BIT_VALUE;
              s_rx_fsm_state_out     <= ST_CHECK_BUS_IDLE;
            end if;

          when ST_CHECK_BUS_IDLE =>
            BSP_RX_IFS <= '1';

            if s_rx_bit_stream_window(C_IFS_LENGTH-1 downto 0) = C_IFS then
              BTL_RX_STOP        <= '1';
              s_rx_fsm_state_out <= ST_IDLE;

            -- Todo: Check for OVERLOAD flag here
            else
              s_rx_fsm_state_out <= ST_WAIT_BUS_IDLE;
            end if;

          when others =>
            BTL_RX_STOP        <= '1';
            s_rx_fsm_state_out <= ST_IDLE;
        end case;
      end if;  -- if/else RESET = '1'
    end if;  -- if rising_edge(CLK)
  end process proc_bsp_rx_fsm;



  -- Convert Tx FSM state register output to std_logic_vector
  TX_FSM_STATE_O <= std_logic_vector(to_unsigned(bsp_tx_fsm_state_t'pos(s_tx_fsm_state_out),
                                                 C_BSP_TX_FSM_STATE_BITSIZE));

  -- Convert voted Tx FSM state register input from std_logic_vector to bsp_tx_fsm_state_t
  s_tx_fsm_state_voted <= bsp_tx_fsm_state_t'val(to_integer(unsigned(TX_FSM_STATE_VOTED_I)));

  s_tx_data_count <= to_integer(unsigned(BSP_TX_DATA_COUNT));


  proc_bsp_tx_fsm : process(CLK) is
  begin  -- process proc_tx_fsm
    if rising_edge(CLK) then
      if RESET = '1' then
        s_tx_restart_crc_pulse          <= '1';
        s_tx_stuff_bit                  <= '0';
        s_tx_write_counter              <= 0;
        s_tx_bit_stream_window          <= (others => '1');  -- Recessive
        s_tx_frame_started              <= '0';
        s_tx_error_flag_shift_reg       <= (others => '0');
        s_send_ack                      <= '0';
        BSP_TX_DONE                     <= '0';
        BTL_TX_BIT_VALUE                <= '1';              -- Recessive
        BTL_TX_BIT_VALID                <= '0';
        BSP_TX_RX_MISMATCH              <= '0';
        BSP_TX_RX_STUFF_MISMATCH        <= '0';
        BSP_ACTIVE_ERROR_FLAG_BIT_ERROR <= '0';
        BSP_ERROR_FLAG_DONE             <= '0';
      else
        s_tx_restart_crc_pulse          <= '0';
        BTL_TX_BIT_VALID                <= '0';
        BSP_TX_DONE                     <= '0';
        BSP_TX_RX_MISMATCH              <= '0';
        BSP_TX_RX_STUFF_MISMATCH        <= '0';
        BSP_ACTIVE_ERROR_FLAG_BIT_ERROR <= '0';
        BSP_ERROR_FLAG_DONE             <= '0';

        case s_tx_fsm_state_voted is
          when ST_IDLE =>
            s_send_ack             <= '0';
            s_tx_frame_started     <= '0';
            s_tx_restart_crc_pulse <= '1';
            s_tx_send_error_flag   <= '0';
            s_tx_stuff_bit         <= '0';

            -- Default to recessive when idle
            s_tx_bit_stream_window <= (others => '1');

            if BSP_RX_SEND_ACK = '1' then
              BTL_TX_BIT_VALUE   <= C_ACK_VALUE;
              s_send_ack         <= '1';
              s_tx_fsm_state_out <= ST_WAIT_BTL_TX_RDY;
            elsif BSP_TX_ACTIVE = '1' then
              s_tx_fsm_state_out <= ST_WAIT_TX_DATA;
            end if;

          when ST_WAIT_TX_DATA =>
            if BSP_TX_ACTIVE = '0' then
              s_tx_fsm_state_out <= ST_IDLE;
            elsif BSP_TX_WRITE_EN = '1' then
              s_tx_write_counter <= 0;
              s_tx_fsm_state_out <= ST_PROCESS_NEXT_TX_BIT;
            end if;

          when ST_PROCESS_NEXT_TX_BIT =>
            -- Don't do bit stuffing for the first bit...
            s_tx_frame_started <= '1';

            if BSP_TX_ACTIVE = '0' then
              s_tx_fsm_state_out <= ST_IDLE;

            elsif s_tx_write_counter = s_tx_data_count then
              BSP_TX_DONE <= '1';

              -- Wait for more data
              s_tx_fsm_state_out <= ST_WAIT_TX_DATA;
            else
              if BSP_TX_BIT_STUFF_EN = '1' and s_tx_frame_started = '1' then
                if s_tx_bit_stream_window = "11111" then
                  -- Send low stuff bit after sequence of 5 ones
                  BTL_TX_BIT_VALUE   <= '0';
                  -- Stuff bit - don't calculate CRC for it
                  s_tx_stuff_bit     <= '1';
                elsif s_tx_bit_stream_window = "00000" then
                  -- Send high stuff bit after sequence of 5 zeros
                  BTL_TX_BIT_VALUE <= '1';
                  -- Stuff bit - don't calculate CRC for it
                  s_tx_stuff_bit   <= '1';
                else
                  -- Send data bit
                  BTL_TX_BIT_VALUE   <= BSP_TX_DATA(s_tx_write_counter);
                  s_tx_write_counter <= s_tx_write_counter + 1;
                  -- Not a stuff bit - calculate CRC for it
                  s_tx_stuff_bit     <= '0';
                end if;
              else
                -- Send data bit - bit stuffing disabled
                BTL_TX_BIT_VALUE   <= BSP_TX_DATA(s_tx_write_counter);
                s_tx_write_counter <= s_tx_write_counter + 1;
                -- Not a stuff bit - calculate CRC for it
                s_tx_stuff_bit     <= '0';
              end if;

              s_tx_fsm_state_out <= ST_WAIT_BTL_TX_RDY;
            end if;

          when ST_WAIT_BTL_TX_RDY =>
            if BSP_TX_ACTIVE = '0' and s_send_ack = '0' and s_tx_send_error_flag = '0' then
              s_tx_fsm_state_out <= ST_IDLE;

            elsif BTL_TX_RDY = '1' then
              -- Tell BTL to send bit when it is ready
              BTL_TX_BIT_VALID       <= '1';

              -- Shift current tx bit into stream of tx bits
              s_tx_bit_stream_window <= s_tx_bit_stream_window(C_STUFF_BIT_THRESHOLD-2 downto 0) &
                                        BTL_TX_BIT_VALUE;

              s_tx_fsm_state_out     <= ST_WAIT_BTL_TX_DONE;
            end if;

          when ST_WAIT_BTL_TX_DONE =>
            if BTL_TX_DONE = '1' then
              s_tx_stuff_bit     <= '0';
              -- Wait for bit to be processed by BTL, then verify
              -- if the same bit value is read back from BTL
              s_tx_fsm_state_out <= ST_WAIT_BTL_RX_VALID;
            end if;

          -- Read back bit that was transmitted
          when ST_WAIT_BTL_RX_VALID =>
            if BTL_RX_BIT_VALID = '1' then
              -- Tx/Rx mismatch?
              if BTL_TX_BIT_VALUE /= BTL_RX_BIT_VALUE then
                -- Tx/Rx mismatch while sending active error flag?
                if s_tx_send_error_flag = '1' and BTL_TX_BIT_VALUE = '0' then
                  BSP_ACTIVE_ERROR_FLAG_BIT_ERROR <= '1';

                -- Tx/Rx mismatch while sending passive error flag?
                elsif s_tx_send_error_flag = '1' and BTL_TX_BIT_VALUE = '1' then
                  -- The CAN 2.0B specification requires the transmitter of passive
                  -- error flag to keep trying to send it until it observes the
                  -- 6 recessive bits of the error flag on the bus (see 3.2.3 Error Frame)

                  -- Restart passive error flag by reinitializing the shift reg used
                  -- to clock out the error flag bits
                  s_tx_error_flag_shift_reg    <= (others => '0');
                  s_tx_error_flag_shift_reg(0) <= '1';
                elsif s_tx_stuff_bit = '1' then
                  BSP_TX_RX_STUFF_MISMATCH <= '1';
                else
                  BSP_TX_RX_MISMATCH <= '1';
                end if;
              end if;


              if s_tx_send_error_flag = '1' then
                s_tx_fsm_state_out <= ST_SEND_ERROR_FLAG;

              elsif BSP_TX_ACTIVE = '1' then
                if s_tx_write_counter = s_tx_data_count then
                  BSP_TX_DONE <= '1';

                  -- Wait for more data
                  s_tx_fsm_state_out <= ST_WAIT_TX_DATA;
                else
                  s_tx_fsm_state_out <= ST_PROCESS_NEXT_TX_BIT;
                end if;
              else
                s_tx_fsm_state_out <= ST_IDLE;
              end if;
            end if;

          when ST_SEND_ERROR_FLAG =>
            s_tx_send_error_flag <= '1';

            if unsigned(s_tx_error_flag_shift_reg) = 0 then
              BSP_ERROR_FLAG_DONE <= '1';
              s_tx_fsm_state_out  <= ST_IDLE;
            else
              s_tx_error_flag_shift_reg <= s_tx_error_flag_shift_reg(C_ERROR_FLAG_LENGTH-2 downto 0) & '0';
              s_tx_fsm_state_out        <= ST_WAIT_BTL_TX_RDY;
            end if;

          when others =>
            s_tx_fsm_state_out <= ST_IDLE;
        end case;

        -- If case the BSP is requested to send an error flag,
        -- ignore any other state assignments and go directly to ST_NEXT_ERROR_FLAG_BIT
        if BSP_SEND_ERROR_FLAG = '1' then
          if s_eml_error_state = ERROR_ACTIVE then
            BTL_TX_BIT_VALUE <= C_ACTIVE_ERROR_FLAG_VALUE;
          else
            BTL_TX_BIT_VALUE <= C_PASSIVE_ERROR_FLAG_VALUE;
          end if;

          s_tx_error_flag_shift_reg    <= (others => '0');
          -- This bit is shifted left as error flag bits are transmitted
          -- When the bit is shifted out of the register the error flag is done
          s_tx_error_flag_shift_reg(0) <= '1';

          s_tx_fsm_state_out           <= ST_SEND_ERROR_FLAG;
        end if;

      end if; -- if/else RESET = '0'
    end if; -- rising_edge(CLK)
  end process proc_bsp_tx_fsm;


  -- Monitor bus for 11 consecutive recessive bits,
  -- and pulse a signal for each occurance of the 11 bits
  -- The EML uses this signal to decide when it can safely
  -- return from BUS OFF state
  proc_bsp_11_recessive_bits : process(CLK) is
    variable v_11_recessive_bit_shift_reg : std_logic_vector(s_11_recessive_bit_shift_reg'range);
    constant c_11_recessive_bits          : std_logic_vector(s_11_recessive_bit_shift_reg'range) := (others => '1');
  begin  -- process proc_rx_fsm
    if rising_edge(CLK) then
      EML_RECV_11_RECESSIVE_BITS <= '0';

      if RESET = '1' then
        -- Don't have to reset all bits, first is sufficient
        s_11_recessive_bit_shift_reg(0) <= '0';
      else
        if BTL_RX_BIT_VALID = '1' then
          v_11_recessive_bit_shift_reg(0)           := BTL_RX_BIT_VALUE;
          v_11_recessive_bit_shift_reg(10 downto 1) := s_11_recessive_bit_shift_reg(9 downto 0);
          s_11_recessive_bit_shift_reg              <= v_11_recessive_bit_shift_reg;

        elsif s_11_recessive_bit_shift_reg = c_11_recessive_bits then
          EML_RECV_11_RECESSIVE_BITS   <= '1';

          -- Restart count (don't have to reset all bits, first bit is sufficient)
          s_11_recessive_bit_shift_reg(0) <= '0';
        end if;
      end if;  -- if/else RESET = '1'
    end if;  -- if rising_edge(CLK)
  end process proc_bsp_11_recessive_bits;

  -- Todo:
  -- Use only one CRC calculator for both Tx and Rx
  -- Since Rx FSM trails the Tx FSM, in principle
  -- they should have the same CRC values?
  INST_canola_crc_rx: entity work.canola_crc
    port map (
      CLK       => CLK,
      RESET     => RESET or s_rx_restart_crc_pulse,
      BIT_IN    => s_rx_bit,
      BIT_VALID => s_rx_update_crc_pulse,
      CRC_IN    => BSP_RX_CRC_CALC_VOTED_I,
      CRC_OUT   => BSP_RX_CRC_CALC_O);

  INST_canola_crc_tx: entity work.canola_crc
    port map (
      CLK       => CLK,
      RESET     => RESET or s_tx_restart_crc_pulse,
      BIT_IN    => BTL_TX_BIT_VALUE,
      BIT_VALID => BTL_TX_BIT_VALID and not s_tx_stuff_bit,
      CRC_IN    => BSP_TX_CRC_CALC_VOTED_I,
      CRC_OUT   => BSP_TX_CRC_CALC_O);


end architecture rtl;
