-----------------------------------------------------------------------------------
--!     @file    test_bench.vhd
--!     @brief   QUEUE_ARBITER TEST BENCH :
--!              QUEUE_ARBITER を検証するためのテストベンチ.
--!     @version 1.7.0
--!     @date    2018/3/22
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2013-2018 Ichiro Kawazome
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
--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all; 
use     std.textio.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.QUEUE_ARBITER;
--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------
entity  TEST_BENCH is 
end     TEST_BENCH;
-------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------
architecture stimulus of TEST_BENCH is
    ----------------------------------------------------------------------------
    -- 時間の定義
    ----------------------------------------------------------------------------
    constant  PERIOD         : time := 10 ns;
    constant  DELAY          : time :=  1 ns;
    ----------------------------------------------------------------------------
    -- リクエスト/グラント信号のタイプの定義
    ----------------------------------------------------------------------------
    subtype   REQUEST_TYPE  is std_logic_vector(1 to 4);
    ----------------------------------------------------------------------------
    -- 各種信号の定義
    ----------------------------------------------------------------------------
    signal    clk_ena        : boolean;
    signal    CLK            : std_logic;
    signal    RST            : std_logic;
    signal    CLR            : std_logic;
    signal    REQ_O          : std_logic;
    signal    VALID          : std_logic;
    signal    REQUEST        : REQUEST_TYPE;
    signal    GRANT          : REQUEST_TYPE;
    signal    SHIFT          : std_logic;
    signal    ENABLE         : std_logic := '1';
    signal    GRANT_NUM      : integer;
    signal    MISMATCH       : integer := 0;
    ----------------------------------------------------------------------------
    -- 信号を文字列に変換する関数の定義
    ----------------------------------------------------------------------------
    function BIN_TO_STRING(VALUE:in std_logic_vector) return STRING is
	variable bv:   std_logic_vector(0 to VALUE'length-1) := VALUE;
	variable str:  string(1 to VALUE'length);
    begin
	for i in 0 to VALUE'length-1 loop
	    case bv(i) is
                when '0'    => str(i+1) := '0';
                when '1'    => str(i+1) := '1';
                when 'L'    => str(i+1) := 'L';
                when 'H'    => str(i+1) := 'H';
                when 'Z'    => str(i+1) := 'Z';
                when 'U'    => str(i+1) := 'U';
                when '-'    => str(i+1) := '-';
                when others => str(i+1) := 'X';
	    end case;
	end loop;
	return str;
    end BIN_TO_STRING; 
    function BIN_TO_STRING(BIT:in std_logic) return STRING is
    begin
       case BIT is
           when 'H'    => return "H";
           when '1'    => return "1";
           when 'L'    => return "L";
           when '0'    => return "0";
           when others => return "X";
       end case;
    end BIN_TO_STRING;
    ----------------------------------------------------------------------------
    -- メッセージをコンソールに出力する関数の定義
    ----------------------------------------------------------------------------
    procedure REPORT_MESSAGE(MES:in STRING) is
        variable str : LINE;
    begin
        WRITE(str, Now, RIGHT, 9);
        WRITE(str, " : " & MES);
        WRITELINE(OUTPUT, str);
    end REPORT_MESSAGE;
    ----------------------------------------------------------------------------
    -- 整数を文字列に変換する関数の定義
    ----------------------------------------------------------------------------
    function INT_TO_STRING(arg:integer;len:integer;space:character) return STRING is
        variable str   : STRING(1 to len);
        variable value : integer;
    begin
        value  := arg;
        for i in str'right downto str'left loop
            if (value > 0) then
                case (value mod 10) is
                    when 0      => str(i) := '0';
                    when 1      => str(i) := '1';
                    when 2      => str(i) := '2';
                    when 3      => str(i) := '3';
                    when 4      => str(i) := '4';
                    when 5      => str(i) := '5';
                    when 6      => str(i) := '6';
                    when 7      => str(i) := '7';
                    when 8      => str(i) := '8';
                    when 9      => str(i) := '9';
                    when others => str(i) := 'X';
                end case;
            else
                if (i = str'right) then
                    str(i) := '0';
                else
                    str(i) := space;
                end if;
            end if;
            value := value / 10;
        end loop;
        return str;
    end INT_TO_STRING;
    ----------------------------------------------------------------------------
    -- グラント出力値の定義 
    ----------------------------------------------------------------------------
    constant  GRANT_REQ1     : REQUEST_TYPE := (1 => '1', others => '0');
    constant  GRANT_REQ2     : REQUEST_TYPE := (2 => '1', others => '0');
    constant  GRANT_REQ3     : REQUEST_TYPE := (3 => '1', others => '0');
    constant  GRANT_REQ4     : REQUEST_TYPE := (4 => '1', others => '0');
    constant  GRANT_NULL     : REQUEST_TYPE := (others => '0');
    ----------------------------------------------------------------------------
    -- コンソールに信号の状態を出力する関数の定義
    ----------------------------------------------------------------------------
    procedure  REPORT_SIGNALS is
        variable str : LINE;
    begin
        WRITE(str, Now, RIGHT, 9);
        WRITE(str, " | REQ(1)=" & BIN_TO_STRING(REQUEST(1)));
        WRITE(str, " | REQ(2)=" & BIN_TO_STRING(REQUEST(2)));
        WRITE(str, " | REQ(3)=" & BIN_TO_STRING(REQUEST(3)));
        WRITE(str, " | REQ(4)=" & BIN_TO_STRING(REQUEST(4)));
        WRITE(str, " | SHIFT="  & BIN_TO_STRING(SHIFT));
        WRITE(str, " | VALID="  & BIN_TO_STRING(VALID));
        WRITE(str, " | REQ_O="  & BIN_TO_STRING(REQ_O));
        WRITE(str, " | GRANT="  & BIN_TO_STRING(GRANT));
        WRITE(str, " | NUM="    & INT_TO_STRING(GRANT_NUM,1,' '));
        WRITELINE(OUTPUT, str);
    end REPORT_SIGNALS;
begin
    ----------------------------------------------------------------------------
    -- クロックの生成
    ----------------------------------------------------------------------------
    process begin
        loop
            CLK <= '1'; wait for PERIOD / 2;
            CLK <= '0'; wait for PERIOD / 2;
            exit when (clk_ena = FALSE);
        end loop;
        CLK <= '0';
        wait;
    end process;
    CLR <= '0';
    ----------------------------------------------------------------------------
    -- アービターブロック
    ----------------------------------------------------------------------------
    ARB:QUEUE_ARBITER generic map(MIN_NUM=>1, MAX_NUM=>4)
        port map (
            CLK         => CLK,
            RST         => RST,
            CLR         => CLR,
            ENABLE      => ENABLE,
            REQUEST     => REQUEST,
            GRANT       => GRANT,
            GRANT_NUM   => GRANT_NUM,
            REQUEST_O   => REQ_O,
            VALID       => VALID,
            SHIFT       => SHIFT
        );
    ----------------------------------------------------------------------------
    -- テスト開始
    ----------------------------------------------------------------------------
    process
        variable MISMATCH : integer := 0;
        ------------------------------------------------------------------------
        -- エラーの回数をコンソールに出力する関数の定義
        ------------------------------------------------------------------------
        procedure REPORT_ERROR is
            variable str : LINE;
            constant tag : STRING(1 to 7) := "  ***  ";
        begin
            WRITE(str,tag);                                       WRITELINE(OUTPUT,str);
            WRITE(str,tag & "ERROR REPORT");                      WRITELINE(OUTPUT,str);
            WRITE(str,tag & "Mismatch=");WRITE(str,MISMATCH);     WRITELINE(OUTPUT,str);
        end REPORT_ERROR;
        ------------------------------------------------------------------------
        -- クロックの立上りまで待って状態をチェックする関数の定義
        ------------------------------------------------------------------------
        procedure WAIT_CLK(
            CNT     : in integer;
            VAL_EXP : in std_logic;
            REQ_EXP : in std_logic;
            GNT_EXP : in REQUEST_TYPE;
            NUM_EXP : in integer
        ) is
        begin
            for i in 1 to CNT loop 
                wait until (CLK'event and CLK = '1'); 
                REPORT_SIGNALS;
                if (VALID /= VAL_EXP) then
                    REPORT_MESSAGE("Mismatch: VAL=" & BIN_TO_STRING(VALID) &
                                            ",EXP=" & BIN_TO_STRING(VAL_EXP));
                    MISMATCH := MISMATCH + 1;
                end if;
                if (REQ_O /= REQ_EXP) then
                    REPORT_MESSAGE("Mismatch: REQ=" & BIN_TO_STRING(REQ_O) &
                                            ",EXP=" & BIN_TO_STRING(REQ_EXP));
                    MISMATCH := MISMATCH + 1;
                end if;
                if (GRANT /= GNT_EXP) then
                    REPORT_MESSAGE("Mismatch: GNT=" & BIN_TO_STRING(GRANT) &
                                            ",EXP=" & BIN_TO_STRING(GNT_EXP));
                    MISMATCH := MISMATCH + 1;
                end if;
                if (GRANT_NUM /= NUM_EXP) then
                    REPORT_MESSAGE("Mismatch: GRANT_NUM=" & INT_TO_STRING(GRANT_NUM,1,' ') &
                                                  ",EXP=" & INT_TO_STRING(NUM_EXP  ,1,' '));
                    MISMATCH := MISMATCH + 1;
                end if;
            end loop;
        end WAIT_CLK;
        procedure WAIT_CLK(CNT:in integer) is
        begin
            for i in 1 to CNT loop 
                wait until (CLK'event and CLK = '1'); 
                REPORT_SIGNALS;
            end loop;
        end WAIT_CLK;
    begin
        clk_ena <= TRUE;
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='1';WAIT_CLK(1,'0','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='1';WAIT_CLK(1,'0','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='1';WAIT_CLK(1,'0','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='1';WAIT_CLK(1,'0','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'0','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'0','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="1100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="1100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="1100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="1100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="1010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="0001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="0011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1101";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1101";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="0110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="1110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0101";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="0101";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="0001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="0001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="0001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1100";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="1110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="0110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="0000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="0100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="1010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="1010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="1010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="1010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="0101";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0101";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0100";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0100";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0100";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0100";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0101";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0100";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0100";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0100";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="0011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="1001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1101";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="0011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="0010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1101";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="0001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="1010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="1010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="1000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="1000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="0101";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0101";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0101";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="0101";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0000";SHIFT<='1';RST<='0';WAIT_CLK(1,'0','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,3);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="0001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1100";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="1110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0000";SHIFT<='1';RST<='0';WAIT_CLK(1,'0','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="1111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1011";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="0110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1010";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0110";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0100";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,4);
        wait for DELAY;REQUEST<="0000";SHIFT<='1';RST<='0';WAIT_CLK(1,'0','0',GRANT_NULL,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1000";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1001";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1101";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1011";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1111";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="1111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ1,1);
        wait for DELAY;REQUEST<="0111";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ4,4);
        wait for DELAY;REQUEST<="0110";SHIFT<='0';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ2,2);
        wait for DELAY;REQUEST<="0010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','0',GRANT_NULL,2);
        wait for DELAY;REQUEST<="0010";SHIFT<='1';RST<='0';WAIT_CLK(1,'1','1',GRANT_REQ3,3);
        wait for DELAY;REQUEST<="0000";SHIFT<='0';RST<='0';WAIT_CLK(1,'0','0',GRANT_NULL,1);
        REPORT_ERROR;
        assert(MISMATCH =0) report "Run mismatch..." severity FAILURE;
        assert(MISMATCH/=0) report "Run complete..." severity NOTE;
        clk_ena <= FALSE;
        wait;
    end process;
end stimulus;
configuration TEST_BENCH_ONE_HOT_ARCH of TEST_BENCH is
    for stimulus
        for ARB : QUEUE_ARBITER
            use entity PIPEWORK.QUEUE_ARBITER(ONE_HOT_ARCH);
        end for;
    end for;
end TEST_BENCH_ONE_HOT_ARCH;
configuration TEST_BENCH_INTEGER_ARCH of TEST_BENCH is
    for stimulus
        for ARB : QUEUE_ARBITER
            use entity PIPEWORK.QUEUE_ARBITER(INTEGER_ARCH);
        end for;
    end for;
end TEST_BENCH_INTEGER_ARCH;
