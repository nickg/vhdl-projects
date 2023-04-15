-----------------------------------------------------------------------------------
--!     @file    test_bench.vhd
--!     @brief   Synchronous Dual Port RAM Test Bench.
--!     @version 1.8.0
--!     @date    2019/3/28
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2019 Ichiro Kawazome
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
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.MT19937AR.SEED_TYPE;
use     DUMMY_PLUG.MT19937AR.TO_SEED_TYPE;
use     DUMMY_PLUG.MT19937AR.PSEUDO_RANDOM_NUMBER_GENERATOR_TYPE;
use     DUMMY_PLUG.MT19937AR.NEW_PSEUDO_RANDOM_NUMBER_GENERATOR;
use     DUMMY_PLUG.MT19937AR.GENERATE_RANDOM_REAL1;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.SDPRAM;
entity  SDPRAM_TEST_BENCH is
    generic (
        DEPTH       : integer := 9;
        RWIDTH      : integer := 5;
        WWIDTH      : integer := 6;
        WEBIT       : integer := 0
    );
    port (
        FINISH      : out std_logic
    );
end     SDPRAM_TEST_BENCH;
architecture MODEL of SDPRAM_TEST_BENCH is
    procedure INT_TO_STRING(constant VAL : in  integer;
                            constant LEN : in  integer;
                            variable STR : out STRING )
    is
        variable buf   : string(STR'length downto 1);
        variable pos   : integer;
        variable tmp   : integer;
        variable digit : integer range 0 to 9;
    begin
        pos := 1;
        tmp := abs(VAL);
        for i in 1 to LEN loop
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
        end loop;
        if (VAL < 0) then
            buf(pos) := '-';
        else
            pos := pos - 1;
        end if;
        STR(1 to pos) := buf(pos downto 1);
    end INT_TO_STRING; -- procedure

    function  INT_TO_STRING(VAL:integer;LEN:integer) return STRING is
        variable str : string(1 to 32);
    begin
        INT_TO_STRING(VAL, LEN, str);
        return str(1 to LEN);
    end INT_TO_STRING;

    function  MAKE_INSTANCE_NAME return STRING is
        variable str : string(1 to 19);
    begin
        str := "DEPTH" & INT_TO_STRING(DEPTH ,2) & 
               "_RD"   & INT_TO_STRING(RWIDTH,1) & 
               "_WD"   & INT_TO_STRING(WWIDTH,1) & 
               "_WE"   & INT_TO_STRING(WEBIT ,1);
        return str;
    end MAKE_INSTANCE_NAME;

    constant  INSTANCE_NAME  : string(1 to 19) := MAKE_INSTANCE_NAME;

    constant  PERIOD      : time    := 10 ns;
    constant  DELAY       : time    :=  1 ns;

    constant  HEX         : STRING(1 to 16) := "0123456789ABCDEF";
    signal    SCENARIO    : STRING(1 to 5);

    signal    CLK         : std_logic;
    signal    RST         : std_logic;
    signal    WE          : std_logic_vector(2**WEBIT-1 downto 0);
    signal    WADDR       : std_logic_vector(DEPTH-1 downto WWIDTH);
    signal    RADDR       : std_logic_vector(DEPTH-1 downto RWIDTH);
    signal    WDATA       : std_logic_vector(2**WWIDTH-1 downto 0);
    signal    RDATA       : std_logic_vector(2**RWIDTH-1 downto 0);
    signal    EXP_Q       : bit_vector(2**RWIDTH-1 downto 0);
    signal    EXP_F       : bit_vector(2**RWIDTH-1 downto 0);
    signal    CLK_ENA     : boolean;

begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    U: SDPRAM
        generic map (
            DEPTH   => DEPTH,
            RWIDTH  => RWIDTH,
            WWIDTH  => WWIDTH,
            WEBIT   => WEBIT,
            ID      => 0
        )
        port map(
            WCLK    => CLK,
            WE      => WE,
            WADDR   => WADDR(DEPTH-1 downto WWIDTH),
            RCLK    => CLK,
            RADDR   => RADDR(DEPTH-1 downto RWIDTH),
            WDATA   => WDATA,
            RDATA   => RDATA
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process begin
        loop
            CLK <= '1'; wait for PERIOD/2;
            CLK <= '0'; wait for PERIOD/2;
            exit when(CLK_ENA = FALSE);
        end loop;
        CLK <= '0';
        wait;
    end process;
    -------------------------------------------------------------------------------
    -- 入力側のモデル
    -------------------------------------------------------------------------------
    process 
        procedure WAIT_CLK(CNT:integer) is
        begin
            if (CNT > 0) then
                for i in 1 to CNT loop 
                    wait until (CLK'event and CLK = '1'); 
                end loop;
                wait for DELAY;
            end if;
        end WAIT_CLK;
        ---------------------------------------------------------------------------
        -- 乱数生成用変数およびプロシージャ
        ---------------------------------------------------------------------------
        variable  prng  : PSEUDO_RANDOM_NUMBER_GENERATOR_TYPE
                        := NEW_PSEUDO_RANDOM_NUMBER_GENERATOR(1623);
        variable  count : integer := 0;
        variable  text_line     : LINE;
        constant  SPACE         : STRING(1 to 1) := " ";
        procedure GENERATE_UNIFORM_RANDOM(
            variable value      : out integer;
                     startpoint : in  integer;
                     endpoint   : in  integer
        ) is
            variable random_number : real;
            variable random_value  : integer;
        begin
            GENERATE_RANDOM_REAL1(prng,random_number);
          --WRITE(text_line, count);
          --WRITE(text_line, SPACE);
          --WRITE(text_line, startpoint);
          --WRITE(text_line, SPACE);
          --WRITE(text_line, endpoint);
          --WRITE(text_line, SPACE);
            random_value := startpoint + integer(random_number*real(endpoint-startpoint));
            value := random_value;
            count := count + 1;
          --WRITE(text_line, random_value);
          --WRITELINE(OUTPUT, text_line);
        end procedure;
        ---------------------------------------------------------------------------
        -- データパターンテーブル/データ書き込みフラグ
        ---------------------------------------------------------------------------
        variable  table : bit_vector(2**DEPTH-1 downto 0);
        variable  w_ok  : bit_vector(2**DEPTH-1 downto 0);
        ---------------------------------------------------------------------------
        -- 中間変数
        ---------------------------------------------------------------------------
        variable  ptr   : integer;
        variable  len   : integer;
        ---------------------------------------------------------------------------
        -- データパターンテーブル//データ書き込みフラグの初期化を行なうサブルーチン
        ---------------------------------------------------------------------------
        procedure  INIT_TABLE is
            variable   pattern : integer;
        begin
            for i in table'range loop
                GENERATE_UNIFORM_RANDOM(pattern,0,2);
                if (pattern >= 1) then table(i) := '1';
                else                   table(i) := '0';
                end if;
            end loop;
            w_ok := (others => '0');
            WAIT_CLK(1);
        end INIT_TABLE;
        ---------------------------------------------------------------------------
        -- RAMにデータを書き込むプロシージャ(WENがbit_vectorの場合)
        ---------------------------------------------------------------------------
        procedure WRITE(PTR:integer;WEN:bit_vector) is
            variable w_ptr     : integer;
            variable w_be      : bit_vector(2**WWIDTH-1 downto 0);
            constant W_BE_SIZE : integer := (2**WWIDTH)/(2**WEBIT);
        begin
            w_ptr := PTR * (2**WWIDTH);
            for i in WEN'range loop
                for n in 0 to W_BE_SIZE-1 loop
                    w_be(i*W_BE_SIZE + n) := WEN(i);
                end loop;
            end loop;
            for i in 0 to 2**WWIDTH-1 loop
                if (w_be(i) = '1') then
                    if (table(w_ptr+i) = '1') then
                        WDATA(i) <= '1';
                    else
                        WDATA(i) <= '0';
                    end if;
                    w_ok(w_ptr+i) := '1';
                else
                    WDATA(i) <= '0';
                end if;
            end loop;
            WADDR <= std_logic_vector(TO_UNSIGNED(PTR,WADDR'length));
            for i in WEN'range loop
                if (WEN(i) = '1') then WE(i) <= '1';
                else                   WE(i) <= '0';
                end if;
            end loop;
            WAIT_CLK(1);
            WE <= (others => '0');
        end WRITE;
        ---------------------------------------------------------------------------
        -- RAMにデータを書き込むプロシージャ
        ---------------------------------------------------------------------------
        procedure WRITE(PTR:integer;LEN:integer) is
            variable word_ena : bit_vector(2**WEBIT-1 downto 0);
            variable word_ptr : integer;
            variable word_pos : integer;
            variable last_ptr : integer;
            variable last_pos : integer;
        begin
            word_ptr := (PTR      )  /  (2**WWIDTH);
            word_pos := (PTR      ) mod (2**WWIDTH);
            last_ptr := (PTR+LEN-1)  /  (2**WWIDTH);
            while (word_ptr <= last_ptr) loop
                if (word_ptr = last_ptr) then
                    last_pos := (PTR+LEN-1) mod (2**WWIDTH);
                else
                    last_pos := (2**WWIDTH)-1;
                end if;
                for i in word_ena'range loop
                    if (i >= word_pos/(2**(WWIDTH-WEBIT))) and
                       (i <= last_pos/(2**(WWIDTH-WEBIT))) then
                        word_ena(i) := '1';
                    else
                        word_ena(i) := '0';
                    end if;
                end loop;
                WRITE(word_ptr,word_ena);
                word_ptr := word_ptr + 1;
                word_pos := 0;
                exit when (word_ptr*(2**WWIDTH) > (2**(DEPTH-WWIDTH)));
            end loop;
        end WRITE;
        ---------------------------------------------------------------------------
        -- RAMの内容とデータパターンの照合を行なうプロシージャ
        ---------------------------------------------------------------------------
        procedure VERIFY is
            variable d : bit_vector(2**RWIDTH-1 downto 0);
            variable w : bit_vector(2**RWIDTH-1 downto 0);
        begin
            wait until (CLK'event and CLK = '1'); 
            wait for DELAY;
            RADDR <= std_logic_vector(TO_UNSIGNED(0,RADDR'length));
            wait until (CLK'event and CLK = '1'); 
            for r_ptr in 0 to 2**(DEPTH-RWIDTH)-1 loop
                wait for DELAY;
                if (r_ptr < 2**(DEPTH-RWIDTH)-1) then
                    RADDR <= std_logic_vector(TO_UNSIGNED(r_ptr+1,RADDR'length));
                end if;
                for i in 0 to 2**RWIDTH-1 loop
                    d(i) := table(r_ptr*(2**RWIDTH)+i);
                    w(i) := w_ok (r_ptr*(2**RWIDTH)+i);
                end loop;
                EXP_Q <= d;
                EXP_F <= w;
                wait until (CLK'event and CLK = '1'); 
                for i in 0 to 2**RWIDTH-1 loop
                    if (w(i) = '1') and 
                       ((d(i) = '1' and RDATA(i) /= '1') or
                        (d(i) = '0' and RDATA(i) /= '0')) then
                        assert (false) report "Mismatch..." severity FAILURE;
                    end if;
                end loop;
            end loop;
            wait for DELAY;
        end VERIFY;
    begin
        ---------------------------------------------------------------------------
        -- シミュレーションの開始、まずはリセットから。
        ---------------------------------------------------------------------------
        assert(false) report "Starting Run..." severity NOTE;
                       SCENARIO <= "START";
                       CLK_ENA  <= TRUE;
                       RST      <= '1';
                       WADDR    <= (others => '0');
                       WE       <= (others => '0');
                       WDATA    <= (others => '0');
                       RADDR    <= (others => '0');
        WAIT_CLK( 4);  RST      <= '0';
        WAIT_CLK( 4); 
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SCENARIO <= "1.0.0";
        for i in 0 to WEBIT loop
            SCENARIO(5) <= HEX(i+1);
            INIT_TABLE;
            for ptr in 0 to 2**(DEPTH-(WWIDTH-i))-1 loop
                WRITE(ptr*(2**(WWIDTH-i)), 2**(WWIDTH-i));
            end loop;
            VERIFY;
        end loop;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        SCENARIO <= "2.0.0";
        for i in 0 to 9 loop
            SCENARIO(5) <= HEX(i+1);
            INIT_TABLE;
            -- RA <= CONV_STD_LOGIC_VECTOR(1, RA'length);
            for n in 0 to 99 loop
                GENERATE_UNIFORM_RANDOM(ptr, 0, 2**(DEPTH-(WWIDTH-WEBIT))-1);
                GENERATE_UNIFORM_RANDOM(len, 1, 2**(WWIDTH-WEBIT));
                WRITE(ptr*(2**(WWIDTH-WEBIT)), len*(2**(WWIDTH-WEBIT)));
            end loop;
            VERIFY;
        end loop;
        ---------------------------------------------------------------------------
        -- シミュレーション終了
        ---------------------------------------------------------------------------
        WAIT_CLK(10); 
        assert(false) report INSTANCE_NAME & " Run complete..." severity NOTE;
        CLK_ENA <= FALSE;
        FINISH  <= 'Z';
        wait;
    end process;
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチのコンポーネント宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
package COMPONENTS is
component SDPRAM_TEST_BENCH is
    generic (
        DEPTH       : integer := 9;
        RWIDTH      : integer := 5;
        WWIDTH      : integer := 6;
        WEBIT       : integer := 0
    );
    port (
        FINISH      : out std_logic
    );
end component;
end     COMPONENTS;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH08_RD3_WD3_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH08_RD3_WD3_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH08_RD3_WD3_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>8,RWIDTH =>3,WWIDTH=>3,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH08_RD4_WD4_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH08_RD4_WD4_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH08_RD4_WD4_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>8,RWIDTH =>4,WWIDTH=>4,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH08_RD5_WD5_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH08_RD5_WD5_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH08_RD5_WD5_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>8,RWIDTH =>5,WWIDTH=>5,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH08_RD6_WD6_WE3 is
end     SDPRAM_TEST_BENCH_DEPTH08_RD6_WD6_WE3;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH08_RD6_WD6_WE3 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>8,RWIDTH =>6,WWIDTH=>6,WEBIT=>3)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH08_RD3_WD4_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH08_RD3_WD4_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH08_RD3_WD4_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>8,RWIDTH =>3,WWIDTH=>4,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH08_RD3_WD5_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH08_RD3_WD5_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH08_RD3_WD5_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>8,RWIDTH =>3,WWIDTH=>5,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH08_RD4_WD3_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH08_RD4_WD3_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH08_RD4_WD3_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>8,RWIDTH =>4,WWIDTH=>3,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH08_RD5_WD3_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH08_RD5_WD3_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH08_RD5_WD3_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>8,RWIDTH =>5,WWIDTH=>3,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH11_RD6_WD6_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH11_RD6_WD6_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH11_RD6_WD6_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>11,RWIDTH =>6,WWIDTH=>6,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH12_RD6_WD6_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH12_RD6_WD6_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH12_RD6_WD6_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>12,RWIDTH =>6,WWIDTH=>6,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH13_RD6_WD6_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH13_RD6_WD6_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH13_RD6_WD6_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>13,RWIDTH =>6,WWIDTH=>6,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH14_RD6_WD6_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH14_RD6_WD6_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH14_RD6_WD6_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>14,RWIDTH =>6,WWIDTH=>6,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH15_RD6_WD6_WE0 is
end     SDPRAM_TEST_BENCH_DEPTH15_RD6_WD6_WE0;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH15_RD6_WD6_WE0 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>15,RWIDTH =>6,WWIDTH=>6,WEBIT=>0)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_DEPTH15_RD6_WD6_WE3 is
end     SDPRAM_TEST_BENCH_DEPTH15_RD6_WD6_WE3;
architecture    MODEL of SDPRAM_TEST_BENCH_DEPTH15_RD6_WD6_WE3 is
    signal FINISH : std_logic;
begin
    TB:SDPRAM_TEST_BENCH generic map (DEPTH=>15,RWIDTH =>6,WWIDTH=>6,WEBIT=>3)port map (open);
end MODEL;
-----------------------------------------------------------------------------------
-- テストベンチ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.SDPRAM_TEST_BENCH;
entity  SDPRAM_TEST_BENCH_ALL is
end     SDPRAM_TEST_BENCH_ALL;
architecture    MODEL of SDPRAM_TEST_BENCH_ALL is
    signal FINISH : std_logic;
begin
    DEPTH_GEN : for DEPTH  in 8 to 12 generate
    RWIDTH_GEN: for RWIDTH in 3 to 6  generate
    WWIDTH_GEN: for WWIDTH in 3 to 6  generate
    WEBIT_GEN : for WEBIT  in 0 to 1  generate
        TB:SDPRAM_TEST_BENCH generic map (
            DEPTH       => DEPTH,
            RWIDTH      => RWIDTH,
            WWIDTH      => WWIDTH,
            WEBIT       => WEBIT
        )
        port map (
           FINISH       => FINISH
        );
    end generate;
    end generate;
    end generate;
    end generate;
    FINISH <= 'H' after 1 ns;
    process (FINISH) begin
        if (FINISH'event and FINISH = 'H') then
            assert(false) report "Run complete all." severity NOTE;
        end if;
    end process;
end MODEL;
