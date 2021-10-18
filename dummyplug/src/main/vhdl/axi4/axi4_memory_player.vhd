-----------------------------------------------------------------------------------
--!     @file    axi4_memory_player.vhd
--!     @brief   AXI4 Memory Dummy Plug Player.
--!     @version 1.7.5
--!     @date    2020/10/6
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
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_SIG_VECTOR;
-----------------------------------------------------------------------------------
--! @brief   AXI4 Memory Dummy Plug Player.
-----------------------------------------------------------------------------------
entity  AXI4_MEMORY_PLAYER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        READ_ENABLE     : --! @brief リードトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        WRITE_ENABLE    : --! @brief ライトトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time    := 0 ns;
        WIDTH           : --! @brief AXI4 チャネルの可変長信号のビット幅.
                          AXI4_SIGNAL_WIDTH_TYPE;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                          integer := 8;
        GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                          integer := 8;
        MEMORY_SIZE     : --! @brief メモリの大きさをバイト数で指定する.
                          integer := 4096;
        READ_QUEUE_SIZE : --! @brief リードトランザクションのキューの数を指定する.
                          integer := 8;
        WRITE_QUEUE_SIZE: --! @brief ライトトランザクションのキューの数を指定する.
                          integer := 8;
        DOMAIN_SIZE     : --! @brief ドメインの数を指定する.
                          integer := 8;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        --------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        ARADDR          : in    std_logic_vector(WIDTH.ARADDR -1 downto 0);
        ARLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        ARSIZE          : in    AXI4_ASIZE_TYPE;
        ARBURST         : in    AXI4_ABURST_TYPE;
        ARLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        ARCACHE         : in    AXI4_ACACHE_TYPE;
        ARPROT          : in    AXI4_APROT_TYPE;
        ARQOS           : in    AXI4_AQOS_TYPE;
        ARREGION        : in    AXI4_AREGION_TYPE;
        ARUSER          : in    std_logic_vector(WIDTH.ARUSER -1 downto 0);
        ARID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        ARVALID         : in    std_logic;
        ARREADY         : out   std_logic;
        --------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        --------------------------------------------------------------------------
        RLAST           : out   std_logic;
        RDATA           : out   std_logic_vector(WIDTH.RDATA  -1 downto 0);
        RRESP           : out   AXI4_RESP_TYPE;
        RUSER           : out   std_logic_vector(WIDTH.RUSER  -1 downto 0);
        RID             : out   std_logic_vector(WIDTH.ID     -1 downto 0);
        RVALID          : out   std_logic;
        RREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        AWADDR          : in    std_logic_vector(WIDTH.AWADDR -1 downto 0);
        AWLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        AWSIZE          : in    AXI4_ASIZE_TYPE;
        AWBURST         : in    AXI4_ABURST_TYPE;
        AWLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        AWCACHE         : in    AXI4_ACACHE_TYPE;
        AWPROT          : in    AXI4_APROT_TYPE;
        AWQOS           : in    AXI4_AQOS_TYPE;
        AWREGION        : in    AXI4_AREGION_TYPE;
        AWUSER          : in    std_logic_vector(WIDTH.AWUSER -1 downto 0);
        AWID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        AWVALID         : in    std_logic;
        AWREADY         : out   std_logic;
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
        WLAST           : in    std_logic;
        WDATA           : in    std_logic_vector(WIDTH.WDATA  -1 downto 0);
        WSTRB           : in    std_logic_vector(WIDTH.WDATA/8-1 downto 0);
        WUSER           : in    std_logic_vector(WIDTH.WUSER  -1 downto 0);
        WID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        WVALID          : in    std_logic;
        WREADY          : out   std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BRESP           : out   AXI4_RESP_TYPE;
        BUSER           : out   std_logic_vector(WIDTH.BUSER  -1 downto 0);
        BID             : out   std_logic_vector(WIDTH.ID     -1 downto 0);
        BVALID          : out   std_logic;
        BREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
        --------------------------------------------------------------------------
        -- General Purpose Input 信号
        --------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH    -1 downto 0) := (others => '0');
        --------------------------------------------------------------------------
        -- General Purpose Output 信号
        --------------------------------------------------------------------------
        GPO             : out   std_logic_vector(GPO_WIDTH    -1 downto 0);
        --------------------------------------------------------------------------
        -- レポートステータス出力.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        -- シミュレーション終了通知信号.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end AXI4_MEMORY_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_CORE.all;
