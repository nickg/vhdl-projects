-----------------------------------------------------------------------------------
--!     @file    axi4_stream_slave player.vhd
--!     @brief   AXI4-Stream Slave Dummy Plug Player.
--!     @version 1.6.1
--!     @date    2016/3/15
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2016 Ichiro Kawazome
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
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_SIG_VECTOR;
-----------------------------------------------------------------------------------
--! @brief   AXI4_STREAM_SLAVE_PLAYER :
-----------------------------------------------------------------------------------
entity  AXI4_STREAM_SLAVE_PLAYER is
    -------------------------------------------------------------------------------
    -- ????????????????????????.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief ?????????????????????????????????.
                          STRING;
        NAME            : --! @brief ????????????.
                          STRING;
        OUTPUT_DELAY    : --! @brief ????????????????????????
                          time;
        SYNC_PLUG_NUM   : --! @brief ???????????????????????????????????????.
                          SYNC_PLUG_NUM_TYPE := 1;
        WIDTH           : --! @brief AXI4 IS WIDTH :
                          AXI4_STREAM_SIGNAL_WIDTH_TYPE;
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
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        ---------------------------------------------------------------------------
        -- AXI4-Stream????????????.
        ---------------------------------------------------------------------------
        TDATA           : in    std_logic_vector(WIDTH.DATA  -1 downto 0);
        TSTRB           : in    std_logic_vector(WIDTH.DATA/8-1 downto 0);
        TKEEP           : in    std_logic_vector(WIDTH.DATA/8-1 downto 0);
        TUSER           : in    std_logic_vector(WIDTH.USER  -1 downto 0);
        TDEST           : in    std_logic_vector(WIDTH.DEST  -1 downto 0);
        TID             : in    std_logic_vector(WIDTH.ID    -1 downto 0);
        TLAST           : in    std_logic;
        TVALID          : in    std_logic;
        TREADY          : inout std_logic;
        ---------------------------------------------------------------------------
        -- ?????????????????????.
        ---------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
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
end AXI4_STREAM_SLAVE_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_CORE.all;
use     DUMMY_PLUG.SYNC.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4-Stream Slave Dummy Plug Player.
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_STREAM_SLAVE_PLAYER is
    -------------------------------------------------------------------------------
    --! SYNC ????????????
    -------------------------------------------------------------------------------
    signal    sync_rst          : std_logic := '0';
    signal    sync_clr          : std_logic := '0';
    signal    sync_req          : SYNC_REQ_VECTOR(SYNC'range);
    signal    sync_ack          : SYNC_ACK_VECTOR(SYNC'range);
    signal    sync_debug        : boolean   := FALSE;
begin
    T: AXI4_STREAM_PLAYER
        ---------------------------------------------------------------------------
        -- ????????????????????????.
        ---------------------------------------------------------------------------
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => NAME            , 
            FULL_NAME       => NAME            ,
            MASTER          => FALSE           ,
            SLAVE           => TRUE            ,
            OUTPUT_DELAY    => OUTPUT_DELAY    ,
            WIDTH           => WIDTH           ,
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
            ACLK            => ACLK            , -- In :
            ARESETn         => ARESETn         , -- In :
            -----------------------------------------------------------------------
            -- AXI4-Stream????????????.
            -----------------------------------------------------------------------
            TDATA_I         => TDATA           , -- In :
            TDATA_O         => open            , -- Out:
            TSTRB_I         => TSTRB           , -- In :
            TSTRB_O         => open            , -- Out:
            TKEEP_I         => TKEEP           , -- In :
            TKEEP_O         => open            , -- Out:
            TUSER_I         => TUSER           , -- In :
            TUSER_O         => open            , -- Out:
            TDEST_I         => TDEST           , -- In :
            TDEST_O         => open            , -- Out:
            TID_I           => TID             , -- In :
            TID_O           => open            , -- Out:
            TLAST_I         => TLAST           , -- In :
            TLAST_O         => open            , -- Out:
            TVALID_I        => TVALID          , -- In :
            TVALID_O        => open            , -- Out:
            TREADY_I        => TREADY          , -- In :
            TREADY_O        => TREADY          , -- Out:
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
                CLK      => ACLK                ,  -- In :
                RST      => sync_rst            ,  -- In :
                CLR      => sync_clr            ,  -- In :
                DEBUG    => sync_debug          ,  -- In :
                SYNC     => SYNC(i)             ,  -- I/O:
                REQ      => sync_req(i)         ,  -- In :
                ACK      => sync_ack(i)            -- Out:
            );
    end generate;
    sync_rst <= '0' when (ARESETn = '1') else '1';
    sync_clr <= '0';
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
