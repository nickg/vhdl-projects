-----------------------------------------------------------------------------------
--!     @file    aix4_adapter_test_bench.vhd
--!     @brief   AXI4_ADPATER TEST BENCH
--!     @version 1.8.2
--!     @date    2020/10/7
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
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
package AXI4_ADAPTER_TEST_BENCH_COMPONENTS is
component  AXI4_ADAPTER_TEST_BENCH
    generic (
        NAME            : STRING  := "test";
        SCENARIO_FILE   : STRING  := "test.snr";
        T_CLK_RATE      : integer := 1;
        T_CLK_PERIOD    : time    := 10 ns;
        M_CLK_RATE      : integer := 1;
        M_CLK_PERIOD    : time    := 10 ns;
        T_DATA_WIDTH    : integer := 32;
        M_DATA_WIDTH    : integer := 32;
        M_MAX_XFER_SIZE : integer := 12;
        FINISH_ABORT    : boolean := FALSE
    );
end component;
end package;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  AXI4_ADAPTER_TEST_BENCH is
    generic (
        NAME            : STRING  := "test";
        SCENARIO_FILE   : STRING  := "test.snr";
        T_CLK_RATE      : integer := 1;
        T_CLK_PERIOD    : time    := 10 ns;
        M_CLK_RATE      : integer := 1;
        M_CLK_PERIOD    : time    := 10 ns;
        T_DATA_WIDTH    : integer := 32;
        M_DATA_WIDTH    : integer := 32;
        M_MAX_XFER_SIZE : integer := 12;
        FINISH_ABORT    : boolean := FALSE
    );
