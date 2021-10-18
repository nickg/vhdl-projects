-----------------------------------------------------------------------------------
--!     @file    axi4_models.vhd                                                 --
--!     @brief   AXI4 Dummy Plug Component Package                               --
--!     @version 1.7.7                                                           --
--!     @date    2021/10/17                                                      --
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
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_SIG_VECTOR;
-----------------------------------------------------------------------------------
--! @brief AXI4 Dummy Plug Component Package                                     --
-----------------------------------------------------------------------------------
package AXI4_MODELS is
-----------------------------------------------------------------------------------
--! @brief AXI4_MASTER_PLAYER                                                    --
-----------------------------------------------------------------------------------
component AXI4_MASTER_PLAYER
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        READ_ENABLE     : --! @brief リードトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        WRITE_ENABLE    : --! @brief ライトトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time    := 0 ns;
        WIDTH           : --! @brief AXI4 チャネルの可変長信号のビット幅.
                          AXI4_SIGNAL_WIDTH_TYPE;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        DEFAULT_SYNC_IO : --! @brief リードトランザクション/ライトトランザクション
                          --         ウェイト時に完了を待ってから次のコマンドを実行
                          --         するか否かを指定する.
                          boolean := true;
        GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                          integer := 8;
        GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                          integer := 8;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        --------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        ARADDR          : inout std_logic_vector(WIDTH.ARADDR -1 downto 0);
        ARLEN           : inout std_logic_vector(WIDTH.ALEN   -1 downto 0);
        ARSIZE          : inout AXI4_ASIZE_TYPE;
        ARBURST         : inout AXI4_ABURST_TYPE;
        ARLOCK          : inout std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        ARCACHE         : inout AXI4_ACACHE_TYPE;
        ARPROT          : inout AXI4_APROT_TYPE;
        ARQOS           : inout AXI4_AQOS_TYPE;
        ARREGION        : inout AXI4_AREGION_TYPE;
        ARUSER          : inout std_logic_vector(WIDTH.ARUSER -1 downto 0);
        ARID            : inout std_logic_vector(WIDTH.ID     -1 downto 0);
        ARVALID         : inout std_logic;
        ARREADY         : in    std_logic;
        --------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        --------------------------------------------------------------------------
        RLAST           : in    std_logic;
        RDATA           : in    std_logic_vector(WIDTH.RDATA  -1 downto 0);
        RRESP           : in    AXI4_RESP_TYPE;
        RUSER           : in    std_logic_vector(WIDTH.RUSER  -1 downto 0);
        RID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        RVALID          : in    std_logic;
        RREADY          : inout std_logic;
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        AWADDR          : inout std_logic_vector(WIDTH.AWADDR -1 downto 0);
        AWLEN           : inout std_logic_vector(WIDTH.ALEN   -1 downto 0);
        AWSIZE          : inout AXI4_ASIZE_TYPE;
        AWBURST         : inout AXI4_ABURST_TYPE;
        AWLOCK          : inout std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        AWCACHE         : inout AXI4_ACACHE_TYPE;
        AWPROT          : inout AXI4_APROT_TYPE;
        AWQOS           : inout AXI4_AQOS_TYPE;
        AWREGION        : inout AXI4_AREGION_TYPE;
        AWUSER          : inout std_logic_vector(WIDTH.AWUSER -1 downto 0);
        AWID            : inout std_logic_vector(WIDTH.ID     -1 downto 0);
        AWVALID         : inout std_logic;
        AWREADY         : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
        WLAST           : inout std_logic;
        WDATA           : inout std_logic_vector(WIDTH.WDATA  -1 downto 0);
        WSTRB           : inout std_logic_vector(WIDTH.WDATA/8-1 downto 0);
        WUSER           : inout std_logic_vector(WIDTH.WUSER  -1 downto 0);
        WID             : inout std_logic_vector(WIDTH.ID     -1 downto 0);
        WVALID          : inout std_logic;
        WREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BRESP           : in    AXI4_RESP_TYPE;
        BUSER           : in    std_logic_vector(WIDTH.BUSER  -1 downto 0);
        BID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        BVALID          : in    std_logic;
        BREADY          : inout std_logic;
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
        --------------------------------------------------------------------------
        -- General Purpose Input 信号
        --------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH    -1 downto 0) := (others => '0');
        --------------------------------------------------------------------------
        -- General Purpose Output 信号
        --------------------------------------------------------------------------
        GPO             : out   std_logic_vector(GPO_WIDTH    -1 downto 0);
        --------------------------------------------------------------------------
        -- レポートステータス出力.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        -- シミュレーション終了通知信号.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief AXI4_SLAVE_PLAYER                                                     --
