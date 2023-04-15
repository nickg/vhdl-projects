-----------------------------------------------------------------------------------
--!     @file    sync.vhd
--!     @brief   Package for Synchronize some dummy-plugs.
--!     @version 1.7.4
--!     @date    2020/9/21
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
-----------------------------------------------------------------------------------
--! @brief Dummy Plug のモデル間で同期するためのパッケージ.
--!      * 同期のための信号が1bitのstd_logicになっているバージョン.
-----------------------------------------------------------------------------------
package SYNC is
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)できる本数の最大値.
    --!        ただしこのパッケージでは意味が無い.
    -------------------------------------------------------------------------------
    constant  SYNC_MAX_PLUG_SIZE: integer := 32;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)できる本数を指定するタイプ宣言.
    -------------------------------------------------------------------------------
    subtype   SYNC_PLUG_NUM_TYPE   is integer range 1 to SYNC_MAX_PLUG_SIZE;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)のための信号のタイプ宣言.
    -------------------------------------------------------------------------------
    alias     SYNC_SIG_TYPE        is std_logic;
    type      SYNC_SIG_VECTOR      is array (INTEGER range <>) of SYNC_SIG_TYPE;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)のための信号を制御するための信号のタイプ宣言.
    -------------------------------------------------------------------------------
    subtype   SYNC_REQ_TYPE        is integer;
    subtype   SYNC_ACK_TYPE        is std_logic;
    type      SYNC_REQ_VECTOR      is array (INTEGER range <>) of SYNC_REQ_TYPE;
    type      SYNC_ACK_VECTOR      is array (INTEGER range <>) of SYNC_ACK_TYPE;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)開始サブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SYNC_REQ    同期開始信号出力.
    --! @param    SYNC_CNT    同期ウェイトクロック数.
    -------------------------------------------------------------------------------
    procedure SYNC_BEGIN(
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
                 SYNC_CNT : in    SYNC_REQ_VECTOR
    );
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)が完了したかどうかを調べるサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SYNC_REQ    同期開始信号出力.
    --! @param    SYNC_ACK    同期応答信号入力.
    --! @param    SYNC_CNT    同期ウェイトクロック数.
    --! @param    DONE        終了フラグ.
    -------------------------------------------------------------------------------
    procedure SYNC_CHECK(
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
        signal   SYNC_ACK : in    SYNC_ACK_VECTOR;
                 SYNC_CNT : inout SYNC_REQ_VECTOR;
                 DONE     : out   boolean
    );
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)終了サブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SYNC_REQ    同期開始信号出力.
    --! @param    SYNC_ACK    同期応答信号入力.
    --! @param    SYNC_CNT    同期ウェイトクロック数.
    -------------------------------------------------------------------------------
    procedure SYNC_END  (
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
        signal   SYNC_ACK : in    SYNC_ACK_VECTOR;
                 SYNC_CNT : in    SYNC_REQ_VECTOR
    );
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)信号を制御するコンポーネント.
    -------------------------------------------------------------------------------
    component SYNC_SIG_DRIVER
        generic (                                              -- 
            NAME     :       STRING             := "";         --! デバッグ出力用の名前.
            PLUG_NUM :       SYNC_PLUG_NUM_TYPE := 1           --! プラグの番号.
        );                                                     -- 
        port (                                                 -- 
            CLK      : in    std_logic;                        --! クロック.
            RST      : in    std_logic;                        --! 非同期リセット.
            CLR      : in    std_logic;                        --! 同期リセット.
            DEBUG    : in    boolean;                          --! デバッグ出力をするための信号.
            SYNC     : inout SYNC_SIG_TYPE;                    --! モデル間同期用入出力信号.
            REQ      : in    SYNC_REQ_TYPE;                    --! 同期要求入力信号.
            ACK      : out   SYNC_ACK_TYPE                     --! 同期応答出力信号.
        );                                                     -- 
    end component;
    -------------------------------------------------------------------------------
    --! @brief モジュール内でローカルにモデル間同期するためのコンポーネント.
    -------------------------------------------------------------------------------
    component SYNC_LOCAL_HUB
        generic (                                              -- 
            NAME     :       STRING             := "";         --! デバッグ出力用の名前.
            PLUG_SIZE:       SYNC_PLUG_NUM_TYPE := 1           --! 接続するモデルの数.
        );                                                     -- 
        port (                                                 -- 
            CLK      : in    std_logic;                        --! クロック.
            RST      : in    std_logic;                        --! 非同期リセット.
            CLR      : in    std_logic;                        --! 同期リセット.
            DEBUG    : in    boolean;                          --! デバッグ出力をするための信号.
            SYNC     : inout SYNC_SIG_TYPE;                    --! モデル間同期用入出力信号.
            REQ      : in    SYNC_REQ_VECTOR(1 to PLUG_SIZE);  --! 同期要求入力信号.
            ACK      : out   SYNC_ACK_VECTOR(1 to PLUG_SIZE)   --! 同期応答出力信号.
        );                                                     -- 
    end component;
    -------------------------------------------------------------------------------
    --! @brief 同期信号の値を標準出力に出力するコンポーネント.
    -------------------------------------------------------------------------------
    component SYNC_PRINT
        generic( NAME     :       STRING := "");
        port   ( SYNC     : in    SYNC_SIG_TYPE);
    end component;
