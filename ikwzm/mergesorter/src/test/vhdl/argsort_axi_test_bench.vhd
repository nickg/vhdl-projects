-----------------------------------------------------------------------------------
--!     @file    argsort_axi_test_bench.vhd
--!     @brief   Merge Sorter ArgSort AXI Test Bench :
--!     @version 1.4.1
--!     @date    2022/11/1
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2021-2022 Ichiro Kawazome
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
entity  ArgSort_AXI_Test_Bench is
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
end ArgSort_AXI_Test_Bench;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library Merge_Sorter;
use     Merge_Sorter.ArgSort_AXI_Components.ArgSort_AXI;
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
architecture Model of ArgSort_AXI_Test_Bench is
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
    constant  STM_AXI_CACHE     :  integer := 15;
    constant  STM_AXI_PROT      :  integer := 1;
    constant  STM_AXI_AUSER     :  integer := 0;
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
    constant  MRG_AXI_CACHE     :  integer := 15;
    constant  MRG_AXI_PROT      :  integer := 1;
    constant  MRG_AXI_AUSER     :  integer := 0;
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
    DUT:  ArgSort_AXI                                    -- 
        generic map (
            MRG_WAYS            => MRG_WAYS            ,
            MRG_WORDS           => MRG_WORDS           ,
            WORD_BITS           => WORD_BITS           , 
            INDEX_BITS          => INDEX_BITS          ,
            COMP_SIGN           => TRUE                ,
            SORT_ORDER          => 0                   ,
            SORT_SIZE_BITS      => SORT_SIZE_BITS      ,
            MRG_FIFO_SIZE       => 0                   ,
            STM_FEEDBACK        => STM_FEEDBACK        ,
            STM_IN_QUEUE_SIZE   => STM_IN_QUEUE        ,
            CSR_AXI_ADDR_WIDTH  => CSR_WIDTH.ARADDR    ,
            CSR_AXI_DATA_WIDTH  => CSR_WIDTH.RDATA     ,
            STM_AXI_ADDR_WIDTH  => STM_AXI_WIDTH.ARADDR,
            STM_AXI_DATA_WIDTH  => STM_AXI_WIDTH.RDATA ,
            STM_AXI_USER_WIDTH  => STM_AXI_WIDTH.ARUSER, -- 
            STM_AXI_ID_WIDTH    => STM_AXI_WIDTH.ID    , -- 
            STM_AXI_ID_BASE     => STM_AXI_ID_BASE     , -- 
            STM_RD_AXI_XFER_SIZE=> AXI_XFER_SIZE       , -- 
            STM_WR_AXI_XFER_SIZE=> AXI_XFER_SIZE       , -- 
            MRG_AXI_ADDR_WIDTH  => MRG_AXI_WIDTH.ARADDR, -- 
            MRG_AXI_DATA_WIDTH  => MRG_AXI_WIDTH.RDATA , -- 
            MRG_AXI_USER_WIDTH  => MRG_AXI_WIDTH.ARUSER, -- 
            MRG_AXI_ID_WIDTH    => MRG_AXI_WIDTH.ID    , -- 
            MRG_AXI_ID_BASE     => MRG_AXI_ID_BASE     , -- 
            MRG_RD_AXI_XFER_SIZE=> AXI_XFER_SIZE       , -- 
            MRG_WR_AXI_XFER_SIZE=> AXI_XFER_SIZE       , --
            MRG_RD_PRE_STATE    => MRG_RD_PRE_STATE    , --
            DEBUG_ENABLE        => DEBUG_ENABLE          -- 
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        -- Clock/Reset Signals.
        ---------------------------------------------------------------------------
            ACLK                => ACLK                , -- In  :
            ARESETn             => ARESETn             , -- In  :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            CSR_AXI_ARADDR      => csr_araddr          , -- in  :
            CSR_AXI_ARVALID     => csr_arvalid         , -- in  :
            CSR_AXI_ARREADY     => csr_arready         , -- out :
        ------------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Data Channel Signals.
        ------------------------------------------------------------------------------
            CSR_AXI_RDATA       => csr_rdata           , -- out :
            CSR_AXI_RRESP       => csr_rresp           , -- out :
            CSR_AXI_RVALID      => csr_rvalid          , -- out :
            CSR_AXI_RREADY      => csr_rready          , -- in  :
        ------------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Address Channel Signals.
        ------------------------------------------------------------------------------
            CSR_AXI_AWADDR      => csr_awaddr          , -- in  :
            CSR_AXI_AWVALID     => csr_awvalid         , -- in  :
            CSR_AXI_AWREADY     => csr_awready         , -- out :
        ------------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Data Channel Signals.
        ------------------------------------------------------------------------------
            CSR_AXI_WDATA       => csr_wdata           , -- in  :
            CSR_AXI_WSTRB       => csr_wstrb           , -- in  :
            CSR_AXI_WVALID      => csr_wvalid          , -- in  :
            CSR_AXI_WREADY      => csr_wready          , -- out :
        ------------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Response Channel Signals.
        ------------------------------------------------------------------------------
            CSR_AXI_BRESP       => csr_bresp           , -- out :
            CSR_AXI_BVALID      => csr_bvalid          , -- out :
            CSR_AXI_BREADY      => csr_bready          , -- in  :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Read Address Channel Signals.
        ---------------------------------------------------------------------------
            STM_AXI_ARID        => stm_axi_arid        , -- Out :
            STM_AXI_ARADDR      => stm_axi_araddr      , -- Out :
            STM_AXI_ARLEN       => stm_axi_arlen       , -- Out :
            STM_AXI_ARSIZE      => stm_axi_arsize      , -- Out :
            STM_AXI_ARBURST     => stm_axi_arburst     , -- Out :
            STM_AXI_ARLOCK      => stm_axi_arlock      , -- Out :
            STM_AXI_ARCACHE     => stm_axi_arcache     , -- Out :
            STM_AXI_ARPROT      => stm_axi_arprot      , -- Out :
            STM_AXI_ARQOS       => stm_axi_arqos       , -- Out :
            STM_AXI_ARREGION    => stm_axi_arregion    , -- Out :
            STM_AXI_ARUSER      => stm_axi_aruser      , -- Out :
            STM_AXI_ARVALID     => stm_axi_arvalid     , -- Out :
            STM_AXI_ARREADY     => stm_axi_arready     , -- In  :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Read Data Channel Signals.
        ---------------------------------------------------------------------------
            STM_AXI_RID         => stm_axi_rid         , -- In  :
            STM_AXI_RDATA       => stm_axi_rdata       , -- In  :
            STM_AXI_RRESP       => stm_axi_rresp       , -- In  :
            STM_AXI_RLAST       => stm_axi_rlast       , -- In  :
            STM_AXI_RVALID      => stm_axi_rvalid      , -- In  :
            STM_AXI_RREADY      => stm_axi_rready      , -- Out :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Writer Address Channel Signals.
        ---------------------------------------------------------------------------
            STM_AXI_AWID        => stm_axi_awid        , -- Out :
            STM_AXI_AWADDR      => stm_axi_awaddr      , -- Out :
            STM_AXI_AWLEN       => stm_axi_awlen       , -- Out :
            STM_AXI_AWSIZE      => stm_axi_awsize      , -- Out :
            STM_AXI_AWBURST     => stm_axi_awburst     , -- Out :
            STM_AXI_AWLOCK      => stm_axi_awlock      , -- Out :
            STM_AXI_AWCACHE     => stm_axi_awcache     , -- Out :
            STM_AXI_AWPROT      => stm_axi_awprot      , -- Out :
            STM_AXI_AWQOS       => stm_axi_awqos       , -- Out :
            STM_AXI_AWREGION    => stm_axi_awregion    , -- Out :
            STM_AXI_AWUSER      => stm_axi_awuser      , -- Out :
            STM_AXI_AWVALID     => stm_axi_awvalid     , -- Out :
            STM_AXI_AWREADY     => stm_axi_awready     , -- In  :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Write Data Channel Signals.
        ---------------------------------------------------------------------------
            STM_AXI_WID         => stm_axi_wid         , -- Out :
            STM_AXI_WDATA       => stm_axi_wdata       , -- Out :
            STM_AXI_WSTRB       => stm_axi_wstrb       , -- Out :
            STM_AXI_WLAST       => stm_axi_wlast       , -- Out :
            STM_AXI_WVALID      => stm_axi_wvalid      , -- Out :
            STM_AXI_WREADY      => stm_axi_wready      , -- In  :
        ---------------------------------------------------------------------------
        -- Stream AXI Write Response Channel Signals.
        ---------------------------------------------------------------------------
            STM_AXI_BID         => stm_axi_bid         , -- In  :
            STM_AXI_BRESP       => stm_axi_bresp       , -- In  :
            STM_AXI_BVALID      => stm_axi_bvalid      , -- In  :
            STM_AXI_BREADY      => stm_axi_bready      , -- Out :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Read Address Channel Signals.
        ---------------------------------------------------------------------------
            MRG_AXI_ARID        => mrg_axi_arid        , -- Out :
            MRG_AXI_ARADDR      => mrg_axi_araddr      , -- Out :
            MRG_AXI_ARLEN       => mrg_axi_arlen       , -- Out :
            MRG_AXI_ARSIZE      => mrg_axi_arsize      , -- Out :
            MRG_AXI_ARBURST     => mrg_axi_arburst     , -- Out :
            MRG_AXI_ARLOCK      => mrg_axi_arlock      , -- Out :
            MRG_AXI_ARCACHE     => mrg_axi_arcache     , -- Out :
            MRG_AXI_ARPROT      => mrg_axi_arprot      , -- Out :
            MRG_AXI_ARQOS       => mrg_axi_arqos       , -- Out :
            MRG_AXI_ARREGION    => mrg_axi_arregion    , -- Out :
            MRG_AXI_ARUSER      => mrg_axi_aruser      , -- Out :
            MRG_AXI_ARVALID     => mrg_axi_arvalid     , -- Out :
            MRG_AXI_ARREADY     => mrg_axi_arready     , -- In  :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Read Data Channel Signals.
        ---------------------------------------------------------------------------
            MRG_AXI_RID         => mrg_axi_rid         , -- In  :
            MRG_AXI_RDATA       => mrg_axi_rdata       , -- In  :
            MRG_AXI_RRESP       => mrg_axi_rresp       , -- In  :
            MRG_AXI_RLAST       => mrg_axi_rlast       , -- In  :
            MRG_AXI_RVALID      => mrg_axi_rvalid      , -- In  :
            MRG_AXI_RREADY      => mrg_axi_rready      , -- Out :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Writer Address Channel Signals.
        ---------------------------------------------------------------------------
            MRG_AXI_AWID        => mrg_axi_awid        , -- Out :
            MRG_AXI_AWADDR      => mrg_axi_awaddr      , -- Out :
            MRG_AXI_AWLEN       => mrg_axi_awlen       , -- Out :
            MRG_AXI_AWSIZE      => mrg_axi_awsize      , -- Out :
            MRG_AXI_AWBURST     => mrg_axi_awburst     , -- Out :
            MRG_AXI_AWLOCK      => mrg_axi_awlock      , -- Out :
            MRG_AXI_AWCACHE     => mrg_axi_awcache     , -- Out :
            MRG_AXI_AWPROT      => mrg_axi_awprot      , -- Out :
            MRG_AXI_AWQOS       => mrg_axi_awqos       , -- Out :
            MRG_AXI_AWREGION    => mrg_axi_awregion    , -- Out :
            MRG_AXI_AWUSER      => mrg_axi_awuser      , -- Out :
            MRG_AXI_AWVALID     => mrg_axi_awvalid     , -- Out :
            MRG_AXI_AWREADY     => mrg_axi_awready     , -- In  :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Write Data Channel Signals.
        ---------------------------------------------------------------------------
            MRG_AXI_WID         => mrg_axi_wid         , -- Out :
            MRG_AXI_WDATA       => mrg_axi_wdata       , -- Out :
            MRG_AXI_WSTRB       => mrg_axi_wstrb       , -- Out :
            MRG_AXI_WLAST       => mrg_axi_wlast       , -- Out :
            MRG_AXI_WVALID      => mrg_axi_wvalid      , -- Out :
            MRG_AXI_WREADY      => mrg_axi_wready      , -- In  :
        ---------------------------------------------------------------------------
        -- Merge AXI Write Response Channel Signals.
        ---------------------------------------------------------------------------
            MRG_AXI_BID         => mrg_axi_bid         , -- In  :
            MRG_AXI_BRESP       => mrg_axi_bresp       , -- In  :
            MRG_AXI_BVALID      => mrg_axi_bvalid      , -- In  :
            MRG_AXI_BREADY      => mrg_axi_bready      , -- Out :
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
            interrupt           => interrupt             -- Out :
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
entity  ArgSort_AXI_Test_Bench_X04_W1_F0 is
    generic (
        NAME            :  STRING  := "TEST_X04_W1_F0";
        SCENARIO_FILE   :  STRING  := "test_x04_w1_f0.snr";
        MRG_WAYS        :  integer := 4;  -- X04
        MRG_WORDS       :  integer := 1;  -- W1
        STM_FEEDBACK    :  integer := 0;  -- F0
        SORT_SIZE_BITS  :  integer := 28;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_AXI_Test_Bench_X04_W1_F0;
architecture Model of ArgSort_AXI_Test_Bench_X04_W1_F0 is
begin
    TB: entity WORK.ArgSort_AXI_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        SORT_SIZE_BITS  => SORT_SIZE_BITS,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_AXI_Test_Bench_X04_W1_F1 is
    generic (
        NAME            :  STRING  := "TEST_X04_W1_F1";
        SCENARIO_FILE   :  STRING  := "test_x04_w1_f1.snr";
        MRG_WAYS        :  integer := 4;  -- X04
        MRG_WORDS       :  integer := 1;  -- W1
        STM_FEEDBACK    :  integer := 1;  -- F1
        SORT_SIZE_BITS  :  integer := 28;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_AXI_Test_Bench_X04_W1_F1;
architecture Model of ArgSort_AXI_Test_Bench_X04_W1_F1 is
begin
    TB: entity WORK.ArgSort_AXI_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        SORT_SIZE_BITS  => SORT_SIZE_BITS,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_AXI_Test_Bench_X04_W1_F2 is
    generic (
        NAME            :  STRING  := "TEST_X04_W1_F2";
        SCENARIO_FILE   :  STRING  := "test_x04_w1_f2.snr";
        MRG_WAYS        :  integer := 4;  -- X04
        MRG_WORDS       :  integer := 1;  -- W1
        STM_FEEDBACK    :  integer := 2;  -- F2
        SORT_SIZE_BITS  :  integer := 28;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_AXI_Test_Bench_X04_W1_F2;
architecture Model of ArgSort_AXI_Test_Bench_X04_W1_F2 is
begin
    TB: entity WORK.ArgSort_AXI_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        SORT_SIZE_BITS  => SORT_SIZE_BITS,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_AXI_Test_Bench_X04_W2_F2 is
    generic (
        NAME            :  STRING  := "TEST_X04_W2_F2";
        SCENARIO_FILE   :  STRING  := "test_x04_w2_f2.snr";
        MRG_WAYS        :  integer := 4;  -- X04
        MRG_WORDS       :  integer := 2;  -- W1
        STM_FEEDBACK    :  integer := 2;  -- F2
        SORT_SIZE_BITS  :  integer := 28;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_AXI_Test_Bench_X04_W2_F2;
architecture Model of ArgSort_AXI_Test_Bench_X04_W2_F2 is
begin
    TB: entity WORK.ArgSort_AXI_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        SORT_SIZE_BITS  => SORT_SIZE_BITS,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_AXI_Test_Bench_X16_W1_F2 is
    generic (
        NAME            :  STRING  := "TEST_X16_W1_F2";
        SCENARIO_FILE   :  STRING  := "test_x16_w1_f2.snr";
        MRG_WAYS        :  integer := 16; -- X16
        MRG_WORDS       :  integer := 1;  -- W1
        STM_FEEDBACK    :  integer := 2;  -- F2
        STM_IN_QUEUE    :  integer := 0;
        SORT_SIZE_BITS  :  integer := 28;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_AXI_Test_Bench_X16_W1_F2;
architecture Model of ArgSort_AXI_Test_Bench_X16_W1_F2 is
begin
    TB: entity WORK.ArgSort_AXI_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        STM_IN_QUEUE    => STM_IN_QUEUE  ,
        SORT_SIZE_BITS  => SORT_SIZE_BITS,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_AXI_Test_Bench_X16_W2_F2 is
    generic (
        NAME            :  STRING  := "TEST_X16_W2_F2";
        SCENARIO_FILE   :  STRING  := "test_x16_w2_f2.snr";
        MRG_WAYS        :  integer := 16; -- X16
        MRG_WORDS       :  integer := 2;  -- W2
        STM_FEEDBACK    :  integer := 2;  -- F2
        STM_IN_QUEUE    :  integer := 0;
        SORT_SIZE_BITS  :  integer := 28;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_AXI_Test_Bench_X16_W2_F2;
architecture Model of ArgSort_AXI_Test_Bench_X16_W2_F2 is
begin
    TB: entity WORK.ArgSort_AXI_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        STM_IN_QUEUE    => STM_IN_QUEUE  ,
        SORT_SIZE_BITS  => SORT_SIZE_BITS,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_AXI_Test_Bench_X16_W2_F0 is
    generic (
        NAME            :  STRING  := "TEST_X16_W2_F0";
        SCENARIO_FILE   :  STRING  := "test_x16_w2_f0.snr";
        MRG_WAYS        :  integer := 16; -- X16
        MRG_WORDS       :  integer := 2;  -- W2
        STM_FEEDBACK    :  integer := 0;  -- F0
        STM_IN_QUEUE    :  integer := 0;
        SORT_SIZE_BITS  :  integer := 28;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_AXI_Test_Bench_X16_W2_F0;
architecture Model of ArgSort_AXI_Test_Bench_X16_W2_F0 is
begin
    TB: entity WORK.ArgSort_AXI_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        STM_IN_QUEUE    => STM_IN_QUEUE  ,
        SORT_SIZE_BITS  => SORT_SIZE_BITS,
        MRG_RD_PRE_STATE=> 12            ,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ArgSort_AXI_Test_Bench_X32_W1_F2 is
    generic (
        NAME            :  STRING  := "TEST_X32_W1_F2";
        SCENARIO_FILE   :  STRING  := "test_x32_w1_f2.snr";
        MRG_WAYS        :  integer := 32; -- X32
        MRG_WORDS       :  integer := 1;  -- W1
        STM_FEEDBACK    :  integer := 2;  -- F2
        STM_IN_QUEUE    :  integer := 0;
        SORT_SIZE_BITS  :  integer := 28;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_AXI_Test_Bench_X32_W1_F2;
architecture Model of ArgSort_AXI_Test_Bench_X32_W1_F2 is
begin
    TB: entity WORK.ArgSort_AXI_Test_Bench generic map(
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE , 
        MRG_WAYS        => MRG_WAYS      ,
        MRG_WORDS       => MRG_WORDS     ,
        STM_FEEDBACK    => STM_FEEDBACK  ,
        STM_IN_QUEUE    => STM_IN_QUEUE  ,
        SORT_SIZE_BITS  => SORT_SIZE_BITS,
        FINISH_ABORT    => FINISH_ABORT
    );
end Model;