-----------------------------------------------------------------------------------
component AXI4_SLAVE_PLAYER
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        READ_ENABLE     : --! @brief リードトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        WRITE_ENABLE    : --! @brief ライトトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time    := 0 ns;
        WIDTH           : --! @brief AXI4 チャネルの可変長信号のビット幅.
                          AXI4_SIGNAL_WIDTH_TYPE;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        DEFAULT_SYNC_IO : --! @brief リードトランザクション/ライトトランザクション
                          --         ウェイト時に完了を待ってから次のコマンドを実行
                          --         するか否かを指定する.
                          boolean := true;
        GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                          integer := 8;
        GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                          integer := 8;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        --------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        ARADDR          : in    std_logic_vector(WIDTH.ARADDR -1 downto 0);
        ARLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        ARSIZE          : in    AXI4_ASIZE_TYPE;
        ARBURST         : in    AXI4_ABURST_TYPE;
        ARLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        ARCACHE         : in    AXI4_ACACHE_TYPE;
        ARPROT          : in    AXI4_APROT_TYPE;
        ARQOS           : in    AXI4_AQOS_TYPE;
        ARREGION        : in    AXI4_AREGION_TYPE;
        ARUSER          : in    std_logic_vector(WIDTH.ARUSER -1 downto 0);
        ARID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        ARVALID         : in    std_logic;
        ARREADY         : inout std_logic;
        --------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        --------------------------------------------------------------------------
        RLAST           : inout std_logic;
        RDATA           : inout std_logic_vector(WIDTH.RDATA  -1 downto 0);
        RRESP           : inout AXI4_RESP_TYPE;
        RUSER           : inout std_logic_vector(WIDTH.RUSER  -1 downto 0);
        RID             : inout std_logic_vector(WIDTH.ID     -1 downto 0);
        RVALID          : inout std_logic;
        RREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        AWADDR          : in    std_logic_vector(WIDTH.AWADDR -1 downto 0);
        AWLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        AWSIZE          : in    AXI4_ASIZE_TYPE;
        AWBURST         : in    AXI4_ABURST_TYPE;
        AWLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        AWCACHE         : in    AXI4_ACACHE_TYPE;
        AWPROT          : in    AXI4_APROT_TYPE;
        AWQOS           : in    AXI4_AQOS_TYPE;
        AWREGION        : in    AXI4_AREGION_TYPE;
        AWUSER          : in    std_logic_vector(WIDTH.AWUSER -1 downto 0);
        AWID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        AWVALID         : in    std_logic;
        AWREADY         : inout std_logic;
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
        WLAST           : in    std_logic;
        WDATA           : in    std_logic_vector(WIDTH.WDATA  -1 downto 0);
        WSTRB           : in    std_logic_vector(WIDTH.WDATA/8-1 downto 0);
        WUSER           : in    std_logic_vector(WIDTH.WUSER  -1 downto 0);
        WID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        WVALID          : in    std_logic;
        WREADY          : inout std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BRESP           : inout AXI4_RESP_TYPE;
        BUSER           : inout std_logic_vector(WIDTH.BUSER  -1 downto 0);
        BID             : inout std_logic_vector(WIDTH.ID     -1 downto 0);
        BVALID          : inout std_logic;
        BREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
        --------------------------------------------------------------------------
        -- General Purpose Input 信号
        --------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH    -1 downto 0) := (others => '0');
        --------------------------------------------------------------------------
        -- General Purpose Output 信号
        --------------------------------------------------------------------------
        GPO             : out   std_logic_vector(GPO_WIDTH    -1 downto 0);
        --------------------------------------------------------------------------
        -- レポートステータス出力.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        -- シミュレーション終了通知信号.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief AXI4_MEMORY_PLAYER                                                    --
