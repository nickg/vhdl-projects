-----------------------------------------------------------------------------------
--!     @file    axi4_signal_printer.vhd
--!     @brief   AXI4 Signal Printer Module.
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
entity  AXI4_SIGNAL_PRINTER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        NAME            : --! @brief 固有名詞.
                          STRING;
        TAG             : --! @brief タグ.
                          STRING;
        READ_ENABLE     : --! @brief リードチャネルを出力するか否かを指定する.
                          boolean   := TRUE;
        WRITE_ENABLE    : --! @brief ライトチャネルを出力するか否かを指定する.
                          boolean   := TRUE;
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
                          AXI4_SIGNAL_WIDTH_TYPE
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
        -- リードアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        ARADDR          : in    std_logic_vector(WIDTH.ARADDR -1 downto 0);
        ARLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        ARSIZE          : in    AXI4_ASIZE_TYPE;
        ARBURST         : in    AXI4_ABURST_TYPE;
        ARLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        ARCACHE         : in    AXI4_ACACHE_TYPE;
        ARPROT          : in    AXI4_APROT_TYPE;
        ARQOS           : in    AXI4_AQOS_TYPE;
        ARREGION        : in    AXI4_AREGION_TYPE;
        ARUSER          : in    std_logic_vector(WIDTH.ARUSER -1 downto 0);
        ARID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        ARVALID         : in    std_logic;
        ARREADY         : in    std_logic;
        --------------------------------------------------------------------------
        -- リードチャネルシグナル.
        --------------------------------------------------------------------------
        RLAST           : in    std_logic;
        RDATA           : in    std_logic_vector(WIDTH.RDATA  -1 downto 0);
        RRESP           : in    AXI4_RESP_TYPE;
        RUSER           : in    std_logic_vector(WIDTH.RUSER  -1 downto 0);
        RID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        RVALID          : in    std_logic;
        RREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        AWADDR          : in    std_logic_vector(WIDTH.AWADDR -1 downto 0);
        AWLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        AWSIZE          : in    AXI4_ASIZE_TYPE;
        AWBURST         : in    AXI4_ABURST_TYPE;
        AWLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        AWCACHE         : in    AXI4_ACACHE_TYPE;
        AWPROT          : in    AXI4_APROT_TYPE;
        AWQOS           : in    AXI4_AQOS_TYPE;
        AWREGION        : in    AXI4_AREGION_TYPE;
        AWUSER          : in    std_logic_vector(WIDTH.AWUSER -1 downto 0);
        AWID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        AWVALID         : in    std_logic;
        AWREADY         : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
        WLAST           : in    std_logic;
        WDATA           : in    std_logic_vector(WIDTH.WDATA  -1 downto 0);
        WSTRB           : in    std_logic_vector(WIDTH.WDATA/8-1 downto 0);
        WUSER           : in    std_logic_vector(WIDTH.WUSER  -1 downto 0);
        WID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        WVALID          : in    std_logic;
        WREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BRESP           : in    AXI4_RESP_TYPE;
        BUSER           : in    std_logic_vector(WIDTH.BUSER  -1 downto 0);
        BID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        BVALID          : in    std_logic;
        BREADY          : in    std_logic
    );
