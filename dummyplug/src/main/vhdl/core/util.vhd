-----------------------------------------------------------------------------------
--!     @file    util.vhd
--!     @brief   Utility Package for Dummy Plug.
--!     @version 1.6.1
--!     @date    2016/3/12
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
-----------------------------------------------------------------------------------
--! @brief Dummy Plug の各種ユーティリティパッケージ.
-----------------------------------------------------------------------------------
package UTIL is
    -------------------------------------------------------------------------------
    --! @brief 文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    --! @param    VAL_LEN 変換された std_logic_vector のビット数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_STD_LOGIC_VECTOR(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer         ;
                  VAL_LEN   : out   integer
    );
    -------------------------------------------------------------------------------
    --! @brief 文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_STD_LOGIC_VECTOR(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer
    );
    -------------------------------------------------------------------------------
    --! @brief 文字列をboolean型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された boolean 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_BOOLEAN(
                  STR       : in    string ;
                  VAL       : out   boolean;
                  STR_LEN   : out   integer
    );
    -------------------------------------------------------------------------------
    --! @brief 文字列を整数型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された整数型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_INTEGER(
                  STR       : in    string ;
                  VAL       : out   integer;
                  STR_LEN   : out   integer
    );
    -------------------------------------------------------------------------------
    --! @brief 16進数文字列を整数型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された整数型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_HEX(
                  STR       : in    string ;
                  VAL       : out   integer;
                  STR_LEN   : out   integer
    );
    -------------------------------------------------------------------------------
    --! @brief 10進数文字列を整数型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された整数型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_DEC(
                  STR       : in    string ;
                  VAL       : out   integer;
                  STR_LEN   : out   integer
    );
    -------------------------------------------------------------------------------
    --! @brief 8進数文字列を整数型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された整数型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_OCT(
                  STR       : in    string ;
                  VAL       : out   integer;
                  STR_LEN   : out   integer
    );
    -------------------------------------------------------------------------------
    --! @brief 2進数文字列を整数型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された整数型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_BIN(
                  STR       : in    string ;
                  VAL       : out   integer;
                  STR_LEN   : out   integer
    );
    -------------------------------------------------------------------------------
    --! @brief 16進数文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    --! @param    VAL_LEN 変換された std_logic_vector のビット数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_HEX(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer         ;
                  VAL_LEN   : out   integer         
    );
    -------------------------------------------------------------------------------
    --! @brief 10進数文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    --! @param    VAL_LEN 変換された std_logic_vector のビット数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_DEC(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer         ;
                  VAL_LEN   : out   integer         
    );
    -------------------------------------------------------------------------------
    --! @brief 8進数文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    --! @param    VAL_LEN 変換された std_logic_vector のビット数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_OCT(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer         ;
                  VAL_LEN   : out   integer         
    );
    -------------------------------------------------------------------------------
    --! @brief 2進数文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    --! @param    VAL_LEN 変換された std_logic_vector のビット数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_BIN(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer         ;
                  VAL_LEN   : out   integer         
    );
    -------------------------------------------------------------------------------
    --! @brief 整数を文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @param    STR     変換された文字列.
    --! @param    LEN     変換された文字列の文字数.
    -------------------------------------------------------------------------------
    procedure INTEGER_TO_STRING(
                  VAL       : in    integer;
                  STR       : out   STRING ;
                  LEN       : out   integer
    );
    -------------------------------------------------------------------------------
    --! @brief 整数型の値を文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function  INTEGER_TO_STRING(VAL: integer) return STRING;
    -------------------------------------------------------------------------------
    --! @brief 整数型の値を16進数文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @param    LEN     整数値のビット数を指定する.文字列の文字数じゃないことに注意.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function  HEX_TO_STRING(VAL: integer; LEN: integer) return STRING;
    -------------------------------------------------------------------------------
    --! @brief std_logic_vector型の値をを16進数文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function  HEX_TO_STRING(VAL: std_logic_vector) return STRING;
    -------------------------------------------------------------------------------
    --! @brief 整数型の値を２進数文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @param    LEN     整数値のビット数を指定する.文字列の文字数じゃないことに注意.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function  BIN_TO_STRING(VAL: integer; LEN: integer) return STRING;
    -------------------------------------------------------------------------------
    --! @brief std_logic_vector型の値を２進数文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function  BIN_TO_STRING(VAL: std_logic_vector) return STRING;
    -------------------------------------------------------------------------------
    --! @brief std_logic型の値を２進数文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function  BIN_TO_STRING(VAL: std_logic       ) return STRING;
    -------------------------------------------------------------------------------
    --! @brief std_logic型の値を２進数文字に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字.
    -------------------------------------------------------------------------------
    function  BIN_TO_CHAR  (VAL: std_logic       ) return character;
    -------------------------------------------------------------------------------
    --! @brief boolean型の値を文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字.
    -------------------------------------------------------------------------------
    function  BOOLEAN_TO_STRING(VAL: boolean) return STRING;
    -------------------------------------------------------------------------------
    --! @brief std_logic型の値同士を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    A       比較する値.
    --! @param    B       比較する値.
    --! @return           比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    function  MATCH_STD_LOGIC(A,B:std_logic) return boolean;
    -------------------------------------------------------------------------------
    --! @brief std_logic_vector型の値同士を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    A       比較する値.
    --! @param    B       比較する値.
    --! @return           比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    function  MATCH_STD_LOGIC(A,B:std_logic_vector) return boolean;
