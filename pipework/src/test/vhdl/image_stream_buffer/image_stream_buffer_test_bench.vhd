-----------------------------------------------------------------------------------
--!     @file    image_stream_buffer_test_bench.vhd
--!     @brief   Image Stream Buffer Test Bench.
--!     @version 1.8.0
--!     @date    2019/3/21
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
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_BUFFER_TEST_BENCH is
    generic (
        NAME            : STRING                  := "test";
        SCENARIO_FILE   : STRING                  := "test.snr";
        I_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
        O_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
        O_SHAPE         : IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        ELEMENT_SIZE    : integer                 := 8*1024;
        LINE_SIZE       : integer                 := 0;
        BANK_SIZE       : integer                 := 0;
        FINISH_ABORT    : boolean                 := FALSE
    );
end     IMAGE_STREAM_BUFFER_TEST_BENCH;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_STREAM_BUFFER;
library DUMMY_PLUG;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
library WORK;
use     WORK.IMAGE_STREAM_MODELS.IMAGE_STREAM_MASTER_PLAYER;
use     WORK.IMAGE_STREAM_MODELS.IMAGE_STREAM_SLAVE_PLAYER;
architecture MODEL of IMAGE_STREAM_BUFFER_TEST_BENCH is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant  PERIOD            :  time    := 10 ns;
    constant  DELAY             :  time    :=  1 ns;
    constant  SYNC_WIDTH        :  integer :=  2;
    constant  GPO_WIDTH         :  integer :=  8;
    constant  GPI_WIDTH         :  integer :=  GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal    CLK               :  std_logic;
    signal    RESET             :  std_logic;
    constant  CLEAR             :  std_logic := '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    I_START           :  std_logic;
    signal    I_ENABLE          :  std_logic;
    signal    I_DATA            :  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
    signal    I_VALID           :  std_logic;
    signal    I_READY           :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    O_RETURN          :  std_logic;
    signal    O_DATA            :  std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
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
    signal    O_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    O_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal    N_REPORT          :  REPORT_STATUS_TYPE;
    signal    I_REPORT          :  REPORT_STATUS_TYPE;
    signal    O_REPORT          :  REPORT_STATUS_TYPE;
    signal    N_FINISH          :  std_logic;
    signal    I_FINISH          :  std_logic;
    signal    O_FINISH          :  std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DUT: IMAGE_STREAM_BUFFER                         --
        generic map(                                 --
            I_PARAM             => I_PARAM         , --
            O_PARAM             => O_PARAM         , --
            O_SHAPE             => O_SHAPE         , --
            ELEMENT_SIZE        => ELEMENT_SIZE    , --
            BANK_SIZE           => BANK_SIZE       , --
            LINE_SIZE           => LINE_SIZE       , --
            ID                  => 0                 --
        )                                            --
        port map (                                   --
            CLK                 => CLK             , -- In  :
            RST                 => RESET           , -- In  :
            CLR                 => CLEAR           , -- In  :
            I_DATA              => I_DATA          , -- In  :
            I_VALID             => I_VALID         , -- In  :
            I_READY             => I_READY         , -- Out :
            O_RETURN            => O_RETURN        , -- In  :
            O_DATA              => O_DATA          , -- Out :
            O_VALID             => O_VALID         , -- Out :
            O_READY             => O_READY           -- In  :
    );
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
            PARAM               => I_PARAM         , --
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
    O: IMAGE_STREAM_SLAVE_PLAYER                     --
        generic map (                                --
            SCENARIO_FILE       => SCENARIO_FILE   , --
            NAME                => "O"             , --
            PARAM               => O_PARAM         , --
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
    O_RETURN <= O_GPO(0);
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
        WRITE(L,T & "[ INTAKE ]");                                    WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,I_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,I_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,I_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ OUTLET ]");                                    WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,O_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,O_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,O_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert (I_REPORT.error_count    = 0 and
                O_REPORT.error_count    = 0)
            report "Simulation complete(error)."    severity FAILURE;
        assert (I_REPORT.mismatch_count = 0 and
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
-- ELEM_BIT8=8bit, CHANNEL_SIZE=4, I.C=1, I.X=1, I.Y=1, O.C=1, O.X=1, O.Y=1
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_BUFFER_TEST_4_8_1x1x1_1x1x1x1 is
    generic (
        NAME            : STRING                  := "test_4_8_1x1x1_1x1x1x1";
        SCENARIO_FILE   : STRING                  := "src/test/scenarios/image_stream_buffer/test_4_8_1x1x1_1x1x1x1.snr";
        I_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_SHAPE         : IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE(8,
                                                                     NEW_IMAGE_SHAPE_SIDE_CONSTANT(4),
                                                                     NEW_IMAGE_SHAPE_SIDE_CONSTANT(1),
                                                                     NEW_IMAGE_SHAPE_SIDE_AUTO    (1024),
                                                                     NEW_IMAGE_SHAPE_SIDE_AUTO    (1024)
                                                     );
        BANK_SIZE       : integer                 := 0;
        LINE_SIZE       : integer                 := 0;
        FINISH_ABORT    : boolean                 := FALSE
    );
end     IMAGE_STREAM_BUFFER_TEST_4_8_1x1x1_1x1x1x1;
architecture MODEL of IMAGE_STREAM_BUFFER_TEST_4_8_1x1x1_1x1x1x1 is
    component IMAGE_STREAM_BUFFER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            I_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            O_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            O_SHAPE         : IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
            BANK_SIZE       : integer                 := 0;
            LINE_SIZE       : integer                 := 0;
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_BUFFER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        I_PARAM         => I_PARAM      ,
        O_PARAM         => O_PARAM      ,
        O_SHAPE         => O_SHAPE      ,
        BANK_SIZE       => BANK_SIZE    ,
        LINE_SIZE       => LINE_SIZE    ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- ELEM_BIT8=8bit, CHANNEL_SIZE=4, I.C=4, I.X=1, I.Y=1, O.C=4, O.X=1, O.Y=1
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_BUFFER_TEST_4_8_4x1x1_4x1x1x1 is
    generic (
        NAME            : STRING                  := "test_4_8_4x1x1_4x1x1x1";
        SCENARIO_FILE   : STRING                  := "src/test/scenarios/image_stream_buffer/test_4_8_4x1x1_4x1x1x1.snr";
        I_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,4,1,1);
        O_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,4,1,1);
        O_SHAPE         : IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE(8,
                                                                     NEW_IMAGE_SHAPE_SIDE_CONSTANT(4),
                                                                     NEW_IMAGE_SHAPE_SIDE_CONSTANT(1),
                                                                     NEW_IMAGE_SHAPE_SIDE_AUTO    (1024),
                                                                     NEW_IMAGE_SHAPE_SIDE_AUTO    (1024)
                                                     );
        BANK_SIZE       : integer                 := 0;
        LINE_SIZE       : integer                 := 0;
        FINISH_ABORT    : boolean                 := FALSE
    );
