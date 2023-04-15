-----------------------------------------------------------------------------------
--!     @file    interface_components.vhd                                        --
--!     @brief   Merge Sorter Interface Component Library Description Package    --
--!     @version 1.3.0                                                           --
--!     @date    2021/07/16                                                      --
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>                     --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--                                                                               --
--      Copyright (C) 2021 Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>           --
--      All rights reserved.                                                     --
--                                                                               --
--      Redistribution and use in source and binary forms, with or without       --
--      modification, are permitted provided that the following conditions       --
--      are met:                                                                 --
--                                                                               --
--        1. Redistributions of source code must retain the above copyright      --
--           notice, this list of conditions and the following disclaimer.       --
--                                                                               --
--        2. Redistributions in binary form must reproduce the above copyright   --
--           notice, this list of conditions and the following disclaimer in     --
--           the documentation and/or other materials provided with the          --
--           distribution.                                                       --
--                                                                               --
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT    --
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,    --
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT         --
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,    --
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY    --
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT      --
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE    --
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.     --
--                                                                               --
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library Merge_Sorter;
use     Merge_Sorter.Interface;
-----------------------------------------------------------------------------------
--! @brief Merge Sorter Interface Component Library Description Package          --
-----------------------------------------------------------------------------------
package Interface_Components is
-----------------------------------------------------------------------------------
--! @brief Merge_Reader                                                          --
-----------------------------------------------------------------------------------
component Merge_Reader
    generic (
        CHANNEL         :  integer :=  0;
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        REG_PARAM       :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
        REQ_ADDR_BITS   :  integer := 32;
        REQ_SIZE_BITS   :  integer := 32;
        BUF_DATA_BITS   :  integer := 64;
        BUF_DEPTH       :  integer := 13;
        MAX_XFER_SIZE   :  integer := 12;
        ARB_NODE_NUM    :  integer :=  4;
        ARB_PIPELINE    :  integer :=  0
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock/Reset Signals.
    -------------------------------------------------------------------------------
        CLK             :  in  std_logic;
        RST             :  in  std_logic;
        CLR             :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Register Interface
    -------------------------------------------------------------------------------
        REG_L           :  in  std_logic_vector(REG_PARAM.BITS     -1 downto 0);
        REG_D           :  in  std_logic_vector(REG_PARAM.BITS     -1 downto 0);
        REG_Q           :  out std_logic_vector(REG_PARAM.BITS     -1 downto 0);
    -------------------------------------------------------------------------------
    -- Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_VALID       :  out std_logic;
        REQ_ADDR        :  out std_logic_vector(REQ_ADDR_BITS      -1 downto 0);
        REQ_SIZE        :  out std_logic_vector(REQ_SIZE_BITS      -1 downto 0);
        REQ_BUF_PTR     :  out std_logic_vector(BUF_DEPTH          -1 downto 0);
        REQ_MODE        :  out std_logic_vector(REG_PARAM.MODE.BITS-1 downto 0);
        REQ_FIRST       :  out std_logic;
        REQ_LAST        :  out std_logic;
        REQ_NONE        :  out std_logic;
        REQ_READY       :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Transaction Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        ACK_VALID       :  in  std_logic;
        ACK_SIZE        :  in  std_logic_vector(BUF_DEPTH         downto 0);
        ACK_ERROR       :  in  std_logic := '0';
        ACK_NEXT        :  in  std_logic;
        ACK_LAST        :  in  std_logic;
        ACK_STOP        :  in  std_logic;
        ACK_NONE        :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Transfer Status Signals.
    -------------------------------------------------------------------------------
        XFER_BUSY       :  in  std_logic;
        XFER_DONE       :  in  std_logic;
        XFER_ERROR      :  in  std_logic := '0';
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      :  out std_logic;
        FLOW_PAUSE      :  out std_logic;
        FLOW_STOP       :  out std_logic;
        FLOW_LAST       :  out std_logic;
        FLOW_SIZE       :  out std_logic_vector(BUF_DEPTH         downto 0);
        PUSH_FIN_VALID  :  in  std_logic;
        PUSH_FIN_LAST   :  in  std_logic;
        PUSH_FIN_ERROR  :  in  std_logic := '0';
        PUSH_FIN_SIZE   :  in  std_logic_vector(BUF_DEPTH         downto 0);
        PUSH_BUF_RESET  :  in  std_logic := '0';
        PUSH_BUF_VALID  :  in  std_logic := '0';
        PUSH_BUF_LAST   :  in  std_logic;
        PUSH_BUF_ERROR  :  in  std_logic := '0';
        PUSH_BUF_SIZE   :  in  std_logic_vector(BUF_DEPTH         downto 0);
        PUSH_BUF_READY  :  out std_logic;
    -------------------------------------------------------------------------------
    -- Buffer Interface Signals.
    -------------------------------------------------------------------------------
        BUF_WEN         :  in  std_logic;
        BUF_BEN         :  in  std_logic_vector(BUF_DATA_BITS/8-1 downto 0);
        BUF_DATA        :  in  std_logic_vector(BUF_DATA_BITS  -1 downto 0);
        BUF_PTR         :  in  std_logic_vector(BUF_DEPTH      -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Outlet Signals.
    -------------------------------------------------------------------------------
        MRG_DATA        :  out std_logic_vector(WORDS*WORD_BITS-1 downto 0);
        MRG_NONE        :  out std_logic_vector(WORDS          -1 downto 0);
        MRG_EBLK        :  out std_logic;
        MRG_LAST        :  out std_logic;
        MRG_VALID       :  out std_logic;
        MRG_READY       :  in  std_logic;
        MRG_LEVEL       :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief Merge_Writer                                                          --
-----------------------------------------------------------------------------------
component Merge_Writer
    generic (
        CHANNEL         :  integer :=  0;
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        REG_PARAM       :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
        REQ_ADDR_BITS   :  integer := 32;
        REQ_SIZE_BITS   :  integer := 32;
        BUF_DATA_BITS   :  integer := 64;
        BUF_DEPTH       :  integer := 13;
        MAX_XFER_SIZE   :  integer := 12
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock/Reset Signals.
    -------------------------------------------------------------------------------
        CLK             :  in  std_logic;
        RST             :  in  std_logic;
        CLR             :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Register Interface
    -------------------------------------------------------------------------------
        REG_L           :  in  std_logic_vector(REG_PARAM.BITS     -1 downto 0);
        REG_D           :  in  std_logic_vector(REG_PARAM.BITS     -1 downto 0);
        REG_Q           :  out std_logic_vector(REG_PARAM.BITS     -1 downto 0);
    -------------------------------------------------------------------------------
    -- Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_VALID       :  out std_logic;
        REQ_ADDR        :  out std_logic_vector(REQ_ADDR_BITS      -1 downto 0);
        REQ_SIZE        :  out std_logic_vector(REQ_SIZE_BITS      -1 downto 0);
        REQ_BUF_PTR     :  out std_logic_vector(BUF_DEPTH          -1 downto 0);
        REQ_MODE        :  out std_logic_vector(REG_PARAM.MODE.BITS-1 downto 0);
        REQ_FIRST       :  out std_logic;
        REQ_LAST        :  out std_logic;
        REQ_NONE        :  out std_logic;
        REQ_READY       :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Transaction Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        ACK_VALID       :  in  std_logic;
        ACK_SIZE        :  in  std_logic_vector(BUF_DEPTH         downto 0);
        ACK_ERROR       :  in  std_logic := '0';
        ACK_NEXT        :  in  std_logic;
        ACK_LAST        :  in  std_logic;
        ACK_STOP        :  in  std_logic;
        ACK_NONE        :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Transfer Status Signals.
    -------------------------------------------------------------------------------
        XFER_BUSY       :  in  std_logic;
        XFER_DONE       :  in  std_logic;
        XFER_ERROR      :  in  std_logic := '0';
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      :  out std_logic;
        FLOW_PAUSE      :  out std_logic;
        FLOW_STOP       :  out std_logic;
        FLOW_LAST       :  out std_logic;
        FLOW_SIZE       :  out std_logic_vector(BUF_DEPTH         downto 0);
        PULL_FIN_VALID  :  in  std_logic;
        PULL_FIN_LAST   :  in  std_logic;
        PULL_FIN_ERROR  :  in  std_logic := '0';
        PULL_FIN_SIZE   :  in  std_logic_vector(BUF_DEPTH         downto 0);
        PULL_BUF_RESET  :  in  std_logic := '0';
        PULL_BUF_VALID  :  in  std_logic := '0';
        PULL_BUF_LAST   :  in  std_logic;
        PULL_BUF_ERROR  :  in  std_logic := '0';
        PULL_BUF_SIZE   :  in  std_logic_vector(BUF_DEPTH         downto 0);
        PULL_BUF_READY  :  out std_logic;
    -------------------------------------------------------------------------------
    -- Buffer Interface Signals.
    -------------------------------------------------------------------------------
        BUF_DATA        :  out std_logic_vector(BUF_DATA_BITS  -1 downto 0);
        BUF_PTR         :  in  std_logic_vector(BUF_DEPTH      -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Intake Signals.
    -------------------------------------------------------------------------------
        MRG_DATA        :  in  std_logic_vector(WORDS*WORD_BITS-1 downto 0);
        MRG_STRB        :  in  std_logic_vector(WORDS          -1 downto 0);
        MRG_LAST        :  in  std_logic;
        MRG_VALID       :  in  std_logic;
        MRG_READY       :  out std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief Merge_AXI_Reader                                                      --
-----------------------------------------------------------------------------------
component Merge_AXI_Reader
    generic (
        WAYS            :  integer :=  8;
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        AXI_ID_BASE     :  integer :=  0;
        AXI_ID_WIDTH    :  integer :=  8;
        AXI_AUSER_WIDTH :  integer :=  4;
        AXI_ADDR_WIDTH  :  integer := 32;
        AXI_DATA_WIDTH  :  integer := 64;
        AXI_XFER_SIZE   :  integer := 10;
        AXI_BUF_DEPTH   :  integer := 11;
        AXI_QUEUE_SIZE  :  integer :=  4;
        AXI_RDATA_REGS  :  integer :=  2;
        AXI_ACK_REGS    :  integer range 0 to 1 :=  1;
        ARB_NODE_NUM    :  integer :=  4;
        ARB_PIPELINE    :  integer :=  0;
        MRG_REG_PARAM   :  Interface.Regs_Field_Type := Interface.Default_Regs_Param
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock/Reset Signals.
    -------------------------------------------------------------------------------
        CLK             :  in  std_logic;
        RST             :  in  std_logic;
        CLR             :  in  std_logic;
    -------------------------------------------------------------------------------
    -- AXI Master Read Address Channel Signals.
    -------------------------------------------------------------------------------
        AXI_ARID        :  out std_logic_vector(AXI_ID_WIDTH        -1 downto 0);
        AXI_ARADDR      :  out std_logic_vector(AXI_ADDR_WIDTH      -1 downto 0);
        AXI_ARLEN       :  out std_logic_vector(7 downto 0);
        AXI_ARSIZE      :  out std_logic_vector(2 downto 0);
        AXI_ARBURST     :  out std_logic_vector(1 downto 0);
        AXI_ARLOCK      :  out std_logic_vector(0 downto 0);
        AXI_ARCACHE     :  out std_logic_vector(3 downto 0);
        AXI_ARPROT      :  out std_logic_vector(2 downto 0);
        AXI_ARQOS       :  out std_logic_vector(3 downto 0);
        AXI_ARREGION    :  out std_logic_vector(3 downto 0);
        AXI_ARUSER      :  out std_logic_vector(AXI_AUSER_WIDTH     -1 downto 0);
        AXI_ARVALID     :  out std_logic;
        AXI_ARREADY     :  in  std_logic;
    -------------------------------------------------------------------------------
    -- AXI Master Read Data Channel Signals.
    -------------------------------------------------------------------------------
        AXI_RID         :  in  std_logic_vector(AXI_ID_WIDTH        -1 downto 0);
        AXI_RDATA       :  in  std_logic_vector(AXI_DATA_WIDTH      -1 downto 0);
        AXI_RRESP       :  in  std_logic_vector(1 downto 0);
        AXI_RLAST       :  in  std_logic;
        AXI_RVALID      :  in  std_logic;
        AXI_RREADY      :  out std_logic;
    -------------------------------------------------------------------------------
    -- Merge Reader Control Register Interface.
    -------------------------------------------------------------------------------
        MRG_REG_L       :  in  std_logic_vector(WAYS*MRG_REG_PARAM.BITS -1 downto 0);
        MRG_REG_D       :  in  std_logic_vector(WAYS*MRG_REG_PARAM.BITS -1 downto 0);
        MRG_REG_Q       :  out std_logic_vector(WAYS*MRG_REG_PARAM.BITS -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Outlet Signals.
    -------------------------------------------------------------------------------
        MRG_DATA        :  out std_logic_vector(WAYS*WORDS*WORD_BITS-1 downto 0);
        MRG_NONE        :  out std_logic_vector(WAYS*WORDS          -1 downto 0);
        MRG_EBLK        :  out std_logic_vector(WAYS                -1 downto 0);
        MRG_LAST        :  out std_logic_vector(WAYS                -1 downto 0);
        MRG_VALID       :  out std_logic_vector(WAYS                -1 downto 0);
        MRG_READY       :  in  std_logic_vector(WAYS                -1 downto 0);
        MRG_LEVEL       :  in  std_logic_vector(WAYS                -1 downto 0);
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic_vector(WAYS                -1 downto 0);
        DONE            :  out std_logic_vector(WAYS                -1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief Merge_AXI_Writer                                                      --
-----------------------------------------------------------------------------------
component Merge_AXI_Writer
    generic (
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        AXI_ID_BASE     :  integer :=  0;
        AXI_ID_WIDTH    :  integer :=  8;
        AXI_AUSER_WIDTH :  integer :=  4;
        AXI_WUSER_WIDTH :  integer :=  4;
        AXI_BUSER_WIDTH :  integer :=  4;
        AXI_ADDR_WIDTH  :  integer := 32;
        AXI_DATA_WIDTH  :  integer := 64;
        AXI_XFER_SIZE   :  integer := 11;
        AXI_BUF_DEPTH   :  integer := 12;
        AXI_QUEUE_SIZE  :  integer :=  4;
        AXI_REQ_REGS    :  integer range 0 to 1 :=  1;
        AXI_ACK_REGS    :  integer range 0 to 1 :=  1;
        AXI_RESP_REGS   :  integer range 0 to 1 :=  1;
        MRG_REG_PARAM   :  Interface.Regs_Field_Type := Interface.Default_Regs_Param
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock/Reset Signals.
    -------------------------------------------------------------------------------
        CLK             :  in  std_logic;
        RST             :  in  std_logic;
        CLR             :  in  std_logic;
    -------------------------------------------------------------------------------
    -- AXI Master Writer Address Channel Signals.
    -------------------------------------------------------------------------------
        AXI_AWID        :  out std_logic_vector(AXI_ID_WIDTH     -1 downto 0);
        AXI_AWADDR      :  out std_logic_vector(AXI_ADDR_WIDTH   -1 downto 0);
        AXI_AWLEN       :  out std_logic_vector(7 downto 0);
        AXI_AWSIZE      :  out std_logic_vector(2 downto 0);
        AXI_AWBURST     :  out std_logic_vector(1 downto 0);
        AXI_AWLOCK      :  out std_logic_vector(0 downto 0);
        AXI_AWCACHE     :  out std_logic_vector(3 downto 0);
        AXI_AWPROT      :  out std_logic_vector(2 downto 0);
        AXI_AWQOS       :  out std_logic_vector(3 downto 0);
        AXI_AWREGION    :  out std_logic_vector(3 downto 0);
        AXI_AWUSER      :  out std_logic_vector(AXI_AUSER_WIDTH  -1 downto 0);
        AXI_AWVALID     :  out std_logic;
        AXI_AWREADY     :  in  std_logic;
    ------------------------------------------------------------------------------
    -- AXI Master Write Data Channel Signals.
    ------------------------------------------------------------------------------
        AXI_WID         :  out std_logic_vector(AXI_ID_WIDTH     -1 downto 0);
        AXI_WDATA       :  out std_logic_vector(AXI_DATA_WIDTH   -1 downto 0);
        AXI_WSTRB       :  out std_logic_vector(AXI_DATA_WIDTH/8 -1 downto 0);
        AXI_WUSER       :  out std_logic_vector(AXI_WUSER_WIDTH  -1 downto 0);
        AXI_WLAST       :  out std_logic;
        AXI_WVALID      :  out std_logic;
        AXI_WREADY      :  in  std_logic;
    ------------------------------------------------------------------------------
    -- AXI Write Response Channel Signals.
    ------------------------------------------------------------------------------
        AXI_BID         :  in  std_logic_vector(AXI_ID_WIDTH     -1 downto 0);
        AXI_BRESP       :  in  std_logic_vector(1 downto 0);
        AXI_BUSER       :  in  std_logic_vector(AXI_BUSER_WIDTH  -1 downto 0);
        AXI_BVALID      :  in  std_logic;
        AXI_BREADY      :  out std_logic;
    -------------------------------------------------------------------------------
    -- Merge Writer Control Register Interface.
    -------------------------------------------------------------------------------
        MRG_REG_L       :  in  std_logic_vector(MRG_REG_PARAM.BITS   -1 downto 0);
        MRG_REG_D       :  in  std_logic_vector(MRG_REG_PARAM.BITS   -1 downto 0);
        MRG_REG_Q       :  out std_logic_vector(MRG_REG_PARAM.BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Intake Signals.
    -------------------------------------------------------------------------------
        MRG_DATA        :  in  std_logic_vector(WORDS*WORD_BITS  -1 downto 0);
        MRG_STRB        :  in  std_logic_vector(WORDS            -1 downto 0);
        MRG_LAST        :  in  std_logic;
        MRG_VALID       :  in  std_logic;
        MRG_READY       :  out std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief Interface_Controller                                                  --
-----------------------------------------------------------------------------------
component Interface_Controller
    generic (
        WAYS                :  integer :=    8;
        WORDS               :  integer :=    8;
        WORD_BITS           :  integer :=   64;
        STM_FEEDBACK        :  integer :=    1;
        STM_RD_DATA_BITS    :  integer :=   32;
        STM_WR_DATA_BITS    :  integer :=   32;
        REG_RW_ADDR_BITS    :  integer :=   64;
        REG_RW_MODE_BITS    :  integer :=   32;
        REG_SIZE_BITS       :  integer :=   32;
        REG_MODE_BITS       :  integer :=   16;
        REG_STAT_BITS       :  integer :=    6;
        REG_COUNT_BITS      :  integer :=   32;
        MRG_RD_REG_PARAM    :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
        MRG_WR_REG_PARAM    :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
        STM_RD_REG_PARAM    :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
        STM_WR_REG_PARAM    :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
        STM_RD_ADDR_VALID   :  boolean := TRUE;
        STM_RD_MODE_VALID   :  boolean := TRUE;
        STM_WR_ADDR_VALID   :  boolean := TRUE;
        STM_WR_MODE_VALID   :  boolean := TRUE;
        MRG_RD_PRE_STATE    :  integer :=    0;
        DEBUG_ENABLE        :  integer :=    0;
        DEBUG_SIZE          :  integer :=    1;
        DEBUG_BITS          :  integer range 64 to 64 := 64;
        DEBUG_COUNT_BITS    :  integer :=   32
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock/Reset Signals.
    -------------------------------------------------------------------------------
        CLK                 :  in  std_logic;
        RST                 :  in  std_logic;
        CLR                 :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Register Interface
    -------------------------------------------------------------------------------
        REG_RD_ADDR_L       :  in  std_logic_vector(REG_RW_ADDR_BITS-1 downto 0) := (others => '0');
        REG_RD_ADDR_D       :  in  std_logic_vector(REG_RW_ADDR_BITS-1 downto 0) := (others => '0');
        REG_RD_ADDR_Q       :  out std_logic_vector(REG_RW_ADDR_BITS-1 downto 0);
        REG_WR_ADDR_L       :  in  std_logic_vector(REG_RW_ADDR_BITS-1 downto 0) := (others => '0');
        REG_WR_ADDR_D       :  in  std_logic_vector(REG_RW_ADDR_BITS-1 downto 0) := (others => '0');
        REG_WR_ADDR_Q       :  out std_logic_vector(REG_RW_ADDR_BITS-1 downto 0);
        REG_T0_ADDR_L       :  in  std_logic_vector(REG_RW_ADDR_BITS-1 downto 0);
        REG_T0_ADDR_D       :  in  std_logic_vector(REG_RW_ADDR_BITS-1 downto 0);
        REG_T0_ADDR_Q       :  out std_logic_vector(REG_RW_ADDR_BITS-1 downto 0);
        REG_T1_ADDR_L       :  in  std_logic_vector(REG_RW_ADDR_BITS-1 downto 0);
        REG_T1_ADDR_D       :  in  std_logic_vector(REG_RW_ADDR_BITS-1 downto 0);
        REG_T1_ADDR_Q       :  out std_logic_vector(REG_RW_ADDR_BITS-1 downto 0);
        REG_RD_MODE_L       :  in  std_logic_vector(REG_RW_MODE_BITS-1 downto 0) := (others => '0');
        REG_RD_MODE_D       :  in  std_logic_vector(REG_RW_MODE_BITS-1 downto 0) := (others => '0');
        REG_RD_MODE_Q       :  out std_logic_vector(REG_RW_MODE_BITS-1 downto 0);
        REG_WR_MODE_L       :  in  std_logic_vector(REG_RW_MODE_BITS-1 downto 0) := (others => '0');
        REG_WR_MODE_D       :  in  std_logic_vector(REG_RW_MODE_BITS-1 downto 0) := (others => '0');
        REG_WR_MODE_Q       :  out std_logic_vector(REG_RW_MODE_BITS-1 downto 0);
        REG_T0_MODE_L       :  in  std_logic_vector(REG_RW_MODE_BITS-1 downto 0);
        REG_T0_MODE_D       :  in  std_logic_vector(REG_RW_MODE_BITS-1 downto 0);
        REG_T0_MODE_Q       :  out std_logic_vector(REG_RW_MODE_BITS-1 downto 0);
        REG_T1_MODE_L       :  in  std_logic_vector(REG_RW_MODE_BITS-1 downto 0);
        REG_T1_MODE_D       :  in  std_logic_vector(REG_RW_MODE_BITS-1 downto 0);
        REG_T1_MODE_Q       :  out std_logic_vector(REG_RW_MODE_BITS-1 downto 0);
        REG_SIZE_L          :  in  std_logic_vector(REG_SIZE_BITS   -1 downto 0);
        REG_SIZE_D          :  in  std_logic_vector(REG_SIZE_BITS   -1 downto 0);
        REG_SIZE_Q          :  out std_logic_vector(REG_SIZE_BITS   -1 downto 0);
        REG_START_L         :  in  std_logic := '0';
        REG_START_D         :  in  std_logic := '0';
        REG_START_Q         :  out std_logic;
        REG_RESET_L         :  in  std_logic := '0';
        REG_RESET_D         :  in  std_logic := '0';
        REG_RESET_Q         :  out std_logic;
        REG_DONE_EN_L       :  in  std_logic := '0';
        REG_DONE_EN_D       :  in  std_logic := '0';
        REG_DONE_EN_Q       :  out std_logic;
        REG_DONE_ST_L       :  in  std_logic := '0';
        REG_DONE_ST_D       :  in  std_logic := '0';
        REG_DONE_ST_Q       :  out std_logic;
        REG_ERR_ST_L        :  in  std_logic := '0';
        REG_ERR_ST_D        :  in  std_logic := '0';
        REG_ERR_ST_Q        :  out std_logic;
        REG_MODE_L          :  in  std_logic_vector(REG_MODE_BITS   -1 downto 0) := (others => '0');
        REG_MODE_D          :  in  std_logic_vector(REG_MODE_BITS   -1 downto 0) := (others => '0');
        REG_MODE_Q          :  out std_logic_vector(REG_MODE_BITS   -1 downto 0);
        REG_STAT_L          :  in  std_logic_vector(REG_STAT_BITS   -1 downto 0) := (others => '0');
        REG_STAT_D          :  in  std_logic_vector(REG_STAT_BITS   -1 downto 0) := (others => '0');
        REG_STAT_Q          :  out std_logic_vector(REG_STAT_BITS   -1 downto 0);
        REG_STAT_I          :  in  std_logic_vector(REG_STAT_BITS   -1 downto 0) := (others => '0');
        REG_COUNT_L         :  in  std_logic_vector(REG_COUNT_BITS  -1 downto 0) := (others => '0');
        REG_COUNT_D         :  in  std_logic_vector(REG_COUNT_BITS  -1 downto 0) := (others => '0');
        REG_COUNT_Q         :  out std_logic_vector(REG_COUNT_BITS  -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Sorter Core Control Interface
    -------------------------------------------------------------------------------
        STM_REQ_VALID       :  out std_logic;
        STM_REQ_READY       :  in  std_logic;
        STM_RES_VALID       :  in  std_logic;
        STM_RES_READY       :  out std_logic;
        MRG_REQ_VALID       :  out std_logic;
        MRG_REQ_READY       :  in  std_logic;
        MRG_RES_VALID       :  in  std_logic;
        MRG_RES_READY       :  out std_logic;
    -------------------------------------------------------------------------------
    -- Stream Reader Control Register Interface
    -------------------------------------------------------------------------------
        STM_RD_REG_L        :  out std_logic_vector(           STM_RD_REG_PARAM.BITS-1 downto 0);
        STM_RD_REG_D        :  out std_logic_vector(           STM_RD_REG_PARAM.BITS-1 downto 0);
        STM_RD_REG_Q        :  in  std_logic_vector(           STM_RD_REG_PARAM.BITS-1 downto 0);
        STM_RD_BUSY         :  in  std_logic;
        STM_RD_DONE         :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Stream Writer Control Register Interface
    -------------------------------------------------------------------------------
        STM_WR_REG_L        :  out std_logic_vector(           STM_WR_REG_PARAM.BITS-1 downto 0);
        STM_WR_REG_D        :  out std_logic_vector(           STM_WR_REG_PARAM.BITS-1 downto 0);
        STM_WR_REG_Q        :  in  std_logic_vector(           STM_WR_REG_PARAM.BITS-1 downto 0);
        STM_WR_BUSY         :  in  std_logic;
        STM_WR_DONE         :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Merge Reader Control Register Interface
    -------------------------------------------------------------------------------
        MRG_RD_REG_L        :  out std_logic_vector(WAYS*MRG_RD_REG_PARAM.BITS-1 downto 0);
        MRG_RD_REG_D        :  out std_logic_vector(WAYS*MRG_RD_REG_PARAM.BITS-1 downto 0);
        MRG_RD_REG_Q        :  in  std_logic_vector(WAYS*MRG_RD_REG_PARAM.BITS-1 downto 0);
        MRG_RD_BUSY         :  in  std_logic_vector(WAYS                      -1 downto 0);
        MRG_RD_DONE         :  in  std_logic_vector(WAYS                      -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Writer Control Register Interface
    -------------------------------------------------------------------------------
        MRG_WR_REG_L        :  out std_logic_vector(           MRG_WR_REG_PARAM.BITS-1 downto 0);
        MRG_WR_REG_D        :  out std_logic_vector(           MRG_WR_REG_PARAM.BITS-1 downto 0);
        MRG_WR_REG_Q        :  in  std_logic_vector(           MRG_WR_REG_PARAM.BITS-1 downto 0);
        MRG_WR_BUSY         :  in  std_logic;
        MRG_WR_DONE         :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Debug Interface
    -------------------------------------------------------------------------------
        DEBUG_MODE          :  in  std_logic_vector(3 downto 0) := (others => '0');
        DEBUG_DATA          :  out std_logic_vector(DEBUG_SIZE*DEBUG_BITS-1 downto 0)
    );
end component;
end Interface_Components;
