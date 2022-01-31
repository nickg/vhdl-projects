-----------------------------------------------------------------------------------
--!     @file    pump_axi4_to_axi4.vhd
--!     @brief   Pump Sample Module (AXI4 to AXI4)
--!     @version 1.8.5
--!     @date    2021/5/18
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2021 Ichiro Kawazome
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
entity  PUMP_AXI4_TO_AXI4 is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        C_ADDR_WIDTH    : integer range 1 to   64 := 32;
        C_DATA_WIDTH    : integer range 8 to 1024 := 32;
        C_ID_WIDTH      : integer                 :=  8;
        M_ADDR_WIDTH    : integer range 1 to   64 := 32;
        M_DATA_WIDTH    : integer range 8 to 1024 := 32;
        M_ID_WIDTH      : integer                 :=  8;
        M_AUSER_WIDTH   : integer                 :=  4;
        M_AXI_ID        : integer                 :=  1;
        I_AXI_ID        : integer                 :=  1;
        I_ADDR_WIDTH    : integer range 1 to   64 := 32;
        I_DATA_WIDTH    : integer range 8 to 1024 := 32;
        I_ID_WIDTH      : integer                 :=  8;
        I_AUSER_WIDTH   : integer                 :=  4;
        I_MAX_XFER_SIZE : integer                 :=  8;
        I_QUEUE_SIZE    : integer                 :=  1;
        I_PROC_VALID    : integer range 0 to    1 :=  1;
        O_AXI_ID        : integer                 :=  2;
        O_ADDR_WIDTH    : integer range 1 to   64 := 32;
        O_DATA_WIDTH    : integer range 8 to 1024 := 32;
        O_ID_WIDTH      : integer                 :=  8;
        O_AUSER_WIDTH   : integer                 :=  4;
        O_MAX_XFER_SIZE : integer                 :=  8;
        O_PROC_VALID    : integer range 0 to    1 :=  1;
        O_QUEUE_SIZE    : integer                 :=  1;
        BUF_DEPTH       : integer                 := 12
    );
    port(
    -------------------------------------------------------------------------------
    -- Reset Signals.
    -------------------------------------------------------------------------------
        ARESETn         : in    std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F Clock.
    -------------------------------------------------------------------------------
        C_CLK           : in    std_logic;
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
    -- Operation Code Fetch I/F Clock.
    -------------------------------------------------------------------------------
        M_CLK           : in    std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch I/F AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        M_ARID          : out   std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_ARADDR        : out   std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
        M_ARLEN         : out   std_logic_vector(7 downto 0);
        M_ARSIZE        : out   std_logic_vector(2 downto 0);
        M_ARBURST       : out   std_logic_vector(1 downto 0);
        M_ARLOCK        : out   std_logic_vector(0 downto 0);
        M_ARCACHE       : out   std_logic_vector(3 downto 0);
        M_ARPROT        : out   std_logic_vector(2 downto 0);
        M_ARQOS         : out   std_logic_vector(3 downto 0);
        M_ARREGION      : out   std_logic_vector(3 downto 0);
        M_ARUSER        : out   std_logic_vector(M_AUSER_WIDTH -1 downto 0);
        M_ARVALID       : out   std_logic;
        M_ARREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch I/F AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        M_RID           : in    std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_RDATA         : in    std_logic_vector(M_DATA_WIDTH  -1 downto 0);
        M_RRESP         : in    std_logic_vector(1 downto 0);
        M_RLAST         : in    std_logic;
        M_RVALID        : in    std_logic;
        M_RREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch I/F AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        M_AWID          : out   std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_AWADDR        : out   std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
        M_AWLEN         : out   std_logic_vector(7 downto 0);
        M_AWSIZE        : out   std_logic_vector(2 downto 0);
        M_AWBURST       : out   std_logic_vector(1 downto 0);
        M_AWLOCK        : out   std_logic_vector(0 downto 0);
        M_AWCACHE       : out   std_logic_vector(3 downto 0);
        M_AWPROT        : out   std_logic_vector(2 downto 0);
        M_AWQOS         : out   std_logic_vector(3 downto 0);
        M_AWREGION      : out   std_logic_vector(3 downto 0);
        M_AWUSER        : out   std_logic_vector(M_AUSER_WIDTH -1 downto 0);
        M_AWVALID       : out   std_logic;
        M_AWREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch I/F AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        M_WDATA         : out   std_logic_vector(M_DATA_WIDTH  -1 downto 0);
        M_WSTRB         : out   std_logic_vector(M_DATA_WIDTH/8-1 downto 0);
        M_WLAST         : out   std_logic;
        M_WVALID        : out   std_logic;
        M_WREADY        : in    std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch I/F AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        M_BID           : in    std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_BRESP         : in    std_logic_vector(1 downto 0);
        M_BVALID        : in    std_logic;
        M_BREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F Clock.
    -------------------------------------------------------------------------------
        I_CLK           : in    std_logic;
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
    -- Interrupt Request Signals.
    -------------------------------------------------------------------------------
        I_IRQ           : out   std_logic;
        O_IRQ           : out   std_logic;
        IRQ             : out   std_logic
    );
