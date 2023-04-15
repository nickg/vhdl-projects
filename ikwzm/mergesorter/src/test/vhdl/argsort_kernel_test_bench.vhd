-----------------------------------------------------------------------------------
--!     @file    argsort_kernel_test_bench.vhd
--!     @brief   Merge Sorter ArgSort Xilinx RTL Kernel Test Bench :
--!     @version 1.2.0
--!     @date    2021/6/28
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2021 Ichiro Kawazome
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
entity  ArgSort_Kernel_Test_Bench is
    generic (
        NAME            :  STRING  := "TEST";
        SCENARIO_FILE   :  STRING  := "test.snr";
        AXI_ADDR_WIDTH  :  integer := 32;
        AXI_DATA_WIDTH  :  integer := 64;
        AXI_XFER_SIZE   :  integer := 12;
        AXI_REQ_QUEUE   :  integer := 12;
        MRG_WAYS        :  integer :=  4;
        MRG_WORDS       :  integer :=  1;
        STM_FEEDBACK    :  integer :=  1;
        STM_IN_QUEUE    :  integer :=  0;
        WORD_BITS       :  integer := 32;
        INDEX_BITS      :  integer := 32;
        SORT_SIZE_BITS  :  integer := 32;
        MRG_RD_PRE_STATE:  integer :=  0;
        DEBUG_ENABLE    :  integer range 0 to 1 := 1;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_Kernel_Test_Bench;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library Merge_Sorter;
use     Merge_Sorter.ArgSort_AXI_Components.ArgSort_Kernel;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_MEMORY_PLAYER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
architecture Model of ArgSort_Kernel_Test_Bench is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant  PERIOD            :  time    := 10 ns;
    constant  DELAY             :  time    :=  1 ns;
    constant  SYNC_WIDTH        :  integer :=  2;
    constant  GPO_WIDTH         :  integer :=  8;
    constant  GPI_WIDTH         :  integer :=  GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal    ACLK              :  std_logic;
    signal    ARESETn           :  std_logic;
    signal    RESET             :  std_logic;
    constant  CLEAR             :  std_logic := '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  CSR_WIDTH         :  AXI4_SIGNAL_WIDTH_TYPE := (
                                       ID          => 4,
                                       AWADDR      => AXI_ADDR_WIDTH,
                                       ARADDR      => AXI_ADDR_WIDTH,
                                       ALEN        => AXI4_ALEN_WIDTH,
                                       ALOCK       => AXI4_ALOCK_WIDTH,
                                       WDATA       => 32,
                                       RDATA       => 32,
                                       ARUSER      => 1,
                                       AWUSER      => 1,
                                       WUSER       => 1,
                                       RUSER       => 1,
                                       BUSER       => 1
                                   );
    signal    csr_araddr        :  std_logic_vector(CSR_WIDTH.ARADDR -1 downto 0);
    signal    csr_arwrite       :  std_logic;
    signal    csr_arlen         :  std_logic_vector(CSR_WIDTH.ALEN   -1 downto 0);
    signal    csr_arsize        :  AXI4_ASIZE_TYPE;
    signal    csr_arburst       :  AXI4_ABURST_TYPE;
    signal    csr_arlock        :  std_logic_vector(CSR_WIDTH.ALOCK  -1 downto 0);
    signal    csr_arcache       :  AXI4_ACACHE_TYPE;
    signal    csr_arprot        :  AXI4_APROT_TYPE;
    signal    csr_arqos         :  AXI4_AQOS_TYPE;
    signal    csr_arregion      :  AXI4_AREGION_TYPE;
    signal    csr_aruser        :  std_logic_vector(CSR_WIDTH.ARUSER -1 downto 0);
    signal    csr_arid          :  std_logic_vector(CSR_WIDTH.ID     -1 downto 0);
    signal    csr_arvalid       :  std_logic;
    signal    csr_arready       :  std_logic;
    signal    csr_rvalid        :  std_logic;
    constant  csr_rlast         :  std_logic := '1';
    signal    csr_rdata         :  std_logic_vector(CSR_WIDTH.RDATA  -1 downto 0);
    signal    csr_rresp         :  AXI4_RESP_TYPE;
    constant  csr_ruser         :  std_logic_vector(CSR_WIDTH.RUSER  -1 downto 0) := (others => '0');
    constant  csr_rid           :  std_logic_vector(CSR_WIDTH.ID     -1 downto 0) := (others => '0');
    signal    csr_rready        :  std_logic;
    signal    csr_awaddr        :  std_logic_vector(CSR_WIDTH.AWADDR -1 downto 0);
    signal    csr_awlen         :  std_logic_vector(CSR_WIDTH.ALEN   -1 downto 0);
    signal    csr_awsize        :  AXI4_ASIZE_TYPE;
    signal    csr_awburst       :  AXI4_ABURST_TYPE;
    signal    csr_awlock        :  std_logic_vector(CSR_WIDTH.ALOCK  -1 downto 0);
    signal    csr_awcache       :  AXI4_ACACHE_TYPE;
    signal    csr_awprot        :  AXI4_APROT_TYPE;
    signal    csr_awqos         :  AXI4_AQOS_TYPE;
    signal    csr_awregion      :  AXI4_AREGION_TYPE;
    signal    csr_awuser        :  std_logic_vector(CSR_WIDTH.AWUSER -1 downto 0);
    signal    csr_awid          :  std_logic_vector(CSR_WIDTH.ID     -1 downto 0);
    signal    csr_awvalid       :  std_logic;
    signal    csr_awready       :  std_logic;
    signal    csr_wlast         :  std_logic;
    signal    csr_wdata         :  std_logic_vector(CSR_WIDTH.WDATA  -1 downto 0);
    signal    csr_wstrb         :  std_logic_vector(CSR_WIDTH.WDATA/8-1 downto 0);
    signal    csr_wuser         :  std_logic_vector(CSR_WIDTH.WUSER  -1 downto 0);
    signal    csr_wid           :  std_logic_vector(CSR_WIDTH.ID     -1 downto 0);
    signal    csr_wvalid        :  std_logic;
    signal    csr_wready        :  std_logic;
    signal    csr_bresp         :  AXI4_RESP_TYPE;
    constant  csr_buser         :  std_logic_vector(CSR_WIDTH.BUSER  -1 downto 0) := (others => '0');
    constant  csr_bid           :  std_logic_vector(CSR_WIDTH.ID     -1 downto 0) := (others => '0');
    signal    csr_bvalid        :  std_logic;
    signal    csr_bready        :  std_logic;
    signal    interrupt         :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  STM_MEMORY_SIZE   :  integer := 32*1024;
    constant  STM_AXI_ID_BASE   :  integer := 0;
    constant  STM_AXI_WIDTH     :  AXI4_SIGNAL_WIDTH_TYPE := (
                                       ID          => 4,
                                       AWADDR      => AXI_ADDR_WIDTH,
                                       ARADDR      => AXI_ADDR_WIDTH,
                                       ALEN        => AXI4_ALEN_WIDTH,
                                       ALOCK       => AXI4_ALOCK_WIDTH,
                                       WDATA       => AXI_DATA_WIDTH,
                                       RDATA       => AXI_DATA_WIDTH,
                                       ARUSER      => 1,
                                       AWUSER      => 1,
                                       WUSER       => 1,
                                       RUSER       => 1,
                                       BUSER       => 1
                                  );
    signal    stm_axi_araddr    :  std_logic_vector(STM_AXI_WIDTH.ARADDR -1 downto 0);
    signal    stm_axi_arlen     :  std_logic_vector(STM_AXI_WIDTH.ALEN   -1 downto 0);
    signal    stm_axi_arsize    :  AXI4_ASIZE_TYPE;
    signal    stm_axi_arburst   :  AXI4_ABURST_TYPE;
    signal    stm_axi_arlock    :  std_logic_vector(STM_AXI_WIDTH.ALOCK  -1 downto 0);
    signal    stm_axi_arcache   :  AXI4_ACACHE_TYPE;
    signal    stm_axi_arprot    :  AXI4_APROT_TYPE;
    signal    stm_axi_arqos     :  AXI4_AQOS_TYPE;
    signal    stm_axi_arregion  :  AXI4_AREGION_TYPE;
    signal    stm_axi_aruser    :  std_logic_vector(STM_AXI_WIDTH.ARUSER -1 downto 0);
    signal    stm_axi_arid      :  std_logic_vector(STM_AXI_WIDTH.ID     -1 downto 0);
    signal    stm_axi_arvalid   :  std_logic;
    signal    stm_axi_arready   :  std_logic;
    signal    stm_axi_rvalid    :  std_logic;
    signal    stm_axi_rlast     :  std_logic;
    signal    stm_axi_rdata     :  std_logic_vector(STM_AXI_WIDTH.RDATA  -1 downto 0);
    signal    stm_axi_rresp     :  AXI4_RESP_TYPE;
    signal    stm_axi_ruser     :  std_logic_vector(STM_AXI_WIDTH.RUSER  -1 downto 0);
    signal    stm_axi_rid       :  std_logic_vector(STM_AXI_WIDTH.ID     -1 downto 0);
    signal    stm_axi_rready    :  std_logic;
    signal    stm_axi_awaddr    :  std_logic_vector(STM_AXI_WIDTH.AWADDR -1 downto 0);
    signal    stm_axi_awlen     :  std_logic_vector(STM_AXI_WIDTH.ALEN   -1 downto 0);
    signal    stm_axi_awsize    :  AXI4_ASIZE_TYPE;
    signal    stm_axi_awburst   :  AXI4_ABURST_TYPE;
    signal    stm_axi_awlock    :  std_logic_vector(STM_AXI_WIDTH.ALOCK  -1 downto 0);
    signal    stm_axi_awcache   :  AXI4_ACACHE_TYPE;
    signal    stm_axi_awprot    :  AXI4_APROT_TYPE;
    signal    stm_axi_awqos     :  AXI4_AQOS_TYPE;
    signal    stm_axi_awregion  :  AXI4_AREGION_TYPE;
    signal    stm_axi_awuser    :  std_logic_vector(STM_AXI_WIDTH.AWUSER -1 downto 0);
    signal    stm_axi_awid      :  std_logic_vector(STM_AXI_WIDTH.ID     -1 downto 0);
    signal    stm_axi_awvalid   :  std_logic;
    signal    stm_axi_awready   :  std_logic;
    signal    stm_axi_wlast     :  std_logic;
    signal    stm_axi_wdata     :  std_logic_vector(STM_AXI_WIDTH.WDATA  -1 downto 0);
    signal    stm_axi_wstrb     :  std_logic_vector(STM_AXI_WIDTH.WDATA/8-1 downto 0);
    signal    stm_axi_wuser     :  std_logic_vector(STM_AXI_WIDTH.WUSER  -1 downto 0);
    signal    stm_axi_wid       :  std_logic_vector(STM_AXI_WIDTH.ID     -1 downto 0);
    signal    stm_axi_wvalid    :  std_logic;
    signal    stm_axi_wready    :  std_logic;
    signal    stm_axi_bresp     :  AXI4_RESP_TYPE;
    signal    stm_axi_buser     :  std_logic_vector(STM_AXI_WIDTH.BUSER  -1 downto 0);
    signal    stm_axi_bid       :  std_logic_vector(STM_AXI_WIDTH.ID     -1 downto 0);
    signal    stm_axi_bvalid    :  std_logic;
    signal    stm_axi_bready    :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  MRG_MEMORY_SIZE   :  integer := 32*1024;
    constant  MRG_AXI_ID_BASE   :  integer := 2;
    constant  MRG_AXI_WIDTH     :  AXI4_SIGNAL_WIDTH_TYPE := (
                                       ID          => 4,
                                       AWADDR      => AXI_ADDR_WIDTH,
                                       ARADDR      => AXI_ADDR_WIDTH,
                                       ALEN        => AXI4_ALEN_WIDTH,
                                       ALOCK       => AXI4_ALOCK_WIDTH,
                                       WDATA       => AXI_DATA_WIDTH,
                                       RDATA       => AXI_DATA_WIDTH,
                                       ARUSER      => 1,
                                       AWUSER      => 1,
                                       WUSER       => 1,
                                       RUSER       => 1,
                                       BUSER       => 1
                                  );
    signal    mrg_axi_araddr    :  std_logic_vector(MRG_AXI_WIDTH.ARADDR -1 downto 0);
    signal    mrg_axi_arlen     :  std_logic_vector(MRG_AXI_WIDTH.ALEN   -1 downto 0);
    signal    mrg_axi_arsize    :  AXI4_ASIZE_TYPE;
    signal    mrg_axi_arburst   :  AXI4_ABURST_TYPE;
    signal    mrg_axi_arlock    :  std_logic_vector(MRG_AXI_WIDTH.ALOCK  -1 downto 0);
    signal    mrg_axi_arcache   :  AXI4_ACACHE_TYPE;
    signal    mrg_axi_arprot    :  AXI4_APROT_TYPE;
    signal    mrg_axi_arqos     :  AXI4_AQOS_TYPE;
    signal    mrg_axi_arregion  :  AXI4_AREGION_TYPE;
    signal    mrg_axi_aruser    :  std_logic_vector(MRG_AXI_WIDTH.ARUSER -1 downto 0);
    signal    mrg_axi_arid      :  std_logic_vector(MRG_AXI_WIDTH.ID     -1 downto 0);
    signal    mrg_axi_arvalid   :  std_logic;
    signal    mrg_axi_arready   :  std_logic;
    signal    mrg_axi_rvalid    :  std_logic;
    signal    mrg_axi_rlast     :  std_logic;
    signal    mrg_axi_rdata     :  std_logic_vector(MRG_AXI_WIDTH.RDATA  -1 downto 0);
    signal    mrg_axi_rresp     :  AXI4_RESP_TYPE;
    signal    mrg_axi_ruser     :  std_logic_vector(MRG_AXI_WIDTH.RUSER  -1 downto 0);
    signal    mrg_axi_rid       :  std_logic_vector(MRG_AXI_WIDTH.ID     -1 downto 0);
    signal    mrg_axi_rready    :  std_logic;
    signal    mrg_axi_awaddr    :  std_logic_vector(MRG_AXI_WIDTH.AWADDR -1 downto 0);
    signal    mrg_axi_awlen     :  std_logic_vector(MRG_AXI_WIDTH.ALEN   -1 downto 0);
    signal    mrg_axi_awsize    :  AXI4_ASIZE_TYPE;
    signal    mrg_axi_awburst   :  AXI4_ABURST_TYPE;
    signal    mrg_axi_awlock    :  std_logic_vector(MRG_AXI_WIDTH.ALOCK  -1 downto 0);
    signal    mrg_axi_awcache   :  AXI4_ACACHE_TYPE;
    signal    mrg_axi_awprot    :  AXI4_APROT_TYPE;
    signal    mrg_axi_awqos     :  AXI4_AQOS_TYPE;
    signal    mrg_axi_awregion  :  AXI4_AREGION_TYPE;
    signal    mrg_axi_awuser    :  std_logic_vector(MRG_AXI_WIDTH.AWUSER -1 downto 0);
    signal    mrg_axi_awid      :  std_logic_vector(MRG_AXI_WIDTH.ID     -1 downto 0);
    signal    mrg_axi_awvalid   :  std_logic;
    signal    mrg_axi_awready   :  std_logic;
    signal    mrg_axi_wlast     :  std_logic;
    signal    mrg_axi_wdata     :  std_logic_vector(MRG_AXI_WIDTH.WDATA  -1 downto 0);
    signal    mrg_axi_wstrb     :  std_logic_vector(MRG_AXI_WIDTH.WDATA/8-1 downto 0);
    signal    mrg_axi_wuser     :  std_logic_vector(MRG_AXI_WIDTH.WUSER  -1 downto 0);
    signal    mrg_axi_wid       :  std_logic_vector(MRG_AXI_WIDTH.ID     -1 downto 0);
    signal    mrg_axi_wvalid    :  std_logic;
    signal    mrg_axi_wready    :  std_logic;
    signal    mrg_axi_bresp     :  AXI4_RESP_TYPE;
    signal    mrg_axi_buser     :  std_logic_vector(MRG_AXI_WIDTH.BUSER  -1 downto 0);
    signal    mrg_axi_bid       :  std_logic_vector(MRG_AXI_WIDTH.ID     -1 downto 0);
    signal    mrg_axi_bvalid    :  std_logic;
    signal    mrg_axi_bready    :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    SYNC              :  SYNC_SIG_VECTOR (SYNC_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    csr_gpi           :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    csr_gpo           :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    stm_axi_gpi       :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    stm_axi_gpo       :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    mrg_axi_gpi       :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    mrg_axi_gpo       :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    N_REPORT          :  REPORT_STATUS_TYPE;
    signal    CSR_REPORT        :  REPORT_STATUS_TYPE;
    signal    STM_AXI_REPORT    :  REPORT_STATUS_TYPE;
    signal    MRG_AXI_REPORT    :  REPORT_STATUS_TYPE;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    N_FINISH          :  std_logic;
    signal    CSR_FINISH        :  std_logic;
    signal    STM_AXI_FINISH    :  std_logic;
    signal    MRG_AXI_FINISH    :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    DUT:  ArgSort_Kernel                                 -- 
        generic map (
            MRG_WAYS                    => MRG_WAYS            ,
            MRG_WORDS                   => MRG_WORDS           ,
            WORD_BITS                   => WORD_BITS           , 
            INDEX_BITS                  => INDEX_BITS          ,
            COMP_SIGN                   => TRUE                ,
            SORT_ORDER                  => 0                   ,
            SORT_SIZE_BITS              => SORT_SIZE_BITS      ,
            MRG_FIFO_SIZE               => 0                   ,
            MRG_RD_PRE_STATE            => MRG_RD_PRE_STATE    ,
            STM_FEEDBACK                => STM_FEEDBACK        ,
            STM_IN_QUEUE_SIZE           => STM_IN_QUEUE        ,
            C_S_AXI_CONTROL_ADDR_WIDTH  => CSR_WIDTH.ARADDR    ,
            C_S_AXI_CONTROL_DATA_WIDTH  => CSR_WIDTH.RDATA     ,
            C_M_AXI_STM_ADDR_WIDTH      => STM_AXI_WIDTH.ARADDR,
            C_M_AXI_STM_DATA_WIDTH      => STM_AXI_WIDTH.RDATA ,
            C_M_AXI_STM_ARUSER_WIDTH    => STM_AXI_WIDTH.ARUSER, -- 
            C_M_AXI_STM_AWUSER_WIDTH    => STM_AXI_WIDTH.AWUSER, -- 
            C_M_AXI_STM_RUSER_WIDTH     => STM_AXI_WIDTH.RUSER , -- 
            C_M_AXI_STM_WUSER_WIDTH     => STM_AXI_WIDTH.WUSER , -- 
            C_M_AXI_STM_BUSER_WIDTH     => STM_AXI_WIDTH.BUSER , -- 
            C_M_AXI_STM_ID_WIDTH        => STM_AXI_WIDTH.ID    , -- 
            C_M_AXI_STM_ID_BASE         => STM_AXI_ID_BASE     , -- 
            C_M_AXI_STM_RD_XFER_SIZE    => AXI_XFER_SIZE       , -- 
            C_M_AXI_STM_WR_XFER_SIZE    => AXI_XFER_SIZE       , -- 
            C_M_AXI_MRG_ADDR_WIDTH      => MRG_AXI_WIDTH.ARADDR, -- 
            C_M_AXI_MRG_DATA_WIDTH      => MRG_AXI_WIDTH.RDATA , -- 
            C_M_AXI_MRG_ARUSER_WIDTH    => MRG_AXI_WIDTH.ARUSER, -- 
            C_M_AXI_MRG_AWUSER_WIDTH    => MRG_AXI_WIDTH.ARUSER, -- 
            C_M_AXI_MRG_RUSER_WIDTH     => MRG_AXI_WIDTH.RUSER , -- 
            C_M_AXI_MRG_WUSER_WIDTH     => MRG_AXI_WIDTH.WUSER , -- 
            C_M_AXI_MRG_BUSER_WIDTH     => MRG_AXI_WIDTH.BUSER , -- 
            C_M_AXI_MRG_ID_WIDTH        => MRG_AXI_WIDTH.ID    , -- 
            C_M_AXI_MRG_ID_BASE         => MRG_AXI_ID_BASE     , -- 
            C_M_AXI_MRG_RD_XFER_SIZE    => AXI_XFER_SIZE       , -- 
            C_M_AXI_MRG_WR_XFER_SIZE    => AXI_XFER_SIZE       , --
            DEBUG_ENABLE                => DEBUG_ENABLE          -- 
        )                                                        -- 
        port map (                                               -- 
        ---------------------------------------------------------------------------
        -- Clock/Reset Signals.
        ---------------------------------------------------------------------------
            AP_CLK                      => ACLK                , -- In  :
            AP_RST_N                    => ARESETn             , -- In  :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            S_AXI_CONTROL_ARADDR        => csr_araddr          , -- in  :
            S_AXI_CONTROL_ARVALID       => csr_arvalid         , -- in  :
            S_AXI_CONTROL_ARREADY       => csr_arready         , -- out :
        ------------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Data Channel Signals.
        ------------------------------------------------------------------------------
            S_AXI_CONTROL_RDATA         => csr_rdata           , -- out :
            S_AXI_CONTROL_RRESP         => csr_rresp           , -- out :
            S_AXI_CONTROL_RVALID        => csr_rvalid          , -- out :
            S_AXI_CONTROL_RREADY        => csr_rready          , -- in  :
        ------------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Address Channel Signals.
        ------------------------------------------------------------------------------
            S_AXI_CONTROL_AWADDR        => csr_awaddr          , -- in  :
            S_AXI_CONTROL_AWVALID       => csr_awvalid         , -- in  :
            S_AXI_CONTROL_AWREADY       => csr_awready         , -- out :
        ------------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Data Channel Signals.
        ------------------------------------------------------------------------------
            S_AXI_CONTROL_WDATA         => csr_wdata           , -- in  :
            S_AXI_CONTROL_WSTRB         => csr_wstrb           , -- in  :
            S_AXI_CONTROL_WVALID        => csr_wvalid          , -- in  :
            S_AXI_CONTROL_WREADY        => csr_wready          , -- out :
        ------------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Response Channel Signals.
        ------------------------------------------------------------------------------
            S_AXI_CONTROL_BRESP         => csr_bresp           , -- out :
            S_AXI_CONTROL_BVALID        => csr_bvalid          , -- out :
            S_AXI_CONTROL_BREADY        => csr_bready          , -- in  :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Read Address Channel Signals.
        ---------------------------------------------------------------------------
            M_AXI_STM_ARID              => stm_axi_arid        , -- Out :
            M_AXI_STM_ARADDR            => stm_axi_araddr      , -- Out :
            M_AXI_STM_ARLEN             => stm_axi_arlen       , -- Out :
            M_AXI_STM_ARSIZE            => stm_axi_arsize      , -- Out :
            M_AXI_STM_ARBURST           => stm_axi_arburst     , -- Out :
            M_AXI_STM_ARLOCK            => stm_axi_arlock      , -- Out :
            M_AXI_STM_ARCACHE           => stm_axi_arcache     , -- Out :
            M_AXI_STM_ARPROT            => stm_axi_arprot      , -- Out :
            M_AXI_STM_ARQOS             => stm_axi_arqos       , -- Out :
            M_AXI_STM_ARREGION          => stm_axi_arregion    , -- Out :
            M_AXI_STM_ARUSER            => stm_axi_aruser      , -- Out :
            M_AXI_STM_ARVALID           => stm_axi_arvalid     , -- Out :
            M_AXI_STM_ARREADY           => stm_axi_arready     , -- In  :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Read Data Channel Signals.
        ---------------------------------------------------------------------------
            M_AXI_STM_RID               => stm_axi_rid         , -- In  :
            M_AXI_STM_RDATA             => stm_axi_rdata       , -- In  :
            M_AXI_STM_RRESP             => stm_axi_rresp       , -- In  :
            M_AXI_STM_RUSER             => stm_axi_ruser       , -- In  :
            M_AXI_STM_RLAST             => stm_axi_rlast       , -- In  :
            M_AXI_STM_RVALID            => stm_axi_rvalid      , -- In  :
            M_AXI_STM_RREADY            => stm_axi_rready      , -- Out :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Writer Address Channel Signals.
        ---------------------------------------------------------------------------
            M_AXI_STM_AWID              => stm_axi_awid        , -- Out :
            M_AXI_STM_AWADDR            => stm_axi_awaddr      , -- Out :
            M_AXI_STM_AWLEN             => stm_axi_awlen       , -- Out :
            M_AXI_STM_AWSIZE            => stm_axi_awsize      , -- Out :
            M_AXI_STM_AWBURST           => stm_axi_awburst     , -- Out :
            M_AXI_STM_AWLOCK            => stm_axi_awlock      , -- Out :
            M_AXI_STM_AWCACHE           => stm_axi_awcache     , -- Out :
            M_AXI_STM_AWPROT            => stm_axi_awprot      , -- Out :
            M_AXI_STM_AWQOS             => stm_axi_awqos       , -- Out :
            M_AXI_STM_AWREGION          => stm_axi_awregion    , -- Out :
            M_AXI_STM_AWUSER            => stm_axi_awuser      , -- Out :
            M_AXI_STM_AWVALID           => stm_axi_awvalid     , -- Out :
            M_AXI_STM_AWREADY           => stm_axi_awready     , -- In  :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Write Data Channel Signals.
        ---------------------------------------------------------------------------
            M_AXI_STM_WID               => stm_axi_wid         , -- Out :
            M_AXI_STM_WDATA             => stm_axi_wdata       , -- Out :
            M_AXI_STM_WSTRB             => stm_axi_wstrb       , -- Out :
            M_AXI_STM_WUSER             => stm_axi_wuser       , -- Out :
            M_AXI_STM_WLAST             => stm_axi_wlast       , -- Out :
            M_AXI_STM_WVALID            => stm_axi_wvalid      , -- Out :
            M_AXI_STM_WREADY            => stm_axi_wready      , -- In  :
        ---------------------------------------------------------------------------
        -- Stream AXI Write Response Channel Signals.
        ---------------------------------------------------------------------------
            M_AXI_STM_BID               => stm_axi_bid         , -- In  :
            M_AXI_STM_BRESP             => stm_axi_bresp       , -- In  :
            M_AXI_STM_BUSER             => stm_axi_buser       , -- In  :
            M_AXI_STM_BVALID            => stm_axi_bvalid      , -- In  :
            M_AXI_STM_BREADY            => stm_axi_bready      , -- Out :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Read Address Channel Signals.
        ---------------------------------------------------------------------------
            M_AXI_MRG_ARID              => mrg_axi_arid        , -- Out :
            M_AXI_MRG_ARADDR            => mrg_axi_araddr      , -- Out :
            M_AXI_MRG_ARLEN             => mrg_axi_arlen       , -- Out :
            M_AXI_MRG_ARSIZE            => mrg_axi_arsize      , -- Out :
            M_AXI_MRG_ARBURST           => mrg_axi_arburst     , -- Out :
            M_AXI_MRG_ARLOCK            => mrg_axi_arlock      , -- Out :
            M_AXI_MRG_ARCACHE           => mrg_axi_arcache     , -- Out :
            M_AXI_MRG_ARPROT            => mrg_axi_arprot      , -- Out :
            M_AXI_MRG_ARQOS             => mrg_axi_arqos       , -- Out :
            M_AXI_MRG_ARREGION          => mrg_axi_arregion    , -- Out :
            M_AXI_MRG_ARUSER            => mrg_axi_aruser      , -- Out :
            M_AXI_MRG_ARVALID           => mrg_axi_arvalid     , -- Out :
            M_AXI_MRG_ARREADY           => mrg_axi_arready     , -- In  :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Read Data Channel Signals.
        ---------------------------------------------------------------------------
            M_AXI_MRG_RID               => mrg_axi_rid         , -- In  :
            M_AXI_MRG_RDATA             => mrg_axi_rdata       , -- In  :
            M_AXI_MRG_RRESP             => mrg_axi_rresp       , -- In  :
            M_AXI_MRG_RUSER             => mrg_axi_ruser       , -- In  :
            M_AXI_MRG_RLAST             => mrg_axi_rlast       , -- In  :
            M_AXI_MRG_RVALID            => mrg_axi_rvalid      , -- In  :
            M_AXI_MRG_RREADY            => mrg_axi_rready      , -- Out :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Writer Address Channel Signals.
        ---------------------------------------------------------------------------
            M_AXI_MRG_AWID              => mrg_axi_awid        , -- Out :
            M_AXI_MRG_AWADDR            => mrg_axi_awaddr      , -- Out :
            M_AXI_MRG_AWLEN             => mrg_axi_awlen       , -- Out :
            M_AXI_MRG_AWSIZE            => mrg_axi_awsize      , -- Out :
            M_AXI_MRG_AWBURST           => mrg_axi_awburst     , -- Out :
            M_AXI_MRG_AWLOCK            => mrg_axi_awlock      , -- Out :
            M_AXI_MRG_AWCACHE           => mrg_axi_awcache     , -- Out :
            M_AXI_MRG_AWPROT            => mrg_axi_awprot      , -- Out :
            M_AXI_MRG_AWQOS             => mrg_axi_awqos       , -- Out :
            M_AXI_MRG_AWREGION          => mrg_axi_awregion    , -- Out :
            M_AXI_MRG_AWUSER            => mrg_axi_awuser      , -- Out :
            M_AXI_MRG_AWVALID           => mrg_axi_awvalid     , -- Out :
            M_AXI_MRG_AWREADY           => mrg_axi_awready     , -- In  :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Write Data Channel Signals.
        ---------------------------------------------------------------------------
            M_AXI_MRG_WID               => mrg_axi_wid         , -- Out :
            M_AXI_MRG_WDATA             => mrg_axi_wdata       , -- Out :
            M_AXI_MRG_WSTRB             => mrg_axi_wstrb       , -- Out :
            M_AXI_MRG_WUSER             => mrg_axi_wuser       , -- Out :
            M_AXI_MRG_WLAST             => mrg_axi_wlast       , -- Out :
            M_AXI_MRG_WVALID            => mrg_axi_wvalid      , -- Out :
            M_AXI_MRG_WREADY            => mrg_axi_wready      , -- In  :
        ---------------------------------------------------------------------------
        -- Merge AXI Write Response Channel Signals.
        ---------------------------------------------------------------------------
            M_AXI_MRG_BID               => mrg_axi_bid         , -- In  :
            M_AXI_MRG_BRESP             => mrg_axi_bresp       , -- In  :
            M_AXI_MRG_BUSER             => mrg_axi_buser       , -- In  :
            M_AXI_MRG_BVALID            => mrg_axi_bvalid      , -- In  :
            M_AXI_MRG_BREADY            => mrg_axi_bready      , -- Out :
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
            interrupt                   => interrupt             -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL                                   -- 
        generic map(                             -- 
            SCENARIO_FILE   => SCENARIO_FILE,    -- 
            NAME            => "MARCHAL",        -- 
            SYNC_PLUG_NUM   => 1,                -- 
            SYNC_WIDTH      => SYNC_WIDTH,       -- 
            FINISH_ABORT    => FALSE             -- 
        )                                        -- 
        port map(                                -- 
            CLK             => ACLK            , -- In  :
            RESET           => RESET           , -- Out :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );                                       -- 
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    CSR: AXI4_MASTER_PLAYER                      -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , -- 
            NAME            => "CSR"           , -- 
            READ_ENABLE     => TRUE            , -- 
            WRITE_ENABLE    => TRUE            , -- 
            OUTPUT_DELAY    => DELAY           , -- 
            WIDTH           => CSR_WIDTH       , -- 
            SYNC_PLUG_NUM   => 2               , -- 
            SYNC_WIDTH      => SYNC_WIDTH      , -- 
            GPI_WIDTH       => GPI_WIDTH       , -- 
            GPO_WIDTH       => GPO_WIDTH       , -- 
            FINISH_ABORT    => FALSE             -- 
        )                                        -- 
        port map(                                -- 
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => csr_araddr      , -- I/O : 
            ARLEN           => csr_arlen       , -- I/O : 
            ARSIZE          => csr_arsize      , -- I/O : 
            ARBURST         => csr_arburst     , -- I/O : 
            ARLOCK          => csr_arlock      , -- I/O : 
            ARCACHE         => csr_arcache     , -- I/O : 
            ARPROT          => csr_arprot      , -- I/O : 
            ARQOS           => csr_arqos       , -- I/O : 
            ARREGION        => csr_arregion    , -- I/O : 
            ARUSER          => csr_aruser      , -- I/O : 
            ARID            => csr_arid        , -- I/O : 
            ARVALID         => csr_arvalid     , -- I/O : 
            ARREADY         => csr_arready     , -- In  :    
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => csr_rlast       , -- In  :    
            RDATA           => csr_rdata       , -- In  :    
            RRESP           => csr_rresp       , -- In  :    
            RUSER           => csr_ruser       , -- In  :    
            RID             => csr_rid         , -- In  :    
            RVALID          => csr_rvalid      , -- In  :    
            RREADY          => csr_rready      , -- I/O : 
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => csr_awaddr      , -- I/O : 
            AWLEN           => csr_awlen       , -- I/O : 
            AWSIZE          => csr_awsize      , -- I/O : 
            AWBURST         => csr_awburst     , -- I/O : 
            AWLOCK          => csr_awlock      , -- I/O : 
            AWCACHE         => csr_awcache     , -- I/O : 
            AWPROT          => csr_awprot      , -- I/O : 
            AWQOS           => csr_awqos       , -- I/O : 
            AWREGION        => csr_awregion    , -- I/O : 
            AWUSER          => csr_awuser      , -- I/O : 
            AWID            => csr_awid        , -- I/O : 
            AWVALID         => csr_awvalid     , -- I/O : 
            AWREADY         => csr_awready     , -- In  :    
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => csr_wlast       , -- I/O : 
            WDATA           => csr_wdata       , -- I/O : 
            WSTRB           => csr_wstrb       , -- I/O : 
            WUSER           => csr_wuser       , -- I/O : 
            WID             => csr_wid         , -- I/O : 
            WVALID          => csr_wvalid      , -- I/O : 
            WREADY          => csr_wready      , -- In  :    
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => csr_bresp       , -- In  :    
            BUSER           => csr_buser       , -- In  :    
            BID             => csr_bid         , -- In  :    
            BVALID          => csr_bvalid      , -- In  :    
            BREADY          => csr_bready      , -- I/O : 
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => csr_gpi         , -- In  :
            GPO             => csr_gpo         , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => CSR_REPORT      , -- Out :
            FINISH          => CSR_FINISH        -- Out :
       );
    csr_gpi(0) <= interrupt;
    csr_gpi(csr_gpi'high downto 1) <= (csr_gpi'high downto 1 => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    STM: AXI4_MEMORY_PLAYER                      -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , -- 
            NAME            => "STM"           , -- 
            READ_ENABLE     => TRUE            , -- 
            WRITE_ENABLE    => FALSE           , -- 
            OUTPUT_DELAY    => DELAY           , -- 
            WIDTH           => STM_AXI_WIDTH   , -- 
            SYNC_PLUG_NUM   => 3               , -- 
            SYNC_WIDTH      => SYNC_WIDTH      , -- 
            GPI_WIDTH       => GPI_WIDTH       , -- 
            GPO_WIDTH       => GPO_WIDTH       , --
            MEMORY_SIZE     => STM_MEMORY_SIZE , -- 
            FINISH_ABORT    => FALSE             -- 
        )                                        -- 
        port map(                                -- 
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => stm_axi_araddr  , -- In  :    
            ARLEN           => stm_axi_arlen   , -- In  :    
            ARSIZE          => stm_axi_arsize  , -- In  :    
            ARBURST         => stm_axi_arburst , -- In  :    
            ARLOCK          => stm_axi_arlock  , -- In  :    
            ARCACHE         => stm_axi_arcache , -- In  :    
            ARPROT          => stm_axi_arprot  , -- In  :    
            ARQOS           => stm_axi_arqos   , -- In  :    
            ARREGION        => stm_axi_arregion, -- In  :    
            ARUSER          => stm_axi_aruser  , -- In  :    
            ARID            => stm_axi_arid    , -- In  :    
            ARVALID         => stm_axi_arvalid , -- In  :    
            ARREADY         => stm_axi_arready , -- I/O : 
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => stm_axi_rlast   , -- I/O : 
            RDATA           => stm_axi_rdata   , -- I/O : 
            RRESP           => stm_axi_rresp   , -- I/O : 
            RUSER           => stm_axi_ruser   , -- I/O : 
            RID             => stm_axi_rid     , -- I/O : 
            RVALID          => stm_axi_rvalid  , -- I/O : 
            RREADY          => stm_axi_rready  , -- In  :    
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            AWADDR          => stm_axi_awaddr  , -- In  :    
            AWLEN           => stm_axi_awlen   , -- In  :    
            AWSIZE          => stm_axi_awsize  , -- In  :    
            AWBURST         => stm_axi_awburst , -- In  :    
            AWLOCK          => stm_axi_awlock  , -- In  :    
            AWCACHE         => stm_axi_awcache , -- In  :    
            AWPROT          => stm_axi_awprot  , -- In  :    
            AWQOS           => stm_axi_awqos   , -- In  :    
            AWREGION        => stm_axi_awregion, -- In  :    
            AWUSER          => stm_axi_awuser  , -- In  :    
            AWID            => stm_axi_awid    , -- In  :    
            AWVALID         => stm_axi_awvalid , -- In  :    
            AWREADY         => stm_axi_awready , -- I/O : 
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
            WLAST           => stm_axi_wlast   , -- In  :    
            WDATA           => stm_axi_wdata   , -- In  :    
            WSTRB           => stm_axi_wstrb   , -- In  :    
            WUSER           => stm_axi_wuser   , -- In  :    
            WID             => stm_axi_wid     , -- In  :    
            WVALID          => stm_axi_wvalid  , -- In  :    
            WREADY          => stm_axi_wready  , -- I/O : 
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => stm_axi_bresp   , -- I/O : 
            BUSER           => stm_axi_buser   , -- I/O : 
            BID             => stm_axi_bid     , -- I/O : 
            BVALID          => stm_axi_bvalid  , -- I/O : 
            BREADY          => stm_axi_bready  , -- In  :    
        ---------------------------------------------------------------------------
        -- シンクロ用信号
        ---------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => stm_axi_gpi     , -- In  :
            GPO             => stm_axi_gpo     , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => STM_AXI_REPORT  , -- Out :
            FINISH          => STM_AXI_FINISH    -- Out :
        );
    stm_axi_gpi(0) <= csr_gpo(0);
    stm_axi_gpi(stm_axi_gpi'high downto 1) <= (stm_axi_gpi'high downto 1 => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    MRG: AXI4_MEMORY_PLAYER                      -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , -- 
            NAME            => "MRG"           , -- 
            READ_ENABLE     => TRUE            , -- 
            WRITE_ENABLE    => FALSE           , -- 
            OUTPUT_DELAY    => DELAY           , -- 
            WIDTH           => MRG_AXI_WIDTH   , -- 
            SYNC_PLUG_NUM   => 4               , -- 
            SYNC_WIDTH      => SYNC_WIDTH      , -- 
            GPI_WIDTH       => GPI_WIDTH       , -- 
            GPO_WIDTH       => GPO_WIDTH       , -- 
            MEMORY_SIZE     => MRG_MEMORY_SIZE , -- 
            FINISH_ABORT    => FALSE             -- 
        )                                        -- 
        port map(                                -- 
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => mrg_axi_araddr  , -- In  :    
            ARLEN           => mrg_axi_arlen   , -- In  :    
            ARSIZE          => mrg_axi_arsize  , -- In  :    
            ARBURST         => mrg_axi_arburst , -- In  :    
            ARLOCK          => mrg_axi_arlock  , -- In  :    
            ARCACHE         => mrg_axi_arcache , -- In  :    
            ARPROT          => mrg_axi_arprot  , -- In  :    
            ARQOS           => mrg_axi_arqos   , -- In  :    
            ARREGION        => mrg_axi_arregion, -- In  :    
            ARUSER          => mrg_axi_aruser  , -- In  :    
            ARID            => mrg_axi_arid    , -- In  :    
            ARVALID         => mrg_axi_arvalid , -- In  :    
            ARREADY         => mrg_axi_arready , -- I/O : 
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => mrg_axi_rlast   , -- I/O : 
            RDATA           => mrg_axi_rdata   , -- I/O : 
            RRESP           => mrg_axi_rresp   , -- I/O : 
            RUSER           => mrg_axi_ruser   , -- I/O : 
            RID             => mrg_axi_rid     , -- I/O : 
            RVALID          => mrg_axi_rvalid  , -- I/O : 
            RREADY          => mrg_axi_rready  , -- In  :    
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            AWADDR          => mrg_axi_awaddr  , -- In  :    
            AWLEN           => mrg_axi_awlen   , -- In  :    
            AWSIZE          => mrg_axi_awsize  , -- In  :    
            AWBURST         => mrg_axi_awburst , -- In  :    
            AWLOCK          => mrg_axi_awlock  , -- In  :    
            AWCACHE         => mrg_axi_awcache , -- In  :    
            AWPROT          => mrg_axi_awprot  , -- In  :    
            AWQOS           => mrg_axi_awqos   , -- In  :    
            AWREGION        => mrg_axi_awregion, -- In  :    
            AWUSER          => mrg_axi_awuser  , -- In  :    
            AWID            => mrg_axi_awid    , -- In  :    
            AWVALID         => mrg_axi_awvalid , -- In  :    
            AWREADY         => mrg_axi_awready , -- I/O : 
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
            WLAST           => mrg_axi_wlast   , -- In  :    
            WDATA           => mrg_axi_wdata   , -- In  :    
            WSTRB           => mrg_axi_wstrb   , -- In  :    
            WUSER           => mrg_axi_wuser   , -- In  :    
            WID             => mrg_axi_wid     , -- In  :    
            WVALID          => mrg_axi_wvalid  , -- In  :    
            WREADY          => mrg_axi_wready  , -- I/O : 
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => mrg_axi_bresp   , -- I/O : 
            BUSER           => mrg_axi_buser   , -- I/O : 
            BID             => mrg_axi_bid     , -- I/O : 
            BVALID          => mrg_axi_bvalid  , -- I/O : 
            BREADY          => mrg_axi_bready  , -- In  :    
        ---------------------------------------------------------------------------
        -- シンクロ用信号
        ---------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => mrg_axi_gpi     , -- In  :
            GPO             => mrg_axi_gpo     , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => MRG_AXI_REPORT  , -- Out :
            FINISH          => MRG_AXI_FINISH    -- Out :
        );
    mrg_axi_gpi(0) <= csr_gpo(0);
    mrg_axi_gpi(stm_axi_gpi'high downto 1) <= (mrg_axi_gpi'high downto 1 => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process begin
        loop
            ACLK <= '0'; wait for PERIOD / 2;
            ACLK <= '1'; wait for PERIOD / 2;
            exit when(N_FINISH = '1');
        end loop;
        ACLK <= '0';
        wait;
    end process;

    ARESETn <= '1' when (RESET = '0') else '0';
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        wait until (N_FINISH'event and N_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                                WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ CSR ]");                                             WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,CSR_REPORT.error_count   );    WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,CSR_REPORT.mismatch_count);    WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,CSR_REPORT.warning_count );    WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ STM AXI]");                                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,STM_AXI_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,STM_AXI_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,STM_AXI_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ MRG AXI]");                                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,MRG_AXI_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,MRG_AXI_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,MRG_AXI_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        assert (CSR_REPORT    .error_count = 0 and
                STM_AXI_REPORT.error_count = 0 and
                MRG_AXI_REPORT.error_count = 0)
            report "Simulation complete(error)."    severity FAILURE;
        assert (CSR_REPORT    .mismatch_count = 0 and
                STM_AXI_REPORT.mismatch_count = 0 and
                MRG_AXI_REPORT.mismatch_count = 0)
            report "Simulation complete(mismatch)." severity FAILURE;
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete(success)."  severity FAILURE;
        else
            assert FALSE report "Simulation complete(success)."  severity NOTE;
        end if;
        wait;
    end process;
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_Kernel_Test_Bench_X04_W1_F0 is
    generic (
        NAME            :  STRING  := "TEST_X04_W1_F0";
        SCENARIO_FILE   :  STRING  := "test_x04_w1_f0.snr";
        MRG_WAYS        :  integer := 4;  -- X04
        MRG_WORDS       :  integer := 1;  -- W1
        STM_FEEDBACK    :  integer := 0;  -- F0
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_Kernel_Test_Bench_X04_W1_F0;
architecture Model of ArgSort_Kernel_Test_Bench_X04_W1_F0 is
begin
    TB: entity WORK.ArgSort_Kernel_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_Kernel_Test_Bench_X04_W1_F1 is
    generic (
        NAME            :  STRING  := "TEST_X04_W1_F1";
        SCENARIO_FILE   :  STRING  := "test_x04_w1_f1.snr";
        MRG_WAYS        :  integer := 4;  -- X04
        MRG_WORDS       :  integer := 1;  -- W1
        STM_FEEDBACK    :  integer := 1;  -- F1
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_Kernel_Test_Bench_X04_W1_F1;
architecture Model of ArgSort_Kernel_Test_Bench_X04_W1_F1 is
begin
    TB: entity WORK.ArgSort_Kernel_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_Kernel_Test_Bench_X04_W1_F2 is
    generic (
        NAME            :  STRING  := "TEST_X04_W1_F2";
        SCENARIO_FILE   :  STRING  := "test_x04_w1_f2.snr";
        MRG_WAYS        :  integer := 4;  -- X04
        MRG_WORDS       :  integer := 1;  -- W1
        STM_FEEDBACK    :  integer := 2;  -- F2
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_Kernel_Test_Bench_X04_W1_F2;
architecture Model of ArgSort_Kernel_Test_Bench_X04_W1_F2 is
begin
    TB: entity WORK.ArgSort_Kernel_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_Kernel_Test_Bench_X04_W2_F2 is
    generic (
        NAME            :  STRING  := "TEST_X04_W2_F2";
        SCENARIO_FILE   :  STRING  := "test_x04_w2_f2.snr";
        MRG_WAYS        :  integer := 4;  -- X04
        MRG_WORDS       :  integer := 2;  -- W1
        STM_FEEDBACK    :  integer := 2;  -- F2
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_Kernel_Test_Bench_X04_W2_F2;
architecture Model of ArgSort_Kernel_Test_Bench_X04_W2_F2 is
begin
    TB: entity WORK.ArgSort_Kernel_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_Kernel_Test_Bench_X16_W1_F2 is
    generic (
        NAME            :  STRING  := "TEST_X16_W1_F2";
        SCENARIO_FILE   :  STRING  := "test_x16_w1_f2.snr";
        MRG_WAYS        :  integer := 16; -- X16
        MRG_WORDS       :  integer := 1;  -- W1
        STM_FEEDBACK    :  integer := 2;  -- F2
        STM_IN_QUEUE    :  integer := 0;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_Kernel_Test_Bench_X16_W1_F2;
architecture Model of ArgSort_Kernel_Test_Bench_X16_W1_F2 is
begin
    TB: entity WORK.ArgSort_Kernel_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        STM_IN_QUEUE    => STM_IN_QUEUE  ,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_Kernel_Test_Bench_X16_W2_F2 is
    generic (
        NAME            :  STRING  := "TEST_X16_W2_F2";
        SCENARIO_FILE   :  STRING  := "test_x16_w2_f2.snr";
        MRG_WAYS        :  integer := 16; -- X16
        MRG_WORDS       :  integer := 2;  -- W2
        STM_FEEDBACK    :  integer := 2;  -- F2
        STM_IN_QUEUE    :  integer := 0;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_Kernel_Test_Bench_X16_W2_F2;
architecture Model of ArgSort_Kernel_Test_Bench_X16_W2_F2 is
begin
    TB: entity WORK.ArgSort_Kernel_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        STM_IN_QUEUE    => STM_IN_QUEUE  ,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_Kernel_Test_Bench_X32_W1_F2 is
    generic (
        NAME            :  STRING  := "TEST_X32_W1_F2";
        SCENARIO_FILE   :  STRING  := "test_x32_w1_f2.snr";
        MRG_WAYS        :  integer := 32; -- X32
        MRG_WORDS       :  integer := 1;  -- W1
        STM_FEEDBACK    :  integer := 2;  -- F2
        STM_IN_QUEUE    :  integer := 0;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_Kernel_Test_Bench_X32_W1_F2;
architecture Model of ArgSort_Kernel_Test_Bench_X32_W1_F2 is
begin
    TB: entity WORK.ArgSort_Kernel_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        STM_IN_QUEUE    => STM_IN_QUEUE  ,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
