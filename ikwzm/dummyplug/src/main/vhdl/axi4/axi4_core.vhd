-----------------------------------------------------------------------------------
--!     @file    axi4_core.vhd
--!     @brief   AXI4 Dummy Plug Core Package.
--!     @version 1.7.2
--!     @date    2019/4/15
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2019 Ichiro Kawazome
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
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.CORE.CORE_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_REQ_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_ACK_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_SIG_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
use     DUMMY_PLUG.READER.EVENT_TYPE;
-----------------------------------------------------------------------------------
--! @brief AXI4 Dummy Plug のコアパッケージ.
-----------------------------------------------------------------------------------
package AXI4_CORE is
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネルのタイプ.
    -------------------------------------------------------------------------------
    type      AXI4_CHANNEL_TYPE is (
        AXI4_CHANNEL_AR,
        AXI4_CHANNEL_AW,
        AXI4_CHANNEL_R,
        AXI4_CHANNEL_W,
        AXI4_CHANNEL_B,
        AXI4_CHANNEL_M
    );
    -------------------------------------------------------------------------------
    --! @brief WAITオペレーション実行時のデフォルトのタイムアウトクロック数
    -------------------------------------------------------------------------------
    constant  DEFAULT_WAIT_TIMEOUT : integer := 10000;
    -------------------------------------------------------------------------------
    --! @brief AXI4 トランザクションデータの最大バイト数.
    -------------------------------------------------------------------------------
    constant  AXI4_XFER_MAX_BYTES  : integer := 4096;
    -------------------------------------------------------------------------------
    --! @brief AXI4 アドレスチャネル信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_A_CHANNEL_SIGNAL_TYPE is record
        ADDR     : std_logic_vector(AXI4_ADDR_MAX_WIDTH -1 downto 0);
        WRITE    : std_logic;
        LEN      : std_logic_vector(AXI4_ALEN_MAX_WIDTH -1 downto 0);
        SIZE     : AXI4_ASIZE_TYPE;
        BURST    : AXI4_ABURST_TYPE;
        LOCK     : std_logic_vector(AXI4_ALOCK_MAX_WIDTH-1 downto 0);
        CACHE    : AXI4_ACACHE_TYPE;
        PROT     : AXI4_APROT_TYPE;
        QOS      : AXI4_AQOS_TYPE;
        REGION   : AXI4_AREGION_TYPE;
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH -1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH   -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4 アドレスチャネル信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_A_CHANNEL_SIGNAL_DONTCARE : AXI4_A_CHANNEL_SIGNAL_TYPE := (
        ADDR    => (others => '-'),
        WRITE   => '-',
        LEN     => (others => '-'),
        SIZE    => (others => '-'),
        BURST   => (others => '-'),
        LOCK    => (others => '-'),
        CACHE   => (others => '-'),
        PROT    => (others => '-'),
        QOS     => (others => '-'),
        REGION  => (others => '-'),
        USER    => (others => '-'),
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4 アドレスチャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_A_CHANNEL_SIGNAL_NULL     : AXI4_A_CHANNEL_SIGNAL_TYPE := (
        ADDR    => (others => '0'),
        WRITE   => '0',
        LEN     => (others => '0'),
        SIZE    => (others => '0'),
        BURST   => (others => '0'),
        LOCK    => (others => '0'),
        CACHE   => (others => '0'),
        PROT    => (others => '0'),
        QOS     => (others => '0'),
        REGION  => (others => '0'),
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4 リードチャネル信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_R_CHANNEL_SIGNAL_TYPE is record
        DATA     : std_logic_vector(AXI4_DATA_MAX_WIDTH-1 downto 0);
        RESP     : AXI4_RESP_TYPE;
        LAST     : std_logic;
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH  -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4 リードチャネル信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_R_CHANNEL_SIGNAL_DONTCARE : AXI4_R_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '-'),
        RESP    => (others => '-'),
        LAST    => '-',
        USER    => (others => '-'),
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 リードチャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_R_CHANNEL_SIGNAL_NULL     : AXI4_R_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '0'),
        RESP    => (others => '0'),
        LAST    => '0',
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライトチャネル信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_W_CHANNEL_SIGNAL_TYPE is record
        DATA     : std_logic_vector(AXI4_DATA_MAX_WIDTH-1 downto 0);
        LAST     : std_logic;
        STRB     : std_logic_vector(AXI4_STRB_MAX_WIDTH-1 downto 0);
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH  -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライトチャネル信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_W_CHANNEL_SIGNAL_DONTCARE : AXI4_W_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '-'),
        LAST    => '-',
        STRB    => (others => '-'),
        USER    => (others => '-'),
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライトチャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_W_CHANNEL_SIGNAL_NULL     : AXI4_W_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '0'),
        LAST    => '0',
        STRB    => (others => '0'),
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライト応答チャネル信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_B_CHANNEL_SIGNAL_TYPE is record
        RESP     : AXI4_RESP_TYPE;
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH  -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライト応答チャネル信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_B_CHANNEL_SIGNAL_DONTCARE : AXI4_B_CHANNEL_SIGNAL_TYPE := (
        RESP    => (others => '-'),
        ID      => (others => '-'),
        USER    => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライト応答チャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_B_CHANNEL_SIGNAL_NULL     : AXI4_B_CHANNEL_SIGNAL_TYPE := (
        RESP    => (others => '0'),
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネル信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_CHANNEL_SIGNAL_TYPE is record
        AR       : AXI4_A_CHANNEL_SIGNAL_TYPE;
        R        : AXI4_R_CHANNEL_SIGNAL_TYPE;
        AW       : AXI4_A_CHANNEL_SIGNAL_TYPE;
        W        : AXI4_W_CHANNEL_SIGNAL_TYPE;
        B        : AXI4_B_CHANNEL_SIGNAL_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネル信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_CHANNEL_SIGNAL_DONTCARE : AXI4_CHANNEL_SIGNAL_TYPE := (
        AR      => AXI4_A_CHANNEL_SIGNAL_DONTCARE,
        R       => AXI4_R_CHANNEL_SIGNAL_DONTCARE,
        AW      => AXI4_A_CHANNEL_SIGNAL_DONTCARE,
        W       => AXI4_W_CHANNEL_SIGNAL_DONTCARE,
        B       => AXI4_B_CHANNEL_SIGNAL_DONTCARE
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_CHANNEL_SIGNAL_NULL     : AXI4_CHANNEL_SIGNAL_TYPE := (
        AR      => AXI4_A_CHANNEL_SIGNAL_NULL,
        R       => AXI4_R_CHANNEL_SIGNAL_NULL,
        AW      => AXI4_A_CHANNEL_SIGNAL_NULL,
        W       => AXI4_W_CHANNEL_SIGNAL_NULL,
        B       => AXI4_B_CHANNEL_SIGNAL_NULL
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4トランザクション信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_TRANSACTION_SIGNAL_TYPE is record
        VALID    : std_logic;
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH    -1 downto 0);
        ADDR     : std_logic_vector(AXI4_ADDR_MAX_WIDTH  -1 downto 0);
        AUSER    : std_logic_vector(AXI4_USER_MAX_WIDTH  -1 downto 0);
        DUSER    : std_logic_vector(AXI4_USER_MAX_WIDTH  -1 downto 0);
        BUSER    : std_logic_vector(AXI4_USER_MAX_WIDTH  -1 downto 0);
        DATA     : std_logic_vector(AXI4_XFER_MAX_BYTES*8-1 downto 0);
        DATA_LEN : integer;
        WRITE    : std_logic;
        LEN      : std_logic_vector(AXI4_ALEN_MAX_WIDTH  -1 downto 0);
        SIZE     : AXI4_ASIZE_TYPE;
        BURST    : AXI4_ABURST_TYPE;
        LOCK     : std_logic_vector(AXI4_ALOCK_MAX_WIDTH -1 downto 0);
        CACHE    : AXI4_ACACHE_TYPE;
        PROT     : AXI4_APROT_TYPE;
        QOS      : AXI4_AQOS_TYPE;
        REGION   : AXI4_AREGION_TYPE;
        RESP     : AXI4_RESP_TYPE;
        TIMEOUT  : integer;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4トランザクション信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_TRANSACTION_SIGNAL_NULL     : AXI4_TRANSACTION_SIGNAL_TYPE := (
        VALID    => '0'              ,
        ID       => (others => '0')  ,
        ADDR     => (others => '0')  ,
        AUSER    => (others => '0')  ,
        DUSER    => (others => '0')  ,
        BUSER    => (others => '0')  ,
        DATA     => (others => '0')  ,
        DATA_LEN =>  0               ,
        WRITE    => '0'              ,
        LEN      => (others => '0')  ,
        SIZE     => (others => '0')  ,
        BURST    => (others => '0')  ,
        LOCK     => (others => '0')  ,
        CACHE    => (others => '0')  ,
        PROT     => (others => '0')  ,
        QOS      => (others => '0')  ,
        REGION   => (others => '0')  ,
        RESP     => (others => '0')  ,
        TIMEOUT  => 0
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4トランザクション信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_TRANSACTION_SIGNAL_DONTCARE : AXI4_TRANSACTION_SIGNAL_TYPE := (
        VALID    => '-'              ,
        ID       => (others => '-')  ,
        ADDR     => (others => '-')  ,
        AUSER    => (others => '-')  ,
        DUSER    => (others => '-')  ,
        BUSER    => (others => '-')  ,
        DATA     => (others => '-')  ,
        DATA_LEN =>  0               ,
        WRITE    => '-'              ,
        LEN      => (others => '-')  ,
        SIZE     => (others => '-')  ,
        BURST    => (others => '-')  ,
        LOCK     => (others => '-')  ,
        CACHE    => (others => '-')  ,
        PROT     => (others => '-')  ,
        QOS      => (others => '-')  ,
        REGION   => (others => '-')  ,
        RESP     => (others => '-')  ,
        TIMEOUT  => 0
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4-Stream 信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_STREAM_SIGNAL_TYPE is record
        DATA     : std_logic_vector(AXI4_DATA_MAX_WIDTH-1 downto 0);
        KEEP     : std_logic_vector(AXI4_STRB_MAX_WIDTH-1 downto 0);
        STRB     : std_logic_vector(AXI4_STRB_MAX_WIDTH-1 downto 0);
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH-1 downto 0);
        DEST     : std_logic_vector(AXI4_DEST_MAX_WIDTH-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH  -1 downto 0);
        LAST     : std_logic;
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4-Stream信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_STREAM_SIGNAL_DONTCARE : AXI4_STREAM_SIGNAL_TYPE := (
        DATA    => (others => '-'),
        KEEP    => (others => '-'),
        STRB    => (others => '-'),
        USER    => (others => '-'),
        DEST    => (others => '-'),
        ID      => (others => '-'),
        LAST    => '-',
        VALID   => '-',
        READY   => '-'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライト応答チャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_STREAM_SIGNAL_NULL     : AXI4_STREAM_SIGNAL_TYPE := (
        DATA    => (others => '0'),
        KEEP    => (others => '0'),
        STRB    => (others => '0'),
        USER    => (others => '0'),
        DEST    => (others => '0'),
        ID      => (others => '0'),
        LAST    => '0',
        VALID   => '0',
        READY   => '0'
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4_CHANNEL_PLAYER
    -------------------------------------------------------------------------------
    component  AXI4_CHANNEL_PLAYER is
        ---------------------------------------------------------------------------
        -- ジェネリック変数.
        ---------------------------------------------------------------------------
        generic (
            SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                              STRING;
            NAME            : --! @brief 固有名詞.
                              STRING;
            FULL_NAME       : --! @brief メッセージ出力用の固有名詞.
                              STRING;
            CHANNEL         : --! @brief チャネルタイプ.
                              AXI4_CHANNEL_TYPE;
            MASTER          : --! @brief マスターモードを指定する.
                              boolean   := FALSE;
            SLAVE           : --! @brief スレーブモードを指定する.
                              boolean   := FALSE;
            READ_ENABLE     : --! @brief リードトランザクションの可/不可を指定する.
                              boolean   := TRUE;
            WRITE_ENABLE    : --! @brief ライトトランザクションの可/不可を指定する.
                              boolean   := TRUE;
            OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                              time;
            WIDTH           : --! @brief AXI4 IS WIDTH :
                              AXI4_SIGNAL_WIDTH_TYPE;
            SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                              integer :=  1;
            SYNC_LOCAL_WAIT : --! @brief ローカル同期時のウェイトクロック数.
                              integer := 2;
            DEFAULT_SYNC_IO : --! @brief リードトランザクション/ライトトランザクション
                              --         ウェイト時に完了を待ってから次のコマンドを実行
                              --         するか否かを指定する.
                              boolean := false;
            GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                              integer := 8;
            GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                              integer := 8;
            FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                              --!        アボートするかどうかを指定するフラグ.
                              boolean := true
        );
        --------------------------------------------------------------------------
        -- 入出力ポートの定義.
        --------------------------------------------------------------------------
        port(
            ----------------------------------------------------------------------
            -- グローバルシグナル.
            ----------------------------------------------------------------------
            ACLK            : in    std_logic;
            ARESETn         : in    std_logic;
            ----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            ----------------------------------------------------------------------
            ARADDR_I        : in    std_logic_vector(WIDTH.ARADDR -1 downto 0);
            ARADDR_O        : out   std_logic_vector(WIDTH.ARADDR -1 downto 0);
            ARLEN_I         : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
            ARLEN_O         : out   std_logic_vector(WIDTH.ALEN   -1 downto 0);
            ARSIZE_I        : in    AXI4_ASIZE_TYPE;
            ARSIZE_O        : out   AXI4_ASIZE_TYPE;
            ARBURST_I       : in    AXI4_ABURST_TYPE;
            ARBURST_O       : out   AXI4_ABURST_TYPE;
            ARLOCK_I        : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
            ARLOCK_O        : out   std_logic_vector(WIDTH.ALOCK  -1 downto 0);
            ARCACHE_I       : in    AXI4_ACACHE_TYPE;
            ARCACHE_O       : out   AXI4_ACACHE_TYPE;
            ARPROT_I        : in    AXI4_APROT_TYPE;
            ARPROT_O        : out   AXI4_APROT_TYPE;
            ARQOS_I         : in    AXI4_AQOS_TYPE;
            ARQOS_O         : out   AXI4_AQOS_TYPE;
            ARREGION_I      : in    AXI4_AREGION_TYPE;
            ARREGION_O      : out   AXI4_AREGION_TYPE;
            ARUSER_I        : in    std_logic_vector(WIDTH.ARUSER -1 downto 0);
            ARUSER_O        : out   std_logic_vector(WIDTH.ARUSER -1 downto 0);
            ARID_I          : in    std_logic_vector(WIDTH.ID     -1 downto 0);
            ARID_O          : out   std_logic_vector(WIDTH.ID     -1 downto 0);
            ARVALID_I       : in    std_logic;
            ARVALID_O       : out   std_logic;
            ARREADY_I       : in    std_logic;
            ARREADY_O       : out   std_logic;
            ----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            ----------------------------------------------------------------------
            RVALID_I        : in    std_logic;
            RVALID_O        : out   std_logic;
            RLAST_I         : in    std_logic;
            RLAST_O         : out   std_logic;
            RDATA_I         : in    std_logic_vector(WIDTH.RDATA  -1 downto 0);
            RDATA_O         : out   std_logic_vector(WIDTH.RDATA  -1 downto 0);
            RRESP_I         : in    AXI4_RESP_TYPE;
            RRESP_O         : out   AXI4_RESP_TYPE;
            RUSER_I         : in    std_logic_vector(WIDTH.RUSER  -1 downto 0);
            RUSER_O         : out   std_logic_vector(WIDTH.RUSER  -1 downto 0);
            RID_I           : in    std_logic_vector(WIDTH.ID     -1 downto 0);
            RID_O           : out   std_logic_vector(WIDTH.ID     -1 downto 0);
            RREADY_I        : in    std_logic;
            RREADY_O        : out   std_logic;
            ----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            ----------------------------------------------------------------------
            AWADDR_I        : in    std_logic_vector(WIDTH.AWADDR -1 downto 0);
            AWADDR_O        : out   std_logic_vector(WIDTH.AWADDR -1 downto 0);
            AWLEN_I         : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
            AWLEN_O         : out   std_logic_vector(WIDTH.ALEN   -1 downto 0);
            AWSIZE_I        : in    AXI4_ASIZE_TYPE;
            AWSIZE_O        : out   AXI4_ASIZE_TYPE;
            AWBURST_I       : in    AXI4_ABURST_TYPE;
            AWBURST_O       : out   AXI4_ABURST_TYPE;
            AWLOCK_I        : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
            AWLOCK_O        : out   std_logic_vector(WIDTH.ALOCK  -1 downto 0);
            AWCACHE_I       : in    AXI4_ACACHE_TYPE;
            AWCACHE_O       : out   AXI4_ACACHE_TYPE;
            AWPROT_I        : in    AXI4_APROT_TYPE;
            AWPROT_O        : out   AXI4_APROT_TYPE;
            AWQOS_I         : in    AXI4_AQOS_TYPE;
            AWQOS_O         : out   AXI4_AQOS_TYPE;
            AWREGION_I      : in    AXI4_AREGION_TYPE;
            AWREGION_O      : out   AXI4_AREGION_TYPE;
            AWUSER_I        : in    std_logic_vector(WIDTH.AWUSER -1 downto 0);
            AWUSER_O        : out   std_logic_vector(WIDTH.AWUSER -1 downto 0);
            AWID_I          : in    std_logic_vector(WIDTH.ID     -1 downto 0);
            AWID_O          : out   std_logic_vector(WIDTH.ID     -1 downto 0);
            AWVALID_I       : in    std_logic;
            AWVALID_O       : out   std_logic;
            AWREADY_I       : in    std_logic;
            AWREADY_O       : out   std_logic;
            ----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            ----------------------------------------------------------------------
            WLAST_I         : in    std_logic;
            WLAST_O         : out   std_logic;
            WDATA_I         : in    std_logic_vector(WIDTH.WDATA  -1 downto 0);
            WDATA_O         : out   std_logic_vector(WIDTH.WDATA  -1 downto 0);
            WSTRB_I         : in    std_logic_vector(WIDTH.WDATA/8-1 downto 0);
            WSTRB_O         : out   std_logic_vector(WIDTH.WDATA/8-1 downto 0);
            WUSER_I         : in    std_logic_vector(WIDTH.WUSER  -1 downto 0);
            WUSER_O         : out   std_logic_vector(WIDTH.WUSER  -1 downto 0);
            WID_I           : in    std_logic_vector(WIDTH.ID     -1 downto 0);
            WID_O           : out   std_logic_vector(WIDTH.ID     -1 downto 0);
            WVALID_I        : in    std_logic;
            WVALID_O        : out   std_logic;
            WREADY_I        : in    std_logic;
            WREADY_O        : out   std_logic;
            ----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            ----------------------------------------------------------------------
            BRESP_I         : in    AXI4_RESP_TYPE;
            BRESP_O         : out   AXI4_RESP_TYPE;
            BUSER_I         : in    std_logic_vector(WIDTH.BUSER  -1 downto 0);
            BUSER_O         : out   std_logic_vector(WIDTH.BUSER  -1 downto 0);
            BID_I           : in    std_logic_vector(WIDTH.ID     -1 downto 0);
            BID_O           : out   std_logic_vector(WIDTH.ID     -1 downto 0);
            BVALID_I        : in    std_logic;
            BVALID_O        : out   std_logic;
            BREADY_I        : in    std_logic;
            BREADY_O        : out   std_logic;
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        : out   SYNC_REQ_VECTOR(SYNC_WIDTH-1 downto 0);
            SYNC_ACK        : in    SYNC_ACK_VECTOR(SYNC_WIDTH-1 downto 0) := (others => '0');
            SYNC_LOCAL_REQ  : out   SYNC_REQ_VECTOR(0 downto 0);
            SYNC_LOCAL_ACK  : in    SYNC_ACK_VECTOR(0 downto 0);
            SYNC_TRANS_REQ  : out   SYNC_REQ_VECTOR(0 downto 0);
            SYNC_TRANS_ACK  : in    SYNC_ACK_VECTOR(0 downto 0);
            -----------------------------------------------------------------------
            -- トランザクション用信号.
            -----------------------------------------------------------------------
            TRAN_I          : in    AXI4_TRANSACTION_SIGNAL_TYPE;
            TRAN_O          : out   AXI4_TRANSACTION_SIGNAL_TYPE;
            -----------------------------------------------------------------------
            -- GPIO
            -----------------------------------------------------------------------
            GPI             : in    std_logic_vector(GPI_WIDTH     -1 downto 0) := (others => '0');
            GPO             : out   std_logic_vector(GPO_WIDTH     -1 downto 0);
            -----------------------------------------------------------------------
            -- 各種状態信号.
            -----------------------------------------------------------------------
            REPORT_STATUS   : out   REPORT_STATUS_TYPE;
            FINISH          : out   std_logic
        );
    end component;
    -------------------------------------------------------------------------------
    --! @brief   AXI4_STREAM_PLAYER :
    -------------------------------------------------------------------------------
    component AXI4_STREAM_PLAYER
        ---------------------------------------------------------------------------
        -- ジェネリック変数.
        ---------------------------------------------------------------------------
        generic (
            SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                              STRING;
            NAME            : --! @brief 固有名詞.
                              STRING;
            FULL_NAME       : --! @brief メッセージ出力用の固有名詞.
                              STRING;
            MASTER          : --! @brief マスターモードを指定する.
                              boolean   := FALSE;
            SLAVE           : --! @brief スレーブモードを指定する.
                              boolean   := FALSE;
            OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                              time;
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
        ---------------------------------------------------------------------------
        -- 入出力ポートの定義.
        ---------------------------------------------------------------------------
        port(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            : in    std_logic;
            ARESETn         : in    std_logic;
            -----------------------------------------------------------------------
            -- AXI4-Streamシグナル.
            -----------------------------------------------------------------------
            TDATA_I         : in    std_logic_vector(WIDTH.DATA  -1 downto 0);
            TDATA_O         : out   std_logic_vector(WIDTH.DATA  -1 downto 0);
            TSTRB_I         : in    std_logic_vector(WIDTH.DATA/8-1 downto 0);
            TSTRB_O         : out   std_logic_vector(WIDTH.DATA/8-1 downto 0);
            TKEEP_I         : in    std_logic_vector(WIDTH.DATA/8-1 downto 0);
            TKEEP_O         : out   std_logic_vector(WIDTH.DATA/8-1 downto 0);
            TUSER_I         : in    std_logic_vector(WIDTH.USER  -1 downto 0);
            TUSER_O         : out   std_logic_vector(WIDTH.USER  -1 downto 0);
            TDEST_I         : in    std_logic_vector(WIDTH.DEST  -1 downto 0);
            TDEST_O         : out   std_logic_vector(WIDTH.DEST  -1 downto 0);
            TID_I           : in    std_logic_vector(WIDTH.ID    -1 downto 0);
            TID_O           : out   std_logic_vector(WIDTH.ID    -1 downto 0);
            TLAST_I         : in    std_logic;
            TLAST_O         : out   std_logic;
            TVALID_I        : in    std_logic;
            TVALID_O        : out   std_logic;
            TREADY_I        : in    std_logic;
            TREADY_O        : out   std_logic;
            -----------------------------------------------------------------------
            -- シンクロ用信号.
            -----------------------------------------------------------------------
            SYNC_REQ        : out   SYNC_REQ_VECTOR (SYNC_WIDTH   -1 downto 0);
            SYNC_ACK        : in    SYNC_ACK_VECTOR (SYNC_WIDTH   -1 downto 0);
            -----------------------------------------------------------------------
            -- General Purpose Input 信号
            -----------------------------------------------------------------------
            GPI             : in    std_logic_vector(GPI_WIDTH-1 downto 0) := (others => '0');
            -----------------------------------------------------------------------
            -- General Purpose Output 信号
            -----------------------------------------------------------------------
            GPO             : out   std_logic_vector(GPO_WIDTH-1 downto 0);
            -----------------------------------------------------------------------
            -- レポートステータス出力.
            -----------------------------------------------------------------------
            REPORT_STATUS   : out   REPORT_STATUS_TYPE;
            -----------------------------------------------------------------------
            -- シミュレーション終了通知信号.
            -----------------------------------------------------------------------
            FINISH          : out   std_logic
        );
    end component;
end     AXI4_CORE;