end     IMAGE_STREAM_BUFFER_TEST_4_8_4x1x1_4x1x1x1;
architecture MODEL of IMAGE_STREAM_BUFFER_TEST_4_8_4x1x1_4x1x1x1 is
    component IMAGE_STREAM_BUFFER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            I_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            O_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            O_SHAPE         : IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
            BANK_SIZE       : integer                 := 0;
            LINE_SIZE       : integer                 := 0;
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_BUFFER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        I_PARAM         => I_PARAM      ,
        O_PARAM         => O_PARAM      ,
        O_SHAPE         => O_SHAPE      ,
        BANK_SIZE       => BANK_SIZE    ,
        LINE_SIZE       => LINE_SIZE    ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- ELEM_BIT8=8bit, CHANNEL_SIZE=1, I.C=1, I.X=4, I.Y=1, O.C=1, O.X=5, O.Y=5
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_BUFFER_TEST_1_8_1x4x1_1x1x5x5 is
    generic (
        NAME            : STRING                  := "test_1_8_1x4x1_1x1x5x5";
        SCENARIO_FILE   : STRING                  := "src/test/scenarios/image_stream_buffer/test_1_8_1x4x1_1x1x5x5.snr";
        I_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(
                                                         ELEM_BITS => 8,
                                                         SHAPE     => NEW_IMAGE_SHAPE(
                                                                        ELEM_BITS => 8,
                                                                        C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1),
                                                                        X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(4),
                                                                        Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1)
                                                                      ),
                                                         STRIDE    => NEW_IMAGE_STREAM_STRIDE_PARAM(4,1)
                                                     );
        O_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(
                                                         ELEM_BITS => 8,
                                                         SHAPE     => NEW_IMAGE_SHAPE(
                                                                        ELEM_BITS => 8,
                                                                        C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1),
                                                                        X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(5),
                                                                        Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(5)
                                                                      ),
                                                         STRIDE    => NEW_IMAGE_STREAM_STRIDE_PARAM(1,1)
                                                     );
        O_SHAPE         : IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE(
                                                         ELEM_BITS => 8,
                                                         C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1),
                                                         D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1),
                                                         X         => NEW_IMAGE_SHAPE_SIDE_AUTO    (1024),
                                                         Y         => NEW_IMAGE_SHAPE_SIDE_AUTO    (1024)
                                                     );
        BANK_SIZE       : integer                 := 0;
        LINE_SIZE       : integer                 := 0;
        FINISH_ABORT    : boolean                 := FALSE
    );
