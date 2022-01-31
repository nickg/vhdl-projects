-----------------------------------------------------------------------------------
--!     @file    axi4_master_to_stream.vhd
--!     @brief   Pump Core Module (AXI4 to AXI4-Stream)
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
entity  AXI4_MASTER_TO_STREAM is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        C_ADDR_WIDTH    : integer range 1 to   64 := 32;
        C_DATA_WIDTH    : integer range 8 to 1024 := 32;
        C_ID_WIDTH      : integer                 :=  8;
        I_CLK_RATE      : integer                 :=  1;
        I_AXI_ID        : integer                 :=  1;
        I_ADDR_WIDTH    : integer range 1 to   64 := 32;
        I_DATA_WIDTH    : integer range 8 to 1024 := 32;
        I_ID_WIDTH      : integer                 :=  8;
        I_AUSER_WIDTH   : integer                 :=  4;
        I_MAX_XFER_SIZE : integer                 :=  8;
        I_QUEUE_SIZE    : integer                 :=  2;
        O_CLK_RATE      : integer                 :=  1;
        O_DATA_WIDTH    : integer                 := 32;
        BUF_WIDTH       : integer                 := 32;
        BUF_DEPTH       : integer                 := 12
    );
    port(
    -------------------------------------------------------------------------------
    -- Reset Signals.
    -------------------------------------------------------------------------------
        ARESETn         : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F Clock.
    -------------------------------------------------------------------------------
        I_CLK           : in    std_logic;
        I_CKE           : in    std_logic;
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
    -- Pump Intake I/F AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        I_AWID          : out   std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_AWADDR        : out   std_logic_vector(I_ADDR_WIDTH  -1 downto 0);
        I_AWLEN         : out   std_logic_vector(7 downto 0);
        I_AWSIZE        : out   std_logic_vector(2 downto 0);
        I_AWBURST       : out   std_logic_vector(1 downto 0);
        I_AWLOCK        : out   std_logic_vector(0 downto 0);
        I_AWCACHE       : out   std_logic_vector(3 downto 0);
        I_AWPROT        : out   std_logic_vector(2 downto 0);
        I_AWQOS         : out   std_logic_vector(3 downto 0);
        I_AWREGION      : out   std_logic_vector(3 downto 0);
        I_AWUSER        : out   std_logic_vector(I_AUSER_WIDTH -1 downto 0);
        I_AWVALID       : out   std_logic;
        I_AWREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        I_WDATA         : out   std_logic_vector(I_DATA_WIDTH  -1 downto 0);
        I_WSTRB         : out   std_logic_vector(I_DATA_WIDTH/8-1 downto 0);
        I_WLAST         : out   std_logic;
        I_WVALID        : out   std_logic;
        I_WREADY        : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        I_BID           : in    std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_BRESP         : in    std_logic_vector(1 downto 0);
        I_BVALID        : in    std_logic;
        I_BREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        I_ARID          : out   std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_ARADDR        : out   std_logic_vector(I_ADDR_WIDTH  -1 downto 0);
        I_ARLEN         : out   std_logic_vector(7 downto 0);
        I_ARSIZE        : out   std_logic_vector(2 downto 0);
        I_ARBURST       : out   std_logic_vector(1 downto 0);
        I_ARLOCK        : out   std_logic_vector(0 downto 0);
        I_ARCACHE       : out   std_logic_vector(3 downto 0);
        I_ARPROT        : out   std_logic_vector(2 downto 0);
        I_ARQOS         : out   std_logic_vector(3 downto 0);
        I_ARREGION      : out   std_logic_vector(3 downto 0);
        I_ARUSER        : out   std_logic_vector(I_AUSER_WIDTH -1 downto 0);
        I_ARVALID       : out   std_logic;
        I_ARREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        I_RID           : in    std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_RDATA         : in    std_logic_vector(I_DATA_WIDTH  -1 downto 0);
        I_RRESP         : in    std_logic_vector(1 downto 0);
        I_RLAST         : in    std_logic;
        I_RVALID        : in    std_logic;
        I_RREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F Clock.
    -------------------------------------------------------------------------------
        O_CLK           : in    std_logic;
        O_CKE           : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet Stream Interface.
    -------------------------------------------------------------------------------
        O_DATA          : out std_logic_vector(O_DATA_WIDTH   -1 downto 0);
        O_STRB          : out std_logic_vector(O_DATA_WIDTH/8 -1 downto 0);
        O_LAST          : out std_logic;
        O_VALID         : out std_logic;
        O_READY         : in  std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet Stop Interface.
    -------------------------------------------------------------------------------
        O_O2I_STOP      : in  std_logic;
        O_I2O_STOP      : out std_logic;
        O_I2O_RESET     : out std_logic;
        O_I2O_ERROR     : out std_logic;
        O_I2O_NONE      : out std_logic;
    -------------------------------------------------------------------------------
    -- Interrupt Request Signals.
    -------------------------------------------------------------------------------
        IRQ             : out   std_logic
    );
