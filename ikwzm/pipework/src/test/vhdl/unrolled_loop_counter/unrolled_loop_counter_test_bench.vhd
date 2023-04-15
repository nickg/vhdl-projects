-----------------------------------------------------------------------------------
--!     @file    unrolled_loop_counter_test_bench.vhd
--!     @brief   UNROLLED_LOOP_COUNTER TEST BENCH :
--!              UNROLLED_LOOP_COUNTER MODULEを検証するためのテストベンチ.
--!     @version 1.7.1
--!     @date    2018/12/23
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018 Ichiro Kawazome
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
component  UNROLLED_LOOP_COUNTER_TEST_BENCH 
    generic (
        UNROLL          : integer := 1;
        STRIDE          : integer := 1;
        MAX_LOOP_SIZE   : integer := 8;
        MAX_LOOP_INIT   : integer := 0;
        VERBOSE         : boolean := FALSE;
        FINISH_ABORT    : boolean := FALSE
    );
    port (
        FINISH          : out std_logic
    );
end component;
component  UNROLLED_LOOP_COUNTER_FUNCTION_MODEL
    generic (
        UNROLL          : integer := 1;
        STRIDE          : integer := 1;
        MAX_LOOP_SIZE   : integer := 8;
        MAX_LOOP_INIT   : integer := 0;
        VERBOSE         : boolean := FALSE;
        FINISH_ABORT    : boolean := FALSE
    );
    port (
        CLK             : out std_logic; 
        RST             : out std_logic;
        CLR             : out std_logic;
        LOOP_START      : out std_logic;
        LOOP_NEXT       : out std_logic;
        LOOP_SIZE       : out integer range 0 to MAX_LOOP_SIZE;
        LOOP_INIT       : out integer range 0 to MAX_LOOP_INIT;
        LOOP_DONE       : in  std_logic;
        LOOP_BUSY       : in  std_logic;
        LOOP_VALID      : in  std_logic_vector(UNROLL-1 downto 0);
        LOOP_FIRST      : in  std_logic;
        LOOP_LAST       : in  std_logic;
        LOOP_TERM       : in  std_logic;
        NEXT_BUSY       : in  std_logic;
        NEXT_VALID      : in  std_logic_vector(UNROLL-1 downto 0);
        NEXT_FIRST      : in  std_logic;
        NEXT_LAST       : in  std_logic;
        NEXT_TERM       : in  std_logic;
        FINISH          : out std_logic
    );
end component;
end COMPONENTS;
-----------------------------------------------------------------------------------
-- UNROLLED_LOOP_COUNTER_FUNCTION_MODEL のエンティティ宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  UNROLLED_LOOP_COUNTER_FUNCTION_MODEL is
    generic (
        UNROLL          : integer := 1;
        STRIDE          : integer := 1;
        MAX_LOOP_SIZE   : integer := 8;
        MAX_LOOP_INIT   : integer := 0;
        VERBOSE         : boolean := FALSE;
        FINISH_ABORT    : boolean := FALSE
    );
    port (
        CLK             : out std_logic; 
        RST             : out std_logic;
        CLR             : out std_logic;
        LOOP_START      : out std_logic;
        LOOP_NEXT       : out std_logic;
        LOOP_SIZE       : out integer range 0 to MAX_LOOP_SIZE;
        LOOP_INIT       : out integer range 0 to MAX_LOOP_INIT;
        LOOP_DONE       : in  std_logic;
        LOOP_BUSY       : in  std_logic;
        LOOP_VALID      : in  std_logic_vector(UNROLL-1 downto 0);
        LOOP_FIRST      : in  std_logic;
        LOOP_LAST       : in  std_logic;
        LOOP_TERM       : in  std_logic;
        NEXT_BUSY       : in  std_logic;
        NEXT_VALID      : in  std_logic_vector(UNROLL-1 downto 0);
        NEXT_FIRST      : in  std_logic;
        NEXT_LAST       : in  std_logic;
        NEXT_TERM       : in  std_logic;
        FINISH          : out std_logic
    );