-----------------------------------------------------------------------------------
component AXI4_MEMORY_PLAYER
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        READ_ENABLE     : --! @brief リードトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        WRITE_ENABLE    : --! @brief ライトトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time    := 0 ns;
        WIDTH           : --! @brief AXI4 チャネルの可変長信号のビット幅.
                          AXI4_SIGNAL_WIDTH_TYPE;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                          integer := 8;
        GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                          integer := 8;
        MEMORY_SIZE     : --! @brief メモリの大きさをバイト数で指定する.
                          integer := 4096;
        READ_QUEUE_SIZE : --! @brief リードトランザクションのキューの数を指定する.
                          integer := 8;
        WRITE_QUEUE_SIZE: --! @brief ライトトランザクションのキューの数を指定する.
                          integer := 8;
        DOMAIN_SIZE     : --! @brief ドメインの数を指定する.
                          integer := 8;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        --------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        ARADDR          : in    std_logic_vector(WIDTH.ARADDR -1 downto 0);
        ARLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        ARSIZE          : in    AXI4_ASIZE_TYPE;
        ARBURST         : in    AXI4_ABURST_TYPE;
        ARLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        ARCACHE         : in    AXI4_ACACHE_TYPE;
        ARPROT          : in    AXI4_APROT_TYPE;
        ARQOS           : in    AXI4_AQOS_TYPE;
        ARREGION        : in    AXI4_AREGION_TYPE;
        ARUSER          : in    std_logic_vector(WIDTH.ARUSER -1 downto 0);
        ARID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        ARVALID         : in    std_logic;
        ARREADY         : out   std_logic;
        --------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        --------------------------------------------------------------------------
        RLAST           : out   std_logic;
        RDATA           : out   std_logic_vector(WIDTH.RDATA  -1 downto 0);
        RRESP           : out   AXI4_RESP_TYPE;
        RUSER           : out   std_logic_vector(WIDTH.RUSER  -1 downto 0);
        RID             : out   std_logic_vector(WIDTH.ID     -1 downto 0);
        RVALID          : out   std_logic;
        RREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        AWADDR          : in    std_logic_vector(WIDTH.AWADDR -1 downto 0);
        AWLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        AWSIZE          : in    AXI4_ASIZE_TYPE;
        AWBURST         : in    AXI4_ABURST_TYPE;
        AWLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        AWCACHE         : in    AXI4_ACACHE_TYPE;
        AWPROT          : in    AXI4_APROT_TYPE;
        AWQOS           : in    AXI4_AQOS_TYPE;
        AWREGION        : in    AXI4_AREGION_TYPE;
        AWUSER          : in    std_logic_vector(WIDTH.AWUSER -1 downto 0);
        AWID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        AWVALID         : in    std_logic;
        AWREADY         : out   std_logic;
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
        WLAST           : in    std_logic;
        WDATA           : in    std_logic_vector(WIDTH.WDATA  -1 downto 0);
        WSTRB           : in    std_logic_vector(WIDTH.WDATA/8-1 downto 0);
        WUSER           : in    std_logic_vector(WIDTH.WUSER  -1 downto 0);
        WID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        WVALID          : in    std_logic;
        WREADY          : out   std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BRESP           : out   AXI4_RESP_TYPE;
        BUSER           : out   std_logic_vector(WIDTH.BUSER  -1 downto 0);
        BID             : out   std_logic_vector(WIDTH.ID     -1 downto 0);
        BVALID          : out   std_logic;
        BREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
        --------------------------------------------------------------------------
        -- General Purpose Input 信号
        --------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH    -1 downto 0) := (others => '0');
        --------------------------------------------------------------------------
        -- General Purpose Output 信号
        --------------------------------------------------------------------------
        GPO             : out   std_logic_vector(GPO_WIDTH    -1 downto 0);
        --------------------------------------------------------------------------
        -- レポートステータス出力.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        -- シミュレーション終了通知信号.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief AXI4_STREAM_MASTER_PLAYER                                             --
