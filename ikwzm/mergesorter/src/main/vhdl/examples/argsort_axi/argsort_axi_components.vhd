-----------------------------------------------------------------------------------
--!     @file    argsort_axi_components.vhd                                      --
--!     @brief   ArgSorter Component Library Description Package                 --
--!     @version 1.4.1                                                           --
--!     @date    2022/11/02                                                      --
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>                     --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--                                                                               --
--      Copyright (C) 2022 Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>           --
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
--! @brief ArgSorter Component Library Description Package                       --
-----------------------------------------------------------------------------------
package ArgSort_AXI_Components is
-----------------------------------------------------------------------------------
--! @brief ArgSort_AXI_Interface                                                 --
-----------------------------------------------------------------------------------
component ArgSort_AXI_Interface
    generic (
        WAYS                :  integer :=    8;
        WORDS               :  integer :=    1;
        WORD_BITS           :  integer :=   64;
        WORD_INDEX_LO       :  integer :=    0;
        WORD_INDEX_HI       :  integer :=   31;
        WORD_COMP_LO        :  integer :=   32;
        WORD_COMP_HI        :  integer :=   63;
        MRG_AXI_ID_BASE     :  integer :=    0;
        MRG_AXI_ID_WIDTH    :  integer :=    8;
        MRG_AXI_ARUSER_WIDTH:  integer :=    4;
        MRG_AXI_AWUSER_WIDTH:  integer :=    4;
        MRG_AXI_RUSER_WIDTH :  integer :=    4;
        MRG_AXI_WUSER_WIDTH :  integer :=    4;
        MRG_AXI_BUSER_WIDTH :  integer :=    4;
        MRG_AXI_ADDR_WIDTH  :  integer :=   32;
        MRG_AXI_DATA_WIDTH  :  integer :=   64;
        MRG_RD_AXI_XFER_SIZE:  integer :=   11;
        MRG_RD_AXI_BUF_DEPTH:  integer :=   12;
        MRG_RD_AXI_QUEUE    :  integer :=    4;
        MRG_RD_AXI_DATA_REGS:  integer :=    2;
        MRG_RD_AXI_ACK_REGS :  integer range 0 to 1 := 1;
        MRG_RD_ARB_NODE_NUM :  integer :=    4;
        MRG_RD_ARB_PIPELINE :  integer :=    0;
        MRG_RD_PRE_STATE    :  integer :=    0;
        MRG_WR_AXI_XFER_SIZE:  integer :=   11;
        MRG_WR_AXI_BUF_DEPTH:  integer :=   12;
        MRG_WR_AXI_QUEUE    :  integer :=    4;
        MRG_WR_AXI_REQ_REGS :  integer range 0 to 1 := 1;
        MRG_WR_AXI_ACK_REGS :  integer range 0 to 1 := 1;
        MRG_WR_AXI_RESP_REGS:  integer range 0 to 1 := 1;
        STM_AXI_ID_BASE     :  integer :=    0;
        STM_AXI_ID_WIDTH    :  integer :=    8;
        STM_AXI_ARUSER_WIDTH:  integer :=    4;
        STM_AXI_AWUSER_WIDTH:  integer :=    4;
        STM_AXI_RUSER_WIDTH :  integer :=    4;
        STM_AXI_WUSER_WIDTH :  integer :=    4;
        STM_AXI_BUSER_WIDTH :  integer :=    4;
        STM_AXI_ADDR_WIDTH  :  integer :=   32;
        STM_AXI_DATA_WIDTH  :  integer :=   64;
        STM_RD_AXI_XFER_SIZE:  integer :=   11;
        STM_RD_AXI_BUF_DEPTH:  integer :=   12;
        STM_WR_AXI_XFER_SIZE:  integer :=   11;
        STM_RD_AXI_QUEUE    :  integer :=    4;
        STM_RD_AXI_DATA_REGS:  integer :=    2;
        STM_RD_AXI_ACK_REGS :  integer range 0 to 1 := 1;
        STM_WR_AXI_BUF_DEPTH:  integer :=   12;
        STM_WR_AXI_QUEUE    :  integer :=    4;
        STM_WR_AXI_REQ_REGS :  integer range 0 to 1 := 1;
        STM_WR_AXI_ACK_REGS :  integer range 0 to 1 := 1;
        STM_WR_AXI_RESP_REGS:  integer range 0 to 1 := 1;
        STM_FEEDBACK        :  integer :=    1;
        STM_RD_ADDR_VALID   :  boolean := TRUE;
        STM_WR_ADDR_VALID   :  boolean := TRUE;
        REG_RW_ADDR_BITS    :  integer :=   64;
        REG_RW_MODE_BITS    :  integer :=   32;
        REG_SIZE_BITS       :  integer :=   32;
        REG_MODE_BITS       :  integer :=   16;
        REG_STAT_BITS       :  integer :=    6;
        REG_COUNT_BITS      :  integer :=   32;
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
    -- Stream AXI Master Read Address Channel Signals.
    -------------------------------------------------------------------------------
        STM_AXI_ARID        :  out std_logic_vector(STM_AXI_ID_WIDTH    -1 downto 0);
        STM_AXI_ARADDR      :  out std_logic_vector(STM_AXI_ADDR_WIDTH  -1 downto 0);
        STM_AXI_ARLEN       :  out std_logic_vector(7 downto 0);
        STM_AXI_ARSIZE      :  out std_logic_vector(2 downto 0);
        STM_AXI_ARBURST     :  out std_logic_vector(1 downto 0);
        STM_AXI_ARLOCK      :  out std_logic_vector(0 downto 0);
        STM_AXI_ARCACHE     :  out std_logic_vector(3 downto 0);
        STM_AXI_ARPROT      :  out std_logic_vector(2 downto 0);
        STM_AXI_ARQOS       :  out std_logic_vector(3 downto 0);
        STM_AXI_ARREGION    :  out std_logic_vector(3 downto 0);
        STM_AXI_ARUSER      :  out std_logic_vector(STM_AXI_ARUSER_WIDTH-1 downto 0);
        STM_AXI_ARVALID     :  out std_logic;
        STM_AXI_ARREADY     :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Stream AXI Master Read Data Channel Signals.
    -------------------------------------------------------------------------------
        STM_AXI_RID         :  in  std_logic_vector(STM_AXI_ID_WIDTH    -1 downto 0) := (others => '0');
        STM_AXI_RDATA       :  in  std_logic_vector(STM_AXI_DATA_WIDTH  -1 downto 0) := (others => '0');
        STM_AXI_RRESP       :  in  std_logic_vector(1 downto 0);
        STM_AXI_RUSER       :  in  std_logic_vector(STM_AXI_RUSER_WIDTH -1 downto 0) := (others => '0');
        STM_AXI_RLAST       :  in  std_logic;
        STM_AXI_RVALID      :  in  std_logic;
        STM_AXI_RREADY      :  out std_logic;
    -------------------------------------------------------------------------------
    -- Stream AXI Master Writer Address Channel Signals.
    -------------------------------------------------------------------------------
        STM_AXI_AWID        :  out std_logic_vector(STM_AXI_ID_WIDTH    -1 downto 0);
        STM_AXI_AWADDR      :  out std_logic_vector(STM_AXI_ADDR_WIDTH  -1 downto 0);
        STM_AXI_AWLEN       :  out std_logic_vector(7 downto 0);
        STM_AXI_AWSIZE      :  out std_logic_vector(2 downto 0);
        STM_AXI_AWBURST     :  out std_logic_vector(1 downto 0);
        STM_AXI_AWLOCK      :  out std_logic_vector(0 downto 0);
        STM_AXI_AWCACHE     :  out std_logic_vector(3 downto 0);
        STM_AXI_AWPROT      :  out std_logic_vector(2 downto 0);
        STM_AXI_AWQOS       :  out std_logic_vector(3 downto 0);
        STM_AXI_AWREGION    :  out std_logic_vector(3 downto 0);
        STM_AXI_AWUSER      :  out std_logic_vector(STM_AXI_AWUSER_WIDTH-1 downto 0);
        STM_AXI_AWVALID     :  out std_logic;
        STM_AXI_AWREADY     :  in  std_logic;
    ------------------------------------------------------------------------------
    -- Stream AXI Master Write Data Channel Signals.
    ------------------------------------------------------------------------------
        STM_AXI_WID         :  out std_logic_vector(STM_AXI_ID_WIDTH    -1 downto 0);
        STM_AXI_WDATA       :  out std_logic_vector(STM_AXI_DATA_WIDTH  -1 downto 0);
        STM_AXI_WSTRB       :  out std_logic_vector(STM_AXI_DATA_WIDTH/8-1 downto 0);
        STM_AXI_WUSER       :  out std_logic_vector(STM_AXI_WUSER_WIDTH -1 downto 0);
        STM_AXI_WLAST       :  out std_logic;
        STM_AXI_WVALID      :  out std_logic;
        STM_AXI_WREADY      :  in  std_logic;
    ------------------------------------------------------------------------------
    -- Stream AXI Write Response Channel Signals.
    ------------------------------------------------------------------------------
        STM_AXI_BID         :  in  std_logic_vector(STM_AXI_ID_WIDTH    -1 downto 0) := (others => '0');
        STM_AXI_BRESP       :  in  std_logic_vector(1 downto 0)                      := (others => '0');
        STM_AXI_BUSER       :  in  std_logic_vector(STM_AXI_BUSER_WIDTH -1 downto 0) := (others => '0');
        STM_AXI_BVALID      :  in  std_logic;
        STM_AXI_BREADY      :  out std_logic;
    -------------------------------------------------------------------------------
    -- Stream Reader Outlet Signals.
    -------------------------------------------------------------------------------
        STM_RD_DATA         :  out std_logic_vector(WORDS*WORD_BITS     -1 downto 0);
        STM_RD_STRB         :  out std_logic_vector(WORDS               -1 downto 0);
        STM_RD_LAST         :  out std_logic;
        STM_RD_VALID        :  out std_logic;
        STM_RD_READY        :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Merge AXI Master Read Address Channel Signals.
    -------------------------------------------------------------------------------
        MRG_AXI_ARID        :  out std_logic_vector(MRG_AXI_ID_WIDTH    -1 downto 0);
        MRG_AXI_ARADDR      :  out std_logic_vector(MRG_AXI_ADDR_WIDTH  -1 downto 0);
        MRG_AXI_ARLEN       :  out std_logic_vector(7 downto 0);
        MRG_AXI_ARSIZE      :  out std_logic_vector(2 downto 0);
        MRG_AXI_ARBURST     :  out std_logic_vector(1 downto 0);
        MRG_AXI_ARLOCK      :  out std_logic_vector(0 downto 0);
        MRG_AXI_ARCACHE     :  out std_logic_vector(3 downto 0);
        MRG_AXI_ARPROT      :  out std_logic_vector(2 downto 0);
        MRG_AXI_ARQOS       :  out std_logic_vector(3 downto 0);
        MRG_AXI_ARREGION    :  out std_logic_vector(3 downto 0);
        MRG_AXI_ARUSER      :  out std_logic_vector(MRG_AXI_ARUSER_WIDTH-1 downto 0);
        MRG_AXI_ARVALID     :  out std_logic;
        MRG_AXI_ARREADY     :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Merge AXI Master Read Data Channel Signals.
    -------------------------------------------------------------------------------
        MRG_AXI_RID         :  in  std_logic_vector(MRG_AXI_ID_WIDTH    -1 downto 0) := (others => '0');
        MRG_AXI_RDATA       :  in  std_logic_vector(MRG_AXI_DATA_WIDTH  -1 downto 0) := (others => '0');
        MRG_AXI_RRESP       :  in  std_logic_vector(1 downto 0)                      := (others => '0');
        MRG_AXI_RUSER       :  in  std_logic_vector(MRG_AXI_RUSER_WIDTH -1 downto 0) := (others => '0');
        MRG_AXI_RLAST       :  in  std_logic;
        MRG_AXI_RVALID      :  in  std_logic;
        MRG_AXI_RREADY      :  out std_logic;
    -------------------------------------------------------------------------------
    -- Merge AXI Master Writer Address Channel Signals.
    -------------------------------------------------------------------------------
        MRG_AXI_AWID        :  out std_logic_vector(MRG_AXI_ID_WIDTH    -1 downto 0);
        MRG_AXI_AWADDR      :  out std_logic_vector(MRG_AXI_ADDR_WIDTH  -1 downto 0);
        MRG_AXI_AWLEN       :  out std_logic_vector(7 downto 0);
        MRG_AXI_AWSIZE      :  out std_logic_vector(2 downto 0);
        MRG_AXI_AWBURST     :  out std_logic_vector(1 downto 0);
        MRG_AXI_AWLOCK      :  out std_logic_vector(0 downto 0);
        MRG_AXI_AWCACHE     :  out std_logic_vector(3 downto 0);
        MRG_AXI_AWPROT      :  out std_logic_vector(2 downto 0);
        MRG_AXI_AWQOS       :  out std_logic_vector(3 downto 0);
        MRG_AXI_AWREGION    :  out std_logic_vector(3 downto 0);
        MRG_AXI_AWUSER      :  out std_logic_vector(MRG_AXI_AWUSER_WIDTH-1 downto 0);
        MRG_AXI_AWVALID     :  out std_logic;
        MRG_AXI_AWREADY     :  in  std_logic;
    ------------------------------------------------------------------------------
    -- Merge AXI Master Write Data Channel Signals.
    ------------------------------------------------------------------------------
        MRG_AXI_WID         :  out std_logic_vector(MRG_AXI_ID_WIDTH    -1 downto 0);
        MRG_AXI_WDATA       :  out std_logic_vector(MRG_AXI_DATA_WIDTH  -1 downto 0);
        MRG_AXI_WSTRB       :  out std_logic_vector(MRG_AXI_DATA_WIDTH/8-1 downto 0);
        MRG_AXI_WUSER       :  out std_logic_vector(MRG_AXI_WUSER_WIDTH -1 downto 0);
        MRG_AXI_WLAST       :  out std_logic;
        MRG_AXI_WVALID      :  out std_logic;
        MRG_AXI_WREADY      :  in  std_logic;
    ------------------------------------------------------------------------------
    -- Merge AXI Write Response Channel Signals.
    ------------------------------------------------------------------------------
        MRG_AXI_BID         :  in  std_logic_vector(MRG_AXI_ID_WIDTH    -1 downto 0);
        MRG_AXI_BRESP       :  in  std_logic_vector(1 downto 0);
        MRG_AXI_BUSER       :  in  std_logic_vector(MRG_AXI_BUSER_WIDTH -1 downto 0);
        MRG_AXI_BVALID      :  in  std_logic;
        MRG_AXI_BREADY      :  out std_logic;
    -------------------------------------------------------------------------------
    -- Merge Reader Outlet Signals.
    -------------------------------------------------------------------------------
        MRG_RD_DATA         :  out std_logic_vector(WAYS*WORDS*WORD_BITS-1 downto 0);
        MRG_RD_NONE         :  out std_logic_vector(WAYS*WORDS          -1 downto 0);
        MRG_RD_EBLK         :  out std_logic_vector(WAYS                -1 downto 0);
        MRG_RD_LAST         :  out std_logic_vector(WAYS                -1 downto 0);
        MRG_RD_VALID        :  out std_logic_vector(WAYS                -1 downto 0);
        MRG_RD_READY        :  in  std_logic_vector(WAYS                -1 downto 0);
        MRG_RD_LEVEL        :  in  std_logic_vector(WAYS                -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Result Intake Signals.
    -------------------------------------------------------------------------------
        MERGED_DATA         :  in  std_logic_vector(WORDS*WORD_BITS     -1 downto 0);
        MERGED_STRB         :  in  std_logic_vector(WORDS               -1 downto 0);
        MERGED_LAST         :  in  std_logic;
        MERGED_VALID        :  in  std_logic;
        MERGED_READY        :  out std_logic;
    -------------------------------------------------------------------------------
    -- Merge Sorter Core Control Interface Signals.
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
    -- Debug Interface
    -------------------------------------------------------------------------------
        DEBUG_MODE          :  in  std_logic_vector(3 downto 0) := (others => '0');
        DEBUG_DATA          :  out std_logic_vector(DEBUG_SIZE*DEBUG_BITS-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief ArgSort_Reader                                                        --
-----------------------------------------------------------------------------------
component ArgSort_Reader
    generic (
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        REG_PARAM       :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
        REQ_ADDR_BITS   :  integer := 32;
        REQ_SIZE_BITS   :  integer := 32;
        BUF_DATA_BITS   :  integer := 64;
        BUF_DEPTH       :  integer := 13;
        MAX_XFER_SIZE   :  integer := 12;
        WORD_INDEX_LO   :  integer :=  0;
        WORD_INDEX_HI   :  integer := 31;
        WORD_COMP_LO    :  integer := 32;
        WORD_COMP_HI    :  integer := 63
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
        ACK_SIZE        :  in  std_logic_vector(BUF_DEPTH             downto 0);
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
        FLOW_SIZE       :  out std_logic_vector(BUF_DEPTH             downto 0);
        PUSH_FIN_VALID  :  in  std_logic;
        PUSH_FIN_LAST   :  in  std_logic;
        PUSH_FIN_ERROR  :  in  std_logic := '0';
        PUSH_FIN_SIZE   :  in  std_logic_vector(BUF_DEPTH             downto 0);
        PUSH_BUF_RESET  :  in  std_logic;
        PUSH_BUF_VALID  :  in  std_logic;
        PUSH_BUF_LAST   :  in  std_logic;
        PUSH_BUF_ERROR  :  in  std_logic := '0';
        PUSH_BUF_SIZE   :  in  std_logic_vector(BUF_DEPTH             downto 0);
        PUSH_BUF_READY  :  out std_logic;
    -------------------------------------------------------------------------------
    -- Buffer Interface Signals.
    -------------------------------------------------------------------------------
        BUF_WEN         :  in  std_logic;
        BUF_BEN         :  in  std_logic_vector(BUF_DATA_BITS/8    -1 downto 0);
        BUF_DATA        :  in  std_logic_vector(BUF_DATA_BITS      -1 downto 0);
        BUF_PTR         :  in  std_logic_vector(BUF_DEPTH          -1 downto 0);
    -------------------------------------------------------------------------------
    -- Stream Outlet Signals.
    -------------------------------------------------------------------------------
        STM_DATA        :  out std_logic_vector(WORDS*WORD_BITS    -1 downto 0);
        STM_STRB        :  out std_logic_vector(WORDS              -1 downto 0);
        STM_LAST        :  out std_logic;
        STM_VALID       :  out std_logic;
        STM_READY       :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief ArgSort_Writer                                                        --
-----------------------------------------------------------------------------------
component ArgSort_Writer
    generic (
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        REG_PARAM       :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
        REQ_ADDR_BITS   :  integer := 32;
        REQ_SIZE_BITS   :  integer := 32;
        BUF_DATA_BITS   :  integer := 64;
        BUF_DEPTH       :  integer := 13;
        MAX_XFER_SIZE   :  integer := 12;
        WORD_INDEX_LO   :  integer :=  0;
        WORD_INDEX_HI   :  integer := 31;
        WORD_COMP_LO    :  integer := 32;
        WORD_COMP_HI    :  integer := 63
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
        ACK_SIZE        :  in  std_logic_vector(BUF_DEPTH             downto 0);
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
        FLOW_SIZE       :  out std_logic_vector(BUF_DEPTH             downto 0);
        PULL_FIN_VALID  :  in  std_logic;
        PULL_FIN_LAST   :  in  std_logic;
        PULL_FIN_ERROR  :  in  std_logic := '0';
        PULL_FIN_SIZE   :  in  std_logic_vector(BUF_DEPTH             downto 0);
        PULL_BUF_RESET  :  in  std_logic;
        PULL_BUF_VALID  :  in  std_logic;
        PULL_BUF_LAST   :  in  std_logic;
        PULL_BUF_ERROR  :  in  std_logic := '0';
        PULL_BUF_SIZE   :  in  std_logic_vector(BUF_DEPTH             downto 0);
        PULL_BUF_READY  :  out std_logic;
    -------------------------------------------------------------------------------
    -- Buffer Interface Signals.
    -------------------------------------------------------------------------------
        BUF_DATA        :  out std_logic_vector(BUF_DATA_BITS      -1 downto 0);
        BUF_PTR         :  in  std_logic_vector(BUF_DEPTH          -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Outlet Signals.
    -------------------------------------------------------------------------------
        STM_DATA        :  in  std_logic_vector(WORDS*WORD_BITS    -1 downto 0);
        STM_STRB        :  in  std_logic_vector(WORDS              -1 downto 0);
        STM_LAST        :  in  std_logic;
        STM_VALID       :  in  std_logic;
        STM_READY       :  out std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief ArgSort_AXI_Reader                                                    --
-----------------------------------------------------------------------------------
component ArgSort_AXI_Reader
    generic (
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        WORD_INDEX_LO   :  integer :=  0;
        WORD_INDEX_HI   :  integer := 31;
        WORD_COMP_LO    :  integer := 32;
        WORD_COMP_HI    :  integer := 63;
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
        STM_REG_PARAM   :  Interface.Regs_Field_Type := Interface.Default_Regs_Param
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
        AXI_ARID        :  out std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_ARADDR      :  out std_logic_vector(AXI_ADDR_WIDTH  -1 downto 0);
        AXI_ARLEN       :  out std_logic_vector(7 downto 0);
        AXI_ARSIZE      :  out std_logic_vector(2 downto 0);
        AXI_ARBURST     :  out std_logic_vector(1 downto 0);
        AXI_ARLOCK      :  out std_logic_vector(0 downto 0);
        AXI_ARCACHE     :  out std_logic_vector(3 downto 0);
        AXI_ARPROT      :  out std_logic_vector(2 downto 0);
        AXI_ARQOS       :  out std_logic_vector(3 downto 0);
        AXI_ARREGION    :  out std_logic_vector(3 downto 0);
        AXI_ARUSER      :  out std_logic_vector(AXI_AUSER_WIDTH -1 downto 0);
        AXI_ARVALID     :  out std_logic;
        AXI_ARREADY     :  in  std_logic;
    -------------------------------------------------------------------------------
    -- AXI Master Read Data Channel Signals.
    -------------------------------------------------------------------------------
        AXI_RID         :  in  std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_RDATA       :  in  std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        AXI_RRESP       :  in  std_logic_vector(1 downto 0);
        AXI_RLAST       :  in  std_logic;
        AXI_RVALID      :  in  std_logic;
        AXI_RREADY      :  out std_logic;
    -------------------------------------------------------------------------------
    -- Stream Reader Control Register Interface.
    -------------------------------------------------------------------------------
        STM_REG_L       :  in  std_logic_vector(STM_REG_PARAM.BITS  -1 downto 0);
        STM_REG_D       :  in  std_logic_vector(STM_REG_PARAM.BITS  -1 downto 0);
        STM_REG_Q       :  out std_logic_vector(STM_REG_PARAM.BITS  -1 downto 0);
    -------------------------------------------------------------------------------
    -- Stream Outlet Signals.
    -------------------------------------------------------------------------------
        STM_DATA        :  out std_logic_vector(WORDS*WORD_BITS  -1 downto 0);
        STM_STRB        :  out std_logic_vector(WORDS            -1 downto 0);
        STM_LAST        :  out std_logic;
        STM_VALID       :  out std_logic;
        STM_READY       :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief ArgSort_AXI_Writer                                                    --
-----------------------------------------------------------------------------------
component ArgSort_AXI_Writer
    generic (
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        WORD_INDEX_LO   :  integer :=  0;
        WORD_INDEX_HI   :  integer := 31;
        WORD_COMP_LO    :  integer := 32;
        WORD_COMP_HI    :  integer := 63;
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
        STM_REG_PARAM   :  Interface.Regs_Field_Type := Interface.Default_Regs_Param
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
        AXI_AWID        :  out std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_AWADDR      :  out std_logic_vector(AXI_ADDR_WIDTH  -1 downto 0);
        AXI_AWLEN       :  out std_logic_vector(7 downto 0);
        AXI_AWSIZE      :  out std_logic_vector(2 downto 0);
        AXI_AWBURST     :  out std_logic_vector(1 downto 0);
        AXI_AWLOCK      :  out std_logic_vector(0 downto 0);
        AXI_AWCACHE     :  out std_logic_vector(3 downto 0);
        AXI_AWPROT      :  out std_logic_vector(2 downto 0);
        AXI_AWQOS       :  out std_logic_vector(3 downto 0);
        AXI_AWREGION    :  out std_logic_vector(3 downto 0);
        AXI_AWUSER      :  out std_logic_vector(AXI_AUSER_WIDTH -1 downto 0);
        AXI_AWVALID     :  out std_logic;
        AXI_AWREADY     :  in  std_logic;
    ------------------------------------------------------------------------------
    -- AXI Master Write Data Channel Signals.
    ------------------------------------------------------------------------------
        AXI_WID         :  out std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_WDATA       :  out std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        AXI_WSTRB       :  out std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
        AXI_WUSER       :  out std_logic_vector(AXI_WUSER_WIDTH -1 downto 0);
        AXI_WLAST       :  out std_logic;
        AXI_WVALID      :  out std_logic;
        AXI_WREADY      :  in  std_logic;
    ------------------------------------------------------------------------------
    -- AXI Write Response Channel Signals.
    ------------------------------------------------------------------------------
        AXI_BID         :  in  std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_BRESP       :  in  std_logic_vector(1 downto 0);
        AXI_BUSER       :  in  std_logic_vector(AXI_BUSER_WIDTH -1 downto 0);
        AXI_BVALID      :  in  std_logic;
        AXI_BREADY      :  out std_logic;
    -------------------------------------------------------------------------------
    -- Stream Writer Control Register Interface.
    -------------------------------------------------------------------------------
        STM_REG_L       :  in  std_logic_vector(STM_REG_PARAM.BITS  -1 downto 0);
        STM_REG_D       :  in  std_logic_vector(STM_REG_PARAM.BITS  -1 downto 0);
        STM_REG_Q       :  out std_logic_vector(STM_REG_PARAM.BITS  -1 downto 0);
    -------------------------------------------------------------------------------
    -- Stream Intake Signals.
    -------------------------------------------------------------------------------
        STM_DATA        :  in  std_logic_vector(WORDS*WORD_BITS  -1 downto 0);
        STM_STRB        :  in  std_logic_vector(WORDS            -1 downto 0);
        STM_LAST        :  in  std_logic;
        STM_VALID       :  in  std_logic;
        STM_READY       :  out std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief ArgSort_AXI                                                           --
-----------------------------------------------------------------------------------
component ArgSort_AXI
    generic (
        MRG_WAYS            : --! @brief MERGE WAY SIZE :
                              integer :=  4;
        MRG_WORDS           : --! @brief MERGE WORD SIZE :
                              integer :=  1;
        WORD_BITS           : --! @brief SORT WORD BIT SIZE :
                              integer := 32;
        INDEX_BITS          : --! @brief INDEX BIT SIZE :
                              integer := 32;
        COMP_SIGN           : --! @brief COMPARE SIGN :
                              boolean := FALSE;
        SORT_ORDER          : --! @brief SORT ORDER :
                              integer :=  0;
        SORT_SIZE_BITS      : --! @brief SORT SIZE BITS :
                              integer range 1 to 32 := 28;
        MRG_FIFO_SIZE       : --! @brief MERGE FIFO SIZE :
                              integer := 16;
        STM_FEEDBACK        : --! @brief STREAM FEED BACK NUMBER :
                              integer :=  0;
        STM_IN_QUEUE_SIZE   : --! @brief STREAM IN QUEUE SIZE :
                              integer :=  0;
        CSR_AXI_ADDR_WIDTH  : --! @brief CSR I/F AXI ADDRRESS WIDTH :
                              integer := 12;
        CSR_AXI_DATA_WIDTH  : --! @brief CSR I/F AXI DATA WIDTH :
                              integer := 32;
        STM_AXI_ADDR_WIDTH  : --! @brief STREAM IN/OUT AXI ADDRESS WIDTH :
                              integer := 32;
        STM_AXI_DATA_WIDTH  : --! @brief STREAM IN/OUT AXI DATA WIDTH :
                              integer := 64;
        STM_AXI_ID_WIDTH    : --! @brief STREAM IN/OUT AXI ID WIDTH :
                              integer := 1;
        STM_AXI_USER_WIDTH  : --! @brief STREAM IN/OUT AXI ADDRESS USER WIDTH :
                              integer := 1;
        STM_AXI_ID_BASE     : --! @brief STREAM IN/OUT AXI ID BASE :
                              integer := 0;
        STM_RD_AXI_XFER_SIZE: --! @brief STREAM IN  AXI MAX XFER SIZE :
                              integer := 11;
        STM_RD_AXI_BUF_SIZE : --! @brief STREAM IN  AXI BUFFER SIZE :
                              integer := 0;
        STM_RD_AXI_QUEUE    : --! @brief STREAM IN  AXI QUEUE SIZE :
                              integer := 4;
        STM_RD_AXI_DATA_REGS: --! @brief STREAM IN  AXI DATA REGISTER :
                              integer := 2;
        STM_RD_AXI_ACK_REGS : --! @brief STREAM IN  AXI ACKNOWLEDGE REGISTER :
                              integer range 0 to 1 := 1;
        STM_WR_AXI_XFER_SIZE: --! @brief STREAM OUT AXI MAX XFER SIZE :
                              integer := 11;
        STM_WR_AXI_BUF_SIZE : --! @brief STREAM OUT AXI BUFFER SIZE :
                              integer := 0;
        STM_WR_AXI_QUEUE    : --! @brief STREAM OUT AXI QUEUE SIZE :
                              integer := 4;
        STM_WR_AXI_REQ_REGS : --! @brief STREAM OUT AXI REQUEST REGISTER :
                              integer range 0 to 1 := 1;
        STM_WR_AXI_ACK_REGS : --! @brief STREAM OUT AXI ACKNOWLEDGE REGISTER :
                              integer range 0 to 1 := 1;
        STM_WR_AXI_RESP_REGS: --! @brief STREAM OUT AXI RESPONSE REGISTER :
                              integer range 0 to 1 := 1;
        MRG_AXI_ADDR_WIDTH  : --! @brief MERGE IN/OUT AXI ADDRESS WIDTH :
                              integer := 32;
        MRG_AXI_DATA_WIDTH  : --! @brief MERGE IN/OUT AXI DATA WIDTH :
                              integer := 64;
        MRG_AXI_ID_WIDTH    : --! @brief MERGE IN/OUT AXI ID WIDTH :
                              integer := 1;
        MRG_AXI_USER_WIDTH  : --! @brief MERGE IN/OUT AXI ADDRESS USER WIDTH :
                              integer := 1;
        MRG_AXI_ID_BASE     : --! @brief MERGE IN/OUT AXI ID BASE :
                              integer := 0;
        MRG_RD_AXI_XFER_SIZE: --! @brief MERGE IN  AXI MAX XFER SIZE :
                              integer := 11;
        MRG_RD_AXI_BUF_SIZE : --! @brief MERGE IN  AXI BUFFER SIZE :
                              integer := 0;
        MRG_RD_AXI_QUEUE    : --! @brief MERGE IN  AXI QUEUE SIZE :
                              integer := 4;
        MRG_RD_AXI_DATA_REGS: --! @brief MERGE IN  AXI DATA REGISTER :
                              integer := 2;
        MRG_RD_AXI_ACK_REGS : --! @brief MERGE IN  AXI ACKNOWLEDGE REGISTER :
                              integer range 0 to 1 := 1;
        MRG_RD_ARB_NODE_NUM : --! @brief MERGE IN  ARBITER NODE SIZE :
                              integer := 4;
        MRG_RD_ARB_PIPELINE : --! @brief MERGE IN  ARBITER PIPELINE :
                              integer := 0;
        MRG_RD_PRE_STATE    : --! @brief MERGE IN  PRE STATE :
                              integer := 0;
        MRG_WR_AXI_XFER_SIZE: --! @brief MERGE OUT AXI MAX XFER SIZE :
                              integer := 11;
        MRG_WR_AXI_BUF_SIZE : --! @brief MERGE OUT AXI BUFFER SIZE :
                              integer := 0;
        MRG_WR_AXI_QUEUE    : --! @brief MERGE OUT AXI QUEUE SIZE :
                              integer := 4;
        MRG_WR_AXI_REQ_REGS : --! @brief MERGE OUT AXI REQUEST REGISTER :
                              integer range 0 to 1 := 1;
        MRG_WR_AXI_ACK_REGS : --! @brief MERGE OUT AXI ACKNOWLEDGE REGISTER :
                              integer range 0 to 1 := 1;
        MRG_WR_AXI_RESP_REGS: --! @brief MERGE OUT AXI RESPONSE REGISTER :
                              integer range 0 to 1 := 1;
        DEBUG_ENABLE        : --! @brief DEBUG ENABLE :
                              integer range 0 to 1 := 0
    );
    port(
    -------------------------------------------------------------------------------
    -- Clock / Reset Signals.
    -------------------------------------------------------------------------------
        ACLK                : in  std_logic;
        ARESETn             : in  std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        CSR_AXI_ARADDR      : in  std_logic_vector(CSR_AXI_ADDR_WIDTH   -1 downto 0);
        CSR_AXI_ARVALID     : in  std_logic;
        CSR_AXI_ARREADY     : out std_logic;
    ------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Read Data Channel Signals.
    ------------------------------------------------------------------------------
        CSR_AXI_RDATA       : out std_logic_vector(CSR_AXI_DATA_WIDTH   -1 downto 0);
        CSR_AXI_RRESP       : out std_logic_vector(1 downto 0);  
        CSR_AXI_RVALID      : out std_logic;
        CSR_AXI_RREADY      : in  std_logic;
    ------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Address Channel Signals.
    ------------------------------------------------------------------------------
        CSR_AXI_AWADDR      : in  std_logic_vector(CSR_AXI_ADDR_WIDTH   -1 downto 0);
        CSR_AXI_AWVALID     : in  std_logic;
        CSR_AXI_AWREADY     : out std_logic;
    ------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Data Channel Signals.
    ------------------------------------------------------------------------------
        CSR_AXI_WDATA       : in  std_logic_vector(CSR_AXI_DATA_WIDTH   -1 downto 0);
        CSR_AXI_WSTRB       : in  std_logic_vector(CSR_AXI_DATA_WIDTH/8 -1 downto 0);
        CSR_AXI_WVALID      : in  std_logic;
        CSR_AXI_WREADY      : out std_logic;
    ------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Response Channel Signals.
    ------------------------------------------------------------------------------
        CSR_AXI_BRESP       : out std_logic_vector(1 downto 0);
        CSR_AXI_BVALID      : out std_logic;
        CSR_AXI_BREADY      : in  std_logic;
    -------------------------------------------------------------------------------
    -- STREAM IN/OUT AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        STM_AXI_ARID        : out std_logic_vector(STM_AXI_ID_WIDTH    -1 downto 0);
        STM_AXI_ARADDR      : out std_logic_vector(STM_AXI_ADDR_WIDTH  -1 downto 0);
        STM_AXI_ARLEN       : out std_logic_vector(7 downto 0);
        STM_AXI_ARSIZE      : out std_logic_vector(2 downto 0);
        STM_AXI_ARBURST     : out std_logic_vector(1 downto 0);
        STM_AXI_ARLOCK      : out std_logic_vector(0 downto 0);
        STM_AXI_ARCACHE     : out std_logic_vector(3 downto 0);
        STM_AXI_ARPROT      : out std_logic_vector(2 downto 0);
        STM_AXI_ARQOS       : out std_logic_vector(3 downto 0);
        STM_AXI_ARREGION    : out std_logic_vector(3 downto 0);
        STM_AXI_ARUSER      : out std_logic_vector(STM_AXI_USER_WIDTH  -1 downto 0);
        STM_AXI_ARVALID     : out std_logic;
        STM_AXI_ARREADY     : in  std_logic;
    -------------------------------------------------------------------------------
    -- STREAM IN/OUT AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        STM_AXI_RID         : in  std_logic_vector(STM_AXI_ID_WIDTH    -1 downto 0);
        STM_AXI_RDATA       : in  std_logic_vector(STM_AXI_DATA_WIDTH  -1 downto 0);
        STM_AXI_RRESP       : in  std_logic_vector(1 downto 0);
        STM_AXI_RLAST       : in  std_logic;
        STM_AXI_RVALID      : in  std_logic;
        STM_AXI_RREADY      : out std_logic;
    -------------------------------------------------------------------------------
    -- STREAM IN/OUT AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        STM_AXI_AWID        : out std_logic_vector(STM_AXI_ID_WIDTH    -1 downto 0);
        STM_AXI_AWADDR      : out std_logic_vector(STM_AXI_ADDR_WIDTH  -1 downto 0);
        STM_AXI_AWLEN       : out std_logic_vector(7 downto 0);
        STM_AXI_AWSIZE      : out std_logic_vector(2 downto 0);
        STM_AXI_AWBURST     : out std_logic_vector(1 downto 0);
        STM_AXI_AWLOCK      : out std_logic_vector(0 downto 0);
        STM_AXI_AWCACHE     : out std_logic_vector(3 downto 0);
        STM_AXI_AWPROT      : out std_logic_vector(2 downto 0);
        STM_AXI_AWQOS       : out std_logic_vector(3 downto 0);
        STM_AXI_AWREGION    : out std_logic_vector(3 downto 0);
        STM_AXI_AWUSER      : out std_logic_vector(STM_AXI_USER_WIDTH  -1 downto 0);
        STM_AXI_AWVALID     : out std_logic;
        STM_AXI_AWREADY     : in  std_logic;
    -------------------------------------------------------------------------------
    -- STREAM IN/OUT AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        STM_AXI_WID         : out std_logic_vector(STM_AXI_ID_WIDTH    -1 downto 0);
        STM_AXI_WDATA       : out std_logic_vector(STM_AXI_DATA_WIDTH  -1 downto 0);
        STM_AXI_WSTRB       : out std_logic_vector(STM_AXI_DATA_WIDTH/8-1 downto 0);
        STM_AXI_WLAST       : out std_logic;
        STM_AXI_WVALID      : out std_logic;
        STM_AXI_WREADY      : in  std_logic;
    -------------------------------------------------------------------------------
    -- STREAM IN/OUT AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        STM_AXI_BID         : in  std_logic_vector(STM_AXI_ID_WIDTH    -1 downto 0);
        STM_AXI_BRESP       : in  std_logic_vector(1 downto 0);
        STM_AXI_BVALID      : in  std_logic;
        STM_AXI_BREADY      : out std_logic;
    -------------------------------------------------------------------------------
    -- MERGE IN/OUT AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        MRG_AXI_ARID        : out std_logic_vector(MRG_AXI_ID_WIDTH    -1 downto 0);
        MRG_AXI_ARADDR      : out std_logic_vector(MRG_AXI_ADDR_WIDTH  -1 downto 0);
        MRG_AXI_ARLEN       : out std_logic_vector(7 downto 0);
        MRG_AXI_ARSIZE      : out std_logic_vector(2 downto 0);
        MRG_AXI_ARBURST     : out std_logic_vector(1 downto 0);
        MRG_AXI_ARLOCK      : out std_logic_vector(0 downto 0);
        MRG_AXI_ARCACHE     : out std_logic_vector(3 downto 0);
        MRG_AXI_ARPROT      : out std_logic_vector(2 downto 0);
        MRG_AXI_ARQOS       : out std_logic_vector(3 downto 0);
        MRG_AXI_ARREGION    : out std_logic_vector(3 downto 0);
        MRG_AXI_ARUSER      : out std_logic_vector(MRG_AXI_USER_WIDTH  -1 downto 0);
        MRG_AXI_ARVALID     : out std_logic;
        MRG_AXI_ARREADY     : in  std_logic;
    -------------------------------------------------------------------------------
    -- MERGE IN/OUT AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        MRG_AXI_RID         : in  std_logic_vector(MRG_AXI_ID_WIDTH    -1 downto 0);
        MRG_AXI_RDATA       : in  std_logic_vector(MRG_AXI_DATA_WIDTH  -1 downto 0);
        MRG_AXI_RRESP       : in  std_logic_vector(1 downto 0);
        MRG_AXI_RLAST       : in  std_logic;
        MRG_AXI_RVALID      : in  std_logic;
        MRG_AXI_RREADY      : out std_logic;
    -------------------------------------------------------------------------------
    -- MERGE IN/OUT AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        MRG_AXI_AWID        : out std_logic_vector(MRG_AXI_ID_WIDTH    -1 downto 0);
        MRG_AXI_AWADDR      : out std_logic_vector(MRG_AXI_ADDR_WIDTH  -1 downto 0);
        MRG_AXI_AWLEN       : out std_logic_vector(7 downto 0);
        MRG_AXI_AWSIZE      : out std_logic_vector(2 downto 0);
        MRG_AXI_AWBURST     : out std_logic_vector(1 downto 0);
        MRG_AXI_AWLOCK      : out std_logic_vector(0 downto 0);
        MRG_AXI_AWCACHE     : out std_logic_vector(3 downto 0);
        MRG_AXI_AWPROT      : out std_logic_vector(2 downto 0);
        MRG_AXI_AWQOS       : out std_logic_vector(3 downto 0);
        MRG_AXI_AWREGION    : out std_logic_vector(3 downto 0);
        MRG_AXI_AWUSER      : out std_logic_vector(MRG_AXI_USER_WIDTH  -1 downto 0);
        MRG_AXI_AWVALID     : out std_logic;
        MRG_AXI_AWREADY     : in  std_logic;
    -------------------------------------------------------------------------------
    -- MERGE IN/OUT AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        MRG_AXI_WID         : out std_logic_vector(MRG_AXI_ID_WIDTH    -1 downto 0);
        MRG_AXI_WDATA       : out std_logic_vector(MRG_AXI_DATA_WIDTH  -1 downto 0);
        MRG_AXI_WSTRB       : out std_logic_vector(MRG_AXI_DATA_WIDTH/8-1 downto 0);
        MRG_AXI_WLAST       : out std_logic;
        MRG_AXI_WVALID      : out std_logic;
        MRG_AXI_WREADY      : in  std_logic;
    -------------------------------------------------------------------------------
    -- MERGE IN/OUT AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        MRG_AXI_BID         : in  std_logic_vector(MRG_AXI_ID_WIDTH    -1 downto 0);
        MRG_AXI_BRESP       : in  std_logic_vector(1 downto 0);
        MRG_AXI_BVALID      : in  std_logic;
        MRG_AXI_BREADY      : out std_logic;
    -------------------------------------------------------------------------------
    -- Interrupt Request
    -------------------------------------------------------------------------------
        INTERRUPT           : out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief ArgSort_Kernel                                                        --
-----------------------------------------------------------------------------------
component ArgSort_Kernel
    generic (
        MRG_WAYS                    : --! @brief MERGE WAY SIZE :
                                      integer :=  4;
        MRG_WORDS                   : --! @brief MERGE WORD SIZE :
                                      integer :=  1;
        WORD_BITS                   : --! @brief SORT WORD BIT SIZE :
                                      integer := 32;
        INDEX_BITS                  : --! @brief INDEX BIT SIZE :
                                      integer := 32;
        COMP_SIGN                   : --! @brief COMPARE SIGN :
                                      boolean := FALSE;
        SORT_ORDER                  : --! @brief SORT ORDER :
                                      integer :=  0;
        SORT_SIZE_BITS              : --! @brief SORT SIZE BITS :
                                      integer range 1 to 32 := 28;
        MRG_FIFO_SIZE               : --! @brief MERGE FIFO SIZE :
                                      integer :=  16;
        MRG_RD_PRE_STATE            : --! @brief MERGE IN  PRE STATE :
                                      integer :=  0;
        STM_FEEDBACK                : --! @brief STREAM FEED BACK NUMBER :
                                      integer :=  0;
        STM_IN_QUEUE_SIZE           : --! @brief STREAM IN QUEUE SIZE :
                                      integer :=  0;
        C_S_AXI_CONTROL_ADDR_WIDTH  : --! @brief S_AXI_CONTROL I/F ADDRRESS WIDTH :
                                      integer := 6;
        C_S_AXI_CONTROL_DATA_WIDTH  : --! @brief S_AXI_CONTROL I/F DATA WIDTH :
                                      integer := 32;
        C_M_AXI_STM_ADDR_WIDTH      : --! @brief STREAM IN/OUT AXI ADDRESS WIDTH :
                                      integer := 32;
        C_M_AXI_STM_DATA_WIDTH      : --! @brief STREAM IN/OUT AXI DATA WIDTH :
                                      integer := 64;
        C_M_AXI_STM_ID_WIDTH        : --! @brief STREAM IN/OUT AXI ID WIDTH :
                                      integer := 1;
        C_M_AXI_STM_ARUSER_WIDTH    : --! @brief STREAM IN/OUT AXI ARUSER WIDTH :
                                      integer := 1;
        C_M_AXI_STM_AWUSER_WIDTH    : --! @brief STREAM IN/OUT AXI AWUSER WIDTH :
                                      integer := 1;
        C_M_AXI_STM_RUSER_WIDTH     : --! @brief STREAM IN/OUT AXI RUSER WIDTH :
                                      integer := 1;
        C_M_AXI_STM_WUSER_WIDTH     : --! @brief STREAM IN/OUT AXI WUSER WIDTH :
                                      integer := 1;
        C_M_AXI_STM_BUSER_WIDTH     : --! @brief STREAM IN/OUT AXI BUSER WIDTH :
                                      integer := 1;
        C_M_AXI_STM_ID_BASE         : --! @brief STREAM IN/OUT AXI ID BASE :
                                      integer := 0;
        C_M_AXI_STM_RD_XFER_SIZE    : --! @brief STREAM IN  AXI MAX XFER SIZE :
                                      integer := 11;
        C_M_AXI_STM_RD_BUF_SIZE     : --! @brief STREAM IN  AXI BUFFER SIZE :
                                      integer := 0;
        C_M_AXI_STM_RD_QUEUE        : --! @brief STREAM IN  AXI QUEUE SIZE :
                                      integer := 4;
        C_M_AXI_STM_RD_DATA_REGS    : --! @brief STREAM IN  AXI DATA REGISTER :
                                      integer := 2;
        C_M_AXI_STM_RD_ACK_REGS     : --! @brief STREAM IN  AXI ACKNOWLEDGE REGISTER :
                                      integer range 0 to 1 := 1;
        C_M_AXI_STM_WR_XFER_SIZE    : --! @brief STREAM OUT AXI MAX XFER SIZE :
                                      integer := 11;
        C_M_AXI_STM_WR_BUF_SIZE     : --! @brief STREAM OUT AXI BUFFER SIZE :
                                      integer := 0;
        C_M_AXI_STM_WR_QUEUE        : --! @brief STREAM OUT AXI QUEUE SIZE :
                                      integer := 4;
        C_M_AXI_STM_WR_REQ_REGS     : --! @brief STREAM OUT AXI REQUEST REGISTER :
                                      integer range 0 to 1 := 1;
        C_M_AXI_STM_WR_ACK_REGS     : --! @brief STREAM OUT AXI ACKNOWLEDGE REGISTER :
                                      integer range 0 to 1 := 1;
        C_M_AXI_STM_WR_RESP_REGS    : --! @brief STREAM OUT AXI RESPONSE REGISTER :
                                      integer range 0 to 1 := 1;
        C_M_AXI_MRG_ADDR_WIDTH      : --! @brief MERGE IN/OUT AXI ADDRESS WIDTH :
                                      integer := 32;
        C_M_AXI_MRG_DATA_WIDTH      : --! @brief MERGE IN/OUT AXI DATA WIDTH :
                                      integer := 64;
        C_M_AXI_MRG_ID_WIDTH        : --! @brief MERGE IN/OUT AXI ID WIDTH :
                                      integer := 1;
        C_M_AXI_MRG_ARUSER_WIDTH    : --! @brief MERGE IN/OUT AXI ARUSER WIDTH :
                                      integer := 1;
        C_M_AXI_MRG_AWUSER_WIDTH    : --! @brief MERGE IN/OUT AXI AWUSER WIDTH :
                                      integer := 1;
        C_M_AXI_MRG_RUSER_WIDTH     : --! @brief MERGE IN/OUT AXI RUSER WIDTH :
                                      integer := 1;
        C_M_AXI_MRG_WUSER_WIDTH     : --! @brief MERGE IN/OUT AXI WUSER WIDTH :
                                      integer := 1;
        C_M_AXI_MRG_BUSER_WIDTH     : --! @brief MERGE IN/OUT AXI BUSER WIDTH :
                                      integer := 1;
        C_M_AXI_MRG_ID_BASE         : --! @brief MERGE IN/OUT AXI ID BASE :
                                      integer := 0;
        C_M_AXI_MRG_RD_XFER_SIZE    : --! @brief MERGE IN  AXI MAX XFER SIZE :
                                      integer := 11;
        C_M_AXI_MRG_RD_BUF_SIZE     : --! @brief MERGE IN  AXI BUFFER SIZE :
                                      integer := 0;
        C_M_AXI_MRG_RD_QUEUE        : --! @brief MERGE IN  AXI QUEUE SIZE :
                                      integer := 4;
        C_M_AXI_MRG_RD_DATA_REGS    : --! @brief MERGE IN  AXI DATA REGISTER :
                                      integer := 2;
        C_M_AXI_MRG_RD_ACK_REGS     : --! @brief MERGE IN  AXI ACKNOWLEDGE REGISTER :
                                      integer range 0 to 1 := 1;
        C_M_AXI_MRG_RD_ARB_NODE_NUM : --! @brief MERGE IN  ARBITER NODE SIZE :
                                      integer := 4;
        C_M_AXI_MRG_RD_ARB_PIPELINE : --! @brief MERGE IN  ARBITER PIPELINE :
                                      integer := 0;
        C_M_AXI_MRG_WR_XFER_SIZE    : --! @brief MERGE OUT AXI MAX XFER SIZE :
                                      integer := 11;
        C_M_AXI_MRG_WR_BUF_SIZE     : --! @brief MERGE OUT AXI BUFFER SIZE :
                                      integer := 0;
        C_M_AXI_MRG_WR_QUEUE        : --! @brief MERGE OUT AXI QUEUE SIZE :
                                      integer := 4;
        C_M_AXI_MRG_WR_REQ_REGS     : --! @brief MERGE OUT AXI REQUEST REGISTER :
                                      integer range 0 to 1 := 1;
        C_M_AXI_MRG_WR_ACK_REGS     : --! @brief MERGE OUT AXI ACKNOWLEDGE REGISTER :
                                      integer range 0 to 1 := 1;
        C_M_AXI_MRG_WR_RESP_REGS    : --! @brief MERGE OUT AXI RESPONSE REGISTER :
                                      integer range 0 to 1 := 1;
        DEBUG_ENABLE                : --! @brief DEBUG ENABLE :
                                      integer range 0 to 1 := 0
    );
    port(
    -------------------------------------------------------------------------------
    -- Clock / Reset Signals.
    -------------------------------------------------------------------------------
        AP_CLK                      : in  std_logic;
        AP_RST_N                    : in  std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        S_AXI_CONTROL_ARADDR        : in  std_logic_vector(C_S_AXI_CONTROL_ADDR_WIDTH   -1 downto 0);
        S_AXI_CONTROL_ARVALID       : in  std_logic;
        S_AXI_CONTROL_ARREADY       : out std_logic;
    ------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Read Data Channel Signals.
    ------------------------------------------------------------------------------
        S_AXI_CONTROL_RDATA         : out std_logic_vector(C_S_AXI_CONTROL_DATA_WIDTH   -1 downto 0);
        S_AXI_CONTROL_RRESP         : out std_logic_vector(1 downto 0);  
        S_AXI_CONTROL_RVALID        : out std_logic;
        S_AXI_CONTROL_RREADY        : in  std_logic;
    ------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Address Channel Signals.
    ------------------------------------------------------------------------------
        S_AXI_CONTROL_AWADDR        : in  std_logic_vector(C_S_AXI_CONTROL_ADDR_WIDTH   -1 downto 0);
        S_AXI_CONTROL_AWVALID       : in  std_logic;
        S_AXI_CONTROL_AWREADY       : out std_logic;
    ------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Data Channel Signals.
    ------------------------------------------------------------------------------
        S_AXI_CONTROL_WDATA         : in  std_logic_vector(C_S_AXI_CONTROL_DATA_WIDTH   -1 downto 0);
        S_AXI_CONTROL_WSTRB         : in  std_logic_vector(C_S_AXI_CONTROL_DATA_WIDTH/8 -1 downto 0);
        S_AXI_CONTROL_WVALID        : in  std_logic;
        S_AXI_CONTROL_WREADY        : out std_logic;
    ------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Response Channel Signals.
    ------------------------------------------------------------------------------
        S_AXI_CONTROL_BRESP         : out std_logic_vector(1 downto 0);
        S_AXI_CONTROL_BVALID        : out std_logic;
        S_AXI_CONTROL_BREADY        : in  std_logic;
    -------------------------------------------------------------------------------
    -- STREAM IN/OUT AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        M_AXI_STM_ARID              : out std_logic_vector(C_M_AXI_STM_ID_WIDTH    -1 downto 0);
        M_AXI_STM_ARADDR            : out std_logic_vector(C_M_AXI_STM_ADDR_WIDTH  -1 downto 0);
        M_AXI_STM_ARLEN             : out std_logic_vector(7 downto 0);
        M_AXI_STM_ARSIZE            : out std_logic_vector(2 downto 0);
        M_AXI_STM_ARBURST           : out std_logic_vector(1 downto 0);
        M_AXI_STM_ARLOCK            : out std_logic_vector(0 downto 0);
        M_AXI_STM_ARCACHE           : out std_logic_vector(3 downto 0);
        M_AXI_STM_ARPROT            : out std_logic_vector(2 downto 0);
        M_AXI_STM_ARQOS             : out std_logic_vector(3 downto 0);
        M_AXI_STM_ARREGION          : out std_logic_vector(3 downto 0);
        M_AXI_STM_ARUSER            : out std_logic_vector(C_M_AXI_STM_ARUSER_WIDTH-1 downto 0);
        M_AXI_STM_ARVALID           : out std_logic;
        M_AXI_STM_ARREADY           : in  std_logic;
    -------------------------------------------------------------------------------
    -- STREAM IN/OUT AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        M_AXI_STM_RID               : in  std_logic_vector(C_M_AXI_STM_ID_WIDTH    -1 downto 0);
        M_AXI_STM_RDATA             : in  std_logic_vector(C_M_AXI_STM_DATA_WIDTH  -1 downto 0);
        M_AXI_STM_RRESP             : in  std_logic_vector(1 downto 0);
        M_AXI_STM_RUSER             : in  std_logic_vector(C_M_AXI_STM_RUSER_WIDTH -1 downto 0);
        M_AXI_STM_RLAST             : in  std_logic;
        M_AXI_STM_RVALID            : in  std_logic;
        M_AXI_STM_RREADY            : out std_logic;
    -------------------------------------------------------------------------------
    -- STREAM IN/OUT AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        M_AXI_STM_AWID              : out std_logic_vector(C_M_AXI_STM_ID_WIDTH    -1 downto 0);
        M_AXI_STM_AWADDR            : out std_logic_vector(C_M_AXI_STM_ADDR_WIDTH  -1 downto 0);
        M_AXI_STM_AWLEN             : out std_logic_vector(7 downto 0);
        M_AXI_STM_AWSIZE            : out std_logic_vector(2 downto 0);
        M_AXI_STM_AWBURST           : out std_logic_vector(1 downto 0);
        M_AXI_STM_AWLOCK            : out std_logic_vector(0 downto 0);
        M_AXI_STM_AWCACHE           : out std_logic_vector(3 downto 0);
        M_AXI_STM_AWPROT            : out std_logic_vector(2 downto 0);
        M_AXI_STM_AWQOS             : out std_logic_vector(3 downto 0);
        M_AXI_STM_AWREGION          : out std_logic_vector(3 downto 0);
        M_AXI_STM_AWUSER            : out std_logic_vector(C_M_AXI_STM_AWUSER_WIDTH-1 downto 0);
        M_AXI_STM_AWVALID           : out std_logic;
        M_AXI_STM_AWREADY           : in  std_logic;
    -------------------------------------------------------------------------------
    -- STREAM IN/OUT AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        M_AXI_STM_WID               : out std_logic_vector(C_M_AXI_STM_ID_WIDTH    -1 downto 0);
        M_AXI_STM_WDATA             : out std_logic_vector(C_M_AXI_STM_DATA_WIDTH  -1 downto 0);
        M_AXI_STM_WSTRB             : out std_logic_vector(C_M_AXI_STM_DATA_WIDTH/8-1 downto 0);
        M_AXI_STM_WUSER             : out std_logic_vector(C_M_AXI_STM_WUSER_WIDTH -1 downto 0);
        M_AXI_STM_WLAST             : out std_logic;
        M_AXI_STM_WVALID            : out std_logic;
        M_AXI_STM_WREADY            : in  std_logic;
    -------------------------------------------------------------------------------
    -- STREAM IN/OUT AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        M_AXI_STM_BID               : in  std_logic_vector(C_M_AXI_STM_ID_WIDTH    -1 downto 0);
        M_AXI_STM_BRESP             : in  std_logic_vector(1 downto 0);
        M_AXI_STM_BUSER             : in  std_logic_vector(C_M_AXI_STM_BUSER_WIDTH -1 downto 0);
        M_AXI_STM_BVALID            : in  std_logic;
        M_AXI_STM_BREADY            : out std_logic;
    -------------------------------------------------------------------------------
    -- MERGE IN/OUT AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        M_AXI_MRG_ARID              : out std_logic_vector(C_M_AXI_MRG_ID_WIDTH    -1 downto 0);
        M_AXI_MRG_ARADDR            : out std_logic_vector(C_M_AXI_MRG_ADDR_WIDTH  -1 downto 0);
        M_AXI_MRG_ARLEN             : out std_logic_vector(7 downto 0);
        M_AXI_MRG_ARSIZE            : out std_logic_vector(2 downto 0);
        M_AXI_MRG_ARBURST           : out std_logic_vector(1 downto 0);
        M_AXI_MRG_ARLOCK            : out std_logic_vector(0 downto 0);
        M_AXI_MRG_ARCACHE           : out std_logic_vector(3 downto 0);
        M_AXI_MRG_ARPROT            : out std_logic_vector(2 downto 0);
        M_AXI_MRG_ARQOS             : out std_logic_vector(3 downto 0);
        M_AXI_MRG_ARREGION          : out std_logic_vector(3 downto 0);
        M_AXI_MRG_ARUSER            : out std_logic_vector(C_M_AXI_MRG_ARUSER_WIDTH-1 downto 0);
        M_AXI_MRG_ARVALID           : out std_logic;
        M_AXI_MRG_ARREADY           : in  std_logic;
    -------------------------------------------------------------------------------
    -- MERGE IN/OUT AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        M_AXI_MRG_RID               : in  std_logic_vector(C_M_AXI_MRG_ID_WIDTH    -1 downto 0);
        M_AXI_MRG_RDATA             : in  std_logic_vector(C_M_AXI_MRG_DATA_WIDTH  -1 downto 0);
        M_AXI_MRG_RRESP             : in  std_logic_vector(1 downto 0);
        M_AXI_MRG_RUSER             : in  std_logic_vector(C_M_AXI_MRG_RUSER_WIDTH -1 downto 0);
        M_AXI_MRG_RLAST             : in  std_logic;
        M_AXI_MRG_RVALID            : in  std_logic;
        M_AXI_MRG_RREADY            : out std_logic;
    -------------------------------------------------------------------------------
    -- MERGE IN/OUT AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        M_AXI_MRG_AWID              : out std_logic_vector(C_M_AXI_MRG_ID_WIDTH    -1 downto 0);
        M_AXI_MRG_AWADDR            : out std_logic_vector(C_M_AXI_MRG_ADDR_WIDTH  -1 downto 0);
        M_AXI_MRG_AWLEN             : out std_logic_vector(7 downto 0);
        M_AXI_MRG_AWSIZE            : out std_logic_vector(2 downto 0);
        M_AXI_MRG_AWBURST           : out std_logic_vector(1 downto 0);
        M_AXI_MRG_AWLOCK            : out std_logic_vector(0 downto 0);
        M_AXI_MRG_AWCACHE           : out std_logic_vector(3 downto 0);
        M_AXI_MRG_AWPROT            : out std_logic_vector(2 downto 0);
        M_AXI_MRG_AWQOS             : out std_logic_vector(3 downto 0);
        M_AXI_MRG_AWREGION          : out std_logic_vector(3 downto 0);
        M_AXI_MRG_AWUSER            : out std_logic_vector(C_M_AXI_MRG_AWUSER_WIDTH-1 downto 0);
        M_AXI_MRG_AWVALID           : out std_logic;
        M_AXI_MRG_AWREADY           : in  std_logic;
    -------------------------------------------------------------------------------
    -- MERGE IN/OUT AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        M_AXI_MRG_WID               : out std_logic_vector(C_M_AXI_MRG_ID_WIDTH    -1 downto 0);
        M_AXI_MRG_WDATA             : out std_logic_vector(C_M_AXI_MRG_DATA_WIDTH  -1 downto 0);
        M_AXI_MRG_WSTRB             : out std_logic_vector(C_M_AXI_MRG_DATA_WIDTH/8-1 downto 0);
        M_AXI_MRG_WUSER             : out std_logic_vector(C_M_AXI_MRG_WUSER_WIDTH -1 downto 0);
        M_AXI_MRG_WLAST             : out std_logic;
        M_AXI_MRG_WVALID            : out std_logic;
        M_AXI_MRG_WREADY            : in  std_logic;
    -------------------------------------------------------------------------------
    -- MERGE IN/OUT AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        M_AXI_MRG_BID               : in  std_logic_vector(C_M_AXI_MRG_ID_WIDTH    -1 downto 0);
        M_AXI_MRG_BRESP             : in  std_logic_vector(1 downto 0);
        M_AXI_MRG_BUSER             : in  std_logic_vector(C_M_AXI_MRG_BUSER_WIDTH -1 downto 0);
        M_AXI_MRG_BVALID            : in  std_logic;
        M_AXI_MRG_BREADY            : out std_logic;
    -------------------------------------------------------------------------------
    -- Interrupt Request
    -------------------------------------------------------------------------------
        INTERRUPT                   : out std_logic
    );
end component;
end ArgSort_AXI_Components;
