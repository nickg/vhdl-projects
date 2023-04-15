-----------------------------------------------------------------------------------
--!     @file    bitonic_sorter_test_bench.vhd
--!     @brief   Bitonic Sorter Test Bench :
--!     @version 1.4.1
--!     @date    2022/11/1
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2020-2022 Ichiro Kawazome
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
entity  Bitonic_Sorter_Test_Bench is
    generic (
        NAME            :  STRING  := "TEST";
        SCENARIO_FILE   :  STRING  := "test.snr";
        WORDS           :  integer :=  4;
        SORT_ORDER      :  integer :=  0;
        COMP_SIGN       :  boolean := FALSE;
        QUEUE_SIZE      :  integer :=  2;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library Merge_Sorter;
use     Merge_Sorter.Word;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_SLAVE_PLAYER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
architecture Model of Bitonic_Sorter_Test_Bench is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant   PERIOD       :  time    := 10 ns;
    constant   DELAY        :  time    :=  1 ns;
    constant   DATA_BITS    :  integer :=  8;
    constant   DATA_COMP_LO :  integer :=  0;
    constant   DATA_COMP_HI :  integer :=  7;
    constant   ATRB_BITS    :  integer :=  4;
    constant   SYNC_WIDTH   :  integer :=  2;
    constant   GPO_WIDTH    :  integer :=  8;
    constant   GPI_WIDTH    :  integer := GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal     CLOCK        :  std_logic;
    signal     ARESETn      :  std_logic;
    signal     RESET        :  std_logic;
    constant   CLEAR        :  std_logic := '0';
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal     SYNC         : SYNC_SIG_VECTOR (SYNC_WIDTH     -1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant   I_WIDTH      :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                   ID    => 4,
                                   USER  => WORDS*ATRB_BITS,
                                   DEST  => 4,
                                   DATA  => WORDS*DATA_BITS
                               );
    signal     i_data       :  std_logic_vector(I_WIDTH.DATA  -1 downto 0);
    signal     i_user       :  std_logic_vector(I_WIDTH.USER  -1 downto 0);
    signal     i_last       :  std_logic;
    signal     i_valid      :  std_logic;
    signal     i_ready      :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant   O_WIDTH      :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                   ID    => 4,
                                   USER  => WORDS*ATRB_BITS,
                                   DEST  => 4,
                                   DATA  => WORDS*DATA_BITS
                               );
    signal     o_data       :  std_logic_vector(O_WIDTH.DATA  -1 downto 0);
    signal     o_user       :  std_logic_vector(O_WIDTH.USER  -1 downto 0);
    signal     o_last       :  std_logic;
    signal     o_valid      :  std_logic;
    signal     o_ready      :  std_logic;
    constant   o_keep       :  std_logic_vector(O_WIDTH.DATA/8-1 downto 0) := (others => '1');
    constant   o_strb       :  std_logic_vector(O_WIDTH.DATA/8-1 downto 0) := (others => '1');
    constant   o_id         :  std_logic_vector(O_WIDTH.ID    -1 downto 0) := (others => '0');
    constant   o_dest       :  std_logic_vector(O_WIDTH.DEST  -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal     I_GPI        : std_logic_vector(GPI_WIDTH   -1 downto 0);
    signal     I_GPO        : std_logic_vector(GPO_WIDTH   -1 downto 0);
    signal     O_GPI        : std_logic_vector(GPI_WIDTH   -1 downto 0);
    signal     O_GPO        : std_logic_vector(GPO_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal     N_REPORT     : REPORT_STATUS_TYPE;
    signal     N_FINISH     : std_logic;
    signal     O_REPORT     : REPORT_STATUS_TYPE;
    signal     O_FINISH     : std_logic;
    signal     I_REPORT     : REPORT_STATUS_TYPE;
    signal     I_FINISH     : std_logic;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL                                   -- 
        generic map(                             -- 
            SCENARIO_FILE   => SCENARIO_FILE,    -- 
            NAME            => "MARCHAL",        -- 
            SYNC_PLUG_NUM   => 1,                -- 
            SYNC_WIDTH      => SYNC_WIDTH,       -- 
            FINISH_ABORT    => FALSE             -- 
        )                                        -- 
        port map(                                -- 
            CLK             => CLOCK           , -- In  :
            RESET           => RESET           , -- Out :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );                                       -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O: AXI4_STREAM_SLAVE_PLAYER                  -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --
            NAME            => "O"             , --
            OUTPUT_DELAY    => DELAY           , --
            SYNC_PLUG_NUM   => 2               , --
            WIDTH           => O_WIDTH         , --
            SYNC_WIDTH      => SYNC_WIDTH      , --
            GPI_WIDTH       => GPI_WIDTH       , --
            GPO_WIDTH       => GPO_WIDTH       , --
            FINISH_ABORT    => FALSE             --
        )                                        -- 
        port map(                                -- 
            ACLK            => CLOCK           , -- In  :
            ARESETn         => ARESETn         , -- In  :
            TDATA           => o_data          , -- In  :
            TSTRB           => o_strb          , -- In  :
            TKEEP           => o_keep          , -- In  :
            TUSER           => o_user          , -- In  :
            TDEST           => o_dest          , -- In  :
            TID             => o_id            , -- In  :
            TLAST           => o_last          , -- In  :
            TVALID          => o_valid         , -- In  :
            TREADY          => o_ready         , -- Out :
            SYNC            => SYNC            , -- I/O :
            GPI             => O_GPI           , -- In  :
            GPO             => O_GPO           , -- Out :
            REPORT_STATUS   => O_REPORT        , -- Out :
            FINISH          => O_FINISH          -- Out :
        );                                       --
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I: AXI4_STREAM_MASTER_PLAYER                     -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --
            NAME            => "I"             , --
            OUTPUT_DELAY    => DELAY           , --
            SYNC_PLUG_NUM   => 3               , --
            WIDTH           => I_WIDTH         , --
            SYNC_WIDTH      => SYNC_WIDTH      , --
            GPI_WIDTH       => GPI_WIDTH       , --
            GPO_WIDTH       => GPO_WIDTH       , --
            FINISH_ABORT    => FALSE             --
        )                                        -- 
        port map (                               -- 
            ACLK            => CLOCK           , -- In  :
            ARESETn         => ARESETn         , -- In  :
            TDATA           => i_data          , -- Out :
            TSTRB           => open            , -- Out :
            TKEEP           => open            , -- Out :
            TUSER           => i_user          , -- Out :
            TDEST           => open            , -- Out :
            TID             => open            , -- Out :
            TLAST           => i_last          , -- Out :
            TVALID          => i_valid         , -- Out :
            TREADY          => i_ready         , -- In  :
            SYNC            => SYNC            , -- I/O :
            GPI             => I_GPI           , -- In  :
            GPO             => open            , -- Out :
            REPORT_STATUS   => I_REPORT        , -- Out :
            FINISH          => I_FINISH          -- Out :
        );                                       --
    I_GPI <= O_GPO;
    O_GPI <= I_GPO;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DUT: entity Merge_Sorter.Bitonic_Sorter      -- 
        generic map (                            -- 
            WORDS       => WORDS               , --
            DATA_BITS   => DATA_BITS           , --
            COMP_HIGH   => DATA_COMP_HI        , --
            COMP_LOW    => DATA_COMP_LO        , --
            COMP_SIGN   => COMP_SIGN           , --
            SORT_ORDER  => SORT_ORDER          , --
            ATRB_BITS   => ATRB_BITS           , --
            INFO_BITS   => 1                   , --
            QUEUE_SIZE  => QUEUE_SIZE            --
        )                                        -- 
        port map (                               -- 
            CLK         => CLOCK               , -- In  :
            RST         => RESET               , -- In  :
            CLR         => CLEAR               , -- In  :
            I_DATA      => i_data              , -- In  :
            I_ATRB      => i_user              , -- In  :
            I_INFO(0)   => i_last              , -- In  :
            I_VALID     => i_valid             , -- In  :
            I_READY     => i_ready             , -- Out :
            O_DATA      => o_data              , -- Out :
            O_ATRB      => o_user              , -- Out :
            O_INFO(0)   => o_last              , -- Out :
            O_VALID     => o_valid             , -- Out :
            O_READY     => o_ready               -- In  :
        );                                       -- 
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process begin
        loop
            CLOCK  <= '0'; wait for PERIOD / 2;
            CLOCK  <= '1'; wait for PERIOD / 2;
            exit when(N_FINISH = '1');
        end loop;
        CLOCK  <= '0';
        wait;
    end process;

    ARESETn <= '1' when (RESET = '0') else '0';
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        wait until (N_FINISH'event and N_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,O_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,O_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,O_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert (O_REPORT.error_count    = 0)
            report "Simulation complete(error)."    severity FAILURE;
        assert (O_REPORT.mismatch_count = 0)
            report "Simulation complete(mismatch)." severity FAILURE;
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete(success)."  severity FAILURE;
        else
            assert FALSE report "Simulation complete(success)."  severity NOTE;
        end if;
        wait;
    end process;
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O0_S0_Q0 is
    generic (
        NAME            :  STRING  := "TEST_X08_O0_S0";
        SCENARIO_FILE   :  STRING  := "test_x08_o0_s0.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 0;
        COMP_SIGN       :  boolean := FALSE;
        QUEUE_SIZE      :  integer := 0;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O0_S0_Q0;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O0_S0_Q0 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O0_S0_Q1 is
    generic (
        NAME            :  STRING  := "TEST_X08_O0_S0";
        SCENARIO_FILE   :  STRING  := "test_x08_o0_s0.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 0;
        COMP_SIGN       :  boolean := FALSE;
        QUEUE_SIZE      :  integer := 1;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O0_S0_Q1;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O0_S0_Q1 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O0_S0_Q2 is
    generic (
        NAME            :  STRING  := "TEST_X08_O0_S0";
        SCENARIO_FILE   :  STRING  := "test_x08_o0_s0.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 0;
        COMP_SIGN       :  boolean := FALSE;
        QUEUE_SIZE      :  integer := 2;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O0_S0_Q2;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O0_S0_Q2 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O0_S1_Q0 is
    generic (
        NAME            :  STRING  := "TEST_X08_O0_S1";
        SCENARIO_FILE   :  STRING  := "test_x08_o0_s1.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 0;
        COMP_SIGN       :  boolean := TRUE;
        QUEUE_SIZE      :  integer := 0;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O0_S1_Q0;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O0_S1_Q0 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O0_S1_Q1 is
    generic (
        NAME            :  STRING  := "TEST_X08_O0_S1";
        SCENARIO_FILE   :  STRING  := "test_x08_o0_s1.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 0;
        COMP_SIGN       :  boolean := TRUE;
        QUEUE_SIZE      :  integer := 1;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O0_S1_Q1;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O0_S1_Q1 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O0_S1_Q2 is
    generic (
        NAME            :  STRING  := "TEST_X08_O0_S1";
        SCENARIO_FILE   :  STRING  := "test_x08_o0_s1.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 0;
        COMP_SIGN       :  boolean := TRUE;
        QUEUE_SIZE      :  integer := 2;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O0_S1_Q2;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O0_S1_Q2 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O1_S0_Q0 is
    generic (
        NAME            :  STRING  := "TEST_X08_O1_S0";
        SCENARIO_FILE   :  STRING  := "test_x08_o1_s0.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 1;
        COMP_SIGN       :  boolean := FALSE;
        QUEUE_SIZE      :  integer := 0;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O1_S0_Q0;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O1_S0_Q0 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O1_S0_Q1 is
    generic (
        NAME            :  STRING  := "TEST_X08_O1_S0";
        SCENARIO_FILE   :  STRING  := "test_x08_o1_s0.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 1;
        COMP_SIGN       :  boolean := FALSE;
        QUEUE_SIZE      :  integer := 1;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O1_S0_Q1;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O1_S0_Q1 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O1_S0_Q2 is
    generic (
        NAME            :  STRING  := "TEST_X08_O1_S0";
        SCENARIO_FILE   :  STRING  := "test_x08_o1_s0.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 1;
        COMP_SIGN       :  boolean := FALSE;
        QUEUE_SIZE      :  integer := 2;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O1_S0_Q2;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O1_S0_Q2 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O1_S1_Q0 is
    generic (
        NAME            :  STRING  := "TEST_X08_O1_S1";
        SCENARIO_FILE   :  STRING  := "test_x08_o1_s1.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 1;
        COMP_SIGN       :  boolean := TRUE;
        QUEUE_SIZE      :  integer := 0;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O1_S1_Q0;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O1_S1_Q0 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O1_S1_Q1 is
    generic (
        NAME            :  STRING  := "TEST_X08_O1_S1";
        SCENARIO_FILE   :  STRING  := "test_x08_o1_s1.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 1;
        COMP_SIGN       :  boolean := TRUE;
        QUEUE_SIZE      :  integer := 1;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O1_S1_Q1;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O1_S1_Q1 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Bitonic_Sorter_Test_Bench_X08_O1_S1_Q2 is
    generic (
        NAME            :  STRING  := "TEST_X08_O1_S1";
        SCENARIO_FILE   :  STRING  := "test_x08_o1_s1.snr";
        WORDS           :  integer := 8;
        SORT_ORDER      :  integer := 1;
        COMP_SIGN       :  boolean := TRUE;
        QUEUE_SIZE      :  integer := 2;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Bitonic_Sorter_Test_Bench_X08_O1_S1_Q2;
architecture Model of Bitonic_Sorter_Test_Bench_X08_O1_S1_Q2 is
begin
    TEST: entity  WORK.Bitonic_Sorter_Test_Bench
        generic map (
            NAME            => NAME,
            SCENARIO_FILE   => SCENARIO_FILE,
            WORDS           => WORDS,
            SORT_ORDER      => SORT_ORDER,
            COMP_SIGN       => COMP_SIGN,
            QUEUE_SIZE      => QUEUE_SIZE,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
