-----------------------------------------------------------------------------------
--!     @file    pipeline_register_test_bench.vhd
--!     @brief   PIPELINE REGISTER TEST BENCH :
--!              PIPELINE_REGISTERを検証するためのテストベンチ.
--!     @version 1.7.0
--!     @date    2018/6/14
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2018 Ichiro Kawazome
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
-----------------------------------------------------------------------------------
-- コンポーネント宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
package COMPONENTS is
component PIPELINE_REGISTER_TEST_BENCH
    generic (
        QUEUE_SIZE  : integer := 1
    );
    port (
        FINISH      : out std_logic
    );
end component;
end COMPONENTS;
-----------------------------------------------------------------------------------
-- エンティティ宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  PIPELINE_REGISTER_TEST_BENCH is
    generic (
        QUEUE_SIZE  : integer := 1
    );
    port (
        FINISH      : out std_logic
    );
end     PIPELINE_REGISTER_TEST_BENCH;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.PIPELINE_REGISTER;
architecture MODEL of PIPELINE_REGISTER_TEST_BENCH is
    constant    PERIOD          :  time    := 10 ns;
    constant    DELAY           :  time    :=  1 ns;
    constant    WORD_BITS       :  integer :=  8;
    signal      clk_ena         :  boolean;
    signal      CLK             :  std_logic;
    signal      RST             :  std_logic;
    signal      CLR             :  std_logic;
    signal      BUSY            :  std_logic;
    signal      VALID           :  std_logic_vector(QUEUE_SIZE  downto 0);
    signal      I_WORD          :  std_logic_vector(WORD_BITS-1 downto 0);
    signal      I_VAL           :  std_logic;
    signal      I_RDY           :  std_logic;
    signal      Q_WORD          :  std_logic_vector(WORD_BITS-1 downto 0);
    signal      Q_VAL           :  std_logic;
    signal      Q_RDY           :  std_logic;
    signal      I_RUN           :  boolean;
    signal      O_RUN           :  boolean;
    function    MESSAGE_TAG return STRING is
    begin
        return "(QUEUE_SIZE="  & INTEGER_TO_STRING(QUEUE_SIZE) & "):";
    end function;
    procedure WAIT_CLK(CNT:integer) is
    begin
        for i in 1 to CNT loop 
            wait until (CLK'event and CLK = '1'); 
        end loop;
        wait for DELAY;
    end procedure;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DUT: PIPELINE_REGISTER               -- 
        generic map(                     -- 
            WORD_BITS   => WORD_BITS   , -- 
            QUEUE_SIZE  => QUEUE_SIZE    -- 
        )                                -- 
        port map (                       -- 
            CLK         => CLK         , -- In  :
            RST         => RST         , -- In  :
            CLR         => CLR         , -- In  :
            I_WORD      => I_WORD      , -- In  :
            I_VAL       => I_VAL       , -- In  :
            I_RDY       => I_RDY       , -- Out :
            Q_WORD      => Q_WORD      , -- Out :
            Q_VAL       => Q_VAL       , -- Out :
            Q_RDY       => Q_RDY       , -- In  :
            VALID       => VALID       , -- Out :
            BUSY        => BUSY          -- Out :
    );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process begin
        while (TRUE) loop
            CLK <= '1'; wait for PERIOD/2;
            CLK <= '0'; wait for PERIOD/2;
            exit when (clk_ena = FALSE);
        end loop;
        CLK <= '0';
        wait;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I_TEST: process
        procedure TEST(CNT: integer; DATA: integer) is
        begin
            WAIT_CLK(CNT);
            I_VAL  <= '1';
            I_WORD <= std_logic_vector(to_unsigned(DATA,WORD_BITS));
            WAIT_LOOP: loop
                wait until (CLK'event and CLK = '1');
                exit when  (I_RDY = '1');
            end loop;
            I_VAL  <= '0' after DELAY;
            I_WORD <= (others => '1') after DELAY;
        end procedure;
        procedure TEST_START is
        begin
            wait until (CLK'event and CLK = '1');
            I_RUN <= TRUE after DELAY;
            WAIT_LOOP: loop
                wait until (CLK'event and CLK = '1');
                exit when  (O_RUN = TRUE);
            end loop;
        end procedure;
        procedure TEST_DONE is
        begin
            wait until (CLK'event and CLK = '1');
            I_RUN <= FALSE after DELAY;
            WAIT_LOOP: loop
                wait until (CLK'event and CLK = '1');
                exit when  (O_RUN = FALSE);
            end loop;
        end procedure;
    begin 
        ---------------------------------------------------------------------------
        -- シミュレーションの開始、まずはリセットから。
        ---------------------------------------------------------------------------
        assert(false) report MESSAGE_TAG & "Starting Run..." severity NOTE;
                              clk_ena <= TRUE;
                              CLR     <= '1';
                              RST     <= '1';
                              I_VAL   <= '0';
                              I_WORD  <= (others => '1');
                              I_RUN   <= FALSE;
        WAIT_CLK( 4);         RST     <= '0';
                              CLR     <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- SCENARIO 1.1
        ---------------------------------------------------------------------------
        TEST_START;
        assert(false) report MESSAGE_TAG & "SCENARIO 1.1 Start" severity NOTE;
        for i in 1 to 10 loop
            TEST(0, i);
        end loop;
        TEST_DONE;
        assert(false) report MESSAGE_TAG & "SCENARIO 1.1 Done"  severity NOTE;
        ---------------------------------------------------------------------------
        -- SCENARIO 1.2
        ---------------------------------------------------------------------------
        TEST_START;
        assert(false) report MESSAGE_TAG & "SCENARIO 1.2 Start" severity NOTE;
        for i in 11 to 20 loop
            TEST(0, i);
        end loop;
        TEST_DONE;
        assert(false) report MESSAGE_TAG & "SCENARIO 1.2 Done"  severity NOTE;
        ---------------------------------------------------------------------------
        -- SCENARIO 1.3
        ---------------------------------------------------------------------------
        TEST_START;
        assert(false) report MESSAGE_TAG & "SCENARIO 1.3 Start" severity NOTE;
        WAIT_CLK(4);
        for i in 21 to 30 loop
            TEST(0, i);
        end loop;
        TEST_DONE;
        assert(false) report MESSAGE_TAG & "SCENARIO 1.3 Done"  severity NOTE;
        ---------------------------------------------------------------------------
        -- SCENARIO 2.1
        ---------------------------------------------------------------------------
        TEST_START;
        assert(false) report MESSAGE_TAG & "SCENARIO 2.1 Start" severity NOTE;
        for i in 1 to 10 loop
            TEST(0, i);
        end loop;
        TEST_DONE;
        assert(false) report MESSAGE_TAG & "SCENARIO 2.1 Done"  severity NOTE;
        ---------------------------------------------------------------------------
        -- SCENARIO 2.2
        ---------------------------------------------------------------------------
        TEST_START;
        assert(false) report MESSAGE_TAG & "SCENARIO 2.2 Start" severity NOTE;
        for i in 1 to 10 loop
            TEST(1, i);
        end loop;
        TEST_DONE;
        assert(false) report MESSAGE_TAG & "SCENARIO 2.2 Done"  severity NOTE;
        ---------------------------------------------------------------------------
        -- SCENARIO 2.3
        ---------------------------------------------------------------------------
        TEST_START;
        assert(false) report MESSAGE_TAG & "SCENARIO 2.3 Start" severity NOTE;
        for i in 1 to 10 loop
            TEST(1, i);
        end loop;
        TEST_DONE;
        assert(false) report MESSAGE_TAG & "SCENARIO 2.3 Done"  severity NOTE;
        ---------------------------------------------------------------------------
        -- シミュレーション終了
        ---------------------------------------------------------------------------
        WAIT_CLK(10);
        assert(false) report MESSAGE_TAG & "Run complete..." severity NOTE;
        FINISH  <= 'Z';
        clk_ena <= FALSE;
        wait;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_TEST: process
        procedure TEST(CNT: integer; DATA: integer) is
            variable ext_data : std_logic_vector(7 downto 0);
            variable int_data : integer;
        begin
            ext_data := std_logic_vector(to_unsigned(DATA,WORD_BITS));
            WAIT_CLK(CNT);
            Q_RDY  <= '1';
            WAIT_LOOP: loop
                wait until (CLK'event and CLK = '1');
                exit when  (Q_VAL = '1');
            end loop;
            int_data := to_integer(unsigned(Q_WORD));
            assert (Q_WORD = ext_data) report MESSAGE_TAG & "Mismatch O_WORD=" & INTEGER_TO_STRING(int_data) & " EXT_WORD=" & INTEGER_TO_STRING(DATA) severity ERROR;
            Q_RDY  <= '0'  after DELAY;
        end procedure;
        procedure TEST_START is
        begin
            wait until (CLK'event and CLK = '1');
            O_RUN <= TRUE after DELAY;
            WAIT_LOOP: loop
                wait until (CLK'event and CLK = '1');
                exit when  (I_RUN = TRUE);
            end loop;
        end procedure;
        procedure TEST_DONE is
        begin
            wait until (CLK'event and CLK = '1');
            O_RUN <= FALSE after DELAY;
            WAIT_LOOP: loop
                wait until (CLK'event and CLK = '1');
                exit when  (I_RUN = FALSE);
            end loop;
        end procedure;
    begin
        Q_RDY  <= '0';
        O_RUN  <= FALSE;
        ---------------------------------------------------------------------------
        -- SCENARIO 1.1
        ---------------------------------------------------------------------------
        TEST_START;
        for i in 1 to 10 loop
            TEST(0, i);
        end loop;
        TEST_DONE;
        ---------------------------------------------------------------------------
        -- SCENARIO 1.2
        ---------------------------------------------------------------------------
        TEST_START;
        WAIT_CLK(3);
        for i in 11 to 20 loop
            TEST(0, i);
        end loop;
        TEST_DONE;
        ---------------------------------------------------------------------------
        -- SCENARIO 1.3
        ---------------------------------------------------------------------------
        TEST_START;
        for i in 21 to 30 loop
            TEST(0, i);
        end loop;
        TEST_DONE;
        ---------------------------------------------------------------------------
        -- SCENARIO 2.1
        ---------------------------------------------------------------------------
        TEST_START;
        for i in 1 to 10 loop
            TEST(1, i);
        end loop;
        TEST_DONE;
        ---------------------------------------------------------------------------
        -- SCENARIO 2.2
        ---------------------------------------------------------------------------
        TEST_START;
        for i in 1 to 10 loop
            TEST(0, i);
        end loop;
        TEST_DONE;
        ---------------------------------------------------------------------------
        -- SCENARIO 2.3
        ---------------------------------------------------------------------------
        TEST_START;
        for i in 1 to 10 loop
            TEST(1, i);
        end loop;
        TEST_DONE;
        ---------------------------------------------------------------------------
        -- シミュレーション終了
        ---------------------------------------------------------------------------
        assert(false) report MESSAGE_TAG & "Complete O_TEST..." severity NOTE;
        wait;
    end process;
end MODEL;
-----------------------------------------------------------------------------------
-- PIPELINE_REGISTER_TEST_BENCH_0 (QUEUE_SIZE=0)
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  PIPELINE_REGISTER_TEST_BENCH_0 is
end     PIPELINE_REGISTER_TEST_BENCH_0;
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.PIPELINE_REGISTER_TEST_BENCH;
architecture MODEL of PIPELINE_REGISTER_TEST_BENCH_0 is
begin
    TB:PIPELINE_REGISTER_TEST_BENCH generic map (QUEUE_SIZE => 0) port map(FINISH => open);
end MODEL;
-----------------------------------------------------------------------------------
-- PIPELINE_REGISTER_TEST_BENCH_1 (QUEUE_SIZE=1)
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  PIPELINE_REGISTER_TEST_BENCH_1 is
end     PIPELINE_REGISTER_TEST_BENCH_1;
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.PIPELINE_REGISTER_TEST_BENCH;
architecture MODEL of PIPELINE_REGISTER_TEST_BENCH_1 is
begin
    TB:PIPELINE_REGISTER_TEST_BENCH generic map (QUEUE_SIZE => 1) port map(FINISH => open);
end MODEL;
-----------------------------------------------------------------------------------
-- PIPELINE_REGISTER_TEST_BENCH_2 (QUEUE_SIZE=2)
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  PIPELINE_REGISTER_TEST_BENCH_2 is
end     PIPELINE_REGISTER_TEST_BENCH_2;
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.PIPELINE_REGISTER_TEST_BENCH;
architecture MODEL of PIPELINE_REGISTER_TEST_BENCH_2 is
begin
    TB:PIPELINE_REGISTER_TEST_BENCH generic map (QUEUE_SIZE => 2) port map(FINISH => open);
end MODEL;
-----------------------------------------------------------------------------------
-- PIPELINE_REGISTER_TEST_BENCH_ALL (QUEUE_SIZE=0,1,2)
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  PIPELINE_REGISTER_TEST_BENCH_ALL is
end     PIPELINE_REGISTER_TEST_BENCH_ALL;
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.PIPELINE_REGISTER_TEST_BENCH;
architecture MODEL of PIPELINE_REGISTER_TEST_BENCH_ALL is
    signal FINISH : std_logic;
begin
    TB0:PIPELINE_REGISTER_TEST_BENCH generic map (QUEUE_SIZE => 0) port map(FINISH => FINISH);
    TB1:PIPELINE_REGISTER_TEST_BENCH generic map (QUEUE_SIZE => 1) port map(FINISH => FINISH);
    TB2:PIPELINE_REGISTER_TEST_BENCH generic map (QUEUE_SIZE => 2) port map(FINISH => FINISH);
    FINISH <= 'H' after 1 ns;
    process (FINISH) begin
        if (FINISH'event and FINISH = 'H') then
            assert(false) report "Run complete all." severity NOTE;
        end if;
    end process;
end MODEL;
