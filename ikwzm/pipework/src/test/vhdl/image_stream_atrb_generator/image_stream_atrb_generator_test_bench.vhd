-----------------------------------------------------------------------------------
--!     @file    image_atrb_generator_test_bench.vhd
--!     @brief   IMAGE ATTRIBUTE GENERATOR TEST BENCH :
--!              IMAGE_STREAM_ATRB_GENERATOR MODULEを検証するためのテストベンチ.
--!     @version 1.8.0
--!     @date    2019/1/22
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2019 Ichiro Kawazome
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
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
package COMPONENTS is
component  IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH 
    generic (
        ATRB_SIZE       : integer := 1;
        STRIDE          : integer := 1;
        MAX_SIZE        : integer := 8;
        MAX_START_BORDER: integer := 0;
        MAX_LAST_BORDER : integer := 0;
        VERBOSE         : boolean := FALSE;
        FINISH_ABORT    : boolean := FALSE
    );
    port (
        FINISH          : out std_logic
    );
end component;
component  IMAGE_STREAM_ATRB_GENERATOR_FUNCTION_MODEL
    generic (
        ATRB_SIZE       : integer := 1;
        STRIDE          : integer := 1;
        MAX_SIZE        : integer := 8;
        MAX_START_BORDER: integer := 0;
        MAX_LAST_BORDER : integer := 0;
        VERBOSE         : boolean := FALSE;
        FINISH_ABORT    : boolean := FALSE
    );
    port (
        CLK             : out std_logic; 
        RST             : out std_logic;
        CLR             : out std_logic;
        LOAD            : out std_logic;
        CHOP            : out std_logic;
        SIZE            : out integer range 0 to MAX_SIZE;
        START_BORDER    : out integer range 0 to MAX_START_BORDER;
        LAST_BORDER     : out integer range 0 to MAX_LAST_BORDER;
        ATRB            : in  IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_SIZE-1);
        START           : in  std_logic;
        LAST            : in  std_logic;
        TERM            : in  std_logic;
        NEXT_ATRB       : in  IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_SIZE-1);
        NEXT_START      : in  std_logic;
        NEXT_LAST       : in  std_logic;
        NEXT_TERM       : in  std_logic;
        FINISH          : out std_logic
    );
end component;
end COMPONENTS;
-----------------------------------------------------------------------------------
-- IMAGE_STREAM_ATRB_GENERATOR_FUNCTION_MODEL のエンティティ宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_ATRB_GENERATOR_FUNCTION_MODEL is
    generic (
        ATRB_SIZE       : integer := 1;
        STRIDE          : integer := 1;
        MAX_SIZE        : integer := 8;
        MAX_START_BORDER: integer := 0;
        MAX_LAST_BORDER : integer := 0;
        VERBOSE         : boolean := FALSE;
        FINISH_ABORT    : boolean := FALSE
    );
    port (
        CLK             : out std_logic; 
        RST             : out std_logic;
        CLR             : out std_logic;
        LOAD            : out std_logic;
        CHOP            : out std_logic;
        SIZE            : out integer range 0 to MAX_SIZE;
        START_BORDER    : out integer range 0 to MAX_START_BORDER;
        LAST_BORDER     : out integer range 0 to MAX_LAST_BORDER;
        ATRB            : in  IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_SIZE-1);
        START           : in  std_logic;
        LAST            : in  std_logic;
        TERM            : in  std_logic;
        NEXT_ATRB       : in  IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_SIZE-1);
        NEXT_START      : in  std_logic;
        NEXT_LAST       : in  std_logic;
        NEXT_TERM       : in  std_logic;
        FINISH          : out std_logic
    );
