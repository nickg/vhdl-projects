-----------------------------------------------------------------------------------
--!     @file    axi4_stream_to_master.vhd
--!     @brief   Pump Core Module (AXI4-Stream to AXI4)
--!     @version 1.8.1
--!     @date    2020/10/2
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2020 Ichiro Kawazome
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
-----------------------------------------------------------------------------------
--! @brief 
-----------------------------------------------------------------------------------
entity  AXI4_STREAM_TO_MASTER is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        C_ADDR_WIDTH    : integer range 1 to   64 := 32;
        C_DATA_WIDTH    : integer range 8 to 1024 := 32;
        C_ID_WIDTH      : integer                 :=  8;
        O_CLK_RATE      : integer                 :=  1;
        O_AXI_ID        : integer                 :=  1;
        O_ADDR_WIDTH    : integer range 1 to   64 := 32;
        O_DATA_WIDTH    : integer range 8 to 1024 := 32;
        O_ID_WIDTH      : integer                 :=  8;
        O_AUSER_WIDTH   : integer                 :=  4;
        O_MAX_XFER_SIZE : integer                 :=  8;
        O_QUEUE_SIZE    : integer                 :=  2;
        I_CLK_RATE      : integer                 :=  1;
        I_DATA_WIDTH    : integer                 := 32;
        BUF_WIDTH       : integer                 := 32;
        BUF_DEPTH       : integer                 := 12
    );
    port(
    -------------------------------------------------------------------------------
    -- Reset Signals.
    -------------------------------------------------------------------------------
        ARESETn         : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F Clock.
    -------------------------------------------------------------------------------
        O_CLK           : in    std_logic;
        O_CKE           : in    std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        C_ARID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_ARADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
        C_ARLEN         : in    std_logic_vector(7 downto 0);
        C_ARSIZE        : in    std_logic_vector(2 downto 0);
        C_ARBURST       : in    std_logic_vector(1 downto 0);
        C_ARVALID       : in    std_logic;
        C_ARREADY       : out   std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        C_RID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_RDATA         : out   std_logic_vector(C_DATA_WIDTH  -1 downto 0);
        C_RRESP         : out   std_logic_vector(1 downto 0);
        C_RLAST         : out   std_logic;
        C_RVALID        : out   std_logic;
        C_RREADY        : in    std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        C_AWID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_AWADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
        C_AWLEN         : in    std_logic_vector(7 downto 0);
        C_AWSIZE        : in    std_logic_vector(2 downto 0);
        C_AWBURST       : in    std_logic_vector(1 downto 0);
        C_AWVALID       : in    std_logic;
        C_AWREADY       : out   std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        C_WDATA         : in    std_logic_vector(C_DATA_WIDTH  -1 downto 0);
        C_WSTRB         : in    std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
        C_WLAST         : in    std_logic;
        C_WVALID        : in    std_logic;
        C_WREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        C_BID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_BRESP         : out   std_logic_vector(1 downto 0);
        C_BVALID        : out   std_logic;
        C_BREADY        : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        O_AWID          : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_AWADDR        : out   std_logic_vector(O_ADDR_WIDTH  -1 downto 0);
        O_AWLEN         : out   std_logic_vector(7 downto 0);
        O_AWSIZE        : out   std_logic_vector(2 downto 0);
        O_AWBURST       : out   std_logic_vector(1 downto 0);
        O_AWLOCK        : out   std_logic_vector(0 downto 0);
        O_AWCACHE       : out   std_logic_vector(3 downto 0);
        O_AWPROT        : out   std_logic_vector(2 downto 0);
        O_AWQOS         : out   std_logic_vector(3 downto 0);
        O_AWREGION      : out   std_logic_vector(3 downto 0);
        O_AWUSER        : out   std_logic_vector(O_AUSER_WIDTH -1 downto 0);
        O_AWVALID       : out   std_logic;
        O_AWREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        O_WID           : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_WDATA         : out   std_logic_vector(O_DATA_WIDTH  -1 downto 0);
        O_WSTRB         : out   std_logic_vector(O_DATA_WIDTH/8-1 downto 0);
        O_WLAST         : out   std_logic;
        O_WVALID        : out   std_logic;
        O_WREADY        : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        O_BID           : in    std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_BRESP         : in    std_logic_vector(1 downto 0);
        O_BVALID        : in    std_logic;
        O_BREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        O_ARID          : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_ARADDR        : out   std_logic_vector(O_ADDR_WIDTH  -1 downto 0);
        O_ARLEN         : out   std_logic_vector(7 downto 0);
        O_ARSIZE        : out   std_logic_vector(2 downto 0);
        O_ARBURST       : out   std_logic_vector(1 downto 0);
        O_ARLOCK        : out   std_logic_vector(0 downto 0);
        O_ARCACHE       : out   std_logic_vector(3 downto 0);
        O_ARPROT        : out   std_logic_vector(2 downto 0);
        O_ARQOS         : out   std_logic_vector(3 downto 0);
        O_ARREGION      : out   std_logic_vector(3 downto 0);
        O_ARUSER        : out   std_logic_vector(O_AUSER_WIDTH -1 downto 0);
        O_ARVALID       : out   std_logic;
        O_ARREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        O_RID           : in    std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_RDATA         : in    std_logic_vector(O_DATA_WIDTH  -1 downto 0);
        O_RRESP         : in    std_logic_vector(1 downto 0);
        O_RLAST         : in    std_logic;
        O_RVALID        : in    std_logic;
        O_RREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F Clock.
    -------------------------------------------------------------------------------
        I_CLK           : in    std_logic;
        I_CKE           : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake Stream Interface.
    -------------------------------------------------------------------------------
        I_DATA          : in  std_logic_vector(I_DATA_WIDTH   -1 downto 0);
        I_STRB          : in  std_logic_vector(I_DATA_WIDTH/8 -1 downto 0);
        I_LAST          : in  std_logic;
        I_VALID         : in  std_logic;
        I_READY         : out std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet Stop Interface.
    -------------------------------------------------------------------------------
        I_I2O_STOP      : in  std_logic;
        I_O2I_STOP      : out std_logic;
        I_O2I_RESET     : out std_logic;
        I_O2I_ERROR     : out std_logic;
        I_O2I_NONE      : out std_logic;
    -------------------------------------------------------------------------------
    -- Interrupt Request Signals.
    -------------------------------------------------------------------------------
        IRQ             : out   std_logic
    );
