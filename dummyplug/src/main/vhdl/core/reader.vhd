-----------------------------------------------------------------------------------
--!     @file    reader.vhd
--!     @brief   Package for Dummy Plug Scenario Reader.
--!     @version 1.6.1
--!     @date    2016/1/7
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
use     std.textio.all;
-----------------------------------------------------------------------------------
--! @brief Dummy Plug のシナリオを読み込むためのパッケージ
-----------------------------------------------------------------------------------
package READER is
    -------------------------------------------------------------------------------
    --! @brief イベントのタイプ
    -------------------------------------------------------------------------------
    type      EVENT_TYPE is (
              EVENT_DIRECTIVE      , -- ディレクティブを示すイベント(未サポート).
              EVENT_DOC_BEGIN      , -- ドキュメントの開始を示すイベント.
              EVENT_DOC_END        , -- ドキュメントの終了を示すイベント.
              EVENT_STREAM_END     , -- ストリームの終わりを示すイベント.
              EVENT_SEQ_BEGIN      , -- リスト(Sequence)の開始を示すイベント.
              EVENT_SEQ_NEXT       , -- リスト(Sequence)の続きを示すイベント.
              EVENT_SEQ_END        , -- リスト(Sequence)の終了を示すイベント.
              EVENT_MAP_BEGIN      , -- ハッシュ(Mapping)の開始を示すイベント.
              EVENT_MAP_NEXT       , -- ハッシュ(Mapping)の続きを示すイベント.
              EVENT_MAP_END        , -- ハッシュ(Mapping)の終了を示すイベント.
              EVENT_MAP_SEP        , -- ハッシュ(Mapping)のキーと値を分けるイベント.
              EVENT_SCALAR         , -- スカラーを示すノード.
              EVENT_TAG_PROP       , -- タグプロパティ.
              EVENT_ANCHOR         , -- アンカー.
              EVENT_ALIAS          , -- エイリアス.
              EVENT_ERROR            -- ノードの読み込みに失敗したことを示す.
    );
    -------------------------------------------------------------------------------
    --! @brief 処理できる構造(STRUCTURE)の状態の深さの最大値.
    -------------------------------------------------------------------------------
    constant  STRUCT_STATE_DEPTH   : integer := 16;
    -------------------------------------------------------------------------------
    --! @brief 処理中の構造(STRUCTURE)の状態を保持するためのスタックのタイプ.
    -------------------------------------------------------------------------------
    type      STRUCT_STATE_STACK   is array (1 to STRUCT_STATE_DEPTH) of integer;
    -------------------------------------------------------------------------------
    --! @brief 処理中の構造(STRUCTURE)のポインタを示すタイプ.
    -------------------------------------------------------------------------------
    subtype   STRUCT_STATE_PTR     is integer range 1 to STRUCT_STATE_DEPTH;
    -------------------------------------------------------------------------------
    --! @brief リーダーの状態を保持する構造体.
    -------------------------------------------------------------------------------
    type      READER_TYPE is record
        name                : LINE;               -- インスタンス名を保持.
        stream_name         : LINE;               -- ストリーム名を保持.
        text_line           : LINE;               -- 現在処理中の行の内容を保持.
        text_pos            : integer;            -- 現在処理中の文字の位置を保持.
        text_end            : integer;            -- 現在処理中の行の最後の文字位置を保持.
        line_num            : integer;            -- 行番号.
        end_of_file         : boolean;            -- ファイルの終端に達したことを示すフラグ.
        debug_mode          : integer;            -- デバッグモード.
        state_stack         : STRUCT_STATE_STACK; -- 処理中の構造を保持するためのスタック.
        state_top           : STRUCT_STATE_PTR;   -- 現在処理中の構造を示すスタックポインタ.
    end record;
    -------------------------------------------------------------------------------
    --! @brief リーダーの状態を保持する構造体の初期化用定数を生成する関数.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    NAME        リーダーの識別名.
    --! @param    STREAM_NAME シナリオファイルの名前を指定する.
    --! @return               生成した定数.
    -------------------------------------------------------------------------------
    function  NEW_READER(NAME: string; STREAM_NAME: string) return READER_TYPE;
    -------------------------------------------------------------------------------
    --! @brief 次に読み取ることのできるイベントまで読み飛ばすサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    NEXT_EVENT  見つかったイベント.
    -------------------------------------------------------------------------------
    procedure SEEK_EVENT(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;       
                  NEXT_EVENT    : out   EVENT_TYPE  
    );
    -------------------------------------------------------------------------------
    --! @brief ストリームからイベントを読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    EVENT       読み取るイベント.
    --! @param    GOOD        正常に読み取れかどうかを示す.
    -------------------------------------------------------------------------------
    procedure READ_EVENT(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  EVENT         : in    EVENT_TYPE;
                  GOOD          : out   boolean
    );
    -------------------------------------------------------------------------------
    --! @brief ストリームからイベントを読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    EVENT       読み取るイベント.
    --! @param    STR         格納された文字列.
    --! @param    STR_LEN     格納した文字列の文字数.
    --! @param    READ_LEN    ストリームから読み取った文字数.
    --! @param    GOOD        正常に読み取れかどうかを示す.
    -------------------------------------------------------------------------------
    procedure READ_EVENT(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  EVENT         : in    EVENT_TYPE;
                  STR           : out   string;
                  STR_LEN       : out   integer;
                  READ_LEN      : out   integer;
                  GOOD          : out   boolean
    );
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_SCALAR,EVENT_TAG_PROP,EVENT_ANCHOR,EVENT_ALIASを
    --!        文字列として取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    STR         格納された文字列.
    --! @param    STR_LEN     格納した文字列の文字数.
    --! @param    READ_LEN    ストリームから読み取った文字数.
    --! @param    GOOD        正常に読み取れかどうかを示す.
    -------------------------------------------------------------------------------
    procedure READ_STRING(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  STR           : out   string;
                  STR_LEN       : out   integer;
                  READ_LEN      : out   integer;
                  GOOD          : out   boolean
    );
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_SCALARを整数(INTEGER)として取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    VALUE       読み取った整数の値.
    --! @param    GOOD        正常に読み取れかどうかを示す.
    -------------------------------------------------------------------------------
    procedure READ_INTEGER(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  VALUE         : out   integer;
                  GOOD          : out   boolean
    );
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_SCALARを真偽値(BOOLEAN)として取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    VALUE       読み取った真偽値の値.
    --! @param    GOOD        正常に読み取れかどうかを示す.
    -------------------------------------------------------------------------------
    procedure READ_BOOLEAN(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  VALUE         : out   boolean;
                  GOOD          : out   boolean
    );
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENTを読み飛ばすサブプログラム.
    --!        EVENTがMAP_BEGINやSEQ_BEGINの場合は、対応するMAP_ENDまたはSEQ_ENDまで
    --!        読み飛ばすことに注意.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    EVENT       読み飛ばすイベント.
    --! @param    GOOD        正常に読み取れかどうかを示す.
    -------------------------------------------------------------------------------
    procedure SKIP_EVENT(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  EVENT         : in    EVENT_TYPE;
                  GOOD          : out   boolean
    );
    -------------------------------------------------------------------------------
    --! @brief イベントを文字列に変換する関数.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    EVENT       イベント入力.
    --! @return               変換した文字列.
    -------------------------------------------------------------------------------
    function  EVENT_TO_STRING(EVENT: EVENT_TYPE) return string;
    -------------------------------------------------------------------------------
    --! @brief 標準出力にリーダーの状態をダンプするサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    -------------------------------------------------------------------------------
    procedure DEBUG_DUMP (
        variable  SELF          : inout READER_TYPE
    );
    -------------------------------------------------------------------------------
    --! @brief 標準出力にリーダーの状態をダンプするサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    MESSAGE     メッセージ.
    -------------------------------------------------------------------------------
    procedure DEBUG_DUMP (
        variable  SELF          : inout READER_TYPE;
                  MESSAGE       : in    string
    );
    -------------------------------------------------------------------------------
    --! @brief 標準出力にリーダーの状態をダンプするサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    POS         キャレットの位置.
    -------------------------------------------------------------------------------
    procedure DEBUG_DUMP (
        variable  SELF          : inout READER_TYPE;
                  POS           : in    integer
    );