-----------------------------------------------------------------------------------
component AXI4_STREAM_MASTER_PLAYER
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        WIDTH           : --! @brief AXI4 IS WIDTH :
                          AXI4_STREAM_SIGNAL_WIDTH_TYPE;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                          integer := 8;
        GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                          integer := 8;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        ---------------------------------------------------------------------------
        -- AXI4-Streamシグナル.
        ---------------------------------------------------------------------------
        TDATA           : inout std_logic_vector(WIDTH.DATA  -1 downto 0);
        TSTRB           : inout std_logic_vector(WIDTH.DATA/8-1 downto 0);
        TKEEP           : inout std_logic_vector(WIDTH.DATA/8-1 downto 0);
        TUSER           : inout std_logic_vector(WIDTH.USER  -1 downto 0);
        TDEST           : inout std_logic_vector(WIDTH.DEST  -1 downto 0);
        TID             : inout std_logic_vector(WIDTH.ID    -1 downto 0);
        TLAST           : inout std_logic;
        TVALID          : inout std_logic;
        TREADY          : in    std_logic;
        ---------------------------------------------------------------------------
        -- シンクロ用信号.
        ---------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
        --------------------------------------------------------------------------
        -- General Purpose Input 信号
        --------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH-1 downto 0) := (others => '0');
        --------------------------------------------------------------------------
        -- General Purpose Output 信号
        --------------------------------------------------------------------------
        GPO             : out   std_logic_vector(GPO_WIDTH-1 downto 0);
        --------------------------------------------------------------------------
        -- レポートステータス出力.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        -- シミュレーション終了通知信号.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief AXI4_STREAM_SLAVE_PLAYER                                              --
-----------------------------------------------------------------------------------
component AXI4_STREAM_SLAVE_PLAYER
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        WIDTH           : --! @brief AXI4 IS WIDTH :
                          AXI4_STREAM_SIGNAL_WIDTH_TYPE;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                          integer := 8;
        GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                          integer := 8;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        ---------------------------------------------------------------------------
        -- AXI4-Streamシグナル.
        ---------------------------------------------------------------------------
        TDATA           : in    std_logic_vector(WIDTH.DATA  -1 downto 0);
        TSTRB           : in    std_logic_vector(WIDTH.DATA/8-1 downto 0);
        TKEEP           : in    std_logic_vector(WIDTH.DATA/8-1 downto 0);
        TUSER           : in    std_logic_vector(WIDTH.USER  -1 downto 0);
        TDEST           : in    std_logic_vector(WIDTH.DEST  -1 downto 0);
        TID             : in    std_logic_vector(WIDTH.ID    -1 downto 0);
        TLAST           : in    std_logic;
        TVALID          : in    std_logic;
        TREADY          : inout std_logic;
        ---------------------------------------------------------------------------
        -- シンクロ用信号.
        ---------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
        --------------------------------------------------------------------------
        -- General Purpose Input 信号
        --------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH-1 downto 0) := (others => '0');
        --------------------------------------------------------------------------
        -- General Purpose Output 信号
        --------------------------------------------------------------------------
        GPO             : out   std_logic_vector(GPO_WIDTH-1 downto 0);
        --------------------------------------------------------------------------
        -- レポートステータス出力.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        -- シミュレーション終了通知信号.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief AXI4_SIGNAL_PRINTER                                                   --
