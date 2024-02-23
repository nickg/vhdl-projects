-------------------------------------------------------------------------------
-- Title      : Register definitions for OpenCores CAN controller
-- Project    : Canola CAN Controller
-------------------------------------------------------------------------------
-- File       : can_register_pkg.vhd
-- Author     : Simon Voigt Nesbø  <svn@hvl.no>
-- Company    :
-- Created    : 2019-06-26
-- Last update: 2020-09-18
-- Platform   :
-- Standard   : VHDL'08
-------------------------------------------------------------------------------
-- Description: Package with register address definitions for use with the
--              OpenCores CAN controller.
--              Used by the testbench that tests the Canola and OpenCores
--              controllers together
-------------------------------------------------------------------------------
-- Copyright (c) 2019
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-06-26  1.0      svn     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package can_register_pkg is
  ------------------------------------------------------------------------------
  -- Note:
  -- Availability of registers also depend on whether the module is
  -- in reset mode or operation mode. Refer to SJA1000 datasheet.
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Common register map for basic and extended mode
  ------------------------------------------------------------------------------
  constant C_CAN_CMR  : natural := 1;   -- Command register
  constant C_CAN_SR   : natural := 2;   -- Status register
  constant C_CAN_IR   : natural := 3;   -- Interrupt Register
  constant C_CAN_BTR0 : natural := 6;   -- Bus timing 0 register
  constant C_CAN_BTR1 : natural := 7;   -- Bus timing 1 register
  constant C_CAN_CDR  : natural := 31;  -- Clock divider register


  ------------------------------------------------------------------------------
  -- BASIC Mode register map
  ------------------------------------------------------------------------------
  constant C_CAN_BM_CR        : natural := 0;   -- Control register
  constant C_CAN_BM_ACR       : natural := 4;   -- Acceptance code register
  constant C_CAN_BM_AMR       : natural := 5;   -- Acceptance mask register
  constant C_CAN_BM_TXB_ID1   : natural := 10;  -- TX buffer - ID byte 1 (10:3)
  constant C_CAN_BM_TXB_ID2   : natural := 11;  -- TX buffer - ID byte 2 (2:0)
  constant C_CAN_BM_TXB_DATA1 : natural := 12;  -- TX buffer - ID data 1
  constant C_CAN_BM_TXB_DATA2 : natural := 13;  -- TX buffer - ID data 2
  constant C_CAN_BM_TXB_DATA3 : natural := 14;  -- TX buffer - ID data 3
  constant C_CAN_BM_TXB_DATA4 : natural := 15;  -- TX buffer - ID data 4
  constant C_CAN_BM_TXB_DATA5 : natural := 16;  -- TX buffer - ID data 5
  constant C_CAN_BM_TXB_DATA6 : natural := 17;  -- TX buffer - ID data 6
  constant C_CAN_BM_TXB_DATA7 : natural := 18;  -- TX buffer - ID data 7
  constant C_CAN_BM_TXB_DATA8 : natural := 19;  -- TX buffer - ID data 8
  constant C_CAN_BM_RXB_ID1   : natural := 20;  -- RX buffer - ID byte 1 (10:3)
  constant C_CAN_BM_RXB_ID2   : natural := 21;  -- RX buffer - ID byte 2 (2:0)
  constant C_CAN_BM_RXB_DATA1 : natural := 22;  -- RX buffer - ID data 1
  constant C_CAN_BM_RXB_DATA2 : natural := 23;  -- RX buffer - ID data 2
  constant C_CAN_BM_RXB_DATA3 : natural := 24;  -- RX buffer - ID data 3
  constant C_CAN_BM_RXB_DATA4 : natural := 25;  -- RX buffer - ID data 4
  constant C_CAN_BM_RXB_DATA5 : natural := 26;  -- RX buffer - ID data 5
  constant C_CAN_BM_RXB_DATA6 : natural := 27;  -- RX buffer - ID data 6
  constant C_CAN_BM_RXB_DATA7 : natural := 28;  -- RX buffer - ID data 7
  constant C_CAN_BM_RXB_DATA8 : natural := 29;  -- RX buffer - ID data 8


  ------------------------------------------------------------------------------
  -- EXTENDED Mode register map
  ------------------------------------------------------------------------------
  constant C_CAN_EM_MOD   : natural := 0;   -- Mode register
  constant C_CAN_EM_IER   : natural := 4;   -- Interrupt enable register
  constant C_CAN_EM_ALC   : natural := 11;  -- Arbitration lost register
  constant C_CAN_EM_ECC   : natural := 12;  -- Error code capture register
  constant C_CAN_EM_EWLR  : natural := 13;  -- Error warning limit register
  constant C_CAN_EM_RXERR : natural := 14;  -- RX error counter register
  constant C_CAN_EM_TXERR : natural := 15;  -- TX error counter register

  -- TX frame information (in operation mode only)
  -- SFF in standard mode, EFF in extended mode
  constant C_CAN_EM_SFF       : natural := 16;  -- TX frame information register
  constant C_CAN_EM_EFF       : natural := 16;  -- TX frame information register


  -- TX/RX data buffer (in operation mode only)
  -- Write operation writes to TX buffer, read operation reads from RX buffer
  -- SFF registers are valid when using standard frame, EFF registers are
  -- valid when using extended frame
  constant C_CAN_EM_SFF_TXB_ID1   : natural := 17;  -- TX buffer - ID byte 1 (10:3)
  constant C_CAN_EM_SFF_TXB_ID2   : natural := 18;  -- TX buffer - ID byte 2 (2:0)
  constant C_CAN_EM_SFF_TXB_DATA1 : natural := 19;  -- TX buffer - ID data 1
  constant C_CAN_EM_SFF_TXB_DATA2 : natural := 20;  -- TX buffer - ID data 2
  constant C_CAN_EM_SFF_TXB_DATA3 : natural := 21;  -- TX buffer - ID data 3
  constant C_CAN_EM_SFF_TXB_DATA4 : natural := 22;  -- TX buffer - ID data 4
  constant C_CAN_EM_SFF_TXB_DATA5 : natural := 23;  -- TX buffer - ID data 5
  constant C_CAN_EM_SFF_TXB_DATA6 : natural := 24;  -- TX buffer - ID data 6
  constant C_CAN_EM_SFF_TXB_DATA7 : natural := 25;  -- TX buffer - ID data 7
  constant C_CAN_EM_SFF_TXB_DATA8 : natural := 26;  -- TX buffer - ID data 8

  constant C_CAN_EM_SFF_RXB_ID1   : natural := 17;  -- RX buffer - ID byte 1 (10:3)
  constant C_CAN_EM_SFF_RXB_ID2   : natural := 18;  -- RX buffer - ID byte 2 (2:0)
  constant C_CAN_EM_SFF_RXB_DATA1 : natural := 19;  -- RX buffer - ID data 1
  constant C_CAN_EM_SFF_RXB_DATA2 : natural := 20;  -- RX buffer - ID data 2
  constant C_CAN_EM_SFF_RXB_DATA3 : natural := 21;  -- RX buffer - ID data 3
  constant C_CAN_EM_SFF_RXB_DATA4 : natural := 22;  -- RX buffer - ID data 4
  constant C_CAN_EM_SFF_RXB_DATA5 : natural := 23;  -- RX buffer - ID data 5
  constant C_CAN_EM_SFF_RXB_DATA6 : natural := 24;  -- RX buffer - ID data 6
  constant C_CAN_EM_SFF_RXB_DATA7 : natural := 25;  -- RX buffer - ID data 7
  constant C_CAN_EM_SFF_RXB_DATA8 : natural := 26;  -- RX buffer - ID data 8

  constant C_CAN_EM_EFF_TXB_ID1   : natural := 17;  -- TX buffer - ID byte 1 (28:21)
  constant C_CAN_EM_EFF_TXB_ID2   : natural := 18;  -- TX buffer - ID byte 2 (20:13)
  constant C_CAN_EM_EFF_TXB_ID3   : natural := 19;  -- TX buffer - ID byte 1 (12:5)
  constant C_CAN_EM_EFF_TXB_ID4   : natural := 20;  -- TX buffer - ID byte 2 (4:0)
  constant C_CAN_EM_EFF_TXB_DATA1 : natural := 21;  -- TX buffer - ID data 1
  constant C_CAN_EM_EFF_TXB_DATA2 : natural := 22;  -- TX buffer - ID data 2
  constant C_CAN_EM_EFF_TXB_DATA3 : natural := 23;  -- TX buffer - ID data 3
  constant C_CAN_EM_EFF_TXB_DATA4 : natural := 24;  -- TX buffer - ID data 4
  constant C_CAN_EM_EFF_TXB_DATA5 : natural := 25;  -- TX buffer - ID data 5
  constant C_CAN_EM_EFF_TXB_DATA6 : natural := 26;  -- TX buffer - ID data 6
  constant C_CAN_EM_EFF_TXB_DATA7 : natural := 27;  -- TX buffer - ID data 7
  constant C_CAN_EM_EFF_TXB_DATA8 : natural := 28;  -- TX buffer - ID data 8

  constant C_CAN_EM_EFF_RXB_ID1   : natural := 17;  -- RX buffer - ID byte 1 (28:21)
  constant C_CAN_EM_EFF_RXB_ID2   : natural := 18;  -- RX buffer - ID byte 2 (20:13)
  constant C_CAN_EM_EFF_RXB_ID3   : natural := 19;  -- RX buffer - ID byte 1 (12:5)
  constant C_CAN_EM_EFF_RXB_ID4   : natural := 20;  -- RX buffer - ID byte 2 (4:0)
  constant C_CAN_EM_EFF_RXB_DATA1 : natural := 21;  -- RX buffer - ID data 1
  constant C_CAN_EM_EFF_RXB_DATA2 : natural := 22;  -- RX buffer - ID data 2
  constant C_CAN_EM_EFF_RXB_DATA3 : natural := 23;  -- RX buffer - ID data 3
  constant C_CAN_EM_EFF_RXB_DATA4 : natural := 24;  -- RX buffer - ID data 4
  constant C_CAN_EM_EFF_RXB_DATA5 : natural := 25;  -- RX buffer - ID data 5
  constant C_CAN_EM_EFF_RXB_DATA6 : natural := 26;  -- RX buffer - ID data 6
  constant C_CAN_EM_EFF_RXB_DATA7 : natural := 27;  -- RX buffer - ID data 7
  constant C_CAN_EM_EFF_RXB_DATA8 : natural := 28;  -- RX buffer - ID data 8

  -- Acceptance code/mask registers (available in reset mode only)
  constant C_CAN_EM_ACR0      : natural := 16;  -- Acceptance Code 0
  constant C_CAN_EM_ACR1      : natural := 17;  -- Acceptance Code 1
  constant C_CAN_EM_ACR2      : natural := 18;  -- Acceptance Code 2
  constant C_CAN_EM_ACR3      : natural := 19;  -- Acceptance Code 3
  constant C_CAN_EM_AMR0      : natural := 20;  -- Acceptance Mask 0
  constant C_CAN_EM_AMR1      : natural := 21;  -- Acceptance Mask 1
  constant C_CAN_EM_AMR2      : natural := 22;  -- Acceptance Mask 2
  constant C_CAN_EM_AMR3      : natural := 23;  -- Acceptance Mask 3


  -- Rx message count and buffer start address
  -- (available in operation and
  constant C_CAN_EM_RMC       : natural := 29;  -- RX Message Counter
  constant C_CAN_EM_RBSA      : natural := 30;  -- RX Buffer Start Address


  ------------------------------------------------------------------------------
  --Interrupt Register (IR) bit definitions
  ------------------------------------------------------------------------------
  constant C_CAN_IR_RI_IRQ_BIT  : natural := 0;  -- Receive Interrupt
  constant C_CAN_IR_TI_IRQ_BIT  : natural := 1;  -- Transmit Interrupt
  constant C_CAN_IR_EI_IRQ_BIT  : natural := 2;  -- Error warning Interrupt
  constant C_CAN_IR_DOI_IRQ_BIT : natural := 3;  -- Data Overrun Interrupt
  constant C_CAN_IR_WUI_IRQ_BIT : natural := 4;  -- Wake-Up Interrupt
  constant C_CAN_IR_EPI_IRQ_BIT : natural := 5;  -- Error Passive Interrupt
  constant C_CAN_IR_ALI_IRQ_BIT : natural := 6;  -- Arbitration Lost Interrupt
  constant C_CAN_IR_BEI_IRQ_BIT : natural := 7;  -- Bus Error Interrupt


end package can_register_pkg;

package body can_register_pkg is
end package body;