use     DUMMY_PLUG.CORE.all;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.all;
use     DUMMY_PLUG.READER.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4 Slave Dummy Plug Player.
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_MEMORY_PLAYER is
    -------------------------------------------------------------------------------
    --! SYNC 制御信号
    -------------------------------------------------------------------------------
    signal    sync_rst          :  std_logic := '0';
    signal    sync_clr          :  std_logic := '0';
    signal    sync_req          :  SYNC_REQ_VECTOR(SYNC'range);
    signal    sync_ack          :  SYNC_ACK_VECTOR(SYNC'range);
    signal    sync_debug        :  boolean   := FALSE;
    -------------------------------------------------------------------------------
    --! 各チャネルの状態出力.
    -------------------------------------------------------------------------------
    signal    reports           :  REPORT_STATUS_VECTOR(1 to 4) := (1 to 4 => REPORT_STATUS_NULL);
    constant  A_REPORT_STATUS   :  integer := 1;
    constant  R_REPORT_STATUS   :  integer := 2;
    constant  W_REPORT_STATUS   :  integer := 3;
    constant  B_REPORT_STATUS   :  integer := 4;
    -------------------------------------------------------------------------------
    --! MAX : 二つの引数を比較して大きい方を選択する関数
    -------------------------------------------------------------------------------
    function  MAX(A,B:integer) return integer is
    begin
        if (A > B) then return A;
        else            return B;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --! アドレス信号のビット幅(WIDTH.ARADDR と WIDTH.AWADDR の大きい方)
    -------------------------------------------------------------------------------
    constant  AADDR_BITS        :  integer := MAX(WIDTH.ARADDR, WIDTH.AWADDR);
    -------------------------------------------------------------------------------
    --! AUSER信号のビット幅(WIDTH.ARUSER と WIDTH.AWUSER の大きい方)
    -------------------------------------------------------------------------------
    constant  AUSER_BITS        :  integer := MAX(1,MAX(WIDTH.ARUSER, WIDTH.AWUSER));
    -------------------------------------------------------------------------------
    --! メモリ宣言
    -------------------------------------------------------------------------------
    type      MEMORY_TYPE       is array(0 to MEMORY_SIZE-1) of std_logic_vector(7 downto 0);
    shared variable  mem        :  MEMORY_TYPE;
    -------------------------------------------------------------------------------
    --! トランザクション情報
    -------------------------------------------------------------------------------
    type      TRAN_INFO_TYPE    is record
                  VALID         :  boolean;
                  DOMAIN        :  integer;
                  RECV_TIME     :  time;
                  COUNT         :  integer;
                  ADDR          :  std_logic_vector(AADDR_BITS-1 downto 0);
                  ALEN          :  std_logic_vector(WIDTH.ALEN-1 downto 0);
                  ASIZE         :  AXI4_ASIZE_TYPE;
                  RESP          :  AXI4_RESP_TYPE;
                  ID            :  integer;
                  USER          :  integer;
                  PTR           :  integer;
                  LATENCY       :  integer;
                  BLK_LENGTH    :  integer;
                  BLK_INTERVAL  :  integer;
                  RESP_DELAY    :  integer;
                  TIMEOUT       :  integer;
    end record;
    constant  TRAN_INFO_NULL    :  TRAN_INFO_TYPE := (
                  VALID         => FALSE,
                  DOMAIN        => 0,
                  COUNT         => 0,
                  RECV_TIME     => 0 ns,
                  ADDR          => (others => '0'),
                  ALEN          => (others => '0'),
                  ASIZE         => (others => '0'),
                  RESP          => (others => '0'),
                  ID            => 0,
                  USER          => 0,
                  PTR           => 0,
                  LATENCY       => 0,
                  BLK_LENGTH    => 0,
                  BLK_INTERVAL  => 0,
                  RESP_DELAY    => 0,
                  TIMEOUT       => 0
    );
    type      TRAN_INFO_VECTOR  is array(integer range <>) of TRAN_INFO_TYPE;
    -------------------------------------------------------------------------------
    --! トランザクションキューサブプログラム
    -------------------------------------------------------------------------------
    procedure TRAN_QUEUE_PROC(
        signal    QUEUE         :  inout TRAN_INFO_VECTOR;
                  CLEAR         :  in    boolean;
                  I_INFO        :  in    TRAN_INFO_TYPE;
                  I_VALID       :  in    boolean;
                  I_READY       :  in    boolean;
                  O_VALID       :  in    boolean;
                  O_READY       :  in    boolean
    ) is
        variable  next_queue    :        TRAN_INFO_VECTOR(QUEUE'range);
    begin
        if (CLEAR = TRUE) then
            next_queue := (others => TRAN_INFO_NULL);
            QUEUE <= next_queue;
        else
            next_queue := QUEUE;
            for i in next_queue'low to next_queue'high loop
                if (next_queue(i).VALID) then
                    next_queue(i).COUNT := next_queue(i).COUNT + 1;
                end if;
            end loop;
            if (O_VALID = TRUE and O_READY = TRUE) then
                O_LOOP: for i in next_queue'low to next_queue'high loop
                    if (i < next_queue'high) then
                        next_queue(i) := next_queue(i+1);
                    else
                        next_queue(i) := TRAN_INFO_NULL;
                    end if;
                end loop;
            end if;
            if (I_VALID = TRUE and I_READY = TRUE) then
                I_LOOP: for i in next_queue'low to next_queue'high loop
                    if (next_queue(i).VALID = FALSE) then
                        next_queue(i)           := I_INFO;
                        next_queue(i).VALID     := TRUE;
                        next_queue(i).COUNT     := 0;
                        next_queue(i).RECV_TIME := Now;
                        exit I_LOOP;
                    end if;
                end loop;
            end if;
            QUEUE <= next_queue;
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! リードトランザクションリクエスト
    -------------------------------------------------------------------------------
    signal    r_tran_info       :  TRAN_INFO_TYPE;
    signal    r_tran_valid      :  boolean;
    signal    r_tran_ready      :  boolean;
    signal    r_tran_clear      :  boolean;
    signal    r_tran_busy       :  boolean;
    -------------------------------------------------------------------------------
    --! ライトトランザクションリクエスト
    -------------------------------------------------------------------------------
    signal    w_tran_info       :  TRAN_INFO_TYPE;
    signal    w_tran_valid      :  boolean;
    signal    w_tran_ready      :  boolean;
    signal    w_tran_clear      :  boolean;
    signal    w_tran_busy       :  boolean;
    -------------------------------------------------------------------------------
    --! ライトトランザクション応答リクエスト
    -------------------------------------------------------------------------------
    signal    b_tran_info       :  TRAN_INFO_TYPE;
    signal    b_tran_valid      :  boolean;
    signal    b_tran_ready      :  boolean;
    signal    b_tran_clear      :  boolean;
    signal    b_tran_busy       :  boolean;
    -------------------------------------------------------------------------------
    --! @brief トランザクション情報からアドレスの下位ビットと１ワードのバイト数を生成
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    tran_info   トランザクション情報
    --! @param    lo_addr     アドレスの下位ビットの整数値.
    --! @param    word_bytes  １ワードのバイト数.
    -------------------------------------------------------------------------------
    procedure TRAN_INFO_READ(
        variable  TRAN_INFO     : in    TRAN_INFO_TYPE;
        constant  DATA_WIDTH    : in    integer;
        variable  ASIZE_BYTES   : inout integer;
        variable  BURST_LEN     : inout integer;
        variable  LOWER_LANE    : inout integer;
        variable  UPPER_LANE    : inout integer;
        variable  MEM_POS       : inout integer;
        variable  BOUNDARY_ERROR: out   boolean
    ) is
        variable  aligned_addr  :       integer;
        variable  boundary_addr :       integer;
    begin
        case tran_info.ASIZE is
            when AXI4_ASIZE_1BYTE   => ASIZE_BYTES :=   1; aligned_addr := 0;
            when AXI4_ASIZE_2BYTE   => ASIZE_BYTES :=   2; aligned_addr := TRAN_INFO.PTR mod   2;
            when AXI4_ASIZE_4BYTE   => ASIZE_BYTES :=   4; aligned_addr := TRAN_INFO.PTR mod   4;
            when AXI4_ASIZE_8BYTE   => ASIZE_BYTES :=   8; aligned_addr := TRAN_INFO.PTR mod   8;
            when AXI4_ASIZE_16BYTE  => ASIZE_BYTES :=  16; aligned_addr := TRAN_INFO.PTR mod  16;
            when AXI4_ASIZE_32BYTE  => ASIZE_BYTES :=  32; aligned_addr := TRAN_INFO.PTR mod  32;
            when AXI4_ASIZE_64BYTE  => ASIZE_BYTES :=  64; aligned_addr := TRAN_INFO.PTR mod  64;
            when AXI4_ASIZE_128BYTE => ASIZE_BYTES := 128; aligned_addr := TRAN_INFO.PTR mod 128;
            when others             => ASIZE_BYTES :=   0; aligned_addr := 0;
        end case;
        case DATA_WIDTH is
            when   16   => LOWER_LANE := TRAN_INFO.PTR mod   2;
            when   32   => LOWER_LANE := TRAN_INFO.PTR mod   4;
            when   64   => LOWER_LANE := TRAN_INFO.PTR mod   8;
            when  128   => LOWER_LANE := TRAN_INFO.PTR mod  16;
            when  256   => LOWER_LANE := TRAN_INFO.PTR mod  32;
            when  512   => LOWER_LANE := TRAN_INFO.PTR mod  64;
            when 1024   => LOWER_LANE := TRAN_INFO.PTR mod 128;
            when others => LOWER_LANE := 0;
        end case;
        BURST_LEN  := TO_INTEGER(unsigned(TRAN_INFO.ALEN)) + 1;
        MEM_POS    := TRAN_INFO.PTR;
        if (ASIZE_BYTES - aligned_addr > MEMORY_SIZE) then
            UPPER_LANE := LOWER_LANE + MEMORY_SIZE - 1;
        else
            UPPER_LANE := LOWER_LANE + ASIZE_BYTES - aligned_addr - 1;
        end if;
        boundary_addr  := TO_INTEGER(unsigned(TRAN_INFO.ADDR(11 downto 0)));
        BOUNDARY_ERROR := ((boundary_addr + ASIZE_BYTES * BURST_LEN) > 4096);
    end procedure;
    -------------------------------------------------------------------------------
    --! ドメイン情報
    -------------------------------------------------------------------------------
    type      DOMAIN_TYPE    is record
                  READ_ENABLE   :  boolean;
                  WRITE_ENABLE  :  boolean;
                  MIN_ADDR      :  unsigned(AADDR_BITS-1 downto 0);
                  MAX_ADDR      :  unsigned(AADDR_BITS-1 downto 0);
                  RESP          :  AXI4_RESP_TYPE;
                  USER          :  integer;
                  MEM_BASE      :  integer;
                  LATENCY       :  integer;
                  BLK_LENGTH    :  integer;
                  BLK_INTERVAL  :  integer;
                  RESP_DELAY    :  integer;
                  TIMEOUT       :  integer;
                  ASIZE         :  AXI4_ASIZE_TYPE;
                  ABURST        :  AXI4_ABURST_TYPE;
                  ALOCK         :  std_logic_vector(WIDTH.ALOCK-1 downto 0);
                  ACACHE        :  AXI4_ACACHE_TYPE;
                  APROT         :  AXI4_APROT_TYPE;
                  AQOS          :  AXI4_AQOS_TYPE;
                  AREGION       :  AXI4_AREGION_TYPE;
                  AUSER         :  std_logic_vector(AUSER_BITS -1 downto 0);
                  AID           :  std_logic_vector(WIDTH.ID   -1 downto 0);
    end record;
    constant  DOMAIN_NULL       :  DOMAIN_TYPE := (
                  READ_ENABLE   => FALSE,
                  WRITE_ENABLE  => FALSE,
                  MIN_ADDR      => to_unsigned(0            , AADDR_BITS),
                  MAX_ADDR      => to_unsigned(MEMORY_SIZE-1, AADDR_BITS),
                  RESP          => AXI4_RESP_OKAY,
                  USER          => 0,
                  MEM_BASE      => 0,
                  LATENCY       => 0,
                  BLK_LENGTH    => 1,
                  BLK_INTERVAL  => 0,
                  RESP_DELAY    => 0,
                  TIMEOUT       => 100000,
                  ASIZE         => (others => '-'),
                  ABURST        => AXI4_ABURST_INCR,
                  ALOCK         => (others => '-'),
                  ACACHE        => (others => '-'),
                  APROT         => (others => '-'),
                  AQOS          => (others => '-'),
                  AREGION       => (others => '-'),
                  AUSER         => (others => '-'),
                  AID           => (others => '-')
    );
    type      DOMAIN_VECTOR     is array(integer range <>) of DOMAIN_TYPE;
    signal    domains           :  DOMAIN_VECTOR(0 to DOMAIN_SIZE-1);
    signal    enable            :  boolean;
    -------------------------------------------------------------------------------
    --! アドレスチャネルをデコードしてトランザクション情報を生成する関数
    -------------------------------------------------------------------------------
    function  DECODE_ADDR_CHANNEL(
                  ENABLE        :  boolean;
                  DOMAINS       :  DOMAIN_VECTOR;
                  AWRITE        :  boolean;
                  AADDR         :  std_logic_vector;
                  ALEN          :  std_logic_vector;
                  ASIZE         :  AXI4_ASIZE_TYPE;
                  ABURST        :  AXI4_ABURST_TYPE;
                  ALOCK         :  std_logic_vector;
                  ACACHE        :  AXI4_ACACHE_TYPE;
                  APROT         :  AXI4_APROT_TYPE;
                  AQOS          :  AXI4_AQOS_TYPE;
                  AREGION       :  AXI4_AREGION_TYPE;
                  AUSER         :  std_logic_vector;
                  AID           :  std_logic_vector)
                  return           TRAN_INFO_TYPE
    is
        variable  axi_addr      :  unsigned(AADDR'length-1 downto 0);
        variable  tran_info     :  TRAN_INFO_TYPE;
        variable  match         :  boolean;
    begin
        tran_info        := TRAN_INFO_NULL;
        tran_info.VALID  := TRUE;
        tran_info.DOMAIN := DOMAINS'high + 1;
        tran_info.ALEN   := ALEN;
        tran_info.ASIZE  := ASIZE;
        tran_info.RESP   := AXI4_RESP_DECERR;
        tran_info.ID     := to_integer(to_01(unsigned(AID)));
        if ENABLE = TRUE then
            axi_addr := to_01(unsigned(AADDR));
            for i in DOMAINS'high downto DOMAINS'low loop
                match := (AWRITE = TRUE  and DOMAINS(i).WRITE_ENABLE = TRUE) or
                         (AWRITE = FALSE and DOMAINS(i).READ_ENABLE  = TRUE);
                if (match) then
                    match := match and ((axi_addr >= DOMAINS(i).MIN_ADDR(AADDR'range)) and
                                        (axi_addr <= DOMAINS(i).MAX_ADDR(AADDR'range)));
                    match := match and MATCH_STD_LOGIC(DOMAINS(i).ASIZE             , ASIZE  );
                    match := match and MATCH_STD_LOGIC(DOMAINS(i).ABURST            , ABURST );
                    match := match and MATCH_STD_LOGIC(DOMAINS(i).ALOCK             , ALOCK  );
                    match := match and MATCH_STD_LOGIC(DOMAINS(i).ACACHE            , ACACHE );
                    match := match and MATCH_STD_LOGIC(DOMAINS(i).APROT             , APROT  );
                    match := match and MATCH_STD_LOGIC(DOMAINS(i).AQOS              , AQOS   );
                    match := match and MATCH_STD_LOGIC(DOMAINS(i).AREGION           , AREGION);
                    match := match and MATCH_STD_LOGIC(DOMAINS(i).AUSER(AUSER'range), AUSER  );
                    match := match and MATCH_STD_LOGIC(DOMAINS(i).AID  (AID  'range), AID    );
                end if;
                if (match) then
                    for bit in 0 to AADDR_BITS-1 loop
                        if bit <= AADDR'high then
                            tran_info.ADDR(bit) := AADDR(bit);
                        else
                            tran_info.ADDR(bit) := '0';
                        end if;
                    end loop;
                    tran_info.VALID        := TRUE;
                    tran_info.DOMAIN       := i;
                    tran_info.ALEN         := ALEN;
                    tran_info.ASIZE        := ASIZE;
                    tran_info.RESP         := DOMAINS(i).RESP;
                    tran_info.ID           := to_integer(to_01(unsigned(AID)));
                    tran_info.USER         := DOMAINS(i).USER;
                    tran_info.PTR          := DOMAINS(i).MEM_BASE + to_integer(axi_addr - DOMAINS(i).MIN_ADDR(AADDR'range));
                    tran_info.LATENCY      := DOMAINS(i).LATENCY;
                    tran_info.BLK_LENGTH   := DOMAINS(i).BLK_LENGTH;
                    tran_info.BLK_INTERVAL := DOMAINS(i).BLK_INTERVAL;
                    tran_info.RESP_DELAY   := DOMAINS(i).RESP_DELAY;
                    tran_info.TIMEOUT      := DOMAINS(i).TIMEOUT;
                    exit;
                end if;
            end loop;
        end if;
        return tran_info;
    end function;
    -------------------------------------------------------------------------------
    -- キーワードの定義.
    -------------------------------------------------------------------------------
    subtype   KEY_TYPE is STRING(1 to 7);
    constant  KEY_NULL      : KEY_TYPE := "       ";
    constant  KEY_SAY       : KEY_TYPE := "SAY    ";
    constant  KEY_SYNC      : KEY_TYPE := "SYNC   ";
    constant  KEY_START     : KEY_TYPE := "START  ";
    constant  KEY_STOP      : KEY_TYPE := "STOP   ";
    constant  KEY_WAIT      : KEY_TYPE := "WAIT   ";
    constant  KEY_CHECK     : KEY_TYPE := "CHECK  ";
    constant  KEY_SET       : KEY_TYPE := "SET    ";
    constant  KEY_FILL      : KEY_TYPE := "FILL   ";
    constant  KEY_ORG       : KEY_TYPE := "ORG    ";
    constant  KEY_DATA      : KEY_TYPE := "DATA   ";
    constant  KEY_DB        : KEY_TYPE := "DB     ";
    constant  KEY_DH        : KEY_TYPE := "DH     ";
    constant  KEY_DW        : KEY_TYPE := "DW     ";
    constant  KEY_DD        : KEY_TYPE := "DD     ";
    constant  KEY_OUT       : KEY_TYPE := "OUT    ";
    constant  KEY_DEBUG     : KEY_TYPE := "DEBUG  ";
    constant  KEY_REPORT    : KEY_TYPE := "REPORT ";
    constant  KEY_TIMEOUT   : KEY_TYPE := "TIMEOUT";
    constant  KEY_DOMAIN    : KEY_TYPE := "DOMAIN ";
    constant  KEY_INDEX     : KEY_TYPE := "INDEX  ";
    constant  KEY_MAP       : KEY_TYPE := "MAP    ";
    constant  KEY_READ      : KEY_TYPE := "READ   ";
    constant  KEY_WRITE     : KEY_TYPE := "WRITE  ";
    constant  KEY_ADDR      : KEY_TYPE := "ADDR   ";
    constant  KEY_LAST      : KEY_TYPE := "LAST   ";
    constant  KEY_SIZE      : KEY_TYPE := "SIZE   ";
    constant  KEY_ASIZE     : KEY_TYPE := "ASIZE  ";
    constant  KEY_ALOCK     : KEY_TYPE := "ALOCK  ";
    constant  KEY_ACACHE    : KEY_TYPE := "ACACHE ";
    constant  KEY_APROT     : KEY_TYPE := "APROT  ";
    constant  KEY_AQOS      : KEY_TYPE := "AQOS   ";
    constant  KEY_AREGION   : KEY_TYPE := "AREGION";
    constant  KEY_AUSER     : KEY_TYPE := "AUSER  ";
    constant  KEY_AID       : KEY_TYPE := "AID    ";
    constant  KEY_USER      : KEY_TYPE := "USER   ";
    constant  KEY_RESP      : KEY_TYPE := "RESP   ";
    constant  KEY_LATENCY   : KEY_TYPE := "LATENCY";
    constant  KEY_BLEN      : KEY_TYPE := "BLEN   ";
    constant  KEY_BINTER    : KEY_TYPE := "BINTER ";
    constant  KEY_RDELAY    : KEY_TYPE := "RDELAY ";
    constant  KEY_OKAY      : KEY_TYPE := "OKAY   ";
    constant  KEY_EXOKAY    : KEY_TYPE := "EXOKAY ";
    constant  KEY_SLVERR    : KEY_TYPE := "SLVERR ";
    constant  KEY_DECERR    : KEY_TYPE := "DECERR ";
begin
    -------------------------------------------------------------------------------
    -- メインブロック
    -------------------------------------------------------------------------------
    MAIN: process
        ---------------------------------------------------------------------------
        -- 各種変数の定義.
        ---------------------------------------------------------------------------
        file      stream        :  TEXT;
        variable  core          :  CORE_TYPE;
        variable  operation     :  OPERATION_TYPE;
        variable  keyword       :  KEY_TYPE;
        variable  gpo_signals   :  std_logic_vector(GPO'range);
        variable  sync_io       :  boolean;
        variable  mem_addr      :  integer;
        type      MEM_MODE_TYPE is (MEM_SET_MODE, MEM_FILL_MODE, MEM_CHECK_MODE);
        variable  mem_mode      :  MEM_MODE_TYPE;
        variable  mem_fill_size :  integer := 1;
        ---------------------------------------------------------------------------
        --! @brief  SYNCオペレーション. 
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        --! @param    OPERATION   オペレーション.
        ---------------------------------------------------------------------------
        procedure execute_sync(
            variable  core      :  inout CORE_TYPE;
            file      stream    :        TEXT;
                      operation :  in    OPERATION_TYPE
        ) is
            constant  proc_name :  string := "EXECUTE_SYNC";
            variable  port_num  :  integer;
            variable  wait_num  :  integer;
        begin
            REPORT_DEBUG  (core, proc_name, "BEGIN");
            READ_SYNC_ARGS(core, stream, operation, port_num, wait_num);
            REPORT_DEBUG  (core, proc_name, "PORT=" & INTEGER_TO_STRING(port_num) &
                                           " WAIT=" & INTEGER_TO_STRING(wait_num));
            if (SYNC_REQ'low <= port_num and port_num <= SYNC_REQ'high) then
                CORE_SYNC(core, port_num, wait_num, SYNC_REQ, SYNC_ACK);
            end if;
            REPORT_DEBUG  (core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  STARTオペレーション. 
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        --! @param    OPERATION   オペレーション.
        ---------------------------------------------------------------------------
        procedure execute_start(
            variable  core      :  inout CORE_TYPE;
            file      stream    :        TEXT;
                      operation :  in    OPERATION_TYPE
        ) is
            constant  proc_name :  string := "EXECUTE_START";
            variable  port_num  :  integer;
            variable  wait_num  :  integer;
        begin
            REPORT_DEBUG  (core, proc_name, "BEGIN");
            enable <= TRUE;
            REPORT_DEBUG  (core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  STOPオペレーション. 
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        --! @param    OPERATION   オペレーション.
        ---------------------------------------------------------------------------
        procedure execute_stop(
            variable  core      :  inout CORE_TYPE;
            file      stream    :        TEXT;
                      operation :  in    OPERATION_TYPE
        ) is
            constant  proc_name :  string := "EXECUTE_START";
            variable  port_num  :  integer;
            variable  wait_num  :  integer;
        begin
            REPORT_DEBUG  (core, proc_name, "BEGIN");
            enable <= FALSE;
            REPORT_DEBUG  (core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  WAITオペレーション. 指定された条件まで待機.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        ---------------------------------------------------------------------------
        procedure execute_wait(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT;
                      sync_io        :  inout boolean
        ) is
            constant  proc_name      :  string := "EXECUTE_WAIT";
            variable  next_event     :  EVENT_TYPE;
            variable  keyword        :  KEY_TYPE;
            variable  wait_count     :  integer;
            variable  scan_len       :  integer;
            variable  timeout        :  integer;
            variable  wait_on        :  boolean;
            variable  gpi_match      :  boolean;
            variable  gpi_signals    :  std_logic_vector(GPI'range);
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            timeout   := DEFAULT_WAIT_TIMEOUT;
            wait_on   := FALSE;
            sync_io   := FALSE;
            SEEK_EVENT(core, stream, next_event);
            case next_event is
                when EVENT_SCALAR =>
                    READ_EVENT(core, stream, EVENT_SCALAR);
                    STRING_TO_INTEGER(
                        STR     => core.str_buf(1 to core.str_len),
                        VAL     => wait_count,
                        STR_LEN => scan_len
                    );
                    if (scan_len = 0) then
                        wait_count := 1;
                    end if;
                    if (wait_count > 0) then
                        for i in 1 to wait_count loop
                            wait until (ACLK'event and ACLK = '1');
                        end loop;
                    end if;
                    wait_count := 0;
                when EVENT_MAP_BEGIN =>
                    READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                    gpi_signals := (others => '-');
                    MAP_READ_LOOP: loop
                        REPORT_DEBUG(core, proc_name, "MAP_READ_LOOP");
                        MAP_READ_PREPARE_FOR_NEXT(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        MAP_READ_STD_LOGIC_VECTOR(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            KEY        => "GPI"           ,  -- In :
                            VAL        => gpi_signals     ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        MAP_READ_INTEGER(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            KEY        => "TIMEOUT"       ,  -- In :
                            VAL        => timeout         ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        MAP_READ_BOOLEAN(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            KEY        => "ON"            ,  -- In :
                            VAL        => wait_on         ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        MAP_READ_BOOLEAN(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            KEY        => "SYNC"          ,  -- In :
                            VAL        => sync_io         ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        case next_event is
                            when EVENT_SCALAR  =>
                                COPY_KEY_WORD(core, keyword);
                                EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                            when EVENT_MAP_END =>
                                exit MAP_READ_LOOP;
                            when others        =>
                                READ_ERROR(core, proc_name, "need EVENT_MAP_END but " &
                                           EVENT_TO_STRING(next_event));
                        end case;
                    end loop;
                    if (wait_on) then
                        SIG_LOOP:loop
                            REPORT_DEBUG(core, proc_name, "SIG_LOOP");
                            wait on GPI;
                            gpi_match := MATCH_STD_LOGIC(gpi_signals, GPI);
                            exit when(gpi_match);
                            if (ACLK'event and ACLK = '1') then
                                if (timeout > 0) then
                                    timeout := timeout - 1;
                                else
                                    EXECUTE_ABORT(core, proc_name, "Time Out!");
                                end if;
                            end if;
                        end loop;
                    else
                        CLK_LOOP:loop
                            REPORT_DEBUG(core, proc_name, "CLK_LOOP");
                            wait until (ACLK'event and ACLK = '1');
                            gpi_match := MATCH_STD_LOGIC(gpi_signals, GPI);
                            exit when(gpi_match);
                            if (timeout > 0) then
                                timeout := timeout - 1;
                            else
                                EXECUTE_ABORT(core, proc_name, "Time Out!");
                            end if;
                        end loop;
                    end if;
                when others =>
                    READ_ERROR(core, proc_name, "SEEK_EVENT NG");
            end case;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  シナリオのマップから DOMAIN の値を読み取るサブプログラム
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        --! @param    domain      読み取った DOMAIN の値. inoutであることに注意.
        --! @param    index       読み取った INDEX の値. inoutであることに注意.
        --! @param    EVENT       次のイベント. inoutであることに注意.
        ---------------------------------------------------------------------------
        procedure map_read_domain(
            variable  core          :  inout CORE_TYPE;
            file      stream        :        TEXT;
                      domain        :  inout DOMAIN_TYPE;
                      index         :  inout integer;
                      event         :  inout EVENT_TYPE
        ) is
            constant  proc_name     :  string := "MAP_READ_DOMAIN";
            variable  next_event    :  EVENT_TYPE;
            variable  key_word      :  KEY_TYPE;
            variable  range_base    :  std_logic_vector(AADDR_BITS-1 downto 0) := (others => '0');
            variable  range_last    :  std_logic_vector(AADDR_BITS-1 downto 0) := (others => '0');
            variable  range_size    :  integer := 0;
            -----------------------------------------------------------------------
            --! @brief シナリオからトランザクション応答ステータスの値を読み取るサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
            --! @param    core        コア変数.
            --! @param    stream      シナリオのストリーム.
            --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
            --! @param    val         読み取ったトランザクション応答ステータスの値.
            -----------------------------------------------------------------------
            procedure read_axi4_resp(
                          val           : inout AXI4_RESP_TYPE
            ) is
                variable  key_word      :       KEY_TYPE;
                variable  next_event    :       EVENT_TYPE;
            begin
                SEEK_EVENT(core, stream, next_event);
                if (next_event = EVENT_SCALAR) then
                    READ_EVENT(core, stream, EVENT_SCALAR);
                    COPY_KEY_WORD(core, key_word);
                    case key_word is
                        when KEY_OKAY    => val := AXI4_RESP_OKAY  ;
                        when KEY_EXOKAY  => val := AXI4_RESP_EXOKAY;
                        when KEY_SLVERR  => val := AXI4_RESP_SLVERR;
                        when KEY_DECERR  => val := AXI4_RESP_DECERR;
                        when others      => READ_ERROR(core, proc_name, "KEY=RESP illegal key_word=" & key_word);
                    end case;
                else
                    READ_ERROR(core, proc_name, "KEY=RESP SEEK_EVENT NG");
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief シナリオから std_logic_vector の値を読み取るサブプログラム
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
            --! @param    core        コア変数.
            --! @param    stream      シナリオのストリーム.
            --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
            --! @param    val         読み取ったトランザクション応答ステータスの値.
            -----------------------------------------------------------------------
            procedure read_value(val: inout std_logic_vector) is
                variable  next_event    : EVENT_TYPE;
                variable  read_len      : integer;
                variable  val_size      : integer;
            begin
                SEEK_EVENT(core, stream, next_event  );
                if (next_event /= EVENT_SCALAR) then
                    READ_ERROR(core, proc_name, "READ_VALUE NG");
                end if;
                READ_EVENT(core, stream, EVENT_SCALAR);
                STRING_TO_STD_LOGIC_VECTOR(
                    STR     => core.str_buf(1 to core.str_len),
                    VAL     => val,
                    STR_LEN => read_len,
                    VAL_LEN => val_size
                );
            end procedure;
            -----------------------------------------------------------------------
            --! @brief シナリオから integer の値を読み取るサブプログラム
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
            --! @param    core        コア変数.
            --! @param    stream      シナリオのストリーム.
            --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
            --! @param    val         読み取ったトランザクション応答ステータスの値.
            -----------------------------------------------------------------------
            procedure read_value(val: inout integer) is
                variable  next_event    : EVENT_TYPE;
                variable  good          : boolean;
            begin
                SEEK_EVENT(core, stream, next_event  );
                if (next_event /= EVENT_SCALAR) then
                    READ_ERROR(core, proc_name, "READ_VALUE NG");
                end if;
                READ_INTEGER(core, stream, val, good);
            end procedure;
            -----------------------------------------------------------------------
            --! @brief シナリオから boolean の値を読み取るサブプログラム
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
            --! @param    core        コア変数.
            --! @param    stream      シナリオのストリーム.
            --! @param    proc_name   プロシージャ名.リードエラー発生時に出力する.
            --! @param    val         読み取ったトランザクション応答ステータスの値.
            -----------------------------------------------------------------------
            procedure read_value(val: inout boolean) is
                variable  next_event    : EVENT_TYPE;
                variable  good          : boolean;
            begin
                SEEK_EVENT(core, stream, next_event  );
                if (next_event /= EVENT_SCALAR) then
                    READ_ERROR(core, proc_name, "READ_VALUE NG");
                end if;
                READ_BOOLEAN(core, stream, val, good);
            end procedure;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            next_event := event;
            READ_MAP_LOOP: loop
                case next_event is
                    when EVENT_SCALAR  =>
                        COPY_KEY_WORD(core, key_word);
                        REPORT_DEBUG(core, proc_name, "KEY=" & key_word);
                        case key_word is
                            when KEY_INDEX   => read_value    (index              );
                            when KEY_READ    => read_value    (domain.READ_ENABLE );
                            when KEY_WRITE   => read_value    (domain.WRITE_ENABLE);
                            when KEY_MAP     => read_value    (domain.MEM_BASE    );
                            when KEY_ADDR    => read_value    (range_base         );
                            when KEY_LAST    => read_value    (range_last         );
                            when KEY_SIZE    => read_value    (range_size         );
                            when KEY_RESP    => read_axi4_resp(domain.RESP        );
                            when KEY_USER    => read_value    (domain.USER        );
                            when KEY_LATENCY => read_value    (domain.LATENCY     );
                            when KEY_BLEN    => read_value    (domain.BLK_LENGTH  );
                            when KEY_BINTER  => read_value    (domain.BLK_INTERVAL);
                            when KEY_RDELAY  => read_value    (domain.RESP_DELAY  );
                            when KEY_TIMEOUT => read_value    (domain.TIMEOUT     );
                            when KEY_ASIZE   => read_value    (domain.ASIZE       );
                            when KEY_ALOCK   => read_value    (domain.ALOCK       );
                            when KEY_ACACHE  => read_value    (domain.ACACHE      );
                            when KEY_APROT   => read_value    (domain.APROT       );
                            when KEY_AQOS    => read_value    (domain.AQOS        );
                            when KEY_AREGION => read_value    (domain.AREGION     );
                            when KEY_AUSER   => read_value    (domain.AUSER       );
                            when KEY_AID     => read_value    (domain.AID         );
                            when others      => exit READ_MAP_LOOP;
                        end case;
                    when EVENT_MAP_END       => exit READ_MAP_LOOP;
                    when others              => exit READ_MAP_LOOP;
                end case;
                SEEK_EVENT(core, stream, next_event);
                if (next_event = EVENT_SCALAR) then
                    READ_EVENT(core, stream, EVENT_SCALAR);
                end if;
            end loop;
            if    (range_size > 0) then
                domain.MIN_ADDR := unsigned(range_base);
                domain.MAX_ADDR := unsigned(range_base) + range_size - 1;
            elsif (unsigned(range_last) > 0) then
                domain.MIN_ADDR := unsigned(range_base);
                domain.MAX_ADDR := unsigned(range_last);
            else
                EXECUTE_ABORT(core, proc_name, "Domain Address Range Error");
            end if;
            event := next_event;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  DOMAINオペレーション. 
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        ---------------------------------------------------------------------------
        procedure execute_domain(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT
        ) is
            constant  proc_name      :  string := "EXECUTE_DOMAIN";
            variable  next_event     :  EVENT_TYPE;
            variable  keyword        :  KEY_TYPE;
            variable  domain         :  DOMAIN_TYPE;
            variable  index          :  integer;
            variable  scan_len       :  integer;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            domain := DOMAIN_NULL;
            domain.READ_ENABLE  := TRUE;
            domain.WRITE_ENABLE := TRUE;
            case next_event is
                when EVENT_MAP_BEGIN =>
                    READ_EVENT(core, stream, EVENT_MAP_BEGIN);
                    MAP_READ_LOOP: loop
                        REPORT_DEBUG(core, proc_name, "MAP_READ_LOOP");
                        MAP_READ_PREPARE_FOR_NEXT(
                            SELF       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        map_read_domain(
                            CORE       => core            ,  -- I/O:
                            STREAM     => stream          ,  -- I/O:
                            DOMAIN     => domain          ,  -- I/O:
                            INDEX      => index           ,  -- I/O:
                            EVENT      => next_event         -- I/O:
                        );
                        case next_event is
                            when EVENT_SCALAR  =>
                                COPY_KEY_WORD(core, keyword);
                                EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                            when EVENT_MAP_END =>
                                exit MAP_READ_LOOP;
                            when others        =>
                                READ_ERROR(core, proc_name, "need EVENT_MAP_END but " &
                                           EVENT_TO_STRING(next_event));
                        end case;
                    end loop;
                when others =>
                    READ_ERROR(core, proc_name, "SEEK_EVENT NG");
            end case;
            if (index >= domains'low and index <= domains'high) then
                domains(index) <= domain;
            else
                EXECUTE_ABORT(core, proc_name, "Domain Index Error");
            end if;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  SETオペレーション. 
        --!         ORG/DB/DH/DW/DD/DATA オペレーション実行時に MEM SET をすることを
        --!         指定する
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        ---------------------------------------------------------------------------
        procedure execute_set(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT
        ) is
            constant  proc_name      :  string := "EXECUTE_SET";
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            mem_mode := MEM_SET_MODE;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  FILL オペレーション. 
        --!         FILL の回数を指定する
        --!         指定されたFILL回数は mem_fill_size 変数に格納される.
        --!         ORG/DB/DH/DW/DD/DATA オペレーション実行時に MEM SET をすることを
        --!         指定する
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        ---------------------------------------------------------------------------
        procedure execute_fill(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT
        ) is
            constant  proc_name      :  string := "EXECUTE_FILL";
            variable  next_event     :  EVENT_TYPE;
            variable  good           :  boolean;
            variable  size           :  integer;
        begin 
            REPORT_DEBUG(core, proc_name, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            READ_INTEGER(core, stream, size, good);
            if (good = FALSE) then
                READ_ERROR(core, proc_name, "READ_INTEGER not good");
            end if;
            if (size < 1) then
                READ_ERROR(core, proc_name, "FILL SIZE less than 1");
            end if;
            mem_mode := MEM_FILL_MODE;
            mem_fill_size := size;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  CHECKオペレーション. 
        --!         ORG/DB/DH/DW/DD/DATA オペレーション実行時に CHECK をすることを
        --!         指定する
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        ---------------------------------------------------------------------------
        procedure execute_check(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT
        ) is
            constant  proc_name      :  string := "EXECUTE_CHECK";
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            mem_mode := MEM_CHECK_MODE;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  シナリオで指定された値を mem_addr で指定された開始アドレスから
        --!         mem に書き込むサブプログラム
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        --! @param    data_size   データのサイズをバイト単位で指定する.
        ---------------------------------------------------------------------------
        procedure mem_set(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT     ;
                      data_size      :  in    integer
        ) is
            constant  proc_name      :  string := "MEM_SET";
            variable  next_event     :  EVENT_TYPE;
            variable  str_len        :  integer;
            variable  seq_level      :  integer;
            variable  len            :  integer;
            variable  byte_size      :  integer;
            variable  data           :  std_logic_vector(8*data_size-1 downto 0);
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN DATA_SIZE=" & INTEGER_TO_STRING(data_size));
            seq_level := 0;
            MAIN_LOOP: loop
                SEEK_EVENT(core, stream, next_event);
                case next_event is
                    when EVENT_SEQ_BEGIN  =>
                        READ_EVENT(core, stream, next_event);
                        seq_level := seq_level + 1;
                    when EVENT_SEQ_END    =>
                        if (seq_level > 0) then
                            READ_EVENT(core, stream, next_event);
                            seq_level := seq_level - 1;
                        end if;
                    when EVENT_SCALAR     =>
                        READ_EVENT(core, stream, next_event);
                        data := (others => '0');
                        STRING_TO_STD_LOGIC_VECTOR(
                            STR     => core.str_buf(1 to core.str_len),
                            VAL     => data,
                            STR_LEN => str_len,
                            VAL_LEN => len
                        );
                        byte_size := ((len+7)/8);
                        for i in 0 to byte_size-1 loop
                            if (mem_addr < mem'low ) or (mem_addr > mem'high) then
                                READ_ERROR(core, proc_name, "MEM_ADDR BOUND CHECK ERROR : " & HEX_TO_STRING(mem_addr,32));
                            end if;
                            mem(mem_addr) := data(8*i+7 downto 8*i);
                            mem_addr := mem_addr + 1;
                        end loop;
                    when EVENT_ERROR      =>
                        READ_ERROR(core, proc_name, "SEEK_EVENT NG");
                    when others =>
                        SKIP_EVENT(core, stream, next_event);
                end case;
                exit when (seq_level = 0);
            end loop;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  シナリオで指定された値を mem_addr で指定された開始アドレスから
        --!         mem_fill_size 分だけ mem に書き込むサブプログラム
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        --! @param    data_size   データのサイズをバイト単位で指定する.
        ---------------------------------------------------------------------------
        procedure mem_fil(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT     ;
                      data_size      :  in    integer
        ) is
            constant  proc_name      :  string := "MEM_FIL";
            variable  next_event     :  EVENT_TYPE;
            variable  str_len        :  integer;
            variable  seq_level      :  integer;
            variable  len            :  integer;
            variable  byte_size      :  integer;
            variable  data           :  std_logic_vector(8*data_size-1 downto 0);
            variable  start_addr     :  integer;
            variable  last_addr      :  integer;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN DATA_SIZE=" & INTEGER_TO_STRING(data_size));
            seq_level := 0;
            start_addr:= mem_addr;
            MAIN_LOOP: loop
                SEEK_EVENT(core, stream, next_event);
                case next_event is
                    when EVENT_SEQ_BEGIN  =>
                        READ_EVENT(core, stream, next_event);
                        seq_level := seq_level + 1;
                    when EVENT_SEQ_END    =>
                        if (seq_level > 0) then
                            READ_EVENT(core, stream, next_event);
                            seq_level := seq_level - 1;
                        end if;
                    when EVENT_SCALAR     =>
                        READ_EVENT(core, stream, next_event);
                        data := (others => '0');
                        STRING_TO_STD_LOGIC_VECTOR(
                            STR     => core.str_buf(1 to core.str_len),
                            VAL     => data,
                            STR_LEN => str_len,
                            VAL_LEN => len
                        );
                        byte_size := ((len+7)/8);
                        for i in 0 to byte_size-1 loop
                            if (mem_addr < mem'low ) or (mem_addr > mem'high) then
                                READ_ERROR(core, proc_name, "MEM_ADDR BOUND CHECK ERROR : " & HEX_TO_STRING(mem_addr,32));
                            end if;
                            mem(mem_addr) := data(8*i+7 downto 8*i);
                            last_addr := mem_addr;
                            mem_addr  := mem_addr + 1;
                        end loop;
                    when EVENT_ERROR      =>
                        READ_ERROR(core, proc_name, "SEEK_EVENT NG");
                    when others =>
                        SKIP_EVENT(core, stream, next_event);
                end case;
                exit when (seq_level = 0);
            end loop;
            for i in 2 to mem_fill_size loop
                for addr in start_addr to last_addr loop
                    if (mem_addr < mem'low ) or (mem_addr > mem'high) then
                        READ_ERROR(core, proc_name, "MEM_ADDR BOUND CHECK ERROR : " & HEX_TO_STRING(mem_addr,32));
                    end if;
                    mem(mem_addr) := mem(addr);
                    mem_addr := mem_addr + 1;
                end loop;
            end loop;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  シナリオで指定された値と mem_addr で指定された開始アドレスから
        --!         mem の値を読んで比較するサブプログラム
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        --! @param    data_size   データのサイズをバイト単位で指定する.
        ---------------------------------------------------------------------------
        procedure mem_chk(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT     ;
                      data_size      :  in    integer
        ) is
            constant  proc_name      :  string := "MEM_CHK";
            variable  next_event     :  EVENT_TYPE;
            variable  str_len        :  integer;
            variable  seq_level      :  integer;
            variable  len            :  integer;
            variable  byte_size      :  integer;
            variable  mem_data       :  std_logic_vector(8*data_size-1 downto 0);
            variable  ext_data       :  std_logic_vector(8*data_size-1 downto 0);
            variable  match_addr     :  integer;
            variable  match          :  boolean;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN DATA_SIZE=" & INTEGER_TO_STRING(data_size));
            seq_level := 0;
            MAIN_LOOP: loop
                SEEK_EVENT(core, stream, next_event);
                case next_event is
                    when EVENT_SEQ_BEGIN  =>
                        READ_EVENT(core, stream, next_event);
                        seq_level := seq_level + 1;
                    when EVENT_SEQ_END    =>
                        if (seq_level > 0) then
                            READ_EVENT(core, stream, next_event);
                            seq_level := seq_level - 1;
                        end if;
                    when EVENT_SCALAR     =>
                        READ_EVENT(core, stream, next_event);
                        ext_data := (others => '0');
                        STRING_TO_STD_LOGIC_VECTOR(
                            STR     => core.str_buf(1 to core.str_len),
                            VAL     => ext_data,
                            STR_LEN => str_len,
                            VAL_LEN => len
                        );
                        byte_size  := ((len+7)/8);
                        match_addr := mem_addr;
                        for i in 0 to byte_size-1 loop
                            if (mem_addr < mem'low ) or (mem_addr > mem'high) then
                                READ_ERROR(core, proc_name, "MEM_ADDR BOUND CHECK ERROR : " & HEX_TO_STRING(mem_addr,32));
                            end if;
                            mem_data(8*i+7 downto 8*i) := mem(mem_addr);
                            mem_addr := mem_addr + 1;
                        end loop;
                        match := MATCH_STD_LOGIC(ext_data(byte_size*8-1 downto 0), mem_data(byte_size*8-1 downto 0));
                        if (match = FALSE) then
                            REPORT_MISMATCH(core, NAME &
                                            " MEM(0x" & HEX_TO_STRING(mem_addr, 32) & "):" & 
                                                 "0x" & HEX_TO_STRING(ext_data(byte_size*8-1 downto 0)) & " /= " &
                                                 "0x" & HEX_TO_STRING(mem_data(byte_size*8-1 downto 0)));
                        end if;
                    when EVENT_ERROR      =>
                        READ_ERROR(core, proc_name, "SEEK_EVENT NG");
                    when others =>
                        SKIP_EVENT(core, stream, next_event);
                end case;
                exit when (seq_level = 0);
            end loop;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  DB オペレーション. 
        --!         SET時は、mem_addr 変数に格納されたアドレスから、指定されたデータ
        --!         を mem にバイト(8bit)単位でセットする.
        --!         CHECK時は、mem_addr 変数に格納されたアドレスから、mem の値をバイ
        --!         ト(8bit)単位で読んで指定されたデータと比較する.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        ---------------------------------------------------------------------------
        procedure execute_memdb(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT
        ) is
            constant  proc_name      :  string := "EXECUTE_MEMDB";
            variable  next_event     :  EVENT_TYPE;
            variable  good           :  boolean;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            case mem_mode is
                when MEM_SET_MODE   => mem_set(core, stream, 1);
                when MEM_FILL_MODE  => mem_fil(core, stream, 1);
                when MEM_CHECK_MODE => mem_chk(core, stream, 1);
            end case;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  DH オペレーション. 
        --!         SET時は、mem_addr 変数に格納されたアドレスから、指定されたデータ
        --!         を mem にハーフ(16bit)単位でセットする.
        --!         CHECK時は、mem_addr 変数に格納されたアドレスから、mem の値をハー
        --!         フ(16bit)単位で読んで指定されたデータと比較する.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        ---------------------------------------------------------------------------
        procedure execute_memdh(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT
        ) is
            constant  proc_name      :  string := "EXECUTE_MEMDH";
            variable  next_event     :  EVENT_TYPE;
            variable  good           :  boolean;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            case mem_mode is
                when MEM_SET_MODE   => mem_set(core, stream, 2);
                when MEM_FILL_MODE  => mem_fil(core, stream, 2);
                when MEM_CHECK_MODE => mem_chk(core, stream, 2);
            end case;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  DW オペレーション. 
        --!         SET時は、mem_addr 変数に格納されたアドレスから、指定されたデータ
        --!         を mem にワード(32bit)単位でセットする.
        --!         CHECK時は、mem_addr 変数に格納されたアドレスから、mem の値をワー
        --!         ド(32bit)単位で読んで指定されたデータと比較する.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        ---------------------------------------------------------------------------
        procedure execute_memdw(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT
        ) is
            constant  proc_name      :  string := "EXECUTE_MEMDW";
            variable  next_event     :  EVENT_TYPE;
            variable  good           :  boolean;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            case mem_mode is
                when MEM_SET_MODE   => mem_set(core, stream, 4);
                when MEM_FILL_MODE  => mem_fil(core, stream, 4);
                when MEM_CHECK_MODE => mem_chk(core, stream, 4);
            end case;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  DD オペレーション. 
        --!         SET時は、mem_addr 変数に格納されたアドレスから、指定されたデータ
        --!         を mem にダブルワード(64bit)単位でセットする.
        --!         CHECK時は、mem_addr 変数に格納されたアドレスから、mem の値をダブ
        --!         ルワード(64bit)単位で読んで指定されたデータと比較する.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        ---------------------------------------------------------------------------
        procedure execute_memdd(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT
        ) is
            constant  proc_name      :  string := "EXECUTE_MEMDD";
            variable  next_event     :  EVENT_TYPE;
            variable  good           :  boolean;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            case mem_mode is
                when MEM_SET_MODE   => mem_set(core, stream, 8);
                when MEM_FILL_MODE  => mem_fil(core, stream, 8);
                when MEM_CHECK_MODE => mem_chk(core, stream, 8);
            end case;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  DATA オペレーション. 
        --!         SET時は、mem_addr 変数に格納されたアドレスから、指定されたデータ
        --!         を mem にセットする.
        --!         CHECK時は、mem_addr 変数に格納されたアドレスから、mem の値を読ん
        --!         で指定されたデータと比較する.
        --!         ここで指定する値は、ビット幅を含む形式でなければならない.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        ---------------------------------------------------------------------------
        procedure execute_memdata(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT
        ) is
            constant  proc_name      :  string := "EXECUTE_MEMDD";
            variable  next_event     :  EVENT_TYPE;
            variable  good           :  boolean;
        begin
            REPORT_DEBUG(core, proc_name, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            case mem_mode is
                when MEM_SET_MODE   => mem_set(core, stream, 32);
                when MEM_FILL_MODE  => mem_fil(core, stream, 32);
                when MEM_CHECK_MODE => mem_chk(core, stream, 32);
            end case;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
        ---------------------------------------------------------------------------
        --! @brief  ORG オペレーション. 
        --!         SET/FILL/CHECK時の開始アドレスを指定する.
        --!         指定された開始アドレスは mem_addr 変数に格納される.
        --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        --! @param    core        コア変数.
        --! @param    stream      入力ストリーム.
        ---------------------------------------------------------------------------
        procedure execute_org(
            variable  core           :  inout CORE_TYPE;
            file      stream         :        TEXT
        ) is
            constant  proc_name      :  string := "EXECUTE_ORG";
            variable  next_event     :  EVENT_TYPE;
            variable  good           :  boolean;
            variable  org            :  integer;
        begin 
            REPORT_DEBUG(core, proc_name, "BEGIN");
            SEEK_EVENT(core, stream, next_event);
            READ_INTEGER(core, stream, org, good);
            if (good = FALSE) then
                READ_ERROR(core, proc_name, "READ_INTEGER not good");
            end if;
            if (org < mem'low ) or (org > mem'high) then
                READ_ERROR(core, proc_name, "ORG BOUND CHECK ERROR : " & HEX_TO_STRING(org,32));
            end if;
            mem_addr := org;
            REPORT_DEBUG(core, proc_name, "END");
        end procedure;
    begin
        ---------------------------------------------------------------------------
        -- ダミープラグコアの初期化.
        ---------------------------------------------------------------------------
        CORE_INIT(
            SELF        => core,          -- 初期化するコア変数.
            NAME        => NAME,          -- コアの名前.
            VOCAL_NAME  => NAME,          -- メッセージ出力用の名前.
            STREAM      => stream,        -- シナリオのストリーム.
            STREAM_NAME => SCENARIO_FILE, -- シナリオのストリーム名.
            OPERATION   => operation      -- コアのオペレーション.
        );
        ---------------------------------------------------------------------------
        -- 変数の初期化.
        ---------------------------------------------------------------------------
        gpo_signals := (others => 'Z');
        core.debug  := 0;
        sync_io     := FALSE;
        mem_addr    := -1;
        mem_mode    := MEM_SET_MODE;
        ---------------------------------------------------------------------------
        -- 信号の初期化
        ---------------------------------------------------------------------------
        reports(A_REPORT_STATUS) <= core.report_status;
        SYNC_REQ                 <= (0 => 0, others => -1);
        FINISH                   <= '0';
        enable                   <= FALSE;
        domains                  <= (others => DOMAIN_NULL);
        domains(0).READ_ENABLE   <= TRUE;
        domains(0).WRITE_ENABLE  <= TRUE;
        r_tran_clear             <= TRUE;
        w_tran_clear             <= TRUE;
        b_tran_clear             <= TRUE;
        ---------------------------------------------------------------------------
        -- リセット解除待ち
        ---------------------------------------------------------------------------
        wait until(ACLK'event and ACLK = '1' and ARESETn = '1');
        r_tran_clear   <= FALSE;
        w_tran_clear   <= FALSE;
        b_tran_clear   <= FALSE;
        ---------------------------------------------------------------------------
        -- メインオペレーションループ
        ---------------------------------------------------------------------------
        while (operation /= OP_FINISH) loop
            reports(A_REPORT_STATUS) <= core.report_status;
            READ_OPERATION(core, stream, operation, keyword);
            case operation is
                when OP_DOC_BEGIN       => execute_sync  (core, stream, operation);
                when OP_SCALAR =>
                    case keyword is
                        when KEY_SYNC   => execute_sync  (core, stream, operation);
                        when KEY_START  => execute_start (core, stream, operation);
                        when KEY_STOP   => execute_stop  (core, stream, operation);
                        when KEY_SET    => execute_set   (core, stream);
                        when KEY_CHECK  => execute_check (core, stream);
                        when others     => EXECUTE_UNDEFINED_SCALAR(core, stream, keyword);
                    end case;
                when OP_MAP             =>
                    REPORT_DEBUG(core, string'("MAIN_LOOP:OP_MAP(") & keyword & ")");
                    case keyword is
                        when KEY_REPORT => EXECUTE_REPORT (core, stream);
                        when KEY_DEBUG  => EXECUTE_DEBUG  (core, stream);
                        when KEY_SAY    => EXECUTE_SAY    (core, stream);
                        when KEY_OUT    => EXECUTE_OUT    (core, stream, gpo_signals, GPO);
                        when KEY_SYNC   => execute_sync   (core, stream, operation);
                        when KEY_WAIT   => execute_wait   (core, stream, sync_io);
                        when KEY_ORG    => execute_org    (core, stream);
                        when KEY_FILL   => execute_fill   (core, stream);
                        when KEY_DATA   => execute_memdata(core, stream);
                        when KEY_DB     => execute_memdb  (core, stream);
                        when KEY_DH     => execute_memdh  (core, stream);
                        when KEY_DW     => execute_memdw  (core, stream);
                        when KEY_DD     => execute_memdd  (core, stream);
                        when KEY_DOMAIN => execute_domain (core, stream);
                        when others     => EXECUTE_UNDEFINED_MAP_KEY(core, stream, keyword);
                    end case;
                when OP_FINISH => exit;
                when others    => null;
            end case;
        end loop;
        reports(A_REPORT_STATUS) <= core.report_status;
        FINISH  <= '1';
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete." severity FAILURE;
        end if;
        wait;
    end process;
    -------------------------------------------------------------------------------
    -- リードトランザクション情報の生成
    -------------------------------------------------------------------------------
    r_tran_info <= DECODE_ADDR_CHANNEL(
                       ENABLE        => enable  ,
                       DOMAINS       => domains ,
                       AWRITE        => FALSE   ,
                       AADDR         => ARADDR  ,
                       ALEN          => ARLEN   ,
                       ASIZE         => ARSIZE  ,
                       ABURST        => ARBURST ,
                       ALOCK         => ARLOCK  ,
                       ACACHE        => ARCACHE ,
                       APROT         => ARPROT  ,
                       AQOS          => ARQOS   ,
                       AREGION       => ARREGION,
                       AUSER         => ARUSER  ,
                       AID           => ARID    );
    r_tran_valid <= (enable = TRUE and ARVALID = '1');
    ARREADY      <= '1' when (enable = TRUE and r_tran_ready = TRUE) else '0';
    -------------------------------------------------------------------------------
    -- リードデータチャネル制御ブロック
    -------------------------------------------------------------------------------
    R: block
        constant  QUEUE_SIZE        :  integer := MAX(1, READ_QUEUE_SIZE);
        signal    tran_queue        :  TRAN_INFO_VECTOR(0 to QUEUE_SIZE-1);
        signal    tran_req_valid    :  boolean;
        signal    tran_req_ready    :  boolean;
        signal    tran_proc_busy    :  boolean;
    begin
        ---------------------------------------------------------------------------
        -- リードリクエストキュー
        ---------------------------------------------------------------------------
        process(ACLK, ARESETn) begin
            if (ARESETn = '0') then
                tran_queue <= (others => TRAN_INFO_NULL);
            elsif (ACLK'event and ACLK = '1') then
                TRAN_QUEUE_PROC(
                    QUEUE    => tran_queue    ,
                    CLEAR    => r_tran_clear  ,
                    I_INFO   => r_tran_info   ,
                    I_VALID  => r_tran_valid  ,
                    I_READY  => r_tran_ready  ,
                    O_VALID  => tran_req_valid,
                    O_READY  => tran_req_ready
                 );
            end if;
        end process;
        r_tran_busy    <= (READ_QUEUE_SIZE > 0 and (tran_proc_busy = TRUE or tran_queue(tran_queue'low ).VALID  = TRUE)) or
                          (READ_QUEUE_SIZE = 0 and (tran_proc_busy = TRUE ));
        r_tran_ready   <= (READ_QUEUE_SIZE > 0 and (tran_queue(tran_queue'high).VALID /= TRUE)) or
                          (READ_QUEUE_SIZE = 0 and (tran_proc_busy = FALSE));
        tran_req_valid <= (tran_queue(tran_queue'low ).VALID  = TRUE);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process
            file      stream        :  TEXT;
            variable  core          :  CORE_TYPE;
            variable  operation     :  OPERATION_TYPE;
            variable  tran_info     :  TRAN_INFO_TYPE;
            variable  out_signals   :  AXI4_R_CHANNEL_SIGNAL_TYPE;
            variable  asize_bytes   :  integer;
            variable  lower_lane    :  integer;
            variable  upper_lane    :  integer;
            variable  burst_len     :  integer;
            variable  mem_pos       :  integer;
            variable  boundary_error:  boolean;
            constant  proc_name     :  string := "R-Channel";
            -----------------------------------------------------------------------
            --! @brief TRAN_INFO_READ で取り込んだトランザクション情報から
            --!        ワード毎のリードデータチャネル信号の値を生成するサブプログラム
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    last       最後のワードであることを指定する.
            --! @param    signals    生成されたワード毎の信号を出力する.
            -----------------------------------------------------------------------
            procedure generate_r_channel_signals(
                          last        :  in  boolean;
                          mem_read    :  in  boolean;
                          signals     :  out AXI4_R_CHANNEL_SIGNAL_TYPE
            ) is
                constant  word_bytes  :      integer := WIDTH.RDATA/8;
            begin 
                signals.USER  := std_logic_vector(to_unsigned(tran_info.USER, signals.USER'length));
                signals.ID    := std_logic_vector(to_unsigned(tran_info.ID  , signals.ID  'length));
                signals.VALID := '1';
                signals.READY := '1';
                if (last) then
                    signals.RESP := tran_info.RESP;
                    signals.LAST := '1';
                else
                    signals.RESP := (others => '0');
                    signals.LAST := '0';
                end if;
                if (mem_read = TRUE) then
                    for lane in 0 to word_bytes-1 loop
                        if (lower_lane <= lane and lane <= upper_lane) then
                            signals.DATA(lane*8+7 downto lane*8) := mem(mem_pos);
                            mem_pos := mem_pos + 1;
                        else
                            signals.DATA(lane*8+7 downto lane*8) := (lane*8+7 downto lane*8 => '0');
                        end if;
                    end loop;
                    lower_lane := (upper_lane + 1)  mod word_bytes;
                    upper_lane := lower_lane + asize_bytes - 1;
                    if (upper_lane >= word_bytes) then
                        upper_lane := word_bytes - 1;
                    end if;
                else
                    for lane in 0 to word_bytes-1 loop
                        signals.DATA(lane*8+7 downto lane*8) := (lane*8+7 downto lane*8 => '0');
                    end loop;
                end if;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief 信号変数(signals)の値をポートに出力するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    signals    出力する信号の値を指定する変数.
            -----------------------------------------------------------------------
            procedure output_r_channel_signals(
                          signals  :  in AXI4_R_CHANNEL_SIGNAL_TYPE
            ) is
            begin 
                RDATA  <= signals.DATA(RDATA'range) after OUTPUT_DELAY;
                RRESP  <= signals.RESP              after OUTPUT_DELAY;
                RLAST  <= signals.LAST              after OUTPUT_DELAY;
                RUSER  <= signals.USER(RUSER'range) after OUTPUT_DELAY;
                RID    <= signals.ID(RID'range)     after OUTPUT_DELAY;
                RVALID <= signals.VALID             after OUTPUT_DELAY;
            end procedure;
            -----------------------------------------------------------------------
            --! @brief メモリから読んでリードチャネルに出力するサブプログラム
            -----------------------------------------------------------------------
            procedure output_r_channel_from_memory is
                constant proc_name      :  string := "OUTPUT_R_CHANNEL_FROM_MEMORY";
                variable timeout_count  :  integer;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                -------------------------------------------------------------------
                -- tran_info.LATENCY がキューに入っていたサイクルよりも多い場合、
                -- 差分の分だけウェイトを入れる
                -------------------------------------------------------------------
                if (tran_info.LATENCY > tran_info.COUNT) then
                    output_r_channel_signals(AXI4_R_CHANNEL_SIGNAL_NULL);
                    LATENCY_LOOP: for i in 0 to tran_info.LATENCY - tran_info.COUNT loop
                        wait until (ACLK'event and ACLK = '1');
                        tran_req_ready <= FALSE;
                    end loop;
                end if;
                -------------------------------------------------------------------
                -- 指定されたバースト長の回数分データを出力する
                -------------------------------------------------------------------
                for i in 1 to burst_len loop
                    ---------------------------------------------------------------
                    -- メモリからデータ読んでリードデータチャネルに出力
                    ---------------------------------------------------------------
                    generate_r_channel_signals(
                        last      => (i = burst_len),
                        mem_read  => TRUE,
                        signals   => out_signals
                    );
                    output_r_channel_signals(out_signals);
                    ---------------------------------------------------------------
                    -- RREADY がアサートされるのを待つ
                    ---------------------------------------------------------------
                    timeout_count := 0;
                    WAIT_READY_LOOP: loop
                        wait until (ACLK'event and ACLK = '1');
                        tran_req_ready <= FALSE;
                        exit when  (RREADY = '1');
                        if (timeout_count >= tran_info.TIMEOUT) then
                            EXECUTE_ABORT(core, proc_name, "Wait RREADY Time Out!");
                        end if;
                        timeout_count := timeout_count + 1;
                    end loop;
                    ---------------------------------------------------------------
                    -- リードデータチャネルの出力をデフォルトに戻しておく
                    ---------------------------------------------------------------
                    output_r_channel_signals(AXI4_R_CHANNEL_SIGNAL_NULL);
                    ---------------------------------------------------------------
                    -- tran_info.BLK_LENGTH 分の転送おきに、tran_info.BLK_INTERVAL で
                    -- 指定されたサイクル分の間隔をあける
                    ---------------------------------------------------------------
                    if (i < burst_len and tran_info.BLK_LENGTH > 0) then
                        if (i mod tran_info.BLK_LENGTH = 0) then
                            BLK_INTERVAL_LOOP: for i in 1 to tran_info.BLK_INTERVAL loop
                                wait until (ACLK'event and ACLK = '1');
                                tran_req_ready <= FALSE;
                            end loop;
                        end if;
                    end if;
                end loop;
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
            -----------------------------------------------------------------------
            --! @brief エラーレスポンスだけをリードチャネルに出力するサブプログラム
            -----------------------------------------------------------------------
            procedure output_r_channel_error_response is
                constant proc_name      :  string := "OUTPUT_R_CHANNEL_ERROR_RESPONSE";
                variable timeout_count  :  integer;
            begin
                REPORT_DEBUG(core, proc_name, "BEGIN");
                -------------------------------------------------------------------
                -- tran_info.RESP_DELAY がキューに入っていたサイクルよりも多い場合、
                -- 差分の分だけウェイトを入れる
                -------------------------------------------------------------------
                if (tran_info.RESP_DELAY > tran_info.COUNT) then
                    output_r_channel_signals(AXI4_R_CHANNEL_SIGNAL_NULL);
                    LATENCY_LOOP: for i in 0 to tran_info.RESP_DELAY - tran_info.COUNT loop
                        wait until (ACLK'event and ACLK = '1');
                        tran_req_ready <= FALSE;
                    end loop;
                end if;
                -------------------------------------------------------------------
                -- レスポンスをリードデータチャネルに出力
                -------------------------------------------------------------------
                generate_r_channel_signals(
                    last      => TRUE ,
                    mem_read  => FALSE,
                    signals   => out_signals
                );
                output_r_channel_signals(out_signals);
                -------------------------------------------------------------------
                -- RREADY がアサートされるのを待つ
                -------------------------------------------------------------------
                timeout_count := 0;
                WAIT_READY_LOOP: loop
                    wait until (ACLK'event and ACLK = '1');
                    tran_req_ready <= FALSE;
                    exit when  (RREADY = '1');
                    if (timeout_count >= tran_info.TIMEOUT) then
                        EXECUTE_ABORT(core, proc_name, "Wait RREADY Time Out!");
                    end if;
                    timeout_count := timeout_count + 1;
                end loop;
                -------------------------------------------------------------------
                -- リードデータチャネルの出力をデフォルトに戻しておく
                -------------------------------------------------------------------
                output_r_channel_signals(AXI4_R_CHANNEL_SIGNAL_NULL);
                REPORT_DEBUG(core, proc_name, "END");
            end procedure;
        begin
            -----------------------------------------------------------------------
            -- ダミープラグコアの初期化.
            -----------------------------------------------------------------------
            CORE_INIT(
                SELF        => core,          -- 初期化するコア変数.
                NAME        => NAME,          -- コアの名前.
                STREAM      => stream,        -- シナリオのストリーム.
                STREAM_NAME => SCENARIO_FILE, -- シナリオのストリーム名.
                OPERATION   => operation      -- コアのオペレーション.
            );
            -----------------------------------------------------------------------
            -- 変数の初期化
            -----------------------------------------------------------------------
            out_signals := AXI4_R_CHANNEL_SIGNAL_NULL;
            core.debug  := 1;
            -----------------------------------------------------------------------
            -- 信号の初期化
            -----------------------------------------------------------------------
            output_r_channel_signals(out_signals);
            reports(R_REPORT_STATUS) <= core.report_status;
            tran_proc_busy           <= FALSE;
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            wait until (ACLK'event and ACLK = '1');
            MAIN_LOOP: loop
                reports(R_REPORT_STATUS) <= core.report_status;
                tran_proc_busy <= FALSE;
                -------------------------------------------------------------------
                -- tran_queue に新しいトランザクションが届くまで待つ
                -------------------------------------------------------------------
                wait for 0 ns; -- tran_req_ready の変化で tran_queue が変化するのを待つ
                wait for 0 ns; -- tran_queue の変化で tran_req_valid が変化するのを待つ
                if tran_req_valid = FALSE then
                    wait until (tran_req_valid = TRUE);
                end if;
                tran_proc_busy <= TRUE;
                tran_req_ready <= TRUE;
                tran_info      := tran_queue(tran_queue'low);
                -------------------------------------------------------------------
                -- tran_info から各種情報を引き出す
                -------------------------------------------------------------------
                TRAN_INFO_READ(
                    TRAN_INFO      => tran_info     ,  -- In  :
                    DATA_WIDTH     => WIDTH.RDATA   ,  -- In  :
                    ASIZE_BYTES    => asize_bytes   ,  -- Out :
                    BURST_LEN      => burst_len     ,  -- Out :
                    LOWER_LANE     => lower_lane    ,  -- Out :
                    UPPER_LANE     => upper_lane    ,  -- Out :
                    MEM_POS        => mem_pos       ,  -- Out :
                    BOUNDARY_ERROR => boundary_error   -- Out :
                );
                -------------------------------------------------------------------
                -- 
                -------------------------------------------------------------------
                if tran_info.DOMAIN < domains'low or domains'high < tran_info.DOMAIN then
                    EXECUTE_ABORT(core, proc_name, "Not Found Domain");
                end if;
                -------------------------------------------------------------------
                -- 4Kbyte 境界の検証
                -------------------------------------------------------------------
                if boundary_error then
                    REPORT_ERROR(core, "4KByte Boundary Error");
                end if;
                -------------------------------------------------------------------
                -- tran_info から各種情報に従ってリードチャネルに出力
                -------------------------------------------------------------------
                case tran_info.RESP is
                    when AXI4_RESP_OKAY   => output_r_channel_from_memory;
                    when AXI4_RESP_EXOKAY => output_r_channel_from_memory;
                    when AXI4_RESP_SLVERR => output_r_channel_error_response;
                    when AXI4_RESP_DECERR => output_r_channel_error_response;
                    when others           => output_r_channel_error_response;
                end case;
            end loop;
            reports(R_REPORT_STATUS) <= core.report_status;
        end process;
    end block;
    -------------------------------------------------------------------------------
    -- ライトトランザクション情報の生成
    -------------------------------------------------------------------------------
    w_tran_info <= DECODE_ADDR_CHANNEL(
                       ENABLE        => enable  ,
                       DOMAINS       => domains ,
                       AWRITE        => TRUE    ,
                       AADDR         => AWADDR  ,
                       ALEN          => AWLEN   ,
                       ASIZE         => AWSIZE  ,
                       ABURST        => AWBURST ,
                       ALOCK         => AWLOCK  ,
                       ACACHE        => AWCACHE ,
                       APROT         => AWPROT  ,
                       AQOS          => AWQOS   ,
                       AREGION       => AWREGION,
                       AUSER         => AWUSER  ,
                       AID           => AWID    );
    w_tran_valid <= (enable = TRUE and AWVALID = '1');
    AWREADY      <= '1' when (enable = TRUE and w_tran_ready = TRUE) else '0';
    -------------------------------------------------------------------------------
    -- ライトデータチャネル制御ブロック
    -------------------------------------------------------------------------------
    W: block
        constant  QUEUE_SIZE        :  integer := 1;
        signal    tran_queue        :  TRAN_INFO_VECTOR(0 to QUEUE_SIZE-1);
        signal    tran_req_valid    :  boolean;
        signal    tran_req_ready    :  boolean;
        signal    tran_proc_busy    :  boolean;
        signal    tran_data_last    :  boolean;
        signal    tran_data_ready   :  boolean;
    begin
        ---------------------------------------------------------------------------
        -- ライトリクエストキュー
        ---------------------------------------------------------------------------
        process(ACLK, ARESETn) begin
            if (ARESETn = '0') then
                tran_queue <= (others => TRAN_INFO_NULL);
            elsif (ACLK'event and ACLK = '1') then
                TRAN_QUEUE_PROC(
                    QUEUE    => tran_queue    ,
                    CLEAR    => w_tran_clear  ,
                    I_INFO   => w_tran_info   ,
                    I_VALID  => w_tran_valid  ,
                    I_READY  => w_tran_ready  ,
                    O_VALID  => tran_req_valid,
                    O_READY  => tran_req_ready
                 );
            end if;
        end process;
        w_tran_busy    <= (tran_proc_busy = TRUE or tran_queue(tran_queue'low ).VALID = TRUE);
        w_tran_ready   <= (tran_queue(tran_queue'high).VALID = FALSE);
        tran_req_valid <= (tran_queue(tran_queue'low ).VALID = TRUE );
        tran_req_ready <= ((tran_data_last = TRUE or WLAST = '1') and WVALID = '1' and tran_data_ready = TRUE);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process
            file      stream        :  TEXT;
            variable  core          :  CORE_TYPE;
            variable  operation     :  OPERATION_TYPE;
            variable  tran_info     :  TRAN_INFO_TYPE;
            variable  out_signals   :  AXI4_W_CHANNEL_SIGNAL_TYPE;
            variable  asize_bytes   :  integer;
            variable  lower_lane    :  integer;
            variable  upper_lane    :  integer;
            variable  burst_len     :  integer;
            variable  mem_pos       :  integer;
            variable  boundary_error:  boolean;
            variable  timeout_count :  integer;
            constant  word_bytes    :  integer := WIDTH.WDATA/8;
            constant  proc_name     :  string := "W-Channel";
            -----------------------------------------------------------------------
            --! @brief 信号変数(signals)の値をポートに出力するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    signals    出力する信号の値を指定する変数.
            -----------------------------------------------------------------------
            procedure output_w_channel_signals(
                          signals  : in AXI4_W_CHANNEL_SIGNAL_TYPE
            ) is
            begin 
                WREADY <= signals.READY               after OUTPUT_DELAY;
            end procedure;
        begin
            -----------------------------------------------------------------------
            -- ダミープラグコアの初期化.
            -----------------------------------------------------------------------
            CORE_INIT(
                SELF        => core,          -- 初期化するコア変数.
                NAME        => NAME,          -- コアの名前.
                STREAM      => stream,        -- シナリオのストリーム.
                STREAM_NAME => SCENARIO_FILE, -- シナリオのストリーム名.
                OPERATION   => operation      -- コアのオペレーション.
            );
            -----------------------------------------------------------------------
            -- 変数の初期化
            -----------------------------------------------------------------------
            out_signals  := AXI4_W_CHANNEL_SIGNAL_NULL;
            -----------------------------------------------------------------------
            -- 信号の初期化
            -----------------------------------------------------------------------
            output_w_channel_signals(AXI4_W_CHANNEL_SIGNAL_NULL);
            reports(W_REPORT_STATUS) <= core.report_status;
            tran_proc_busy           <= FALSE;
            tran_data_last           <= FALSE;
            tran_data_ready          <= FALSE;
            b_tran_info              <= TRAN_INFO_NULL;
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            wait until (ACLK'event and ACLK = '1');
            MAIN_LOOP: loop
                reports(W_REPORT_STATUS) <= core.report_status;
                tran_proc_busy  <= FALSE;
                tran_data_last  <= FALSE;
                tran_data_ready <= FALSE;
                -------------------------------------------------------------------
                -- tran_queue に新しいトランザクションが届き、かつライト応答キュー
                -- が空くまで待つ.
                -------------------------------------------------------------------
                wait for 0 ns; -- tran_req_ready の変化で tran_queue が変化するのを待つ
                wait for 0 ns; -- tran_queue の変化で tran_req_valid が変化するのを待つ
                if (tran_req_valid = FALSE or b_tran_ready = FALSE) then
                    wait until (tran_req_valid = TRUE and b_tran_ready = TRUE);
                end if;
                tran_proc_busy <= TRUE;
                tran_info      := tran_queue(tran_queue'low);
                -------------------------------------------------------------------
                -- tran_info から各種情報を引き出す
                -------------------------------------------------------------------
                TRAN_INFO_READ(
                    TRAN_INFO      => tran_info     ,  -- In  :
                    DATA_WIDTH     => WIDTH.WDATA   ,  -- In  :
                    ASIZE_BYTES    => asize_bytes   ,  -- Out :
                    BURST_LEN      => burst_len     ,  -- Out :
                    LOWER_LANE     => lower_lane    ,  -- Out :
                    UPPER_LANE     => upper_lane    ,  -- Out :
                    MEM_POS        => mem_pos       ,  -- Out :
                    BOUNDARY_ERROR => boundary_error
                );
                -------------------------------------------------------------------
                -- 
                -------------------------------------------------------------------
                if tran_info.DOMAIN < domains'low or domains'high < tran_info.DOMAIN then
                    EXECUTE_ABORT(core, proc_name, "Not Found Domain");
                end if;
                -------------------------------------------------------------------
                -- 4Kbyte 境界の検証
                -------------------------------------------------------------------
                if boundary_error then
                    REPORT_ERROR(core, "4KByte Boundary Error");
                end if;
                -------------------------------------------------------------------
                -- ライト応答キューに入れる b_tran_info を設定しておく
                -------------------------------------------------------------------
                b_tran_info <= tran_info;
                -------------------------------------------------------------------
                -- tran_info.LATENCY がキューに入っていたサイクルよりも多い場合、
                -- 差分の分だけウェイトを入れる
                -------------------------------------------------------------------
                if (tran_info.LATENCY > tran_info.COUNT) then
                    output_w_channel_signals(AXI4_W_CHANNEL_SIGNAL_NULL);
                    LATENCY_LOOP: for i in 0 to tran_info.LATENCY - tran_info.COUNT loop
                        wait until (ACLK'event and ACLK = '1');
                    end loop;
                end if;
                -------------------------------------------------------------------
                -- 指定されたバースト長の回数分データを入力する
                -------------------------------------------------------------------
                BURST_LOOP: for i in 1 to burst_len loop
                    ---------------------------------------------------------------
                    -- 最後の転送時に、ライトリクエストキューからリクエスト情報を取
                    -- り除くため、またはライト応答キューに b_tran_info を入れるた
                    -- めに tran_data_last 信号をアサートしておく.
                    ---------------------------------------------------------------
                    if (i = burst_len) then
                        tran_data_last <= TRUE;
                    else
                        tran_data_last <= FALSE;
                    end if;
                    ---------------------------------------------------------------
                    -- ライトデータチャネルからデータが届くのを待つ
                    ---------------------------------------------------------------
                    tran_data_ready   <= TRUE;
                    out_signals.READY := '1';
                    output_w_channel_signals(out_signals);
                    timeout_count := 0;
                    WAIT_VALID_LOOP: loop
                        wait until (ACLK'event and ACLK = '1');
                        exit when  (WVALID = '1');
                        if (timeout_count >= tran_info.TIMEOUT) then
                            EXECUTE_ABORT(core, proc_name, "Wait WVALID Time Out!");
                        end if;
                        timeout_count := timeout_count + 1;
                    end loop;
                    ---------------------------------------------------------------
                    -- WREADY をネゲートしておく
                    ---------------------------------------------------------------
                    output_w_channel_signals(AXI4_W_CHANNEL_SIGNAL_NULL);
                    ---------------------------------------------------------------
                    -- tran_data_last もネゲートしておく
                    ---------------------------------------------------------------
                    tran_data_last  <= FALSE;
                    tran_data_ready <= FALSE;
                    ---------------------------------------------------------------
                    -- ライトデータチャネルからのデータをメモリに書く
                    ---------------------------------------------------------------
                    if (tran_info.RESP = AXI4_RESP_OKAY  ) or
                       (tran_info.RESP = AXI4_RESP_EXOKAY) then
                        for lane in 0 to word_bytes-1 loop
                            if (lower_lane <= lane and lane <= upper_lane) then
                                if (WSTRB(lane) = '1') then
                                    mem(mem_pos) := WDATA(lane*8+7 downto lane*8);
                                end if;
                                mem_pos := mem_pos + 1;
                            end if;
                        end loop;
                        lower_lane := (upper_lane + 1)  mod word_bytes;
                        upper_lane := lower_lane + asize_bytes - 1;
                        if (upper_lane >= word_bytes) then
                            upper_lane := word_bytes - 1;
                        end if;
                    end if;
                    ---------------------------------------------------------------
                    -- WLAST 信号とバースト長のチェック
                    ---------------------------------------------------------------
                    if (WLAST = '0' and i  = burst_len) then
                        REPORT_MISMATCH(core, "Expect WLAST=1 but 0");
                    end if;
                    if (WLAST = '1' and i /= burst_len) then
                        REPORT_MISMATCH(core, "Expect WLAST=0 but 1");
                    end if;
                    if (WLAST = '1') then
                        exit BURST_LOOP;
                    end if;
                    ---------------------------------------------------------------
                    -- tran_info.BLK_LENGTH 分の転送おきに、tran_info.BLK_INTERVAL で
                    -- 指定されたサイクル分の間隔をあける
                    ---------------------------------------------------------------
                    if (i < burst_len and tran_info.BLK_LENGTH > 0) then
                        if (i mod tran_info.BLK_LENGTH = 0) then
                            BLK_INTERVAL_LOOP: for i in 1 to tran_info.BLK_INTERVAL loop
                                wait until (ACLK'event and ACLK = '1');
                            end loop;
                        end if;
                    end if;
                end loop;
            end loop;
            reports(W_REPORT_STATUS) <= core.report_status;
        end process;
        ---------------------------------------------------------------------------
        -- ライト応答キューに b_tran_info を入れるための信号
        ---------------------------------------------------------------------------
        b_tran_valid <= ((tran_data_last = TRUE or WLAST = '1') and WVALID = '1' and tran_data_ready = TRUE);
    end block;
    -------------------------------------------------------------------------------
    -- ライト応答チャネル制御ブロック
    -------------------------------------------------------------------------------
    B: block
        constant  QUEUE_SIZE        :  integer := MAX(1, WRITE_QUEUE_SIZE);
        signal    tran_queue        :  TRAN_INFO_VECTOR(0 to QUEUE_SIZE-1);
        signal    tran_req_valid    :  boolean;
        signal    tran_req_ready    :  boolean;
        signal    tran_proc_busy    :  boolean;
    begin
        ---------------------------------------------------------------------------
        -- ライト応答リクエストキュー
        ---------------------------------------------------------------------------
        process(ACLK, ARESETn) begin
            if (ARESETn = '0') then
                tran_queue <= (others => TRAN_INFO_NULL);
            elsif (ACLK'event and ACLK = '1') then
                TRAN_QUEUE_PROC(
                    QUEUE    => tran_queue    ,
                    CLEAR    => b_tran_clear  ,
                    I_INFO   => b_tran_info   ,
                    I_VALID  => b_tran_valid  ,
                    I_READY  => b_tran_ready  ,
                    O_VALID  => tran_req_valid,
                    O_READY  => tran_req_ready
                 );
            end if;
        end process;
        b_tran_busy    <= (WRITE_QUEUE_SIZE > 0 and (tran_proc_busy = TRUE or tran_queue(tran_queue'low ).VALID  = TRUE)) or
                          (WRITE_QUEUE_SIZE = 0 and (tran_proc_busy = TRUE));
        b_tran_ready   <= (WRITE_QUEUE_SIZE > 0 and (tran_queue(tran_queue'high).VALID /= TRUE)) or
                          (WRITE_QUEUE_SIZE = 0 and (tran_proc_busy = FALSE));
        tran_req_valid <= (tran_queue(tran_queue'low ).VALID  = TRUE);
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        process
            file      stream        :  TEXT;
            variable  core          :  CORE_TYPE;
            variable  operation     :  OPERATION_TYPE;
            variable  tran_info     :  TRAN_INFO_TYPE;
            variable  out_signals   :  AXI4_B_CHANNEL_SIGNAL_TYPE;
            variable  timeout_count :  integer;
            constant  proc_name     :  string := "B-Channel";
            -----------------------------------------------------------------------
            --! @brief 信号変数(signals)の値をポートに出力するサブプログラム.
            --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            --! @param    signals    出力する信号の値を指定する変数.
            -----------------------------------------------------------------------
            procedure output_b_channel_signals(
                          signals  :  in AXI4_B_CHANNEL_SIGNAL_TYPE
            ) is
            begin 
                BRESP  <= signals.RESP              after OUTPUT_DELAY;
                BUSER  <= signals.USER(BUSER'range) after OUTPUT_DELAY;
                BID    <= signals.ID(BID'range)     after OUTPUT_DELAY;
                BVALID <= signals.VALID             after OUTPUT_DELAY;
            end procedure;
        begin
            -----------------------------------------------------------------------
            -- ダミープラグコアの初期化.
            -----------------------------------------------------------------------
            CORE_INIT(
                SELF        => core,          -- 初期化するコア変数.
                NAME        => NAME,          -- コアの名前.
                STREAM      => stream,        -- シナリオのストリーム.
                STREAM_NAME => SCENARIO_FILE, -- シナリオのストリーム名.
                OPERATION   => operation      -- コアのオペレーション.
            );
            -----------------------------------------------------------------------
            -- 変数の初期化
            -----------------------------------------------------------------------
            out_signals  := AXI4_B_CHANNEL_SIGNAL_NULL;
            -----------------------------------------------------------------------
            -- 信号の初期化
            -----------------------------------------------------------------------
            output_b_channel_signals(AXI4_B_CHANNEL_SIGNAL_NULL);
            reports(B_REPORT_STATUS) <= core.report_status;
            tran_proc_busy <= FALSE;
            -----------------------------------------------------------------------
            -- 
            -----------------------------------------------------------------------
            wait until (ACLK'event and ACLK = '1');
            MAIN_LOOP: loop
                reports(B_REPORT_STATUS) <= core.report_status;
                tran_proc_busy <= FALSE;
                -------------------------------------------------------------------
                -- tran_queue に新しいトランザクションが届くまで待つ
                -------------------------------------------------------------------
                wait for 0 ns; -- tran_req_ready の変化で tran_queue が変化するのを待つ
                wait for 0 ns; -- tran_queue の変化で tran_req_valid が変化するのを待つ
                if tran_req_valid = FALSE then
                    wait until (tran_req_valid = TRUE);
                end if;
                tran_proc_busy <= TRUE;
                tran_req_ready <= TRUE;
                tran_info      := tran_queue(tran_queue'low);
                -------------------------------------------------------------------
                -- tran_info.RESP_DELAY がキューに入っていたサイクルよりも多い場合、
                -- 差分の分だけウェイトを入れる
                -------------------------------------------------------------------
                if (tran_info.RESP_DELAY > tran_info.COUNT) then
                    output_b_channel_signals(AXI4_B_CHANNEL_SIGNAL_NULL);
                    LATENCY_LOOP: for i in 0 to tran_info.RESP_DELAY - tran_info.COUNT loop
                        wait until (ACLK'event and ACLK = '1');
                        tran_req_ready <= FALSE;
                    end loop;
                end if;
                -------------------------------------------------------------------
                -- レスポンスをライト応答チャネルに出力
                -------------------------------------------------------------------
                out_signals.VALID := '1';
                out_signals.RESP  := tran_info.RESP;
                out_signals.USER  := std_logic_vector(to_unsigned(tran_info.USER, out_signals.USER'length));
                out_signals.ID    := std_logic_vector(to_unsigned(tran_info.ID  , out_signals.ID  'length));
                output_b_channel_signals(out_signals);
                -------------------------------------------------------------------
                -- BREADY がアサートされるのを待つ
                -------------------------------------------------------------------
                timeout_count := 0;
                WAIT_READY_LOOP: loop
                    wait until (ACLK'event and ACLK = '1');
                    tran_req_ready <= FALSE;
                    exit when  (BREADY = '1');
                    if (timeout_count >= tran_info.TIMEOUT) then
                        EXECUTE_ABORT(core, proc_name, "Wait BREADY Time Out!");
                    end if;
                    timeout_count := timeout_count + 1;
                end loop;
                -------------------------------------------------------------------
                -- ライト応答チャネルの出力をデフォルトに戻しておく
                -------------------------------------------------------------------
                output_b_channel_signals(AXI4_B_CHANNEL_SIGNAL_NULL);
            end loop;
            reports(B_REPORT_STATUS) <= core.report_status;
        end process;
    end block;
    -------------------------------------------------------------------------------
    -- レポートの集計.
    -------------------------------------------------------------------------------
    REPORT_STATUS <= MARGE_REPORT_STATUS(reports);
    -------------------------------------------------------------------------------
    -- このコア用の同期回路
    -------------------------------------------------------------------------------
    SYNC_DRIVER: for i in SYNC'range generate
        UNIT: SYNC_SIG_DRIVER
            generic map (
                NAME     => string'("SLAVE:SYNC"),
                PLUG_NUM => SYNC_PLUG_NUM
            )
            port map (
                CLK      => ACLK                ,  -- In :
                RST      => sync_rst            ,  -- In :
                CLR      => sync_clr            ,  -- In :
                DEBUG    => sync_debug          ,  -- In :
                SYNC     => SYNC(i)             ,  -- I/O:
                REQ      => sync_req(i)         ,  -- In :
                ACK      => sync_ack(i)            -- Out:
            );
    end generate;
    sync_rst <= '0' when (ARESETn = '1') else '1';
    sync_clr <= '0';
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