-----------------------------------------------------------------------------------
component AXI4_SIGNAL_PRINTER
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        NAME            : --! @brief 固有名詞.
                          STRING;
        TAG             : --! @brief タグ.
                          STRING;
        READ_ENABLE     : --! @brief リードチャネルを出力するか否かを指定する.
                          boolean   := TRUE;
        WRITE_ENABLE    : --! @brief ライトチャネルを出力するか否かを指定する.
                          boolean   := TRUE;
        TAG_WIDTH       : --! @brief タグを出力する際の文字幅.
                          --!      * TAG_WIDTH>0 =>  TAG_WIDTH幅の右詰.
                          --!      * TAG_WIDTH<0 => -TAG_WIDTH幅の左詰.
                          --!      * TAG_WIDTH=0 => 出力しない.
                          integer := 13;
        TIME_WIDTH      : --! @brief 時間を出力する際の文字幅.
                          --!      * TIME_WIDTH>0 =>  TAG_WIDTH幅の右詰.
                          --!      * TIME_WIDTH<0 => -TAG_WIDTH幅の左詰.
                          --!      * TIEM_WIDTH=0 => 出力しない.
                          integer := 13;
        WIDTH           : --! @brief AXI4 チャネルの可変長信号のビット幅.
                          AXI4_SIGNAL_WIDTH_TYPE
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        --------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        ARADDR          : in    std_logic_vector(WIDTH.ARADDR -1 downto 0);
        ARLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        ARSIZE          : in    AXI4_ASIZE_TYPE;
        ARBURST         : in    AXI4_ABURST_TYPE;
        ARLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        ARCACHE         : in    AXI4_ACACHE_TYPE;
        ARPROT          : in    AXI4_APROT_TYPE;
        ARQOS           : in    AXI4_AQOS_TYPE;
        ARREGION        : in    AXI4_AREGION_TYPE;
        ARUSER          : in    std_logic_vector(WIDTH.ARUSER -1 downto 0);
        ARID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        ARVALID         : in    std_logic;
        ARREADY         : in    std_logic;
        --------------------------------------------------------------------------
        -- リードチャネルシグナル.
        --------------------------------------------------------------------------
        RLAST           : in    std_logic;
        RDATA           : in    std_logic_vector(WIDTH.RDATA  -1 downto 0);
        RRESP           : in    AXI4_RESP_TYPE;
        RUSER           : in    std_logic_vector(WIDTH.RUSER  -1 downto 0);
        RID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        RVALID          : in    std_logic;
        RREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        AWADDR          : in    std_logic_vector(WIDTH.AWADDR -1 downto 0);
        AWLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        AWSIZE          : in    AXI4_ASIZE_TYPE;
        AWBURST         : in    AXI4_ABURST_TYPE;
        AWLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        AWCACHE         : in    AXI4_ACACHE_TYPE;
        AWPROT          : in    AXI4_APROT_TYPE;
        AWQOS           : in    AXI4_AQOS_TYPE;
        AWREGION        : in    AXI4_AREGION_TYPE;
        AWUSER          : in    std_logic_vector(WIDTH.AWUSER -1 downto 0);
        AWID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        AWVALID         : in    std_logic;
        AWREADY         : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
        WLAST           : in    std_logic;
        WDATA           : in    std_logic_vector(WIDTH.WDATA  -1 downto 0);
        WSTRB           : in    std_logic_vector(WIDTH.WDATA/8-1 downto 0);
        WUSER           : in    std_logic_vector(WIDTH.WUSER  -1 downto 0);
        WID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        WVALID          : in    std_logic;
        WREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BRESP           : in    AXI4_RESP_TYPE;
        BUSER           : in    std_logic_vector(WIDTH.BUSER  -1 downto 0);
        BID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        BVALID          : in    std_logic;
        BREADY          : in    std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief AXI4_STREAM_SIGNAL_PRINTER                                            --
-----------------------------------------------------------------------------------
component AXI4_STREAM_SIGNAL_PRINTER
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        NAME            : --! @brief 固有名詞.
                          STRING;
        TAG             : --! @brief タグ.
                          STRING;
        TAG_WIDTH       : --! @brief タグを出力する際の文字幅.
                          --!      * TAG_WIDTH>0 =>  TAG_WIDTH幅の右詰.
                          --!      * TAG_WIDTH<0 => -TAG_WIDTH幅の左詰.
                          --!      * TAG_WIDTH=0 => 出力しない.
                          integer := 13;
        TIME_WIDTH      : --! @brief 時間を出力する際の文字幅.
                          --!      * TIME_WIDTH>0 =>  TAG_WIDTH幅の右詰.
                          --!      * TIME_WIDTH<0 => -TAG_WIDTH幅の左詰.
                          --!      * TIEM_WIDTH=0 => 出力しない.
                          integer := 13;
        WIDTH           : --! @brief AXI4 チャネルの可変長信号のビット幅.
                          AXI4_STREAM_SIGNAL_WIDTH_TYPE
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        ---------------------------------------------------------------------------
        -- AXI4-Streamシグナル.
        ---------------------------------------------------------------------------
        TDATA           : in    std_logic_vector(WIDTH.DATA  -1 downto 0);
        TSTRB           : in    std_logic_vector(WIDTH.DATA/8-1 downto 0);
        TKEEP           : in    std_logic_vector(WIDTH.DATA/8-1 downto 0);
        TUSER           : in    std_logic_vector(WIDTH.USER  -1 downto 0);
        TDEST           : in    std_logic_vector(WIDTH.DEST  -1 downto 0);
        TID             : in    std_logic_vector(WIDTH.ID    -1 downto 0);
        TLAST           : in    std_logic;
        TVALID          : in    std_logic;
        TREADY          : in    std_logic
    );
end component;
end AXI4_MODELS;
