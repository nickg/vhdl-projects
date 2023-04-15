-----------------------------------------------------------------------------------
--!     @file    argsort_reader.vhd
--!     @brief   Merge Sorter ArgSort Reader Module :
--!     @version 1.3.0
--!     @date    2021/7/14
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2021 Ichiro Kawazome
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
library Merge_Sorter;
use     Merge_Sorter.Interface;
entity  ArgSort_Reader is
    generic (
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        REG_PARAM       :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
        REQ_ADDR_BITS   :  integer := 32;
        REQ_SIZE_BITS   :  integer := 32;
        BUF_DATA_BITS   :  integer := 64;
        BUF_DEPTH       :  integer := 13;
        MAX_XFER_SIZE   :  integer := 12;
        WORD_INDEX_LO   :  integer :=  0;
        WORD_INDEX_HI   :  integer := 31;
        WORD_COMP_LO    :  integer := 32;
        WORD_COMP_HI    :  integer := 63
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock/Reset Signals.
    -------------------------------------------------------------------------------
        CLK             :  in  std_logic;
        RST             :  in  std_logic;
        CLR             :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Register Interface
    -------------------------------------------------------------------------------
        REG_L           :  in  std_logic_vector(REG_PARAM.BITS     -1 downto 0);
        REG_D           :  in  std_logic_vector(REG_PARAM.BITS     -1 downto 0);
        REG_Q           :  out std_logic_vector(REG_PARAM.BITS     -1 downto 0);
    -------------------------------------------------------------------------------
    -- Transaction Command Request Signals.
    -------------------------------------------------------------------------------
        REQ_VALID       :  out std_logic;
        REQ_ADDR        :  out std_logic_vector(REQ_ADDR_BITS      -1 downto 0);
        REQ_SIZE        :  out std_logic_vector(REQ_SIZE_BITS      -1 downto 0);
        REQ_BUF_PTR     :  out std_logic_vector(BUF_DEPTH          -1 downto 0);
        REQ_MODE        :  out std_logic_vector(REG_PARAM.MODE.BITS-1 downto 0);
        REQ_FIRST       :  out std_logic;
        REQ_LAST        :  out std_logic;
        REQ_NONE        :  out std_logic;
        REQ_READY       :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Transaction Command Acknowledge Signals.
    -------------------------------------------------------------------------------
        ACK_VALID       :  in  std_logic;
        ACK_SIZE        :  in  std_logic_vector(BUF_DEPTH             downto 0);
        ACK_ERROR       :  in  std_logic := '0';
        ACK_NEXT        :  in  std_logic;
        ACK_LAST        :  in  std_logic;
        ACK_STOP        :  in  std_logic;
        ACK_NONE        :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Transfer Status Signals.
    -------------------------------------------------------------------------------
        XFER_BUSY       :  in  std_logic;
        XFER_DONE       :  in  std_logic;
        XFER_ERROR      :  in  std_logic := '0';
    -------------------------------------------------------------------------------
    -- Intake Flow Control Signals.
    -------------------------------------------------------------------------------
        FLOW_READY      :  out std_logic;
        FLOW_PAUSE      :  out std_logic;
        FLOW_STOP       :  out std_logic;
        FLOW_LAST       :  out std_logic;
        FLOW_SIZE       :  out std_logic_vector(BUF_DEPTH             downto 0);
        PUSH_FIN_VALID  :  in  std_logic;
        PUSH_FIN_LAST   :  in  std_logic;
        PUSH_FIN_ERROR  :  in  std_logic := '0';
        PUSH_FIN_SIZE   :  in  std_logic_vector(BUF_DEPTH             downto 0);
        PUSH_BUF_RESET  :  in  std_logic;
        PUSH_BUF_VALID  :  in  std_logic;
        PUSH_BUF_LAST   :  in  std_logic;
        PUSH_BUF_ERROR  :  in  std_logic := '0';
        PUSH_BUF_SIZE   :  in  std_logic_vector(BUF_DEPTH             downto 0);
        PUSH_BUF_READY  :  out std_logic;
    -------------------------------------------------------------------------------
    -- Buffer Interface Signals.
    -------------------------------------------------------------------------------
        BUF_WEN         :  in  std_logic;
        BUF_BEN         :  in  std_logic_vector(BUF_DATA_BITS/8    -1 downto 0);
        BUF_DATA        :  in  std_logic_vector(BUF_DATA_BITS      -1 downto 0);
        BUF_PTR         :  in  std_logic_vector(BUF_DEPTH          -1 downto 0);
    -------------------------------------------------------------------------------
    -- Stream Outlet Signals.
    -------------------------------------------------------------------------------
        STM_DATA        :  out std_logic_vector(WORDS*WORD_BITS    -1 downto 0);
        STM_STRB        :  out std_logic_vector(WORDS              -1 downto 0);
        STM_LAST        :  out std_logic;
        STM_VALID       :  out std_logic;
        STM_READY       :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end ArgSort_Reader;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library Merge_Sorter;
use     Merge_Sorter.Interface;
library PIPEWORK;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_STREAM_INTAKE_CONTROLLER;
use     PIPEWORK.COMPONENTS.SDPRAM;
architecture RTL of ArgSort_Reader is
    -------------------------------------------------------------------------------
    -- データバスのビット数の２のべき乗値を計算する.
    -------------------------------------------------------------------------------
    function CALC_DATA_WIDTH(BITS:integer) return integer is
        variable value : integer;
    begin
        value := 0;
        while (2**(value) < BITS) loop
            value := value + 1;
        end loop;
        return value;
    end function;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    constant  WORD_COMP_BITS        :  integer := WORD_COMP_HI  - WORD_COMP_LO  + 1;
    constant  WORD_INDEX_BITS       :  integer := WORD_INDEX_HI - WORD_INDEX_LO + 1;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    constant  BUF_DATA_WIDTH        :  integer := CALC_DATA_WIDTH(BUF_DATA_BITS);
    constant  BUF_BYTES             :  integer := 2**BUF_DEPTH;
    constant  MAX_XFER_BYTES        :  integer := 2**MAX_XFER_SIZE;
    ------------------------------------------------------------------------------
    -- 入力側のフロー制御用定数.
    ------------------------------------------------------------------------------
    constant  I_FLOW_READY_LEVEL    :  std_logic_vector(BUF_DEPTH downto 0)
                                    := std_logic_vector(to_unsigned(BUF_BYTES-MAX_XFER_BYTES     , BUF_DEPTH+1));
    constant  I_BUF_READY_LEVEL     :  std_logic_vector(BUF_DEPTH downto 0)
                                    := std_logic_vector(to_unsigned(BUF_BYTES-2*(BUF_DATA_BITS/8), BUF_DEPTH+1));
    constant  I_STAT_RESV_NULL      :  std_logic_vector(REG_PARAM.STAT.RESV.BITS-1 downto 0) := (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    signal    reg_load              :  std_logic_vector(REG_PARAM.BITS -1 downto 0);
    signal    reg_wbit              :  std_logic_vector(REG_PARAM.BITS -1 downto 0);
    signal    reg_rbit              :  std_logic_vector(REG_PARAM.BITS -1 downto 0);
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    signal    buf_ren               :  std_logic;
    signal    buf_rptr              :  std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal    buf_rdata             :  std_logic_vector(BUF_DATA_BITS  -1 downto 0);
    signal    buf_we                :  std_logic_vector(BUF_DATA_BITS/8-1 downto 0);
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    signal    comp_data             :  std_logic_vector(WORDS*WORD_COMP_BITS  -1 downto 0);
    signal    comp_strb             :  std_logic_vector(WORDS*WORD_COMP_BITS/8-1 downto 0);
    signal    comp_last             :  std_logic;
    signal    comp_valid            :  std_logic;
    signal    comp_ready            :  std_logic;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    signal    o_reset               :  std_logic;
    signal    o_open_valid          :  std_logic;
    signal    o_close_valid         :  std_logic;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    signal    i_open                :  std_logic;
    signal    i_close_valid         :  std_logic;
begin 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    reg_load <= REG_L;
    reg_wbit <= REG_D;
    REG_Q <= reg_rbit;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    CTRL: PUMP_STREAM_INTAKE_CONTROLLER                      -- 
        generic map (                                        -- 
            I_CLK_RATE          => 1                       , --
            I_REQ_ADDR_VALID    => 1                       , --
            I_REQ_ADDR_BITS     => REQ_ADDR_BITS           , --
            I_REG_ADDR_BITS     => REG_PARAM.ADDR.BITS     , --
            I_REQ_SIZE_VALID    => 1                       , --
            I_REQ_SIZE_BITS     => REQ_SIZE_BITS           , --
            I_REG_SIZE_BITS     => REG_PARAM.SIZE.BITS     , --
            I_REG_MODE_BITS     => REG_PARAM.MODE.BITS     , --
            I_REG_STAT_BITS     => REG_PARAM.STAT.RESV.BITS, --
            I_USE_PUSH_BUF_SIZE => 0                       , --
            I_FIXED_FLOW_OPEN   => 0                       , --
            I_FIXED_POOL_OPEN   => 1                       , --
            O_CLK_RATE          => 1                       , --
            O_DATA_BITS         => WORDS*WORD_COMP_BITS    , --
            O_WORD_BITS         => WORD_COMP_BITS          , --
            BUF_DEPTH           => BUF_DEPTH               , --
            BUF_DATA_BITS       => BUF_DATA_BITS           , --
            I2O_OPEN_INFO_BITS  => 1                       , --
            I2O_CLOSE_INFO_BITS => 1                       , --
            O2I_OPEN_INFO_BITS  => 1                       , --
            O2I_CLOSE_INFO_BITS => 1                       , --
            I2O_DELAY_CYCLE     => 1                         --
        )                                                    -- 
        port map (                                           -- 
        ---------------------------------------------------------------------------
        -- Reset Signals.
        ---------------------------------------------------------------------------
            RST                 => RST                     , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Clock and Clock Enable.
        ---------------------------------------------------------------------------
            I_CLK               => CLK                     , --  In  :
            I_CLR               => CLR                     , --  In  :
            I_CKE               => '1'                     , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Control Register Interface.
        ---------------------------------------------------------------------------
            I_ADDR_L            => reg_load(REG_PARAM.ADDR.HI      downto REG_PARAM.ADDR.LO     ), --  In  :
            I_ADDR_D            => reg_wbit(REG_PARAM.ADDR.HI      downto REG_PARAM.ADDR.LO     ), --  In  :
            I_ADDR_Q            => reg_rbit(REG_PARAM.ADDR.HI      downto REG_PARAM.ADDR.LO     ), --  Out :
            I_SIZE_L            => reg_load(REG_PARAM.SIZE.HI      downto REG_PARAM.SIZE.LO     ), --  In  :
            I_SIZE_D            => reg_wbit(REG_PARAM.SIZE.HI      downto REG_PARAM.SIZE.LO     ), --  In  :
            I_SIZE_Q            => reg_rbit(REG_PARAM.SIZE.HI      downto REG_PARAM.SIZE.LO     ), --  Out :
            I_MODE_L            => reg_load(REG_PARAM.MODE.HI      downto REG_PARAM.MODE.LO     ), --  In  :
            I_MODE_D            => reg_wbit(REG_PARAM.MODE.HI      downto REG_PARAM.MODE.LO     ), --  In  :
            I_MODE_Q            => reg_rbit(REG_PARAM.MODE.HI      downto REG_PARAM.MODE.LO     ), --  Out :
            I_STAT_L            => reg_load(REG_PARAM.STAT.RESV.HI downto REG_PARAM.STAT.RESV.LO), --  In  :
            I_STAT_D            => reg_wbit(REG_PARAM.STAT.RESV.HI downto REG_PARAM.STAT.RESV.LO), --  In  :
            I_STAT_Q            => reg_rbit(REG_PARAM.STAT.RESV.HI downto REG_PARAM.STAT.RESV.LO), --  Out :
            I_STAT_I            => I_STAT_RESV_NULL                    , --  In  :
            I_RESET_L           => reg_load(REG_PARAM.CTRL.RESET.POS)  , --  In  :
            I_RESET_D           => reg_wbit(REG_PARAM.CTRL.RESET.POS)  , --  In  :
            I_RESET_Q           => reg_rbit(REG_PARAM.CTRL.RESET.POS)  , --  Out :
            I_START_L           => reg_load(REG_PARAM.CTRL.START.POS)  , --  In  :
            I_START_D           => reg_wbit(REG_PARAM.CTRL.START.POS)  , --  In  :
            I_START_Q           => reg_rbit(REG_PARAM.CTRL.START.POS)  , --  Out :
            I_STOP_L            => reg_load(REG_PARAM.CTRL.STOP.POS )  , --  In  :
            I_STOP_D            => reg_wbit(REG_PARAM.CTRL.STOP.POS )  , --  In  :
            I_STOP_Q            => reg_rbit(REG_PARAM.CTRL.STOP.POS )  , --  Out :
            I_PAUSE_L           => reg_load(REG_PARAM.CTRL.PAUSE.POS)  , --  In  :
            I_PAUSE_D           => reg_wbit(REG_PARAM.CTRL.PAUSE.POS)  , --  In  :
            I_PAUSE_Q           => reg_rbit(REG_PARAM.CTRL.PAUSE.POS)  , --  Out :
            I_FIRST_L           => reg_load(REG_PARAM.CTRL.FIRST.POS)  , --  In  :
            I_FIRST_D           => reg_wbit(REG_PARAM.CTRL.FIRST.POS)  , --  In  :
            I_FIRST_Q           => reg_rbit(REG_PARAM.CTRL.FIRST.POS)  , --  Out :
            I_LAST_L            => reg_load(REG_PARAM.CTRL.LAST.POS )  , --  In  :
            I_LAST_D            => reg_wbit(REG_PARAM.CTRL.LAST.POS )  , --  In  :
            I_LAST_Q            => reg_rbit(REG_PARAM.CTRL.LAST.POS )  , --  Out :
            I_DONE_EN_L         => reg_load(REG_PARAM.CTRL.DONE.POS )  , --  In  :
            I_DONE_EN_D         => reg_wbit(REG_PARAM.CTRL.DONE.POS )  , --  In  :
            I_DONE_EN_Q         => reg_rbit(REG_PARAM.CTRL.DONE.POS )  , --  Out :
            I_DONE_ST_L         => reg_load(REG_PARAM.STAT.DONE.POS )  , --  In  :
            I_DONE_ST_D         => reg_wbit(REG_PARAM.STAT.DONE.POS )  , --  In  :
            I_DONE_ST_Q         => reg_rbit(REG_PARAM.STAT.DONE.POS )  , --  Out :
            I_ERR_ST_L          => reg_load(REG_PARAM.STAT.ERROR.POS)  , --  In  :
            I_ERR_ST_D          => reg_wbit(REG_PARAM.STAT.ERROR.POS)  , --  In  :
            I_ERR_ST_Q          => reg_rbit(REG_PARAM.STAT.ERROR.POS)  , --  Out :
            I_CLOSE_ST_L        => reg_load(REG_PARAM.STAT.CLOSE.POS)  , --  In  :
            I_CLOSE_ST_D        => reg_wbit(REG_PARAM.STAT.CLOSE.POS)  , --  In  :
            I_CLOSE_ST_Q        => reg_rbit(REG_PARAM.STAT.CLOSE.POS)  , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Configuration Signals.
        ---------------------------------------------------------------------------
            I_ADDR_FIX          => '0'                                 , --  In  :
            I_BUF_READY_LEVEL   => I_BUF_READY_LEVEL                   , --  In  :
            I_FLOW_READY_LEVEL  => I_FLOW_READY_LEVEL                  , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Transaction Command Request Signals.
        ---------------------------------------------------------------------------
            I_REQ_VALID         => REQ_VALID                           , --  Out :
            I_REQ_ADDR          => REQ_ADDR                            , --  Out :
            I_REQ_SIZE          => REQ_SIZE                            , --  Out :
            I_REQ_BUF_PTR       => REQ_BUF_PTR                         , --  Out :
            I_REQ_FIRST         => REQ_FIRST                           , --  Out :
            I_REQ_LAST          => REQ_LAST                            , --  Out :
            I_REQ_NONE          => REQ_NONE                            , --  Out :
            I_REQ_READY         => REQ_READY                           , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Transaction Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            I_ACK_VALID         => ACK_VALID                           , --  In  :
            I_ACK_SIZE          => ACK_SIZE                            , --  In  :
            I_ACK_ERROR         => ACK_ERROR                           , --  In  :
            I_ACK_NEXT          => ACK_NEXT                            , --  In  :
            I_ACK_LAST          => ACK_LAST                            , --  In  :
            I_ACK_STOP          => ACK_STOP                            , --  In  :
            I_ACK_NONE          => ACK_NONE                            , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Transfer Status Signals.
        ---------------------------------------------------------------------------
            I_XFER_BUSY         => XFER_BUSY                           , --  In  :
            I_XFER_DONE         => XFER_DONE                           , --  In  :
            I_XFER_ERROR        => XFER_ERROR                          , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Flow Control Signals.
        ---------------------------------------------------------------------------
            I_FLOW_READY        => FLOW_READY                          , --  Out :
            I_FLOW_PAUSE        => FLOW_PAUSE                          , --  Out :
            I_FLOW_STOP         => FLOW_STOP                           , --  Out :
            I_FLOW_LAST         => FLOW_LAST                           , --  Out :
            I_FLOW_SIZE         => FLOW_SIZE                           , --  Out :
            I_PUSH_FIN_VALID    => PUSH_FIN_VALID                      , --  In  :
            I_PUSH_FIN_LAST     => PUSH_FIN_LAST                       , --  In  :
            I_PUSH_FIN_ERROR    => PUSH_FIN_ERROR                      , --  In  :
            I_PUSH_FIN_SIZE     => PUSH_FIN_SIZE                       , --  In  :
            I_PUSH_BUF_RESET    => PUSH_BUF_RESET                      , --  In  :
            I_PUSH_BUF_VALID    => PUSH_BUF_VALID                      , --  In  :
            I_PUSH_BUF_LAST     => PUSH_BUF_LAST                       , --  In  :
            I_PUSH_BUF_ERROR    => PUSH_BUF_ERROR                      , --  In  :
            I_PUSH_BUF_SIZE     => PUSH_BUF_SIZE                       , --  In  :
            I_PUSH_BUF_READY    => PUSH_BUF_READY                      , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Status.
        ---------------------------------------------------------------------------
            I_OPEN              => i_open                              , --  Out :
            I_TRAN_BUSY         => open                                , --  Out :
            I_TRAN_DONE         => open                                , --  Out :
            I_TRAN_ERROR        => open                                , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Open/Close Infomation Interface
        ---------------------------------------------------------------------------
            I_I2O_OPEN_INFO     => "0"                                 , --  In  :
            I_I2O_CLOSE_INFO    => "0"                                 , --  In  :
            I_O2I_OPEN_INFO     => open                                , --  Out :
            I_O2I_OPEN_VALID    => open                                , --  Out :
            I_O2I_CLOSE_INFO    => open                                , --  Out :
            I_O2I_CLOSE_VALID   => i_close_valid                       , --  Out :
            I_O2I_STOP          => open                                , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Clock and Clock Enable.
        ---------------------------------------------------------------------------
            O_CLK               => CLK                                 , --  In  :
            O_CLR               => CLR                                 , --  In  :
            O_CKE               => '1'                                 , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Stream Interface.
        ---------------------------------------------------------------------------
            O_DATA              => comp_data                           , --  Out :
            O_STRB              => comp_strb                           , --  Out :
            O_LAST              => comp_last                           , --  Out :
            O_VALID             => comp_valid                          , --  Out :
            O_READY             => comp_ready                          , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Status.
        ---------------------------------------------------------------------------
            O_OPEN              => open                                , --  Out :
            O_DONE              => open                                , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Open/Close Infomation Interface
        ---------------------------------------------------------------------------
            O_O2I_STOP          => '0'                                 , --  In  :
            O_O2I_OPEN_INFO     => "0"                                 , --  In  :
            O_O2I_OPEN_VALID    => o_open_valid                        , --  In  :
            O_O2I_CLOSE_INFO    => "0"                                 , --  In  :
            O_O2I_CLOSE_VALID   => o_close_valid                       , --  In  :
            O_I2O_RESET         => o_reset                             , --  Out :
            O_I2O_STOP          => open                                , --  Out :
            O_I2O_ERROR         => open                                , --  Out :
            O_I2O_OPEN_INFO     => open                                , --  Out :
            O_I2O_OPEN_VALID    => o_open_valid                        , --  Out :
            O_I2O_CLOSE_INFO    => open                                , --  Out :
            O_I2O_CLOSE_VALID   => o_close_valid                       , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Buffer Read Interface.
        ---------------------------------------------------------------------------
            BUF_REN             => buf_ren                             , --  Out :
            BUF_PTR             => buf_rptr                            , --  Out :
            BUF_DATA            => buf_rdata                             --  In  :
        );                                                               --
    REQ_MODE <= reg_rbit(REG_PARAM.MODE.HI downto REG_PARAM.MODE.LO);    -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    STATUS: block
        type    I_STATE_TYPE  is (I_IDLE, I_RUN, I_TAR);
        signal  i_state       :  I_STATE_TYPE;
    begin
        process (CLK, RST) begin
            if (RST = '1') then
                    i_state <= I_IDLE;
            elsif (CLK'event and CLK = '1') then
                if    (CLR = '1' or reg_rbit(REG_PARAM.CTRL.RESET.POS) = '1') then
                    i_state <= I_IDLE;
                else
                    case i_state is
                        when I_IDLE =>
                            if    (i_open = '1' and i_close_valid = '1') then
                                i_state <= I_TAR;
                            elsif (i_open = '1' and i_close_valid = '0') then
                                i_state <= I_RUN;
                            else
                                i_state <= I_IDLE;
                            end if;
                        when I_RUN =>
                            if    (i_open = '1' and i_close_valid = '1') then
                                i_state <= I_TAR;
                            elsif (i_open = '1' and i_close_valid = '0') then
                                i_state <= I_RUN;
                            elsif (i_open = '0' and i_close_valid = '1') then
                                i_state <= I_IDLE;
                            else
                                i_state <= I_RUN;
                            end if;
                        when I_TAR =>
                            if (i_open = '0') then
                                i_state <= I_IDLE;
                            else
                                i_state <= I_TAR;
                            end if;
                        when others => 
                                i_state <= I_IDLE;
                    end case;
                end if;
            end if;
        end process;
        BUSY  <= '1' when ((i_state = I_IDLE and i_open = '1') or
                           (i_state = I_RUN                  ) or
                           (i_state = I_TAR                  )) else '0';
        DONE  <= '1' when ((i_state = I_RUN  and i_open = '0' and i_close_valid = '1') or
                           (i_state = I_TAR  and i_open = '0')) else '0';
        reg_rbit(REG_PARAM.CTRL.EBLK.POS) <= '0';
    end block;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    RAM: SDPRAM 
        generic map(
            DEPTH       => BUF_DEPTH+3         ,
            RWIDTH      => BUF_DATA_WIDTH      , --
            WWIDTH      => BUF_DATA_WIDTH      , --
            WEBIT       => BUF_DATA_WIDTH-3    , --
            ID          => 0                     -- 
        )                                        -- 
        port map (                               -- 
            WCLK        => CLK                 , -- In  :
            WE          => buf_we              , -- In  :
            WADDR       => BUF_PTR (BUF_DEPTH-1 downto BUF_DATA_WIDTH-3), -- In  :
            WDATA       => BUF_DATA            , -- In  :
            RCLK        => CLK                 , -- In  :
            RADDR       => buf_rptr(BUF_DEPTH-1 downto BUF_DATA_WIDTH-3), -- In  :
            RDATA       => buf_rdata             -- Out :
        );
    buf_we <= BUF_BEN when (BUF_WEN = '1') else (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    STM_OUT: for i in 0 to WORDS-1 generate
        signal    o_word         :  std_logic_vector(WORD_BITS-1 downto 0);
        signal    index          :  unsigned(WORD_INDEX_BITS-1 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    index <= to_unsigned(i, index'length);
            elsif (CLK'event and CLK = '1') then
                if    (CLR = '1' or o_reset = '1' or o_open_valid = '1') then
                    index <= to_unsigned(i, index'length);
                elsif (comp_valid = '1' and comp_ready = '1') then
                    index <= index + WORDS;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_word(WORD_COMP_HI  downto WORD_COMP_LO ) <= comp_data((i+1)*WORD_COMP_BITS-1 downto i*WORD_COMP_BITS);
        o_word(WORD_INDEX_HI downto WORD_INDEX_LO) <= std_logic_vector(index);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        STM_DATA((i+1)*WORD_BITS-1 downto i*WORD_BITS) <= o_word;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        STM_STRB(i) <= comp_strb(i*(WORD_COMP_BITS/8)) when (i > 0) else '1';
    end generate;
    STM_LAST   <= comp_last;
    STM_VALID  <= comp_valid;
    comp_ready <= STM_READY;
end RTL;