end     UNROLLED_LOOP_COUNTER_FUNCTION_MODEL;
-----------------------------------------------------------------------------------
-- UNROLLED_LOOP_COUNTER_GENERATOR_FUNCTION_MODEL のアーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.UTIL.BIN_TO_STRING;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
architecture MODEL of UNROLLED_LOOP_COUNTER_FUNCTION_MODEL is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant    HEX             : STRING(1 to 16) := "0123456789ABCDEF";
    constant    PERIOD          : time    := 10 ns;
    constant    DELAY           : time    :=  2 ns;
    constant    TIMEOUT_CYCLE   : integer := 1000000;
    signal      SCENARIO        : STRING(1 to 5);
    signal      clock           : std_logic;
    signal      clk_ena         : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function    MESSAGE_TAG return STRING is
    begin
        return "(UNROLL="         & INTEGER_TO_STRING(UNROLL       ) &
               ",STRIDE="         & INTEGER_TO_STRING(STRIDE       ) &
               ",MAX_LOOP_SIZE="  & INTEGER_TO_STRING(MAX_LOOP_SIZE) &
               ",MAX_LOOP_INIT="  & INTEGER_TO_STRING(MAX_LOOP_INIT) &
               "):";
    end function;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process begin
        while (TRUE) loop
            CLK <= '1'; clock <= '1'; wait for PERIOD/2;
            CLK <= '0'; clock <= '0'; wait for PERIOD/2;
            exit when (clk_ena = '0');
        end loop;
        CLK <= '0'; clock <= '0';
        wait;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure WAIT_CLK(CNT:integer) is
        begin
            for i in 1 to CNT loop 
                wait until (clock'event and clock = '1'); 
            end loop;
            wait for DELAY;
        end WAIT_CLK;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  EXPECT_VALID_SIZE :  integer := MAX_LOOP_SIZE+MAX_LOOP_INIT+10;
        variable  expect_valid      :  std_logic_vector(EXPECT_VALID_SIZE-1 downto 0);
        procedure GEN_EXPECT_VALID(
            variable  EXP_VALID    :  inout std_logic_vector;
                      LOOP_SIZE    :  in    integer;
                      LOOP_INIT    :  in    integer)
        is
        begin
            for pos in EXP_VALID'range loop
                if (pos >= LOOP_INIT and pos <= LOOP_SIZE-1) then
                    EXP_VALID(pos) := '1';
                else
                    EXP_VALID(pos) := '0';
                end if;
            end loop;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        variable  mismatch_count :  integer;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        variable  test_number    :  integer;
        variable  test_cycle     :  integer;
        variable  test_next      :  std_logic;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure CHECK_VALID(EXP_VALID: in std_logic_vector) is
            alias    expect_valid :  std_logic_vector(LOOP_VALID'range) is EXP_VALID;
            variable mismatch     :  boolean;
        begin
            mismatch := FALSE;
            for i in LOOP_VALID'range loop
                if (LOOP_VALID(i) /= expect_valid(i)) then
                    mismatch := TRUE;
                end if;
            end loop;
            if (mismatch) then
                assert (TRUE) report MESSAGE_TAG & "Mimatch LOOP_VALID" severity ERROR;
                mismatch_count := mismatch_count+1;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure CHECK_FIRST(CYCLE: in integer) is
            variable exp_first :  std_logic;
        begin
            if (CYCLE = 0) then
                exp_first := '1';
            else
                exp_first := '0';
            end if;
            if (LOOP_FIRST /= exp_first) then
                assert (TRUE) report MESSAGE_TAG & "Mimatch LOOP_FIRST" severity ERROR;
                mismatch_count := mismatch_count+1;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure CHECK_TERM(CYCLE,SIZE: in integer) is
            variable exp_term :  std_logic;
        begin
            if (CYCLE+(UNROLL*STRIDE) > SIZE) then
                exp_term := '1';
            else
                exp_term := '0';
            end if;
            if (LOOP_TERM /= exp_term) then
                assert (TRUE) report MESSAGE_TAG & "Mimatch LOOP_TERM" severity ERROR;
                mismatch_count := mismatch_count+1;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure CHECK_LAST(CYCLE,SIZE: in integer) is
            variable exp_last :  std_logic;
        begin
            if (CYCLE+(STRIDE*UNROLL) > SIZE-1) then
                exp_last := '1';
            else
                exp_last := '0';
            end if;
            if (LOOP_LAST /= exp_last) then
                assert (TRUE) report MESSAGE_TAG & "Mimatch LOOP_LAST" severity ERROR;
                mismatch_count := mismatch_count+1;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure CHECK_DONE(CYCLE,SIZE: in integer;T_NEXT:std_logic) is
            variable exp_done :  std_logic;
        begin
            if (SIZE > 0) then
                if (CYCLE+(STRIDE*UNROLL) = SIZE and T_NEXT = '1') then
                    exp_done := '1';
                else
                    exp_done := '0';
                end if;
            else
                if (CYCLE = 0) then
                    exp_done := '1';
                else
                    exp_done := '0';
                end if;
            end if;
            if (LOOP_DONE /= exp_done) then
                assert (TRUE) report MESSAGE_TAG & "Mimatch LOOP_DONE" severity ERROR;
                mismatch_count := mismatch_count+1;
            end if;
        end procedure;
    begin 
        ---------------------------------------------------------------------------
        -- シミュレーションの開始、まずはリセットから。
        ---------------------------------------------------------------------------
        assert(VERBOSE=FALSE) report  MESSAGE_TAG & "Starting Run..." severity NOTE;
                              clk_ena      <= '1';
                              SCENARIO     <= "START";
                              CLR          <= '1';
                              RST          <= '1';
                              LOOP_START   <= '0';
                              LOOP_NEXT    <= '0';
                              LOOP_SIZE    <=  0 ;
                              LOOP_INIT    <=  0 ;
        WAIT_CLK( 4);         RST          <= '0';
                              CLR          <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        assert(VERBOSE=FALSE) report  MESSAGE_TAG & "Test 1" severity NOTE;
        test_number := 1;
        for test_loop_size in 0 to MAX_LOOP_SIZE loop
        for test_loop_init in 0 to MAX_LOOP_INIT loop
            assert(VERBOSE=FALSE) report  MESSAGE_TAG & "Test 1."     & INTEGER_TO_STRING(test_number   ) &
                                                        " LOOP_SIZE=" & INTEGER_TO_STRING(test_loop_size) &
                                                        ",LOOP_INIT=" & INTEGER_TO_STRING(test_loop_init) severity NOTE;
            GEN_EXPECT_VALID(expect_valid, test_loop_size, test_loop_init);
            WAIT_CLK( 1);         LOOP_START <= '1';
                                  LOOP_SIZE  <= test_loop_size;
                                  LOOP_INIT  <= test_loop_init;
            WAIT_CLK( 1);         LOOP_START <= '0';
                                  LOOP_NEXT  <= '1'; test_next  := '1';
            test_cycle := 0;
            while (test_cycle < test_loop_size+4) loop
                wait until (clock'event and clock = '1');
                CHECK_VALID(expect_valid(test_cycle+LOOP_VALID'length-1 downto test_cycle));
                CHECK_FIRST(test_cycle);
                CHECK_LAST (test_cycle, test_loop_size);
                CHECK_TERM (test_cycle, test_loop_size);
                CHECK_DONE (test_cycle, test_loop_size, test_next);
                test_cycle := test_cycle + STRIDE;
            end loop;
            WAIT_CLK( 1);         LOOP_NEXT  <= '0'; test_next  := '0';
            test_number := test_number + 1;
        end loop;
        end loop;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        assert(VERBOSE=FALSE) report  MESSAGE_TAG & "Test 2" severity NOTE;
        test_number := 1;
        for test_loop_size in 0 to MAX_LOOP_SIZE loop
        for test_loop_init in 0 to MAX_LOOP_INIT loop
            assert(VERBOSE=FALSE) report  MESSAGE_TAG & "Test 2."     & INTEGER_TO_STRING(test_number   ) &
                                                        " LOOP_SIZE=" & INTEGER_TO_STRING(test_loop_size) &
                                                        ",LOOP_INIT=" & INTEGER_TO_STRING(test_loop_init) severity NOTE;
            GEN_EXPECT_VALID(expect_valid, test_loop_size, test_loop_init);
            WAIT_CLK( 1);         LOOP_START <= '1';
                                  LOOP_SIZE  <= test_loop_size;
                                  LOOP_INIT  <= test_loop_init;
            WAIT_CLK( 1);         LOOP_START <= '0';
            test_cycle := 0;
            while (test_cycle < test_loop_size+4) loop
                wait until (clock'event and clock = '1');
                CHECK_VALID(expect_valid(test_cycle+LOOP_VALID'length-1 downto test_cycle));
                CHECK_FIRST(test_cycle);
                CHECK_LAST (test_cycle, test_loop_size);
                CHECK_TERM (test_cycle, test_loop_size);
                CHECK_DONE (test_cycle, test_loop_size, test_next);
                wait for DELAY;
                LOOP_NEXT  <= '1'; test_next  := '1';
                wait until (clock'event and clock = '1');
                CHECK_VALID(expect_valid(test_cycle+LOOP_VALID'length-1 downto test_cycle));
                CHECK_FIRST(test_cycle);
                CHECK_LAST (test_cycle, test_loop_size);
                CHECK_TERM (test_cycle, test_loop_size);
                CHECK_DONE (test_cycle, test_loop_size, test_next);
                wait for DELAY;
                LOOP_NEXT  <= '0'; test_next  := '0';
                test_cycle := test_cycle + STRIDE;
            end loop;
            WAIT_CLK( 1);         LOOP_NEXT  <= '0'; test_next  := '0';
            test_number := test_number + 1;
        end loop;
        end loop;
        ---------------------------------------------------------------------------
        -- シミュレーション終了
        ---------------------------------------------------------------------------
        SCENARIO <= "DONE.";
        WAIT_CLK(10);
        if (mismatch_count > 0) then
            FINISH  <= 'Z';
            clk_ena <= '0';
            assert FALSE report MESSAGE_TAG & "Simulation complete(mismatch)."  severity FAILURE;
        end if;
        if (FINISH_ABORT) then
            FINISH  <= 'Z';
            clk_ena <= '0';
            assert FALSE report MESSAGE_TAG & "Simulation complete(success)."  severity FAILURE;
        else
            assert FALSE report MESSAGE_TAG & "Simulation complete(success)."  severity NOTE;
            FINISH  <= 'Z';
            clk_ena <= '0';
        end if;
        wait;
    end process;
end MODEL;
-----------------------------------------------------------------------------------
-- UNROLLED_LOOP_COUNTER_TEST_BENCH のエンティティ宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  UNROLLED_LOOP_COUNTER_TEST_BENCH is
    generic (
        UNROLL          : integer := 1;
        STRIDE          : integer := 1;
        MAX_LOOP_SIZE   : integer := 8;
        MAX_LOOP_INIT   : integer := 0;
        VERBOSE         : boolean := FALSE;
        FINISH_ABORT    : boolean := FALSE
    );
    port (
        FINISH          : out std_logic
    );
end     UNROLLED_LOOP_COUNTER_TEST_BENCH;
-----------------------------------------------------------------------------------
-- UNROLLED_LOOP_COUNTER_TEST_BENCH のアーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.UNROLLED_LOOP_COUNTER;
use     WORK.COMPONENTS.UNROLLED_LOOP_COUNTER_FUNCTION_MODEL;
architecture MODEL of UNROLLED_LOOP_COUNTER_TEST_BENCH is
    signal    CLK           :  std_logic; 
    signal    RST           :  std_logic;
    signal    CLR           :  std_logic;
    signal    LOOP_START    :  std_logic;
    signal    LOOP_NEXT     :  std_logic;
    signal    LOOP_SIZE     :  integer range 0 to MAX_LOOP_SIZE;
    signal    LOOP_INIT     :  integer range 0 to MAX_LOOP_INIT;
    signal    LOOP_DONE     :  std_logic;
    signal    LOOP_BUSY     :  std_logic;
    signal    LOOP_VALID    :  std_logic_vector(UNROLL-1 downto 0);
    signal    LOOP_FIRST    :  std_logic;
    signal    LOOP_LAST     :  std_logic;
    signal    LOOP_TERM     :  std_logic;
    signal    NEXT_VALID    :  std_logic_vector(UNROLL-1 downto 0);
    signal    NEXT_BUSY     :  std_logic;
    signal    NEXT_FIRST    :  std_logic;
    signal    NEXT_LAST     :  std_logic;
    signal    NEXT_TERM     :  std_logic;
begin
    DUT: UNROLLED_LOOP_COUNTER
        generic map (
            UNROLL          => UNROLL          , -- 
            STRIDE          => STRIDE          , -- 
            MAX_LOOP_SIZE   => MAX_LOOP_SIZE   , -- 
            MAX_LOOP_INIT   => MAX_LOOP_INIT     -- 
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            LOOP_START      => LOOP_START      , -- In  :
            LOOP_NEXT       => LOOP_NEXT       , -- In  :
            LOOP_SIZE       => LOOP_SIZE       , -- In  :
            LOOP_INIT       => LOOP_INIT       , -- In  :
            LOOP_DONE       => LOOP_DONE       , -- Out :
            LOOP_BUSY       => LOOP_BUSY       , -- Out :
            LOOP_VALID      => LOOP_VALID      , -- Out :
            LOOP_FIRST      => LOOP_FIRST      , -- Out :
            LOOP_LAST       => LOOP_LAST       , -- Out :
            LOOP_TERM       => LOOP_TERM       , -- Out :
            NEXT_VALID      => NEXT_VALID      , -- Out :
            NEXT_BUSY       => NEXT_BUSY       , -- Out :
            NEXT_FIRST      => NEXT_FIRST      , -- Out :
            NEXT_LAST       => NEXT_LAST       , -- Out :
            NEXT_TERM       => NEXT_TERM         -- Out :
        );
    FM: UNROLLED_LOOP_COUNTER_FUNCTION_MODEL
        generic map (
            UNROLL          => UNROLL          , -- 
            STRIDE          => STRIDE          , -- 
            MAX_LOOP_SIZE   => MAX_LOOP_SIZE   , -- 
            MAX_LOOP_INIT   => MAX_LOOP_INIT   , -- 
            VERBOSE         => VERBOSE         , --
            FINISH_ABORT    => FINISH_ABORT      --
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- Out :
            RST             => RST             , -- Out :
            CLR             => CLR             , -- Out :
            LOOP_START      => LOOP_START      , -- Out :
            LOOP_NEXT       => LOOP_NEXT       , -- Out :
            LOOP_SIZE       => LOOP_SIZE       , -- Out :
            LOOP_INIT       => LOOP_INIT       , -- Out :
            LOOP_DONE       => LOOP_DONE       , -- In  :
            LOOP_BUSY       => LOOP_BUSY       , -- In  :
            LOOP_VALID      => LOOP_VALID      , -- In  :
            LOOP_FIRST      => LOOP_FIRST      , -- In  :
            LOOP_LAST       => LOOP_LAST       , -- In  :
            LOOP_TERM       => LOOP_TERM       , -- In  :
            NEXT_VALID      => NEXT_VALID      , -- In  :
            NEXT_BUSY       => NEXT_BUSY       , -- In  :
            NEXT_FIRST      => NEXT_FIRST      , -- In  :
            NEXT_LAST       => NEXT_LAST       , -- In  :
            NEXT_TERM       => NEXT_TERM       , -- In  :
            FINISH          => FINISH            -- In  :
        );
end MODEL;
-----------------------------------------------------------------------------------
-- UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_1_1
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.UNROLLED_LOOP_COUNTER_TEST_BENCH;
entity  UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_1_1 is
    generic (VERBOSE      : boolean := TRUE ;
             FINISH_ABORT : boolean := FALSE);
    port    (FINISH       : out std_logic   );
end     UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_1_1;
architecture MODEL of UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_1_1 is
begin
    TB: UNROLLED_LOOP_COUNTER_TEST_BENCH 
        generic map (
            MAX_LOOP_SIZE => 32,
            MAX_LOOP_INIT => 0,
            STRIDE        => 1,
            UNROLL        => 1,
            VERBOSE       => VERBOSE,
            FINISH_ABORT  => FINISH_ABORT
        )
        port map (
            FINISH        => FINISH
        );
end MODEL;
-----------------------------------------------------------------------------------
-- UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_2_1
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.UNROLLED_LOOP_COUNTER_TEST_BENCH;
entity  UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_2_1 is
    generic (VERBOSE      : boolean := TRUE ;
             FINISH_ABORT : boolean := FALSE);
    port    (FINISH       : out std_logic   );
end     UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_2_1;
architecture MODEL of UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_2_1 is
begin
    TB: UNROLLED_LOOP_COUNTER_TEST_BENCH 
        generic map (
            MAX_LOOP_SIZE => 32,
            MAX_LOOP_INIT => 0,
            STRIDE        => 2,
            UNROLL        => 1,
            VERBOSE       => VERBOSE,
            FINISH_ABORT  => FINISH_ABORT
        )
        port map (
            FINISH        => FINISH
        );
end MODEL;
-----------------------------------------------------------------------------------
-- UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_1_2
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.UNROLLED_LOOP_COUNTER_TEST_BENCH;
entity  UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_1_2 is
    generic (VERBOSE      : boolean := TRUE ;
             FINISH_ABORT : boolean := FALSE);
    port    (FINISH       : out std_logic   );
end     UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_1_2;
architecture MODEL of UNROLLED_LOOP_COUNTER_TEST_BENCH_32_0_1_2 is
begin
    TB: UNROLLED_LOOP_COUNTER_TEST_BENCH 
        generic map (
            MAX_LOOP_SIZE => 32,
            MAX_LOOP_INIT => 0,
            STRIDE        => 1,
            UNROLL        => 2,
            VERBOSE       => VERBOSE,
            FINISH_ABORT  => FINISH_ABORT
        )
        port map (
            FINISH        => FINISH
        );
end MODEL;
-----------------------------------------------------------------------------------
-- UNROLLED_LOOP_COUNTER_TEST_BENCH_32_1_1_2
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.UNROLLED_LOOP_COUNTER_TEST_BENCH;
entity  UNROLLED_LOOP_COUNTER_TEST_BENCH_32_1_1_2 is
    generic (VERBOSE      : boolean := TRUE ;
             FINISH_ABORT : boolean := FALSE);
    port    (FINISH       : out std_logic   );
end     UNROLLED_LOOP_COUNTER_TEST_BENCH_32_1_1_2;
architecture MODEL of UNROLLED_LOOP_COUNTER_TEST_BENCH_32_1_1_2 is
begin
    TB: UNROLLED_LOOP_COUNTER_TEST_BENCH 
        generic map (
            MAX_LOOP_SIZE => 32,
            MAX_LOOP_INIT => 1,
            STRIDE        => 1,
            UNROLL        => 2,
            VERBOSE       => VERBOSE,
            FINISH_ABORT  => FINISH_ABORT
        )
        port map (
            FINISH        => FINISH
        );
end MODEL;
