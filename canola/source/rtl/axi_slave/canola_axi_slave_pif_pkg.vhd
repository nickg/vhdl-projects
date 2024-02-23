library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package canola_axi_slave_pif_pkg is

  constant C_CANOLA_AXI_SLAVE_ADDR_WIDTH : natural := 32;
  constant C_CANOLA_AXI_SLAVE_DATA_WIDTH : natural := 32;
  
  subtype t_canola_axi_slave_addr is std_logic_vector(C_CANOLA_AXI_SLAVE_ADDR_WIDTH-1 downto 0);
  subtype t_canola_axi_slave_data is std_logic_vector(C_CANOLA_AXI_SLAVE_DATA_WIDTH-1 downto 0);
  
  constant C_ADDR_STATUS : t_canola_axi_slave_addr := 32X"0";
  constant C_ADDR_CONTROL : t_canola_axi_slave_addr := 32X"4";
  constant C_ADDR_CONFIG : t_canola_axi_slave_addr := 32X"8";
  constant C_ADDR_BTL_PROP_SEG : t_canola_axi_slave_addr := 32X"20";
  constant C_ADDR_BTL_PHASE_SEG1 : t_canola_axi_slave_addr := 32X"24";
  constant C_ADDR_BTL_PHASE_SEG2 : t_canola_axi_slave_addr := 32X"28";
  constant C_ADDR_BTL_SYNC_JUMP_WIDTH : t_canola_axi_slave_addr := 32X"2C";
  constant C_ADDR_TIME_QUANTA_CLOCK_SCALE : t_canola_axi_slave_addr := 32X"30";
  constant C_ADDR_TRANSMIT_ERROR_COUNT : t_canola_axi_slave_addr := 32X"34";
  constant C_ADDR_RECEIVE_ERROR_COUNT : t_canola_axi_slave_addr := 32X"38";
  constant C_ADDR_TX_MSG_SENT_COUNT : t_canola_axi_slave_addr := 32X"3C";
  constant C_ADDR_TX_FAILED_COUNT : t_canola_axi_slave_addr := 32X"40";
  constant C_ADDR_TX_ACK_ERROR_COUNT : t_canola_axi_slave_addr := 32X"44";
  constant C_ADDR_TX_ARB_LOST_COUNT : t_canola_axi_slave_addr := 32X"48";
  constant C_ADDR_TX_BIT_ERROR_COUNT : t_canola_axi_slave_addr := 32X"4C";
  constant C_ADDR_TX_RETRANSMIT_COUNT : t_canola_axi_slave_addr := 32X"50";
  constant C_ADDR_RX_MSG_RECV_COUNT : t_canola_axi_slave_addr := 32X"54";
  constant C_ADDR_RX_CRC_ERROR_COUNT : t_canola_axi_slave_addr := 32X"58";
  constant C_ADDR_RX_FORM_ERROR_COUNT : t_canola_axi_slave_addr := 32X"5C";
  constant C_ADDR_RX_STUFF_ERROR_COUNT : t_canola_axi_slave_addr := 32X"60";
  constant C_ADDR_TX_MSG_ID : t_canola_axi_slave_addr := 32X"64";
  constant C_ADDR_TX_PAYLOAD_LENGTH : t_canola_axi_slave_addr := 32X"68";
  constant C_ADDR_TX_PAYLOAD_0 : t_canola_axi_slave_addr := 32X"6C";
  constant C_ADDR_TX_PAYLOAD_1 : t_canola_axi_slave_addr := 32X"70";
  constant C_ADDR_RX_MSG_ID : t_canola_axi_slave_addr := 32X"74";
  constant C_ADDR_RX_PAYLOAD_LENGTH : t_canola_axi_slave_addr := 32X"78";
  constant C_ADDR_RX_PAYLOAD_0 : t_canola_axi_slave_addr := 32X"7C";
  constant C_ADDR_RX_PAYLOAD_1 : t_canola_axi_slave_addr := 32X"80";
  
  -- RW Register Record Definitions
  
  type t_canola_axi_slave_rw_CONFIG is record
    TX_RETRANSMIT_EN : std_logic;
    BTL_TRIPLE_SAMPLING_EN : std_logic;
  end record;
  
  type t_canola_axi_slave_rw_TX_MSG_ID is record
    EXT_ID_EN : std_logic;
    RTR_EN : std_logic;
    ARB_ID_B : std_logic_vector(17 downto 0);
    ARB_ID_A : std_logic_vector(10 downto 0);
  end record;
  
  type t_canola_axi_slave_rw_TX_PAYLOAD_0 is record
    PAYLOAD_BYTE_0 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_1 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_2 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_3 : std_logic_vector(7 downto 0);
  end record;
  
  type t_canola_axi_slave_rw_TX_PAYLOAD_1 is record
    PAYLOAD_BYTE_4 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_5 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_6 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_7 : std_logic_vector(7 downto 0);
  end record;
  
  type t_canola_axi_slave_rw_regs is record
    CONFIG : t_canola_axi_slave_rw_CONFIG;
    BTL_PROP_SEG : std_logic_vector(15 downto 0);
    BTL_PHASE_SEG1 : std_logic_vector(15 downto 0);
    BTL_PHASE_SEG2 : std_logic_vector(15 downto 0);
    BTL_SYNC_JUMP_WIDTH : std_logic_vector(2 downto 0);
    TIME_QUANTA_CLOCK_SCALE : std_logic_vector(7 downto 0);
    TX_MSG_ID : t_canola_axi_slave_rw_TX_MSG_ID;
    TX_PAYLOAD_LENGTH : std_logic_vector(3 downto 0);
    TX_PAYLOAD_0 : t_canola_axi_slave_rw_TX_PAYLOAD_0;
    TX_PAYLOAD_1 : t_canola_axi_slave_rw_TX_PAYLOAD_1;
  end record;

  -- RW Register Reset Value Constant
  
  constant c_canola_axi_slave_rw_regs : t_canola_axi_slave_rw_regs := (
    CONFIG => (
      TX_RETRANSMIT_EN => '0',
      BTL_TRIPLE_SAMPLING_EN => '0'),
    BTL_PROP_SEG => 16X"7",
    BTL_PHASE_SEG1 => 16X"7",
    BTL_PHASE_SEG2 => 16X"7",
    BTL_SYNC_JUMP_WIDTH => 3X"1",
    TIME_QUANTA_CLOCK_SCALE => 8X"F",
    TX_MSG_ID => (
      EXT_ID_EN => '0',
      RTR_EN => '0',
      ARB_ID_B => (others => '0'),
      ARB_ID_A => (others => '0')),
    TX_PAYLOAD_LENGTH => (others => '0'),
    TX_PAYLOAD_0 => (
      PAYLOAD_BYTE_0 => (others => '0'),
      PAYLOAD_BYTE_1 => (others => '0'),
      PAYLOAD_BYTE_2 => (others => '0'),
      PAYLOAD_BYTE_3 => (others => '0')),
    TX_PAYLOAD_1 => (
      PAYLOAD_BYTE_4 => (others => '0'),
      PAYLOAD_BYTE_5 => (others => '0'),
      PAYLOAD_BYTE_6 => (others => '0'),
      PAYLOAD_BYTE_7 => (others => '0')));

  -- RO Register Record Definitions
  
  type t_canola_axi_slave_ro_STATUS is record
    RX_MSG_VALID : std_logic;
    TX_BUSY : std_logic;
    TX_DONE : std_logic;
    TX_FAILED : std_logic;
    ERROR_STATE : std_logic_vector(1 downto 0);
  end record;
  
  type t_canola_axi_slave_ro_RX_MSG_ID is record
    EXT_ID_EN : std_logic;
    RTR_EN : std_logic;
    ARB_ID_B : std_logic_vector(17 downto 0);
    ARB_ID_A : std_logic_vector(10 downto 0);
  end record;
  
  type t_canola_axi_slave_ro_RX_PAYLOAD_0 is record
    PAYLOAD_BYTE_0 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_1 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_2 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_3 : std_logic_vector(7 downto 0);
  end record;
  
  type t_canola_axi_slave_ro_RX_PAYLOAD_1 is record
    PAYLOAD_BYTE_4 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_5 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_6 : std_logic_vector(7 downto 0);
    PAYLOAD_BYTE_7 : std_logic_vector(7 downto 0);
  end record;
  
  type t_canola_axi_slave_ro_regs is record
    STATUS : t_canola_axi_slave_ro_STATUS;
    TRANSMIT_ERROR_COUNT : std_logic_vector(15 downto 0);
    RECEIVE_ERROR_COUNT : std_logic_vector(15 downto 0);
    TX_MSG_SENT_COUNT : t_canola_axi_slave_data;
    TX_FAILED_COUNT : t_canola_axi_slave_data;
    TX_ACK_ERROR_COUNT : t_canola_axi_slave_data;
    TX_ARB_LOST_COUNT : t_canola_axi_slave_data;
    TX_BIT_ERROR_COUNT : t_canola_axi_slave_data;
    TX_RETRANSMIT_COUNT : t_canola_axi_slave_data;
    RX_MSG_RECV_COUNT : t_canola_axi_slave_data;
    RX_CRC_ERROR_COUNT : t_canola_axi_slave_data;
    RX_FORM_ERROR_COUNT : t_canola_axi_slave_data;
    RX_STUFF_ERROR_COUNT : t_canola_axi_slave_data;
    RX_MSG_ID : t_canola_axi_slave_ro_RX_MSG_ID;
    RX_PAYLOAD_LENGTH : std_logic_vector(3 downto 0);
    RX_PAYLOAD_0 : t_canola_axi_slave_ro_RX_PAYLOAD_0;
    RX_PAYLOAD_1 : t_canola_axi_slave_ro_RX_PAYLOAD_1;
  end record;

  -- RO Register Reset Value Constant
  
  constant c_canola_axi_slave_ro_regs : t_canola_axi_slave_ro_regs := (
    STATUS => (
      RX_MSG_VALID => '0',
      TX_BUSY => '0',
      TX_DONE => '0',
      TX_FAILED => '0',
      ERROR_STATE => (others => '0')),
    TRANSMIT_ERROR_COUNT => (others => '0'),
    RECEIVE_ERROR_COUNT => (others => '0'),
    TX_MSG_SENT_COUNT => (others => '0'),
    TX_FAILED_COUNT => (others => '0'),
    TX_ACK_ERROR_COUNT => (others => '0'),
    TX_ARB_LOST_COUNT => (others => '0'),
    TX_BIT_ERROR_COUNT => (others => '0'),
    TX_RETRANSMIT_COUNT => (others => '0'),
    RX_MSG_RECV_COUNT => (others => '0'),
    RX_CRC_ERROR_COUNT => (others => '0'),
    RX_FORM_ERROR_COUNT => (others => '0'),
    RX_STUFF_ERROR_COUNT => (others => '0'),
    RX_MSG_ID => (
      EXT_ID_EN => '0',
      RTR_EN => '0',
      ARB_ID_B => (others => '0'),
      ARB_ID_A => (others => '0')),
    RX_PAYLOAD_LENGTH => (others => '0'),
    RX_PAYLOAD_0 => (
      PAYLOAD_BYTE_0 => (others => '0'),
      PAYLOAD_BYTE_1 => (others => '0'),
      PAYLOAD_BYTE_2 => (others => '0'),
      PAYLOAD_BYTE_3 => (others => '0')),
    RX_PAYLOAD_1 => (
      PAYLOAD_BYTE_4 => (others => '0'),
      PAYLOAD_BYTE_5 => (others => '0'),
      PAYLOAD_BYTE_6 => (others => '0'),
      PAYLOAD_BYTE_7 => (others => '0')));
  -- PULSE Register Record Definitions
  
  type t_canola_axi_slave_pulse_CONTROL is record
    TX_START : std_logic;
    RESET_TX_MSG_SENT_COUNTER : std_logic;
    RESET_TX_FAILED_COUNTER : std_logic;
    RESET_TX_ACK_ERROR_COUNTER : std_logic;
    RESET_TX_ARB_LOST_COUNTER : std_logic;
    RESET_TX_BIT_ERROR_COUNTER : std_logic;
    RESET_TX_RETRANSMIT_COUNTER : std_logic;
    RESET_RX_MSG_RECV_COUNTER : std_logic;
    RESET_RX_CRC_ERROR_COUNTER : std_logic;
    RESET_RX_FORM_ERROR_COUNTER : std_logic;
    RESET_RX_STUFF_ERROR_COUNTER : std_logic;
  end record;
  
  type t_canola_axi_slave_pulse_regs is record
    CONTROL : t_canola_axi_slave_pulse_CONTROL;
  end record;

  -- PULSE Register Reset Value Constant
  
  constant c_canola_axi_slave_pulse_regs : t_canola_axi_slave_pulse_regs := (
    CONTROL => (
      TX_START => '0',
      RESET_TX_MSG_SENT_COUNTER => '0',
      RESET_TX_FAILED_COUNTER => '0',
      RESET_TX_ACK_ERROR_COUNTER => '0',
      RESET_TX_ARB_LOST_COUNTER => '0',
      RESET_TX_BIT_ERROR_COUNTER => '0',
      RESET_TX_RETRANSMIT_COUNTER => '0',
      RESET_RX_MSG_RECV_COUNTER => '0',
      RESET_RX_CRC_ERROR_COUNTER => '0',
      RESET_RX_FORM_ERROR_COUNTER => '0',
      RESET_RX_STUFF_ERROR_COUNTER => '0'));


end package canola_axi_slave_pif_pkg;