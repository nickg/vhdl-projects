-----------------------------------------------------------------------------------
--!     @file    axi4_stream_signal_printer.vhd
--!     @brief   AXI4-Stream Signal Printer Module.
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
-----------------------------------------------------------------------------------
--! @brief   AXI4_SIGNAL_PRINTER :
-----------------------------------------------------------------------------------
entity  AXI4_STREAM_SIGNAL_PRINTER is
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
end     AXI4_STREAM_SIGNAL_PRINTER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.UTIL.all;
use     DUMMY_PLUG.AXI4_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4_SIGNAL_PRINTER :
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_STREAM_SIGNAL_PRINTER is
begin
    process
        variable  text_line      : LINE;
        procedure p(M:in string) is
        begin
            if    (TAG_WIDTH > 0) then
                WRITE(text_line, TAG, RIGHT,  TAG_WIDTH);
            elsif (TAG_WIDTH < 0) then
                WRITE(text_line, TAG, LEFT , -TAG_WIDTH);
            end if;
            WRITE(text_line, M);
            WRITELINE(OUTPUT, text_line);
        end procedure;
        procedure p(T:in time;M:in string) is
        begin
            if    (TAG_WIDTH > 0) then
                WRITE(text_line, TAG, RIGHT,  TAG_WIDTH);
            elsif (TAG_WIDTH < 0) then
                WRITE(text_line, TAG, LEFT , -TAG_WIDTH);
            end if;
            if    (TIME_WIDTH > 0) then
                WRITE(text_line, T, RIGHT,  TIME_WIDTH);
            elsif (TIME_WIDTH < 0) then
                WRITE(text_line, T, LEFT , -TIME_WIDTH);
            end if;
            WRITE(text_line, M);
            WRITELINE(OUTPUT, text_line);
        end procedure;
        function resize(ARG:std_logic_vector;LEN:integer) return std_logic_vector is
            variable val : std_logic_vector(LEN-1        downto 0);
            alias    av  : std_logic_vector(ARG'length-1 downto 0) is ARG;
        begin
            for i in val'range loop
                if (i > av'high) then
                    val(i) := '0';
                else
                    val(i) := av(i);
                end if;
            end loop;
            return val;
        end function;
        function strcont(C:character;LEN:integer;I:integer) return string is
            constant val : string(1 to (LEN+I-1)/I) := (others => C);
        begin
            return val;
        end function;
        function strcont(M:string;LEN:integer;I:integer) return string is
            constant val_len : integer := (LEN+I-1)/I;
            variable val_buf : string(1 to val_len);
            constant lo_pos  : integer := (val_len-M'length)/2+1;
            constant hi_pos  : integer := lo_pos + M'length-1;
            variable pos     : integer;
        begin
            pos := M'low;
            for i in val_buf'range loop
                if (lo_pos <= i and i <= hi_pos) then
                    val_buf(i) := M(pos);
                    pos := pos + 1;
                else
                    val_buf(i) := ' ';
                end if;
            end loop;
            return val_buf;
        end function;
        constant tdata_id : string := strcont("DATA"  , TDATA'length   ,4);
        constant tdata_sp : string := strcont(' '     , TDATA'length   ,4);
        constant tdata_hl : string := strcont('-'     , TDATA'length   ,4);
        constant tdata_fm : string := strcont('h'     , TDATA'length   ,4);
        constant tstrb_id : string := strcont("STRB"  , TSTRB'length   ,1);
        constant tstrb_sp : string := strcont(' '     , TSTRB'length   ,1);
        constant tstrb_hl : string := strcont('-'     , TSTRB'length   ,1);
        constant tstrb_fm : string := strcont('b'     , TSTRB'length   ,1);
        constant tkeep_id : string := strcont("KEEP"  , TKEEP'length   ,1);
        constant tkeep_sp : string := strcont(' '     , TKEEP'length   ,1);
        constant tkeep_hl : string := strcont('-'     , TKEEP'length   ,1);
        constant tkeep_fm : string := strcont('b'     , TKEEP'length   ,1);
        constant s_head_0 : string := strcont(' '     , ABS(TIME_WIDTH),1);
        constant s_head_1 : string := strcont(' '     , ABS(TIME_WIDTH),1);
        constant s_head_2 : string := strcont(' '     , ABS(TIME_WIDTH),1);
        constant s_head_3 : string := strcont(' '     , ABS(TIME_WIDTH),1);
        constant s_head_4 : string := strcont(' '     , ABS(TIME_WIDTH),1);
        constant s_head_5 : string := strcont(' '     , ABS(TIME_WIDTH),1);
        constant s_head_6 : string := strcont("TIME"  , ABS(TIME_WIDTH),1);
        constant s_head_7 : string := strcont(' '     , ABS(TIME_WIDTH),1);
        constant s_head_8 : string := strcont(' '     , ABS(TIME_WIDTH),1);
        constant s_head_h : string := strcont('-'     , ABS(TIME_WIDTH),1);
        constant t_head_0 : string := "|   " & tdata_sp & " " & tstrb_sp & " " & tkeep_sp & "      |";
        constant t_head_1 : string := "|   " & tdata_sp & " " & tstrb_sp & " " & tkeep_sp & "      |";
        constant t_head_2 : string := "|   " & tdata_sp & " " & tstrb_sp & " " & tkeep_sp & "   V R|";
        constant t_head_3 : string := "|   " & tdata_sp & " " & tstrb_sp & " " & tkeep_sp & " L A E|";
        constant t_head_4 : string := "|   " & tdata_sp & " " & tstrb_sp & " " & tkeep_sp & " A L A|";
        constant t_head_5 : string := "|   " & tdata_sp & " " & tstrb_sp & " " & tkeep_sp & " S I D|";
        constant t_head_6 : string := "|ID " & tdata_id & " " & tstrb_id & " " & tkeep_id & " T D Y|";
        constant t_head_7 : string := "| M|" & tdata_sp & "|" & tstrb_sp & "|" & tkeep_sp & "|M M S|";
        constant t_head_8 : string := "|hh|" & tdata_fm & "|" & tstrb_fm & "|" & tkeep_fm & "|b b b|";
        constant t_head_h : string := "|--+" & tdata_hl & "+" & tstrb_hl & "+" & tkeep_hl & "+-----|";
    begin
     -- p(s_head_0 & t_head_0);
     -- p(s_head_1 & t_head_1);
        p(s_head_2 & t_head_2);
        p(s_head_3 & t_head_3);
        p(s_head_4 & t_head_4);
        p(s_head_5 & t_head_5);
        p(s_head_6 & t_head_6);
        p(s_head_h & t_head_h);
        p(s_head_7 & t_head_7);
        p(s_head_8 & t_head_8);
        p(s_head_h & t_head_h);
        MAIN_LOOP:loop
            wait until (ACLK'event and ACLK = '1');
            p(Now, string'("|") & HEX_TO_STRING(resize(TID,8)) &
                   string'("|") & HEX_TO_STRING(TDATA  ) &
                   string'("|") & BIN_TO_STRING(TSTRB  ) &
                   string'("|") & BIN_TO_STRING(TKEEP  ) &
                   string'("|") & BIN_TO_STRING(TLAST  ) &
                   string'(" ") & BIN_TO_STRING(TVALID ) &
                   string'(" ") & BIN_TO_STRING(TREADY ) &
                   string'("|"));
        end loop;
    end process;
end MODEL;
