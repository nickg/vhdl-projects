-----------------------------------------------------------------------------------
--!     @file    image_stream_player_test_bench.vhd
--!     @brief   Image Stream Dummy Plug Player Test Bench.
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
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_PLAYER_TEST_BENCH is
    generic (
        NAME            : STRING                  := "test";
        SCENARIO_FILE   : STRING                  := "test.snr";
        PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
        FINISH_ABORT    : boolean                 := FALSE
    );
end     IMAGE_STREAM_PLAYER_TEST_BENCH;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
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
architecture MODEL of IMAGE_STREAM_PLAYER_TEST_BENCH is
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
    signal    RESET             :  std_logic;
    signal    CLK               :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    WIN_DATA          :  std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
    signal    WIN_VALID         :  std_logic;
    signal    WIN_READY         :  std_logic;
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal    SYNC              :  SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal    M_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    M_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    S_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    S_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal    N_REPORT          :  REPORT_STATUS_TYPE;
    signal    M_REPORT          :  REPORT_STATUS_TYPE;
    signal    S_REPORT          :  REPORT_STATUS_TYPE;
    signal    N_FINISH          :  std_logic;
    signal    M_FINISH          :  std_logic;
    signal    S_FINISH          :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure DEBUG_IMAGE_STREAM_PARAM(NAME:string; PARAM:IMAGE_STREAM_PARAM_TYPE)
    is
        variable L   : LINE;
        constant T   : STRING(1 to 1) := " ";
    begin
        WRITE(L,T & NAME);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  ELEM_BITS   = " & INTEGER_TO_STRING(PARAM.ELEM_BITS));WRITELINE(OUTPUT,L);
        WRITE(L,T & "  ATRB_BITS   = " & INTEGER_TO_STRING(PARAM.ATRB_BITS));WRITELINE(OUTPUT,L);
        WRITE(L,T & "  INFO_BITS   = " & INTEGER_TO_STRING(PARAM.INFO_BITS));WRITELINE(OUTPUT,L);
        WRITE(L,T & "  SHAPE.C SIZE="  & INTEGER_TO_STRING(PARAM.SHAPE.C.SIZE)                  &
                               " LO="  & INTEGER_TO_STRING(PARAM.SHAPE.C.LO)                    &
                               " HI="  & INTEGER_TO_STRING(PARAM.SHAPE.C.HI)                    &
                               " DE="  & BOOLEAN_TO_STRING(PARAM.SHAPE.C.ELEM_IN_DATA)(1 to 1)  &
                               " DA="  & BOOLEAN_TO_STRING(PARAM.SHAPE.C.ATRB_IN_DATA)(1 to 1)  );WRITELINE(OUTPUT,L);
        WRITE(L,T & "       .D SIZE="  & INTEGER_TO_STRING(PARAM.SHAPE.D.SIZE)                  &
                               " LO="  & INTEGER_TO_STRING(PARAM.SHAPE.D.LO)                    &
                               " HI="  & INTEGER_TO_STRING(PARAM.SHAPE.D.HI)                    &
                               " DE="  & BOOLEAN_TO_STRING(PARAM.SHAPE.D.ELEM_IN_DATA)(1 to 1)  &
                               " DA="  & BOOLEAN_TO_STRING(PARAM.SHAPE.D.ATRB_IN_DATA)(1 to 1)  );WRITELINE(OUTPUT,L);
        WRITE(L,T & "       .X SIZE="  & INTEGER_TO_STRING(PARAM.SHAPE.X.SIZE)                  &
                               " LO="  & INTEGER_TO_STRING(PARAM.SHAPE.X.LO)                    &
                               " HI="  & INTEGER_TO_STRING(PARAM.SHAPE.X.HI)                    &
                               " DE="  & BOOLEAN_TO_STRING(PARAM.SHAPE.X.ELEM_IN_DATA)(1 to 1)  &
                               " DA="  & BOOLEAN_TO_STRING(PARAM.SHAPE.X.ATRB_IN_DATA)(1 to 1)  );WRITELINE(OUTPUT,L);
        WRITE(L,T & "       .Y SIZE="  & INTEGER_TO_STRING(PARAM.SHAPE.Y.SIZE)                  &
                               " LO="  & INTEGER_TO_STRING(PARAM.SHAPE.Y.LO)                    &
                               " HI="  & INTEGER_TO_STRING(PARAM.SHAPE.Y.HI)                    &
                               " DE="  & BOOLEAN_TO_STRING(PARAM.SHAPE.Y.ELEM_IN_DATA)(1 to 1)  &
                               " DA="  & BOOLEAN_TO_STRING(PARAM.SHAPE.Y.ATRB_IN_DATA)(1 to 1)  );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  DATA            SIZE=" & INTEGER_TO_STRING(PARAM.DATA.SIZE)              &
                                       " LO=" & INTEGER_TO_STRING(PARAM.DATA.LO)                &
                                       " HI=" & INTEGER_TO_STRING(PARAM.DATA.HI)                );WRITELINE(OUTPUT,L);
        WRITE(L,T & "     ELEM_FIELD   SIZE=" & INTEGER_TO_STRING(PARAM.DATA.ELEM_FIELD.SIZE)   &
                                       " LO=" & INTEGER_TO_STRING(PARAM.DATA.ELEM_FIELD.LO)     &
                                       " HI=" & INTEGER_TO_STRING(PARAM.DATA.ELEM_FIELD.HI)     );WRITELINE(OUTPUT,L);
        WRITE(L,T & "     ATRB_FIELD   SIZE=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.SIZE)   &
                                       " LO=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.LO)     &
                                       " HI=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.HI)     );WRITELINE(OUTPUT,L);
        WRITE(L,T & "     ATRB_FIELD.C SIZE=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.C.SIZE) &
                                       " LO=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.C.LO)   &
                                       " HI=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.C.HI)   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "     ATRB_FIELD.D SIZE=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.D.SIZE) &
                                       " LO=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.D.LO)   &
                                       " HI=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.D.HI)   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "     ATRB_FIELD.X SIZE=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.X.SIZE) &
                                       " LO=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.X.LO)   &
                                       " HI=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.X.HI)   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "     ATRB_FIELD.Y SIZE=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.Y.SIZE) &
                                       " LO=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.Y.LO)   &
                                       " HI=" & INTEGER_TO_STRING(PARAM.DATA.ATRB_FIELD.Y.HI)   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "     INFO_FIELD   SIZE=" & INTEGER_TO_STRING(PARAM.DATA.INFO_FIELD.SIZE)   &
                                       " LO=" & INTEGER_TO_STRING(PARAM.DATA.INFO_FIELD.LO)     &
                                       " HI=" & INTEGER_TO_STRING(PARAM.DATA.INFO_FIELD.HI)     );WRITELINE(OUTPUT,L);
    end procedure;