end AXI4_STREAM_TO_MASTER;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_WRITE_INTERFACE;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_REGISTER_INTERFACE;
use     PIPEWORK.COMPONENTS.REGISTER_ACCESS_ADAPTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_STREAM_OUTLET_CONTROLLER;
use     PIPEWORK.COMPONENTS.SDPRAM;
architecture RTL of AXI4_STREAM_TO_MASTER is
    -------------------------------------------------------------------------------
    -- リセット信号.
    -------------------------------------------------------------------------------
    signal    RST                   :  std_logic;
    constant  CLR                   :  std_logic := '0';
    ------------------------------------------------------------------------------
    -- 出力側のフロー制御用定数.
    ------------------------------------------------------------------------------
    constant  O_FLOW_VALID          :  integer := 1;
    constant  O_USE_PULL_BUF_SIZE   :  integer := 0;
    constant  O_FIXED_FLOW_OPEN     :  integer := 0;
    constant  O_FIXED_POOL_OPEN     :  integer := 1;
    constant  O_REQ_ADDR_VALID      :  integer := 1;
    constant  O_REQ_SIZE_VALID      :  integer := 1;
    constant  O_FLOW_READY_LEVEL    :  std_logic_vector(BUF_DEPTH downto 0)
                                    := std_logic_vector(to_unsigned(2**O_MAX_XFER_SIZE, BUF_DEPTH+1));
    constant  O_BUF_READY_LEVEL     :  std_logic_vector(BUF_DEPTH downto 0)
                                    := std_logic_vector(to_unsigned(2*O_DATA_WIDTH    , BUF_DEPTH+1));
    -------------------------------------------------------------------------------
    -- 出力側 AXI I/F の各種定数
    -------------------------------------------------------------------------------
    constant  O_REQ_LOCK            :  AXI4_ALOCK_TYPE  := (others => '0');
    constant  O_REQ_PROT            :  AXI4_APROT_TYPE  := (others => '0');
    constant  O_REQ_QOS             :  AXI4_AQOS_TYPE   := (others => '0');
    constant  O_REQ_REGION          :  AXI4_AREGION_TYPE:= (others => '0');
    constant  O_REQ_ID              :  std_logic_vector(O_ID_WIDTH -1 downto 0)
                                    := std_logic_vector(to_unsigned(O_AXI_ID, O_ID_WIDTH));
    constant  O_ADDR_FIX            :  std_logic := '0';
    constant  O_REQ_REGS            :  integer := 1;
    constant  O_ACK_REGS            :  integer := 1;
    constant  O_RESP_REGS           :  integer := 1;
    constant  O_REQ_QUEUE           :  integer := O_QUEUE_SIZE;
    constant  O_RDATA_REGS          :  integer := 3;
    constant  O_REQ_SIZE_BITS       :  integer := 32;
    constant  O_XFER_MIN_SIZE       :  integer := O_MAX_XFER_SIZE;
    constant  O_XFER_MAX_SIZE       :  integer := O_MAX_XFER_SIZE;
    constant  OPEN_INFO_BITS        :  integer := 32;
    constant  CLOSE_INFO_BITS       :  integer := 32;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    o_req_valid           :  std_logic;
    signal    o_req_addr            :  std_logic_vector(O_ADDR_WIDTH   -1 downto 0);
    signal    o_req_size            :  std_logic_vector(O_REQ_SIZE_BITS-1 downto 0);
    signal    o_req_buf_ptr         :  std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal    o_req_cache           :  AXI4_ACACHE_TYPE;
    signal    o_req_speculative     :  std_logic;
    signal    o_req_safety          :  std_logic;
    signal    o_req_first           :  std_logic;
    signal    o_req_last            :  std_logic;
    signal    o_req_none            :  std_logic;
    signal    o_req_ready           :  std_logic;
    signal    o_ack_valid           :  std_logic;
    signal    o_ack_size            :  std_logic_vector(BUF_DEPTH         downto 0);
    signal    o_ack_error           :  std_logic;
    signal    o_ack_next            :  std_logic;
    signal    o_ack_last            :  std_logic;
    signal    o_ack_stop            :  std_logic;
    signal    o_ack_none            :  std_logic;
    signal    o_xfer_busy           :  std_logic;
    signal    o_xfer_done           :  std_logic;
    signal    o_xfer_error          :  std_logic;
    signal    o_flow_ready          :  std_logic;
    signal    o_flow_pause          :  std_logic;
    signal    o_flow_stop           :  std_logic;
    signal    o_flow_last           :  std_logic;
    signal    o_flow_size           :  std_logic_vector(BUF_DEPTH         downto 0);
    signal    o_pull_fin_valid      :  std_logic;
    signal    o_pull_fin_last       :  std_logic;
    signal    o_pull_fin_error      :  std_logic;
    signal    o_pull_fin_size       :  std_logic_vector(BUF_DEPTH         downto 0);
    signal    o_pull_rsv_valid      :  std_logic;
    signal    o_pull_rsv_last       :  std_logic;
    signal    o_pull_rsv_error      :  std_logic;
    signal    o_pull_rsv_size       :  std_logic_vector(BUF_DEPTH         downto 0);
    signal    o_pull_buf_reset      :  std_logic;
    signal    o_pull_buf_valid      :  std_logic;
    signal    o_pull_buf_last       :  std_logic;
    signal    o_pull_buf_error      :  std_logic;
    signal    o_pull_buf_size       :  std_logic_vector(BUF_DEPTH         downto 0);
    signal    o_pull_buf_ready      :  std_logic;
    signal    o_open                :  std_logic;
    signal    o_tran_busy           :  std_logic;
    signal    o_tran_done           :  std_logic;
    signal    o_tran_error          :  std_logic;
    signal    o_i_open_info         :  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    signal    o_q_open_info         :  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    signal    o_i_close_info        :  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    signal    o_q_close_info        :  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    signal    o_o_open_info         :  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    signal    o_o_open_valid        :  std_logic;
    signal    o_o_close_info        :  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    signal    o_o_close_valid       :  std_logic;
    signal    o_o_stop              :  std_logic;
    signal    i_open                :  std_logic;
    signal    i_done                :  std_logic;
    signal    i_error               :  std_logic;
    signal    i_i_open_info         :  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    signal    i_i_open_valid        :  std_logic;
    signal    i_i_close_info        :  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    signal    i_i_close_valid       :  std_logic;
    signal    i_o_open_info         :  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    signal    i_o_open_valid        :  std_logic;
    signal    i_o_close_info        :  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    signal    i_o_close_valid       :  std_logic;
    -------------------------------------------------------------------------------
    -- データバスのビット数の２のべき乗値を計算する.
    -------------------------------------------------------------------------------
    function CALC_DATA_SIZE(WIDTH:integer) return integer is
        variable value : integer;
    begin
        value := 0;
        while (2**(value) < WIDTH) loop
            value := value + 1;
        end loop;
        return value;
    end function;
    ------------------------------------------------------------------------------
    -- バッファのデータ幅のビット数を２のべき乗値で示す.
    ------------------------------------------------------------------------------
    constant  BUF_DATA_BIT_SIZE     :  integer := CALC_DATA_SIZE(BUF_WIDTH);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    buf_ren               :  std_logic;
    signal    buf_rptr              :  std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal    buf_rdata             :  std_logic_vector(BUF_WIDTH      -1 downto 0);
    signal    buf_wen               :  std_logic;
    signal    buf_we                :  std_logic_vector(BUF_WIDTH/8    -1 downto 0);
    signal    buf_ben               :  std_logic_vector(BUF_WIDTH/8    -1 downto 0);
    signal    buf_wdata             :  std_logic_vector(BUF_WIDTH      -1 downto 0);
    signal    buf_wptr              :  std_logic_vector(BUF_DEPTH      -1 downto 0);
    -------------------------------------------------------------------------------
    -- レジスタアクセスインターフェースのアドレスのビット数.
    -------------------------------------------------------------------------------
    constant  REGS_ADDR_WIDTH       :  integer := 5;
    -------------------------------------------------------------------------------
    -- 全レジスタのビット数.
    -------------------------------------------------------------------------------
    constant  REGS_DATA_BITS        :  integer := (2**REGS_ADDR_WIDTH)*8;
    -------------------------------------------------------------------------------
    -- レジスタアクセスインターフェースのデータのビット数.
    -------------------------------------------------------------------------------
    constant  REGS_DATA_WIDTH       :  integer := 32;
    -------------------------------------------------------------------------------
    -- レジスタアクセス用の信号群.
    -------------------------------------------------------------------------------
    signal    regs_load             :  std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal    regs_wbit             :  std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal    regs_rbit             :  std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Pump Outlet Registers
    -------------------------------------------------------------------------------
    --           31            24              16               8               0
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x00 |                       Address[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x04 |                       Address[63:31]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x08 |                          Size[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x0C | Control[7:0]  |  Status[7:0]  |          Mode[15:00]          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x10 |                     OPEN_INFO[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x14 |                    CLOSE_INFO[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -------------------------------------------------------------------------------
    constant  O_REGS_BASE_ADDR      :  integer := 16#00#;
    constant  O_REGS_BITS           :  integer := 128;
    constant  O_REGS_LO             :  integer := 8*O_REGS_BASE_ADDR;
    constant  O_REGS_HI             :  integer := O_REGS_LO + O_REGS_BITS - 1;
    -------------------------------------------------------------------------------
    -- Pump Outlet Address Register
    -------------------------------------------------------------------------------
    -- Address     = 転送開始アドレス.
    -------------------------------------------------------------------------------
    constant  O_ADDR_REGS_ADDR      :  integer := O_REGS_BASE_ADDR + 16#00#;
    constant  O_ADDR_REGS_BITS      :  integer := 64;
    constant  O_ADDR_REGS_LO        :  integer := 8*O_ADDR_REGS_ADDR;
    constant  O_ADDR_REGS_HI        :  integer := 8*O_ADDR_REGS_ADDR + O_ADDR_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Outlet Size Register
    -------------------------------------------------------------------------------
    -- Size[31:00] = 転送サイズ.
    -------------------------------------------------------------------------------
    constant  O_SIZE_REGS_ADDR      :  integer := O_REGS_BASE_ADDR + 16#08#;
    constant  O_SIZE_REGS_BITS      :  integer := 32;
    constant  O_SIZE_REGS_LO        :  integer := 8*O_SIZE_REGS_ADDR;
    constant  O_SIZE_REGS_HI        :  integer := 8*O_SIZE_REGS_ADDR + O_SIZE_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Outlet Mode Register
    -------------------------------------------------------------------------------
    -- Mode[15]    = 1:AXI4 Master Read I/F をセイフティモードで動かす.
    -- Mode[14]    = 1:AXI4 Master Read I/F を投機モードで動かす.
    -- Mode[13]    = 1:AXI4 Master Read I/F をアドレス固定モードにする.
    -- Mode[11:08] = AXI4 Master Read I/F の ARUSER の値を指定する.
    -- Mode[07:04] = AXI4 Master Read I/F のキャッシュモードを指定する.
    -- Mode[01]    = 1:エラー発生時(Status[1]='1')に割り込みを発生する.
    -- Mode[00]    = 1:転送終了時(Status[0]='1')に割り込みを発生する.
    -------------------------------------------------------------------------------
    constant  O_MODE_REGS_ADDR      :  integer := O_REGS_BASE_ADDR + 16#0C#;
    constant  O_MODE_REGS_BITS      :  integer := 16;
    constant  O_MODE_REGS_HI        :  integer := 8*O_MODE_REGS_ADDR + 15;
    constant  O_MODE_REGS_LO        :  integer := 8*O_MODE_REGS_ADDR +  0;
    constant  O_MODE_SAFETY_POS     :  integer := 8*O_MODE_REGS_ADDR + 15;
    constant  O_MODE_SPECUL_POS     :  integer := 8*O_MODE_REGS_ADDR + 14;
    constant  O_MODE_AFIX_POS       :  integer := 8*O_MODE_REGS_ADDR + 13;
    constant  O_MODE_AUSER_HI       :  integer := 8*O_MODE_REGS_ADDR + 12;
    constant  O_MODE_AUSER_LO       :  integer := 8*O_MODE_REGS_ADDR +  8;
    constant  O_MODE_CACHE_HI       :  integer := 8*O_MODE_REGS_ADDR +  7;
    constant  O_MODE_CACHE_LO       :  integer := 8*O_MODE_REGS_ADDR +  4;
    constant  O_MODE_CLOSE_POS      :  integer := 8*O_MODE_REGS_ADDR +  2;
    constant  O_MODE_ERROR_POS      :  integer := 8*O_MODE_REGS_ADDR +  1;
    constant  O_MODE_DONE_POS       :  integer := 8*O_MODE_REGS_ADDR +  0;
    -------------------------------------------------------------------------------
    -- Pump Outlet Status Register
    -------------------------------------------------------------------------------
    -- Status[7:2] = 予約.
    -- Status[1]   = エラー発生時にセットされる.
    -- Status[0]   = 転送終了時かつ Control[2]='1' にセットされる.
    -------------------------------------------------------------------------------
    constant  O_STAT_REGS_ADDR      :  integer := O_REGS_BASE_ADDR + 16#0E#;
    constant  O_STAT_REGS_BITS      :  integer := 8;
    constant  O_STAT_RESV_HI        :  integer := 8*O_STAT_REGS_ADDR +  7;
    constant  O_STAT_RESV_LO        :  integer := 8*O_STAT_REGS_ADDR +  3;
    constant  O_STAT_CLOSE_POS      :  integer := 8*O_STAT_REGS_ADDR +  2;
    constant  O_STAT_ERROR_POS      :  integer := 8*O_STAT_REGS_ADDR +  1;
    constant  O_STAT_DONE_POS       :  integer := 8*O_STAT_REGS_ADDR +  0;
    constant  O_STAT_RESV_BITS      :  integer := O_STAT_RESV_HI - O_STAT_RESV_LO + 1;
    constant  O_STAT_RESV_NULL      :  std_logic_vector(O_STAT_RESV_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Pump Outlet Control Register
    -------------------------------------------------------------------------------
    -- Control[7]  = 1:モジュールをリセットする. 0:リセットを解除する.
    -- Control[6]  = 1:転送を一時中断する.       0:転送を再開する.
    -- Control[5]  = 1:転送を中止する.           0:意味無し.
    -- Control[4]  = 1:転送を開始する.           0:意味無し.
    -- Control[3]  = 予約.
    -- Control[2]  = 1:転送終了時にStatus[0]がセットされる.
    -- Control[1]  = 1:連続したトランザクションの開始を指定する.
    -- Control[0]  = 1:連続したトランザクションの終了を指定する.
    -------------------------------------------------------------------------------
    constant  O_CTRL_REGS_ADDR      :  integer := O_REGS_BASE_ADDR + 16#0F#;
    constant  O_CTRL_RESET_POS      :  integer := 8*O_CTRL_REGS_ADDR +  7;
    constant  O_CTRL_PAUSE_POS      :  integer := 8*O_CTRL_REGS_ADDR +  6;
    constant  O_CTRL_STOP_POS       :  integer := 8*O_CTRL_REGS_ADDR +  5;
    constant  O_CTRL_START_POS      :  integer := 8*O_CTRL_REGS_ADDR +  4;
    constant  O_CTRL_RESV_POS       :  integer := 8*O_CTRL_REGS_ADDR +  3;
    constant  O_CTRL_DONE_POS       :  integer := 8*O_CTRL_REGS_ADDR +  2;
    constant  O_CTRL_FIRST_POS      :  integer := 8*O_CTRL_REGS_ADDR +  1;
    constant  O_CTRL_LAST_POS       :  integer := 8*O_CTRL_REGS_ADDR +  0;
    -------------------------------------------------------------------------------
    -- Pump Outlet Open Infomation Register
    -------------------------------------------------------------------------------
    constant  O_OPEN_REGS_ADDR      :  integer := O_REGS_BASE_ADDR + 16#10#;
    constant  O_OPEN_REGS_BITS      :  integer := OPEN_INFO_BITS;
    constant  O_OPEN_REGS_LO        :  integer := 8*O_OPEN_REGS_ADDR;
    constant  O_OPEN_REGS_HI        :  integer := 8*O_OPEN_REGS_ADDR + O_OPEN_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Outlet Close Infomation Register
    -------------------------------------------------------------------------------
    constant  O_CLOSE_REGS_ADDR     :  integer := O_REGS_BASE_ADDR + 16#14#;
    constant  O_CLOSE_REGS_BITS     :  integer := CLOSE_INFO_BITS;
    constant  O_CLOSE_REGS_LO       :  integer := 8*O_CLOSE_REGS_ADDR;
    constant  O_CLOSE_REGS_HI       :  integer := 8*O_CLOSE_REGS_ADDR + O_CLOSE_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Reserve Register
    -------------------------------------------------------------------------------
    constant  O_RESV_REGS_ADDR      :  integer := O_REGS_BASE_ADDR + 16#18#;
    constant  O_RESV_REGS_BITS      :  integer := 64;
    constant  O_RESV_REGS_LO        :  integer := 8*O_RESV_REGS_ADDR;
    constant  O_RESV_REGS_HI        :  integer := 8*O_RESV_REGS_ADDR + O_RESV_REGS_BITS-1;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    RST <= '1' when (ARESETn = '0') else '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    CSR_IF: block
        constant sig_1          : std_logic := '1';
        signal   regs_req       : std_logic;
        signal   regs_write     : std_logic;
        signal   regs_ack       : std_logic;
        signal   regs_err       : std_logic;
        signal   regs_addr      : std_logic_vector(REGS_ADDR_WIDTH  -1 downto 0);
        signal   regs_ben       : std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
        signal   regs_wdata     : std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
        signal   regs_rdata     : std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
    begin 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        AXI4: AXI4_REGISTER_INTERFACE                  --
            generic map (                              -- 
                AXI4_ADDR_WIDTH => C_ADDR_WIDTH      , --
                AXI4_DATA_WIDTH => C_DATA_WIDTH      , --
                AXI4_ID_WIDTH   => C_ID_WIDTH        , --
                REGS_ADDR_WIDTH => REGS_ADDR_WIDTH   , --
                REGS_DATA_WIDTH => REGS_DATA_WIDTH     --
            )                                          -- 
            port map (                                 -- 
            -----------------------------------------------------------------------
            -- Clock and Reset Signals.
            -----------------------------------------------------------------------
                CLK             => O_CLK             , -- In  :
                RST             => RST               , -- In  :
                CLR             => CLR               , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Read Address Channel Signals.
            -----------------------------------------------------------------------
                ARID            => C_ARID            , -- In  :
                ARADDR          => C_ARADDR          , -- In  :
                ARLEN           => C_ARLEN           , -- In  :
                ARSIZE          => C_ARSIZE          , -- In  :
                ARBURST         => C_ARBURST         , -- In  :
                ARVALID         => C_ARVALID         , -- In  :
                ARREADY         => C_ARREADY         , -- Out :
            -----------------------------------------------------------------------
            -- AXI4 Read Data Channel Signals.
            -----------------------------------------------------------------------
                RID             => C_RID             , -- Out :
                RDATA           => C_RDATA           , -- Out :
                RRESP           => C_RRESP           , -- Out :
                RLAST           => C_RLAST           , -- Out :
                RVALID          => C_RVALID          , -- Out :
                RREADY          => C_RREADY          , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Write Address Channel Signals.
            -----------------------------------------------------------------------
                AWID            => C_AWID            , -- In  :
                AWADDR          => C_AWADDR          , -- In  :
                AWLEN           => C_AWLEN           , -- In  :
                AWSIZE          => C_AWSIZE          , -- In  :
                AWBURST         => C_AWBURST         , -- In  :
                AWVALID         => C_AWVALID         , -- In  :
                AWREADY         => C_AWREADY         , -- Out :
            -----------------------------------------------------------------------
            -- AXI4 Write Data Channel Signals.
            -----------------------------------------------------------------------
                WDATA           => C_WDATA           , -- In  :
                WSTRB           => C_WSTRB           , -- In  :
                WLAST           => C_WLAST           , -- In  :
                WVALID          => C_WVALID          , -- In  :
                WREADY          => C_WREADY          , -- Out :
            -----------------------------------------------------------------------
            -- AXI4 Write Response Channel Signals.
            -----------------------------------------------------------------------
                BID             => C_BID             , -- Out :
                BRESP           => C_BRESP           , -- Out :
                BVALID          => C_BVALID          , -- Out :
                BREADY          => C_BREADY          , -- In  :
            -----------------------------------------------------------------------
            -- Register Interface.
            -----------------------------------------------------------------------
                REGS_REQ        => regs_req          , -- Out :
                REGS_WRITE      => regs_write        , -- Out :
                REGS_ACK        => regs_ack          , -- In  :
                REGS_ERR        => regs_err          , -- In  :
                REGS_ADDR       => regs_addr         , -- Out :
                REGS_BEN        => regs_ben          , -- Out :
                REGS_WDATA      => regs_wdata        , -- Out :
                REGS_RDATA      => regs_rdata          -- In  :
            );
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        DEC: REGISTER_ACCESS_ADAPTER                   -- 
            generic map (                              -- 
                ADDR_WIDTH      => REGS_ADDR_WIDTH   , -- 
                DATA_WIDTH      => REGS_DATA_WIDTH   , -- 
                WBIT_MIN        => regs_wbit'low     , -- 
                WBIT_MAX        => regs_wbit'high    , -- 
                RBIT_MIN        => regs_rbit'low     , -- 
                RBIT_MAX        => regs_rbit'high    , -- 
                I_CLK_RATE      => 1                 , -- 
                O_CLK_RATE      => 1                 , -- 
                O_CLK_REGS      => 0                   -- 
            )                                          -- 
            port map (                                 -- 
                RST             => RST               , -- In  :
                I_CLK           => O_CLK             , -- In  :
                I_CLR           => CLR               , -- In  :
                I_CKE           => sig_1             , -- In  :
                I_REQ           => regs_req          , -- In  :
                I_SEL           => sig_1             , -- In  :
                I_WRITE         => regs_write        , -- In  :
                I_ADDR          => regs_addr         , -- In  :
                I_BEN           => regs_ben          , -- In  :
                I_WDATA         => regs_wdata        , -- In  :
                I_RDATA         => regs_rdata        , -- Out :
                I_ACK           => regs_ack          , -- Out :
                I_ERR           => regs_err          , -- Out :
                O_CLK           => O_CLK             , -- In  :
                O_CLR           => CLR               , -- In  :
                O_CKE           => sig_1             , -- In  :
                O_WDATA         => regs_wbit         , -- Out :
                O_WLOAD         => regs_load         , -- Out :
                O_RDATA         => regs_rbit           -- In  :
            );                                         -- 
    end block;                                         -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_IF: AXI4_MASTER_WRITE_INTERFACE                  -- 
        generic map (                                  -- 
            AXI4_ADDR_WIDTH     => O_ADDR_WIDTH      , -- 
            AXI4_DATA_WIDTH     => O_DATA_WIDTH      , --   
            AXI4_ID_WIDTH       => O_ID_WIDTH        , --   
            VAL_BITS            => 1                 , --   
            REQ_SIZE_BITS       => O_REQ_SIZE_BITS   , --   
            REQ_SIZE_VALID      => 1                 , --   
            FLOW_VALID          => O_FLOW_VALID      , --   
            BUF_DATA_WIDTH      => BUF_WIDTH         , --   
            BUF_PTR_BITS        => BUF_DEPTH         , --   
            ALIGNMENT_BITS      => 8                 , --   
            XFER_SIZE_BITS      => BUF_DEPTH+1       , --   
            XFER_MIN_SIZE       => O_XFER_MIN_SIZE   , --   
            XFER_MAX_SIZE       => O_XFER_MAX_SIZE   , --   
            QUEUE_SIZE          => O_REQ_QUEUE       , --   
            REQ_REGS            => O_REQ_REGS        , --   
            ACK_REGS            => O_ACK_REGS        , --   
            RESP_REGS           => O_RESP_REGS         --   
        )                                              -- 
        port map(                                      --
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK                 => O_CLK             , -- In  :
            RST                 => RST               , -- In  :
            CLR                 => CLR               , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Write Address Channel Signals.
        --------------------------------------------------------------------------
            AWID                => O_AWID              , -- Out :
            AWADDR              => O_AWADDR            , -- Out :
            AWLEN               => O_AWLEN             , -- Out :
            AWSIZE              => O_AWSIZE            , -- Out :
            AWBURST             => O_AWBURST           , -- Out :
            AWLOCK              => O_AWLOCK            , -- Out :
            AWCACHE             => O_AWCACHE           , -- Out :
            AWPROT              => O_AWPROT            , -- Out :
            AWQOS               => O_AWQOS             , -- Out :
            AWREGION            => O_AWREGION          , -- Out :
            AWVALID             => O_AWVALID           , -- Out :
            AWREADY             => O_AWREADY           , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Write Data Channel Signals.
        --------------------------------------------------------------------------
            WID                 => O_WID               , -- Out :
            WDATA               => O_WDATA             , -- Out :
            WSTRB               => O_WSTRB             , -- Out :
            WLAST               => O_WLAST             , -- Out :
            WVALID              => O_WVALID            , -- Out :
            WREADY              => O_WREADY            , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Write Response Channel Signals.
        --------------------------------------------------------------------------
            BID                 => O_BID               , -- In  :
            BRESP               => O_BRESP             , -- In  :
            BVALID              => O_BVALID            , -- In  :
            BREADY              => O_BREADY            , -- Out :
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
            XFER_SIZE_SEL       => "1"               , -- In  :
            REQ_ADDR            => o_req_addr        , -- In  :
            REQ_SIZE            => o_req_size        , -- In  :
            REQ_ID              => O_REQ_ID          , -- In  :
            REQ_BURST           => AXI4_ABURST_INCR  , -- In  :
            REQ_LOCK            => O_REQ_LOCK        , -- In  :
            REQ_CACHE           => o_req_cache       , -- In  :
            REQ_PROT            => O_REQ_PROT        , -- In  :
            REQ_QOS             => O_REQ_QOS         , -- In  :
            REQ_REGION          => O_REQ_REGION      , -- In  :
            REQ_BUF_PTR         => o_req_buf_ptr     , -- In  :
            REQ_FIRST           => o_req_first       , -- In  :
            REQ_LAST            => o_req_last        , -- In  :
            REQ_SPECULATIVE     => o_req_speculative , -- In  :
            REQ_SAFETY          => o_req_safety      , -- In  :
            REQ_VAL(0)          => o_req_valid       , -- In  :
            REQ_RDY             => o_req_ready       , -- Out :
        ---------------------------------------------------------------------------
        -- Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            ACK_VAL(0)          => o_ack_valid       , -- Out :
            ACK_NEXT            => o_ack_next        , -- Out :
            ACK_LAST            => o_ack_last        , -- Out :
            ACK_ERROR           => o_ack_error       , -- Out :
            ACK_STOP            => o_ack_stop        , -- Out :
            ACK_NONE            => o_ack_none        , -- Out :
            ACK_SIZE            => o_ack_size        , -- Out :
        ---------------------------------------------------------------------------
        -- Transfer Status Signal.
        ---------------------------------------------------------------------------
            XFER_BUSY(0)        => o_xfer_busy       , -- Out :
            XFER_ERROR(0)       => o_xfer_error      , -- Out :
            XFER_DONE(0)        => o_xfer_done       , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_STOP           => o_flow_stop       , -- In  :
            FLOW_PAUSE          => o_flow_pause      , -- In  :
            FLOW_LAST           => o_flow_last       , -- In  :
            FLOW_SIZE           => o_flow_size       , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Reserve Size Signals.
        ---------------------------------------------------------------------------
            PULL_RSV_VAL(0)     => o_pull_rsv_valid  , -- Out :
            PULL_RSV_LAST       => o_pull_rsv_last   , -- Out :
            PULL_RSV_ERROR      => o_pull_rsv_error  , -- Out :
            PULL_RSV_SIZE       => o_pull_rsv_size   , -- Out :
        ---------------------------------------------------------------------------
        -- Pull Final Size Signals.
        ---------------------------------------------------------------------------
            PULL_FIN_VAL(0)     => o_pull_fin_valid  , -- Out :
            PULL_FIN_LAST       => o_pull_fin_last   , -- Out :
            PULL_FIN_ERROR      => o_pull_fin_error  , -- Out :
            PULL_FIN_SIZE       => o_pull_fin_size   , -- Out :
        ---------------------------------------------------------------------------
        -- Pull Buffer Size Signals.
        ---------------------------------------------------------------------------
            PULL_BUF_RESET(0)   => o_pull_buf_reset  , -- Out :
            PULL_BUF_VAL(0)     => o_pull_buf_valid  , -- Out :
            PULL_BUF_LAST       => o_pull_buf_last   , -- Out :
            PULL_BUF_ERROR      => o_pull_buf_error  , -- Out :
            PULL_BUF_SIZE       => o_pull_buf_size   , -- Out :
            PULL_BUF_RDY(0)     => o_pull_buf_ready  , -- In  :
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_REN(0)          => buf_ren           , -- Out :
            BUF_DATA            => buf_rdata         , -- Out :
            BUF_PTR             => buf_rptr            -- Out :
        );
    O_ARID     <= (others => '0');
    O_ARADDR   <= (others => '0');
    O_ARLEN    <= (others => '0');
    O_ARSIZE   <= (others => '0');
    O_ARBURST  <= (others => '0');
    O_ARLOCK   <= (others => '0');
    O_ARCACHE  <= (others => '0');
    O_ARPROT   <= (others => '0');
    O_ARQOS    <= (others => '0');
    O_ARREGION <= (others => '0');
    O_ARUSER   <= (others => '0');
    O_ARVALID  <= '0';
    O_RREADY   <= '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    INFO: block
    begin
        process(O_CLK, RST) begin
            if (RST = '1') then
                o_i_open_info  <= (others => '0');
                o_i_close_info <= (others => '0');
                o_q_open_info  <= (others => '0');
                o_q_close_info <= (others => '0');
            elsif (O_CLK'event and O_CLK = '1') then
                for i in o_i_open_info'range loop
                    if (regs_load(O_OPEN_REGS_LO + i) = '1') then
                        o_i_open_info(i)  <= regs_wbit(O_OPEN_REGS_LO + i);
                    end if;
                end loop;
                for i in o_i_close_info'range loop
                    if (regs_load(O_CLOSE_REGS_LO + i) = '1') then
                        o_i_close_info(i) <= regs_wbit(O_CLOSE_REGS_LO + i);
                    end if;
                end loop;
                if (o_o_open_valid = '1') then
                    o_q_open_info  <= o_o_open_info;
                end if;
                if (o_o_close_valid = '1') then
                    o_q_close_info <= o_o_close_info;
                end if;
            end if;
        end process;
        regs_rbit(O_OPEN_REGS_HI  downto O_OPEN_REGS_LO ) <= o_q_open_info;
        regs_rbit(O_CLOSE_REGS_HI downto O_CLOSE_REGS_LO) <= o_q_close_info;
        regs_rbit(O_RESV_REGS_HI  downto O_RESV_REGS_LO ) <= (O_RESV_REGS_HI downto O_RESV_REGS_LO => '0');
        i_i_open_valid  <= i_o_open_valid;
        i_i_open_info   <= i_o_open_info;
        i_i_close_valid <= i_o_close_valid;
        i_i_close_info  <= i_o_close_info;
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    CTRL: PUMP_STREAM_OUTLET_CONTROLLER
        generic map (
            O_CLK_RATE          => O_CLK_RATE          , --
            O_REQ_ADDR_VALID    => O_REQ_ADDR_VALID    , --
            O_REQ_ADDR_BITS     => O_ADDR_WIDTH        , --
            O_REG_ADDR_BITS     => O_ADDR_REGS_BITS    , --
            O_REQ_SIZE_VALID    => O_REQ_SIZE_VALID    , --
            O_REQ_SIZE_BITS     => O_REQ_SIZE_BITS     , --
            O_REG_SIZE_BITS     => O_SIZE_REGS_BITS    , --
            O_REG_MODE_BITS     => O_MODE_REGS_BITS    , --
            O_REG_STAT_BITS     => O_STAT_RESV_BITS    , --
            O_USE_PULL_BUF_SIZE => O_USE_PULL_BUF_SIZE , --
            O_FIXED_FLOW_OPEN   => O_FIXED_FLOW_OPEN   , --
            O_FIXED_POOL_OPEN   => O_FIXED_POOL_OPEN   , --
            I_CLK_RATE          => I_CLK_RATE          , --
            I_DATA_BITS         => I_DATA_WIDTH        , --
            BUF_DEPTH           => BUF_DEPTH           , --
            BUF_DATA_BITS       => BUF_WIDTH           , --
            O2I_OPEN_INFO_BITS  => OPEN_INFO_BITS      , --
            O2I_CLOSE_INFO_BITS => CLOSE_INFO_BITS     , --
            I2O_OPEN_INFO_BITS  => OPEN_INFO_BITS      , --
            I2O_CLOSE_INFO_BITS => CLOSE_INFO_BITS     , --
            I2O_DELAY_CYCLE     => 1                     --
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        --Reset Signals.
        ---------------------------------------------------------------------------
            RST                 => RST                 , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Clock and Clock Enable.
        ---------------------------------------------------------------------------
            O_CLK               => O_CLK               , --  In  :
            O_CLR               => '0'                 , --  In  :
            O_CKE               => O_CKE               , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Control Register Interface.
        ---------------------------------------------------------------------------
            O_ADDR_L            => regs_load(O_ADDR_REGS_HI downto O_ADDR_REGS_LO), --  In  :
            O_ADDR_D            => regs_wbit(O_ADDR_REGS_HI downto O_ADDR_REGS_LO), --  In  :
            O_ADDR_Q            => regs_rbit(O_ADDR_REGS_HI downto O_ADDR_REGS_LO), --  Out :
            O_SIZE_L            => regs_load(O_SIZE_REGS_HI downto O_SIZE_REGS_LO), --  In  :
            O_SIZE_D            => regs_wbit(O_SIZE_REGS_HI downto O_SIZE_REGS_LO), --  In  :
            O_SIZE_Q            => regs_rbit(O_SIZE_REGS_HI downto O_SIZE_REGS_LO), --  Out :
            O_MODE_L            => regs_load(O_MODE_REGS_HI downto O_MODE_REGS_LO), --  In  :
            O_MODE_D            => regs_wbit(O_MODE_REGS_HI downto O_MODE_REGS_LO), --  In  :
            O_MODE_Q            => regs_rbit(O_MODE_REGS_HI downto O_MODE_REGS_LO), --  Out :
            O_STAT_L            => regs_load(O_STAT_RESV_HI downto O_STAT_RESV_LO), --  In  :
            O_STAT_D            => regs_wbit(O_STAT_RESV_HI downto O_STAT_RESV_LO), --  In  :
            O_STAT_Q            => regs_rbit(O_STAT_RESV_HI downto O_STAT_RESV_LO), --  Out :
            O_STAT_I            => O_STAT_RESV_NULL                               , --  In  :
            O_RESET_L           => regs_load(O_CTRL_RESET_POS)                    , --  In  :
            O_RESET_D           => regs_wbit(O_CTRL_RESET_POS)                    , --  In  :
            O_RESET_Q           => regs_rbit(O_CTRL_RESET_POS)                    , --  Out :
            O_START_L           => regs_load(O_CTRL_START_POS)                    , --  In  :
            O_START_D           => regs_wbit(O_CTRL_START_POS)                    , --  In  :
            O_START_Q           => regs_rbit(O_CTRL_START_POS)                    , --  Out :
            O_STOP_L            => regs_load(O_CTRL_STOP_POS )                    , --  In  :
            O_STOP_D            => regs_wbit(O_CTRL_STOP_POS )                    , --  In  :
            O_STOP_Q            => regs_rbit(O_CTRL_STOP_POS )                    , --  Out :
            O_PAUSE_L           => regs_load(O_CTRL_PAUSE_POS)                    , --  In  :
            O_PAUSE_D           => regs_wbit(O_CTRL_PAUSE_POS)                    , --  In  :
            O_PAUSE_Q           => regs_rbit(O_CTRL_PAUSE_POS)                    , --  Out :
            O_FIRST_L           => regs_load(O_CTRL_FIRST_POS)                    , --  In  :
            O_FIRST_D           => regs_wbit(O_CTRL_FIRST_POS)                    , --  In  :
            O_FIRST_Q           => regs_rbit(O_CTRL_FIRST_POS)                    , --  Out :
            O_LAST_L            => regs_load(O_CTRL_LAST_POS )                    , --  In  :
            O_LAST_D            => regs_wbit(O_CTRL_LAST_POS )                    , --  In  :
            O_LAST_Q            => regs_rbit(O_CTRL_LAST_POS )                    , --  Out :
            O_DONE_EN_L         => regs_load(O_CTRL_DONE_POS )                    , --  In  :
            O_DONE_EN_D         => regs_wbit(O_CTRL_DONE_POS )                    , --  In  :
            O_DONE_EN_Q         => regs_rbit(O_CTRL_DONE_POS )                    , --  Out :
            O_DONE_ST_L         => regs_load(O_STAT_DONE_POS )                    , --  In  :
            O_DONE_ST_D         => regs_wbit(O_STAT_DONE_POS )                    , --  In  :
            O_DONE_ST_Q         => regs_rbit(O_STAT_DONE_POS )                    , --  Out :
            O_ERR_ST_L          => regs_load(O_STAT_ERROR_POS)                    , --  In  :
            O_ERR_ST_D          => regs_wbit(O_STAT_ERROR_POS)                    , --  In  :
            O_ERR_ST_Q          => regs_rbit(O_STAT_ERROR_POS)                    , --  Out :
            O_CLOSE_ST_L        => regs_load(O_STAT_CLOSE_POS)                    , --  In  :
            O_CLOSE_ST_D        => regs_wbit(O_STAT_CLOSE_POS)                    , --  In  :
            O_CLOSE_ST_Q        => regs_rbit(O_STAT_CLOSE_POS)                    , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Configuration Signals.
        ---------------------------------------------------------------------------
            O_ADDR_FIX          => O_ADDR_FIX          , --  In  :
            O_BUF_READY_LEVEL   => O_BUF_READY_LEVEL   , --  In  :
            O_FLOW_READY_LEVEL  => O_FLOW_READY_LEVEL  , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Transaction Command Request Signals.
        ---------------------------------------------------------------------------
            O_REQ_VALID         => o_req_valid         , --  Out :
            O_REQ_ADDR          => o_req_addr          , --  Out :
            O_REQ_SIZE          => o_req_size          , --  Out :
            O_REQ_BUF_PTR       => o_req_buf_ptr       , --  Out :
            O_REQ_FIRST         => o_req_first         , --  Out :
            O_REQ_LAST          => o_req_last          , --  Out :
            O_REQ_NONE          => o_req_none          , --  Out :
            O_REQ_READY         => o_req_ready         , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Transaction Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            O_ACK_VALID         => o_ack_valid         , --  In  :
            O_ACK_SIZE          => o_ack_size          , --  In  :
            O_ACK_ERROR         => o_ack_error         , --  In  :
            O_ACK_NEXT          => o_ack_next          , --  In  :
            O_ACK_LAST          => o_ack_last          , --  In  :
            O_ACK_STOP          => o_ack_stop          , --  In  :
            O_ACK_NONE          => o_ack_none          , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Transfer Status Signals.
        ---------------------------------------------------------------------------
            O_XFER_BUSY         => o_xfer_busy         , --  In  :
            O_XFER_DONE         => o_xfer_done         , --  In  :
            O_XFER_ERROR        => o_xfer_error        , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            O_FLOW_READY        => o_flow_ready        , --  Out :
            O_FLOW_PAUSE        => o_flow_pause        , --  Out :
            O_FLOW_STOP         => o_flow_stop         , --  Out :
            O_FLOW_LAST         => o_flow_last         , --  Out :
            O_FLOW_SIZE         => o_flow_size         , --  Out :
            O_PULL_FIN_VALID    => o_pull_fin_valid    , --  In  :
            O_PULL_FIN_LAST     => o_pull_fin_last     , --  In  :
            O_PULL_FIN_ERROR    => o_pull_fin_error    , --  In  :
            O_PULL_FIN_SIZE     => o_pull_fin_size     , --  In  :
            O_PULL_RSV_VALID    => o_pull_rsv_valid    , --  In  :
            O_PULL_RSV_LAST     => o_pull_rsv_last     , --  In  :
            O_PULL_RSV_ERROR    => o_pull_rsv_error    , --  In  :
            O_PULL_RSV_SIZE     => o_pull_rsv_size     , --  In  :
            O_PULL_BUF_RESET    => o_pull_buf_reset    , --  In  :
            O_PULL_BUF_VALID    => o_pull_buf_valid    , --  In  :
            O_PULL_BUF_LAST     => o_pull_buf_last     , --  In  :
            O_PULL_BUF_ERROR    => o_pull_buf_error    , --  In  :
            O_PULL_BUF_SIZE     => o_pull_buf_size     , --  In  :
            O_PULL_BUF_READY    => o_pull_buf_ready    , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Status.
        ---------------------------------------------------------------------------
            O_OPEN              => o_open              , --  Out :
            O_TRAN_BUSY         => o_tran_busy         , --  Out :
            O_TRAN_DONE         => o_tran_done         , --  Out :
            O_TRAN_ERROR        => o_tran_error        , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Open/Close Infomation Interface
        ---------------------------------------------------------------------------
            O_O2I_OPEN_INFO     => o_i_open_info       , --  In  :
            O_O2I_CLOSE_INFO    => o_i_close_info      , --  In  :
            O_I2O_OPEN_INFO     => o_o_open_info       , --  Out :
            O_I2O_OPEN_VALID    => o_o_open_valid      , --  Out :
            O_I2O_CLOSE_INFO    => o_o_close_info      , --  Out :
            O_I2O_CLOSE_VALID   => o_o_close_valid     , --  Out :
            O_I2O_STOP          => o_o_stop            , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Clock and Clock Enable.
        ---------------------------------------------------------------------------
            I_CLK               => I_CLK               , --  In  :
            I_CLR               => '0'                 , --  In  :
            I_CKE               => I_CKE               , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Stream Interface.
        ---------------------------------------------------------------------------
            I_DATA              => I_DATA              , --  In  :
            I_STRB              => I_STRB              , --  In  :
            I_LAST              => I_LAST              , --  In  :
            I_VALID             => I_VALID             , --  In  :
            I_READY             => I_READY             , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Status.
        ---------------------------------------------------------------------------
            I_OPEN              => i_open              , --  Out :
            I_DONE              => i_done              , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Open/Close Infomation Interface
        ---------------------------------------------------------------------------
            I_I2O_STOP          => I_I2O_STOP          , --  In  :
            I_I2O_OPEN_INFO     => i_i_open_info       , --  In  :
            I_I2O_OPEN_VALID    => i_i_open_valid      , --  In  :
            I_I2O_CLOSE_INFO    => i_i_close_info      , --  In  :
            I_I2O_CLOSE_VALID   => i_i_close_valid     , --  In  :
            I_O2I_RESET         => I_O2I_RESET         , --  Out :
            I_O2I_STOP          => I_O2I_STOP          , --  Out :
            I_O2I_ERROR         => I_O2I_ERROR         , --  Out :
            I_O2I_NONE          => I_O2I_NONE          , --  Out :
            I_O2I_OPEN_INFO     => i_o_open_info       , --  Out :
            I_O2I_OPEN_VALID    => i_o_open_valid      , --  Out :
            I_O2I_CLOSE_INFO    => i_o_close_info      , --  Out :
            I_O2I_CLOSE_VALID   => i_o_close_valid     , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Buffer Read Interface.
        ---------------------------------------------------------------------------
            BUF_WEN             => buf_wen             , --  Out :
            BUF_BEN             => buf_ben             , --  Out :
            BUF_PTR             => buf_wptr            , --  Out :
            BUF_DATA            => buf_wdata             --  Out :
        );                                               --
    regs_rbit(O_CTRL_RESV_POS) <= '0';
    o_req_cache       <= regs_rbit(O_MODE_CACHE_HI downto O_MODE_CACHE_LO);
    o_req_speculative <= regs_rbit(O_MODE_SPECUL_POS);
    o_req_safety      <= regs_rbit(O_MODE_SAFETY_POS);
    O_AWUSER          <= std_logic_vector(resize(unsigned(regs_rbit(O_MODE_AUSER_HI downto O_MODE_AUSER_LO)), O_AUSER_WIDTH));
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process (O_CLK, RST) begin
        if (RST = '1') then
                IRQ <= '0';
        elsif (O_CLK'event and O_CLK = '1') then
            if (CLR = '1') then
                IRQ <= '0';
            elsif (regs_rbit(O_STAT_CLOSE_POS) = '1' and regs_rbit(O_MODE_CLOSE_POS) = '1') or
                  (regs_rbit(O_STAT_DONE_POS ) = '1' and regs_rbit(O_MODE_DONE_POS ) = '1') or
                  (regs_rbit(O_STAT_ERROR_POS) = '1' and regs_rbit(O_MODE_ERROR_POS) = '1') then
                IRQ <= '1';
            else
                IRQ <= '0';
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    RAM: SDPRAM 
        generic map(
            DEPTH       => BUF_DEPTH+3         ,
            RWIDTH      => BUF_DATA_BIT_SIZE   , --
            WWIDTH      => BUF_DATA_BIT_SIZE   , --
            WEBIT       => BUF_DATA_BIT_SIZE-3 , --
            ID          => 0                     -- 
        )                                        -- 
        port map (                               -- 
            WCLK        => I_CLK               , -- In  :
            WE          => buf_we              , -- In  :
            WADDR       => buf_wptr(BUF_DEPTH-1 downto BUF_DATA_BIT_SIZE-3), -- In  :
            WDATA       => buf_wdata           , -- In  :
            RCLK        => O_CLK               , -- In  :
            RADDR       => buf_rptr(BUF_DEPTH-1 downto BUF_DATA_BIT_SIZE-3), -- In  :
            RDATA       => buf_rdata             -- Out :
        );
    buf_we <= buf_ben when (buf_wen = '1') else (others => '0');
end RTL;
