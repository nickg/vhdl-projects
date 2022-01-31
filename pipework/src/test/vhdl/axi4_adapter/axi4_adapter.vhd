-----------------------------------------------------------------------------------
--!     @file    aix4_adapter.vhd
--!     @brief   AXI4_ADPATER
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
--! @brief   AXI4-AXI4 Adapter
-----------------------------------------------------------------------------------
entity  AXI4_ADAPTER is
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
        RDATA_REGS          : --! @brief RDATA REGISTER TYPE :
                              --! RDATA/RRESP/RLAST/RVALID の入力をどうするか指定する.
                              --! * RDATA_REGS=0 スルー入力(レジスタは通さない).
                              --! * RDATA_REGS=1 １段だけレジスタを通す. 
                              --!   ただしバースト転送時には１サイクル毎にウェイトが入る.
                              --! * RDATA_REGS=2 ２段のレジスタを通す.
                              --! * RDATA_REGS=3 ３段のレジスタを通す.
                              --!   このモードの場合、必ずRDATA/RRESPは一つのレジスタ
                              --!   で受けるので外部インターフェース向き.
                              integer := 0;
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
        T_ARID              : in    std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
        T_ARUSER            : in    std_logic_vector(AXI4_AUSER_WIDTH-1 downto 0);
        T_ARADDR            : in    std_logic_vector(AXI4_ADDR_WIDTH -1 downto 0);
        T_ARLEN             : in    std_logic_vector(AXI4_ALEN_WIDTH -1 downto 0);
        T_ARSIZE            : in    AXI4_ASIZE_TYPE;
        T_ARBURST           : in    AXI4_ABURST_TYPE;
        T_ARLOCK            : in    std_logic_vector(AXI4_ALOCK_WIDTH-1 downto 0);
        T_ARCACHE           : in    AXI4_ACACHE_TYPE;
        T_ARPROT            : in    AXI4_APROT_TYPE;
        T_ARQOS             : in    AXI4_AQOS_TYPE;
        T_ARREGION          : in    AXI4_AREGION_TYPE;
        T_ARVALID           : in    std_logic;
        T_ARREADY           : out   std_logic;
        T_RID               : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
        T_RDATA             : out   std_logic_vector(T_DATA_WIDTH    -1 downto 0);
        T_RRESP             : out   AXI4_RESP_TYPE;
        T_RLAST             : out   std_logic;
        T_RVALID            : out   std_logic;
        T_RREADY            : in    std_logic;
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
        M_BREADY            : out   std_logic;
        M_ARID              : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
        M_ARUSER            : out   std_logic_vector(AXI4_AUSER_WIDTH-1 downto 0);
        M_ARADDR            : out   std_logic_vector(AXI4_ADDR_WIDTH -1 downto 0);
        M_ARLEN             : out   std_logic_vector(AXI4_ALEN_WIDTH -1 downto 0);
        M_ARSIZE            : out   AXI4_ASIZE_TYPE;
        M_ARBURST           : out   AXI4_ABURST_TYPE;
        M_ARLOCK            : out   std_logic_vector(AXI4_ALOCK_WIDTH-1 downto 0);
        M_ARCACHE           : out   AXI4_ACACHE_TYPE;
        M_ARPROT            : out   AXI4_APROT_TYPE;
        M_ARQOS             : out   AXI4_AQOS_TYPE;
        M_ARREGION          : out   AXI4_AREGION_TYPE;
        M_ARVALID           : out   std_logic;
        M_ARREADY           : in    std_logic;
        M_RID               : in    std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
        M_RDATA             : in    std_logic_vector(M_DATA_WIDTH    -1 downto 0);
        M_RRESP             : in    AXI4_RESP_TYPE;
        M_RLAST             : in    std_logic;
        M_RVALID            : in    std_logic;
        M_RREADY            : out   std_logic
    );