end     AXI4_ADAPTER_TEST_BENCH;
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
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SIGNAL_PRINTER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.SDPRAM;
architecture MODEL of AXI4_ADAPTER_TEST_BENCH is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant M_DELAY         : time    := M_CLK_PERIOD*0.1;
    constant T_DELAY         : time    := T_CLK_PERIOD*0.1;
    constant AXI4_ADDR_WIDTH : integer := 32;
    constant AXI4_ID_WIDTH   : integer :=  4;
    constant AXI4_AUSER_WIDTH: integer :=  4;
    constant M_WIDTH         : AXI4_SIGNAL_WIDTH_TYPE := (
                                 ID          => AXI4_ID_WIDTH,
                                 AWADDR      => AXI4_ADDR_WIDTH,
                                 ARADDR      => AXI4_ADDR_WIDTH,
                                 AWUSER      => AXI4_AUSER_WIDTH,
                                 ARUSER      => AXI4_AUSER_WIDTH,
                                 ALEN        => AXI4_ALEN_WIDTH,
                                 ALOCK       => AXI4_ALOCK_WIDTH,
                                 WDATA       => M_DATA_WIDTH,
                                 RDATA       => M_DATA_WIDTH,
                                 WUSER       => 1,
                                 RUSER       => 1,
                                 BUSER       => 1);
    constant T_WIDTH         : AXI4_SIGNAL_WIDTH_TYPE := (
                                 ID          => AXI4_ID_WIDTH,
                                 AWADDR      => AXI4_ADDR_WIDTH,
                                 ARADDR      => AXI4_ADDR_WIDTH,
                                 AWUSER      => AXI4_AUSER_WIDTH,
                                 ARUSER      => AXI4_AUSER_WIDTH,
                                 ALEN        => AXI4_ALEN_WIDTH,
                                 ALOCK       => AXI4_ALOCK_WIDTH,
                                 WDATA       => T_DATA_WIDTH,
                                 RDATA       => T_DATA_WIDTH,
                                 WUSER       => 1,
                                 RUSER       => 1,
                                 BUSER       => 1);
    constant SYNC_WIDTH      : integer :=  2;
    constant GPO_WIDTH       : integer :=  8;
    constant GPI_WIDTH       : integer :=  GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal   ARESETn         : std_logic;
    signal   RESET           : std_logic;
    signal   M_CLK           : std_logic;
    constant M_CLR           : std_logic := '0';
    signal   M_CKE           : std_logic := '1';
    signal   T_CLK           : std_logic;
    constant T_CLR           : std_logic := '0';
    signal   T_CKE           : std_logic := '1';
    ------------------------------------------------------------------------------
    -- リードアドレスチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   M_ARADDR        : std_logic_vector(M_WIDTH.ARADDR -1 downto 0);
    signal   M_ARWRITE       : std_logic;
    signal   M_ARLEN         : std_logic_vector(M_WIDTH.ALEN   -1 downto 0);
    signal   M_ARSIZE        : AXI4_ASIZE_TYPE;
    signal   M_ARBURST       : AXI4_ABURST_TYPE;
    signal   M_ARLOCK        : std_logic_vector(M_WIDTH.ALOCK  -1 downto 0);
    signal   M_ARCACHE       : AXI4_ACACHE_TYPE;
    signal   M_ARPROT        : AXI4_APROT_TYPE;
    signal   M_ARQOS         : AXI4_AQOS_TYPE;
    signal   M_ARREGION      : AXI4_AREGION_TYPE;
    signal   M_ARUSER        : std_logic_vector(M_WIDTH.ARUSER -1 downto 0);
    signal   M_ARID          : std_logic_vector(M_WIDTH.ID     -1 downto 0);
    signal   M_ARVALID       : std_logic;
    signal   M_ARREADY       : std_logic;
    -------------------------------------------------------------------------------
    -- リードデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   M_RVALID        : std_logic;
    signal   M_RLAST         : std_logic;
    signal   M_RDATA         : std_logic_vector(M_WIDTH.RDATA  -1 downto 0);
    signal   M_RRESP         : AXI4_RESP_TYPE;
    signal   M_RUSER         : std_logic_vector(M_WIDTH.RUSER  -1 downto 0);
    signal   M_RID           : std_logic_vector(M_WIDTH.ID     -1 downto 0);
    signal   M_RREADY        : std_logic;
    -------------------------------------------------------------------------------
    -- ライトアドレスチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   M_AWADDR        : std_logic_vector(M_WIDTH.AWADDR -1 downto 0);
    signal   M_AWLEN         : std_logic_vector(M_WIDTH.ALEN   -1 downto 0);
    signal   M_AWSIZE        : AXI4_ASIZE_TYPE;
    signal   M_AWBURST       : AXI4_ABURST_TYPE;
    signal   M_AWLOCK        : std_logic_vector(M_WIDTH.ALOCK  -1 downto 0);
    signal   M_AWCACHE       : AXI4_ACACHE_TYPE;
    signal   M_AWPROT        : AXI4_APROT_TYPE;
    signal   M_AWQOS         : AXI4_AQOS_TYPE;
    signal   M_AWREGION      : AXI4_AREGION_TYPE;
    signal   M_AWUSER        : std_logic_vector(M_WIDTH.AWUSER -1 downto 0);
    signal   M_AWID          : std_logic_vector(M_WIDTH.ID     -1 downto 0);
    signal   M_AWVALID       : std_logic;
    signal   M_AWREADY       : std_logic;
    -------------------------------------------------------------------------------
    -- ライトデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   M_WLAST         : std_logic;
    signal   M_WDATA         : std_logic_vector(M_WIDTH.WDATA  -1 downto 0);
    signal   M_WSTRB         : std_logic_vector(M_WIDTH.WDATA/8-1 downto 0);
    signal   M_WUSER         : std_logic_vector(M_WIDTH.WUSER  -1 downto 0);
    signal   M_WID           : std_logic_vector(M_WIDTH.ID     -1 downto 0);
    signal   M_WVALID        : std_logic;
    signal   M_WREADY        : std_logic;
    -------------------------------------------------------------------------------
    -- ライト応答チャネルシグナル.
    -------------------------------------------------------------------------------
    signal   M_BRESP         : AXI4_RESP_TYPE;
    signal   M_BUSER         : std_logic_vector(M_WIDTH.BUSER  -1 downto 0);
    signal   M_BID           : std_logic_vector(M_WIDTH.ID     -1 downto 0);
    signal   M_BVALID        : std_logic;
    signal   M_BREADY        : std_logic;
    ------------------------------------------------------------------------------
    -- リードアドレスチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   T_ARADDR        : std_logic_vector(T_WIDTH.ARADDR -1 downto 0);
    signal   T_ARLEN         : std_logic_vector(T_WIDTH.ALEN   -1 downto 0);
    signal   T_ARSIZE        : AXI4_ASIZE_TYPE;
    signal   T_ARBURST       : AXI4_ABURST_TYPE;
    signal   T_ARLOCK        : std_logic_vector(T_WIDTH.ALOCK  -1 downto 0);
    signal   T_ARCACHE       : AXI4_ACACHE_TYPE;
    signal   T_ARPROT        : AXI4_APROT_TYPE;
    signal   T_ARQOS         : AXI4_AQOS_TYPE;
    signal   T_ARREGION      : AXI4_AREGION_TYPE;
    signal   T_ARUSER        : std_logic_vector(T_WIDTH.ARUSER -1 downto 0);
    signal   T_ARID          : std_logic_vector(T_WIDTH.ID     -1 downto 0);
    signal   T_ARVALID       : std_logic;
    signal   T_ARREADY       : std_logic;
    -------------------------------------------------------------------------------
    -- リードデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   T_RVALID        : std_logic;
    signal   T_RLAST         : std_logic;
    signal   T_RDATA         : std_logic_vector(T_WIDTH.RDATA  -1 downto 0);
    signal   T_RRESP         : AXI4_RESP_TYPE;
    signal   T_RUSER         : std_logic_vector(T_WIDTH.RUSER  -1 downto 0);
    signal   T_RID           : std_logic_vector(T_WIDTH.ID     -1 downto 0);
    signal   T_RREADY        : std_logic;
    -------------------------------------------------------------------------------
    -- ライトアドレスチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   T_AWADDR        : std_logic_vector(T_WIDTH.AWADDR -1 downto 0);
    signal   T_AWLEN         : std_logic_vector(T_WIDTH.ALEN   -1 downto 0);
    signal   T_AWSIZE        : AXI4_ASIZE_TYPE;
    signal   T_AWBURST       : AXI4_ABURST_TYPE;
    signal   T_AWLOCK        : std_logic_vector(T_WIDTH.ALOCK  -1 downto 0);
    signal   T_AWCACHE       : AXI4_ACACHE_TYPE;
    signal   T_AWPROT        : AXI4_APROT_TYPE;
    signal   T_AWQOS         : AXI4_AQOS_TYPE;
    signal   T_AWREGION      : AXI4_AREGION_TYPE;
    signal   T_AWUSER        : std_logic_vector(T_WIDTH.AWUSER -1 downto 0);
    signal   T_AWID          : std_logic_vector(T_WIDTH.ID     -1 downto 0);
    signal   T_AWVALID       : std_logic;
    signal   T_AWREADY       : std_logic;
    -------------------------------------------------------------------------------
    -- ライトデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   T_WLAST         : std_logic;
    signal   T_WDATA         : std_logic_vector(T_WIDTH.WDATA  -1 downto 0);
    signal   T_WSTRB         : std_logic_vector(T_WIDTH.WDATA/8-1 downto 0);
    signal   T_WUSER         : std_logic_vector(T_WIDTH.WUSER  -1 downto 0);
    signal   T_WID           : std_logic_vector(T_WIDTH.ID     -1 downto 0);
    signal   T_WVALID        : std_logic;
    signal   T_WREADY        : std_logic;
    -------------------------------------------------------------------------------
    -- ライト応答チャネルシグナル.
    -------------------------------------------------------------------------------
    signal   T_BRESP         : AXI4_RESP_TYPE;
    signal   T_BUSER         : std_logic_vector(T_WIDTH.BUSER  -1 downto 0);
    signal   T_BID           : std_logic_vector(T_WIDTH.ID     -1 downto 0);
    signal   T_BVALID        : std_logic;
    signal   T_BREADY        : std_logic;
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal   SYNC            : SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal   M_GPI           : std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal   M_GPO           : std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal   T_GPI           : std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal   T_GPO           : std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal   N_REPORT        : REPORT_STATUS_TYPE;
    signal   M_REPORT        : REPORT_STATUS_TYPE;
    signal   T_REPORT        : REPORT_STATUS_TYPE;
    signal   N_FINISH        : std_logic;
    signal   M_FINISH        : std_logic;
    signal   T_FINISH        : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    component AXI4_ADAPTER 
        generic (
            AXI4_ID_WIDTH       : integer range 1 to AXI4_ID_MAX_WIDTH;
            AXI4_AUSER_WIDTH    : integer := 1;
            AXI4_ADDR_WIDTH     : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
            T_CLK_RATE          : integer :=  1;
            T_DATA_WIDTH        : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
            M_CLK_RATE          : integer :=  1;
            M_DATA_WIDTH        : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
            M_MAX_XFER_SIZE     : integer := 12;
            BUF_DEPTH           : integer := 12;
            RDATA_REGS          : integer := 0;
            RESP_REGS           : integer := 0
        );
        port(
            RST                 : in    std_logic;
            T_CLK               : in    std_logic;
            T_CKE               : in    std_logic;
            T_CLR               : in    std_logic;
            T_AWID              : in    std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            T_AWUSER            : in    std_logic_vector(AXI4_AUSER_WIDTH-1 downto 0);
            T_AWADDR            : in    std_logic_vector(AXI4_ADDR_WIDTH -1 downto 0);
            T_AWLEN             : in    std_logic_vector(AXI4_ALEN_WIDTH -1 downto 0);
            T_AWSIZE            : in    AXI4_ASIZE_TYPE;
            T_AWBURST           : in    AXI4_ABURST_TYPE;
            T_AWLOCK            : in    std_logic_vector(AXI4_ALOCK_WIDTH-1 downto 0);
            T_AWCACHE           : in    AXI4_ACACHE_TYPE;
            T_AWPROT            : in    AXI4_APROT_TYPE;
            T_AWQOS             : in    AXI4_AQOS_TYPE;
            T_AWREGION          : in    AXI4_AREGION_TYPE;
            T_AWVALID           : in    std_logic;
            T_AWREADY           : out   std_logic;
            T_WDATA             : in    std_logic_vector(T_DATA_WIDTH    -1 downto 0);
            T_WSTRB             : in    std_logic_vector(T_DATA_WIDTH/8  -1 downto 0);
            T_WLAST             : in    std_logic;
            T_WVALID            : in    std_logic;
            T_WREADY            : out   std_logic;
            T_BID               : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            T_BRESP             : out   AXI4_RESP_TYPE;
            T_BVALID            : out   std_logic;
            T_BREADY            : in    std_logic;
            T_ARID              : in    std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            T_ARUSER            : in    std_logic_vector(AXI4_AUSER_WIDTH-1 downto 0);
            T_ARADDR            : in    std_logic_vector(AXI4_ADDR_WIDTH -1 downto 0);
            T_ARLEN             : in    std_logic_vector(AXI4_ALEN_WIDTH -1 downto 0);
            T_ARSIZE            : in    AXI4_ASIZE_TYPE;
            T_ARBURST           : in    AXI4_ABURST_TYPE;
            T_ARLOCK            : in    std_logic_vector(AXI4_ALOCK_WIDTH-1 downto 0);
            T_ARCACHE           : in    AXI4_ACACHE_TYPE;
            T_ARPROT            : in    AXI4_APROT_TYPE;
            T_ARQOS             : in    AXI4_AQOS_TYPE;
            T_ARREGION          : in    AXI4_AREGION_TYPE;
            T_ARVALID           : in    std_logic;
            T_ARREADY           : out   std_logic;
            T_RID               : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            T_RDATA             : out   std_logic_vector(T_DATA_WIDTH    -1 downto 0);
            T_RRESP             : out   AXI4_RESP_TYPE;
            T_RLAST             : out   std_logic;
            T_RVALID            : out   std_logic;
            T_RREADY            : in    std_logic;
            M_CLK               : in    std_logic;
            M_CKE               : in    std_logic;
            M_CLR               : in    std_logic;
            M_AWID              : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            M_AWUSER            : out   std_logic_vector(AXI4_AUSER_WIDTH-1 downto 0);
            M_AWADDR            : out   std_logic_vector(AXI4_ADDR_WIDTH -1 downto 0);
            M_AWLEN             : out   std_logic_vector(AXI4_ALEN_WIDTH -1 downto 0);
            M_AWSIZE            : out   AXI4_ASIZE_TYPE;
            M_AWBURST           : out   AXI4_ABURST_TYPE;
            M_AWLOCK            : out   std_logic_vector(AXI4_ALOCK_WIDTH-1 downto 0);
            M_AWCACHE           : out   AXI4_ACACHE_TYPE;
            M_AWPROT            : out   AXI4_APROT_TYPE;
            M_AWQOS             : out   AXI4_AQOS_TYPE;
            M_AWREGION          : out   AXI4_AREGION_TYPE;
            M_AWVALID           : out   std_logic;
            M_AWREADY           : in    std_logic;
            M_WID               : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            M_WDATA             : out   std_logic_vector(M_DATA_WIDTH    -1 downto 0);
            M_WSTRB             : out   std_logic_vector(M_DATA_WIDTH/8  -1 downto 0);
            M_WLAST             : out   std_logic;
            M_WVALID            : out   std_logic;
            M_WREADY            : in    std_logic;
            M_BID               : in    std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            M_BRESP             : in    AXI4_RESP_TYPE;
            M_BVALID            : in    std_logic;
            M_BREADY            : out   std_logic;
            M_ARID              : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            M_ARUSER            : out   std_logic_vector(AXI4_AUSER_WIDTH-1 downto 0);
            M_ARADDR            : out   std_logic_vector(AXI4_ADDR_WIDTH -1 downto 0);
            M_ARLEN             : out   std_logic_vector(AXI4_ALEN_WIDTH -1 downto 0);
            M_ARSIZE            : out   AXI4_ASIZE_TYPE;
            M_ARBURST           : out   AXI4_ABURST_TYPE;
            M_ARLOCK            : out   std_logic_vector(AXI4_ALOCK_WIDTH-1 downto 0);
            M_ARCACHE           : out   AXI4_ACACHE_TYPE;
            M_ARPROT            : out   AXI4_APROT_TYPE;
            M_ARQOS             : out   AXI4_AQOS_TYPE;
            M_ARREGION          : out   AXI4_AREGION_TYPE;
            M_ARVALID           : out   std_logic;
            M_ARREADY           : in    std_logic;
            M_RID               : in    std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            M_RDATA             : in    std_logic_vector(M_DATA_WIDTH    -1 downto 0);
            M_RRESP             : in    AXI4_RESP_TYPE;
            M_RLAST             : in    std_logic;
            M_RVALID            : in    std_logic;
            M_RREADY            : out   std_logic
        );
    end component;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "N",
            SYNC_PLUG_NUM   => 1,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
            CLK             => T_CLK           , -- In  :
            RESET           => RESET           , -- In  :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_MASTER_PLAYER
    ------------------------------------------------------------------------------
    T: AXI4_MASTER_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "T"             ,
            READ_ENABLE     => TRUE            ,
            WRITE_ENABLE    => TRUE            ,
            OUTPUT_DELAY    => T_DELAY         ,
            WIDTH           => T_WIDTH         ,
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
            ACLK            => T_CLK           , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => T_ARADDR        , -- I/O : 
            ARLEN           => T_ARLEN         , -- I/O : 
            ARSIZE          => T_ARSIZE        , -- I/O : 
            ARBURST         => T_ARBURST       , -- I/O : 
            ARLOCK          => T_ARLOCK        , -- I/O : 
            ARCACHE         => T_ARCACHE       , -- I/O : 
            ARPROT          => T_ARPROT        , -- I/O : 
            ARQOS           => T_ARQOS         , -- I/O : 
            ARREGION        => T_ARREGION      , -- I/O : 
            ARUSER          => T_ARUSER        , -- I/O : 
            ARID            => T_ARID          , -- I/O : 
            ARVALID         => T_ARVALID       , -- I/O : 
            ARREADY         => T_ARREADY       , -- In  :    
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => T_RLAST         , -- In  :    
            RDATA           => T_RDATA         , -- In  :    
            RRESP           => T_RRESP         , -- In  :    
            RUSER           => T_RUSER         , -- In  :    
            RID             => T_RID           , -- In  :    
            RVALID          => T_RVALID        , -- In  :    
            RREADY          => T_RREADY        , -- I/O : 
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => T_AWADDR        , -- I/O : 
            AWLEN           => T_AWLEN         , -- I/O : 
            AWSIZE          => T_AWSIZE        , -- I/O : 
            AWBURST         => T_AWBURST       , -- I/O : 
            AWLOCK          => T_AWLOCK        , -- I/O : 
            AWCACHE         => T_AWCACHE       , -- I/O : 
            AWPROT          => T_AWPROT        , -- I/O : 
            AWQOS           => T_AWQOS         , -- I/O : 
            AWREGION        => T_AWREGION      , -- I/O : 
            AWUSER          => T_AWUSER        , -- I/O : 
            AWID            => T_AWID          , -- I/O : 
            AWVALID         => T_AWVALID       , -- I/O : 
            AWREADY         => T_AWREADY       , -- In  :    
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => T_WLAST         , -- I/O : 
            WDATA           => T_WDATA         , -- I/O : 
            WSTRB           => T_WSTRB         , -- I/O : 
            WUSER           => T_WUSER         , -- I/O : 
            WID             => T_WID           , -- I/O : 
            WVALID          => T_WVALID        , -- I/O : 
            WREADY          => T_WREADY        , -- In  :    
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => T_BRESP         , -- In  :    
            BUSER           => T_BUSER         , -- In  :    
            BID             => T_BID           , -- In  :    
            BVALID          => T_BVALID        , -- In  :    
            BREADY          => T_BREADY        , -- I/O : 
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => T_GPI           , -- In  :
            GPO             => T_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => T_REPORT        , -- Out :
            FINISH          => T_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_SLAVE_PLAYER
    ------------------------------------------------------------------------------
    M: AXI4_SLAVE_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "M"             ,
            READ_ENABLE     => TRUE            ,
            WRITE_ENABLE    => TRUE            ,
            OUTPUT_DELAY    => M_DELAY         ,
            WIDTH           => M_WIDTH         ,
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
            ACLK            => M_CLK           , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => M_ARADDR        , -- In  : 
            ARLEN           => M_ARLEN         , -- In  : 
            ARSIZE          => M_ARSIZE        , -- In  : 
            ARBURST         => M_ARBURST       , -- In  : 
            ARLOCK          => M_ARLOCK        , -- In  : 
            ARCACHE         => M_ARCACHE       , -- In  : 
            ARPROT          => M_ARPROT        , -- In  : 
            ARQOS           => M_ARQOS         , -- In  : 
            ARREGION        => M_ARREGION      , -- In  : 
            ARUSER          => M_ARUSER        , -- In  : 
            ARID            => M_ARID          , -- In  : 
            ARVALID         => M_ARVALID       , -- In  : 
            ARREADY         => M_ARREADY       , -- I/O :    
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => M_RLAST         , -- I/O :    
            RDATA           => M_RDATA         , -- I/O :    
            RRESP           => M_RRESP         , -- I/O :    
            RUSER           => M_RUSER         , -- I/O :    
            RID             => M_RID           , -- I/O :    
            RVALID          => M_RVALID        , -- I/O :    
            RREADY          => M_RREADY        , -- In  : 
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => M_AWADDR        , -- In  : 
            AWLEN           => M_AWLEN         , -- In  : 
            AWSIZE          => M_AWSIZE        , -- In  : 
            AWBURST         => M_AWBURST       , -- In  : 
            AWLOCK          => M_AWLOCK        , -- In  : 
            AWCACHE         => M_AWCACHE       , -- In  : 
            AWPROT          => M_AWPROT        , -- In  : 
            AWQOS           => M_AWQOS         , -- In  : 
            AWREGION        => M_AWREGION      , -- In  : 
            AWUSER          => M_AWUSER        , -- In  : 
            AWID            => M_AWID          , -- In  : 
            AWVALID         => M_AWVALID       , -- In  : 
            AWREADY         => M_AWREADY       , -- I/O :    
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => M_WLAST         , -- In  : 
            WDATA           => M_WDATA         , -- In  : 
            WSTRB           => M_WSTRB         , -- In  : 
            WUSER           => M_WUSER         , -- In  : 
            WID             => M_WID           , -- In  : 
            WVALID          => M_WVALID        , -- In  : 
            WREADY          => M_WREADY        , -- I/O :    
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => M_BRESP         , -- I/O :    
            BUSER           => M_BUSER         , -- I/O :    
            BID             => M_BID           , -- I/O :    
            BVALID          => M_BVALID        , -- I/O :    
            BREADY          => M_BREADY        , -- In  : 
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => M_GPI           , -- In  :
            GPO             => M_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => M_REPORT        , -- Out :
            FINISH          => M_FINISH          -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DUT: AXI4_ADAPTER 
        generic map (
            AXI4_ID_WIDTH       => AXI4_ID_WIDTH       ,
            AXI4_AUSER_WIDTH    => AXI4_AUSER_WIDTH    ,
            AXI4_ADDR_WIDTH     => AXI4_ADDR_WIDTH     ,
            T_CLK_RATE          => T_CLK_RATE          ,
            T_DATA_WIDTH        => T_DATA_WIDTH        ,
            M_CLK_RATE          => M_CLK_RATE          ,
            M_DATA_WIDTH        => M_DATA_WIDTH        ,
            M_MAX_XFER_SIZE     => M_MAX_XFER_SIZE     ,
            BUF_DEPTH           => 12                  ,
            RDATA_REGS          => 3                   ,
            RESP_REGS           => 1
        )
        port map(
        --------------------------------------------------------------------------
        -- Reset Signals.
        --------------------------------------------------------------------------
            RST                 => RESET               , -- In  :
        --------------------------------------------------------------------------
        -- Responder Signals.
        --------------------------------------------------------------------------
            T_CLK               => T_CLK               , -- In  :
            T_CKE               => T_CKE               , -- In  :
            T_CLR               => T_CLR               , -- In  :
            T_AWID              => T_AWID              , -- In  :
            T_AWUSER            => T_AWUSER            , -- In  :
            T_AWADDR            => T_AWADDR            , -- In  :
            T_AWLEN             => T_AWLEN             , -- In  :
            T_AWSIZE            => T_AWSIZE            , -- In  :
            T_AWBURST           => T_AWBURST           , -- In  :
            T_AWLOCK            => T_AWLOCK            , -- In  :
            T_AWCACHE           => T_AWCACHE           , -- In  :
            T_AWPROT            => T_AWPROT            , -- In  :
            T_AWQOS             => T_AWQOS             , -- In  :
            T_AWREGION          => T_AWREGION          , -- In  :
            T_AWVALID           => T_AWVALID           , -- In  :
            T_AWREADY           => T_AWREADY           , -- Out :
            T_WDATA             => T_WDATA             , -- In  :
            T_WSTRB             => T_WSTRB             , -- In  :
            T_WLAST             => T_WLAST             , -- In  :
            T_WVALID            => T_WVALID            , -- In  :
            T_WREADY            => T_WREADY            , -- Out :
            T_BID               => T_BID               , -- Out :
            T_BRESP             => T_BRESP             , -- Out :
            T_BVALID            => T_BVALID            , -- Out :
            T_BREADY            => T_BREADY            , -- In  :
            T_ARID              => T_ARID              , -- In  :
            T_ARUSER            => T_ARUSER            , -- In  :
            T_ARADDR            => T_ARADDR            , -- In  :
            T_ARLEN             => T_ARLEN             , -- In  :
            T_ARSIZE            => T_ARSIZE            , -- In  :
            T_ARBURST           => T_ARBURST           , -- In  :
            T_ARLOCK            => T_ARLOCK            , -- In  :
            T_ARCACHE           => T_ARCACHE           , -- In  :
            T_ARPROT            => T_ARPROT            , -- In  :
            T_ARQOS             => T_ARQOS             , -- In  :
            T_ARREGION          => T_ARREGION          , -- In  :
            T_ARVALID           => T_ARVALID           , -- In  :
            T_ARREADY           => T_ARREADY           , -- Out :
            T_RID               => T_RID               , -- Out :
            T_RDATA             => T_RDATA             , -- Out :
            T_RRESP             => T_RRESP             , -- Out :
            T_RLAST             => T_RLAST             , -- Out :
            T_RVALID            => T_RVALID            , -- Out :
            T_RREADY            => T_RREADY            , -- In  :
        --------------------------------------------------------------------------
        -- Requester Signals.
        --------------------------------------------------------------------------
            M_CLK               => M_CLK               , -- In  :
            M_CKE               => M_CKE               , -- In  :
            M_CLR               => M_CLR               , -- In  :
            M_AWID              => M_AWID              , -- Out :
            M_AWUSER            => M_AWUSER            , -- Out :
            M_AWADDR            => M_AWADDR            , -- Out :
            M_AWLEN             => M_AWLEN             , -- Out :
            M_AWSIZE            => M_AWSIZE            , -- Out :
            M_AWBURST           => M_AWBURST           , -- Out :
            M_AWLOCK            => M_AWLOCK            , -- Out :
            M_AWCACHE           => M_AWCACHE           , -- Out :
            M_AWPROT            => M_AWPROT            , -- Out :
            M_AWQOS             => M_AWQOS             , -- Out :
            M_AWREGION          => M_AWREGION          , -- Out :
            M_AWVALID           => M_AWVALID           , -- Out :
            M_AWREADY           => M_AWREADY           , -- In  :
            M_WID               => M_WID               , -- Out :
            M_WDATA             => M_WDATA             , -- Out :
            M_WSTRB             => M_WSTRB             , -- Out :
            M_WLAST             => M_WLAST             , -- Out :
            M_WVALID            => M_WVALID            , -- Out :
            M_WREADY            => M_WREADY            , -- In  :
            M_BID               => M_BID               , -- In  :
            M_BRESP             => M_BRESP             , -- In  :
            M_BVALID            => M_BVALID            , -- In  :
            M_BREADY            => M_BREADY            , -- Out :
            M_ARID              => M_ARID              , -- Out :
            M_ARUSER            => M_ARUSER            , -- Out :
            M_ARADDR            => M_ARADDR            , -- Out :
            M_ARLEN             => M_ARLEN             , -- Out :
            M_ARSIZE            => M_ARSIZE            , -- Out :
            M_ARBURST           => M_ARBURST           , -- Out :
            M_ARLOCK            => M_ARLOCK            , -- Out :
            M_ARCACHE           => M_ARCACHE           , -- Out :
            M_ARPROT            => M_ARPROT            , -- Out :
            M_ARQOS             => M_ARQOS             , -- Out :
            M_ARREGION          => M_ARREGION          , -- Out :
            M_ARVALID           => M_ARVALID           , -- Out :
            M_ARREADY           => M_ARREADY           , -- In  :
            M_RID               => M_RID               , -- In  :
            M_RDATA             => M_RDATA             , -- In  :
            M_RRESP             => M_RRESP             , -- In  :
            M_RLAST             => M_RLAST             , -- In  :
            M_RVALID            => M_RVALID            , -- In  :
            M_RREADY            => M_RREADY              -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    ASYNC: if (M_CLK_RATE = 0 and T_CLK_RATE = 0) generate
        process begin
            loop
                M_CLK <= '1'; wait for M_CLK_PERIOD/2;
                M_CLK <= '0'; wait for M_CLK_PERIOD/2;
                exit when (M_FINISH = '1');
            end loop;
            M_CLK <= '0';
            wait;
        end process;
        process begin
            loop
                T_CLK <= '1'; wait for T_CLK_PERIOD/2;
                T_CLK <= '0'; wait for T_CLK_PERIOD/2;
                exit when (T_FINISH = '1');
            end loop;
            T_CLK <= '0';
            wait;
        end process;
        M_CKE <= '1';
        T_CKE <= '1';
    end generate;
    TSYNC: if (T_CLK_RATE >= 1 and M_CLK_RATE = 1) generate
        process begin
            T_CLK <= '0';
            T_CKE <= '1';
            M_CLK <= '0';
            M_CKE <= '1';
            MAIN_LOOP : loop 
                for i in 1 to T_CLK_RATE loop
                    wait for M_CLK_PERIOD/(T_CLK_RATE*2);
                    M_CLK <= '1';
                    T_CLK <= not T_CLK;
                    if (i = 1) then
                        T_CKE <= '1';
                    else
                        T_CKE <= '0';
                    end if;
                end loop;
                for i in 1 to T_CLK_RATE loop
                    wait for M_CLK_PERIOD/(T_CLK_RATE*2);
                    M_CLK <= '0';
                    T_CLK <= not T_CLK;
                    if (i = T_CLK_RATE) then
                        T_CKE <= '1';
                    else
                        T_CKE <= '0';
                    end if;
                end loop;
                exit when (T_FINISH = '1');
            end loop;
            T_CLK <= '0';
            T_CKE <= '1';
            M_CLK <= '0';
            M_CKE <= '1';
            wait;
        end process;
    end generate;
    RSYNC: if (T_CLK_RATE = 1 and M_CLK_RATE >= 2) generate
        process begin
            T_CLK <= '0';
            T_CKE <= '1';
            M_CLK <= '0';
            M_CKE <= '1';
            MAIN_LOOP : loop 
                for i in 1 to M_CLK_RATE loop
                    wait for T_CLK_PERIOD/(M_CLK_RATE*2);
                    T_CLK <= '1';
                    M_CLK <= not M_CLK;
                    if (i = 1) then
                        M_CKE <= '1';
                    else
                        M_CKE <= '0';
                    end if;
                end loop;
                for i in 1 to M_CLK_RATE loop
                    wait for T_CLK_PERIOD/(M_CLK_RATE*2);
                    T_CLK <= '0';
                    M_CLK <= not M_CLK;
                    if (i = M_CLK_RATE) then
                        M_CKE <= '1';
                    else
                        M_CKE <= '0';
                    end if;
                end loop;
                exit when (T_FINISH = '1');
            end loop;
            T_CLK <= '0';
            T_CKE <= '1';
            M_CLK <= '0';
            M_CKE <= '1';
            wait;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    ARESETn <= '1' when (RESET = '0') else '0';
    T_GPI   <= T_GPO;
    M_GPI   <= T_GPO;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        wait until (T_FINISH'event and T_FINISH = '1');
        wait for T_DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ RESPONDER SIDE ]");                            WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,T_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,T_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,T_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ REQUESTER SIDE ]");                            WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,M_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,M_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,M_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert (T_REPORT.error_count    = 0 and
                M_REPORT.error_count    = 0)
            report "Simulation complete(error)." severity FAILURE;
        assert (T_REPORT.mismatch_count = 0 and
                M_REPORT.mismatch_count = 0)
            report "Simulation complete(mismatch)." severity FAILURE;
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete(success)."  severity FAILURE;
        else
            assert FALSE report "Simulation complete(success)."  severity NOTE;
        end if;
        wait;
    end process;
    
 -- SYNC_PRINT_0: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(0)")) port map (SYNC(0));
 -- SYNC_PRINT_1: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(1)")) port map (SYNC(1));
end MODEL;
