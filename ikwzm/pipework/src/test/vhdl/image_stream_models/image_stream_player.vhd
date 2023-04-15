-----------------------------------------------------------------------------------
--!     @file    image_stream_player.vhd
--!     @brief   Image Stream Dummy Plug Player.
--!     @version 1.8.0
--!     @date    2019/1/29
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2019 Ichiro Kawazome
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
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_REQ_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_ACK_VECTOR;
-----------------------------------------------------------------------------------
--! @brief   IMAGE_STREAM_PLAYER :
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_PLAYER is
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
        PARAM           : --! @brief Image Stream Parameter
                          IMAGE_STREAM_PARAM_TYPE;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time;
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
        CLK             : in    std_logic;
        RST             : in    std_logic;
        ---------------------------------------------------------------------------
        -- Image Stream Signals
        ---------------------------------------------------------------------------
        DATA_I          : in    std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
        DATA_O          : out   std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
        VALID_I         : in    std_logic;
        VALID_O         : out   std_logic;
        READY_I         : in    std_logic;
        READY_O         : out   std_logic;
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
end IMAGE_STREAM_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.CORE.all;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.all;
use     DUMMY_PLUG.READER.all;
-----------------------------------------------------------------------------------
--! @brief   IMAGE_STREAM_PLAYER :
-----------------------------------------------------------------------------------
architecture MODEL of IMAGE_STREAM_PLAYER is
    -------------------------------------------------------------------------------
    --! @brief MAX : 二つの引数を比較して大きい方を選択する関数
    -------------------------------------------------------------------------------
    function  MAX(A,B:integer) return integer is
    begin
        if (A > B) then return A;
        else            return B;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! @brief WAITオペレーション実行時のデフォルトのタイムアウトクロック数
    -------------------------------------------------------------------------------
    constant  DEFAULT_WAIT_TIMEOUT : integer := 10000;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の ELEMENT 信号の定義
    -------------------------------------------------------------------------------
    subtype   IMAGE_ELEM_SIGNAL_TYPE    is std_logic_vector(PARAM.ELEM_BITS-1 downto 0);
    type      IMAGE_ELEM_SIGNAL_STREAM  is array (integer range <>,
                                                  integer range <>,
                                                  integer range <>,
                                                  integer range <>) of IMAGE_ELEM_SIGNAL_TYPE;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の ATTRIBUTE 信号の定義
    -------------------------------------------------------------------------------
    subtype   IMAGE_ATRB_SIGNAL_TYPE    is std_logic_vector(PARAM.ATRB_BITS-1 downto 0);
    type      IMAGE_ATRB_SIGNAL_VECTOR  is array (integer range <>) of IMAGE_ATRB_SIGNAL_TYPE;
    type      IMAGE_ATRB_SIGNAL_STREAM  is record
                  Y         :  IMAGE_ATRB_SIGNAL_VECTOR(PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.HI);
                  X         :  IMAGE_ATRB_SIGNAL_VECTOR(PARAM.SHAPE.X.LO to PARAM.SHAPE.X.HI);
                  D         :  IMAGE_ATRB_SIGNAL_VECTOR(PARAM.SHAPE.D.LO to PARAM.SHAPE.D.HI);
                  C         :  IMAGE_ATRB_SIGNAL_VECTOR(PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI);
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image Stream 信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      IMAGE_STREAM_SIGNAL_TYPE is record
                  ELEM      :  IMAGE_ELEM_SIGNAL_STREAM(PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.HI,
                                                        PARAM.SHAPE.X.LO to PARAM.SHAPE.X.HI,
                                                        PARAM.SHAPE.D.LO to PARAM.SHAPE.D.HI,
                                                        PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI);
                  ATRB      :  IMAGE_ATRB_SIGNAL_STREAM;
                  INFO      :  std_logic_vector(MAX(1, PARAM.INFO_BITS)-1 downto 0);
                  DATA      :  std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
                  VALID     :  std_logic;
                  READY     :  std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief Image Stream 信号を値で埋めるプロシージャ
    -------------------------------------------------------------------------------
    procedure FILL_DATA_TO_IMAGE_STREAM_SIGNAL(
                  W         : inout IMAGE_STREAM_SIGNAL_TYPE;
                  D         : in    std_logic)
    is
    begin
        for y_pos in PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.HI loop
        for x_pos in PARAM.SHAPE.X.LO to PARAM.SHAPE.X.HI loop
        for d_pos in PARAM.SHAPE.D.LO to PARAM.SHAPE.D.HI loop
        for c_pos in PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI loop
            for i in IMAGE_ELEM_SIGNAL_TYPE'range loop
                W.ELEM(y_pos, x_pos, d_pos, c_pos)(i) := D;
            end loop;
            SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                PARAM   => PARAM,
                C       => c_pos,
                D       => d_pos,
                X       => x_pos,
                Y       => y_pos,
                ELEMENT => W.ELEM(y_pos, x_pos, d_pos, c_pos),
                DATA    => W.DATA
            );
        end loop;
        end loop;
        end loop;
        end loop;
        for y_pos in PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.HI loop
            for i in IMAGE_ATRB_SIGNAL_TYPE'range loop
                W.ATRB.Y(y_pos)(i) := D;
            end loop;
            SET_ATRB_Y_TO_IMAGE_STREAM_DATA(
                PARAM   => PARAM,
                Y       => y_pos,
                ATRB    => W.ATRB.Y(y_pos),
                DATA    => W.DATA
            );
        end loop;
        for x_pos in PARAM.SHAPE.X.LO to PARAM.SHAPE.X.HI loop
            for i in IMAGE_ATRB_SIGNAL_TYPE'range loop
                W.ATRB.X(x_pos)(i) := D;
            end loop;
            SET_ATRB_X_TO_IMAGE_STREAM_DATA(
                PARAM   => PARAM,
                X       => x_pos,
                ATRB    => W.ATRB.X(x_pos),
                DATA    => W.DATA
            );
        end loop;
        for d_pos in PARAM.SHAPE.D.LO to PARAM.SHAPE.D.HI loop
            for i in IMAGE_ATRB_SIGNAL_TYPE'range loop
                W.ATRB.D(d_pos)(i) := D;
            end loop;
            SET_ATRB_D_TO_IMAGE_STREAM_DATA(
                PARAM   => PARAM,
                D       => d_pos,
                ATRB    => W.ATRB.D(d_pos),
                DATA    => W.DATA
            );
        end loop;
        for c_pos in PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI loop
            for i in IMAGE_ATRB_SIGNAL_TYPE'range loop
                W.ATRB.C(c_pos)(i) := D;
            end loop;
            SET_ATRB_C_TO_IMAGE_STREAM_DATA(
                PARAM   => PARAM,
                C       => c_pos,
                ATRB    => W.ATRB.C(c_pos),
                DATA    => W.DATA
            );
        end loop;
        for i in W.INFO'range loop
            W.INFO(i) := D;
        end loop;
        if (PARAM.INFO_BITS > 0) then
            for i in PARAM.DATA.INFO_FIELD.LO to PARAM.DATA.INFO_FIELD.HI loop
                W.DATA(i) := D;
            end loop;
        end if;
        W.VALID := D;
        W.READY := D;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief Image Stream 信号を値で埋める関数
    -------------------------------------------------------------------------------
    function  INIT_IMAGE_STREAM_SIGNAL(D: std_logic) return IMAGE_STREAM_SIGNAL_TYPE
    is
        variable win_signal : IMAGE_STREAM_SIGNAL_TYPE;
    begin
        FILL_DATA_TO_IMAGE_STREAM_SIGNAL(win_signal, D);
        return win_signal;
    end function;
    -------------------------------------------------------------------------------
    --! @brief Image Stream 信号の初期値
    -------------------------------------------------------------------------------
    constant  IMAGE_STREAM_SIGNAL_NULL      : IMAGE_STREAM_SIGNAL_TYPE := INIT_IMAGE_STREAM_SIGNAL('0');
    constant  IMAGE_STREAM_SIGNAL_DONTCARE  : IMAGE_STREAM_SIGNAL_TYPE := INIT_IMAGE_STREAM_SIGNAL('-');
    -------------------------------------------------------------------------------
    --! @brief 入力信号のどれかに変化があるまで待つサブプログラム.
    -------------------------------------------------------------------------------
    procedure wait_on_signals is
    begin
        wait on 
            CLK        , -- In  :
            RST        , -- In  :
            DATA_I     , -- In  :
            VALID_I    , -- In  :
            READY_I    , -- In  :
            GPI        ; -- In  :
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    signals     信号の期待値.
    --! @param    match       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure match_image_stream_signals(
                  signals   : in    IMAGE_STREAM_SIGNAL_TYPE;
                  match     : out   boolean
    ) is
    begin
        match := MATCH_STD_LOGIC(signals.VALID, VALID_I) and 
                 MATCH_STD_LOGIC(signals.READY, READY_I) and 
                 MATCH_STD_LOGIC(signals.DATA , DATA_I );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief Image Stream の期待値と信号の値を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    core        コア変数.
    --! @param    signals     信号の期待値.
    --! @param    match       比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    procedure match_image_stream_signals(
        variable  core      : inout CORE_TYPE;
                  signals   : in    IMAGE_STREAM_SIGNAL_TYPE;
                  match     : out   boolean
    ) is
        variable  elem_i    :       std_logic_vector(PARAM.ELEM_BITS-1 downto 0);
        variable  atrb_i    :       std_logic_vector(PARAM.ATRB_BITS-1 downto 0);
        variable  match_s   :       boolean;
    begin
        match_image_stream_signals(signals, match_s);
        match := match_s;
        if (match_s = TRUE) then
            return;
        end if;
        if (MATCH_STD_LOGIC(signals.VALID , VALID_I) = FALSE) then
            REPORT_MISMATCH(core, "VALID " & 
                            BIN_TO_STRING(  VALID_I ) & " /= " &
                            BIN_TO_STRING(  signals.VALID) );
        end if;
        if (MATCH_STD_LOGIC(signals.READY , READY_I) = FALSE) then
            REPORT_MISMATCH(core, "READY " &
                            BIN_TO_STRING(  READY_I ) & " /= " &
                            BIN_TO_STRING(  signals.READY) );
        end if;
        for y_pos in PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.HI loop
        for x_pos in PARAM.SHAPE.X.LO to PARAM.SHAPE.X.HI loop
        for d_pos in PARAM.SHAPE.D.LO to PARAM.SHAPE.D.HI loop -- D Channel は要素に含まれていない
        for c_pos in PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI loop
            elem_i := GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                          PARAM  => PARAM,
                          C      => c_pos,
                          D      => d_pos,
                          X      => x_pos,
                          Y      => y_pos,
                          DATA   => DATA_I
                      );
            if (MATCH_STD_LOGIC(signals.ELEM(y_pos, x_pos, d_pos, c_pos) , elem_i) = FALSE) then
                REPORT_MISMATCH(core, "ELEM[" &
                                INTEGER_TO_STRING(y_pos) & "][" &
                                INTEGER_TO_STRING(x_pos) & "][ " & 
                                INTEGER_TO_STRING(d_pos) & "][ " & 
                                INTEGER_TO_STRING(c_pos) & "] 0x" & 
                                HEX_TO_STRING(elem_i)    & " /= 0x" &
                                HEX_TO_STRING(signals.ELEM(y_pos, x_pos, d_pos, c_pos)));
            end if;
        end loop;
        end loop;
        end loop;
        end loop;
        if (PARAM.DATA.ATRB_FIELD.Y.SIZE > 0) then
            for y_pos in PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.HI loop
                atrb_i := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(
                                  PARAM  => PARAM,
                                  Y      => y_pos,
                                  DATA   => DATA_I
                              );
                if (MATCH_STD_LOGIC(signals.ATRB.Y(y_pos), atrb_i) = FALSE) then
                    REPORT_MISMATCH(core, "ATRB.Y[" &
                                    INTEGER_TO_STRING(y_pos) & "] 0x" &
                                    HEX_TO_STRING(atrb_i)    & " /= 0x" &
                                    HEX_TO_STRING(signals.ATRB.Y(y_pos)));
                end if;
            end loop;
        end if;
        if (PARAM.DATA.ATRB_FIELD.X.SIZE > 0) then
            for x_pos in PARAM.SHAPE.X.LO to PARAM.SHAPE.X.HI loop
                atrb_i := GET_ATRB_X_FROM_IMAGE_STREAM_DATA(
                                  PARAM  => PARAM,
                                  X      => x_pos,
                                  DATA   => DATA_I
                              );
                if (MATCH_STD_LOGIC(signals.ATRB.X(x_pos), atrb_i) = FALSE) then
                    REPORT_MISMATCH(core, "ATRB.X[" &
                                    INTEGER_TO_STRING(x_pos) & "] 0x" &
                                    HEX_TO_STRING(atrb_i)    & " /= 0x" &
                                    HEX_TO_STRING(signals.ATRB.X(x_pos)));
                end if;
            end loop;
        end if;
        if (PARAM.DATA.ATRB_FIELD.D.SIZE > 0) then
            for d_pos in PARAM.SHAPE.D.LO to PARAM.SHAPE.D.HI loop
                atrb_i := GET_ATRB_D_FROM_IMAGE_STREAM_DATA(
                                  PARAM  => PARAM,
                                  D      => d_pos,
                                  DATA   => DATA_I
                              );
                if (MATCH_STD_LOGIC(signals.ATRB.D(d_pos) , atrb_i) = FALSE) then
                    REPORT_MISMATCH(core, "ATRB.D[" &
                                    INTEGER_TO_STRING(d_pos) & "] 0x" &
                                    HEX_TO_STRING(atrb_i)    & " /= 0x" &
                                    HEX_TO_STRING(signals.ATRB.D(d_pos)));
                end if;
            end loop;
        end if;
        if (PARAM.DATA.ATRB_FIELD.C.SIZE > 0) then
            for c_pos in PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI loop
                atrb_i := GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                                  PARAM  => PARAM,
                                  C      => c_pos,
                                  DATA   => DATA_I
                              );
                if (MATCH_STD_LOGIC(signals.ATRB.C(c_pos) , atrb_i) = FALSE) then
                    REPORT_MISMATCH(core, "ATRB.C[" &
                                    INTEGER_TO_STRING(c_pos) & "] 0x" &
                                    HEX_TO_STRING(atrb_i)    & " /= 0x" &
                                    HEX_TO_STRING(signals.ATRB.C(c_pos)));
                end if;
            end loop;
        end if;
        if (PARAM.INFO_BITS > 0) then
            if (MATCH_STD_LOGIC(signals.INFO, DATA_I(PARAM.DATA.INFO_FIELD.HI downto PARAM.DATA.INFO_FIELD.LO)) = FALSE) then
                REPORT_MISMATCH(core, "INFO 0x" &
                                HEX_TO_STRING(DATA_I(PARAM.DATA.INFO_FIELD.HI downto PARAM.DATA.INFO_FIELD.LO)) & " /= 0x" &
                                HEX_TO_STRING(signals.INFO));
            end if;
        end if;
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
    constant  KEY_DATA      : KEYWORD_TYPE := "DATA  ";
    constant  KEY_ELEM      : KEYWORD_TYPE := "ELEM  ";
    constant  KEY_ATRB      : KEYWORD_TYPE := "ATRB  ";
    constant  KEY_C         : KEYWORD_TYPE := "C     ";
    constant  KEY_D         : KEYWORD_TYPE := "D     ";
    constant  KEY_X         : KEYWORD_TYPE := "X     ";
    constant  KEY_Y         : KEYWORD_TYPE := "Y     ";
    constant  KEY_INFO      : KEYWORD_TYPE := "INFO  ";
    constant  KEY_VALID     : KEYWORD_TYPE := "VALID ";
    constant  KEY_READY     : KEYWORD_TYPE := "READY ";
