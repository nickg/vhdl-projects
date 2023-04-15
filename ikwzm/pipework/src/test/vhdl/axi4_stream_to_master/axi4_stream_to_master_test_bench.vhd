-----------------------------------------------------------------------------------
--!     @file    axi4_stream_to_master_test_bench.vhd
--!     @brief   Pump Core Module (AXI4-Stream to AXI4) Test Bench
--!     @version 1.8.1
--!     @date    2020/10/2
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2020 Ichiro Kawazome
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
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
entity  AXI4_STREAM_TO_MASTER_TEST_BENCH is
    generic (
        NAME            : STRING                                 := "test";
        SCENARIO_FILE   : STRING                                 := "test.snr";
        O_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        I_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        O_CLK_RATE      : integer                                :=  1;
        I_CLK_RATE      : integer                                :=  1;
        O_PERIOD        : time                                   := 10 ns;
        I_PERIOD        : time                                   := 10 ns;
        MAX_XFER_SIZE   : integer                                :=  6;
        BUF_WIDTH       : integer                                := 32;
        BUF_DEPTH       : integer                                := 12;
        FINISH_ABORT    : boolean                                := FALSE
    );
end     AXI4_STREAM_TO_MASTER_TEST_BENCH;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SLAVE_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SIGNAL_PRINTER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
architecture MODEL of AXI4_STREAM_TO_MASTER_TEST_BENCH is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant  DELAY             :  time    :=  1 ns;
    constant  AXI4_ADDR_WIDTH   :  integer := 32;
    constant  C_WIDTH           :  AXI4_SIGNAL_WIDTH_TYPE := (
                                     ID          => 4,
                                     AWADDR      => AXI4_ADDR_WIDTH,
                                     ARADDR      => AXI4_ADDR_WIDTH,
                                     ALEN        => AXI4_ALEN_WIDTH,
                                     ALOCK       => AXI4_ALOCK_WIDTH,
                                     WDATA       => 32,
                                     RDATA       => 32,
                                     ARUSER      => 1,
                                     AWUSER      => 1,
                                     WUSER       => 1,
                                     RUSER       => 1,
                                     BUSER       => 1);
    constant  O_WIDTH           :  AXI4_SIGNAL_WIDTH_TYPE := (
                                     ID          => 4,
                                     AWADDR      => AXI4_ADDR_WIDTH,
                                     ARADDR      => AXI4_ADDR_WIDTH,
                                     ALEN        => AXI4_ALEN_WIDTH,
                                     ALOCK       => AXI4_ALOCK_WIDTH,
                                     WDATA       => O_DATA_WIDTH,
                                     RDATA       => O_DATA_WIDTH,
                                     ARUSER      => 1,
                                     AWUSER      => 1,
                                     WUSER       => 1,
                                     RUSER       => 1,
                                     BUSER       => 1);
    constant    I_WIDTH         :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                      ID         => 4,
                                      USER       => 4,
                                      DEST       => 4,
                                      DATA       => I_DATA_WIDTH
                                   );
    constant   O_AXI_ID         :  integer :=  1;
    constant   O_QUEUE_SIZE     :  integer :=  4;
    constant   SYNC_WIDTH       :  integer :=  2;
    constant   GPO_WIDTH        :  integer :=  8;
    constant   GPI_WIDTH        :  integer :=  GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal    ARESETn           :  std_logic;
    signal    RESET             :  std_logic;
    constant  CLEAR             :  std_logic := '0';
    signal    O_CLK             :  std_logic;
    constant  O_CKE             :  std_logic := '1';
    ------------------------------------------------------------------------------
    -- CSR I/F 
    ------------------------------------------------------------------------------
    signal    C_ARADDR          :  std_logic_vector(C_WIDTH.ARADDR -1 downto 0);
    signal    C_ARLEN           :  std_logic_vector(C_WIDTH.ALEN   -1 downto 0);
    signal    C_ARSIZE          :  AXI4_ASIZE_TYPE;
    signal    C_ARBURST         :  AXI4_ABURST_TYPE;
    signal    C_ARLOCK          :  std_logic_vector(C_WIDTH.ALOCK  -1 downto 0);
    signal    C_ARCACHE         :  AXI4_ACACHE_TYPE;
    signal    C_ARPROT          :  AXI4_APROT_TYPE;
    signal    C_ARQOS           :  AXI4_AQOS_TYPE;
    signal    C_ARREGION        :  AXI4_AREGION_TYPE;
    signal    C_ARUSER          :  std_logic_vector(C_WIDTH.ARUSER -1 downto 0);
    signal    C_ARID            :  std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal    C_ARVALID         :  std_logic;
    signal    C_ARREADY         :  std_logic;
    signal    C_RVALID          :  std_logic;
    signal    C_RLAST           :  std_logic;
    signal    C_RDATA           :  std_logic_vector(C_WIDTH.RDATA  -1 downto 0);
    signal    C_RRESP           :  AXI4_RESP_TYPE;
    signal    C_RUSER           :  std_logic_vector(C_WIDTH.RUSER  -1 downto 0);
    signal    C_RID             :  std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal    C_RREADY          :  std_logic;
    signal    C_AWADDR          :  std_logic_vector(C_WIDTH.AWADDR -1 downto 0);
    signal    C_AWLEN           :  std_logic_vector(C_WIDTH.ALEN   -1 downto 0);
    signal    C_AWSIZE          :  AXI4_ASIZE_TYPE;
    signal    C_AWBURST         :  AXI4_ABURST_TYPE;
    signal    C_AWLOCK          :  std_logic_vector(C_WIDTH.ALOCK  -1 downto 0);
    signal    C_AWCACHE         :  AXI4_ACACHE_TYPE;
    signal    C_AWPROT          :  AXI4_APROT_TYPE;
    signal    C_AWQOS           :  AXI4_AQOS_TYPE;
    signal    C_AWREGION        :  AXI4_AREGION_TYPE;
    signal    C_AWUSER          :  std_logic_vector(C_WIDTH.AWUSER -1 downto 0);
    signal    C_AWID            :  std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal    C_AWVALID         :  std_logic;
    signal    C_AWREADY         :  std_logic;
    signal    C_WLAST           :  std_logic;
    signal    C_WDATA           :  std_logic_vector(C_WIDTH.WDATA  -1 downto 0);
    signal    C_WSTRB           :  std_logic_vector(C_WIDTH.WDATA/8-1 downto 0);
    signal    C_WUSER           :  std_logic_vector(C_WIDTH.WUSER  -1 downto 0);
    signal    C_WID             :  std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal    C_WVALID          :  std_logic;
    signal    C_WREADY          :  std_logic;
    signal    C_BRESP           :  AXI4_RESP_TYPE;
    signal    C_BUSER           :  std_logic_vector(C_WIDTH.BUSER  -1 downto 0);
    signal    C_BID             :  std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal    C_BVALID          :  std_logic;
    signal    C_BREADY          :  std_logic;
    ------------------------------------------------------------------------------
    -- Out I/F 
    ------------------------------------------------------------------------------
    signal    O_ARADDR          :  std_logic_vector(O_WIDTH.ARADDR -1 downto 0);
    signal    O_ARLEN           :  std_logic_vector(O_WIDTH.ALEN   -1 downto 0);
    signal    O_ARSIZE          :  AXI4_ASIZE_TYPE;
    signal    O_ARBURST         :  AXI4_ABURST_TYPE;
    signal    O_ARLOCK          :  std_logic_vector(O_WIDTH.ALOCK  -1 downto 0);
    signal    O_ARCACHE         :  AXI4_ACACHE_TYPE;
    signal    O_ARPROT          :  AXI4_APROT_TYPE;
    signal    O_ARQOS           :  AXI4_AQOS_TYPE;
    signal    O_ARREGION        :  AXI4_AREGION_TYPE;
    signal    O_ARUSER          :  std_logic_vector(O_WIDTH.ARUSER -1 downto 0);
    signal    O_ARID            :  std_logic_vector(O_WIDTH.ID     -1 downto 0);
    signal    O_ARVALID         :  std_logic;
    signal    O_ARREADY         :  std_logic;
    signal    O_RVALID          :  std_logic;
    signal    O_RLAST           :  std_logic;
    signal    O_RDATA           :  std_logic_vector(O_WIDTH.RDATA  -1 downto 0);
    signal    O_RRESP           :  AXI4_RESP_TYPE;
    signal    O_RUSER           :  std_logic_vector(O_WIDTH.RUSER  -1 downto 0);
    signal    O_RID             :  std_logic_vector(O_WIDTH.ID     -1 downto 0);
    signal    O_RREADY          :  std_logic;
    signal    O_AWADDR          :  std_logic_vector(O_WIDTH.AWADDR -1 downto 0);
    signal    O_AWLEN           :  std_logic_vector(O_WIDTH.ALEN   -1 downto 0);
    signal    O_AWSIZE          :  AXI4_ASIZE_TYPE;
    signal    O_AWBURST         :  AXI4_ABURST_TYPE;
    signal    O_AWLOCK          :  std_logic_vector(O_WIDTH.ALOCK  -1 downto 0);
    signal    O_AWCACHE         :  AXI4_ACACHE_TYPE;
    signal    O_AWPROT          :  AXI4_APROT_TYPE;
    signal    O_AWQOS           :  AXI4_AQOS_TYPE;
    signal    O_AWREGION        :  AXI4_AREGION_TYPE;
    signal    O_AWUSER          :  std_logic_vector(O_WIDTH.AWUSER -1 downto 0);
    signal    O_AWID            :  std_logic_vector(O_WIDTH.ID     -1 downto 0);
    signal    O_AWVALID         :  std_logic;
    signal    O_AWREADY         :  std_logic;
    signal    O_WLAST           :  std_logic;
    signal    O_WDATA           :  std_logic_vector(O_WIDTH.WDATA  -1 downto 0);
    signal    O_WSTRB           :  std_logic_vector(O_WIDTH.WDATA/8-1 downto 0);
    signal    O_WUSER           :  std_logic_vector(O_WIDTH.WUSER  -1 downto 0);
    signal    O_WID             :  std_logic_vector(O_WIDTH.ID     -1 downto 0);
    signal    O_WVALID          :  std_logic;
    signal    O_WREADY          :  std_logic;
    signal    O_BRESP           :  AXI4_RESP_TYPE;
    signal    O_BUSER           :  std_logic_vector(O_WIDTH.BUSER  -1 downto 0);
    signal    O_BID             :  std_logic_vector(O_WIDTH.ID     -1 downto 0);
    signal    O_BVALID          :  std_logic;
    signal    O_BREADY          :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    I_CLK             :  std_logic;
    constant  I_CKE             :  std_logic := '1';
    signal    I_TDATA           :  std_logic_vector(I_WIDTH.DATA   -1 downto 0);
    signal    I_TSTRB           :  std_logic_vector(I_WIDTH.DATA/8 -1 downto 0);
    signal    I_TKEEP           :  std_logic_vector(I_WIDTH.DATA/8 -1 downto 0);
    signal    I_TDEST           :  std_logic_vector(I_WIDTH.DEST   -1 downto 0);
    signal    I_TUSER           :  std_logic_vector(I_WIDTH.USER   -1 downto 0);
    signal    I_TID             :  std_logic_vector(I_WIDTH.ID     -1 downto 0);
    signal    I_TLAST           :  std_logic;
    signal    I_TVALID          :  std_logic;
    signal    I_TREADY          :  std_logic;
    signal    I_I2O_STOP        :  std_logic;
    signal    I_O2I_STOP        :  std_logic;
    signal    I_O2I_RESET       :  std_logic;
    signal    I_O2I_ERROR       :  std_logic;
    signal    I_O2I_NONE        :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    IRQ               :  std_logic;
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal    SYNC              :  SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal    C_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    C_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    O_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    O_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    I_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    I_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal    N_REPORT          :  REPORT_STATUS_TYPE;
    signal    C_REPORT          :  REPORT_STATUS_TYPE;
    signal    O_REPORT          :  REPORT_STATUS_TYPE;
    signal    I_REPORT          :  REPORT_STATUS_TYPE;
    signal    N_FINISH          :  std_logic;
    signal    C_FINISH          :  std_logic;
    signal    O_FINISH          :  std_logic;
    signal    I_FINISH          :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component AXI4_STREAM_TO_MASTER 
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        generic (
            C_ADDR_WIDTH    : integer range 1 to   64 := 32;
            C_DATA_WIDTH    : integer range 8 to 1024 := 32;
            C_ID_WIDTH      : integer                 :=  8;
            O_CLK_RATE      : integer                 :=  1;
            O_AXI_ID        : integer                 :=  1;
            O_ADDR_WIDTH    : integer range 1 to   64 := 32;
            O_DATA_WIDTH    : integer range 8 to 1024 := 32;
            O_ID_WIDTH      : integer                 :=  8;
            O_AUSER_WIDTH   : integer                 :=  4;
            O_MAX_XFER_SIZE : integer                 :=  8;
            O_QUEUE_SIZE    : integer                 :=  1;
            I_CLK_RATE      : integer                 :=  1;
            I_DATA_WIDTH    : integer                 := 32;
            BUF_WIDTH       : integer                 := 32;
            BUF_DEPTH       : integer                 := 12
        );
        port(
        ---------------------------------------------------------------------------
        -- Reset Signals.
        ---------------------------------------------------------------------------
            ARESETn         : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Intake I/F Clock.
        ---------------------------------------------------------------------------
            O_CLK           : in    std_logic;
            O_CKE           : in    std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            C_ARID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_ARADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
            C_ARLEN         : in    std_logic_vector(7 downto 0);
            C_ARSIZE        : in    std_logic_vector(2 downto 0);
            C_ARBURST       : in    std_logic_vector(1 downto 0);
            C_ARVALID       : in    std_logic;
            C_ARREADY       : out   std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            C_RID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_RDATA         : out   std_logic_vector(C_DATA_WIDTH  -1 downto 0);
            C_RRESP         : out   std_logic_vector(1 downto 0);
            C_RLAST         : out   std_logic;
            C_RVALID        : out   std_logic;
            C_RREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            C_AWID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_AWADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
            C_AWLEN         : in    std_logic_vector(7 downto 0);
            C_AWSIZE        : in    std_logic_vector(2 downto 0);
            C_AWBURST       : in    std_logic_vector(1 downto 0);
            C_AWVALID       : in    std_logic;
            C_AWREADY       : out   std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            C_WDATA         : in    std_logic_vector(C_DATA_WIDTH  -1 downto 0);
            C_WSTRB         : in    std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
            C_WLAST         : in    std_logic;
            C_WVALID        : in    std_logic;
            C_WREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            C_BID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_BRESP         : out   std_logic_vector(1 downto 0);
            C_BVALID        : out   std_logic;
            C_BREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            O_AWID          : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_AWADDR        : out   std_logic_vector(O_ADDR_WIDTH  -1 downto 0);
            O_AWLEN         : out   std_logic_vector(7 downto 0);
            O_AWSIZE        : out   std_logic_vector(2 downto 0);
            O_AWBURST       : out   std_logic_vector(1 downto 0);
            O_AWLOCK        : out   std_logic_vector(0 downto 0);
            O_AWCACHE       : out   std_logic_vector(3 downto 0);
            O_AWPROT        : out   std_logic_vector(2 downto 0);
            O_AWQOS         : out   std_logic_vector(3 downto 0);
            O_AWREGION      : out   std_logic_vector(3 downto 0);
            O_AWUSER        : out   std_logic_vector(O_AUSER_WIDTH -1 downto 0);
            O_AWVALID       : out   std_logic;
            O_AWREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            O_WID           : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_WDATA         : out   std_logic_vector(O_DATA_WIDTH  -1 downto 0);
            O_WSTRB         : out   std_logic_vector(O_DATA_WIDTH/8-1 downto 0);
            O_WLAST         : out   std_logic;
            O_WVALID        : out   std_logic;
            O_WREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            O_BID           : in    std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_BRESP         : in    std_logic_vector(1 downto 0);
            O_BVALID        : in    std_logic;
            O_BREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            O_ARID          : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_ARADDR        : out   std_logic_vector(O_ADDR_WIDTH  -1 downto 0);
            O_ARLEN         : out   std_logic_vector(7 downto 0);
            O_ARSIZE        : out   std_logic_vector(2 downto 0);
            O_ARBURST       : out   std_logic_vector(1 downto 0);
            O_ARLOCK        : out   std_logic_vector(0 downto 0);
            O_ARCACHE       : out   std_logic_vector(3 downto 0);
            O_ARPROT        : out   std_logic_vector(2 downto 0);
            O_ARQOS         : out   std_logic_vector(3 downto 0);
            O_ARREGION      : out   std_logic_vector(3 downto 0);
            O_ARUSER        : out   std_logic_vector(O_AUSER_WIDTH -1 downto 0);
            O_ARVALID       : out   std_logic;
            O_ARREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            O_RID           : in    std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_RDATA         : in    std_logic_vector(O_DATA_WIDTH  -1 downto 0);
            O_RRESP         : in    std_logic_vector(1 downto 0);
            O_RLAST         : in    std_logic;
            O_RVALID        : in    std_logic;
            O_RREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Pump Intake I/F Clock.
        ---------------------------------------------------------------------------
            I_CLK           : in    std_logic;
            I_CKE           : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet Stream Interface.
        ---------------------------------------------------------------------------
            I_DATA          : in    std_logic_vector(I_DATA_WIDTH   -1 downto 0);
            I_STRB          : in    std_logic_vector(I_DATA_WIDTH/8 -1 downto 0);
            I_LAST          : in    std_logic;
            I_VALID         : in    std_logic;
            I_READY         : out   std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet Stop Interface.
        ---------------------------------------------------------------------------
            I_I2O_STOP      : in  std_logic;
            I_O2I_STOP      : out std_logic;
            I_O2I_RESET     : out std_logic;
            I_O2I_ERROR     : out std_logic;
            I_O2I_NONE      : out std_logic;
        ---------------------------------------------------------------------------
        -- Interrupt Request Signals.
        ---------------------------------------------------------------------------
            IRQ             : out   std_logic
        );
    end component;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    DUT: AXI4_STREAM_TO_MASTER                       -- 
        generic map (                                -- 
            C_ADDR_WIDTH    => C_WIDTH.AWADDR      , -- 
            C_DATA_WIDTH    => C_WIDTH.WDATA       , -- 
            C_ID_WIDTH      => C_WIDTH.ID          , -- 
            O_CLK_RATE      => O_CLK_RATE          , -- 
            O_AXI_ID        => O_AXI_ID            , -- 
            O_ADDR_WIDTH    => O_WIDTH.ARADDR      , -- 
            O_DATA_WIDTH    => O_WIDTH.RDATA       , -- 
            O_ID_WIDTH      => O_WIDTH.ID          , -- 
            O_AUSER_WIDTH   => O_WIDTH.ARUSER      , -- 
            O_MAX_XFER_SIZE => MAX_XFER_SIZE       , -- 
            O_QUEUE_SIZE    => O_QUEUE_SIZE        , -- 
            I_CLK_RATE      => I_CLK_RATE          , -- 
            I_DATA_WIDTH    => I_DATA_WIDTH        , -- 
            BUF_WIDTH       => BUF_WIDTH           , -- 
            BUF_DEPTH       => BUF_DEPTH             -- 
        )                                            -- 
        port map (                                   -- 
        ---------------------------------------------------------------------------
        -- Reset Signals.
        ---------------------------------------------------------------------------
            ARESETn         => ARESETn             , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Intake I/F Clock.
        ---------------------------------------------------------------------------
            O_CLK           => O_CLK               , -- In  :
            O_CKE           => O_CKE               , -- In  :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            C_ARID          => C_ARID              , -- In  :
            C_ARADDR        => C_ARADDR            , -- In  :
            C_ARLEN         => C_ARLEN             , -- In  :
            C_ARSIZE        => C_ARSIZE            , -- In  :
            C_ARBURST       => C_ARBURST           , -- In  :
            C_ARVALID       => C_ARVALID           , -- In  :
            C_ARREADY       => C_ARREADY           , -- Out :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            C_RID           => C_RID               , -- Out :
            C_RDATA         => C_RDATA             , -- Out :
            C_RRESP         => C_RRESP             , -- Out :
            C_RLAST         => C_RLAST             , -- Out :
            C_RVALID        => C_RVALID            , -- Out :
            C_RREADY        => C_RREADY            , -- In  :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            C_AWID          => C_AWID              , -- In  :
            C_AWADDR        => C_AWADDR            , -- In  :
            C_AWLEN         => C_AWLEN             , -- In  :
            C_AWSIZE        => C_AWSIZE            , -- In  :
            C_AWBURST       => C_AWBURST           , -- In  :
            C_AWVALID       => C_AWVALID           , -- In  :
            C_AWREADY       => C_AWREADY           , -- Out :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            C_WDATA         => C_WDATA             , -- In  :
            C_WSTRB         => C_WSTRB             , -- In  :
            C_WLAST         => C_WLAST             , -- In  :
            C_WVALID        => C_WVALID            , -- In  :
            C_WREADY        => C_WREADY            , -- Out :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            C_BID           => C_BID               , -- Out :
            C_BRESP         => C_BRESP             , -- Out :
            C_BVALID        => C_BVALID            , -- Out :
            C_BREADY        => C_BREADY            , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            O_AWID          => O_AWID              , -- Out :
            O_AWADDR        => O_AWADDR            , -- Out :
            O_AWLEN         => O_AWLEN             , -- Out :
            O_AWSIZE        => O_AWSIZE            , -- Out :
            O_AWBURST       => O_AWBURST           , -- Out :
            O_AWLOCK        => O_AWLOCK            , -- Out :
            O_AWCACHE       => O_AWCACHE           , -- Out :
            O_AWPROT        => O_AWPROT            , -- Out :
            O_AWQOS         => O_AWQOS             , -- Out :
            O_AWREGION      => O_AWREGION          , -- Out :
            O_AWUSER        => O_AWUSER            , -- Out :
            O_AWVALID       => O_AWVALID           , -- Out :
            O_AWREADY       => O_AWREADY           , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            O_WID           => O_WID               , -- Out :
            O_WDATA         => O_WDATA             , -- Out :
            O_WSTRB         => O_WSTRB             , -- Out :
            O_WLAST         => O_WLAST             , -- Out :
            O_WVALID        => O_WVALID            , -- Out :
            O_WREADY        => O_WREADY            , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            O_BID           => O_BID               , -- In  :
            O_BRESP         => O_BRESP             , -- In  :
            O_BVALID        => O_BVALID            , -- In  :
            O_BREADY        => O_BREADY            , -- Out :
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            O_ARID          => O_ARID              , -- Out :
            O_ARADDR        => O_ARADDR            , -- Out :
            O_ARLEN         => O_ARLEN             , -- Out :
            O_ARSIZE        => O_ARSIZE            , -- Out :
            O_ARBURST       => O_ARBURST           , -- Out :
            O_ARLOCK        => O_ARLOCK            , -- Out :
            O_ARCACHE       => O_ARCACHE           , -- Out :
            O_ARPROT        => O_ARPROT            , -- Out :
            O_ARQOS         => O_ARQOS             , -- Out :
            O_ARREGION      => O_ARREGION          , -- Out :
            O_ARUSER        => O_ARUSER            , -- Out :
            O_ARVALID       => O_ARVALID           , -- Out :
            O_ARREADY       => O_ARREADY           , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            O_RID           => O_RID               , -- In  :
            O_RDATA         => O_RDATA             , -- In  :
            O_RRESP         => O_RRESP             , -- In  :
            O_RLAST         => O_RLAST             , -- In  :
            O_RVALID        => O_RVALID            , -- In  :
            O_RREADY        => O_RREADY            , -- Out :
        ---------------------------------------------------------------------------
        -- Pump Intake I/F Clock.
        ---------------------------------------------------------------------------
            I_CLK           => I_CLK               , -- In  :
            I_CKE           => I_CKE               , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Intake Stream Interface.
        ---------------------------------------------------------------------------
            I_DATA          => I_TDATA             , -- In  :
            I_STRB          => I_TSTRB             , -- In  :
            I_LAST          => I_TLAST             , -- In  :
            I_VALID         => I_TVALID            , -- In  :
            I_READY         => I_TREADY            , -- Out :
        ---------------------------------------------------------------------------
        -- Pump Outlet Stop Interface.
        ---------------------------------------------------------------------------
            I_I2O_STOP      => I_I2O_STOP          , -- In  :
            I_O2I_STOP      => I_O2I_STOP          , -- Out :
            I_O2I_RESET     => I_O2I_RESET         , -- Out :
            I_O2I_ERROR     => I_O2I_ERROR         , -- Out :
            I_O2I_NONE      => I_O2I_NONE          , -- Out :
        ---------------------------------------------------------------------------
        -- Interrupt Request Signals.
        ---------------------------------------------------------------------------
            IRQ             => IRQ                   -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "MARCHAL",
            SYNC_PLUG_NUM   => 1,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
            CLK             => I_CLK           , -- In  :
            RESET           => RESET           , -- In  :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_MASTER_PLAYER
    ------------------------------------------------------------------------------
    C: AXI4_MASTER_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "CSR"           ,
            READ_ENABLE     => TRUE            ,
            WRITE_ENABLE    => TRUE            ,
            OUTPUT_DELAY    => DELAY           ,
            WIDTH           => C_WIDTH         ,
            SYNC_PLUG_NUM   => 2               ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => O_CLK           , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => C_ARADDR        , -- I/O : 
            ARLEN           => C_ARLEN         , -- I/O : 
            ARSIZE          => C_ARSIZE        , -- I/O : 
            ARBURST         => C_ARBURST       , -- I/O : 
            ARLOCK          => C_ARLOCK        , -- I/O : 
            ARCACHE         => C_ARCACHE       , -- I/O : 
            ARPROT          => C_ARPROT        , -- I/O : 
            ARQOS           => C_ARQOS         , -- I/O : 
            ARREGION        => C_ARREGION      , -- I/O : 
            ARUSER          => C_ARUSER        , -- I/O : 
            ARID            => C_ARID          , -- I/O : 
            ARVALID         => C_ARVALID       , -- I/O : 
            ARREADY         => C_ARREADY       , -- In  :    
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => C_RLAST         , -- In  :    
            RDATA           => C_RDATA         , -- In  :    
            RRESP           => C_RRESP         , -- In  :    
            RUSER           => C_RUSER         , -- In  :    
            RID             => C_RID           , -- In  :    
            RVALID          => C_RVALID        , -- In  :    
            RREADY          => C_RREADY        , -- I/O : 
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => C_AWADDR        , -- I/O : 
            AWLEN           => C_AWLEN         , -- I/O : 
            AWSIZE          => C_AWSIZE        , -- I/O : 
            AWBURST         => C_AWBURST       , -- I/O : 
            AWLOCK          => C_AWLOCK        , -- I/O : 
            AWCACHE         => C_AWCACHE       , -- I/O : 
            AWPROT          => C_AWPROT        , -- I/O : 
            AWQOS           => C_AWQOS         , -- I/O : 
            AWREGION        => C_AWREGION      , -- I/O : 
            AWUSER          => C_AWUSER        , -- I/O : 
            AWID            => C_AWID          , -- I/O : 
            AWVALID         => C_AWVALID       , -- I/O : 
            AWREADY         => C_AWREADY       , -- In  :    
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => C_WLAST         , -- I/O : 
            WDATA           => C_WDATA         , -- I/O : 
            WSTRB           => C_WSTRB         , -- I/O : 
            WUSER           => C_WUSER         , -- I/O : 
            WID             => C_WID           , -- I/O : 
            WVALID          => C_WVALID        , -- I/O : 
            WREADY          => C_WREADY        , -- In  :    
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => C_BRESP         , -- In  :    
            BUSER           => C_BUSER         , -- In  :    
            BID             => C_BID           , -- In  :    
            BVALID          => C_BVALID        , -- In  :    
            BREADY          => C_BREADY        , -- I/O : 
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => C_GPI           , -- In  :
            GPO             => C_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => C_REPORT        , -- Out :
            FINISH          => C_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_SLAVE_PLAYER
    ------------------------------------------------------------------------------
    O: AXI4_SLAVE_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "O"             ,
            READ_ENABLE     => TRUE            ,
            WRITE_ENABLE    => TRUE            ,
            OUTPUT_DELAY    => DELAY           ,
            WIDTH           => O_WIDTH         ,
            SYNC_PLUG_NUM   => 3               ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => O_CLK           , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => O_ARADDR        , -- In  :    
            ARLEN           => O_ARLEN         , -- In  :    
            ARSIZE          => O_ARSIZE        , -- In  :    
            ARBURST         => O_ARBURST       , -- In  :    
            ARLOCK          => O_ARLOCK        , -- In  :    
            ARCACHE         => O_ARCACHE       , -- In  :    
            ARPROT          => O_ARPROT        , -- In  :    
            ARQOS           => O_ARQOS         , -- In  :    
            ARREGION        => O_ARREGION      , -- In  :    
            ARUSER          => O_ARUSER        , -- In  :    
            ARID            => O_ARID          , -- In  :    
            ARVALID         => O_ARVALID       , -- In  :    
            ARREADY         => O_ARREADY       , -- I/O : 
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => O_RLAST         , -- I/O : 
            RDATA           => O_RDATA         , -- I/O : 
            RRESP           => O_RRESP         , -- I/O : 
            RUSER           => O_RUSER         , -- I/O : 
            RID             => O_RID           , -- I/O : 
            RVALID          => O_RVALID        , -- I/O : 
            RREADY          => O_RREADY        , -- In  :    
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            AWADDR          => O_AWADDR        , -- In  :    
            AWLEN           => O_AWLEN         , -- In  :    
            AWSIZE          => O_AWSIZE        , -- In  :    
            AWBURST         => O_AWBURST       , -- In  :    
            AWLOCK          => O_AWLOCK        , -- In  :    
            AWCACHE         => O_AWCACHE       , -- In  :    
            AWPROT          => O_AWPROT        , -- In  :    
            AWQOS           => O_AWQOS         , -- In  :    
            AWREGION        => O_AWREGION      , -- In  :    
            AWUSER          => O_AWUSER        , -- In  :    
            AWID            => O_AWID          , -- In  :    
            AWVALID         => O_AWVALID       , -- In  :    
            AWREADY         => O_AWREADY       , -- I/O : 
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
            WLAST           => O_WLAST         , -- In  :    
            WDATA           => O_WDATA         , -- In  :    
            WSTRB           => O_WSTRB         , -- In  :    
            WUSER           => O_WUSER         , -- In  :    
            WID             => O_WID           , -- In  :    
            WVALID          => O_WVALID        , -- In  :    
            WREADY          => O_WREADY        , -- I/O : 
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => O_BRESP         , -- I/O : 
            BUSER           => O_BUSER         , -- I/O : 
            BID             => O_BID           , -- I/O : 
            BVALID          => O_BVALID        , -- I/O : 
            BREADY          => O_BREADY        , -- In  :    
        ---------------------------------------------------------------------------
        -- シンクロ用信号
        ---------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => O_GPI           , -- In  :
            GPO             => O_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => O_REPORT        , -- Out :
            FINISH          => O_FINISH          -- Out :
    );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I: AXI4_STREAM_MASTER_PLAYER                 -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --
            NAME            => "I"             , --
            OUTPUT_DELAY    => DELAY           , --
            SYNC_PLUG_NUM   => 4               , --
            WIDTH           => I_WIDTH         , --
            SYNC_WIDTH      => SYNC_WIDTH      , --
            GPI_WIDTH       => GPI_WIDTH       , --
            GPO_WIDTH       => GPO_WIDTH       , --
            FINISH_ABORT    => FALSE             --
        )                                        -- 
        port map(                                -- 
            ACLK            => I_CLK           , -- In  :
            ARESETn         => ARESETn         , -- In  :
            TDATA           => I_TDATA         , -- I/O :
            TSTRB           => I_TSTRB         , -- I/O :
            TKEEP           => I_TKEEP         , -- I/O :
            TUSER           => I_TUSER         , -- I/O :
            TDEST           => I_TDEST         , -- I/O :
            TID             => I_TID           , -- I/O :
            TLAST           => I_TLAST         , -- I/O :
            TVALID          => I_TVALID        , -- I/O :
            TREADY          => I_TREADY        , -- In  :
            SYNC            => SYNC            , -- I/O :
            GPI             => I_GPI           , -- In  :
            GPO             => I_GPO           , -- Out :
            REPORT_STATUS   => I_REPORT        , -- Out :
            FINISH          => I_FINISH          -- Out :
        );                                       --
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    CLK_SYNC: if (I_CLK_RATE = 1 and O_CLK_RATE = 1) generate
        process begin
            loop
                I_CLK <= '0'; 
                O_CLK <= '0'; wait for O_PERIOD / 2;
                I_CLK <= '1'; 
                O_CLK <= '1'; wait for O_PERIOD / 2;
                exit when(C_FINISH = '1');
            end loop;
            I_CLK <= '0';
            O_CLK <= '0';
            wait;
        end process;
    end generate;
    CLK_ASYNC: if (I_CLK_RATE /= 1 or O_CLK_RATE /= 1) generate
        process begin
            loop
                I_CLK  <= '0'; wait for I_PERIOD / 2;
                I_CLK  <= '1'; wait for I_PERIOD / 2;
                exit when(C_FINISH = '1');
            end loop;
            I_CLK  <= '0';
            wait;
        end process;
        process begin
            loop
                O_CLK  <= '0'; wait for O_PERIOD / 2;
                O_CLK  <= '1'; wait for O_PERIOD / 2;
                exit when(C_FINISH = '1');
            end loop;
            O_CLK  <= '0';
            wait;
        end process;
    end generate;

    ARESETn  <= '1' when (RESET = '0') else '0';
    C_GPI(0) <= IRQ;
    C_GPI(C_GPI'high downto 1) <= (C_GPI'high downto 1 => '0');
    O_GPI    <= (others => '0');
    I_GPI(0) <= I_O2I_STOP;
    I_GPI(1) <= I_O2I_RESET;
    I_GPI(2) <= I_O2I_ERROR;
    I_GPI(3) <= I_O2I_NONE;
    I_GPI(I_GPI'high downto 4) <= (I_GPI'high downto 4 => '0');
    I_I2O_STOP <= I_GPO(0);
        
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        wait until (C_FINISH'event and C_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ CSR ]");                                       WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,C_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,C_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,C_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ IN ]");                                        WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,I_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,I_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,I_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ OUT ]");                                       WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,O_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,O_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,O_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert (C_REPORT.error_count    = 0 and
                I_REPORT.error_count    = 0 and
                O_REPORT.error_count    = 0)
            report "Simulation complete(error)."    severity FAILURE;
        assert (C_REPORT.mismatch_count = 0 and
                I_REPORT.mismatch_count = 0 and
                O_REPORT.mismatch_count = 0)
            report "Simulation complete(mismatch)." severity FAILURE;
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete(success)."  severity FAILURE;
        else
            assert FALSE report "Simulation complete(success)."  severity NOTE;
        end if;
        wait;
    end process;
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  AXI4_S2M_TB_32_32_256_SYNC is
    generic (
        NAME            : STRING  := "AXI4_STREAM_TO_MASTER_TEST_BENCH_32_32_256_SYNC";
        SCENARIO_FILE   : STRING  := "axi4_stream_to_master_test_bench_32_32_256.snr";
        FINISH_ABORT    : boolean := FALSE
    );