end package;
-----------------------------------------------------------------------------------
-- SYNC :
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
-----------------------------------------------------------------------------------
--! @brief Dummy Plug のモデル間で同期するためのパッケージ.
-----------------------------------------------------------------------------------
package body SYNC is
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)開始サブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SYNC_REQ    同期開始信号出力.
    --! @param    SYNC_CNT    同期ウェイトクロック数.
    -------------------------------------------------------------------------------
    procedure SYNC_BEGIN(
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
                 SYNC_CNT : in    SYNC_REQ_VECTOR
    ) is
    begin
        ---------------------------------------------------------------------------
        -- SYNC_REQ信号に SYNC_CNT を出力.
        ---------------------------------------------------------------------------
        SYNC_REQ <= SYNC_CNT;
        ---------------------------------------------------------------------------
        -- SYNC_CNTの値がSYNC_REQ信号に反映されるまでのΔ時間だけ待つ.
        ---------------------------------------------------------------------------
        wait for 0 ns;
        ---------------------------------------------------------------------------
        -- SYNC_SIG_DRIVER にて SYNC_REQ信号が変化して SYNC 信号に反映されるまでの
        -- Δ時間だけ待つ.
        ---------------------------------------------------------------------------
        wait for 0 ns;
        ---------------------------------------------------------------------------
        -- SYNC_SIG_DRIVER にて SYNC信号が変化して SYNC_ACK 信号に反映されるまで
        -- のΔ時間だけ待つ.
        ---------------------------------------------------------------------------
        wait for 0 ns;
    end SYNC_BEGIN;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)が完了したかどうかを調べるサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SYNC_REQ    同期開始信号出力.
    --! @param    SYNC_ACK    同期応答信号入力.
    --! @param    SYNC_CNT    同期ウェイトクロック数.
    --! @param    DONE        終了フラグ.
    -------------------------------------------------------------------------------
    procedure SYNC_CHECK(
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
        signal   SYNC_ACK : in    SYNC_ACK_VECTOR;
                 SYNC_CNT : inout SYNC_REQ_VECTOR;
                 DONE     : out   boolean
    ) is 
        variable use_sync :       std_logic_vector(SYNC_CNT'range);
        constant all_done :       std_logic_vector(SYNC_CNT'range) := (others => '0');
    begin
        use_sync := (others => '1');
        for i in SYNC_CNT'range loop
            if (SYNC_CNT(i) > 0 and SYNC_ACK(i) = '1') then
                SYNC_CNT(i) := 0;
                SYNC_REQ(i) <= 0;
            end if;
            if (SYNC_CNT(i) > 0) then
                use_sync(i) := '1';
            else
                use_sync(i) := '0';
            end if;
        end loop;
        DONE := (use_sync = all_done);
    end SYNC_CHECK;
    -------------------------------------------------------------------------------
    --! @brief モデル間同期(SYNC)終了サブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    SYNC_REQ    同期開始信号出力.
    --! @param    SYNC_ACK    同期応答信号入力.
    --! @param    SYNC_CNT    同期ウェイトクロック数.
    -------------------------------------------------------------------------------
    procedure SYNC_END  (
        signal   SYNC_REQ : out   SYNC_REQ_VECTOR;
        signal   SYNC_ACK : in    SYNC_ACK_VECTOR;
                 SYNC_CNT : in    SYNC_REQ_VECTOR
    ) is 
        variable count    :       SYNC_REQ_VECTOR (SYNC_CNT'range);
        variable done     :       boolean;
    begin
        count := SYNC_CNT;
        ---------------------------------------------------------------------------
        -- SYNC_CHECKを実行して done が TRUE になるまで待つループ.
        ---------------------------------------------------------------------------
        WAIT_SYNC_ACK_LOOP : loop
            SYNC_CHECK(SYNC_REQ => SYNC_REQ, -- Out: SYNC_REQ_VECTOR;
                       SYNC_ACK => SYNC_ACK, -- In : SYNC_ACK_VECTOR;
                       SYNC_CNT => count,    -- I/O: SYNC_REQ_VECTOR;
                       DONE     => done);    -- Out: boolean;
            exit when done;
            wait on SYNC_ACK; -- 超重要 これがないとシミュレーターが無限ループに陥る
        end loop;
        ---------------------------------------------------------------------------
        -- SYNC_CNTをクリアしたのがSYNC_REQ信号に反映されるまでのΔ時間だけ待つ.
        ---------------------------------------------------------------------------
        wait for 0 ns;
    end SYNC_END;
end package body;
-----------------------------------------------------------------------------------
-- SYNC_SIG_DRIVER : 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.SYNC.all;
-----------------------------------------------------------------------------------
--! @brief モデル間同期(SYNC)信号を制御するコンポーネント.
-----------------------------------------------------------------------------------
entity  SYNC_SIG_DRIVER is
    generic (                                              -- 
        NAME     :       STRING             := "";         --! デバッグ出力用の名前.
        PLUG_NUM :       SYNC_PLUG_NUM_TYPE := 1           --! プラグの番号.
    );                                                     -- 
    port (                                                 -- 
        CLK      : in    std_logic;                        --! クロック.
        RST      : in    std_logic;                        --! 非同期リセット.
        CLR      : in    std_logic;                        --! 同期リセット.
        DEBUG    : in    boolean;                          --! デバッグ出力をするための信号.
        SYNC     : inout SYNC_SIG_TYPE;                    --! モデル間同期用入出力信号.
        REQ      : in    SYNC_REQ_TYPE;                    --! 同期要求入力信号.
        ACK      : out   SYNC_ACK_TYPE                     --! 同期応答出力信号.
    );                                                     -- 
end     SYNC_SIG_DRIVER;
architecture MODEL of SYNC_SIG_DRIVER is
    procedure REPORT_DEBUG(MESSAGE: STRING) is
        variable text_line  : line;
    begin
        if (DEBUG) then
            WRITE(text_line, Now, RIGHT,  13);
            WRITE(text_line, string'(" (") & NAME & ") SYNC_SIG_DRIVER:");
            WRITE(text_line, MESSAGE);
            WRITELINE(OUTPUT, text_line);
        end if;
    end procedure;
begin
    process 
        variable sync_delay : integer;
    begin
        SYNC   <= 'Z';
        ACK    <= '0';
        SYNC_LOOP: loop
            if (REQ > 0) then
                REPORT_DEBUG(string'("REQ>0"));
                sync_delay := REQ;
                if (sync_delay >= 2) then
                    for i in 2 to sync_delay loop
                        wait until (CLK'event and CLK = '1');
                    end loop;
                end if;
                SYNC   <= 'H';
                REPORT_DEBUG(string'("WAIT SYNC START"));
                wait until (SYNC = '1' or SYNC = 'H');
                REPORT_DEBUG(string'("WAIT SYNC DONE"));
                SYNC   <= '0';
                ACK    <= '1';
                REPORT_DEBUG(string'("WAIT REQ START"));
                wait until (REQ = 0);
                REPORT_DEBUG(string'("WAIT REQ DONE"));
                ACK    <= '0';
            elsif (REQ = 0) then
                REPORT_DEBUG(string'("REQ=0"));
                SYNC   <= '0';
            else
                REPORT_DEBUG(string'("REQ<0"));
                SYNC   <= 'Z';
            end if;
            wait on REQ;
        end loop;
    end process;
end MODEL;
-----------------------------------------------------------------------------------
-- SYNC_LOCAL_HUB : 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
-----------------------------------------------------------------------------------
--! @brief モジュール内でローカルにモデル間同期するためのコンポーネント.
-----------------------------------------------------------------------------------
entity SYNC_LOCAL_HUB is
    generic (                                              -- 
        NAME     :       STRING             := "";         --! デバッグ出力用の名前.
        PLUG_SIZE:       SYNC_PLUG_NUM_TYPE := 1           --! 接続するモデルの数.
    );                                                     -- 
    port (                                                 -- 
        CLK      : in    std_logic;                        --! クロック.
        RST      : in    std_logic;                        --! 非同期リセット.
        CLR      : in    std_logic;                        --! 同期リセット.
        DEBUG    : in    boolean;                          --! デバッグ出力をするための信号.
        SYNC     : inout SYNC_SIG_TYPE;                    --! モデル間同期用入出力信号.
        REQ      : in    SYNC_REQ_VECTOR(1 to PLUG_SIZE);  --! 同期要求入力信号.
        ACK      : out   SYNC_ACK_VECTOR(1 to PLUG_SIZE)   --! 同期応答出力信号.
    );                                                     -- 
end SYNC_LOCAL_HUB;
architecture MODEL of SYNC_LOCAL_HUB is
begin
    PLUG : for i in 1 to PLUG_SIZE generate
        DRIVER : SYNC_SIG_DRIVER
            generic map (
                NAME     => NAME & "(" & INTEGER_TO_STRING(i) & ")",
                PLUG_NUM => i
            )
            port map (
                CLK      => CLK   ,   --! In  : 
                RST      => RST   ,   --! In  : 
                CLR      => CLR   ,   --! In  : 
                DEBUG    => DEBUG ,   --! In  : 
                SYNC     => sync  ,   --! I/O : 
                REQ      => REQ(i),   --! In  : 
                ACK      => ACK(i)    --! Out : 
            );
    end generate;
end MODEL;
----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.BIN_TO_STRING;
-----------------------------------------------------------------------------------
--! @brief 同期信号の値を標準出力に出力するコンポーネント.
-----------------------------------------------------------------------------------
entity  SYNC_PRINT is
    generic(NAME:    STRING  := "");
    port   (SYNC: in SYNC_SIG_TYPE);
end SYNC_PRINT;
architecture MODEL of SYNC_PRINT is
begin
    process (SYNC)
        variable text_line : line;
    begin
        WRITE(text_line, Now, RIGHT,  13);
        WRITE(text_line, string'(" (") & NAME & ") ");
        WRITE(text_line, BIN_TO_STRING(SYNC));
        WRITELINE(OUTPUT, text_line);
    end process;
end MODEL;
----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------
