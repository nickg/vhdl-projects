-----------------------------------------------------------------------------------
--!     @file    convolution_int_core_test_bench.vhd
--!     @brief   Test Bench for Convolution Integer Core Module
--!     @version 1.8.0
--!     @date    2019/3/21
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2019 Ichiro Kawazome
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
library PipeWork;
use     PipeWork.IMAGE_TYPES.all;
use     PipeWork.CONVOLUTION_TYPES.all;
entity  CONV_INT_CORE_TEST_BENCH is
    generic (
        NAME            : STRING                          := "test";
        SCENARIO_FILE   : STRING                          := "test.snr";
        SIGN            : boolean                         := FALSE;
        KERNEL_SIZE     : CONVOLUTION_KERNEL_SIZE_TYPE    := CONVOLUTION_KERNEL_SIZE_1x1;
        STRIDE          : IMAGE_STREAM_STRIDE_PARAM_TYPE  := NEW_IMAGE_STREAM_STRIDE_PARAM(1,1);
        I_STREAM        : IMAGE_STREAM_PARAM_TYPE         := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        I_SHAPE_C       : IMAGE_SHAPE_SIDE_TYPE           := NEW_IMAGE_SHAPE_SIDE_CONSTANT(1);
        I_SHAPE_X       : IMAGE_SHAPE_SIDE_TYPE           := NEW_IMAGE_SHAPE_SIDE_CONSTANT(1);
        I_SHAPE_Y       : IMAGE_SHAPE_SIDE_TYPE           := NEW_IMAGE_SHAPE_SIDE_CONSTANT(1);
        O_SHAPE_C       : IMAGE_SHAPE_SIDE_TYPE           := NEW_IMAGE_SHAPE_SIDE_CONSTANT(1);
        C_UNROLL        : integer                         := 1;
        D_UNROLL        : integer                         := 1;
        X_UNROLL        : integer                         := 1;
        Y_UNROLL        : integer                         := 1;
        FINISH_ABORT    : boolean                         := FALSE
    );