end     AXI4_S2M_TB_32_32_256_SYNC;
architecture MODEL of AXI4_S2M_TB_32_32_256_SYNC is
begin
    TB: entity work.AXI4_STREAM_TO_MASTER_TEST_BENCH
        generic map (
            NAME            => NAME            , -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --   
            I_DATA_WIDTH    => 32              , --   
            O_DATA_WIDTH    => 32              , --   
            I_CLK_RATE      => 1               , --   
            O_CLK_RATE      => 1               , --   
            I_PERIOD        => 10 ns           , --   
            O_PERIOD        => 10 ns           , --   
            MAX_XFER_SIZE   => 8               , --   
            BUF_WIDTH       => 32              , --   
            BUF_DEPTH       => 16              , --   
            FINISH_ABORT    => FINISH_ABORT      --   
        );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  AXI4_S2M_TB_32_64_256_SYNC is
    generic (
        NAME            : STRING  := "AXI4_STREAM_TO_MASTER_TEST_BENCH_32_64_256_SYNC";
        SCENARIO_FILE   : STRING  := "axi4_stream_to_master_test_bench_32_64_256.snr";
        FINISH_ABORT    : boolean := FALSE
    );
end     AXI4_S2M_TB_32_64_256_SYNC;
architecture MODEL of AXI4_S2M_TB_32_64_256_SYNC is
begin
    TB: entity work.AXI4_STREAM_TO_MASTER_TEST_BENCH
        generic map (
            NAME            => NAME            , -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --   
            O_DATA_WIDTH    => 32              , --   
            I_DATA_WIDTH    => 64              , --   
            O_CLK_RATE      => 1               , --   
            I_CLK_RATE      => 1               , --   
            O_PERIOD        => 10 ns           , --   
            I_PERIOD        => 10 ns           , --   
            MAX_XFER_SIZE   => 8               , --   
            BUF_WIDTH       => 64              , --   
            BUF_DEPTH       => 16              , --   
            FINISH_ABORT    => FINISH_ABORT      --   
        );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  AXI4_S2M_TB_64_32_256_SYNC is
    generic (
        NAME            : STRING  := "AXI4_STREAM_TO_MASTER_TEST_BENCH_64_32_256_SYNC";
        SCENARIO_FILE   : STRING  := "axi4_stream_to_master_test_bench_64_32_256.snr";
        FINISH_ABORT    : boolean := FALSE
    );
