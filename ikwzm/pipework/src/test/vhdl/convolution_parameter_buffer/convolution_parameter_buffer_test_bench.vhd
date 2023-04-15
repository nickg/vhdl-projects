-----------------------------------------------------------------------------------
--!     @file    convolution_parameter_buffer_test_bench.vhd
--!     @brief   Test Bench for Convolution Parameter Buffer Module
--!     @version 1.8.0
--!     @date    2019/3/21
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2019 Ichiro Kawazome
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
entity  CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH is
    generic (
        NAME            : STRING  := "test";
        SCENARIO_FILE   : STRING  := "test.snr";
        KY_SIZE         : integer := 1;
        KX_SIZE         : integer := 1;
        D_UNROLL        : integer := 1;
        C_UNROLL        : integer := 1;
        SHAPE_CONSTANT  : boolean := FALSE;
        SHAPE_H         : integer := 1;
        SHAPE_W         : integer := 1;
        SHAPE_D         : integer := 1;
        SHAPE_C         : integer := 1;
        FINISH_ABORT    : boolean := FALSE
    );
end CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.all;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_MASTER_PLAYER;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.COMPONENTS.REGISTER_ACCESS_ADAPTER;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_REGISTER_INTERFACE;
use     PIPEWORK.CONVOLUTION_COMPONENTS.CONVOLUTION_PARAMETER_BUFFER;
architecture MODEL of CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant  PERIOD            :  time    := 10 ns;
    constant  DELAY             :  time    :=  1 ns;
    constant  SYNC_WIDTH        :  integer :=  2;
    constant  GPO_WIDTH         :  integer :=  8;
    constant  GPI_WIDTH         :  integer :=  GPO_WIDTH;
    constant  ELEM_BITS         :  integer :=  8;
    constant  SIZE_BITS         :  integer := 12;
    constant  PARAM             :  IMAGE_STREAM_PARAM_TYPE
                                := NEW_IMAGE_STREAM_PARAM(
                                       ELEM_BITS => ELEM_BITS,
                                       SHAPE     => NEW_IMAGE_SHAPE(
                                           ELEM_BITS => ELEM_BITS,
                                           C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(C_UNROLL, TRUE, TRUE),
                                           D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(D_UNROLL, TRUE, TRUE),
                                           X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(KX_SIZE , TRUE, TRUE),
                                           Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(KY_SIZE , TRUE, TRUE)
                                       )
                                   );
    function  NEW_SHAPE return IMAGE_SHAPE_TYPE is
    begin
        if (SHAPE_CONSTANT = TRUE) then
            return NEW_IMAGE_SHAPE(
                       ELEM_BITS => ELEM_BITS,
                       C         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(SHAPE_C),
                       D         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(SHAPE_D),
                       X         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(SHAPE_W),
                       Y         => NEW_IMAGE_SHAPE_SIDE_CONSTANT(SHAPE_H)
                   );
        else
            return NEW_IMAGE_SHAPE(
                       ELEM_BITS => ELEM_BITS,
                       C         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(2**SIZE_BITS),
                       D         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(2**SIZE_BITS),
                       X         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(2**SIZE_BITS),
                       Y         => NEW_IMAGE_SHAPE_SIDE_EXTERNAL(2**SIZE_BITS)
                   );
        end if;
    end function;
    constant  SHAPE             :  IMAGE_SHAPE_TYPE := NEW_SHAPE;
    constant  ELEMENT_SIZE      :  integer := 4096;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal    CLK               :  std_logic;
    signal    RESET             :  std_logic;
    signal    ARESETn           :  std_logic;
    constant  CLEAR             :  std_logic := '0';
    ------------------------------------------------------------------------------
    -- CSR I/F
    ------------------------------------------------------------------------------
    constant  C_WIDTH           :  AXI4_SIGNAL_WIDTH_TYPE := (
                                     ID          => 4,
                                     AWADDR      => 32,
                                     ARADDR      => 32,
                                     ALEN        => AXI4_ALEN_WIDTH,
                                     ALOCK       => AXI4_ALOCK_WIDTH,
                                     WDATA       => 32,
                                     RDATA       => 32,
                                     ARUSER      => 1,
                                     AWUSER      => 1,
                                     WUSER       => 1,
                                     RUSER       => 1,
                                     BUSER       => 1);
    signal    C_ARADDR          :  std_logic_vector(C_WIDTH.ARADDR -1 downto 0);
    signal    C_ARLEN           :  std_logic_vector(C_WIDTH.ALEN   -1 downto 0);
    signal    C_ARSIZE          :  AXI4_ASIZE_TYPE;
    signal    C_ARBURST         :  AXI4_ABURST_TYPE;
    signal    C_ARLOCK          :  std_logic_vector(C_WIDTH.ALOCK  -1 downto 0);
    signal    C_ARCACHE         :  AXI4_ACACHE_TYPE;
    signal    C_ARPROT          :  AXI4_APROT_TYPE;
    signal    C_ARQOS           :  AXI4_AQOS_TYPE;
    signal    C_ARREGION        :  AXI4_AREGION_TYPE;
    signal    C_ARUSER          :  std_logic_vector(C_WIDTH.ARUSER -1 downto 0);
    signal    C_ARID            :  std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal    C_ARVALID         :  std_logic;
    signal    C_ARREADY         :  std_logic;
    signal    C_RVALID          :  std_logic;
    signal    C_RLAST           :  std_logic;
    signal    C_RDATA           :  std_logic_vector(C_WIDTH.RDATA  -1 downto 0);
    signal    C_RRESP           :  AXI4_RESP_TYPE;
    signal    C_RUSER           :  std_logic_vector(C_WIDTH.RUSER  -1 downto 0);
    signal    C_RID             :  std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal    C_RREADY          :  std_logic;
    signal    C_AWADDR          :  std_logic_vector(C_WIDTH.AWADDR -1 downto 0);
    signal    C_AWLEN           :  std_logic_vector(C_WIDTH.ALEN   -1 downto 0);
    signal    C_AWSIZE          :  AXI4_ASIZE_TYPE;
    signal    C_AWBURST         :  AXI4_ABURST_TYPE;
    signal    C_AWLOCK          :  std_logic_vector(C_WIDTH.ALOCK  -1 downto 0);
    signal    C_AWCACHE         :  AXI4_ACACHE_TYPE;
    signal    C_AWPROT          :  AXI4_APROT_TYPE;
    signal    C_AWQOS           :  AXI4_AQOS_TYPE;
    signal    C_AWREGION        :  AXI4_AREGION_TYPE;
    signal    C_AWUSER          :  std_logic_vector(C_WIDTH.AWUSER -1 downto 0);
    signal    C_AWID            :  std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal    C_AWVALID         :  std_logic;
    signal    C_AWREADY         :  std_logic;
    signal    C_WLAST           :  std_logic;
    signal    C_WDATA           :  std_logic_vector(C_WIDTH.WDATA  -1 downto 0);
    signal    C_WSTRB           :  std_logic_vector(C_WIDTH.WDATA/8-1 downto 0);
    signal    C_WUSER           :  std_logic_vector(C_WIDTH.WUSER  -1 downto 0);
    signal    C_WID             :  std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal    C_WVALID          :  std_logic;
    signal    C_WREADY          :  std_logic;
    signal    C_BRESP           :  AXI4_RESP_TYPE;
    signal    C_BUSER           :  std_logic_vector(C_WIDTH.BUSER  -1 downto 0);
    signal    C_BID             :  std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal    C_BVALID          :  std_logic;
    signal    C_BREADY          :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    C_SIZE            :  integer range 0 to SHAPE.C.MAX_SIZE := SHAPE.C.SIZE;
    signal    D_SIZE            :  integer range 0 to SHAPE.D.MAX_SIZE := SHAPE.D.SIZE;
    signal    X_SIZE            :  integer range 0 to SHAPE.X.MAX_SIZE := SHAPE.X.SIZE;
    signal    Y_SIZE            :  integer range 0 to SHAPE.Y.MAX_SIZE := SHAPE.Y.SIZE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  I_WIDTH           :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                      ID         => 4,
                                      USER       => 4,
                                      DEST       => 4,
                                      DATA       => ELEM_BITS
                                   );
    signal    I_DATA            :  std_logic_vector(I_WIDTH.DATA   -1 downto 0);
    signal    I_STRB            :  std_logic_vector(I_WIDTH.DATA/8 -1 downto 0);
    signal    I_KEEP            :  std_logic_vector(I_WIDTH.DATA/8 -1 downto 0);
    signal    I_DEST            :  std_logic_vector(I_WIDTH.DEST   -1 downto 0);
    signal    I_USER            :  std_logic_vector(I_WIDTH.USER   -1 downto 0);
    signal    I_ID              :  std_logic_vector(I_WIDTH.ID     -1 downto 0);
    signal    I_LAST            :  std_logic;
    signal    I_VALID           :  std_logic;
    signal    I_READY           :  std_logic;
    signal    REQ_VALID         :  std_logic;
    signal    REQ_READY         :  std_logic;
    signal    RES_VALID         :  std_logic;
    signal    RES_READY         :  std_logic;
    signal    BUSY              :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    O_DATA            :  std_logic_vector(PARAM.DATA.SIZE-1 downto 0);
    signal    O_VALID           :  std_logic;
    signal    O_READY           :  std_logic;
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal    SYNC              :  SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal    C_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    C_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    I_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    I_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    O_GPI             :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    O_GPO             :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal    N_REPORT          :  REPORT_STATUS_TYPE;
    signal    C_REPORT          :  REPORT_STATUS_TYPE;
    signal    I_REPORT          :  REPORT_STATUS_TYPE;
    signal    O_REPORT          :  REPORT_STATUS_TYPE;
    signal    N_FINISH          :  std_logic;
    signal    C_FINISH          :  std_logic;
    signal    I_FINISH          :  std_logic;
    signal    O_FINISH          :  std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DUT: CONVOLUTION_PARAMETER_BUFFER                --
        generic map (                                --
            PARAM               => PARAM           , --
            SHAPE               => SHAPE           , --
            ELEMENT_SIZE        => ELEMENT_SIZE    , --
            ID                  => 0                 --
        )                                            --
        port map (                                   --
        --------------------------------------------------------------------------
        -- クロック&リセット信号
        --------------------------------------------------------------------------
            CLK                 => CLK             , -- In  :
            RST                 => RESET           , -- In  :
            CLR                 => CLEAR           , -- In  :
        --------------------------------------------------------------------------
        -- 制御 I/F
        --------------------------------------------------------------------------
            REQ_VALID           => REQ_VALID       , -- In  :
            REQ_READY           => REQ_READY       , -- Out :
            C_SIZE              => C_SIZE          , -- In  :
            D_SIZE              => D_SIZE          , -- In  :
            X_SIZE              => X_SIZE          , -- In  :
            Y_SIZE              => Y_SIZE          , -- In  :
            RES_VALID           => RES_VALID       , -- Out :
            RES_READY           => RES_READY       , -- In  :
            BUSY                => BUSY            , -- Out :
        --------------------------------------------------------------------------
        -- 入力 I/F
        --------------------------------------------------------------------------
            I_DATA              => I_DATA          , -- In  :
            I_VALID             => I_VALID         , -- In  :
            I_READY             => I_READY         , -- Out :
        -------------------------------------------------------------------------------
        -- 出力側 I/F
        -------------------------------------------------------------------------------
            O_DATA              => O_DATA          , -- Out :
            O_VALID             => O_VALID         , -- Out :
            O_READY             => O_READY           -- In  :
        );                                           --
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    N: MARCHAL                                       --
        generic map(                                 --
            SCENARIO_FILE       => SCENARIO_FILE   , --
            NAME                => "MARCHAL"       , --
            SYNC_PLUG_NUM       => 1               , --
            SYNC_WIDTH          => SYNC_WIDTH      , --
            FINISH_ABORT        => FALSE             --
        )                                            --
        port map(                                    --
            CLK                 => CLK             , -- In  :
            RESET               => RESET           , -- In  :
            SYNC(0)             => SYNC(0)         , -- I/O :
            SYNC(1)             => SYNC(1)         , -- I/O :
            REPORT_STATUS       => N_REPORT        , -- Out :
            FINISH              => N_FINISH          -- Out :
        );                                           --
    ------------------------------------------------------------------------------
    -- AXI4_MASTER_PLAYER
    ------------------------------------------------------------------------------
    C: AXI4_MASTER_PLAYER                            --
        generic map (                                --
            SCENARIO_FILE       => SCENARIO_FILE   , --
            NAME                => "CSR"           , --
            READ_ENABLE         => TRUE            , --
            WRITE_ENABLE        => TRUE            , --
            OUTPUT_DELAY        => DELAY           , --
            WIDTH               => C_WIDTH         , --
            SYNC_PLUG_NUM       => 2               , --
            SYNC_WIDTH          => SYNC_WIDTH      , --
            GPI_WIDTH           => GPI_WIDTH       , --
            GPO_WIDTH           => GPO_WIDTH       , --
            FINISH_ABORT        => FALSE             --
        )                                            --
        port map(                                    --
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK                => CLK             , -- In  :
            ARESETn             => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR              => C_ARADDR        , -- I/O :
            ARLEN               => C_ARLEN         , -- I/O :
            ARSIZE              => C_ARSIZE        , -- I/O :
            ARBURST             => C_ARBURST       , -- I/O :
            ARLOCK              => C_ARLOCK        , -- I/O :
            ARCACHE             => C_ARCACHE       , -- I/O :
            ARPROT              => C_ARPROT        , -- I/O :
            ARQOS               => C_ARQOS         , -- I/O :
            ARREGION            => C_ARREGION      , -- I/O :
            ARUSER              => C_ARUSER        , -- I/O :
            ARID                => C_ARID          , -- I/O :
            ARVALID             => C_ARVALID       , -- I/O :
            ARREADY             => C_ARREADY       , -- In  :
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST               => C_RLAST         , -- In  :
            RDATA               => C_RDATA         , -- In  :
            RRESP               => C_RRESP         , -- In  :
            RUSER               => C_RUSER         , -- In  :
            RID                 => C_RID           , -- In  :
            RVALID              => C_RVALID        , -- In  :
            RREADY              => C_RREADY        , -- I/O :
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR              => C_AWADDR        , -- I/O :
            AWLEN               => C_AWLEN         , -- I/O :
            AWSIZE              => C_AWSIZE        , -- I/O :
            AWBURST             => C_AWBURST       , -- I/O :
            AWLOCK              => C_AWLOCK        , -- I/O :
            AWCACHE             => C_AWCACHE       , -- I/O :
            AWPROT              => C_AWPROT        , -- I/O :
            AWQOS               => C_AWQOS         , -- I/O :
            AWREGION            => C_AWREGION      , -- I/O :
            AWUSER              => C_AWUSER        , -- I/O :
            AWID                => C_AWID          , -- I/O :
            AWVALID             => C_AWVALID       , -- I/O :
            AWREADY             => C_AWREADY       , -- In  :
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST               => C_WLAST         , -- I/O :
            WDATA               => C_WDATA         , -- I/O :
            WSTRB               => C_WSTRB         , -- I/O :
            WUSER               => C_WUSER         , -- I/O :
            WID                 => C_WID           , -- I/O :
            WVALID              => C_WVALID        , -- I/O :
            WREADY              => C_WREADY        , -- In  :
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP               => C_BRESP         , -- In  :
            BUSER               => C_BUSER         , -- In  :
            BID                 => C_BID           , -- In  :
            BVALID              => C_BVALID        , -- In  :
            BREADY              => C_BREADY        , -- I/O :
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)             => SYNC(0)         , -- I/O :
            SYNC(1)             => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI                 => C_GPI           , -- In  :
            GPO                 => C_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS       => C_REPORT        , -- Out :
            FINISH              => C_FINISH          -- Out :
        );                                           --
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    REGS: block
        ---------------------------------------------------------------------------
        -- レジスタアクセスインターフェースのアドレスのビット数.
        ---------------------------------------------------------------------------
        constant  REGS_ADDR_WIDTH       :  integer := 4;
        ---------------------------------------------------------------------------
        -- 全レジスタのビット数.
        ---------------------------------------------------------------------------
        constant  REGS_DATA_BITS        :  integer := (2**REGS_ADDR_WIDTH)*8;
        ---------------------------------------------------------------------------
        -- レジスタアクセスインターフェースのデータのビット数.
        ---------------------------------------------------------------------------
        constant  REGS_DATA_WIDTH       :  integer := 32;
        constant  REGS_BASE_ADDR        :  integer := 16#00#;
        constant  REGS_BITS             :  integer := 4*32;
        constant  REGS_LO               :  integer := 8*REGS_BASE_ADDR;
        constant  REGS_HI               :  integer := REGS_LO + REGS_BITS - 1;
        constant  sig_1                 :  std_logic := '1';
        ---------------------------------------------------------------------------
        -- レジスタアクセス用の信号群.
        ---------------------------------------------------------------------------
        signal    regs_load             :  std_logic_vector(REGS_DATA_BITS   -1 downto 0);
        signal    regs_wbit             :  std_logic_vector(REGS_DATA_BITS   -1 downto 0);
        signal    regs_rbit             :  std_logic_vector(REGS_DATA_BITS   -1 downto 0);
        signal    regs_req              :  std_logic;
        signal    regs_write            :  std_logic;
        signal    regs_ack              :  std_logic;
        signal    regs_err              :  std_logic;
        signal    regs_addr             :  std_logic_vector(REGS_ADDR_WIDTH  -1 downto 0);
        signal    regs_ben              :  std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
        signal    regs_wdata            :  std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
        signal    regs_rdata            :  std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  IC_REGS_ADDR          :  integer := REGS_BASE_ADDR + 16#00#;
        constant  IC_REGS_BITS          :  integer := 32;
        constant  IC_REGS_LO            :  integer := 8*IC_REGS_ADDR;
        constant  IC_REGS_HI            :  integer := 8*IC_REGS_ADDR + IC_REGS_BITS-1;
        signal    ic_regs               :  std_logic_vector(IC_REGS_BITS-1 downto 0);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  OC_REGS_ADDR          :  integer := REGS_BASE_ADDR + 16#04#;
        constant  OC_REGS_BITS          :  integer := 32;
        constant  OC_REGS_LO            :  integer := 8*OC_REGS_ADDR;
        constant  OC_REGS_HI            :  integer := 8*OC_REGS_ADDR + OC_REGS_BITS-1;
        signal    oc_regs               :  std_logic_vector(OC_REGS_BITS-1 downto 0);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  IW_REGS_ADDR          :  integer := REGS_BASE_ADDR + 16#08#;
        constant  IW_REGS_BITS          :  integer := 32;
        constant  IW_REGS_LO            :  integer := 8*IW_REGS_ADDR;
        constant  IW_REGS_HI            :  integer := 8*IW_REGS_ADDR + IW_REGS_BITS-1;
        signal    iw_regs               :  std_logic_vector(IW_REGS_BITS-1 downto 0);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant  IH_REGS_ADDR          :  integer := REGS_BASE_ADDR + 16#0C#;
        constant  IH_REGS_BITS          :  integer := 32;
        constant  IH_REGS_LO            :  integer := 8*IH_REGS_ADDR;
        constant  IH_REGS_HI            :  integer := 8*IH_REGS_ADDR + IH_REGS_BITS-1;
        signal    ih_regs               :  std_logic_vector(IH_REGS_BITS-1 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        AXI4: AXI4_REGISTER_INTERFACE                --
            generic map (                            --
                AXI4_ADDR_WIDTH => C_WIDTH.ARADDR  , --
                AXI4_DATA_WIDTH => C_WIDTH.RDATA   , --
                AXI4_ID_WIDTH   => C_WIDTH.ID      , --
                REGS_ADDR_WIDTH => REGS_ADDR_WIDTH , --
                REGS_DATA_WIDTH => REGS_DATA_WIDTH   --
            )                                        --
            port map (                               --
            -----------------------------------------------------------------------
            -- Clock and Reset Signals.
            -----------------------------------------------------------------------
                CLK             => CLK             , -- In  :
                RST             => RESET           , -- In  :
                CLR             => CLEAR           , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Read Address Channel Signals.
            -----------------------------------------------------------------------
                ARID            => C_ARID          , -- In  :
                ARADDR          => C_ARADDR        , -- In  :
                ARLEN           => C_ARLEN         , -- In  :
                ARSIZE          => C_ARSIZE        , -- In  :
                ARBURST         => C_ARBURST       , -- In  :
                ARVALID         => C_ARVALID       , -- In  :
                ARREADY         => C_ARREADY       , -- Out :
            -----------------------------------------------------------------------
            -- AXI4 Read Data Channel Signals.
            -----------------------------------------------------------------------
                RID             => C_RID           , -- Out :
                RDATA           => C_RDATA         , -- Out :
                RRESP           => C_RRESP         , -- Out :
                RLAST           => C_RLAST         , -- Out :
                RVALID          => C_RVALID        , -- Out :
                RREADY          => C_RREADY        , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Write Address Channel Signals.
            -----------------------------------------------------------------------
                AWID            => C_AWID          , -- In  :
                AWADDR          => C_AWADDR        , -- In  :
                AWLEN           => C_AWLEN         , -- In  :
                AWSIZE          => C_AWSIZE        , -- In  :
                AWBURST         => C_AWBURST       , -- In  :
                AWVALID         => C_AWVALID       , -- In  :
                AWREADY         => C_AWREADY       , -- Out :
            -----------------------------------------------------------------------
            -- AXI4 Write Data Channel Signals.
            -----------------------------------------------------------------------
                WDATA           => C_WDATA         , -- In  :
                WSTRB           => C_WSTRB         , -- In  :
                WLAST           => C_WLAST         , -- In  :
                WVALID          => C_WVALID        , -- In  :
                WREADY          => C_WREADY        , -- Out :
            -----------------------------------------------------------------------
            -- AXI4 Write Response Channel Signals.
            -----------------------------------------------------------------------
                BID             => C_BID           , -- Out :
                BRESP           => C_BRESP         , -- Out :
                BVALID          => C_BVALID        , -- Out :
                BREADY          => C_BREADY        , -- In  :
            -----------------------------------------------------------------------
            -- Register Interface.
            -----------------------------------------------------------------------
                REGS_REQ        => regs_req        , -- Out :
                REGS_WRITE      => regs_write      , -- Out :
                REGS_ACK        => regs_ack        , -- In  :
                REGS_ERR        => regs_err        , -- In  :
                REGS_ADDR       => regs_addr       , -- Out :
                REGS_BEN        => regs_ben        , -- Out :
                REGS_WDATA      => regs_wdata      , -- Out :
                REGS_RDATA      => regs_rdata        -- In  :
            );                                       --
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        DEC: REGISTER_ACCESS_ADAPTER                 --
            generic map (                            --
                ADDR_WIDTH      => REGS_ADDR_WIDTH , --
                DATA_WIDTH      => REGS_DATA_WIDTH , --
                WBIT_MIN        => regs_wbit'low   , --
                WBIT_MAX        => regs_wbit'high  , --
                RBIT_MIN        => regs_rbit'low   , --
                RBIT_MAX        => regs_rbit'high  , --
                I_CLK_RATE      => 1               , --
                O_CLK_RATE      => 1               , --
                O_CLK_REGS      => 0                 --
            )                                        --
            port map (                               --
                RST             => RESET           , -- In  :
                I_CLK           => CLK             , -- In  :
                I_CLR           => CLEAR           , -- In  :
                I_CKE           => sig_1           , -- In  :
                I_REQ           => regs_req        , -- In  :
                I_SEL           => sig_1           , -- In  :
                I_WRITE         => regs_write      , -- In  :
                I_ADDR          => regs_addr       , -- In  :
                I_BEN           => regs_ben        , -- In  :
                I_WDATA         => regs_wdata      , -- In  :
                I_RDATA         => regs_rdata      , -- Out :
                I_ACK           => regs_ack        , -- Out :
                I_ERR           => regs_err        , -- Out :
                O_CLK           => CLK             , -- In  :
                O_CLR           => CLEAR           , -- In  :
                O_CKE           => sig_1           , -- In  :
                O_WDATA         => regs_wbit       , -- Out :
                O_WLOAD         => regs_load       , -- Out :
                O_RDATA         => regs_rbit         -- In  :
            );                                       --
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (CLK, RESET) begin
            if (RESET = '1') then
                ic_regs <= (others => '0');
                oc_regs <= (others => '0');
                iw_regs <= (others => '0');
                ih_regs <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                for i in ic_regs'range loop
                    if (regs_load(i+IC_REGS_LO) = '1') then
                        ic_regs(i) <= regs_wbit(i+IC_REGS_LO);
                    end if;
                end loop;
                for i in oc_regs'range loop
                    if (regs_load(i+OC_REGS_LO) = '1') then
                        oc_regs(i) <= regs_wbit(i+OC_REGS_LO);
                    end if;
                end loop;
                for i in iw_regs'range loop
                    if (regs_load(i+IW_REGS_LO) = '1') then
                        iw_regs(i) <= regs_wbit(i+IW_REGS_LO);
                    end if;
                end loop;
                for i in ih_regs'range loop
                    if (regs_load(i+IH_REGS_LO) = '1') then
                        ih_regs(i) <= regs_wbit(i+IH_REGS_LO);
                    end if;
                end loop;
            end if;
        end process;
        regs_rbit(IC_REGS_HI downto IC_REGS_LO) <= ic_regs;
        regs_rbit(OC_REGS_HI downto OC_REGS_LO) <= oc_regs;
        regs_rbit(IW_REGS_HI downto IW_REGS_LO) <= iw_regs;
        regs_rbit(IH_REGS_HI downto IH_REGS_LO) <= ih_regs;
        SHAPE_IS_EXTERNAL: if (SHAPE_CONSTANT = FALSE) generate
            C_SIZE <= to_integer(to_01(unsigned(ic_regs(SIZE_BITS-1 downto 0))));
            D_SIZE <= to_integer(to_01(unsigned(oc_regs(SIZE_BITS-1 downto 0))));
            X_SIZE <= to_integer(to_01(unsigned(iw_regs(SIZE_BITS-1 downto 0))));
            Y_SIZE <= to_integer(to_01(unsigned(ih_regs(SIZE_BITS-1 downto 0))));
        end generate;
    end block;                                       --
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I: AXI4_STREAM_MASTER_PLAYER                     --
        generic map (                                --
            SCENARIO_FILE       => SCENARIO_FILE   , --
            NAME                => "I"             , --
            OUTPUT_DELAY        => DELAY           , --
            SYNC_PLUG_NUM       => 3               , --
            WIDTH               => I_WIDTH         , --
            SYNC_WIDTH          => SYNC_WIDTH      , --
            GPI_WIDTH           => GPI_WIDTH       , --
            GPO_WIDTH           => GPO_WIDTH       , --
            FINISH_ABORT        => FALSE             --
        )                                            --
        port map(                                    --
            ACLK                => CLK             , -- In  :
            ARESETn             => ARESETn         , -- In  :
            TDATA               => I_DATA          , -- I/O :
            TSTRB               => I_STRB          , -- I/O :
            TKEEP               => I_KEEP          , -- I/O :
            TUSER               => I_USER          , -- I/O :
            TDEST               => I_DEST          , -- I/O :
            TID                 => I_ID            , -- I/O :
            TLAST               => I_LAST          , -- I/O :
            TVALID              => I_VALID         , -- I/O :
            TREADY              => I_READY         , -- In  :
            SYNC                => SYNC            , -- I/O :
            GPI                 => I_GPI           , -- In  :
            GPO                 => I_GPO           , -- Out :
            REPORT_STATUS       => I_REPORT        , -- Out :
            FINISH              => I_FINISH          -- Out :
        );                                           --
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O: entity WORK.IMAGE_STREAM_SLAVE_PLAYER         --
        generic map (                                --
            SCENARIO_FILE       => SCENARIO_FILE   , --
            NAME                => "O"             , --
            PARAM               => PARAM           , --
            OUTPUT_DELAY        => DELAY           , --
            SYNC_PLUG_NUM       => 4               , --
            SYNC_WIDTH          => SYNC_WIDTH      , --
            GPI_WIDTH           => GPI_WIDTH       , --
            GPO_WIDTH           => GPO_WIDTH       , --
            FINISH_ABORT        => FALSE             --
        )                                            --
        port map (                                   --
            CLK                 => CLK             , -- In  :
            RST                 => RESET           , -- In  :
            DATA                => O_DATA          , -- In  :
            VALID               => O_VALID         , -- In  :
            READY               => O_READY         , -- I/O :
            SYNC(0)             => SYNC(0)         , -- I/O :
            SYNC(1)             => SYNC(1)         , -- I/O :
            GPI                 => O_GPI           , -- In  :
            GPO                 => O_GPO           , -- Out :
            REPORT_STATUS       => O_REPORT        , -- Out :
            FINISH              => O_FINISH          -- Out :
        );                                           --
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process begin
        loop
            CLK <= '0'; wait for PERIOD / 2;
            CLK <= '1'; wait for PERIOD / 2;
            exit when(N_FINISH = '1');
        end loop;
        CLK <= '0';
        wait;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    REQ_VALID <= C_GPO(0);
    RES_READY <= C_GPO(1);
    C_GPI(0)  <= REQ_READY;
    C_GPI(1)  <= RES_VALID;
    C_GPI(2)  <= BUSY;
    C_GPI(C_GPI'high downto 3) <= (C_GPI'high downto 3 => '0');
    I_GPI     <= (others => '0');
    O_GPI     <= (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    ARESETn  <= '1' when (RESET = '0') else '0';

    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        wait until (C_FINISH'event and C_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ CSR ]");                                       WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,C_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,C_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,C_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ IN ]");                                        WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,I_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,I_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,I_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ OUT ]");                                       WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,O_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,O_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,O_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert (C_REPORT.error_count    = 0 and
                I_REPORT.error_count    = 0 and
                O_REPORT.error_count    = 0)
            report "Simulation complete(error)."    severity FAILURE;
        assert (C_REPORT.mismatch_count = 0 and
                I_REPORT.mismatch_count = 0 and
                O_REPORT.mismatch_count = 0)
            report "Simulation complete(mismatch)." severity FAILURE;
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete(success)."  severity FAILURE;
        else
            assert FALSE report "Simulation complete(success)."  severity NOTE;
        end if;
        wait;
    end process;
end MODEL;
-----------------------------------------------------------------------------------
-- 1x1x1x1
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x1x1 is
    generic (
        NAME            : STRING  := "test_1x1x1x1";
        SCENARIO_FILE   : STRING  := "src/test/scenarios/convolution_parameter_buffer/test_1x1x1x1.snr";
        KY_SIZE         : integer := 1;
        KX_SIZE         : integer := 1;
        D_UNROLL        : integer := 1;
        C_UNROLL        : integer := 1;
        SHAPE_CONSTANT  : boolean := FALSE;
        SHAPE_H         : integer := 1;
        SHAPE_W         : integer := 1;
        SHAPE_D         : integer := 1;
        SHAPE_C         : integer := 1;
        FINISH_ABORT    : boolean := FALSE
    );
end CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x1x1;
architecture MODEL of CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x1x1 is
begin
    TB: entity WORK.CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH generic map(
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        KY_SIZE         => KY_SIZE         ,
        KX_SIZE         => KX_SIZE         ,
        D_UNROLL        => D_UNROLL        ,
        C_UNROLL        => C_UNROLL        ,
        SHAPE_CONSTANT  => SHAPE_CONSTANT  ,
        SHAPE_H         => SHAPE_H         ,
        SHAPE_W         => SHAPE_W         ,
        SHAPE_D         => SHAPE_D         ,
        SHAPE_C         => SHAPE_C         ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- 1x1x1x1-1x1x1x1
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x1x1_1x1x1x1 is
    generic (
        NAME            : STRING  := "test_1x1x1x1_1x1x1x1";
        SCENARIO_FILE   : STRING  := "src/test/scenarios/convolution_parameter_buffer/test_1x1x1x1_1x1x1x1.snr";
        KY_SIZE         : integer := 1;
        KX_SIZE         : integer := 1;
        D_UNROLL        : integer := 1;
        C_UNROLL        : integer := 1;
        SHAPE_CONSTANT  : boolean := TRUE;
        SHAPE_H         : integer := 1;
        SHAPE_W         : integer := 1;
        SHAPE_D         : integer := 1;
        SHAPE_C         : integer := 1;
        FINISH_ABORT    : boolean := FALSE
    );
end CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x1x1_1x1x1x1;
architecture MODEL of CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x1x1_1x1x1x1 is
begin
    TB: entity WORK.CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH generic map(
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        KY_SIZE         => KY_SIZE         ,
        KX_SIZE         => KX_SIZE         ,
        D_UNROLL        => D_UNROLL        ,
        C_UNROLL        => C_UNROLL        ,
        SHAPE_CONSTANT  => SHAPE_CONSTANT  ,
        SHAPE_H         => SHAPE_H         ,
        SHAPE_W         => SHAPE_W         ,
        SHAPE_D         => SHAPE_D         ,
        SHAPE_C         => SHAPE_C         ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- 1x1x1x4
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x1x4 is
    generic (
        NAME            : STRING  := "test_1x1x1x4";
        SCENARIO_FILE   : STRING  := "src/test/scenarios/convolution_parameter_buffer/test_1x1x1x4.snr";
        KY_SIZE         : integer := 1;
        KX_SIZE         : integer := 1;
        D_UNROLL        : integer := 1;
        C_UNROLL        : integer := 4;
        SHAPE_CONSTANT  : boolean := FALSE;
        SHAPE_H         : integer := 1;
        SHAPE_W         : integer := 1;
        SHAPE_D         : integer := 1;
        SHAPE_C         : integer := 1;
        FINISH_ABORT    : boolean := FALSE
    );
end CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x1x4;
architecture MODEL of CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x1x4 is
begin
    TB: entity WORK.CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH generic map(
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        KY_SIZE         => KY_SIZE         ,
        KX_SIZE         => KX_SIZE         ,
        D_UNROLL        => D_UNROLL        ,
        C_UNROLL        => C_UNROLL        ,
        SHAPE_CONSTANT  => SHAPE_CONSTANT  ,
        SHAPE_H         => SHAPE_H         ,
        SHAPE_W         => SHAPE_W         ,
        SHAPE_D         => SHAPE_D         ,
        SHAPE_C         => SHAPE_C         ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- 1x1x2x4
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x2x4 is
    generic (
        NAME            : STRING  := "test_1x1x2x4";
        SCENARIO_FILE   : STRING  := "src/test/scenarios/convolution_parameter_buffer/test_1x1x2x4.snr";
        KY_SIZE         : integer := 1;
        KX_SIZE         : integer := 1;
        D_UNROLL        : integer := 2;
        C_UNROLL        : integer := 4;
        SHAPE_CONSTANT  : boolean := FALSE;
        SHAPE_H         : integer := 1;
        SHAPE_W         : integer := 1;
        SHAPE_D         : integer := 1;
        SHAPE_C         : integer := 1;
        FINISH_ABORT    : boolean := FALSE
    );
end CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x2x4;
architecture MODEL of CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_1x1x2x4 is
begin
    TB: entity WORK.CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH generic map(
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        KY_SIZE         => KY_SIZE         ,
        KX_SIZE         => KX_SIZE         ,
        D_UNROLL        => D_UNROLL        ,
        C_UNROLL        => C_UNROLL        ,
        SHAPE_CONSTANT  => SHAPE_CONSTANT  ,
        SHAPE_H         => SHAPE_H         ,
        SHAPE_W         => SHAPE_W         ,
        SHAPE_D         => SHAPE_D         ,
        SHAPE_C         => SHAPE_C         ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- 3x3x1x1
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_3x3x1x1 is
    generic (
        NAME            : STRING  := "test_3x3x1x1";
        SCENARIO_FILE   : STRING  := "src/test/scenarios/convolution_parameter_buffer/test_3x3x1x1.snr";
        KY_SIZE         : integer := 3;
        KX_SIZE         : integer := 3;
        D_UNROLL        : integer := 1;
        C_UNROLL        : integer := 1;
        SHAPE_CONSTANT  : boolean := FALSE;
        SHAPE_H         : integer := 1;
        SHAPE_W         : integer := 1;
        SHAPE_D         : integer := 1;
        SHAPE_C         : integer := 1;
        FINISH_ABORT    : boolean := FALSE
    );
end CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_3x3x1x1;
architecture MODEL of CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_3x3x1x1 is
begin
    TB: entity WORK.CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH generic map(
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        KY_SIZE         => KY_SIZE         ,
        KX_SIZE         => KX_SIZE         ,
        D_UNROLL        => D_UNROLL        ,
        C_UNROLL        => C_UNROLL        ,
        SHAPE_CONSTANT  => SHAPE_CONSTANT  ,
        SHAPE_H         => SHAPE_H         ,
        SHAPE_W         => SHAPE_W         ,
        SHAPE_D         => SHAPE_D         ,
        SHAPE_C         => SHAPE_C         ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
-----------------------------------------------------------------------------------
-- 3x3x2x4
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_3x3x2x4 is
    generic (
        NAME            : STRING  := "test_3x3x2x4";
        SCENARIO_FILE   : STRING  := "src/test/scenarios/convolution_parameter_buffer/test_3x3x2x4.snr";
        KY_SIZE         : integer := 3;
        KX_SIZE         : integer := 3;
        D_UNROLL        : integer := 2;
        C_UNROLL        : integer := 4;
        SHAPE_CONSTANT  : boolean := FALSE;
        SHAPE_H         : integer := 1;
        SHAPE_W         : integer := 1;
        SHAPE_D         : integer := 1;
        SHAPE_C         : integer := 1;
        FINISH_ABORT    : boolean := FALSE
    );
end CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_3x3x2x4;
architecture MODEL of CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH_3x3x2x4 is
begin
    TB: entity WORK.CONVOLUTION_PARAMETER_BUFFER_TEST_BENCH generic map(
        NAME            => NAME            ,
        SCENARIO_FILE   => SCENARIO_FILE   ,
        KY_SIZE         => KY_SIZE         ,
        KX_SIZE         => KX_SIZE         ,
        D_UNROLL        => D_UNROLL        ,
        C_UNROLL        => C_UNROLL        ,
        SHAPE_CONSTANT  => SHAPE_CONSTANT  ,
        SHAPE_H         => SHAPE_H         ,
        SHAPE_W         => SHAPE_W         ,
        SHAPE_D         => SHAPE_D         ,
        SHAPE_C         => SHAPE_C         ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