end     AXI4_SIGNAL_PRINTER;
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
architecture MODEL of AXI4_SIGNAL_PRINTER is
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
        constant raddr_id : string := strcont("ARADDR", ARADDR'length  ,4);
        constant raddr_sp : string := strcont(' '     , ARADDR'length  ,4);
        constant raddr_hl : string := strcont('-'     , ARADDR'length  ,4);
        constant raddr_fm : string := strcont('h'     , ARADDR'length  ,4);
        constant rdata_id : string := strcont("RDATA" , RDATA'length   ,4);
        constant rdata_sp : string := strcont(' '     , RDATA'length   ,4);
        constant rdata_hl : string := strcont('-'     , RDATA'length   ,4);
        constant rdata_fm : string := strcont('h'     , RDATA'length   ,4);
        constant waddr_id : string := strcont("AWADDR", AWADDR'length  ,4);
        constant waddr_sp : string := strcont(' '     , AWADDR'length  ,4);
        constant waddr_hl : string := strcont('-'     , AWADDR'length  ,4);
        constant waddr_fm : string := strcont('h'     , AWADDR'length  ,4);
        constant wdata_id : string := strcont("WDATA" , WDATA'length   ,4);
        constant wdata_sp : string := strcont(' '     , WDATA'length   ,4);
        constant wdata_hl : string := strcont('-'     , WDATA'length   ,4);
        constant wdata_fm : string := strcont('h'     , WDATA'length   ,4);
        constant wstrb_id : string := strcont("WSTB"  , WSTRB'length   ,1);
        constant wstrb_sp : string := strcont(' '     , WSTRB'length   ,1);
        constant wstrb_hl : string := strcont('-'     , WSTRB'length   ,1);
        constant wstrb_fm : string := strcont('b'     , WSTRB'length   ,1);
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
        constant r_head_0 : string := "|   " & raddr_sp & "      A   A     A A|   " & rdata_sp & "        |";
        constant r_head_1 : string := "|   " & raddr_sp & "    A R A R A   R R|   " & rdata_sp & "     R R|";
        constant r_head_2 : string := "|   " & raddr_sp & "  A R B R C R A V R|   " & rdata_sp & " R R V R|";
        constant r_head_3 : string := "|   " & raddr_sp & "  R S U L A P R A E|   " & rdata_sp & " R L A E|";
        constant r_head_4 : string := "|   " & raddr_sp & "  L I R O C R Q L A|   " & rdata_sp & " E A L A|";
        constant r_head_5 : string := "|   " & raddr_sp & "  E Z S C H O O I D|   " & rdata_sp & " S S I D|";
        constant r_head_6 : string := "|ID " & raddr_id & "  N E T K E T S D Y|ID " & rdata_id & " P T D Y|";
        constant r_head_7 : string := "| M|" & raddr_sp & "| M M M M M M M M S| M|" & rdata_sp & "|S S S M|";
        constant r_head_8 : string := "|hh|" & raddr_fm & "|hh h h h h h h b b|hh|" & rdata_fm & "|h b b b|";
        constant r_head_h : string := "+--+" & raddr_hl & "+------------------+--+" & rdata_hl & "+-------|";
        constant w_head_0 : string := "|   " & waddr_sp & "      A   A     A A|   " & wdata_sp & " " & wstrb_sp & "      |        |";
        constant w_head_1 : string := "|   " & waddr_sp & "    A W A W A   W W|   " & wdata_sp & " " & wstrb_sp & "   W W|     B B|";
        constant w_head_2 : string := "|   " & waddr_sp & "  A W B W C W A V R|   " & wdata_sp & " " & wstrb_sp & " W V R|   B V R|";
        constant w_head_3 : string := "|   " & waddr_sp & "  W S U L A P W A E|   " & wdata_sp & " " & wstrb_sp & " L A E|   R A E|";
        constant w_head_4 : string := "|   " & waddr_sp & "  L I R O C R Q L A|   " & wdata_sp & " " & wstrb_sp & " A L A|   E L A|";
        constant w_head_5 : string := "|   " & waddr_sp & "  E Z S C H O O I D|   " & wdata_sp & " " & wstrb_sp & " S I D|   S I D|";
        constant w_head_6 : string := "|ID " & waddr_id & "  N E T K E T S D Y|ID " & wdata_id & " " & wstrb_id & " T D Y|ID P D Y|";
        constant w_head_7 : string := "| S|" & waddr_sp & "| M M M M M M M M S| M|" & wdata_sp & "|" & wstrb_sp & "|M M S| S|S S M|";
        constant w_head_8 : string := "|hh|" & waddr_fm & "|hh h h h h h h b b|hh|" & wdata_fm & "|" & wstrb_fm & "|b b b|hh|h b b|";
        constant w_head_h : string := "|--+" & waddr_hl & "+------------------+--+" & wdata_hl & "+" & wstrb_hl & "+-----+--+-----|";
    begin
        if (READ_ENABLE = TRUE and WRITE_ENABLE = TRUE) then
            p(s_head_0 & r_head_0 & w_head_0);
            p(s_head_1 & r_head_1 & w_head_1);
            p(s_head_2 & r_head_2 & w_head_2);
            p(s_head_3 & r_head_3 & w_head_3);
            p(s_head_4 & r_head_4 & w_head_4);
            p(s_head_5 & r_head_5 & w_head_5);
            p(s_head_6 & r_head_6 & w_head_6);
            p(s_head_h & r_head_h & w_head_h);
            p(s_head_7 & r_head_7 & w_head_7);
            p(s_head_8 & r_head_8 & w_head_8);
            p(s_head_h & r_head_h & w_head_h);
            READ_WRITE_LOOP:loop
                wait until (ACLK'event and ACLK = '1');
                p(Now, string'("|") & HEX_TO_STRING(resize(ARID,8)) &
                       string'("|") & HEX_TO_STRING(ARADDR ) &
                       string'("|") & HEX_TO_STRING(resize(ARLEN,AXI4_ALEN_MAX_WIDTH)) &
                       string'(" ") & HEX_TO_STRING(ARSIZE ) &
                       string'(" ") & HEX_TO_STRING(ARBURST) &
                       string'(" ") & HEX_TO_STRING(ARLOCK ) &
                       string'(" ") & HEX_TO_STRING(ARCACHE) &
                       string'(" ") & HEX_TO_STRING(ARPROT ) &
                       string'(" ") & HEX_TO_STRING(ARQOS  ) &
                       string'(" ") & BIN_TO_STRING(ARVALID) &
                       string'(" ") & BIN_TO_STRING(ARREADY) &
                       string'("|") & HEX_TO_STRING(resize(RID,8)) &
                       string'("|") & HEX_TO_STRING(RDATA  ) &
                       string'("|") & HEX_TO_STRING(RRESP  ) &
                       string'(" ") & BIN_TO_STRING(RLAST  ) &
                       string'(" ") & BIN_TO_STRING(RVALID ) &
                       string'(" ") & BIN_TO_STRING(RREADY ) &
                       string'("|") & 
                       string'("|") & HEX_TO_STRING(resize(AWID,8)) &
                       string'("|") & HEX_TO_STRING(AWADDR ) &
                       string'("|") & HEX_TO_STRING(resize(AWLEN,AXI4_ALEN_MAX_WIDTH)) &
                       string'(" ") & HEX_TO_STRING(AWSIZE ) &
                       string'(" ") & HEX_TO_STRING(AWBURST) &
                       string'(" ") & HEX_TO_STRING(AWLOCK ) &
                       string'(" ") & HEX_TO_STRING(AWCACHE) &
                       string'(" ") & HEX_TO_STRING(AWPROT ) &
                       string'(" ") & HEX_TO_STRING(AWQOS  ) &
                       string'(" ") & BIN_TO_STRING(AWVALID) &
                       string'(" ") & BIN_TO_STRING(AWREADY) &
                       string'("|") & HEX_TO_STRING(resize(WID,8)) &
                       string'("|") & HEX_TO_STRING(WDATA  ) &
                       string'("|") & BIN_TO_STRING(WSTRB  ) &
                       string'("|") & BIN_TO_STRING(WLAST  ) &
                       string'(" ") & BIN_TO_STRING(WVALID ) &
                       string'(" ") & BIN_TO_STRING(WREADY ) &
                       string'("|") & HEX_TO_STRING(resize(BID,8)) &
                       string'("|") & HEX_TO_STRING(BRESP  ) &
                       string'(" ") & BIN_TO_STRING(BVALID ) &
                       string'(" ") & BIN_TO_STRING(BREADY ) &
                       string'("|"));
            end loop;
        end if;
        if (READ_ENABLE = TRUE and WRITE_ENABLE = FALSE) then
            p(s_head_0 & r_head_0);
            p(s_head_1 & r_head_1);
            p(s_head_2 & r_head_2);
            p(s_head_3 & r_head_3);
            p(s_head_4 & r_head_4);
            p(s_head_5 & r_head_5);
            p(s_head_6 & r_head_6);
            p(s_head_h & r_head_h);
            p(s_head_7 & r_head_7);
            p(s_head_8 & r_head_8);
            p(s_head_h & r_head_h);
            READ_ONLY_LOOP:loop
                wait until (ACLK'event and ACLK = '1');
                p(Now, string'("|") & HEX_TO_STRING(resize(ARID,8)) &
                       string'("|") & HEX_TO_STRING(ARADDR ) &
                       string'("|") & HEX_TO_STRING(resize(ARLEN,AXI4_ALEN_MAX_WIDTH)) &
                       string'(" ") & HEX_TO_STRING(ARSIZE ) &
                       string'(" ") & HEX_TO_STRING(ARBURST) &
                       string'(" ") & HEX_TO_STRING(ARLOCK ) &
                       string'(" ") & HEX_TO_STRING(ARCACHE) &
                       string'(" ") & HEX_TO_STRING(ARPROT ) &
                       string'(" ") & HEX_TO_STRING(ARQOS  ) &
                       string'(" ") & BIN_TO_STRING(ARVALID) &
                       string'(" ") & BIN_TO_STRING(ARREADY) &
                       string'("|") & HEX_TO_STRING(resize(RID,8)) &
                       string'("|") & HEX_TO_STRING(RDATA  ) &
                       string'("|") & HEX_TO_STRING(RRESP  ) &
                       string'(" ") & BIN_TO_STRING(RLAST  ) &
                       string'(" ") & BIN_TO_STRING(RVALID ) &
                       string'(" ") & BIN_TO_STRING(RREADY ) &
                       string'("|"));
            end loop;
        end if;
        if (READ_ENABLE = FALSE and WRITE_ENABLE = TRUE) then
            p(s_head_0 & w_head_0);
            p(s_head_1 & w_head_1);
            p(s_head_2 & w_head_2);
            p(s_head_3 & w_head_3);
            p(s_head_4 & w_head_4);
            p(s_head_5 & w_head_5);
            p(s_head_6 & w_head_6);
            p(s_head_h & w_head_h);
            p(s_head_7 & w_head_7);
            p(s_head_8 & w_head_8);
            p(s_head_h & w_head_h);
            WRITE_ONLY_LOOP:loop
                wait until (ACLK'event and ACLK = '1');
                p(Now, string'("|") & HEX_TO_STRING(resize(AWID,8)) &
                       string'("|") & HEX_TO_STRING(AWADDR ) &
                       string'("|") & HEX_TO_STRING(resize(AWLEN,AXI4_ALEN_MAX_WIDTH)) &
                       string'(" ") & HEX_TO_STRING(AWSIZE ) &
                       string'(" ") & HEX_TO_STRING(AWBURST) &
                       string'(" ") & HEX_TO_STRING(AWLOCK ) &
                       string'(" ") & HEX_TO_STRING(AWCACHE) &
                       string'(" ") & HEX_TO_STRING(AWPROT ) &
                       string'(" ") & HEX_TO_STRING(AWQOS  ) &
                       string'(" ") & BIN_TO_STRING(AWVALID) &
                       string'(" ") & BIN_TO_STRING(AWREADY) &
                       string'("|") & HEX_TO_STRING(resize(WID,8)) &
                       string'("|") & HEX_TO_STRING(WDATA  ) &
                       string'("|") & BIN_TO_STRING(WSTRB  ) &
                       string'("|") & BIN_TO_STRING(WLAST  ) &
                       string'(" ") & BIN_TO_STRING(WVALID ) &
                       string'(" ") & BIN_TO_STRING(WREADY ) &
                       string'("|") & HEX_TO_STRING(resize(BID,8)) &
                       string'("|") & HEX_TO_STRING(BRESP  ) &
                       string'(" ") & BIN_TO_STRING(BVALID ) &
                       string'(" ") & BIN_TO_STRING(BREADY ) &
                       string'("|"));
            end loop;
        end if;
    end process;
end MODEL;
