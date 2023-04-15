-----------------------------------------------------------------------------------
--!     @file    merge_reader.vhd
--!     @brief   Merge Sorter Merge Reader Module :
--!     @version 1.3.0
--!     @date    2021/7/15
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
entity  Merge_Reader is
    generic (
        CHANNEL         :  integer :=  0;
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        REG_PARAM       :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
        REQ_ADDR_BITS   :  integer := 32;
        REQ_SIZE_BITS   :  integer := 32;
        BUF_DATA_BITS   :  integer := 64;
        BUF_DEPTH       :  integer := 13;
        MAX_XFER_SIZE   :  integer := 12;
        ARB_NODE_NUM    :  integer :=  4;
        ARB_PIPELINE    :  integer :=  0
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
        ACK_SIZE        :  in  std_logic_vector(BUF_DEPTH         downto 0);
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
        FLOW_SIZE       :  out std_logic_vector(BUF_DEPTH         downto 0);
        PUSH_FIN_VALID  :  in  std_logic;
        PUSH_FIN_LAST   :  in  std_logic;
        PUSH_FIN_ERROR  :  in  std_logic := '0';
        PUSH_FIN_SIZE   :  in  std_logic_vector(BUF_DEPTH         downto 0);
        PUSH_BUF_RESET  :  in  std_logic := '0';
        PUSH_BUF_VALID  :  in  std_logic := '0';
        PUSH_BUF_LAST   :  in  std_logic;
        PUSH_BUF_ERROR  :  in  std_logic := '0';
        PUSH_BUF_SIZE   :  in  std_logic_vector(BUF_DEPTH         downto 0);
        PUSH_BUF_READY  :  out std_logic;
    -------------------------------------------------------------------------------
    -- Buffer Interface Signals.
    -------------------------------------------------------------------------------
        BUF_WEN         :  in  std_logic;
        BUF_BEN         :  in  std_logic_vector(BUF_DATA_BITS/8-1 downto 0);
        BUF_DATA        :  in  std_logic_vector(BUF_DATA_BITS  -1 downto 0);
        BUF_PTR         :  in  std_logic_vector(BUF_DEPTH      -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Outlet Signals.
    -------------------------------------------------------------------------------
        MRG_DATA        :  out std_logic_vector(WORDS*WORD_BITS-1 downto 0);
        MRG_NONE        :  out std_logic_vector(WORDS          -1 downto 0);
        MRG_EBLK        :  out std_logic;
        MRG_LAST        :  out std_logic;
        MRG_VALID       :  out std_logic;
        MRG_READY       :  in  std_logic;
        MRG_LEVEL       :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end Merge_Reader;
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
architecture RTL of Merge_Reader is
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
    -- 各種定数
    ------------------------------------------------------------------------------
    constant  BUF_DATA_WIDTH    :  integer := CALC_DATA_WIDTH(BUF_DATA_BITS);
    constant  BUF_DATA_BYTES    :  integer := BUF_DATA_BITS/8;
    constant  BUF_BYTES         :  integer := 2**BUF_DEPTH;
    constant  MAX_XFER_BYTES    :  integer := 2**MAX_XFER_SIZE;
    ------------------------------------------------------------------------------
    -- 入力側のフロー制御用定数.
    ------------------------------------------------------------------------------
    constant  I_FLOW_READY_LEVEL:  std_logic_vector(BUF_DEPTH downto 0)
                                := std_logic_vector(to_unsigned(BUF_BYTES-MAX_XFER_BYTES  , BUF_DEPTH+1));
    constant  I_BUF_READY_LEVEL :  std_logic_vector(BUF_DEPTH downto 0)
                                := std_logic_vector(to_unsigned(BUF_BYTES-2*BUF_DATA_BYTES, BUF_DEPTH+1));
    ---------------------------------------------------------------------------
    -- 各種レジスタ出力信号
    ---------------------------------------------------------------------------
    signal    reg_o             :  std_logic_vector(REG_PARAM.BITS -1 downto 0);
    ---------------------------------------------------------------------------
    -- REQ/FLOW/ACK 制御信号
    ---------------------------------------------------------------------------
    signal    c_req_valid       :  std_logic;
    signal    c_req_ready       :  std_logic;
    signal    c_req_last        :  std_logic;
    signal    c_req_none        :  std_logic;
    signal    c_flow_ready      :  std_logic;
    signal    c_flow_pause      :  std_logic;
    signal    c_flow_stop       :  std_logic;
    signal    c_ack_valid       :  std_logic;
    signal    c_ack_size        :  std_logic_vector(BUF_DEPTH         downto 0);
    signal    c_ack_error       :  std_logic;
    signal    c_ack_next        :  std_logic;
    signal    c_ack_last        :  std_logic;
    signal    c_ack_stop        :  std_logic;
    signal    c_ack_none        :  std_logic;
    ---------------------------------------------------------------------------
    -- マージデータ出力制御信号
    ---------------------------------------------------------------------------
    signal    mrg_in_data       :  std_logic_vector(WORDS*WORD_BITS  -1 downto 0);
    signal    mrg_in_strb       :  std_logic_vector(WORDS*WORD_BITS/8-1 downto 0);
    signal    mrg_in_none       :  std_logic_vector(WORDS            -1 downto 0);
    signal    mrg_in_last       :  std_logic;
    signal    mrg_in_valid      :  std_logic;
    signal    mrg_in_ready      :  std_logic;
    signal    mrg_in_eblk       :  std_logic;
    ---------------------------------------------------------------------------
    -- PUMP STREAM 側 制御信号
    ---------------------------------------------------------------------------
    signal    i_open            :  std_logic;
    signal    i_end_of_blk      :  std_logic;
    signal    o_open_valid      :  std_logic;
    signal    o_close_valid     :  std_logic;
    signal    o_end_of_blk      :  std_logic;
    signal    o_reset           :  std_logic;
    signal    o_stop            :  std_logic;
    signal    o_error           :  std_logic;
    signal    o_open            :  std_logic;
    signal    o_done            :  std_logic;
    ---------------------------------------------------------------------------
    -- バッファ制御信号
    ---------------------------------------------------------------------------
    signal    buf_ren           :  std_logic;
    signal    buf_rptr          :  std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal    buf_rdata         :  std_logic_vector(BUF_DATA_BITS  -1 downto 0);
    signal    buf_we            :  std_logic_vector(BUF_DATA_BITS/8-1 downto 0);
begin
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
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
            O_DATA_BITS         => WORD_BITS*WORDS         , --
            O_WORD_BITS         => WORD_BITS               , --
            BUF_DEPTH           => BUF_DEPTH               , --
            BUF_DATA_BITS       => BUF_DATA_BITS           , --
            I2O_OPEN_INFO_BITS  => 1                       , --
            I2O_CLOSE_INFO_BITS => 1                       , --
            O2I_OPEN_INFO_BITS  => 1                       , --
            O2I_CLOSE_INFO_BITS => 1                       , --
            I2O_DELAY_CYCLE     => 1                         --
        )                                                    -- 
        port map (                                           -- 
        -----------------------------------------------------------------------
        --Reset Signals.
        -----------------------------------------------------------------------
            RST                 => RST                     , --  In  :
        -----------------------------------------------------------------------
        -- Intake Clock and Clock Enable.
        -----------------------------------------------------------------------
            I_CLK               => CLK                     , --  In  :
            I_CLR               => CLR                     , --  In  :
            I_CKE               => '1'                     , --  In  :
        -----------------------------------------------------------------------
        -- Intake Control Register Interface.
        -----------------------------------------------------------------------
            I_ADDR_L            => REG_L(REG_PARAM.ADDR.HI      downto REG_PARAM.ADDR.LO     ), --  In  :
            I_ADDR_D            => REG_D(REG_PARAM.ADDR.HI      downto REG_PARAM.ADDR.LO     ), --  In  :
            I_ADDR_Q            => reg_o(REG_PARAM.ADDR.HI      downto REG_PARAM.ADDR.LO     ), --  Out :
            I_SIZE_L            => REG_L(REG_PARAM.SIZE.HI      downto REG_PARAM.SIZE.LO     ), --  In  :
            I_SIZE_D            => REG_D(REG_PARAM.SIZE.HI      downto REG_PARAM.SIZE.LO     ), --  In  :
            I_SIZE_Q            => reg_o(REG_PARAM.SIZE.HI      downto REG_PARAM.SIZE.LO     ), --  Out :
            I_MODE_L            => REG_L(REG_PARAM.MODE.HI      downto REG_PARAM.MODE.LO     ), --  In  :
            I_MODE_D            => REG_D(REG_PARAM.MODE.HI      downto REG_PARAM.MODE.LO     ), --  In  :
            I_MODE_Q            => reg_o(REG_PARAM.MODE.HI      downto REG_PARAM.MODE.LO     ), --  Out :
            I_STAT_L            => REG_L(REG_PARAM.STAT.RESV.HI downto REG_PARAM.STAT.RESV.LO), --  In  :
            I_STAT_D            => REG_D(REG_PARAM.STAT.RESV.HI downto REG_PARAM.STAT.RESV.LO), --  In  :
            I_STAT_Q            => reg_o(REG_PARAM.STAT.RESV.HI downto REG_PARAM.STAT.RESV.LO), --  Out :
            I_RESET_L           => REG_L(REG_PARAM.CTRL.RESET.POS)  , --  In  :
            I_RESET_D           => REG_D(REG_PARAM.CTRL.RESET.POS)  , --  In  :
            I_RESET_Q           => reg_o(REG_PARAM.CTRL.RESET.POS)  , --  Out :
            I_START_L           => REG_L(REG_PARAM.CTRL.START.POS)  , --  In  :
            I_START_D           => REG_D(REG_PARAM.CTRL.START.POS)  , --  In  :
            I_START_Q           => reg_o(REG_PARAM.CTRL.START.POS)  , --  Out :
            I_STOP_L            => REG_L(REG_PARAM.CTRL.STOP.POS )  , --  In  :
            I_STOP_D            => REG_D(REG_PARAM.CTRL.STOP.POS )  , --  In  :
            I_STOP_Q            => reg_o(REG_PARAM.CTRL.STOP.POS )  , --  Out :
            I_PAUSE_L           => REG_L(REG_PARAM.CTRL.PAUSE.POS)  , --  In  :
            I_PAUSE_D           => REG_D(REG_PARAM.CTRL.PAUSE.POS)  , --  In  :
            I_PAUSE_Q           => reg_o(REG_PARAM.CTRL.PAUSE.POS)  , --  Out :
            I_FIRST_L           => REG_L(REG_PARAM.CTRL.FIRST.POS)  , --  In  :
            I_FIRST_D           => REG_D(REG_PARAM.CTRL.FIRST.POS)  , --  In  :
            I_FIRST_Q           => reg_o(REG_PARAM.CTRL.FIRST.POS)  , --  Out :
            I_LAST_L            => REG_L(REG_PARAM.CTRL.LAST.POS )  , --  In  :
            I_LAST_D            => REG_D(REG_PARAM.CTRL.LAST.POS )  , --  In  :
            I_LAST_Q            => reg_o(REG_PARAM.CTRL.LAST.POS )  , --  Out :
            I_DONE_EN_L         => REG_L(REG_PARAM.CTRL.DONE.POS )  , --  In  :
            I_DONE_EN_D         => REG_D(REG_PARAM.CTRL.DONE.POS )  , --  In  :
            I_DONE_EN_Q         => reg_o(REG_PARAM.CTRL.DONE.POS )  , --  Out :
            I_DONE_ST_L         => REG_L(REG_PARAM.STAT.DONE.POS )  , --  In  :
            I_DONE_ST_D         => REG_D(REG_PARAM.STAT.DONE.POS )  , --  In  :
            I_DONE_ST_Q         => reg_o(REG_PARAM.STAT.DONE.POS )  , --  Out :
            I_ERR_ST_L          => REG_L(REG_PARAM.STAT.ERROR.POS)  , --  In  :
            I_ERR_ST_D          => REG_D(REG_PARAM.STAT.ERROR.POS)  , --  In  :
            I_ERR_ST_Q          => reg_o(REG_PARAM.STAT.ERROR.POS)  , --  Out :
            I_CLOSE_ST_L        => REG_L(REG_PARAM.STAT.CLOSE.POS)  , --  In  :
            I_CLOSE_ST_D        => REG_D(REG_PARAM.STAT.CLOSE.POS)  , --  In  :
            I_CLOSE_ST_Q        => reg_o(REG_PARAM.STAT.CLOSE.POS)  , --  Out :
        -----------------------------------------------------------------------
        -- Intake Configuration Signals.
        -----------------------------------------------------------------------
            I_ADDR_FIX          => '0'                              , --  In  :
            I_BUF_READY_LEVEL   => I_BUF_READY_LEVEL                , --  In  :
            I_FLOW_READY_LEVEL  => I_FLOW_READY_LEVEL               , --  In  :
        -----------------------------------------------------------------------
        -- Intake Transaction Command Request Signals.
        -----------------------------------------------------------------------
            I_REQ_VALID         => c_req_valid                      , --  Out :
            I_REQ_ADDR          => REQ_ADDR                         , --  Out :
            I_REQ_SIZE          => REQ_SIZE                         , --  Out :
            I_REQ_BUF_PTR       => REQ_BUF_PTR                      , --  Out :
            I_REQ_FIRST         => REQ_FIRST                        , --  Out :
            I_REQ_LAST          => c_req_last                       , --  Out :
            I_REQ_NONE          => c_req_none                       , --  Out :
            I_REQ_READY         => c_req_ready                      , --  In  :
        -----------------------------------------------------------------------
        -- Intake Transaction Command Acknowledge Signals.
        -----------------------------------------------------------------------
            I_ACK_VALID         => c_ack_valid                      , --  In  :
            I_ACK_SIZE          => c_ack_size                       , --  In  :
            I_ACK_ERROR         => c_ack_error                      , --  In  :
            I_ACK_NEXT          => c_ack_next                       , --  In  :
            I_ACK_LAST          => c_ack_last                       , --  In  :
            I_ACK_STOP          => c_ack_stop                       , --  In  :
            I_ACK_NONE          => c_ack_none                       , --  In  :
        -----------------------------------------------------------------------
        -- Intake Transfer Status Signals.
        -----------------------------------------------------------------------
            I_XFER_BUSY         => XFER_BUSY                        , --  In  :
            I_XFER_DONE         => XFER_DONE                        , --  In  :
            I_XFER_ERROR        => XFER_ERROR                       , --  In  :
        -----------------------------------------------------------------------
        -- Intake Flow Control Signals.
        -----------------------------------------------------------------------
            I_FLOW_READY        => c_flow_ready                     , --  Out :
            I_FLOW_PAUSE        => c_flow_pause                     , --  Out :
            I_FLOW_STOP         => c_flow_stop                      , --  Out :
            I_FLOW_LAST         => FLOW_LAST                        , --  Out :
            I_FLOW_SIZE         => FLOW_SIZE                        , --  Out :
            I_PUSH_FIN_VALID    => PUSH_FIN_VALID                   , --  In  :
            I_PUSH_FIN_LAST     => PUSH_FIN_LAST                    , --  In  :
            I_PUSH_FIN_ERROR    => PUSH_FIN_ERROR                   , --  In  :
            I_PUSH_FIN_SIZE     => PUSH_FIN_SIZE                    , --  In  :
            I_PUSH_BUF_RESET    => PUSH_BUF_RESET                   , --  In  :
            I_PUSH_BUF_VALID    => PUSH_BUF_VALID                   , --  In  :
            I_PUSH_BUF_LAST     => PUSH_BUF_LAST                    , --  In  :
            I_PUSH_BUF_ERROR    => PUSH_BUF_ERROR                   , --  In  :
            I_PUSH_BUF_SIZE     => PUSH_BUF_SIZE                    , --  In  :
            I_PUSH_BUF_READY    => PUSH_BUF_READY                   , --  Out :
        -----------------------------------------------------------------------
        -- Intake Status.
        -----------------------------------------------------------------------
            I_OPEN              => i_open                           , --  Out :
            I_TRAN_BUSY         => open                             , --  Out :
            I_TRAN_DONE         => open                             , --  Out :
            I_TRAN_ERROR        => open                             , --  Out :
        -----------------------------------------------------------------------
        -- Intake Open/Close Infomation Interface
        -----------------------------------------------------------------------
            I_I2O_OPEN_INFO(0)  => i_end_of_blk                     , --  In  :
            I_I2O_CLOSE_INFO    => "0"                              , --  In  :
            I_O2I_OPEN_INFO     => open                             , --  Out :
            I_O2I_OPEN_VALID    => open                             , --  Out :
            I_O2I_CLOSE_INFO    => open                             , --  Out :
            I_O2I_CLOSE_VALID   => open                             , --  Out :
            I_O2I_STOP          => open                             , --  Out :
        -----------------------------------------------------------------------
        -- Outlet Clock and Clock Enable.
        -----------------------------------------------------------------------
            O_CLK               => CLK                              , --  In  :
            O_CLR               => CLR                              , --  In  :
            O_CKE               => '1'                              , --  In  :
        -----------------------------------------------------------------------
        -- Outlet Stream Interface.
        -----------------------------------------------------------------------
            O_DATA              => mrg_in_data                      , --  Out :
            O_STRB              => mrg_in_strb                      , --  Out :
            O_LAST              => mrg_in_last                      , --  Out :
            O_VALID             => mrg_in_valid                     , --  Out :
            O_READY             => mrg_in_ready                     , --  In  :
        -----------------------------------------------------------------------
        -- Outlet Status.
        -----------------------------------------------------------------------
            O_OPEN              => o_open                           , --  Out :
            O_DONE              => o_done                           , --  Out :
        -----------------------------------------------------------------------
        -- Outlet Open/Close Infomation Interface
        -----------------------------------------------------------------------
            O_O2I_STOP          => '0'                              , --  In  :
            O_O2I_OPEN_INFO     => "0"                              , --  In  :
            O_O2I_OPEN_VALID    => o_open_valid                     , --  In  :
            O_O2I_CLOSE_INFO    => "0"                              , --  In  :
            O_O2I_CLOSE_VALID   => o_close_valid                    , --  In  :
            O_I2O_RESET         => o_reset                          , --  Out :
            O_I2O_ERROR         => o_error                          , --  Out :
            O_I2O_STOP          => o_stop                           , --  Out :
            O_I2O_OPEN_INFO(0)  => o_end_of_blk                     , --  Out :
            O_I2O_OPEN_VALID    => o_open_valid                     , --  Out :
            O_I2O_CLOSE_INFO    => open                             , --  Out :
            O_I2O_CLOSE_VALID   => o_close_valid                    , --  Out :
        -----------------------------------------------------------------------
        -- Outlet Buffer Read Interface.
        -----------------------------------------------------------------------
            BUF_REN             => buf_ren                          , --  Out :
            BUF_PTR             => buf_rptr                         , --  Out :
            BUF_DATA            => buf_rdata                          --  In  :
        );                                                            --
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    REG_Q <= reg_o;
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    REQ: block
        type      STATE_TYPE    is (IDLE_STATE    ,
                                    I_REQ_STATE   ,
                                    NONE_ACK_STATE);
        signal    curr_state    :  STATE_TYPE;
        signal    last_state    :  std_logic;
    begin
        process (CLK, RST) begin
            if (RST = '1') then
                    curr_state  <= IDLE_STATE;
                    last_state  <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1' or o_reset = '1') then
                    curr_state  <= IDLE_STATE;
                    last_state  <= '0';
                else
                    case curr_state is
                        when IDLE_STATE =>
                            if    (c_req_valid = '1' and c_req_none   = '1') then
                                curr_state <= NONE_ACK_STATE;
                            elsif (c_req_valid = '1' and c_flow_ready = '1') or
                                  (c_req_valid = '1' and c_flow_stop  = '1') then
                                curr_state <= I_REQ_STATE;
                            else
                                curr_state <= IDLE_STATE;
                            end if;
                            last_state <= c_req_last;
                        when I_REQ_STATE =>
                            if    (ACK_VALID = '1') then
                                curr_state <= IDLE_STATE;
                            else
                                curr_state <= I_REQ_STATE;
                            end if;
                        when NONE_ACK_STATE =>
                                curr_state <= IDLE_STATE;
                        when others =>
                                curr_state <= IDLE_STATE;
                    end case;
                end if;
            end if;
        end process;
        -----------------------------------------------------------------------
        --
        -----------------------------------------------------------------------
        REQ_VALID   <= '1' when (curr_state = I_REQ_STATE) else '0';
        REQ_LAST    <= c_req_last;
        REQ_NONE    <= c_req_none;
        REQ_MODE    <= reg_o(REG_PARAM.MODE.HI downto REG_PARAM.MODE.LO);
        c_req_ready <= '1';
        -----------------------------------------------------------------------
        --
        -----------------------------------------------------------------------
        c_ack_valid <= ACK_VALID when (curr_state = I_REQ_STATE   ) else
                       '1'       when (curr_state = NONE_ACK_STATE) else '0';
        c_ack_size  <= ACK_SIZE  when (curr_state = I_REQ_STATE   ) else (others => '0');
        c_ack_error <= ACK_ERROR when (curr_state = I_REQ_STATE   ) else '0';
        c_ack_next  <= ACK_NEXT  when (curr_state = I_REQ_STATE   ) else
                       '1'       when (curr_state = NONE_ACK_STATE and last_state = '0') else '0';
        c_ack_last  <= ACK_LAST  when (curr_state = I_REQ_STATE   ) else
                       '1'       when (curr_state = NONE_ACK_STATE and last_state = '1') else '0';
        c_ack_stop  <= ACK_STOP  when (curr_state = I_REQ_STATE   ) else '0';
        c_ack_none  <= ACK_NONE  when (curr_state = I_REQ_STATE   ) else
                       '1'       when (curr_state = NONE_ACK_STATE) else '0';
    end block;
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    FLOW_READY  <= c_flow_ready;
    FLOW_PAUSE  <= c_flow_pause;
    FLOW_STOP   <= c_flow_stop;
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                i_end_of_blk <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1' or reg_o(REG_PARAM.CTRL.RESET.POS) = '1') then
                i_end_of_blk <= '0';
            elsif (REG_L(REG_PARAM.CTRL.EBLK.POS) = '1') then
                i_end_of_blk <= REG_D(REG_PARAM.CTRL.EBLK.POS);
            end if;
        end if;
    end process;
    reg_o(REG_PARAM.CTRL.EBLK.POS) <= i_end_of_blk;
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    MRG: block
        type      STATE_TYPE    is (IDLE_STATE    ,
                                    MRG_READ_STATE,
                                    MRG_NONE_STATE,
                                    CHK_NONE_STATE,
                                    END_NONE_STATE);
        signal    curr_state    :  STATE_TYPE;
        signal    o_none        :  std_logic;
    begin 
        process (CLK, RST) begin
            if (RST = '1') then
                    curr_state  <= IDLE_STATE;
                    o_none      <= '0';
                    mrg_in_eblk <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1' or o_reset = '1') then
                    curr_state  <= IDLE_STATE;
                    o_none      <= '0';
                    mrg_in_eblk <= '0';
                else
                    case curr_state is
                        when IDLE_STATE =>
                            if (o_open_valid = '1') then
                                curr_state <= MRG_READ_STATE;
                            else
                                curr_state <= IDLE_STATE;
                            end if;
                            if (o_open_valid = '1') then
                                mrg_in_eblk <= o_end_of_blk;
                            end if;
                            o_none <= '1';
                        when MRG_READ_STATE =>
                            if (o_open = '0') or
                               (o_open = '1' and o_done = '1') then
                                curr_state <= CHK_NONE_STATE;
                            else
                                curr_state <= MRG_READ_STATE;
                            end if;
                            if (mrg_in_valid = '1' and mrg_in_ready = '1') then
                                o_none <= '0';
                            end if;
                        when CHK_NONE_STATE =>
                            if (o_none = '0') then
                                curr_state <= IDLE_STATE;
                            else
                                curr_state <= MRG_NONE_STATE;
                            end if;
                        when MRG_NONE_STATE =>
                            if (MRG_READY = '1') then
                                curr_state <= END_NONE_STATE;
                            else
                                curr_state <= MRG_NONE_STATE;
                            end if;
                        when END_NONE_STATE =>
                                curr_state <= IDLE_STATE;
                        when others => 
                                curr_state <= IDLE_STATE;
                    end case;
                end if;
            end if;
        end process;
        -----------------------------------------------------------------------
        --
        -----------------------------------------------------------------------
        BUSY <= '1' when ((curr_state = IDLE_STATE     and i_open = '1') or
                          (curr_state = MRG_READ_STATE                 ) or
                          (curr_state = CHK_NONE_STATE                 ) or
                          (curr_state = MRG_NONE_STATE                 ) or
                          (curr_state = END_NONE_STATE                 )) else '0';
        DONE <= '1' when ((curr_state = CHK_NONE_STATE and o_none = '0') or
                          (curr_state = END_NONE_STATE                 )) else '0';
        -----------------------------------------------------------------------
        --
        -----------------------------------------------------------------------
        process (curr_state, mrg_in_strb) begin
            for i in mrg_in_none'range loop
                if (curr_state = MRG_NONE_STATE) or
                   (mrg_in_strb(i*(WORD_BITS/8)) = '0') then
                    mrg_in_none(i) <= '1';
                else
                    mrg_in_none(i) <= '0';
                end if;
            end loop;
        end process;
        -----------------------------------------------------------------------
        --
        -----------------------------------------------------------------------
        MRG_DATA     <= mrg_in_data;
        MRG_NONE     <= mrg_in_none;
        MRG_VALID    <= '1' when (curr_state = MRG_NONE_STATE) or
                                 (curr_state = MRG_READ_STATE and mrg_in_valid = '1') else '0';
        MRG_LAST     <= '1' when (curr_state = MRG_NONE_STATE) or
                                 (curr_state = MRG_READ_STATE and mrg_in_last  = '1') else '0';
        MRG_EBLK     <= mrg_in_eblk;
        mrg_in_ready <= '1' when (curr_state = MRG_READ_STATE and MRG_READY    = '1') else '0';
    end block;
    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------
    RAM: SDPRAM 
        generic map(
            DEPTH       => BUF_DEPTH+3         ,
            RWIDTH      => BUF_DATA_WIDTH      , --
            WWIDTH      => BUF_DATA_WIDTH      , --
            WEBIT       => BUF_DATA_WIDTH-3    , --
            ID          => CHANNEL               -- 
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
end RTL;