end AXI4_MASTER_TO_STREAM;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_READ_INTERFACE;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_REGISTER_INTERFACE;
use     PIPEWORK.COMPONENTS.REGISTER_ACCESS_ADAPTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_STREAM_INTAKE_CONTROLLER;
use     PIPEWORK.COMPONENTS.SDPRAM;
architecture RTL of AXI4_MASTER_TO_STREAM is
    -------------------------------------------------------------------------------
    -- リセット信号.
    -------------------------------------------------------------------------------
    signal    RST                   :  std_logic;
    constant  CLR                   :  std_logic := '0';
    ------------------------------------------------------------------------------
    -- 入力側のフロー制御用定数.
    ------------------------------------------------------------------------------
    constant  I_FLOW_VALID          :  integer := 1;
    constant  I_USE_PUSH_BUF_SIZE   :  integer := 0;
    constant  I_FIXED_FLOW_OPEN     :  integer := 0;
    constant  I_FIXED_POOL_OPEN     :  integer := 1;
    constant  I_REQ_ADDR_VALID      :  integer := 1;
    constant  I_REQ_SIZE_VALID      :  integer := 1;
    constant  I_FLOW_READY_LEVEL    :  std_logic_vector(BUF_DEPTH downto 0)
                                    := std_logic_vector(to_unsigned(2**BUF_DEPTH-2**I_MAX_XFER_SIZE, BUF_DEPTH+1));
    constant  I_BUF_READY_LEVEL     :  std_logic_vector(BUF_DEPTH downto 0)
                                    := std_logic_vector(to_unsigned(2**BUF_DEPTH-2*I_DATA_WIDTH    , BUF_DEPTH+1));
    -------------------------------------------------------------------------------
    -- 定数
    -------------------------------------------------------------------------------
    constant  I_REQ_LOCK            :  AXI4_ALOCK_TYPE  := (others => '0');
    constant  I_REQ_PROT            :  AXI4_APROT_TYPE  := (others => '0');
    constant  I_REQ_QOS             :  AXI4_AQOS_TYPE   := (others => '0');
    constant  I_REQ_REGION          :  AXI4_AREGION_TYPE:= (others => '0');
    constant  I_REQ_ID              :  std_logic_vector(I_ID_WIDTH -1 downto 0)
                                    := std_logic_vector(to_unsigned(I_AXI_ID, I_ID_WIDTH));
    constant  I_ADDR_FIX            :  std_logic := '0';
    constant  I_ACK_REGS            :  integer := 1;
    constant  I_REQ_QUEUE           :  integer := I_QUEUE_SIZE;
    constant  I_RDATA_REGS          :  integer := 3;
    constant  I_REQ_SIZE_BITS       :  integer := 32;
    constant  I_XFER_MIN_SIZE       :  integer := I_MAX_XFER_SIZE;
    constant  I_XFER_MAX_SIZE       :  integer := I_MAX_XFER_SIZE;
    constant  OPEN_INFO_BITS        :  integer := 32;
    constant  CLOSE_INFO_BITS       :  integer := 32;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    i_req_valid           :  std_logic;
    signal    i_req_addr            :  std_logic_vector(I_ADDR_WIDTH   -1 downto 0);
    signal    i_req_size            :  std_logic_vector(I_REQ_SIZE_BITS-1 downto 0);
    signal    i_req_buf_ptr         :  std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal    i_req_cache           :  AXI4_ACACHE_TYPE;
    signal    i_req_speculative     :  std_logic;
    signal    i_req_safety          :  std_logic;
    signal    i_req_first           :  std_logic;
    signal    i_req_last            :  std_logic;
    signal    i_req_none            :  std_logic;
    signal    i_req_ready           :  std_logic;
    signal    i_ack_valid           :  std_logic;
    signal    i_ack_size            :  std_logic_vector(BUF_DEPTH         downto 0);
    signal    i_ack_error           :  std_logic;
    signal    i_ack_next            :  std_logic;
    signal    i_ack_last            :  std_logic;
    signal    i_ack_stop            :  std_logic;
    signal    i_ack_none            :  std_logic;
    signal    i_xfer_busy           :  std_logic;
    signal    i_xfer_done           :  std_logic;
    signal    i_xfer_error          :  std_logic;
    signal    i_flow_ready          :  std_logic;
    signal    i_flow_pause          :  std_logic;
    signal    i_flow_stop           :  std_logic;
    signal    i_flow_last           :  std_logic;
    signal    i_flow_size           :  std_logic_vector(BUF_DEPTH         downto 0);
    signal    i_push_fin_valid      :  std_logic;
    signal    i_push_fin_last       :  std_logic;
    signal    i_push_fin_error      :  std_logic;
    signal    i_push_fin_size       :  std_logic_vector(BUF_DEPTH         downto 0);
    signal    i_push_rsv_valid      :  std_logic;
    signal    i_push_rsv_last       :  std_logic;
    signal    i_push_rsv_error      :  std_logic;
    signal    i_push_rsv_size       :  std_logic_vector(BUF_DEPTH         downto 0);
    signal    i_push_buf_reset      :  std_logic;
    signal    i_push_buf_valid      :  std_logic;
    signal    i_push_buf_last       :  std_logic;
    signal    i_push_buf_error      :  std_logic;
    signal    i_push_buf_size       :  std_logic_vector(BUF_DEPTH         downto 0);
    signal    i_push_buf_ready      :  std_logic;
    signal    i_open                :  std_logic;
    signal    i_tran_busy           :  std_logic;
    signal    i_tran_done           :  std_logic;
    signal    i_tran_none           :  std_logic;
    signal    i_tran_error          :  std_logic;
    signal    i_i_open_info         :  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    signal    i_q_open_info         :  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    signal    i_i_close_info        :  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    signal    i_q_close_info        :  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    signal    i_o_open_info         :  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    signal    i_o_open_valid        :  std_logic;
    signal    i_o_close_info        :  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    signal    i_o_close_valid       :  std_logic;
    signal    i_o_stop              :  std_logic;
    signal    o_open                :  std_logic;
    signal    o_done                :  std_logic;
    signal    o_i_open_info         :  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    signal    o_i_open_valid        :  std_logic;
    signal    o_i_close_info        :  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    signal    o_i_close_valid       :  std_logic;
    signal    o_o_open_info         :  std_logic_vector(OPEN_INFO_BITS -1 downto 0);
    signal    o_o_open_valid        :  std_logic;
    signal    o_o_close_info        :  std_logic_vector(CLOSE_INFO_BITS-1 downto 0);
    signal    o_o_close_valid       :  std_logic;
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
    -- Pump Intake Registers
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
    constant  I_REGS_BASE_ADDR      :  integer := 16#00#;
    constant  I_REGS_BITS           :  integer := 128;
    constant  I_REGS_LO             :  integer := 8*I_REGS_BASE_ADDR;
    constant  I_REGS_HI             :  integer := I_REGS_LO + I_REGS_BITS - 1;
    -------------------------------------------------------------------------------
    -- Pump Intake Address Register
    -------------------------------------------------------------------------------
    -- Address     = 転送開始アドレス.
    -------------------------------------------------------------------------------
    constant  I_ADDR_REGS_ADDR      :  integer := I_REGS_BASE_ADDR + 16#00#;
    constant  I_ADDR_REGS_BITS      :  integer := 64;
    constant  I_ADDR_REGS_LO        :  integer := 8*I_ADDR_REGS_ADDR;
    constant  I_ADDR_REGS_HI        :  integer := 8*I_ADDR_REGS_ADDR + I_ADDR_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Intake Size Register
    -------------------------------------------------------------------------------
    -- Size[31:00] = 転送サイズ.
    -------------------------------------------------------------------------------
    constant  I_SIZE_REGS_ADDR      :  integer := I_REGS_BASE_ADDR + 16#08#;
    constant  I_SIZE_REGS_BITS      :  integer := 32;
    constant  I_SIZE_REGS_LO        :  integer := 8*I_SIZE_REGS_ADDR;
    constant  I_SIZE_REGS_HI        :  integer := 8*I_SIZE_REGS_ADDR + I_SIZE_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Intake Mode Register
    -------------------------------------------------------------------------------
    -- Mode[15]    = 1:AXI4 Master Read I/F をセイフティモードで動かす.
    -- Mode[14]    = 1:AXI4 Master Read I/F を投機モードで動かす.
    -- Mode[13]    = 1:AXI4 Master Read I/F をアドレス固定モードにする.
    -- Mode[11:08] = AXI4 Master Read I/F の ARUSER の値を指定する.
    -- Mode[07:04] = AXI4 Master Read I/F のキャッシュモードを指定する.
    -- Mode[01]    = 1:エラー発生時(Status[1]='1')に割り込みを発生する.
    -- Mode[00]    = 1:転送終了時(Status[0]='1')に割り込みを発生する.
    -------------------------------------------------------------------------------
    constant  I_MODE_REGS_ADDR      :  integer := I_REGS_BASE_ADDR + 16#0C#;
    constant  I_MODE_REGS_BITS      :  integer := 16;
    constant  I_MODE_REGS_HI        :  integer := 8*I_MODE_REGS_ADDR + 15;
    constant  I_MODE_REGS_LO        :  integer := 8*I_MODE_REGS_ADDR +  0;
    constant  I_MODE_SAFETY_POS     :  integer := 8*I_MODE_REGS_ADDR + 15;
    constant  I_MODE_SPECUL_POS     :  integer := 8*I_MODE_REGS_ADDR + 14;
    constant  I_MODE_AFIX_POS       :  integer := 8*I_MODE_REGS_ADDR + 13;
    constant  I_MODE_AUSER_HI       :  integer := 8*I_MODE_REGS_ADDR + 12;
    constant  I_MODE_AUSER_LO       :  integer := 8*I_MODE_REGS_ADDR +  8;
    constant  I_MODE_CACHE_HI       :  integer := 8*I_MODE_REGS_ADDR +  7;
    constant  I_MODE_CACHE_LO       :  integer := 8*I_MODE_REGS_ADDR +  4;
    constant  I_MODE_CLOSE_POS      :  integer := 8*I_MODE_REGS_ADDR +  2;
    constant  I_MODE_ERROR_POS      :  integer := 8*I_MODE_REGS_ADDR +  1;
    constant  I_MODE_DONE_POS       :  integer := 8*I_MODE_REGS_ADDR +  0;
    -------------------------------------------------------------------------------
    -- Pump Intake Status Register
    -------------------------------------------------------------------------------
    -- Status[7:2] = 予約.
    -- Status[1]   = エラー発生時にセットされる.
    -- Status[0]   = 転送終了時かつ Control[2]='1' にセットされる.
    -------------------------------------------------------------------------------
    constant  I_STAT_REGS_ADDR      :  integer := I_REGS_BASE_ADDR + 16#0E#;
    constant  I_STAT_REGS_BITS      :  integer := 8;
    constant  I_STAT_RESV_HI        :  integer := 8*I_STAT_REGS_ADDR +  7;
    constant  I_STAT_RESV_LO        :  integer := 8*I_STAT_REGS_ADDR +  3;
    constant  I_STAT_CLOSE_POS      :  integer := 8*I_STAT_REGS_ADDR +  2;
    constant  I_STAT_ERROR_POS      :  integer := 8*I_STAT_REGS_ADDR +  1;
    constant  I_STAT_DONE_POS       :  integer := 8*I_STAT_REGS_ADDR +  0;
    constant  I_STAT_RESV_BITS      :  integer := I_STAT_RESV_HI - I_STAT_RESV_LO + 1;
    constant  I_STAT_RESV_NULL      :  std_logic_vector(I_STAT_RESV_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- Pump Intake Control Register
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
    constant  I_CTRL_REGS_ADDR      :  integer := I_REGS_BASE_ADDR + 16#0F#;
    constant  I_CTRL_RESET_POS      :  integer := 8*I_CTRL_REGS_ADDR +  7;
    constant  I_CTRL_PAUSE_POS      :  integer := 8*I_CTRL_REGS_ADDR +  6;
    constant  I_CTRL_STOP_POS       :  integer := 8*I_CTRL_REGS_ADDR +  5;
    constant  I_CTRL_START_POS      :  integer := 8*I_CTRL_REGS_ADDR +  4;
    constant  I_CTRL_RESV_POS       :  integer := 8*I_CTRL_REGS_ADDR +  3;
    constant  I_CTRL_DONE_POS       :  integer := 8*I_CTRL_REGS_ADDR +  2;
    constant  I_CTRL_FIRST_POS      :  integer := 8*I_CTRL_REGS_ADDR +  1;
    constant  I_CTRL_LAST_POS       :  integer := 8*I_CTRL_REGS_ADDR +  0;
    -------------------------------------------------------------------------------
    -- Pump Intake Open Infomation Register
    -------------------------------------------------------------------------------
    constant  I_OPEN_REGS_ADDR      :  integer := I_REGS_BASE_ADDR + 16#10#;
    constant  I_OPEN_REGS_BITS      :  integer := OPEN_INFO_BITS;
    constant  I_OPEN_REGS_LO        :  integer := 8*I_OPEN_REGS_ADDR;
    constant  I_OPEN_REGS_HI        :  integer := 8*I_OPEN_REGS_ADDR + I_OPEN_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Intake Close Infomation Register
    -------------------------------------------------------------------------------
    constant  I_CLOSE_REGS_ADDR     :  integer := I_REGS_BASE_ADDR + 16#14#;
    constant  I_CLOSE_REGS_BITS     :  integer := CLOSE_INFO_BITS;
    constant  I_CLOSE_REGS_LO       :  integer := 8*I_CLOSE_REGS_ADDR;
    constant  I_CLOSE_REGS_HI       :  integer := 8*I_CLOSE_REGS_ADDR + I_CLOSE_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Reserve Register
    -------------------------------------------------------------------------------
    constant  I_RESV_REGS_ADDR      :  integer := I_REGS_BASE_ADDR + 16#18#;
    constant  I_RESV_REGS_BITS      :  integer := 64;
    constant  I_RESV_REGS_LO        :  integer := 8*I_RESV_REGS_ADDR;
    constant  I_RESV_REGS_HI        :  integer := 8*I_RESV_REGS_ADDR + I_RESV_REGS_BITS-1;
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
                CLK             => I_CLK             , -- In  :
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
                I_CLK           => I_CLK             , -- In  :
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
                O_CLK           => I_CLK             , -- In  :
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
    I_IF: AXI4_MASTER_READ_INTERFACE                   -- 
        generic map (                                  -- 
            AXI4_ADDR_WIDTH     => I_ADDR_WIDTH      , -- 
            AXI4_DATA_WIDTH     => I_DATA_WIDTH      , --   
            AXI4_ID_WIDTH       => I_ID_WIDTH        , --   
            VAL_BITS            => 1                 , --   
            REQ_SIZE_BITS       => I_REQ_SIZE_BITS   , --   
            REQ_SIZE_VALID      => I_REQ_SIZE_VALID  , --   
            FLOW_VALID          => I_FLOW_VALID      , --   
            BUF_DATA_WIDTH      => BUF_WIDTH         , --   
            BUF_PTR_BITS        => BUF_DEPTH         , --   
            ALIGNMENT_BITS      => 8                 , --   
            XFER_SIZE_BITS      => BUF_DEPTH+1       , --   
            XFER_MIN_SIZE       => I_XFER_MIN_SIZE   , --   
            XFER_MAX_SIZE       => I_XFER_MAX_SIZE   , --   
            QUEUE_SIZE          => I_REQ_QUEUE       , --   
            RDATA_REGS          => I_RDATA_REGS      , --   
            ACK_REGS            => I_ACK_REGS          --   
        )                                              -- 
        port map(                                      --
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK                 => I_CLK             , -- In  :
            RST                 => RST               , -- In  :
            CLR                 => CLR               , -- In  :
        ---------------------------------------------------------------------------
        -- AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            ARID                => I_ARID            , -- Out :
            ARADDR              => I_ARADDR          , -- Out :
            ARLEN               => I_ARLEN           , -- Out :
            ARSIZE              => I_ARSIZE          , -- Out :
            ARBURST             => I_ARBURST         , -- Out :
            ARLOCK              => I_ARLOCK          , -- Out :
            ARCACHE             => I_ARCACHE         , -- Out :
            ARPROT              => I_ARPROT          , -- Out :
            ARQOS               => I_ARQOS           , -- Out :
            ARREGION            => I_ARREGION        , -- Out :
            ARVALID             => I_ARVALID         , -- Out :
            ARREADY             => I_ARREADY         , -- In  :
        ---------------------------------------------------------------------------
        -- AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            RID                 => I_RID             , -- In  :
            RDATA               => I_RDATA           , -- In  :
            RRESP               => I_RRESP           , -- In  :
            RLAST               => I_RLAST           , -- In  :
            RVALID              => I_RVALID          , -- In  :
            RREADY              => I_RREADY          , -- Out :
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
            XFER_SIZE_SEL       => "1"               , -- In  :
            REQ_ADDR            => i_req_addr        , -- In  :
            REQ_SIZE            => i_req_size        , -- In  :
            REQ_ID              => I_REQ_ID          , -- In  :
            REQ_BURST           => AXI4_ABURST_INCR  , -- In  :
            REQ_LOCK            => I_REQ_LOCK        , -- In  :
            REQ_CACHE           => i_req_cache       , -- In  :
            REQ_PROT            => I_REQ_PROT        , -- In  :
            REQ_QOS             => I_REQ_QOS         , -- In  :
            REQ_REGION          => I_REQ_REGION      , -- In  :
            REQ_BUF_PTR         => i_req_buf_ptr     , -- In  :
            REQ_FIRST           => i_req_first       , -- In  :
            REQ_LAST            => i_req_last        , -- In  :
            REQ_SPECULATIVE     => i_req_speculative , -- In  :
            REQ_SAFETY          => i_req_safety      , -- In  :
            REQ_VAL(0)          => i_req_valid       , -- In  :
            REQ_RDY             => i_req_ready       , -- Out :
        ---------------------------------------------------------------------------
        -- Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            ACK_VAL(0)          => i_ack_valid       , -- Out :
            ACK_NEXT            => i_ack_next        , -- Out :
            ACK_LAST            => i_ack_last        , -- Out :
            ACK_ERROR           => i_ack_error       , -- Out :
            ACK_STOP            => i_ack_stop        , -- Out :
            ACK_NONE            => i_ack_none        , -- Out :
            ACK_SIZE            => i_ack_size        , -- Out :
        ---------------------------------------------------------------------------
        -- Transfer Status Signal.
        ---------------------------------------------------------------------------
            XFER_BUSY(0)        => i_xfer_busy       , -- Out :
            XFER_ERROR(0)       => i_xfer_error      , -- Out :
            XFER_DONE(0)        => i_xfer_done       , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_STOP           => i_flow_stop       , -- In  :
            FLOW_PAUSE          => i_flow_pause      , -- In  :
            FLOW_LAST           => i_flow_last       , -- In  :
            FLOW_SIZE           => i_flow_size       , -- In  :
        ---------------------------------------------------------------------------
        -- Push Reserve Size Signals.
        ---------------------------------------------------------------------------
            PUSH_RSV_VAL(0)     => i_push_rsv_valid  , -- Out :
            PUSH_RSV_LAST       => i_push_rsv_last   , -- Out :
            PUSH_RSV_ERROR      => i_push_rsv_error  , -- Out :
            PUSH_RSV_SIZE       => i_push_rsv_size   , -- Out :
        ---------------------------------------------------------------------------
        -- Push Final Size Signals.
        ---------------------------------------------------------------------------
            PUSH_FIN_VAL(0)     => i_push_fin_valid  , -- Out :
            PUSH_FIN_LAST       => i_push_fin_last   , -- Out :
            PUSH_FIN_ERROR      => i_push_fin_error  , -- Out :
            PUSH_FIN_SIZE       => i_push_fin_size   , -- Out :
        ---------------------------------------------------------------------------
        -- Push Buffer Size Signals.
        ---------------------------------------------------------------------------
            PUSH_BUF_RESET(0)   => i_push_buf_reset  , -- Out :
            PUSH_BUF_VAL(0)     => i_push_buf_valid  , -- Out :
            PUSH_BUF_LAST       => i_push_buf_last   , -- Out :
            PUSH_BUF_ERROR      => i_push_buf_error  , -- Out :
            PUSH_BUF_SIZE       => i_push_buf_size   , -- Out :
            PUSH_BUF_RDY(0)     => i_push_buf_ready  , -- In  :
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_WEN(0)          => buf_wen           , -- Out :
            BUF_BEN             => buf_ben           , -- Out :
            BUF_DATA            => buf_wdata         , -- Out :
            BUF_PTR             => buf_wptr            -- Out :
        );
    I_AWID            <= (others => '0');
    I_AWADDR          <= (others => '0');
    I_AWLEN           <= (others => '0');
    I_AWSIZE          <= (others => '0');
    I_AWBURST         <= (others => '0');
    I_AWLOCK          <= (others => '0');
    I_AWCACHE         <= (others => '0');
    I_AWPROT          <= (others => '0');
    I_AWQOS           <= (others => '0');
    I_AWREGION        <= (others => '0');
    I_AWUSER          <= (others => '0');
    I_AWVALID         <= '0';
    I_WDATA           <= (others => '0');
    I_WSTRB           <= (others => '0');
    I_WLAST           <= '0';
    I_WVALID          <= '0';
    I_BREADY          <= '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    INFO: block
    begin
        process(I_CLK, RST) begin
            if (RST = '1') then
                i_i_open_info  <= (others => '0');
                i_i_close_info <= (others => '0');
                i_q_open_info  <= (others => '0');
                i_q_close_info <= (others => '0');
            elsif (I_CLK'event and I_CLK = '1') then
                for i in i_i_open_info'range loop
                    if (regs_load(I_OPEN_REGS_LO + i) = '1') then
                        i_i_open_info(i)  <= regs_wbit(I_OPEN_REGS_LO + i);
                    end if;
                end loop;
                for i in i_i_close_info'range loop
                    if (regs_load(I_CLOSE_REGS_LO + i) = '1') then
                        i_i_close_info(i) <= regs_wbit(I_CLOSE_REGS_LO + i);
                    end if;
                end loop;
                if (i_o_open_valid = '1') then
                    i_q_open_info  <= i_o_open_info;
                end if;
                if (i_o_close_valid = '1') then
                    i_q_close_info <= i_o_close_info;
                end if;
            end if;
        end process;
        regs_rbit(I_OPEN_REGS_HI  downto I_OPEN_REGS_LO ) <= i_q_open_info;
        regs_rbit(I_CLOSE_REGS_HI downto I_CLOSE_REGS_LO) <= i_q_close_info;
        regs_rbit(I_RESV_REGS_HI  downto I_RESV_REGS_LO ) <= (I_RESV_REGS_HI downto I_RESV_REGS_LO => '0');
        o_i_open_valid  <= o_o_open_valid;
        o_i_open_info   <= o_o_open_info;
        o_i_close_valid <= o_o_close_valid;
        o_i_close_info  <= o_o_close_info;
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    CTRL: PUMP_STREAM_INTAKE_CONTROLLER
        generic map (
            I_CLK_RATE          => I_CLK_RATE          , --
            I_REQ_ADDR_VALID    => I_REQ_ADDR_VALID    , --
            I_REQ_ADDR_BITS     => I_ADDR_WIDTH        , --
            I_REG_ADDR_BITS     => I_ADDR_REGS_BITS    , --
            I_REQ_SIZE_VALID    => I_REQ_SIZE_VALID    , --
            I_REQ_SIZE_BITS     => I_REQ_SIZE_BITS     , --
            I_REG_SIZE_BITS     => I_SIZE_REGS_BITS    , --
            I_REG_MODE_BITS     => I_MODE_REGS_BITS    , --
            I_REG_STAT_BITS     => I_STAT_RESV_BITS    , --
            I_USE_PUSH_BUF_SIZE => I_USE_PUSH_BUF_SIZE , --
            I_FIXED_FLOW_OPEN   => I_FIXED_FLOW_OPEN   , --
            I_FIXED_POOL_OPEN   => I_FIXED_POOL_OPEN   , --
            O_CLK_RATE          => O_CLK_RATE          , --
            O_DATA_BITS         => O_DATA_WIDTH        , --
            BUF_DEPTH           => BUF_DEPTH           , --
            BUF_DATA_BITS       => BUF_WIDTH           , --
            I2O_OPEN_INFO_BITS  => OPEN_INFO_BITS      , --
            I2O_CLOSE_INFO_BITS => CLOSE_INFO_BITS     , --
            O2I_OPEN_INFO_BITS  => OPEN_INFO_BITS      , --
            O2I_CLOSE_INFO_BITS => CLOSE_INFO_BITS     , --
            I2O_DELAY_CYCLE     => 1                     --
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        --Reset Signals.
        ---------------------------------------------------------------------------
            RST                 => RST                 , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Clock and Clock Enable.
        ---------------------------------------------------------------------------
            I_CLK               => I_CLK               , --  In  :
            I_CLR               => '0'                 , --  In  :
            I_CKE               => I_CKE               , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Control Register Interface.
        ---------------------------------------------------------------------------
            I_ADDR_L            => regs_load(I_ADDR_REGS_HI downto I_ADDR_REGS_LO), --  In  :
            I_ADDR_D            => regs_wbit(I_ADDR_REGS_HI downto I_ADDR_REGS_LO), --  In  :
            I_ADDR_Q            => regs_rbit(I_ADDR_REGS_HI downto I_ADDR_REGS_LO), --  Out :
            I_SIZE_L            => regs_load(I_SIZE_REGS_HI downto I_SIZE_REGS_LO), --  In  :
            I_SIZE_D            => regs_wbit(I_SIZE_REGS_HI downto I_SIZE_REGS_LO), --  In  :
            I_SIZE_Q            => regs_rbit(I_SIZE_REGS_HI downto I_SIZE_REGS_LO), --  Out :
            I_MODE_L            => regs_load(I_MODE_REGS_HI downto I_MODE_REGS_LO), --  In  :
            I_MODE_D            => regs_wbit(I_MODE_REGS_HI downto I_MODE_REGS_LO), --  In  :
            I_MODE_Q            => regs_rbit(I_MODE_REGS_HI downto I_MODE_REGS_LO), --  Out :
            I_STAT_L            => regs_load(I_STAT_RESV_HI downto I_STAT_RESV_LO), --  In  :
            I_STAT_D            => regs_wbit(I_STAT_RESV_HI downto I_STAT_RESV_LO), --  In  :
            I_STAT_Q            => regs_rbit(I_STAT_RESV_HI downto I_STAT_RESV_LO), --  Out :
            I_STAT_I            => I_STAT_RESV_NULL                               , --  In  :
            I_RESET_L           => regs_load(I_CTRL_RESET_POS)                    , --  In  :
            I_RESET_D           => regs_wbit(I_CTRL_RESET_POS)                    , --  In  :
            I_RESET_Q           => regs_rbit(I_CTRL_RESET_POS)                    , --  Out :
            I_START_L           => regs_load(I_CTRL_START_POS)                    , --  In  :
            I_START_D           => regs_wbit(I_CTRL_START_POS)                    , --  In  :
            I_START_Q           => regs_rbit(I_CTRL_START_POS)                    , --  Out :
            I_STOP_L            => regs_load(I_CTRL_STOP_POS )                    , --  In  :
            I_STOP_D            => regs_wbit(I_CTRL_STOP_POS )                    , --  In  :
            I_STOP_Q            => regs_rbit(I_CTRL_STOP_POS )                    , --  Out :
            I_PAUSE_L           => regs_load(I_CTRL_PAUSE_POS)                    , --  In  :
            I_PAUSE_D           => regs_wbit(I_CTRL_PAUSE_POS)                    , --  In  :
            I_PAUSE_Q           => regs_rbit(I_CTRL_PAUSE_POS)                    , --  Out :
            I_FIRST_L           => regs_load(I_CTRL_FIRST_POS)                    , --  In  :
            I_FIRST_D           => regs_wbit(I_CTRL_FIRST_POS)                    , --  In  :
            I_FIRST_Q           => regs_rbit(I_CTRL_FIRST_POS)                    , --  Out :
            I_LAST_L            => regs_load(I_CTRL_LAST_POS )                    , --  In  :
            I_LAST_D            => regs_wbit(I_CTRL_LAST_POS )                    , --  In  :
            I_LAST_Q            => regs_rbit(I_CTRL_LAST_POS )                    , --  Out :
            I_DONE_EN_L         => regs_load(I_CTRL_DONE_POS )                    , --  In  :
            I_DONE_EN_D         => regs_wbit(I_CTRL_DONE_POS )                    , --  In  :
            I_DONE_EN_Q         => regs_rbit(I_CTRL_DONE_POS )                    , --  Out :
            I_DONE_ST_L         => regs_load(I_STAT_DONE_POS )                    , --  In  :
            I_DONE_ST_D         => regs_wbit(I_STAT_DONE_POS )                    , --  In  :
            I_DONE_ST_Q         => regs_rbit(I_STAT_DONE_POS )                    , --  Out :
            I_ERR_ST_L          => regs_load(I_STAT_ERROR_POS)                    , --  In  :
            I_ERR_ST_D          => regs_wbit(I_STAT_ERROR_POS)                    , --  In  :
            I_ERR_ST_Q          => regs_rbit(I_STAT_ERROR_POS)                    , --  Out :
            I_CLOSE_ST_L        => regs_load(I_STAT_CLOSE_POS)                    , --  In  :
            I_CLOSE_ST_D        => regs_wbit(I_STAT_CLOSE_POS)                    , --  In  :
            I_CLOSE_ST_Q        => regs_rbit(I_STAT_CLOSE_POS)                    , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Configuration Signals.
        ---------------------------------------------------------------------------
            I_ADDR_FIX          => I_ADDR_FIX          , --  In  :
            I_BUF_READY_LEVEL   => I_BUF_READY_LEVEL   , --  In  :
            I_FLOW_READY_LEVEL  => I_FLOW_READY_LEVEL  , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Transaction Command Request Signals.
        ---------------------------------------------------------------------------
            I_REQ_VALID         => i_req_valid         , --  Out :
            I_REQ_ADDR          => i_req_addr          , --  Out :
            I_REQ_SIZE          => i_req_size          , --  Out :
            I_REQ_BUF_PTR       => i_req_buf_ptr       , --  Out :
            I_REQ_FIRST         => i_req_first         , --  Out :
            I_REQ_LAST          => i_req_last          , --  Out :
            I_REQ_NONE          => i_req_none          , --  Out :
            I_REQ_READY         => i_req_ready         , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Transaction Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            I_ACK_VALID         => i_ack_valid         , --  In  :
            I_ACK_SIZE          => i_ack_size          , --  In  :
            I_ACK_ERROR         => i_ack_error         , --  In  :
            I_ACK_NEXT          => i_ack_next          , --  In  :
            I_ACK_LAST          => i_ack_last          , --  In  :
            I_ACK_STOP          => i_ack_stop          , --  In  :
            I_ACK_NONE          => i_ack_none          , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Transfer Status Signals.
        ---------------------------------------------------------------------------
            I_XFER_BUSY         => i_xfer_busy         , --  In  :
            I_XFER_DONE         => i_xfer_done         , --  In  :
            I_XFER_ERROR        => i_xfer_error        , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Flow Control Signals.
        ---------------------------------------------------------------------------
            I_FLOW_READY        => i_flow_ready        , --  Out :
            I_FLOW_PAUSE        => i_flow_pause        , --  Out :
            I_FLOW_STOP         => i_flow_stop         , --  Out :
            I_FLOW_LAST         => i_flow_last         , --  Out :
            I_FLOW_SIZE         => i_flow_size         , --  Out :
            I_PUSH_FIN_VALID    => i_push_fin_valid    , --  In  :
            I_PUSH_FIN_LAST     => i_push_fin_last     , --  In  :
            I_PUSH_FIN_ERROR    => i_push_fin_error    , --  In  :
            I_PUSH_FIN_SIZE     => i_push_fin_size     , --  In  :
            I_PUSH_RSV_VALID    => i_push_rsv_valid    , --  In  :
            I_PUSH_RSV_LAST     => i_push_rsv_last     , --  In  :
            I_PUSH_RSV_ERROR    => i_push_rsv_error    , --  In  :
            I_PUSH_RSV_SIZE     => i_push_rsv_size     , --  In  :
            I_PUSH_BUF_RESET    => i_push_buf_reset    , --  In  :
            I_PUSH_BUF_VALID    => i_push_buf_valid    , --  In  :
            I_PUSH_BUF_LAST     => i_push_buf_last     , --  In  :
            I_PUSH_BUF_ERROR    => i_push_buf_error    , --  In  :
            I_PUSH_BUF_SIZE     => i_push_buf_size     , --  In  :
            I_PUSH_BUF_READY    => i_push_buf_ready    , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Status.
        ---------------------------------------------------------------------------
            I_OPEN              => i_open              , --  Out :
            I_TRAN_BUSY         => i_tran_busy         , --  Out :
            I_TRAN_DONE         => i_tran_done         , --  Out :
            I_TRAN_NONE         => i_tran_none         , --  Out :
            I_TRAN_ERROR        => i_tran_error        , --  Out :
        ---------------------------------------------------------------------------
        -- Intake Open/Close Infomation Interface
        ---------------------------------------------------------------------------
            I_I2O_OPEN_INFO     => i_i_open_info       , --  In  :
            I_I2O_CLOSE_INFO    => i_i_close_info      , --  In  :
            I_O2I_OPEN_INFO     => i_o_open_info       , --  Out :
            I_O2I_OPEN_VALID    => i_o_open_valid      , --  Out :
            I_O2I_CLOSE_INFO    => i_o_close_info      , --  Out :
            I_O2I_CLOSE_VALID   => i_o_close_valid     , --  Out :
            I_O2I_STOP          => i_o_stop            , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Clock and Clock Enable.
        ---------------------------------------------------------------------------
            O_CLK               => O_CLK               , --  In  :
            O_CLR               => '0'                 , --  In  :
            O_CKE               => O_CKE               , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Stream Interface.
        ---------------------------------------------------------------------------
            O_DATA              => O_DATA              , --  Out :
            O_STRB              => O_STRB              , --  Out :
            O_LAST              => O_LAST              , --  Out :
            O_VALID             => O_VALID             , --  Out :
            O_READY             => O_READY             , --  In  :
        ---------------------------------------------------------------------------
        -- Outlet Status.
        ---------------------------------------------------------------------------
            O_OPEN              => o_open              , --  Out :
            O_DONE              => o_done              , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Open/Close Infomation Interface
        ---------------------------------------------------------------------------
            O_O2I_STOP          => O_O2I_STOP          , --  In  :
            O_O2I_OPEN_INFO     => o_i_open_info       , --  In  :
            O_O2I_OPEN_VALID    => o_i_open_valid      , --  In  :
            O_O2I_CLOSE_INFO    => o_i_close_info      , --  In  :
            O_O2I_CLOSE_VALID   => o_i_close_valid     , --  In  :
            O_I2O_RESET         => O_I2O_RESET         , --  Out :
            O_I2O_ERROR         => O_I2O_ERROR         , --  Out :
            O_I2O_STOP          => O_I2O_STOP          , --  Out :
            O_I2O_NONE          => O_I2O_NONE          , --  Out :
            O_I2O_OPEN_INFO     => o_o_open_info       , --  Out :
            O_I2O_OPEN_VALID    => o_o_open_valid      , --  Out :
            O_I2O_CLOSE_INFO    => o_o_close_info      , --  Out :
            O_I2O_CLOSE_VALID   => o_o_close_valid     , --  Out :
        ---------------------------------------------------------------------------
        -- Outlet Buffer Read Interface.
        ---------------------------------------------------------------------------
            BUF_REN             => buf_ren             , --  Out :
            BUF_PTR             => buf_rptr            , --  Out :
            BUF_DATA            => buf_rdata             --  In  :
        );                                               --
    regs_rbit(I_CTRL_RESV_POS) <= '0';
    i_req_cache       <= regs_rbit(I_MODE_CACHE_HI downto I_MODE_CACHE_LO);
    i_req_speculative <= regs_rbit(I_MODE_SPECUL_POS);
    i_req_safety      <= regs_rbit(I_MODE_SAFETY_POS);
    I_ARUSER          <= std_logic_vector(resize(unsigned(regs_rbit(I_MODE_AUSER_HI downto I_MODE_AUSER_LO)), I_AUSER_WIDTH));
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process (I_CLK, RST) begin
        if (RST = '1') then
                IRQ <= '0';
        elsif (I_CLK'event and I_CLK = '1') then
            if (CLR = '1') then
                IRQ <= '0';
            elsif (regs_rbit(I_STAT_CLOSE_POS) = '1' and regs_rbit(I_MODE_CLOSE_POS) = '1') or
                  (regs_rbit(I_STAT_DONE_POS ) = '1' and regs_rbit(I_MODE_DONE_POS ) = '1') or
                  (regs_rbit(I_STAT_ERROR_POS) = '1' and regs_rbit(I_MODE_ERROR_POS) = '1') then
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