begin 
    -------------------------------------------------------------------------------
    -- メインプロセス
    -------------------------------------------------------------------------------
    process
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        type      SEQ_POS_VECTOR is array(integer range <>) of integer;
        type      SEQ_PARAM_TYPE is record
                      LO_POS    : SEQ_POS_VECTOR(0 to 4);
                      Y         : integer;
                      X         : integer;
                      D         : integer;
                      C         : integer;
                      MAX       : integer;
        end record;
        function  NEW_SEQ_PARAM return  SEQ_PARAM_TYPE is
            variable  seq_param : SEQ_PARAM_TYPE;
            variable  seq_level : integer;
        begin
            seq_level := 0;
            if (PARAM.SHAPE.Y.ELEM_IN_DATA = TRUE) then
                seq_level   := seq_level + 1;
                seq_param.Y := seq_level;
            end if;
            if (PARAM.SHAPE.X.ELEM_IN_DATA = TRUE) then
                seq_level   := seq_level + 1;
                seq_param.X := seq_level;
            end if;
            if (PARAM.SHAPE.D.ELEM_IN_DATA = TRUE) then
                seq_level   := seq_level + 1;
                seq_param.D := seq_level;
            end if;
            if (PARAM.SHAPE.C.ELEM_IN_DATA = TRUE) then
                seq_level   := seq_level + 1;
                seq_param.C := seq_level;
            end if;
            seq_param.MAX := seq_level;
            if (PARAM.SHAPE.Y.ELEM_IN_DATA = FALSE) then
                seq_level   := seq_level + 1;
                seq_param.Y := seq_level;
            end if;
            if (PARAM.SHAPE.X.ELEM_IN_DATA = FALSE) then
                seq_level   := seq_level + 1;
                seq_param.X := seq_level;
            end if;
            if (PARAM.SHAPE.D.ELEM_IN_DATA = FALSE) then
                seq_level   := seq_level + 1;
                seq_param.D := seq_level;
            end if;
            if (PARAM.SHAPE.C.ELEM_IN_DATA = FALSE) then
                seq_level   := seq_level + 1;
                seq_param.C := seq_level;
            end if;
            seq_param.LO_POS(0) := 0;
            seq_param.LO_POS(seq_param.Y) := PARAM.SHAPE.Y.LO;
            seq_param.LO_POS(seq_param.X) := PARAM.SHAPE.X.LO;
            seq_param.LO_POS(seq_param.D) := PARAM.SHAPE.D.LO;
            seq_param.LO_POS(seq_param.C) := PARAM.SHAPE.C.LO;
            return seq_param;
        end function;
        constant  SEQ_PARAM     : SEQ_PARAM_TYPE := NEW_SEQ_PARAM;
        ---------------------------------------------------------------------------
        -- 各種変数の定義.
        ---------------------------------------------------------------------------
        file      stream        : TEXT;
        variable  core          : CORE_TYPE;
        variable  keyword       : KEYWORD_TYPE;
        variable  operation     : OPERATION_TYPE;
        variable  out_signals   : IMAGE_STREAM_SIGNAL_TYPE;
        variable  chk_signals   : IMAGE_STREAM_SIGNAL_TYPE;
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
        --! @brief IMAGE_STREAM_SIGNAL 構造体の ELEM の値を読み取るサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure read_image_stream_elem(
                      proc_name     : in    string;
                      signals       : inout IMAGE_STREAM_SIGNAL_TYPE
        ) is
            variable  next_event    :       EVENT_TYPE;
            variable  seq_pos       :       SEQ_POS_VECTOR(0 to 4);
            variable  seq_level     :       integer;
        begin
            seq_level     := 0;
            seq_pos       := SEQ_PARAM.LO_POS;
            SEQ_LOOP: loop
                SEEK_EVENT(core, stream, next_event);
                case next_event is
                    when EVENT_SEQ_BEGIN => 
                        READ_EVENT(core, stream, EVENT_SEQ_BEGIN);
                        if (seq_level >= SEQ_PARAM.MAX) then
                            READ_ERROR(core, proc_name, "READ_ELEM Out of Level(" & INTEGER_TO_STRING(seq_level) & ")");
                        else
                            seq_level := seq_level + 1;
                            seq_pos(seq_level) := SEQ_PARAM.LO_POS(seq_level);
                        end if;
                    when EVENT_SEQ_END   =>
                        READ_EVENT(core, stream, EVENT_SEQ_END  );
                        if (seq_level > 0) then
                            seq_level := seq_level - 1;
                            seq_pos(seq_level) := seq_pos(seq_level) + 1;
                        end if;
                    when EVENT_SCALAR    =>
                        if    (seq_level /= SEQ_PARAM.MAX) then
                            READ_ERROR(core, proc_name, "READ_ELEM less level(" & INTEGER_TO_STRING(seq_level) &
                                                              ") /= max_level(" & INTEGER_TO_STRING(SEQ_PARAM.MAX) & ")");
                        elsif (seq_pos(SEQ_PARAM.Y) < PARAM.SHAPE.Y.LO or seq_pos(SEQ_PARAM.Y) > PARAM.SHAPE.Y.HI) then
                            READ_ERROR(core, proc_name, "READ_ELEM Out of Y Range(" & INTEGER_TO_STRING(seq_pos(SEQ_PARAM.Y)) & ")");
                        elsif (seq_pos(SEQ_PARAM.X) < PARAM.SHAPE.X.LO or seq_pos(SEQ_PARAM.X) > PARAM.SHAPE.X.HI) then
                            READ_ERROR(core, proc_name, "READ_ELEM Out of X Range(" & INTEGER_TO_STRING(seq_pos(SEQ_PARAM.X)) & ")");
                        elsif (seq_pos(SEQ_PARAM.D) < PARAM.SHAPE.D.LO or seq_pos(SEQ_PARAM.D) > PARAM.SHAPE.D.HI) then
                            READ_ERROR(core, proc_name, "READ_ELEM Out of D Range(" & INTEGER_TO_STRING(seq_pos(SEQ_PARAM.D)) & ")");
                        elsif (seq_pos(SEQ_PARAM.C) < PARAM.SHAPE.C.LO or seq_pos(SEQ_PARAM.C) > PARAM.SHAPE.C.HI) then
                            READ_ERROR(core, proc_name, "READ_ELEM Out of C Range(" & INTEGER_TO_STRING(seq_pos(SEQ_PARAM.C)) & ")");
                        else
                            read_value(proc_name, signals.ELEM(seq_pos(SEQ_PARAM.Y), seq_pos(SEQ_PARAM.X), seq_pos(SEQ_PARAM.D), seq_pos(SEQ_PARAM.C)));
                            SET_ELEMENT_TO_IMAGE_STREAM_DATA(
                                PARAM   => PARAM,
                                C       => seq_pos(SEQ_PARAM.C),
                                D       => seq_pos(SEQ_PARAM.D),
                                X       => seq_pos(SEQ_PARAM.X),
                                Y       => seq_pos(SEQ_PARAM.Y),
                                ELEMENT => signals.ELEM(seq_pos(SEQ_PARAM.Y), seq_pos(SEQ_PARAM.X), seq_pos(SEQ_PARAM.D), seq_pos(SEQ_PARAM.C)),
                                DATA    => signals.DATA
                            );
                            -- REPORT_NOTE(core, string'(  "seq_pos(y)=") & INTEGER_TO_STRING(seq_pos(seq_y_level)) &
                            --                            ",seq_pos(x)="  & INTEGER_TO_STRING(seq_pos(seq_x_level)) &
                            --                            ",seq_pos(d)="  & INTEGER_TO_STRING(seq_pos(seq_d_level)) &
                            --                            ",seq_pos(c)="  & INTEGER_TO_STRING(seq_pos(seq_c_level)) &
                            --                            ",elem="        & HEX_TO_STRING(signals.ELEM(seq_pos(seq_y_level),
                            --                                                                         seq_pos(seq_x_level),
                            --                                                                         seq_pos(seq_d_level),
                            --                                                                         seq_pos(seq_c_level))) & 
                            --                            ",data="        & HEX_TO_STRING(signals.DATA));
                        end if;
                        seq_pos(SEQ_PARAM.MAX) := seq_pos(SEQ_PARAM.MAX) + 1;
                    when EVENT_ERROR     =>
                        READ_ERROR(core, proc_name, "SEEK_EVENT NG");
                    when others          =>
                        SKIP_EVENT(core, stream, next_event);
                        -- ERROR
                end case;
                exit when (seq_level <= 0);
            end loop;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief IMAGE_STREAM_SIGNAL 構造体の ATRB.C の値を読み取るサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        --! @param    pos         ATRB.C のインデックス
        --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure read_image_stream_atrb_c_value(
                      proc_name     : in    string;
                      pos           : in    integer;
                      signals       : inout IMAGE_STREAM_SIGNAL_TYPE
        ) is
        begin 
            if (pos < PARAM.SHAPE.C.LO or pos > PARAM.SHAPE.C.HI) then
                READ_ERROR(core, proc_name, "READ_ATRB.C Out of Range(" & INTEGER_TO_STRING(pos) & ")");
            else
                read_value(proc_name, signals.ATRB.C(pos));
                SET_ATRB_C_TO_IMAGE_STREAM_DATA(PARAM, pos, signals.ATRB.C(pos), signals.DATA);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief IMAGE_STREAM_SIGNAL 構造体の ATRB.D の値を読み取るサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        --! @param    pos         ATRB.C のインデックス
        --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure read_image_stream_atrb_d_value(
                      proc_name     : in    string;
                      pos           : in    integer;
                      signals       : inout IMAGE_STREAM_SIGNAL_TYPE
        ) is
        begin 
            if (pos < PARAM.SHAPE.D.LO or pos > PARAM.SHAPE.D.HI) then
                READ_ERROR(core, proc_name, "READ_ATRB.D Out of Range(" & INTEGER_TO_STRING(pos) & ")");
            else
                read_value(proc_name, signals.ATRB.D(pos));
                SET_ATRB_D_TO_IMAGE_STREAM_DATA(PARAM, pos, signals.ATRB.D(pos), signals.DATA);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief IMAGE_STREAM_SIGNAL 構造体の ATRB.X の値を読み取るサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        --! @param    pos         ATRB.X のインデックス
        --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure read_image_stream_atrb_x_value(
                      proc_name     : in    string;
                      pos           : in    integer;
                      signals       : inout IMAGE_STREAM_SIGNAL_TYPE
        ) is
        begin 
            if (pos < PARAM.SHAPE.X.LO or pos > PARAM.SHAPE.X.HI) then
                READ_ERROR(core, proc_name, "READ_ATRB.X Out of Range(" & INTEGER_TO_STRING(pos) & ")");
            else
                read_value(proc_name, signals.ATRB.X(pos));
                SET_ATRB_X_TO_IMAGE_STREAM_DATA(PARAM, pos, signals.ATRB.X(pos), signals.DATA);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief IMAGE_STREAM_SIGNAL 構造体の ATRB.Y の値を読み取るサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        --! @param    pos         ATRB.Y のインデックス
        --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure read_image_stream_atrb_y_value(
                      proc_name     : in    string;
                      pos           : in    integer;
                      signals       : inout IMAGE_STREAM_SIGNAL_TYPE
        ) is
        begin 
            if (pos < PARAM.SHAPE.Y.LO or pos > PARAM.SHAPE.Y.HI) then
                READ_ERROR(core, proc_name, "READ_ATRB.Y Out of Range(" & INTEGER_TO_STRING(pos) & ")");
            else
                read_value(proc_name, signals.ATRB.Y(pos));
                SET_ATRB_Y_TO_IMAGE_STREAM_DATA(PARAM, pos, signals.ATRB.Y(pos), signals.DATA);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief IMAGE_STREAM_SIGNAL 構造体の ATRB.[CXY] 配列を読み取るサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure read_image_stream_atrb_vector(
                      proc_name     : in    string;
                      key_word      : in    KEYWORD_TYPE;
                      signals       : inout IMAGE_STREAM_SIGNAL_TYPE
        ) is
            variable  next_event    :       EVENT_TYPE;
            variable  seq_pos       :       integer;
            variable  seq_level     :       integer;
        begin
            case key_word is
                when KEY_C  => seq_pos := PARAM.SHAPE.C.LO;
                when KEY_D  => seq_pos := PARAM.SHAPE.D.LO;
                when KEY_X  => seq_pos := PARAM.SHAPE.X.LO;
                when KEY_Y  => seq_pos := PARAM.SHAPE.Y.LO;
                when others => seq_pos := 0;
            end case;
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
                    when EVENT_SCALAR    =>
                        case key_word is
                            when KEY_C  => read_image_stream_atrb_c_value(proc_name, seq_pos, signals);
                            when KEY_D  => read_image_stream_atrb_d_value(proc_name, seq_pos, signals);
                            when KEY_X  => read_image_stream_atrb_x_value(proc_name, seq_pos, signals);
                            when KEY_Y  => read_image_stream_atrb_y_value(proc_name, seq_pos, signals);
                            when others => null;
                        end case;
                        seq_pos := seq_pos + 1;
                    when EVENT_ERROR     =>
                        READ_ERROR(core, proc_name, "SEEK_EVENT NG");
                    when others          =>
                        SKIP_EVENT(core, stream, next_event);
                        -- ERROR
                end case;
                exit when (seq_level <= 0);
            end loop;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief IMAGE_STREAM_SIGNAL 構造体の ATRB の値を読み取るサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure read_image_stream_atrb(
                      proc_name     : in    string;
                      signals       : inout IMAGE_STREAM_SIGNAL_TYPE
        ) is
            variable  next_event    :       EVENT_TYPE;
            variable  key_word      :       KEYWORD_TYPE;
        begin
            SEEK_EVENT(core, stream, next_event);
            if (next_event /= EVENT_MAP_BEGIN) then
                READ_ERROR(core, proc_name, "READ_ATRB Not Sequece");
            end if;
            READ_EVENT(core, stream, EVENT_MAP_BEGIN);
            MAP_LOOP: loop
                SEEK_EVENT(core, stream, next_event);
                case next_event is
                    when EVENT_SCALAR  =>
                        READ_EVENT(core, stream, EVENT_SCALAR);
                        COPY_KEY_WORD(core, key_word);
                        case key_word is
                            when KEY_C  => read_image_stream_atrb_vector(proc_name, KEY_C, signals);
                            when KEY_D  => read_image_stream_atrb_vector(proc_name, KEY_D, signals);
                            when KEY_X  => read_image_stream_atrb_vector(proc_name, KEY_X, signals);
                            when KEY_Y  => read_image_stream_atrb_vector(proc_name, KEY_Y, signals);
                            when others => READ_ERROR(core, proc_name, "READ_ATRB Undefined Map Operation " & key_word);
                                           exit MAP_LOOP;
                        end case;
                    when EVENT_MAP_END  => READ_EVENT(core, stream, EVENT_MAP_END);
                                           exit MAP_LOOP;
                    when others         => READ_ERROR(core, proc_name, "READ_ATRB Illega Map Item");
                                           exit MAP_LOOP;
                end case;
            end loop;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief IMAGE_STREAM_SIGNAL 構造体の DATA の値を読み取るサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure read_image_stream_data(
                      proc_name     : in    string;
                      signals       : inout IMAGE_STREAM_SIGNAL_TYPE
        ) is
        begin
            read_value(proc_name, signals.DATA);
            for y_pos in PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.HI loop
            for x_pos in PARAM.SHAPE.X.LO to PARAM.SHAPE.X.HI loop
            for d_pos in PARAM.SHAPE.D.LO to PARAM.SHAPE.D.HI loop -- D Channel は要素に含まれていない
            for c_pos in PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI loop
                signals.ELEM(y_pos, x_pos, d_pos, c_pos) := GET_ELEMENT_FROM_IMAGE_STREAM_DATA(
                                                                PARAM  => PARAM,
                                                                C      => c_pos,
                                                                D      => d_pos,
                                                                X      => x_pos,
                                                                Y      => y_pos,
                                                                DATA   => signals.DATA
                                                            );
            end loop;
            end loop;
            end loop;
            end loop;
            for y_pos in PARAM.SHAPE.Y.LO to PARAM.SHAPE.Y.HI loop
                signals.ATRB.Y(y_pos) := GET_ATRB_Y_FROM_IMAGE_STREAM_DATA(
                                             PARAM  => PARAM,
                                             Y      => y_pos,
                                             DATA   => signals.DATA
                                         );
            end loop;
            for x_pos in PARAM.SHAPE.X.LO to PARAM.SHAPE.X.HI loop
                signals.ATRB.X(x_pos) := GET_ATRB_X_FROM_IMAGE_STREAM_DATA(
                                             PARAM  => PARAM,
                                             X      => x_pos,
                                             DATA   => signals.DATA
                                         );
            end loop;
            for c_pos in PARAM.SHAPE.C.LO to PARAM.SHAPE.C.HI loop
                signals.ATRB.C(c_pos) := GET_ATRB_C_FROM_IMAGE_STREAM_DATA(
                                             PARAM  => PARAM,
                                             C      => c_pos,
                                             DATA   => signals.DATA
                                         );
            end loop;
            if (PARAM.INFO_BITS > 0) then
                signals.INFO := signals.DATA(PARAM.DATA.INFO_FIELD.HI downto PARAM.DATA.INFO_FIELD.LO);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief IMAGE_STREAM_SIGNAL 構造体の INFO の値を読み取るサブプログラム.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
        --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure read_image_stream_info(
                      proc_name     : in    string;
                      signals       : inout IMAGE_STREAM_SIGNAL_TYPE
        ) is
        begin
            if (PARAM.INFO_BITS > 0) then
                read_value(proc_name, signals.INFO);
                signals.DATA(PARAM.DATA.INFO_FIELD.HI downto PARAM.DATA.INFO_FIELD.LO) := signals.INFO;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオのマップからIMAGE_STREAM_SIGNAL 構造体の値を読み取るサブプログラム.
        --!      * このサブプログラムを呼ぶときは、すでにMAP_READ_BEGINを実行済みに
        --!        しておかなければならない。
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    signals     読み取った値が入るレコード変数. inoutであることに注意.
        --! @param    event       次のイベント. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure map_read_image_stream_signals(
                      signals       : inout IMAGE_STREAM_SIGNAL_TYPE;
                      event         : inout EVENT_TYPE
        ) is
            constant  proc_name     :       string := "MAP_READ_IMAGE_STREAM_SIGNALS";
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
                            when KEY_ELEM  =>
                                read_image_stream_elem(proc_name, signals);
                            when KEY_ATRB =>
                                read_image_stream_atrb(proc_name, signals);
                            when KEY_INFO =>
                                read_image_stream_info(proc_name, signals);
                            when KEY_DATA  =>
                                read_image_stream_data(proc_name, signals);
                            when KEY_VALID =>
                                read_value(proc_name, signals.VALID);
                            when KEY_READY =>
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
                    chk_signals := IMAGE_STREAM_SIGNAL_DONTCARE;
                    gpi_signals := (others => '-');
                    MAP_READ_LOOP: loop
                        MAP_READ_PREPARE_FOR_NEXT(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        map_read_image_stream_signals(
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
                    match_image_stream_signals(core, chk_signals, match);
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
            variable  img_match      : boolean;
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
                            wait until (CLK'event and CLK = '1');
                        end loop;
                    end if;
                    wait_count := 0;
                when EVENT_MAP_BEGIN =>
                    READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                    chk_signals := IMAGE_STREAM_SIGNAL_DONTCARE;
                    gpi_signals := (others => '-');
                    MAP_READ_LOOP: loop
                        REPORT_DEBUG(core, proc_name, "MAP_READ_LOOP");
                        MAP_READ_PREPARE_FOR_NEXT(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        map_read_image_stream_signals(
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
                            match_image_stream_signals(chk_signals, img_match);
                            gpi_match := MATCH_STD_LOGIC(gpi_signals, GPI);
                            exit when(img_match and gpi_match);
                            if (CLK'event and CLK = '1') then
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
                            wait until (CLK'event and CLK = '1');
                            match_image_stream_signals(chk_signals, img_match);
                            gpi_match := MATCH_STD_LOGIC(gpi_signals, GPI);
                            exit when(img_match and gpi_match);
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
        --! @brief シナリオからDATAの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_data is
            constant proc_name : string := "EXECUTE_DATA";
        begin
            if (MASTER) then
                read_image_stream_data(proc_name, out_signals);
                DATA_O <= out_signals.DATA after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからELEMの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_elem is
            constant proc_name : string := "EXECUTE_ELEM";
        begin
            if (MASTER) then
                read_image_stream_elem(proc_name, out_signals);
                DATA_O <= out_signals.DATA after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからATRBの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_atrb is
            constant proc_name : string := "EXECUTE_ATRB";
        begin
            if (MASTER) then
                read_image_stream_atrb(proc_name, out_signals);
                DATA_O <= out_signals.DATA after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからINFOの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_info is
            constant proc_name : string := "EXECUTE_INFO";
        begin
            if (MASTER) then
                read_image_stream_info(proc_name, out_signals);
                DATA_O <= out_signals.DATA after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからVALIDの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_valid is
            constant proc_name : string := "EXECUTE_VALID";
        begin
            if (MASTER) then
                read_value(proc_name, out_signals.VALID);
                VALID_O <= out_signals.VALID after OUTPUT_DELAY;
            else
                skip_value(proc_name);
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief シナリオからREADYの値を読んで出力するサブプログラム.
        ---------------------------------------------------------------------------
        procedure execute_ready is
            constant proc_name : string := "EXECUTE_READY";
        begin
            if (SLAVE) then
                read_value(proc_name, out_signals.READY);
                READY_O <= out_signals.READY after OUTPUT_DELAY;
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
        out_signals := IMAGE_STREAM_SIGNAL_NULL;
        chk_signals := IMAGE_STREAM_SIGNAL_DONTCARE;
        gpo_signals := (others => 'Z');
        gpi_signals := (others => '-');
        core.debug  := 0;
        ---------------------------------------------------------------------------
        -- 信号の初期化
        ---------------------------------------------------------------------------
        SYNC_REQ      <= (0 =>0, others => -1);
        FINISH        <= '0';
        REPORT_STATUS <= core.report_status;
        if (MASTER) then
            DATA_O  <= (others => '0');
            VALID_O <= '0';
        end if;
        if (SLAVE) then
            READY_O <= '0';
        end if;
        ---------------------------------------------------------------------------
        -- リセット解除待ち
        ---------------------------------------------------------------------------
        wait until(CLK'event and CLK = '1' and RST = '0');
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
                        when KEY_DATA   => execute_data;
                        when KEY_ELEM   => execute_elem;
                        when KEY_ATRB   => execute_atrb;
                        when KEY_INFO   => execute_info;
                        when KEY_VALID  => execute_valid;
                        when KEY_READY  => execute_ready;
                        when KEY_REPORT => EXECUTE_REPORT(core, stream);
                        when KEY_DEBUG  => EXECUTE_DEBUG (core, stream);
                        when KEY_SAY    => EXECUTE_SAY   (core, stream);
                        when KEY_OUT    => EXECUTE_OUT   (core, stream, gpo_signals, GPO);
                        when KEY_SYNC   => execute_sync  (operation);
                        when KEY_WAIT   => execute_wait;
                        when KEY_CHECK  => execute_check;
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
