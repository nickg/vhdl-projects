-----------------------------------------------------------------------------------
--!     @file    axi4_stream_player.vhd
--!     @brief   AXI4-Stream Dummy Plug Player.
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
use     DUMMY_PLUG.SYNC.SYNC_REQ_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_ACK_VECTOR;
-----------------------------------------------------------------------------------
--! @brief   AXI4_STREAM_PLAYER :
-----------------------------------------------------------------------------------
entity  AXI4_STREAM_PLAYER is
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
        ---------------------------------------------------------------------------
        -- シンクロ用信号.
        ---------------------------------------------------------------------------
        SYNC_REQ        : out   SYNC_REQ_VECTOR (SYNC_WIDTH   -1 downto 0);
        SYNC_ACK        : in    SYNC_ACK_VECTOR (SYNC_WIDTH   -1 downto 0);
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
end AXI4_STREAM_PLAYER;
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
--! @brief   AXI4_STREAM_PLAYER :
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_STREAM_PLAYER is
    -------------------------------------------------------------------------------
    --! @brief AXI4-Stream Xferのレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_STREAM_XFER_DATA_TYPE is record
        id       : std_logic_vector(AXI4_ID_MAX_WIDTH    -1 downto 0);
        dest     : std_logic_vector(AXI4_DEST_MAX_WIDTH  -1 downto 0);
        user     : std_logic_vector(AXI4_USER_MAX_WIDTH  -1 downto 0);
        data     : std_logic_vector(AXI4_XFER_MAX_BYTES*8-1 downto 0);
        strb     : std_logic_vector(AXI4_XFER_MAX_BYTES  -1 downto 0);
        keep     : std_logic_vector(AXI4_XFER_MAX_BYTES  -1 downto 0);
        bytes    : integer;
        last     : std_logic;
    end record;
    constant  AXI4_STREAM_XFER_DATA_NULL : AXI4_STREAM_XFER_DATA_TYPE := (
        id       => (others => '0'),
        dest     => (others => '0'),
        user     => (others => '0'),
        data     => (others => '0'),
        strb     => (others => '0'),
        keep     => (others => '0'),
        bytes    =>  0,
        last     => '0'
    );
    -------------------------------------------------------------------------------
    --! @brief 入力信号のどれかに変化があるまで待つサブプログラム.
    -------------------------------------------------------------------------------
    procedure  wait_on_signals is
    begin
        wait on 
            ACLK       , -- In  :
            ARESETn    , -- In  :
            TDATA_I    , -- In  :
            TSTRB_I    , -- In  :
            TKEEP_I    , -- In  :
            TUSER_I    , -- In  :
            TDEST_I    , -- In  :
            TID_I      , -- In  :
            TLAST_I    , -- In  :
            TVALID_I   , -- In  :
            TREADY_I   , -- In  :
            GPI        ; -- In  :
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief AXI4-Streamの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    signals     信号の期待値.
    --! @param    match       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure match_axi4_stream_signals(
                  signals       : in    AXI4_STREAM_SIGNAL_TYPE;
                  match         : out   boolean
    ) is
    begin
        match := MATCH_STD_LOGIC(signals.VALID               ,TVALID_I) and 
                 MATCH_STD_LOGIC(signals.READY               ,TREADY_I) and 
                 MATCH_STD_LOGIC(signals.LAST                ,TLAST_I ) and 
                 MATCH_STD_LOGIC(signals.DATA(TDATA_I'range) ,TDATA_I ) and 
                 MATCH_STD_LOGIC(signals.STRB(TSTRB_I'range) ,TSTRB_I ) and 
                 MATCH_STD_LOGIC(signals.KEEP(TKEEP_I'range) ,TKEEP_I ) and 
                 MATCH_STD_LOGIC(signals.ID  (TID_I  'range) ,TID_I   ) and 
                 MATCH_STD_LOGIC(signals.USER(TUSER_I'range) ,TUSER_I ) and
                 MATCH_STD_LOGIC(signals.DEST(TDEST_I'range) ,TDEST_I );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief AXI4-Streamの期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    SIGNALS     信号の期待値.
    --! @param    MATCH       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure match_axi4_stream_signals(
        variable  core      : inout CORE_TYPE;
                  signals   : in    AXI4_STREAM_SIGNAL_TYPE;
                  match     : out   boolean
    ) is
        variable  count     :       integer;
    begin
        count := 0;
        if (MATCH_STD_LOGIC(signals.VALID              ,TVALID_I) = FALSE) then
            REPORT_MISMATCH(core, "TVALID " & 
                            BIN_TO_STRING(TVALID_I) & " /= " &
                            BIN_TO_STRING(signals.VALID));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.READY              ,TREADY_I) = FALSE) then
            REPORT_MISMATCH(core, "TREADY " &
                            BIN_TO_STRING(TREADY_I) & " /= " &
                            BIN_TO_STRING(signals.READY));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.DATA(TDATA_I'range),TDATA_I ) = FALSE) then
            REPORT_MISMATCH(core, "TDATA " &
                            HEX_TO_STRING(TDATA_I ) & " /= " &
                            HEX_TO_STRING(signals.DATA(TDATA_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.STRB(TSTRB_I'range),TSTRB_I ) = FALSE) then
            REPORT_MISMATCH(core, "TSTRB " &
                            BIN_TO_STRING(TSTRB_I ) & " /= " &
                            BIN_TO_STRING(signals.STRB(TSTRB_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.KEEP(TKEEP_I'range),TKEEP_I ) = FALSE) then
            REPORT_MISMATCH(core, "TKEEP " &
                            BIN_TO_STRING(TKEEP_I ) & " /= " &
                            BIN_TO_STRING(signals.KEEP(TKEEP_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.LAST               ,TLAST_I ) = FALSE) then
            REPORT_MISMATCH(core, "TLAST " &
                            BIN_TO_STRING(TLAST_I ) & " /= " &
                            BIN_TO_STRING(signals.LAST));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.ID(TID_I'range)    ,TID_I   ) = FALSE) then
            REPORT_MISMATCH(core, "TID " &
                            HEX_TO_STRING(TID_I   ) & " /= " &
                            HEX_TO_STRING(signals.ID(TID_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.USER(TUSER_I'range),TUSER_I ) = FALSE) then
            REPORT_MISMATCH(core, "TUSER " &
                            HEX_TO_STRING(TUSER_I ) & " /= " &
                            HEX_TO_STRING(signals.USER(TUSER_I'range)));
            count := count + 1;
        end if;
        if (MATCH_STD_LOGIC(signals.DEST(TDEST_I'range),TDEST_I ) = FALSE) then
            REPORT_MISMATCH(core, "TDEST " &
                            HEX_TO_STRING(TDEST_I ) & " /= " &
                            HEX_TO_STRING(signals.DEST(TDEST_I'range)));
            count := count + 1;
        end if;
        match := (count = 0);
    end procedure;
    -------------------------------------------------------------------------------
    -- キーワードの定義.
    -------------------------------------------------------------------------------
    subtype   KEYWORD_TYPE is STRING(1 to 6);
    constant  KEY_NULL      : KEYWORD_TYPE := "      ";
    constant  KEY_SAY       : KEYWORD_TYPE := "SAY   ";
    constant  KEY_SYNC      : KEYWORD_TYPE := "SYNC  ";
    constant  KEY_WAIT      : KEYWORD_TYPE := "WAIT  ";
    constant  KEY_CHECK     : KEYWORD_TYPE := "CHECK ";
    constant  KEY_OUT       : KEYWORD_TYPE := "OUT   ";
    constant  KEY_DEBUG     : KEYWORD_TYPE := "DEBUG ";
    constant  KEY_REPORT    : KEYWORD_TYPE := "REPORT";
    constant  KEY_XFER      : KEYWORD_TYPE := "XFER  ";
    constant  KEY_TDATA     : KEYWORD_TYPE := "TDATA ";
    constant  KEY_TSTRB     : KEYWORD_TYPE := "TSTRB ";
    constant  KEY_TKEEP     : KEYWORD_TYPE := "TKEEP ";
    constant  KEY_TLAST     : KEYWORD_TYPE := "TLAST ";
    constant  KEY_TUSER     : KEYWORD_TYPE := "TUSER ";
    constant  KEY_TDEST     : KEYWORD_TYPE := "TDEST ";
    constant  KEY_TID       : KEYWORD_TYPE := "TID   ";
    constant  KEY_TVALID    : KEYWORD_TYPE := "TVALID";
    constant  KEY_TREADY    : KEYWORD_TYPE := "TREADY";
    constant  KEY_DATA      : KEYWORD_TYPE := "DATA  ";
    constant  KEY_STRB      : KEYWORD_TYPE := "STRB  ";
    constant  KEY_KEEP      : KEYWORD_TYPE := "KEEP  ";
    constant  KEY_LAST      : KEYWORD_TYPE := "LAST  ";
    constant  KEY_USER      : KEYWORD_TYPE := "USER  ";
    constant  KEY_DEST      : KEYWORD_TYPE := "DEST  ";
    constant  KEY_ID        : KEYWORD_TYPE := "ID    ";
    constant  KEY_VALID     : KEYWORD_TYPE := "VALID ";
    constant  KEY_READY     : KEYWORD_TYPE := "READY ";
begin 
    -------------------------------------------------------------------------------
    -- メインプロセス
    -------------------------------------------------------------------------------
    process
        ---------------------------------------------------------------------------
        -- 各種変数の定義.
        ---------------------------------------------------------------------------
        file      stream        : TEXT;
        variable  core          : CORE_TYPE;
        variable  keyword       : KEYWORD_TYPE;
        variable  operation     : OPERATION_TYPE;
        variable  out_signals   : AXI4_STREAM_SIGNAL_TYPE;
        variable  chk_signals   : AXI4_STREAM_SIGNAL_TYPE;
        variable  gpo_signals   : std_logic_vector(GPO'range);
        variable  gpi_signals   : std_logic_vector(GPI'range);
        ---------------------------------------------------------------------------
        --! @brief std_logic_vectorの値を読むサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        --! @param    value       読み取ったstd_logic_vectorの値.
        ---------------------------------------------------------------------------
        procedure read_value(
                      proc_name     : in    string;
                      value         : out   std_logic_vector
        ) is
            variable  next_event    :       EVENT_TYPE;
            variable  read_len      :       integer;
            variable  value_size    :       integer;
        begin
            SEEK_EVENT(core, stream, next_event);
            if (next_event /= EVENT_SCALAR) then
                READ_ERROR(core, proc_name, "READ_VALUE NG");
            end if;
            READ_EVENT(core, stream, EVENT_SCALAR);
            STRING_TO_STD_LOGIC_VECTOR(
                STR     => core.str_buf(1 to core.str_len),
                VAL     => value,
                STR_LEN => read_len,
                VAL_LEN => value_size
            );
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief std_logicの値を読むサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        --! @param    value       読み取ったstd_logicの値.
        ---------------------------------------------------------------------------
        procedure read_value(
                      proc_name     : in    string;
                      value         : out   std_logic
        ) is
            variable  next_event    :       EVENT_TYPE;
            variable  read_len      :       integer;
            variable  value_size    :       integer;
            variable  vec           :       std_logic_vector(0 downto 0);
        begin
            SEEK_EVENT(core, stream, next_event);
            if (next_event /= EVENT_SCALAR) then
                READ_ERROR(core, proc_name, "READ_VALUE NG");
            end if;
            READ_EVENT(core, stream, EVENT_SCALAR);
            STRING_TO_STD_LOGIC_VECTOR(
                STR     => core.str_buf(1 to core.str_len),
                VAL     => vec,
                STR_LEN => read_len,
                VAL_LEN => value_size
            );
            value := vec(0);
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief 値を読み飛ばすサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        ---------------------------------------------------------------------------
        procedure skip_value(
                      proc_name     : in    string
        ) is
            variable  next_event    :       EVENT_TYPE;
            variable  read_len      :       integer;
            variable  val_size      :       integer;
        begin
            SEEK_EVENT(core, stream, next_event);
            if (next_event /= EVENT_SCALAR) then
                READ_ERROR(core, proc_name, "SKIP_VALUE NG");
            end if;
            READ_EVENT(core, stream, EVENT_SCALAR);
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオのマップからAXI4-Stream信号構造体の値を読み取るサブプログラム.
        --!      * このサブプログラムを呼ぶときは、すでにMAP_READ_BEGINを実行済みに
        --!        しておかなければならない。
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
        --! @param    event       次のイベント. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure map_read_axi4_stream_signals(
                      signals       : inout AXI4_STREAM_SIGNAL_TYPE;
                      event         : inout EVENT_TYPE
        ) is
            constant  proc_name     :       string := "MAP_READ_AXI4_STREAM_SIGNALS";
            variable  next_event    :       EVENT_TYPE;
            variable  key_word      :       KEYWORD_TYPE;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            next_event := event;
            MAP_LOOP: loop
                case next_event is
                    when EVENT_SCALAR  =>
                        COPY_KEY_WORD(core, key_word);
                        case key_word is
                            when KEY_TDATA  | KEY_DATA  =>
                                read_value(proc_name, signals.DATA(WIDTH.DATA  -1 downto 0));
                            when KEY_TKEEP  | KEY_KEEP  =>
                                read_value(proc_name, signals.KEEP(WIDTH.DATA/8-1 downto 0));
                            when KEY_TSTRB  | KEY_STRB  =>
                                read_value(proc_name, signals.STRB(WIDTH.DATA/8-1 downto 0));
                            when KEY_TUSER  | KEY_USER  =>
                                read_value(proc_name, signals.USER(WIDTH.USER  -1 downto 0));
                            when KEY_TDEST  | KEY_DEST  =>
                                read_value(proc_name, signals.DEST(WIDTH.DEST  -1 downto 0));
                            when KEY_TID    | KEY_ID    =>
                                read_value(proc_name, signals.ID  (WIDTH.ID    -1 downto 0));
                            when KEY_TLAST  | KEY_LAST  =>
                                read_value(proc_name, signals.LAST );
                            when KEY_TVALID | KEY_VALID =>
                                read_value(proc_name, signals.VALID);
                            when KEY_TREADY | KEY_READY =>
                                read_value(proc_name, signals.READY);
                            when others => exit MAP_LOOP;
                        end case;
                    when EVENT_MAP_END  => exit MAP_LOOP;
                    when others         => exit MAP_LOOP;
                end case;
                SEEK_EVENT(core, stream, next_event);
                if (next_event = EVENT_SCALAR) then
                    READ_EVENT(core, stream, EVENT_SCALAR);
                end if;
            end loop;
            event := next_event;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief CHECKオペレーション.信号が指定された値になっているかチェック.
        ---------------------------------------------------------------------------
        procedure execute_check is
            constant  proc_name      : string := "EXECUTE_CHECK";
            variable  next_event     : EVENT_TYPE;
            variable  keyword        : KEYWORD_TYPE;
            variable  match          : boolean;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            case next_event is
                when EVENT_MAP_BEGIN =>
                    READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                    chk_signals := AXI4_STREAM_SIGNAL_DONTCARE;
                    gpi_signals := (others => '-');
                    MAP_READ_LOOP: loop
                        MAP_READ_PREPARE_FOR_NEXT(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        map_read_axi4_stream_signals(
                            signals    => chk_signals     ,  -- I/O:
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
                    match_axi4_stream_signals(core, chk_signals, match);
                    MATCH_GPI(core, gpi_signals, GPI, match);
                when others =>
                    READ_ERROR(core, proc_name, "SEEK_EVENT NG");
            end case;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  WAITオペレーション. 指定された条件まで待機.
        ---------------------------------------------------------------------------
        procedure execute_wait is
            constant  proc_name      : string := "EXECUTE_WAIT";
            variable  next_event     : EVENT_TYPE;
            variable  keyword        : KEYWORD_TYPE;
            variable  wait_count     : integer;
            variable  scan_len       : integer;
            variable  timeout        : integer;
            variable  wait_on        : boolean;
            variable  axi_match      : boolean;
            variable  gpi_match      : boolean;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            timeout   := DEFAULT_WAIT_TIMEOUT;
            wait_on   := FALSE;
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
                    chk_signals := AXI4_STREAM_SIGNAL_DONTCARE;
                    gpi_signals := (others => '-');
                    MAP_READ_LOOP: loop
                        REPORT_DEBUG(core, proc_name, "MAP_READ_LOOP");
                        MAP_READ_PREPARE_FOR_NEXT(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        map_read_axi4_stream_signals(
                            signals    => chk_signals     ,  -- I/O:
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
                            match_axi4_stream_signals(chk_signals, axi_match);
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
                            match_axi4_stream_signals(chk_signals, axi_match);
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
        ---------------------------------------------------------------------------
        --! @brief execute_xfer 用の変数.
        --!        procedure内のローカル変数ではなくprocess内の変数にしているのは、
        --!        procedureだと、実行する度に変数の領域を確保する必要があるため。
        ---------------------------------------------------------------------------
        variable  xfer_data     : AXI4_STREAM_XFER_DATA_TYPE;
        ---------------------------------------------------------------------------
        --! @brief xfer_data.DATA の値を読み取るサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        ---------------------------------------------------------------------------
        procedure read_xfer_byte_data(
                      pos           : inout integer
        ) is
            constant  proc_name     :       string := "read_xfer_byte_data";
            variable  read_len      :       integer;
            variable  value_size    :       integer;
            variable  bytes         :       integer;
        begin 
            REPORT_DEBUG(core, proc_name, "BEGIN");
            if (core.str_len = 4 and core.str_buf(1 to 4) = "NULL") or
               (core.str_len = 3 and core.str_buf(1 to 3) = "NIL" ) then
                if (SLAVE) then
                    xfer_data.data(8*pos+7 downto 8*pos) := "--------";
                    xfer_data.strb(pos) := '0';
                    xfer_data.keep(pos) := '0';
                else
                    xfer_data.data(8*pos+7 downto 8*pos) := "00000000";
                    xfer_data.strb(pos) := '0';
                    xfer_data.keep(pos) := '0';
                end if;
                pos := pos + 1;
            elsif (core.str_len = 3 and core.str_buf(1 to 3) = "PAD" ) then
                if (SLAVE) then
                    xfer_data.data(8*pos+7 downto 8*pos) := "--------";
                    xfer_data.strb(pos) := '0';
                    xfer_data.keep(pos) := '1';
                else
                    xfer_data.data(8*pos+7 downto 8*pos) := "00000000";
                    xfer_data.strb(pos) := '0';
                    xfer_data.keep(pos) := '1';
                end if;
                pos := pos + 1;
            else
                STRING_TO_STD_LOGIC_VECTOR(
                    STR     => core.str_buf(1 to core.str_len),
                    VAL     => xfer_data.data(AXI4_XFER_MAX_BYTES*8-1 downto 8*pos),
                    STR_LEN => read_len,
                    VAL_LEN => value_size
                );
                bytes := (value_size+7)/8;
                xfer_data.strb(bytes+pos-1 downto pos) := (bytes+pos-1 downto pos => '1');
                xfer_data.keep(bytes+pos-1 downto pos) := (bytes+pos-1 downto pos => '1');
                pos := pos + bytes;
            end if;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief xfer_data.DATA の値を読み取るサブプログラム.
        ---------------------------------------------------------------------------
        procedure read_xfer_data is
            constant  proc_name     : string := "read_xfer_data";
            variable  next_event    : EVENT_TYPE;
            variable  seq_level     : integer;
            variable  data_pos      : integer;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            if (next_event = EVENT_SCALAR) then
                READ_EVENT(core, stream, EVENT_SCALAR);
                data_pos := 0;
                read_xfer_byte_data(data_pos);
                xfer_data.BYTES := data_pos;
            elsif (next_event = EVENT_SEQ_BEGIN) then
                READ_EVENT(core, stream, EVENT_SEQ_BEGIN);
                data_pos  := 0;
                seq_level := 1;
                SEQ_LOOP: loop
                    SEEK_EVENT(core, stream, next_event);
                    case next_event is
                        when EVENT_SEQ_BEGIN =>
                            READ_EVENT(core, stream, next_event);
                            seq_level := seq_level + 1;
                        when EVENT_SEQ_END   =>
                            if (seq_level > 0) then
                                READ_EVENT(core, stream, next_event);
                                seq_level := seq_level - 1;
                            end if;
                            exit when (seq_level = 0);
                        when EVENT_SCALAR    =>
                            READ_EVENT(core, stream, next_event);
                            read_xfer_byte_data(data_pos);
                        when EVENT_ERROR     =>
                            READ_ERROR(core, proc_name, "SEEK_EVENT NG");
                        when others          =>
                            READ_ERROR(core, proc_name, "SEEK_EVENT NG");
                    end case;
                end loop;
                xfer_data.BYTES := data_pos;
            end if;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオのマップから xfer_data の値を読み取るサブプログラム.
        --!      * このサブプログラムを呼ぶときは、すでにMAP_READ_BEGINを実行済みに
        --!        しておかなければならない。
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    event       次のイベント. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure map_read_axi4_xfer_data(
                      event         : inout EVENT_TYPE
        ) is
            constant  proc_name     :       string := "MAP_READ_AXI4_XFER_DATA";
            variable  next_event    :       EVENT_TYPE;
            variable  key_word      :       KEYWORD_TYPE;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            next_event := event;
            MAP_LOOP: loop
                case next_event is
                    when EVENT_SCALAR  =>
                        COPY_KEY_WORD(core, key_word);
                        case key_word is
                            when KEY_DATA =>
                                read_xfer_data;
                            when KEY_USER =>
                                read_value(proc_name, xfer_data.USER);
                            when KEY_DEST =>
                                read_value(proc_name, xfer_data.DEST);
                            when KEY_ID   =>
                                read_value(proc_name, xfer_data.ID  );
                            when KEY_LAST =>
                                read_value(proc_name, xfer_data.LAST);
                            when others   => exit MAP_LOOP;
                        end case;
                    when EVENT_MAP_END    => exit MAP_LOOP;
                    when others           => exit MAP_LOOP;
                end case;
                SEEK_EVENT(core, stream, next_event);
                if (next_event = EVENT_SCALAR) then
                    READ_EVENT(core, stream, EVENT_SCALAR);
                end if;
            end loop;
            event := next_event;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief xfer_data の値を１ワード毎の AXI4-Stream 信号を取り出す.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    signals     読み取った値が入る変数. 
        --! @param    pos         xfer_dataの位置. inout で変更される事に注意.
        ---------------------------------------------------------------------------
        procedure xfer_data_to_signals(
                      signals        : out   AXI4_STREAM_SIGNAL_TYPE;
                      pos            : inout integer
        ) is
        begin 
            signals.ID   := xfer_data.id;
            signals.USER := xfer_data.user;
            signals.DEST := xfer_data.dest;
            for i in 0 to WIDTH.DATA/8-1 loop
                if (pos < xfer_data.bytes) then
                    signals.DATA(8*i+7 downto 8*i) := xfer_data.data(8*pos+7 downto 8*pos);
                    signals.STRB(i) := xfer_data.strb(pos);
                    signals.KEEP(i) := xfer_data.keep(pos);
                    pos := pos + 1;
                elsif (SLAVE) then
                    signals.DATA(8*i+7 downto 8*i) := "--------";
                    signals.STRB(i) := '0';
                    signals.KEEP(i) := '-';
                else
                    signals.DATA(8*i+7 downto 8*i) := "00000000";
                    signals.STRB(i) := '0';
                    signals.KEEP(i) := '0';
                end if;
            end loop;
            if (xfer_data.LAST = '1' and pos >= xfer_data.bytes) then
                signals.LAST := '1';
            else
                signals.LAST := '0';
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  XFERオペレーション(マスター用). 
        ---------------------------------------------------------------------------
        procedure execute_xfer_master(
                      timeout        : inout integer
        ) is
            constant  proc_name      :       string := "EXECUTE_XFER_MASTER";
            variable  pos            :       integer;
        begin
            pos := 0;
            while(pos < xfer_data.bytes) loop
                xfer_data_to_signals(out_signals, pos);
                TDATA_O  <= out_signals.data(TDATA_O'range) after OUTPUT_DELAY;
                TSTRB_O  <= out_signals.strb(TSTRB_O'range) after OUTPUT_DELAY;
                TKEEP_O  <= out_signals.keep(TKEEP_O'range) after OUTPUT_DELAY;
                TID_O    <= out_signals.id  (TID_O  'range) after OUTPUT_DELAY;
                TDEST_O  <= out_signals.dest(TDEST_O'range) after OUTPUT_DELAY;
                TUSER_O  <= out_signals.user(TUSER_O'range) after OUTPUT_DELAY;
                TLAST_O  <= out_signals.last                after OUTPUT_DELAY;
                TVALID_O <= '1' after OUTPUT_DELAY;
                MASTER_CHECK_LOOP: loop
                    wait until (ACLK'event and ACLK = '1');
                    exit when(TREADY_I = '1');
                    if (timeout > 0) then
                        timeout := timeout - 1;
                    else
                        EXECUTE_ABORT(core, proc_name, "Time Out!");
                    end if;
                end loop;
                TVALID_O <= '0' after OUTPUT_DELAY;
            end loop;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  XFERオペレーション(スレーブ用). 
        ---------------------------------------------------------------------------
        procedure execute_xfer_slave(
                      timeout        : inout integer
        ) is
            constant  proc_name      :       string := "EXECUTE_XFER_SLAVE";
            variable  pos            :       integer;
            variable  match          :       boolean;
        begin
            pos := 0;
            chk_signals := AXI4_STREAM_SIGNAL_DONTCARE;
            while(pos < xfer_data.bytes) loop
                TREADY_O <= '1' after OUTPUT_DELAY;
                SLAVE_CHECK_LOOP: loop
                    wait until (ACLK'event and ACLK = '1');
                    exit when(TVALID_I = '1');
                    if (timeout > 0) then
                        timeout := timeout - 1;
                    else
                        EXECUTE_ABORT(core, proc_name, "Time Out!");
                    end if;
                end loop;
                TREADY_O <= '0' after OUTPUT_DELAY;
                xfer_data_to_signals(chk_signals, pos);
                match_axi4_stream_signals(core, chk_signals, match);
            end loop;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  XFERオペレーション. 
        ---------------------------------------------------------------------------
        procedure execute_xfer is
            constant  proc_name      : string := "EXECUTE_XFER";
            variable  next_event     : EVENT_TYPE;
            variable  keyword        : KEYWORD_TYPE;
            variable  timeout        : integer;
            variable  pos            : integer;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            timeout := DEFAULT_WAIT_TIMEOUT;
            xfer_data.bytes :=  0 ;
            xfer_data.last  := '0';
            SEEK_EVENT(core, stream, next_event);
            case next_event is
                when EVENT_MAP_BEGIN =>
                    READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                    MAP_READ_LOOP: loop
                        REPORT_DEBUG(core, proc_name, "MAP_READ_LOOP");
                        MAP_READ_PREPARE_FOR_NEXT(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        map_read_axi4_xfer_data(
                            event      => next_event         -- I/O:
                        );
                        MAP_READ_INTEGER(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            KEY        => "TIMEOUT"       ,  -- In :
                            VAL        => timeout         ,  -- I/O:
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
                    if (MASTER) then
                        execute_xfer_master(timeout);
                    end if;
                    if (SLAVE) then
                        execute_xfer_slave (timeout);
                    end if;
                when others =>
                    READ_ERROR(core, proc_name, "SEEK_EVENT NG");
            end case;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  SYNCオペレーション. 
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    OPERATION   オペレーション.
        ---------------------------------------------------------------------------
        procedure execute_sync(
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
            if (SYNC_REQ'low <= port_num and port_num <= SYNC_REQ'high) then
                CORE_SYNC(core, port_num, wait_num, SYNC_REQ, SYNC_ACK);
            end if;
            REPORT_DEBUG  (core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief 信号変数(signals)の値をポートに出力するサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    signals    出力する信号の値を指定する変数.
        ---------------------------------------------------------------------------
        -- procedure EXECUTE_OUTPUT(signals: in AXI4_STREAM_SIGNAL_TYPE) is
        -- begin 
        --     if (MASTER) then
        --         TDATA_O  <= signals.DATA(TDATA_O'range) after OUTPUT_DELAY;
        --         TSTRB_O  <= signals.STRB(TSTRB_O'range) after OUTPUT_DELAY;
        --         TKEEP_O  <= signals.KEEP(TKEEP_O'range) after OUTPUT_DELAY;
        --         TUSER_O  <= signals.USER(TUSER_O'range) after OUTPUT_DELAY;
        --         TDEST_O  <= signals.DEST(TDEST_O'range) after OUTPUT_DELAY;
        --         TID_O    <= signals.DEST(TID_O  'range) after OUTPUT_DELAY;
        --         TLAST_O  <= signals.LAST                after OUTPUT_DELAY;
        --         TVALID_O <= signals.VALID               after OUTPUT_DELAY;
        --     end if;
        --     if (SLAVE) then
        --         TREADY_O <= signals.READY               after OUTPUT_DELAY;
        --     end if;
        -- end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからTDATAの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_tdata is
            constant proc_name : string := "EXECUTE_TDATA";
        begin
            if (MASTER) then
                read_value(proc_name, out_signals.DATA(WIDTH.DATA  -1 downto 0));
                TDATA_O  <= out_signals.DATA(TDATA_O'range) after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからTSTRBの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_tstrb is
            constant proc_name : string := "EXECUTE_TSTRB";
        begin
            if (MASTER) then
                read_value(proc_name, out_signals.STRB(WIDTH.DATA/8-1 downto 0));
                TSTRB_O  <= out_signals.STRB(TSTRB_O'range) after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからTKEEPの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_tkeep is
            constant proc_name : string := "EXECUTE_TKEEP";
        begin
            if (MASTER) then
                read_value(proc_name, out_signals.KEEP(WIDTH.DATA/8-1 downto 0));
                TKEEP_O  <= out_signals.KEEP(TKEEP_O'range) after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからTIDの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_tid is
            constant proc_name : string := "EXECUTE_TID";
        begin
            if (MASTER) then
                read_value(proc_name, out_signals.ID(WIDTH.ID-1 downto 0));
                xfer_data.id(WIDTH.ID-1 downto 0) := out_signals.ID(WIDTH.ID-1 downto 0);
                TID_O    <= out_signals.ID  (TID_O  'range) after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからTUSERの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_tuser is
            constant proc_name : string := "EXECUTE_TUSER";
        begin
            if (MASTER) then
                read_value(proc_name, out_signals.USER(WIDTH.USER-1 downto 0));
                xfer_data.user(WIDTH.USER-1 downto 0) := out_signals.user(WIDTH.USER-1 downto 0);
                TUSER_O  <= out_signals.USER(TUSER_O'range) after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからTDESTの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_tdest is
            constant proc_name : string := "EXECUTE_TDEST";
        begin
            if (MASTER) then
                read_value(proc_name, out_signals.DEST(WIDTH.DEST-1 downto 0));
                xfer_data.dest(WIDTH.DEST-1 downto 0) := out_signals.dest(WIDTH.DEST-1 downto 0);
                TDEST_O  <= out_signals.DEST(TDEST_O'range) after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからTLASTの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_tlast is
            constant proc_name : string := "EXECUTE_TLAST";
        begin
            if (MASTER) then
                read_value(proc_name, out_signals.LAST);
                TLAST_O  <= out_signals.LAST                after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからTVALIDの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_tvalid is
            constant proc_name : string := "EXECUTE_TVALID";
        begin
            if (MASTER) then
                read_value(proc_name, out_signals.VALID);
                TVALID_O <= out_signals.VALID               after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからTREADYの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_tready is
            constant proc_name : string := "EXECUTE_TREADY";
        begin
            if (SLAVE) then
                read_value(proc_name, out_signals.READY);
                TREADY_O <= out_signals.READY               after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
    begin
        ---------------------------------------------------------------------------
        -- ダミープラグコアの初期化.
        ---------------------------------------------------------------------------
        CORE_INIT(
            SELF        => core,          -- 初期化するコア変数.
            NAME        => NAME,          -- コアの名前.
            VOCAL_NAME  => FULL_NAME,     -- メッセージ出力用の名前.
            STREAM      => stream,        -- シナリオのストリーム.
            STREAM_NAME => SCENARIO_FILE, -- シナリオのストリーム名.
            OPERATION   => operation      -- コアのオペレーション.
        );
        ---------------------------------------------------------------------------
        -- 変数の初期化.
        ---------------------------------------------------------------------------
        out_signals := AXI4_STREAM_SIGNAL_NULL;
        chk_signals := AXI4_STREAM_SIGNAL_DONTCARE;
        gpo_signals := (others => 'Z');
        gpi_signals := (others => '-');
        xfer_data   := AXI4_STREAM_XFER_DATA_NULL;
        core.debug  := 0;
        ---------------------------------------------------------------------------
        -- 信号の初期化
        ---------------------------------------------------------------------------
        SYNC_REQ       <= (0 =>0, others => -1);
        FINISH         <= '0';
        REPORT_STATUS  <= core.report_status;
        if (MASTER) then
            TDATA_O  <= (others => '0');
            TSTRB_O  <= (others => '1');
            TKEEP_O  <= (others => '1');
            TID_O    <= (others => '0');
            TUSER_O  <= (others => '0');
            TDEST_O  <= (others => '0');
            TLAST_O  <= '0';
            TVALID_O <= '0';
        end if;
        if (SLAVE) then
            TREADY_O <= '0';
        end if;
        ---------------------------------------------------------------------------
        -- リセット解除待ち
        ---------------------------------------------------------------------------
        wait until(ACLK'event and ACLK = '1' and ARESETn = '1');
        ---------------------------------------------------------------------------
        -- メインオペレーションループ
        ---------------------------------------------------------------------------
        while (operation /= OP_FINISH) loop
            REPORT_STATUS <= core.report_status;
            READ_OPERATION(core, stream, operation, keyword);
            case operation is
                when OP_DOC_BEGIN => execute_sync(operation);
                when OP_MAP       =>
                    case keyword is
                        when KEY_DATA   |
                             KEY_TDATA  => execute_tdata;
                        when KEY_STRB   |
                             KEY_TSTRB  => execute_tstrb;
                        when KEY_KEEP   |
                             KEY_TKEEP  => execute_tkeep;
                        when KEY_ID     |
                             KEY_TID    => execute_tid;
                        when KEY_USER   |
                             KEY_TUSER  => execute_tuser;
                        when KEY_DEST   |
                             KEY_TDEST  => execute_tdest;
                        when KEY_LAST   |
                             KEY_TLAST  => execute_tlast;
                        when KEY_VALID  |
                             KEY_TVALID => execute_tvalid;
                        when KEY_READY  |
                             KEY_TREADY => execute_tready;
                        when KEY_REPORT => EXECUTE_REPORT(core, stream);
                        when KEY_DEBUG  => EXECUTE_DEBUG (core, stream);
                        when KEY_SAY    => EXECUTE_SAY   (core, stream);
                        when KEY_OUT    => EXECUTE_OUT   (core, stream, gpo_signals, GPO);
                        when KEY_SYNC   => execute_sync  (operation);
                        when KEY_WAIT   => execute_wait;
                        when KEY_CHECK  => execute_check;
                        when KEY_XFER   => execute_xfer;
                        when others     => EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                    end case;
                when OP_FINISH    => exit;
                when others       => null;
            end case;
        end loop;
        REPORT_STATUS <= core.report_status;
        FINISH        <= '1';
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete." severity FAILURE;
        end if;
        wait;
    end process;        
end MODEL;