end PUMP_AXI4_TO_AXI4;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_READ_INTERFACE;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_WRITE_INTERFACE;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_REGISTER_INTERFACE;
use     PIPEWORK.COMPONENTS.QUEUE_ARBITER;
use     PIPEWORK.COMPONENTS.REGISTER_ACCESS_ADAPTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROLLER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_OPERATION_PROCESSOR;
architecture RTL of PUMP_AXI4_TO_AXI4 is
    -------------------------------------------------------------------------------
    -- リセット信号.
    -------------------------------------------------------------------------------
    signal   RST                : std_logic;
    constant CLR                : std_logic := '0';
    -------------------------------------------------------------------------------
    -- レジスタアクセスインターフェースのアドレスのビット数.
    -------------------------------------------------------------------------------
    constant REGS_ADDR_WIDTH    : integer := 6;
    constant CORE_ADDR_WIDTH    : integer := 5;
    -------------------------------------------------------------------------------
    -- 全レジスタのビット数.
    -------------------------------------------------------------------------------
    constant REGS_DATA_BITS     : integer := (2**REGS_ADDR_WIDTH)*8;
    constant CORE_DATA_BITS     : integer := (2**CORE_ADDR_WIDTH)*8;
    -------------------------------------------------------------------------------
    -- レジスタアクセスインターフェースのデータのビット数.
    -------------------------------------------------------------------------------
    constant REGS_DATA_WIDTH    : integer := 32;
    -------------------------------------------------------------------------------
    -- 定数
    -------------------------------------------------------------------------------
    constant I_CKE              : std_logic        := '1';
    constant I_LOCK             : AXI4_ALOCK_TYPE  := (others => '0');
    constant I_PROT             : AXI4_APROT_TYPE  := (others => '0');
    constant I_QOS              : AXI4_AQOS_TYPE   := (others => '0');
    constant I_REGION           : AXI4_AREGION_TYPE:= (others => '0');
    constant I_ACK_REGS         : integer := 1;
    constant I_REQ_QUEUE        : integer := I_QUEUE_SIZE;
    constant I_RDATA_REGS       : integer := 3;
    -------------------------------------------------------------------------------
    -- 定数
    -------------------------------------------------------------------------------
    constant O_CKE              : std_logic        := '1';
    constant O_LOCK             : AXI4_ALOCK_TYPE  := (others => '0');
    constant O_PROT             : AXI4_APROT_TYPE  := (others => '0');
    constant O_QOS              : AXI4_AQOS_TYPE   := (others => '0');
    constant O_REGION           : AXI4_AREGION_TYPE:= (others => '0');
    constant O_REQ_REGS         : integer := 1;
    constant O_ACK_REGS         : integer := 1;
    constant O_RES_QUEUE        : integer := O_QUEUE_SIZE;
    constant O_RES_REGS         : integer := 1;
    -------------------------------------------------------------------------------
    -- レジスタアクセス用の信号群.
    -------------------------------------------------------------------------------
    signal   regs_load          : std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal   regs_wbit          : std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal   regs_rena          : std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal   regs_rbit          : std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal   pump_load          : std_logic_vector(CORE_DATA_BITS   -1 downto 0);
    signal   pump_wbit          : std_logic_vector(CORE_DATA_BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Operation Code Foramt
    -------------------------------------------------------------------------------
    --           31            24              16               8               0
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x00 |                                                               |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x04 |                                                               |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x08 |                                                               |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x0C | TYPE  |E|F|                                                   |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -------------------------------------------------------------------------------
    -- TYPE        = オペレーションコードのタイプ.
    -- End         = このビットが'1'の場合、オペレーション終了時にオペレーションプ
    --               ロセッサのStatus[0]をセットすることを指定する.
    -- Fetch       = このビットが'1'の場合、オペレーションコード読み込み時にオペレ
    --               ーションプロセッサのStatus[1]をセットすることを指定する.
    -------------------------------------------------------------------------------
    constant PO_BITS            : integer := 128;
    constant PO_TYPE_HI         : integer := 127;
    constant PO_TYPE_LO         : integer := 124;
    constant PO_END_POS         : integer := 123;
    constant PO_FETCH_POS       : integer := 122;
    constant PI_BITS            : integer := 128;
    constant PI_TYPE_HI         : integer := 127;
    constant PI_TYPE_LO         : integer := 124;
    constant PI_END_POS         : integer := 123;
    constant PI_FETCH_POS       : integer := 122;
    -------------------------------------------------------------------------------
    -- Operation Code(NONE)
    -------------------------------------------------------------------------------
    --           31            24              16               8               0
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x00 |                       Reserve[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x04 |                       Reserve[63:31]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x08 |                       Reserve[95:64]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x0C |0|0|0|0|E|F|           Reserve[121:96]                         |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -------------------------------------------------------------------------------
    -- TYPE        = "0000"
    -- End         = このビットが'1'の場合、オペレーション終了時にオペレーションプ
    --               ロセッサのStatus[0]をセットすることを指定する.
    -- Fetch       = このビットが'1'の場合、オペレーションコード読み込み時にオペレ
    --               ーションプロセッサのStatus[1]をセットすることを指定する.
    -------------------------------------------------------------------------------
    constant PO_NONE_CODE       : integer :=   0;
    constant PI_NONE_CODE       : integer :=   0;
    -------------------------------------------------------------------------------
    -- Operation Code(XFER)
    -------------------------------------------------------------------------------
    --           31            24              16               8               0
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x00 |                       Address[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x04 |                       Address[63:31]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x08 |                          Size[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x0C |1|1|0|0|E|F|L|F|0|0|0|0|0|0|0|0|          Mode[15:00]          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -------------------------------------------------------------------------------
    -- TYPE        = "1100"
    -- End         = このビットが'1'の場合、オペレーション終了時にオペレーションプ
    --               ロセッサのStatus[0]をセットすることを指定する.
    -- Fetch       = このビットが'1'の場合、オペレーションコード読み込み時にオペレ
    --               ーションプロセッサのStatus[1]をセットすることを指定する.
    -- Last        = 1:連続したトランザクションの開始を指定する.
    -- First       = 1:連続したトランザクションの終了を指定する.
    -- Mode[15]    = 1:AXI4 Master I/F をセイフティモードで動かすことを示す.
    -- Mode[14]    = 1:AXI4 Master I/F を投機モードで動かすことを示す.
    -- Mode[13]    = 1:AXI4 Master I/F をアドレス固定モードにすることを示す.
    -- Mode[12:08] = AXI4 Master I/F の ARUSER/AWUSER の値を指定する.
    -- Mode[07:04] = AXI4 Master I/F のキャッシュモードを指定する.
    -- Mode[01]    = 1:エラー発生時(Status[1]='1')に割り込みを発生する.
    -- Mode[00]    = 1:転送終了時(Status[0]='1')に割り込みを発生する.
    -- Size[31:00] = 転送サイズ.
    -- Address     = 転送開始アドレス.
    -------------------------------------------------------------------------------
    constant PO_XFER_CODE       : integer :=  12;
    constant PO_CORE_HI         : integer := 123;
    constant PO_CORE_LO         : integer :=   0;
    constant PI_XFER_CODE       : integer :=  12;
    constant PI_CORE_HI         : integer := 123;
    constant PI_CORE_LO         : integer :=   0;
    -------------------------------------------------------------------------------
    -- Operation Code(LINK)
    -------------------------------------------------------------------------------
    --           31            24              16               8               0
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x00 |                       Address[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x04 |                       Address[63:31]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x08 |                          Mode[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x0C |1|1|0|1|E|F|   |    Status     |          Mode[47:32]          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -------------------------------------------------------------------------------
    -- TYPE        = "1101"
    -- End         = このビットが'1'の場合、オペレーション終了時にオペレーションプ
    --               ロセッサのStatus[0]をセットすることを指定する.
    -- Fetch       = このビットが'1'の場合、オペレーションコード読み込み時にオペレ
    --               ーションプロセッサのStatus[1]をセットすることを指定する.
    -- Mode[43:40] = AXI4 Master Read I/F のキャッシュモードを指定する.
    -- Mode[33]    = 1:Operation Code を読み込んだ時(Status[1]='1')に割り込みを発生する.
    -- Mode[32]    = 1:オペレーション終了時(Status[0]='1')に割り込みを発生する.
    -- Address     = オペレーションコードフェッチアドレス.
    -------------------------------------------------------------------------------
    constant PO_LINK_CODE       : integer :=  13;
    constant PO_STAT_HI         : integer := 119;
    constant PO_STAT_LO         : integer := 112;
    constant PO_MODE_HI         : integer := 111;
    constant PO_MODE_LO         : integer :=  64;
    constant PO_ADDR_HI         : integer :=  63;
    constant PO_ADDR_LO         : integer :=   0;
    constant PI_LINK_CODE       : integer :=  13;
    constant PI_STAT_HI         : integer := 119;
    constant PI_STAT_LO         : integer := 112;
    constant PI_MODE_HI         : integer := 111;
    constant PI_MODE_LO         : integer :=  64;
    constant PI_ADDR_HI         : integer :=  63;
    constant PI_ADDR_LO         : integer :=   0;
    -------------------------------------------------------------------------------
    -- Operation Code(Co-Pro)
    -------------------------------------------------------------------------------
    --           31            24              16               8               0
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x00 |                       Operand[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x04 |                       Operand[63:31]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x08 |                       Operand[95:64]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    --     +0x0C |1|0|1|1|E|F|           Operand[121:96]                         |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -------------------------------------------------------------------------------
    -- TYPE        = "1011"
    -- End         = このビットが'1'の場合、オペレーション終了時にオペレーションプ
    --               ロセッサのStatus[0]をセットすることを指定する.
    -- Fetch       = このビットが'1'の場合、オペレーションコード読み込み時にオペレ
    --               ーションプロセッサのStatus[1]をセットすることを指定する.
    -- Operand     = 転送開始アドレス.
    -------------------------------------------------------------------------------
    constant PO_CPRO_CODE       : integer :=  11;
    constant PO_CPRO_HI         : integer := 121;
    constant PO_CPRO_LO         : integer :=   0;
    constant PI_CPRO_CODE       : integer :=  11;
    constant PI_CPRO_HI         : integer := 121;
    constant PI_CPRO_LO         : integer :=   0;
    -------------------------------------------------------------------------------
    -- レジスタのアドレスマップ.
    -------------------------------------------------------------------------------
    -- Pump Core Outlet Registers
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
    -------------------------------------------------------------------------------
    constant CO_REGS_BASE_ADDR  : integer := 16#00#;
    constant CO_REGS_BITS       : integer := 128;   
    constant CO_REGS_LO         : integer := 8*CO_REGS_BASE_ADDR;
    constant CO_REGS_HI         : integer := CO_REGS_LO + CO_REGS_BITS - 1;
    -------------------------------------------------------------------------------
    -- Pump Core Outlet Address Register
    -------------------------------------------------------------------------------
    -- Address     = 転送開始アドレス.
    -------------------------------------------------------------------------------
    constant CO_ADDR_REGS_ADDR  : integer := CO_REGS_BASE_ADDR + 16#00#;
    constant CO_ADDR_REGS_BITS  : integer := 64;
    constant CO_ADDR_REGS_LO    : integer := 8*CO_ADDR_REGS_ADDR;
    constant CO_ADDR_REGS_HI    : integer := 8*CO_ADDR_REGS_ADDR + CO_ADDR_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Core Outlet Size Register
    -------------------------------------------------------------------------------
    -- Size[31:00] = 転送サイズ.
    -------------------------------------------------------------------------------
    constant CO_SIZE_REGS_ADDR  : integer := CO_REGS_BASE_ADDR + 16#08#;
    constant CO_SIZE_REGS_BITS  : integer := 32;
    constant CO_SIZE_REGS_LO    : integer := 8*CO_SIZE_REGS_ADDR;
    constant CO_SIZE_REGS_HI    : integer := 8*CO_SIZE_REGS_ADDR + CO_SIZE_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Core Outlet Mode Register
    -------------------------------------------------------------------------------
    -- Mode[15]    = 1:AXI4 Master Write I/F をセイフティモードで動かす.
    -- Mode[14]    = 1:AXI4 Master Write I/F を投機モードで動かす.
    -- Mode[13]    = 1:AXI4 Master Write I/F をアドレス固定モードにする.
    -- Mode[12:08] = AXI4 Master Write I/F の AWUSER の値を指定する.
    -- Mode[07:04] = AXI4 Master Write I/F のキャッシュモードを指定する.
    -- Mode[01]    = 1:エラー発生時(Status[1]='1')に割り込みを発生する.
    -- Mode[00]    = 1:転送終了時(Status[0]='1')に割り込みを発生する.
    -------------------------------------------------------------------------------
    constant CO_MODE_REGS_ADDR  : integer := CO_REGS_BASE_ADDR + 16#0C#;
    constant CO_MODE_REGS_BITS  : integer := 16;
    constant CO_MODE_REGS_HI    : integer := 8*CO_MODE_REGS_ADDR + 15;
    constant CO_MODE_REGS_LO    : integer := 8*CO_MODE_REGS_ADDR +  0;
    constant CO_MODE_SAFETY_POS : integer := 8*CO_MODE_REGS_ADDR + 15;
    constant CO_MODE_SPECUL_POS : integer := 8*CO_MODE_REGS_ADDR + 14;
    constant CO_MODE_AFIX_POS   : integer := 8*CO_MODE_REGS_ADDR + 13;
    constant CO_MODE_AUSER_HI   : integer := 8*CO_MODE_REGS_ADDR + 12;
    constant CO_MODE_AUSER_LO   : integer := 8*CO_MODE_REGS_ADDR +  8;
    constant CO_MODE_CACHE_HI   : integer := 8*CO_MODE_REGS_ADDR +  7;
    constant CO_MODE_CACHE_LO   : integer := 8*CO_MODE_REGS_ADDR +  4;
    constant CO_MODE_ERROR_POS  : integer := 8*CO_MODE_REGS_ADDR +  1;
    constant CO_MODE_DONE_POS   : integer := 8*CO_MODE_REGS_ADDR +  0;
    -------------------------------------------------------------------------------
    -- Pump Core Outlet Status Register
    -------------------------------------------------------------------------------
    -- Status[7:2] = 予約.
    -- Status[1]   = エラー発生時にセットされる.
    -- Status[0]   = 転送終了時かつ Control[2]='1' にセットされる.
    -------------------------------------------------------------------------------
    constant CO_STAT_REGS_ADDR  : integer := CO_REGS_BASE_ADDR + 16#0E#;
    constant CO_STAT_REGS_BITS  : integer := 8;
    constant CO_STAT_RESV_HI    : integer := 8*CO_STAT_REGS_ADDR +  7;
    constant CO_STAT_RESV_LO    : integer := 8*CO_STAT_REGS_ADDR +  2;
    constant CO_STAT_ERROR_POS  : integer := 8*CO_STAT_REGS_ADDR +  1;
    constant CO_STAT_DONE_POS   : integer := 8*CO_STAT_REGS_ADDR +  0;
    constant CO_STAT_RESV_BITS  : integer := CO_STAT_RESV_HI - CO_STAT_RESV_LO + 1;
    -------------------------------------------------------------------------------
    -- Pump Core Outlet Control Register
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
    constant CO_CTRL_REGS_ADDR  : integer := CO_REGS_BASE_ADDR + 16#0F#;
    constant CO_CTRL_RESET_POS  : integer := 8*CO_CTRL_REGS_ADDR +  7;
    constant CO_CTRL_PAUSE_POS  : integer := 8*CO_CTRL_REGS_ADDR +  6;
    constant CO_CTRL_STOP_POS   : integer := 8*CO_CTRL_REGS_ADDR +  5;
    constant CO_CTRL_START_POS  : integer := 8*CO_CTRL_REGS_ADDR +  4;
    constant CO_CTRL_RESV_POS   : integer := 8*CO_CTRL_REGS_ADDR +  3;
    constant CO_CTRL_DONE_POS   : integer := 8*CO_CTRL_REGS_ADDR +  2;
    constant CO_CTRL_FIRST_POS  : integer := 8*CO_CTRL_REGS_ADDR +  1;
    constant CO_CTRL_LAST_POS   : integer := 8*CO_CTRL_REGS_ADDR +  0;
    -------------------------------------------------------------------------------
    -- Pump Core Outlet Processor Operation Code Range
    -------------------------------------------------------------------------------
    constant CO_OPERAND_LO      : integer := CO_REGS_LO;
    constant CO_OPERAND_HI      : integer := CO_CTRL_RESV_POS;
    -------------------------------------------------------------------------------
    -- Pump Core Intake Registers
    -------------------------------------------------------------------------------
    --           31            24              16               8               0
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x10 |                       Address[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x14 |                       Address[63:31]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x18 |                          Size[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x1C | Control[7:0]  |  Status[7:0]  |          Mode[15:00]          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -------------------------------------------------------------------------------
    constant CI_REGS_BASE_ADDR  : integer := 16#10#;
    constant CI_REGS_BITS       : integer := 128;
    constant CI_REGS_LO         : integer := 8*CI_REGS_BASE_ADDR;
    constant CI_REGS_HI         : integer := CI_REGS_LO + CI_REGS_BITS - 1;
    -------------------------------------------------------------------------------
    -- Pump Core Intake Address Register
    -------------------------------------------------------------------------------
    -- Address     = 転送開始アドレス.
    -------------------------------------------------------------------------------
    constant CI_ADDR_REGS_ADDR  : integer := CI_REGS_BASE_ADDR + 16#00#;
    constant CI_ADDR_REGS_BITS  : integer := 64;
    constant CI_ADDR_REGS_LO    : integer := 8*CI_ADDR_REGS_ADDR;
    constant CI_ADDR_REGS_HI    : integer := 8*CI_ADDR_REGS_ADDR + CI_ADDR_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Core Intake Size Register
    -------------------------------------------------------------------------------
    -- Size[31:00] = 転送サイズ.
    -------------------------------------------------------------------------------
    constant CI_SIZE_REGS_ADDR  : integer := CI_REGS_BASE_ADDR + 16#08#;
    constant CI_SIZE_REGS_BITS  : integer := 32;
    constant CI_SIZE_REGS_LO    : integer := 8*CI_SIZE_REGS_ADDR;
    constant CI_SIZE_REGS_HI    : integer := 8*CI_SIZE_REGS_ADDR + CI_SIZE_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Pump Core Intake Mode Register
    -------------------------------------------------------------------------------
    -- Mode[15]    = 1:AXI4 Master Read I/F をセイフティモードで動かす.
    -- Mode[14]    = 1:AXI4 Master Read I/F を投機モードで動かす.
    -- Mode[13]    = 1:AXI4 Master Read I/F をアドレス固定モードにする.
    -- Mode[11:08] = AXI4 Master Read I/F の ARUSER の値を指定する.
    -- Mode[07:04] = AXI4 Master Read I/F のキャッシュモードを指定する.
    -- Mode[01]    = 1:エラー発生時(Status[1]='1')に割り込みを発生する.
    -- Mode[00]    = 1:転送終了時(Status[0]='1')に割り込みを発生する.
    -------------------------------------------------------------------------------
    constant CI_MODE_REGS_ADDR  : integer := CI_REGS_BASE_ADDR + 16#0C#;
    constant CI_MODE_REGS_BITS  : integer := 16;
    constant CI_MODE_REGS_HI    : integer := 8*CI_MODE_REGS_ADDR + 15;
    constant CI_MODE_REGS_LO    : integer := 8*CI_MODE_REGS_ADDR +  0;
    constant CI_MODE_SAFETY_POS : integer := 8*CI_MODE_REGS_ADDR + 15;
    constant CI_MODE_SPECUL_POS : integer := 8*CI_MODE_REGS_ADDR + 14;
    constant CI_MODE_AFIX_POS   : integer := 8*CI_MODE_REGS_ADDR + 13;
    constant CI_MODE_AUSER_HI   : integer := 8*CI_MODE_REGS_ADDR + 12;
    constant CI_MODE_AUSER_LO   : integer := 8*CI_MODE_REGS_ADDR +  8;
    constant CI_MODE_CACHE_HI   : integer := 8*CI_MODE_REGS_ADDR +  7;
    constant CI_MODE_CACHE_LO   : integer := 8*CI_MODE_REGS_ADDR +  4;
    constant CI_MODE_ERROR_POS  : integer := 8*CI_MODE_REGS_ADDR +  1;
    constant CI_MODE_DONE_POS   : integer := 8*CI_MODE_REGS_ADDR +  0;
    -------------------------------------------------------------------------------
    -- Pump Core Intake Status Register
    -------------------------------------------------------------------------------
    -- Status[7:2] = 予約.
    -- Status[1]   = エラー発生時にセットされる.
    -- Status[0]   = 転送終了時かつ Control[2]='1' にセットされる.
    -------------------------------------------------------------------------------
    constant CI_STAT_REGS_ADDR  : integer := CI_REGS_BASE_ADDR + 16#0E#;
    constant CI_STAT_REGS_BITS  : integer := 8;
    constant CI_STAT_RESV_HI    : integer := 8*CI_STAT_REGS_ADDR +  7;
    constant CI_STAT_RESV_LO    : integer := 8*CI_STAT_REGS_ADDR +  2;
    constant CI_STAT_ERROR_POS  : integer := 8*CI_STAT_REGS_ADDR +  1;
    constant CI_STAT_DONE_POS   : integer := 8*CI_STAT_REGS_ADDR +  0;
    constant CI_STAT_RESV_BITS  : integer := CI_STAT_RESV_HI - CI_STAT_RESV_LO + 1;
    -------------------------------------------------------------------------------
    -- Pump Core Intake Control Register
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
    constant CI_CTRL_REGS_ADDR  : integer := CI_REGS_BASE_ADDR + 16#0F#;
    constant CI_CTRL_RESET_POS  : integer := 8*CI_CTRL_REGS_ADDR +  7;
    constant CI_CTRL_PAUSE_POS  : integer := 8*CI_CTRL_REGS_ADDR +  6;
    constant CI_CTRL_STOP_POS   : integer := 8*CI_CTRL_REGS_ADDR +  5;
    constant CI_CTRL_START_POS  : integer := 8*CI_CTRL_REGS_ADDR +  4;
    constant CI_CTRL_RESV_POS   : integer := 8*CI_CTRL_REGS_ADDR +  3;
    constant CI_CTRL_DONE_POS   : integer := 8*CI_CTRL_REGS_ADDR +  2;
    constant CI_CTRL_FIRST_POS  : integer := 8*CI_CTRL_REGS_ADDR +  1;
    constant CI_CTRL_LAST_POS   : integer := 8*CI_CTRL_REGS_ADDR +  0;
    -------------------------------------------------------------------------------
    -- Pump Core Intake Processor Operation Code Range
    -------------------------------------------------------------------------------
    constant CI_OPERAND_LO      : integer := CI_REGS_LO;
    constant CI_OPERAND_HI      : integer := CI_CTRL_RESV_POS;
    -------------------------------------------------------------------------------
    -- Pump Outlet Processor Registers
    -------------------------------------------------------------------------------
    --           31            24              16               8               0
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x20 |                       Address[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x24 |                       Address[63:31]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x28 |                          Mode[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x2C |  Control[7:0] |  Status[7:0]  |          Mode[47:32]          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -------------------------------------------------------------------------------
    constant PO_REGS_BASE_ADDR  : integer := 16#20#;
    constant PO_REGS_BITS       : integer := 128;
    constant PO_REGS_LO         : integer := 8*PO_REGS_BASE_ADDR;
    constant PO_REGS_HI         : integer := PO_REGS_LO + PO_REGS_BITS - 1;
    -------------------------------------------------------------------------------
    -- Pump Outlet Processor Address Register
    -------------------------------------------------------------------------------
    -- Address     = オペレーションコードフェッチアドレス.
    -------------------------------------------------------------------------------
    constant PO_ADDR_REGS_ADDR  : integer := PO_REGS_BASE_ADDR + 16#00#;
    constant PO_ADDR_REGS_LO    : integer := 8*PO_REGS_BASE_ADDR + PO_ADDR_LO;
    constant PO_ADDR_REGS_HI    : integer := 8*PO_REGS_BASE_ADDR + PO_ADDR_HI;
    -------------------------------------------------------------------------------
    -- Pump Outlet Processor Mode Register
    -------------------------------------------------------------------------------
    -- Mode[44:40] = AXI4 Master Read I/F の ARUSER の値を指定する.
    -- Mode[39:36] = AXI4 Master Read I/F のキャッシュモードを指定する.
    -- Mode[33]    = 1:Operation Code を読み込んだ時(Status[1]='1')に割り込みを発生する.
    -- Mode[32]    = 1:オペレーション終了時(Status[0]='1')に割り込みを発生する.
    -------------------------------------------------------------------------------
    constant PO_MODE_REGS_ADDR  : integer := PO_REGS_BASE_ADDR + 16#08#;
    constant PO_MODE_REGS_HI    : integer := 8*PO_REGS_BASE_ADDR + PO_MODE_HI;
    constant PO_MODE_REGS_LO    : integer := 8*PO_REGS_BASE_ADDR + PO_MODE_LO;
    constant PO_MODE_AUSER_HI   : integer := 8*PO_REGS_BASE_ADDR + PO_MODE_LO + 44;
    constant PO_MODE_AUSER_LO   : integer := 8*PO_REGS_BASE_ADDR + PO_MODE_LO + 40;
    constant PO_MODE_CACHE_HI   : integer := 8*PO_REGS_BASE_ADDR + PO_MODE_LO + 39;
    constant PO_MODE_CACHE_LO   : integer := 8*PO_REGS_BASE_ADDR + PO_MODE_LO + 36;
    constant PO_MODE_FETCH_POS  : integer := 8*PO_REGS_BASE_ADDR + PO_MODE_LO + 33;
    constant PO_MODE_END_POS    : integer := 8*PO_REGS_BASE_ADDR + PO_MODE_LO + 32;
    -------------------------------------------------------------------------------
    -- Pump Outlet Processor Status Register
    -------------------------------------------------------------------------------
    -- Status[4]   = 1:出力時にエラーが発生した事を示す.
    -- Status[3]   = 1:オペレーションコード読み込み時にエラーが発生した事を示す.
    -- Status[2]   = 1:不正なオペレーションコードを読み込んだ事を示す.
    -- Status[1]   = 1:Fetchフラグ付きのオペレーションコードを読み込んだ事を示す.
    -- Status[0]   = 1:Endフラグ付きのオペレーションコードを処理し終えた事をを示す.
    -------------------------------------------------------------------------------
    constant PO_STAT_REGS_ADDR  : integer := PO_REGS_BASE_ADDR + 16#0E#;
    constant PO_STAT_REGS_HI    : integer := 8*PO_REGS_BASE_ADDR + PO_STAT_HI;
    constant PO_STAT_REGS_LO    : integer := 8*PO_REGS_BASE_ADDR + PO_STAT_LO;
    constant PO_STAT_ERROR_HI   : integer := 8*PO_REGS_BASE_ADDR + PO_STAT_LO + 4;
    constant PO_STAT_ERROR_LO   : integer := 8*PO_REGS_BASE_ADDR + PO_STAT_LO + 2;
    constant PO_STAT_FETCH_POS  : integer := 8*PO_REGS_BASE_ADDR + PO_STAT_LO + 1;
    constant PO_STAT_END_POS    : integer := 8*PO_REGS_BASE_ADDR + PO_STAT_LO + 0;
    -------------------------------------------------------------------------------
    -- Pump Outlet Processor Control Register
    -------------------------------------------------------------------------------
    -- Control[7]  = 1:モジュールをリセットする. 0:リセットを解除する.
    -- Control[6]  = 1:転送を一時中断する.       0:転送を再開する.
    -- Control[5]  = 1:転送を中止する.           0:意味無し.
    -- Control[4]  = 1:転送を開始する.           0:意味無し.
    -- Control[3:0]= 予約.
    -------------------------------------------------------------------------------
    constant PO_CTRL_REGS_ADDR  : integer := PO_REGS_BASE_ADDR + 16#0F#;
    constant PO_CTRL_RESET_POS  : integer := 8*PO_CTRL_REGS_ADDR + 7;
    constant PO_CTRL_PAUSE_POS  : integer := 8*PO_CTRL_REGS_ADDR + 6;
    constant PO_CTRL_STOP_POS   : integer := 8*PO_CTRL_REGS_ADDR + 5;
    constant PO_CTRL_START_POS  : integer := 8*PO_CTRL_REGS_ADDR + 4;
    constant PO_CTRL_RESV_HI    : integer := 8*PO_CTRL_REGS_ADDR + 3;
    constant PO_CTRL_RESV_LO    : integer := 8*PO_CTRL_REGS_ADDR + 0;
    -------------------------------------------------------------------------------
    -- Pump Intake Processor Registers
    -------------------------------------------------------------------------------
    --           31            24              16               8               0
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x30 |                       Address[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x34 |                       Address[63:31]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x38 |                          Mode[31:00]                          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -- Addr=0x3C |  Control[7:0] |  Status[7:0]  |          Mode[47:32]          |
    --           +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    -------------------------------------------------------------------------------
    constant PI_REGS_BASE_ADDR  : integer := 16#30#;
    constant PI_REGS_BITS       : integer := 128;
    constant PI_REGS_LO         : integer := 8*PI_REGS_BASE_ADDR;
    constant PI_REGS_HI         : integer := PI_REGS_LO + PI_REGS_BITS - 1;
    -------------------------------------------------------------------------------
    -- Pump Intake Processor Address Register
    -------------------------------------------------------------------------------
    -- Address     = オペレーションコードフェッチアドレス.
    -------------------------------------------------------------------------------
    constant PI_ADDR_REGS_ADDR  : integer := PI_REGS_BASE_ADDR + 16#00#;
    constant PI_ADDR_REGS_LO    : integer := 8*PI_REGS_BASE_ADDR + PI_ADDR_LO;
    constant PI_ADDR_REGS_HI    : integer := 8*PI_REGS_BASE_ADDR + PI_ADDR_HI;
    -------------------------------------------------------------------------------
    -- Pump Intake Processor Mode Register
    -------------------------------------------------------------------------------
    -- Mode[44:40] = AXI4 Master Read I/F の ARUSER の値を指定する.
    -- Mode[39:36] = AXI4 Master Read I/F のキャッシュモードを指定する.
    -- Mode[33]    = 1:Operation Code を読み込んだ時(Status[1]='1')に割り込みを発生する.
    -- Mode[32]    = 1:オペレーション終了時(Status[0]='1')に割り込みを発生する.
    -------------------------------------------------------------------------------
    constant PI_MODE_REGS_ADDR  : integer := PI_REGS_BASE_ADDR + 16#08#;
    constant PI_MODE_REGS_HI    : integer := 8*PI_REGS_BASE_ADDR + PI_MODE_HI;
    constant PI_MODE_REGS_LO    : integer := 8*PI_REGS_BASE_ADDR + PI_MODE_LO;
    constant PI_MODE_AUSER_HI   : integer := 8*PI_REGS_BASE_ADDR + PI_MODE_LO + 44;
    constant PI_MODE_AUSER_LO   : integer := 8*PI_REGS_BASE_ADDR + PI_MODE_LO + 40;
    constant PI_MODE_CACHE_HI   : integer := 8*PI_REGS_BASE_ADDR + PI_MODE_LO + 39;
    constant PI_MODE_CACHE_LO   : integer := 8*PI_REGS_BASE_ADDR + PI_MODE_LO + 36;
    constant PI_MODE_FETCH_POS  : integer := 8*PI_REGS_BASE_ADDR + PI_MODE_LO + 33;
    constant PI_MODE_END_POS    : integer := 8*PI_REGS_BASE_ADDR + PI_MODE_LO + 32;
    -------------------------------------------------------------------------------
    -- Pump Intake Processor Status Register
    -------------------------------------------------------------------------------
    -- Status[4]   = 1:出力時にエラーが発生した事を示す.
    -- Status[3]   = 1:オペレーションコード読み込み時にエラーが発生した事を示す.
    -- Status[2]   = 1:不正なオペレーションコードを読み込んだ事を示す.
    -- Status[1]   = 1:Fetchフラグ付きのオペレーションコードを読み込んだ事を示す.
    -- Status[0]   = 1:Endフラグ付きのオペレーションコードを処理し終えた事をを示す.
    -------------------------------------------------------------------------------
    constant PI_STAT_REGS_ADDR  : integer := PI_REGS_BASE_ADDR + 16#0E#;
    constant PI_STAT_REGS_HI    : integer := 8*PI_REGS_BASE_ADDR + PI_STAT_HI;
    constant PI_STAT_REGS_LO    : integer := 8*PI_REGS_BASE_ADDR + PI_STAT_LO;
    constant PI_STAT_ERROR_HI   : integer := 8*PI_REGS_BASE_ADDR + PI_STAT_LO + 4;
    constant PI_STAT_ERROR_LO   : integer := 8*PI_REGS_BASE_ADDR + PI_STAT_LO + 2;
    constant PI_STAT_FETCH_POS  : integer := 8*PI_REGS_BASE_ADDR + PI_STAT_LO + 1;
    constant PI_STAT_END_POS    : integer := 8*PI_REGS_BASE_ADDR + PI_STAT_LO + 0;
    -------------------------------------------------------------------------------
    -- Pump Intake Processor Control Register
    -------------------------------------------------------------------------------
    -- Control[7]  = 1:モジュールをリセットする. 0:リセットを解除する.
    -- Control[6]  = 1:転送を一時中断する.       0:転送を再開する.
    -- Control[5]  = 1:転送を中止する.           0:意味無し.
    -- Control[4]  = 1:転送を開始する.           0:意味無し.
    -- Control[3:0]= 予約.
    -------------------------------------------------------------------------------
    constant PI_CTRL_REGS_ADDR  : integer := PI_REGS_BASE_ADDR + 16#0F#;
    constant PI_CTRL_RESV_HI    : integer := 8*PI_CTRL_REGS_ADDR + 3;
    constant PI_CTRL_RESV_LO    : integer := 8*PI_CTRL_REGS_ADDR + 0;
    constant PI_CTRL_RESET_POS  : integer := 8*PI_CTRL_REGS_ADDR + 7;
    constant PI_CTRL_PAUSE_POS  : integer := 8*PI_CTRL_REGS_ADDR + 6;
    constant PI_CTRL_STOP_POS   : integer := 8*PI_CTRL_REGS_ADDR + 5;
    constant PI_CTRL_START_POS  : integer := 8*PI_CTRL_REGS_ADDR + 4;
    -------------------------------------------------------------------------------
    -- Pump Core Outlet signals.
    -------------------------------------------------------------------------------
    signal   core_o_open        : std_logic;
    signal   core_o_run         : std_logic;
    signal   core_o_done        : std_logic;
    signal   core_o_none        : std_logic;
    signal   core_o_error       : std_logic;
    signal   core_o_stat        : std_logic_vector(CO_STAT_RESV_HI downto CO_STAT_RESV_LO);
    signal   core_o_auser       : std_logic_vector(O_AUSER_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- Pump Core Intake signals.
    -------------------------------------------------------------------------------
    signal   core_i_open        : std_logic;
    signal   core_i_run         : std_logic;
    signal   core_i_done        : std_logic;
    signal   core_i_none        : std_logic;
    signal   core_i_error       : std_logic;
    signal   core_i_stat        : std_logic_vector(CI_STAT_RESV_HI downto CI_STAT_RESV_LO);
    signal   core_i_auser       : std_logic_vector(I_AUSER_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   i_interrupt        : std_logic;
    signal   o_interrupt        : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant i_ruser            : std_logic_vector(0 downto 0) := (others => '0');
    constant o_buser            : std_logic_vector(0 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    function resize(ARG:std_logic_vector;LEN:integer) return std_logic_vector is
        variable val : std_logic_vector(LEN-1        downto 0);
        alias    av  : std_logic_vector(ARG'length-1 downto 0) is ARG;
    begin
        for i in val'range loop
            if (i > av'high) then
                val(i) := '0';
            else
                val(i) := av(i);
            end if;
        end loop;
        return val;
    end function;
    -------------------------------------------------------------------------------
    -- PUMP_AXI4_TO_AXI4_CORE のコンポーネント宣言.
    -------------------------------------------------------------------------------
    component PUMP_AXI4_TO_AXI4_CORE
        generic (
            I_CLK_RATE      : integer                                :=  1;
            I_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
            I_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
            I_ID_WIDTH      : integer                                :=  4;
            I_AUSER_WIDTH   : integer range 1 to 32                  :=  4;
            I_RUSER_WIDTH   : integer range 1 to 32                  :=  4;
            I_AXI_ID        : integer                                :=  1;
            I_REG_ADDR_BITS : integer                                := 64;
            I_REG_SIZE_BITS : integer                                := 32;
            I_REG_MODE_BITS : integer                                := 16;
            I_REG_STAT_BITS : integer                                :=  8;
            I_MAX_XFER_SIZE : integer                                :=  8;
            I_REQ_QUEUE     : integer                                :=  1;
            I_ACK_REGS      : integer range 0 to 1                   :=  0;
            I_RDATA_REGS    : integer                                :=  0;
            O_CLK_RATE      : integer                                :=  1;
            O_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
            O_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
            O_ID_WIDTH      : integer                                :=  4;
            O_AUSER_WIDTH   : integer range 1 to 32                  :=  4;
            O_WUSER_WIDTH   : integer range 1 to 32                  :=  4;
            O_BUSER_WIDTH   : integer range 1 to 32                  :=  4;
            O_AXI_ID        : integer                                :=  2;
            O_REG_ADDR_BITS : integer                                := 64;
            O_REG_SIZE_BITS : integer                                := 32;
            O_REG_MODE_BITS : integer                                := 16;
            O_REG_STAT_BITS : integer                                :=  8;
            O_MAX_XFER_SIZE : integer                                :=  1;
            O_REQ_REGS      : integer range 0 to 1                   :=  0;
            O_ACK_REGS      : integer range 0 to 1                   :=  0;
            O_RES_QUEUE     : integer                                :=  2;
            O_RES_REGS      : integer                                :=  1;
            BUF_DEPTH       : integer                                := 12
        );
        port(
            RST             : in  std_logic;
            I_CLK           : in  std_logic; 
            I_CLR           : in  std_logic;
            I_CKE           : in  std_logic;
            I_ADDR_L        : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
            I_ADDR_D        : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
            I_ADDR_Q        : out std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
            I_SIZE_L        : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
            I_SIZE_D        : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
            I_SIZE_Q        : out std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
            I_MODE_L        : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
            I_MODE_D        : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
            I_MODE_Q        : out std_logic_vector(I_REG_MODE_BITS-1 downto 0);
            I_STAT_L        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
            I_STAT_D        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
            I_STAT_Q        : out std_logic_vector(I_REG_STAT_BITS-1 downto 0);
            I_STAT_I        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
            I_RESET_L       : in  std_logic;
            I_RESET_D       : in  std_logic;
            I_RESET_Q       : out std_logic;
            I_START_L       : in  std_logic;
            I_START_D       : in  std_logic;
            I_START_Q       : out std_logic;
            I_STOP_L        : in  std_logic;
            I_STOP_D        : in  std_logic;
            I_STOP_Q        : out std_logic;
            I_PAUSE_L       : in  std_logic;
            I_PAUSE_D       : in  std_logic;
            I_PAUSE_Q       : out std_logic;
            I_FIRST_L       : in  std_logic;
            I_FIRST_D       : in  std_logic;
            I_FIRST_Q       : out std_logic;
            I_LAST_L        : in  std_logic;
            I_LAST_D        : in  std_logic;
            I_LAST_Q        : out std_logic;
            I_DONE_EN_L     : in  std_logic;
            I_DONE_EN_D     : in  std_logic;
            I_DONE_EN_Q     : out std_logic;
            I_DONE_ST_L     : in  std_logic;
            I_DONE_ST_D     : in  std_logic;
            I_DONE_ST_Q     : out std_logic;
            I_ERR_ST_L      : in  std_logic;
            I_ERR_ST_D      : in  std_logic;
            I_ERR_ST_Q      : out std_logic;
            I_ADDR_FIX      : in  std_logic;
            I_SPECULATIVE   : in  std_logic;
            I_SAFETY        : in  std_logic;
            I_CACHE         : in  AXI4_ACACHE_TYPE ;
            I_LOCK          : in  AXI4_ALOCK_TYPE  ;
            I_PROT          : in  AXI4_APROT_TYPE  ;
            I_QOS           : in  AXI4_AQOS_TYPE   ;
            I_REGION        : in  AXI4_AREGION_TYPE;
            I_AUSER         : in  std_logic_vector(I_AUSER_WIDTH  -1 downto 0);
            O_CLK           : in  std_logic; 
            O_CLR           : in  std_logic;
            O_CKE           : in  std_logic;
            O_ADDR_L        : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
            O_ADDR_D        : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
            O_ADDR_Q        : out std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
            O_SIZE_L        : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
            O_SIZE_D        : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
            O_SIZE_Q        : out std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
            O_MODE_L        : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
            O_MODE_D        : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
            O_MODE_Q        : out std_logic_vector(O_REG_MODE_BITS-1 downto 0);
            O_STAT_L        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
            O_STAT_D        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
            O_STAT_Q        : out std_logic_vector(O_REG_STAT_BITS-1 downto 0);
            O_STAT_I        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
            O_RESET_L       : in  std_logic;
            O_RESET_D       : in  std_logic;
            O_RESET_Q       : out std_logic;
            O_START_L       : in  std_logic;
            O_START_D       : in  std_logic;
            O_START_Q       : out std_logic;
            O_STOP_L        : in  std_logic;
            O_STOP_D        : in  std_logic;
            O_STOP_Q        : out std_logic;
            O_PAUSE_L       : in  std_logic;
            O_PAUSE_D       : in  std_logic;
            O_PAUSE_Q       : out std_logic;
            O_FIRST_L       : in  std_logic;
            O_FIRST_D       : in  std_logic;
            O_FIRST_Q       : out std_logic;
            O_LAST_L        : in  std_logic;
            O_LAST_D        : in  std_logic;
            O_LAST_Q        : out std_logic;
            O_DONE_EN_L     : in  std_logic;
            O_DONE_EN_D     : in  std_logic;
            O_DONE_EN_Q     : out std_logic;
            O_DONE_ST_L     : in  std_logic;
            O_DONE_ST_D     : in  std_logic;
            O_DONE_ST_Q     : out std_logic;
            O_ERR_ST_L      : in  std_logic;
            O_ERR_ST_D      : in  std_logic;
            O_ERR_ST_Q      : out std_logic;
            O_ADDR_FIX      : in  std_logic;
            O_SPECULATIVE   : in  std_logic;
            O_SAFETY        : in  std_logic;
            O_CACHE         : in  AXI4_ACACHE_TYPE ;
            O_LOCK          : in  AXI4_ALOCK_TYPE  ;
            O_PROT          : in  AXI4_APROT_TYPE  ;
            O_QOS           : in  AXI4_AQOS_TYPE   ;
            O_REGION        : in  AXI4_AREGION_TYPE;
            O_AUSER         : in  std_logic_vector(O_AUSER_WIDTH  -1 downto 0);
            I_ARID          : out std_logic_vector(I_ID_WIDTH     -1 downto 0);
            I_ARADDR        : out std_logic_vector(I_ADDR_WIDTH   -1 downto 0);
            I_ARLEN         : out AXI4_ALEN_TYPE;
            I_ARSIZE        : out AXI4_ASIZE_TYPE;
            I_ARBURST       : out AXI4_ABURST_TYPE;
            I_ARLOCK        : out AXI4_ALOCK_TYPE;
            I_ARCACHE       : out AXI4_ACACHE_TYPE;
            I_ARPROT        : out AXI4_APROT_TYPE;
            I_ARQOS         : out AXI4_AQOS_TYPE;
            I_ARREGION      : out AXI4_AREGION_TYPE;
            I_ARUSER        : out std_logic_vector(I_AUSER_WIDTH  -1 downto 0);
            I_ARVALID       : out std_logic;
            I_ARREADY       : in  std_logic;
            I_RID           : in  std_logic_vector(I_ID_WIDTH     -1 downto 0);
            I_RDATA         : in  std_logic_vector(I_DATA_WIDTH   -1 downto 0);
            I_RRESP         : in  AXI4_RESP_TYPE;
            I_RLAST         : in  std_logic;
            I_RUSER         : in  std_logic_vector(I_RUSER_WIDTH  -1 downto 0);
            I_RVALID        : in  std_logic;
            I_RREADY        : out std_logic;
            O_AWID          : out std_logic_vector(O_ID_WIDTH     -1 downto 0);
            O_AWADDR        : out std_logic_vector(O_ADDR_WIDTH   -1 downto 0);
            O_AWLEN         : out AXI4_ALEN_TYPE;
            O_AWSIZE        : out AXI4_ASIZE_TYPE;
            O_AWBURST       : out AXI4_ABURST_TYPE;
            O_AWLOCK        : out AXI4_ALOCK_TYPE;
            O_AWCACHE       : out AXI4_ACACHE_TYPE;
            O_AWPROT        : out AXI4_APROT_TYPE;
            O_AWQOS         : out AXI4_AQOS_TYPE;
            O_AWREGION      : out AXI4_AREGION_TYPE;
            O_AWUSER        : out std_logic_vector(O_AUSER_WIDTH  -1 downto 0);
            O_AWVALID       : out std_logic;
            O_AWREADY       : in  std_logic;
            O_WID           : out std_logic_vector(O_ID_WIDTH     -1 downto 0);
            O_WDATA         : out std_logic_vector(O_DATA_WIDTH   -1 downto 0);
            O_WSTRB         : out std_logic_vector(O_DATA_WIDTH/8 -1 downto 0);
            O_WUSER         : out std_logic_vector(O_WUSER_WIDTH  -1 downto 0);
            O_WLAST         : out std_logic;
            O_WVALID        : out std_logic;
            O_WREADY        : in  std_logic;
            O_BID           : in  std_logic_vector(O_ID_WIDTH     -1 downto 0);
            O_BRESP         : in  AXI4_RESP_TYPE;
            O_BUSER         : in  std_logic_vector(O_BUSER_WIDTH  -1 downto 0);
            O_BVALID        : in  std_logic;
            O_BREADY        : out std_logic;
            I_OPEN          : out std_logic;
            I_RUNNING       : out std_logic;
            I_DONE          : out std_logic;
            I_NONE          : out std_logic;
            I_ERROR         : out std_logic;
            O_OPEN          : out std_logic;
            O_RUNNING       : out std_logic;
            O_DONE          : out std_logic;
            O_NONE          : out std_logic;
            O_ERROR         : out std_logic
        );
    end component;
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
                CLK             => C_CLK             , -- In  :
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
                I_CLK           => C_CLK             , -- In  :
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
                O_CLK           => C_CLK             , -- In  :
                O_CLR           => CLR               , -- In  :
                O_CKE           => sig_1             , -- In  :
                O_WDATA         => regs_wbit         , -- Out :
                O_WLOAD         => regs_load         , -- Out :
                O_RENAB         => regs_rena         , -- Out :
                O_RDATA         => regs_rbit           -- In  :
            );                                         -- 
    end block;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    PUMP_PROC: if (I_PROC_VALID /= 0 or O_PROC_VALID /= 0) generate
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant MR_BUF_SIZE        : integer := 4;
        constant MR_BUF_WIDTH       : integer := 5;
        constant MR_SIZE_BITS       : integer := MR_BUF_SIZE+1;
        constant MR_QUEUE_SIZE      : integer := 1;
        constant MR_RDATA_REGS      : integer := 1;
        constant MR_ACK_REGS        : integer := 1;
        constant MR_MAX_XFER_SIZE   : integer := 4;
        constant MR_ID              : std_logic_vector(M_ID_WIDTH -1 downto 0) := 
                                      std_logic_vector(to_unsigned(M_AXI_ID, M_ID_WIDTH));
        constant MR_XFER_SIZE_SEL   : std_logic_vector(MR_MAX_XFER_SIZE downto MR_MAX_XFER_SIZE) := std_logic_vector'("1");
        constant MR_SPECULATIVE     : std_logic := '0';
        constant MR_SAFETY          : std_logic := '1';
        constant MR_LOCK            : AXI4_ALOCK_TYPE  := (others => '0');
        constant MR_PROT            : AXI4_APROT_TYPE  := (others => '0');
        constant MR_QOS             : AXI4_AQOS_TYPE   := (others => '0');
        constant MR_REGION          : AXI4_AREGION_TYPE:= (others => '0');
        signal   mr_cache           : AXI4_ACACHE_TYPE;
        signal   mr_auser           : std_logic_vector(4 downto 0);
        signal   mr_req_addr        : std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
        signal   mr_req_size        : std_logic_vector(MR_SIZE_BITS  -1 downto 0);
        signal   mr_req_ptr         : std_logic_vector(MR_BUF_SIZE   -1 downto 0);
        signal   mr_req_first       : std_logic;
        signal   mr_req_last        : std_logic;
        signal   mr_req_valid       : std_logic_vector(1 downto 0);
        signal   mr_req_ready       : std_logic;
        signal   mr_xfer_busy       : std_logic_vector(1 downto 0);
        signal   mr_xfer_done       : std_logic_vector(1 downto 0);
        signal   mr_xfer_error      : std_logic_vector(1 downto 0);
        signal   mr_ack_valid       : std_logic_vector(1 downto 0);
        signal   mr_ack_error       : std_logic;
        signal   mr_ack_next        : std_logic;
        signal   mr_ack_last        : std_logic;
        signal   mr_ack_stop        : std_logic;
        signal   mr_ack_none        : std_logic;
        signal   mr_ack_size        : std_logic_vector(MR_SIZE_BITS  -1 downto 0);
        constant mr_flow_pause      : std_logic := '0';
        constant mr_flow_stop       : std_logic := '0';
        constant mr_flow_last       : std_logic := '0';
        constant mr_flow_size       : std_logic_vector(MR_SIZE_BITS  -1 downto 0) := (others => '1');
        signal   mr_buf_wen         : std_logic_vector(1 downto 0);
        signal   mr_buf_ben         : std_logic_vector(2**(MR_BUF_WIDTH-3)-1 downto 0);
        signal   mr_buf_wdata       : std_logic_vector(2**(MR_BUF_WIDTH  )-1 downto 0);
        signal   mr_buf_wptr        : std_logic_vector(MR_BUF_SIZE   -1 downto 0);
        signal   mr_buf_wready      : std_logic_vector(1 downto 0);
        ---------------------------------------------------------------------------
        -- 定数
        ---------------------------------------------------------------------------
        constant MW_BUF_SIZE        : integer := 4;
        constant MW_BUF_WIDTH       : integer := 5;
        constant MW_SIZE_BITS       : integer := MR_BUF_SIZE+1;
        constant MW_QUEUE_SIZE      : integer := 1;
        constant MW_REQ_REGS        : integer := 1;
        constant MW_ACK_REGS        : integer := 1;
        constant MW_RESP_REGS       : integer := 1;
        constant MW_MAX_XFER_SIZE   : integer := 4;
        constant MW_ID              : std_logic_vector(M_ID_WIDTH -1 downto 0) := 
                                      std_logic_vector(to_unsigned(M_AXI_ID, M_ID_WIDTH));
        constant MW_SPECULATIVE     : std_logic := '0';
        constant MW_SAFETY          : std_logic := '1';
        constant MW_XFER_SIZE_SEL   : std_logic_vector(MW_MAX_XFER_SIZE downto MW_MAX_XFER_SIZE) := std_logic_vector'("1");
        constant MW_LOCK            : AXI4_ALOCK_TYPE  := (others => '0');
        constant MW_PROT            : AXI4_APROT_TYPE  := (others => '0');
        constant MW_QOS             : AXI4_AQOS_TYPE   := (others => '0');
        constant MW_REGION          : AXI4_AREGION_TYPE:= (others => '0');
        constant MW_CACHE           : AXI4_ACACHE_TYPE := (others => '0');
        constant MW_AUSER           : std_logic_vector(M_AUSER_WIDTH -1 downto 0) := (others => '0');
        constant mw_req_addr        : std_logic_vector(M_ADDR_WIDTH  -1 downto 0) := (others => '0');
        constant mw_req_size        : std_logic_vector(MW_SIZE_BITS  -1 downto 0) := (others => '0');
        constant mw_req_ptr         : std_logic_vector(MW_BUF_SIZE   -1 downto 0) := (others => '0');
        constant mw_req_first       : std_logic := '0';
        constant mw_req_last        : std_logic := '0';
        constant mw_req_valid       : std_logic_vector(1 downto 0) := (others => '0');
        signal   mw_req_ready       : std_logic;
        signal   mw_xfer_busy       : std_logic_vector(1 downto 0);
        signal   mw_xfer_done       : std_logic_vector(1 downto 0);
        signal   mw_xfer_error      : std_logic_vector(1 downto 0);
        signal   mw_ack_valid       : std_logic_vector(1 downto 0);
        signal   mw_ack_error       : std_logic;
        signal   mw_ack_next        : std_logic;
        signal   mw_ack_last        : std_logic;
        signal   mw_ack_stop        : std_logic;
        signal   mw_ack_none        : std_logic;
        signal   mw_ack_size        : std_logic_vector(MW_SIZE_BITS  -1 downto 0);
        constant mw_flow_pause      : std_logic := '0';
        constant mw_flow_stop       : std_logic := '0';
        constant mw_flow_last       : std_logic := '0';
        constant mw_flow_size       : std_logic_vector(MW_SIZE_BITS  -1 downto 0) := (others => '0');
        constant mw_buf_rdata       : std_logic_vector(2**(MW_BUF_WIDTH)-1 downto 0) := (others => '0');
        signal   mw_buf_rptr        : std_logic_vector(MW_BUF_SIZE   -1 downto 0);
        constant mw_buf_rready      : std_logic_vector(1 downto 0) := std_logic_vector'("00");
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        signal   po_req_addr        : std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
        signal   po_req_size        : std_logic_vector(MR_SIZE_BITS  -1 downto 0);
        signal   po_req_ptr         : std_logic_vector(MR_BUF_SIZE   -1 downto 0);
        signal   po_req_first       : std_logic;
        signal   po_req_last        : std_logic;
        signal   po_req_valid       : std_logic;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        signal   pi_req_addr        : std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
        signal   pi_req_size        : std_logic_vector(MR_SIZE_BITS  -1 downto 0);
        signal   pi_req_ptr         : std_logic_vector(MR_BUF_SIZE   -1 downto 0);
        signal   pi_req_first       : std_logic;
        signal   pi_req_last        : std_logic;
        signal   pi_req_valid       : std_logic;
        signal   pi_mode_end        : std_logic;
        signal   pi_stat_end        : std_logic;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        MR_IF: AXI4_MASTER_READ_INTERFACE
            generic map (
                AXI4_ADDR_WIDTH => M_ADDR_WIDTH      , -- 
                AXI4_DATA_WIDTH => M_DATA_WIDTH      , -- 
                AXI4_ID_WIDTH   => M_ID_WIDTH        , -- 
                VAL_BITS        => 2                 , -- 
                REQ_SIZE_BITS   => MR_SIZE_BITS      , -- 
                REQ_SIZE_VALID  => 1                 , -- 
                FLOW_VALID      => 0                 , -- 
                BUF_DATA_WIDTH  => 2**MR_BUF_WIDTH   , -- 
                BUF_PTR_BITS    => MR_BUF_SIZE       , -- 
                XFER_SIZE_BITS  => MR_SIZE_BITS      , -- 
                XFER_MIN_SIZE   => MR_MAX_XFER_SIZE  , -- 
                XFER_MAX_SIZE   => MR_MAX_XFER_SIZE  , -- 
                QUEUE_SIZE      => MR_QUEUE_SIZE     , -- 
                RDATA_REGS      => MR_RDATA_REGS     , --
                ACK_REGS        => MR_ACK_REGS         -- 
            )
            port map (
            -----------------------------------------------------------------------
            -- Clock and Reset Signals.
            -----------------------------------------------------------------------
                CLK             => M_CLK             , -- In  :
                RST             => RST               , -- In  :
                CLR             => CLR               , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Read Address Channel Signals.
            -----------------------------------------------------------------------
                ARID            => M_ARID            , -- Out :
                ARADDR          => M_ARADDR          , -- Out :
                ARLEN           => M_ARLEN           , -- Out :
                ARSIZE          => M_ARSIZE          , -- Out :
                ARBURST         => M_ARBURST         , -- Out :
                ARLOCK          => M_ARLOCK          , -- Out :
                ARCACHE         => M_ARCACHE         , -- Out :
                ARPROT          => M_ARPROT          , -- Out :
                ARQOS           => M_ARQOS           , -- Out :
                ARREGION        => M_ARREGION        , -- Out :
                ARVALID         => M_ARVALID         , -- Out :
                ARREADY         => M_ARREADY         , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Read Data Channel Signals.
            -----------------------------------------------------------------------
                RID             => M_RID             , -- In  :
                RDATA           => M_RDATA           , -- In  :
                RRESP           => M_RRESP           , -- In  :
                RLAST           => M_RLAST           , -- In  :
                RVALID          => M_RVALID          , -- In  :
                RREADY          => M_RREADY          , -- Out :
            -----------------------------------------------------------------------
            -- Command Request Signals.
            -----------------------------------------------------------------------
                REQ_ADDR        => mr_req_addr       , -- In  :
                REQ_SIZE        => mr_req_size       , -- In  :
                REQ_ID          => MR_ID             , -- In  :
                REQ_BURST       => AXI4_ABURST_INCR  , -- In  :
                REQ_LOCK        => MR_LOCK           , -- In  :
                REQ_CACHE       => mr_cache          , -- In  :
                REQ_PROT        => MR_PROT           , -- In  :
                REQ_QOS         => MR_QOS            , -- In  :
                REQ_REGION      => MR_REGION         , -- In  :
                REQ_BUF_PTR     => mr_req_ptr        , -- In  :
                REQ_FIRST       => mr_req_first      , -- In  :
                REQ_LAST        => mr_req_last       , -- In  :
                REQ_SPECULATIVE => MR_SPECULATIVE    , -- In  :
                REQ_SAFETY      => MR_SAFETY         , -- In  :
                REQ_VAL         => mr_req_valid      , -- In  :
                REQ_RDY         => mr_req_ready      , -- Out :
                XFER_SIZE_SEL   => MR_XFER_SIZE_SEL  , -- In  :
                XFER_BUSY       => mr_xfer_busy      , -- Out :
                XFER_DONE       => mr_xfer_done      , -- Out :
                XFER_ERROR      => mr_xfer_error     , -- Out :
            -----------------------------------------------------------------------
            -- Response Signals.
            -----------------------------------------------------------------------
                ACK_VAL         => mr_ack_valid      , -- Out :
                ACK_ERROR       => mr_ack_error      , -- Out :
                ACK_NEXT        => mr_ack_next       , -- Out :
                ACK_LAST        => mr_ack_last       , -- Out :
                ACK_STOP        => mr_ack_stop       , -- Out :
                ACK_NONE        => mr_ack_none       , -- Out :
                ACK_SIZE        => mr_ack_size       , -- Out :
            -----------------------------------------------------------------------
            -- Flow Control Signals.
            -----------------------------------------------------------------------
                FLOW_PAUSE      => mr_flow_pause     , -- In  : 未使用
                FLOW_STOP       => mr_flow_stop      , -- In  : 未使用
                FLOW_LAST       => mr_flow_last      , -- In  : 未使用
                FLOW_SIZE       => mr_flow_size      , -- In  : 未使用
            -----------------------------------------------------------------------
            -- Push Reserve Size Signals.
            -----------------------------------------------------------------------
                PUSH_RSV_VAL    => open              , -- Out :
                PUSH_RSV_SIZE   => open              , -- Out :
                PUSH_RSV_LAST   => open              , -- Out :
                PUSH_RSV_ERROR  => open              , -- Out :
            -----------------------------------------------------------------------
            -- Push Final Size Signals.
            -----------------------------------------------------------------------
                PUSH_FIN_VAL    => open              , -- Out :
                PUSH_FIN_SIZE   => open              , -- Out :
                PUSH_FIN_LAST   => open              , -- Out :
                PUSH_FIN_ERROR  => open              , -- Out :
            -----------------------------------------------------------------------
            -- Push Buffer Signals.
            -----------------------------------------------------------------------
                PUSH_BUF_RESET  => open              , -- Out :
                PUSH_BUF_VAL    => open              , -- Out :
                PUSH_BUF_SIZE   => open              , -- Out :
                PUSH_BUF_LAST   => open              , -- Out :
                PUSH_BUF_ERROR  => open              , -- Out :
                PUSH_BUF_RDY    => mr_buf_wready     , -- In  :
            -----------------------------------------------------------------------
            -- Read Buffer Interface Signals.
            -----------------------------------------------------------------------
                BUF_WEN         => mr_buf_wen        , -- Out :
                BUF_BEN         => mr_buf_ben        , -- Out :
                BUF_DATA        => mr_buf_wdata      , -- Out :
                BUF_PTR         => mr_buf_wptr         -- Out :
            );
        M_ARUSER <= resize(mr_auser, M_ARUSER'length);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        MW_IF: AXI4_MASTER_WRITE_INTERFACE
            generic map (
                AXI4_ADDR_WIDTH => M_ADDR_WIDTH      , --
                AXI4_DATA_WIDTH => M_DATA_WIDTH      , -- 
                AXI4_ID_WIDTH   => M_ID_WIDTH        , -- 
                VAL_BITS        => 2                 , -- 
                REQ_SIZE_BITS   => MW_SIZE_BITS      , -- 
                REQ_SIZE_VALID  => 1                 , -- 
                FLOW_VALID      => 0                 , -- 
                BUF_DATA_WIDTH  => 2**MW_BUF_WIDTH   , -- 
                BUF_PTR_BITS    => MW_BUF_SIZE       , -- 
                XFER_SIZE_BITS  => MW_SIZE_BITS      , -- 
                XFER_MIN_SIZE   => MW_MAX_XFER_SIZE  , -- 
                XFER_MAX_SIZE   => MW_MAX_XFER_SIZE  , -- 
                REQ_REGS        => MW_REQ_REGS       , -- 
                ACK_REGS        => MW_ACK_REGS       , -- 
                QUEUE_SIZE      => MW_QUEUE_SIZE     , -- 
                RESP_REGS       => MW_RESP_REGS        -- 
            )
            port map (
            -----------------------------------------------------------------------
            -- Clock and Reset Signals.
            -----------------------------------------------------------------------
                CLK             => M_CLK             , -- In  :
                RST             => RST               , -- In  :
                CLR             => CLR               , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Write Address Channel Signals.
            -----------------------------------------------------------------------
                AWID            => M_AWID            , -- Out :
                AWADDR          => M_AWADDR          , -- Out :
                AWLEN           => M_AWLEN           , -- Out :
                AWSIZE          => M_AWSIZE          , -- Out :
                AWBURST         => M_AWBURST         , -- Out :
                AWLOCK          => M_AWLOCK          , -- Out :
                AWCACHE         => M_AWCACHE         , -- Out :
                AWPROT          => M_AWPROT          , -- Out :
                AWQOS           => M_AWQOS           , -- Out :
                AWREGION        => M_AWREGION        , -- Out :
                AWVALID         => M_AWVALID         , -- Out :
                AWREADY         => M_AWREADY         , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Write Data Channel Signals.
            -----------------------------------------------------------------------
                WID             => open              , -- Out :
                WDATA           => M_WDATA           , -- Out :
                WSTRB           => M_WSTRB           , -- Out :
                WLAST           => M_WLAST           , -- Out :
                WVALID          => M_WVALID          , -- Out :
                WREADY          => M_WREADY          , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Write Response Channel Signals.
            -----------------------------------------------------------------------
                BID             => M_BID             , -- In  :
                BRESP           => M_BRESP           , -- In  :
                BVALID          => M_BVALID          , -- In  :
                BREADY          => M_BREADY          , -- Out :
            -----------------------------------------------------------------------
            -- Command Request Signals.
            -----------------------------------------------------------------------
                REQ_ADDR        => mw_req_addr       , -- In  :
                REQ_SIZE        => mw_req_size       , -- In  :
                REQ_ID          => MW_ID             , -- In  :
                REQ_BURST       => AXI4_ABURST_INCR  , -- In  :
                REQ_LOCK        => MW_LOCK           , -- In  :
                REQ_CACHE       => MW_CACHE          , -- In  :
                REQ_PROT        => MW_PROT           , -- In  :
                REQ_QOS         => MW_QOS            , -- In  :
                REQ_REGION      => MW_REGION         , -- In  :
                REQ_BUF_PTR     => mw_req_ptr        , -- In  :
                REQ_FIRST       => mw_req_first      , -- In  :
                REQ_LAST        => mw_req_last       , -- In  :
                REQ_SPECULATIVE => MW_SPECULATIVE    , -- In  :
                REQ_SAFETY      => MW_SAFETY         , -- In  :
                REQ_VAL         => mw_req_valid      , -- In  :
                REQ_RDY         => mw_req_ready      , -- Out :
                XFER_SIZE_SEL   => MW_XFER_SIZE_SEL  , -- In  :
                XFER_BUSY       => mw_xfer_busy      , -- Out :
                XFER_DONE       => mw_xfer_done      , -- Out :
                XFER_ERROR      => mw_xfer_error     , -- Out :
            -----------------------------------------------------------------------
            -- Response Signals.
            -----------------------------------------------------------------------
                ACK_VAL         => mw_ack_valid      , -- Out :
                ACK_ERROR       => mw_ack_error      , -- Out :
                ACK_NEXT        => mw_ack_next       , -- Out :
                ACK_LAST        => mw_ack_last       , -- Out :
                ACK_STOP        => mw_ack_stop       , -- Out :
                ACK_NONE        => mw_ack_none       , -- Out :
                ACK_SIZE        => mw_ack_size       , -- Out :
            -----------------------------------------------------------------------
            -- Flow Control Signals.
            -----------------------------------------------------------------------
                FLOW_PAUSE      => mw_flow_pause     , -- In  : 未使用
                FLOW_STOP       => mw_flow_stop      , -- In  : 未使用
                FLOW_LAST       => mw_flow_last      , -- In  : 未使用
                FLOW_SIZE       => mw_flow_size      , -- In  : 未使用
            -----------------------------------------------------------------------
            -- Pull Reserve Size Signals.
            -----------------------------------------------------------------------
                PULL_RSV_VAL    => open              , -- Out :
                PULL_RSV_SIZE   => open              , -- Out :
                PULL_RSV_LAST   => open              , -- Out :
                PULL_RSV_ERROR  => open              , -- Out :
            -----------------------------------------------------------------------
            -- Pull Final Size Signals.
            -----------------------------------------------------------------------
                PULL_FIN_VAL    => open              , -- Out :
                PULL_FIN_SIZE   => open              , -- Out :
                PULL_FIN_LAST   => open              , -- Out :
                PULL_FIN_ERROR  => open              , -- Out :
            -----------------------------------------------------------------------
            -- Pull Buffer Size Signals.
            -----------------------------------------------------------------------
                PULL_BUF_RESET  => open              , -- Out :
                PULL_BUF_VAL    => open              , -- Out :
                PULL_BUF_SIZE   => open              , -- Out :
                PULL_BUF_LAST   => open              , -- Out :
                PULL_BUF_ERROR  => open              , -- Out :
                PULL_BUF_RDY    => mw_buf_rready     , -- In  :
            -----------------------------------------------------------------------
            -- Read Buffer Interface Signals.
            -----------------------------------------------------------------------
                BUF_REN         => open              , -- Out :
                BUF_DATA        => mw_buf_rdata      , -- In  :
                BUF_PTR         => mw_buf_rptr         -- Out :
            );
        M_AWUSER <= MW_AUSER;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        M_ARB : if (O_PROC_VALID /= 0 and I_PROC_VALID /= 0) generate
            constant ENABLE  : std_logic := '1';
            signal   num     : integer range 0 to 1;
            signal   request : std_logic_vector(0 to 1);
            signal   grant   : std_logic_vector(0 to 1);
            signal   valid   : std_logic;
            signal   shift   : std_logic;
            constant ALL0    : std_logic_vector(0 to 1) := (others => '0');
        begin
            QUEUE: QUEUE_ARBITER 
                generic map (
                    MIN_NUM     => 0            ,  -- 
                    MAX_NUM     => 1               -- 
                )                                  --
                port map (                         -- 
                    CLK         => M_CLK        ,  -- In  :
                    RST         => RST          ,  -- In  :
                    CLR         => CLR          ,  -- In  :
                    ENABLE      => ENABLE       ,  -- In  :
                    REQUEST     => request      ,  -- In  :
                    GRANT       => grant        ,  -- Out :
                    GRANT_NUM   => num          ,  -- Out :
                    REQUEST_O   => open         ,  -- Out :
                    VALID       => valid        ,  -- Out :
                    SHIFT       => shift           -- In  :
                );
            request(0)      <= po_req_valid;
            mr_req_valid(0) <= grant(0) and po_req_valid;
            request(1)      <= pi_req_valid;
            mr_req_valid(1) <= grant(1) and pi_req_valid;
            mr_req_addr     <= pi_req_addr  when (num = 1) else po_req_addr;
            mr_req_size     <= pi_req_size  when (num = 1) else po_req_size;
            mr_req_ptr      <= pi_req_ptr   when (num = 1) else po_req_ptr;
            mr_req_first    <= pi_req_first when (num = 1) else po_req_first;
            mr_req_last     <= pi_req_first when (num = 1) else po_req_last;
            mr_cache        <= regs_rbit(PI_MODE_CACHE_HI downto PI_MODE_CACHE_LO) when (num = 1) else
                               regs_rbit(PO_MODE_CACHE_HI downto PO_MODE_CACHE_LO);
            process (M_CLK, RST) begin
                if (RST = '1') then
                        mr_auser <= (others => '0');
                elsif (M_CLK'event and M_CLK = '1') then
                    if (CLR = '1') then
                        mr_auser <= (others => '0');
                    elsif (mr_req_ready = '1' and mr_req_valid(0) = '1') then
                        mr_auser <= regs_rbit(PO_MODE_AUSER_HI downto PO_MODE_AUSER_LO);
                    elsif (mr_req_ready = '1' and mr_req_valid(1) = '1') then
                        mr_auser <= regs_rbit(PI_MODE_AUSER_HI downto PI_MODE_AUSER_LO);
                    end if;
                end if;
            end process;
            shift <= '1' when (mr_ack_valid /= ALL0) else '0';
        end generate;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        O_SEL : if (O_PROC_VALID /= 0 and I_PROC_VALID = 0) generate
            mr_req_valid(0) <= po_req_valid;
            mr_req_valid(1) <= '0';
            mr_req_addr     <= po_req_addr;
            mr_req_size     <= po_req_size;
            mr_req_ptr      <= po_req_ptr;
            mr_req_first    <= po_req_first;
            mr_req_last     <= po_req_last;
            mr_buf_wready(1)<= '0';
            mr_cache        <= regs_rbit(PO_MODE_CACHE_HI downto PO_MODE_CACHE_LO);
            mr_auser        <= regs_rbit(PO_MODE_AUSER_HI downto PO_MODE_AUSER_LO);
        end generate;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        I_SEL : if (O_PROC_VALID = 0 and I_PROC_VALID /= 0) generate
            mr_req_valid(0) <= '0';
            mr_req_valid(1) <= pi_req_valid;
            mr_req_addr     <= pi_req_addr;
            mr_req_size     <= pi_req_size;
            mr_req_ptr      <= pi_req_ptr;
            mr_req_first    <= pi_req_first;
            mr_req_last     <= pi_req_last;
            mr_buf_wready(0)<= '0';
            mr_cache        <= regs_rbit(PI_MODE_CACHE_HI downto PI_MODE_CACHE_LO);
            mr_auser        <= regs_rbit(PI_MODE_AUSER_HI downto PI_MODE_AUSER_LO);
        end generate;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        O_PROC: if (O_PROC_VALID /= 0) generate
            signal   xfer_load      : std_logic_vector(CO_REGS_HI downto CO_REGS_LO);
            signal   xfer_wbit      : std_logic_vector(CO_REGS_HI downto CO_REGS_LO);
            signal   proc_o_c_load  : std_logic_vector(PO_CPRO_HI downto PO_CPRO_LO);
            signal   proc_o_c_data  : std_logic_vector(PO_CPRO_HI downto PO_CPRO_LO);
            signal   proc_o_c_req   : std_logic;
            signal   proc_o_stat    : std_logic_vector(7 downto 0);
            signal   proc_o_busy    : std_logic;
            signal   proc_o_done    : std_logic;
            signal   proc_o_fetch   : std_logic;
            signal   proc_o_error   : std_logic_vector(2 downto 0);
            signal   proc_o_mode    : boolean;
        begin
            PROC: PUMP_OPERATION_PROCESSOR
                generic map (
                    M_ADDR_BITS     => M_ADDR_WIDTH      , -- 
                    M_BUF_SIZE      => MR_BUF_SIZE       , -- 
                    M_BUF_WIDTH     => MR_BUF_WIDTH      , -- 
                    OP_BITS         => PO_BITS           , -- 
                    OP_XFER_LO      => PO_CORE_LO        , -- 
                    OP_XFER_HI      => PO_CORE_HI        , -- 
                    OP_CPRO_LO      => PO_CPRO_LO        , --
                    OP_CPRO_HI      => PO_CPRO_HI        , --
                    OP_ADDR_LO      => PO_ADDR_LO        , -- 
                    OP_ADDR_HI      => PO_ADDR_HI        , -- 
                    OP_MODE_LO      => PO_MODE_LO        , -- 
                    OP_MODE_HI      => PO_MODE_HI        , -- 
                    OP_STAT_LO      => PO_STAT_LO        , -- 
                    OP_STAT_HI      => PO_STAT_HI        , --
                    OP_FETCH_POS    => PO_FETCH_POS      , --
                    OP_END_POS      => PO_END_POS        , --
                    OP_TYPE_LO      => PO_TYPE_LO        , --
                    OP_TYPE_HI      => PO_TYPE_HI        , --
                    OP_NONE_CODE    => PO_NONE_CODE      , --
                    OP_CPRO_CODE    => PO_CPRO_CODE      , --
                    OP_XFER_CODE    => PO_XFER_CODE      , --
                    OP_LINK_CODE    => PO_LINK_CODE        -- 
                )
                port map (
                -------------------------------------------------------------------
                -- Clock & Reset Signals.
                -------------------------------------------------------------------
                    CLK             => C_CLK             , -- In  :
                    RST             => RST               , -- In  :
                    CLR             => CLR               , -- In  :
                -------------------------------------------------------------------
                -- Transfer Request Block Read Signals.
                -------------------------------------------------------------------
                    M_REQ_VALID     => po_req_valid      , -- Out :
                    M_REQ_ADDR      => po_req_addr       , -- Out :
                    M_REQ_SIZE      => po_req_size       , -- Out :
                    M_REQ_PTR       => po_req_ptr        , -- Out :
                    M_REQ_FIRST     => po_req_first      , -- Out :
                    M_REQ_LAST      => po_req_last       , -- Out :
                    M_REQ_READY     => mr_req_ready      , -- In  :
                    M_ACK_VALID     => mr_ack_valid(0)   , -- In  :
                    M_ACK_ERROR     => mr_ack_error      , -- In  :
                    M_ACK_NEXT      => mr_ack_next       , -- In  :
                    M_ACK_LAST      => mr_ack_last       , -- In  :
                    M_ACK_STOP      => mr_ack_stop       , -- In  :
                    M_ACK_NONE      => mr_ack_none       , -- In  :
                    M_ACK_SIZE      => mr_ack_size       , -- In  :
                    M_BUF_WE        => mr_buf_wen(0)     , -- In  :
                    M_BUF_BEN       => mr_buf_ben        , -- In  :
                    M_BUF_DATA      => mr_buf_wdata      , -- In  :
                    M_BUF_PTR       => mr_buf_wptr       , -- In  :
                    M_BUF_RDY       => mr_buf_wready(0)  , -- Out :
                    M_XFER_BUSY     => mr_xfer_busy(0)   , -- In  :
                    M_XFER_DONE     => mr_xfer_done(0)   , -- In  :
                    M_XFER_ERROR    => mr_xfer_error(0)  , -- In  :
                -------------------------------------------------------------------
                -- Control Status Register Interface Signals.
                -------------------------------------------------------------------
                    T_ADDR_L        => regs_load(PO_ADDR_REGS_HI downto PO_ADDR_REGS_LO),
                    T_ADDR_D        => regs_wbit(PO_ADDR_REGS_HI downto PO_ADDR_REGS_LO),
                    T_ADDR_Q        => regs_rbit(PO_ADDR_REGS_HI downto PO_ADDR_REGS_LO),
                    T_MODE_L        => regs_load(PO_MODE_REGS_HI downto PO_MODE_REGS_LO),
                    T_MODE_D        => regs_wbit(PO_MODE_REGS_HI downto PO_MODE_REGS_LO),
                    T_MODE_Q        => regs_rbit(PO_MODE_REGS_HI downto PO_MODE_REGS_LO),
                    T_STAT_L        => regs_load(PO_STAT_REGS_HI downto PO_STAT_REGS_LO),
                    T_STAT_D        => regs_wbit(PO_STAT_REGS_HI downto PO_STAT_REGS_LO),
                    T_STAT_Q        => regs_rbit(PO_STAT_REGS_HI downto PO_STAT_REGS_LO),
                    T_STAT_I        => proc_o_stat                 ,
                    T_RESET_L       => regs_load(PO_CTRL_RESET_POS),
                    T_RESET_D       => regs_wbit(PO_CTRL_RESET_POS),
                    T_RESET_Q       => regs_rbit(PO_CTRL_RESET_POS),
                    T_START_L       => regs_load(PO_CTRL_START_POS),
                    T_START_D       => regs_wbit(PO_CTRL_START_POS),
                    T_START_Q       => regs_rbit(PO_CTRL_START_POS),
                    T_STOP_L        => regs_load(PO_CTRL_STOP_POS ),
                    T_STOP_D        => regs_wbit(PO_CTRL_STOP_POS ),
                    T_STOP_Q        => regs_rbit(PO_CTRL_STOP_POS ),
                    T_PAUSE_L       => regs_load(PO_CTRL_PAUSE_POS),
                    T_PAUSE_D       => regs_wbit(PO_CTRL_PAUSE_POS),
                    T_PAUSE_Q       => regs_rbit(PO_CTRL_PAUSE_POS),
                    T_BUSY          => proc_o_busy                 ,
                    T_DONE          => proc_o_done                 ,
                    T_FETCH         => proc_o_fetch                ,
                    T_ERROR         => proc_o_error                ,
                -------------------------------------------------------------------
                -- Co-Processer Interface Signals.
                -------------------------------------------------------------------
                    C_OPERAND_L     => proc_o_c_load               ,
                    C_OPERAND_D     => proc_o_c_data               ,
                    C_REQ           => proc_o_c_req                ,
                    C_ACK           => '1'                         ,
                -------------------------------------------------------------------
                -- Pump Control Register Interface Signals.
                -------------------------------------------------------------------
                    X_RESET_L       => xfer_load(CO_CTRL_RESET_POS),
                    X_RESET_D       => xfer_wbit(CO_CTRL_RESET_POS),
                    X_RESET_Q       => regs_rbit(CO_CTRL_RESET_POS),
                    X_START_L       => xfer_load(CO_CTRL_START_POS),
                    X_START_D       => xfer_wbit(CO_CTRL_START_POS),
                    X_START_Q       => regs_rbit(CO_CTRL_START_POS),
                    X_STOP_L        => xfer_load(CO_CTRL_STOP_POS ),
                    X_STOP_D        => xfer_wbit(CO_CTRL_STOP_POS ),
                    X_STOP_Q        => regs_rbit(CO_CTRL_STOP_POS ),
                    X_PAUSE_L       => xfer_load(CO_CTRL_PAUSE_POS),
                    X_PAUSE_D       => xfer_wbit(CO_CTRL_PAUSE_POS),
                    X_PAUSE_Q       => regs_rbit(CO_CTRL_PAUSE_POS),
                    X_OPERAND_L     => xfer_load(CO_OPERAND_HI downto CO_OPERAND_LO),
                    X_OPERAND_D     => xfer_wbit(CO_OPERAND_HI downto CO_OPERAND_LO),
                    X_OPERAND_Q     => regs_rbit(CO_OPERAND_HI downto CO_OPERAND_LO),
                    X_RUN           => core_o_run                  ,
                    X_DONE          => core_o_done                 ,
                    X_ERROR         => core_o_error       
                );
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            regs_rbit(PO_CTRL_RESV_HI downto PO_CTRL_RESV_LO) <= (others => '0');
            proc_o_stat(0)          <= proc_o_done;
            proc_o_stat(1)          <= proc_o_fetch;
            proc_o_stat(4 downto 2) <= proc_o_error(2 downto 0);
            proc_o_stat(7 downto 5) <= (7 downto 5 => '0');
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            proc_o_mode <= (regs_rbit(PO_CTRL_START_POS) = '1');
            process (regs_load, regs_wbit, xfer_load, xfer_wbit, proc_o_mode) begin
                if (proc_o_mode) then
                    pump_load(CO_CTRL_RESET_POS) <= xfer_load(CO_CTRL_RESET_POS);
                    pump_wbit(CO_CTRL_RESET_POS) <= xfer_wbit(CO_CTRL_RESET_POS);
                    pump_load(CO_CTRL_START_POS) <= xfer_load(CO_CTRL_START_POS);
                    pump_wbit(CO_CTRL_START_POS) <= xfer_wbit(CO_CTRL_START_POS);
                    pump_load(CO_CTRL_STOP_POS ) <= xfer_load(CO_CTRL_STOP_POS );
                    pump_wbit(CO_CTRL_STOP_POS ) <= xfer_wbit(CO_CTRL_STOP_POS );
                    pump_load(CO_CTRL_PAUSE_POS) <= xfer_load(CO_CTRL_PAUSE_POS);
                    pump_wbit(CO_CTRL_PAUSE_POS) <= xfer_wbit(CO_CTRL_PAUSE_POS);
                    pump_load(CO_OPERAND_HI downto CO_OPERAND_LO) <= xfer_load(CO_OPERAND_HI downto CO_OPERAND_LO);
                    pump_wbit(CO_OPERAND_HI downto CO_OPERAND_LO) <= xfer_wbit(CO_OPERAND_HI downto CO_OPERAND_LO);
                else
                    pump_load(CO_CTRL_RESET_POS) <= regs_load(CO_CTRL_RESET_POS);
                    pump_wbit(CO_CTRL_RESET_POS) <= regs_wbit(CO_CTRL_RESET_POS);
                    pump_load(CO_CTRL_START_POS) <= regs_load(CO_CTRL_START_POS);
                    pump_wbit(CO_CTRL_START_POS) <= regs_wbit(CO_CTRL_START_POS);
                    pump_load(CO_CTRL_STOP_POS ) <= regs_load(CO_CTRL_STOP_POS );
                    pump_wbit(CO_CTRL_STOP_POS ) <= regs_wbit(CO_CTRL_STOP_POS );
                    pump_load(CO_CTRL_PAUSE_POS) <= regs_load(CO_CTRL_PAUSE_POS);
                    pump_wbit(CO_CTRL_PAUSE_POS) <= regs_wbit(CO_CTRL_PAUSE_POS);
                    pump_load(CO_CTRL_RESV_POS ) <= regs_load(CO_CTRL_RESV_POS );
                    pump_wbit(CO_CTRL_RESV_POS ) <= regs_wbit(CO_CTRL_RESV_POS );
                    pump_load(CO_CTRL_DONE_POS ) <= regs_load(CO_CTRL_DONE_POS );
                    pump_wbit(CO_CTRL_DONE_POS ) <= regs_wbit(CO_CTRL_DONE_POS );
                    pump_load(CO_OPERAND_HI downto CO_OPERAND_LO) <= regs_load(CO_OPERAND_HI downto CO_OPERAND_LO);
                    pump_wbit(CO_OPERAND_HI downto CO_OPERAND_LO) <= regs_wbit(CO_OPERAND_HI downto CO_OPERAND_LO);
                end if;
            end process;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            process (C_CLK, RST) begin
                if (RST = '1') then
                        o_interrupt <= '0';
                elsif (C_CLK'event and C_CLK = '1') then
                    if (regs_rbit(CO_MODE_DONE_POS ) = '1' and regs_rbit(CO_STAT_DONE_POS ) = '1') or
                       (regs_rbit(PO_MODE_END_POS  ) = '1' and regs_rbit(PO_STAT_END_POS  ) = '1') or
                       (regs_rbit(PO_MODE_FETCH_POS) = '1' and regs_rbit(PO_STAT_FETCH_POS) = '1') then
                        o_interrupt <= '1';
                    else
                        o_interrupt <= '0';
                    end if;
                end if;
            end process;
        end generate;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        I_PROC: if (I_PROC_VALID /= 0) generate
            signal   xfer_load      : std_logic_vector(CI_REGS_HI downto CI_REGS_LO);
            signal   xfer_wbit      : std_logic_vector(CI_REGS_HI downto CI_REGS_LO);
            signal   proc_i_c_load  : std_logic_vector(PI_CPRO_HI downto PI_CPRO_LO);
            signal   proc_i_c_data  : std_logic_vector(PI_CPRO_HI downto PI_CPRO_LO);
            signal   proc_i_c_req   : std_logic;
            signal   proc_i_stat    : std_logic_vector(7 downto 0);
            signal   proc_i_busy    : std_logic;
            signal   proc_i_done    : std_logic;
            signal   proc_i_fetch   : std_logic;
            signal   proc_i_error   : std_logic_vector(2 downto 0);
            signal   proc_i_mode    : boolean;
        begin
            PROC: PUMP_OPERATION_PROCESSOR
                generic map (
                    M_ADDR_BITS     => M_ADDR_WIDTH      , -- 
                    M_BUF_SIZE      => MR_BUF_SIZE       , -- 
                    M_BUF_WIDTH     => MR_BUF_WIDTH      , -- 
                    OP_BITS         => PI_BITS           , -- 
                    OP_XFER_LO      => PI_CORE_LO        , -- 
                    OP_XFER_HI      => PI_CORE_HI        , -- 
                    OP_CPRO_LO      => PI_CPRO_LO        , --
                    OP_CPRO_HI      => PI_CPRO_HI        , --
                    OP_ADDR_LO      => PI_ADDR_LO        , -- 
                    OP_ADDR_HI      => PI_ADDR_HI        , -- 
                    OP_MODE_LO      => PI_MODE_LO        , -- 
                    OP_MODE_HI      => PI_MODE_HI        , -- 
                    OP_STAT_LO      => PI_STAT_LO        , -- 
                    OP_STAT_HI      => PI_STAT_HI        , --
                    OP_FETCH_POS    => PI_FETCH_POS      , --
                    OP_END_POS      => PI_END_POS        , --
                    OP_TYPE_LO      => PI_TYPE_LO        , --
                    OP_TYPE_HI      => PI_TYPE_HI        , --
                    OP_NONE_CODE    => PI_NONE_CODE      , --
                    OP_CPRO_CODE    => PI_CPRO_CODE      , --
                    OP_XFER_CODE    => PI_XFER_CODE      , --
                    OP_LINK_CODE    => PI_LINK_CODE        -- 
                )
                port map (
                -------------------------------------------------------------------
                -- Clock & Reset Signals.
                -------------------------------------------------------------------
                    CLK             => C_CLK             , -- In  :
                    RST             => RST               , -- In  :
                    CLR             => CLR               , -- In  :
                -------------------------------------------------------------------
                -- Transfer Request Block Read Signals.
                -------------------------------------------------------------------
                    M_REQ_VALID     => pi_req_valid      , -- Out :
                    M_REQ_ADDR      => pi_req_addr       , -- Out :
                    M_REQ_SIZE      => pi_req_size       , -- Out :
                    M_REQ_PTR       => pi_req_ptr        , -- Out :
                    M_REQ_FIRST     => pi_req_first      , -- Out :
                    M_REQ_LAST      => pi_req_last       , -- Out :
                    M_REQ_READY     => mr_req_ready      , -- In  :
                    M_ACK_VALID     => mr_ack_valid(1)   , -- In  :
                    M_ACK_ERROR     => mr_ack_error      , -- In  :
                    M_ACK_NEXT      => mr_ack_next       , -- In  :
                    M_ACK_LAST      => mr_ack_last       , -- In  :
                    M_ACK_STOP      => mr_ack_stop       , -- In  :
                    M_ACK_NONE      => mr_ack_none       , -- In  :
                    M_ACK_SIZE      => mr_ack_size       , -- In  :
                    M_BUF_WE        => mr_buf_wen(1)     , -- In  :
                    M_BUF_BEN       => mr_buf_ben        , -- In  :
                    M_BUF_DATA      => mr_buf_wdata      , -- In  :
                    M_BUF_PTR       => mr_buf_wptr       , -- In  :
                    M_BUF_RDY       => mr_buf_wready(1)  , -- Out :
                    M_XFER_BUSY     => mr_xfer_busy(1)   , -- In  :
                    M_XFER_DONE     => mr_xfer_done(1)   , -- In  :
                    M_XFER_ERROR    => mr_xfer_error(1)  , -- In  :
                -------------------------------------------------------------------
                -- Control Status Register Interface Signals.
                -------------------------------------------------------------------
                    T_ADDR_L        => regs_load(PI_ADDR_REGS_HI downto PI_ADDR_REGS_LO),
                    T_ADDR_D        => regs_wbit(PI_ADDR_REGS_HI downto PI_ADDR_REGS_LO),
                    T_ADDR_Q        => regs_rbit(PI_ADDR_REGS_HI downto PI_ADDR_REGS_LO),
                    T_MODE_L        => regs_load(PI_MODE_REGS_HI downto PI_MODE_REGS_LO),
                    T_MODE_D        => regs_wbit(PI_MODE_REGS_HI downto PI_MODE_REGS_LO),
                    T_MODE_Q        => regs_rbit(PI_MODE_REGS_HI downto PI_MODE_REGS_LO),
                    T_STAT_L        => regs_load(PI_STAT_REGS_HI downto PI_STAT_REGS_LO),
                    T_STAT_D        => regs_wbit(PI_STAT_REGS_HI downto PI_STAT_REGS_LO),
                    T_STAT_Q        => regs_rbit(PI_STAT_REGS_HI downto PI_STAT_REGS_LO),
                    T_STAT_I        => proc_i_stat                 ,
                    T_RESET_L       => regs_load(PI_CTRL_RESET_POS),
                    T_RESET_D       => regs_wbit(PI_CTRL_RESET_POS),
                    T_RESET_Q       => regs_rbit(PI_CTRL_RESET_POS),
                    T_START_L       => regs_load(PI_CTRL_START_POS),
                    T_START_D       => regs_wbit(PI_CTRL_START_POS),
                    T_START_Q       => regs_rbit(PI_CTRL_START_POS),
                    T_STOP_L        => regs_load(PI_CTRL_STOP_POS ),
                    T_STOP_D        => regs_wbit(PI_CTRL_STOP_POS ),
                    T_STOP_Q        => regs_rbit(PI_CTRL_STOP_POS ),
                    T_PAUSE_L       => regs_load(PI_CTRL_PAUSE_POS),
                    T_PAUSE_D       => regs_wbit(PI_CTRL_PAUSE_POS),
                    T_PAUSE_Q       => regs_rbit(PI_CTRL_PAUSE_POS),
                    T_BUSY          => proc_i_busy                 ,
                    T_DONE          => proc_i_done                 ,
                    T_FETCH         => proc_i_fetch                ,
                    T_ERROR         => proc_i_error                ,
                -------------------------------------------------------------------
                -- Co-Processer Interface Signals.
                -------------------------------------------------------------------
                    C_OPERAND_L     => proc_i_c_load               ,
                    C_OPERAND_D     => proc_i_c_data               ,
                    C_REQ           => proc_i_c_req                ,
                    C_ACK           => '1'                         ,
                -------------------------------------------------------------------
                -- Pump Control Register Interface Signals.
                -------------------------------------------------------------------
                    X_RESET_L       => xfer_load(CI_CTRL_RESET_POS),
                    X_RESET_D       => xfer_wbit(CI_CTRL_RESET_POS),
                    X_RESET_Q       => regs_rbit(CI_CTRL_RESET_POS),
                    X_START_L       => xfer_load(CI_CTRL_START_POS),
                    X_START_D       => xfer_wbit(CI_CTRL_START_POS),
                    X_START_Q       => regs_rbit(CI_CTRL_START_POS),
                    X_STOP_L        => xfer_load(CI_CTRL_STOP_POS ),
                    X_STOP_D        => xfer_wbit(CI_CTRL_STOP_POS ),
                    X_STOP_Q        => regs_rbit(CI_CTRL_STOP_POS ),
                    X_PAUSE_L       => xfer_load(CI_CTRL_PAUSE_POS),
                    X_PAUSE_D       => xfer_wbit(CI_CTRL_PAUSE_POS),
                    X_PAUSE_Q       => regs_rbit(CI_CTRL_PAUSE_POS),
                    X_OPERAND_L     => xfer_load(CI_OPERAND_HI downto CI_OPERAND_LO),
                    X_OPERAND_D     => xfer_wbit(CI_OPERAND_HI downto CI_OPERAND_LO),
                    X_OPERAND_Q     => regs_rbit(CI_OPERAND_HI downto CI_OPERAND_LO),
                    X_RUN           => core_i_run                  ,
                    X_DONE          => core_i_done                 ,
                    X_ERROR         => core_i_error       
                );
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            regs_rbit(PI_CTRL_RESV_HI downto PI_CTRL_RESV_LO) <= (others => '0');
            proc_i_stat(0)          <= proc_i_done;
            proc_i_stat(1)          <= proc_i_fetch;
            proc_i_stat(4 downto 2) <= proc_i_error(2 downto 0);
            proc_i_stat(7 downto 5) <= (7 downto 5 => '0');
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            proc_i_mode <= (regs_rbit(PI_CTRL_START_POS) = '1');
            process (regs_load, regs_wbit, xfer_load, xfer_wbit, proc_i_mode) begin
                if (proc_i_mode) then
                    pump_load(CI_CTRL_RESET_POS) <= xfer_load(CI_CTRL_RESET_POS);
                    pump_wbit(CI_CTRL_RESET_POS) <= xfer_wbit(CI_CTRL_RESET_POS);
                    pump_load(CI_CTRL_START_POS) <= xfer_load(CI_CTRL_START_POS);
                    pump_wbit(CI_CTRL_START_POS) <= xfer_wbit(CI_CTRL_START_POS);
                    pump_load(CI_CTRL_STOP_POS ) <= xfer_load(CI_CTRL_STOP_POS );
                    pump_wbit(CI_CTRL_STOP_POS ) <= xfer_wbit(CI_CTRL_STOP_POS );
                    pump_load(CI_CTRL_PAUSE_POS) <= xfer_load(CI_CTRL_PAUSE_POS);
                    pump_wbit(CI_CTRL_PAUSE_POS) <= xfer_wbit(CI_CTRL_PAUSE_POS);
                    pump_load(CI_OPERAND_HI downto CI_OPERAND_LO) <= xfer_load(CI_OPERAND_HI downto CI_OPERAND_LO);
                    pump_wbit(CI_OPERAND_HI downto CI_OPERAND_LO) <= xfer_wbit(CI_OPERAND_HI downto CI_OPERAND_LO);
                else
                    pump_load(CI_CTRL_RESET_POS) <= regs_load(CI_CTRL_RESET_POS);
                    pump_wbit(CI_CTRL_RESET_POS) <= regs_wbit(CI_CTRL_RESET_POS);
                    pump_load(CI_CTRL_START_POS) <= regs_load(CI_CTRL_START_POS);
                    pump_wbit(CI_CTRL_START_POS) <= regs_wbit(CI_CTRL_START_POS);
                    pump_load(CI_CTRL_STOP_POS ) <= regs_load(CI_CTRL_STOP_POS );
                    pump_wbit(CI_CTRL_STOP_POS ) <= regs_wbit(CI_CTRL_STOP_POS );
                    pump_load(CI_CTRL_PAUSE_POS) <= regs_load(CI_CTRL_PAUSE_POS);
                    pump_wbit(CI_CTRL_PAUSE_POS) <= regs_wbit(CI_CTRL_PAUSE_POS);
                    pump_load(CI_CTRL_RESV_POS ) <= regs_load(CI_CTRL_RESV_POS );
                    pump_wbit(CI_CTRL_RESV_POS ) <= regs_wbit(CI_CTRL_RESV_POS );
                    pump_load(CI_CTRL_DONE_POS ) <= regs_load(CI_CTRL_DONE_POS );
                    pump_wbit(CI_CTRL_DONE_POS ) <= regs_wbit(CI_CTRL_DONE_POS );
                    pump_load(CI_OPERAND_HI downto CI_OPERAND_LO) <= regs_load(CI_OPERAND_HI downto CI_OPERAND_LO);
                    pump_wbit(CI_OPERAND_HI downto CI_OPERAND_LO) <= regs_wbit(CI_OPERAND_HI downto CI_OPERAND_LO);
                end if;
            end process;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            pi_mode_end <= regs_rbit(PI_MODE_END_POS  );
            pi_stat_end <= regs_rbit(PI_STAT_END_POS  );
            process (C_CLK, RST) begin
                if (RST = '1') then
                        i_interrupt <= '0';
                elsif (C_CLK'event and C_CLK = '1') then
                    if (regs_rbit(CI_MODE_DONE_POS ) = '1' and regs_rbit(CI_STAT_DONE_POS ) = '1') or
                       (regs_rbit(PI_MODE_END_POS  ) = '1' and regs_rbit(PI_STAT_END_POS  ) = '1') or
                       (regs_rbit(PI_MODE_FETCH_POS) = '1' and regs_rbit(PI_STAT_FETCH_POS) = '1') then
                        i_interrupt <= '1';
                    else
                        i_interrupt <= '0';
                    end if;
                end if;
            end process;
        end generate;
    end generate;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    O_PROC_DISABLE: if (O_PROC_VALID = 0) generate
        regs_rbit(PO_REGS_HI downto PO_REGS_LO) <= (others => '0');
        pump_load(CO_REGS_HI downto CO_REGS_LO) <= regs_load(CO_REGS_HI downto CO_REGS_LO);
        pump_wbit(CO_REGS_HI downto CO_REGS_LO) <= regs_wbit(CO_REGS_HI downto CO_REGS_LO);
        process (C_CLK, RST) begin
            if (RST = '1') then
                    o_interrupt <= '0';
            elsif (C_CLK'event and C_CLK = '1') then
                if (regs_rbit(CO_MODE_DONE_POS ) = '1' and regs_rbit(CO_STAT_DONE_POS ) = '1') or
                   (regs_rbit(CO_MODE_ERROR_POS) = '1' and regs_rbit(CO_STAT_ERROR_POS) = '1') then
                    o_interrupt <= '1';
                else
                    o_interrupt <= '0';
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I_PROC_DISABLE: if (I_PROC_VALID = 0) generate
        regs_rbit(PI_REGS_HI downto PI_REGS_LO) <= (others => '0');
        pump_load(CI_REGS_HI downto CI_REGS_LO) <= regs_load(CI_REGS_HI downto CI_REGS_LO);
        pump_wbit(CI_REGS_HI downto CI_REGS_LO) <= regs_wbit(CI_REGS_HI downto CI_REGS_LO);
        process (C_CLK, RST) begin
            if (RST = '1') then
                    i_interrupt <= '0';
            elsif (C_CLK'event and C_CLK = '1') then
                if (regs_rbit(CI_MODE_DONE_POS ) = '1' and regs_rbit(CI_STAT_DONE_POS ) = '1') or
                   (regs_rbit(CI_MODE_ERROR_POS) = '1' and regs_rbit(CI_STAT_ERROR_POS) = '1') then
                    i_interrupt <= '1';
                else
                    i_interrupt <= '0';
                end if;
            end if;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    PUMP_CORE: PUMP_AXI4_TO_AXI4_CORE
        generic map (
            I_CLK_RATE      => 1                 ,
            I_ADDR_WIDTH    => I_ADDR_WIDTH      ,
            I_DATA_WIDTH    => I_DATA_WIDTH      ,
            I_ID_WIDTH      => I_ID_WIDTH        ,
            I_AUSER_WIDTH   => I_AUSER_WIDTH     ,
            I_RUSER_WIDTH   => 1                 ,
            I_AXI_ID        => I_AXI_ID          ,
            I_REG_ADDR_BITS => CI_ADDR_REGS_BITS ,
            I_REG_SIZE_BITS => CI_SIZE_REGS_BITS ,
            I_REG_MODE_BITS => CI_MODE_REGS_BITS ,
            I_REG_STAT_BITS => CI_STAT_RESV_BITS ,
            I_MAX_XFER_SIZE => I_MAX_XFER_SIZE   ,
            I_ACK_REGS      => I_ACK_REGS        ,
            I_REQ_QUEUE     => I_REQ_QUEUE       ,
            I_RDATA_REGS    => I_RDATA_REGS      ,
            O_CLK_RATE      => 1                 ,
            O_ADDR_WIDTH    => O_ADDR_WIDTH      ,
            O_DATA_WIDTH    => O_DATA_WIDTH      ,
            O_ID_WIDTH      => O_ID_WIDTH        ,
            O_AUSER_WIDTH   => O_AUSER_WIDTH     ,
            O_WUSER_WIDTH   => 1                 ,
            O_BUSER_WIDTH   => 1                 ,
            O_AXI_ID        => O_AXI_ID          ,
            O_REG_ADDR_BITS => CO_ADDR_REGS_BITS ,
            O_REG_SIZE_BITS => CO_SIZE_REGS_BITS ,
            O_REG_MODE_BITS => CO_MODE_REGS_BITS ,
            O_REG_STAT_BITS => CO_STAT_RESV_BITS ,
            O_MAX_XFER_SIZE => O_MAX_XFER_SIZE   ,
            O_REQ_REGS      => O_REQ_REGS        ,
            O_ACK_REGS      => O_ACK_REGS        ,
            O_RES_QUEUE     => O_RES_QUEUE       ,
            O_RES_REGS      => O_RES_REGS        ,
            BUF_DEPTH       => BUF_DEPTH       
        )
        port map (
        ---------------------------------------------------------------------------
        -- Asyncronous Reset Signal.
        ---------------------------------------------------------------------------
            RST             => RST               , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Intake Clock and Clock Enable.
        ---------------------------------------------------------------------------
            I_CLK           => I_CLK             , -- In  :
            I_CLR           => CLR               , -- In  :
            I_CKE           => I_CKE             , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Outlet Clock and Clock Enable.
        ---------------------------------------------------------------------------
            O_CLK           => O_CLK             , -- In  :
            O_CLR           => CLR               , -- In  :
            O_CKE           => O_CKE             , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Intake Control Register I/F Signals.
        ---------------------------------------------------------------------------
            I_ADDR_L        => pump_load(CI_ADDR_REGS_HI downto CI_ADDR_REGS_LO),
            I_ADDR_D        => pump_wbit(CI_ADDR_REGS_HI downto CI_ADDR_REGS_LO),
            I_ADDR_Q        => regs_rbit(CI_ADDR_REGS_HI downto CI_ADDR_REGS_LO),
            I_SIZE_L        => pump_load(CI_SIZE_REGS_HI downto CI_SIZE_REGS_LO),
            I_SIZE_D        => pump_wbit(CI_SIZE_REGS_HI downto CI_SIZE_REGS_LO),
            I_SIZE_Q        => regs_rbit(CI_SIZE_REGS_HI downto CI_SIZE_REGS_LO),
            I_MODE_L        => pump_load(CI_MODE_REGS_HI downto CI_MODE_REGS_LO),
            I_MODE_D        => pump_wbit(CI_MODE_REGS_HI downto CI_MODE_REGS_LO),
            I_MODE_Q        => regs_rbit(CI_MODE_REGS_HI downto CI_MODE_REGS_LO),
            I_STAT_L        => pump_load(CI_STAT_RESV_HI downto CI_STAT_RESV_LO),
            I_STAT_D        => pump_wbit(CI_STAT_RESV_HI downto CI_STAT_RESV_LO),
            I_STAT_Q        => regs_rbit(CI_STAT_RESV_HI downto CI_STAT_RESV_LO),
            I_STAT_I        => core_i_stat                  ,
            I_RESET_L       => pump_load(CI_CTRL_RESET_POS ),
            I_RESET_D       => pump_wbit(CI_CTRL_RESET_POS ),
            I_RESET_Q       => regs_rbit(CI_CTRL_RESET_POS ),
            I_START_L       => pump_load(CI_CTRL_START_POS ),
            I_START_D       => pump_wbit(CI_CTRL_START_POS ),
            I_START_Q       => regs_rbit(CI_CTRL_START_POS ),
            I_STOP_L        => pump_load(CI_CTRL_STOP_POS  ),
            I_STOP_D        => pump_wbit(CI_CTRL_STOP_POS  ),
            I_STOP_Q        => regs_rbit(CI_CTRL_STOP_POS  ),
            I_PAUSE_L       => pump_load(CI_CTRL_PAUSE_POS ),
            I_PAUSE_D       => pump_wbit(CI_CTRL_PAUSE_POS ),
            I_PAUSE_Q       => regs_rbit(CI_CTRL_PAUSE_POS ),
            I_FIRST_L       => pump_load(CI_CTRL_FIRST_POS ),
            I_FIRST_D       => pump_wbit(CI_CTRL_FIRST_POS ),
            I_FIRST_Q       => regs_rbit(CI_CTRL_FIRST_POS ),
            I_LAST_L        => pump_load(CI_CTRL_LAST_POS  ),
            I_LAST_D        => pump_wbit(CI_CTRL_LAST_POS  ),
            I_LAST_Q        => regs_rbit(CI_CTRL_LAST_POS  ),
            I_DONE_EN_L     => pump_load(CI_CTRL_DONE_POS  ),
            I_DONE_EN_D     => pump_wbit(CI_CTRL_DONE_POS  ),
            I_DONE_EN_Q     => regs_rbit(CI_CTRL_DONE_POS  ),
            I_DONE_ST_L     => pump_load(CI_STAT_DONE_POS  ),
            I_DONE_ST_D     => pump_wbit(CI_STAT_DONE_POS  ),
            I_DONE_ST_Q     => regs_rbit(CI_STAT_DONE_POS  ),
            I_ERR_ST_L      => pump_load(CI_STAT_ERROR_POS ),
            I_ERR_ST_D      => pump_wbit(CI_STAT_ERROR_POS ),
            I_ERR_ST_Q      => regs_rbit(CI_STAT_ERROR_POS ),
            I_ADDR_FIX      => regs_rbit(CI_MODE_AFIX_POS  ),
            I_SPECULATIVE   => regs_rbit(CI_MODE_SPECUL_POS),
            I_SAFETY        => regs_rbit(CI_MODE_SAFETY_POS),
            I_CACHE         => regs_rbit(CI_MODE_CACHE_HI downto CI_MODE_CACHE_LO),
            I_LOCK          => I_LOCK            ,
            I_PROT          => I_PROT            ,
            I_QOS           => I_QOS             ,
            I_REGION        => I_REGION          ,
            I_AUSER         => core_i_auser      ,
        ---------------------------------------------------------------------------
        -- Pump Outlet Control Register I/F Signals.
        ---------------------------------------------------------------------------
            O_ADDR_L        => pump_load(CO_ADDR_REGS_HI downto CO_ADDR_REGS_LO),
            O_ADDR_D        => pump_wbit(CO_ADDR_REGS_HI downto CO_ADDR_REGS_LO),
            O_ADDR_Q        => regs_rbit(CO_ADDR_REGS_HI downto CO_ADDR_REGS_LO),
            O_SIZE_L        => pump_load(CO_SIZE_REGS_HI downto CO_SIZE_REGS_LO),
            O_SIZE_D        => pump_wbit(CO_SIZE_REGS_HI downto CO_SIZE_REGS_LO),
            O_SIZE_Q        => regs_rbit(CO_SIZE_REGS_HI downto CO_SIZE_REGS_LO),
            O_MODE_L        => pump_load(CO_MODE_REGS_HI downto CO_MODE_REGS_LO),
            O_MODE_D        => pump_wbit(CO_MODE_REGS_HI downto CO_MODE_REGS_LO),
            O_MODE_Q        => regs_rbit(CO_MODE_REGS_HI downto CO_MODE_REGS_LO),
            O_STAT_L        => pump_load(CO_STAT_RESV_HI downto CO_STAT_RESV_LO),
            O_STAT_D        => pump_wbit(CO_STAT_RESV_HI downto CO_STAT_RESV_LO),
            O_STAT_Q        => regs_rbit(CO_STAT_RESV_HI downto CO_STAT_RESV_LO),
            O_STAT_I        => core_o_stat                  ,
            O_RESET_L       => pump_load(CO_CTRL_RESET_POS ),
            O_RESET_D       => pump_wbit(CO_CTRL_RESET_POS ),
            O_RESET_Q       => regs_rbit(CO_CTRL_RESET_POS ),
            O_START_L       => pump_load(CO_CTRL_START_POS ),
            O_START_D       => pump_wbit(CO_CTRL_START_POS ),
            O_START_Q       => regs_rbit(CO_CTRL_START_POS ),
            O_STOP_L        => pump_load(CO_CTRL_STOP_POS  ),
            O_STOP_D        => pump_wbit(CO_CTRL_STOP_POS  ),
            O_STOP_Q        => regs_rbit(CO_CTRL_STOP_POS  ),
            O_PAUSE_L       => pump_load(CO_CTRL_PAUSE_POS ),
            O_PAUSE_D       => pump_wbit(CO_CTRL_PAUSE_POS ),
            O_PAUSE_Q       => regs_rbit(CO_CTRL_PAUSE_POS ),
            O_FIRST_L       => pump_load(CO_CTRL_FIRST_POS ),
            O_FIRST_D       => pump_wbit(CO_CTRL_FIRST_POS ),
            O_FIRST_Q       => regs_rbit(CO_CTRL_FIRST_POS ),
            O_LAST_L        => pump_load(CO_CTRL_LAST_POS  ),
            O_LAST_D        => pump_wbit(CO_CTRL_LAST_POS  ),
            O_LAST_Q        => regs_rbit(CO_CTRL_LAST_POS  ),
            O_DONE_EN_L     => pump_load(CO_CTRL_DONE_POS  ),
            O_DONE_EN_D     => pump_wbit(CO_CTRL_DONE_POS  ),
            O_DONE_EN_Q     => regs_rbit(CO_CTRL_DONE_POS  ),
            O_DONE_ST_L     => pump_load(CO_STAT_DONE_POS  ),
            O_DONE_ST_D     => pump_wbit(CO_STAT_DONE_POS  ),
            O_DONE_ST_Q     => regs_rbit(CO_STAT_DONE_POS  ),
            O_ERR_ST_L      => pump_load(CO_STAT_ERROR_POS ),
            O_ERR_ST_D      => pump_wbit(CO_STAT_ERROR_POS ),
            O_ERR_ST_Q      => regs_rbit(CO_STAT_ERROR_POS ),
            O_ADDR_FIX      => regs_rbit(CO_MODE_AFIX_POS  ),
            O_SPECULATIVE   => regs_rbit(CO_MODE_SPECUL_POS),
            O_SAFETY        => regs_rbit(CO_MODE_SAFETY_POS),
            O_CACHE         => regs_rbit(CO_MODE_CACHE_HI downto CO_MODE_CACHE_LO),
            O_LOCK          => O_LOCK            ,
            O_PROT          => O_PROT            ,
            O_QOS           => O_QOS             ,
            O_REGION        => O_REGION          ,
            O_AUSER         => core_o_auser      ,
        --------------------------------------------------------------------------
        -- Pump Intake AXI4 Read Address Channel Signals.
        --------------------------------------------------------------------------
            I_ARID          => I_ARID            , -- Out :
            I_ARADDR        => I_ARADDR          , -- Out :
            I_ARLEN         => I_ARLEN           , -- Out :
            I_ARSIZE        => I_ARSIZE          , -- Out :
            I_ARBURST       => I_ARBURST         , -- Out :
            I_ARLOCK        => I_ARLOCK          , -- Out :
            I_ARCACHE       => I_ARCACHE         , -- Out :
            I_ARPROT        => I_ARPROT          , -- Out :
            I_ARQOS         => I_ARQOS           , -- Out :
            I_ARREGION      => I_ARREGION        , -- Out :
            I_ARUSER        => I_ARUSER          , -- Out :
            I_ARVALID       => I_ARVALID         , -- Out :
            I_ARREADY       => I_ARREADY         , -- In  :
        --------------------------------------------------------------------------
        -- Pump Intake AXI4 Read Data Channel Signals.
        --------------------------------------------------------------------------
            I_RID           => I_RID             , -- In  :
            I_RDATA         => I_RDATA           , -- In  :
            I_RRESP         => I_RRESP           , -- In  :
            I_RLAST         => I_RLAST           , -- In  :
            I_RUSER         => i_ruser           , -- In  :
            I_RVALID        => I_RVALID          , -- In  :
            I_RREADY        => I_RREADY          , -- Out :
        --------------------------------------------------------------------------
        -- Pump Outlet AXI4 Write Address Channel Signals.
        --------------------------------------------------------------------------
            O_AWID          => O_AWID            , -- Out :
            O_AWADDR        => O_AWADDR          , -- Out :
            O_AWLEN         => O_AWLEN           , -- Out :
            O_AWSIZE        => O_AWSIZE          , -- Out :
            O_AWBURST       => O_AWBURST         , -- Out :
            O_AWLOCK        => O_AWLOCK          , -- Out :
            O_AWCACHE       => O_AWCACHE         , -- Out :
            O_AWPROT        => O_AWPROT          , -- Out :
            O_AWQOS         => O_AWQOS           , -- Out :
            O_AWREGION      => O_AWREGION        , -- Out :
            O_AWUSER        => O_AWUSER          , -- Out :
            O_AWVALID       => O_AWVALID         , -- Out :
            O_AWREADY       => O_AWREADY         , -- In  :
        --------------------------------------------------------------------------
        -- Pump Outlet AXI4 Write Data Channel Signals.
        --------------------------------------------------------------------------
            O_WID           => open              , -- Out :
            O_WDATA         => O_WDATA           , -- Out :
            O_WSTRB         => O_WSTRB           , -- Out :
            O_WUSER         => open              , -- Out :
            O_WLAST         => O_WLAST           , -- Out :
            O_WVALID        => O_WVALID          , -- Out :
            O_WREADY        => O_WREADY          , -- In  :
        --------------------------------------------------------------------------
        -- Pump Outlet AXI4 Write Response Channel Signals.
        --------------------------------------------------------------------------
            O_BID           => O_BID             , -- In  :
            O_BRESP         => O_BRESP           , -- In  :
            O_BUSER         => o_buser           , -- In  :
            O_BVALID        => O_BVALID          , -- In  :
            O_BREADY        => O_BREADY          , -- Out :
        ---------------------------------------------------------------------------
        -- Pump Intake Status Signals.
        ---------------------------------------------------------------------------
            I_OPEN          => core_i_open       , -- Out :
            I_RUNNING       => core_i_run        , -- Out :
            I_DONE          => core_i_done       , -- Out :
            I_NONE          => core_i_none       , -- Out :
            I_ERROR         => core_i_error      , -- Out :
        ---------------------------------------------------------------------------
        -- Pump Outlet Status Signals.
        ---------------------------------------------------------------------------
            O_OPEN          => core_o_open       , -- Out :
            O_RUNNING       => core_o_run        , -- Out :
            O_DONE          => core_o_done       , -- Out :
            O_NONE          => core_o_none       , -- Out :
            O_ERROR         => core_o_error        -- Out :
        );
    regs_rbit(CO_CTRL_RESV_POS) <= '0';
    regs_rbit(CI_CTRL_RESV_POS) <= '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    core_i_auser <= RESIZE(regs_rbit(CI_MODE_AUSER_HI downto CI_MODE_AUSER_LO), I_AUSER_WIDTH);
    core_o_auser <= RESIZE(regs_rbit(CO_MODE_AUSER_HI downto CO_MODE_AUSER_LO), O_AUSER_WIDTH);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    core_i_stat  <= (others => '0');
    core_o_stat  <= (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I_AWID       <= (others => '0');
    I_AWADDR     <= (others => '0');
    I_AWLEN      <= (others => '0');
    I_AWSIZE     <= (others => '0');
    I_AWBURST    <= (others => '0');
    I_AWLOCK     <= (others => '0');
    I_AWCACHE    <= (others => '0');
    I_AWPROT     <= (others => '0');
    I_AWQOS      <= (others => '0');
    I_AWREGION   <= (others => '0');
    I_AWUSER     <= (others => '0');
    I_AWVALID    <= '0';
    I_WDATA      <= (others => '0');
    I_WSTRB      <= (others => '0');
    I_WLAST      <= '0';
    I_WVALID     <= '0';
    I_BREADY     <= '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    O_ARID       <= (others => '0');
    O_ARADDR     <= (others => '0');
    O_ARLEN      <= (others => '0');
    O_ARSIZE     <= (others => '0');
    O_ARBURST    <= (others => '0');
    O_ARLOCK     <= (others => '0');
    O_ARCACHE    <= (others => '0');
    O_ARPROT     <= (others => '0');
    O_ARQOS      <= (others => '0');
    O_ARREGION   <= (others => '0');
    O_ARUSER     <= (others => '0');
    O_ARVALID    <= '0';
    O_RREADY     <= '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    IRQ   <= i_interrupt or o_interrupt;
    I_IRQ <= i_interrupt;
    O_IRQ <= o_interrupt;
end RTL;
