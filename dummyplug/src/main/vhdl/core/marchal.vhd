-----------------------------------------------------------------------------------
--!     @file    marchal.vhd
--!     @brief   Marchal Dummy Plug Player.
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
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_SIG_VECTOR;
-----------------------------------------------------------------------------------
--! @brief   MARCHAL
-----------------------------------------------------------------------------------
entity  MARCHAL is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_WIDTH      : --! @brief シンクロ用信号のビット幅.
                          integer :=  1;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        --------------------------------------------------------------------------
        --! グローバルシグナル.
        --------------------------------------------------------------------------
        CLK             : in    std_logic;
        --------------------------------------------------------------------------
        --! グローバルシグナル.
        --------------------------------------------------------------------------
        RESET           : out   std_logic;
        --------------------------------------------------------------------------
        --! シンクロ用信号
        --------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR(SYNC_WIDTH-1 downto 0);
        --------------------------------------------------------------------------
        --! レポートステータス出力.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        --! シミュレーション終了通知信号.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end MARCHAL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.CORE.all;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.all;
use     DUMMY_PLUG.VOCAL.all;
use     DUMMY_PLUG.READER.all;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
architecture MODEL of MARCHAL is
    -------------------------------------------------------------------------------
    --! SYNC 制御信号
    -------------------------------------------------------------------------------
    signal    sync_req          : SYNC_REQ_VECTOR(SYNC'range);
    signal    sync_ack          : SYNC_ACK_VECTOR(SYNC'range);
    signal    sync_rst          : std_logic := '0';
    signal    sync_clr          : std_logic := '0';
    signal    sync_debug        : boolean   := FALSE;
    -------------------------------------------------------------------------------
    --! TIME_KEEPER
    -------------------------------------------------------------------------------
    subtype   TIMER_TIME_TYPE   is unsigned(63 downto 0);
    constant  DEFAULT_TIMEOUT   : TIMER_TIME_TYPE := (others => '1');
    signal    timer_reset       : boolean := TRUE;
    signal    timer_valid       : boolean := TRUE;
    signal    timer             : TIMER_TIME_TYPE := DEFAULT_TIMEOUT;
    signal    timeout_time      : TIMER_TIME_TYPE := DEFAULT_TIMEOUT;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    MAIN: process
        file      stream        : TEXT;
        variable  core          : CORE_TYPE;
        variable  operation     : OPERATION_TYPE;
        variable  keyword       : STRING(1 to 3);
        constant  KEY_SAY       : STRING(1 to 3) := "SAY";
        constant  KEY_DEBUG     : STRING(1 to 3) := "DEB";
        constant  KEY_REPORT    : STRING(1 to 3) := "REP";
        constant  KEY_SYNC      : STRING(1 to 3) := "SYN";
        constant  KEY_WAIT      : STRING(1 to 3) := "WAI";
        constant  KEY_TIMEOUT   : STRING(1 to 3) := "TIM";
        ---------------------------------------------------------------------------
        --! @brief  TIMEOUTオペレーション.タイムアウトの設定を行う.
        ---------------------------------------------------------------------------
        procedure EXECUTE_TIMEOUT is
            constant PROC_NAME  : string := "EXECUTE_TIMEOUT";
            variable next_event : EVENT_TYPE;
            variable valid      : boolean;
            variable count      : std_logic_vector(TIMER_TIME_TYPE'range);
            variable valid_len  : integer;
            variable count_len  : integer;
        begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            case next_event is
                when EVENT_SCALAR =>
                    READ_EVENT(core, stream, EVENT_SCALAR);
                    STRING_TO_STD_LOGIC_VECTOR(core.str_buf(1 to core.str_len), count, count_len);
                    if (count_len > 0) then
                        timeout_time <= unsigned(count);
                    else
                        STRING_TO_BOOLEAN     (core.str_buf(1 to core.str_len), valid, valid_len);
                        if (valid_len > 0) then
                            timer_valid <= valid;
                        else
                            READ_ERROR(core, PROC_NAME, "Invalid Parameter(" &
                                       core.str_buf(1 to core.str_len) & ")");
                        end if;
                    end if;
                when others =>
                    READ_ERROR(core, PROC_NAME, "SEEK_EVENT NG");
            end case;
            REPORT_DEBUG(core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  WAITオペレーション. 指定された条件まで待機.
        ---------------------------------------------------------------------------
        procedure EXECUTE_WAIT is
            constant PROC_NAME  : string := "EXECUTE_WAIT";
            variable next_event : EVENT_TYPE;
            variable wait_count : integer;
            variable scan_len   : integer;
         begin
            REPORT_DEBUG(core, PROC_NAME, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            case next_event is
                when EVENT_SCALAR =>
                    READ_EVENT(core, stream, EVENT_SCALAR);
                    STRING_TO_INTEGER(core.str_buf(1 to core.str_len), wait_count, scan_len);
                    if (scan_len = 0) then
                        wait_count := 1;
                    end if;
                    if (wait_count > 0) then
                        for i in 1 to wait_count loop
                            wait until (CLK'event and CLK = '1');
                        end loop;
                    end if;
                    wait_count := 0;
                when others =>
                    READ_ERROR(core, PROC_NAME, "SEEK_EVENT NG");
            end case;
            REPORT_DEBUG(core, PROC_NAME, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  SYNCオペレーション. 
        ---------------------------------------------------------------------------
        procedure EXECUTE_SYNC(operation: in OPERATION_TYPE) is
            constant PROC_NAME  : string := "EXECUTE_SYNC";
            variable port_num   : integer;
            variable wait_num   : integer;
        begin
            REPORT_DEBUG  (core, PROC_NAME, "BEGIN");
            READ_SYNC_ARGS(core, stream, operation, port_num, wait_num);
            REPORT_DEBUG  (core, PROC_NAME, "PORT=" & INTEGER_TO_STRING(port_num) &
                                           " WAIT=" & INTEGER_TO_STRING(wait_num));
            if (SYNC_REQ'low <= port_num and port_num <= SYNC_REQ'high) then
                CORE_SYNC(core, port_num, wait_num, SYNC_REQ, SYNC_ACK);
            end if;
            REPORT_DEBUG  (core, PROC_NAME, "END");
        end procedure;
    begin
        ---------------------------------------------------------------------------
        --! ダミープラグコアの初期化.
        ---------------------------------------------------------------------------
        CORE_INIT(
            SELF        => core,          --! 初期化するコア変数.
            NAME        => NAME,          --! コアの名前.
            STREAM      => stream,        --! シナリオのストリーム.
            STREAM_NAME => SCENARIO_FILE, --! シナリオのストリーム名.
            OPERATION   => operation      --! コアのオペレーション.
        );
        ---------------------------------------------------------------------------
        --! リセット信号の生成.
        ---------------------------------------------------------------------------
        REPORT_STATUS <= core.report_status;
        sync_req <= (0 => 0, others => -1);
        FINISH   <= '0';
        sync_rst <= '1';
        sync_clr <= '0';
        RESET    <= '1';
        wait until(CLK'event and CLK = '1');
        sync_rst <= '0';
        RESET    <= '0';
        wait until(CLK'event and CLK = '1');
        ---------------------------------------------------------------------------
        --! ダミーコアメインループ
        ---------------------------------------------------------------------------
        core.debug := 0;
        MAIN_LOOP: while (operation /= OP_FINISH) loop
            REPORT_STATUS <= core.report_status;
            READ_OPERATION(core, stream, operation, keyword);
            case operation is
                when OP_DOC_BEGIN =>
                    timer_reset  <= TRUE, FALSE after 1 ns;
                    CORE_SYNC(core, 0, 2, sync_req, sync_ack);
                when OP_MAP    =>
                    case keyword is
                        when KEY_SYNC   => EXECUTE_SYNC  (operation);
                        when KEY_WAIT   => EXECUTE_WAIT;
                        when KEY_TIMEOUT=> EXECUTE_TIMEOUT;
                        when KEY_SAY    => EXECUTE_SAY   (core, stream);
                        when KEY_DEBUG  => EXECUTE_DEBUG (core, stream);
                        when KEY_REPORT => EXECUTE_REPORT(core, stream);
                        when others     => EXECUTE_SKIP  (core, stream);
                    end case;
                when OP_SCALAR =>
                    case keyword is
                        when KEY_SYNC   => EXECUTE_SYNC  (operation);
                        when others     => null;
                    end case;
                when OP_FINISH => exit;
                when others    => null;
            end case;
        end loop;
        REPORT_STATUS <= core.report_status;
        FINISH <= '1';
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete." severity FAILURE;
        end if;
        wait;
    end process;
    -------------------------------------------------------------------------------
    --! @brief タイムキーパー
    -------------------------------------------------------------------------------
    TIME_KEEPER: process(timer_reset, CLK)
        variable vocal : VOCAL_TYPE := NEW_VOCAL(NAME);
    begin
        if (timer_reset) then
            timer <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (timer_valid) then
                if (timer < timeout_time) then
                    timer <= timer + 1;
                else
                    REPORT_FAILURE(vocal, string'("Time Out!"));
                    assert FALSE report "Time Out!" severity FAILURE;
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --! @ SYNC制御
    -------------------------------------------------------------------------------
    SYNC_DRIVER: for i in SYNC'range generate
        UNIT: SYNC_SIG_DRIVER
            generic map (
                NAME     => string'("MARCHAL:SYNC"),
                PLUG_NUM => SYNC_PLUG_NUM
            )
            port map (
                CLK      => CLK ,                -- In :
                RST      => sync_rst,            -- In :
                CLR      => sync_clr,            -- In :
                DEBUG    => sync_debug,          -- In :
                SYNC     => SYNC(i),             -- I/O:
                REQ      => sync_req(i),         -- In :
                ACK      => sync_ack(i)          -- Out:
            );
    end generate;
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
