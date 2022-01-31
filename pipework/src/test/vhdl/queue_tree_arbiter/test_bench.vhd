-----------------------------------------------------------------------------------
--!     @file    test_bench.vhd
--!     @brief   Test Bench for QUEUE_TREE_ARBITER
--!     @version 1.8.3
--!     @date    2020/10/13
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2020 Ichiro Kawazome
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
entity  TEST_BENCH is
    generic (
        NAME            :  STRING  := "test";
        SCENARIO_FILE   :  STRING  := "test.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 3;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 0;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.QUEUE_TREE_ARBITER;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_SLAVE_PLAYER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
architecture MODEL of TEST_BENCH is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant  PERIOD            :  time    :=  10 ns;
    constant  DELAY             :  time    :=   1 ns;
    constant  SYNC_WIDTH        :  integer :=  2;
    constant  GPO_WIDTH         :  integer :=  2;
    constant  GPI_WIDTH         :  integer :=  MAX_NUM-MIN_NUM+1;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal    ARESETn           :  std_logic;
    signal    RESET             :  std_logic;
    constant  CLEAR             :  std_logic := '0';
    signal    CLK               :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    REQ_VALID         :  std_logic_vector(MAX_NUM downto MIN_NUM);
    signal    REQ_READY         :  std_logic_vector(MAX_NUM downto MIN_NUM);
    signal    GRANT             :  std_logic_vector(MAX_NUM downto MIN_NUM);
    signal    SHIFT             :  std_logic;
    signal    ENABLE            :  std_logic;
    signal    REQ_GPO           :  std_logic_vector(MAX_NUM downto MIN_NUM);
    signal    REQ_GPI           :  std_logic_vector(0 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  OUT_WIDTH         :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                      ID         => 4,
                                      USER       => 4,
                                      DEST       => 4,
                                      DATA       => ((((MAX_NUM-MIN_NUM+1)+7)/8)*8)
                                   );
    signal    OUT_DATA          :  std_logic_vector(OUT_WIDTH.DATA   -1 downto 0);
    constant  OUT_STRB          :  std_logic_vector(OUT_WIDTH.DATA/8 -1 downto 0) := (others => '1');
    constant  OUT_KEEP          :  std_logic_vector(OUT_WIDTH.DATA/8 -1 downto 0) := (others => '1');
    constant  OUT_DEST          :  std_logic_vector(OUT_WIDTH.DEST   -1 downto 0) := (others => '0');
    constant  OUT_USER          :  std_logic_vector(OUT_WIDTH.USER   -1 downto 0) := (others => '0');
    constant  OUT_ID            :  std_logic_vector(OUT_WIDTH.ID     -1 downto 0) := (others => '0');
    constant  OUT_LAST          :  std_logic := '0';
    signal    OUT_VALID         :  std_logic;
    signal    OUT_READY         :  std_logic;
    signal    OUT_GPI           :  std_logic_vector(GPI_WIDTH-1 downto 0);
    signal    OUT_GPO           :  std_logic_vector(GPO_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal    SYNC              :  SYNC_SIG_VECTOR(SYNC_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal    N_REPORT          :  REPORT_STATUS_TYPE;
    signal    REQ_REPORT        :  REPORT_STATUS_VECTOR(MAX_NUM downto MIN_NUM);
    signal    O_REPORT          :  REPORT_STATUS_TYPE;
    signal    N_FINISH          :  std_logic;
    signal    REQ_FINISH        :  std_logic_vector    (MAX_NUM downto MIN_NUM);
    signal    O_FINISH          :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    DUT: QUEUE_TREE_ARBITER              -- 
        generic map (                    -- 
            MIN_NUM     => MIN_NUM     , --
            MAX_NUM     => MAX_NUM     , --
            NODE_NUM    => NODE_NUM    , --
            PIPELINE    => PIPELINE      --
        )                                -- 
        port map (                       -- 
            CLK         => CLK         , -- In  :
            RST         => RESET       , -- In  :
            CLR         => CLEAR       , -- In  :
            ENABLE      => ENABLE      , -- In  :
            REQUEST     => REQ_VALID   , -- In  :
            GRANT       => GRANT       , -- Out :
            VALID       => OUT_VALID   , -- Out :
            SHIFT       => OUT_READY     -- In  :
        );
    ENABLE <= OUT_GPO(0);
    SHIFT  <= '1' when (OUT_VALID = '1' and OUT_READY = '1') else '0';
    process (SHIFT, GRANT) begin
        for i in REQ_READY'range loop
            if (GRANT(i) = '1' and SHIFT = '1') then
                REQ_READY(i) <= '1';
            else
                REQ_READY(i) <= '0';
            end if;
        end loop;
    end process;
    OUT_DATA <= std_logic_vector(resize(to_01(unsigned(GRANT)),OUT_DATA'length));
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL                                   -- 
        generic map(                             -- 
            SCENARIO_FILE   => SCENARIO_FILE   , -- 
            NAME            => "MARCHAL"       , -- 
            SYNC_PLUG_NUM   => 1               , -- 
            SYNC_WIDTH      => SYNC_WIDTH      , -- 
            FINISH_ABORT    => FALSE             -- 
        )                                        -- 
        port map(                                -- 
            CLK             => CLK             , -- In  :
            RESET           => RESET           , -- In  :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    O: AXI4_STREAM_SLAVE_PLAYER                  -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --
            NAME            => "OUT"           , --
            OUTPUT_DELAY    => DELAY           , --
            SYNC_PLUG_NUM   => 2               , --
            WIDTH           => OUT_WIDTH       , --
            SYNC_WIDTH      => SYNC_WIDTH      , --
            GPI_WIDTH       => GPI_WIDTH       , --
            GPO_WIDTH       => GPO_WIDTH       , --
            FINISH_ABORT    => FALSE             --
        )                                        -- 
        port map(                                -- 
            ACLK            => CLK             , -- In  :
            ARESETn         => ARESETn         , -- In  :
            TDATA           => OUT_DATA        , -- In  :
            TSTRB           => OUT_STRB        , -- In  :
            TKEEP           => OUT_KEEP        , -- In  :
            TUSER           => OUT_USER        , -- In  :
            TDEST           => OUT_DEST        , -- In  :
            TID             => OUT_ID          , -- In  :
            TLAST           => OUT_LAST        , -- In  :
            TVALID          => OUT_VALID       , -- In  :
            TREADY          => OUT_READY       , -- Out :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            GPI             => OUT_GPI         , -- In  :
            GPO             => OUT_GPO         , -- Out :
            REPORT_STATUS   => O_REPORT        , -- Out :
            FINISH          => O_FINISH          -- Out :
        );                                       --
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    REQ: for i in MIN_NUM to MAX_NUM generate
        constant  NAME      :  STRING := string'("REQ") & INTEGER_TO_STRING(i);
        constant  I_WIDTH   :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                  ID         => 4,
                                  USER       => 4,
                                  DEST       => 4,
                                  DATA       => 8
                               );
    begin
        PLAYER: AXI4_STREAM_MASTER_PLAYER            -- 
            generic map (                            -- 
                SCENARIO_FILE   => SCENARIO_FILE   , --
                NAME            => NAME            , --
                OUTPUT_DELAY    => DELAY           , --
                SYNC_PLUG_NUM   => 3+(i-MIN_NUM)   , --
                WIDTH           => I_WIDTH         , --
                SYNC_WIDTH      => SYNC_WIDTH      , --
                GPI_WIDTH       => 1               , --
                GPO_WIDTH       => 1               , --
                FINISH_ABORT    => FALSE             --
            )                                        -- 
            port map(                                -- 
                ACLK            => CLK             , -- In  :
                ARESETn         => ARESETn         , -- In  :
                TDATA           => open            , -- I/O :
                TSTRB           => open            , -- I/O :
                TKEEP           => open            , -- I/O :
                TUSER           => open            , -- I/O :
                TDEST           => open            , -- I/O :
                TID             => open            , -- I/O :
                TLAST           => open            , -- I/O :
                TVALID          => REQ_VALID(i)    , -- I/O :
                TREADY          => REQ_READY(i)    , -- In  :
                SYNC            => SYNC            , -- I/O :
                GPI(0)          => OUT_GPO(1)      , -- In  :
                GPO(0)          => OUT_GPI(i)      , -- Out :
                REPORT_STATUS   => REQ_REPORT(i)   , -- Out :
                FINISH          => REQ_FINISH(i)     -- Out :
            );                                       --
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process begin
        while (TRUE) loop
            CLK <= '1';
            wait for PERIOD / 2;
            CLK <= '0';
            wait for PERIOD / 2;
            exit when (N_FINISH = '1');
        end loop;
        CLK <= '0';
        wait;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    ARESETn <= '1' when (RESET = '0') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process
        variable L        : LINE;
        constant T        : STRING(1 to 7) := "  ***  ";
        variable i_report : REPORT_STATUS_TYPE;
    begin
        wait until (N_FINISH'event and N_FINISH = '1');
        wait for DELAY;
        i_report := MARGE_REPORT_STATUS(REQ_REPORT);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ REQ SIDE ]");                                  WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,i_report.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,i_report.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,i_report.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ OUT SIDE ]");                                  WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,O_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,O_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,O_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert (N_REPORT.error_count    = 0 and
                i_report.error_count    = 0 and
                O_REPORT.error_count    = 0)
            report "Simulation complete(error)." severity FAILURE;
        assert (N_REPORT.mismatch_count = 0 and
                i_report.mismatch_count = 0 and
                O_REPORT.mismatch_count = 0)
            report "Simulation complete(mismatch)." severity FAILURE;
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete(success)."  severity FAILURE;
        else
            assert FALSE report "Simulation complete(success)."  severity NOTE;
        end if;
        wait;
    end process;
end MODEL;
library ieee;
use     ieee.std_logic_1164.all;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_08_4_0 is
    generic (
        NAME            :  STRING  := "test_08_4_0";
        SCENARIO_FILE   :  STRING  := "test_08_4_0.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 7;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 0;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_08_4_0;
architecture MODEL of TEST_BENCH_08_4_0 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_04_4_3 is
    generic (
        NAME            :  STRING  := "test_04_4_3";
        SCENARIO_FILE   :  STRING  := "test_04_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 3;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_04_4_3;
architecture MODEL of TEST_BENCH_04_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_05_4_3 is
    generic (
        NAME            :  STRING  := "test_05_4_3";
        SCENARIO_FILE   :  STRING  := "test_05_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 4;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_05_4_3;
architecture MODEL of TEST_BENCH_05_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_06_4_3 is
    generic (
        NAME            :  STRING  := "test_06_4_3";
        SCENARIO_FILE   :  STRING  := "test_06_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 5;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_06_4_3;
architecture MODEL of TEST_BENCH_06_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_07_4_3 is
    generic (
        NAME            :  STRING  := "test_07_4_3";
        SCENARIO_FILE   :  STRING  := "test_07_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 6;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_07_4_3;
architecture MODEL of TEST_BENCH_07_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_08_4_3 is
    generic (
        NAME            :  STRING  := "test_08_4_3";
        SCENARIO_FILE   :  STRING  := "test_08_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 7;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_08_4_3;
architecture MODEL of TEST_BENCH_08_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_09_4_3 is
    generic (
        NAME            :  STRING  := "test_09_4_3";
        SCENARIO_FILE   :  STRING  := "test_09_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 8;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_09_4_3;
architecture MODEL of TEST_BENCH_09_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_10_4_0 is
    generic (
        NAME            :  STRING  := "test_10_4_0";
        SCENARIO_FILE   :  STRING  := "test_10_4_0.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 9;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 0;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_10_4_0;
architecture MODEL of TEST_BENCH_10_4_0 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_10_4_1 is
    generic (
        NAME            :  STRING  := "test_10_4_1";
        SCENARIO_FILE   :  STRING  := "test_10_4_1.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 9;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 1;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_10_4_1;
architecture MODEL of TEST_BENCH_10_4_1 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_10_4_2 is
    generic (
        NAME            :  STRING  := "test_10_4_2";
        SCENARIO_FILE   :  STRING  := "test_10_4_2.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 9;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 2;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_10_4_2;
architecture MODEL of TEST_BENCH_10_4_2 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_10_4_3 is
    generic (
        NAME            :  STRING  := "test_10_4_3";
        SCENARIO_FILE   :  STRING  := "test_10_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 9;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_10_4_3;
architecture MODEL of TEST_BENCH_10_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_11_4_3 is
    generic (
        NAME            :  STRING  := "test_11_4_3";
        SCENARIO_FILE   :  STRING  := "test_11_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 10;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_11_4_3;
architecture MODEL of TEST_BENCH_11_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_12_4_3 is
    generic (
        NAME            :  STRING  := "test_12_4_3";
        SCENARIO_FILE   :  STRING  := "test_12_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 11;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_12_4_3;
architecture MODEL of TEST_BENCH_12_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_13_4_3 is
    generic (
        NAME            :  STRING  := "test_13_4_3";
        SCENARIO_FILE   :  STRING  := "test_13_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 12;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_13_4_3;
architecture MODEL of TEST_BENCH_13_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_14_4_3 is
    generic (
        NAME            :  STRING  := "test_14_4_3";
        SCENARIO_FILE   :  STRING  := "test_14_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 13;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_14_4_3;
architecture MODEL of TEST_BENCH_14_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_15_4_3 is
    generic (
        NAME            :  STRING  := "test_15_4_3";
        SCENARIO_FILE   :  STRING  := "test_15_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 14;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_15_4_3;
architecture MODEL of TEST_BENCH_15_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  TEST_BENCH_16_4_3 is
    generic (
        NAME            :  STRING  := "test_16_4_3";
        SCENARIO_FILE   :  STRING  := "test_16_4_3.snr";
        MIN_NUM         :  integer := 0;
        MAX_NUM         :  integer := 15;
        NODE_NUM        :  integer := 4;
        PIPELINE        :  integer := 3;
        FINISH_ABORT    :  boolean := FALSE
    );
end     TEST_BENCH_16_4_3;
architecture MODEL of TEST_BENCH_16_4_3 is
begin
    TB: entity WORK.TEST_BENCH generic map (
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        MIN_NUM         => MIN_NUM         ,
        MAX_NUM         => MAX_NUM         ,
        NODE_NUM        => NODE_NUM        ,
        PIPELINE        => PIPELINE        ,
        FINISH_ABORT    => FINISH_ABORT    
    );
end MODEL;