begin
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
    M: IMAGE_STREAM_MASTER_PLAYER                    --
        generic map (                                --
            SCENARIO_FILE       => SCENARIO_FILE   , --
            NAME                => "M"             , --
            PARAM               => PARAM           , --
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
            DATA                => WIN_DATA        , -- I/O :
            VALID               => WIN_VALID       , -- I/O :
            READY               => WIN_READY       , -- In  :
            SYNC(0)             => SYNC(0)         , -- I/O :
            SYNC(1)             => SYNC(1)         , -- I/O :
            GPI                 => M_GPI           , -- In  :
            GPO                 => M_GPO           , -- Out :
            REPORT_STATUS       => M_REPORT        , -- Out :
            FINISH              => M_FINISH          -- Out :
        );                                           --
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    S: IMAGE_STREAM_SLAVE_PLAYER                     --
        generic map (                                --
            SCENARIO_FILE       => SCENARIO_FILE   , --
            NAME                => "S"             , --
            PARAM               => PARAM           , --
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
            DATA                => WIN_DATA        , -- In  :
            VALID               => WIN_VALID       , -- In  :
            READY               => WIN_READY       , -- I/O :
            SYNC(0)             => SYNC(0)         , -- I/O :
            SYNC(1)             => SYNC(1)         , -- I/O :
            GPI                 => S_GPI           , -- In  :
            GPO                 => S_GPO           , -- Out :
            REPORT_STATUS       => S_REPORT        , -- Out :
            FINISH              => S_FINISH          -- Out :
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
    M_GPI <= S_GPO;
    S_GPI <= M_GPO;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        DEBUG_IMAGE_STREAM_PARAM(string'("PARAM"), PARAM);
        wait until (N_FINISH'event and N_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ MASTER ]");                                    WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,M_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,M_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,M_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ SLAVE ]");                                     WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,S_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,S_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,S_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert (M_REPORT.error_count    = 0 and
                S_REPORT.error_count    = 0)
            report "Simulation complete(error)."    severity FAILURE;
        assert (M_REPORT.mismatch_count = 0 and
                S_REPORT.mismatch_count = 0)
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
-- ELEM_BITS=8bit, C=0, D=0, X=0, Y=0
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_PLAYER_TEST_8x0x0x0x0 is
    generic (
        NAME            : STRING                  := "test_8x0x0x0x0";
        SCENARIO_FILE   : STRING                  := "test_8x0x0x0x0.snr";
        PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(ELEM_BITS => 8,
                                                                            SHAPE     => NEW_IMAGE_SHAPE(
                                                                                ELEM_BITS => 8,
                                                                                C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , FALSE),
                                                                                D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, FALSE, FALSE),
                                                                                X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , FALSE),
                                                                                Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , FALSE)
                                                                            )
                                                                           );
        FINISH_ABORT    : boolean := FALSE
    );
