-----------------------------------------------------------------------------------
--!     @file    merge_sorter_core_test_bench.vhd
--!     @brief   Merge Sorter Core Test Bench :
--!     @version 1.4.1
--!     @date    2022/11/2
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2022 Ichiro Kawazome
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
entity  Merge_Sorter_Core_Test_Bench is
    generic (
        NAME            :  STRING  := "TEST";
        SCENARIO_FILE   :  STRING  := "test.snr";
        MRG_IN_ENABLE   :  boolean := TRUE;
        MRG_WAYS        :  integer := 4;
        MRG_WORDS       :  integer := 1;
        MRG_FIFO_SIZE   :  integer := 64;
        STM_IN_ENABLE   :  boolean := TRUE;
        STM_WORDS       :  integer := 1;
        STM_FEEDBACK    :  integer := 2;
        SORT_ORDER      :  integer := 0;
        COMP_SIGN       :  boolean := FALSE;
        FINISH_ABORT    :  boolean := FALSE
    );
end     Merge_Sorter_Core_Test_Bench;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library Merge_Sorter;
use     Merge_Sorter.Core_Components.Merge_Sorter_Core;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_SLAVE_PLAYER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
architecture Model of Merge_Sorter_Core_Test_Bench is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant   PERIOD       :  time    := 10 ns;
    constant   DELAY        :  time    :=  1 ns;
    constant   QUEUE_SIZE   :  integer :=  2;
    constant   DATA_BITS    :  integer := 32;
    constant   COMP_HIGH    :  integer := 31;
    constant   COMP_LOW     :  integer :=  0;
    constant   ATRB_BITS    :  integer :=  4;
    constant   INFO_BITS    :  integer :=  8;
    constant   SYNC_WIDTH   :  integer :=  2;
    constant   GPO_WIDTH    :  integer :=  8;
    constant   GPI_WIDTH    :  integer :=  GPO_WIDTH;
    constant   USER_ATRB_LO :  integer := 0;
    constant   USER_ATRB_HI :  integer := USER_ATRB_LO + MRG_WORDS*ATRB_BITS - 1;
    constant   USER_INFO_LO :  integer := USER_ATRB_HI + 1;
    constant   USER_INFO_HI :  integer := USER_INFO_LO + INFO_BITS - 1;
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
    signal     SYNC         : SYNC_SIG_VECTOR (SYNC_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant   MRG_I_WIDTH  :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                   ID    => 4,
                                   USER  => MRG_WORDS*ATRB_BITS+INFO_BITS,
                                   DEST  => 4,
                                   DATA  => MRG_WORDS*DATA_BITS
                               );
    type       I_DATA_VECTOR is array (integer range <>) of std_logic_vector(MRG_I_WIDTH.DATA-1 downto 0);
    type       I_USER_VECTOR is array (integer range <>) of std_logic_vector(MRG_I_WIDTH.USER-1 downto 0);
    signal     mrg_i_data   :  I_DATA_VECTOR   (MRG_WAYS-1 downto 0);
    signal     mrg_i_user   :  I_USER_VECTOR   (MRG_WAYS-1 downto 0);
    signal     mrg_i_last   :  std_logic_vector(MRG_WAYS-1 downto 0);
    signal     mrg_i_valid  :  std_logic_vector(MRG_WAYS-1 downto 0);
    signal     mrg_i_ready  :  std_logic_vector(MRG_WAYS-1 downto 0);
    signal     mrg_i_word   :  std_logic_vector(MRG_WAYS*MRG_WORDS*DATA_BITS-1 downto 0);
    signal     mrg_i_none   :  std_logic_vector(MRG_WAYS*MRG_WORDS          -1 downto 0);
    signal     mrg_i_eblk   :  std_logic_vector(MRG_WAYS-1 downto 0);
    signal     mrg_i_level  :  std_logic_vector(MRG_WAYS-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant   STM_I_WIDTH  :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                   ID    => 4,
                                   USER  => STM_WORDS*ATRB_BITS+INFO_BITS,
                                   DEST  => 4,
                                   DATA  => STM_WORDS*DATA_BITS
                               );
    signal     stm_i_data   :  std_logic_vector(STM_I_WIDTH.DATA  -1 downto 0);
    signal     stm_i_user   :  std_logic_vector(STM_I_WIDTH.USER  -1 downto 0);
    signal     stm_i_ena    :  std_logic_vector(STM_WORDS         -1 downto 0);
    signal     stm_i_last   :  std_logic;
    signal     stm_i_valid  :  std_logic;
    signal     stm_i_ready  :  std_logic;
    signal     stm_i_keep   :  std_logic_vector(STM_I_WIDTH.DATA/8-1 downto 0) := (others => '1');
    signal     stm_i_strb   :  std_logic_vector(STM_I_WIDTH.DATA/8-1 downto 0) := (others => '1');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant   OUT_WIDTH    :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                   ID    => 4,
                                   USER  => MRG_WORDS*ATRB_BITS+INFO_BITS,
                                   DEST  => 4,
                                   DATA  => MRG_WORDS*DATA_BITS
                               );
    signal     out_data     :  std_logic_vector(OUT_WIDTH.DATA  -1 downto 0);
    signal     out_user     :  std_logic_vector(OUT_WIDTH.USER  -1 downto 0);
    signal     out_last     :  std_logic;
    signal     out_valid    :  std_logic;
    signal     out_ready    :  std_logic;
    signal     out_ena      :  std_logic_vector(MRG_WORDS       -1 downto 0);
    constant   out_strb     :  std_logic_vector(OUT_WIDTH.DATA/8-1 downto 0) := (others => '1');
    constant   out_keep     :  std_logic_vector(OUT_WIDTH.DATA/8-1 downto 0) := (others => '1');
    constant   out_id       :  std_logic_vector(OUT_WIDTH.ID    -1 downto 0) := (others => '0');
    constant   out_dest     :  std_logic_vector(OUT_WIDTH.DEST  -1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal     OUT_GPI      :  std_logic_vector(GPI_WIDTH   -1 downto 0);
    signal     OUT_GPO      :  std_logic_vector(GPO_WIDTH   -1 downto 0);
    signal     STM_I_GPI    :  std_logic_vector(GPI_WIDTH   -1 downto 0);
    signal     STM_I_GPO    :  std_logic_vector(GPO_WIDTH   -1 downto 0);
    signal     MRG_I_GPI    :  std_logic_vector(GPI_WIDTH   -1 downto 0);
    signal     MRG_I_GPO    :  std_logic_vector(GPO_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal     N_REPORT     :  REPORT_STATUS_TYPE;
    signal     N_FINISH     :  std_logic;
    signal     OUT_REPORT   :  REPORT_STATUS_TYPE;
    signal     OUT_FINISH   :  std_logic;
    signal     STM_I_REPORT :  REPORT_STATUS_TYPE;
    signal     STM_I_FINISH :  std_logic;
    signal     MRG_I_REPORT :  REPORT_STATUS_VECTOR(MRG_WAYS-1 downto 0);
    signal     MRG_I_FINISH :  std_logic_vector    (MRG_WAYS-1 downto 0);
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
    STM_O: AXI4_STREAM_SLAVE_PLAYER              -- 
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
            ACLK            => CLOCK           , -- In  :
            ARESETn         => ARESETn         , -- In  :
            TDATA           => out_data        , -- In  :
            TSTRB           => out_strb        , -- In  :
            TKEEP           => out_keep        , -- In  :
            TUSER           => out_user        , -- In  :
            TDEST           => out_dest        , -- In  :
            TID             => out_id          , -- In  :
            TLAST           => out_last        , -- In  :
            TVALID          => out_valid       , -- In  :
            TREADY          => out_ready       , -- Out :
            SYNC            => SYNC            , -- I/O :
            GPI             => OUT_GPI         , -- In  :
            GPO             => OUT_GPO         , -- Out :
            REPORT_STATUS   => OUT_REPORT      , -- Out :
            FINISH          => OUT_FINISH        -- Out :
        );                                       --
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    STM_I: AXI4_STREAM_MASTER_PLAYER             -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --
            NAME            => "STM_I"         , --
            OUTPUT_DELAY    => DELAY           , --
            SYNC_PLUG_NUM   => 3               , --
            WIDTH           => STM_I_WIDTH     , --
            SYNC_WIDTH      => SYNC_WIDTH      , --
            GPI_WIDTH       => GPI_WIDTH       , --
            GPO_WIDTH       => GPO_WIDTH       , --
            FINISH_ABORT    => FALSE             --
        )                                        -- 
        port map (                               -- 
            ACLK            => CLOCK           , -- In  :
            ARESETn         => ARESETn         , -- In  :
            TDATA           => stm_i_data      , -- Out :
            TSTRB           => stm_i_strb      , -- Out :
            TKEEP           => stm_i_keep      , -- Out :
            TUSER           => stm_i_user      , -- Out :
            TDEST           => open            , -- Out :
            TID             => open            , -- Out :
            TLAST           => stm_i_last      , -- Out :
            TVALID          => stm_i_valid     , -- Out :
            TREADY          => stm_i_ready     , -- In  :
            SYNC            => SYNC            , -- I/O :
            GPI             => STM_I_GPI       , -- In  :
            GPO             => STM_I_GPO       , -- Out :
            REPORT_STATUS   => STM_I_REPORT    , -- Out :
            FINISH          => STM_I_FINISH      -- Out :
        );                                       --
    process(stm_i_user)
        variable    a_atrb    :  std_logic_vector(ATRB_BITS-1 downto 0);
    begin
        for i in stm_i_ena'range loop
            a_atrb := stm_i_user((i+1)*ATRB_BITS-1 downto i*ATRB_BITS);
            if (a_atrb(0) = '1') then
                stm_i_ena(i) <= '0';
            else
                stm_i_ena(i) <= '1';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I_MASTER:  for i in 0 to MRG_WAYS-1 generate        --
        signal    gpi  : std_logic_vector(GPI_WIDTH-1 downto 0);
        constant  name : string(1 to 7) := string'("MRG_I") & HEX_TO_STRING(i,8);
    begin                                            -- 
        PLAYER: AXI4_STREAM_MASTER_PLAYER            -- 
            generic map (                            -- 
                SCENARIO_FILE   => SCENARIO_FILE   , --
                NAME            => name            , --
                OUTPUT_DELAY    => DELAY           , --
                SYNC_PLUG_NUM   => 4+i             , --
                WIDTH           => MRG_I_WIDTH     , --
                SYNC_WIDTH      => SYNC_WIDTH      , --
                GPI_WIDTH       => GPI_WIDTH       , --
                GPO_WIDTH       => GPO_WIDTH       , --
                FINISH_ABORT    => FALSE             --
            )                                        -- 
            port map (                               -- 
                ACLK            => CLOCK           , -- In  :
                ARESETn         => ARESETn         , -- In  :
                TDATA           => mrg_i_data  (i) , -- Out :
                TSTRB           => open            , -- Out :
                TKEEP           => open            , -- Out :
                TUSER           => mrg_i_user  (i) , -- Out :
                TDEST           => open            , -- Out :
                TID             => open            , -- Out :
                TLAST           => mrg_i_last  (i) , -- Out :
                TVALID          => mrg_i_valid (i) , -- Out :
                TREADY          => mrg_i_ready (i) , -- In  :
                SYNC            => SYNC            , -- I/O :
                GPI             => gpi             , -- In  :
                GPO             => open            , -- Out :
                REPORT_STATUS   => MRG_I_REPORT(i) , -- Out :
                FINISH          => MRG_I_FINISH(i)   -- Out :
            );                                       -- 
        gpi(0)                 <= mrg_i_level(i);
        gpi(gpi'high downto 1) <= (gpi'high downto 1 => '0');
    end generate;
    process (mrg_i_data, mrg_i_user)
        variable    user_atrb :  std_logic_vector(MRG_WORDS*ATRB_BITS-1 downto 0);
        variable    a_atrb    :  std_logic_vector(          ATRB_BITS-1 downto 0);
        variable    i_none    :  std_logic_vector(MRG_WORDS          -1 downto 0);
        variable    i_eblk    :  std_logic;
    begin
        for i in 0 to MRG_WAYS-1 loop
            user_atrb := mrg_i_user(i)(USER_ATRB_HI downto USER_ATRB_LO);
            for n in 0 to MRG_WORDS-1 loop
                a_atrb    := user_atrb((n+1)*ATRB_BITS-1 downto n*ATRB_BITS);
                i_none(n) := a_atrb(0);
                i_eblk    := a_atrb(3);
            end loop;
            mrg_i_word((i+1)*(MRG_WORDS*DATA_BITS)-1 downto i*(MRG_WORDS*DATA_BITS)) <= mrg_i_data(i);
            mrg_i_none((i+1)*(MRG_WORDS          )-1 downto i*(MRG_WORDS          )) <= i_none;
            mrg_i_eblk(i) <= i_eblk;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DUT: Merge_Sorter_Core                       -- 
        generic map (                            -- 
            SORT_ORDER      => SORT_ORDER      , -- 
            MRG_IN_ENABLE   => MRG_IN_ENABLE   , --
            MRG_WAYS        => MRG_WAYS        , --
            MRG_WORDS       => MRG_WORDS       , --
            MRG_FIFO_SIZE   => MRG_FIFO_SIZE   , --
            MRG_LEVEL_SIZE  => MRG_FIFO_SIZE/2 , --
            STM_IN_ENABLE   => STM_IN_ENABLE   , --
            STM_WORDS       => STM_WORDS       , -- 
            STM_FEEDBACK    => STM_FEEDBACK    , -- 
            DATA_BITS       => DATA_BITS       , --
            COMP_HIGH       => COMP_HIGH       , -- 
            COMP_LOW        => COMP_LOW        , --
            COMP_SIGN       => COMP_SIGN         --
        )                                        -- 
        port map (                               -- 
            CLK             => CLOCK           , -- In  :
            RST             => RESET           , -- In  :
            CLR             => CLEAR           , -- In  :
            STM_REQ_VALID   => OUT_GPO(0)      , -- In  :
            STM_REQ_READY   => OUT_GPI(0)      , -- Out :
            STM_RES_VALID   => OUT_GPI(1)      , -- Out :
            STM_RES_READY   => OUT_GPO(1)      , -- In  :
            STM_IN_DATA     => stm_i_data      , -- In  :
            STM_IN_STRB     => stm_i_ena       , -- In  :
            STM_IN_LAST     => stm_i_last      , -- In  :
            STM_IN_VALID    => stm_i_valid     , -- In  :
            STM_IN_READY    => stm_i_ready     , -- Out :
            MRG_REQ_VALID   => OUT_GPO(2)      , -- In  :
            MRG_REQ_READY   => OUT_GPI(2)      , -- Out :
            MRG_RES_VALID   => OUT_GPI(3)      , -- Out :
            MRG_RES_READY   => OUT_GPO(3)      , -- In  :
            MRG_IN_DATA     => mrg_i_word      , -- In  :
            MRG_IN_NONE     => mrg_i_none      , -- In  :
            MRG_IN_EBLK     => mrg_i_eblk      , -- In  :
            MRG_IN_LAST     => mrg_i_last      , -- In  :
            MRG_IN_VALID    => mrg_i_valid     , -- In  :
            MRG_IN_READY    => mrg_i_ready     , -- Out :
            MRG_IN_LEVEL    => mrg_i_level     , -- Out :
            OUT_DATA        => out_data        , -- Out :
            OUT_STRB        => out_ena         , -- Out :
            OUT_LAST        => out_last        , -- Out :
            OUT_VALID       => out_valid       , -- Out :
            OUT_READY       => out_ready         -- In  :
        );                                       --
    process (out_ena)
        variable    user_atrb :  std_logic_vector(MRG_WORDS*ATRB_BITS-1 downto 0);
        variable    a_atrb    :  std_logic_vector(          ATRB_BITS-1 downto 0);
    begin
        for i in 0 to MRG_WORDS-1 loop
            if (out_ena(i) = '1') then
                a_atrb(0) := '0';
                a_atrb(1) := '0';
                a_atrb(2) := '0';
                a_atrb(3) := '0';
            else
                a_atrb(0) := '1';
                a_atrb(1) := '0';
                a_atrb(2) := '1';
                a_atrb(3) := '0';
            end if;
            user_atrb((i+1)*ATRB_BITS-1 downto i*ATRB_BITS) := a_atrb;
        end loop;
        out_user(USER_ATRB_HI downto USER_ATRB_LO) <= user_atrb;
        out_user(USER_INFO_HI downto USER_INFO_LO) <= (USER_INFO_HI downto USER_INFO_LO => '0');
    end process;
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
        WRITE(L,T);                                                     WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                            WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                     WRITELINE(OUTPUT,L);
        WRITE(L,T & "[OUT]"      );                                     WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,OUT_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,OUT_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,OUT_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                     WRITELINE(OUTPUT,L);
        assert (OUT_REPORT.error_count    = 0) 
            report "Simulation complete(error)."    severity FAILURE;
        assert (OUT_REPORT.mismatch_count = 0)
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
entity  Merge_Sorter_Core_Test_Bench_X04_W1_M1_S1_F2 is
    generic (
        NAME            :  STRING  := "TEST_X04_w1_M1_S1_F2";
        SCENARIO_FILE   :  STRING  := "test_x04_w1_m1_s1_f2.snr";
        MRG_WAYS        :  integer := 4;     -- X04
        MRG_WORDS       :  integer := 1;     -- W1
        MRG_FIFO_SIZE   :  integer := 64;    -- 
        MRG_IN_ENABLE   :  boolean := TRUE;  -- M1
        STM_IN_ENABLE   :  boolean := TRUE;  -- S1
        STM_WORDS       :  integer := 1;     -- W1
        STM_FEEDBACK    :  integer := 2;     -- F2
        SORT_ORDER      :  integer := 0;     -- 
        COMP_SIGN       :  boolean := FALSE; --
        FINISH_ABORT    :  boolean := FALSE  --
    );