end     AXI4_S2M_TB_64_32_256_SYNC;
architecture MODEL of AXI4_S2M_TB_64_32_256_SYNC is
begin
    TB: entity work.AXI4_STREAM_TO_MASTER_TEST_BENCH
        generic map (
            NAME            => NAME            , -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --   
            O_DATA_WIDTH    => 64              , --   
            I_DATA_WIDTH    => 32              , --   
            O_CLK_RATE      => 1               , --   
            I_CLK_RATE      => 1               , --   
            O_PERIOD        => 10 ns           , --   
            I_PERIOD        => 10 ns           , --   
            MAX_XFER_SIZE   => 8               , --   
            BUF_WIDTH       => 64              , --   
            BUF_DEPTH       => 16              , --   
            FINISH_ABORT    => FINISH_ABORT      --   
        );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  AXI4_S2M_TB_64_64_256_SYNC is
    generic (
        NAME            : STRING  := "AXI4_STREAM_TO_MASTER_TEST_BENCH_64_64_256_SYNC";
        SCENARIO_FILE   : STRING  := "axi4_stream_to_master_test_bench_64_64_256.snr";
        FINISH_ABORT    : boolean := FALSE
    );
end     AXI4_S2M_TB_64_64_256_SYNC;
architecture MODEL of AXI4_S2M_TB_64_64_256_SYNC is
begin
    TB: entity work.AXI4_STREAM_TO_MASTER_TEST_BENCH
        generic map (
            NAME            => NAME            , -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --   
            O_DATA_WIDTH    => 64              , --   
            I_DATA_WIDTH    => 64              , --   
            O_CLK_RATE      => 1               , --   
            I_CLK_RATE      => 1               , --   
            O_PERIOD        => 10 ns           , --   
            I_PERIOD        => 10 ns           , --   
            MAX_XFER_SIZE   => 8               , --   
            BUF_WIDTH       => 64              , --   
            BUF_DEPTH       => 16              , --   
            FINISH_ABORT    => FINISH_ABORT      --   
        );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  AXI4_S2M_TB_32_32_256_100MHz_250MHz is
    generic (
        NAME            : STRING  := "AXI4_STREAM_TO_MASTER_TEST_BENCH_32_32_256_100MHz_250MHz";
        SCENARIO_FILE   : STRING  := "axi4_stream_to_master_test_bench_32_32_256.snr";
        FINISH_ABORT    : boolean := FALSE
    );
