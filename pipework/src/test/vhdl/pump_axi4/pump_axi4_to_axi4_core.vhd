-----------------------------------------------------------------------------------
--!     @file    pump_axi4_to_axi4_core.vhd
--!     @brief   Pump Core Module (AXI4 to AXI4)
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
library PipeWork;
use     PipeWork.AXI4_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief 
-----------------------------------------------------------------------------------
entity  PUMP_AXI4_TO_AXI4_CORE is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        I_CLK_RATE      : --! @brief PUMP INTAKE CLOCK RATE :
                          --! O_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側の
                          --! クロック(O_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        I_ADDR_WIDTH    : --! @brief PUMP INTAKE AXI4 ADDRESS WIDTH :
                          --! I_ARADDR のビット幅を指定する.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        I_DATA_WIDTH    : --! @brief PUMP INTAKE AXI4 DATA WIDTH :
                          --! I_RDATA のビット幅を指定する.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        I_ID_WIDTH      : --! @brief PUMP INTAKE AXI4 ID WIDTH :
                          --! I_ARID/I_RID のビット幅を指定する.
                          integer := 4;
        I_AUSER_WIDTH   : --! @brief PUMP INTAKE AXI4 AUSER WIDTH :
                          --! I_ARUSER のビット幅を指定する.
                          integer range 1 to 32                  :=  4;
        I_RUSER_WIDTH   : --! @brief PUMP INTAKE AXI4 RUSER WIDTH :
                          --! I_RUSER のビット幅を指定する.
                          integer range 1 to 32                  :=  4;
        I_AXI_ID        : --! @brief PUMP INTAKE AXI4 ID :
                          --! I_ARID/I_RIDの値を指定する.
                          integer :=  1;
        I_REG_ADDR_BITS : --! @brief PUMP INTAKE ADDRESS REGISTER BITS :
                          --! I_ADDR_L/I_ADDR_D/I_ADDR_Q のビット数を指定する.
                          integer := 64;
        I_REG_SIZE_BITS : --! @brief PUMP INTAKE SIZE REGISTER BITS :
                          --! I_SIZE_L/I_SIZE_D/I_SIZE_Q のビット数を指定する.
                          integer := 32;
        I_REG_MODE_BITS : --! @brief PUMP INTAKE MODE REGISTER BITS :
                          --! I_MODE_L/I_MODE_D/I_MODE_Q のビット数を指定する.
                          integer := 16;
        I_REG_STAT_BITS : --! @brief PUMP INTAKE STATUS REGISTER BITS :
                          --! I_STAT_L/I_STAT_D/I_STAT_Q のビット数を指定する.
                          integer :=  8;
        I_MAX_XFER_SIZE : --! @brief PUMP INTAKE MAX TRANSFER SIZE :
                          --! PUMP INTAKE の最大転送バイト数を２のべき乗値で指定す
                          --! る.
                          integer :=  8;
        I_REQ_QUEUE     : --! @brief PUMP INTAKE REQUEST QUEUE SIZE :
                          --! PUMP INTAKE のリクエストキューの大きさを指定する.
                          --! 詳細は PipeWork.Components の AXI4_MASTER_READ_INTERFACE を参照.
                          integer :=  1;
        I_RDATA_REGS    : --! @brief RDATA REGISTER TYPE :
                          --! RDATA/RRESP/RLAST/RVALID の入力をどうするか指定する.
                          --! * RDATA_REGS=0 スルー入力(レジスタは通さない).
                          --! * RDATA_REGS=1 １段だけレジスタを通す. 
                          --!   ただしバースト転送時には１サイクル毎にウェイトが入る.
                          --! * RDATA_REGS=2 ２段のレジスタを通す.
                          --! * RDATA_REGS=3 ３段のレジスタを通す.
                          --!   このモードの場合、必ずRDATA/RRESPは一つのレジスタ
                          --!   で受けるので外部インターフェース向き.
                          integer := 0;
        I_ACK_REGS      : --! @brief PUMP INTAKE ACKNOWLEDGE SIGNALS REGSITERED OUT :
                          --! PUMP INTAKE 側の Acknowledge Signals の出力をレジスタ
                          --! 出力にするか否かを指定する.
                          --! * I_ACK_REGS=0で組み合わせ出力.
                          --! * I_ACK_REGS=1でレジスタ出力.
                          integer range 0 to 1 := 0;
        O_CLK_RATE      : --! @brief OUTPUT CLOCK RATE :
                          --! I_CLK_RATEとペアで入力側のクロック(I_CLK)と出力側の
                          --! クロック(O_CLK)との関係を指定する.
                          --! 詳細は PipeWork.Components の SYNCRONIZER を参照.
                          integer :=  1;
        O_ADDR_WIDTH    : --! @brief PUMP OUTLET AXI4 ADDRESS WIDTH :
                          --! O_AWADDR のビット幅を指定する.
                          integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        O_DATA_WIDTH    : --! @brief PUMP OUTLET AXI4 DATA WIDTH :
                          --! O_WDATA のビット幅を指定する.
                          integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        O_ID_WIDTH      : --! @brief PUMP OUTLET AXI4 ID WIDTH :
                          --! O_AWID/O_WID/O_BID のビット幅を指定する.
                          integer := 4;
        O_AUSER_WIDTH   : --! @brief PUMP OUTLET AXI4 AUSER WIDTH :
                          --! O_AWUSER のビット幅を指定する.
                          integer range 1 to 32                  :=  4;
        O_WUSER_WIDTH   : --! @brief PUMP OUTLET AXI4 WUSER WIDTH :
                          --! O_WUSER のビット幅を指定する.
                          integer range 1 to 32                  :=  4;
        O_BUSER_WIDTH   : --! @brief PUMP OUTLET AXI4 BUSER WIDTH :
                          --! O_BUSER のビット幅を指定する.
                          integer range 1 to 32                  :=  4;
        O_AXI_ID        : --! @brief PUMP OUTLET AXI4 ID :
                          --! O_AWID/O_WIDの値を指定する.
                          integer :=  2;
        O_REG_ADDR_BITS : --! @brief PUMP OUTLET ADDRESS REGISTER BITS :
                          --! O_ADDR_L/O_ADDR_D/O_ADDR_Q のビット数を指定する.
                          integer := 64;
        O_REG_SIZE_BITS : --! @brief PUMP OUTLET SIZE REGISTER BITS :
                          --! O_SIZE_L/O_SIZE_D/O_SIZE_Q のビット数を指定する.
                          integer := 32;
        O_REG_MODE_BITS : --! @brief PUMP OUTLET MODE REGISTER BITS :
                          --! O_MODE_L/O_MODE_D/O_MODE_Q のビット数を指定する.
                          integer := 16;
        O_REG_STAT_BITS : --! @brief PUMP OUTLET STATUS REGISTER BITS :
                          --! O_STAT_L/O_STAT_D/O_STAT_Q のビット数を指定する.
                          integer :=  8;
        O_MAX_XFER_SIZE : --! @brief PUMP OUTLET MAX TRANSFER SIZE :
                          --! PUMP OUTLET の最大転送バイト数を２のべき乗値で指定す
                          --! る.
                          integer :=  8;
        O_REQ_REGS      : --! @brief  PUMP OUTLET REQUEST REGISTER USE :
                          --! ライトトランザクションの最初のデータ出力のタイミング
                          --! を指定する.
                          --! * REQ_REGS=0でアドレスの出力と同時にデータを出力する.
                          --! * REQ_REGS=1でアドレスを出力してから１クロック後に
                          --!   データを出力する.
                          --! * REQ_REGS=1にすると動作周波数が向上する可能性がある.
                          integer range 0 to 1 := 0;
        O_ACK_REGS      : --! @brief PUMP OUTLET ACKNOWLEDGE SIGNALS REGSITERED OUT :
                          --! PUMP OUTLET 側の Acknowledge Signals の出力をレジスタ
                          --! 出力にするか否かを指定する.
                          --! * O_ACK_REGS=0で組み合わせ出力.
                          --! * O_ACK_REGS=1でレジスタ出力.
                          integer range 0 to 1 := 0;
        O_RES_QUEUE     : --! @brief PUMP OUTLET RESPONSE QUEUE SIZE :
                          --! PUMP OUTLET のレスポンスキューの大きさを指定する.
                          --! 詳細は PipeWork.Components の AXI4_MASTER_WRITE_INTERFACE を参照.
                          integer :=  2;
        O_RES_REGS      : --! @brief PUMP OUTLET RESPONSE REGISTER USE :
                          --! レスポンスの入力側にレジスタを挿入する.
                          --! 詳細は PipeWork.Components の AXI4_MASTER_WRITE_INTERFACE を参照.
                          integer :=  1;
        BUF_DEPTH       : --! @brief BUFFER DEPTH :
                          --! バッファの大きさ(バイト数)を２のべき乗で指定する.
                          --! * バッファの大きさは I_MAX_XFER_SIZE で示される入力側
                          --!   の最大転送バイト数と O_MAX_XFER_SIZE で示される出力
                          --!   側の最大転送バイト数よりも大きくなければならない.
                          integer := 12
    );
    port(
    -------------------------------------------------------------------------------
    -- Asyncronous Reset Signal.
    -------------------------------------------------------------------------------
        RST             : in  std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake Clock and Clock Enable.
    -------------------------------------------------------------------------------
        I_CLK           : in  std_logic;
        I_CLR           : in  std_logic;
        I_CKE           : in  std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet Clock and Clock Enable.
    -------------------------------------------------------------------------------
        O_CLK           : in  std_logic;
        O_CLR           : in  std_logic;
        O_CKE           : in  std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake Control Register I/F Signals.
    -------------------------------------------------------------------------------
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
        I_CACHE         : in  AXI4_ACACHE_TYPE;
        I_LOCK          : in  AXI4_ALOCK_TYPE  ;
        I_PROT          : in  AXI4_APROT_TYPE  ;
        I_QOS           : in  AXI4_AQOS_TYPE   ;
        I_REGION        : in  AXI4_AREGION_TYPE;
        I_AUSER         : in  std_logic_vector(I_AUSER_WIDTH  -1 downto 0);
    -------------------------------------------------------------------------------
    -- Pump Outlet Control Register I/F Signals.
    -------------------------------------------------------------------------------
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
    -------------------------------------------------------------------------------
    -- Pump Intake AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
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
    ------------------------------------------------------------------------------
    -- Pump Intake AXI4 Read Data Channel Signals.
    ------------------------------------------------------------------------------
        I_RID           : in  std_logic_vector(I_ID_WIDTH     -1 downto 0);
        I_RDATA         : in  std_logic_vector(I_DATA_WIDTH   -1 downto 0);
        I_RRESP         : in  AXI4_RESP_TYPE;
        I_RLAST         : in  std_logic;
        I_RUSER         : in  std_logic_vector(I_RUSER_WIDTH  -1 downto 0);
        I_RVALID        : in  std_logic;
        I_RREADY        : out std_logic;
    ------------------------------------------------------------------------------
    -- Pump Outlet AXI4 Write Address Channel Signals.
    ------------------------------------------------------------------------------
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
    ------------------------------------------------------------------------------
    -- Pump Outlet AXI4 Write Data Channel Signals.
    ------------------------------------------------------------------------------
        O_WID           : out std_logic_vector(O_ID_WIDTH     -1 downto 0);
        O_WDATA         : out std_logic_vector(O_DATA_WIDTH   -1 downto 0);
        O_WSTRB         : out std_logic_vector(O_DATA_WIDTH/8 -1 downto 0);
        O_WUSER         : out std_logic_vector(O_WUSER_WIDTH  -1 downto 0);
        O_WLAST         : out std_logic;
        O_WVALID        : out std_logic;
        O_WREADY        : in  std_logic;
    ------------------------------------------------------------------------------
    -- Pump Outlet AXI4 Write Response Channel Signals.
    ------------------------------------------------------------------------------
        O_BID           : in  std_logic_vector(O_ID_WIDTH     -1 downto 0);
        O_BRESP         : in  AXI4_RESP_TYPE;
        O_BUSER         : in  std_logic_vector(O_BUSER_WIDTH  -1 downto 0);
        O_BVALID        : in  std_logic;
        O_BREADY        : out std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake Status Signals.
    -------------------------------------------------------------------------------
        I_OPEN          : out std_logic;
        I_RUNNING       : out std_logic;
        I_DONE          : out std_logic;
        I_NONE          : out std_logic;
        I_ERROR         : out std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet Status Signals.
    -------------------------------------------------------------------------------
        O_OPEN          : out std_logic;
        O_RUNNING       : out std_logic;
        O_DONE          : out std_logic;
        O_NONE          : out std_logic;
        O_ERROR         : out std_logic
    );