end     Merge_Sorter_Core_Test_Bench_X04_W1_M1_S1_F2;
architecture Model of Merge_Sorter_Core_Test_Bench_X04_W1_M1_S1_F2 is
begin
    TEST: entity  WORK.Merge_Sorter_Core_Test_Bench
        generic map (
            NAME            => NAME         ,
            SCENARIO_FILE   => SCENARIO_FILE,
            MRG_IN_ENABLE   => MRG_IN_ENABLE,
            MRG_WAYS        => MRG_WAYS     ,
            MRG_WORDS       => MRG_WORDS    ,
            MRG_FIFO_SIZE   => MRG_FIFO_SIZE,
            STM_IN_ENABLE   => STM_IN_ENABLE,
            STM_WORDS       => STM_WORDS    ,
            STM_FEEDBACK    => STM_FEEDBACK ,
            SORT_ORDER      => SORT_ORDER   ,
            COMP_SIGN       => COMP_SIGN    ,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Merge_Sorter_Core_Test_Bench_X04_W1_M1_S0_F0 is
    generic (
        NAME            :  STRING  := "TEST_X04_w1_M1_S0_F0";
        SCENARIO_FILE   :  STRING  := "test_x04_w1_m1_s0_f0.snr";
        MRG_WAYS        :  integer := 4;     -- X04
        MRG_WORDS       :  integer := 1;     -- W1
        MRG_FIFO_SIZE   :  integer := 64;    -- 
        MRG_IN_ENABLE   :  boolean := TRUE;  -- M1
        STM_IN_ENABLE   :  boolean := FALSE; -- S0
        STM_WORDS       :  integer := 1;     -- W1
        STM_FEEDBACK    :  integer := 0;     -- F0
        SORT_ORDER      :  integer := 0;     -- 
        COMP_SIGN       :  boolean := FALSE; --
        FINISH_ABORT    :  boolean := FALSE  --
    );
end     Merge_Sorter_Core_Test_Bench_X04_W1_M1_S0_F0;
architecture Model of Merge_Sorter_Core_Test_Bench_X04_W1_M1_S0_F0 is
begin
    TEST: entity  WORK.Merge_Sorter_Core_Test_Bench
        generic map (
            NAME            => NAME         ,
            SCENARIO_FILE   => SCENARIO_FILE,
            MRG_IN_ENABLE   => MRG_IN_ENABLE,
            MRG_WAYS        => MRG_WAYS     ,
            MRG_WORDS       => MRG_WORDS    ,
            MRG_FIFO_SIZE   => MRG_FIFO_SIZE,
            STM_IN_ENABLE   => STM_IN_ENABLE,
            STM_WORDS       => STM_WORDS    ,
            STM_FEEDBACK    => STM_FEEDBACK ,
            SORT_ORDER      => SORT_ORDER   ,
            COMP_SIGN       => COMP_SIGN    ,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Merge_Sorter_Core_Test_Bench_X04_W1_M0_S1_F0 is
    generic (
        NAME            :  STRING  := "TEST_X04_W1_M0_S1_F0";
        SCENARIO_FILE   :  STRING  := "test_x04_w1_m0_s1_f0.snr";
        MRG_WAYS        :  integer := 4;     -- X04
        MRG_WORDS       :  integer := 1;     -- W1
        MRG_FIFO_SIZE   :  integer := 64;    -- 
        MRG_IN_ENABLE   :  boolean := FALSE; -- M0
        STM_IN_ENABLE   :  boolean := TRUE;  -- S1
        STM_WORDS       :  integer := 1;     -- W1
        STM_FEEDBACK    :  integer := 0;     -- F0
        SORT_ORDER      :  integer := 0;     -- 
        COMP_SIGN       :  boolean := FALSE; --
        FINISH_ABORT    :  boolean := FALSE  --
    );
end     Merge_Sorter_Core_Test_Bench_X04_W1_M0_S1_F0;
architecture Model of Merge_Sorter_Core_Test_Bench_X04_W1_M0_S1_F0 is
begin
    TEST: entity  WORK.Merge_Sorter_Core_Test_Bench
        generic map (
            NAME            => NAME         ,
            SCENARIO_FILE   => SCENARIO_FILE,
            MRG_IN_ENABLE   => MRG_IN_ENABLE,
            MRG_WAYS        => MRG_WAYS     ,
            MRG_WORDS       => MRG_WORDS    ,
            MRG_FIFO_SIZE   => MRG_FIFO_SIZE,
            STM_IN_ENABLE   => STM_IN_ENABLE,
            STM_WORDS       => STM_WORDS    ,
            STM_FEEDBACK    => STM_FEEDBACK ,
            SORT_ORDER      => SORT_ORDER   ,
            COMP_SIGN       => COMP_SIGN    ,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Merge_Sorter_Core_Test_Bench_X04_W1_M0_S1_F1 is
    generic (
        NAME            :  STRING  := "TEST_X04_W1_M0_S1_F1";
        SCENARIO_FILE   :  STRING  := "test_x04_w1_m0_s1_f1.snr";
        MRG_WAYS        :  integer := 4;     -- X04
        MRG_WORDS       :  integer := 1;     -- W1
        MRG_FIFO_SIZE   :  integer := 64;    -- 
        MRG_IN_ENABLE   :  boolean := FALSE; -- M0
        STM_IN_ENABLE   :  boolean := TRUE;  -- S1
        STM_WORDS       :  integer := 1;     -- W1
        STM_FEEDBACK    :  integer := 1;     -- F1
        SORT_ORDER      :  integer := 0;     -- 
        COMP_SIGN       :  boolean := FALSE; --
        FINISH_ABORT    :  boolean := FALSE  --
    );
end     Merge_Sorter_Core_Test_Bench_X04_W1_M0_S1_F1;
architecture Model of Merge_Sorter_Core_Test_Bench_X04_W1_M0_S1_F1 is
begin
    TEST: entity  WORK.Merge_Sorter_Core_Test_Bench
        generic map (
            NAME            => NAME         ,
            SCENARIO_FILE   => SCENARIO_FILE,
            MRG_IN_ENABLE   => MRG_IN_ENABLE,
            MRG_WAYS        => MRG_WAYS     ,
            MRG_WORDS       => MRG_WORDS    ,
            MRG_FIFO_SIZE   => MRG_FIFO_SIZE,
            STM_IN_ENABLE   => STM_IN_ENABLE,
            STM_WORDS       => STM_WORDS    ,
            STM_FEEDBACK    => STM_FEEDBACK ,
            SORT_ORDER      => SORT_ORDER   ,
            COMP_SIGN       => COMP_SIGN    ,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Merge_Sorter_Core_Test_Bench_X04_W1_M0_S1_F2 is
    generic (
        NAME            :  STRING  := "TEST_X04_W1_M0_S1_F2";
        SCENARIO_FILE   :  STRING  := "test_x04_w1_m0_s1_f2.snr";
        MRG_WAYS        :  integer := 4;     -- X04
        MRG_WORDS       :  integer := 1;     -- W1
        MRG_FIFO_SIZE   :  integer := 64;    -- 
        MRG_IN_ENABLE   :  boolean := FALSE; -- M0
        STM_IN_ENABLE   :  boolean := TRUE;  -- S1
        STM_WORDS       :  integer := 1;     -- W1
        STM_FEEDBACK    :  integer := 2;     -- F2
        SORT_ORDER      :  integer := 0;     -- 
        COMP_SIGN       :  boolean := FALSE; --
        FINISH_ABORT    :  boolean := FALSE  --
    );
end     Merge_Sorter_Core_Test_Bench_X04_W1_M0_S1_F2;
architecture Model of Merge_Sorter_Core_Test_Bench_X04_W1_M0_S1_F2 is
begin
    TEST: entity  WORK.Merge_Sorter_Core_Test_Bench
        generic map (
            NAME            => NAME         ,
            SCENARIO_FILE   => SCENARIO_FILE,
            MRG_IN_ENABLE   => MRG_IN_ENABLE,
            MRG_WAYS        => MRG_WAYS     ,
            MRG_WORDS       => MRG_WORDS    ,
            MRG_FIFO_SIZE   => MRG_FIFO_SIZE,
            STM_IN_ENABLE   => STM_IN_ENABLE,
            STM_WORDS       => STM_WORDS    ,
            STM_FEEDBACK    => STM_FEEDBACK ,
            SORT_ORDER      => SORT_ORDER   ,
            COMP_SIGN       => COMP_SIGN    ,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Merge_Sorter_Core_Test_Bench_X04_W2_M1_S0_F0 is
    generic (
        NAME            :  STRING  := "TEST_X04_W2_M1_S0_F0";
        SCENARIO_FILE   :  STRING  := "test_x04_w2_m1_s0_f0.snr";
        MRG_WAYS        :  integer := 4;     -- X04
        MRG_WORDS       :  integer := 2;     -- W1
        MRG_FIFO_SIZE   :  integer := 64;    -- 
        MRG_IN_ENABLE   :  boolean := TRUE;  -- M1
        STM_IN_ENABLE   :  boolean := FALSE; -- S0
        STM_WORDS       :  integer := 2;     -- W1
        STM_FEEDBACK    :  integer := 0;     -- F0
        SORT_ORDER      :  integer := 0;     -- 
        COMP_SIGN       :  boolean := FALSE; --
        FINISH_ABORT    :  boolean := FALSE  --
    );
end     Merge_Sorter_Core_Test_Bench_X04_W2_M1_S0_F0;
architecture Model of Merge_Sorter_Core_Test_Bench_X04_W2_M1_S0_F0 is
begin
    TEST: entity  WORK.Merge_Sorter_Core_Test_Bench
        generic map (
            NAME            => NAME         ,
            SCENARIO_FILE   => SCENARIO_FILE,
            MRG_IN_ENABLE   => MRG_IN_ENABLE,
            MRG_WAYS        => MRG_WAYS     ,
            MRG_WORDS       => MRG_WORDS    ,
            MRG_FIFO_SIZE   => MRG_FIFO_SIZE,
            STM_IN_ENABLE   => STM_IN_ENABLE,
            STM_WORDS       => STM_WORDS    ,
            STM_FEEDBACK    => STM_FEEDBACK ,
            SORT_ORDER      => SORT_ORDER   ,
            COMP_SIGN       => COMP_SIGN    ,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Merge_Sorter_Core_Test_Bench_X04_W2_M0_S1_F0 is
    generic (
        NAME            :  STRING  := "TEST_X04_W2_M0_S1_F0";
        SCENARIO_FILE   :  STRING  := "test_x04_w2_m0_s1_f0.snr";
        MRG_WAYS        :  integer := 4;     -- X04
        MRG_WORDS       :  integer := 2;     -- W1
        MRG_FIFO_SIZE   :  integer := 64;    -- 
        MRG_IN_ENABLE   :  boolean := FALSE; -- M0
        STM_IN_ENABLE   :  boolean := TRUE;  -- S1
        STM_WORDS       :  integer := 2;     -- W1
        STM_FEEDBACK    :  integer := 0;     -- F0
        SORT_ORDER      :  integer := 0;     -- 
        COMP_SIGN       :  boolean := FALSE; --
        FINISH_ABORT    :  boolean := FALSE  --
    );
end     Merge_Sorter_Core_Test_Bench_X04_W2_M0_S1_F0;
architecture Model of Merge_Sorter_Core_Test_Bench_X04_W2_M0_S1_F0 is
begin
    TEST: entity  WORK.Merge_Sorter_Core_Test_Bench
        generic map (
            NAME            => NAME         ,
            SCENARIO_FILE   => SCENARIO_FILE,
            MRG_IN_ENABLE   => MRG_IN_ENABLE,
            MRG_WAYS        => MRG_WAYS     ,
            MRG_WORDS       => MRG_WORDS    ,
            MRG_FIFO_SIZE   => MRG_FIFO_SIZE,
            STM_IN_ENABLE   => STM_IN_ENABLE,
            STM_WORDS       => STM_WORDS    ,
            STM_FEEDBACK    => STM_FEEDBACK ,
            SORT_ORDER      => SORT_ORDER   ,
            COMP_SIGN       => COMP_SIGN    ,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Merge_Sorter_Core_Test_Bench_X04_W2_M0_S1_F1 is
    generic (
        NAME            :  STRING  := "TEST_X04_W2_M0_S1_F1";
        SCENARIO_FILE   :  STRING  := "test_x04_w2_m0_s1_f1.snr";
        MRG_WAYS        :  integer := 4;     -- X04
        MRG_WORDS       :  integer := 2;     -- W1
        MRG_FIFO_SIZE   :  integer := 64;    -- 
        MRG_IN_ENABLE   :  boolean := FALSE; -- M0
        STM_IN_ENABLE   :  boolean := TRUE;  -- S1
        STM_WORDS       :  integer := 2;     -- W1
        STM_FEEDBACK    :  integer := 1;     -- F1
        SORT_ORDER      :  integer := 0;     -- 
        COMP_SIGN       :  boolean := FALSE; --
        FINISH_ABORT    :  boolean := FALSE  --
    );
end     Merge_Sorter_Core_Test_Bench_X04_W2_M0_S1_F1;
architecture Model of Merge_Sorter_Core_Test_Bench_X04_W2_M0_S1_F1 is
begin
    TEST: entity  WORK.Merge_Sorter_Core_Test_Bench
        generic map (
            NAME            => NAME         ,
            SCENARIO_FILE   => SCENARIO_FILE,
            MRG_IN_ENABLE   => MRG_IN_ENABLE,
            MRG_WAYS        => MRG_WAYS     ,
            MRG_WORDS       => MRG_WORDS    ,
            MRG_FIFO_SIZE   => MRG_FIFO_SIZE,
            STM_IN_ENABLE   => STM_IN_ENABLE,
            STM_WORDS       => STM_WORDS    ,
            STM_FEEDBACK    => STM_FEEDBACK ,
            SORT_ORDER      => SORT_ORDER   ,
            COMP_SIGN       => COMP_SIGN    ,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  Merge_Sorter_Core_Test_Bench_X04_W2_M0_S1_F2 is
    generic (
        NAME            :  STRING  := "TEST_X04_W2_M0_S1_F2";
        SCENARIO_FILE   :  STRING  := "test_x04_w2_m0_s1_f2.snr";
        MRG_WAYS        :  integer := 4;     -- X04
        MRG_WORDS       :  integer := 2;     -- W1
        MRG_FIFO_SIZE   :  integer := 64;    -- 
        MRG_IN_ENABLE   :  boolean := FALSE; -- M0
        STM_IN_ENABLE   :  boolean := TRUE;  -- S1
        STM_WORDS       :  integer := 2;     -- W1
        STM_FEEDBACK    :  integer := 2;     -- F2
        SORT_ORDER      :  integer := 0;     -- 
        COMP_SIGN       :  boolean := FALSE; --
        FINISH_ABORT    :  boolean := FALSE  --
    );
end     Merge_Sorter_Core_Test_Bench_X04_W2_M0_S1_F2;
architecture Model of Merge_Sorter_Core_Test_Bench_X04_W2_M0_S1_F2 is
begin
    TEST: entity  WORK.Merge_Sorter_Core_Test_Bench
        generic map (
            NAME            => NAME         ,
            SCENARIO_FILE   => SCENARIO_FILE,
            MRG_IN_ENABLE   => MRG_IN_ENABLE,
            MRG_WAYS        => MRG_WAYS     ,
            MRG_WORDS       => MRG_WORDS    ,
            MRG_FIFO_SIZE   => MRG_FIFO_SIZE,
            STM_IN_ENABLE   => STM_IN_ENABLE,
            STM_WORDS       => STM_WORDS    ,
            STM_FEEDBACK    => STM_FEEDBACK ,
            SORT_ORDER      => SORT_ORDER   ,
            COMP_SIGN       => COMP_SIGN    ,
            FINISH_ABORT    => FINISH_ABORT
        );
end Model;