end     CONV_INT_CORE_TEST_BENCH;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
library PipeWork;
use     PipeWork.CONVOLUTION_COMPONENTS.CONVOLUTION_INT_CORE;
library WORK;
use     WORK.IMAGE_STREAM_MODELS.IMAGE_STREAM_MASTER_PLAYER;
use     WORK.IMAGE_STREAM_MODELS.IMAGE_STREAM_SLAVE_PLAYER;
architecture MODEL of CONV_INT_CORE_TEST_BENCH is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant  PERIOD            :  time    := 10 ns;
    constant  DELAY             :  time    :=  1 ns;
    constant  SYNC_WIDTH        :  integer :=  2;
    constant  GPO_WIDTH         :  integer :=  8;
    constant  GPI_WIDTH         :  integer :=  GPO_WIDTH;
    constant  W_ELEM_BITS       :  integer :=  8;
    constant  B_ELEM_BITS       :  integer := 16;
    constant  M_ELEM_BITS       :  integer := 16;
    constant  O_ELEM_BITS       :  integer := 16;
    constant  PARAM             :  CONVOLUTION_PARAM_TYPE := NEW_CONVOLUTION_PARAM(
                                       KERNEL_SIZE => KERNEL_SIZE,
                                       STRIDE      => STRIDE     ,
                                       I_STREAM    => I_STREAM   ,
                                       I_SHAPE     => NEW_IMAGE_SHAPE(
                                           ELEM_BITS  => I_STREAM.ELEM_BITS,
                                           C          => I_SHAPE_C,
                                           D          => NEW_IMAGE_SHAPE_SIDE_CONSTANT(0),
                                           X          => I_SHAPE_X,
                                           Y          => I_SHAPE_Y
                                       ),
                                       B_ELEM_BITS => B_ELEM_BITS,
                                       W_ELEM_BITS => W_ELEM_BITS,
                                       M_ELEM_BITS => M_ELEM_BITS,
                                       O_ELEM_BITS => O_ELEM_BITS,
                                       O_SHAPE_C   => O_SHAPE_C  ,
                                       C_UNROLL    => C_UNROLL   ,
                                       D_UNROLL    => D_UNROLL   ,
                                       X_UNROLL    => X_UNROLL   ,
                                       Y_UNROLL    => Y_UNROLL
                                   );
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal    CLK               :  std_logic;
    signal    RESET             :  std_logic;
    constant  CLEAR             :  std_logic := '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    C_SIZE            :  integer range 0 to PARAM.SHAPE.C.MAX_SIZE := PARAM.SHAPE.C.SIZE;
    signal    D_SIZE            :  integer range 0 to PARAM.SHAPE.D.MAX_SIZE := PARAM.SHAPE.D.SIZE;
    signal    X_SIZE            :  integer range 0 to PARAM.SHAPE.X.MAX_SIZE := PARAM.SHAPE.X.SIZE;
    signal    Y_SIZE            :  integer range 0 to PARAM.SHAPE.Y.MAX_SIZE := PARAM.SHAPE.Y.SIZE;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    I_DATA            :  std_logic_vector(PARAM.I_STREAM.DATA.SIZE-1 downto 0);
    signal    I_VALID           :  std_logic;
    signal    I_READY           :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    W_DATA            :  std_logic_vector(PARAM.W_STREAM.DATA.SIZE-1 downto 0);
    signal    W_VALID           :  std_logic;
    signal    W_READY           :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    B_DATA            :  std_logic_vector(PARAM.B_STREAM.DATA.SIZE-1 downto 0);
    signal    B_VALID           :  std_logic;
    signal    B_READY           :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    O_DATA            :  std_logic_vector(PARAM.O_STREAM.DATA.SIZE-1 downto 0);
    signal    O_VALID           :  std_logic;
    signal    O_READY           :  std_logic;
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal    SYNC              :  SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal    I_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    I_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    W_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    W_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    B_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    B_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    O_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    O_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal    N_REPORT          :  REPORT_STATUS_TYPE;
    signal    I_REPORT          :  REPORT_STATUS_TYPE;
    signal    W_REPORT          :  REPORT_STATUS_TYPE;
    signal    B_REPORT          :  REPORT_STATUS_TYPE;
    signal    O_REPORT          :  REPORT_STATUS_TYPE;
    signal    N_FINISH          :  std_logic;
    signal    I_FINISH          :  std_logic;
    signal    W_FINISH          :  std_logic;
    signal    B_FINISH          :  std_logic;
    signal    O_FINISH          :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    DUT: CONVOLUTION_INT_CORE                        -- 
        generic map (                                -- 
            PARAM               => PARAM           , -- 
            SIGN                => SIGN              -- 
        )                                            -- 
        port map (                                   -- 
            CLK                 => CLK             , -- In  :
            RST                 => RESET           , -- In  :
            CLR                 => CLEAR           , -- In  :
            C_SIZE              => C_SIZE          , -- In  :
            D_SIZE              => D_SIZE          , -- In  :
            X_SIZE              => X_SIZE          , -- In  :
            Y_SIZE              => Y_SIZE          , -- In  :
            I_DATA              => I_DATA          , -- In  :
            I_VALID             => I_VALID         , -- In  :
            I_READY             => I_READY         , -- Out :
            W_DATA              => W_DATA          , -- In  :
            W_VALID             => W_VALID         , -- In  :
            W_READY             => W_READY         , -- Out :
            B_DATA              => B_DATA          , -- In  :
            B_VALID             => B_VALID         , -- In  :
            B_READY             => B_READY         , -- Out :
            O_DATA              => O_DATA          , -- Out :
            O_VALID             => O_VALID         , -- Out :
            O_READY             => O_READY           -- In  :
        );                                           -- 
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL                                       -- 
        generic map(                                 -- 
            SCENARIO_FILE       => SCENARIO_FILE   , -- 
            NAME                => "MARCHAL"       , --
            SYNC_PLUG_NUM       => 1               , --
            SYNC_WIDTH          => SYNC_WIDTH      , -- 
            FINISH_ABORT        => FALSE             -- 
        )                                            -- 
        port map(                                    -- 
            CLK                 => CLK             , -- In  :
            RESET               => RESET           , -- Out :
            SYNC(0)             => SYNC(0)         , -- I/O :
            SYNC(1)             => SYNC(1)         , -- I/O :
            REPORT_STATUS       => N_REPORT        , -- Out :
            FINISH              => N_FINISH          -- Out :
        );                                           -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I: IMAGE_STREAM_MASTER_PLAYER                    -- 
        generic map (                                -- 
            SCENARIO_FILE       => SCENARIO_FILE   , -- 
            NAME                => "I"             , --   
            PARAM               => PARAM.I_STREAM  , --   
            OUTPUT_DELAY        => DELAY           , --   
            SYNC_PLUG_NUM       => 2               , --   
            SYNC_WIDTH          => SYNC_WIDTH      , --   
            GPI_WIDTH           => GPI_WIDTH       , --   
            GPO_WIDTH           => GPO_WIDTH       , --   
            FINISH_ABORT        => FALSE             --   
        )                                            -- 
        port map (                                   -- 
            CLK                 => CLK             , -- In  :
            RST                 => RESET           , -- In  :
            DATA                => I_DATA          , -- I/O :
            VALID               => I_VALID         , -- I/O :
            READY               => I_READY         , -- In  :
            SYNC(0)             => SYNC(0)         , -- I/O :
            SYNC(1)             => SYNC(1)         , -- I/O :
            GPI                 => I_GPI           , -- In  :
            GPO                 => I_GPO           , -- Out :
            REPORT_STATUS       => I_REPORT        , -- Out :
            FINISH              => I_FINISH          -- Out :
        );                                           -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    W: IMAGE_STREAM_MASTER_PLAYER                    -- 
        generic map (                                -- 
            SCENARIO_FILE       => SCENARIO_FILE   , -- 
            NAME                => "W"             , --   
            PARAM               => PARAM.W_STREAM  , --   
            OUTPUT_DELAY        => DELAY           , --   
            SYNC_PLUG_NUM       => 3               , --   
            SYNC_WIDTH          => SYNC_WIDTH      , --   
            GPI_WIDTH           => GPI_WIDTH       , --   
            GPO_WIDTH           => GPO_WIDTH       , --   
            FINISH_ABORT        => FALSE             --   
        )                                            -- 
        port map (                                   -- 
            CLK                 => CLK             , -- In  :
            RST                 => RESET           , -- In  :
            DATA                => W_DATA          , -- I/O :
            VALID               => W_VALID         , -- I/O :
            READY               => W_READY         , -- In  :
            SYNC(0)             => SYNC(0)         , -- I/O :
            SYNC(1)             => SYNC(1)         , -- I/O :
            GPI                 => W_GPI           , -- In  :
            GPO                 => W_GPO           , -- Out :
            REPORT_STATUS       => W_REPORT        , -- Out :
            FINISH              => W_FINISH          -- Out :
        );                                           -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    B: IMAGE_STREAM_MASTER_PLAYER                    -- 
        generic map (                                -- 
            SCENARIO_FILE       => SCENARIO_FILE   , -- 
            NAME                => "B"             , --   
            PARAM               => PARAM.B_STREAM  , --   
            OUTPUT_DELAY        => DELAY           , --   
            SYNC_PLUG_NUM       => 4               , --   
            SYNC_WIDTH          => SYNC_WIDTH      , --   
            GPI_WIDTH           => GPI_WIDTH       , --   
            GPO_WIDTH           => GPO_WIDTH       , --   
            FINISH_ABORT        => FALSE             --   
        )                                            -- 
        port map (                                   -- 
            CLK                 => CLK             , -- In  :
            RST                 => RESET           , -- In  :
            DATA                => B_DATA          , -- I/O :
            VALID               => B_VALID         , -- I/O :
            READY               => B_READY         , -- In  :
            SYNC(0)             => SYNC(0)         , -- I/O :
            SYNC(1)             => SYNC(1)         , -- I/O :
            GPI                 => B_GPI           , -- In  :
            GPO                 => B_GPO           , -- Out :
            REPORT_STATUS       => B_REPORT        , -- Out :
            FINISH              => B_FINISH          -- Out :
        );                                           -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O: IMAGE_STREAM_SLAVE_PLAYER                     -- 
        generic map (                                -- 
            SCENARIO_FILE       => SCENARIO_FILE   , -- 
            NAME                => "O"             , --   
            PARAM               => PARAM.O_STREAM  , --   
            OUTPUT_DELAY        => DELAY           , --   
            SYNC_PLUG_NUM       => 5               , --   
            SYNC_WIDTH          => SYNC_WIDTH      , --   
            GPI_WIDTH           => GPI_WIDTH       , --   
            GPO_WIDTH           => GPO_WIDTH       , --   
            FINISH_ABORT        => FALSE             --   
        )                                            -- 
        port map (                                   -- 
            CLK                 => CLK             , -- In  :
            RST                 => RESET           , -- In  :
            DATA                => O_DATA          , -- In  :
            VALID               => O_VALID         , -- In  :
            READY               => O_READY         , -- I/O :
            SYNC(0)             => SYNC(0)         , -- I/O :
            SYNC(1)             => SYNC(1)         , -- I/O :
            GPI                 => O_GPI           , -- In  :
            GPO                 => O_GPO           , -- Out :
            REPORT_STATUS       => O_REPORT        , -- Out :
            FINISH              => O_FINISH          -- Out :
        );                                           -- 
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process begin
        loop
            CLK <= '0'; wait for PERIOD / 2;
            CLK <= '1'; wait for PERIOD / 2;
            exit when(N_FINISH = '1');
        end loop;
        CLK <= '0';
        wait;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I_GPI    <= (others => '0');
    W_GPI    <= (others => '0');
    B_GPI    <= (others => '0');
    O_GPI    <= (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        wait until (N_FINISH'event and N_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ I ]");                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,I_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,I_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,I_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ W ]");                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,W_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,W_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,W_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ B ]");                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,B_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,B_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,B_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ O ]");                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,O_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,O_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,O_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert (I_REPORT.error_count    = 0 and
                W_REPORT.error_count    = 0 and
                B_REPORT.error_count    = 0 and
                O_REPORT.error_count    = 0)
            report "Simulation complete(error)."    severity FAILURE;
        assert (I_REPORT.mismatch_count = 0 and
                W_REPORT.mismatch_count = 0 and
                B_REPORT.mismatch_count = 0 and
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
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PipeWork;
use     PipeWork.IMAGE_TYPES.all;
use     PipeWork.CONVOLUTION_TYPES.all;
entity  CONV_INT_CORE_TEST_BENCH_3x3_8_8x12x12_4x10x10_1111 is
    generic (
        NAME            : STRING                          := "test_3x3_8_8x12x12_4x10x10_1111";
        SCENARIO_FILE   : STRING                          := "test_3x3_8_8x12x12_4x10x10_1111.snr";
        SIGN            : boolean                         := FALSE;
        KERNEL_SIZE     : CONVOLUTION_KERNEL_SIZE_TYPE    := CONVOLUTION_KERNEL_SIZE_3x3;
        STRIDE          : IMAGE_STREAM_STRIDE_PARAM_TYPE  := NEW_IMAGE_STREAM_STRIDE_PARAM(1,1);
        I_STREAM        : IMAGE_STREAM_PARAM_TYPE         := NEW_IMAGE_STREAM_PARAM(8,8,1,1);
        I_SHAPE_C       : IMAGE_SHAPE_SIDE_TYPE           := NEW_IMAGE_SHAPE_SIDE_CONSTANT(8);
        I_SHAPE_X       : IMAGE_SHAPE_SIDE_TYPE           := NEW_IMAGE_SHAPE_SIDE_CONSTANT(12);
        I_SHAPE_Y       : IMAGE_SHAPE_SIDE_TYPE           := NEW_IMAGE_SHAPE_SIDE_CONSTANT(12);
        O_SHAPE_C       : IMAGE_SHAPE_SIDE_TYPE           := NEW_IMAGE_SHAPE_SIDE_CONSTANT(4);
        C_UNROLL        : integer                         := 1;
        D_UNROLL        : integer                         := 1;
        X_UNROLL        : integer                         := 1;
        Y_UNROLL        : integer                         := 1;
        FINISH_ABORT    : boolean                         := FALSE
    );
end     CONV_INT_CORE_TEST_BENCH_3x3_8_8x12x12_4x10x10_1111;
architecture MODEL of CONV_INT_CORE_TEST_BENCH_3x3_8_8x12x12_4x10x10_1111 is
begin
    TB: entity WORK.CONV_INT_CORE_TEST_BENCH generic map (
        NAME            => NAME            , 
        SCENARIO_FILE   => SCENARIO_FILE   , 
        SIGN            => SIGN            , 
        KERNEL_SIZE     => KERNEL_SIZE     , 
        STRIDE          => STRIDE          , 
        I_STREAM        => I_STREAM        , 
        I_SHAPE_C       => I_SHAPE_C       , 
        I_SHAPE_X       => I_SHAPE_X       , 
        I_SHAPE_Y       => I_SHAPE_Y       , 
        O_SHAPE_C       => O_SHAPE_C       , 
        C_UNROLL        => C_UNROLL        , 
        D_UNROLL        => D_UNROLL        , 
        X_UNROLL        => X_UNROLL        , 
        Y_UNROLL        => Y_UNROLL        , 
        FINISH_ABORT    => FINISH_ABORT   
    );
end MODEL;
