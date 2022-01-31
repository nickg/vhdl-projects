-----------------------------------------------------------------------------------
--!     @file    aix4_write_adapter.vhd
--!     @brief   AXI4_WRITE_ADPATER
--!     @version 1.8.2
--!     @date    2020/10/7
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
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4-AXI4 Write Adapter
-----------------------------------------------------------------------------------
entity  AXI4_WRITE_ADAPTER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        AXI4_ID_WIDTH       : --! @brief AXI4 ID WIDTH :
                              --! AXI4 アドレスチャネルおよびライトレスポンスチャネ
                              --! ルのID信号のビット幅.
                              integer := 4;
        AXI4_AUSER_WIDTH    : --! @brief AXI4 ADDRESS USER WIDTH :
                              --! AXI4 アドレスチャネルおよびライトレスポンスチャネ
                              --! ルのAUSER信号のビット幅.
                              integer := 1;
        AXI4_ADDR_WIDTH     : --! @brief RESPONDER AIX4 ADDRESS CHANNEL ADDR WIDTH :
                              --! AXI4 ライトアドレスチャネルのAWADDR信号のビット幅.
                              integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        T_CLK_RATE          : --! @brief RESPONDER CLOCK RATE :
                              --! M_CLK_RATEとペアでレスポンダ側のクロック(T_CLK)と
                              --! リクエスト側のクロック(M_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        T_DATA_WIDTH        : --! @brief RESPONDER AXI4 WRITE DATA CHANNEL DATA WIDTH :
                              --! AXI4 ライトデータチャネルのWDATA信号のビット幅.
                              integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        M_CLK_RATE          : --! @brief REQUESTER CLOCK RATE :
                              --! T_CLK_RATEとペアでレスポンダ側のクロック(T_CLK)と
                              --! リクエスト側のクロック(M_CLK)との関係を指定する.
                              --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                              integer :=  1;
        M_DATA_WIDTH        : --! @brief REQUESTER AXI4 WRITE DATA CHANNEL DATA WIDTH :
                              --! AXI4 ライトデータチャネルのWDATA信号のビット幅.
                              integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        M_MAX_XFER_SIZE     : --! @brief TRANSFER MAXIMUM SIZE :
                              --! 一回の転送サイズの最大バイト数を２のべき乗で指定する.
                              integer := 12;
        BUF_DEPTH           : --! @brief Buffer Depth :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        RESP_REGS           : --! @brief RESPONSE REGISTER USE :
                              --! レスポンスの入力側にレジスタを挿入する.
                              integer := 0
    );
    port(
    ------------------------------------------------------------------------------
    -- Reset Signals.
    ------------------------------------------------------------------------------
        RST                 : in    std_logic;
    ------------------------------------------------------------------------------
    -- Responder Signals.
    ------------------------------------------------------------------------------
        T_CLK               : in    std_logic;
        T_CKE               : in    std_logic;
        T_CLR               : in    std_logic;
        T_AWID              : in    std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
        T_AWUSER            : in    std_logic_vector(AXI4_AUSER_WIDTH-1 downto 0);
        T_AWADDR            : in    std_logic_vector(AXI4_ADDR_WIDTH -1 downto 0);
        T_AWLEN             : in    std_logic_vector(AXI4_ALEN_WIDTH -1 downto 0);
        T_AWSIZE            : in    AXI4_ASIZE_TYPE;
        T_AWBURST           : in    AXI4_ABURST_TYPE;
        T_AWLOCK            : in    std_logic_vector(AXI4_ALOCK_WIDTH-1 downto 0);
        T_AWCACHE           : in    AXI4_ACACHE_TYPE;
        T_AWPROT            : in    AXI4_APROT_TYPE;
        T_AWQOS             : in    AXI4_AQOS_TYPE;
        T_AWREGION          : in    AXI4_AREGION_TYPE;
        T_AWVALID           : in    std_logic;
        T_AWREADY           : out   std_logic;
        T_WDATA             : in    std_logic_vector(T_DATA_WIDTH    -1 downto 0);
        T_WSTRB             : in    std_logic_vector(T_DATA_WIDTH/8  -1 downto 0);
        T_WLAST             : in    std_logic;
        T_WVALID            : in    std_logic;
        T_WREADY            : out   std_logic;
        T_BID               : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
        T_BRESP             : out   AXI4_RESP_TYPE;
        T_BVALID            : out   std_logic;
        T_BREADY            : in    std_logic;
    ------------------------------------------------------------------------------
    -- Requester Signals.
    ------------------------------------------------------------------------------
        M_CLK               : in    std_logic;
        M_CKE               : in    std_logic;
        M_CLR               : in    std_logic;
        M_AWID              : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
        M_AWUSER            : out   std_logic_vector(AXI4_AUSER_WIDTH-1 downto 0);
        M_AWADDR            : out   std_logic_vector(AXI4_ADDR_WIDTH -1 downto 0);
        M_AWLEN             : out   std_logic_vector(AXI4_ALEN_WIDTH -1 downto 0);
        M_AWSIZE            : out   AXI4_ASIZE_TYPE;
        M_AWBURST           : out   AXI4_ABURST_TYPE;
        M_AWLOCK            : out   std_logic_vector(AXI4_ALOCK_WIDTH-1 downto 0);
        M_AWCACHE           : out   AXI4_ACACHE_TYPE;
        M_AWPROT            : out   AXI4_APROT_TYPE;
        M_AWQOS             : out   AXI4_AQOS_TYPE;
        M_AWREGION          : out   AXI4_AREGION_TYPE;
        M_AWVALID           : out   std_logic;
        M_AWREADY           : in    std_logic;
        M_WID               : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
        M_WDATA             : out   std_logic_vector(M_DATA_WIDTH    -1 downto 0);
        M_WSTRB             : out   std_logic_vector(M_DATA_WIDTH/8  -1 downto 0);
        M_WLAST             : out   std_logic;
        M_WVALID            : out   std_logic;
        M_WREADY            : in    std_logic;
        M_BID               : in    std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
        M_BRESP             : in    AXI4_RESP_TYPE;
        M_BVALID            : in    std_logic;
        M_BREADY            : out   std_logic
    );