end     IMAGE_STREAM_PLAYER_TEST_8x0x0x0x0;
architecture MODEL of IMAGE_STREAM_PLAYER_TEST_8x0x0x0x0 is
    component IMAGE_STREAM_PLAYER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_PLAYER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        PARAM           => PARAM        ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- ELEM_BITS=8bit, C=1, D=0, X=0, Y=0
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_PLAYER_TEST_8x1x0x0x0 is
    generic (
        NAME            : STRING                  := "test_8x1x0x0x0";
        SCENARIO_FILE   : STRING                  := "test_8x1x0x0x0.snr";
        PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(ELEM_BITS => 8,
                                                                            SHAPE     => NEW_IMAGE_SHAPE(
                                                                                ELEM_BITS => 8,
                                                                                C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , TRUE ),
                                                                                D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, FALSE, FALSE),
                                                                                X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , FALSE),
                                                                                Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , FALSE)
                                                                            )
                                                                           );
        FINISH_ABORT    : boolean := FALSE
    );
end     IMAGE_STREAM_PLAYER_TEST_8x1x0x0x0;
architecture MODEL of IMAGE_STREAM_PLAYER_TEST_8x1x0x0x0 is
    component IMAGE_STREAM_PLAYER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_PLAYER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        PARAM           => PARAM        ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- ELEM_BITS=8bit, C=1, D=0, X=1, Y=1
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_PLAYER_TEST_8x1x0x1x1 is
    generic (
        NAME            : STRING                  := "test_8x1x0x1x1";
        SCENARIO_FILE   : STRING                  := "test_8x1x0x1x1.snr";
        PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(ELEM_BITS => 8,
                                                                            SHAPE     => NEW_IMAGE_SHAPE(
                                                                                ELEM_BITS => 8,
                                                                                C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , TRUE ),
                                                                                D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, FALSE, FALSE),
                                                                                X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , TRUE ),
                                                                                Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , TRUE )
                                                                            )
                                                                           );
        FINISH_ABORT    : boolean := FALSE
    );
end     IMAGE_STREAM_PLAYER_TEST_8x1x0x1x1;
architecture MODEL of IMAGE_STREAM_PLAYER_TEST_8x1x0x1x1 is
    component IMAGE_STREAM_PLAYER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_PLAYER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        PARAM           => PARAM        ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- ELEM_BITS=8bit, C=3, D=0, X=4, Y=1
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_PLAYER_TEST_8x3x0x4x1 is
    generic (
        NAME            : STRING                  := "test_8x3x0x4x1";
        SCENARIO_FILE   : STRING                  := "test_8x3x0x4x1.snr";
        PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(ELEM_BITS => 8,
                                                                            SHAPE     => NEW_IMAGE_SHAPE(
                                                                                ELEM_BITS => 8,
                                                                                C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(3, TRUE , TRUE ),
                                                                                D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, FALSE, FALSE),
                                                                                X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(4, TRUE , TRUE ),
                                                                                Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , TRUE )
                                                                                ),
                                                                            STRIDE    => NEW_IMAGE_STREAM_STRIDE_PARAM(4,1)
                                                                           );
        FINISH_ABORT    : boolean := FALSE
    );
