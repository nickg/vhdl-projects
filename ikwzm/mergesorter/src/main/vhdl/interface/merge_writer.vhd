-----------------------------------------------------------------------------------
--!     @file    merge_writer.vhd
--!     @brief   Merge Sorter Merge Writer Module :
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
entity  Merge_Writer is
    generic (
        CHANNEL         :  integer :=  0;
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        REG_PARAM       :  Interface.Regs_Field_Type := Interface.Default_Regs_Param;
        REQ_ADDR_BITS   :  integer := 32;
        REQ_SIZE_BITS   :  integer := 32;
        BUF_DATA_BITS   :  integer := 64;
        BUF_DEPTH       :  integer := 13;
        MAX_XFER_SIZE   :  integer := 12
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
        PULL_FIN_VALID  :  in  std_logic;
        PULL_FIN_LAST   :  in  std_logic;
        PULL_FIN_ERROR  :  in  std_logic := '0';
        PULL_FIN_SIZE   :  in  std_logic_vector(BUF_DEPTH         downto 0);
        PULL_BUF_RESET  :  in  std_logic := '0';
        PULL_BUF_VALID  :  in  std_logic := '0';
        PULL_BUF_LAST   :  in  std_logic;
        PULL_BUF_ERROR  :  in  std_logic := '0';
        PULL_BUF_SIZE   :  in  std_logic_vector(BUF_DEPTH         downto 0);
        PULL_BUF_READY  :  out std_logic;
    -------------------------------------------------------------------------------
    -- Buffer Interface Signals.
    -------------------------------------------------------------------------------
        BUF_DATA        :  out std_logic_vector(BUF_DATA_BITS  -1 downto 0);
        BUF_PTR         :  in  std_logic_vector(BUF_DEPTH      -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Intake Signals.
    -------------------------------------------------------------------------------
        MRG_DATA        :  in  std_logic_vector(WORDS*WORD_BITS-1 downto 0);
        MRG_STRB        :  in  std_logic_vector(WORDS          -1 downto 0);
        MRG_LAST        :  in  std_logic;
        MRG_VALID       :  in  std_logic;
        MRG_READY       :  out std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end Merge_Writer;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library Merge_Sorter;
use     Merge_Sorter.Interface;
library PIPEWORK;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_STREAM_OUTLET_CONTROLLER;
use     PIPEWORK.COMPONENTS.SDPRAM;
architecture RTL of Merge_Writer is
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
    -- 出力側のフロー制御用定数.
    ------------------------------------------------------------------------------
    constant  O_FLOW_READY_LEVEL:  std_logic_vector(BUF_DEPTH downto 0)
                                := std_logic_vector(to_unsigned(MAX_XFER_BYTES     , BUF_DEPTH+1));
    constant  O_BUF_READY_LEVEL :  std_logic_vector(BUF_DEPTH downto 0)
                                := std_logic_vector(to_unsigned(2*(BUF_DATA_BITS/8), BUF_DEPTH+1));
    ---------------------------------------------------------------------------
    -- 各種レジスタ出力信号
    ---------------------------------------------------------------------------
    signal    reg_o             :  std_logic_vector(REG_PARAM.BITS -1 downto 0);
    ------------------------------------------------------------------------------
    -- バッファ制御信号
    ------------------------------------------------------------------------------
    signal    buf_wen           :  std_logic;
    signal    buf_ben           :  std_logic_vector(BUF_DATA_BITS/8-1 downto 0);
    signal    buf_wptr          :  std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal    buf_wdata         :  std_logic_vector(BUF_DATA_BITS  -1 downto 0);
    signal    buf_we            :  std_logic_vector(BUF_DATA_BITS/8-1 downto 0);
    ------------------------------------------------------------------------------
    -- PUMP STREAM 側 制御信号
    ------------------------------------------------------------------------------
    signal    o_open            :  std_logic;
    signal    o_open_valid      :  std_logic;
    signal    o_close_valid     :  std_logic;
    signal    i_reset           :  std_logic;
    signal    i_stop            :  std_logic;
    signal    i_error           :  std_logic;
    signal    i_open_valid      :  std_logic;
    signal    i_close_valid     :  std_logic;
    signal    i_strb            :  std_logic_vector(WORDS*WORD_BITS/8-1 downto 0);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    CTRL: PUMP_STREAM_OUTLET_CONTROLLER                      -- 
        generic map (                                        -- 
            O_CLK_RATE          => 1                       , --
            O_REQ_ADDR_VALID    => 1                       , --
            O_REQ_ADDR_BITS     => REQ_ADDR_BITS           , --
            O_REG_ADDR_BITS     => REG_PARAM.ADDR.BITS     , --
            O_REQ_SIZE_VALID    => 1                       , --
            O_REQ_SIZE_BITS     => REQ_SIZE_BITS           , --
            O_REG_SIZE_BITS     => REG_PARAM.SIZE.BITS     , --
            O_REG_MODE_BITS     => REG_PARAM.MODE.BITS     , --
            O_REG_STAT_BITS     => REG_PARAM.STAT.RESV.BITS, --
            O_USE_PULL_BUF_SIZE => 0                       , --
            O_FIXED_FLOW_OPEN   => 0                       , --
            O_FIXED_POOL_OPEN   => 1                       , --
            I_CLK_RATE          => 1                       , --
            I_DATA_BITS         => WORD_BITS*WORDS         , --
            I_WORD_BITS         => WORD_BITS               , --
            BUF_DEPTH           => BUF_DEPTH               , --
            BUF_DATA_BITS       => BUF_DATA_BITS           , --
            O2I_OPEN_INFO_BITS  => 1                       , --
            O2I_CLOSE_INFO_BITS => 1                       , --
            I2O_OPEN_INFO_BITS  => 1                       , --
            I2O_CLOSE_INFO_BITS => 1                       , --
            I2O_DELAY_CYCLE     => 1                         --
        )                                                    -- 
        port map (                                           -- 
        ---------------------------------------------------------------------------
        --Reset Signals.
        ---------------------------------------------------------------------------
            RST                 => RST                     , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Clock and Clock Enable.
        ---------------------------------------------------------------------------
            O_CLK               => CLK                     , --  In  :
            O_CLR               => CLR                     , --  In  :
            O_CKE               => '1'                     , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Control Register Interface.
        ---------------------------------------------------------------------------
            O_ADDR_L            => REG_L(REG_PARAM.ADDR.HI      downto REG_PARAM.ADDR.LO     ), --  In  :
            O_ADDR_D            => REG_D(REG_PARAM.ADDR.HI      downto REG_PARAM.ADDR.LO     ), --  In  :
            O_ADDR_Q            => reg_o(REG_PARAM.ADDR.HI      downto REG_PARAM.ADDR.LO     ), --  Out :
            O_SIZE_L            => REG_L(REG_PARAM.SIZE.HI      downto REG_PARAM.SIZE.LO     ), --  In  :
            O_SIZE_D            => REG_D(REG_PARAM.SIZE.HI      downto REG_PARAM.SIZE.LO     ), --  In  :
            O_SIZE_Q            => reg_o(REG_PARAM.SIZE.HI      downto REG_PARAM.SIZE.LO     ), --  Out :
            O_MODE_L            => REG_L(REG_PARAM.MODE.HI      downto REG_PARAM.MODE.LO     ), --  In  :
            O_MODE_D            => REG_D(REG_PARAM.MODE.HI      downto REG_PARAM.MODE.LO     ), --  In  :
            O_MODE_Q            => reg_o(REG_PARAM.MODE.HI      downto REG_PARAM.MODE.LO     ), --  Out :
            O_STAT_L            => REG_L(REG_PARAM.STAT.RESV.HI downto REG_PARAM.STAT.RESV.LO), --  In  :
            O_STAT_D            => REG_D(REG_PARAM.STAT.RESV.HI downto REG_PARAM.STAT.RESV.LO), --  In  :
            O_STAT_Q            => reg_o(REG_PARAM.STAT.RESV.HI downto REG_PARAM.STAT.RESV.LO), --  Out :
            O_RESET_L           => REG_L(REG_PARAM.CTRL.RESET.POS)  , --  In  :
            O_RESET_D           => REG_D(REG_PARAM.CTRL.RESET.POS)  , --  In  :
            O_RESET_Q           => reg_o(REG_PARAM.CTRL.RESET.POS)  , --  Out :
            O_START_L           => REG_L(REG_PARAM.CTRL.START.POS)  , --  In  :
            O_START_D           => REG_D(REG_PARAM.CTRL.START.POS)  , --  In  :
            O_START_Q           => reg_o(REG_PARAM.CTRL.START.POS)  , --  Out :
            O_STOP_L            => REG_L(REG_PARAM.CTRL.STOP.POS )  , --  In  :
            O_STOP_D            => REG_D(REG_PARAM.CTRL.STOP.POS )  , --  In  :
            O_STOP_Q            => reg_o(REG_PARAM.CTRL.STOP.POS )  , --  Out :
            O_PAUSE_L           => REG_L(REG_PARAM.CTRL.PAUSE.POS)  , --  In  :
            O_PAUSE_D           => REG_D(REG_PARAM.CTRL.PAUSE.POS)  , --  In  :
            O_PAUSE_Q           => reg_o(REG_PARAM.CTRL.PAUSE.POS)  , --  Out :
            O_FIRST_L           => REG_L(REG_PARAM.CTRL.FIRST.POS)  , --  In  :
            O_FIRST_D           => REG_D(REG_PARAM.CTRL.FIRST.POS)  , --  In  :
            O_FIRST_Q           => reg_o(REG_PARAM.CTRL.FIRST.POS)  , --  Out :
            O_LAST_L            => REG_L(REG_PARAM.CTRL.LAST.POS )  , --  In  :
            O_LAST_D            => REG_D(REG_PARAM.CTRL.LAST.POS )  , --  In  :
            O_LAST_Q            => reg_o(REG_PARAM.CTRL.LAST.POS )  , --  Out :
            O_DONE_EN_L         => REG_L(REG_PARAM.CTRL.DONE.POS )  , --  In  :
            O_DONE_EN_D         => REG_D(REG_PARAM.CTRL.DONE.POS )  , --  In  :
            O_DONE_EN_Q         => reg_o(REG_PARAM.CTRL.DONE.POS )  , --  Out :
            O_DONE_ST_L         => REG_L(REG_PARAM.STAT.DONE.POS )  , --  In  :
            O_DONE_ST_D         => REG_D(REG_PARAM.STAT.DONE.POS )  , --  In  :
            O_DONE_ST_Q         => reg_o(REG_PARAM.STAT.DONE.POS )  , --  Out :
            O_ERR_ST_L          => REG_L(REG_PARAM.STAT.ERROR.POS)  , --  In  :
            O_ERR_ST_D          => REG_D(REG_PARAM.STAT.ERROR.POS)  , --  In  :
            O_ERR_ST_Q          => reg_o(REG_PARAM.STAT.ERROR.POS)  , --  Out :
            O_CLOSE_ST_L        => REG_L(REG_PARAM.STAT.CLOSE.POS)  , --  In  :
            O_CLOSE_ST_D        => REG_D(REG_PARAM.STAT.CLOSE.POS)  , --  In  :
            O_CLOSE_ST_Q        => reg_o(REG_PARAM.STAT.CLOSE.POS)  , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Configuration Signals.
        ---------------------------------------------------------------------------
            O_ADDR_FIX          => '0'                              , --  In  :
            O_BUF_READY_LEVEL   => O_BUF_READY_LEVEL                , --  In  :
            O_FLOW_READY_LEVEL  => O_FLOW_READY_LEVEL               , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Transaction Command Request Signals.
        ---------------------------------------------------------------------------
            O_REQ_VALID         => REQ_VALID                        , --  Out :
            O_REQ_ADDR          => REQ_ADDR                         , --  Out :
            O_REQ_SIZE          => REQ_SIZE                         , --  Out :
            O_REQ_BUF_PTR       => REQ_BUF_PTR                      , --  Out :
            O_REQ_FIRST         => REQ_FIRST                        , --  Out :
            O_REQ_LAST          => REQ_LAST                         , --  Out :
            O_REQ_NONE          => REQ_NONE                         , --  Out :
            O_REQ_READY         => REQ_READY                        , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Transaction Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            O_ACK_VALID         => ACK_VALID                        , --  In  :
            O_ACK_SIZE          => ACK_SIZE                         , --  In  :
            O_ACK_ERROR         => ACK_ERROR                        , --  In  :
            O_ACK_NEXT          => ACK_NEXT                         , --  In  :
            O_ACK_LAST          => ACK_LAST                         , --  In  :
            O_ACK_STOP          => ACK_STOP                         , --  In  :
            O_ACK_NONE          => ACK_NONE                         , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Transfer Status Signals.
        ---------------------------------------------------------------------------
            O_XFER_BUSY         => XFER_BUSY                        , --  In  :
            O_XFER_DONE         => XFER_DONE                        , --  In  :
            O_XFER_ERROR        => XFER_ERROR                       , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            O_FLOW_READY        => FLOW_READY                       , --  Out :
            O_FLOW_PAUSE        => FLOW_PAUSE                       , --  Out :
            O_FLOW_STOP         => FLOW_STOP                        , --  Out :
            O_FLOW_LAST         => FLOW_LAST                        , --  Out :
            O_FLOW_SIZE         => FLOW_SIZE                        , --  Out :
            O_PULL_FIN_VALID    => PULL_FIN_VALID                   , --  In  :
            O_PULL_FIN_LAST     => PULL_FIN_LAST                    , --  In  :
            O_PULL_FIN_ERROR    => PULL_FIN_ERROR                   , --  In  :
            O_PULL_FIN_SIZE     => PULL_FIN_SIZE                    , --  In  :
            O_PULL_BUF_RESET    => PULL_BUF_RESET                   , --  In  :
            O_PULL_BUF_VALID    => PULL_BUF_VALID                   , --  In  :
            O_PULL_BUF_LAST     => PULL_BUF_LAST                    , --  In  :
            O_PULL_BUF_ERROR    => PULL_BUF_ERROR                   , --  In  :
            O_PULL_BUF_SIZE     => PULL_BUF_SIZE                    , --  In  :
            O_PULL_BUF_READY    => PULL_BUF_READY                   , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Status.
        ---------------------------------------------------------------------------
            O_OPEN              => o_open                           , --  Out :
            O_TRAN_BUSY         => open                             , --  Out :
            O_TRAN_DONE         => open                             , --  Out :
            O_TRAN_ERROR        => open                             , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Open/Close Infomation Interface
        ---------------------------------------------------------------------------
            O_O2I_OPEN_INFO     => "0"                              , --  In  :
            O_O2I_CLOSE_INFO    => "0"                              , --  In  :
            O_I2O_OPEN_INFO     => open                             , --  Out :
            O_I2O_OPEN_VALID    => o_open_valid                     , --  Out :
            O_I2O_CLOSE_INFO    => open                             , --  Out :
            O_I2O_CLOSE_VALID   => o_close_valid                    , --  Out :
            O_I2O_STOP          => open                             , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Clock and Clock Enable.
        ---------------------------------------------------------------------------
            I_CLK               => CLK                              , --  In  :
            I_CLR               => CLR                              , --  In  :
            I_CKE               => '1'                              , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Stream Interface.
        ---------------------------------------------------------------------------
            I_DATA              => MRG_DATA                         , --  In  :
            I_STRB              => i_strb                           , --  In  :
            I_LAST              => MRG_LAST                         , --  In  :
            I_VALID             => MRG_VALID                        , --  In  :
            I_READY             => MRG_READY                        , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Status.
        ---------------------------------------------------------------------------
            I_OPEN              => open                             , --  Out :
            I_DONE              => open                             , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Open/Close Infomation Interface
        ---------------------------------------------------------------------------
            I_I2O_STOP          => '0'                              , --  In  :
            I_I2O_OPEN_INFO     => "0"                              , --  In  :
            I_I2O_OPEN_VALID    => i_open_valid                     , --  In  :
            I_I2O_CLOSE_INFO    => "0"                              , --  In  :
            I_I2O_CLOSE_VALID   => i_close_valid                    , --  In  :
            I_O2I_RESET         => i_reset                          , --  Out :
            I_O2I_STOP          => i_stop                           , --  Out :
            I_O2I_ERROR         => i_error                          , --  Out :
            I_O2I_OPEN_INFO     => open                             , --  Out :
            I_O2I_OPEN_VALID    => i_open_valid                     , --  Out :
            I_O2I_CLOSE_INFO    => open                             , --  Out :
            I_O2I_CLOSE_VALID   => i_close_valid                    , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Buffer Read Interface.
        ---------------------------------------------------------------------------
            BUF_WEN             => buf_wen                          , --  Out :
            BUF_BEN             => buf_ben                          , --  Out :
            BUF_PTR             => buf_wptr                         , --  Out :
            BUF_DATA            => buf_wdata                          --  Out :
        );                                                            --
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    REG_Q <= reg_o;
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    REQ_MODE <= reg_o(REG_PARAM.MODE.HI downto REG_PARAM.MODE.LO);    -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I_STRB_GEN: for i in 0 to WORDS-1 generate
        constant  STRB_BITS     :  integer := WORD_BITS/8;
        constant  STRB_1        :  std_logic_vector(STRB_BITS-1 downto 0) := (others => '1');
        constant  STRB_0        :  std_logic_vector(STRB_BITS-1 downto 0) := (others => '0');
    begin
        i_strb((i+1)*STRB_BITS-1 downto i*STRB_BITS) <= STRB_1 when (MRG_STRB(i) = '1') else STRB_0;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    STATUS: block
        type    O_STATE_TYPE  is (O_IDLE, O_RUN, O_TAR);
        signal  o_state       :  O_STATE_TYPE;
    begin
        process (CLK, RST) begin
            if (RST = '1') then
                    o_state <= O_IDLE;
            elsif (CLK'event and CLK = '1') then
                if    (CLR = '1' or reg_o(REG_PARAM.CTRL.RESET.POS) = '1') then
                    o_state <= O_IDLE;
                else
                    case o_state is
                        when O_IDLE =>
                            if    (o_open = '1' and o_close_valid = '1') then
                                o_state <= O_TAR;
                            elsif (o_open = '1' and o_close_valid = '0') then
                                o_state <= O_RUN;
                            else
                                o_state <= O_IDLE;
                            end if;
                        when O_RUN =>
                            if    (o_open = '1' and o_close_valid = '1') then
                                o_state <= O_TAR;
                            elsif (o_open = '1' and o_close_valid = '0') then
                                o_state <= O_RUN;
                            elsif (o_open = '0' and o_close_valid = '1') then
                                o_state <= O_IDLE;
                            else
                                o_state <= O_RUN;
                            end if;
                        when O_TAR =>
                            if (o_open = '0') then
                                o_state <= O_IDLE;
                            else
                                o_state <= O_TAR;
                            end if;
                        when others => 
                                o_state <= O_IDLE;
                    end case;
                end if;
            end if;
        end process;
        BUSY  <= '1' when ((o_state = O_IDLE and o_open = '1') or
                           (o_state = O_RUN                  ) or
                           (o_state = O_TAR                  )) else '0';
        DONE  <= '1' when ((o_state = O_RUN  and o_open = '0' and o_close_valid = '1') or
                           (o_state = O_TAR  and o_open = '0')) else '0';
        reg_o(REG_PARAM.CTRL.EBLK.POS) <= '0';
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
            ID          => CHANNEL               -- 
        )                                        -- 
        port map (                               -- 
            WCLK        => CLK                 , -- In  :
            WE          => buf_we              , -- In  :
            WADDR       => buf_wptr(BUF_DEPTH-1 downto BUF_DATA_WIDTH-3), -- In  :
            WDATA       => buf_wdata           , -- In  :
            RCLK        => CLK                 , -- In  :
            RADDR       => BUF_PTR (BUF_DEPTH-1 downto BUF_DATA_WIDTH-3), -- In  :
            RDATA       => BUF_DATA              -- Out :
        );
    buf_we <= buf_ben when (buf_wen = '1') else (others => '0');
end RTL;