end AXI4_WRITE_ADAPTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.SDPRAM;
use     PIPEWORK.PUMP_COMPONENTS.PIPE_CONTROLLER;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_WRITE_INTERFACE;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_SLAVE_WRITE_INTERFACE;
architecture RTL of AXI4_WRITE_ADAPTER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  MAX(A,B:integer) return integer is begin
        if (A > B) then return A;
        else            return B;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  MIN(A,B:integer) return integer is begin
        if (A < B) then return A;
        else            return B;
        end if;
    end function;
    -------------------------------------------------------------------------------
    -- データバスのビット数の２のべき乗値を計算する.
    -------------------------------------------------------------------------------
    function  CALC_DATA_SIZE(WIDTH:integer) return integer is
        variable value : integer;
    begin
        value := 0;
        while (2**(value) < WIDTH) loop
            value := value + 1;
        end loop;
        return value;
    end function;
    ------------------------------------------------------------------------------
    -- バッファのデータ幅は T_DATA_WIDTH と M_DATA_WIDTH の大きい方を選択する.
    ------------------------------------------------------------------------------
    constant  BUF_DATA_BITS     : integer := MAX(T_DATA_WIDTH, M_DATA_WIDTH);
    ------------------------------------------------------------------------------
    -- バッファのデータ幅のビット数(２のべき乗値).
    ------------------------------------------------------------------------------
    constant  BUF_DATA_BIT_SIZE : integer := CALC_DATA_SIZE(BUF_DATA_BITS);
    ------------------------------------------------------------------------------
    -- バッファのデータ幅をバイト数.
    ------------------------------------------------------------------------------
    constant  BUF_DATA_BYTES    : integer := BUF_DATA_BITS/8;
    -------------------------------------------------------------------------------
    -- バッファのデータ幅のバイト数(２のべき乗値).
    -------------------------------------------------------------------------------
    constant  BUF_DATA_BYTE_SIZE: integer := BUF_DATA_BIT_SIZE-3;
    -------------------------------------------------------------------------------
    -- アライメントの単位は T_DATA_WIDTH と M_DATA_WIDTH の小さい方を選択する.
    -------------------------------------------------------------------------------
    constant  ALIGNMENT_BITS    : integer := MIN(T_DATA_WIDTH, M_DATA_WIDTH);
    -------------------------------------------------------------------------------
    -- アライメントのバイト数を２のべき乗値で示す.
    -------------------------------------------------------------------------------
    constant  ALIGNMENT_SIZE    : integer := CALC_DATA_SIZE(ALIGNMENT_BITS/8);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  M_DATA_BYTES      : integer := M_DATA_WIDTH/8;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  T_DATA_BYTES      : integer := T_DATA_WIDTH/8;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  SIZE_BITS         : integer := 13;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  T_MAX_XFER_SIZE   : integer := 12;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  MAKE_POOL_SIZE return std_logic_vector is
        variable pool_size : std_logic_vector(SIZE_BITS-1 downto 0);
    begin
        for i in pool_size'range loop
            if (BUF_DEPTH <= pool_size'high and i = BUF_DEPTH     ) or
               (BUF_DEPTH  > pool_size'high and i = pool_size'high) then
                pool_size(i) := '1';
            else
                pool_size(i) := '0';
            end if;
        end loop;
        return pool_size;
    end function;
    constant  POOL_SIZE         : std_logic_vector(SIZE_BITS-1 downto 0) := MAKE_POOL_SIZE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  MODE_LO           : integer := 0;
    constant  MODE_ID_LO        : integer := MODE_LO;
    constant  MODE_ID_HI        : integer := MODE_ID_LO     + AXI4_ID_WIDTH     - 1;
    constant  MODE_ABURST_LO    : integer := MODE_ID_HI     + 1;
    constant  MODE_ABURST_HI    : integer := MODE_ABURST_LO + AXI4_ABURST_WIDTH - 1;
    constant  MODE_ALOCK_LO     : integer := MODE_ABURST_HI + 1;
    constant  MODE_ALOCK_HI     : integer := MODE_ALOCK_LO  + AXI4_ALOCK_WIDTH  - 1;
    constant  MODE_ACACHE_LO    : integer := MODE_ALOCK_HI  + 1;
    constant  MODE_ACACHE_HI    : integer := MODE_ACACHE_LO + AXI4_ACACHE_WIDTH - 1;
    constant  MODE_APROT_LO     : integer := MODE_ACACHE_HI + 1;
    constant  MODE_APROT_HI     : integer := MODE_APROT_LO  + AXI4_APROT_WIDTH  - 1;
    constant  MODE_AQOS_LO      : integer := MODE_APROT_HI  + 1;
    constant  MODE_AQOS_HI      : integer := MODE_AQOS_LO   + AXI4_AQOS_WIDTH   - 1;
    constant  MODE_AREGION_LO   : integer := MODE_AQOS_HI   + 1;
    constant  MODE_AREGION_HI   : integer := MODE_AREGION_LO+ AXI4_AREGION_WIDTH- 1;
    constant  MODE_AUSER_LO     : integer := MODE_AREGION_HI+ 1;
    constant  MODE_AUSER_HI     : integer := MODE_AUSER_LO  + AXI4_AUSER_WIDTH  - 1;
    constant  MODE_HI           : integer := MODE_AUSER_HI;
    constant  MODE_BITS         : integer := MODE_HI        + 1;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    t_req_id          : std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
    signal    t_req_addr        : std_logic_vector(AXI4_ADDR_WIDTH-1 downto 0);
    signal    t_req_size        : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    t_req_mode        : std_logic_vector(MODE_BITS-1 downto 0);
    signal    t_req_burst       : AXI4_ABURST_TYPE;
    signal    t_req_valid       : std_logic;
    signal    t_req_start       : std_logic;
    signal    t_req_ready       : std_logic;
    signal    t_req_buf_ptr     : std_logic_vector(BUF_DEPTH-1 downto 0);
    constant  t_req_dir         : std_logic := '1';
    constant  t_req_first       : std_logic := '1';
    constant  t_req_last        : std_logic := '1';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    t_ack_valid       : std_logic;
    signal    t_ack_next        : std_logic;
    signal    t_ack_last        : std_logic;
    signal    t_ack_error       : std_logic;
    signal    t_ack_stop        : std_logic;
    signal    t_ack_size        : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  t_req_stop        : std_logic := '0';
    constant  t_req_pause       : std_logic := '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  t_xfer_select     : std_logic_vector(0 downto 0) := std_logic_vector'("1");
    signal    t_xfer_busy       : std_logic;
    signal    t_xfer_done       : std_logic;
    signal    t_xfer_error      : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    t_i_flow_rdy      : std_logic;
    signal    t_i_flow_pause    : std_logic;
    signal    t_i_flow_stop     : std_logic;
    signal    t_i_flow_last     : std_logic;
    signal    t_i_flow_size     : std_logic_vector(SIZE_BITS-1 downto 0);
    constant  t_i_flow_level    : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    t_push_fin_val    : std_logic;
    signal    t_push_fin_last   : std_logic;
    signal    t_push_fin_err    : std_logic;
    signal    t_push_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    t_push_rsv_val    : std_logic;
    signal    t_push_rsv_last   : std_logic;
    signal    t_push_rsv_err    : std_logic;
    signal    t_push_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  t_push_buf_level  : std_logic_vector(SIZE_BITS-1 downto 0) 
                               := std_logic_vector(to_unsigned(2**BUF_DEPTH-BUF_DATA_BYTES, SIZE_BITS));
    signal    t_push_buf_reset  : std_logic;
    signal    t_push_buf_val    : std_logic;
    signal    t_push_buf_last   : std_logic;
    signal    t_push_buf_err    : std_logic;
    signal    t_push_buf_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    t_push_buf_rdy    : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  t_o_flow_level    : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    signal    t_o_flow_rdy      : std_logic;
    signal    t_o_flow_pause    : std_logic;
    signal    t_o_flow_stop     : std_logic;
    signal    t_o_flow_last     : std_logic;
    signal    t_o_flow_size     : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  t_pull_fin_val    : std_logic := '0';
    constant  t_pull_fin_last   : std_logic := '0';
    constant  t_pull_fin_err    : std_logic := '0';
    constant  t_pull_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  t_pull_rsv_val    : std_logic := '0';
    constant  t_pull_rsv_last   : std_logic := '0';
    constant  t_pull_rsv_err    : std_logic := '0';
    constant  t_pull_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  t_pull_buf_level  : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    constant  t_pull_buf_reset  : std_logic := '0';
    constant  t_pull_buf_val    : std_logic := '0';
    constant  t_pull_buf_last   : std_logic := '0';
    constant  t_pull_buf_err    : std_logic := '0';
    constant  t_pull_buf_size   : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    signal    t_pull_buf_rdy    : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    t_pool_write      : std_logic;
    signal    t_pool_ben        : std_logic_vector(BUF_DATA_BYTES-1 downto 0);
    signal    t_pool_we         : std_logic_vector(BUF_DATA_BYTES-1 downto 0);
    signal    t_pool_wdata      : std_logic_vector(BUF_DATA_BITS -1 downto 0);
    signal    t_pool_wptr       : std_logic_vector(BUF_DEPTH     -1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  m_req_speculative : std_logic := '0';
    constant  m_req_safety      : std_logic := '0';
    constant  m_xfer_size_sel   : std_logic_vector(M_MAX_XFER_SIZE downto M_MAX_XFER_SIZE) := "1";
    signal    m_req_id          : std_logic_vector(AXI4_ID_WIDTH  -1 downto 0);
    signal    m_req_addr        : std_logic_vector(AXI4_ADDR_WIDTH-1 downto 0);
    signal    m_req_size        : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    m_req_buf_ptr     : std_logic_vector(BUF_DEPTH-1 downto 0);
    signal    m_req_mode        : std_logic_vector(MODE_BITS-1 downto 0);
    signal    m_req_burst       : AXI4_ABURST_TYPE;
    signal    m_req_lock        : std_logic_vector(AXI4_ALOCK_WIDTH-1 downto 0);
    signal    m_req_cache       : AXI4_ACACHE_TYPE;
    signal    m_req_prot        : AXI4_APROT_TYPE;
    signal    m_req_qos         : AXI4_AQOS_TYPE;
    signal    m_req_region      : AXI4_AREGION_TYPE;
    signal    m_req_dir         : std_logic;
    signal    m_req_first       : std_logic;
    signal    m_req_last        : std_logic;
    signal    m_req_valid       : std_logic;
    signal    m_req_ready       : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    m_ack_valid       : std_logic;
    signal    m_ack_next        : std_logic;
    signal    m_ack_last        : std_logic;
    signal    m_ack_error       : std_logic;
    signal    m_ack_stop        : std_logic;
    signal    m_ack_none        : std_logic;
    signal    m_ack_size        : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    m_xfer_busy       : std_logic;
    signal    m_xfer_done       : std_logic;
    signal    m_xfer_error      : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  m_i_flow_level    : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    signal    m_i_flow_pause    : std_logic;
    signal    m_i_flow_stop     : std_logic;
    signal    m_i_flow_last     : std_logic;
    signal    m_i_flow_size     : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    m_i_flow_rdy      : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  m_push_fin_val    : std_logic := '0';
    constant  m_push_fin_last   : std_logic := '0';
    constant  m_push_fin_err    : std_logic := '0';
    constant  m_push_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  m_push_rsv_val    : std_logic := '0';
    constant  m_push_rsv_last   : std_logic := '0';
    constant  m_push_rsv_err    : std_logic := '0';
    constant  m_push_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  m_push_buf_level  : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    constant  m_push_buf_reset  : std_logic := '0';
    constant  m_push_buf_val    : std_logic := '0';
    constant  m_push_buf_last   : std_logic := '0';
    constant  m_push_buf_err    : std_logic := '0';
    constant  m_push_buf_size   : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    signal    m_push_buf_rdy    : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  m_o_flow_level    : std_logic_vector(SIZE_BITS-1 downto 0)
                               := std_logic_vector(to_unsigned(2**M_MAX_XFER_SIZE, SIZE_BITS));
    signal    m_o_flow_pause    : std_logic;
    signal    m_o_flow_stop     : std_logic;
    signal    m_o_flow_last     : std_logic;
    signal    m_o_flow_size     : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    m_o_flow_rdy      : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    m_pull_fin_val    : std_logic;
    signal    m_pull_fin_last   : std_logic;
    signal    m_pull_fin_err    : std_logic;
    signal    m_pull_fin_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    m_pull_rsv_val    : std_logic;
    signal    m_pull_rsv_last   : std_logic;
    signal    m_pull_rsv_err    : std_logic;
    signal    m_pull_rsv_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  m_pull_buf_level  : std_logic_vector(SIZE_BITS-1 downto 0)
                               := std_logic_vector(to_unsigned(BUF_DATA_BYTES, SIZE_BITS));
    signal    m_pull_buf_reset  : std_logic;
    signal    m_pull_buf_val    : std_logic;
    signal    m_pull_buf_last   : std_logic;
    signal    m_pull_buf_err    : std_logic;
    signal    m_pull_buf_size   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    m_pull_buf_rdy    : std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    m_pool_read       : std_logic;
    signal    m_pool_rdata      : std_logic_vector(BUF_DATA_BITS -1 downto 0);
    signal    m_pool_rptr       : std_logic_vector(BUF_DEPTH     -1 downto 0);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    T_IF: AXI4_SLAVE_WRITE_INTERFACE                     -- 
        generic map (                                    -- 
            AXI4_ADDR_WIDTH     => AXI4_ADDR_WIDTH     , -- 
            AXI4_ID_WIDTH       => AXI4_ID_WIDTH       , -- 
            AXI4_DATA_WIDTH     => T_DATA_WIDTH        , -- 
            VAL_BITS            => 1                   , --
            XFER_SIZE_BITS      => SIZE_BITS           , -- 
            BUF_DATA_WIDTH      => BUF_DATA_BITS       , -- 
            BUF_PTR_BITS        => BUF_DEPTH           , -- 
            ALIGNMENT_BITS      => ALIGNMENT_BITS        -- 
        )                                                -- 
        port map(                                        -- 
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            RST                 => RST                 , -- In  :
            CLK                 => T_CLK               , -- In  :
            CLR                 => T_CLR               , -- In  :
        ---------------------------------------------------------------------------
        -- AXI4 Write Signals.
        ---------------------------------------------------------------------------
            AWID                => T_AWID              , -- In  :
            AWADDR              => T_AWADDR            , -- In  :
            AWLEN               => T_AWLEN             , -- In  :
            AWSIZE              => T_AWSIZE            , -- In  :
            AWBURST             => T_AWBURST           , -- In  :
            AWVALID             => T_AWVALID           , -- In  :
            AWREADY             => T_AWREADY           , -- Out :
            WDATA               => T_WDATA             , -- In  :
            WSTRB               => T_WSTRB             , -- In  :
            WLAST               => T_WLAST             , -- In  :
            WVALID              => T_WVALID            , -- In  :
            WREADY              => T_WREADY            , -- Out :
            BID                 => T_BID               , -- Out :
            BRESP               => T_BRESP             , -- Out :
            BVALID              => T_BVALID            , -- Out :
            BREADY              => T_BREADY            , -- In  :
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
            REQ_ADDR            => t_req_addr          , -- Out :
            REQ_ID              => t_req_id            , -- Out :
            REQ_BURST           => t_req_burst         , -- Out :
            REQ_VAL             => t_req_valid         , -- Out :
            REQ_START           => t_req_start         , -- Out :
            REQ_RDY             => t_req_ready         , -- In  :
        ---------------------------------------------------------------------------
        -- Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            ACK_VAL             => t_ack_valid         , -- In  :
            ACK_NEXT            => t_ack_next          , -- In  :
            ACK_LAST            => t_ack_last          , -- In  :
            ACK_ERROR           => t_ack_error         , -- In  :
            ACK_SIZE            => t_ack_size          , -- In  :
        ---------------------------------------------------------------------------
        -- Transfer Control Singal.
        ---------------------------------------------------------------------------
            XFER_START          => t_req_start         , -- In  :
            XFER_LAST           => t_req_last          , -- In  :
            XFER_SEL            => t_xfer_select       , -- In  :
            XFER_BUF_PTR        => t_req_buf_ptr       , -- In  :
        ---------------------------------------------------------------------------
        -- Transfer Status Signal.
        ---------------------------------------------------------------------------
            XFER_BUSY(0)        => t_xfer_busy         , -- Out :
            XFER_DONE(0)        => t_xfer_done         , -- Out :
            XFER_ERROR(0)       => t_xfer_error        , -- Out :
        ---------------------------------------------------------------------------
        -- Push Reserve Size Signals.
        ---------------------------------------------------------------------------
            PUSH_RSV_VAL(0)     => t_push_rsv_val      , -- Out :
            PUSH_RSV_LAST       => t_push_rsv_last     , -- Out :
            PUSH_RSV_ERROR      => t_push_rsv_err      , -- Out :
            PUSH_RSV_SIZE       => t_push_rsv_size     , -- Out :
        ---------------------------------------------------------------------------
        -- Push Final Size Signals.
        ---------------------------------------------------------------------------
            PUSH_FIN_VAL(0)     => t_push_fin_val      , -- Out :
            PUSH_FIN_LAST       => t_push_fin_last     , -- Out :
            PUSH_FIN_ERROR      => t_push_fin_err      , -- Out :
            PUSH_FIN_SIZE       => t_push_fin_size     , -- Out :
        ---------------------------------------------------------------------------
        -- Push Buffer Size Signals.
        ---------------------------------------------------------------------------
            PUSH_BUF_RESET(0)   => t_push_buf_reset    , -- Out :
            PUSH_BUF_VAL(0)     => t_push_buf_val      , -- Out :
            PUSH_BUF_LAST       => t_push_buf_last     , -- Out :
            PUSH_BUF_ERROR      => t_push_buf_err      , -- Out :
            PUSH_BUF_SIZE       => t_push_buf_size     , -- Out :
            PUSH_BUF_RDY(0)     => t_push_buf_rdy      , -- In  :
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_WEN(0)          => t_pool_write        , -- Out :
            BUF_BEN             => t_pool_ben          , -- Out :
            BUF_DATA            => t_pool_wdata        , -- Out :
            BUF_PTR             => t_pool_wptr           -- Out :
        );
    t_req_mode(MODE_ID_HI      downto MODE_ID_LO     ) <= t_req_id;
    t_req_mode(MODE_ABURST_HI  downto MODE_ABURST_LO ) <= t_req_burst;
    t_req_mode(MODE_ALOCK_HI   downto MODE_ALOCK_LO  ) <= T_AWLOCK;
    t_req_mode(MODE_ACACHE_HI  downto MODE_ACACHE_LO ) <= T_AWCACHE;
    t_req_mode(MODE_APROT_HI   downto MODE_APROT_LO  ) <= T_AWPROT;
    t_req_mode(MODE_AQOS_HI    downto MODE_AQOS_LO   ) <= T_AWQOS;
    t_req_mode(MODE_AREGION_HI downto MODE_AREGION_LO) <= T_AWREGION;
    t_req_mode(MODE_AUSER_HI   downto MODE_AUSER_LO  ) <= T_AWUSER;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (t_req_addr) begin
        for i in t_req_buf_ptr'range loop
            if (i < ALIGNMENT_SIZE) then
                t_req_buf_ptr(i) <= t_req_addr(i);
            else
                t_req_buf_ptr(i) <= '0';
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    PIPE: PIPE_CONTROLLER                                -- 
        generic map (                                    -- 
            T_CLK_RATE          => T_CLK_RATE          , --
            M_CLK_RATE          => M_CLK_RATE          , --
            ADDR_BITS           => AXI4_ADDR_WIDTH     , --
            ADDR_VALID          => 1                   , --
            SIZE_BITS           => SIZE_BITS           , --
            SIZE_VALID          => 0                   , --
            MODE_BITS           => MODE_BITS           , --
            BUF_DEPTH           => BUF_DEPTH           , --
            XFER_SIZE_BITS      => SIZE_BITS           , --
            XFER_COUNT_BITS     => SIZE_BITS           , --
            T_XFER_MAX_SIZE     => T_MAX_XFER_SIZE     , --
            -----------------------------------------------------------------------
            -- PUSH
            -----------------------------------------------------------------------
            PUSH_VALID          => 1                   , --
            M_O_FIXED_CLOSE     => 0                   , --
            M_O_FIXED_FLOW_OPEN => 0                   , --
            M_O_FIXED_POOL_OPEN => 0                   , --
            T_I_FIXED_CLOSE     => 0                   , --
            T_I_FIXED_FLOW_OPEN => 1                   , --
            T_I_FIXED_POOL_OPEN => 0                   , --
            M2T_PULL_RSV_VALID  => 0                   , --
            M2T_PULL_BUF_VALID  => 1                   , --
            T2M_PUSH_RSV_VALID  => 0                   , --
            T2M_PUSH_BUF_VALID  => 1                   , --
            T2M_PUSH_FIN_DELAY  => 1                   , --
            -----------------------------------------------------------------------
            -- PULL
            -----------------------------------------------------------------------
            PULL_VALID          => 0                   , --
            M_I_FIXED_CLOSE     => 1                   , --
            M_I_FIXED_FLOW_OPEN => 0                   , --
            M_I_FIXED_POOL_OPEN => 0                   , --
            T_O_FIXED_CLOSE     => 1                   , --
            T_O_FIXED_FLOW_OPEN => 0                   , --
            T_O_FIXED_POOL_OPEN => 0                   , --
            M2T_PUSH_RSV_VALID  => 0                   , --
            M2T_PUSH_BUF_VALID  => 0                   , --
            T2M_PULL_RSV_VALID  => 0                   , --
            T2M_PULL_BUF_VALID  => 0                   , --
            M2T_PUSH_FIN_DELAY  => 0                     --
        )                                                --
        port map (                                       --
        ---------------------------------------------------------------------------
        -- リセット信号.
        ---------------------------------------------------------------------------
            RST                 => RST                 , -- In  :
        ---------------------------------------------------------------------------
        -- レスポンダ側クロック.
        ---------------------------------------------------------------------------
            T_CLK               => T_CLK               , -- In  :
            T_CLR               => T_CLR               , -- In  :
            T_CKE               => T_CKE               , -- In  :
        ---------------------------------------------------------------------------
        -- レスポンダ側からの要求信号入力.
        ---------------------------------------------------------------------------
            T_REQ_ADDR          => t_req_addr          , -- In  :
            T_REQ_SIZE          => t_req_size          , -- In  :
            T_REQ_BUF_PTR       => t_req_buf_ptr       , -- In  :
            T_REQ_MODE          => t_req_mode          , -- In  :
            T_REQ_DIR           => t_req_dir           , -- In  :
            T_REQ_FIRST         => t_req_first         , -- In  :
            T_REQ_LAST          => t_req_last          , -- In  :
            T_REQ_VALID         => t_req_valid         , -- In  :
            T_REQ_READY         => t_req_ready         , -- Out :
        ---------------------------------------------------------------------------
        -- レスポンダ側への応答信号出力.
        ---------------------------------------------------------------------------
            T_ACK_VALID         => t_ack_valid         , -- Out :
            T_ACK_NEXT          => t_ack_next          , -- Out :
            T_ACK_LAST          => t_ack_last          , -- Out :
            T_ACK_ERROR         => t_ack_error         , -- Out :
            T_ACK_STOP          => t_ack_stop          , -- Out :
            T_ACK_SIZE          => t_ack_size          , -- Out :
        ---------------------------------------------------------------------------
        -- レスポンダ側からの制御信号入力(未使用).
        ---------------------------------------------------------------------------
            T_REQ_STOP          => t_req_stop          , -- In  :
            T_REQ_PAUSE         => t_req_pause         , -- In  :
        ---------------------------------------------------------------------------
        -- レスポンダ側からのステータス信号入力.
        ---------------------------------------------------------------------------
            T_XFER_BUSY         => t_xfer_busy         , -- In  :
            T_XFER_DONE         => t_xfer_done         , -- In  :
            T_XFER_ERROR        => t_xfer_error        , -- In  :
        ---------------------------------------------------------------------------
        -- レスポンダ側からデータ入力のフロー制御信号入出力.
        ---------------------------------------------------------------------------
            T_I_FLOW_LEVEL      => t_i_flow_level      , -- In  :
            T_I_BUF_SIZE        => POOL_SIZE           , -- In  :
            T_I_FLOW_READY      => t_i_flow_rdy        , -- Out :
            T_I_FLOW_PAUSE      => t_i_flow_pause      , -- Out :
            T_I_FLOW_STOP       => t_i_flow_stop       , -- Out :
            T_I_FLOW_LAST       => t_i_flow_last       , -- Out :
            T_I_FLOW_SIZE       => t_i_flow_size       , -- Out :
            T_PUSH_FIN_VALID    => t_push_fin_val      , -- In  :
            T_PUSH_FIN_LAST     => t_push_fin_last     , -- In  :
            T_PUSH_FIN_ERROR    => t_push_fin_err      , -- In  :
            T_PUSH_FIN_SIZE     => t_push_fin_size     , -- In  :
            T_PUSH_RSV_VALID    => t_push_rsv_val      , -- In  :
            T_PUSH_RSV_LAST     => t_push_rsv_last     , -- In  :
            T_PUSH_RSV_ERROR    => t_push_rsv_err      , -- In  :
            T_PUSH_RSV_SIZE     => t_push_rsv_size     , -- In  :
            T_PUSH_BUF_LEVEL    => t_push_buf_level    , -- In  :
            T_PUSH_BUF_RESET    => t_push_buf_reset    , -- In  :
            T_PUSH_BUF_VALID    => t_push_buf_val      , -- In  :
            T_PUSH_BUF_LAST     => t_push_buf_last     , -- In  :
            T_PUSH_BUF_ERROR    => t_push_buf_err      , -- In  :
            T_PUSH_BUF_SIZE     => t_push_buf_size     , -- In  :
            T_PUSH_BUF_READY    => t_push_buf_rdy      , -- Out :
        ---------------------------------------------------------------------------
        -- レスポンダ側へのデータ出力のフロー制御信号入出力
        ---------------------------------------------------------------------------
            T_O_FLOW_LEVEL      => t_o_flow_level      , -- In  :
            T_O_FLOW_READY      => t_o_flow_rdy        , -- Out :
            T_O_FLOW_PAUSE      => t_o_flow_pause      , -- Out :
            T_O_FLOW_STOP       => t_o_flow_stop       , -- Out :
            T_O_FLOW_LAST       => t_o_flow_last       , -- Out :
            T_O_FLOW_SIZE       => t_o_flow_size       , -- Out :
            T_PULL_FIN_VALID    => t_pull_fin_val      , -- In  :
            T_PULL_FIN_LAST     => t_pull_fin_last     , -- In  :
            T_PULL_FIN_ERROR    => t_pull_fin_err      , -- In  :
            T_PULL_FIN_SIZE     => t_pull_fin_size     , -- In  :
            T_PULL_RSV_VALID    => t_pull_rsv_val      , -- In  :
            T_PULL_RSV_LAST     => t_pull_rsv_last     , -- In  :
            T_PULL_RSV_ERROR    => t_pull_rsv_err      , -- In  :
            T_PULL_RSV_SIZE     => t_pull_rsv_size     , -- In  :
            T_PULL_BUF_LEVEL    => t_pull_buf_level    , -- In  :
            T_PULL_BUF_RESET    => t_pull_buf_reset    , -- In  :
            T_PULL_BUF_VALID    => t_pull_buf_val      , -- In  :
            T_PULL_BUF_LAST     => t_pull_buf_last     , -- In  :
            T_PULL_BUF_ERROR    => t_pull_buf_err      , -- In  :
            T_PULL_BUF_SIZE     => t_pull_buf_size     , -- In  :
            T_PULL_BUF_READY    => t_pull_buf_rdy      , -- Out :
        ---------------------------------------------------------------------------
        -- リクエスト側クロック.
        ---------------------------------------------------------------------------
            M_CLK               => M_CLK               , -- In  :
            M_CLR               => M_CLR               , -- In  :
            M_CKE               => M_CKE               , -- In  :
        ---------------------------------------------------------------------------
        -- リクエスタ側への要求信号出力.
        ---------------------------------------------------------------------------
            M_REQ_ADDR          => m_req_addr          , -- Out :
            M_REQ_SIZE          => m_req_size          , -- Out :
            M_REQ_BUF_PTR       => m_req_buf_ptr       , -- Out :
            M_REQ_MODE          => m_req_mode          , -- Out :
            M_REQ_DIR           => m_req_dir           , -- Out :
            M_REQ_FIRST         => m_req_first         , -- Out :
            M_REQ_LAST          => m_req_last          , -- Out :
            M_REQ_VALID         => m_req_valid         , -- Out :
            M_REQ_READY         => m_req_ready         , -- In  :
        ---------------------------------------------------------------------------
        -- リクエスタ側からの応答信号入力.
        ---------------------------------------------------------------------------
            M_ACK_VALID         => m_ack_valid         , -- In  :
            M_ACK_NEXT          => m_ack_next          , -- In  :
            M_ACK_LAST          => m_ack_last          , -- In  :
            M_ACK_ERROR         => m_ack_error         , -- In  :
            M_ACK_STOP          => m_ack_stop          , -- In  :
            M_ACK_NONE          => m_ack_none          , -- In  :
            M_ACK_SIZE          => m_ack_size          , -- In  :
        ---------------------------------------------------------------------------
        -- リクエスタ側からのステータス信号入力.
        ---------------------------------------------------------------------------
            M_XFER_BUSY         => m_xfer_busy         , -- In  :
            M_XFER_DONE         => m_xfer_done         , -- In  :
            M_XFER_ERROR        => m_xfer_error        , -- In  :
        ---------------------------------------------------------------------------
        -- リクエスタ側からデータ入力のフロー制御信号入出力.
        ---------------------------------------------------------------------------
            M_I_BUF_SIZE        => POOL_SIZE           , -- In  :
            M_I_FLOW_PAUSE      => m_i_flow_pause      , -- Out :
            M_I_FLOW_STOP       => m_i_flow_stop       , -- Out :
            M_I_FLOW_LAST       => m_i_flow_last       , -- Out :
            M_I_FLOW_SIZE       => m_i_flow_size       , -- Out :
            M_I_FLOW_READY      => m_i_flow_rdy        , -- Out :
            M_I_FLOW_LEVEL      => m_i_flow_level      , -- In  :
            M_PUSH_FIN_VALID    => m_push_fin_val      , -- In  :
            M_PUSH_FIN_LAST     => m_push_fin_last     , -- In  :
            M_PUSH_FIN_ERROR    => m_push_fin_err      , -- In  :
            M_PUSH_FIN_SIZE     => m_push_fin_size     , -- In  :
            M_PUSH_RSV_VALID    => m_push_rsv_val      , -- In  :
            M_PUSH_RSV_LAST     => m_push_rsv_last     , -- In  :
            M_PUSH_RSV_ERROR    => m_push_rsv_err      , -- In  :
            M_PUSH_RSV_SIZE     => m_push_rsv_size     , -- In  :
            M_PUSH_BUF_RESET    => m_push_buf_reset    , -- In  :
            M_PUSH_BUF_VALID    => m_push_buf_val      , -- In  :
            M_PUSH_BUF_LAST     => m_push_buf_last     , -- In  :
            M_PUSH_BUF_ERROR    => m_push_buf_err      , -- In  :
            M_PUSH_BUF_SIZE     => m_push_buf_size     , -- In  :
            M_PUSH_BUF_READY    => m_push_buf_rdy      , -- In  :
            M_PUSH_BUF_LEVEL    => m_push_buf_level    , -- In  :
        ---------------------------------------------------------------------------
        -- リクエスタ側へのデータ出力のフロー制御信号入出力
        ---------------------------------------------------------------------------
            M_O_FLOW_PAUSE      => m_o_flow_pause      , -- Out :
            M_O_FLOW_STOP       => m_o_flow_stop       , -- Out :
            M_O_FLOW_LAST       => m_o_flow_last       , -- Out :
            M_O_FLOW_SIZE       => m_o_flow_size       , -- Out :
            M_O_FLOW_READY      => m_o_flow_rdy        , -- Out :
            M_O_FLOW_LEVEL      => m_o_flow_level      , -- In  :
            M_PULL_FIN_VALID    => m_pull_fin_val      , -- In  :
            M_PULL_FIN_LAST     => m_pull_fin_last     , -- In  :
            M_PULL_FIN_ERROR    => m_pull_fin_err      , -- In  :
            M_PULL_FIN_SIZE     => m_pull_fin_size     , -- In  :
            M_PULL_RSV_VALID    => m_pull_rsv_val      , -- In  :
            M_PULL_RSV_LAST     => m_pull_rsv_last     , -- In  :
            M_PULL_RSV_ERROR    => m_pull_rsv_err      , -- In  :
            M_PULL_RSV_SIZE     => m_pull_rsv_size     , -- In  :
            M_PULL_BUF_LEVEL    => m_pull_buf_level    , -- In  :
            M_PULL_BUF_RESET    => m_pull_buf_reset    , -- In  :
            M_PULL_BUF_VALID    => m_pull_buf_val      , -- In  :
            M_PULL_BUF_LAST     => m_pull_buf_last     , -- In  :
            M_PULL_BUF_ERROR    => m_pull_buf_err      , -- In  :
            M_PULL_BUF_SIZE     => m_pull_buf_size     , -- In  :
            M_PULL_BUF_READY    => m_pull_buf_rdy        -- Out :
        );
    m_req_id     <= m_req_mode(MODE_ID_HI      downto MODE_ID_LO     );
    m_req_burst  <= m_req_mode(MODE_ABURST_HI  downto MODE_ABURST_LO );
    m_req_lock   <= m_req_mode(MODE_ALOCK_HI   downto MODE_ALOCK_LO  );
    m_req_cache  <= m_req_mode(MODE_ACACHE_HI  downto MODE_ACACHE_LO );
    m_req_prot   <= m_req_mode(MODE_APROT_HI   downto MODE_APROT_LO  );
    m_req_qos    <= m_req_mode(MODE_AQOS_HI    downto MODE_AQOS_LO   );
    m_req_region <= m_req_mode(MODE_AREGION_HI downto MODE_AREGION_LO);
    M_AWUSER     <= m_req_mode(MODE_AUSER_HI   downto MODE_AUSER_LO  );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    POOL: SDPRAM                                         --
        generic map (                                    --
            DEPTH   => BUF_DEPTH+3                     , --
            RWIDTH  => BUF_DATA_BIT_SIZE               , --
            WWIDTH  => BUF_DATA_BIT_SIZE               , --
            WEBIT   => BUF_DATA_BYTE_SIZE              , --
            ID      => 0                                 --
        )                                                --
        port map (                                       --
            WCLK    => T_CLK                           , -- In  :
            WE      => t_pool_we                       , -- In  :
            WADDR   => t_pool_wptr(BUF_DEPTH-1 downto BUF_DATA_BYTE_SIZE), 
            WDATA   => t_pool_wdata                    , -- In  :
            RCLK    => M_CLK                           , -- In  :
            RADDR   => m_pool_rptr(BUF_DEPTH-1 downto BUF_DATA_BYTE_SIZE),
            RDATA   => m_pool_rdata                      -- Out :
        );
    t_pool_we <= t_pool_ben when (t_pool_write = '1') else (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    M_IF: AXI4_MASTER_WRITE_INTERFACE                    -- 
        generic map (                                    -- 
            AXI4_ADDR_WIDTH     => AXI4_ADDR_WIDTH     , -- 
            AXI4_ID_WIDTH       => AXI4_ID_WIDTH       , -- 
            AXI4_DATA_WIDTH     => M_DATA_WIDTH        , -- 
            VAL_BITS            => 1                   , -- 
            REQ_SIZE_BITS       => SIZE_BITS           , -- 
            REQ_SIZE_VALID      => 0                   , -- 
            FLOW_VALID          => 1                   , -- 
            BUF_DATA_WIDTH      => BUF_DATA_BITS       , -- 
            BUF_PTR_BITS        => BUF_DEPTH           , -- 
            ALIGNMENT_BITS      => ALIGNMENT_BITS      , -- 
            XFER_SIZE_BITS      => SIZE_BITS           , -- 
            XFER_MIN_SIZE       => M_MAX_XFER_SIZE     , -- 
            XFER_MAX_SIZE       => M_MAX_XFER_SIZE     , -- 
            QUEUE_SIZE          => 1                   , --
            RESP_REGS           => RESP_REGS             --
        )                                                -- 
        port map(                                        -- 
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            RST                 => RST                 , -- In  :
            CLK                 => M_CLK               , -- In  :
            CLR                 => M_CLR               , -- In  :
        ---------------------------------------------------------------------------
        -- AXI4 Write Signals.
        ---------------------------------------------------------------------------
            AWID                => M_AWID              , -- Out :
            AWADDR              => M_AWADDR            , -- Out :
            AWLEN               => M_AWLEN             , -- Out :
            AWSIZE              => M_AWSIZE            , -- Out :
            AWBURST             => M_AWBURST           , -- Out :
            AWLOCK              => M_AWLOCK            , -- Out :
            AWCACHE             => M_AWCACHE           , -- Out :
            AWPROT              => M_AWPROT            , -- Out :
            AWQOS               => M_AWQOS             , -- Out :
            AWREGION            => M_AWREGION          , -- Out :
            AWVALID             => M_AWVALID           , -- Out :
            AWREADY             => M_AWREADY           , -- In  :
            WID                 => M_WID               , -- Out :
            WDATA               => M_WDATA             , -- Out :
            WSTRB               => M_WSTRB             , -- Out :
            WLAST               => M_WLAST             , -- Out :
            WVALID              => M_WVALID            , -- Out :
            WREADY              => M_WREADY            , -- In  :
            BID                 => M_BID               , -- In  :
            BRESP               => M_BRESP             , -- In  :
            BVALID              => M_BVALID            , -- In  :
            BREADY              => M_BREADY            , -- Out :
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
            XFER_SIZE_SEL       => m_xfer_size_sel     , -- In  :
            REQ_ADDR            => m_req_addr          , -- In  :
            REQ_SIZE            => m_req_size          , -- In  :
            REQ_ID              => m_req_id            , -- In  :
            REQ_BURST           => m_req_burst         , -- In  :
            REQ_LOCK            => m_req_lock          , -- In  :
            REQ_CACHE           => m_req_cache         , -- In  :
            REQ_PROT            => m_req_prot          , -- In  :
            REQ_QOS             => m_req_qos           , -- In  :
            REQ_REGION          => m_req_region        , -- In  :
            REQ_BUF_PTR         => m_req_buf_ptr       , -- In  :
            REQ_FIRST           => m_req_first         , -- In  :
            REQ_LAST            => m_req_last          , -- In  :
            REQ_SPECULATIVE     => m_req_speculative   , -- In  :
            REQ_SAFETY          => m_req_safety        , -- In  :
            REQ_VAL(0)          => m_req_valid         , -- In  :
            REQ_RDY             => m_req_ready         , -- Out :
        ---------------------------------------------------------------------------
        -- Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            ACK_VAL(0)          => m_ack_valid         , -- Out :
            ACK_NEXT            => m_ack_next          , -- Out :
            ACK_LAST            => m_ack_last          , -- Out :
            ACK_ERROR           => m_ack_error         , -- Out :
            ACK_STOP            => m_ack_stop          , -- Out :
            ACK_NONE            => m_ack_none          , -- Out :
            ACK_SIZE            => m_ack_size          , -- Out :
        ---------------------------------------------------------------------------
        -- Transfer Status Signal.
        ---------------------------------------------------------------------------
            XFER_BUSY(0)        => m_xfer_busy         , -- Out :
            XFER_DONE(0)        => m_xfer_done         , -- Out :
            XFER_ERROR(0)       => m_xfer_error        , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_STOP           => m_o_flow_stop       , -- In  :
            FLOW_PAUSE          => m_o_flow_pause      , -- In  :
            FLOW_LAST           => m_o_flow_last       , -- In  :
            FLOW_SIZE           => m_o_flow_size       , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Reserve Size Signals.
        ---------------------------------------------------------------------------
            PULL_RSV_VAL(0)     => m_pull_rsv_val      , -- Out :
            PULL_RSV_LAST       => m_pull_rsv_last     , -- Out :
            PULL_RSV_ERROR      => m_pull_rsv_err      , -- Out :
            PULL_RSV_SIZE       => m_pull_rsv_size     , -- Out :
        ---------------------------------------------------------------------------
        -- Pull Final Size Signals.
        ---------------------------------------------------------------------------
            PULL_FIN_VAL(0)     => m_pull_fin_val      , -- Out :
            PULL_FIN_LAST       => m_pull_fin_last     , -- Out :
            PULL_FIN_ERROR      => m_pull_fin_err      , -- Out :
            PULL_FIN_SIZE       => m_pull_fin_size     , -- Out :
        ---------------------------------------------------------------------------
        -- Pull Buffer Size Signals.
        ---------------------------------------------------------------------------
            PULL_BUF_RESET(0)   => m_pull_buf_reset    , -- Out :
            PULL_BUF_VAL(0)     => m_pull_buf_val      , -- Out :
            PULL_BUF_LAST       => m_pull_buf_last     , -- Out :
            PULL_BUF_ERROR      => m_pull_buf_err      , -- Out :
            PULL_BUF_SIZE       => m_pull_buf_size     , -- Out :
            PULL_BUF_RDY(0)     => m_pull_buf_rdy      , -- In  :
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_REN(0)          => m_pool_read         , -- Out :
            BUF_DATA            => m_pool_rdata        , -- In  :
            BUF_PTR             => m_pool_rptr           -- Out :
        );
end RTL;