end PUMP_AXI4_TO_AXI4_CORE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_READ_INTERFACE;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_WRITE_INTERFACE;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROLLER;
use     PIPEWORK.COMPONENTS.SDPRAM;
architecture RTL of PUMP_AXI4_TO_AXI4_CORE is
    ------------------------------------------------------------------------------
    -- 各種サイズカウンタのビット数.
    ------------------------------------------------------------------------------
    constant SIZE_BITS          : integer := BUF_DEPTH+1;
    ------------------------------------------------------------------------------
    -- 最大転送バイト数.
    ------------------------------------------------------------------------------
    constant I_MAX_XFER_BYTES   : integer := 2**I_MAX_XFER_SIZE;
    constant O_MAX_XFER_BYTES   : integer := 2**O_MAX_XFER_SIZE;
    ------------------------------------------------------------------------------
    -- バッファの総バイト数
    ------------------------------------------------------------------------------
    constant BUF_BYTES          : integer := 2**BUF_DEPTH;
    ------------------------------------------------------------------------------
    -- バッファデータのビット幅.
    ------------------------------------------------------------------------------
    function MAX(A,B:integer) return integer is begin
        if (A > B) then return A;
        else            return B;
        end if;
    end function;
    constant BUF_DATA_WIDTH     : integer := MAX(O_DATA_WIDTH,I_DATA_WIDTH);
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
    constant BUF_DATA_BIT_SIZE  : integer := CALC_DATA_SIZE(BUF_DATA_WIDTH);
    ------------------------------------------------------------------------------
    -- バッファのデータ幅をバイト数で示す.
    ------------------------------------------------------------------------------
    constant BUF_DATA_BYTES     : integer := BUF_DATA_WIDTH/8;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant I2O_DELAY_CYCLE    : integer := 0;
    ------------------------------------------------------------------------------
    -- 入力側のフロー制御用定数.
    ------------------------------------------------------------------------------
    constant I_FLOW_VALID       : integer := 1;
    constant I_USE_PUSH_RSV_SIZE: integer := 0;
    constant I_USE_PUSH_BUF_SIZE: integer := 0;
    constant I_FIXED_FLOW_OPEN  : integer := 0;
    constant I_FIXED_POOL_OPEN  : integer := 1;
    constant I_REQ_ADDR_VALID   : integer := 1;
    constant I_REQ_SIZE_VALID   : integer := 1;
    constant I_FLOW_READY_LEVEL : std_logic_vector(SIZE_BITS-1 downto 0) :=
                                  std_logic_vector(to_unsigned(BUF_BYTES-I_MAX_XFER_BYTES,SIZE_BITS));
    constant I_BUF_READY_LEVEL  : std_logic_vector(SIZE_BITS-1 downto 0) :=
                                  std_logic_vector(to_unsigned(BUF_BYTES-2*BUF_DATA_BYTES,SIZE_BITS));
    ------------------------------------------------------------------------------
    -- 出力側のフロー制御用定数.
    ------------------------------------------------------------------------------
    constant O_FLOW_VALID       : integer := 1;
    constant O_USE_PULL_RSV_SIZE: integer := 0;
    constant O_USE_PULL_BUF_SIZE: integer := 0;
    constant O_FIXED_FLOW_OPEN  : integer := 0;
    constant O_FIXED_POOL_OPEN  : integer := 1;
    constant O_REQ_ADDR_VALID   : integer := 1;
    constant O_REQ_SIZE_VALID   : integer := 1;
    constant O_FLOW_READY_LEVEL : std_logic_vector(SIZE_BITS-1 downto 0) :=
                                  std_logic_vector(to_unsigned(O_MAX_XFER_BYTES,SIZE_BITS));
    constant O_BUF_READY_LEVEL  : std_logic_vector(SIZE_BITS-1 downto 0) :=
                                  std_logic_vector(to_unsigned(  BUF_DATA_BYTES,SIZE_BITS));
    ------------------------------------------------------------------------------
    -- 入力側の各種定数.
    ------------------------------------------------------------------------------
    constant I_ID               : std_logic_vector(I_ID_WIDTH -1 downto 0) :=
                                  std_logic_vector(to_unsigned(I_AXI_ID, I_ID_WIDTH));
    constant I_XFER_SIZE_SEL    : std_logic_vector(I_MAX_XFER_SIZE downto I_MAX_XFER_SIZE) := "1";
    ------------------------------------------------------------------------------
    -- 入力側の各種信号群.
    ------------------------------------------------------------------------------
    signal   i_req_addr         : std_logic_vector(I_ADDR_WIDTH    -1 downto 0);
    signal   i_req_size         : std_logic_vector(I_REG_SIZE_BITS -1 downto 0);
    signal   i_req_buf_ptr      : std_logic_vector(BUF_DEPTH       -1 downto 0);
    signal   i_req_burst_type   : AXI4_ABURST_TYPE;
    signal   i_req_first        : std_logic;
    signal   i_req_last         : std_logic;
    signal   i_req_none         : std_logic;
    signal   i_req_valid        : std_logic;
    signal   i_req_ready        : std_logic;
    signal   i_xfer_busy        : std_logic;
    signal   i_xfer_done        : std_logic;
    signal   i_xfer_error       : std_logic;
    signal   i_ack_valid        : std_logic;
    signal   i_ack_error        : std_logic;
    signal   i_ack_next         : std_logic;
    signal   i_ack_last         : std_logic;
    signal   i_ack_stop         : std_logic;
    signal   i_ack_none         : std_logic;
    signal   i_ack_size         : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   i_flow_pause       : std_logic;
    signal   i_flow_stop        : std_logic;
    signal   i_flow_last        : std_logic;
    signal   i_flow_size        : std_logic_vector(SIZE_BITS       -1 downto 0);
    ------------------------------------------------------------------------------
    -- 出力側の各種定数.
    ------------------------------------------------------------------------------
    constant O_ID               : std_logic_vector(O_ID_WIDTH -1 downto 0) := 
                                  std_logic_vector(to_unsigned(O_AXI_ID, O_ID_WIDTH));
    constant O_XFER_SIZE_SEL    : std_logic_vector(O_MAX_XFER_SIZE downto O_MAX_XFER_SIZE) := "1";
    ------------------------------------------------------------------------------
    -- 出力側の各種信号群.
    ------------------------------------------------------------------------------
    signal   o_req_addr         : std_logic_vector(O_ADDR_WIDTH    -1 downto 0);
    signal   o_req_size         : std_logic_vector(O_REG_SIZE_BITS -1 downto 0);
    signal   o_req_buf_ptr      : std_logic_vector(BUF_DEPTH       -1 downto 0);
    signal   o_req_burst_type   : AXI4_ABURST_TYPE;
    signal   o_req_first        : std_logic;
    signal   o_req_last         : std_logic;
    signal   o_req_none         : std_logic;
    signal   o_req_valid        : std_logic;
    signal   o_req_ready        : std_logic;
    signal   o_xfer_busy        : std_logic;
    signal   o_xfer_done        : std_logic;
    signal   o_xfer_error       : std_logic;
    signal   o_ack_valid        : std_logic;
    signal   o_ack_error        : std_logic;
    signal   o_ack_next         : std_logic;
    signal   o_ack_last         : std_logic;
    signal   o_ack_stop         : std_logic;
    signal   o_ack_none         : std_logic;
    signal   o_ack_size         : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   o_flow_pause       : std_logic;
    signal   o_flow_stop        : std_logic;
    signal   o_flow_last        : std_logic;
    signal   o_flow_size        : std_logic_vector(SIZE_BITS       -1 downto 0);
    ------------------------------------------------------------------------------
    -- フローカウンタ制御用信号群.
    ------------------------------------------------------------------------------
    signal   push_fin_valid     : std_logic;
    signal   push_fin_error     : std_logic;
    signal   push_fin_last      : std_logic;
    signal   push_fin_size      : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   push_rsv_valid     : std_logic;
    signal   push_rsv_error     : std_logic;
    signal   push_rsv_last      : std_logic;
    signal   push_rsv_size      : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   push_buf_valid     : std_logic;
    signal   push_buf_ready     : std_logic;
    signal   push_buf_reset     : std_logic;
    signal   push_buf_error     : std_logic;
    signal   push_buf_last      : std_logic;
    signal   push_buf_size      : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   pull_fin_valid     : std_logic;
    signal   pull_fin_error     : std_logic;
    signal   pull_fin_last      : std_logic;
    signal   pull_fin_size      : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   pull_rsv_valid     : std_logic;
    signal   pull_rsv_error     : std_logic;
    signal   pull_rsv_last      : std_logic;
    signal   pull_rsv_size      : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   pull_buf_valid     : std_logic;
    signal   pull_buf_ready     : std_logic;
    signal   pull_buf_reset     : std_logic;
    signal   pull_buf_error     : std_logic;
    signal   pull_buf_last      : std_logic;
    signal   pull_buf_size      : std_logic_vector(SIZE_BITS       -1 downto 0);
    ------------------------------------------------------------------------------
    -- バッファへのアクセス用信号群.
    ------------------------------------------------------------------------------
    signal   buf_wdata          : std_logic_vector(BUF_DATA_WIDTH  -1 downto 0);
    signal   buf_ben            : std_logic_vector(BUF_DATA_WIDTH/8-1 downto 0);
    signal   buf_we             : std_logic_vector(BUF_DATA_WIDTH/8-1 downto 0);
    signal   buf_wptr           : std_logic_vector(BUF_DEPTH       -1 downto 0);
    signal   buf_wen            : std_logic;
    constant buf_wready         : std_logic := '1';
    signal   buf_rdata          : std_logic_vector(BUF_DATA_WIDTH  -1 downto 0);
    signal   buf_rptr           : std_logic_vector(BUF_DEPTH       -1 downto 0);
    constant buf_rready         : std_logic := '1';