end     AXI4_S2M_TB_32_32_256_100MHz_250MHz;
architecture MODEL of AXI4_S2M_TB_32_32_256_100MHz_250MHz is
begin
    TB: entity work.AXI4_STREAM_TO_MASTER_TEST_BENCH
        generic map (
            NAME            => NAME            , -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --   
            O_DATA_WIDTH    => 32              , --   
            I_DATA_WIDTH    => 32              , --   
            O_CLK_RATE      => 0               , --   
            I_CLK_RATE      => 0               , --   
            O_PERIOD        => 10 ns           , --   
            I_PERIOD        =>  4 ns           , --   
            MAX_XFER_SIZE   => 8               , --   
            BUF_WIDTH       => 32              , --   
            BUF_DEPTH       => 16              , --   
            FINISH_ABORT    => FINISH_ABORT      --   
        );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  AXI4_S2M_TB_32_32_256_250MHz_100MHz is
    generic (
        NAME            : STRING  := "AXI4_STREAM_TO_MASTER_TEST_BENCH_32_32_256_250MHz_100MHz";
        SCENARIO_FILE   : STRING  := "axi4_stream_to_master_test_bench_32_32_256.snr";
        FINISH_ABORT    : boolean := FALSE
    );
end     AXI4_S2M_TB_32_32_256_250MHz_100MHz;
architecture MODEL of AXI4_S2M_TB_32_32_256_250MHz_100MHz is
begin
    TB: entity work.AXI4_STREAM_TO_MASTER_TEST_BENCH
        generic map (
            NAME            => NAME            , -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --   
            O_DATA_WIDTH    => 32              , --   
            I_DATA_WIDTH    => 32              , --   
            O_CLK_RATE      => 0               , --   
            I_CLK_RATE      => 0               , --   
            O_PERIOD        =>  4 ns           , --   
            I_PERIOD        => 10 ns           , --   
            MAX_XFER_SIZE   => 8               , --   
            BUF_WIDTH       => 32              , --   
            BUF_DEPTH       => 16              , --   
            FINISH_ABORT    => FINISH_ABORT      --   
        );
end MODEL;