end     IMAGE_STREAM_PLAYER_TEST_8x3x0x4x1;
architecture MODEL of IMAGE_STREAM_PLAYER_TEST_8x3x0x4x1 is
    component IMAGE_STREAM_PLAYER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_PLAYER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        PARAM           => PARAM        ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- ELEM_BITS=8bit, C=0, D=0, X=2, Y=2
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_PLAYER_TEST_8x0x0x2x2 is
    generic (
        NAME            : STRING                  := "test_8x0x0x2x2";
        SCENARIO_FILE   : STRING                  := "src/test/scenarios/image_stream_models/test_8x0x0x2x2.snr";
        PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(ELEM_BITS => 8,
                                                                            SHAPE     => NEW_IMAGE_SHAPE(
                                                                                ELEM_BITS => 8,
                                                                                C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , FALSE),
                                                                                D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, FALSE, FALSE),
                                                                                X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(2, TRUE , TRUE ),
                                                                                Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(2, TRUE , TRUE )
                                                                                )
                                                                           );
        FINISH_ABORT    : boolean := FALSE
    );
end     IMAGE_STREAM_PLAYER_TEST_8x0x0x2x2;
architecture MODEL of IMAGE_STREAM_PLAYER_TEST_8x0x0x2x2 is
    component IMAGE_STREAM_PLAYER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_PLAYER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        PARAM           => PARAM        ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- ELEM_BITS=8bit, C=4, D=4, X=3, Y=3
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_PLAYER_TEST_8x4x4x3x3 is
    generic (
        NAME            : STRING                  := "test_8x4x4x3x3";
        SCENARIO_FILE   : STRING                  := "test_8x4x4x3x3.snr";
        PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(ELEM_BITS => 8,
                                                                            SHAPE     => NEW_IMAGE_SHAPE(
                                                                                ELEM_BITS => 8,
                                                                                C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(4, TRUE , TRUE ),
                                                                                D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(4, FALSE, TRUE ),
                                                                                X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(3, TRUE , TRUE ),
                                                                                Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(3, TRUE , TRUE )
                                                                                )
                                                                           );
        FINISH_ABORT    : boolean := FALSE
    );
end     IMAGE_STREAM_PLAYER_TEST_8x4x4x3x3;
architecture MODEL of IMAGE_STREAM_PLAYER_TEST_8x4x4x3x3 is
    component IMAGE_STREAM_PLAYER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_PLAYER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        PARAM           => PARAM        ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- ELEM_BITS=8bit, C=0, D=1, X=0, Y=0
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
entity  IMAGE_STREAM_PLAYER_TEST_8x0x1x0x0 is
    generic (
        NAME            : STRING                  := "test_8x0x1x0x0";
        SCENARIO_FILE   : STRING                  := "test_8x0x1x0x0.snr";
        PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(ELEM_BITS => 8,
                                                                            SHAPE     => NEW_IMAGE_SHAPE(
                                                                                ELEM_BITS => 8,
                                                                                C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , FALSE),
                                                                                D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, FALSE, TRUE ),
                                                                                X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , FALSE),
                                                                                Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(1, TRUE , FALSE)
                                                                                )
                                                                           );
        FINISH_ABORT    : boolean := FALSE
    );
end     IMAGE_STREAM_PLAYER_TEST_8x0x1x0x0;
architecture MODEL of IMAGE_STREAM_PLAYER_TEST_8x0x1x0x0 is
    component IMAGE_STREAM_PLAYER_TEST_BENCH is
        generic (
            NAME            : STRING                  := "test";
            SCENARIO_FILE   : STRING                  := "test.snr";
            PARAM           : IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1);
            FINISH_ABORT    : boolean                 := FALSE
        );
    end component;
begin
    TB: IMAGE_STREAM_PLAYER_TEST_BENCH generic map (
        NAME            => NAME         ,
        SCENARIO_FILE   => SCENARIO_FILE,
        PARAM           => PARAM        ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