end     IMAGE_STREAM_BUFFER_TEST_1_8_1x4x1_1x1x5x5;
architecture MODEL of IMAGE_STREAM_BUFFER_TEST_1_8_1x4x1_1x1x5x5 is
    component IMAGE_STREAM_BUFFER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            I_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            O_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            O_SHAPE         : IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
            BANK_SIZE       : integer                 := 0;
            LINE_SIZE       : integer                 := 0;
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_BUFFER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        I_PARAM         => I_PARAM      ,
        O_PARAM         => O_PARAM      ,
        O_SHAPE         => O_SHAPE      ,
        BANK_SIZE       => BANK_SIZE    ,
        LINE_SIZE       => LINE_SIZE    ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- ELEM_BITS=2bit, CHANNEL_SIZE=0, I.C=32, I.X=1, I.Y=1, O.C=32, O.X=3, O.Y=3 D_SIZE=8
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_BUFFER_TEST_0_2_32x1x1_32x4x3x3 is
    generic (
        NAME            : STRING                  := "test_0_2_32x1x1_32x4x3x3";
        SCENARIO_FILE   : STRING                  := "src/test/scenarios/image_stream_buffer/test_0_2_32x1x1_32x4x3x3.snr";
        I_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(
                                                         ELEM_BITS => 2,
                                                         SHAPE     => NEW_IMAGE_SHAPE(
                                                                        ELEM_BITS => 2,
                                                                        C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(32),
                                                                        D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(0),
                                                                        X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1),
                                                                        Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1)
                                                                      ),
                                                         STRIDE    => NEW_IMAGE_STREAM_STRIDE_PARAM(1,1)
                                                     );
        O_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(
                                                         ELEM_BITS => 2,
                                                         SHAPE     => NEW_IMAGE_SHAPE(
                                                                        ELEM_BITS => 2,
                                                                        C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(32  , TRUE , TRUE),
                                                                        D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(4   , FALSE, TRUE),
                                                                        X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(-1,1, TRUE , TRUE),
                                                                        Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(-1,1, TRUE , TRUE)
                                                                      ),
                                                         STRIDE    => NEW_IMAGE_STREAM_STRIDE_PARAM(1,1)
                                                     );
        O_SHAPE         : IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE(
                                                         ELEM_BITS => 8,
                                                         C         => NEW_IMAGE_SHAPE_SIDE_AUTO    (1024),
                                                         D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(8),
                                                         X         => NEW_IMAGE_SHAPE_SIDE_AUTO    (1024),
                                                         Y         => NEW_IMAGE_SHAPE_SIDE_AUTO    (1024)
                                                     );
        BANK_SIZE       : integer                 := 0;
        LINE_SIZE       : integer                 := 0;
        FINISH_ABORT    : boolean                 := FALSE
    );