end AXI4_ADAPTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of AXI4_ADAPTER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component AXI4_WRITE_ADAPTER
        generic (
            AXI4_ID_WIDTH       : integer := 4;
            AXI4_AUSER_WIDTH    : integer := 1;
            AXI4_ADDR_WIDTH     : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
            T_CLK_RATE          : integer :=  1;
            T_DATA_WIDTH        : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
            M_CLK_RATE          : integer :=  1;
            M_DATA_WIDTH        : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
            M_MAX_XFER_SIZE     : integer := 12;
            BUF_DEPTH           : integer := 12;
            RESP_REGS           : integer := 0
        );
        port(
            RST                 : in    std_logic;
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
    end component;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component AXI4_READ_ADAPTER
        generic (
            AXI4_ID_WIDTH       : integer ;
            AXI4_AUSER_WIDTH    : integer := 1;
            AXI4_ADDR_WIDTH     : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
            T_CLK_RATE          : integer :=  1;
            T_DATA_WIDTH        : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
            M_CLK_RATE          : integer :=  1;
            M_DATA_WIDTH        : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
            M_MAX_XFER_SIZE     : integer := 12;
            BUF_DEPTH           : integer := 12;
            RDATA_REGS          : integer := 0
        );
        port(
            RST                 : in    std_logic;
            T_CLK               : in    std_logic;
            T_CKE               : in    std_logic;
            T_CLR               : in    std_logic;
            T_ARID              : in    std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            T_ARUSER            : in    std_logic_vector(AXI4_AUSER_WIDTH-1 downto 0);
            T_ARADDR            : in    std_logic_vector(AXI4_ADDR_WIDTH -1 downto 0);
            T_ARLEN             : in    std_logic_vector(AXI4_ALEN_WIDTH -1 downto 0);
            T_ARSIZE            : in    AXI4_ASIZE_TYPE;
            T_ARBURST           : in    AXI4_ABURST_TYPE;
            T_ARLOCK            : in    std_logic_vector(AXI4_ALOCK_WIDTH-1 downto 0);
            T_ARCACHE           : in    AXI4_ACACHE_TYPE;
            T_ARPROT            : in    AXI4_APROT_TYPE;
            T_ARQOS             : in    AXI4_AQOS_TYPE;
            T_ARREGION          : in    AXI4_AREGION_TYPE;
            T_ARVALID           : in    std_logic;
            T_ARREADY           : out   std_logic;
            T_RID               : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            T_RDATA             : out   std_logic_vector(T_DATA_WIDTH    -1 downto 0);
            T_RRESP             : out   AXI4_RESP_TYPE;
            T_RLAST             : out   std_logic;
            T_RVALID            : out   std_logic;
            T_RREADY            : in    std_logic;
            M_CLK               : in    std_logic;
            M_CKE               : in    std_logic;
            M_CLR               : in    std_logic;
            M_ARID              : out   std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            M_ARUSER            : out   std_logic_vector(AXI4_AUSER_WIDTH-1 downto 0);
            M_ARADDR            : out   std_logic_vector(AXI4_ADDR_WIDTH -1 downto 0);
            M_ARLEN             : out   std_logic_vector(AXI4_ALEN_WIDTH -1 downto 0);
            M_ARSIZE            : out   AXI4_ASIZE_TYPE;
            M_ARBURST           : out   AXI4_ABURST_TYPE;
            M_ARLOCK            : out   std_logic_vector(AXI4_ALOCK_WIDTH-1 downto 0);
            M_ARCACHE           : out   AXI4_ACACHE_TYPE;
            M_ARPROT            : out   AXI4_APROT_TYPE;
            M_ARQOS             : out   AXI4_AQOS_TYPE;
            M_ARREGION          : out   AXI4_AREGION_TYPE;
            M_ARVALID           : out   std_logic;
            M_ARREADY           : in    std_logic;
            M_RID               : in    std_logic_vector(AXI4_ID_WIDTH   -1 downto 0);
            M_RDATA             : in    std_logic_vector(M_DATA_WIDTH    -1 downto 0);
            M_RRESP             : in    AXI4_RESP_TYPE;
            M_RLAST             : in    std_logic;
            M_RVALID            : in    std_logic;
            M_RREADY            : out   std_logic
        );
    end component;
begin
    W: AXI4_WRITE_ADAPTER
        generic map (
            AXI4_ID_WIDTH       => AXI4_ID_WIDTH       , -- 
            AXI4_AUSER_WIDTH    => AXI4_AUSER_WIDTH    , -- 
            AXI4_ADDR_WIDTH     => AXI4_ADDR_WIDTH     , --
            T_CLK_RATE          => T_CLK_RATE          , --
            T_DATA_WIDTH        => T_DATA_WIDTH        , --
            M_CLK_RATE          => M_CLK_RATE          , --
            M_DATA_WIDTH        => M_DATA_WIDTH        , --
            M_MAX_XFER_SIZE     => M_MAX_XFER_SIZE     , --
            BUF_DEPTH           => BUF_DEPTH           , --
            RESP_REGS           => RESP_REGS             -- 
        )                                                -- 
        port map(                                        -- 
            RST                 => RST                 , -- In  :
            T_CLK               => T_CLK               , -- In  :
            T_CKE               => T_CKE               , -- In  :
            T_CLR               => T_CLR               , -- In  :
            T_AWID              => T_AWID              , -- In  :
            T_AWUSER            => T_AWUSER            , -- In  :
            T_AWADDR            => T_AWADDR            , -- In  :
            T_AWLEN             => T_AWLEN             , -- In  :
            T_AWSIZE            => T_AWSIZE            , -- In  :
            T_AWBURST           => T_AWBURST           , -- In  :
            T_AWLOCK            => T_AWLOCK            , -- In  :
            T_AWCACHE           => T_AWCACHE           , -- In  :
            T_AWPROT            => T_AWPROT            , -- In  :
            T_AWQOS             => T_AWQOS             , -- In  :
            T_AWREGION          => T_AWREGION          , -- In  :
            T_AWVALID           => T_AWVALID           , -- In  :
            T_AWREADY           => T_AWREADY           , -- Out :
            T_WDATA             => T_WDATA             , -- In  :
            T_WSTRB             => T_WSTRB             , -- In  :
            T_WLAST             => T_WLAST             , -- In  :
            T_WVALID            => T_WVALID            , -- In  :
            T_WREADY            => T_WREADY            , -- Out :
            T_BID               => T_BID               , -- Out :
            T_BRESP             => T_BRESP             , -- Out :
            T_BVALID            => T_BVALID            , -- Out :
            T_BREADY            => T_BREADY            , -- In  :
            M_CLK               => M_CLK               , -- In  :
            M_CKE               => M_CKE               , -- In  :
            M_CLR               => M_CLR               , -- In  :
            M_AWID              => M_AWID              , -- Out :
            M_AWUSER            => M_AWUSER            , -- Out :
            M_AWADDR            => M_AWADDR            , -- Out :
            M_AWLEN             => M_AWLEN             , -- Out :
            M_AWSIZE            => M_AWSIZE            , -- Out :
            M_AWBURST           => M_AWBURST           , -- Out :
            M_AWLOCK            => M_AWLOCK            , -- Out :
            M_AWCACHE           => M_AWCACHE           , -- Out :
            M_AWPROT            => M_AWPROT            , -- Out :
            M_AWQOS             => M_AWQOS             , -- Out :
            M_AWREGION          => M_AWREGION          , -- Out :
            M_AWVALID           => M_AWVALID           , -- Out :
            M_AWREADY           => M_AWREADY           , -- In  :
            M_WID               => M_WID               , -- Out :
            M_WDATA             => M_WDATA             , -- Out :
            M_WSTRB             => M_WSTRB             , -- Out :
            M_WLAST             => M_WLAST             , -- Out :
            M_WVALID            => M_WVALID            , -- Out :
            M_WREADY            => M_WREADY            , -- In  :
            M_BID               => M_BID               , -- In  :
            M_BRESP             => M_BRESP             , -- In  :
            M_BVALID            => M_BVALID            , -- In  :
            M_BREADY            => M_BREADY              -- Out :
        );
    R: AXI4_READ_ADAPTER
        generic map (
            AXI4_ID_WIDTH       => AXI4_ID_WIDTH       , -- 
            AXI4_AUSER_WIDTH    => AXI4_AUSER_WIDTH    , -- 
            AXI4_ADDR_WIDTH     => AXI4_ADDR_WIDTH     , -- 
            T_CLK_RATE          => T_CLK_RATE          , -- 
            T_DATA_WIDTH        => T_DATA_WIDTH        , -- 
            M_CLK_RATE          => M_CLK_RATE          , -- 
            M_DATA_WIDTH        => M_DATA_WIDTH        , -- 
            M_MAX_XFER_SIZE     => M_MAX_XFER_SIZE     , -- 
            BUF_DEPTH           => BUF_DEPTH           , --
            RDATA_REGS          => RDATA_REGS            -- 
        )                                                -- 
        port map (                                       -- 
            RST                 => RST                 , -- In  :
            T_CLK               => T_CLK               , -- In  :
            T_CKE               => T_CKE               , -- In  :
            T_CLR               => T_CLR               , -- In  :
            T_ARID              => T_ARID              , -- In  :
            T_ARUSER            => T_ARUSER            , -- In  :
            T_ARADDR            => T_ARADDR            , -- In  :
            T_ARLEN             => T_ARLEN             , -- In  :
            T_ARSIZE            => T_ARSIZE            , -- In  :
            T_ARBURST           => T_ARBURST           , -- In  :
            T_ARLOCK            => T_ARLOCK            , -- In  :
            T_ARCACHE           => T_ARCACHE           , -- In  :
            T_ARPROT            => T_ARPROT            , -- In  :
            T_ARQOS             => T_ARQOS             , -- In  :
            T_ARREGION          => T_ARREGION          , -- In  :
            T_ARVALID           => T_ARVALID           , -- In  :
            T_ARREADY           => T_ARREADY           , -- Out :
            T_RID               => T_RID               , -- Out :
            T_RDATA             => T_RDATA             , -- Out :
            T_RRESP             => T_RRESP             , -- Out :
            T_RLAST             => T_RLAST             , -- Out :
            T_RVALID            => T_RVALID            , -- Out :
            T_RREADY            => T_RREADY            , -- In  :
            M_CLK               => M_CLK               , -- In  :
            M_CKE               => M_CKE               , -- In  :
            M_CLR               => M_CLR               , -- In  :
            M_ARID              => M_ARID              , -- Out :
            M_ARUSER            => M_ARUSER            , -- Out :
            M_ARADDR            => M_ARADDR            , -- Out :
            M_ARLEN             => M_ARLEN             , -- Out :
            M_ARSIZE            => M_ARSIZE            , -- Out :
            M_ARBURST           => M_ARBURST           , -- Out :
            M_ARLOCK            => M_ARLOCK            , -- Out :
            M_ARCACHE           => M_ARCACHE           , -- Out :
            M_ARPROT            => M_ARPROT            , -- Out :
            M_ARQOS             => M_ARQOS             , -- Out :
            M_ARREGION          => M_ARREGION          , -- Out :
            M_ARVALID           => M_ARVALID           , -- Out :
            M_ARREADY           => M_ARREADY           , -- In  :
            M_RID               => M_RID               , -- In  :
            M_RDATA             => M_RDATA             , -- In  :
            M_RRESP             => M_RRESP             , -- In  :
            M_RLAST             => M_RLAST             , -- In  :
            M_RVALID            => M_RVALID            , -- In  :
            M_RREADY            => M_RREADY              -- Out :
        );
end RTL;
