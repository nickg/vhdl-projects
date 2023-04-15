-----------------------------------------------------------------------------------
--!     @file    axi4_channel_player.vhd
--!     @brief   AXI4 A/R/W/B Channel Dummy Plug Player.
--!     @version 1.6.1
--!     @date    2016/3/15
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2016 Ichiro Kawazome
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
use     DUMMY_PLUG.AXI4_CORE.all;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_REQ_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_ACK_VECTOR;
-----------------------------------------------------------------------------------
--! @brief   AXI4_CHANNEL_PLAYER :
-----------------------------------------------------------------------------------
entity  AXI4_CHANNEL_PLAYER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
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
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
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
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
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
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
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
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
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
        ---------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        ---------------------------------------------------------------------------
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
        ---------------------------------------------------------------------------
        -- シンクロ用信号.
        ---------------------------------------------------------------------------
        SYNC_REQ        : out   SYNC_REQ_VECTOR(SYNC_WIDTH-1 downto 0);
        SYNC_ACK        : in    SYNC_ACK_VECTOR(SYNC_WIDTH-1 downto 0) := (others => '0');
        SYNC_LOCAL_REQ  : out   SYNC_REQ_VECTOR(0 downto 0);
        SYNC_LOCAL_ACK  : in    SYNC_ACK_VECTOR(0 downto 0);
        SYNC_TRANS_REQ  : out   SYNC_REQ_VECTOR(0 downto 0);
        SYNC_TRANS_ACK  : in    SYNC_ACK_VECTOR(0 downto 0);
        ---------------------------------------------------------------------------
        -- トランザクション用信号.
        ---------------------------------------------------------------------------
        TRAN_I          : in    AXI4_TRANSACTION_SIGNAL_TYPE;
        TRAN_O          : out   AXI4_TRANSACTION_SIGNAL_TYPE;
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
end AXI4_CHANNEL_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_CORE.all;
use     DUMMY_PLUG.CORE.all;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.all;
use     DUMMY_PLUG.READER.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4_CHANNEL_PLAYER :
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_CHANNEL_PLAYER is
    -------------------------------------------------------------------------------
    --! @brief 入力信号のどれかに変化があるまで待つサブプログラム.
    -------------------------------------------------------------------------------
    procedure  wait_on_signals is
    begin
        wait on 
            ACLK       , -- In  :
            ARADDR_I   , -- In  :
            ARLEN_I    , -- In  :
            ARSIZE_I   , -- In  :
            ARBURST_I  , -- In  :
            ARLOCK_I   , -- In  :
            ARCACHE_I  , -- In  :
            ARPROT_I   , -- In  :
            ARQOS_I    , -- In  :
            ARREGION_I , -- In  :
            ARUSER_I   , -- In  :
            ARID_I     , -- In  :
            ARVALID_I  , -- In  :
            ARREADY_I  , -- In  :
            AWADDR_I   , -- In  :
            AWLEN_I    , -- In  :
            AWSIZE_I   , -- In  :
            AWBURST_I  , -- In  :
            AWLOCK_I   , -- In  :
            AWCACHE_I  , -- In  :
            AWPROT_I   , -- In  :
            AWQOS_I    , -- In  :
            AWREGION_I , -- In  :
            AWUSER_I   , -- In  :
            AWID_I     , -- In  :
            AWVALID_I  , -- In  :
            AWREADY_I  , -- In  :
            RLAST_I    , -- In  :
            RDATA_I    , -- In  :
            RRESP_I    , -- In  :
            RUSER_I    , -- In  :
            RID_I      , -- In  :
            RVALID_I   , -- In  :
            RREADY_I   , -- In  :
            WLAST_I    , -- In  :
            WDATA_I    , -- In  :
            WSTRB_I    , -- In  :
            WUSER_I    , -- In  :
            WID_I      , -- In  :
            WVALID_I   , -- In  :
            WREADY_I   , -- In  :
            BRESP_I    , -- In  :
            BUSER_I    , -- In  :
            BID_I      , -- In  :
            BVALID_I   , -- In  :
            BREADY_I   , -- In  :
            GPI        ; -- In  :
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 全チャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SIGNALS     信号の期待値.
    --! @param    MATCH       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure match_axi4_channel(
                  signals       : in    AXI4_CHANNEL_SIGNAL_TYPE;
                  match         : out   boolean
    ) is
        variable  ar_match      :       boolean;
        variable  aw_match      :       boolean;
        variable  r_match       :       boolean;
        variable  w_match       :       boolean;
    begin
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (WRITE_ENABLE) then
            aw_match := MATCH_STD_LOGIC(signals.AW.VALID               ,AWVALID_I ) and 
                        MATCH_STD_LOGIC(signals.AW.READY               ,AWREADY_I ) and 
                        MATCH_STD_LOGIC(signals.AW.ID  (AWID_I  'range),AWID_I    ) and 
                        MATCH_STD_LOGIC(signals.AW.ADDR(AWADDR_I'range),AWADDR_I  ) and 
                        MATCH_STD_LOGIC(signals.AW.LEN (AWLEN_I 'range),AWLEN_I   ) and 
                        MATCH_STD_LOGIC(signals.AW.SIZE                ,AWSIZE_I  ) and 
                        MATCH_STD_LOGIC(signals.AW.BURST               ,AWBURST_I ) and 
                        MATCH_STD_LOGIC(signals.AW.LOCK(AWLOCK_I'range),AWLOCK_I  ) and 
                        MATCH_STD_LOGIC(signals.AW.CACHE               ,AWCACHE_I ) and 
                        MATCH_STD_LOGIC(signals.AW.PROT                ,AWPROT_I  ) and
                        MATCH_STD_LOGIC(signals.AW.QOS                 ,AWQOS_I   ) and
                        MATCH_STD_LOGIC(signals.AW.REGION              ,AWREGION_I) and
                        MATCH_STD_LOGIC(signals.AW.USER(AWUSER_I'range),AWUSER_I  );
        else
            aw_match := TRUE;
        end if;
        ---------------------------------------------------------------------------
        -- ライトチャネルシグナル/ライト応答チャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (WRITE_ENABLE) then
            w_match  := MATCH_STD_LOGIC(signals.W.VALID                ,WVALID_I  ) and 
                        MATCH_STD_LOGIC(signals.W.READY                ,WREADY_I  ) and 
                        MATCH_STD_LOGIC(signals.B.VALID                ,BVALID_I  ) and 
                        MATCH_STD_LOGIC(signals.B.READY                ,BREADY_I  ) and
                        MATCH_STD_LOGIC(signals.W.ID(WID_I'range)      ,WID_I     ) and 
                        MATCH_STD_LOGIC(signals.B.ID(BID_I'range)      ,BID_I     ) and 
                        MATCH_STD_LOGIC(signals.W.DATA(WDATA_I'range)  ,WDATA_I   ) and 
                        MATCH_STD_LOGIC(signals.W.STRB(WSTRB_I'range)  ,WSTRB_I   ) and 
                        MATCH_STD_LOGIC(signals.W.LAST                 ,WLAST_I   ) and 
                        MATCH_STD_LOGIC(signals.B.RESP                 ,BRESP_I   ) and
                        MATCH_STD_LOGIC(signals.W.USER(WUSER_I'range)  ,WUSER_I   ) and 
                        MATCH_STD_LOGIC(signals.B.USER(BUSER_I'range)  ,BUSER_I   );
        else
            w_match  := TRUE;
        end if;
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (READ_ENABLE) then
            ar_match := MATCH_STD_LOGIC(signals.AR.VALID               ,ARVALID_I ) and 
                        MATCH_STD_LOGIC(signals.AR.READY               ,ARREADY_I ) and 
                        MATCH_STD_LOGIC(signals.AR.ID  (ARID_I  'range),ARID_I    ) and 
                        MATCH_STD_LOGIC(signals.AR.ADDR(ARADDR_I'range),ARADDR_I  ) and 
                        MATCH_STD_LOGIC(signals.AR.LEN (ARLEN_I 'range),ARLEN_I   ) and 
                        MATCH_STD_LOGIC(signals.AR.SIZE                ,ARSIZE_I  ) and 
                        MATCH_STD_LOGIC(signals.AR.BURST               ,ARBURST_I ) and 
                        MATCH_STD_LOGIC(signals.AR.LOCK(ARLOCK_I'range),ARLOCK_I  ) and 
                        MATCH_STD_LOGIC(signals.AR.CACHE               ,ARCACHE_I ) and 
                        MATCH_STD_LOGIC(signals.AR.PROT                ,ARPROT_I  ) and
                        MATCH_STD_LOGIC(signals.AR.QOS                 ,ARQOS_I   ) and
                        MATCH_STD_LOGIC(signals.AR.REGION              ,ARREGION_I) and
                        MATCH_STD_LOGIC(signals.AR.USER(ARUSER_I'range),ARUSER_I  );
        else
            ar_match := TRUE;
        end if;
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナルの比較
        ---------------------------------------------------------------------------
        if (READ_ENABLE) then
            r_match  := MATCH_STD_LOGIC(signals.R.VALID                ,RVALID_I  ) and 
                        MATCH_STD_LOGIC(signals.R.READY                ,RREADY_I  ) and 
                        MATCH_STD_LOGIC(signals.R.ID(RID_I'range)      ,RID_I     ) and 
                        MATCH_STD_LOGIC(signals.R.DATA(RDATA_I'range)  ,RDATA_I   ) and 
                        MATCH_STD_LOGIC(signals.R.LAST                 ,RLAST_I   ) and 
                        MATCH_STD_LOGIC(signals.R.USER(RUSER_I'range)  ,RUSER_I   );
        else
            r_match  := TRUE;
        end if;
        match := ar_match and aw_match and r_match and w_match;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief アドレスチャネルの期待値と信号の値を比較するサブプログラム.
    -------------------------------------------------------------------------------
    procedure match_axi4_channel(
        variable  core          : inout CORE_TYPE;
                  name          : in    STRING;
                  signals       : in    AXI4_A_CHANNEL_SIGNAL_TYPE;
                  match         : out   boolean;
        signal    ADDR          : in    std_logic_vector;
        signal    LEN           : in    std_logic_vector;
        signal    SIZE          : in    AXI4_ASIZE_TYPE;
        signal    BURST         : in    AXI4_ABURST_TYPE;
        signal    LOCK          : in    std_logic_vector;
        signal    CACHE         : in    AXI4_ACACHE_TYPE;
        signal    PROT          : in    AXI4_APROT_TYPE;
        signal    QOS           : in    AXI4_AQOS_TYPE;
        signal    REGION        : in    AXI4_AREGION_TYPE;
        signal    USER          : in    std_logic_vector;
        signal    ID            : in    std_logic_vector;
        signal    VALID         : in    std_logic;
        signal    READY         : in    std_logic
    ) is
        variable  count         :       integer;
    begin
        count := 0;
        if (MATCH_STD_LOGIC(signals.VALID           ,VALID ) = FALSE) then
            REPORT_MISMATCH(core, name & "VALID " &
                            BIN_TO_STRING(VALID) & " /= " &
                            BIN_TO_STRING(signals.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.READY           ,READY ) = FALSE) then
            REPORT_MISMATCH(core, name & "READY " & 
                            BIN_TO_STRING(READY) & " /= " &
                            BIN_TO_STRING(signals.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.ADDR(ADDR'range),ADDR  ) = FALSE) then
            REPORT_MISMATCH(core, name & "ADDR " &
                            HEX_TO_STRING(ADDR ) & " /= " &
                            HEX_TO_STRING(signals.ADDR(ADDR'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.LEN(LEN'range)  ,LEN   ) = FALSE) then
            REPORT_MISMATCH(core, name & "LEN " &
                            BIN_TO_STRING(LEN  ) & " /= " &
                            BIN_TO_STRING(signals.LEN));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.SIZE            ,SIZE  ) = FALSE) then
            REPORT_MISMATCH(core, name & "SIZE " &
                            BIN_TO_STRING(SIZE ) & " /= " &
                            BIN_TO_STRING(signals.SIZE));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.BURST           ,BURST ) = FALSE) then
            REPORT_MISMATCH(core, name & "BURST " &
                            BIN_TO_STRING(BURST) & " /= " &
                            BIN_TO_STRING(signals.BURST));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.LOCK(LOCK'range),LOCK  ) = FALSE) then
            REPORT_MISMATCH(core, name & "LOCK " &
                            BIN_TO_STRING(LOCK ) & " /= " &
                            BIN_TO_STRING(signals.LOCK));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.CACHE           ,CACHE ) = FALSE) then
            REPORT_MISMATCH(core, name & "CACHE " &
                            BIN_TO_STRING(CACHE) & " /= " &
                            BIN_TO_STRING(signals.CACHE));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.PROT            ,PROT  ) = FALSE) then
            REPORT_MISMATCH(core, name & "PROT " &
                            BIN_TO_STRING(PROT ) & " /= " &
                            BIN_TO_STRING(signals.PROT));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.QOS             ,QOS   ) = FALSE) then
            REPORT_MISMATCH(core, name & "QOS " &
                            HEX_TO_STRING(QOS  ) & " /= " &
                            HEX_TO_STRING(signals.QOS));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.REGION          ,REGION) = FALSE) then
            REPORT_MISMATCH(core, name & "REGION " &
                            HEX_TO_STRING(REGION) & " /= " &
                            HEX_TO_STRING(signals.REGION));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.ID(ID'range)    ,ID    ) = FALSE) then
            REPORT_MISMATCH(core, name & "ID " &
                            HEX_TO_STRING(ID   ) & " /= " &
                            HEX_TO_STRING(signals.ID(ID'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.USER(USER'range),USER  ) = FALSE) then
            REPORT_MISMATCH(core, name & "USER " &
                            HEX_TO_STRING(USER ) & " /= " &
                            HEX_TO_STRING(signals.USER(USER'range)));
            count := count + 1;
        end if;
        match := (count = 0);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライトアドレスチャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    signals     信号の期待値.
    --! @param    match       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure match_axi4_aw_channel(
        variable  core      : inout CORE_TYPE;
                  signals   : in    AXI4_A_CHANNEL_SIGNAL_TYPE;
                  match     : out   boolean
    ) is
    begin
        match_axi4_channel(
            core        => core         , -- I/O :
            name        => "AW"         , -- In  :
            signals     => signals      , -- In  :
            match       => match        , -- Out :
            ADDR        => AWADDR_I     , -- In  :
            LEN         => AWLEN_I      , -- In  :
            SIZE        => AWSIZE_I     , -- In  :
            BURST       => AWBURST_I    , -- In  :
            LOCK        => AWLOCK_I     , -- In  :
            CACHE       => AWCACHE_I    , -- In  :
            PROT        => AWPROT_I     , -- In  :
            QOS         => AWQOS_I      , -- In  :
            REGION      => AWREGION_I   , -- In  :
            USER        => AWUSER_I     , -- In  :
            ID          => AWID_I       , -- In  :
            VALID       => AWVALID_I    , -- In  :
            READY       => AWREADY_I      -- In  :
        );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief リードアドレスチャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    signals     信号の期待値.
    --! @param    match       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure match_axi4_ar_channel(
        variable  core      : inout CORE_TYPE;
                  signals   : in    AXI4_A_CHANNEL_SIGNAL_TYPE;
                  match     : out   boolean
    ) is
    begin
        match_axi4_channel(
            core        => core         , -- I/O :
            name        => "AR"         , -- In  :
            signals     => signals      , -- In  :
            match       => match        , -- Out :
            ADDR        => ARADDR_I     , -- In  :
            LEN         => ARLEN_I      , -- In  :
            SIZE        => ARSIZE_I     , -- In  :
            BURST       => ARBURST_I    , -- In  :
            LOCK        => ARLOCK_I     , -- In  :
            CACHE       => ARCACHE_I    , -- In  :
            PROT        => ARPROT_I     , -- In  :
            QOS         => ARQOS_I      , -- In  :
            REGION      => ARREGION_I   , -- In  :
            USER        => ARUSER_I     , -- In  :
            ID          => ARID_I       , -- In  :
            VALID       => ARVALID_I    , -- In  :
            READY       => ARREADY_I      -- In  :
        );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライトデータチャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    signals     信号の期待値.
    --! @param    match       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure match_axi4_w_channel(
        variable  core      : inout CORE_TYPE;
                  signals   : in    AXI4_W_CHANNEL_SIGNAL_TYPE;
                  match     : out   boolean
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        if (MATCH_STD_LOGIC(signals.VALID              ,WVALID_I) = FALSE) then
            REPORT_MISMATCH(core, "WVALID " & 
                            BIN_TO_STRING(WVALID_I) & " /= " &
                            BIN_TO_STRING(signals.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.READY              ,WREADY_I) = FALSE) then
            REPORT_MISMATCH(core, "WREADY " &
                            BIN_TO_STRING(WREADY_I) & " /= " &
                            BIN_TO_STRING(signals.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.DATA(WDATA_I'range),WDATA_I ) = FALSE) then
            REPORT_MISMATCH(core, "WDATA " &
                            HEX_TO_STRING(WDATA_I ) & " /= " &
                            HEX_TO_STRING(signals.DATA(WDATA_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.STRB(WSTRB_I'range),WSTRB_I ) = FALSE) then
            REPORT_MISMATCH(core, "WSTRB " &
                            BIN_TO_STRING(WSTRB_I ) & " /= " &
                            BIN_TO_STRING(signals.STRB(WSTRB_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.LAST               ,WLAST_I ) = FALSE) then
            REPORT_MISMATCH(core, "WLAST " &
                            BIN_TO_STRING(WLAST_I ) & " /= " &
                            BIN_TO_STRING(signals.LAST));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.ID(WID_I'range)    ,WID_I   ) = FALSE) then
            REPORT_MISMATCH(core, "WID " &
                            HEX_TO_STRING(WID_I   ) & " /= " &
                            HEX_TO_STRING(signals.ID(WID_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.USER(WUSER_I'range),WUSER_I ) = FALSE) then
            REPORT_MISMATCH(core, "WUSER " &
                            HEX_TO_STRING(WUSER_I ) & " /= " &
                            HEX_TO_STRING(signals.USER(WUSER_I'range)));
            count := count + 1;
        end if;
        match := (count = 0);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライト応答チャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    signals     信号の期待値.
    --! @param    match       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure match_axi4_b_channel(
        variable  core      : inout CORE_TYPE;
                  signals   : in    AXI4_B_CHANNEL_SIGNAL_TYPE;
                  match     : out   boolean
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        if (MATCH_STD_LOGIC(signals.VALID              ,BVALID_I) = FALSE) then
            REPORT_MISMATCH(core, "BVALID " & 
                            BIN_TO_STRING(BVALID_I)  & " /= " &
                            BIN_TO_STRING(signals.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.READY              ,BREADY_I) = FALSE) then
            REPORT_MISMATCH(core, "BREADY " &
                            BIN_TO_STRING(BREADY_I)  & " /= " &
                            BIN_TO_STRING(signals.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.RESP               ,BRESP_I ) = FALSE) then
            REPORT_MISMATCH(core, "BRESP "  &
                            BIN_TO_STRING(BRESP_I )  & " /= " &
                            BIN_TO_STRING(signals.RESP));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.ID(BID_I'range)    ,BID_I   ) = FALSE) then
            REPORT_MISMATCH(core, "BID "    &
                            HEX_TO_STRING(BID_I   )  & " /= " &
                            HEX_TO_STRING(signals.ID(BID_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.USER(BUSER_I'range),BUSER_I ) = FALSE) then
            REPORT_MISMATCH(core, "BUSER "  &
                            HEX_TO_STRING(BUSER_I )  & " /= " &
                            HEX_TO_STRING(signals.USER(BUSER_I'range)));
            count := count + 1;
        end if;
        match := (count = 0);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief リードデータチャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    signals     信号の期待値.
    --! @param    match       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure match_axi4_r_channel(
        variable  core      : inout CORE_TYPE;
                  signals   : in    AXI4_R_CHANNEL_SIGNAL_TYPE;
                  match     : out   boolean
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        if (MATCH_STD_LOGIC(signals.VALID              ,RVALID_I) = FALSE) then
            REPORT_MISMATCH(core, "RVALID " & 
                            BIN_TO_STRING(RVALID_I) & " /= " &
                            BIN_TO_STRING(signals.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.READY              ,RREADY_I) = FALSE) then
            REPORT_MISMATCH(core, "RREADY " &
                            BIN_TO_STRING(RREADY_I) & " /= " &
                            BIN_TO_STRING(signals.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.DATA(RDATA_I'range),RDATA_I ) = FALSE) then
            REPORT_MISMATCH(core, "RDATA " &
                            HEX_TO_STRING(RDATA_I ) & " /= " &
                            HEX_TO_STRING(signals.DATA(RDATA_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.LAST               ,RLAST_I ) = FALSE) then
            REPORT_MISMATCH(core, "RLAST " &
                            BIN_TO_STRING(RLAST_I ) & " /= " &
                            BIN_TO_STRING(signals.LAST));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.RESP               ,RRESP_I ) = FALSE) then
            REPORT_MISMATCH(core, "RRESP " &
                            BIN_TO_STRING(RRESP_I ) & " /= " &
                            BIN_TO_STRING(signals.RESP));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.ID(RID_I'range)    ,RID_I   ) = FALSE) then
            REPORT_MISMATCH(core, "RID " &
                            HEX_TO_STRING(RID_I   ) & " /= " &
                            HEX_TO_STRING(signals.ID(RID_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.USER(RUSER_I'range),RUSER_I ) = FALSE) then
            REPORT_MISMATCH(core, "RUSER " &
                            HEX_TO_STRING(RUSER_I ) & " /= " &
                            HEX_TO_STRING(signals.USER(RUSER_I'range)));
            count := count + 1;
        end if;
        match := (count = 0);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 全チャネルの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    signals     信号の期待値.
    --! @param    match       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure  match_axi4_channel(
        variable  core      : inout CORE_TYPE;
                  signals   : in    AXI4_CHANNEL_SIGNAL_TYPE;
                  match     : out   boolean
    ) is
        variable  aw_match  :       boolean;
        variable  w_match   :       boolean;
        variable  b_match   :       boolean;
        variable  ar_match  :       boolean;
        variable  r_match   :       boolean;
    begin
        if (WRITE_ENABLE) then
            match_axi4_aw_channel(core, signals.AW, aw_match);
            match_axi4_w_channel (core, signals.W , w_match );
            match_axi4_b_channel (core, signals.B , b_match );
        else
            aw_match := TRUE;
            w_match  := TRUE;
            b_match  := TRUE;
        end if;
        if (READ_ENABLE) then
            match_axi4_ar_channel(core, signals.AR, ar_match);
            match_axi4_r_channel (core, signals.R , r_match );
        else
            ar_match := TRUE;
            r_match  := TRUE;
        end if;
        match := aw_match and w_match and b_match and ar_match and r_match;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライトアドレスチャネルの転送を待つサブプログラム.
    -------------------------------------------------------------------------------
    procedure  wait_until_xfer_ar(
        variable  core      : inout CORE_TYPE;
                  proc_name : in    string;
                  timeout   : in    integer
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        WAIT_LOOP: loop
            wait until (ACLK'event and ACLK = '1');
            exit when  (ARVALID_I = '1' and ARREADY_I = '1');
            if (count >= timeout) then
                EXECUTE_ABORT(core, proc_name, "WAIT AR Time Out!");
            end if;
            count := count + 1;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief リードアドレスチャネルの転送を待つサブプログラム.
    -------------------------------------------------------------------------------
    procedure  wait_until_xfer_aw(
        variable  core      : inout CORE_TYPE;
                  proc_name : in    string;
                  timeout   : in    integer
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        WAIT_LOOP: loop
            wait until (ACLK'event and ACLK = '1');
            exit when  (AWVALID_I = '1' and AWREADY_I = '1');
            if (count >= timeout) then
                EXECUTE_ABORT(core, proc_name, "WAIT AW Time Out!");
            end if;
            count := count + 1;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief リードデータチャネルのデータ転送を待つサブプログラム.
    -------------------------------------------------------------------------------
    procedure  wait_until_xfer_r(
        variable  core      : inout CORE_TYPE;
                  proc_name : in    string;
                  timeout   : in    integer;
                  last      : in    std_logic
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        WAIT_LOOP: loop
            wait until (ACLK'event and ACLK = '1');
            exit when  (RVALID_I = '1' and RREADY_I = '1' and (last = '0' or RLAST_I = '1'));
            if (count >= timeout) then
                EXECUTE_ABORT(core, proc_name, "WAIT R Time Out!");
            end if;
            count := count + 1;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライトデータチャネルのデータ転送を待つサブプログラム.
    -------------------------------------------------------------------------------
    procedure  wait_until_xfer_w(
        variable  core      : inout CORE_TYPE;
                  proc_name : in    string;
                  timeout   : in    integer;
                  last      : in    std_logic
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        WAIT_LOOP: loop
            wait until (ACLK'event and ACLK = '1');
            exit when  (WVALID_I = '1' and WREADY_I = '1' and (last = '0' or WLAST_I = '1'));
            if (count >= timeout) then
                EXECUTE_ABORT(core, proc_name, "WAIT W Time Out!");
            end if;
            count := count + 1;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ライト応答チャネルの転送を待つサブプログラム.
    -------------------------------------------------------------------------------
    procedure  wait_until_xfer_b(
        variable  core      : inout CORE_TYPE;
                  proc_name : in    string;
                  timeout   : in    integer
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        WAIT_LOOP: loop
            wait until (ACLK'event and ACLK = '1');
            exit when  (BVALID_I = '1' and BREADY_I = '1');
            if (count >= timeout) then
                EXECUTE_ABORT(core, proc_name, "WAIT B Time Out!");
            end if;
            count := count + 1;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief チャネル信号変数の初期化.
    -------------------------------------------------------------------------------
    function  GEN_INIT_signals return AXI4_CHANNEL_SIGNAL_TYPE is
        variable  value : AXI4_CHANNEL_SIGNAL_TYPE;
    begin
        value := AXI4_CHANNEL_SIGNAL_DONTCARE;
        if (MASTER) then
            case CHANNEL is
                when AXI4_CHANNEL_AR =>
                    value.AR       := AXI4_A_CHANNEL_SIGNAL_NULL;
                    value.AR.READY := '-';
                when AXI4_CHANNEL_AW =>
                    value.AW       := AXI4_A_CHANNEL_SIGNAL_NULL;
                    value.AW.READY := '-';
                when AXI4_CHANNEL_W  =>
                    value.W        := AXI4_W_CHANNEL_SIGNAL_NULL;
                    value.W.READY  := '-';
                when AXI4_CHANNEL_R  => 
                    value.R        := AXI4_R_CHANNEL_SIGNAL_DONTCARE;
                    value.R.READY  := '0';
                when AXI4_CHANNEL_B  =>
                    value.B        := AXI4_B_CHANNEL_SIGNAL_DONTCARE;
                    value.B.READY  := '0';
                when others =>
                    null;
            end case;
        end if;
        if (SLAVE) then
            case CHANNEL is
                when AXI4_CHANNEL_AR =>
                    value.AR       := AXI4_A_CHANNEL_SIGNAL_DONTCARE;
                    value.AR.READY := '0';
                when AXI4_CHANNEL_AW =>
                    value.AW       := AXI4_A_CHANNEL_SIGNAL_DONTCARE;
                    value.AW.READY := '0';
                when AXI4_CHANNEL_W  =>
                    value.W        := AXI4_W_CHANNEL_SIGNAL_DONTCARE;
                    value.W.READY  := '0';
                when AXI4_CHANNEL_R  => 
                    value.R        := AXI4_R_CHANNEL_SIGNAL_NULL;
                    value.R.READY  := '-';
                when AXI4_CHANNEL_B  => 
                    value.B        := AXI4_B_CHANNEL_SIGNAL_NULL;
                    value.B.READY  := '-';
                when others =>
                    null;
            end case;
        end if;
        return value;
    end function;
    constant  INIT_SIGNALS  : AXI4_CHANNEL_SIGNAL_TYPE := GEN_INIT_SIGNALS;
    -------------------------------------------------------------------------------
    -- キーワードの定義.
    -------------------------------------------------------------------------------
    subtype   KEY_TYPE is STRING(1 to 7);
    constant  KEY_AR        : KEY_TYPE := "AR     ";
    constant  KEY_AW        : KEY_TYPE := "AW     ";
    constant  KEY_W         : KEY_TYPE := "W      ";
    constant  KEY_R         : KEY_TYPE := "R      ";
    constant  KEY_B         : KEY_TYPE := "B      ";

    constant  KEY_NULL      : KEY_TYPE := "       ";
    constant  KEY_SAY       : KEY_TYPE := "SAY    ";
    constant  KEY_SYNC      : KEY_TYPE := "SYNC   ";
    constant  KEY_WAIT      : KEY_TYPE := "WAIT   ";
    constant  KEY_CHECK     : KEY_TYPE := "CHECK  ";
    constant  KEY_OUT       : KEY_TYPE := "OUT    ";
    constant  KEY_DEBUG     : KEY_TYPE := "DEBUG  ";
    constant  KEY_REPORT    : KEY_TYPE := "REPORT ";
    constant  KEY_TIMEOUT   : KEY_TYPE := "TIMEOUT";

    constant  KEY_READ      : KEY_TYPE := "READ   ";
    constant  KEY_WRITE     : KEY_TYPE := "WRITE  ";
    constant  KEY_ADDR      : KEY_TYPE := "ADDR   ";
    constant  KEY_LEN       : KEY_TYPE := "LEN    ";
    constant  KEY_SIZE      : KEY_TYPE := "SIZE   ";
    constant  KEY_BURST     : KEY_TYPE := "BURST  ";
    constant  KEY_LOCK      : KEY_TYPE := "LOCK   ";
    constant  KEY_CACHE     : KEY_TYPE := "CACHE  ";
    constant  KEY_PROT      : KEY_TYPE := "PROT   ";
    constant  KEY_QOS       : KEY_TYPE := "QOS    ";
    constant  KEY_REGION    : KEY_TYPE := "REGION ";
    constant  KEY_USER      : KEY_TYPE := "USER   ";
    constant  KEY_ID        : KEY_TYPE := "ID     ";
    constant  KEY_DATA      : KEY_TYPE := "DATA   ";
    constant  KEY_RESP      : KEY_TYPE := "RESP   ";
    constant  KEY_LAST      : KEY_TYPE := "LAST   ";
    constant  KEY_KEEP      : KEY_TYPE := "KEEP   ";
    constant  KEY_DEST      : KEY_TYPE := "DEST   ";
    constant  KEY_STRB      : KEY_TYPE := "STRB   ";
    constant  KEY_VALID     : KEY_TYPE := "VALID  ";
    constant  KEY_READY     : KEY_TYPE := "READY  ";

    constant  KEY_AWRITE    : KEY_TYPE := "AWRITE ";
    constant  KEY_ALEN      : KEY_TYPE := "ALEN   ";
    constant  KEY_ASIZE     : KEY_TYPE := "ASIZE  ";
    constant  KEY_ABURST    : KEY_TYPE := "ABURST ";
    constant  KEY_ALOCK     : KEY_TYPE := "ALOCK  ";
    constant  KEY_ACACHE    : KEY_TYPE := "ACACHE ";
    constant  KEY_APROT     : KEY_TYPE := "APROT  ";
    constant  KEY_AQOS      : KEY_TYPE := "AQOS   ";
    constant  KEY_AREGION   : KEY_TYPE := "AREGION";
    constant  KEY_AUSER     : KEY_TYPE := "AUSER  ";
    constant  KEY_AID       : KEY_TYPE := "AID    ";
    constant  KEY_AVALID    : KEY_TYPE := "AVALID ";
    constant  KEY_AREADY    : KEY_TYPE := "AREADY ";
    
    constant  KEY_AWADDR    : KEY_TYPE := "AWADDR ";
    constant  KEY_AWLEN     : KEY_TYPE := "AWLEN  ";
    constant  KEY_AWSIZE    : KEY_TYPE := "AWSIZE ";
    constant  KEY_AWBURST   : KEY_TYPE := "AWBURST";
    constant  KEY_AWLOCK    : KEY_TYPE := "AWLOCK ";
    constant  KEY_AWCACHE   : KEY_TYPE := "AWCACHE";
    constant  KEY_AWPROT    : KEY_TYPE := "AWPROT ";
    constant  KEY_AWQOS     : KEY_TYPE := "AWQOS  ";
    constant  KEY_AWUSER    : KEY_TYPE := "AWUSER ";
    constant  KEY_AWREGION  : KEY_TYPE := "AWREGIO";
    constant  KEY_AWID      : KEY_TYPE := "AWID   ";
    constant  KEY_AWVALID   : KEY_TYPE := "AWVALID";
    constant  KEY_AWREADY   : KEY_TYPE := "AWREADY";
    
    constant  KEY_ARADDR    : KEY_TYPE := "ARADDR ";
    constant  KEY_ARLEN     : KEY_TYPE := "ARLEN  ";
    constant  KEY_ARSIZE    : KEY_TYPE := "ARSIZE ";
    constant  KEY_ARBURST   : KEY_TYPE := "ARBURST";
    constant  KEY_ARLOCK    : KEY_TYPE := "ARLOCK ";
    constant  KEY_ARCACHE   : KEY_TYPE := "ARCACHE";
    constant  KEY_ARPROT    : KEY_TYPE := "ARPROT ";
    constant  KEY_ARQOS     : KEY_TYPE := "ARQOS  ";
    constant  KEY_ARUSER    : KEY_TYPE := "ARUSER ";
    constant  KEY_ARREGION  : KEY_TYPE := "ARREGIO";
    constant  KEY_ARID      : KEY_TYPE := "ARID   ";
    constant  KEY_ARVALID   : KEY_TYPE := "ARVALID";
    constant  KEY_ARREADY   : KEY_TYPE := "ARREADY";
    
    constant  KEY_RDATA     : KEY_TYPE := "RDATA  ";
    constant  KEY_RRESP     : KEY_TYPE := "RRESP  ";
    constant  KEY_RLAST     : KEY_TYPE := "RLAST  ";
    constant  KEY_RUSER     : KEY_TYPE := "RUSER  ";
    constant  KEY_RID       : KEY_TYPE := "RID    ";
    constant  KEY_RVALID    : KEY_TYPE := "RVALID ";
    constant  KEY_RREADY    : KEY_TYPE := "RREADY ";

    constant  KEY_WDATA     : KEY_TYPE := "WDATA  ";
    constant  KEY_WSTRB     : KEY_TYPE := "WSTRB  ";
    constant  KEY_WLAST     : KEY_TYPE := "WLAST  ";
    constant  KEY_WUSER     : KEY_TYPE := "WUSER  ";
    constant  KEY_WID       : KEY_TYPE := "WID    ";
    constant  KEY_WVALID    : KEY_TYPE := "WVALID ";
    constant  KEY_WREADY    : KEY_TYPE := "WREADY ";

    constant  KEY_BRESP     : KEY_TYPE := "BRESP  ";
    constant  KEY_BUSER     : KEY_TYPE := "BUSER  ";
    constant  KEY_BID       : KEY_TYPE := "BID    ";
    constant  KEY_BVALID    : KEY_TYPE := "BVALID ";
    constant  KEY_BREADY    : KEY_TYPE := "BREADY ";

    constant  KEY_DUSER     : KEY_TYPE := "DUSER  ";
    constant  KEY_OKAY      : KEY_TYPE := "OKAY   ";
    constant  KEY_EXOKAY    : KEY_TYPE := "EXOKAY ";
    constant  KEY_SLVERR    : KEY_TYPE := "SLVERR ";
    constant  KEY_DECERR    : KEY_TYPE := "DECERR ";
    constant  KEY_FIXED     : KEY_TYPE := "FIXED  ";
    constant  KEY_INCR      : KEY_TYPE := "INCR   ";
    constant  KEY_WRAP      : KEY_TYPE := "WRAP   ";
    constant  KEY_RESV      : KEY_TYPE := "RESV   ";

    function  GENERATE_KEY_CHANNEL return KEY_TYPE is
    begin
        case CHANNEL is
            when AXI4_CHANNEL_AR => return KEY_AR;
            when AXI4_CHANNEL_AW => return KEY_AW;
            when AXI4_CHANNEL_R  => return KEY_R;
            when AXI4_CHANNEL_W  => return KEY_W;
            when AXI4_CHANNEL_B  => return KEY_B;
            when others          => return KEY_NULL;
        end case;
    end function;
    constant  KEY_CHANNEL   : KEY_TYPE := GENERATE_KEY_CHANNEL;

    -------------------------------------------------------------------------------
    --! @brief READERから読み取る信号の種類を示すタイプの定義.
    -------------------------------------------------------------------------------
    type      READ_AXI4_SIGNAL_TYPE is (
              READ_NONE     ,
              READ_ARADDR   ,
              READ_ARSIZE   ,
              READ_ARLEN    ,
              READ_ARBURST  ,
              READ_ARLOCK   ,
              READ_ARCACHE  ,
              READ_ARPROT   ,
              READ_ARQOS    ,
              READ_ARREGION ,
              READ_ARUSER   ,
              READ_ARID     ,
              READ_ARVALID  ,
              READ_ARREADY  ,
              READ_AWADDR   ,
              READ_AWSIZE   ,
              READ_AWLEN    ,
              READ_AWBURST  ,
              READ_AWLOCK   ,
              READ_AWCACHE  ,
              READ_AWPROT   ,
              READ_AWQOS    ,
              READ_AWREGION ,
              READ_AWUSER   ,
              READ_AWID     ,
              READ_AWVALID  ,
              READ_AWREADY  ,
              READ_RDATA    ,
              READ_RRESP    ,
              READ_RLAST    ,
              READ_RUSER    ,
              READ_RID      ,
              READ_RVALID   ,
              READ_RREADY   ,
              READ_WDATA    ,
              READ_WSTRB    ,
              READ_WLAST    ,
              READ_WUSER    ,
              READ_WID      ,
              READ_WVALID   ,
              READ_WREADY   ,
              READ_BRESP    ,
              READ_BUSER    ,
              READ_BID      ,
              READ_BVALID   ,
              READ_BREADY   
    );
    -------------------------------------------------------------------------------
    --! @brief KEY_WORD から READ_AXI4_SIGNAL_TYPEに変換する関数.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    KEY_WORD    キーワード.
    --! @param    CHANNEL     チャネルのタイプ.
    --! @param    R           リード可/不可を指定.
    --! @param    W           ライト可/不可を指定.
    --! @return               変換されたREAD_AXI4_SIGNAL_TYPE.
    -------------------------------------------------------------------------------
    function  to_read_axi4_channel_signal(
                  key_word   : KEY_TYPE;
                  channel    : AXI4_CHANNEL_TYPE;
                  r,w        : boolean
    ) return READ_AXI4_SIGNAL_TYPE is
    begin
        if (w and not r) then
            case key_word is
                when KEY_ID         =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWID ;
                        when AXI4_CHANNEL_W  => return READ_WID  ;
                        when AXI4_CHANNEL_B  => return READ_BID  ;
                        when others          => null;
                    end case;
                when KEY_USER       =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWUSER;
                        when AXI4_CHANNEL_W  => return READ_WUSER;
                        when AXI4_CHANNEL_B  => return READ_BUSER;
                        when others          => null;
                    end case;
                when KEY_VALID      =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWVALID;
                        when AXI4_CHANNEL_W  => return READ_WVALID;
                        when AXI4_CHANNEL_B  => return READ_BVALID;
                        when others           => null;
                    end case;
                when KEY_READY      =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWREADY;
                        when AXI4_CHANNEL_W  => return READ_WREADY;
                        when AXI4_CHANNEL_B  => return READ_BREADY;
                        when others          => null;
                    end case;
                when KEY_DATA       =>
                    case channel is
                        when AXI4_CHANNEL_W  => return READ_WDATA;
                        when others          => null;
                    end case;
                when KEY_LAST       =>
                    case channel is
                        when AXI4_CHANNEL_W  => return READ_WLAST;
                        when others          => null;
                    end case;
                when KEY_RESP       =>
                    case channel is
                        when AXI4_CHANNEL_B  => return READ_BRESP;
                        when others          => null;
                    end case;
                when KEY_ADDR       => 
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWADDR;
                        when others          => null;
                    end case;
                when KEY_LEN        =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWLEN;
                        when others          => null;
                    end case;
                when KEY_SIZE       =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWSIZE;
                        when others          => null;
                    end case;
                when KEY_BURST      =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWBURST;
                        when others          => null;
                    end case;
                when KEY_LOCK       =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWLOCK;
                        when others          => null;
                    end case;
                when KEY_CACHE      =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWCACHE;
                        when others          => null;
                    end case;
                when KEY_PROT       =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWPROT;
                        when others          => null;
                    end case;
                when KEY_QOS        =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWQOS;
                        when others          => null;
                    end case;
                when KEY_REGION     =>
                    case channel is
                        when AXI4_CHANNEL_AW => return READ_AWREGION;
                        when others          => null;
                    end case;
                when KEY_STRB       =>
                    case channel is
                        when AXI4_CHANNEL_W  => return READ_WSTRB;
                        when others          => null;
                    end case;
                when KEY_AWADDR              => return READ_AWADDR;
                when KEY_AWLEN               => return READ_AWLEN;   
                when KEY_AWSIZE              => return READ_AWSIZE;  
                when KEY_AWBURST             => return READ_AWBURST; 
                when KEY_AWLOCK              => return READ_AWLOCK;  
                when KEY_AWCACHE             => return READ_AWCACHE; 
                when KEY_AWPROT              => return READ_AWPROT;  
                when KEY_AWQOS               => return READ_AWQOS;   
                when KEY_AWREGION            => return READ_AWREGION;
                when KEY_AWUSER              => return READ_AWUSER;  
                when KEY_AWID                => return READ_AWID;    
                when KEY_AWVALID             => return READ_AWVALID; 
                when KEY_AWREADY             => return READ_AWREADY; 
                when KEY_ALEN                => return READ_AWLEN;   
                when KEY_ASIZE               => return READ_AWSIZE;  
                when KEY_ABURST              => return READ_AWBURST; 
                when KEY_ALOCK               => return READ_AWLOCK;  
                when KEY_ACACHE              => return READ_AWCACHE; 
                when KEY_APROT               => return READ_AWPROT;  
                when KEY_AQOS                => return READ_AWQOS;   
                when KEY_AREGION             => return READ_AWREGION;
                when KEY_AUSER               => return READ_AWUSER;  
                when KEY_AID                 => return READ_AWID;    
                when KEY_AVALID              => return READ_AWVALID; 
                when KEY_AREADY              => return READ_AWREADY; 
                when KEY_WDATA               => return READ_WDATA;  
                when KEY_WSTRB               => return READ_WSTRB;  
                when KEY_WLAST               => return READ_WLAST;  
                when KEY_WUSER               => return READ_WUSER;  
                when KEY_WID                 => return READ_WID;    
                when KEY_WVALID              => return READ_WVALID; 
                when KEY_WREADY              => return READ_WREADY; 
                when KEY_BRESP               => return READ_BRESP;  
                when KEY_BUSER               => return READ_BUSER;  
                when KEY_BID                 => return READ_BID;    
                when KEY_BVALID              => return READ_BVALID; 
                when KEY_BREADY              => return READ_BREADY; 
                when others                  => null;
            end case;
        elsif (r and not w) then
            case key_word is
                when KEY_ID         =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARID ;
                        when AXI4_CHANNEL_R  => return READ_RID  ;
                        when others          => null;
                    end case;
                when KEY_USER       =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARUSER;  
                        when AXI4_CHANNEL_R  => return READ_RUSER;
                        when others          => null;
                    end case;
                when KEY_VALID      =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARVALID; 
                        when AXI4_CHANNEL_R  => return READ_RVALID; 
                        when others          => null;
                    end case;
                when KEY_READY      =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARREADY; 
                        when AXI4_CHANNEL_R  => return READ_RREADY; 
                        when others          => null;
                    end case;
                when KEY_DATA       =>
                    case channel is
                        when AXI4_CHANNEL_R  => return READ_RDATA;
                        when others          => null;
                    end case;
                when KEY_LAST       =>
                    case channel is
                        when AXI4_CHANNEL_R  => return READ_RLAST;
                        when others          => null;
                    end case;
                when KEY_RESP       =>
                    case channel is
                        when AXI4_CHANNEL_R  => return READ_RRESP;
                        when others          => null;
                    end case;
                when KEY_ADDR       =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARADDR;
                        when others          => null;
                    end case;
                when KEY_LEN        =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARLEN;
                        when others          => null;
                    end case;
                when KEY_SIZE       =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARSIZE;  
                        when others          => null;
                    end case;
                when KEY_BURST      =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARBURST;
                        when others          => null;
                    end case;
                when KEY_LOCK       =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARLOCK;
                        when others          => null;
                    end case;
                when KEY_CACHE      =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARCACHE;
                        when others          => null;
                    end case;
                when KEY_PROT       =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARPROT;
                        when others          => null;
                    end case;
                when KEY_QOS        =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARQOS;  
                        when others          => null;
                    end case;
                when KEY_REGION     =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARREGION;
                        when others          => null;
                    end case;
                when KEY_ARADDR              => return READ_ARADDR;   
                when KEY_ARLEN               => return READ_ARLEN;   
                when KEY_ARSIZE              => return READ_ARSIZE;  
                when KEY_ARBURST             => return READ_ARBURST; 
                when KEY_ARLOCK              => return READ_ARLOCK;  
                when KEY_ARCACHE             => return READ_ARCACHE; 
                when KEY_ARPROT              => return READ_ARPROT;  
                when KEY_ARQOS               => return READ_ARQOS;   
                when KEY_ARREGION            => return READ_ARREGION;
                when KEY_ARUSER              => return READ_ARUSER;  
                when KEY_ARID                => return READ_ARID;    
                when KEY_ARVALID             => return READ_ARVALID; 
                when KEY_ARREADY             => return READ_ARREADY;
                when KEY_ALEN                => return READ_ARLEN;   
                when KEY_ASIZE               => return READ_ARSIZE;  
                when KEY_ABURST              => return READ_ARBURST; 
                when KEY_ALOCK               => return READ_ARLOCK;  
                when KEY_ACACHE              => return READ_ARCACHE; 
                when KEY_APROT               => return READ_ARPROT;  
                when KEY_AQOS                => return READ_ARQOS;   
                when KEY_AREGION             => return READ_ARREGION;
                when KEY_AUSER               => return READ_ARUSER;  
                when KEY_AID                 => return READ_ARID;    
                when KEY_AVALID              => return READ_ARVALID; 
                when KEY_AREADY              => return READ_ARREADY; 
                when KEY_RDATA               => return READ_RDATA;  
                when KEY_RRESP               => return READ_RRESP;  
                when KEY_RLAST               => return READ_RLAST;  
                when KEY_RUSER               => return READ_RUSER;  
                when KEY_RID                 => return READ_RID;    
                when KEY_RVALID              => return READ_RVALID; 
                when KEY_RREADY              => return READ_RREADY; 
                when others                  => null;
            end case;
        elsif (r or w) then
            case key_word is
                when KEY_ID         =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARID ;
                        when AXI4_CHANNEL_AW => return READ_AWID ;
                        when AXI4_CHANNEL_R  => return READ_RID  ;
                        when AXI4_CHANNEL_W  => return READ_WID  ;
                        when AXI4_CHANNEL_B  => return READ_BID  ;
                        when others          => null;
                    end case;
                when KEY_USER       =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARUSER;
                        when AXI4_CHANNEL_AW => return READ_AWUSER;
                        when AXI4_CHANNEL_R  => return READ_RUSER;
                        when AXI4_CHANNEL_W  => return READ_WUSER;
                        when AXI4_CHANNEL_B  => return READ_BUSER;
                        when others          => null;
                    end case;
                when KEY_VALID      =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARVALID;
                        when AXI4_CHANNEL_AW => return READ_AWVALID;
                        when AXI4_CHANNEL_R  => return READ_RVALID;
                        when AXI4_CHANNEL_W  => return READ_WVALID;
                        when AXI4_CHANNEL_B  => return READ_BVALID;
                        when others          => null;
                    end case;
                when KEY_READY      =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARREADY;
                        when AXI4_CHANNEL_AW => return READ_AWREADY;
                        when AXI4_CHANNEL_R  => return READ_RREADY;
                        when AXI4_CHANNEL_W  => return READ_WREADY;
                        when AXI4_CHANNEL_B  => return READ_BREADY;
                        when others          => null;
                    end case;
                when KEY_AUSER      =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARUSER;
                        when AXI4_CHANNEL_AW => return READ_AWUSER;
                        when others          => null;
                    end case;
                when KEY_DATA       =>
                    case channel is
                        when AXI4_CHANNEL_R  => return READ_RDATA;
                        when AXI4_CHANNEL_W  => return READ_WDATA;
                        when others          => null;
                    end case;
                when KEY_LAST       =>
                    case channel is
                        when AXI4_CHANNEL_R  => return READ_RLAST;
                        when AXI4_CHANNEL_W  => return READ_WLAST;
                        when others          => null;
                    end case;
                when KEY_RESP       =>
                    case channel is
                        when AXI4_CHANNEL_R  => return READ_RRESP;
                        when AXI4_CHANNEL_B  => return READ_BRESP;
                        when others          => null;
                    end case;
                when KEY_ADDR       => 
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARADDR; 
                        when AXI4_CHANNEL_AW => return READ_AWADDR; 
                        when others          => null;
                    end case;
                when KEY_LEN        =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARLEN; 
                        when AXI4_CHANNEL_AW => return READ_AWLEN; 
                        when others          => null;
                    end case;
                when KEY_SIZE       =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARSIZE;
                        when AXI4_CHANNEL_AW => return READ_AWSIZE;
                        when others          => null;
                    end case;
                when KEY_BURST      =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARBURST;
                        when AXI4_CHANNEL_AW => return READ_AWBURST;
                        when others          => null;
                    end case;
                when KEY_LOCK       =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARLOCK;
                        when AXI4_CHANNEL_AW => return READ_AWLOCK;
                        when others          => null;
                    end case;
                when KEY_CACHE      =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARCACHE;
                        when AXI4_CHANNEL_AW => return READ_AWCACHE;
                        when others          => null;
                    end case;
                when KEY_PROT       =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARPROT;
                        when AXI4_CHANNEL_AW => return READ_AWPROT;
                        when others          => null;
                    end case;
                when KEY_QOS        =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARQOS;
                        when AXI4_CHANNEL_AW => return READ_AWQOS;
                        when others          => null;
                    end case;
                when KEY_REGION     =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARREGION;
                        when AXI4_CHANNEL_AW => return READ_AWREGION;
                        when others          => null;
                    end case;
                when KEY_STRB       =>
                    case channel is
                        when AXI4_CHANNEL_W  => return READ_WSTRB;
                        when others          => null;
                    end case;
                when KEY_AVALID     =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARVALID;
                        when AXI4_CHANNEL_AW => return READ_AWVALID;
                        when AXI4_CHANNEL_R  => return READ_ARVALID;
                        when AXI4_CHANNEL_W  => return READ_AWVALID;
                        when AXI4_CHANNEL_B  => return READ_AWVALID;
                        when others          => null;
                    end case;
                when KEY_AREADY     =>
                    case channel is
                        when AXI4_CHANNEL_AR => return READ_ARREADY;
                        when AXI4_CHANNEL_AW => return READ_AWREADY;
                        when AXI4_CHANNEL_R  => return READ_ARREADY;
                        when AXI4_CHANNEL_W  => return READ_AWREADY;
                        when AXI4_CHANNEL_B  => return READ_AWREADY;
                        when others          => null;
                    end case;
                when KEY_ARADDR              => return READ_ARADDR;
                when KEY_ARLEN               => return READ_ARLEN; 
                when KEY_ARSIZE              => return READ_ARSIZE;
                when KEY_ARBURST             => return READ_ARBURST;
                when KEY_ARLOCK              => return READ_ARLOCK;
                when KEY_ARCACHE             => return READ_ARCACHE;
                when KEY_ARPROT              => return READ_ARPROT;
                when KEY_ARQOS               => return READ_ARQOS; 
                when KEY_ARREGION            => return READ_ARREGION;
                when KEY_ARUSER              => return READ_ARUSER;
                when KEY_ARID                => return READ_ARID;  
                when KEY_ARVALID             => return READ_ARVALID;
                when KEY_ARREADY             => return READ_ARREADY;
                when KEY_AWADDR              => return READ_AWADDR;
                when KEY_AWLEN               => return READ_AWLEN; 
                when KEY_AWSIZE              => return READ_AWSIZE;
                when KEY_AWBURST             => return READ_AWBURST;
                when KEY_AWLOCK              => return READ_AWLOCK;
                when KEY_AWCACHE             => return READ_AWCACHE;
                when KEY_AWPROT              => return READ_AWPROT;
                when KEY_AWQOS               => return READ_AWQOS; 
                when KEY_AWREGION            => return READ_AWREGION;
                when KEY_AWUSER              => return READ_AWUSER;
                when KEY_AWID                => return READ_AWID;  
                when KEY_AWVALID             => return READ_AWVALID;
                when KEY_AWREADY             => return READ_AWREADY;
                when KEY_RDATA               => return READ_RDATA;
                when KEY_RRESP               => return READ_RRESP;
                when KEY_RLAST               => return READ_RLAST;
                when KEY_RUSER               => return READ_RUSER;
                when KEY_RID                 => return READ_RID;  
                when KEY_RVALID              => return READ_RVALID;
                when KEY_RREADY              => return READ_RREADY;
                when KEY_WDATA               => return READ_WDATA;
                when KEY_WSTRB               => return READ_WSTRB;
                when KEY_WLAST               => return READ_WLAST;
                when KEY_WUSER               => return READ_WUSER;
                when KEY_WID                 => return READ_WID;  
                when KEY_WVALID              => return READ_WVALID;
                when KEY_WREADY              => return READ_WREADY;
                when KEY_BRESP               => return READ_BRESP;
                when KEY_BUSER               => return READ_BUSER;
                when KEY_BID                 => return READ_BID;  
                when KEY_BVALID              => return READ_BVALID;
                when KEY_BREADY              => return READ_BREADY;
                when others                  => null;
            end case;
        end if;
        return READ_NONE;
    end function;
    -------------------------------------------------------------------------------
    --! @brief シナリオからトランザクションサイズの値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    stream      シナリオのストリーム.
    --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
    --! @param    val         読み取ったトランザクションサイズの値.
    -------------------------------------------------------------------------------
    procedure read_transaction_size(
        variable  core          : inout CORE_TYPE;
        file      stream        :       TEXT;
                  proc_name     : in    string;
                  val           : inout AXI4_ASIZE_TYPE
    ) is
        variable  size          :       integer;
        variable  good          :       boolean;
    begin
        READ_INTEGER(core, stream, size, good);
        if (good) then
            case size is
                when    128 => val := AXI4_ASIZE_128BYTE;
                when     64 => val := AXI4_ASIZE_64BYTE;
                when     32 => val := AXI4_ASIZE_32BYTE;
                when     16 => val := AXI4_ASIZE_16BYTE;
                when      8 => val := AXI4_ASIZE_8BYTE;
                when      4 => val := AXI4_ASIZE_4BYTE;
                when      2 => val := AXI4_ASIZE_2BYTE;
                when      1 => val := AXI4_ASIZE_1BYTE;
                when others => READ_ERROR(core, proc_name, "KEY=SIZE illegal number=" & INTEGER_TO_STRING(size));
            end case;
        else                   READ_ERROR(core, proc_name, "KEY=SIZE READ_INTEGER not good");
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオからトランザクションバースト長の値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    stream      シナリオのストリーム.
    --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
    --! @param    val         読み取ったトランザクションバースト長の値.
    -------------------------------------------------------------------------------
    procedure read_transaction_alen(
        variable  core          : inout CORE_TYPE;
        file      stream        :       TEXT;
                  proc_name     : in    string;
                  val           : inout std_logic_vector
    ) is
        variable  size          :       integer;
        variable  good          :       boolean;
    begin
        READ_INTEGER(core, stream, size, good);
        if (good) then
            val := std_logic_vector(to_unsigned(size-1, WIDTH.ALEN));
        else
            READ_ERROR(core, proc_name, "KEY=SIZE READ_INTEGER not good");
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオからトランザクション応答ステータスの値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    stream      シナリオのストリーム.
    --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
    --! @param    val         読み取ったトランザクション応答ステータスの値.
    -------------------------------------------------------------------------------
    procedure read_transaction_resp(
        variable  core          : inout CORE_TYPE;
        file      stream        :       TEXT;
                  proc_name     : in    string;
                  val           : inout AXI4_RESP_TYPE
    ) is
        variable  key_word      :       KEY_TYPE;
        variable  next_event    :       EVENT_TYPE;
    begin
        SEEK_EVENT(core, stream, next_event);
        if (next_event = EVENT_SCALAR) then
            READ_EVENT(core, stream, EVENT_SCALAR);
            COPY_KEY_WORD(core, key_word);
            case key_word is
                when KEY_OKAY    => val := AXI4_RESP_OKAY  ;
                when KEY_EXOKAY  => val := AXI4_RESP_EXOKAY;
                when KEY_SLVERR  => val := AXI4_RESP_SLVERR;
                when KEY_DECERR  => val := AXI4_RESP_DECERR;
                when others      => READ_ERROR(core, proc_name, "KEY=RESP illegal key_word=" & key_word);
            end case;
        else
            READ_ERROR(core, proc_name, "KEY=RESP SEEK_EVENT NG");
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオからトランザクションタイムアウトの値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    stream      シナリオのストリーム.
    --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
    --! @param    val         読み取ったタイムアウト値.
    -------------------------------------------------------------------------------
    procedure read_transaction_timeout(
        variable  core          : inout CORE_TYPE;
        file      stream        :       TEXT;
                  proc_name     : in    string;
                  val           : inout integer
    ) is
        variable  timeout       :       integer;
        variable  good          :       boolean;
    begin
        READ_INTEGER(core, stream, timeout, good);
        if (good) then
            val := timeout;
        else
            READ_ERROR(core, proc_name, "KEY=TIMEOUT READ_INTEGER not good");
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオからトランザクションバーストモードの値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    stream      シナリオのストリーム.
    --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
    --! @param    val         読み取ったトランザクションバーストモードの値.
    -------------------------------------------------------------------------------
    procedure read_transaction_burst(
        variable  core          : inout CORE_TYPE;
        file      stream        :       TEXT;
                  proc_name     : in    string;
                  val           : inout AXI4_ABURST_TYPE
    ) is
        variable  key_word      :       KEY_TYPE;
        variable  next_event    :       EVENT_TYPE;
    begin
        SEEK_EVENT(core, stream, next_event);
        if (next_event = EVENT_SCALAR) then
            READ_EVENT(core, stream, EVENT_SCALAR);
            COPY_KEY_WORD(core, key_word);
            case key_word is
                when KEY_FIXED   => val := AXI4_ABURST_FIXED;
                when KEY_INCR    => val := AXI4_ABURST_INCR;
                when KEY_WRAP    => val := AXI4_ABURST_WRAP;
                when KEY_RESV    => val := AXI4_ABURST_RESV;
                when others      => READ_ERROR(core, proc_name, "KEY=BURST illegal key_word=" & key_word);
            end case;
        else
            READ_ERROR(core, proc_name, "KEY=BURST SEEK_EVENT NG");
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief トランザクション情報からアドレスの下位ビットと１ワードのバイト数を生成
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    trans       トランザクション情報.
    --! @param    addr        アドレスの下位ビットの整数値.
    --! @param    size        １ワードのバイト数.
    -------------------------------------------------------------------------------
    procedure transaction_to_addr_and_bytes(
                  trans         : in    AXI4_TRANSACTION_SIGNAL_TYPE;
                  addr          : out   integer;
                  size          : out   integer
    ) is
    begin
        case trans.SIZE is
            when AXI4_ASIZE_1BYTE   => size :=   1; addr := 0;
            when AXI4_ASIZE_2BYTE   => size :=   2; addr := TO_INTEGER(unsigned(trans.ADDR(0 downto 0)));
            when AXI4_ASIZE_4BYTE   => size :=   4; addr := TO_INTEGER(unsigned(trans.ADDR(1 downto 0)));
            when AXI4_ASIZE_8BYTE   => size :=   8; addr := TO_INTEGER(unsigned(trans.ADDR(2 downto 0)));
            when AXI4_ASIZE_16BYTE  => size :=  16; addr := TO_INTEGER(unsigned(trans.ADDR(3 downto 0)));
            when AXI4_ASIZE_32BYTE  => size :=  32; addr := TO_INTEGER(unsigned(trans.ADDR(4 downto 0)));
            when AXI4_ASIZE_64BYTE  => size :=  64; addr := TO_INTEGER(unsigned(trans.ADDR(5 downto 0)));
            when AXI4_ASIZE_128BYTE => size := 128; addr := TO_INTEGER(unsigned(trans.ADDR(6 downto 0)));
            when others             => size :=   0; addr := 0;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからチャネル信号構造体の値を読み取るサブプログラム.
    --!      * このサブプログラムを呼ぶときは、すでにMAP_READ_BEGINを実行済みに
    --!        しておかなければならない。
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    stream      シナリオのストリーム.
    --! @param    channel     チャネルのタイプ.
    --! @param    read        リード可/不可を指定.
    --! @param    write       ライト可/不可を指定.
    --! @param    width       チャネル信号のビット幅を指定する.
    --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
    --! @param    event       次のイベント. inoutであることに注意.
    -------------------------------------------------------------------------------
    procedure map_read_axi4_channel(
        variable  core          : inout CORE_TYPE;
        file      stream        :       TEXT;
                  channel       : in    AXI4_CHANNEL_TYPE;
                  read          : in    boolean;
                  write         : in    boolean;
                  width         : in    AXI4_SIGNAL_WIDTH_TYPE;
                  signals       : inout AXI4_CHANNEL_SIGNAL_TYPE;
                  event         : inout EVENT_TYPE
    ) is
        constant  proc_name     :       string := "MAP_READ_AXI4_CHANNEL";
        variable  next_event    :       EVENT_TYPE;
        variable  key_word      :       KEY_TYPE;
        procedure read_val(val: out std_logic_vector) is
            variable  next_event    : EVENT_TYPE;
            variable  read_len      : integer;
            variable  val_size      : integer;
        begin
            SEEK_EVENT(core, stream, next_event  );
            if (next_event /= EVENT_SCALAR) then
                READ_ERROR(core, proc_name, "READ_VAL NG");
            end if;
            READ_EVENT(core, stream, EVENT_SCALAR);
            STRING_TO_STD_LOGIC_VECTOR(
                STR     => core.str_buf(1 to core.str_len),
                VAL     => val,
                STR_LEN => read_len,
                VAL_LEN => val_size
            );
        end procedure;
        procedure read_val(val: out std_logic) is
            variable  next_event    : EVENT_TYPE;
            variable  read_len      : integer;
            variable  val_size      : integer;
            variable  vec           : std_logic_vector(0 downto 0);
        begin
            SEEK_EVENT(core, stream, next_event  );
            if (next_event /= EVENT_SCALAR) then
                READ_ERROR(core, proc_name, "READ_VAL NG");
            end if;
            READ_EVENT(core, stream, EVENT_SCALAR);
            STRING_TO_STD_LOGIC_VECTOR(
                STR     => core.str_buf(1 to core.str_len),
                VAL     => vec,
                STR_LEN => read_len,
                VAL_LEN => val_size
            );
            val := vec(0);
        end procedure;
    begin
        REPORT_DEBUG(core, proc_name, "BEGIN");
        next_event := event;
        MAP_LOOP: loop
            case next_event is
                when EVENT_SCALAR  =>
                    COPY_KEY_WORD(core, key_word);
                    case to_read_axi4_channel_signal(key_word, channel, read, write) is
                        when READ_ARID     => read_val(signals.AR.ID  (width.ID     -1 downto 0));
                        when READ_ARADDR   => read_val(signals.AR.ADDR(width.ARADDR -1 downto 0));
                        when READ_ARLEN    => read_transaction_alen (core, stream, proc_name, signals.AR.LEN  );
                        when READ_ARSIZE   => read_transaction_size (core, stream, proc_name, signals.AR.SIZE );
                        when READ_ARBURST  => read_transaction_burst(core, stream, proc_name, signals.AR.BURST);
                        when READ_ARLOCK   => read_val(signals.AR.LOCK  );
                        when READ_ARCACHE  => read_val(signals.AR.CACHE );
                        when READ_ARPROT   => read_val(signals.AR.PROT  );
                        when READ_ARQOS    => read_val(signals.AR.QOS   );
                        when READ_ARREGION => read_val(signals.AR.REGION);
                        when READ_ARUSER   => read_val(signals.AR.USER(width.ARUSER -1 downto 0));
                        when READ_ARVALID  => read_val(signals.AR.VALID );
                        when READ_ARREADY  => read_val(signals.AR.READY );
                        when READ_AWID     => read_val(signals.AW.ID  (width.ID     -1 downto 0));
                        when READ_AWADDR   => read_val(signals.AW.ADDR(width.ARADDR -1 downto 0));
                        when READ_AWLEN    => read_transaction_alen (core, stream, proc_name, signals.AW.LEN  );
                        when READ_AWSIZE   => read_transaction_size (core, stream, proc_name, signals.AW.SIZE );
                        when READ_AWBURST  => read_transaction_burst(core, stream, proc_name, signals.AW.BURST);
                        when READ_AWLOCK   => read_val(signals.AW.LOCK  );
                        when READ_AWCACHE  => read_val(signals.AW.CACHE );
                        when READ_AWPROT   => read_val(signals.AW.PROT  );
                        when READ_AWQOS    => read_val(signals.AW.QOS   );
                        when READ_AWREGION => read_val(signals.AW.REGION);
                        when READ_AWUSER   => read_val(signals.AW.USER(width.ARUSER -1 downto 0));
                        when READ_AWVALID  => read_val(signals.AW.VALID );
                        when READ_AWREADY  => read_val(signals.AW.READY );
                        when READ_RID      => read_val(signals.R.ID   (width.ID     -1 downto 0));
                        when READ_RUSER    => read_val(signals.R.USER (width.RUSER  -1 downto 0));
                        when READ_RDATA    => read_val(signals.R.DATA (width.RDATA  -1 downto 0));
                        when READ_RRESP    => read_transaction_resp(core, stream, proc_name, signals.R.RESP);
                        when READ_RLAST    => read_val(signals.R.LAST  );
                        when READ_RVALID   => read_val(signals.R.VALID );
                        when READ_RREADY   => read_val(signals.R.READY );
                        when READ_WID      => read_val(signals.W.ID   (width.ID     -1 downto 0));
                        when READ_WUSER    => read_val(signals.W.USER (width.WUSER  -1 downto 0));
                        when READ_WDATA    => read_val(signals.W.DATA (width.WDATA  -1 downto 0));
                        when READ_WSTRB    => read_val(signals.W.STRB (width.WDATA/8-1 downto 0));
                        when READ_WLAST    => read_val(signals.W.LAST  );
                        when READ_WVALID   => read_val(signals.W.VALID );
                        when READ_WREADY   => read_val(signals.W.READY );
                        when READ_BID      => read_val(signals.B.ID   (width.ID     -1 downto 0));
                        when READ_BUSER    => read_val(signals.B.USER (width.BUSER  -1 downto 0));
                        when READ_BRESP    => read_transaction_resp(core, stream, proc_name, signals.B.RESP);
                        when READ_BVALID   => read_val(signals.B.VALID );
                        when READ_BREADY   => read_val(signals.B.READY );
                        when others        => exit MAP_LOOP;
                    end case;
                when EVENT_MAP_END =>         exit MAP_LOOP;
                when others        =>         exit MAP_LOOP;
            end case;
            SEEK_EVENT(core, stream, next_event);
            if (next_event = EVENT_SCALAR) then
                READ_EVENT(core, stream, EVENT_SCALAR);
            end if;
        end loop;
        event := next_event;
        REPORT_DEBUG(core, proc_name, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからトランザクションの値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    stream      シナリオのストリーム.
    --! @param    addr_width  アドレスのビット幅.
    --! @param    auser_width ユーザー信号のビット幅.
    --! @param    duser_width ユーザー信号のビット幅.
    --! @param    BUSER_WIDTH ユーザー信号のビット幅.
    --! @param    id_width    ID信号のビット幅.
    --! @param    trans       トランザクション信号.
    --! @param    EVENT       次のイベント. inoutであることに注意.
    -------------------------------------------------------------------------------
    procedure map_read_axi4_transaction(
        variable  core          : inout CORE_TYPE;
        file      stream        :       TEXT;
                  addr_width    : in    integer;
                  auser_width   : in    integer;
                  duser_width   : in    integer;
                  buser_width   : in    integer;
                  id_width      : in    integer;
                  trans         : inout AXI4_TRANSACTION_SIGNAL_TYPE;
                  event         : inout EVENT_TYPE
    ) is
        constant  proc_name     :       string := "AXI4_CORE.MAP_READ_AXI4_TRANSACTION";
        variable  next_event    :       EVENT_TYPE;
        variable  key_word      :       KEY_TYPE;
        variable  len           :       integer;
        variable  pos           :       integer;
        variable  number_bytes  :       integer;
        variable  address       :       integer;
        variable  data_bytes    :       integer;
        variable  burst_len     :       integer;
    begin
        REPORT_DEBUG(core, proc_name, "BEGIN");
        next_event := event;
        pos        := trans.DATA_LEN;
        READ_MAP_LOOP: loop
            case next_event is
                when EVENT_SCALAR  =>
                    COPY_KEY_WORD(core, key_word);
                    REPORT_DEBUG(core, proc_name, "KEY=" & key_word);
                    case key_word is
                        when KEY_TIMEOUT=> read_transaction_timeout(core, stream, proc_name, trans.TIMEOUT);
                        when KEY_SIZE   => read_transaction_size   (core, stream, proc_name, trans.SIZE   );
                        when KEY_RESP   => read_transaction_resp   (core, stream, proc_name, trans.RESP   );
                        when KEY_BURST  => read_transaction_burst  (core, stream, proc_name, trans.BURST  );
                        when KEY_LOCK   => READ_STD_LOGIC_VECTOR   (core, stream, trans.LOCK  , len);
                        when KEY_CACHE  => READ_STD_LOGIC_VECTOR   (core, stream, trans.CACHE , len);
                        when KEY_PROT   => READ_STD_LOGIC_VECTOR   (core, stream, trans.PROT  , len);
                        when KEY_QOS    => READ_STD_LOGIC_VECTOR   (core, stream, trans.QOS   , len);
                        when KEY_REGION => READ_STD_LOGIC_VECTOR   (core, stream, trans.REGION, len);
                        when KEY_ADDR   => READ_STD_LOGIC_VECTOR   (core, stream, trans.ADDR (addr_width   -1 downto   0), len);
                        when KEY_AUSER  => READ_STD_LOGIC_VECTOR   (core, stream, trans.AUSER(auser_width  -1 downto   0), len);
                        when KEY_DUSER  => READ_STD_LOGIC_VECTOR   (core, stream, trans.DUSER(duser_width  -1 downto   0), len);
                        when KEY_BUSER  => READ_STD_LOGIC_VECTOR   (core, stream, trans.BUSER(buser_width  -1 downto   0), len);
                        when KEY_ID     => READ_STD_LOGIC_VECTOR   (core, stream, trans.ID   (id_width     -1 downto   0), len);
                        when KEY_DATA   => READ_STD_LOGIC_VECTOR   (core, stream, trans.DATA (trans.DATA'high downto pos), len);
                                           pos := pos + len;
                        when others     => exit READ_MAP_LOOP;
                    end case;
                when EVENT_MAP_END      => exit READ_MAP_LOOP;
                when others             => exit READ_MAP_LOOP;
            end case;
            SEEK_EVENT(core, stream, next_event);
            if (next_event = EVENT_SCALAR) then
                READ_EVENT(core, stream, EVENT_SCALAR);
            end if;
        end loop;
        event          := next_event;
        trans.DATA_LEN := pos;
        transaction_to_addr_and_bytes(trans, address, number_bytes);
        data_bytes := (pos+7)/8;
        burst_len  := (address + data_bytes + number_bytes - 1) / number_bytes;
        trans.LEN  := std_logic_vector(TO_UNSIGNED(burst_len-1, AXI4_ALEN_WIDTH));
        REPORT_DEBUG(core, proc_name, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ローカル同期オペレーション.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    SYNC_REQ    同期開始信号出力.
    --! @param    SYNC_ACK    同期応答信号入力.
    -------------------------------------------------------------------------------
    procedure local_sync(
        variable  core       : inout CORE_TYPE;
        signal    sync_req   : out   SYNC_REQ_VECTOR(0 downto 0);
        signal    sync_ack   : in    SYNC_ACK_VECTOR(0 downto 0)
    ) is
        constant  proc_name  :       string := "LOCAL_SYNC";
        variable  sync_count :       SYNC_REQ_VECTOR(0 downto 0);
    begin
        REPORT_DEBUG(core, proc_name, "BEGIN");
        sync_count(0) := SYNC_LOCAL_WAIT;
        SYNC_BEGIN(sync_req,           sync_count);
        REPORT_DEBUG(core, proc_name, "SYNC");
        SYNC_END  (sync_req, sync_ack, sync_count);
        REPORT_DEBUG(core, proc_name, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief CHECKオペレーション.信号が指定された値になっているかチェック.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    stream      入力ストリーム.
    -------------------------------------------------------------------------------
    procedure execute_check(
        variable  core           : inout CORE_TYPE;
        file      stream         :       TEXT
    ) is
        constant  proc_name      : string := "EXECUTE_CHECK";
        variable  next_event     : EVENT_TYPE;
        variable  keyword        : KEY_TYPE;
        variable  match          : boolean;
        variable  axi_signals    : AXI4_CHANNEL_SIGNAL_TYPE;
        variable  gpi_signals    : std_logic_vector(GPI'range);
    begin
        REPORT_DEBUG(core, proc_name, "BEGIN");
        SEEK_EVENT(core, stream, next_event);
        case next_event is
            when EVENT_MAP_BEGIN =>
                READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                axi_signals := AXI4_CHANNEL_SIGNAL_DONTCARE;
                gpi_signals := (others => '-');
                MAP_READ_LOOP: loop
                    MAP_READ_PREPARE_FOR_NEXT(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    map_read_axi4_channel(
                        core       => core            ,  -- I/O:
                        stream     => stream          ,  -- I/O:
                        channel    => channel         ,  -- In :
                        read       => READ_ENABLE     ,  -- In :
                        write      => WRITE_ENABLE    ,  -- In :
                        width      => WIDTH           ,  -- In :
                        signals    => axi_signals     ,  -- I/O:
                        event      => next_event         -- I/O:
                    );
                    MAP_READ_STD_LOGIC_VECTOR(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        KEY        => "GPI"           ,  -- In :
                        VAL        => gpi_signals     ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    case next_event is
                        when EVENT_SCALAR  =>
                            COPY_KEY_WORD(core, keyword);
                            EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                        when EVENT_MAP_END =>
                            exit MAP_READ_LOOP;
                        when others        =>
                            READ_ERROR(core, proc_name, "need EVENT_MAP_END but " &
                                       EVENT_TO_STRING(next_event));
                    end case;
                end loop;
                match_axi4_channel(core, axi_signals, match);
                MATCH_GPI         (core, gpi_signals, GPI, match);
            when others =>
                READ_ERROR(core, proc_name, "SEEK_EVENT NG");
        end case;
        REPORT_DEBUG(core, proc_name, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief  WAITオペレーション. 指定された条件まで待機.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    stream      入力ストリーム.
    -------------------------------------------------------------------------------
    procedure execute_wait(
        variable  core           : inout CORE_TYPE;
        file      stream         :       TEXT;
                  sync_io        : inout boolean
    ) is
        constant  proc_name      : string := "EXECUTE_WAIT";
        variable  next_event     : EVENT_TYPE;
        variable  keyword        : KEY_TYPE;
        variable  wait_count     : integer;
        variable  scan_len       : integer;
        variable  timeout        : integer;
        variable  wait_on        : boolean;
        variable  axi_match      : boolean;
        variable  gpi_match      : boolean;
        variable  axi_signals    : AXI4_CHANNEL_SIGNAL_TYPE;
        variable  gpi_signals    : std_logic_vector(GPI'range);
    begin
        REPORT_DEBUG(core, proc_name, "BEGIN");
        timeout   := DEFAULT_WAIT_TIMEOUT;
        wait_on   := FALSE;
        sync_io   := DEFAULT_SYNC_IO;
        SEEK_EVENT(core, stream, next_event);
        case next_event is
            when EVENT_SCALAR =>
                READ_EVENT(core, stream, EVENT_SCALAR);
                STRING_TO_INTEGER(
                    STR     => core.str_buf(1 to core.str_len),
                    VAL     => wait_count,
                    STR_LEN => scan_len
                );
                if (scan_len = 0) then
                    wait_count := 1;
                end if;
                if (wait_count > 0) then
                    for i in 1 to wait_count loop
                        wait until (ACLK'event and ACLK = '1');
                    end loop;
                end if;
                wait_count := 0;
            when EVENT_MAP_BEGIN =>
                READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                axi_signals := AXI4_CHANNEL_SIGNAL_DONTCARE;
                gpi_signals := (others => '-');
                MAP_READ_LOOP: loop
                    REPORT_DEBUG(core, proc_name, "MAP_READ_LOOP");
                    MAP_READ_PREPARE_FOR_NEXT(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    map_read_axi4_channel(
                        core       => core            ,  -- I/O:
                        stream     => stream          ,  -- I/O:
                        channel    => channel         ,  -- In :
                        read       => READ_ENABLE     ,  -- In :
                        write      => WRITE_ENABLE    ,  -- In :
                        width      => WIDTH           ,  -- In :
                        signals    => axi_signals     ,  -- I/O:
                        event      => next_event         -- I/O:
                    );
                    MAP_READ_STD_LOGIC_VECTOR(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        KEY        => "GPI"           ,  -- In :
                        VAL        => gpi_signals     ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_INTEGER(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        KEY        => "TIMEOUT"       ,  -- In :
                        VAL        => timeout         ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_BOOLEAN(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        KEY        => "ON"            ,  -- In :
                        VAL        => wait_on         ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_BOOLEAN(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        KEY        => "SYNC"          ,  -- In :
                        VAL        => sync_io         ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    case next_event is
                        when EVENT_SCALAR  =>
                            COPY_KEY_WORD(core, keyword);
                            EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                        when EVENT_MAP_END =>
                            exit MAP_READ_LOOP;
                        when others        =>
                            READ_ERROR(core, proc_name, "need EVENT_MAP_END but " &
                                       EVENT_TO_STRING(next_event));
                    end case;
                end loop;
                if (wait_on) then
                    SIG_LOOP:loop
                        REPORT_DEBUG(core, proc_name, "SIG_LOOP");
                        wait_on_signals;
                        match_axi4_channel(axi_signals, axi_match);
                        gpi_match := MATCH_STD_LOGIC(gpi_signals, GPI);
                        exit when(axi_match and gpi_match);
                        if (ACLK'event and ACLK = '1') then
                            if (timeout > 0) then
                                timeout := timeout - 1;
                            else
                                EXECUTE_ABORT(core, proc_name, "Time Out!");
                            end if;
                        end if;
                    end loop;
                else
                    CLK_LOOP:loop
                        REPORT_DEBUG(core, proc_name, "CLK_LOOP");
                        wait until (ACLK'event and ACLK = '1');
                        match_axi4_channel(axi_signals, axi_match);
                        gpi_match := MATCH_STD_LOGIC(gpi_signals, GPI);
                        exit when(axi_match and gpi_match);
                        if (timeout > 0) then
                            timeout := timeout - 1;
                        else
                            EXECUTE_ABORT(core, proc_name, "Time Out!");
                        end if;
                    end loop;
                end if;
            when others =>
                READ_ERROR(core, proc_name, "SEEK_EVENT NG");
        end case;
        REPORT_DEBUG(core, proc_name, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief  WAITオペレーション. 指定された条件まで待機.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    stream      入力ストリーム.
    -------------------------------------------------------------------------------
    procedure execute_skip_sync_io(
        variable  core           : inout CORE_TYPE;
        file      stream         :       TEXT;
                  sync_io        : inout boolean
    ) is
        constant  proc_name      :       STRING := "EXECUTE_SKIP_SYNC_IO";
        variable  next_event     :       EVENT_TYPE;
    begin
        REPORT_DEBUG(core, proc_name, "BEGIN");
        sync_io   := DEFAULT_SYNC_IO;
        SEEK_EVENT(core, stream, next_event);
        case next_event is
            when EVENT_SCALAR =>
                SKIP_EVENT(core, stream, EVENT_SCALAR);
            when EVENT_MAP_BEGIN =>
                READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                MAP_READ_LOOP: loop
                    REPORT_DEBUG(core, proc_name, "MAP_READ_LOOP");
                    MAP_READ_PREPARE_FOR_NEXT(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    MAP_READ_BOOLEAN(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        KEY        => "SYNC"          ,  -- In :
                        VAL        => sync_io         ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    case next_event is
                        when EVENT_SCALAR  =>
                            SEEK_EVENT(core, STREAM, next_event);
                            SKIP_EVENT(core, STREAM, next_event);
                        when EVENT_MAP_END =>
                            exit MAP_READ_LOOP;
                        when others        =>
                            READ_ERROR(core, proc_name, "need EVENT_MAP_END but " &
                                       EVENT_TO_STRING(next_event));
                    end case;
                end loop;
            when others =>
                READ_ERROR(core, proc_name, "SEEK_EVENT NG");
        end case;
        REPORT_DEBUG(core, proc_name, "END");
    end procedure;
begin 
    -------------------------------------------------------------------------------
    -- メインチャネル.
    -------------------------------------------------------------------------------
    CHANNEL_M: if (CHANNEL = AXI4_CHANNEL_M) generate
        PROCESS_M: process
            -----------------------------------------------------------------------
            -- 各種変数の定義.
            -----------------------------------------------------------------------
            file      stream        : TEXT;
            variable  core          : CORE_TYPE;
            variable  keyword       : KEY_TYPE;
            variable  operation     : OPERATION_TYPE;
            variable  gpo_signals   : std_logic_vector(GPO'range);
            variable  sync_io       : boolean;
            -----------------------------------------------------------------------
            --! @brief  SYNCオペレーション. 
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    core        コア変数.
            --! @param    stream      入力ストリーム.
            --! @param    OPERATION   オペレーション.
            -----------------------------------------------------------------------
            procedure execute_sync(
                variable  core      : inout CORE_TYPE;
                file      stream    :       TEXT;
                          operation : in    OPERATION_TYPE
            ) is
                constant  proc_name : string := "EXECUTE_SYNC";
                variable  port_num  : integer;
                variable  wait_num  : integer;
            begin
                REPORT_DEBUG  (core, proc_name, "BEGIN");
                READ_SYNC_ARGS(core, stream, operation, port_num, wait_num);
                REPORT_DEBUG  (core, proc_name, "PORT=" & INTEGER_TO_STRING(port_num) &
                                               " WAIT=" & INTEGER_TO_STRING(wait_num));
                local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                if (SYNC_REQ'low <= port_num and port_num <= SYNC_REQ'high) then
                    CORE_SYNC(core, port_num, wait_num, SYNC_REQ, SYNC_ACK);
                end if;
                REPORT_DEBUG  (core, proc_name, "END");
            end procedure;
        begin
            -----------------------------------------------------------------------
            -- ダミープラグコアの初期化.
            -----------------------------------------------------------------------
            CORE_INIT(
                SELF        => core,          -- 初期化するコア変数.
                NAME        => NAME,          -- コアの名前.
                VOCAL_NAME  => FULL_NAME,     -- メッセージ出力用の名前.
                STREAM      => stream,        -- シナリオのストリーム.
                stream_NAME => SCENARIO_FILE, -- シナリオのストリーム名.
                OPERATION   => operation      -- コアのオペレーション.
            );
            -----------------------------------------------------------------------
            -- 変数の初期化.
            -----------------------------------------------------------------------
            gpo_signals := (others => 'Z');
            core.debug  := 0;
            -----------------------------------------------------------------------
            -- 信号の初期化
            -----------------------------------------------------------------------
            SYNC_REQ       <= (0 => 0, others => -1);
            SYNC_LOCAL_REQ <= (        others =>  0);
            SYNC_TRANS_REQ <= (        others =>  0);
            FINISH         <= '0';
            REPORT_STATUS  <= core.report_status;
            -----------------------------------------------------------------------
            -- リセット解除待ち
            -----------------------------------------------------------------------
            wait until(ACLK'event and ACLK = '1' and ARESETn = '1');
            -----------------------------------------------------------------------
            -- メインオペレーションループ
            -----------------------------------------------------------------------
            while (operation /= OP_FINISH) loop
                REPORT_STATUS <= core.report_status;
                READ_OPERATION(core, stream, operation, keyword);
                case operation is
                    when OP_DOC_BEGIN       => execute_sync  (core, stream, operation);
                    when OP_SCALAR =>
                        case keyword is
                            when KEY_SYNC   => execute_sync  (core, stream, operation);
                            when others     => EXECUTE_UNDEFINED_SCALAR(core, stream, keyword);
                        end case;
                    when OP_MAP             =>
                        REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP(") & keyword & ")");
                        case keyword is
                            when KEY_AR     |
                                 KEY_AW     |
                                 KEY_R      |
                                 KEY_W      |
                                 KEY_B      => EXECUTE_SKIP  (core, stream);
                            when KEY_REPORT => EXECUTE_REPORT(core, stream);
                            when KEY_DEBUG  => EXECUTE_DEBUG (core, stream);
                            when KEY_SAY    => EXECUTE_SAY   (core, stream);
                            when KEY_CHECK  => execute_check (core, stream);
                            when KEY_OUT    => EXECUTE_OUT   (core, stream, gpo_signals, GPO);
                            when KEY_SYNC   => execute_sync  (core, stream, operation);
                            when KEY_WAIT   => execute_wait  (core, stream, sync_io);
                                                   if (sync_io) then
                                                       local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                                                   end if;
                            when KEY_READ   => if (READ_ENABLE ) then
                                                   execute_skip_sync_io(core, stream, sync_io);
                                                   if (sync_io) then
                                                       local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                                                   end if;
                                               else
                                                   EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                                               end if;
                            when KEY_WRITE  => if (WRITE_ENABLE) then
                                                   execute_skip_sync_io(core, stream, sync_io);
                                                   if (sync_io) then
                                                       local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                                                   end if;
                                               else
                                                   EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                                               end if;
                            when others     => EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                        end case;
                    when OP_FINISH => exit;
                    when others    => null;
                end case;
            end loop;
            REPORT_STATUS <= core.report_status;
            FINISH        <= '1';
            if (FINISH_ABORT) then
                assert FALSE report "Simulation complete." severity FAILURE;
            end if;
            wait;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- アドレスチャネル
    -------------------------------------------------------------------------------
    CHANNEL_A:if (CHANNEL = AXI4_CHANNEL_AW or CHANNEL = AXI4_CHANNEL_AR) generate
        PROCESS_A: process
            ---------------------------------------------------------------------------
            -- 各種変数の定義.
            ---------------------------------------------------------------------------
            file      stream        : TEXT;
            variable  core          : CORE_TYPE;
            variable  keyword       : KEY_TYPE;
            variable  operation     : OPERATION_TYPE;
            variable  out_signals   : AXI4_CHANNEL_SIGNAL_TYPE;
            variable  chk_a_signals : AXI4_A_CHANNEL_SIGNAL_TYPE;
            variable  tran_info     : AXI4_TRANSACTION_SIGNAL_TYPE;
            -----------------------------------------------------------------------
            --! @brief 信号変数(signals)の値をポートに出力するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    signals    出力する信号の値を指定する変数.
            -----------------------------------------------------------------------
            procedure execute_output(signals: in AXI4_CHANNEL_SIGNAL_TYPE) is
            begin 
                if (MASTER and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_AW) then
                    AWADDR_O  <= signals.AW.ADDR(AWADDR_O'range)after OUTPUT_DELAY;
                    AWVALID_O <= signals.AW.VALID               after OUTPUT_DELAY;
                    AWLEN_O   <= signals.AW.LEN (AWLEN_O 'range)after OUTPUT_DELAY;
                    AWSIZE_O  <= signals.AW.SIZE                after OUTPUT_DELAY;
                    AWBURST_O <= signals.AW.BURST               after OUTPUT_DELAY;
                    AWLOCK_O  <= signals.AW.LOCK(AWLOCK_O'range)after OUTPUT_DELAY;
                    AWCACHE_O <= signals.AW.CACHE               after OUTPUT_DELAY;
                    AWPROT_O  <= signals.AW.PROT                after OUTPUT_DELAY;
                    AWQOS_O   <= signals.AW.QOS                 after OUTPUT_DELAY;
                    AWREGION_O<= signals.AW.REGION              after OUTPUT_DELAY;
                    AWUSER_O  <= signals.AW.USER(AWUSER_O'range)after OUTPUT_DELAY;
                    AWID_O    <= signals.AW.id  (AWID_O  'range)after OUTPUT_DELAY;
                end if;
                if (MASTER and READ_ENABLE  and CHANNEL = AXI4_CHANNEL_AR) then
                    ARADDR_O  <= signals.AR.ADDR(ARADDR_O'range)after OUTPUT_DELAY;
                    ARVALID_O <= signals.AR.VALID               after OUTPUT_DELAY;
                    ARLEN_O   <= signals.AR.LEN (ARLEN_O 'range)after OUTPUT_DELAY;
                    ARSIZE_O  <= signals.AR.SIZE                after OUTPUT_DELAY;
                    ARBURST_O <= signals.AR.BURST               after OUTPUT_DELAY;
                    ARLOCK_O  <= signals.AR.LOCK(ARLOCK_O'range)after OUTPUT_DELAY;
                    ARCACHE_O <= signals.AR.CACHE               after OUTPUT_DELAY;
                    ARPROT_O  <= signals.AR.PROT                after OUTPUT_DELAY;
                    ARQOS_O   <= signals.AR.QOS                 after OUTPUT_DELAY;
                    ARREGION_O<= signals.AR.REGION              after OUTPUT_DELAY;
                    ARUSER_O  <= signals.AR.USER(ARUSER_O'range)after OUTPUT_DELAY;
                    ARID_O    <= signals.AR.id  (ARID_O  'range)after OUTPUT_DELAY;
                end if;
                if (SLAVE  and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_AW) then
                    AWREADY_O <= signals.AW.READY               after OUTPUT_DELAY;
                end if;
                if (SLAVE  and READ_ENABLE  and CHANNEL = AXI4_CHANNEL_AR) then
                    ARREADY_O <= signals.AR.READY               after OUTPUT_DELAY;
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief トランザクションの情報をシナリオから読むサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    proc_name  プロシージャの名前.
            --! @param    timeout    タイムアウトのクロック数.
            -----------------------------------------------------------------------
            procedure read_transaction_info(
                          proc_name  : in     string;
                          sync_io    : inout  boolean
            ) is
                variable  next_event : EVENT_TYPE;
                variable  addr_width : integer;
                variable  auser_width: integer;
                variable  duser_width: integer;
                variable  buser_width: integer;
            begin
                sync_io   := DEFAULT_SYNC_IO;
                case CHANNEL is
                    when AXI4_CHANNEL_AR =>
                        addr_width  := WIDTH.ARADDR;
                        auser_width := WIDTH.ARUSER;
                        duser_width := WIDTH.RUSER;
                        buser_width := 1;
                    when AXI4_CHANNEL_AW =>
                        addr_width  := WIDTH.AWADDR;
                        auser_width := WIDTH.AWUSER;
                        duser_width := WIDTH.WUSER;
                        buser_width := WIDTH.BUSER;
                    when others =>
                        null;
                end case;
                SEEK_EVENT(core, stream, next_event);
                case next_event is
                    when EVENT_MAP_BEGIN =>
                        READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                        MAP_READ_LOOP: loop
                            MAP_READ_PREPARE_FOR_NEXT(
                                SELF       => core            ,  -- I/O:
                                STREAM     => stream          ,  -- I/O:
                                EVENT      => next_event         -- I/O:
                            );
                            map_read_axi4_transaction(
                                core       => core            ,  -- I/O:
                                stream     => stream          ,  -- I/O:
                                addr_width => addr_width      ,  -- In :
                                auser_width=> auser_width     ,  -- In :
                                duser_width=> duser_width     ,  -- In :
                                buser_width=> buser_width     ,  -- In :
                                id_width   => WIDTH.ID        ,  -- In :
                                trans      => tran_info       ,  -- I/O:
                                event      => next_event         -- I/O:
                            );
                            MAP_READ_BOOLEAN(
                                SELF       => core            ,  -- I/O:
                                STREAM     => stream          ,  -- I/O:
                                KEY        => "SYNC"          ,  -- In :
                                VAL        => sync_io         ,  -- I/O:
                                EVENT      => next_event         -- I/O:
                            );
                            case next_event is
                                when EVENT_SCALAR  =>
                                    COPY_KEY_WORD(core, keyword);
                                    EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                                when EVENT_MAP_END =>
                                    exit MAP_READ_LOOP;
                                when others        =>
                                    READ_ERROR(core, proc_name, "need EVENT_MAP_END but " &
                                               EVENT_TO_STRING(next_event));
                            end case;
                        end loop;
                    when others =>
                        READ_ERROR(core, proc_name, "SEEK_EVENT NG");
                end case;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief デフォルトの ASIZE を計算するサブプログラム.
            -----------------------------------------------------------------------
            function  default_asize(WIDTH:integer) return AXI4_ASIZE_TYPE is
            begin
                case WIDTH is
                    when      8 => return AXI4_ASIZE_1BYTE;
                    when     16 => return AXI4_ASIZE_2BYTE;
                    when     32 => return AXI4_ASIZE_4BYTE;
                    when     64 => return AXI4_ASIZE_8BYTE;
                    when    128 => return AXI4_ASIZE_16BYTE;
                    when    256 => return AXI4_ASIZE_32BYTE;
                    when    512 => return AXI4_ASIZE_64BYTE;
                    when   1024 => return AXI4_ASIZE_128BYTE;
                    when others => return (others => '0');
                end case;
            end function;
            constant  AXI4_ARSIZE_DEFAULT : AXI4_ASIZE_TYPE := default_asize(WIDTH.RDATA);
            constant  AXI4_AWSIZE_DEFAULT : AXI4_ASIZE_TYPE := default_asize(WIDTH.WDATA);
            -----------------------------------------------------------------------
            --! @brief マスターリードランザクション(アドレスチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_transaction_master_read_addr is
                constant  proc_name  : string := "EXECUTE_TRANSACTION_MASTER_READ_ADDR";
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                tran_info         := AXI4_TRANSACTION_SIGNAL_NULL;
                tran_info.SIZE    := AXI4_ARSIZE_DEFAULT;
                tran_info.BURST   := AXI4_ABURST_INCR;
                tran_info.DUSER   := (others => '-');
                tran_info.VALID   := '1';
                tran_info.TIMEOUT := DEFAULT_WAIT_TIMEOUT;
                read_transaction_info(proc_name, sync_io);
                local_sync(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                TRAN_O <= tran_info;
                out_signals.AR.ADDR(ARADDR_O'range) := tran_info.ADDR (ARADDR_O'range);
                out_signals.AR.USER(ARUSER_O'range) := tran_info.AUSER(ARUSER_O'range);
                out_signals.AR.ID  (ARID_O  'range) := tran_info.ID   (ARID_O  'range);
                out_signals.AR.WRITE                := '0';
                out_signals.AR.LEN (ARLEN_O 'range) := tran_info.LEN  (ARLEN_O 'range);
                out_signals.AR.SIZE                 := tran_info.SIZE;
                out_signals.AR.BURST                := tran_info.BURST;
                out_signals.AR.LOCK(ARLOCK_O'range) := tran_info.LOCK (ARLOCK_O'range);
                out_signals.AR.CACHE                := tran_info.CACHE;
                out_signals.AR.PROT                 := tran_info.PROT;
                out_signals.AR.QOS                  := tran_info.QOS;
                out_signals.AR.REGION               := tran_info.REGION;
                out_signals.AR.VALID                := '1';
                execute_output(out_signals);
                wait until (ACLK'event and ACLK = '0');
                TRAN_O.VALID <= '0';
                wait_until_xfer_ar(core, proc_name, tran_info.TIMEOUT);
                out_signals.AR                      := AXI4_A_CHANNEL_SIGNAL_NULL;
                execute_output(out_signals);
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief マスターライトトランザクション(アドレスチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_transaction_master_write_addr is
                constant  proc_name  : string := "EXECUTE_TRANSACTION_MASTER_WRITE_ADDR";
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                tran_info         := AXI4_TRANSACTION_SIGNAL_NULL;
                tran_info.SIZE    := AXI4_AWSIZE_DEFAULT;
                tran_info.BURST   := AXI4_ABURST_INCR;
                tran_info.BUSER   := (others => '-');
                tran_info.VALID   := '1';
                tran_info.TIMEOUT := DEFAULT_WAIT_TIMEOUT;
                read_transaction_info(proc_name, sync_io);
                local_sync(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                TRAN_O <= tran_info;
                out_signals.AW.ADDR(AWADDR_O'range) := tran_info.ADDR (AWADDR_O'range);
                out_signals.AW.USER(AWUSER_O'range) := tran_info.AUSER(AWUSER_O'range);
                out_signals.AW.ID  (AWID_O  'range) := tran_info.ID   (AWID_O  'range);
                out_signals.AW.WRITE                := '1';
                out_signals.AW.LEN (AWLEN_O 'range) := tran_info.LEN  (AWLEN_O 'range);
                out_signals.AW.SIZE                 := tran_info.SIZE;
                out_signals.AW.BURST                := tran_info.BURST;
                out_signals.AW.LOCK(AWLOCK_O'range) := tran_info.LOCK (AWLOCK_O'range);
                out_signals.AW.CACHE                := tran_info.CACHE;
                out_signals.AW.PROT                 := tran_info.PROT;
                out_signals.AW.QOS                  := tran_info.QOS;
                out_signals.AW.REGION               := tran_info.REGION;
                out_signals.AW.VALID                := '1';
                execute_output(out_signals);
                wait until (ACLK'event and ACLK = '0');
                TRAN_O.VALID <= '0';
                wait_until_xfer_aw(core, proc_name, tran_info.TIMEOUT);
                out_signals.AW                      := AXI4_A_CHANNEL_SIGNAL_NULL;
                execute_output(out_signals);
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief スレーブリードトランザクション(アドレスチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_transaction_slave_read_addr is
                constant  proc_name  : string := "EXECUTE_TRANSACTION_SLAVE_READ_ADDR";
                variable  match      : boolean;
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                tran_info         := AXI4_TRANSACTION_SIGNAL_DONTCARE;
                tran_info.SIZE    := AXI4_ARSIZE_DEFAULT;
                tran_info.BURST   := AXI4_ABURST_INCR;
                tran_info.VALID   := '1';
                tran_info.TIMEOUT := DEFAULT_WAIT_TIMEOUT;
                read_transaction_info(proc_name, sync_io);
                local_sync(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                TRAN_O       <= tran_info;
                ARREADY_O    <= '1';
                wait until (ACLK'event and ACLK = '0');
                TRAN_O.VALID <= '0';
                wait_until_xfer_ar(core, proc_name, tran_info.TIMEOUT);
                ARREADY_O    <= '0';
                chk_a_signals.ADDR(ARADDR_I'range) := tran_info.ADDR (ARADDR_I'range);
                chk_a_signals.USER(ARUSER_I'range) := tran_info.AUSER(ARUSER_I'range);
                chk_a_signals.ID  (ARID_I  'range) := tran_info.ID   (ARID_I  'range);
                chk_a_signals.WRITE                := tran_info.WRITE;
                chk_a_signals.LEN (ARLEN_I 'range) := tran_info.LEN  (ARLEN_I 'range);
                chk_a_signals.SIZE                 := tran_info.SIZE;
                chk_a_signals.BURST                := tran_info.BURST;
                chk_a_signals.LOCK(ARLOCK_I'range) := tran_info.LOCK (ARLOCK_I'range);
                chk_a_signals.CACHE                := tran_info.CACHE;
                chk_a_signals.PROT                 := tran_info.PROT;
                chk_a_signals.QOS                  := tran_info.QOS;
                chk_a_signals.REGION               := tran_info.REGION;
                chk_a_signals.VALID                := '1';
                chk_a_signals.READY                := '1';
                match_axi4_ar_channel(core, chk_a_signals, match);
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief スレーブライトトランザクション(アドレスチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_transaction_slave_write_addr is
                constant  proc_name  : string := "EXECUTE_TRANSACTION_SLAVE_WRITE_ADDR";
                variable  match      : boolean;
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                tran_info         := AXI4_TRANSACTION_SIGNAL_DONTCARE;
                tran_info.SIZE    := AXI4_AWSIZE_DEFAULT;
                tran_info.BURST   := AXI4_ABURST_INCR;
                tran_info.BUSER   := (others => '0');
                tran_info.VALID   := '1';
                tran_info.TIMEOUT := DEFAULT_WAIT_TIMEOUT;
                read_transaction_info(proc_name, sync_io);
                local_sync(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                TRAN_O       <= tran_info;
                AWREADY_O    <= '1';
                wait until (ACLK'event and ACLK = '0');
                TRAN_O.VALID <= '0';
                wait_until_xfer_aw(core, proc_name, tran_info.TIMEOUT);
                AWREADY_O    <= '0';
                chk_a_signals.ADDR(AWADDR_I'range) := tran_info.ADDR (AWADDR_I'range);
                chk_a_signals.USER(AWUSER_I'range) := tran_info.AUSER(AWUSER_I'range);
                chk_a_signals.ID  (AWID_I  'range) := tran_info.ID   (AWID_I  'range);
                chk_a_signals.WRITE                := tran_info.WRITE;
                chk_a_signals.LEN (AWLEN_I 'range) := tran_info.LEN  (AWLEN_I 'range);
                chk_a_signals.SIZE                 := tran_info.SIZE;
                chk_a_signals.BURST                := tran_info.BURST;
                chk_a_signals.LOCK(AWLOCK_I'range) := tran_info.LOCK (AWLOCK_I'range);
                chk_a_signals.CACHE                := tran_info.CACHE;
                chk_a_signals.PROT                 := tran_info.PROT;
                chk_a_signals.QOS                  := tran_info.QOS;
                chk_a_signals.REGION               := tran_info.REGION;
                chk_a_signals.VALID                := '1';
                chk_a_signals.READY                := '1';
                match_axi4_aw_channel(core, chk_a_signals, match);
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief 関係無いトランザクションを実行するサブプログラム.
            -----------------------------------------------------------------------
            procedure execute_dummy_operation is
                variable  sync_io    : boolean;
            begin
                execute_skip_sync_io(core, stream, sync_io);
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーション(SCALAR)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_channel_scalar_operation is
            begin 
                SKIP_EVENT(core, stream, EVENT_SCALAR);
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーション(MAP)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_channel_map_operation is
                constant  proc_name  : string := "EXECUTE_CHANNEL_MAP_OPERATION";
                variable  next_event : EVENT_TYPE;
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                MAP_READ_LOOP: loop
                    MAP_READ_PREPARE_FOR_NEXT(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    map_read_axi4_channel(
                        core       => core            ,  -- In :
                        stream     => stream          ,  -- I/O:
                        channel    => CHANNEL         ,  -- In :
                        read       => READ_ENABLE     ,  -- In :
                        write      => WRITE_ENABLE    ,  -- In :
                        width      => WIDTH           ,  -- In :
                        signals    => out_signals     ,  -- I/O:
                        event      => next_event         -- Out:
                    );
                    execute_output(out_signals);
                    case next_event is
                        when EVENT_SCALAR  =>
                            COPY_KEY_WORD(core, keyword);
                            case keyword is
                                when KEY_DEBUG  => EXECUTE_DEBUG (core, stream);
                                when KEY_REPORT => EXECUTE_REPORT(core, stream);
                                when KEY_SAY    => EXECUTE_SAY   (core, stream);
                                when KEY_WAIT   => execute_wait  (core, stream, sync_io);
                                when KEY_CHECK  => execute_check (core, stream);
                                when others     => EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                            end case;
                        when EVENT_MAP_END =>
                            exit MAP_READ_LOOP;
                        when others        =>
                            READ_ERROR(core, proc_name, "need EVENT_MAP_END but " &
                                       EVENT_TO_STRING(next_event));
                    end case;
                end loop;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーションループ
            -----------------------------------------------------------------------
            procedure execute_channel_operation is
                constant  proc_name  : string := "EXECUTE_CHANNEL_OPERATION";
                variable  next_event : EVENT_TYPE;
                variable  seq_level  : integer;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                seq_level := 0;
                SEQ_LOOP: loop
                    SEEK_EVENT(core, stream, next_event);
                    case next_event is
                        when EVENT_SEQ_BEGIN =>
                            READ_EVENT(core, stream, EVENT_SEQ_BEGIN);
                            seq_level := seq_level + 1;
                        when EVENT_SEQ_END   =>
                            READ_EVENT(core, stream, EVENT_SEQ_END  );
                            seq_level := seq_level - 1;
                        when EVENT_MAP_BEGIN =>
                            execute_channel_map_operation;
                        when EVENT_SCALAR    =>
                            execute_channel_scalar_operation;
                        when EVENT_ERROR     =>
                            READ_ERROR(core, proc_name, "SEEK_EVENT NG");
                        when others          =>
                            SKIP_EVENT(core, stream, next_event);
                            -- ERROR
                    end case;
                    exit when (seq_level <= 0);
                end loop;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
        begin
            -----------------------------------------------------------------------
            -- ダミープラグコアの初期化.
            -----------------------------------------------------------------------
            CORE_INIT(
                SELF        => core,          -- 初期化するコア変数.
                NAME        => NAME,          -- コアの名前.
                VOCAL_NAME  => FULL_NAME,     -- メッセージ出力用の名前.
                STREAM      => stream,        -- シナリオのストリーム.
                STREAM_NAME => SCENARIO_FILE, -- シナリオのストリーム名.
                OPERATION   => operation      -- コアのオペレーション.
            );
            -----------------------------------------------------------------------
            -- 変数の初期化.
            -----------------------------------------------------------------------
            out_signals := INIT_SIGNALS;
            -----------------------------------------------------------------------
            -- 信号の初期化
            -----------------------------------------------------------------------
            SYNC_LOCAL_REQ <= (others => 0);
            SYNC_TRANS_REQ <= (others => 0);
            FINISH         <= '0';
            REPORT_STATUS  <= core.report_status;
            execute_output(out_signals);
            core.debug := 0;
            -----------------------------------------------------------------------
            -- メインオペレーションループ
            -----------------------------------------------------------------------
            while (operation /= OP_FINISH) loop
                REPORT_STATUS <= core.report_status;
                READ_OPERATION(core, stream, operation, keyword);
                case operation is
                    when OP_DOC_BEGIN   => local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                    when OP_MAP         =>
                        REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP(") & keyword & ")");
                        if    (keyword = KEY_CHANNEL) then
                            execute_channel_operation;
                        elsif (keyword = KEY_REPORT ) then
                            EXECUTE_REPORT(core, stream);
                        elsif (keyword = KEY_SYNC   ) then
                            local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                            EXECUTE_SKIP(core, stream);
                        elsif (keyword = KEY_WAIT   ) or
                              (CHANNEL = AXI4_CHANNEL_AR and MASTER and WRITE_ENABLE and keyword = KEY_WRITE) or
                              (CHANNEL = AXI4_CHANNEL_AR and SLAVE  and WRITE_ENABLE and keyword = KEY_WRITE) or
                              (CHANNEL = AXI4_CHANNEL_AW and MASTER and READ_ENABLE  and keyword = KEY_READ ) or
                              (CHANNEL = AXI4_CHANNEL_AW and SLAVE  and READ_ENABLE  and keyword = KEY_READ ) then
                            execute_dummy_operation;
                        elsif (CHANNEL = AXI4_CHANNEL_AR and MASTER and READ_ENABLE  and keyword = KEY_READ ) then
                            execute_transaction_master_read_addr;
                        elsif (CHANNEL = AXI4_CHANNEL_AR and SLAVE  and READ_ENABLE  and keyword = KEY_READ ) then
                            execute_transaction_slave_read_addr;
                        elsif (CHANNEL = AXI4_CHANNEL_AW and MASTER and WRITE_ENABLE and keyword = KEY_WRITE) then
                            execute_transaction_master_write_addr;
                        elsif (CHANNEL = AXI4_CHANNEL_AW and SLAVE  and WRITE_ENABLE and keyword = KEY_WRITE) then
                            execute_transaction_slave_write_addr;
                        else
                            REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP:SKIP BEGIN"));
                            EXECUTE_SKIP(core, stream);
                            REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP:SKIP END"));
                        end if;
                    when OP_SCALAR      =>
                        if (keyword = KEY_SYNC) then
                            local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                        else
                            EXECUTE_UNDEFINED_SCALAR(core, stream, keyword);
                        end if;
                    when OP_FINISH      => exit;
                    when others         => null;
                end case;
            end loop;
            REPORT_STATUS <= core.report_status;
            FINISH        <= '1';
            if (FINISH_ABORT) then
                assert FALSE report "Simulation complete." severity FAILURE;
            end if;
            wait;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- データチャネル
    -------------------------------------------------------------------------------
    CHANNEL_D:if (CHANNEL = AXI4_CHANNEL_W  or CHANNEL = AXI4_CHANNEL_B  or CHANNEL = AXI4_CHANNEL_R) generate
        PROCESS_D: process
            ---------------------------------------------------------------------------
            -- 各種変数の定義.
            ---------------------------------------------------------------------------
            file      stream        : TEXT;
            variable  core          : CORE_TYPE;
            variable  keyword       : KEY_TYPE;
            variable  operation     : OPERATION_TYPE;
            variable  out_signals   : AXI4_CHANNEL_SIGNAL_TYPE;
            variable  chk_r_signals : AXI4_R_CHANNEL_SIGNAL_TYPE;
            variable  chk_w_signals : AXI4_W_CHANNEL_SIGNAL_TYPE;
            variable  chk_b_signals : AXI4_B_CHANNEL_SIGNAL_TYPE;
            variable  tran_info     : AXI4_TRANSACTION_SIGNAL_TYPE;
            variable  aligned_addr  : integer;
            variable  number_bytes  : integer;
            variable  lower_lane    : integer;
            variable  upper_lane    : integer;
            variable  burst_len     : integer;
            variable  data_pos      : integer;
            variable  data_bits     : integer;
            variable  data_bytes    : integer;
            variable  match         : boolean;
            -----------------------------------------------------------------------
            --! @brief 信号変数(signals)の値をポートに出力するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    signals    出力する信号の値を指定する変数.
            -----------------------------------------------------------------------
            procedure execute_output(
                          signals  : in AXI4_CHANNEL_SIGNAL_TYPE
            ) is
            begin 
                if (MASTER and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_W) then
                    WDATA_O   <= signals.W.DATA(WDATA_O'range)  after OUTPUT_DELAY;
                    WLAST_O   <= signals.W.LAST                 after OUTPUT_DELAY;
                    WSTRB_O   <= signals.W.STRB(WSTRB_O'range)  after OUTPUT_DELAY;
                    WUSER_O   <= signals.W.USER(WUSER_O'range)  after OUTPUT_DELAY;
                    WID_O     <= signals.W.ID(WID_O'range)      after OUTPUT_DELAY;
                    WVALID_O  <= signals.W.VALID                after OUTPUT_DELAY;
                end if;
                if (MASTER and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_B) then
                    BREADY_O  <= signals.B.READY                after OUTPUT_DELAY;
                end if;
                if (MASTER and READ_ENABLE  and CHANNEL = AXI4_CHANNEL_R) then
                    RREADY_O  <= signals.R.READY                after OUTPUT_DELAY;
                end if;
                if (SLAVE  and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_W) then
                    WREADY_O  <= signals.W.READY                after OUTPUT_DELAY;
                end if;
                if (SLAVE  and WRITE_ENABLE and CHANNEL = AXI4_CHANNEL_B) then
                    BRESP_O   <= signals.B.RESP                 after OUTPUT_DELAY;
                    BUSER_O   <= signals.B.USER(BUSER_O'range)  after OUTPUT_DELAY;
                    BID_O     <= signals.B.ID(BID_O'range)      after OUTPUT_DELAY;
                    BVALID_O  <= signals.B.VALID                after OUTPUT_DELAY;
                end if;
                if (SLAVE  and READ_ENABLE  and CHANNEL = AXI4_CHANNEL_R) then
                    RDATA_O   <= signals.R.DATA(RDATA_O'range)  after OUTPUT_DELAY;
                    RRESP_O   <= signals.R.RESP                 after OUTPUT_DELAY;
                    RLAST_O   <= signals.R.LAST                 after OUTPUT_DELAY;
                    RUSER_O   <= signals.R.USER(RUSER_O'range)  after OUTPUT_DELAY;
                    RID_O     <= signals.R.ID(RID_O'range)      after OUTPUT_DELAY;
                    RVALID_O  <= signals.R.VALID                after OUTPUT_DELAY;
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief アドレスチャネルからのトランザクション情報をTRAN_I信号から
            --!        取り込んで内部変数にセットするサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    proc_name  プロシージャの名前.
            --! @param    DATA_WIDTH データのビット幅.
            -----------------------------------------------------------------------
            procedure get_transaction_info(
                          proc_name   : in string;
                          DATA_WIDTH  : in integer
            ) is
            begin
                REPORT_DEBUG(core, proc_name, "GET_TRANSACTION_INFO BEGIN");
                wait until (TRAN_I.VALID'event and TRAN_I.VALID = '1');
                tran_info := TRAN_I;
                transaction_to_addr_and_bytes(tran_info, aligned_addr, number_bytes);
                case DATA_WIDTH is
                    when   16   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(0 downto 0)));
                    when   32   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(1 downto 0)));
                    when   64   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(2 downto 0)));
                    when  128   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(3 downto 0)));
                    when  256   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(4 downto 0)));
                    when  512   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(5 downto 0)));
                    when 1024   => lower_lane := TO_INTEGER(unsigned(tran_info.ADDR(6 downto 0)));
                    when others => lower_lane := 0;
                end case;
                burst_len  := TO_INTEGER(unsigned(tran_info.LEN))+1;
                data_pos   := 0;
                data_bits  := tran_info.DATA_LEN;
                data_bytes := (data_bits+7)/8;
                if (number_bytes - aligned_addr > data_bytes) then
                    upper_lane := lower_lane + data_bytes - 1;
                else
                    upper_lane := lower_lane + number_bytes - aligned_addr - 1;
                end if;
                REPORT_DEBUG(core, proc_name, "GET_TRANSACTION_INFO END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief get_transaction_info で取り込んだトランザクション情報から
            --!        ワード毎のリードデータチャネル信号の値を生成するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    proc_name  プロシージャの名前.
            --! @param    last       最後のワードであることを指定する.
            --! @param    default    指定の無いstd_logicの値.
            --! @param    signals    生成されたワード毎の信号を出力する.
            -----------------------------------------------------------------------
            procedure generate_r_channel_signals(
                          proc_name   : in  string;
                          last        : in  boolean;
                          default     : in  std_logic;
                          signals     : out AXI4_R_CHANNEL_SIGNAL_TYPE
            ) is
                constant  word_bytes  :     integer := WIDTH.RDATA/8;
            begin 
                signals.USER  := tran_info.DUSER;
                signals.ID    := tran_info.ID;
                signals.VALID := '1';
                signals.READY := '1';
                if (last) then
                    signals.RESP := tran_info.RESP;
                    signals.LAST := '1';
                else
                    signals.RESP := (others => default);
                    signals.LAST := '0';
                end if;
                for lane in 0 to word_bytes-1 loop
                    if (lower_lane <= lane and lane <= upper_lane) then
                        for bit in 0 to 7 loop
                            if (data_pos < data_bits) then
                                signals.DATA(lane*8+bit) := tran_info.DATA(data_pos);
                                data_pos := data_pos + 1;
                            else
                                signals.DATA(lane*8+bit) := default;
                            end if;
                        end loop;
                    else
                        signals.DATA(lane*8+7 downto lane*8) := (lane*8+7 downto lane*8 => default);
                    end if;
                end loop;
                lower_lane := (upper_lane + 1)  mod word_bytes;
                upper_lane := lower_lane + number_bytes - 1;
                if (upper_lane >= word_bytes) then
                    upper_lane := word_bytes - 1;
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief get_transaction_info で取り込んだトランザクション情報から
            --!        ワード毎のライトデータチャネル信号の値を生成するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    proc_name  プロシージャの名前.
            --! @param    last       最後のワードであることを指定する.
            --! @param    default    指定の無いstd_logicの値.
            --! @param    signals    生成されたワード毎の信号を出力する.
            -----------------------------------------------------------------------
            procedure generate_w_channel_signals(
                          proc_name   : in  string;
                          last        : in  boolean;
                          default     : in  std_logic;
                          signals     : out AXI4_W_CHANNEL_SIGNAL_TYPE
            ) is
                constant  word_bytes  :     integer := WIDTH.WDATA/8;
            begin
                signals.USER  := tran_info.DUSER;
                signals.VALID := '1';
                signals.READY := '1';
                if (last) then
                    signals.LAST := '1';
                else
                    signals.LAST := '0';
                end if;                
                for lane in 0 to word_bytes-1 loop
                    signals.STRB(lane) := '0';
                    if (lower_lane <= lane and lane <= upper_lane) then
                        for bit in 0 to 7 loop
                            if (data_pos < data_bits) then
                                signals.DATA(lane*8+bit) := tran_info.DATA(data_pos);
                                data_pos := data_pos + 1;
                                signals.STRB(lane) := '1';
                            else
                                signals.DATA(lane*8+bit) := default;
                            end if;
                        end loop;
                    else
                        signals.DATA(lane*8+7 downto lane*8) := (lane*8+7 downto lane*8 => default);
                    end if;
                end loop;
                lower_lane := (upper_lane + 1)  mod word_bytes;
                upper_lane := lower_lane + number_bytes - 1;
                if (upper_lane >= word_bytes) then
                    upper_lane := word_bytes - 1;
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief get_transaction_info で取り込んだトランザクション情報から
            --!        ワード毎のライト応答チャネル信号の値を生成するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    proc_name  プロシージャの名前.
            --! @param    signals    生成されたワード毎の信号を出力する.
            -----------------------------------------------------------------------
            procedure generate_b_channel_signals(
                          proc_name   : in  string;
                          signals     : out AXI4_B_CHANNEL_SIGNAL_TYPE
            ) is
            begin
                signals.USER  := tran_info.BUSER;
                signals.ID    := tran_info.ID;
                signals.RESP  := tran_info.RESP;
                signals.VALID := '1';
                signals.READY := '1';
            end procedure;
            -----------------------------------------------------------------------
            --! @brief マスターリードトランザクション(データチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_transaction_master_read_data is
                constant  proc_name  : string := "EXECUTE_TRANSACTION_MASTER_READ_DATA";
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                execute_skip_sync_io(core, stream, sync_io);
                local_sync(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                get_transaction_info(proc_name, WIDTH.RDATA);
                for i in 1 to burst_len loop
                    RREADY_O <= '1' after OUTPUT_DELAY;
                    generate_r_channel_signals(
                        proc_name => proc_name,
                        last      => (i = burst_len),
                        default   => '-',
                        signals   => chk_r_signals
                    );
                    wait_until_xfer_r(core, proc_name, tran_info.TIMEOUT, '0');
                    match_axi4_r_channel(core, chk_r_signals, match);
                end loop;
                RREADY_O <= '0' after OUTPUT_DELAY;
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief スレーブリードトランザクション(データチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_transaction_slave_read_data is
                constant  proc_name  : string := "EXECUTE_TRANSACTION_SLAVE_READ_DATA";
                variable  arid       : std_logic_vector(ARID_I'range);
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                execute_skip_sync_io(core, stream, sync_io);
                local_sync(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                get_transaction_info(proc_name, WIDTH.RDATA);
                wait_until_xfer_ar(core, proc_name, tran_info.TIMEOUT);
                arid := ARID_I;
                for i in 1 to burst_len loop
                    generate_r_channel_signals(
                        proc_name => proc_name, 
                        last      => (i = burst_len),
                        default   => '0',
                        signals   => out_signals.R
                    );
                    if (out_signals.R.ID(arid'range) = AXI4_TRANSACTION_SIGNAL_DONTCARE.ID(arid'range)) then
                        out_signals.R.ID(arid'range) := arid;
                    end if;
                    execute_output(out_signals);
                    wait_until_xfer_r(core, proc_name, tran_info.TIMEOUT, '0');
                end loop;
                out_signals.R := AXI4_R_CHANNEL_SIGNAL_NULL;
                execute_output(out_signals);
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief マスターライトトランザクション(データチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_transaction_master_write_data is
                constant  proc_name  : string := "EXECUTE_TRANSACTION_MASTER_WRITE_DATA";
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                execute_skip_sync_io(core, stream, sync_io);
                local_sync(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                get_transaction_info(proc_name, WIDTH.WDATA);
                for i in 1 to burst_len loop
                    generate_w_channel_signals(
                        proc_name => proc_name, 
                        last      => (i = burst_len),
                        default   => '0',
                        signals   => out_signals.W
                    );
                    execute_output(out_signals);
                    wait_until_xfer_w(core, proc_name, tran_info.TIMEOUT, '0');
                end loop;
                out_signals.W := AXI4_W_CHANNEL_SIGNAL_NULL;
                execute_output(out_signals);
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief スレーブライトトランザクション(データチャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_transaction_slave_write_data is
                constant  proc_name  : string := "EXECUTE_TRANSACTION_SLAVE_WRITE_DATA";
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                execute_skip_sync_io(core, stream, sync_io);
                local_sync(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                get_transaction_info(proc_name, WIDTH.WDATA);
                for i in 1 to burst_len loop
                    WREADY_O <= '1' after OUTPUT_DELAY;
                    generate_w_channel_signals(
                        proc_name => proc_name,
                        last      => (i = burst_len),
                        default   => '-',
                        signals   => chk_w_signals
                    );
                    chk_w_signals.ID := (others => '-');
                    wait_until_xfer_w(core, proc_name, tran_info.TIMEOUT, '0');
                    match_axi4_w_channel(core, chk_w_signals, match);
                end loop;
                WREADY_O <= '0' after OUTPUT_DELAY;
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief マスターライトトランザクション(応答チャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_transaction_master_write_resp is
                constant  proc_name  : string := "EXECUTE_TRANSACTION_MASTER_WRITE_RESP";
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                execute_skip_sync_io(core, stream, sync_io);
                local_sync(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                get_transaction_info(proc_name, WIDTH.WDATA);
                wait_until_xfer_aw(core, proc_name, tran_info.TIMEOUT);
                generate_b_channel_signals(
                    proc_name => proc_name, 
                    signals   => chk_b_signals
                );
                BREADY_O <= '1' after OUTPUT_DELAY;
                wait_until_xfer_b (core, proc_name, tran_info.TIMEOUT);
                BREADY_O <= '0' after OUTPUT_DELAY;
                match_axi4_b_channel(core, chk_b_signals, match);
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief スレーブライトトランザクション(応答チャネル)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_transaction_slave_write_resp is
                constant  proc_name  : string := "EXECUTE_TRANSACTION_SLAVE_WRITE_RESP";
                variable  awid       : std_logic_vector(AWID_I'range);
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                execute_skip_sync_io(core, stream, sync_io);
                local_sync(core, SYNC_TRANS_REQ, SYNC_TRANS_ACK);
                get_transaction_info(proc_name, WIDTH.WDATA);
                wait_until_xfer_aw(core, proc_name, tran_info.TIMEOUT);
                awid := AWID_I;
                generate_b_channel_signals(
                    proc_name => proc_name, 
                    signals   => out_signals.B
                );
                if (out_signals.B.ID(awid'range) = AXI4_TRANSACTION_SIGNAL_DONTCARE.ID(awid'range)) then
                    out_signals.B.ID(awid'range) := awid;
                end if;
                if (not (WVALID_I = '1' and WREADY_I = '1' and WLAST_I = '1')) then
                    wait_until_xfer_w (core, proc_name, tran_info.TIMEOUT, '1');
                end if;
                execute_output(out_signals);
                wait_until_xfer_b (core, proc_name, tran_info.TIMEOUT);
                out_signals.B := AXI4_B_CHANNEL_SIGNAL_NULL;
                execute_output(out_signals);
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief 関係無いトランザクションを実行するサブプログラム.
            -----------------------------------------------------------------------
            procedure execute_dummy_operation is
                variable  sync_io    : boolean;
            begin
                execute_skip_sync_io(core, stream, sync_io);
                if (sync_io) then
                    local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーション(SCALAR)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_channel_scalar_operation is
            begin 
                SKIP_EVENT(core, stream, EVENT_SCALAR);
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーション(MAP)実行サブプログラム.
            -----------------------------------------------------------------------
            procedure execute_channel_map_operation is
                constant  proc_name  : string := "EXECUTE_CHANNEL_MAP_OPERATION";
                variable  next_event : EVENT_TYPE;
                variable  sync_io    : boolean;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                MAP_READ_LOOP: loop
                    MAP_READ_PREPARE_FOR_NEXT(
                        SELF       => core            ,  -- I/O:
                        STREAM     => stream          ,  -- I/O:
                        EVENT      => next_event         -- I/O:
                    );
                    map_read_axi4_channel(
                        core       => core            ,  -- In :
                        stream     => stream          ,  -- I/O:
                        channel    => CHANNEL         ,  -- In :
                        read       => READ_ENABLE     ,  -- In :
                        write      => WRITE_ENABLE    ,  -- In :
                        width      => WIDTH           ,  -- In :
                        signals    => out_signals     ,  -- I/O:
                        event      => next_event         -- Out:
                    );
                    execute_output(out_signals);
                    case next_event is
                        when EVENT_SCALAR  =>
                            COPY_KEY_WORD(core, keyword);
                            case keyword is
                                when KEY_DEBUG  => EXECUTE_DEBUG (core, stream);
                                when KEY_REPORT => EXECUTE_REPORT(core, stream);
                                when KEY_SAY    => EXECUTE_SAY   (core, stream);
                                when KEY_WAIT   => execute_wait  (core, stream, sync_io);
                                when KEY_CHECK  => execute_check (core, stream);
                                when others     => EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                            end case;
                        when EVENT_MAP_END =>
                            exit MAP_READ_LOOP;
                        when others        =>
                            READ_ERROR(core, proc_name, "need EVENT_MAP_END but " &
                                       EVENT_TO_STRING(next_event));
                    end case;
                end loop;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief チャネルオペレーションループ
            -----------------------------------------------------------------------
            procedure execute_channel_operation is
                constant  proc_name  : string := "EXECUTE_CHANNEL_OPERATION";
                variable  next_event : EVENT_TYPE;
                variable  seq_level  : integer;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                seq_level := 0;
                SEQ_LOOP: loop
                    SEEK_EVENT(core, stream, next_event);
                    case next_event is
                        when EVENT_SEQ_BEGIN =>
                            READ_EVENT(core, stream, EVENT_SEQ_BEGIN);
                            seq_level := seq_level + 1;
                        when EVENT_SEQ_END   =>
                            READ_EVENT(core, stream, EVENT_SEQ_END  );
                            seq_level := seq_level - 1;
                        when EVENT_MAP_BEGIN =>
                            execute_channel_map_operation;
                        when EVENT_SCALAR    =>
                            execute_channel_scalar_operation;
                        when EVENT_ERROR     =>
                            READ_ERROR(core, proc_name, "SEEK_EVENT NG");
                        when others          =>
                            SKIP_EVENT(core, stream, next_event);
                            -- ERROR
                    end case;
                    exit when (seq_level <= 0);
                end loop;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
        begin
            -----------------------------------------------------------------------
            -- ダミープラグコアの初期化.
            -----------------------------------------------------------------------
            CORE_INIT(
                SELF        => core,          -- 初期化するコア変数.
                NAME        => NAME,          -- コアの名前.
                VOCAL_NAME  => FULL_NAME,     -- メッセージ出力用の名前.
                STREAM      => stream,        -- シナリオのストリーム.
                STREAM_NAME => SCENARIO_FILE, -- シナリオのストリーム名.
                OPERATION   => operation      -- コアのオペレーション.
            );
            -----------------------------------------------------------------------
            -- 変数の初期化.
            -----------------------------------------------------------------------
            out_signals := INIT_SIGNALS;
            -----------------------------------------------------------------------
            -- 信号の初期化
            -----------------------------------------------------------------------
            SYNC_LOCAL_REQ <= (others => 0);
            SYNC_TRANS_REQ <= (others => 0);
            FINISH         <= '0';
            REPORT_STATUS  <= core.report_status;
            execute_output(out_signals);
            core.debug := 0;
            -----------------------------------------------------------------------
            -- メインオペレーションループ
            -----------------------------------------------------------------------
            while (operation /= OP_FINISH) loop
                REPORT_STATUS <= core.report_status;
                READ_OPERATION(core, stream, operation, keyword);
                case operation is
                    when OP_DOC_BEGIN   => local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                    when OP_MAP         =>
                        REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP(") & keyword & ")");
                        if    (keyword = KEY_CHANNEL) then
                            execute_channel_operation;
                        elsif (keyword = KEY_REPORT ) then
                            EXECUTE_REPORT(core, stream);
                        elsif (keyword = KEY_SYNC   ) then
                            local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                            EXECUTE_SKIP(core, stream);
                        elsif (keyword = KEY_WAIT   ) or
                              (CHANNEL = AXI4_CHANNEL_R and MASTER and WRITE_ENABLE and keyword = KEY_WRITE) or
                              (CHANNEL = AXI4_CHANNEL_R and SLAVE  and WRITE_ENABLE and keyword = KEY_WRITE) or
                              (CHANNEL = AXI4_CHANNEL_W and MASTER and READ_ENABLE  and keyword = KEY_READ ) or
                              (CHANNEL = AXI4_CHANNEL_W and SLAVE  and READ_ENABLE  and keyword = KEY_READ ) or
                              (CHANNEL = AXI4_CHANNEL_B and MASTER and READ_ENABLE  and keyword = KEY_READ ) or
                              (CHANNEL = AXI4_CHANNEL_B and SLAVE  and READ_ENABLE  and keyword = KEY_READ ) then
                            execute_dummy_operation;
                        elsif (CHANNEL = AXI4_CHANNEL_R and MASTER and READ_ENABLE  and keyword = KEY_READ ) then
                            execute_transaction_master_read_data;
                        elsif (CHANNEL = AXI4_CHANNEL_R and SLAVE  and READ_ENABLE  and keyword = KEY_READ ) then
                            execute_transaction_slave_read_data;
                        elsif (CHANNEL = AXI4_CHANNEL_W and MASTER and WRITE_ENABLE and keyword = KEY_WRITE) then
                            execute_transaction_master_write_data;
                        elsif (CHANNEL = AXI4_CHANNEL_W and SLAVE  and WRITE_ENABLE and keyword = KEY_WRITE) then
                            execute_transaction_slave_write_data;
                        elsif (CHANNEL = AXI4_CHANNEL_B and MASTER and WRITE_ENABLE and keyword = KEY_WRITE) then
                            execute_transaction_master_write_resp;
                        elsif (CHANNEL = AXI4_CHANNEL_B and SLAVE  and WRITE_ENABLE and keyword = KEY_WRITE) then
                            execute_transaction_slave_write_resp;
                        else
                            REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP:SKIP BEGIN"));
                            EXECUTE_SKIP(core, stream);
                            REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP:SKIP END"));
                        end if;
                    when OP_SCALAR      =>
                        if (keyword = KEY_SYNC) then
                            local_sync(core, SYNC_LOCAL_REQ, SYNC_LOCAL_ACK);
                        else
                            EXECUTE_UNDEFINED_SCALAR(core, stream, keyword);
                        end if;
                    when OP_FINISH      => exit;
                    when others         => null;
                end case;
            end loop;
            REPORT_STATUS <= core.report_status;
            FINISH        <= '1';
            if (FINISH_ABORT) then
                assert FALSE report "Simulation complete." severity FAILURE;
            end if;
            wait;
        end process;
    end generate;
end MODEL;