end     IMAGE_STREAM_BUFFER_TEST_0_2_32x1x1_32x4x3x3;
architecture MODEL of IMAGE_STREAM_BUFFER_TEST_0_2_32x1x1_32x4x3x3 is
    component IMAGE_STREAM_BUFFER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            I_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            O_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            O_SHAPE         : IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
            BANK_SIZE       : integer                 := 0;
            LINE_SIZE       : integer                 := 0;
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_BUFFER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        I_PARAM         => I_PARAM      ,
        O_PARAM         => O_PARAM      ,
        O_SHAPE         => O_SHAPE      ,
        BANK_SIZE       => BANK_SIZE    ,
        LINE_SIZE       => LINE_SIZE    ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- ELEM_BITS=2bit, CHANNEL_SIZE=0, I.C=32, I.X=1, I.Y=1, O.C=32, O.X=3, O.Y=3 D_SIZE=8
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_BUFFER_TEST_0_2_32x1x1_32x4x3x3_bug1 is
    generic (
        NAME            : STRING                  := "test_0_2_32x1x1_32x4x3x3_bug1";
        SCENARIO_FILE   : STRING                  := "src/test/scenarios/image_stream_buffer/test_0_2_32x1x1_32x4x3x3_bug1.snr";
        I_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(
                                                         ELEM_BITS => 2,
                                                         SHAPE     => NEW_IMAGE_SHAPE(
                                                                        ELEM_BITS => 2,
                                                                        C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(32),
                                                                        D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(0),
                                                                        X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1),
                                                                        Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1)
                                                                      ),
                                                         STRIDE    => NEW_IMAGE_STREAM_STRIDE_PARAM(1,1)
                                                     );
        O_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(
                                                         ELEM_BITS => 2,
                                                         SHAPE     => NEW_IMAGE_SHAPE(
                                                                        ELEM_BITS => 2,
                                                                        C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(32  , TRUE , TRUE),
                                                                        D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(4   , FALSE, TRUE),
                                                                        X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(-1,1, TRUE , TRUE),
                                                                        Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(-1,1, TRUE , TRUE)
                                                                      ),
                                                         STRIDE    => NEW_IMAGE_STREAM_STRIDE_PARAM(1,1)
                                                     );
        O_SHAPE         : IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE(
                                                         ELEM_BITS => 8,
                                                         C         => NEW_IMAGE_SHAPE_SIDE_AUTO    (1024),
                                                         D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(8),
                                                         X         => NEW_IMAGE_SHAPE_SIDE_AUTO    (1024),
                                                         Y         => NEW_IMAGE_SHAPE_SIDE_AUTO    (1024)
                                                     );
        BANK_SIZE       : integer                 := 0;
        LINE_SIZE       : integer                 := 0;
        FINISH_ABORT    : boolean                 := FALSE
    );
end     IMAGE_STREAM_BUFFER_TEST_0_2_32x1x1_32x4x3x3_bug1;
architecture MODEL of IMAGE_STREAM_BUFFER_TEST_0_2_32x1x1_32x4x3x3_bug1 is
    component IMAGE_STREAM_BUFFER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            I_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            O_PARAM         : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            O_SHAPE         : IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
            BANK_SIZE       : integer                 := 0;
            LINE_SIZE       : integer                 := 0;
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_BUFFER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        I_PARAM         => I_PARAM      ,
        O_PARAM         => O_PARAM      ,
        O_SHAPE         => O_SHAPE      ,
        BANK_SIZE       => BANK_SIZE    ,
        LINE_SIZE       => LINE_SIZE    ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
