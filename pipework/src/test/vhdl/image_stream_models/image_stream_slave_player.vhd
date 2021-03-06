-----------------------------------------------------------------------------------
--!     @file    image_stream_slave_player.vhd
--!     @brief   Image Stream Slave Dummy Plug Player.
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
--! @brief   IMAGE_STREAM_SLAVE_PLAYER :
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_SLAVE_PLAYER is
    -------------------------------------------------------------------------------
    -- ????????????????????????.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief ?????????????????????????????????.
                          STRING;
        NAME            : --! @brief ????????????.
                          STRING;
        PARAM           : --! @brief Image Stream Parameter
                          IMAGE_STREAM_PARAM_TYPE;
        OUTPUT_DELAY    : --! @brief ????????????????????????
                          time;
        SYNC_PLUG_NUM   : --! @brief ???????????????????????????????????????.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_WIDTH      : --! @brief ??????????????????????????????.
                          integer :=  1;
        GPI_WIDTH       : --! @brief GPI(General Purpose Input)?????????????????????.
                          integer := 8;
        GPO_WIDTH       : --! @brief GPO(General Purpose Output)?????????????????????.
                          integer := 8;
        FINISH_ABORT    : --! @brief FINISH ???????????????????????????????????????????????????
                          --!        ??????????????????????????????????????????????????????.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- ???????????????????????????.
    -------------------------------------------------------------------------------
    port(
        ---------------------------------------------------------------------------
        -- ???????????????????????????.
        ---------------------------------------------------------------------------
        CLK             : in    std_logic;
        RST             : in    std_logic;
        ---------------------------------------------------------------------------
        -- Image Stream Signals
        ---------------------------------------------------------------------------
        DATA            : in    std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
        VALID           : in    std_logic;
        READY           : inout std_logic;
        ---------------------------------------------------------------------------
        -- ?????????????????????.
        ---------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH-1 downto 0);
        --------------------------------------------------------------------------
        -- General Purpose Input ??????
        --------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH-1 downto 0) := (others => '0');
        --------------------------------------------------------------------------
        -- General Purpose Output ??????
        --------------------------------------------------------------------------
        GPO             : out   std_logic_vector(GPO_WIDTH-1 downto 0);
        --------------------------------------------------------------------------
        -- ?????????????????????????????????.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        -- ??????????????????????????????????????????.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end IMAGE_STREAM_SLAVE_PLAYER;
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
architecture MODEL of IMAGE_STREAM_SLAVE_PLAYER is
    -------------------------------------------------------------------------------
    --! SYNC ????????????
    -------------------------------------------------------------------------------
    signal    sync_rst          : std_logic := '0';
    signal    sync_clr          : std_logic := '0';
    signal    sync_req          : SYNC_REQ_VECTOR(SYNC'range);
    signal    sync_ack          : SYNC_ACK_VECTOR(SYNC'range);
    signal    sync_debug        : boolean   := FALSE;
    -------------------------------------------------------------------------------
    --! IMAGE_STREAM_PLAYER ??????????????????????????????
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
        -- ????????????????????????.
        ---------------------------------------------------------------------------
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => NAME            , 
            FULL_NAME       => NAME            ,
            MASTER          => FALSE           ,
            SLAVE           => TRUE            ,
            PARAM           => PARAM           ,
            OUTPUT_DELAY    => OUTPUT_DELAY    ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FINISH_ABORT
        )
        ---------------------------------------------------------------------------
        -- ???????????????????????????.
        ---------------------------------------------------------------------------
        port map(
            -----------------------------------------------------------------------
            -- ???????????????????????????.
            -----------------------------------------------------------------------
            CLK             => CLK             , -- In :
            RST             => RST             , -- In :
            -----------------------------------------------------------------------
            -- AXI4-Stream????????????.
            -----------------------------------------------------------------------
            DATA_I          => DATA            , -- In :
            DATA_O          => open            , -- Out:
            VALID_I         => VALID           , -- In :
            VALID_O         => open            , -- Out:
            READY_I         => READY           , -- In :
            READY_O         => READY           , -- Out:
            -----------------------------------------------------------------------
            -- ?????????????????????.
            -----------------------------------------------------------------------
            SYNC_REQ        => sync_req        , -- Out:
            SYNC_ACK        => sync_ack        , -- In :
            -----------------------------------------------------------------------
            -- General Purpose Input ??????
            -----------------------------------------------------------------------
            GPI             => GPI             , -- In :
            -----------------------------------------------------------------------
            -- General Purpose Output ??????
            -----------------------------------------------------------------------
            GPO             => GPO             , -- Out:
            -----------------------------------------------------------------------
            -- ?????????????????????????????????.
            -----------------------------------------------------------------------
            REPORT_STATUS   => REPORT_STATUS   , -- Out:
            -----------------------------------------------------------------------
            -- ??????????????????????????????????????????.
            -----------------------------------------------------------------------
            FINISH          => FINISH            -- Out:
        );
    -------------------------------------------------------------------------------
    -- ????????????
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