end UTIL;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
-----------------------------------------------------------------------------------
--! @brief Dummy Plug の各種ユーティリティパッケージ本体.
-----------------------------------------------------------------------------------
package body UTIL is
    -------------------------------------------------------------------------------
    --! @brief 整数型の値をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    NUM     入力値.
    --! @param    VAL     変換された std_logic_vector 型の値.
    -------------------------------------------------------------------------------
    procedure integer_to_std_logic_vector(
                  NUM       : in    integer;
                  VAL       : out   std_logic_vector
    ) is
        alias     result    :       std_logic_vector(VAL'length-1 downto 0) is VAL;
        variable  number    :       integer;
        variable  bin       :       std_logic;
    begin
        if (NUM < 0) then
            bin    := '1';
            number := -(NUM+1);
        else
            bin    := '0';
            number := NUM;
        end if;
        for i in 0 to result'left loop
            if ((number mod 2) = 0) then
                result(i) :=     bin;
            else
                result(i) := not bin;
            end if;
            number := number/2;
        end loop;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    --! @param    VAL_LEN 変換された std_logic_vector のビット数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_STD_LOGIC_VECTOR(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer         ;
                  VAL_LEN   : out   integer         
    ) is
        variable  value     :       integer;
        variable  pos       :       integer;
        variable  len       :       integer;
        variable  quote     :       boolean;
    begin
        ---------------------------------------------------------------------------
        -- 最初の文字が'0'の場合...
        ---------------------------------------------------------------------------
        if (STR(STR'low) = '0' and STR'low < STR'high) then
            pos := STR'low;
            if ((STR(pos+1) = 'x' or STR(pos+1) = 'X') and pos+2 <= STR'high) then
                STRING_TO_HEX(STR(pos+2 to STR'high), VAL, len, VAL_LEN);
                pos := pos + 2 + len;
            else
                STRING_TO_OCT(STR(pos+1 to STR'high), VAL, len, VAL_LEN);
                pos := pos + 1 + len;
            end if;
            if (len > 0) then
                STR_LEN := pos - STR'low;
            else
                STR_LEN := 0;
            end if;
        ---------------------------------------------------------------------------
        -- 最初の文字が'0'ではなかった場合.
        ---------------------------------------------------------------------------
        else
            -----------------------------------------------------------------------
            -- 最初の定数(10進数)を読む.
            -----------------------------------------------------------------------
            STRING_TO_DEC(STR, value, len);
            if (len = 0) then
                value := 0;
            end if;
            pos := STR'low + len;
            -----------------------------------------------------------------------
            -- 次の字句が ' の場合は、最初に読んだ定数はベクタの大きさになる.
            -----------------------------------------------------------------------
            if (pos <= STR'high) then
                quote := (STR(pos) = ''');
            else
                quote := FALSE;
            end if;
            if (quote) then
                if (value < 0 or pos+1 > STR'high) then 
                    STR_LEN := 0;
                    VAL_LEN := 0;
                    return; 
                end if;
                case STR(pos+1) is
                    when 'X'|'x'=> STRING_TO_HEX(STR(pos+2 to STR'high), VAL, len, VAL_LEN);
                    when 'H'|'h'=> STRING_TO_HEX(STR(pos+2 to STR'high), VAL, len, VAL_LEN);
                    when 'O'|'o'=> STRING_TO_OCT(STR(pos+2 to STR'high), VAL, len, VAL_LEN);
                    when 'B'|'b'=> STRING_TO_BIN(STR(pos+2 to STR'high), VAL, len, VAL_LEN);
                    when 'D'|'d'=> STRING_TO_DEC(STR(pos+2 to STR'high), VAL, len, VAL_LEN);
                    when others => len := 0; VAL_LEN := 0;
                end case;
                if (len > 0) then
                    if (value > 0) then
                        VAL_LEN := value;
                    end if;
                    STR_LEN := pos + 2 + len - STR'low;
                else
                    STR_LEN := 0;
                    VAL_LEN := 0;
                end if;
            ---------------------------------------------------------------------------
            -- 次の字句が ' でない場合は、読んだ定数を返す.
            ---------------------------------------------------------------------------
            else
                STR_LEN := len;
                VAL_LEN := VAL'length;
                integer_to_std_logic_vector(value, VAL);
            end if;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_STD_LOGIC_VECTOR(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer         
    ) is
        variable  val_len   :       integer;
    begin
        STRING_TO_STD_LOGIC_VECTOR(STR,VAL,STR_LEN,val_len);
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 文字列をboolean型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された boolean 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_BOOLEAN(
                  STR       : in    string ;
                  VAL       : out   boolean;
                  STR_LEN   : out   integer
    ) is
    begin
        case STR'length is
            when 1 => if    STR = "y"     or
                            STR = "Y"     then VAL := TRUE ; STR_LEN := 1;
                      elsif STR = "n"     or
                            STR = "N"     then VAL := FALSE; STR_LEN := 1;
                      else                     VAL := FALSE; STR_LEN := 0;
                      end if;
            when 2 => if    STR = "on"    or
                            STR = "On"    or
                            STR = "ON"    then VAL := TRUE ; STR_LEN := 1;
                      elsif STR = "no"    or
                            STR = "No"    or
                            STR = "NO"    then VAL := FALSE; STR_LEN := 1;
                      else                     VAL := FALSE; STR_LEN := 0;
                      end if;
            when 3 => if    STR = "yes"   or
                            STR = "Yes"   or
                            STR = "YES"   then VAL := TRUE ; STR_LEN := 1;
                      elsif STR = "off"   or
                            STR = "Off"   or
                            STR = "OFF"   then VAL := FALSE; STR_LEN := 1;
                      else                     VAL := FALSE; STR_LEN := 0;
                      end if;
            when 4 => if    STR = "true"  or
                            STR = "True"  or
                            STR = "TRUE"  then VAL := TRUE ; STR_LEN := 1;
                      else                     VAL := FALSE; STR_LEN := 0;
                      end if;
            when 5 => if    STR = "false" or
                            STR = "False" or
                            STR = "FALSE" then VAL := FALSE; STR_LEN := 1;
                      else                     VAL := FALSE; STR_LEN := 0;
                      end if;
            when others =>                     VAL := FALSE; STR_LEN := 0;
        end case;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 文字列を整数型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された整数型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_INTEGER(
                  STR       : in    string ;
                  VAL       : out   integer;
                  STR_LEN   : out   integer
    ) is
        variable  pos       :       integer;
        variable  value     :       integer;
        variable  k         :       integer;
        variable  len       :       integer;
    begin
        pos   := STR'low;
        value := 0;
        k     := 1;
        if (STR(pos) = '-') then
            pos := pos + 1;
            k   := -1;
        end if;
        if (pos <= STR'high) then
            if (STR(pos) = '0' and pos+1 <= STR'high) then
                if ((STR(pos+1) = 'x' or STR(pos+1) = 'X') and pos+2 <= STR'high) then
                    STRING_TO_HEX(STR(pos+2 to STR'high), value, len);
                    pos := pos + 2 + len;
                else
                    STRING_TO_OCT(STR(pos+1 to STR'high), value, len);
                    pos := pos + 1 + len;
                end if;
            else
                    STRING_TO_DEC(STR(pos+0 to STR'high), value, len);
                    pos := pos + 0 + len;
            end if;
        end if;
        VAL     := k * value;
        STR_LEN := pos - STR'low;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 16進数文字列を整数型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された整数型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_HEX(
                  STR       : in    string ;
                  VAL       : out   integer;
                  STR_LEN   : out   integer
    ) is
        variable  pos       :       integer;
        variable  value     :       integer;
    begin
        pos   := STR'low;
        value := 0;
        MAIN_LOOP: loop
            exit MAIN_LOOP when (pos > STR'high);
            case STR(pos) is
                when '0'       => value := value*16+0;
                when '1'       => value := value*16+1;
                when '2'       => value := value*16+2;
                when '3'       => value := value*16+3;
                when '4'       => value := value*16+4;
                when '5'       => value := value*16+5;
                when '6'       => value := value*16+6;
                when '7'       => value := value*16+7;
                when '8'       => value := value*16+8;
                when '9'       => value := value*16+9;
                when 'a' | 'A' => value := value*16+10;
                when 'b' | 'B' => value := value*16+11;
                when 'c' | 'C' => value := value*16+12;
                when 'd' | 'D' => value := value*16+13;
                when 'e' | 'E' => value := value*16+14;
                when 'f' | 'F' => value := value*16+15;
                when '_'       =>
                when others    => exit MAIN_LOOP;
            end case;
            pos := pos + 1;
        end loop;
        VAL     := value;
        STR_LEN := pos - STR'low;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 10進数文字列を整数型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された整数型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_DEC(
                  STR       : in    string ;
                  VAL       : out   integer;
                  STR_LEN   : out   integer
    ) is
        variable  pos       :       integer;
        variable  value     :       integer;
    begin
        pos   := STR'low;
        value := 0;
        MAIN_LOOP: loop
            exit MAIN_LOOP when (pos > STR'high);
            case STR(pos) is
                when '0'    => value := value*10+0;
                when '1'    => value := value*10+1;
                when '2'    => value := value*10+2;
                when '3'    => value := value*10+3;
                when '4'    => value := value*10+4;
                when '5'    => value := value*10+5;
                when '6'    => value := value*10+6;
                when '7'    => value := value*10+7;
                when '8'    => value := value*10+8;
                when '9'    => value := value*10+9;
                when '_'    =>
                when others => exit MAIN_LOOP;
            end case;
            pos := pos + 1;
        end loop;
        VAL     := value;
        STR_LEN := pos - STR'low;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 8進数文字列を整数型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された整数型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_OCT(
                  STR       : in    string ;
                  VAL       : out   integer;
                  STR_LEN   : out   integer
    ) is
        variable  pos       :       integer;
        variable  value     :       integer;
    begin
        pos   := STR'low;
        value := 0;
        MAIN_LOOP: loop
            exit MAIN_LOOP when (pos > STR'high);
            case STR(pos) is
                when '0'       => value := value*8+0;
                when '1'       => value := value*8+1;
                when '2'       => value := value*8+2;
                when '3'       => value := value*8+3;
                when '4'       => value := value*8+4;
                when '5'       => value := value*8+5;
                when '6'       => value := value*8+6;
                when '7'       => value := value*8+7;
                when '_'       =>
                when others    => exit MAIN_LOOP;
            end case;
            pos := pos + 1;
        end loop;
        VAL     := value;
        STR_LEN := pos - STR'low;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 2進数文字列を整数型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された整数型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_BIN(
                  STR       : in    string ;
                  VAL       : out   integer;
                  STR_LEN   : out   integer
    ) is
        variable  pos       :       integer;
        variable  value     :       integer;
    begin
        pos   := STR'low;
        value := 0;
        MAIN_LOOP: loop
            exit MAIN_LOOP when (pos > STR'high);
            case STR(pos) is
                when '0'       => value := value*2+0;
                when '1'       => value := value*2+1;
                when '_'       =>
                when others    => exit MAIN_LOOP;
            end case;
            pos := pos + 1;
        end loop;
        VAL     := value;
        STR_LEN := pos - STR'low;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 10進数文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    --! @param    VAL_LEN 変換された std_logic_vector のビット数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_DEC(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer         ;
                  VAL_LEN   : out   integer         
    ) is
        variable  value     :       integer;
        variable  length    :       integer;
    begin
        STRING_TO_DEC(STR, value, length);
        integer_to_std_logic_vector(value, VAL);
        STR_LEN := length;
        VAL_LEN := VAL'length;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 16進数文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    --! @param    VAL_LEN 変換された std_logic_vector のビット数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_HEX(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer         ;
                  VAL_LEN   : out   integer         
    ) is
        variable  vec       :   std_logic_vector(VAL'length-1 downto 0) := (others => '0');
        variable  value     :   std_logic_vector(3 downto 0);
        variable  pos       :   integer;
        variable  len       :   integer;
        variable  spc       :   boolean;
    begin
        pos := STR'low;
        len := 0;
        MAIN_LOOP: loop
            spc := FALSE;
            exit MAIN_LOOP when (pos > STR'high);
            case STR(pos) is
                when '0'    => value := "0000";
                when '1'    => value := "0001";
                when '2'    => value := "0010";
                when '3'    => value := "0011";
                when '4'    => value := "0100";
                when '5'    => value := "0101";
                when '6'    => value := "0110";
                when '7'    => value := "0111";
                when '8'    => value := "1000";
                when '9'    => value := "1001";
                when 'A'|'a'=> value := "1010";
                when 'B'|'b'=> value := "1011";
                when 'C'|'c'=> value := "1100";
                when 'D'|'d'=> value := "1101";
                when 'E'|'e'=> value := "1110";
                when 'F'|'f'=> value := "1111";
                when 'U'|'u'=> value := "UUUU";
                when 'Z'|'z'=> value := "ZZZZ";
                when 'X'|'x'=> value := "XXXX";
                when '-'    => value := "----";
                when '_'    => spc   := TRUE  ;
                when others => exit MAIN_LOOP;
            end case;
            pos := pos + 1;
            if (spc = FALSE) then
                if (VAL'length > 4) then
                    vec(VAL'length-1 downto 4) := vec(VAL'length-5 downto 0);
                    vec(           3 downto 0) := value;
                else
                    vec := value(vec'range);
                end if;
                len := len + 4;
                exit MAIN_LOOP when (len >= VAL'length);
            end if;
        end loop;
        ---------------------------------------------------------------------------
        -- 出来た定数を出力変数に代入する。
        ---------------------------------------------------------------------------
        VAL     := vec;
        VAL_LEN := len;
        STR_LEN := pos - STR'low;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 8進数文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    --! @param    VAL_LEN 変換された std_logic_vector のビット数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_OCT(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer         ;
                  VAL_LEN   : out   integer         
    ) is
        variable  vec       :       std_logic_vector(VAL'length-1 downto 0) := (others => '0');
        variable  value     :       std_logic_vector(2 downto 0);
        variable  pos       :       integer;
        variable  len       :       integer;
        variable  spc       :       boolean;
    begin
        pos := STR'low;
        len := 0;
        MAIN_LOOP: loop
            spc := FALSE;
            exit MAIN_LOOP when (pos > STR'high);
            case STR(pos) is
                when '0'    => value := "000";
                when '1'    => value := "001";
                when '2'    => value := "010";
                when '3'    => value := "011";
                when '4'    => value := "100";
                when '5'    => value := "101";
                when '6'    => value := "110";
                when '7'    => value := "111";
                when 'U'|'u'=> value := "UUU";
                when 'Z'|'z'=> value := "ZZZ";
                when 'X'|'x'=> value := "XXX";
                when '-'    => value := "---";
                when '_'    => spc   := TRUE ;
                when others => exit MAIN_LOOP;
            end case;
            pos := pos + 1;
            if (spc = FALSE) then
                if (VAL'length > 3) then
                    vec(VAL'length-1 downto 3) := vec(VAL'length-4 downto 0);
                    vec(           2 downto 0) := value;
                else
                    vec := value(vec'range);
                end if;
                len := len + 3;
                exit MAIN_LOOP when (len >= VAL'length);
            end if;
        end loop;
        ---------------------------------------------------------------------------
        -- 出来た定数を出力変数に代入する。
        ---------------------------------------------------------------------------
        VAL     := vec;
        VAL_LEN := len;
        STR_LEN := pos - STR'low;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 2進数文字列をstd_logic_vector型の値に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    STR     入力文字列.
    --! @param    VAL     変換された std_logic_vector 型の値.
    --! @param    STR_LEN 入力文字列のうち、変換に要した文字の数.
    --! @param    VAL_LEN 変換された std_logic_vector のビット数.
    -------------------------------------------------------------------------------
    procedure STRING_TO_BIN(
                  STR       : in    string          ;
                  VAL       : out   std_logic_vector;
                  STR_LEN   : out   integer         ;
                  VAL_LEN   : out   integer         
    ) is
        variable  vec       :       std_logic_vector(VAL'length-1 downto 0) := (others => '0');
        variable  bin       :       std_logic;
        variable  pos       :       integer;
        variable  len       :       integer;
        variable  spc       :       boolean;
    begin
        pos := STR'low;
        len := 0;
        MAIN_LOOP: loop
            spc := FALSE;
            exit MAIN_LOOP when (pos > STR'high);
            case STR(pos) is
                when '0'    => bin := '0' ;
                when '1'    => bin := '1' ;
                when 'X'    => bin := 'X' ;
                when 'U'    => bin := 'U' ;
                when 'Z'    => bin := 'Z' ;
                when '-'    => bin := '-' ;
                when '_'    => spc := TRUE;
                when others => exit MAIN_LOOP;
            end case;
            pos := pos + 1;
            if (spc = FALSE) then
                if (VAL'length > 1) then
                    vec(VAL'length-1 downto 1) := vec(VAL'length-2 downto 0);
                end if;
                vec(0) := bin;
                len    := len + 1;
                exit MAIN_LOOP when (len > VAL'length);
            end if;
        end loop;
        ---------------------------------------------------------------------------
        -- 出来た定数を出力変数に代入する。
        ---------------------------------------------------------------------------
        VAL     := vec;
        VAL_LEN := len;
        STR_LEN := pos - STR'low;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 整数を文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @param    STR     変換された文字列.
    --! @param    LEN     変換された文字列の文字数.
    -------------------------------------------------------------------------------
    procedure INTEGER_TO_STRING(
                  VAL   : in    integer;
                  STR   : out   STRING ;
                  LEN   : out   integer
    ) is
	variable  buf   :       string(STR'length downto 1);
	variable  pos   :       integer;
	variable  tmp   :       integer;
        variable  digit :       integer range 0 to 9;
    begin
        pos := 1;
        tmp := abs(VAL);
	loop
            digit := abs(tmp mod 10);
            case digit is
               when 0 => buf(pos) := '0';
               when 1 => buf(pos) := '1';
               when 2 => buf(pos) := '2';
               when 3 => buf(pos) := '3';
               when 4 => buf(pos) := '4';
               when 5 => buf(pos) := '5';
               when 6 => buf(pos) := '6';
               when 7 => buf(pos) := '7';
               when 8 => buf(pos) := '8';
               when 9 => buf(pos) := '9';
            end case;
            pos := pos + 1;
	    tmp := tmp / 10;
	    exit when tmp = 0;
	end loop;
	if (VAL < 0) then
	    buf(pos) := '-';
        else
            pos := pos - 1;
	end if;
	STR(1 to pos) := buf(pos downto 1);
	LEN := pos;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief 整数型の値を文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function INTEGER_TO_STRING(VAL: integer) return STRING is
	variable  str : string(1 to 32);
	variable  len : integer;
    begin
	INTEGER_TO_STRING(VAL, str, len);
	return str(1 to len);
    end function;
    -------------------------------------------------------------------------------
    --! @brief 整数型の値を16進数文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @param    LEN     整数値のビット数を指定する.文字列の文字数じゃないことに注意.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function  HEX_TO_STRING(VAL: integer; LEN: integer) return STRING is
        variable  vec : std_logic_vector(LEN-1 downto 0);
    begin
        vec := std_logic_vector(to_unsigned(VAL,LEN));
        return HEX_TO_STRING(vec);
    end function;
    -------------------------------------------------------------------------------
    --! @brief std_logic_vector型の値をを16進数文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function HEX_TO_STRING(VAL: std_logic_vector) return STRING is
	constant  ne   : integer := (VAL'length+3)/4;
        variable  quad : std_logic_vector(0 to 3);
	variable  pv   : std_logic_vector(0 to VAL'length-1) := VAL;
	variable  bv   : std_logic_vector(0 to ne*4-1);
	variable  str  : string(1 to ne);
        variable  len  : integer range 0 to 3;
    begin
        ---------------------------------------------------------------------------
        -- 入力された VAL の長さを ４の倍数 になるように正規化して bv に代入
        ---------------------------------------------------------------------------
        len := VAL'length mod 4;
        case len is
            when 1      => bv(0 to 2) := "000"; bv(3 to bv'right) := pv;
            when 2      => bv(0 to 1) := "00" ; bv(2 to bv'right) := pv;
            when 3      => bv(0 to 0) := "0"  ; bv(1 to bv'right) := pv;
            when others =>                      bv(0 to bv'right) := pv;
        end case;
        ---------------------------------------------------------------------------
        -- 処理ループ
        ---------------------------------------------------------------------------
	for i in 0 to ne-1 loop
            for j in 0 to 3 loop
                case bv(4*i+j) is
                    when '0'    => quad(j) := '0';
                    when '1'    => quad(j) := '1';
                    when 'L'    => quad(j) := '0';
                    when 'H'    => quad(j) := '1';
                    when 'Z'    => quad(j) := 'Z';
                    when 'U'    => quad(j) := 'U';
                    when '-'    => quad(j) := '-';
                    when others => quad(j) := 'X';
                end case;
            end loop;
	    case quad is
                when "0000" => str(i+1) := '0';
                when "0001" => str(i+1) := '1';
                when "0010" => str(i+1) := '2';
                when "0011" => str(i+1) := '3';
                when "0100" => str(i+1) := '4';
                when "0101" => str(i+1) := '5';
                when "0110" => str(i+1) := '6';
                when "0111" => str(i+1) := '7';
                when "1000" => str(i+1) := '8';
                when "1001" => str(i+1) := '9';
                when "1010" => str(i+1) := 'A';
                when "1011" => str(i+1) := 'B';
                when "1100" => str(i+1) := 'C';
                when "1101" => str(i+1) := 'D';
                when "1110" => str(i+1) := 'E';
                when "1111" => str(i+1) := 'F';
                when "ZZZZ" => str(i+1) := 'Z';
                when "UUUU" => str(i+1) := 'U';
                when "----" => str(i+1) := '-';
                when others => str(i+1) := 'X';
	    end case;
	end loop;
	return str;
    end HEX_TO_STRING; 
    -------------------------------------------------------------------------------
    --! @brief std_logic型の値を２進数文字に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字.
    -------------------------------------------------------------------------------
    function BIN_TO_CHAR(VAL: std_logic) return character is
    begin
        case VAL is
            when '0'    => return '0';
            when '1'    => return '1';
            when 'L'    => return 'L';
            when 'H'    => return 'H';
            when 'Z'    => return 'Z';
            when 'U'    => return 'U';
            when '-'    => return '-';
            when others => return 'X';
         end case;
    end BIN_TO_CHAR; 
    -------------------------------------------------------------------------------
    --! @brief 整数型の値を２進数文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @param    LEN     整数値のビット数を指定する.文字列の文字数じゃないことに注意.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function  BIN_TO_STRING(VAL: integer; LEN: integer) return STRING is
        variable  vec : std_logic_vector(LEN-1 downto 0);
    begin
        vec := std_logic_vector(to_unsigned(VAL,LEN));
        return BIN_TO_STRING(vec);
    end function;
    -------------------------------------------------------------------------------
    --! @brief std_logic_vector型の値を２進数文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function BIN_TO_STRING(VAL: std_logic_vector) return STRING is
	variable  bv :  std_logic_vector(1 to VAL'length) := VAL;
	variable  str:  string(1 to VAL'length) ;
    begin
	for i in bv'range loop
            str(i) := BIN_TO_CHAR(bv(i));
    	end loop;
    	return str;
    end BIN_TO_STRING; 
    -------------------------------------------------------------------------------
    --! @brief std_logic型の値を２進数文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字列.
    -------------------------------------------------------------------------------
    function BIN_TO_STRING(VAL: std_logic) return STRING is
        variable  str:  string(1 to 1);
    begin
        str(1) := BIN_TO_CHAR(VAL);
        return str;
    end BIN_TO_STRING; 
    -------------------------------------------------------------------------------
    --! @brief boolean型の値を文字列に変換するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    VAL     入力値.
    --! @return           変換された文字.
    -------------------------------------------------------------------------------
    function  BOOLEAN_TO_STRING(VAL: boolean) return STRING is
        constant  T : string(1 to 4) := "TRUE";
        constant  F : string(1 to 5) := "FALSE";
    begin
        if (VAL) then return T;
        else          return F;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! @brief std_logic型の値同士を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    A       比較する値.
    --! @param    B       比較する値.
    --! @return           比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    function  MATCH_STD_LOGIC(A,B:std_logic) return boolean is
    begin
       case A is
            when '0'    => if (B /= '0') then return FALSE; end if;
            when '1'    => if (B /= '1') then return FALSE; end if;
            when 'L'    => if (B /= 'L') then return FALSE; end if;
            when 'H'    => if (B /= 'H') then return FALSE; end if;
            when 'Z'    => if (B /= 'Z') then return FALSE; end if;
            when 'U'    => if (B /= 'U') then return FALSE; end if;
            when 'X'    => if (B /= 'X') then return FALSE; end if;
            when '-'    => 
            when others => 
        end case;
        return TRUE;
    end function;
    -------------------------------------------------------------------------------
    --! @brief std_logic_vector型の値同士を比較するサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    A       比較する値.
    --! @param    B       比較する値.
    --! @return           比較した結果。マッチすれば TRUE、しなければ FALSE.
    -------------------------------------------------------------------------------
    function  MATCH_STD_LOGIC(A,B:std_logic_vector) return boolean is
        alias vec_a : std_logic_vector(A'length-1 downto 0) is A;
        alias vec_b : std_logic_vector(B'length-1 downto 0) is B;
    begin
        if (A'length /= B'length) then
            assert FALSE
            report "MATCH_STD_LOGIC_VECTOR arguments are not of the same length"
            severity FAILURE;
        else
            for i in 0 to A'length-1 loop
                if (MATCH_STD_LOGIC(vec_a(i),vec_b(i)) = FALSE) then
                    return FALSE;
                end if;
            end loop;
        end if;
        return TRUE;
    end function;
end UTIL;
