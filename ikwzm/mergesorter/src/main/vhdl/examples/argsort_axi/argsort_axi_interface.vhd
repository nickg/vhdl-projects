-----------------------------------------------------------------------------------
--!     @file    argsort_axi_interface.vhd
--!     @brief   Merge Sorter ArgSort AXI Interface Module :
--!     @version 1.2.0
--!     @date    2021/6/27
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2021 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_AXI_Interface is
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
end ArgSort_AXI_Interface;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library Merge_Sorter;
use     Merge_Sorter.Interface;
use     Merge_Sorter.ArgSort_AXI_Components.Argsort_AXI_Reader;
use     Merge_Sorter.ArgSort_AXI_Components.Argsort_AXI_Writer;
use     Merge_Sorter.Interface_Components.Merge_AXI_Reader;
use     Merge_Sorter.Interface_Components.Merge_AXI_Writer;
use     Merge_Sorter.Interface_Components.Interface_Controller;
architecture RTL of Argsort_AXI_Interface is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  STM_RD_DATA_BITS  :  integer := (WORD_COMP_HI  - WORD_COMP_LO  + 1);
    constant  STM_RD_REG_PARAM  :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
    signal    stm_rd_reg_load   :  std_logic_vector(STM_RD_REG_PARAM.BITS-1 downto 0);
    signal    stm_rd_reg_wbit   :  std_logic_vector(STM_RD_REG_PARAM.BITS-1 downto 0);
    signal    stm_rd_reg_rbit   :  std_logic_vector(STM_RD_REG_PARAM.BITS-1 downto 0);
    signal    stm_rd_busy       :  std_logic;
    signal    stm_rd_done       :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  STM_WR_DATA_BITS  :  integer := (WORD_INDEX_HI - WORD_INDEX_LO + 1);
    constant  STM_WR_REG_PARAM  :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
    signal    stm_wr_reg_load   :  std_logic_vector(STM_WR_REG_PARAM.BITS-1 downto 0);
    signal    stm_wr_reg_wbit   :  std_logic_vector(STM_WR_REG_PARAM.BITS-1 downto 0);
    signal    stm_wr_reg_rbit   :  std_logic_vector(STM_WR_REG_PARAM.BITS-1 downto 0);
    signal    stm_wr_busy       :  std_logic;
    signal    stm_wr_done       :  std_logic;
    signal    stm_wr_valid      :  std_logic;
    signal    stm_wr_ready      :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  MRG_RD_REG_PARAM  :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
    signal    mrg_rd_reg_load   :  std_logic_vector(WAYS*MRG_RD_REG_PARAM.BITS-1 downto 0);
    signal    mrg_rd_reg_wbit   :  std_logic_vector(WAYS*MRG_RD_REG_PARAM.BITS-1 downto 0);
    signal    mrg_rd_reg_rbit   :  std_logic_vector(WAYS*MRG_RD_REG_PARAM.BITS-1 downto 0);
    signal    mrg_rd_busy       :  std_logic_vector(WAYS                      -1 downto 0);
    signal    mrg_rd_done       :  std_logic_vector(WAYS                      -1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  MRG_WR_REG_PARAM  :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
    signal    mrg_wr_reg_load   :  std_logic_vector(MRG_WR_REG_PARAM.BITS-1 downto 0);
    signal    mrg_wr_reg_wbit   :  std_logic_vector(MRG_WR_REG_PARAM.BITS-1 downto 0);
    signal    mrg_wr_reg_rbit   :  std_logic_vector(MRG_WR_REG_PARAM.BITS-1 downto 0);
    signal    mrg_wr_busy       :  std_logic;
    signal    mrg_wr_done       :  std_logic;
    signal    mrg_wr_valid      :  std_logic;
    signal    mrg_wr_ready      :  std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    STM_RD: Argsort_AXI_Reader                           -- 
        generic map (                                    -- 
            WORDS               => WORDS               , --
            WORD_BITS           => WORD_BITS           , --
            WORD_INDEX_LO       => WORD_INDEX_LO       , --
            WORD_INDEX_HI       => WORD_INDEX_HI       , --
            WORD_COMP_LO        => WORD_COMP_LO        , --
            WORD_COMP_HI        => WORD_COMP_HI        , --
            AXI_ID_BASE         => STM_AXI_ID_BASE     , --
            AXI_ID_WIDTH        => STM_AXI_ID_WIDTH    , --
            AXI_AUSER_WIDTH     => STM_AXI_ARUSER_WIDTH, --
            AXI_ADDR_WIDTH      => STM_AXI_ADDR_WIDTH  , --
            AXI_DATA_WIDTH      => STM_AXI_DATA_WIDTH  , --
            AXI_XFER_SIZE       => STM_RD_AXI_XFER_SIZE, --
            AXI_BUF_DEPTH       => STM_RD_AXI_BUF_DEPTH, --
            AXI_QUEUE_SIZE      => STM_RD_AXI_QUEUE    , --
            AXI_RDATA_REGS      => STM_RD_AXI_DATA_REGS, --
            AXI_ACK_REGS        => STM_RD_AXI_ACK_REGS , -- 
            STM_REG_PARAM       => STM_RD_REG_PARAM      --
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        -- Clock/Reset Signals.
        ---------------------------------------------------------------------------
            CLK                 => CLK                 , -- In  :
            RST                 => RST                 , -- In  :
            CLR                 => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- AXI Master Read Address Channel Signals.
        ---------------------------------------------------------------------------
            AXI_ARID            => STM_AXI_ARID        , -- Out :
            AXI_ARADDR          => STM_AXI_ARADDR      , -- Out :
            AXI_ARLEN           => STM_AXI_ARLEN       , -- Out :
            AXI_ARSIZE          => STM_AXI_ARSIZE      , -- Out :
            AXI_ARBURST         => STM_AXI_ARBURST     , -- Out :
            AXI_ARLOCK          => STM_AXI_ARLOCK      , -- Out :
            AXI_ARCACHE         => STM_AXI_ARCACHE     , -- Out :
            AXI_ARPROT          => STM_AXI_ARPROT      , -- Out :
            AXI_ARQOS           => STM_AXI_ARQOS       , -- Out :
            AXI_ARREGION        => STM_AXI_ARREGION    , -- Out :
            AXI_ARUSER          => STM_AXI_ARUSER      , -- Out :
            AXI_ARVALID         => STM_AXI_ARVALID     , -- Out :
            AXI_ARREADY         => STM_AXI_ARREADY     , -- In  :
        ---------------------------------------------------------------------------
        -- AXI Master Read Data Channel Signals.
        ---------------------------------------------------------------------------
            AXI_RID             => STM_AXI_RID         , -- In  :
            AXI_RDATA           => STM_AXI_RDATA       , -- In  :
            AXI_RRESP           => STM_AXI_RRESP       , -- In  :
            AXI_RLAST           => STM_AXI_RLAST       , -- In  :
            AXI_RVALID          => STM_AXI_RVALID      , -- In  :
            AXI_RREADY          => STM_AXI_RREADY      , -- Out :
        ---------------------------------------------------------------------------
        -- Stream Reader Control Register Interface.
        -------------------------------------------------------------------------------
            STM_REG_L           => stm_rd_reg_load     , -- In  :
            STM_REG_D           => stm_rd_reg_wbit     , -- In  :
            STM_REG_Q           => stm_rd_reg_rbit     , -- Out :
        ---------------------------------------------------------------------------
        -- Stream Outlet Signals.
        ---------------------------------------------------------------------------
            STM_DATA            => STM_RD_DATA         , -- Out :
            STM_STRB            => STM_RD_STRB         , -- Out :
            STM_LAST            => STM_RD_LAST         , -- Out :
            STM_VALID           => STM_RD_VALID        , -- Out :
            STM_READY           => STM_RD_READY        , -- In  :
        ---------------------------------------------------------------------------
        -- Status Output.
        ---------------------------------------------------------------------------
            BUSY                => stm_rd_busy         , -- Out :
            DONE                => stm_rd_done           -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    STM_WR:  ArgSort_AXI_Writer                          -- 
        generic map (                                    -- 
            WORDS               => WORDS               , --
            WORD_BITS           => WORD_BITS           , --
            WORD_INDEX_LO       => WORD_INDEX_LO       , --
            WORD_INDEX_HI       => WORD_INDEX_HI       , --
            WORD_COMP_LO        => WORD_COMP_LO        , --
            WORD_COMP_HI        => WORD_COMP_HI        , --
            AXI_ID_BASE         => STM_AXI_ID_BASE     , --
            AXI_ID_WIDTH        => STM_AXI_ID_WIDTH    , --
            AXI_AUSER_WIDTH     => STM_AXI_AWUSER_WIDTH, --
            AXI_WUSER_WIDTH     => STM_AXI_WUSER_WIDTH , --
            AXI_BUSER_WIDTH     => STM_AXI_BUSER_WIDTH , --
            AXI_ADDR_WIDTH      => STM_AXI_ADDR_WIDTH  , --
            AXI_DATA_WIDTH      => STM_AXI_DATA_WIDTH  , --
            AXI_XFER_SIZE       => STM_WR_AXI_XFER_SIZE, --
            AXI_BUF_DEPTH       => STM_WR_AXI_BUF_DEPTH, --
            AXI_QUEUE_SIZE      => STM_WR_AXI_QUEUE    , --
            AXI_REQ_REGS        => STM_WR_AXI_REQ_REGS , --
            AXI_ACK_REGS        => STM_WR_AXI_ACK_REGS , --
            AXI_RESP_REGS       => STM_WR_AXI_RESP_REGS, -- 
            STM_REG_PARAM       => STM_WR_REG_PARAM      --
        )                                                --
        port map (                                       --
        ---------------------------------------------------------------------------
        -- Clock/Reset Signals.
        ---------------------------------------------------------------------------
            CLK                 => CLK                 , -- In  :
            RST                 => RST                 , -- In  :
            CLR                 => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- AXI Master Writer Address Channel Signals.
        ---------------------------------------------------------------------------
            AXI_AWID            => STM_AXI_AWID        , -- Out :
            AXI_AWADDR          => STM_AXI_AWADDR      , -- Out :
            AXI_AWLEN           => STM_AXI_AWLEN       , -- Out :
            AXI_AWSIZE          => STM_AXI_AWSIZE      , -- Out :
            AXI_AWBURST         => STM_AXI_AWBURST     , -- Out :
            AXI_AWLOCK          => STM_AXI_AWLOCK      , -- Out :
            AXI_AWCACHE         => STM_AXI_AWCACHE     , -- Out :
            AXI_AWPROT          => STM_AXI_AWPROT      , -- Out :
            AXI_AWQOS           => STM_AXI_AWQOS       , -- Out :
            AXI_AWREGION        => STM_AXI_AWREGION    , -- Out :
            AXI_AWUSER          => STM_AXI_AWUSER      , -- Out :
            AXI_AWVALID         => STM_AXI_AWVALID     , -- Out :
            AXI_AWREADY         => STM_AXI_AWREADY     , -- In  :
        --------------------------------------------------------------------------
        -- AXI Master Write Data Channel Signals.
        --------------------------------------------------------------------------
            AXI_WID             => STM_AXI_WID         , -- Out :
            AXI_WDATA           => STM_AXI_WDATA       , -- Out :
            AXI_WSTRB           => STM_AXI_WSTRB       , -- Out :
            AXI_WUSER           => STM_AXI_WUSER       , -- Out :
            AXI_WLAST           => STM_AXI_WLAST       , -- Out :
            AXI_WVALID          => STM_AXI_WVALID      , -- Out :
            AXI_WREADY          => STM_AXI_WREADY      , -- In  :
        --------------------------------------------------------------------------
        -- AXI Write Response Channel Signals.
        --------------------------------------------------------------------------
            AXI_BID             => STM_AXI_BID         , -- In  :
            AXI_BRESP           => STM_AXI_BRESP       , -- In  :
            AXI_BUSER           => STM_AXI_BUSER       , -- In  :
            AXI_BVALID          => STM_AXI_BVALID      , -- In  :
            AXI_BREADY          => STM_AXI_BREADY      , -- Out :
        ---------------------------------------------------------------------------
        -- Stream Writer Control Register Interface.
        ---------------------------------------------------------------------------
            STM_REG_L           => stm_wr_reg_load     , -- In  :
            STM_REG_D           => stm_wr_reg_wbit     , -- In  :
            STM_REG_Q           => stm_wr_reg_rbit     , -- Out :
        --------------------------------------------------------------------------
        -- Stream Intake Signals.
        --------------------------------------------------------------------------
            STM_DATA            => MERGED_DATA         , -- In  :
            STM_STRB            => MERGED_STRB         , -- In  :
            STM_LAST            => MERGED_LAST         , -- In  :
            STM_VALID           => stm_wr_valid        , -- In  :
            STM_READY           => stm_wr_ready        , -- Out :
        --------------------------------------------------------------------------
        -- Status Output.
        --------------------------------------------------------------------------
            BUSY                => stm_wr_busy         , -- Out :
            DONE                => stm_wr_done           -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    MRG_RD: Merge_AXI_Reader                             -- 
        generic map (                                    -- 
            WAYS                => WAYS                , --
            WORDS               => WORDS               , --
            WORD_BITS           => WORD_BITS           , --
            AXI_ID_BASE         => MRG_AXI_ID_BASE     , --
            AXI_ID_WIDTH        => MRG_AXI_ID_WIDTH    , --
            AXI_AUSER_WIDTH     => MRG_AXI_ARUSER_WIDTH, --
            AXI_ADDR_WIDTH      => MRG_AXI_ADDR_WIDTH  , --
            AXI_DATA_WIDTH      => MRG_AXI_DATA_WIDTH  , --
            AXI_XFER_SIZE       => MRG_RD_AXI_XFER_SIZE, --
            AXI_BUF_DEPTH       => MRG_RD_AXI_BUF_DEPTH, --
            AXI_QUEUE_SIZE      => MRG_RD_AXI_QUEUE    , --
            AXI_RDATA_REGS      => MRG_RD_AXI_DATA_REGS, -- 
            AXI_ACK_REGS        => MRG_RD_AXI_ACK_REGS , -- 
            ARB_NODE_NUM        => MRG_RD_ARB_NODE_NUM , -- 
            ARB_PIPELINE        => MRG_RD_ARB_PIPELINE , -- 
            MRG_REG_PARAM       => MRG_RD_REG_PARAM      --
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        -- Clock/Reset Signals.
        ---------------------------------------------------------------------------
            CLK                 => CLK                 , -- In  :
            RST                 => RST                 , -- In  :
            CLR                 => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- AXI Master Read Address Channel Signals.
        ---------------------------------------------------------------------------
            AXI_ARID            => MRG_AXI_ARID        , -- Out :
            AXI_ARADDR          => MRG_AXI_ARADDR      , -- Out :
            AXI_ARLEN           => MRG_AXI_ARLEN       , -- Out :
            AXI_ARSIZE          => MRG_AXI_ARSIZE      , -- Out :
            AXI_ARBURST         => MRG_AXI_ARBURST     , -- Out :
            AXI_ARLOCK          => MRG_AXI_ARLOCK      , -- Out :
            AXI_ARCACHE         => MRG_AXI_ARCACHE     , -- Out :
            AXI_ARPROT          => MRG_AXI_ARPROT      , -- Out :
            AXI_ARQOS           => MRG_AXI_ARQOS       , -- Out :
            AXI_ARREGION        => MRG_AXI_ARREGION    , -- Out :
            AXI_ARUSER          => MRG_AXI_ARUSER      , -- Out :
            AXI_ARVALID         => MRG_AXI_ARVALID     , -- Out :
            AXI_ARREADY         => MRG_AXI_ARREADY     , -- In  :
        ---------------------------------------------------------------------------
        -- AXI Master Read Data Channel Signals.
        ---------------------------------------------------------------------------
            AXI_RID             => MRG_AXI_RID         , -- In  :
            AXI_RDATA           => MRG_AXI_RDATA       , -- In  :
            AXI_RRESP           => MRG_AXI_RRESP       , -- In  :
            AXI_RLAST           => MRG_AXI_RLAST       , -- In  :
            AXI_RVALID          => MRG_AXI_RVALID      , -- In  :
            AXI_RREADY          => MRG_AXI_RREADY      , -- Out :
        ---------------------------------------------------------------------------
        -- Merge Reader Control Register Interface.
        ---------------------------------------------------------------------------
            MRG_REG_L           => mrg_rd_reg_load     , -- In  :
            MRG_REG_D           => mrg_rd_reg_wbit     , -- In  :
            MRG_REG_Q           => mrg_rd_reg_rbit     , -- Out :
        ---------------------------------------------------------------------------
        -- Merge Outlet Signals.
        ---------------------------------------------------------------------------
            MRG_DATA            => MRG_RD_DATA         , -- Out :
            MRG_NONE            => MRG_RD_NONE         , -- Out :
            MRG_EBLK            => MRG_RD_EBLK         , -- Out :
            MRG_LAST            => MRG_RD_LAST         , -- Out :
            MRG_VALID           => MRG_RD_VALID        , -- Out :
            MRG_READY           => MRG_RD_READY        , -- In  :
            MRG_LEVEL           => MRG_RD_LEVEL        , -- In  :
        ---------------------------------------------------------------------------
        -- Status Output.
        ---------------------------------------------------------------------------
            BUSY                => mrg_rd_busy         , -- Out :
            DONE                => mrg_rd_done           -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    MRG_WR: Merge_AXI_Writer                             -- 
        generic map (                                    -- 
            WORDS               => WORDS               , --
            WORD_BITS           => WORD_BITS           , --
            AXI_ID_BASE         => MRG_AXI_ID_BASE     , --
            AXI_ID_WIDTH        => MRG_AXI_ID_WIDTH    , --
            AXI_AUSER_WIDTH     => MRG_AXI_AWUSER_WIDTH, --
            AXI_WUSER_WIDTH     => MRG_AXI_WUSER_WIDTH , --
            AXI_BUSER_WIDTH     => MRG_AXI_BUSER_WIDTH , --
            AXI_ADDR_WIDTH      => MRG_AXI_ADDR_WIDTH  , --
            AXI_DATA_WIDTH      => MRG_AXI_DATA_WIDTH  , --
            AXI_XFER_SIZE       => MRG_WR_AXI_XFER_SIZE, --
            AXI_BUF_DEPTH       => MRG_WR_AXI_BUF_DEPTH, --
            AXI_QUEUE_SIZE      => MRG_WR_AXI_QUEUE    , -- 
            AXI_REQ_REGS        => MRG_WR_AXI_REQ_REGS , -- 
            AXI_ACK_REGS        => MRG_WR_AXI_ACK_REGS , --
            AXI_RESP_REGS       => MRG_WR_AXI_RESP_REGS, -- 
            MRG_REG_PARAM       => MRG_WR_REG_PARAM      --
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        -- Clock/Reset Signals.
        ---------------------------------------------------------------------------
            CLK                 => CLK                 , -- In  :
            RST                 => RST                 , -- In  :
            CLR                 => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- AXI Master Writer Address Channel Signals.
        ---------------------------------------------------------------------------
            AXI_AWID            => MRG_AXI_AWID        , -- Out :
            AXI_AWADDR          => MRG_AXI_AWADDR      , -- Out :
            AXI_AWLEN           => MRG_AXI_AWLEN       , -- Out :
            AXI_AWSIZE          => MRG_AXI_AWSIZE      , -- Out :
            AXI_AWBURST         => MRG_AXI_AWBURST     , -- Out :
            AXI_AWLOCK          => MRG_AXI_AWLOCK      , -- Out :
            AXI_AWCACHE         => MRG_AXI_AWCACHE     , -- Out :
            AXI_AWPROT          => MRG_AXI_AWPROT      , -- Out :
            AXI_AWQOS           => MRG_AXI_AWQOS       , -- Out :
            AXI_AWREGION        => MRG_AXI_AWREGION    , -- Out :
            AXI_AWUSER          => MRG_AXI_AWUSER      , -- Out :
            AXI_AWVALID         => MRG_AXI_AWVALID     , -- Out :
            AXI_AWREADY         => MRG_AXI_AWREADY     , -- In  :
        ---------------------------------------------------------------------------
        -- AXI Master Write Data Channel Signals.
        ---------------------------------------------------------------------------
            AXI_WID             => MRG_AXI_WID         , -- Out :
            AXI_WDATA           => MRG_AXI_WDATA       , -- Out :
            AXI_WSTRB           => MRG_AXI_WSTRB       , -- Out :
            AXI_WUSER           => MRG_AXI_WUSER       , -- Out :
            AXI_WLAST           => MRG_AXI_WLAST       , -- Out :
            AXI_WVALID          => MRG_AXI_WVALID      , -- Out :
            AXI_WREADY          => MRG_AXI_WREADY      , -- In  :
        ---------------------------------------------------------------------------
        -- AXI Write Response Channel Signals.
        ---------------------------------------------------------------------------
            AXI_BID             => MRG_AXI_BID         , -- In  :
            AXI_BRESP           => MRG_AXI_BRESP       , -- In  :
            AXI_BUSER           => MRG_AXI_BUSER       , -- In  :
            AXI_BVALID          => MRG_AXI_BVALID      , -- In  :
            AXI_BREADY          => MRG_AXI_BREADY      , -- Out :
        ---------------------------------------------------------------------------
        -- Merge Writer Control Register Interface.
        ---------------------------------------------------------------------------
            MRG_REG_L           => mrg_wr_reg_load     , -- In  :
            MRG_REG_D           => mrg_wr_reg_wbit     , -- In  :
            MRG_REG_Q           => mrg_wr_reg_rbit     , -- Out :
        ---------------------------------------------------------------------------
        -- Merge Intake Signals.
        ---------------------------------------------------------------------------
            MRG_DATA            => MERGED_DATA         , -- In  :
            MRG_STRB            => MERGED_STRB         , -- In  :
            MRG_LAST            => MERGED_LAST         , -- In  :
            MRG_VALID           => mrg_wr_valid        , -- In  :
            MRG_READY           => mrg_wr_ready        , -- Out :
        ---------------------------------------------------------------------------
        -- Status Output.
        ---------------------------------------------------------------------------
            BUSY                => mrg_wr_busy         , -- Out :
            DONE                => mrg_wr_done           -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    stm_wr_valid <= '1' when (stm_wr_busy = '1' and MERGED_VALID = '1') else '0';
    mrg_wr_valid <= '1' when (mrg_wr_busy = '1' and MERGED_VALID = '1') else '0';
    MERGED_READY <= '1' when (stm_wr_busy = '1' and stm_wr_ready = '1') or
                             (mrg_wr_busy = '1' and mrg_wr_ready = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    CTRL: Interface_Controller                           -- 
        generic map (                                    -- 
            WAYS                => WAYS                , --
            WORDS               => WORDS               , --
            WORD_BITS           => WORD_BITS           , --
            STM_FEEDBACK        => STM_FEEDBACK        , --
            STM_RD_DATA_BITS    => STM_RD_DATA_BITS    , --
            STM_WR_DATA_BITS    => STM_WR_DATA_BITS    , --
            REG_RW_ADDR_BITS    => REG_RW_ADDR_BITS    , --
            REG_RW_MODE_BITS    => REG_RW_MODE_BITS    , --
            REG_SIZE_BITS       => REG_SIZE_BITS       , --
            REG_MODE_BITS       => REG_MODE_BITS       , --
            REG_STAT_BITS       => REG_STAT_BITS       , --
            REG_COUNT_BITS      => REG_COUNT_BITS      , --
            MRG_RD_REG_PARAM    => MRG_RD_REG_PARAM    , --
            MRG_WR_REG_PARAM    => MRG_WR_REG_PARAM    , --
            STM_RD_REG_PARAM    => STM_RD_REG_PARAM    , --
            STM_WR_REG_PARAM    => STM_WR_REG_PARAM    , --
            STM_RD_ADDR_VALID   => STM_RD_ADDR_VALID   , --
            STM_WR_ADDR_VALID   => STM_WR_ADDR_VALID   , --
            MRG_RD_PRE_STATE    => MRG_RD_PRE_STATE    , --
            DEBUG_ENABLE        => DEBUG_ENABLE        , -- 
            DEBUG_SIZE          => DEBUG_SIZE          , --
            DEBUG_BITS          => DEBUG_BITS          , --
            DEBUG_COUNT_BITS    => DEBUG_COUNT_BITS      -- 
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        -- Clock/Reset Signals.
        ---------------------------------------------------------------------------
            CLK                 => CLK                 , -- In  :
            RST                 => RST                 , -- In  :
            CLR                 => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- Register Interface
        ---------------------------------------------------------------------------
            REG_RD_ADDR_L       => REG_RD_ADDR_L       , -- In  :
            REG_RD_ADDR_D       => REG_RD_ADDR_D       , -- In  :
            REG_RD_ADDR_Q       => REG_RD_ADDR_Q       , -- Out :
            REG_WR_ADDR_L       => REG_WR_ADDR_L       , -- In  :
            REG_WR_ADDR_D       => REG_WR_ADDR_D       , -- In  :
            REG_WR_ADDR_Q       => REG_WR_ADDR_Q       , -- Out :
            REG_T0_ADDR_L       => REG_T0_ADDR_L       , -- In  :
            REG_T0_ADDR_D       => REG_T0_ADDR_D       , -- In  :
            REG_T0_ADDR_Q       => REG_T0_ADDR_Q       , -- Out :
            REG_T1_ADDR_L       => REG_T1_ADDR_L       , -- In  :
            REG_T1_ADDR_D       => REG_T1_ADDR_D       , -- In  :
            REG_T1_ADDR_Q       => REG_T1_ADDR_Q       , -- Out :
            REG_RD_MODE_L       => REG_RD_MODE_L       , -- In  :
            REG_RD_MODE_D       => REG_RD_MODE_D       , -- In  :
            REG_RD_MODE_Q       => REG_RD_MODE_Q       , -- Out :
            REG_WR_MODE_L       => REG_WR_MODE_L       , -- In  :
            REG_WR_MODE_D       => REG_WR_MODE_D       , -- In  :
            REG_WR_MODE_Q       => REG_WR_MODE_Q       , -- Out :
            REG_T0_MODE_L       => REG_T0_MODE_L       , -- In  :
            REG_T0_MODE_D       => REG_T0_MODE_D       , -- In  :
            REG_T0_MODE_Q       => REG_T0_MODE_Q       , -- Out :
            REG_T1_MODE_L       => REG_T1_MODE_L       , -- In  :
            REG_T1_MODE_D       => REG_T1_MODE_D       , -- In  :
            REG_T1_MODE_Q       => REG_T1_MODE_Q       , -- Out :
            REG_SIZE_L          => REG_SIZE_L          , -- In  :
            REG_SIZE_D          => REG_SIZE_D          , -- In  :
            REG_SIZE_Q          => REG_SIZE_Q          , -- Out :
            REG_START_L         => REG_START_L         , -- In  :
            REG_START_D         => REG_START_D         , -- In  :
            REG_START_Q         => REG_START_Q         , -- Out :
            REG_RESET_L         => REG_RESET_L         , -- In  :
            REG_RESET_D         => REG_RESET_D         , -- In  :
            REG_RESET_Q         => REG_RESET_Q         , -- Out :
            REG_DONE_EN_L       => REG_DONE_EN_L       , -- In  :
            REG_DONE_EN_D       => REG_DONE_EN_D       , -- In  :
            REG_DONE_EN_Q       => REG_DONE_EN_Q       , -- Out :
            REG_DONE_ST_L       => REG_DONE_ST_L       , -- In  :
            REG_DONE_ST_D       => REG_DONE_ST_D       , -- In  :
            REG_DONE_ST_Q       => REG_DONE_ST_Q       , -- Out :
            REG_ERR_ST_L        => REG_ERR_ST_L        , -- In  :
            REG_ERR_ST_D        => REG_ERR_ST_D        , -- In  :
            REG_ERR_ST_Q        => REG_ERR_ST_Q        , -- Out :
            REG_MODE_L          => REG_MODE_L          , -- In  :
            REG_MODE_D          => REG_MODE_D          , -- In  :
            REG_MODE_Q          => REG_MODE_Q          , -- Out :
            REG_STAT_L          => REG_STAT_L          , -- In  :
            REG_STAT_D          => REG_STAT_D          , -- In  :
            REG_STAT_Q          => REG_STAT_Q          , -- Out :
            REG_STAT_I          => REG_STAT_I          , -- In  :
            REG_COUNT_L         => REG_COUNT_L         , -- In  :
            REG_COUNT_D         => REG_COUNT_D         , -- In  :
            REG_COUNT_Q         => REG_COUNT_Q         , -- Out :
        ---------------------------------------------------------------------------
        -- Debug Interface
        ---------------------------------------------------------------------------
            DEBUG_MODE          => DEBUG_MODE          , -- In  :
            DEBUG_DATA          => DEBUG_DATA          , -- Out :
        ---------------------------------------------------------------------------
        -- Merge Sorter Core Control Interface
        ---------------------------------------------------------------------------
            STM_REQ_VALID       => STM_REQ_VALID       , -- Out :
            STM_REQ_READY       => STM_REQ_READY       , -- In  :
            STM_RES_VALID       => STM_RES_VALID       , -- In  :
            STM_RES_READY       => STM_RES_READY       , -- Out :
            MRG_REQ_VALID       => MRG_REQ_VALID       , -- Out :
            MRG_REQ_READY       => MRG_REQ_READY       , -- In  :
            MRG_RES_VALID       => MRG_RES_VALID       , -- In  :
            MRG_RES_READY       => MRG_RES_READY       , -- Out :
        ---------------------------------------------------------------------------
        -- Stream Reader Control Register Interface
        ---------------------------------------------------------------------------
            STM_RD_REG_L        => stm_rd_reg_load     , -- Out :
            STM_RD_REG_D        => stm_rd_reg_wbit     , -- Out :
            STM_RD_REG_Q        => stm_rd_reg_rbit     , -- In  :
            STM_RD_BUSY         => stm_rd_busy         , -- In  :
            STM_RD_DONE         => stm_rd_done         , -- In  :
        ---------------------------------------------------------------------------
        -- Stream Writer Control Register Interface
        ---------------------------------------------------------------------------
            STM_WR_REG_L        => stm_wr_reg_load     , -- Out :
            STM_WR_REG_D        => stm_wr_reg_wbit     , -- Out :
            STM_WR_REG_Q        => stm_wr_reg_rbit     , -- In  :
            STM_WR_BUSY         => stm_wr_busy         , -- In  :
            STM_WR_DONE         => stm_wr_done         , -- In  :
        ---------------------------------------------------------------------------
        -- Merge Reader Control Register Interface
        ---------------------------------------------------------------------------
            MRG_RD_REG_L        => mrg_rd_reg_load     , -- Out :
            MRG_RD_REG_D        => mrg_rd_reg_wbit     , -- Out :
            MRG_RD_REG_Q        => mrg_rd_reg_rbit     , -- In  :
            MRG_RD_BUSY         => mrg_rd_busy         , -- In  :
            MRG_RD_DONE         => mrg_rd_done         , -- In  :
        ---------------------------------------------------------------------------
        -- Merge Writer Control Register Interface
        ---------------------------------------------------------------------------
            MRG_WR_REG_L        => mrg_wr_reg_load     , -- Out :
            MRG_WR_REG_D        => mrg_wr_reg_wbit     , -- Out :
            MRG_WR_REG_Q        => mrg_wr_reg_rbit     , -- In  :
            MRG_WR_BUSY         => mrg_wr_busy         , -- In  :
            MRG_WR_DONE         => mrg_wr_done           -- In  :
    );
end RTL;
