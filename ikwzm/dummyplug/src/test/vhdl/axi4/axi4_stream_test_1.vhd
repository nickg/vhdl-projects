-----------------------------------------------------------------------------------
--!     @file    aix4_stream_test_1.vhd
--!     @brief   TEST BENCH No.1 for DUMMY_PLUG.AXI4_MODELS
--!     @version 1.7.1
--!     @date    2018/3/20
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
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_SLAVE_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_SIGNAL_PRINTER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
entity  DUMMY_PLUG_AXI4_STREAM_TEST_1 is
    generic (
        NAME            : --! @brief テストベンチの識別名.
                          STRING;
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        DATA_WIDTH      : --! @brief データチャネルのビット幅.
                          integer;
        EXP_REPORT      : --! @brief 期待しているREPORT_STATUSの値.
                          REPORT_STATUS_TYPE
    );
end     DUMMY_PLUG_AXI4_STREAM_TEST_1;
architecture MODEL of DUMMY_PLUG_AXI4_STREAM_TEST_1 is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant PERIOD          : time    := 10 ns;
    constant DELAY           : time    :=  1 ns;
    constant WIDTH           : AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                 ID    =>  4,
                                 DATA  =>  DATA_WIDTH,
                                 USER  =>  4,
                                 DEST  =>  4);
    constant SYNC_WIDTH      : integer :=  2;
    constant GPO_WIDTH       : integer :=  8;
    constant GPI_WIDTH       : integer :=  2*GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal   ACLK            : std_logic;
    signal   ARESETn         : std_logic;
    signal   RESET           : std_logic;
    -------------------------------------------------------------------------------
    -- AXI4-Stream シグナル.
    -------------------------------------------------------------------------------
    signal   TLAST           : std_logic;
    signal   TDATA           : std_logic_vector(WIDTH.DATA  -1 downto 0);
    signal   TSTRB           : std_logic_vector(WIDTH.DATA/8-1 downto 0);
    signal   TKEEP           : std_logic_vector(WIDTH.DATA/8-1 downto 0);
    signal   TUSER           : std_logic_vector(WIDTH.USER  -1 downto 0);
    signal   TDEST           : std_logic_vector(WIDTH.DEST  -1 downto 0);
    signal   TID             : std_logic_vector(WIDTH.ID    -1 downto 0);
    signal   TVALID          : std_logic;
    signal   TREADY          : std_logic;
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal   SYNC            : SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal   M_GPI           : std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal   M_GPO           : std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal   S_GPI           : std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal   S_GPO           : std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal   N_REPORT        : REPORT_STATUS_TYPE;
    signal   M_REPORT        : REPORT_STATUS_TYPE;
    signal   S_REPORT        : REPORT_STATUS_TYPE;
    signal   N_FINISH        : std_logic;
    signal   M_FINISH        : std_logic;
    signal   S_FINISH        : std_logic;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "MARCHAL",
            SYNC_PLUG_NUM   => 1,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
            CLK             => ACLK            , -- In  :
            RESET           => RESET           , -- In  :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_STREAM_MASTER_PLAYER
    ------------------------------------------------------------------------------
    M: AXI4_STREAM_MASTER_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "MASTER"        ,
            OUTPUT_DELAY    => DELAY           ,
            WIDTH           => WIDTH           ,
            SYNC_PLUG_NUM   => 2               ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            TLAST           => TLAST           , -- I/O : 
            TDATA           => TDATA           , -- I/O : 
            TSTRB           => TSTRB           , -- I/O : 
            TKEEP           => TKEEP           , -- I/O : 
            TUSER           => TUSER           , -- I/O : 
            TDEST           => TDEST           , -- I/O : 
            TID             => TID             , -- I/O : 
            TVALID          => TVALID          , -- I/O : 
            TREADY          => TREADY          , -- In  :    
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => M_GPI           , -- In  :
            GPO             => M_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => M_REPORT        , -- Out :
            FINISH          => M_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_STREAM_SLAVE_PLAYER
    ------------------------------------------------------------------------------
    S: AXI4_STREAM_SLAVE_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "SLAVE"         ,
            OUTPUT_DELAY    => DELAY           ,
            WIDTH           => WIDTH           ,
            SYNC_PLUG_NUM   => 3               ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
            TLAST           => TLAST           , -- In  :    
            TDATA           => TDATA           , -- In  :    
            TSTRB           => TSTRB           , -- In  :    
            TKEEP           => TKEEP           , -- In  :    
            TUSER           => TUSER           , -- In  :    
            TDEST           => TDEST           , -- In  :    
            TID             => TID             , -- In  :    
            TVALID          => TVALID          , -- In  :    
            TREADY          => TREADY          , -- I/O : 
        ---------------------------------------------------------------------------
        -- シンクロ用信号
        ---------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => S_GPI           , -- In  :
            GPO             => S_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => S_REPORT        , -- Out :
            FINISH          => S_FINISH          -- Out :
    );

    ------------------------------------------------------------------------------
    -- AXI4_STREAM_SIGNAL_PRINTER
    ------------------------------------------------------------------------------
    P: AXI4_STREAM_SIGNAL_PRINTER
        generic map (
            NAME            => NAME,
            TAG             => NAME,
            TAG_WIDTH       => 0,
            TIME_WIDTH      => 13,
            WIDTH           => WIDTH
        ) 
        -------------------------------------------------------------------------------
        -- 入出力ポートの定義.
        -------------------------------------------------------------------------------
        port map (
            ACLK            => ACLK            , -- In :
            ARESETn         => ARESETn         , -- In :
            TDATA           => TDATA           , -- In :
            TSTRB           => TSTRB           , -- In :
            TKEEP           => TKEEP           , -- In :
            TUSER           => TUSER           , -- In :
            TDEST           => TDEST           , -- In :
            TID             => TID             , -- In :
            TLAST           => TLAST           , -- In :
            TVALID          => TVALID          , -- In :
            TREADY          => TREADY            -- In :
    );    
        
    process begin
        while (TRUE) loop
            ACLK <= '1';
            wait for PERIOD / 2;
            ACLK <= '0';
            wait for PERIOD / 2;
            exit when (N_FINISH = '1');
        end loop;
        ACLK <= '0';
        wait;
    end process;

    ARESETn <= '1' when (RESET = '0') else '0';
    M_GPI   <= S_GPO & M_GPO;
    S_GPI   <= S_GPO & M_GPO;
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
        variable rep : REPORT_STATUS_TYPE;
        variable rv  : REPORT_STATUS_VECTOR(1 to 2);
    begin
        wait until (N_FINISH'event and N_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
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
        rv(1) := M_REPORT;
        rv(2) := S_REPORT;
        rep := MARGE_REPORT_STATUS(rv);
        assert (rep.error_count      = EXP_REPORT.error_count     ) and
               (rep.mismatch_count   = EXP_REPORT.mismatch_count  ) and
               (rep.warning_count    = EXP_REPORT.warning_count   ) and
               (rep.failure_count    = EXP_REPORT.failure_count   ) and
               (rep.read_error_count = EXP_REPORT.read_error_count)
        report "REPORT Mismatch !!" severity FAILURE;
        assert FALSE report "Simulation complete." severity NOTE;
        wait;
    end process;
    
 -- SYNC_PRINT_0: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(0)")) port map (SYNC(0));
 -- SYNC_PRINT_1: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(1)")) port map (SYNC(1));
end MODEL;