end     IMAGE_STREAM_ATRB_GENERATOR_FUNCTION_MODEL;
-----------------------------------------------------------------------------------
-- IMAGE_STREAM_ATRB_GENERATOR_GENERATOR_FUNCTION_MODEL のアーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.UTIL.BIN_TO_STRING;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
architecture MODEL of IMAGE_STREAM_ATRB_GENERATOR_FUNCTION_MODEL is
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
        return "(ATRB_SIZE="        & INTEGER_TO_STRING(ATRB_SIZE       ) &
               ",STRIDE="           & INTEGER_TO_STRING(STRIDE          ) &
               ",MAX_SIZE="         & INTEGER_TO_STRING(MAX_SIZE        ) &
               ",MAX_START_BORDER=" & INTEGER_TO_STRING(MAX_START_BORDER) &
               ",MAX_LAST_BORDER="  & INTEGER_TO_STRING(MAX_LAST_BORDER ) &
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
        constant  EXPECT_ATRB_SIZE :  integer := MAX_SIZE+MAX_START_BORDER+MAX_LAST_BORDER+10;
        variable  expect_atrb      :  IMAGE_STREAM_ATRB_VECTOR(0 to EXPECT_ATRB_SIZE-1);
        procedure GEN_EXPECT_ATRB(
            variable  EXP_ATRB     :  inout IMAGE_STREAM_ATRB_VECTOR;
                      SIZE         :  in    integer;
                      START_BORDER :  in    integer;
                      LAST_BORDER  :  in    integer)
        is
        begin
            for pos in EXP_ATRB'range loop
                EXP_ATRB(pos).START := (pos <= START_BORDER);
                EXP_ATRB(pos).VALID := (pos >= START_BORDER and pos <= START_BORDER+SIZE-1);
                EXP_ATRB(pos).LAST  := (                        pos >= START_BORDER+SIZE-1);
            end loop;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        variable  mismatch_count :  integer;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure CHECK_ATRB(EXP_ATRB: in IMAGE_STREAM_ATRB_VECTOR) is
            alias    expect_atrb :  IMAGE_STREAM_ATRB_VECTOR(ATRB'range) is EXP_ATRB;
            variable mismatch    :  boolean;
        begin
            mismatch := FALSE;
            for i in ATRB'range loop
                if (ATRB(i) /= expect_atrb(i)) then
                    mismatch := TRUE;
                end if;
            end loop;
            if (mismatch) then
                assert (TRUE) report MESSAGE_TAG & "Mimatch ATRB" severity ERROR;
                mismatch_count := mismatch_count+1;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure CHECK_START(CYCLE: in integer) is
            variable exp_start :  std_logic;
        begin
            if (CYCLE = 0) then
                exp_start := '1';
            else
                exp_start := '0';
            end if;
            if (START /= exp_start) then
                assert (TRUE) report MESSAGE_TAG & "Mimatch START" severity ERROR;
                mismatch_count := mismatch_count+1;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure CHECK_TERM(CYCLE,SIZE,LAST_BORDER: in integer) is
            variable exp_term :  std_logic;
        begin
            if (CYCLE+STRIDE > SIZE-LAST_BORDER) then
                exp_term := '1';
            else
                exp_term := '0';
            end if;
            if (TERM /= exp_term) then
                assert (TRUE) report MESSAGE_TAG & "Mimatch TERM" severity ERROR;
                mismatch_count := mismatch_count+1;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure CHECK_LAST(CYCLE,SIZE,LAST_BORDER: in integer) is
            variable exp_last :  std_logic;
        begin
            if (CYCLE+STRIDE > SIZE-LAST_BORDER-1) then
                exp_last := '1';
            else
                exp_last := '0';
            end if;
            if (LAST /= exp_last) then
                assert (TRUE) report MESSAGE_TAG & "Mimatch LAST" severity ERROR;
                mismatch_count := mismatch_count+1;
            end if;
        end procedure;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        variable  test_number      :  integer;
        variable  test_cycle       :  integer;
        variable  test_last        :  std_logic;
    begin 
        ---------------------------------------------------------------------------
        -- シミュレーションの開始、まずはリセットから。
        ---------------------------------------------------------------------------
        assert(VERBOSE=FALSE) report  MESSAGE_TAG & "Starting Run..." severity NOTE;
                              clk_ena      <= '1';
                              SCENARIO     <= "START";
                              CLR          <= '1';
                              RST          <= '1';
                              CHOP         <= '0';
                              LOAD         <= '0';
                              SIZE         <=  0 ;
                              START_BORDER <=  0 ;
                              LAST_BORDER  <=  0 ;
        WAIT_CLK( 4);         RST          <= '0';
                              CLR          <= '0';
        WAIT_CLK( 4);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        assert(VERBOSE=FALSE) report  MESSAGE_TAG & "Test 1" severity NOTE;
        test_number := 1;
        for test_size         in 1 to MAX_SIZE loop
        for test_start_border in 0 to MAX_START_BORDER loop
        for test_last_border  in 0 to MAX_LAST_BORDER  loop
            assert(VERBOSE=FALSE) report  MESSAGE_TAG & "Test 1."        & INTEGER_TO_STRING(test_number       ) &
                                                        " SIZE="         & INTEGER_TO_STRING(test_size         ) &
                                                        ",START_BORDER=" & INTEGER_TO_STRING(test_start_border ) &
                                                        ",LAST_BORDER="  & INTEGER_TO_STRING(test_last_border  ) severity NOTE;
            GEN_EXPECT_ATRB(expect_atrb, test_size, test_start_border, test_last_border);
            WAIT_CLK( 1);         LOAD         <= '1';
                                  SIZE         <= test_size;
                                  START_BORDER <= test_start_border;
                                  LAST_BORDER  <= test_last_border;
            WAIT_CLK( 1);         LOAD         <= '0';
                                  CHOP         <= '1';
            test_cycle := 0;
            while (test_cycle < test_size+4) loop
                wait until (clock'event and clock = '1');
                CHECK_ATRB (expect_atrb(test_cycle to test_cycle+ATRB'length-1));
                CHECK_START(test_cycle);
                CHECK_LAST (test_cycle, test_size, test_last_border);
                CHECK_TERM (test_cycle, test_size, test_last_border);
                test_cycle := test_cycle + STRIDE;
            end loop;
            WAIT_CLK( 1);         CHOP         <= '0';
            test_number := test_number + 1;
        end loop;
        end loop;
        end loop;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        assert(VERBOSE=FALSE) report  MESSAGE_TAG & "Test 2" severity NOTE;
        test_number := 1;
        for test_size         in 1 to MAX_SIZE loop
        for test_start_border in 0 to MAX_START_BORDER loop
        for test_last_border  in 0 to MAX_LAST_BORDER  loop
            assert(VERBOSE=FALSE) report  MESSAGE_TAG & "Test 2."        & INTEGER_TO_STRING(test_number       ) &
                                                        " SIZE="         & INTEGER_TO_STRING(test_size         ) &
                                                        ",START_BORDER=" & INTEGER_TO_STRING(test_start_border ) &
                                                        ",LAST_BORDER="  & INTEGER_TO_STRING(test_last_border  ) severity NOTE;
            GEN_EXPECT_ATRB(expect_atrb, test_size, test_start_border, test_last_border);
            WAIT_CLK( 1);         LOAD         <= '1';
                                  SIZE         <= test_size;
                                  START_BORDER <= test_start_border;
                                  LAST_BORDER  <= test_last_border;
            WAIT_CLK( 1);         LOAD         <= '0';
                                  CHOP         <= '0';
            test_cycle := 0;
            while (test_cycle < test_size+4) loop
                wait until (clock'event and clock = '1');
                CHECK_ATRB (expect_atrb(test_cycle to test_cycle+ATRB'length-1));
                CHECK_START(test_cycle);
                CHECK_LAST (test_cycle, test_size, test_last_border);
                CHECK_TERM (test_cycle, test_size, test_last_border);
                CHOP <= '1' after DELAY;
                wait until (clock'event and clock = '1');
                test_cycle := test_cycle + STRIDE;
                CHECK_ATRB (expect_atrb(test_cycle to test_cycle+ATRB'length-1));
                CHECK_START(test_cycle);
                CHECK_LAST (test_cycle, test_size, test_last_border);
                CHECK_TERM (test_cycle, test_size, test_last_border);
                CHOP <= '0' after DELAY;
            end loop;
            WAIT_CLK( 1);         CHOP         <= '0';
            test_number := test_number + 1;
        end loop;
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
-- IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH のエンティティ宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH is
    generic (
        ATRB_SIZE       : integer := 1;
        STRIDE          : integer := 1;
        MAX_SIZE        : integer := 8;
        MAX_START_BORDER: integer := 0;
        MAX_LAST_BORDER : integer := 0;
        VERBOSE         : boolean := FALSE;
        FINISH_ABORT    : boolean := FALSE
    );
    port (
        FINISH          : out std_logic
    );
end     IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH;
-----------------------------------------------------------------------------------
-- IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH のアーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_STREAM_ATRB_GENERATOR;
use     WORK.COMPONENTS.IMAGE_STREAM_ATRB_GENERATOR_FUNCTION_MODEL;
architecture MODEL of IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH is
    signal    CLK           :  std_logic; 
    signal    RST           :  std_logic;
    signal    CLR           :  std_logic;
    signal    LOAD          :  std_logic;
    signal    CHOP          :  std_logic;
    signal    SIZE          :  integer range 0 to MAX_SIZE;
    signal    START_BORDER  :  integer range 0 to MAX_START_BORDER;
    signal    LAST_BORDER   :  integer range 0 to MAX_LAST_BORDER;
    signal    ATRB          :  IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_SIZE-1);
    signal    START         :  std_logic;
    signal    LAST          :  std_logic;
    signal    TERM          :  std_logic;
    signal    NEXT_ATRB     :  IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_SIZE-1);
    signal    NEXT_START    :  std_logic;
    signal    NEXT_LAST     :  std_logic;
    signal    NEXT_TERM     :  std_logic;
begin
    DUT: IMAGE_STREAM_ATRB_GENERATOR
        generic map (
            ATRB_SIZE       => ATRB_SIZE       , -- 
            STRIDE          => STRIDE          , -- 
            MAX_SIZE        => MAX_SIZE        , -- 
            MAX_START_BORDER=> MAX_START_BORDER, -- 
            MAX_LAST_BORDER => MAX_LAST_BORDER   -- 
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
            LOAD            => LOAD            , -- In  :
            CHOP            => CHOP            , -- In  :
            SIZE            => SIZE            , -- In  :
            START_BORDER    => START_BORDER    , -- In  :
            LAST_BORDER     => LAST_BORDER     , -- In  :
            ATRB            => ATRB            , -- Out :
            START           => START           , -- Out :
            LAST            => LAST            , -- Out :
            TERM            => TERM            , -- Out :
            NEXT_ATRB       => NEXT_ATRB       , -- Out :
            NEXT_START      => NEXT_START      , -- Out :
            NEXT_LAST       => NEXT_LAST       , -- Out :
            NEXT_TERM       => NEXT_TERM         -- Out :
        );
    FM: IMAGE_STREAM_ATRB_GENERATOR_FUNCTION_MODEL
        generic map (
            ATRB_SIZE       => ATRB_SIZE       , --
            STRIDE          => STRIDE          , --
            MAX_SIZE        => MAX_SIZE        , --
            MAX_START_BORDER=> MAX_START_BORDER, --
            MAX_LAST_BORDER => MAX_LAST_BORDER , --
            VERBOSE         => VERBOSE         , --
            FINISH_ABORT    => FINISH_ABORT      --
        )                                        -- 
        port map (                               -- 
            CLK             => CLK             , -- Out :
            RST             => RST             , -- Out :
            CLR             => CLR             , -- Out :
            LOAD            => LOAD            , -- Out :
            CHOP            => CHOP            , -- Out :
            SIZE            => SIZE            , -- Out :
            START_BORDER    => START_BORDER    , -- Out :
            LAST_BORDER     => LAST_BORDER     , -- Out :
            ATRB            => ATRB            , -- In  :
            START           => START           , -- In  :
            LAST            => LAST            , -- In  :
            TERM            => TERM            , -- In  :
            NEXT_ATRB       => NEXT_ATRB       , -- In  :
            NEXT_START      => NEXT_START      , -- In  :
            NEXT_LAST       => NEXT_LAST       , -- In  :
            NEXT_TERM       => NEXT_TERM       , -- In  :
            FINISH          => FINISH            -- Out :
        );
end MODEL;
-----------------------------------------------------------------------------------
-- IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_1_1_32_0_0
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH;
entity  IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_1_1_32_0_0 is
    generic (VERBOSE      : boolean := FALSE ;
             FINISH_ABORT : boolean := FALSE);
    port    (FINISH       : out std_logic   );
end     IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_1_1_32_0_0;
architecture MODEL of IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_1_1_32_0_0 is
begin
    TB: IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH 
        generic map (
            ATRB_SIZE       => 1,
            STRIDE          => 1,
            MAX_SIZE        => 32,
            MAX_START_BORDER=> 0,
            MAX_LAST_BORDER => 0,
            VERBOSE         => VERBOSE,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map (
            FINISH          => FINISH
        );
end MODEL;
-----------------------------------------------------------------------------------
-- IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_3_1_32_0_0
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH;
entity  IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_3_1_32_0_0 is
    generic (VERBOSE      : boolean := FALSE ;
             FINISH_ABORT : boolean := FALSE);
    port    (FINISH       : out std_logic   );
end     IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_3_1_32_0_0;
architecture MODEL of IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_3_1_32_0_0 is
begin
    TB: IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH 
        generic map (
            ATRB_SIZE       => 3,
            STRIDE          => 1,
            MAX_SIZE        => 32,
            MAX_START_BORDER=> 0,
            MAX_LAST_BORDER => 0,
            VERBOSE         => VERBOSE,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map (
            FINISH          => FINISH
        );
end MODEL;
-----------------------------------------------------------------------------------
-- IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_3_1_32_1_1
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH;
entity  IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_3_1_32_1_1 is
    generic (VERBOSE      : boolean := FALSE ;
             FINISH_ABORT : boolean := FALSE);
    port    (FINISH       : out std_logic   );
end     IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_3_1_32_1_1;
architecture MODEL of IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_3_1_32_1_1 is
begin
    TB: IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH 
        generic map (
            ATRB_SIZE       => 3,
            STRIDE          => 1,
            MAX_SIZE        => 32,
            MAX_START_BORDER=> 1,
            MAX_LAST_BORDER => 1,
            VERBOSE         => VERBOSE,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map (
            FINISH          => FINISH
        );
end MODEL;
-----------------------------------------------------------------------------------
-- IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_4_4_32_0_0
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH;
entity  IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_4_4_32_0_0 is
    generic (VERBOSE      : boolean := FALSE ;
             FINISH_ABORT : boolean := FALSE);
    port    (FINISH       : out std_logic   );
end     IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_4_4_32_0_0;
architecture MODEL of IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH_4_4_32_0_0 is
begin
    TB: IMAGE_STREAM_ATRB_GENERATOR_TEST_BENCH 
        generic map (
            ATRB_SIZE       => 4,
            STRIDE          => 4,
            MAX_SIZE        => 32,
            MAX_START_BORDER=> 0,
            MAX_LAST_BORDER => 0,
            VERBOSE         => VERBOSE,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map (
            FINISH          => FINISH
        );
end MODEL;
