-----------------------------------------------------------------------------------
--!     @file    image_stream_models.vhd                                         --
--!     @brief   Image Stream Model Component Package                            --
--!     @version 1.8.0                                                           --
--!     @date    2019/01/22                                                      --
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>                     --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--                                                                               --
--      Copyright (C) 2019 Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>           --
--      All rights reserved.                                                     --
--                                                                               --
--      Redistribution and use in source and binary forms, with or without       --
--      modification, are permitted provided that the following conditions       --
--      are met:                                                                 --
--                                                                               --
--        1. Redistributions of source code must retain the above copyright      --
--           notice, this list of conditions and the following disclaimer.       --
--                                                                               --
--        2. Redistributions in binary form must reproduce the above copyright   --
--           notice, this list of conditions and the following disclaimer in     --
--           the documentation and/or other materials provided with the          --
--           distribution.                                                       --
--                                                                               --
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT    --
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,    --
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT         --
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,    --
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY    --
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT      --
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE    --
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.     --
--                                                                               --
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
--! @brief Image Stream Model Component Package                                  --
-----------------------------------------------------------------------------------
package IMAGE_STREAM_MODELS is
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_MASTER_PLAYER                                            --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_MASTER_PLAYER
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
        DATA            : inout std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
        VALID           : inout std_logic;
        READY           : in    std_logic;
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
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_SLAVE_PLAYER                                             --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_SLAVE_PLAYER
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
end component;
end IMAGE_STREAM_MODELS;
