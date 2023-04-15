-----------------------------------------------------------------------------------
--!     @file    axi3_signal_printer.vhd
--!     @brief   AXI3 Signal Printer Module.
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
--! @brief   AXI3_SIGNAL_PRINTER :
-----------------------------------------------------------------------------------
entity  AXI3_SIGNAL_PRINTER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        NAME            : --! @brief 固有名詞.
                          STRING;
        TAG             : --! @brief
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
        AXI4_ID_WIDTH   : --! @brief AXI4 IS WIDTH :
                          integer :=  4;
        AXI4_A_WIDTH    : --! @brief AXI4 ADDR WIDTH :
                          integer := 32;
        AXI4_W_WIDTH    : --! @brief AXI4 WRITE DATA WIDTH :
                          integer := 32;
        AXI4_R_WIDTH    : --! @brief AXI4 READ DATA WIDTH :
                          integer := 32
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
        --------------------------------------------------------------------------
        -- アドレスチャネルシグナル.
        --------------------------------------------------------------------------
        AVALID          : in    std_logic;
        ADDR            : in    std_logic_vector(AXI4_A_WIDTH   -1 downto 0);
        AWRITE          : in    std_logic;
        ALEN            : in    AXI4_ALEN_TYPE;
        ASIZE           : in    AXI4_ASIZE_TYPE;
        ABURST          : in    AXI4_ABURST_TYPE;
        ALOCK           : in    AXI4_ALOCK_TYPE;
        ACACHE          : in    AXI4_ACACHE_TYPE;
        APROT           : in    AXI4_APROT_TYPE;
        AID             : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        AREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- リードチャネルシグナル.
        --------------------------------------------------------------------------
        RVALID          : in    std_logic;
        RLAST           : in    std_logic;
        RDATA           : in    std_logic_vector(AXI4_R_WIDTH   -1 downto 0);
        RRESP           : in    AXI4_RESP_TYPE;
        RID             : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        RREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトチャネルシグナル.
        --------------------------------------------------------------------------
        WVALID          : in    std_logic;
        WLAST           : in    std_logic;
        WDATA           : in    std_logic_vector(AXI4_W_WIDTH   -1 downto 0);
        WSTRB           : in    std_logic_vector(AXI4_W_WIDTH/8 -1 downto 0);
        WID             : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        WREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BVALID          : in    std_logic;
        BRESP           : in    AXI4_RESP_TYPE;
        BID             : in    std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
        BREADY          : in    std_logic
    );
end     AXI3_SIGNAL_PRINTER;
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
architecture MODEL of AXI3_SIGNAL_PRINTER is
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
        constant addr_id  : string := strcont("ADDR" , AXI4_A_WIDTH  ,4);
        constant addr_sp  : string := strcont(' '    , AXI4_A_WIDTH  ,4);
        constant addr_hl  : string := strcont('-'    , AXI4_A_WIDTH  ,4);
        constant wdata_id : string := strcont("WDATA", AXI4_W_WIDTH  ,4);
        constant wdata_sp : string := strcont(' '    , AXI4_W_WIDTH  ,4);
        constant wdata_hl : string := strcont('-'    , AXI4_W_WIDTH  ,4);
        constant wstrb_id : string := strcont("WSTB" , AXI4_W_WIDTH/8,1);
        constant wstrb_sp : string := strcont(' '    , AXI4_W_WIDTH/8,1);
        constant wstrb_hl : string := strcont('-'    , AXI4_W_WIDTH/8,1);
        constant rdata_id : string := strcont("RDATA", AXI4_R_WIDTH  ,4);
        constant rdata_sp : string := strcont(' '    , AXI4_R_WIDTH  ,4);
        constant rdata_hl : string := strcont('-'    , AXI4_R_WIDTH  ,4);
    begin
        p(string'("             |   ") & addr_sp & " A     A   A   A A|   " & wdata_sp & " " & wstrb_sp & "   W W|   " & rdata_sp & "     R R|     B B ");
        p(string'("             |   ") & addr_sp & " W   A B A C A V R|   " & wdata_sp & " " & wstrb_sp & " W V R|   " & rdata_sp & " R R V R|   B V R ");
        p(string'("             |   ") & addr_sp & " R A S U L A P A E|   " & wdata_sp & " " & wstrb_sp & " L A E|   " & rdata_sp & " R L A E|   R A E ");
        p(string'("             |   ") & addr_sp & " I L I R O C R L A|   " & wdata_sp & " " & wstrb_sp & " A L A|   " & rdata_sp & " E A L A|   E L A "); 
        p(string'("             |   ") & addr_sp & " T E Z S C H O I D|   " & wdata_sp & " " & wstrb_sp & " S I D|   " & rdata_sp & " S S I D|   S I D ");
        p(string'("     TIME    |ID ") & addr_id & " E N E T K E T D Y|ID " & wdata_id & " " & wstrb_id & " T D Y|ID " & rdata_id & " P T D Y|ID P D Y ");
        p(string'(" ------------+--+") & addr_hl & "+-----------------+--+" & wdata_hl & "+" & wstrb_hl & "+-----+--+" & rdata_hl & "+-------+--+------");
        p(string'("             | M|") & addr_sp & "|M M M M M M M M S| M|" & wdata_sp & "|" & wstrb_sp & "|M M S| S|" & rdata_sp & "|S S S M| S|S S M ");
        p(string'(" ------------+--|") & addr_hl & "+-----------------+--+" & wdata_hl & "+" & wstrb_hl & "+-----+--+" & rdata_hl & "+-------+--+------");
        MAIN_LOOP:loop
            wait until (ACLK'event and ACLK = '1');
            p(Now, string'("|") & HEX_TO_STRING(resize(AID,8)) &
                   string'("|") & HEX_TO_STRING(ADDR  ) &
                   string'("|") & BIN_TO_STRING(AWRITE) &
                   string'(" ") & HEX_TO_STRING(ALEN  ) &
                   string'(" ") & HEX_TO_STRING(ASIZE ) &
                   string'(" ") & HEX_TO_STRING(ABURST) &
                   string'(" ") & HEX_TO_STRING(ALOCK ) &
                   string'(" ") & HEX_TO_STRING(ACACHE) &
                   string'(" ") & HEX_TO_STRING(APROT ) &
                   string'(" ") & BIN_TO_STRING(AVALID) &
                   string'(" ") & BIN_TO_STRING(AREADY) &
                   string'("|") & HEX_TO_STRING(resize(WID,8)) &
                   string'("|") & HEX_TO_STRING(WDATA ) &
                   string'("|") & BIN_TO_STRING(WSTRB ) &
                   string'("|") & BIN_TO_STRING(WLAST ) &
                   string'(" ") & BIN_TO_STRING(WVALID) &
                   string'(" ") & BIN_TO_STRING(WREADY) &
                   string'("|") & HEX_TO_STRING(resize(RID,8)) &
                   string'("|") & HEX_TO_STRING(RDATA ) &
                   string'("|") & HEX_TO_STRING(RRESP ) &
                   string'(" ") & BIN_TO_STRING(RLAST ) &
                   string'(" ") & BIN_TO_STRING(RVALID) &
                   string'(" ") & BIN_TO_STRING(RREADY) &
                   string'("|") & HEX_TO_STRING(resize(BID,8)) &
                   string'("|") & HEX_TO_STRING(BRESP ) &
                   string'(" ") & BIN_TO_STRING(BVALID) &
                   string'(" ") & BIN_TO_STRING(BREADY));
        end loop;
    end process;
end MODEL;