end READER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.UTIL.STRING_TO_INTEGER;
use     DUMMY_PLUG.UTIL.STRING_TO_BOOLEAN;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
-----------------------------------------------------------------------------------
--! @brief Dummy Plug のシナリオを読み込むためのパッケージの本体.
-----------------------------------------------------------------------------------
package body  READER is
    -------------------------------------------------------------------------------
    --! @brief トークンの定義
    -------------------------------------------------------------------------------
    type      TOKEN_TYPE is (
              TOKEN_DOCUMENT_BEGIN    , -- "---"
              TOKEN_DOCUMENT_END      , -- "..."
              TOKEN_SEQ_ENTRY         , -- "-"(#x2D,hyphen) denotes a block sequence entry.
              TOKEN_FLOW_ENTRY        , -- ","(#x2C,comma) ends a flow collection entry.
              TOKEN_FLOW_SEQ_BEGIN    , -- "["(#x5B,left  bracket) starts a flow sequence.
              TOKEN_FLOW_SEQ_END      , -- "]"(#x5D,right bracket) ends   a flow sequence.
              TOKEN_FLOW_MAP_BEGIN    , -- "{"(#x7B,left  brace  ) starts a flow mapping.
              TOKEN_FLOW_MAP_END      , -- "{"(#x7D,right brace  ) ends   a flow sequence.
              TOKEN_SINGLE_QUOTE      , -- "'"(#x27,single quote ) a single quoted flow scala.
              TOKEN_DOUBLE_QUOTE      , -- """(#x22,double quote ) a dobule quoted flow scala.
              TOKEN_LITERAL           , -- "|"(#x7C,vertical bar ) denotes a literal block scala.
              TOKEN_FOLDED            , -- ">"(#x3E,greater than ) denotes a folded  block scala.
              TOKEN_DIRECTIVE         , -- "%"
              TOKEN_TAG_PROPERTY      , -- "!"
              TOKEN_ANCHOR_PROPERTY   , -- "&"
              TOKEN_ALIAS_NODE        , -- "*"
              TOKEN_MAP_EXPLICIT_KEY  , -- "? "
              TOKEN_MAP_SEPARATOR     , -- ": "
              TOKEN_SCALAR            , -- SCALAR
              TOKEN_ERROR             , -- パースエラー
              TOKEN_STREAM_END          -- ストリームの終端を示す.
    );
    -------------------------------------------------------------------------------
    --! @brief STRUCT_STACK の内容
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!     *  READER_TYPEではすべてひっくるめて integer に押し込んでいるが、
    --!        実際はステート、インデント、暗黙のマップキー探索の各状態を持っている.
    -------------------------------------------------------------------------------
    constant  STATE_MAX_SIZE                : integer    := 18;
    constant  INDENT_MAX_SIZE               : integer    := 1024;
    constant  MAPKEY_MAX_SIZE               : integer    :=  4;
    constant  STATE_OFFSET                  : integer    := INDENT_MAX_SIZE;
    constant  MAPKEY_OFFSET                 : integer    := STATE_MAX_SIZE*INDENT_MAX_SIZE;
    subtype   STATE_TYPE                   is integer range 0 to  STATE_MAX_SIZE-1;
    subtype   INDENT_TYPE                  is integer range 0 to INDENT_MAX_SIZE-1;
    subtype   MAPKEY_MODE                  is integer range 0 to MAPKEY_MAX_SIZE-1;
    -------------------------------------------------------------------------------
    --! @brief ステートマシンの状態の定義.
    -------------------------------------------------------------------------------
    constant  STATE_NONE                    : STATE_TYPE :=  0;
    constant  STATE_DOCUMENT                : STATE_TYPE :=  1;
    constant  STATE_BLOCK_SEQ_VAL           : STATE_TYPE :=  2;
    constant  STATE_BLOCK_SEQ_END           : STATE_TYPE :=  3;
    constant  STATE_BLOCK_MAP_IMPLICIT_KEY  : STATE_TYPE :=  4;
    constant  STATE_BLOCK_MAP_IMPLICIT_SEP  : STATE_TYPE :=  5;
    constant  STATE_BLOCK_MAP_IMPLICIT_VAL  : STATE_TYPE :=  6;
    constant  STATE_BLOCK_MAP_IMPLICIT_END  : STATE_TYPE :=  7;
    constant  STATE_BLOCK_MAP_EXPLICIT_KEY  : STATE_TYPE :=  8;
    constant  STATE_BLOCK_MAP_EXPLICIT_SEP  : STATE_TYPE :=  9;
    constant  STATE_BLOCK_MAP_EXPLICIT_VAL  : STATE_TYPE := 10;
    constant  STATE_BLOCK_MAP_EXPLICIT_END  : STATE_TYPE := 11;
    constant  STATE_FLOW_SEQ_VAL            : STATE_TYPE := 12;
    constant  STATE_FLOW_SEQ_END            : STATE_TYPE := 13;
    constant  STATE_FLOW_MAP_KEY            : STATE_TYPE := 14;
    constant  STATE_FLOW_MAP_SEP            : STATE_TYPE := 15;
    constant  STATE_FLOW_MAP_VAL            : STATE_TYPE := 16;
    constant  STATE_FLOW_MAP_END            : STATE_TYPE := 17;
    -------------------------------------------------------------------------------
    --! @brief 暗黙のマップキー探索時の状態の定義.
    -------------------------------------------------------------------------------
    constant  MAPKEY_NULL                   : MAPKEY_MODE := 0;
    constant  MAPKEY_FOUND                  : MAPKEY_MODE := 1;
    constant  MAPKEY_READ                   : MAPKEY_MODE := 2;
    -------------------------------------------------------------------------------
    --! @brief 構造の状態を整数に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VALUE       変換された整数値.
    --! @param    STATE       変換する構造の状態.
    --! @param    INDENT      変換するインデントの状態.
    --! @param    MAPKEY      変換する暗黙のマップキー探索状態.
    -------------------------------------------------------------------------------
    procedure pack_struct_state_value(
        variable  VALUE         : out   integer    ;
                  STATE         : in    STATE_TYPE ;
                  INDENT        : in    INDENT_TYPE;
                  MAPKEY        : in    MAPKEY_MODE 
    ) is
    begin 
        VALUE := (MAPKEY * MAPKEY_OFFSET)
               + (STATE  * STATE_OFFSET )
               + (INDENT                );
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 整数から構造の状態に変換.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VALUE       変換する整数値.
    --! @param    STATE       変換された構造の状態.
    --! @param    INDENT      変換されたインデントの状態.
    --! @param    MAPKEY      変換された暗黙のマップキー探索状態.
    -------------------------------------------------------------------------------
    procedure unpack_struct_state_value(
                  VALUE         : in    integer    ;
                  STATE         : out   STATE_TYPE ;
                  INDENT        : out   INDENT_TYPE;
                  MAPKEY        : out   MAPKEY_MODE 
    ) is
    begin 
        MAPKEY := (VALUE / MAPKEY_OFFSET) mod MAPKEY_MAX_SIZE;
        STATE  := (VALUE / STATE_OFFSET ) mod STATE_MAX_SIZE;
        INDENT := (VALUE                ) mod INDENT_MAX_SIZE;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 構造の状態の初期化.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    -------------------------------------------------------------------------------
    procedure init_struct_state(
        variable  SELF          : inout READER_TYPE
    ) is
        variable  value         :       integer;
    begin
        pack_struct_state_value(value, STATE_NONE, 0, MAPKEY_NULL);
        SELF.state_top   := SELF.state_stack'low;
        SELF.state_stack := (others => value);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 現在の構造の状態を得る.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    CURR_STATE  現在の構造の状態を出力.
    --! @param    CURR_INDENT 現在のインデントを出力.
    --! @param    CURR_MAPKEY 暗黙のマップキー探索状態を出力.
    -------------------------------------------------------------------------------
    procedure get_struct_state(
        variable  SELF          : inout READER_TYPE;
                  CURR_STATE    : out   STATE_TYPE ;
                  CURR_INDENT   : out   INDENT_TYPE;
                  CURR_MAPKEY   : out   MAPKEY_MODE
    ) is
        variable  curr_value    :       integer;
    begin
        curr_value := SELF.state_stack(SELF.state_top);
        unpack_struct_state_value(curr_value, CURR_STATE, CURR_INDENT, CURR_MAPKEY);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 現在の構造の状態を得る.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    CURR_STATE  現在の構造の状態を出力.
    --! @param    CURR_INDENT 現在のインデントを出力.
    -------------------------------------------------------------------------------
    procedure get_struct_state(
        variable  SELF          : inout READER_TYPE;
                  CURR_STATE    : out   STATE_TYPE ;
                  CURR_INDENT   : out   INDENT_TYPE
    ) is
        variable  curr_mapkey   :       MAPKEY_MODE;
    begin
        get_struct_state(SELF, CURR_STATE, CURR_INDENT, curr_mapkey);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 現在の構造の状態を得る.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    CURR_STATE  現在の構造の状態を出力.
    -------------------------------------------------------------------------------
    procedure get_struct_state(
        variable  SELF          : inout READER_TYPE;
                  CURR_STATE    : out   STATE_TYPE
    ) is
        variable  curr_indent   :       INDENT_TYPE;
        variable  curr_mapkey   :       MAPKEY_MODE;
    begin
        get_struct_state(SELF, CURR_STATE, curr_indent, curr_mapkey);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 現在の構造の状態を変更する(indent/mapkeyの変更も行う).
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    NEW_STATE   新しい構造の状態.
    --! @param    NEW_INDENT  新しいインデント状態.
    --! @param    NEW_MAPKEY  新しい暗黙のマップキー探索状態.
    -------------------------------------------------------------------------------
    procedure set_struct_state(
        variable  SELF          : inout READER_TYPE;
                  NEW_STATE     : in    STATE_TYPE ;
                  NEW_INDENT    : in    INDENT_TYPE;
                  NEW_MAPKEY    : in    MAPKEY_MODE
    ) is
        variable  new_value     :       integer;
    begin
        pack_struct_state_value(new_value, NEW_STATE, NEW_INDENT, NEW_MAPKEY);
        SELF.state_stack(SELF.state_top) := new_value;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 現在の構造の状態を変更する(indentの変更も行う).
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    NEW_STATE   新しい構造の状態.
    --! @param    NEW_INDENT  新しいインデント状態.
    -------------------------------------------------------------------------------
    procedure set_struct_state(
        variable  SELF          : inout READER_TYPE;
                  NEW_STATE     : in    STATE_TYPE ;
                  NEW_INDENT    : in    INDENT_TYPE
    ) is
        variable  curr_state    :       STATE_TYPE ;
        variable  curr_indent   :       INDENT_TYPE;
        variable  curr_mapkey   :       MAPKEY_MODE;
    begin
        get_struct_state(SELF, curr_state, curr_indent, curr_mapkey);
        set_struct_state(SELF,  NEW_STATE,  NEW_indent, curr_mapkey);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 現在の構造の状態を変更する(indentの変更は行わない).
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    NEW_STATE   新しい構造の状態.
    -------------------------------------------------------------------------------
    procedure set_struct_state(
        variable  SELF          : inout READER_TYPE;
                  NEW_STATE     : in    STATE_TYPE
    ) is
        variable  curr_state    :       STATE_TYPE ;
        variable  curr_indent   :       INDENT_TYPE;
        variable  curr_mapkey   :       MAPKEY_MODE;
    begin
        get_struct_state(SELF, curr_state, curr_indent, curr_mapkey);
        set_struct_state(SELF,  NEW_STATE, curr_indent, curr_mapkey);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 現在の構造の状態を保存してから状態を変更する.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    RET_STATE   新しい状態から戻ったときの状態.
    --! @param    RET_INDENT  新しい状態から戻ったときのインデント状態.
    --! @param    RET_MAPKEY  新しい状態から戻ったときの暗黙のマップキー探索状態.
    --! @param    NEW_STATE   新しい構造の状態.
    --! @param    NEW_INDENT  新しいインデント状態.
    --! @param    NEW_MAPKEY  新しい暗黙のマップキー探索状態.
    --! @param    GOOD        スタックに保存できたことを示す変数.
    -------------------------------------------------------------------------------
    procedure call_struct_state(
        variable  SELF          : inout READER_TYPE;
                  RET_STATE     : in    STATE_TYPE ;
                  RET_INDENT    : in    INDENT_TYPE;
                  RET_MAPKEY    : in    MAPKEY_MODE;
                  NEW_STATE     : in    STATE_TYPE ;
                  NEW_INDENT    : in    INDENT_TYPE;
                  NEW_MAPKEY    : in    MAPKEY_MODE;
                  GOOD          : out   boolean     
    ) is
    begin
        if (SELF.state_top < SELF.state_stack'high) then
            set_struct_state(SELF, RET_STATE, RET_INDENT, RET_MAPKEY);
            SELF.state_top := SELF.state_top + 1;
            set_struct_state(SELF, NEW_STATE, NEW_INDENT, NEW_MAPKEY);
            GOOD := TRUE;
        else
            GOOD := FALSE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 現在の構造の状態を保存してから状態を変更する.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    RET_STATE   新しい状態から戻ったときの状態.
    --! @param    RET_INDENT  新しい状態から戻ったときのインデント状態.
    --! @param    NEW_STATE   新しい構造の状態.
    --! @param    NEW_INDENT  新しいインデント状態.
    --! @param    GOOD        スタックに保存できたことを示す変数.
    -------------------------------------------------------------------------------
    procedure call_struct_state(
        variable  SELF          : inout READER_TYPE;
                  RET_STATE     : in    STATE_TYPE ;
                  RET_INDENT    : in    INDENT_TYPE;
                  NEW_STATE     : in    STATE_TYPE ;
                  NEW_INDENT    : in    INDENT_TYPE;
                  GOOD          : out   boolean
    ) is
    begin
        if (SELF.state_top < SELF.state_stack'high) then
            set_struct_state(SELF, RET_STATE, RET_INDENT);
            SELF.state_top := SELF.state_top + 1;
            set_struct_state(SELF, NEW_STATE, NEW_INDENT, MAPKEY_NULL);
            GOOD := TRUE;
        else
            GOOD := FALSE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 前の構造の状態を復元する.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    CURR_STATE  復帰時の構造の状態を出力.
    --! @param    CURR_INDENT 復帰時のインデントを出力.
    --! @param    CURR_MAPKEY 復帰時のマップキー探索状態を出力.
    --! @param    GOOD        スタックから取り出せたことを示す変数.
    -------------------------------------------------------------------------------
    procedure return_struct_state(
        variable  SELF          : inout READER_TYPE;
                  CURR_STATE    : out   STATE_TYPE ;
                  CURR_INDENT   : out   INDENT_TYPE;
                  CURR_MAPKEY   : out   MAPKEY_MODE;
                  GOOD          : out   boolean
    ) is
        variable  struct        :       integer;
    begin
        if (SELF.state_top >  SELF.state_stack'low) then
            SELF.state_top := SELF.state_top - 1;
            get_struct_state(SELF, CURR_STATE, CURR_INDENT, CURR_MAPKEY);
            GOOD := TRUE;
        else
            GOOD := FALSE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 前の構造の状態を復元する.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    GOOD        スタックから取り出せたことを示す変数.
    -------------------------------------------------------------------------------
    procedure return_struct_state(
        variable  SELF          : inout READER_TYPE;
                  GOOD          : out   boolean     
    ) is
        variable  struct        :       integer    ;    
        variable  next_state    :       STATE_TYPE ; 
        variable  next_indent   :       INDENT_TYPE;
        variable  next_mapkey   :       INDENT_TYPE;
    begin
        return_struct_state(SELF, next_state, next_indent, next_mapkey, GOOD);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 現在の暗黙のマップキー探索状態を得る.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    CURR_MAPKEY 現在の暗黙のマップキー探索状態.
    -------------------------------------------------------------------------------
    procedure get_map_key_mode(
        variable  SELF          : inout READER_TYPE;
                  CURR_MAPKEY   : out   MAPKEY_MODE 
    ) is
        variable  curr_state    :       STATE_TYPE ;
        variable  curr_indent   :       INDENT_TYPE;
    begin
        get_struct_state(SELF, curr_state, curr_indent, CURR_MAPKEY);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 暗黙のマップキー探索状態を設定する.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    NEW_MAPKEY  設定する暗黙のマップキー探索状態.
    -------------------------------------------------------------------------------
    procedure set_map_key_mode(
        variable  SELF          : inout READER_TYPE;
                  NEW_MAPKEY    : in    MAPKEY_MODE
    ) is
        variable  curr_state    :       STATE_TYPE ;
        variable  curr_indent   :       INDENT_TYPE;
        variable  curr_mapkey   :       MAPKEY_MODE;
    begin
        get_struct_state(SELF, curr_state, curr_indent, curr_mapkey);
        set_struct_state(SELF, curr_state, curr_indent,  NEW_MAPKEY);
    end procedure;
    -------------------------------------------------------------------------------
    -- @brief 文字がワードをスカラーを構成する文字かどうかを判定する関数.
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- 現時点では未使用のためコメントアウト
    -------------------------------------------------------------------------------
    -- function  is_word_char(CHAR : character) return boolean is
    -- begin
    --     case CHAR is
    --         when 'a'|'b'|'c'|'d'|'e'|'f'|'g'|'h'|'i'|'j'|'k'|'l'|'m'|
    --              'n'|'o'|'p'|'q'|'r'|'s'|'t'|'u'|'v'|'w'|'x'|'y'|'z'|
    --              'A'|'B'|'C'|'D'|'E'|'F'|'G'|'H'|'I'|'J'|'K'|'L'|'M'|
    --              'N'|'O'|'P'|'Q'|'R'|'S'|'T'|'U'|'V'|'W'|'X'|'Y'|'Z'|
    --              '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9'|'_'|'-' => return TRUE;
    --         when others =>                                          return FALSE;
    --     end case;
    -- end function;
    -------------------------------------------------------------------------------
    -- @brief 文字が英数字かどうかを判定する関数.
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- 現時点では未使用のためコメントアウト
    -------------------------------------------------------------------------------
    -- function  is_alnum(CHAR : character) return boolean is
    -- begin
    --     case CHAR is
    --         when 'a'|'b'|'c'|'d'|'e'|'f'|'g'|'h'|'i'|'j'|'k'|'l'|'m'|
    --              'n'|'o'|'p'|'q'|'r'|'s'|'t'|'u'|'v'|'w'|'x'|'y'|'z'|
    --              'A'|'B'|'C'|'D'|'E'|'F'|'G'|'H'|'I'|'J'|'K'|'L'|'M'|
    --              'N'|'O'|'P'|'Q'|'R'|'S'|'T'|'U'|'V'|'W'|'X'|'Y'|'Z'|
    --              '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9'|'_' => return TRUE;
    --         when others =>                                      return FALSE;
    --     end case;
    -- end function;
    -------------------------------------------------------------------------------
    -- @brief 文字が数字かどうかを判定する関数
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- 現時点では未使用のためコメントアウト
    -------------------------------------------------------------------------------
    -- function  is_digit(CHAR : character) return boolean is
    -- begin
    --     case CHAR is
    --         when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' => return TRUE;
    --         when others                                  => return FALSE;
    --     end case;
    -- end is_digit;
    -------------------------------------------------------------------------------
    --! @brief 文字が空白かどうかを判定する関数
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CHAR        判定する文字.
    --! @return               判定結果.空白だった場合はTRUE.
    -------------------------------------------------------------------------------
    function  is_space(CHAR : character) return boolean is
    begin
        case CHAR is
            when ' '| '#' | ht  => return TRUE;
            when others         => return FALSE;
        end case;
    end function;
    -------------------------------------------------------------------------------
    --! @brief ストリームから１行読んでテキストラインにセットするサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    -------------------------------------------------------------------------------
    procedure read_text_line(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT
    ) is
    begin
        if (EndFile(STREAM)) then
            SELF.end_of_file := TRUE;
        else
            READLINE(STREAM, SELF.text_line);
            SELF.text_pos    := SELF.text_line'low;
            SELF.text_end    := SELF.text_line'high;
            SELF.line_num    := SELF.line_num + 1;
            SELF.end_of_file := FALSE;
            set_map_key_mode(SELF, MAPKEY_NULL);
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *指定された位置の* 文字を得るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    POS         スキャンする位置.
    --! @param    CHAR        ポインタが示している文字を出力.
    --! @param    GOOD        ポインタがまだ行内にあることを示す.
    -------------------------------------------------------------------------------
    procedure scan_char(
        variable  SELF          : inout READER_TYPE;
                  POS           : in    integer    ;
                  CHAR          : out   character  ;
                  GOOD          : out   boolean    
    ) is
    begin
        if (SELF.end_of_file = TRUE) or
           (SELF.text_line   = null) or
           (POS     > SELF.text_end) then
            CHAR := nul;
            GOOD := FALSE;
        else
            CHAR := SELF.text_line(POS);
            GOOD := TRUE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *現在の位置の* 文字を得るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    CHAR        ポインタが示している文字を出力.
    --! @param    GOOD        ポインタがまだ行内にあることを示す.
    -------------------------------------------------------------------------------
    procedure scan_char(
        variable  SELF          : inout READER_TYPE;
                  CHAR          : out   character  ;
                  GOOD          : out   boolean    
    ) is
    begin
        scan_char(SELF, SELF.text_pos, CHAR, GOOD);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *指定された位置から* スキャンを開始し、
    --!        空白以外のキャラクタをみつけたら、そのキャラと空白文字の数を返す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    START_POS   スキャンを開始する位置.
    --! @param    FOUND_CHAR  見つかった空白以外のキャラクタ.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_space(
        variable  SELF          : inout READER_TYPE;
                  START_POS     : in    integer;    
                  FOUND_CHAR    : out   character;  
                  FOUND         : out   boolean;    
                  FOUND_LEN     : out   integer;    
                  END_LINE      : out   boolean     
    ) is
        variable  pos           :       integer;    
        variable  len           :       integer;    
        variable  curr_char     :       character;  
    begin
        if (SELF.end_of_file  =  TRUE) or
           (SELF.text_line    =  null) or
           (START_POS > SELF.text_end) then
                FOUND_CHAR := nul;
                FOUND      := FALSE;
                FOUND_LEN  := 0;
                END_LINE   := TRUE;
                return;
        end if;
        pos  := START_POS;
        len  := 0;
        scan_space_loop:  loop
            if (pos > SELF.text_end) then
                FOUND_CHAR := nul;
                FOUND      := FALSE;
                FOUND_LEN  := 0;
                END_LINE   := TRUE;
                return;
            end if;
            curr_char := SELF.text_line(pos);
            if (curr_char = '#') then
                FOUND_CHAR := ' ';
                FOUND      := TRUE;
                FOUND_LEN  := SELF.text_end-START_POS+1;
                END_LINE   := FALSE;
                return;
            end if;
            if (is_space(curr_char) = FALSE) then
                FOUND_CHAR := curr_char;
                FOUND      := (pos > START_POS);
                FOUND_LEN  := len;
                END_LINE   := FALSE;
                return;
            end if;
            pos := pos + 1;
            len := len + 1;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームから空白を読み飛ばすサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * 空白を読み飛ばして最初に見つかった文字を返す.
    --!      * 文字が見つかった場合は FOUND=TRUE を返す.
    --!      * 何も見付からずにストリームの終端に到達した場合はEND_STREAM=TRUEを返す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    FOUND_CHAR  見つかった空白以外の文字.
    --! @param    FOUND       空白以外の文字が見つかったことを示す.
    --! @param    END_STREAM  ストリームが最期に達したことを示す.
    -------------------------------------------------------------------------------
    procedure skip_space(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;       
                  FOUND_CHAR    : out   character;  
                  FOUND         : out   boolean;    
                  END_STREAM    : out   boolean     
    ) is
        variable  curr_char     :       character;  
    begin
        while(SELF.end_of_file = FALSE) loop
            if (SELF.text_line = null) or
               (SELF.text_pos > SELF.text_end) then
                read_text_line(SELF, STREAM);
                exit when(SELF.end_of_file);
            end if;
            for pos in SELF.text_pos to SELF.text_end loop
                curr_char := SELF.text_line(pos);
                exit when (curr_char = '#');
                if (is_space(curr_char) = FALSE) then
                    SELF.text_pos := pos;
                    FOUND_CHAR    := curr_char;
                    FOUND         := TRUE;
                    END_STREAM    := FALSE;
                    return;
                end if;
            end loop;
            SELF.text_pos := SELF.text_end+1;
        end loop;
        FOUND_CHAR := nul;
        FOUND      := FALSE;
        END_STREAM := TRUE;
    end skip_space;
    -------------------------------------------------------------------------------
    --! @brief ストリームから空白を読み飛ばすサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * これは何もステータスを返さない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    -------------------------------------------------------------------------------
    procedure skip_space(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT        
    ) is
        variable  char          :       character;  
        variable  found         :       boolean;    
        variable  stream_end    :       boolean;    
    begin
        skip_space(SELF, STREAM, char, found, stream_end);
    end skip_space;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *指定された位置から* スキャンを開始し、
    --!        '...' または "..." のようなクォートされた文字列をみつけたら
    --!        その文字数(クォート文字含む)を返す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    START_POS   スキャンを開始する位置.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_quoted_string(
        variable  SELF          : inout READER_TYPE;
                  START_POS     : in    integer;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
        variable  quote_char    :       character;
    begin
        if (SELF.end_of_file  =  TRUE) or
           (SELF.text_line    =  null) or
           (START_POS > SELF.text_end) then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := TRUE;
            return;
        end if;
        if    (START_POS+1 > SELF.text_end) then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := FALSE;
            return;
        end if;
        if (SELF.text_line(START_POS) /= ''') and
           (SELF.text_line(START_POS) /= '"') then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := FALSE;
            return;
        end if;
        quote_char := SELF.text_line(START_POS);
        for pos in START_POS+1 to SELF.text_end loop
            if (SELF.text_line(pos) = quote_char) then
                FOUND     := TRUE;
                FOUND_LEN := pos - START_POS + 1;
                END_LINE  := FALSE;
                return;
            end if;
        end loop;
        FOUND     := FALSE;
        FOUND_LEN := 0;
        END_LINE  := FALSE;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *現在の位置から* スキャンを開始し、
    --!        '...' または "..." のようなクォートされた文字列をみつけたら
    --!        その文字数(クォート文字含む)を返す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_quoted_string(
        variable  SELF          : inout READER_TYPE;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
    begin
        scan_quoted_string(SELF, SELF.text_pos, FOUND, FOUND_LEN, END_LINE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *指定された位置から* スキャンを開始し、
    --!        ドキュメント開始を示すキーワード "---" 探す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    START_POS   スキャンを開始する位置.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_doc_begin(
        variable  SELF          : inout READER_TYPE;
                  START_POS     : in    integer;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
    begin
        if (SELF.end_of_file  =  TRUE) or
           (SELF.text_line    =  null) or
           (START_POS  /= SELF.text_line'low) or
           (START_POS+2 > SELF.text_end     ) then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := TRUE;
            return;
        end if;
        if (SELF.text_line(START_POS  ) = '-') and
           (SELF.text_line(START_POS+1) = '-') and
           (SELF.text_line(START_POS+2) = '-') then
            FOUND     := TRUE;
            FOUND_LEN := 3;
            END_LINE  := TRUE;
        else
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := TRUE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *現在の位置から* スキャンを開始し、
    --!        ドキュメント開始を示すキーワード "---" 探す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_doc_begin(
        variable  SELF          : inout READER_TYPE;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
    begin
        scan_doc_begin(SELF, SELF.text_pos, FOUND, FOUND_LEN, END_LINE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *指定された位置から* スキャンを開始し、
    --!        ドキュメント開始を示すキーワード "..." 探す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    START_POS   スキャンを開始する位置.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_doc_end(
        variable  SELF          : inout READER_TYPE;
                  START_POS     : in    integer;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
    begin
        if (SELF.end_of_file  =  TRUE) or
           (SELF.text_line    =  null) or
           (START_POS  /= SELF.text_line'low) or
           (START_POS+2 > SELF.text_end     ) then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := TRUE;
            return;
        end if;
        if (SELF.text_line(START_POS  ) = '.') and
           (SELF.text_line(START_POS+1) = '.') and
           (SELF.text_line(START_POS+2) = '.') then
            FOUND     := TRUE;
            FOUND_LEN := 3;
            END_LINE  := TRUE;
        else
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := TRUE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *現在の地点から* スキャンを開始し、
    --!        ドキュメント終了を示すキーワード "..." 探す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_doc_end(
        variable  SELF          : inout READER_TYPE;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
    begin
        scan_doc_end(SELF, SELF.text_pos, FOUND, FOUND_LEN, END_LINE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *指定された位置から* スキャンを開始し、
    --!        指定されたインジケーターを探す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * インジケーターの後に空白または行末があることに注意.
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    START_POS   スキャンを開始する位置.
    --! @param    INDICATOR   探すインジケーター.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_indicator(
        variable  SELF          : inout READER_TYPE;
                  START_POS     : in    integer;
                  INDICATOR     : in    character;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
        variable  curr_state    :       STATE_TYPE;
    begin
        if    (SELF.end_of_file  =  TRUE) or
              (SELF.text_line    =  null) or
              (START_POS > SELF.text_end) then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := TRUE;
        elsif (SELF.text_line(START_POS) /= INDICATOR) then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := FALSE;
        elsif (START_POS+1 > SELF.text_end) then
            FOUND     := TRUE;
            FOUND_LEN := 1;
            END_LINE  := TRUE;
        elsif (is_space(SELF.text_line(START_POS+1))) then
            FOUND     := TRUE;
            FOUND_LEN := 2;
            END_LINE  := FALSE;
        elsif (INDICATOR = ':') then
            get_struct_state(SELF, curr_state);
            if (curr_state = STATE_FLOW_MAP_KEY or curr_state = STATE_FLOW_MAP_SEP) then
                FOUND     := TRUE;
                FOUND_LEN := 1;
                END_LINE  := FALSE;
            else
                FOUND     := FALSE;
                FOUND_LEN := 0;
                END_LINE  := FALSE;
            end if;
        else
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := FALSE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *現在の位置から* スキャンを開始し、
    --!        指定されたインジケーターを探す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * インジケーターの後に空白または行末があることに注意.
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    INDICATOR   探すインジケーター.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_indicator(
        variable  SELF          : inout READER_TYPE;
                  INDICATOR     : in    character;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
    begin
        scan_indicator(SELF, SELF.text_pos, INDICATOR, FOUND, FOUND_LEN, END_LINE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *指定された位置から* スキャンを開始し、
    --!        指定されたインジケーターを探す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * インジケーターの後に空白または行末があることに注意.
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    START_POS   スキャンを開始する位置.
    --! @param    INDICATOR   探すインジケーター.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_POS   見つかったインジケータの位置.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure find_indicator(
        variable  SELF          : inout READER_TYPE;
                  START_POS     : in    integer;
                  INDICATOR     : in    character;
                  FOUND         : out   boolean;
                  FOUND_POS     : out   integer;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
        variable  pos           :       integer;
        variable  char_found    :       boolean;
        variable  space_len     :       integer;
        variable  sep_len       :       integer;
        variable  found_char    :       character;
        variable  end_of_line   :       boolean;
    begin
        pos := START_POS;
        scan_space    (SELF, pos, found_char, char_found, space_len, end_of_line);
        pos := pos + space_len;
        scan_indicator(SELF, pos, INDICATOR , char_found, sep_len  , end_of_line);
        if (char_found = FALSE) then
            FOUND     := FALSE;
            FOUND_POS := START_POS;
            FOUND_LEN := 0;
            END_LINE  := end_of_line;
        else
            FOUND     := TRUE;
            FOUND_POS := pos;
            FOUND_LEN := sep_len;
            END_LINE  := end_of_line;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    -- @brief テキストラインの *現在の位置から* スキャンを開始し、
    --        指定されたインジケーターを探す.
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --      * インジケーターの後に空白または行末があることに注意.
    --      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    -------------------------------------------------------------------------------
    -- 現時点では未使用のためコメントアウト
    ------------------------------------------------------------------------------
    -- procedure find_indicator(
    --     variable SELF       : inout READER_TYPE;   -- コンテキスト.
    --              INDICATOR  : in    character;     -- 探すインジケーター.
    --              FOUND      : out   boolean;       -- 見つかったことを示す.
    --              FOUND_POS  : out   integer;       -- 見つかったインジケータの場所.
    --              FOUND_LEN  : out   integer;       -- 見つかったインジケータの文字数.
    --              END_LINE   : out   boolean        -- ポインタが行末を越えたことを示す.
    -- ) is
    -- begin 
    --     find_indicator(SELF, SELF.text_pos, INDICATOR, FOUND, FOUND_POS, FOUND_LEN, END_LINE);
    -- end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *指定された位置から* スキャンを開始し、
    --!        TAGを見つけてタグの文字列の位置と長さを返す.
    --!        その文字数(クォート文字含む)を返す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    START_POS   スキャンを開始する位置.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    TAG_POS     タグ文字列の開始位置.
    --! @param    TAG_LEN     タグ文字列の文字数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_tag_prop(
        variable  SELF          : inout READER_TYPE;
                  START_POS     : in    integer;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  TAG_POS       : out   integer;
                  TAG_LEN       : out   integer;
                  END_LINE      : out   boolean 
    ) is
        variable  quote_char    :       character;
    begin
        if (SELF.end_of_file  =  TRUE) or
           (SELF.text_line    =  null) or
           (START_POS > SELF.text_end) then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            TAG_POS   := START_POS;
            TAG_LEN   := 0;
            END_LINE  := TRUE;
            return;
        end if;
        if (START_POS+1 > SELF.text_end) or
           (SELF.text_line(START_POS) /= '!') then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            TAG_POS   := START_POS;
            TAG_LEN   := 0;
            END_LINE  := FALSE;
            return;
        end if;
        if (SELF.text_line(START_POS+1) = '!') then
            FOUND     := TRUE;
            TAG_POS   := START_POS+2;
            for pos in START_POS+2 to SELF.text_end loop
                if (is_space(SELF.text_line(pos))) then
                    FOUND_LEN := pos - START_POS;
                    TAG_LEN   := pos - START_POS - 2;
                    END_LINE  := FALSE;
                    return;
                end if;
            end loop;
            FOUND_LEN := SELF.text_end - START_POS;
            TAG_LEN   := SELF.text_end - START_POS-2;
            END_LINE  := TRUE;
            return;
        end if;
        if (START_POS+4 > SELF.text_end) then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            TAG_POS   := START_POS;
            TAG_LEN   := 0;
            END_LINE  := FALSE;
            return;
        end if;
        if (SELF.text_line(START_POS+1) = '<') and
           (SELF.text_line(START_POS+2) = '!') then
            TAG_POS   := START_POS+3;
            for pos in START_POS+3 to SELF.text_end loop
                if (SELF.text_line(pos) = '>') then
                    FOUND     := TRUE;
                    FOUND_LEN := pos - START_POS + 1;
                    TAG_LEN   := pos - START_POS + 1 - 4;
                    END_LINE  := FALSE;
                    return;
                end if;
            end loop;
        end if;
        FOUND     := FALSE;
        FOUND_LEN := 0;
        TAG_POS   := START_POS;
        TAG_LEN   := 0;
        END_LINE  := FALSE;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *現在の位置から* スキャンを開始し、
    --!        TAGを見つけてタグの文字列の位置と長さを返す.
    --!        その文字数(クォート文字含む)を返す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    TAG_POS     タグ文字列の開始位置.
    --! @param    TAG_LEN     タグ文字列の文字数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_tag_prop(
        variable  SELF          : inout READER_TYPE;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  TAG_POS       : out   integer;
                  TAG_LEN       : out   integer;
                  END_LINE      : out   boolean 
    ) is
    begin
        scan_tag_prop(SELF, SELF.text_pos, FOUND, FOUND_LEN, TAG_POS, TAG_LEN, END_LINE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *指定された位置の次の位置* スキャンを開始し、
    --!        プレーンスカラー(plain scalar)を探す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * 最初の位置のキャラクタは既にスキャン済みでスカラーであることが
    --!        確認されている事が前提.
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    START_POS   スキャンを開始する位置.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_plain_one_line(
        variable  SELF          : inout READER_TYPE;
                  START_POS     : in    integer;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
        variable  len           :       integer;
        variable  char          :       character;
        variable  curr_state    :       STATE_TYPE;
        variable  scan_found    :       boolean;
        variable  scan_pos      :       integer;
        variable  scan_len      :       integer;
    begin
        len      := 1;
        END_LINE := FALSE;
        get_struct_state(SELF, curr_state);
        for pos in START_POS+1 to SELF.text_end loop
            char := SELF.text_line(pos);
            case char is
                when NUL|SOH|STX|ETX|EOT|ENQ|ACK|BEL|
                     BS |HT |LF |VT |FF |CR |SO |SI |
                     DLE|DC1|DC2|DC3|DC4|NAK|SYN|ETB|
                     CAN|EM |SUB|ESC|FSP|GSP|RSP|USP|DEL =>
                    exit;
                when '['|']'|'{'|'}'|',' =>
                    if (curr_state = STATE_FLOW_MAP_KEY) or
                       (curr_state = STATE_FLOW_MAP_VAL) or
                       (curr_state = STATE_FLOW_MAP_SEP) or
                       (curr_state = STATE_FLOW_MAP_END) or
                       (curr_state = STATE_FLOW_SEQ_VAL) or
                       (curr_state = STATE_FLOW_SEQ_END) then
                        for prev_pos in pos-1 downto START_POS loop
                            exit when (SELF.text_line(prev_pos) /= ' ');
                            len := len - 1;
                        end loop;
                        exit;
                    end if;
                when ':'=>
                    find_indicator(SELF, pos, ':', scan_found, scan_pos, scan_len, END_LINE);
                    if (scan_found) then
                        for prev_pos in pos-1 downto START_POS loop
                            exit when (SELF.text_line(prev_pos) /= ' ');
                            len := len - 1;
                        end loop;
                        exit;
                    end if;
                when '#' =>
                    if (SELF.text_line(pos-1) = ' ') then
                        for prev_pos in pos-1 downto START_POS loop
                            exit when (SELF.text_line(prev_pos) /= ' ');
                            len := len - 1;
                        end loop;
                        exit;
                    end if;
                when others => null;
            end case;
            len := len + 1;
        end loop;
        FOUND     := TRUE;
        FOUND_LEN := len;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *現在の位置の次の位置* スキャンを開始し、
    --!        プレーンスカラー(plain scalar)を探す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * 最初の位置のキャラクタは既にスキャン済みでスカラーであることが
    --!        確認されている事が前提.
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_plain_one_line(
        variable  SELF          : inout READER_TYPE;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
    begin
        scan_plain_one_line(SELF, SELF.text_pos, FOUND, FOUND_LEN, END_LINE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *指定された位置から* スキャンを開始し、
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!        プレーンスカラー(plain scalar)を探す.
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    START_POS   スキャンを開始する位置.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_plain_scalar(
        variable  SELF          : inout READER_TYPE;
                  START_POS     : in    integer;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
        variable  len           :       integer;
        variable  char          :       character;
        variable  found_key     :       boolean;
    begin
        if (SELF.end_of_file  =  TRUE) or
           (SELF.text_line    =  null) or
           (START_POS > SELF.text_end) then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := TRUE;
            return;
        end if;
        char := SELF.text_line(START_POS);
        case char is
            when NUL|SOH|STX|ETX|EOT|ENQ|ACK|BEL|
                 BS |HT |LF |VT |FF |CR |SO |SI |
                 DLE|DC1|DC2|DC3|DC4|NAK|SYN|ETB|
                 CAN|EM |SUB|ESC|FSP|GSP|RSP|USP|
                 DEL|'.'|','|'['|']'|'{'|'}'|'#'|
                 '&'|'*'|'!'|'|'|'>'|'%'|'@'|'`'=>
                FOUND     := FALSE;
                FOUND_LEN := 0;
                END_LINE  := FALSE;
            when '-' | ':' | '?' =>
                scan_indicator(SELF, START_POS, char, found_key, len, END_LINE);
                if (found_key) then
                    FOUND     := FALSE;
                    FOUND_LEN := 0;
                    END_LINE  := FALSE;
                else
                    scan_plain_one_line(SELF, START_POS, FOUND, FOUND_LEN, END_LINE);
                end if;
            when '"' | ''' =>
                scan_quoted_string(SELF, START_POS, found_key, len, END_LINE);
                if (found_key) then
                    FOUND     := TRUE;
                    FOUND_LEN := len;
                    END_LINE  := FALSE;
                else
                    FOUND     := TRUE;
                    FOUND_LEN := SELF.text_end - START_POS;
                    END_LINE  := TRUE;
                end if;
            when others =>
                scan_plain_one_line(SELF, START_POS, FOUND, FOUND_LEN, END_LINE);
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *現在の地点から* スキャンを開始し、スカラーを探す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_plain_scalar(
        variable  SELF          : inout READER_TYPE;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean 
    ) is
    begin
        scan_plain_scalar(SELF, SELF.text_pos, FOUND, FOUND_LEN, END_LINE);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインからプレーンスカラー(plain scalar)を読んでバッファに
    --!        格納するサブプログラム
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STR         見つかったワードを格納するバッファ.
    --! @param    STR_LEN     格納したワードの文字数.
    --! @param    READ_LEN    見つかったワードの文字数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure read_plain_scalar(
        variable  SELF          : inout READER_TYPE;
                  STR           : out   string;
                  STR_LEN       : out   integer;
                  READ_LEN      : out   integer;
                  END_LINE      : out   boolean 
    ) is
        alias     str_buf       :       string(1 to STR'length) is STR;
        variable  pos           :       integer;
        variable  scalar_len    :       integer;
        variable  found         :       boolean;
        variable  end_of_line   :       boolean;
    begin
        scan_plain_scalar(SELF, found, scalar_len, end_of_line);
        if (found = TRUE) then
            pos  := SELF.text_pos;
            if (scalar_len <= STR'length) then
                str_buf := (others => ' ');
                str_buf(1 to scalar_len) := SELF.text_line(pos to pos + scalar_len-1);
                STR_LEN := scalar_len;
            else
                str_buf(1 to STR'length) := SELF.text_line(pos to pos + STR'length-1);
                STR_LEN := STR'length;
            end if;
            SELF.text_pos := SELF.text_pos + scalar_len;
            READ_LEN := scalar_len;
            END_LINE := FALSE;
        else
            STR_LEN  := 0;
            READ_LEN := 0;
            END_LINE := end_of_line;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからクォートされた文字列を取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STR         見つかったワードを格納するバッファ.
    --! @param    STR_LEN     格納したワードの文字数.
    --! @param    READ_LEN    見つかったワードの文字数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure read_quoted_string(
        variable  SELF          : inout READER_TYPE;
                  STR           : out   string;
                  STR_LEN       : out   integer;
                  READ_LEN      : out   integer;
                  END_LINE      : out   boolean 
    ) is
        alias     str_buf       :       string(1 to STR'length) is STR;
        variable  pos           :       integer;
        variable  string_len    :       integer;
        variable  quoted_len    :       integer;
        variable  found         :       boolean;
        variable  end_of_line   :       boolean;
    begin
        scan_quoted_string(SELF, found, quoted_len, end_of_line);
        if (found = TRUE and end_of_line = FALSE) then
            pos  := SELF.text_pos + 1;
            string_len := quoted_len-2;
            if (string_len <= STR'length) then
                str_buf := (others => ' ');
                str_buf(1 to string_len) := SELF.text_line(pos to pos + string_len-1);
                STR_LEN := string_len;
            else
                str_buf(1 to STR'length) := SELF.text_line(pos to pos + STR'length-1);
                STR_LEN := STR'length;
            end if;
            SELF.text_pos := SELF.text_pos + quoted_len;
            READ_LEN := quoted_len;
            END_LINE := FALSE;
        else
            STR_LEN  := 0;
            READ_LEN := 0;
            END_LINE := FALSE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの現在のポインタが示しているトークンを得るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    TOKEN       見つかったトークンのタイプ.
    --! @param    TOKEN_POS   見つかったトークンの位置.
    --! @param    TOKEN_LEN   見つかったトークンの文字数.
    -------------------------------------------------------------------------------
    procedure scan_token(
        variable  SELF          : inout READER_TYPE;
                  TOKEN         : out   TOKEN_TYPE;
                  TOKEN_POS     : out   integer;
                  TOKEN_LEN     : out   integer
    ) is
        variable  char          :       character;
        variable  found         :       boolean;
        variable  found_len     :       integer;
        variable  line_end      :       boolean;
    begin
        ---------------------------------------------------------------------------
        -- 現在のポインタにあるキャラクタをcharにセットする.
        ---------------------------------------------------------------------------
        scan_char(SELF, char, found);
        ---------------------------------------------------------------------------
        -- 現在のポインタの位置を変数 TOKEN_POS にセットする.
        ---------------------------------------------------------------------------
        TOKEN_POS := SELF.text_pos;
        ---------------------------------------------------------------------------
        -- ファイルの終端の場合はTOKEN_STREAM_ENDをセットする.
        ---------------------------------------------------------------------------
        if (SELF.end_of_file) then
            TOKEN_LEN := 0;
            TOKEN     := TOKEN_STREAM_END;
            return;
        end if;
        ---------------------------------------------------------------------------
        -- キャラクタを調べる.
        ---------------------------------------------------------------------------
        case char is
            -----------------------------------------------------------------------
            -- 最初の文字が制御文字(プリントできない文字)だった場合.
            -----------------------------------------------------------------------
            when NUL|SOH|STX|ETX|EOT|ENQ|ACK|BEL|
                 BS |HT |LF |VT |FF |CR |SO |SI |
                 DLE|DC1|DC2|DC3|DC4|NAK|SYN|ETB|
                 CAN|EM |SUB|ESC|FSP|GSP|RSP|USP|DEL =>
                TOKEN_LEN := 0; TOKEN := TOKEN_ERROR;
            -----------------------------------------------------------------------
            -- 最初の文字が'-'で始まっているならば、'---'か'-'をチェックする.
            -----------------------------------------------------------------------
            when '-'    =>
                scan_doc_begin(SELF, found, found_len, line_end);
                if (found = TRUE) then
                    TOKEN     := TOKEN_DOCUMENT_BEGIN;
                    TOKEN_LEN := found_len;
                    return;
                end if;
                scan_indicator(SELF, '-', found, found_len, line_end);
                if (found = TRUE) then
                    TOKEN     := TOKEN_SEQ_ENTRY;
                    TOKEN_LEN := found_len;
                    return;
                end if;
                scan_plain_one_line(SELF, found, found_len, line_end);
                if (found = TRUE) then
                    TOKEN     := TOKEN_SCALAR;
                    TOKEN_LEN := found_len;
                    return;
                else
                    TOKEN     := TOKEN_ERROR;
                    TOKEN_LEN := 0;
                    return;
                end if;
            -----------------------------------------------------------------------
            -- 最初の文字が'?'で始まっているならば、'? 'をチェックする.
            -----------------------------------------------------------------------
            when '?'    =>
                scan_indicator(SELF, '?', found, found_len, line_end);
                if (found = TRUE) then
                    TOKEN     := TOKEN_MAP_EXPLICIT_KEY;
                    TOKEN_LEN := found_len;
                    return;
                end if;
                scan_plain_one_line(SELF, found, found_len, line_end);
                if (found = TRUE) then
                    TOKEN     := TOKEN_SCALAR;
                    TOKEN_LEN := found_len;
                    return;
                else
                    TOKEN     := TOKEN_ERROR;
                    TOKEN_LEN := 0;
                    return;
                end if;
            -----------------------------------------------------------------------
            -- 最初の文字が':'で始まっているならば、': 'をチェックする.
            -----------------------------------------------------------------------
            when ':'    =>
                scan_indicator(SELF, ':', found, found_len, line_end);
                if (found = TRUE) then
                    TOKEN  := TOKEN_MAP_SEPARATOR;
                    TOKEN_LEN := found_len;
                    return;
                end if;
                scan_plain_one_line(SELF, found, found_len, line_end);
                if (found = TRUE) then
                    TOKEN     := TOKEN_SCALAR;
                    TOKEN_LEN := found_len;
                    return;
                else
                    TOKEN     := TOKEN_ERROR;
                    TOKEN_LEN := 0;
                    return;
                end if;
            -----------------------------------------------------------------------
            -- 最初の文字が'.'で始まっているならば、'...'をチェックする.
            -----------------------------------------------------------------------
            when '.'    => 
                scan_doc_end(SELF, found, found_len, line_end);
                if (found = TRUE) then
                    TOKEN  := TOKEN_DOCUMENT_END;
                    TOKEN_LEN := found_len;
                    return;
                end if;
                scan_plain_scalar(SELF, found, found_len, line_end);
                if (found = TRUE) then
                    TOKEN  := TOKEN_SCALAR;
                    TOKEN_LEN := found_len;
                    return;
                else
                    TOKEN  := TOKEN_ERROR;
                    TOKEN_LEN := 0;
                    return;
                end if;
            -----------------------------------------------------------------------
            -- それ以外のインジケーター候補の場合...
            -----------------------------------------------------------------------
            when ','    => TOKEN_LEN := 1; TOKEN := TOKEN_FLOW_ENTRY;
            when '['    => TOKEN_LEN := 1; TOKEN := TOKEN_FLOW_SEQ_BEGIN;
            when ']'    => TOKEN_LEN := 1; TOKEN := TOKEN_FLOW_SEQ_END;
            when '{'    => TOKEN_LEN := 1; TOKEN := TOKEN_FLOW_MAP_BEGIN;
            when '}'    => TOKEN_LEN := 1; TOKEN := TOKEN_FLOW_MAP_END;
            when '#'    => TOKEN_LEN := 0; TOKEN := TOKEN_ERROR;
            when '&'    => TOKEN_LEN := 1; TOKEN := TOKEN_ANCHOR_PROPERTY;
            when '*'    => TOKEN_LEN := 1; TOKEN := TOKEN_ALIAS_NODE;
            when '!'    => TOKEN_LEN := 1; TOKEN := TOKEN_TAG_PROPERTY;
            when '|'    => TOKEN_LEN := 1; TOKEN := TOKEN_LITERAL;
            when '>'    => TOKEN_LEN := 1; TOKEN := TOKEN_FOLDED;
            when '''    => TOKEN_LEN := 1; TOKEN := TOKEN_SINGLE_QUOTE;
            when '"'    => TOKEN_LEN := 1; TOKEN := TOKEN_DOUBLE_QUOTE;
            when '%'    => TOKEN_LEN := 1; TOKEN := TOKEN_DIRECTIVE;
            when '@'    => TOKEN_LEN := 0; TOKEN := TOKEN_ERROR;
            when '`'    => TOKEN_LEN := 0; TOKEN := TOKEN_ERROR;
            -----------------------------------------------------------------------
            -- それ以外の文字だった場合...
            -----------------------------------------------------------------------
            when others =>
                scan_plain_one_line(SELF, found, found_len, line_end);
                TOKEN_LEN := found_len;
                TOKEN     := TOKEN_SCALAR;
        end case;
    end scan_token;
    -------------------------------------------------------------------------------
    --! @brief テキストラインから指定したトークンを読み飛ばすサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    TOKEN       読み飛ばすトークン.
    --! @param    POS         トークンの位置.
    --! @param    LEN         トークンの文字数.
    -------------------------------------------------------------------------------
    procedure skip_token(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  TOKEN         : in    TOKEN_TYPE;
                  POS           : in    integer;
                  LEN           : in    integer
    ) is
    begin
        SELF.text_pos := POS + LEN;
    end skip_token;
    -------------------------------------------------------------------------------
    --! @brief リーダーの状態を保持する構造体の初期化用定数を生成する関数.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    NAME        リーダーの識別名.
    --! @param    STREAM_NAME シナリオファイルの名前を指定する.
    --! @return               生成した定数.
    -------------------------------------------------------------------------------
    function  NEW_READER(NAME: string;STREAM_NAME: string) return READER_TYPE is
        variable self    : READER_TYPE;
    begin
        WRITE(self.name       , NAME       );
        WRITE(self.stream_name, STREAM_NAME);
        self.text_line   := null;
        self.text_pos    := 0;
        self.text_end    := 0;
        self.line_num    := 0;
        self.end_of_file := FALSE;
        self.debug_mode  := 0;
        init_struct_state(self);
        return self;
    end function;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *指定された位置から* スキャンを開始し、
    --!        行内に完結したフローコレクション('['...']' or '{'...'}')があるかを探す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * このサブプログラムは、行内に暗黙のマップキーがあるかどうかを調べる
    --!        ために使われる.
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    START_POS   スキャンを開始する位置.
    --! @param    END_CHAR    閉じ括弧を指定する.
    --! @param    FOUND       見つかったことを示す.
    --! @param    FOUND_LEN   見つかった空白の数.
    --! @param    END_LINE    ポインタが行末を越えたことを示す.
    -------------------------------------------------------------------------------
    procedure scan_flow_collection(
        variable  SELF          : inout READER_TYPE;
                  START_POS     : in    integer;
                  END_CHAR      : in    character;
                  FOUND         : out   boolean;
                  FOUND_LEN     : out   integer;
                  END_LINE      : out   boolean
    ) is
        variable  pos           :       integer;
        variable  scan_found    :       boolean;
        variable  scan_len      :       integer;
        variable  end_of_line   :       boolean;
    begin
        if (START_POS > SELF.text_end) then
            FOUND     := FALSE;
            FOUND_LEN := 0;
            END_LINE  := TRUE;
            return;
        end if;
        pos := START_POS;
        end_of_line := FALSE;
        while (end_of_line = FALSE) loop
            if    (SELF.text_line(pos) = END_CHAR) then
                FOUND     := TRUE;
                FOUND_LEN := pos - START_POS + 1;
                END_LINE  := FALSE;
               return;
            elsif (SELF.text_line(pos) = '[') then
                scan_flow_collection(SELF, pos+1, ']', scan_found, scan_len, end_of_line);
                if (scan_found) then
                    pos := pos + scan_len+1;
                    next;
                end if;
            elsif (SELF.text_line(pos) = '{') then
                scan_flow_collection(SELF, pos+1, '}', scan_found, scan_len, end_of_line);
                if (scan_found) then
                    pos := pos + scan_len+1;
                    next;
                end if;
            elsif (SELF.text_line(pos) = ''') or
                  (SELF.text_line(pos) = '"') then
                scan_quoted_string(SELF, pos, scan_found, scan_len, end_of_line);
                if (scan_found) then
                    pos := pos + scan_len;
                end if;
            elsif (SELF.text_line(pos) = '#') then
                exit;
            elsif (pos >= SELF.text_end) then
                end_of_line := TRUE;
            else
                pos := pos + 1;
            end if;
        end loop;
        FOUND     := FALSE;
        FOUND_LEN := 0;
        END_LINE  := TRUE;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief テキストラインの *現在の位置から* スキャンを開始し、
    --!        行内に暗黙のマップキーがあるか調べる.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --!      * テキストラインをスキャンするだけで、ポインタを更新したり、新たに
    --!        ストリームからテキストラインを読み込む等のコンテキストの変更は行わない.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    FOUND       暗黙のマップキーが見つかったことを示す.
    -------------------------------------------------------------------------------
    procedure scan_block_map_implicit_key(
        variable  SELF          : inout READER_TYPE;
                  FOUND         : out   boolean
    ) is
        variable  pos           :       integer;
        variable  len           :       integer;
        variable  scan_found    :       boolean;
        variable  line_end      :       boolean;
        variable  map_key       :       MAPKEY_MODE;
    begin
        get_map_key_mode(SELF, map_key);
        case map_key is
            when MAPKEY_NULL =>
                pos := SELF.text_pos;
                case SELF.text_line(pos) is
                    when '[' =>
                        scan_flow_collection(SELF, pos+1, ']', scan_found, len, line_end);
                        pos := pos + len+1;
                    when '{' =>
                        scan_flow_collection(SELF, pos+1, '}', scan_found, len, line_end);
                        pos := pos + len+1;
                    when others =>
                        scan_plain_scalar(SELF, pos, scan_found, len, line_end);
                        pos := pos + len;
                end case;
                if (scan_found) then
                    find_indicator(SELF, pos, ':', scan_found, pos, len, line_end);
                    if (scan_found) then
                        FOUND := TRUE;
                        set_map_key_mode(SELF, MAPKEY_FOUND);
                    else
                        FOUND := FALSE;
                    end if;
                else
                        FOUND := FALSE;
                end if;
            when MAPKEY_FOUND =>
                FOUND := TRUE;
            when others =>
                FOUND := FALSE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 次に読み取ることのできるイベントをスキャンするサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    NEXT_EVENT  見つかったイベント.
    -------------------------------------------------------------------------------
    procedure SEEK_EVENT(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  NEXT_EVENT    : out   EVENT_TYPE
    ) is
        variable  curr_state    :       STATE_TYPE;
        variable  curr_indent   :       INDENT_TYPE;
        variable  indent        :       INDENT_TYPE;
        variable  token         :       TOKEN_TYPE;
        variable  pos           :       integer;
        variable  len           :       integer;
        variable  found         :       boolean;
    begin
        ---------------------------------------------------------------------------
        -- まずは空白を読み飛ばす.
        ---------------------------------------------------------------------------
        skip_space(SELF, STREAM);
        ---------------------------------------------------------------------------
        -- テキストラインからイベント情報を得る.
        ---------------------------------------------------------------------------
        scan_token(SELF, token, pos, len);
        indent := SELF.text_pos;
        ---------------------------------------------------------------------------
        -- 現在の状態により分岐.
        ---------------------------------------------------------------------------
        get_struct_state(SELF, curr_state, curr_indent);
        case curr_state is
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            when STATE_NONE  =>
                case token is
                    when TOKEN_DIRECTIVE        => NEXT_EVENT := EVENT_DIRECTIVE;
                    when TOKEN_DOCUMENT_BEGIN   => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_SEQ_ENTRY        => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_FLOW_SEQ_BEGIN   => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_FLOW_MAP_BEGIN   => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_MAP_EXPLICIT_KEY => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_SCALAR           => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_LITERAL          => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_FOLDED           => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_SINGLE_QUOTE     => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_DOUBLE_QUOTE     => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_TAG_PROPERTY     => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_ANCHOR_PROPERTY  => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_ALIAS_NODE       => NEXT_EVENT := EVENT_DOC_BEGIN;
                    when TOKEN_STREAM_END       => NEXT_EVENT := EVENT_STREAM_END;
                    when others                 => NEXT_EVENT := EVENT_ERROR;
                end case;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            when STATE_DOCUMENT =>
                case token is
                    when TOKEN_DOCUMENT_BEGIN   => NEXT_EVENT := EVENT_DOC_END;
                    when TOKEN_DOCUMENT_END     => NEXT_EVENT := EVENT_DOC_END;
                    when TOKEN_STREAM_END       => NEXT_EVENT := EVENT_DOC_END;
                    when TOKEN_SEQ_ENTRY        => NEXT_EVENT := EVENT_SEQ_BEGIN;
                    when TOKEN_FLOW_SEQ_BEGIN   => NEXT_EVENT := EVENT_SEQ_BEGIN;
                    when TOKEN_FLOW_MAP_BEGIN   => NEXT_EVENT := EVENT_MAP_BEGIN;
                    when TOKEN_MAP_EXPLICIT_KEY => NEXT_EVENT := EVENT_MAP_BEGIN;
                    when TOKEN_SCALAR           => NEXT_EVENT := EVENT_MAP_BEGIN;
                    when TOKEN_LITERAL          => NEXT_EVENT := EVENT_MAP_BEGIN;
                    when TOKEN_FOLDED           => NEXT_EVENT := EVENT_MAP_BEGIN;
                    when TOKEN_SINGLE_QUOTE     => NEXT_EVENT := EVENT_MAP_BEGIN;
                    when TOKEN_DOUBLE_QUOTE     => NEXT_EVENT := EVENT_MAP_BEGIN;
                    when TOKEN_TAG_PROPERTY     => NEXT_EVENT := EVENT_TAG_PROP;
                    when TOKEN_ANCHOR_PROPERTY  => NEXT_EVENT := EVENT_ANCHOR;
                    when TOKEN_ALIAS_NODE       => NEXT_EVENT := EVENT_ALIAS;
                    when others                 => NEXT_EVENT := EVENT_ERROR;
                end case;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            when STATE_FLOW_MAP_KEY           |
                 STATE_BLOCK_MAP_IMPLICIT_KEY |
                 STATE_BLOCK_MAP_EXPLICIT_KEY =>
                case token is
                    when TOKEN_DOCUMENT_BEGIN   => NEXT_EVENT := EVENT_DOC_END;
                    when TOKEN_DOCUMENT_END     => NEXT_EVENT := EVENT_DOC_END;
                    when TOKEN_STREAM_END       => NEXT_EVENT := EVENT_DOC_END;
                    when TOKEN_SEQ_ENTRY        => NEXT_EVENT := EVENT_SEQ_BEGIN;
                    when TOKEN_FLOW_SEQ_BEGIN   => NEXT_EVENT := EVENT_SEQ_BEGIN;
                    when TOKEN_FLOW_MAP_BEGIN   => NEXT_EVENT := EVENT_MAP_BEGIN;
                    when TOKEN_MAP_EXPLICIT_KEY => NEXT_EVENT := EVENT_MAP_BEGIN;
                    when TOKEN_SCALAR           => NEXT_EVENT := EVENT_SCALAR;
                    when TOKEN_DOUBLE_QUOTE     => NEXT_EVENT := EVENT_SCALAR;
                    when TOKEN_SINGLE_QUOTE     => NEXT_EVENT := EVENT_SCALAR;
                    when TOKEN_LITERAL          => NEXT_EVENT := EVENT_SCALAR;
                    when TOKEN_FOLDED           => NEXT_EVENT := EVENT_SCALAR;
                    when TOKEN_TAG_PROPERTY     => NEXT_EVENT := EVENT_TAG_PROP;
                    when TOKEN_ANCHOR_PROPERTY  => NEXT_EVENT := EVENT_ANCHOR;
                    when TOKEN_ALIAS_NODE       => NEXT_EVENT := EVENT_ALIAS;
                    when others                 => NEXT_EVENT := EVENT_ERROR;
                end case;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            when STATE_BLOCK_SEQ_VAL          |
                 STATE_FLOW_SEQ_VAL           |
                 STATE_FLOW_MAP_VAL           |
                 STATE_BLOCK_MAP_IMPLICIT_VAL |
                 STATE_BLOCK_MAP_EXPLICIT_VAL =>
                case token is
                    when TOKEN_DOCUMENT_BEGIN   => NEXT_EVENT := EVENT_DOC_END;
                    when TOKEN_DOCUMENT_END     => NEXT_EVENT := EVENT_DOC_END;
                    when TOKEN_STREAM_END       => NEXT_EVENT := EVENT_DOC_END;
                    when TOKEN_SEQ_ENTRY        => NEXT_EVENT := EVENT_SEQ_BEGIN;
                    when TOKEN_MAP_EXPLICIT_KEY => NEXT_EVENT := EVENT_MAP_BEGIN;
                    when TOKEN_TAG_PROPERTY     => NEXT_EVENT := EVENT_TAG_PROP;
                    when TOKEN_ANCHOR_PROPERTY  => NEXT_EVENT := EVENT_ANCHOR;
                    when TOKEN_ALIAS_NODE       => NEXT_EVENT := EVENT_ALIAS;
                    when TOKEN_FLOW_SEQ_BEGIN   =>
                        scan_block_map_implicit_key(SELF, found);
                        if (found) then
                            NEXT_EVENT := EVENT_MAP_BEGIN;
                        else
                            NEXT_EVENT := EVENT_SEQ_BEGIN;
                        end if;
                    when TOKEN_FLOW_MAP_BEGIN   =>
                        scan_block_map_implicit_key(SELF, found);
                        if (found) then
                            NEXT_EVENT := EVENT_MAP_BEGIN;
                        else
                            NEXT_EVENT := EVENT_MAP_BEGIN;
                        end if;
                    when TOKEN_SCALAR           |
                         TOKEN_DOUBLE_QUOTE     |
                         TOKEN_SINGLE_QUOTE     =>
                        scan_block_map_implicit_key(SELF, found);
                        if (found) then
                            NEXT_EVENT := EVENT_MAP_BEGIN;
                        else
                            NEXT_EVENT := EVENT_SCALAR;
                        end if;
                    when TOKEN_LITERAL        => NEXT_EVENT := EVENT_SCALAR;
                    when TOKEN_FOLDED         => NEXT_EVENT := EVENT_SCALAR;
                    when others               => NEXT_EVENT := EVENT_ERROR;
                end case;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            when STATE_BLOCK_SEQ_END =>
                case token is
                    when TOKEN_DOCUMENT_BEGIN => NEXT_EVENT := EVENT_SEQ_END;
                    when TOKEN_DOCUMENT_END   => NEXT_EVENT := EVENT_SEQ_END;
                    when TOKEN_STREAM_END     => NEXT_EVENT := EVENT_SEQ_END;
                    when TOKEN_SEQ_ENTRY      =>
                        if    (indent < curr_indent) then
                            NEXT_EVENT := EVENT_SEQ_END;
                        elsif (indent = curr_indent) then
                            NEXT_EVENT := EVENT_SEQ_NEXT;
                        else
                            NEXT_EVENT := EVENT_ERROR;
                        end if;
                    when others               =>
                        if    (indent < curr_indent) then
                            NEXT_EVENT := EVENT_SEQ_END;
                        else
                            NEXT_EVENT := EVENT_ERROR;
                        end if;
                end case;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            when STATE_FLOW_SEQ_END =>
                case token is
                    when TOKEN_FLOW_ENTRY     => NEXT_EVENT := EVENT_SEQ_NEXT;
                    when TOKEN_FLOW_SEQ_END   => NEXT_EVENT := EVENT_SEQ_END;
                    when others               => NEXT_EVENT := EVENT_ERROR;
                end case;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            when STATE_FLOW_MAP_SEP           |
                 STATE_BLOCK_MAP_IMPLICIT_SEP =>
                if (token = TOKEN_MAP_SEPARATOR) then
                    NEXT_EVENT := EVENT_MAP_SEP;
                else
                    NEXT_EVENT := EVENT_ERROR;
                end if;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            when STATE_BLOCK_MAP_EXPLICIT_SEP =>
                if (token = TOKEN_MAP_SEPARATOR) and
                   (indent = curr_indent      ) then
                    NEXT_EVENT := EVENT_MAP_SEP;
                else
                    NEXT_EVENT := EVENT_ERROR;
                end if;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            when STATE_BLOCK_MAP_IMPLICIT_END |
                 STATE_BLOCK_MAP_EXPLICIT_END =>
                case token is
                    when TOKEN_DOCUMENT_BEGIN => NEXT_EVENT := EVENT_MAP_END;
                    when TOKEN_DOCUMENT_END   => NEXT_EVENT := EVENT_MAP_END;
                    when TOKEN_STREAM_END     => NEXT_EVENT := EVENT_MAP_END;
                    when others               => 
                        if    (indent < curr_indent) then
                            NEXT_EVENT := EVENT_MAP_END;
                        elsif (indent = curr_indent) then
                            NEXT_EVENT := EVENT_MAP_NEXT;
                        else
                            NEXT_EVENT := EVENT_ERROR;
                        end if;
                end case;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            when STATE_FLOW_MAP_END =>
                case token is
                    when TOKEN_FLOW_ENTRY       => NEXT_EVENT := EVENT_MAP_NEXT;
                    when TOKEN_FLOW_MAP_END     => NEXT_EVENT := EVENT_MAP_END;
                    when others                 => NEXT_EVENT := EVENT_ERROR;
                end case;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            when others                         => NEXT_EVENT := EVENT_ERROR;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_DOC_BEGINを取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    LEN         読み出した文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_doc_begin(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  LEN           : out   integer;
                  GOOD          : out   boolean 
    ) is
        variable  curr_state    :       STATE_TYPE;
        variable  token         :       TOKEN_TYPE;
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
    begin
        get_struct_state(SELF, curr_state);
        case curr_state is
            when STATE_NONE  =>
                scan_token(SELF, token, token_pos, token_len);
                if (token = TOKEN_DOCUMENT_BEGIN) then
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                end if;
                set_struct_state(SELF, STATE_DOCUMENT, 0);
                LEN  := token_len;
                GOOD := TRUE;
            when others =>
                LEN  := 0;
                GOOD := FALSE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_DOC_ENDを取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    LEN         読み出した文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_doc_end(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  LEN           : out   integer;
                  GOOD          : out   boolean
    ) is
        variable  curr_state    :       STATE_TYPE;
        variable  token         :       TOKEN_TYPE; 
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
        variable  stack_good    :       boolean;
    begin
        get_struct_state(SELF, curr_state);
        case curr_state is
            when STATE_DOCUMENT  =>
                scan_token(SELF, token, token_pos, token_len);
                if (token = TOKEN_DOCUMENT_END) then
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                    while(SELF.end_of_file = FALSE) loop
                        read_text_line(SELF, STREAM);
                        scan_token(SELF, token, token_pos, token_len);
                        if (token = TOKEN_DIRECTIVE     ) or
                           (token = TOKEN_DOCUMENT_BEGIN) then
                            exit;
                        end if;
                    end loop;
                end if;
                set_struct_state(SELF, STATE_NONE, 0);
                LEN  := token_len;
                GOOD := TRUE;
            when others =>
                LEN  := 0;
                GOOD := FALSE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_SEQ_BEGINを取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    LEN         読み出した文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_seq_begin(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  LEN           : out   integer;
                  GOOD          : out   boolean
    ) is
        variable  token         :       TOKEN_TYPE;
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
        variable  curr_state    :       STATE_TYPE;
        variable  next_state    :       STATE_TYPE;
        variable  next_indent   :       INDENT_TYPE;
        variable  new_indent    :       INDENT_TYPE;
    begin
        get_struct_state(SELF, curr_state, next_indent);
        case curr_state is
            when STATE_DOCUMENT               => next_state := STATE_DOCUMENT;
            when STATE_FLOW_SEQ_VAL           => next_state := STATE_FLOW_SEQ_END ;
            when STATE_FLOW_MAP_KEY           => next_state := STATE_FLOW_MAP_SEP ;
            when STATE_FLOW_MAP_VAL           => next_state := STATE_FLOW_MAP_END ;
            when STATE_BLOCK_SEQ_VAL          => next_state := STATE_BLOCK_SEQ_END;
            when STATE_BLOCK_MAP_IMPLICIT_KEY => next_state := STATE_BLOCK_MAP_IMPLICIT_SEP;
            when STATE_BLOCK_MAP_IMPLICIT_VAL => next_state := STATE_BLOCK_MAP_IMPLICIT_END;
            when STATE_BLOCK_MAP_EXPLICIT_KEY => next_state := STATE_BLOCK_MAP_EXPLICIT_SEP;
            when STATE_BLOCK_MAP_EXPLICIT_VAL => next_state := STATE_BLOCK_MAP_EXPLICIT_END;
            when others                       => GOOD := FALSE;
                                                 return;
        end case;
        scan_token(SELF, token, token_pos, token_len);
        new_indent := SELF.text_pos;
        case token is
            when TOKEN_SEQ_ENTRY =>
                skip_token(SELF, STREAM, token, token_pos, token_len);
                set_struct_state(SELF, next_state);
                call_struct_state(
                    SELF       => SELF,
                    RET_STATE  => next_state,
                    RET_INDENT => next_indent,
                    NEW_STATE  => STATE_BLOCK_SEQ_VAL,
                    NEW_INDENT => new_indent,
                    GOOD       => GOOD
                );
                LEN := token_len;
            when TOKEN_FLOW_SEQ_BEGIN => 
                skip_token(SELF, STREAM, token, token_pos, token_len);
                set_struct_state(SELF, next_state);
                call_struct_state(
                    SELF    => SELF,
                    RET_STATE  => next_state,
                    RET_INDENT => next_indent,
                    NEW_STATE  => STATE_FLOW_SEQ_VAL,
                    NEW_INDENT => new_indent,
                    GOOD       => GOOD
                );
                LEN := token_len;
            when others =>
                LEN  := 0;
                GOOD := FALSE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief コンテキストからEVENT_SEQ_ENDを取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    LEN         読み出した文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_seq_end(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  LEN           : out   integer;
                  GOOD          : out   boolean
    ) is
        variable  curr_state    :       STATE_TYPE;
        variable  token         :       TOKEN_TYPE;
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
    begin
        get_struct_state(SELF, curr_state);
        case curr_state is
            when STATE_BLOCK_SEQ_END =>
                LEN := 0;
                return_struct_state(SELF, GOOD);
            when STATE_FLOW_SEQ_END  =>
                scan_token(SELF, token, token_pos, token_len);
                if (token = TOKEN_FLOW_SEQ_END) then
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                    return_struct_state(SELF, GOOD);
                    LEN  := token_len;
                else
                    LEN  := 0;
                    GOOD := FALSE;
                end if;
            when others =>
                    LEN  := 0;
                    GOOD := FALSE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_SEQ_NEXTを取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    LEN         読み出した文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_seq_next(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  LEN           : out   integer;
                  GOOD          : out   boolean 
    ) is
        variable  curr_state    :       STATE_TYPE;
        variable  token         :       TOKEN_TYPE;
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
        variable  stack_good    :       boolean;
    begin
        get_struct_state(SELF, curr_state);
        case curr_state is
            when STATE_BLOCK_SEQ_END => 
                scan_token(SELF, token, token_pos, token_len);
                if (token = TOKEN_SEQ_ENTRY) then
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                    set_struct_state(SELF, STATE_BLOCK_SEQ_VAL);
                    LEN  := token_len;
                    GOOD := TRUE;
                else
                    LEN  := 0;
                    GOOD := FALSE;
                end if;
            when STATE_FLOW_SEQ_END  =>
                scan_token(SELF, token, token_pos, token_len);
                if (token = TOKEN_FLOW_ENTRY) then
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                    set_struct_state(SELF, STATE_FLOW_SEQ_VAL);
                    LEN  := token_len;
                    GOOD := TRUE;
                else
                    LEN  := 0;
                    GOOD := FALSE;
                end if;
            when others =>
                    LEN  := 0;
                    GOOD := FALSE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_MAP_BEGINを取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    LEN         読み出した文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_map_begin(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  LEN           : out   integer;
                  GOOD          : out   boolean
    ) is
        variable  token         :       TOKEN_TYPE;
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
        variable  found         :       boolean;
        variable  curr_state    :       STATE_TYPE;
        variable  ret_state     :       STATE_TYPE;
        variable  ret_indent    :       INDENT_TYPE;
        variable  new_indent    :       INDENT_TYPE;
    begin
        get_struct_state(SELF, curr_state, ret_indent);
        case curr_state is
            when STATE_DOCUMENT               => ret_state := STATE_DOCUMENT;
            when STATE_FLOW_SEQ_VAL           => ret_state := STATE_FLOW_SEQ_END ;
            when STATE_FLOW_MAP_KEY           => ret_state := STATE_FLOW_MAP_SEP ;
            when STATE_FLOW_MAP_VAL           => ret_state := STATE_FLOW_MAP_END ;
            when STATE_BLOCK_SEQ_VAL          => ret_state := STATE_BLOCK_SEQ_END;
            when STATE_BLOCK_MAP_IMPLICIT_KEY => ret_state := STATE_BLOCK_MAP_IMPLICIT_SEP;
            when STATE_BLOCK_MAP_IMPLICIT_VAL => ret_state := STATE_BLOCK_MAP_IMPLICIT_END;
            when STATE_BLOCK_MAP_EXPLICIT_KEY => ret_state := STATE_BLOCK_MAP_EXPLICIT_SEP;
            when STATE_BLOCK_MAP_EXPLICIT_VAL => ret_state := STATE_BLOCK_MAP_EXPLICIT_END;
            when others                       => GOOD := FALSE;
                                                 return;
        end case;
        new_indent := SELF.text_pos;
        scan_token(SELF, token, token_pos, token_len);
        case token is
            when TOKEN_SCALAR          |
                 TOKEN_LITERAL         |
                 TOKEN_FOLDED          |
                 TOKEN_DOUBLE_QUOTE    |
                 TOKEN_SINGLE_QUOTE    |
                 TOKEN_FLOW_SEQ_BEGIN  =>
                call_struct_state(
                    SELF       => SELF,
                    RET_STATE  => ret_state,
                    RET_INDENT => ret_indent,
                    RET_MAPKEY => MAPKEY_NULL,
                    NEW_STATE  => STATE_BLOCK_MAP_IMPLICIT_KEY,
                    NEW_INDENT => new_indent,
                    NEW_MAPKEY => MAPKEY_READ,
                    GOOD       => GOOD
                );
                LEN := 0;
            when TOKEN_MAP_EXPLICIT_KEY =>
                skip_token(SELF, STREAM, token, token_pos, token_len);
                call_struct_state(
                    SELF       => SELF,
                    RET_STATE  => ret_state,
                    RET_INDENT => ret_indent,
                    NEW_STATE  => STATE_BLOCK_MAP_EXPLICIT_KEY,
                    NEW_INDENT => new_indent,
                    GOOD       => GOOD
                );
                LEN := token_len;
            when TOKEN_FLOW_MAP_BEGIN   =>
                scan_block_map_implicit_key(SELF, found);
                if (found = TRUE) then
                    call_struct_state(
                        SELF       => SELF,
                        RET_STATE  => ret_state,
                        RET_INDENT => ret_indent,
                        RET_MAPKEY => MAPKEY_NULL,
                        NEW_STATE  => STATE_BLOCK_MAP_IMPLICIT_KEY,
                        NEW_INDENT => new_indent,
                        NEW_MAPKEY => MAPKEY_READ,
                        GOOD       => GOOD
                    );
                    LEN := 0;
                else
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                    call_struct_state(
                        SELF       => SELF,
                        RET_STATE  => ret_state,
                        RET_INDENT => ret_indent,
                        NEW_STATE  => STATE_FLOW_MAP_KEY,
                        NEW_INDENT => new_indent,
                        GOOD       => GOOD
                    );
                    LEN := token_len;
                end if;
            when others =>
                LEN  := 0;
                GOOD := FALSE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_MAP_SEPを取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    LEN         読み出した文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_map_sep(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  LEN           : out   integer;
                  GOOD          : out   boolean
    ) is
        variable  curr_state    :       STATE_TYPE;
        variable  curr_indent   :       INDENT_TYPE;
        variable  token         :       TOKEN_TYPE;
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
    begin
        get_struct_state(SELF, curr_state, curr_indent);
        case curr_state is
            when STATE_BLOCK_MAP_IMPLICIT_SEP =>
                scan_token(SELF, token, token_pos, token_len);
                if (token = TOKEN_MAP_SEPARATOR) then
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                    set_struct_state(SELF, STATE_BLOCK_MAP_IMPLICIT_VAL, curr_indent, MAPKEY_NULL);
                    LEN  := token_len;
                    GOOD := TRUE;
                else
                    LEN  := 0;
                    GOOD := FALSE;
                end if;
            when STATE_BLOCK_MAP_EXPLICIT_SEP =>
                scan_token(SELF, token, token_pos, token_len);
                if (token = TOKEN_MAP_SEPARATOR) then
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                    set_struct_state(SELF, STATE_BLOCK_MAP_EXPLICIT_VAL, curr_indent, MAPKEY_NULL);
                    LEN  := token_len;
                    GOOD := TRUE;
                else
                    LEN  := 0;
                    GOOD := FALSE;
                end if;
            when STATE_FLOW_MAP_SEP  =>
                scan_token(SELF, token, token_pos, token_len);
                if (token = TOKEN_MAP_SEPARATOR) then
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                    set_struct_state(SELF, STATE_FLOW_MAP_VAL          , curr_indent, MAPKEY_NULL);
                    LEN  := token_len;
                    GOOD := TRUE;
                else
                    LEN  := 0;
                    GOOD := FALSE;
                end if;
            when others =>
                    LEN  := 0;
                    GOOD := FALSE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_MAP_ENDを取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    LEN         読み出した文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_map_end(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  LEN           : out   integer;
                  GOOD          : out   boolean 
    ) is
        variable  curr_state    :       STATE_TYPE;
        variable  token         :       TOKEN_TYPE;
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
    begin
        get_struct_state(SELF, curr_state);
        case curr_state is
            when STATE_BLOCK_MAP_IMPLICIT_END =>
                LEN := 0;
                return_struct_state(SELF, GOOD);
            when STATE_BLOCK_MAP_EXPLICIT_END => 
                LEN := 0;
                return_struct_state(SELF, GOOD);
            when STATE_FLOW_MAP_END  =>
                scan_token(SELF, token, token_pos, token_len);
                if (token = TOKEN_FLOW_MAP_END) then
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                    return_struct_state(SELF, GOOD);
                    LEN  := token_len;
                else
                    LEN  := 0;
                    GOOD := FALSE;
                end if;
            when others =>
                LEN  := 0;
                GOOD := FALSE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_MAP_NEXTを取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    LEN         読み出した文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_map_next(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  LEN           : out   integer;
                  GOOD          : out   boolean 
    ) is
        variable  curr_state    :       STATE_TYPE;
        variable  token         :       TOKEN_TYPE;
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
    begin
        get_struct_state(SELF, curr_state);
        case curr_state is
            when STATE_BLOCK_MAP_IMPLICIT_END |
                 STATE_BLOCK_MAP_EXPLICIT_END =>
                scan_token(SELF, token, token_pos, token_len);
                if (token = TOKEN_MAP_EXPLICIT_KEY) then
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                    set_struct_state(SELF, STATE_BLOCK_MAP_EXPLICIT_KEY);
                    LEN := token_len;
                else
                    set_struct_state(SELF, STATE_BLOCK_MAP_IMPLICIT_KEY);
                    LEN := 0;
                end if;
                GOOD := TRUE;
            when STATE_FLOW_MAP_END  =>
                scan_token(SELF, token, token_pos, token_len);
                if (token = TOKEN_FLOW_ENTRY) then
                    skip_token(SELF, STREAM, token, token_pos, token_len);
                    set_struct_state(SELF, STATE_FLOW_MAP_KEY);
                    LEN  := token_len;
                    GOOD := TRUE;
                else
                    LEN  := 0;
                    GOOD := FALSE;
                end if;
            when others =>
                    LEN  := 0;
                    GOOD := FALSE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_TAG_PROPを取り出す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    STR         読み取ったタグを格納するバッファ.
    --! @param    STR_LEN     バッファに格納した文字数.
    --! @param    READ_LEN    読み取った文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_tag_prop(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  STR           : out   string;
                  STR_LEN       : out   integer;
                  READ_LEN      : out   integer;
                  GOOD          : out   boolean 
    ) is
        alias     str_buf       :       string(1 to STR'length) is STR;
        variable  string_pos    :       integer;
        variable  string_len    :       integer;
        variable  scan_len      :       integer;
        variable  found         :       boolean;
        variable  end_of_line   :       boolean;
    begin
        scan_tag_prop(SELF, found, scan_len, string_pos, string_len, end_of_line);
        if (found = TRUE) then
            if (string_len <= STR'length) then
                str_buf := (others => ' ');
                str_buf(1 to string_len) := SELF.text_line(string_pos to string_pos + string_len-1);
                STR_LEN := string_len;
            else
                str_buf(1 to STR'length) := SELF.text_line(string_pos to string_pos + STR'length-1);
                STR_LEN := STR'length;
            end if;
            SELF.text_pos := SELF.text_pos + scan_len;
            READ_LEN := scan_len;
            GOOD     := TRUE;
        else
            STR_LEN  := 0;
            READ_LEN := 0;
            GOOD     := FALSE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_ANCHORを取り出す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    STR         読み取ったタグを格納するバッファ.
    --! @param    STR_LEN     バッファに格納した文字数.
    --! @param    READ_LEN    読み取った文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_anchor(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  STR           : out   string;
                  STR_LEN       : out   integer;
                  READ_LEN      : out   integer;
                  GOOD          : out   boolean 
    ) is
        variable  token         :       TOKEN_TYPE;
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
        variable  line_end      :       boolean;
    begin
        scan_token(SELF, token, token_pos, token_len);
        if (token = TOKEN_ANCHOR_PROPERTY) then
            skip_token(SELF, STREAM, token, token_pos, token_len);
            read_plain_scalar(SELF, STR, STR_LEN, READ_LEN, line_end);
            GOOD := TRUE;
        else
            STR_LEN  := 0;
            READ_LEN := 0;
            GOOD     := FALSE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_ALIASを取り出す.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    STR         読み取ったタグを格納するバッファ.
    --! @param    STR_LEN     バッファに格納した文字数.
    --! @param    READ_LEN    読み取った文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_alias(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  STR           : out   string;
                  STR_LEN       : out   integer;
                  READ_LEN      : out   integer;
                  GOOD          : out   boolean 
    ) is
        variable  token         :       TOKEN_TYPE;
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
        variable  line_end      :       boolean;
        variable  curr_state    :       STATE_TYPE;
        variable  next_state    :       STATE_TYPE;
        variable  next_event    :       EVENT_TYPE;
    begin
        scan_token(SELF, token, token_pos, token_len);
        if (token /= TOKEN_ALIAS_NODE) then
            STR_LEN  := 0;
            READ_LEN := 0;
            GOOD     := FALSE;
            return;
        end if;
        get_struct_state(SELF, curr_state);
        case curr_state is
            when STATE_FLOW_SEQ_VAL           => next_state := STATE_FLOW_SEQ_END ;
            when STATE_FLOW_MAP_KEY           => next_state := STATE_FLOW_MAP_SEP ;
            when STATE_FLOW_MAP_VAL           => next_state := STATE_FLOW_MAP_END ;
            when STATE_BLOCK_SEQ_VAL          => next_state := STATE_BLOCK_SEQ_END;
            when STATE_BLOCK_MAP_IMPLICIT_KEY => next_state := STATE_BLOCK_MAP_IMPLICIT_SEP;
            when STATE_BLOCK_MAP_IMPLICIT_VAL => next_state := STATE_BLOCK_MAP_IMPLICIT_END;
            when STATE_BLOCK_MAP_EXPLICIT_KEY => next_state := STATE_BLOCK_MAP_EXPLICIT_SEP;
            when STATE_BLOCK_MAP_EXPLICIT_VAL => next_state := STATE_BLOCK_MAP_EXPLICIT_END;
            when others                       => STR_LEN  := 0;
                                                 READ_LEN := 0;
                                                 GOOD     := FALSE;
                                                 return;
        end case;
        set_struct_state(SELF, next_state);
        skip_token(SELF, STREAM, token, token_pos, token_len);
        read_plain_scalar(SELF, STR, STR_LEN, READ_LEN, line_end);
        SEEK_EVENT(SELF, STREAM, next_event);
        case next_event is
            when  EVENT_SEQ_NEXT => read_seq_next(SELF, STREAM, token_len, GOOD);
            when  EVENT_MAP_NEXT => read_map_next(SELF, STREAM, token_len, GOOD);
            when  EVENT_MAP_SEP  => read_map_sep (SELF, STREAM, token_len, GOOD);
            when  others         => GOOD := TRUE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからliteralの文字列を取り出す
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    TOKEN       リテラルのタイプ
    --! @param    STR         読み取ったタグを格納するバッファ.
    --! @param    STR_LEN     バッファに格納した文字数.
    --! @param    READ_LEN    読み取った文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_literal_string(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  TOKEN         : in    TOKEN_TYPE;
                  STR           : out   string;
                  STR_LEN       : out   integer;
                  READ_LEN      : out   integer;
                  GOOD          : out   boolean 
    ) is
        variable  str_pos       :       integer;
        variable  literal_len   :       integer;
        variable  char          :       character;
        variable  indent        :       integer;
        variable  now_literal   :       boolean;
    begin
        --------------------------------------------------------------------------
        -- まず TOKEN_LITERAL または TOKEN_FOLDED のある行は捨てて次の行を読む.
        --------------------------------------------------------------------------
        read_text_line(SELF, STREAM);
        --------------------------------------------------------------------------
        -- なにか空白以外の文字が含まれる行まで読む.
        --------------------------------------------------------------------------
        now_literal := FALSE;
        indent      := 0;
        literal_len := 0;
        str_pos     := STR'low;
        while(now_literal = FALSE and SELF.end_of_file = FALSE) loop
            for pos in SELF.text_line'low to SELF.text_line'high loop
                char   := SELF.text_line(pos);
                if (char /= ' ' and char /= ht) then
                    now_literal := TRUE;
                    indent := pos;
                    exit;
                end if;
            end loop;
            if (now_literal = FALSE) then
                read_text_line(SELF, STREAM);
                literal_len := literal_len + 1;
                if (str_pos <= STR'high) then
                    STR(str_pos) := LF;
                    str_pos := str_pos + 1;
                end if;
            end if;
        end loop;        
        --------------------------------------------------------------------------
        -- インデント数以下の行まで読み込む.
        --------------------------------------------------------------------------
        while (now_literal = TRUE and SELF.end_of_file = FALSE) loop
            for pos in SELF.text_line'low to SELF.text_end loop
                char := SELF.text_line(pos);
                if (pos >= indent) then
                    literal_len := literal_len + 1;
                    if (str_pos <= STR'high) then
                        STR(str_pos) := char;
                        str_pos := str_pos + 1;
                    end if;
                end if;
            end loop;
            read_text_line(SELF, STREAM);
            for pos in SELF.text_line'low to SELF.text_end loop
                char := SELF.text_line(pos);
                if (pos < indent) then
                    if (char /= ' ' and char /= ht) then
                        now_literal := FALSE;
                        exit;
                    end if;
                end if;
            end loop;
            exit when (now_literal = FALSE);
            literal_len := literal_len + 1;
            if (str_pos <= STR'high) then
                if (TOKEN = TOKEN_FOLDED) then
                    STR(str_pos) := ' ';
                else
                    STR(str_pos) := LF;
                end if;
                str_pos := str_pos + 1;
            end if;
        end loop;
        STR_LEN  := str_pos - STR'low;
        READ_LEN := literal_len;
        GOOD     := TRUE;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_SCALARを文字列(STRING)として読み出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    STR         読み取ったタグを格納するバッファ.
    --! @param    STR_LEN     バッファに格納した文字数.
    --! @param    READ_LEN    読み取った文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure read_scalar(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  STR           : out   string;
                  STR_LEN       : out   integer;
                  READ_LEN      : out   integer;
                  GOOD          : out   boolean 
    ) is
        variable  token         :       TOKEN_TYPE;
        variable  token_pos     :       integer;
        variable  token_len     :       integer;
        variable  curr_state    :       STATE_TYPE;
        variable  line_end      :       boolean;
        variable  next_state    :       STATE_TYPE;
        variable  next_event    :       EVENT_TYPE;
    begin
        get_struct_state(SELF, curr_state);
        case curr_state is
            when STATE_FLOW_SEQ_VAL           => next_state := STATE_FLOW_SEQ_END ;
            when STATE_FLOW_MAP_KEY           => next_state := STATE_FLOW_MAP_SEP ;
            when STATE_FLOW_MAP_VAL           => next_state := STATE_FLOW_MAP_END ;
            when STATE_BLOCK_SEQ_VAL          => next_state := STATE_BLOCK_SEQ_END;
            when STATE_BLOCK_MAP_IMPLICIT_KEY => next_state := STATE_BLOCK_MAP_IMPLICIT_SEP;
            when STATE_BLOCK_MAP_IMPLICIT_VAL => next_state := STATE_BLOCK_MAP_IMPLICIT_END;
            when STATE_BLOCK_MAP_EXPLICIT_KEY => next_state := STATE_BLOCK_MAP_EXPLICIT_SEP;
            when STATE_BLOCK_MAP_EXPLICIT_VAL => next_state := STATE_BLOCK_MAP_EXPLICIT_END;
            when others                       => STR_LEN  := 0;
                                                 READ_LEN := 0;
                                                 GOOD     := FALSE;
                                                 return;
        end case;
        scan_token(SELF, token, token_pos, token_len);
        case token is
            when TOKEN_SCALAR  =>
                read_plain_scalar (SELF, STR, STR_LEN, READ_LEN, line_end);
                set_struct_state(SELF, next_state);
                GOOD := TRUE;
            when TOKEN_SINGLE_QUOTE =>
                read_quoted_string(SELF, STR, STR_LEN, READ_LEN, line_end);
                set_struct_state(SELF, next_state);
                GOOD := TRUE;
            when TOKEN_DOUBLE_QUOTE =>
                read_quoted_string(SELF, STR, STR_LEN, READ_LEN, line_end);
                set_struct_state(SELF, next_state);
                GOOD := TRUE;
            when TOKEN_LITERAL =>
                read_literal_string(SELF, STREAM, token, STR, STR_LEN, READ_LEN, GOOD);
                set_struct_state(SELF, next_state);
            when TOKEN_FOLDED =>
                read_literal_string(SELF, STREAM, token, STR, STR_LEN, READ_LEN, GOOD);
                set_struct_state(SELF, next_state);
            when others =>
                STR_LEN  := 0;
                READ_LEN := 0;
                GOOD     := FALSE;
        end case;
        SEEK_EVENT(SELF, STREAM, next_event);
        case next_event is
            when  EVENT_SEQ_NEXT => read_seq_next(SELF, STREAM, token_len, GOOD);
            when  EVENT_MAP_NEXT => read_map_next(SELF, STREAM, token_len, GOOD);
            when  EVENT_MAP_SEP  => read_map_sep (SELF, STREAM, token_len, GOOD);
            when  others         => null;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_SCALAR,EVENT_TAG_PROP,EVENT_ANCHOR,EVENT_ALIASを
    --!        文字列として取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    STR         読み取ったタグを格納するバッファ.
    --! @param    STR_LEN     バッファに格納した文字数.
    --! @param    READ_LEN    読み取った文字数.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure READ_STRING(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  STR           : out   string;
                  STR_LEN       : out   integer;
                  READ_LEN      : out   integer;
                  GOOD          : out   boolean
    ) is
        variable  next_event    :       EVENT_TYPE;
    begin
        SEEK_EVENT(SELF, STREAM, next_event);
        case next_event is
            when EVENT_SCALAR   => read_scalar  (SELF, STREAM, STR, STR_LEN, READ_LEN, GOOD);
            when EVENT_TAG_PROP => read_tag_prop(SELF, STREAM, STR, STR_LEN, READ_LEN, GOOD);
            when EVENT_ANCHOR   => read_anchor  (SELF, STREAM, STR, STR_LEN, READ_LEN, GOOD);
            when EVENT_ALIAS    => read_alias   (SELF, STREAM, STR, STR_LEN, READ_LEN, GOOD);
            when others         => STR_LEN := 0; READ_LEN := 0; GOOD := FALSE;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_SCALARを整数(INTEGER)として取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    VALUE       読み取った整数値.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure READ_INTEGER(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  VALUE         : out   integer;
                  GOOD          : out   boolean
    ) is
        variable  word          :       string(1 to 128);
        variable  word_len      :       integer;
        variable  read_len      :       integer;
        variable  value_len     :       integer;
    begin
        read_scalar(SELF, STREAM, word, word_len, read_len, GOOD);
        if (word_len > 0) then
            STRING_TO_INTEGER(word(1 to word_len), VALUE, value_len);
            GOOD := TRUE;
        else
            VALUE:= 0;
            GOOD := FALSE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENT_SCALARを真偽値数(BOOLEAN)として取り出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    VALUE       読み取った真偽値.
    --! @param    GOOD        読み取りに成功したことを示す.
    -------------------------------------------------------------------------------
    procedure READ_BOOLEAN(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  VALUE         : out   boolean;
                  GOOD          : out   boolean
    ) is
        variable  word          :       string(1 to 5);
        variable  word_len      :       integer;
        variable  read_len      :       integer;
        variable  value_len     :       integer;
    begin
        read_scalar(SELF, STREAM, word, word_len, read_len, GOOD);
        if (word_len > 0) then
            STRING_TO_BOOLEAN(word(1 to word_len), VALUE, value_len);
            GOOD := (value_len > 0);
        else
            VALUE:= FALSE;
            GOOD := FALSE;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームから指定されたイベントを読み出すサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    EVENT       読み取るイベント.
    --! @param    STR         格納された文字列.
    --! @param    STR_LEN     格納した文字列の文字数.
    --! @param    READ_LEN    ストリームから読み取った文字数.
    --! @param    GOOD        正常に読み取れかどうかを示す.
    -------------------------------------------------------------------------------
    procedure READ_EVENT(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  EVENT         : in    EVENT_TYPE;
                  STR           : out   string;
                  STR_LEN       : out   integer;
                  READ_LEN      : out   integer;
                  GOOD          : out   boolean
    ) is
        variable  next_event    :       EVENT_TYPE;
        variable  dummy_len     :       integer;
    begin
        if (EVENT = EVENT_ERROR) then
            DEBUG_DUMP(SELF, string'("READ_EVENT INTERNAL ERROR"));
            assert (FALSE) report "READ_EVENT INTERNAL ERROR"
            severity FAILURE;
        end if;
        SEEK_EVENT(SELF, STREAM, next_event);
        if (EVENT /= next_event) then
            GOOD := FALSE;
            return;
        end if;
        STR_LEN  := 0;
        case EVENT is
            when EVENT_DOC_BEGIN  => read_doc_begin(SELF, STREAM, READ_LEN, GOOD);
            when EVENT_DOC_END    => read_doc_end  (SELF, STREAM, READ_LEN, GOOD);
            when EVENT_SEQ_BEGIN  => read_seq_begin(SELF, STREAM, READ_LEN, GOOD);
            when EVENT_SEQ_NEXT   => read_seq_next (SELF, STREAM, READ_LEN, GOOD);
            when EVENT_SEQ_END    => read_seq_end  (SELF, STREAM, READ_LEN, GOOD);
            when EVENT_MAP_BEGIN  => read_map_begin(SELF, STREAM, READ_LEN, GOOD);
            when EVENT_MAP_SEP    => read_map_sep  (SELF, STREAM, READ_LEN, GOOD);
            when EVENT_MAP_NEXT   => read_map_next (SELF, STREAM, READ_LEN, GOOD);
            when EVENT_MAP_END    => read_map_end  (SELF, STREAM, READ_LEN, GOOD);
            when EVENT_SCALAR     => read_scalar   (SELF, STREAM, STR, STR_LEN, READ_LEN, GOOD);
            when EVENT_TAG_PROP   => read_tag_prop (SELF, STREAM, STR, STR_LEN, READ_LEN, GOOD);
            when EVENT_ANCHOR     => read_anchor   (SELF, STREAM, STR, STR_LEN, READ_LEN, GOOD);
            when EVENT_ALIAS      => read_alias    (SELF, STREAM, STR, STR_LEN, READ_LEN, GOOD);
            when EVENT_DIRECTIVE  => read_text_line(SELF, STREAM);
                                     READ_LEN := 0; GOOD := TRUE;
            when EVENT_STREAM_END => READ_LEN := 0; GOOD := TRUE;
            when others           => READ_LEN := 0; GOOD := FALSE;
        end case;
        SEEK_EVENT(SELF, STREAM, next_event);
        case next_event is
            when EVENT_SEQ_NEXT => read_seq_next(SELF, STREAM, dummy_len, GOOD);
            when EVENT_MAP_NEXT => read_map_next(SELF, STREAM, dummy_len, GOOD);
            when EVENT_MAP_SEP  => read_map_sep (SELF, STREAM, dummy_len, GOOD);
            when others         => 
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームから指定されたイベントを読み出すサブプログラム.
    --!        ただしスカラー、文字列などは読み捨てる.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    EVENT       読み取るイベント.
    --! @param    GOOD        正常に読み取れかどうかを示す.
    -------------------------------------------------------------------------------
    procedure READ_EVENT(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  EVENT         : in    EVENT_TYPE;
                  GOOD          : out   boolean
    ) is
        variable  str_buf       :       string(1 to 1); -- どうせ捨てるので少なくてもかまわない.
        variable  str_len       :       integer;
        variable  read_len      :       integer;
    begin
        READ_EVENT(SELF, STREAM, EVENT, str_buf, str_len, read_len, GOOD);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENTを読み飛ばすサブプログラム.
    --!        EVENTがMAP_BEGINやSEQ_BEGINの場合は、対応するMAP_ENDまたはSEQ_ENDまで
    --!        読み飛ばすことに注意.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    EVENT       読み取るイベント.
    --! @param    STR_BUF     文字列読み飛ばし用のバッファ.
    --! @param    STR_LEN     バッファに格納した文字数.
    --! @param    GOOD        正常に読み取れかどうかを示す.
    -------------------------------------------------------------------------------
    procedure SKIP_EVENT(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  EVENT         : in    EVENT_TYPE;
                  STR_BUF       : out   string;
                  STR_LEN       : out   integer;
                  GOOD          : out   boolean
    ) is
        variable  end_event     :       EVENT_TYPE;
        variable  next_event    :       EVENT_TYPE;
        variable  skip_done     :       boolean;
        variable  read_good     :       boolean;
        variable  read_len      :       integer;
        variable  dummy_len     :       integer;
    begin
        SEEK_EVENT(SELF, STREAM, next_event);
        if (EVENT /= next_event) then
            GOOD := FALSE;
            return;
        end if;
        STR_LEN  := 0;
        case EVENT is
            when EVENT_DOC_BEGIN  => read_doc_begin(SELF, STREAM, read_len, read_good);
                                     end_event := EVENT_DOC_END;
                                     skip_done := FALSE;
            when EVENT_DOC_END    => read_doc_end  (SELF, STREAM, read_len, read_good);
                                     end_event := EVENT_STREAM_END;
                                     skip_done := TRUE;
            when EVENT_SEQ_BEGIN  => read_seq_begin(SELF, STREAM, read_len, read_good);
                                     end_event := EVENT_SEQ_END;
                                     skip_done := FALSE;
            when EVENT_SEQ_NEXT   => read_seq_next (SELF, STREAM, read_len, read_good);
                                     end_event := EVENT_SEQ_END;
                                     skip_done := FALSE;
            when EVENT_SEQ_END    => read_seq_end  (SELF, STREAM, read_len, read_good);
                                     end_event := EVENT_SEQ_END;
                                     skip_done := TRUE;
            when EVENT_MAP_BEGIN  => read_map_begin(SELF, STREAM, read_len, read_good);
                                     end_event := EVENT_MAP_END;
                                     skip_done := FALSE;
            when EVENT_MAP_SEP    => read_map_sep  (SELF, STREAM, read_len, read_good);
                                     end_event := EVENT_MAP_END;
                                     skip_done := FALSE;
            when EVENT_MAP_NEXT   => read_map_next (SELF, STREAM, read_len, read_good);
                                     end_event := EVENT_MAP_END;
                                     skip_done := FALSE;
            when EVENT_MAP_END    => read_map_end  (SELF, STREAM, read_len, read_good);
                                     end_event := EVENT_MAP_END;
                                     skip_done := TRUE;
            when EVENT_DIRECTIVE  => read_text_line(SELF, STREAM);
                                     end_event := EVENT_DOC_BEGIN;
                                     skip_done := TRUE;
            when EVENT_STREAM_END => end_event := EVENT_STREAM_END;
                                     skip_done := TRUE;
            when EVENT_SCALAR     => read_scalar  (SELF, STREAM, STR_BUF, STR_LEN, read_len, read_good);
                                     end_event := EVENT_SCALAR;
                                     skip_done := TRUE;
            when EVENT_TAG_PROP   => read_tag_prop(SELF, STREAM, STR_BUF, STR_LEN, read_len, read_good);
                                     end_event := EVENT_STREAM_END;
                                     skip_done := FALSE;
            when EVENT_ANCHOR     => read_anchor  (SELF, STREAM, STR_BUF, STR_LEN, read_len, read_good);
                                     end_event := EVENT_STREAM_END;
                                     skip_done := FALSE;
            when EVENT_ALIAS      => read_alias   (SELF, STREAM, STR_BUF, STR_LEN, read_len, read_good);
                                     end_event := EVENT_SCALAR;
                                     skip_done := TRUE;
            when others           => skip_done := TRUE;
                                     read_good := FALSE;
        end case;
        if (read_good = FALSE) then
            GOOD := FALSE;
            return;
        end if;
        while (skip_done = FALSE) loop
            -- DEBUG_DUMP(SELF, string'("SKIP_EVENT LOOP"));
            SEEK_EVENT(SELF, STREAM, next_event);
            if (next_event = end_event) then
                READ_EVENT(SELF, STREAM, next_event, read_good);
                exit;
            end if;
            case next_event is
                when EVENT_DOC_BEGIN  |
                     EVENT_SEQ_BEGIN  |
                     EVENT_MAP_BEGIN  =>
                    SKIP_EVENT(SELF, STREAM, next_event, STR_BUF, STR_LEN, read_good);
                when EVENT_STREAM_END =>
                    READ_EVENT(SELF, STREAM, next_event, read_good);
                    skip_done := TRUE;
                when EVENT_ERROR     =>
                    read_good := FALSE;
                    skip_done := TRUE;
                when others => 
                    READ_EVENT(SELF, STREAM, next_event, read_good);
            end case;
        end loop;
        if (read_good = FALSE) then
            GOOD := FALSE;
            return;
        end if;
        SEEK_EVENT(SELF, STREAM, next_event);
        case next_event is
            when EVENT_SEQ_NEXT => read_seq_next(SELF, STREAM, dummy_len, read_good);
            when EVENT_MAP_NEXT => read_map_next(SELF, STREAM, dummy_len, read_good);
            when EVENT_MAP_SEP  => read_map_sep (SELF, STREAM, dummy_len, read_good);
            when EVENT_ERROR    => read_good := FALSE;
            when others         => 
        end case;
        GOOD := read_good;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief ストリームからEVENTを読み飛ばすサブプログラム.
    --!        EVENTがMAP_BEGINやSEQ_BEGINの場合は、対応するMAP_ENDまたはSEQ_ENDまで
    --!        読み飛ばすことに注意.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SELF        リーダー変数.
    --! @param    STREAM      入力ストリーム.
    --! @param    EVENT       読み取るイベント.
    --! @param    GOOD        正常に読み取れかどうかを示す.
    -------------------------------------------------------------------------------
    procedure SKIP_EVENT(
        variable  SELF          : inout READER_TYPE;
        file      STREAM        :       TEXT;
                  EVENT         : in    EVENT_TYPE;
                  GOOD          : out   boolean
    ) is
        variable  skip_buf      :       string(1 to 1);
        variable  skip_len      :       integer;
    begin
        SKIP_EVENT(SELF, STREAM, EVENT, skip_buf, skip_len, GOOD);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief イベントに対応した文字列.
    -------------------------------------------------------------------------------
    constant  STRING_EVENT_DIRECTIVE   : string := "EVENT_DIRECTIVE"  ;
    constant  STRING_EVENT_DOC_BEGIN   : string := "EVENT_DOC_BEGIN"  ;
    constant  STRING_EVENT_DOC_END     : string := "EVENT_DOC_END"    ;
    constant  STRING_EVENT_STREAM_END  : string := "EVENT_STREAM_END" ;
    constant  STRING_EVENT_SEQ_BEGIN   : string := "EVENT_SEQ_BEGIN"  ;
    constant  STRING_EVENT_SEQ_NEXT    : string := "EVENT_SEQ_NEXT"   ;
    constant  STRING_EVENT_SEQ_END     : string := "EVENT_SEQ_END"    ;
    constant  STRING_EVENT_MAP_BEGIN   : string := "EVENT_MAP_BEGIN"  ;
    constant  STRING_EVENT_MAP_SEP     : string := "EVENT_MAP_SEP"    ;
    constant  STRING_EVENT_MAP_NEXT    : string := "EVENT_MAP_NEXT"   ;
    constant  STRING_EVENT_MAP_END     : string := "EVENT_MAP_END"    ;
    constant  STRING_EVENT_SCALAR      : string := "EVENT_SCALAR"     ;
    constant  STRING_EVENT_TAG_PROP    : string := "EVENT_TAG_PROP"   ;
    constant  STRING_EVENT_ANCHOR      : string := "EVENT_ANCHOR"     ;
    constant  STRING_EVENT_ALIAS       : string := "EVENT_ALIAS"      ;
    constant  STRING_EVENT_ERROR       : string := "EVENT_ERROR "     ;
    -------------------------------------------------------------------------------
    --! @brief イベントを文字列に変換する関数.
    -------------------------------------------------------------------------------
    function  EVENT_TO_STRING(EVENT: EVENT_TYPE) return string is
    begin
        case EVENT is
            when EVENT_DIRECTIVE       => return STRING_EVENT_DIRECTIVE  ;
            when EVENT_DOC_BEGIN       => return STRING_EVENT_DOC_BEGIN  ;
            when EVENT_DOC_END         => return STRING_EVENT_DOC_END    ;
            when EVENT_STREAM_END      => return STRING_EVENT_STREAM_END ;
            when EVENT_SEQ_BEGIN       => return STRING_EVENT_SEQ_BEGIN  ;
            when EVENT_SEQ_NEXT        => return STRING_EVENT_SEQ_NEXT   ;
            when EVENT_SEQ_END         => return STRING_EVENT_SEQ_END    ;
            when EVENT_MAP_BEGIN       => return STRING_EVENT_MAP_BEGIN  ;
            when EVENT_MAP_SEP         => return STRING_EVENT_MAP_SEP    ;
            when EVENT_MAP_NEXT        => return STRING_EVENT_MAP_NEXT   ;
            when EVENT_MAP_END         => return STRING_EVENT_MAP_END    ;
            when EVENT_SCALAR          => return STRING_EVENT_SCALAR     ;
            when EVENT_TAG_PROP        => return STRING_EVENT_TAG_PROP   ;
            when EVENT_ANCHOR          => return STRING_EVENT_ANCHOR     ;
            when EVENT_ALIAS           => return STRING_EVENT_ALIAS      ;
            when EVENT_ERROR           => return STRING_EVENT_ERROR      ;
        end case;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 状態に対応した文字列.
    -------------------------------------------------------------------------------
    constant  STRING_STATE_NONE                   : string := "STATE_NONE"                  ;
    constant  STRING_STATE_DOCUMENT               : string := "STATE_DOCUMENT"              ;
    constant  STRING_STATE_BLOCK_SEQ_VAL          : string := "STATE_BLOCK_SEQ_VAL"         ;
    constant  STRING_STATE_BLOCK_SEQ_END          : string := "STATE_BLOCK_SEQ_END"         ;
    constant  STRING_STATE_BLOCK_MAP_IMPLICIT_KEY : string := "STATE_BLOCK_MAP_IMPLICIT_KEY";
    constant  STRING_STATE_BLOCK_MAP_IMPLICIT_SEP : string := "STATE_BLOCK_MAP_IMPLICIT_SEP";
    constant  STRING_STATE_BLOCK_MAP_IMPLICIT_VAL : string := "STATE_BLOCK_MAP_IMPLICIT_VAL";
    constant  STRING_STATE_BLOCK_MAP_IMPLICIT_END : string := "STATE_BLOCK_MAP_IMPLICIT_END";
    constant  STRING_STATE_BLOCK_MAP_EXPLICIT_KEY : string := "STATE_BLOCK_MAP_EXPLICIT_KEY";
    constant  STRING_STATE_BLOCK_MAP_EXPLICIT_SEP : string := "STATE_BLOCK_MAP_EXPLICIT_SEP";
    constant  STRING_STATE_BLOCK_MAP_EXPLICIT_VAL : string := "STATE_BLOCK_MAP_EXPLICIT_VAL";
    constant  STRING_STATE_BLOCK_MAP_EXPLICIT_END : string := "STATE_BLOCK_MAP_EXPLICIT_END";
    constant  STRING_STATE_FLOW_SEQ_VAL           : string := "STATE_FLOW_SEQ_VAL"          ;
    constant  STRING_STATE_FLOW_SEQ_END           : string := "STATE_FLOW_SEQ_END"          ;
    constant  STRING_STATE_FLOW_MAP_KEY           : string := "STATE_FLOW_MAP_KEY"          ;
    constant  STRING_STATE_FLOW_MAP_VAL           : string := "STATE_FLOW_MAP_VAL"          ;
    constant  STRING_STATE_FLOW_MAP_SEP           : string := "STATE_FLOW_MAP_SEP"          ;
    constant  STRING_STATE_FLOW_MAP_END           : string := "STATE_FLOW_MAP_END"          ;
    constant  STRING_STATE_ERROR                  : string := "STATE_ERROR"                 ;
    -------------------------------------------------------------------------------
    --! @brief 状態を文字列に変換する関数.
    -------------------------------------------------------------------------------
    function  struct_state_to_string(state: STATE_TYPE) return string
    is
    begin
        case(state) is
            when STATE_NONE                   => return STRING_STATE_NONE                   ;
            when STATE_DOCUMENT               => return STRING_STATE_DOCUMENT               ;
            when STATE_BLOCK_SEQ_VAL          => return STRING_STATE_BLOCK_SEQ_VAL          ;
            when STATE_BLOCK_SEQ_END          => return STRING_STATE_BLOCK_SEQ_END          ;
            when STATE_BLOCK_MAP_IMPLICIT_KEY => return STRING_STATE_BLOCK_MAP_IMPLICIT_KEY ;
            when STATE_BLOCK_MAP_IMPLICIT_SEP => return STRING_STATE_BLOCK_MAP_IMPLICIT_SEP ;
            when STATE_BLOCK_MAP_IMPLICIT_VAL => return STRING_STATE_BLOCK_MAP_IMPLICIT_VAL ;
            when STATE_BLOCK_MAP_IMPLICIT_END => return STRING_STATE_BLOCK_MAP_IMPLICIT_END ;
            when STATE_BLOCK_MAP_EXPLICIT_KEY => return STRING_STATE_BLOCK_MAP_EXPLICIT_KEY ;
            when STATE_BLOCK_MAP_EXPLICIT_SEP => return STRING_STATE_BLOCK_MAP_EXPLICIT_SEP ;
            when STATE_BLOCK_MAP_EXPLICIT_VAL => return STRING_STATE_BLOCK_MAP_EXPLICIT_VAL ;
            when STATE_BLOCK_MAP_EXPLICIT_END => return STRING_STATE_BLOCK_MAP_EXPLICIT_END ;
            when STATE_FLOW_SEQ_VAL           => return STRING_STATE_FLOW_SEQ_VAL           ;
            when STATE_FLOW_SEQ_END           => return STRING_STATE_FLOW_SEQ_END           ;
            when STATE_FLOW_MAP_KEY           => return STRING_STATE_FLOW_MAP_KEY           ;
            when STATE_FLOW_MAP_VAL           => return STRING_STATE_FLOW_MAP_VAL           ;
            when STATE_FLOW_MAP_SEP           => return STRING_STATE_FLOW_MAP_SEP           ;
            when STATE_FLOW_MAP_END           => return STRING_STATE_FLOW_MAP_END           ;
            when others                       => return STRING_STATE_ERROR                  ;
        end case;
    end function;
    -------------------------------------------------------------------------------
    --! @brief MAPKEY_MODE に対応した文字列.
    -------------------------------------------------------------------------------
    constant  STRING_MAPKEY_NULL       : string := "MAPKEY_NULL" ;
    constant  STRING_MAPKEY_FOUND      : string := "MAPKEY_FOUND";
    constant  STRING_MAPKEY_READ       : string := "MAPKEY_READ" ;
    constant  STRING_MAPKEY_ERROR      : string := "MAPKEY_ERROR";
    -------------------------------------------------------------------------------
    --! @brief MAPKEY_MODE を文字列に変換する関数.
    -------------------------------------------------------------------------------
    function  struct_mapkey_to_string(mapkey: MAPKEY_MODE) return string is
    begin
        case (mapkey) is
            when MAPKEY_NULL  => return STRING_MAPKEY_NULL ;
            when MAPKEY_FOUND => return STRING_MAPKEY_FOUND;
            when MAPKEY_READ  => return STRING_MAPKEY_READ ;
            when others       => return STRING_MAPKEY_ERROR;
        end case;
    end function;
    -------------------------------------------------------------------------------
    --! @brief 標準出力にリーダーの状態をダンプするサブプログラム.
    -------------------------------------------------------------------------------
    procedure DEBUG_DUMP (
        variable  SELF          : inout READER_TYPE;
                  MESSAGE       : in    string
    ) is
        variable  text_line     :       LINE;
    begin
        WRITE(text_line, "message    : " & MESSAGE);
        WRITELINE(OUTPUT, text_line);
        DEBUG_DUMP(SELF);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 標準出力にリーダーの状態をダンプするサブプログラム.
    -------------------------------------------------------------------------------
    procedure DEBUG_DUMP (
        variable  SELF          : inout READER_TYPE
    ) is
    begin
        DEBUG_DUMP(SELF, SELF.text_pos);
    end procedure;        
    -------------------------------------------------------------------------------
    --! @brief 標準出力にリーダーの状態をダンプするサブプログラム.
    -------------------------------------------------------------------------------
    procedure DEBUG_DUMP (
        variable  SELF          : inout READER_TYPE;
                  POS           : in    integer
    ) is
        variable  text_line     :       LINE;
        variable  state         :       STATE_TYPE;
        variable  indent        :       INDENT_TYPE;
        variable  mapkey        :       MAPKEY_MODE;
    begin
        if TRUE then
            get_struct_state(SELF, state, indent, mapkey);
            WRITE(text_line, "   name       : " & SELF.name(SELF.name'range));
            WRITELINE(OUTPUT, text_line);
            WRITE(text_line, "   stream_name: " & SELF.stream_name(SELF.stream_name'range) &
                                            "(" & INTEGER_TO_STRING(SELF.line_num) &
                                            "," & INTEGER_TO_STRING(SELF.text_pos) &
                                            "," & INTEGER_TO_STRING(SELF.text_end) & ")");
            WRITELINE(OUTPUT, text_line);
            WRITE(text_line, "   curr_state : " & struct_state_to_string(state)    &
                                            "(" & INTEGER_TO_STRING(indent)        &
                                            "," & struct_mapkey_to_string(mapkey)  & ")");
                                        
            WRITELINE(OUTPUT, text_line);
        end if;
        for i in SELF.state_top-1 downto SELF.state_stack'low loop
            unpack_struct_state_value(SELF.state_stack(i),state,indent,mapkey);
            WRITE(text_line, "   prev_state : " & struct_state_to_string(state)    &
                                            "(" & INTEGER_TO_STRING(indent)        &
                                            "," & struct_mapkey_to_string(mapkey)  & ")");
            WRITELINE(OUTPUT, text_line);
        end loop;
        if (SELF.text_line = null) then
            WRITE(text_line, string'("   text_line  : null "));
        else
            WRITE(text_line, "   text_line  : " & SELF.text_line(SELF.text_line'range));
            WRITELINE(OUTPUT, text_line);
            WRITE(text_line, string'("               |"));
            for i in SELF.text_line'low to SELF.text_line'high loop
                if (i = POS) then
                    WRITE(text_line, string'("^"));
                else
                    WRITE(text_line, string'(" "));
                end if;
            end loop;
        end if;
        WRITE(text_line, string'("|"));
        WRITELINE(OUTPUT, text_line);
    end procedure;
end READER;
