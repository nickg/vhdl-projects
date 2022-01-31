-----------------------------------------------------------------------------------
--!     @file    image_stream_master_player.vhd
--!     @brief   Image Stream Master Dummy Plug Player.
--!     @version 1.8.0
--!     @date    2019/1/29
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
library DUMMY_PLUG;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_SIG_VECTOR;
-----------------------------------------------------------------------------------
--! @brief   IMAGE_STREAM_MASTER_PLAYER :
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_MASTER_PLAYER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        PARAM           : --! @brief Image Stream Parameter
                          IMAGE_STREAM_PARAM_TYPE;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                          integer := 8;
        GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                          integer := 8;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
        CLK             : in    std_logic;
        RST             : in    std_logic;
        ---------------------------------------------------------------------------
        -- Image Stream Signals
        ---------------------------------------------------------------------------
        DATA            : inout std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
        VALID           : inout std_logic;
        READY           : in    std_logic;
        ---------------------------------------------------------------------------
        -- シンクロ用信号.
        ---------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH-1 downto 0);
        --------------------------------------------------------------------------
        -- General Purpose Input 信号
        --------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH-1 downto 0) := (others => '0');
        --------------------------------------------------------------------------
        -- General Purpose Output 信号
        --------------------------------------------------------------------------
        GPO             : out   std_logic_vector(GPO_WIDTH-1 downto 0);
        --------------------------------------------------------------------------
        -- レポートステータス出力.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        -- シミュレーション終了通知信号.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end IMAGE_STREAM_MASTER_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.SYNC.all;
-----------------------------------------------------------------------------------
--! @brief   Image Stream Master Dummy Plug Player.
-----------------------------------------------------------------------------------
architecture MODEL of IMAGE_STREAM_MASTER_PLAYER is
    -------------------------------------------------------------------------------
    --! SYNC 制御信号
    -------------------------------------------------------------------------------
    signal    sync_rst          : std_logic := '0';
    signal    sync_clr          : std_logic := '0';
    signal    sync_req          : SYNC_REQ_VECTOR(SYNC'range);
    signal    sync_ack          : SYNC_ACK_VECTOR(SYNC'range);
    signal    sync_debug        : boolean   := FALSE;
    -------------------------------------------------------------------------------
    --! IMAGE_STREAM_PLAYER のコンポーネント宣言
    -------------------------------------------------------------------------------
    component IMAGE_STREAM_PLAYER is
        generic (
            SCENARIO_FILE   : STRING;
            NAME            : STRING;
            FULL_NAME       : STRING;
            MASTER          : boolean;
            SLAVE           : boolean;
            PARAM           : IMAGE_STREAM_PARAM_TYPE;
            OUTPUT_DELAY    : time;
            SYNC_WIDTH      : integer;
            GPI_WIDTH       : integer;
            GPO_WIDTH       : integer;
            FINISH_ABORT    : boolean := true
        );
        port(
            CLK             : in    std_logic;
            RST             : in    std_logic;
            DATA_I          : in    std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
            DATA_O          : out   std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
            VALID_I         : in    std_logic;
            VALID_O         : out   std_logic;
            READY_I         : in    std_logic;
            READY_O         : out   std_logic;
            SYNC_REQ        : out   SYNC_REQ_VECTOR (SYNC_WIDTH-1 downto 0);
            SYNC_ACK        : in    SYNC_ACK_VECTOR (SYNC_WIDTH-1 downto 0);
            GPI             : in    std_logic_vector(GPI_WIDTH -1 downto 0) := (others => '0');
            GPO             : out   std_logic_vector(GPO_WIDTH -1 downto 0);
            REPORT_STATUS   : out   REPORT_STATUS_TYPE;
            FINISH          : out   std_logic
        );
    end component;
begin
    T: IMAGE_STREAM_PLAYER
        ---------------------------------------------------------------------------
        -- ジェネリック変数.
        ---------------------------------------------------------------------------
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => NAME            , 
            FULL_NAME       => NAME            ,
            MASTER          => TRUE            ,
            SLAVE           => FALSE           ,
            PARAM           => PARAM           ,
            OUTPUT_DELAY    => OUTPUT_DELAY    ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FINISH_ABORT
        )
        ---------------------------------------------------------------------------
        -- 入出力ポートの定義.
        ---------------------------------------------------------------------------
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            CLK             => CLK             , -- In :
            RST             => RST             , -- In :
            -----------------------------------------------------------------------
            -- AXI4-Streamシグナル.
            -----------------------------------------------------------------------
            DATA_I          => DATA            , -- In :
            DATA_O          => DATA            , -- Out:
            VALID_I         => VALID           , -- In :
            VALID_O         => VALID           , -- Out:
            READY_I         => READY           , -- In :
            READY_O         => open            , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号.
            -----------------------------------------------------------------------
            SYNC_REQ        => sync_req        , -- Out:
            SYNC_ACK        => sync_ack        , -- In :
            -----------------------------------------------------------------------
            -- General Purpose Input 信号
            -----------------------------------------------------------------------
            GPI             => GPI             , -- In :
            -----------------------------------------------------------------------
            -- General Purpose Output 信号
            -----------------------------------------------------------------------
            GPO             => GPO             , -- Out:
            -----------------------------------------------------------------------
            -- レポートステータス出力.
            -----------------------------------------------------------------------
            REPORT_STATUS   => REPORT_STATUS   , -- Out:
            -----------------------------------------------------------------------
            -- シミュレーション終了通知信号.
            -----------------------------------------------------------------------
            FINISH          => FINISH            -- Out:
        );
    -------------------------------------------------------------------------------
    -- 同期回路
    -------------------------------------------------------------------------------
    SYNC_DRIVER: for i in SYNC'range generate
        UNIT: SYNC_SIG_DRIVER
            generic map (
                NAME     => string'("MASTER:SYNC"),
                PLUG_NUM => SYNC_PLUG_NUM
            )
            port map (
                CLK      => CLK                 ,  -- In :
                RST      => sync_rst            ,  -- In :
                CLR      => sync_clr            ,  -- In :
                DEBUG    => sync_debug          ,  -- In :
                SYNC     => SYNC(i)             ,  -- I/O:
                REQ      => sync_req(i)         ,  -- In :
                ACK      => sync_ack(i)            -- Out:
            );
    end generate;
    sync_rst <= '0' when (RST = '0') else '1';
    sync_clr <= '0';
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