begin
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    I_IF: AXI4_MASTER_READ_INTERFACE                     -- 
        generic map (                                    -- 
            AXI4_ADDR_WIDTH     => I_ADDR_WIDTH        , -- 
            AXI4_DATA_WIDTH     => I_DATA_WIDTH        , -- 
            AXI4_ID_WIDTH       => I_ID_WIDTH          , -- 
            VAL_BITS            => 1                   , -- 
            REQ_SIZE_BITS       => I_REG_SIZE_BITS     , -- 
            REQ_SIZE_VALID      => I_REQ_SIZE_VALID    , -- 
            FLOW_VALID          => I_FLOW_VALID        , -- 
            BUF_DATA_WIDTH      => BUF_DATA_WIDTH      , -- 
            BUF_PTR_BITS        => BUF_DEPTH           , -- 
            XFER_SIZE_BITS      => SIZE_BITS           , -- 
            XFER_MIN_SIZE       => I_MAX_XFER_SIZE     , -- 
            XFER_MAX_SIZE       => I_MAX_XFER_SIZE     , -- 
            QUEUE_SIZE          => I_REQ_QUEUE         , --
            RDATA_REGS          => I_RDATA_REGS        , --
            ACK_REGS            => I_ACK_REGS            -- 
        )                                                -- 
        port map (                                       -- 
        --------------------------------------------------------------------------
        -- Clock and Reset Signals.
        --------------------------------------------------------------------------
            CLK                 => I_CLK               , -- In  :
            CLR                 => I_CLR               , -- In  :
            RST                 => RST                 , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Read Address Channel Signals.
        --------------------------------------------------------------------------
            ARID                => I_ARID              , -- Out :
            ARADDR              => I_ARADDR            , -- Out :
            ARLEN               => I_ARLEN             , -- Out :
            ARSIZE              => I_ARSIZE            , -- Out :
            ARBURST             => I_ARBURST           , -- Out :
            ARLOCK              => I_ARLOCK            , -- Out :
            ARCACHE             => I_ARCACHE           , -- Out :
            ARPROT              => I_ARPROT            , -- Out :
            ARQOS               => I_ARQOS             , -- Out :
            ARREGION            => I_ARREGION          , -- Out :
            ARVALID             => I_ARVALID           , -- Out :
            ARREADY             => I_ARREADY           , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Read Data Channel Signals.
        --------------------------------------------------------------------------
            RID                 => I_RID               , -- In  :
            RDATA               => I_RDATA             , -- In  :
            RRESP               => I_RRESP             , -- In  :
            RLAST               => I_RLAST             , -- In  :
            RVALID              => I_RVALID            , -- In  :
            RREADY              => I_RREADY            , -- Out :
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
            REQ_ADDR            => i_req_addr          , -- In  :
            REQ_SIZE            => i_req_size          , -- In  :
            REQ_ID              => I_ID                , -- In  :
            REQ_BURST           => i_req_burst_type    , -- In  :
            REQ_LOCK            => I_LOCK              , -- In  :
            REQ_CACHE           => I_CACHE             , -- In  :
            REQ_PROT            => I_PROT              , -- In  :
            REQ_QOS             => I_QOS               , -- In  :
            REQ_REGION          => I_REGION            , -- In  :
            REQ_BUF_PTR         => i_req_buf_ptr       , -- In  :
            REQ_FIRST           => i_req_first         , -- In  :
            REQ_LAST            => i_req_last          , -- In  :
            REQ_SPECULATIVE     => I_SPECULATIVE       , -- In  :
            REQ_SAFETY          => I_SAFETY            , -- In  :
            REQ_VAL(0)          => i_req_valid         , -- In  :
            REQ_RDY             => i_req_ready         , -- Out :
            XFER_SIZE_SEL       => I_XFER_SIZE_SEL     , -- In  :
        ---------------------------------------------------------------------------
        -- Response Signals.
        ---------------------------------------------------------------------------
            ACK_VAL(0)          => i_ack_valid         , -- Out :
            ACK_ERROR           => i_ack_error         , -- Out :
            ACK_NEXT            => i_ack_next          , -- Out :
            ACK_LAST            => i_ack_last          , -- Out :
            ACK_STOP            => i_ack_stop          , -- Out :
            ACK_NONE            => i_ack_none          , -- Out :
            ACK_SIZE            => i_ack_size          , -- Out :
        ---------------------------------------------------------------------------
        -- Transfer Status Signal.
        ---------------------------------------------------------------------------
            XFER_BUSY(0)        => i_xfer_busy         , -- Out :
            XFER_DONE(0)        => i_xfer_done         , -- Out :
            XFER_ERROR(0)       => i_xfer_error        , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_PAUSE          => i_flow_pause        , -- In  :
            FLOW_STOP           => i_flow_stop         , -- In  :
            FLOW_LAST           => i_flow_last         , -- In  :
            FLOW_SIZE           => i_flow_size         , -- In  :
        ---------------------------------------------------------------------------
        -- Reserve Size Signals.
        ---------------------------------------------------------------------------
            PUSH_RSV_VAL(0)     => push_rsv_valid      , -- Out :
            PUSH_RSV_SIZE       => push_rsv_size       , -- Out :
            PUSH_RSV_LAST       => push_rsv_last       , -- Out :
            PUSH_RSV_ERROR      => push_rsv_error      , -- Out :
        ---------------------------------------------------------------------------
        -- Push Size Signals.
        ---------------------------------------------------------------------------
            PUSH_FIN_VAL(0)     => push_fin_valid      , -- Out :
            PUSH_FIN_SIZE       => push_fin_size       , -- Out :
            PUSH_FIN_LAST       => push_fin_last       , -- Out :
            PUSH_FIN_ERROR      => push_fin_error      , -- Out :
        ---------------------------------------------------------------------------
        -- Push Size Signals.
        ---------------------------------------------------------------------------
            PUSH_BUF_RESET(0)   => push_buf_reset      , -- Out :
            PUSH_BUF_VAL(0)     => push_buf_valid      , -- Out :
            PUSH_BUF_SIZE       => push_buf_size       , -- Out :
            PUSH_BUF_LAST       => push_buf_last       , -- Out :
            PUSH_BUF_ERROR      => push_buf_error      , -- Out :
            PUSH_BUF_RDY(0)     => push_buf_ready      , -- In  :
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_WEN(0)          => buf_wen             , -- Out :
            BUF_BEN             => buf_ben             , -- Out :
            BUF_DATA            => buf_wdata           , -- Out :
            BUF_PTR             => buf_wptr              -- Out :
        );
    process (I_CLK, RST) begin
        if (RST = '1') then
                I_ARUSER <= (others => '0');
        elsif (I_CLK'event and I_CLK = '1') then
            if (I_CLR = '1') then
                I_ARUSER <= (others => '0');
            elsif (i_req_valid = '1' and i_req_ready = '1') then
                I_ARUSER <= I_AUSER;
            end if;
        end if;
    end process;
    i_req_burst_type <= AXI4_ABURST_FIXED when (I_ADDR_FIX = '1') else AXI4_ABURST_INCR;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_IF: AXI4_MASTER_WRITE_INTERFACE                    -- 
        generic map (                                    -- 
            AXI4_ADDR_WIDTH     => O_ADDR_WIDTH        , -- 
            AXI4_DATA_WIDTH     => O_DATA_WIDTH        , -- 
            AXI4_ID_WIDTH       => O_ID_WIDTH          , -- 
            VAL_BITS            => 1                   , -- 
            REQ_SIZE_BITS       => O_REG_SIZE_BITS     , -- 
            REQ_SIZE_VALID      => O_REQ_SIZE_VALID    , -- 
            FLOW_VALID          => O_FLOW_VALID        , -- 
            BUF_DATA_WIDTH      => BUF_DATA_WIDTH      , -- 
            BUF_PTR_BITS        => BUF_DEPTH           , -- 
            XFER_SIZE_BITS      => SIZE_BITS           , -- 
            XFER_MIN_SIZE       => O_MAX_XFER_SIZE     , -- 
            XFER_MAX_SIZE       => O_MAX_XFER_SIZE     , -- 
            REQ_REGS            => O_REQ_REGS          , -- 
            ACK_REGS            => O_ACK_REGS          , -- 
            QUEUE_SIZE          => O_RES_QUEUE         , -- 
            RESP_REGS           => O_RES_REGS            -- 
        )                                                -- 
        port map (                                       -- 
        --------------------------------------------------------------------------
        -- Clock and Reset Signals.
        --------------------------------------------------------------------------
            CLK                 => O_CLK               , -- In  :
            CLR                 => O_CLR               , -- In  :
            RST                 => RST                 , -- In  :
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
            REQ_ADDR            => o_req_addr          , -- In  :
            REQ_SIZE            => o_req_size          , -- In  :
            REQ_ID              => O_ID                , -- In  :
            REQ_BURST           => o_req_burst_type    , -- In  :
            REQ_LOCK            => O_LOCK              , -- In  :
            REQ_CACHE           => O_CACHE             , -- In  :
            REQ_PROT            => O_PROT              , -- In  :
            REQ_QOS             => O_QOS               , -- In  :
            REQ_REGION          => O_REGION            , -- In  :
            REQ_BUF_PTR         => o_req_buf_ptr       , -- In  :
            REQ_FIRST           => o_req_first         , -- In  :
            REQ_LAST            => o_req_last          , -- In  :
            REQ_SPECULATIVE     => O_SPECULATIVE       , -- In  :
            REQ_SAFETY          => O_SAFETY            , -- In  :
            REQ_VAL(0)          => o_req_valid         , -- In  :
            REQ_RDY             => o_req_ready         , -- Out :
            XFER_SIZE_SEL       => O_XFER_SIZE_SEL     , -- In  :
        ---------------------------------------------------------------------------
        -- Response Signals.
        ---------------------------------------------------------------------------
            ACK_VAL(0)          => o_ack_valid         , -- Out :
            ACK_ERROR           => o_ack_error         , -- Out :
            ACK_NEXT            => o_ack_next          , -- Out :
            ACK_LAST            => o_ack_last          , -- Out :
            ACK_STOP            => o_ack_stop          , -- Out :
            ACK_NONE            => o_ack_none          , -- Out :
            ACK_SIZE            => o_ack_size          , -- Out :
        ---------------------------------------------------------------------------
        -- Transfer Status Signal.
        ---------------------------------------------------------------------------
            XFER_BUSY(0)        => o_xfer_busy         , -- Out :
            XFER_DONE(0)        => o_xfer_done         , -- Out :
            XFER_ERROR(0)       => o_xfer_error        , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_PAUSE          => o_flow_pause        , -- In  :
            FLOW_STOP           => o_flow_stop         , -- In  :
            FLOW_LAST           => o_flow_last         , -- In  :
            FLOW_SIZE           => o_flow_size         , -- In  :
        ---------------------------------------------------------------------------
        -- Reserve Size Signals.
        ---------------------------------------------------------------------------
            PULL_RSV_VAL(0)     => pull_rsv_valid      , -- Out :
            PULL_RSV_SIZE       => pull_rsv_size       , -- Out :
            PULL_RSV_LAST       => pull_rsv_last       , -- Out :
            PULL_RSV_ERROR      => pull_rsv_error      , -- Out :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            PULL_FIN_VAL(0)     => pull_fin_valid      , -- Out :
            PULL_FIN_SIZE       => pull_fin_size       , -- Out :
            PULL_FIN_LAST       => pull_fin_last       , -- Out :
            PULL_FIN_ERROR      => pull_fin_error      , -- Out :
        ---------------------------------------------------------------------------
        -- Pull Buffer Size Signals.
        ---------------------------------------------------------------------------
            PULL_BUF_RESET(0)   => pull_buf_reset      , -- Out :
            PULL_BUF_VAL(0)     => pull_buf_valid      , -- Out :
            PULL_BUF_SIZE       => pull_buf_size       , -- Out :
            PULL_BUF_LAST       => pull_buf_last       , -- Out :
            PULL_BUF_ERROR      => pull_buf_error      , -- Out :
            PULL_BUF_RDY(0)     => pull_buf_ready      , -- Out :
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_REN             => open                , -- Out :
            BUF_DATA            => buf_rdata           , -- In  :
            BUF_PTR             => buf_rptr              -- Out :
        );
    process (O_CLK, RST) begin
        if (RST = '1') then
                O_AWUSER <= (others => '0');
        elsif (O_CLK'event and O_CLK = '1') then
            if (O_CLR = '1') then
                O_AWUSER <= (others => '0');
            elsif (o_req_valid = '1' and o_req_ready = '1') then
                O_AWUSER <= O_AUSER;
            end if;
        end if;
    end process;
    O_WUSER          <= (others => '0');
    o_req_burst_type <= AXI4_ABURST_FIXED when (O_ADDR_FIX = '1') else AXI4_ABURST_INCR;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    CTRL: PUMP_CONTROLLER                                -- 
        generic map (                                    -- 
            I_CLK_RATE          => I_CLK_RATE          , -- 
            I_REQ_ADDR_VALID    => I_REQ_ADDR_VALID    , -- 
            I_REQ_ADDR_BITS     => I_ADDR_WIDTH        , -- 
            I_REG_ADDR_BITS     => I_REG_ADDR_BITS     , -- 
            I_REQ_SIZE_VALID    => I_REQ_SIZE_VALID    , -- 
            I_REQ_SIZE_BITS     => I_REG_SIZE_BITS     , -- 
            I_REG_SIZE_BITS     => I_REG_SIZE_BITS     , -- 
            I_REG_MODE_BITS     => I_REG_MODE_BITS     , -- 
            I_REG_STAT_BITS     => I_REG_STAT_BITS     , -- 
            I_USE_PUSH_RSV_SIZE => I_USE_PUSH_RSV_SIZE , -- 
            I_USE_PUSH_BUF_SIZE => I_USE_PUSH_BUF_SIZE , -- 
            I_FIXED_FLOW_OPEN   => I_FIXED_FLOW_OPEN   , -- 
            I_FIXED_POOL_OPEN   => I_FIXED_POOL_OPEN   , -- 
            O_CLK_RATE          => O_CLK_RATE          , -- 
            O_REQ_ADDR_VALID    => O_REQ_ADDR_VALID    , -- 
            O_REQ_ADDR_BITS     => O_ADDR_WIDTH        , -- 
            O_REG_ADDR_BITS     => O_REG_ADDR_BITS     , -- 
            O_REQ_SIZE_VALID    => O_REQ_SIZE_VALID    , -- 
            O_REQ_SIZE_BITS     => O_REG_SIZE_BITS     , -- 
            O_REG_SIZE_BITS     => O_REG_SIZE_BITS     , -- 
            O_REG_MODE_BITS     => O_REG_MODE_BITS     , -- 
            O_REG_STAT_BITS     => O_REG_STAT_BITS     , -- 
            O_USE_PULL_RSV_SIZE => O_USE_PULL_RSV_SIZE , -- 
            O_USE_PULL_BUF_SIZE => O_USE_PULL_BUF_SIZE , -- 
            O_FIXED_FLOW_OPEN   => O_FIXED_FLOW_OPEN   , -- 
            O_FIXED_POOL_OPEN   => O_FIXED_POOL_OPEN   , -- 
            BUF_DEPTH           => BUF_DEPTH           , -- 
            I2O_DELAY_CYCLE     => I2O_DELAY_CYCLE       -- 
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        -- Reset Signals.
        ---------------------------------------------------------------------------
            RST                 => RST             , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Clock and Clock Enable.
        ---------------------------------------------------------------------------
            I_CLK               => I_CLK           , -- In  :
            I_CLR               => I_CLR           , -- In  :
            I_CKE               => I_CKE           , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Control Register Interface.
        ---------------------------------------------------------------------------
            I_ADDR_L            => I_ADDR_L        , -- In  :
            I_ADDR_D            => I_ADDR_D        , -- In  :
            I_ADDR_Q            => I_ADDR_Q        , -- Out :
            I_SIZE_L            => I_SIZE_L        , -- In  :
            I_SIZE_D            => I_SIZE_D        , -- In  :
            I_SIZE_Q            => I_SIZE_Q        , -- Out :
            I_MODE_L            => I_MODE_L        , -- In  :
            I_MODE_D            => I_MODE_D        , -- In  :
            I_MODE_Q            => I_MODE_Q        , -- Out :
            I_STAT_L            => I_STAT_L        , -- In  :
            I_STAT_D            => I_STAT_D        , -- In  :
            I_STAT_Q            => I_STAT_Q        , -- Out :
            I_STAT_I            => I_STAT_I        , -- In  :
            I_RESET_L           => I_RESET_L       , -- In  :
            I_RESET_D           => I_RESET_D       , -- In  :
            I_RESET_Q           => I_RESET_Q       , -- Out :
            I_START_L           => I_START_L       , -- In  :
            I_START_D           => I_START_D       , -- In  :
            I_START_Q           => I_START_Q       , -- Out :
            I_STOP_L            => I_STOP_L        , -- In  :
            I_STOP_D            => I_STOP_D        , -- In  :
            I_STOP_Q            => I_STOP_Q        , -- Out :
            I_PAUSE_L           => I_PAUSE_L       , -- In  :
            I_PAUSE_D           => I_PAUSE_D       , -- In  :
            I_PAUSE_Q           => I_PAUSE_Q       , -- Out :
            I_FIRST_L           => I_FIRST_L       , -- In  :
            I_FIRST_D           => I_FIRST_D       , -- In  :
            I_FIRST_Q           => I_FIRST_Q       , -- Out :
            I_LAST_L            => I_LAST_L        , -- In  :
            I_LAST_D            => I_LAST_D        , -- In  :
            I_LAST_Q            => I_LAST_Q        , -- Out :
            I_DONE_EN_L         => I_DONE_EN_L     , -- In  :
            I_DONE_EN_D         => I_DONE_EN_D     , -- In  :
            I_DONE_EN_Q         => I_DONE_EN_Q     , -- Out :
            I_DONE_ST_L         => I_DONE_ST_L     , -- In  :
            I_DONE_ST_D         => I_DONE_ST_D     , -- In  :
            I_DONE_ST_Q         => I_DONE_ST_Q     , -- Out :
            I_ERR_ST_L          => I_ERR_ST_L      , -- In  :
            I_ERR_ST_D          => I_ERR_ST_D      , -- In  :
            I_ERR_ST_Q          => I_ERR_ST_Q      , -- Out :
        ---------------------------------------------------------------------------
        -- Intake Configuration Signals.
        ---------------------------------------------------------------------------
            I_ADDR_FIX          => I_ADDR_FIX        , -- In  :
            I_BUF_READY_LEVEL   => I_BUF_READY_LEVEL , -- In  :
            I_FLOW_READY_LEVEL  => I_FLOW_READY_LEVEL, -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Clock and Clock Enable.
        ---------------------------------------------------------------------------
            O_CLK               => O_CLK           , -- In  :
            O_CLR               => O_CLR           , -- In  :
            O_CKE               => O_CKE           , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Control Register Interface.
        ---------------------------------------------------------------------------
            O_ADDR_L            => O_ADDR_L        , -- In  :
            O_ADDR_D            => O_ADDR_D        , -- In  :
            O_ADDR_Q            => O_ADDR_Q        , -- Out :
            O_SIZE_L            => O_SIZE_L        , -- In  :
            O_SIZE_D            => O_SIZE_D        , -- In  :
            O_SIZE_Q            => O_SIZE_Q        , -- Out :
            O_MODE_L            => O_MODE_L        , -- In  :
            O_MODE_D            => O_MODE_D        , -- In  :
            O_MODE_Q            => O_MODE_Q        , -- Out :
            O_STAT_L            => O_STAT_L        , -- In  :
            O_STAT_D            => O_STAT_D        , -- In  :
            O_STAT_Q            => O_STAT_Q        , -- Out :
            O_STAT_I            => O_STAT_I        , -- In  :
            O_RESET_L           => O_RESET_L       , -- In  :
            O_RESET_D           => O_RESET_D       , -- In  :
            O_RESET_Q           => O_RESET_Q       , -- Out :
            O_START_L           => O_START_L       , -- In  :
            O_START_D           => O_START_D       , -- In  :
            O_START_Q           => O_START_Q       , -- Out :
            O_STOP_L            => O_STOP_L        , -- In  :
            O_STOP_D            => O_STOP_D        , -- In  :
            O_STOP_Q            => O_STOP_Q        , -- Out :
            O_PAUSE_L           => O_PAUSE_L       , -- In  :
            O_PAUSE_D           => O_PAUSE_D       , -- In  :
            O_PAUSE_Q           => O_PAUSE_Q       , -- Out :
            O_FIRST_L           => O_FIRST_L       , -- In  :
            O_FIRST_D           => O_FIRST_D       , -- In  :
            O_FIRST_Q           => O_FIRST_Q       , -- Out :
            O_LAST_L            => O_LAST_L        , -- In  :
            O_LAST_D            => O_LAST_D        , -- In  :
            O_LAST_Q            => O_LAST_Q        , -- Out :
            O_DONE_EN_L         => O_DONE_EN_L     , -- In  :
            O_DONE_EN_D         => O_DONE_EN_D     , -- In  :
            O_DONE_EN_Q         => O_DONE_EN_Q     , -- Out :
            O_DONE_ST_L         => O_DONE_ST_L     , -- In  :
            O_DONE_ST_D         => O_DONE_ST_D     , -- In  :
            O_DONE_ST_Q         => O_DONE_ST_Q     , -- Out :
            O_ERR_ST_L          => O_ERR_ST_L      , -- In  :
            O_ERR_ST_D          => O_ERR_ST_D      , -- In  :
            O_ERR_ST_Q          => O_ERR_ST_Q      , -- Out :
        ---------------------------------------------------------------------------
        -- Intake Configuration Signals.
        ---------------------------------------------------------------------------
            O_ADDR_FIX          => O_ADDR_FIX        , -- In  :
            O_BUF_READY_LEVEL   => O_BUF_READY_LEVEL , -- In  :
            O_FLOW_READY_LEVEL  => O_FLOW_READY_LEVEL, -- In  :
        ---------------------------------------------------------------------------
        -- Intake Transaction Command Request Signals.
        ---------------------------------------------------------------------------
            I_REQ_VALID         => i_req_valid     , -- Out :
            I_REQ_ADDR          => i_req_addr      , -- Out :
            I_REQ_SIZE          => i_req_size      , -- Out :
            I_REQ_BUF_PTR       => i_req_buf_ptr   , -- Out :
            I_REQ_FIRST         => i_req_first     , -- Out :
            I_REQ_LAST          => i_req_last      , -- Out :
            I_REQ_NONE          => i_req_none      , -- Out :
            I_REQ_READY         => i_req_ready     , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Transaction Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            I_ACK_VALID         => i_ack_valid     , -- In  :
            I_ACK_SIZE          => i_ack_size      , -- In  :
            I_ACK_ERROR         => i_ack_error     , -- In  :
            I_ACK_NEXT          => i_ack_next      , -- In  :
            I_ACK_LAST          => i_ack_last      , -- In  :
            I_ACK_STOP          => i_ack_stop      , -- In  :
            I_ACK_NONE          => i_ack_none      , -- In  :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            I_XFER_BUSY         => i_xfer_busy     , -- In  :
            I_XFER_DONE         => i_xfer_done     , -- In  :
            I_XFER_ERROR        => i_xfer_error    , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Flow Control Signals.
        ---------------------------------------------------------------------------
            I_FLOW_PAUSE        => i_flow_pause    , -- Out :
            I_FLOW_STOP         => i_flow_stop     , -- Out :
            I_FLOW_LAST         => i_flow_last     , -- Out :
            I_FLOW_SIZE         => i_flow_size     , -- Out :
            I_PUSH_FIN_VALID    => push_fin_valid  , -- In  :
            I_PUSH_FIN_LAST     => push_fin_last   , -- In  :
            I_PUSH_FIN_ERROR    => push_fin_error  , -- In  :
            I_PUSH_FIN_SIZE     => push_fin_size   , -- In  :
            I_PUSH_RSV_VALID    => push_rsv_valid  , -- In  :
            I_PUSH_RSV_LAST     => push_rsv_last   , -- In  :
            I_PUSH_RSV_ERROR    => push_rsv_error  , -- In  :
            I_PUSH_RSV_SIZE     => push_rsv_size   , -- In  :
            I_PUSH_BUF_RESET    => push_buf_reset  , -- In  :
            I_PUSH_BUF_VALID    => push_buf_valid  , -- In  :
            I_PUSH_BUF_LAST     => push_buf_last   , -- In  :
            I_PUSH_BUF_ERROR    => push_buf_error  , -- In  :
            I_PUSH_BUF_SIZE     => push_buf_size   , -- In  :
            I_PUSH_BUF_READY    => push_buf_ready  , -- Out :
        ---------------------------------------------------------------------------
        -- Intake Status.
        ---------------------------------------------------------------------------
            I_OPEN              => I_OPEN          , -- Out :
            I_RUNNING           => I_RUNNING       , -- Out :
            I_DONE              => I_DONE          , -- Out :
            I_NONE              => I_NONE          , -- Out :
            I_ERROR             => I_ERROR         , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Transaction Command Request Signals.
        ---------------------------------------------------------------------------
            O_REQ_VALID         => o_req_valid     , -- Out :
            O_REQ_ADDR          => o_req_addr      , -- Out :
            O_REQ_SIZE          => o_req_size      , -- Out :
            O_REQ_BUF_PTR       => o_req_buf_ptr   , -- Out :
            O_REQ_FIRST         => o_req_first     , -- Out :
            O_REQ_LAST          => o_req_last      , -- Out :
            O_REQ_NONE          => o_req_none      , -- Out :
            O_REQ_READY         => o_req_ready     , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Transaction Command Response Signals.
        ---------------------------------------------------------------------------
            O_ACK_VALID         => o_ack_valid     , -- In  :
            O_ACK_SIZE          => o_ack_size      , -- In  :
            O_ACK_ERROR         => o_ack_error     , -- In  :
            O_ACK_NEXT          => o_ack_next      , -- In  :
            O_ACK_LAST          => o_ack_last      , -- In  :
            O_ACK_STOP          => o_ack_stop      , -- In  :
            O_ACK_NONE          => o_ack_none      , -- In  :
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
            O_XFER_BUSY         => o_xfer_busy     , -- In  :
            O_XFER_DONE         => o_xfer_done     , -- In  :
            O_XFER_ERROR        => o_xfer_error    , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            O_FLOW_PAUSE        => o_flow_pause    , -- Out :
            O_FLOW_STOP         => o_flow_stop     , -- Out :
            O_FLOW_LAST         => o_flow_last     , -- Out :
            O_FLOW_SIZE         => o_flow_size     , -- Out :
            O_PULL_FIN_VALID    => pull_fin_valid  , -- In  :
            O_PULL_FIN_LAST     => pull_fin_last   , -- In  :
            O_PULL_FIN_ERROR    => pull_fin_error  , -- In  :
            O_PULL_FIN_SIZE     => pull_fin_size   , -- In  :
            O_PULL_RSV_VALID    => pull_rsv_valid  , -- In  :
            O_PULL_RSV_LAST     => pull_rsv_last   , -- In  :
            O_PULL_RSV_ERROR    => pull_rsv_error  , -- In  :
            O_PULL_RSV_SIZE     => pull_rsv_size   , -- In  :
            O_PULL_BUF_RESET    => pull_buf_reset  , -- In  :
            O_PULL_BUF_VALID    => pull_buf_valid  , -- In  :
            O_PULL_BUF_LAST     => pull_buf_last   , -- In  :
            O_PULL_BUF_ERROR    => pull_buf_error  , -- In  :
            O_PULL_BUF_SIZE     => pull_buf_size   , -- In  :
            O_PULL_BUF_READY    => pull_buf_ready  , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Status.
        ---------------------------------------------------------------------------
            O_OPEN              => O_OPEN          , -- Out :
            O_RUNNING           => O_RUNNING       , -- Out :
            O_DONE              => O_DONE          , -- Out :
            O_NONE              => O_NONE          , -- Out :
            O_ERROR             => O_ERROR           -- Out :
        );
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
