-----------------------------------------------------------------------------------
--!     @file    aix4_lite_test_bench.vhd
--!     @brief   AXI4 LITE TEST BENCH
--!     @version 1.8.6
--!     @date    2021/5/25
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2021 Ichiro Kawazome
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
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SLAVE_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SIGNAL_PRINTER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.SDPRAM;
use     PIPEWORK.COMPONENTS.REGISTER_ACCESS_SYNCRONIZER;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_REGISTER_INTERFACE;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
entity  AXI4_LITE_TEST_BENCH is
    generic (
        NAME            : STRING;
        SCENARIO_FILE   : STRING;
        AXI4_DATA_WIDTH : integer := 32;
        REGS_DATA_WIDTH : integer := 32;
        PRINT_AXI4_READ : boolean := TRUE;
        PRINT_AXI4_WRITE: boolean := TRUE;
        FINISH_ABORT    : boolean := FALSE
    );
end     AXI4_LITE_TEST_BENCH;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_LITE_TEST_BENCH is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant PERIOD          : time    := 10 ns;
    constant DELAY           : time    :=  1 ns;
    constant AXI4_ADDR_WIDTH : integer := 32;
    constant REGS_ADDR_WIDTH : integer := 12;
    constant WIDTH           : AXI4_SIGNAL_WIDTH_TYPE := (
                                 ID          => 4,
                                 AWADDR      => AXI4_ADDR_WIDTH,
                                 ARADDR      => AXI4_ADDR_WIDTH,
                                 WDATA       => AXI4_DATA_WIDTH,
                                 RDATA       => AXI4_DATA_WIDTH,
                                 ALEN        => AXI4_ALEN_WIDTH,
                                 ALOCK       => AXI4_ALOCK_WIDTH,
                                 ARUSER      => 1,
                                 AWUSER      => 1,
                                 WUSER       => 1,
                                 RUSER       => 1,
                                 BUSER       => 1);
    constant SYNC_WIDTH      : integer :=  2;
    constant GPO_WIDTH       : integer :=  8;
    constant GPI_WIDTH       : integer :=  GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal   ACLK            : std_logic;
    signal   ARESETn         : std_logic;
    signal   RESET           : std_logic;
    constant CLEAR           : std_logic := '0';
    constant ACKE            : std_logic := '1';
    ------------------------------------------------------------------------------
    -- リードアドレスチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   ARADDR          : std_logic_vector(WIDTH.ARADDR -1 downto 0);
    signal   ARWRITE         : std_logic;
    signal   ARLEN           : std_logic_vector(WIDTH.ALEN   -1 downto 0);
    signal   ARSIZE          : AXI4_ASIZE_TYPE;
    signal   ARBURST         : AXI4_ABURST_TYPE;
    signal   ARLOCK          : std_logic_vector(WIDTH.ALOCK  -1 downto 0);
    signal   ARCACHE         : AXI4_ACACHE_TYPE;
    signal   ARPROT          : AXI4_APROT_TYPE;
    signal   ARQOS           : AXI4_AQOS_TYPE;
    signal   ARREGION        : AXI4_AREGION_TYPE;
    signal   ARUSER          : std_logic_vector(WIDTH.ARUSER -1 downto 0);
    signal   ARID            : std_logic_vector(WIDTH.ID     -1 downto 0);
    signal   ARVALID         : std_logic;
    signal   ARREADY         : std_logic;
    -------------------------------------------------------------------------------
    -- リードデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   RVALID          : std_logic;
    signal   RLAST           : std_logic;
    signal   RDATA           : std_logic_vector(WIDTH.RDATA  -1 downto 0);
    signal   RRESP           : AXI4_RESP_TYPE;
    signal   RUSER           : std_logic_vector(WIDTH.RUSER  -1 downto 0);
    signal   RID             : std_logic_vector(WIDTH.ID     -1 downto 0);
    signal   RREADY          : std_logic;
    -------------------------------------------------------------------------------
    -- ライトアドレスチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   AWADDR          : std_logic_vector(WIDTH.AWADDR -1 downto 0);
    signal   AWLEN           : std_logic_vector(WIDTH.ALEN   -1 downto 0);
    signal   AWSIZE          : AXI4_ASIZE_TYPE;
    signal   AWBURST         : AXI4_ABURST_TYPE;
    signal   AWLOCK          : std_logic_vector(WIDTH.ALOCK  -1 downto 0);
    signal   AWCACHE         : AXI4_ACACHE_TYPE;
    signal   AWPROT          : AXI4_APROT_TYPE;
    signal   AWQOS           : AXI4_AQOS_TYPE;
    signal   AWREGION        : AXI4_AREGION_TYPE;
    signal   AWUSER          : std_logic_vector(WIDTH.AWUSER -1 downto 0);
    signal   AWID            : std_logic_vector(WIDTH.ID     -1 downto 0);
    signal   AWVALID         : std_logic;
    signal   AWREADY         : std_logic;
    -------------------------------------------------------------------------------
    -- ライトデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   WLAST           : std_logic;
    signal   WDATA           : std_logic_vector(WIDTH.WDATA  -1 downto 0);
    signal   WSTRB           : std_logic_vector(WIDTH.WDATA/8-1 downto 0);
    signal   WUSER           : std_logic_vector(WIDTH.WUSER  -1 downto 0);
    signal   WID             : std_logic_vector(WIDTH.ID     -1 downto 0);
    signal   WVALID          : std_logic;
    signal   WREADY          : std_logic;
    -------------------------------------------------------------------------------
    -- ライト応答チャネルシグナル.
    -------------------------------------------------------------------------------
    signal   BRESP           : AXI4_RESP_TYPE;
    signal   BUSER           : std_logic_vector(WIDTH.BUSER  -1 downto 0);
    signal   BID             : std_logic_vector(WIDTH.ID     -1 downto 0);
    signal   BVALID          : std_logic;
    signal   BREADY          : std_logic;
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal   SYNC            : SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal   M_GPI           : std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal   M_GPO           : std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal   N_REPORT        : REPORT_STATUS_TYPE;
    signal   M_REPORT        : REPORT_STATUS_TYPE;
    signal   N_FINISH        : std_logic;
    signal   M_FINISH        : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant I_SEL           : std_logic := '1';
    signal   I_REQ           : std_logic;
    signal   I_WRITE         : std_logic;
    signal   I_ACK           : std_logic;
    signal   I_ERR           : std_logic;
    signal   I_ADDR          : std_logic_vector(REGS_ADDR_WIDTH  -1 downto 0);
    signal   I_BEN           : std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
    signal   I_WDATA         : std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
    signal   I_RDATA         : std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   REGS_CLK        : std_logic;
    constant REGS_CKE        : std_logic := '1';
    signal   REGS_REQ        : std_logic;
    signal   REGS_WRITE      : std_logic;
    signal   REGS_ACK        : std_logic;
    signal   REGS_ERR        : std_logic;
    signal   REGS_ADDR       : std_logic_vector(REGS_ADDR_WIDTH  -1 downto 0);
    signal   REGS_BEN        : std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
    signal   REGS_WDATA      : std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
    signal   REGS_RDATA      : std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
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
    constant REGS_DATA_SIZE  : integer := CALC_DATA_SIZE(REGS_DATA_WIDTH);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant RAM_DEPTH       : integer := REGS_ADDR_WIDTH+3;
    signal   RAM_ADDR        : std_logic_vector(REGS_ADDR_WIDTH  -1 downto REGS_DATA_SIZE-3);
    signal   RAM_RDATA       : std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
    signal   RAM_WE          : std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
    signal   regs_state      : std_logic_vector(1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "MARCHAL",
            SYNC_PLUG_NUM   => 1,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
            CLK             => ACLK            , -- In  :
            RESET           => RESET           , -- In  :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_MASTER_PLAYER
    ------------------------------------------------------------------------------
    M: AXI4_MASTER_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "MASTER"        ,
            READ_ENABLE     => TRUE            ,
            WRITE_ENABLE    => TRUE            ,
            OUTPUT_DELAY    => DELAY           ,
            WIDTH           => WIDTH           ,
            SYNC_PLUG_NUM   => 2               ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => ARADDR          , -- I/O : 
            ARLEN           => ARLEN           , -- I/O : 
            ARSIZE          => ARSIZE          , -- I/O : 
            ARBURST         => ARBURST         , -- I/O : 
            ARLOCK          => ARLOCK          , -- I/O : 
            ARCACHE         => ARCACHE         , -- I/O : 
            ARPROT          => ARPROT          , -- I/O : 
            ARQOS           => ARQOS           , -- I/O : 
            ARREGION        => ARREGION        , -- I/O : 
            ARUSER          => ARUSER          , -- I/O : 
            ARID            => ARID            , -- I/O : 
            ARVALID         => ARVALID         , -- I/O : 
            ARREADY         => ARREADY         , -- In  :    
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => RLAST           , -- In  :    
            RDATA           => RDATA           , -- In  :    
            RRESP           => RRESP           , -- In  :    
            RUSER           => RUSER           , -- In  :    
            RID             => RID             , -- In  :    
            RVALID          => RVALID          , -- In  :    
            RREADY          => RREADY          , -- I/O : 
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => AWADDR          , -- I/O : 
            AWLEN           => AWLEN           , -- I/O : 
            AWSIZE          => AWSIZE          , -- I/O : 
            AWBURST         => AWBURST         , -- I/O : 
            AWLOCK          => AWLOCK          , -- I/O : 
            AWCACHE         => AWCACHE         , -- I/O : 
            AWPROT          => AWPROT          , -- I/O : 
            AWQOS           => AWQOS           , -- I/O : 
            AWREGION        => AWREGION        , -- I/O : 
            AWUSER          => AWUSER          , -- I/O : 
            AWID            => AWID            , -- I/O : 
            AWVALID         => AWVALID         , -- I/O : 
            AWREADY         => AWREADY         , -- In  :    
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => WLAST           , -- I/O : 
            WDATA           => WDATA           , -- I/O : 
            WSTRB           => WSTRB           , -- I/O : 
            WUSER           => WUSER           , -- I/O : 
            WID             => WID             , -- I/O : 
            WVALID          => WVALID          , -- I/O : 
            WREADY          => WREADY          , -- In  :    
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => BRESP           , -- In  :    
            BUSER           => BUSER           , -- In  :    
            BID             => BID             , -- In  :    
            BVALID          => BVALID          , -- In  :    
            BREADY          => BREADY          , -- I/O : 
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => M_GPI           , -- In  :
            GPO             => M_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => M_REPORT        , -- Out :
            FINISH          => M_FINISH          -- Out :
        );
    -------------------------------------------------------------------------------
    -- AXI4_SIGNAL_PRINTER
    -------------------------------------------------------------------------------
    PRINT: AXI4_SIGNAL_PRINTER                   -- 
        generic map (                            -- 
            NAME            => NAME            , -- 
            TAG             => NAME            , -- 
            TAG_WIDTH       => 0               , -- 
            TIME_WIDTH      => 13              , -- 
            WIDTH           => WIDTH           , -- 
            READ_ENABLE     => PRINT_AXI4_READ , -- 
            WRITE_ENABLE    => PRINT_AXI4_WRITE  -- 
        )                                        -- 
        port map (                               -- 
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => ARADDR          , -- In  :
            ARLEN           => ARLEN           , -- In  :
            ARSIZE          => ARSIZE          , -- In  :
            ARBURST         => ARBURST         , -- In  :
            ARLOCK          => ARLOCK          , -- In  :
            ARCACHE         => ARCACHE         , -- In  :
            ARPROT          => ARPROT          , -- In  :
            ARQOS           => ARQOS           , -- In  :
            ARREGION        => ARREGION        , -- In  :
            ARUSER          => ARUSER          , -- In  :
            ARID            => ARID            , -- In  :
            ARVALID         => ARVALID         , -- In  :
            ARREADY         => ARREADY         , -- In  :
        ---------------------------------------------------------------------------
        -- リードチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => RLAST           , -- In  :
            RDATA           => RDATA           , -- In  :
            RRESP           => RRESP           , -- In  :
            RUSER           => RUSER           , -- In  :
            RID             => RID             , -- In  :
            RVALID          => RVALID          , -- In  :
            RREADY          => RREADY          , -- In  :
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            AWADDR          => AWADDR          , -- In  :
            AWLEN           => AWLEN           , -- In  :
            AWSIZE          => AWSIZE          , -- In  :
            AWBURST         => AWBURST         , -- In  :
            AWLOCK          => AWLOCK          , -- In  :
            AWCACHE         => AWCACHE         , -- In  :
            AWPROT          => AWPROT          , -- In  :
            AWQOS           => AWQOS           , -- In  :
            AWREGION        => AWREGION        , -- In  :
            AWUSER          => AWUSER          , -- In  :
            AWID            => AWID            , -- In  :
            AWVALID         => AWVALID         , -- In  :
            AWREADY         => AWREADY         , -- In  :
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
            WLAST           => WLAST           , -- In  :
            WDATA           => WDATA           , -- In  :
            WSTRB           => WSTRB           , -- In  :
            WUSER           => WUSER           , -- In  :
            WID             => WID             , -- In  :
            WVALID          => WVALID          , -- In  :
            WREADY          => WREADY          , -- In  :
        ---------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        ---------------------------------------------------------------------------
            BRESP           => BRESP           , -- In  :
            BUSER           => BUSER           , -- In  :
            BID             => BID             , -- In  :
            BVALID          => BVALID          , -- In  :
            BREADY          => BREADY            -- In  :
    );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    DUT: AXI4_REGISTER_INTERFACE
        generic map (
            AXI4_LITE       => 1               ,
            AXI4_ADDR_WIDTH => AXI4_ADDR_WIDTH , 
            AXI4_DATA_WIDTH => AXI4_DATA_WIDTH , 
            AXI4_ID_WIDTH   => WIDTH.ID        ,
            REGS_ADDR_WIDTH => REGS_ADDR_WIDTH ,
            REGS_DATA_WIDTH => REGS_DATA_WIDTH 
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => ACLK            ,
            RST             => RESET           ,
            CLR             => CLEAR           ,
        ---------------------------------------------------------------------------
        -- AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            ARID            => ARID            ,
            ARADDR          => ARADDR          ,
            ARVALID         => ARVALID         ,
            ARREADY         => ARREADY         ,
        ---------------------------------------------------------------------------
        -- AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            RID             => RID             ,
            RDATA           => RDATA           ,
            RRESP           => RRESP           ,
            RLAST           => RLAST           ,
            RVALID          => RVALID          ,
            RREADY          => RREADY          ,
        ---------------------------------------------------------------------------
        -- AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            AWID            => AWID            ,
            AWADDR          => AWADDR          ,
            AWVALID         => AWVALID         ,
            AWREADY         => AWREADY         ,
        ---------------------------------------------------------------------------
        -- AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            WDATA           => WDATA           ,
            WSTRB           => WSTRB           ,
            WVALID          => WVALID          ,
            WREADY          => WREADY          ,
        ---------------------------------------------------------------------------
        -- AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            BID             => BID             ,
            BRESP           => BRESP           ,
            BVALID          => BVALID          ,
            BREADY          => BREADY          ,
        ---------------------------------------------------------------------------
        -- Register Write Interface.
        ---------------------------------------------------------------------------
            REGS_REQ        => I_REQ           ,
            REGS_WRITE      => I_WRITE         ,
            REGS_ACK        => I_ACK           ,
            REGS_ERR        => I_ERR           ,
            REGS_ADDR       => I_ADDR          ,
            REGS_BEN        => I_BEN           ,
            REGS_WDATA      => I_WDATA         ,
            REGS_RDATA      => I_RDATA      
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    REGS_SYNC: REGISTER_ACCESS_SYNCRONIZER
        generic map (
            ADDR_WIDTH      => REGS_ADDR_WIDTH ,
            DATA_WIDTH      => REGS_DATA_WIDTH ,
            I_CLK_RATE      => 0               ,
            O_CLK_RATE      => 0               ,
            O_CLK_REGS      => 0
        )
        port map (
        ---------------------------------------------------------------------------
        -- リセット信号
        ---------------------------------------------------------------------------
            RST             => RESET           , 
        ---------------------------------------------------------------------------
        -- 入力側のクロック信号/同期リセット信号
        ---------------------------------------------------------------------------
            I_CLK           => ACLK            ,
            I_CLR           => CLEAR           ,
            I_CKE           => ACKE            ,
        ---------------------------------------------------------------------------
        -- 入力側のレジスタアクセスインターフェース
        ---------------------------------------------------------------------------
            I_REQ           => I_REQ           ,
            I_SEL           => I_SEL           ,
            I_WRITE         => I_WRITE         ,
            I_ADDR          => I_ADDR          ,
            I_BEN           => I_BEN           ,
            I_WDATA         => I_WDATA         ,
            I_RDATA         => I_RDATA         ,
            I_ACK           => I_ACK           ,
            I_ERR           => I_ERR           ,
        ---------------------------------------------------------------------------
        -- 出力側のクロック信号/同期リセット信号
        ---------------------------------------------------------------------------
            O_CLK           => REGS_CLK        ,
            O_CLR           => CLEAR           ,
            O_CKE           => REGS_CKE        ,
        ---------------------------------------------------------------------------
        -- 出力側のレジスタアクセスインターフェース
        ---------------------------------------------------------------------------
            O_REQ           => REGS_REQ        ,
            O_WRITE         => REGS_WRITE      ,
            O_ADDR          => REGS_ADDR       ,
            O_BEN           => REGS_BEN        ,
            O_WDATA         => REGS_WDATA      ,
            O_RDATA         => REGS_RDATA      ,
            O_ACK           => REGS_ACK        ,
            O_ERR           => REGS_ERR
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process (REGS_CLK, RESET) begin
        if (RESET = '1') then
            regs_state <= "00";
        elsif (REGS_CLK'event and REGS_CLK = '1') then
            case regs_state is
                when "00" =>
                    if (REGS_REQ = '1' and REGS_WRITE = '0') then
                        regs_state <= "01";
                    else
                        regs_state <= "00";
                    end if;
                when "01" =>
                    if (REGS_ACK = '1') then
                        regs_state <= "00";
                    else
                        regs_state <= "01";
                    end if;
                when others => 
                        regs_state <= "00";
            end case;
        end if;
    end process;
    REGS_ACK   <= '1' when (REGS_REQ = '1' and REGS_WRITE = '1') or
                         (regs_state = "01") else '0';
    REGS_ERR   <= '0';
    REGS_RDATA <= RAM_RDATA;
    RAM_ADDR   <= REGS_ADDR(RAM_ADDR'range);
    RAM_WE_GEN: for i in RAM_WE'range generate
        RAM_WE(i) <= '1' when (REGS_REQ = '1' and REGS_WRITE = '1' and REGS_ACK = '1' and REGS_BEN(i) = '1') else '0';
    end generate;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    RAM: SDPRAM 
        generic map (
            DEPTH           => RAM_DEPTH       ,
            RWIDTH          => REGS_DATA_SIZE  ,
            WWIDTH          => REGS_DATA_SIZE  ,
            WEBIT           => REGS_DATA_SIZE-3,
            ID              => 0
        ) 
        port map (
            WCLK            => REGS_CLK        ,
            WE              => RAM_WE          ,
            WADDR           => RAM_ADDR        ,
            WDATA           => REGS_WDATA      ,
            RCLK            => REGS_CLK        ,
            RADDR           => RAM_ADDR        ,
            RDATA           => RAM_RDATA
        );
    
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process begin
        loop
            ACLK     <= '0';
            REGS_CLK <= '0';
            wait for PERIOD / 2;
            ACLK     <= '1';
            REGS_CLK <= '1';
            wait for PERIOD / 2;
            exit when(M_FINISH = '1');
        end loop;
        ACLK     <= '0';
        REGS_CLK <= '0';
        wait;
    end process;

    ARESETn <= '1' when (RESET = '0') else '0';
    M_GPI   <= M_GPO;
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        wait until (M_FINISH'event and M_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ MASTER ]");                                    WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,M_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,M_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,M_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert(M_REPORT.error_count    = 0) report "Simulation complete(error)."    severity FAILURE;
        assert(M_REPORT.mismatch_count = 0) report "Simulation complete(mismatch)." severity FAILURE;
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete(success)."  severity FAILURE;
        else
            assert FALSE report "Simulation complete(success)."  severity NOTE;
        end if;
        wait;
    end process;
    
 -- SYNC_PRINT_0: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(0)")) port map (SYNC(0));
 -- SYNC_PRINT_1: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(1)")) port map (SYNC(1));
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
