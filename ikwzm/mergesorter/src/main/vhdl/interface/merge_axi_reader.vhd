-----------------------------------------------------------------------------------
--!     @file    merge_axi_reader.vhd
--!     @brief   Merge Sorter Merge AXI Reader Module :
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
entity  Merge_AXI_Reader is
    generic (
        WAYS            :  integer :=  8;
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        AXI_ID_BASE     :  integer :=  0;
        AXI_ID_WIDTH    :  integer :=  8;
        AXI_AUSER_WIDTH :  integer :=  4;
        AXI_ADDR_WIDTH  :  integer := 32;
        AXI_DATA_WIDTH  :  integer := 64;
        AXI_XFER_SIZE   :  integer := 10;
        AXI_BUF_DEPTH   :  integer := 11;
        AXI_QUEUE_SIZE  :  integer :=  4;
        AXI_RDATA_REGS  :  integer :=  2;
        AXI_ACK_REGS    :  integer range 0 to 1 :=  1;
        ARB_NODE_NUM    :  integer :=  4;
        ARB_PIPELINE    :  integer :=  0;
        MRG_REG_PARAM   :  Interface.Regs_Field_Type := Interface.Default_Regs_Param
    );
    port (
    -------------------------------------------------------------------------------
    -- Clock/Reset Signals.
    -------------------------------------------------------------------------------
        CLK             :  in  std_logic;
        RST             :  in  std_logic;
        CLR             :  in  std_logic;
    -------------------------------------------------------------------------------
    -- AXI Master Read Address Channel Signals.
    -------------------------------------------------------------------------------
        AXI_ARID        :  out std_logic_vector(AXI_ID_WIDTH        -1 downto 0);
        AXI_ARADDR      :  out std_logic_vector(AXI_ADDR_WIDTH      -1 downto 0);
        AXI_ARLEN       :  out std_logic_vector(7 downto 0);
        AXI_ARSIZE      :  out std_logic_vector(2 downto 0);
        AXI_ARBURST     :  out std_logic_vector(1 downto 0);
        AXI_ARLOCK      :  out std_logic_vector(0 downto 0);
        AXI_ARCACHE     :  out std_logic_vector(3 downto 0);
        AXI_ARPROT      :  out std_logic_vector(2 downto 0);
        AXI_ARQOS       :  out std_logic_vector(3 downto 0);
        AXI_ARREGION    :  out std_logic_vector(3 downto 0);
        AXI_ARUSER      :  out std_logic_vector(AXI_AUSER_WIDTH     -1 downto 0);
        AXI_ARVALID     :  out std_logic;
        AXI_ARREADY     :  in  std_logic;
    -------------------------------------------------------------------------------
    -- AXI Master Read Data Channel Signals.
    -------------------------------------------------------------------------------
        AXI_RID         :  in  std_logic_vector(AXI_ID_WIDTH        -1 downto 0);
        AXI_RDATA       :  in  std_logic_vector(AXI_DATA_WIDTH      -1 downto 0);
        AXI_RRESP       :  in  std_logic_vector(1 downto 0);
        AXI_RLAST       :  in  std_logic;
        AXI_RVALID      :  in  std_logic;
        AXI_RREADY      :  out std_logic;
    -------------------------------------------------------------------------------
    -- Merge Reader Control Register Interface.
    -------------------------------------------------------------------------------
        MRG_REG_L       :  in  std_logic_vector(WAYS*MRG_REG_PARAM.BITS -1 downto 0);
        MRG_REG_D       :  in  std_logic_vector(WAYS*MRG_REG_PARAM.BITS -1 downto 0);
        MRG_REG_Q       :  out std_logic_vector(WAYS*MRG_REG_PARAM.BITS -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Outlet Signals.
    -------------------------------------------------------------------------------
        MRG_DATA        :  out std_logic_vector(WAYS*WORDS*WORD_BITS-1 downto 0);
        MRG_NONE        :  out std_logic_vector(WAYS*WORDS          -1 downto 0);
        MRG_EBLK        :  out std_logic_vector(WAYS                -1 downto 0);
        MRG_LAST        :  out std_logic_vector(WAYS                -1 downto 0);
        MRG_VALID       :  out std_logic_vector(WAYS                -1 downto 0);
        MRG_READY       :  in  std_logic_vector(WAYS                -1 downto 0);
        MRG_LEVEL       :  in  std_logic_vector(WAYS                -1 downto 0);
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic_vector(WAYS                -1 downto 0);
        DONE            :  out std_logic_vector(WAYS                -1 downto 0)
    );
end Merge_AXI_Reader;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library Merge_Sorter;
use     Merge_Sorter.Interface;
use     Merge_Sorter.Interface_Components.Merge_Reader;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_READ_INTERFACE;
use     PIPEWORK.COMPONENTS.QUEUE_TREE_ARBITER;
architecture RTL of Merge_AXI_Reader is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  MAX(A,B:integer) return integer is
    begin
        if (A > B) then return A;
        else            return B;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  MIN(A,B:integer) return integer is
    begin
        if (A < B) then return A;
        else            return B;
        end if;
    end function;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    constant  ALIGNMENT_BITS    :  integer := MIN(      WORD_BITS, AXI_DATA_WIDTH);
    constant  BUF_DATA_BITS     :  integer := MAX(WORDS*WORD_BITS, AXI_DATA_WIDTH);
    constant  BUF_DEPTH         :  integer := AXI_BUF_DEPTH;
    constant  BUF_BYTES         :  integer := 2**BUF_DEPTH;
    constant  MAX_XFER_BYTES    :  integer := 2**AXI_XFER_SIZE;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    constant  XFER_SIZE_BITS    :  integer := BUF_DEPTH+1;
    constant  REQ_SIZE_BITS     :  integer := MRG_REG_PARAM.SIZE.BITS;
    constant  REQ_MODE_BITS     :  integer := MRG_REG_PARAM.MODE.BITS;
    constant  REQ_MODE_FIELD    :  Interface.Mode_Regs_Field_Type := Interface.New_Mode_Regs_Field(0);
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    constant  REQ_LOCK          :  std_logic_vector(0 downto 0) := (others => '0');
    constant  REQ_QOS           :  std_logic_vector(3 downto 0) := (others => '0');
    constant  REQ_REGION        :  std_logic_vector(3 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    req_addr          :  std_logic_vector(AXI_ADDR_WIDTH -1 downto 0);
    signal    req_size          :  std_logic_vector(REQ_SIZE_BITS  -1 downto 0);
    signal    req_buf_ptr       :  std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal    req_mode          :  std_logic_vector(REQ_MODE_BITS  -1 downto 0);
    signal    req_cache         :  std_logic_vector(3 downto 0);
    signal    req_prot          :  std_logic_vector(2 downto 0);
    signal    req_id            :  std_logic_vector(AXI_ID_WIDTH   -1 downto 0);
    signal    req_speculative   :  std_logic;
    signal    req_safety        :  std_logic;
    signal    req_first         :  std_logic;
    signal    req_last          :  std_logic;
    signal    req_none          :  std_logic;
    constant  REQ_VALID_ALL0    :  std_logic_vector(WAYS           -1 downto 0) := (others => '0');
    signal    req_valid         :  std_logic_vector(WAYS           -1 downto 0);
    signal    req_ready         :  std_logic;
    signal    xfer_busy         :  std_logic_vector(WAYS           -1 downto 0);
    signal    xfer_done         :  std_logic_vector(WAYS           -1 downto 0);
    signal    xfer_error        :  std_logic_vector(WAYS           -1 downto 0);
    signal    ack_valid         :  std_logic_vector(WAYS           -1 downto 0);
    signal    ack_error         :  std_logic;
    signal    ack_next          :  std_logic;
    signal    ack_last          :  std_logic;
    signal    ack_stop          :  std_logic;
    signal    ack_none          :  std_logic;
    signal    ack_size          :  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    signal    flow_pause        :  std_logic;
    signal    flow_stop         :  std_logic;
    signal    flow_last         :  std_logic;
    signal    flow_size         :  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    signal    push_fin_valid    :  std_logic_vector(WAYS           -1 downto 0);
    signal    push_fin_error    :  std_logic;
    signal    push_fin_last     :  std_logic;
    signal    push_fin_size     :  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    signal    push_buf_valid    :  std_logic_vector(WAYS           -1 downto 0);
    signal    push_buf_ready    :  std_logic_vector(WAYS           -1 downto 0);
    signal    push_buf_reset    :  std_logic_vector(WAYS           -1 downto 0);
    signal    push_buf_error    :  std_logic;
    signal    push_buf_last     :  std_logic;
    signal    push_buf_size     :  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    signal    buf_wdata         :  std_logic_vector(BUF_DATA_BITS  -1 downto 0);
    signal    buf_ben           :  std_logic_vector(BUF_DATA_BITS/8-1 downto 0);
    signal    buf_wptr          :  std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal    buf_wen           :  std_logic_vector(WAYS           -1 downto 0);
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    type      REQ_ADDR_VECTOR       is array (integer range <>) of std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
    type      REQ_SIZE_VECTOR       is array (integer range <>) of std_logic_vector(REQ_SIZE_BITS -1 downto 0);
    type      REQ_MODE_VECTOR       is array (integer range <>) of std_logic_vector(REQ_MODE_BITS -1 downto 0);
    type      REQ_BUF_PTR_VECTOR    is array (integer range <>) of std_logic_vector(BUF_DEPTH     -1 downto 0);
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    signal    i_req_addr        :  REQ_ADDR_VECTOR   (WAYS-1 downto 0);
    signal    i_req_size        :  REQ_SIZE_VECTOR   (WAYS-1 downto 0);
    signal    i_req_mode        :  REQ_MODE_VECTOR   (WAYS-1 downto 0);
    signal    i_req_buf_ptr     :  REQ_BUF_PTR_VECTOR(WAYS-1 downto 0);
    signal    i_req_first       :  std_logic_vector  (WAYS-1 downto 0);
    signal    i_req_last        :  std_logic_vector  (WAYS-1 downto 0);
    signal    i_req_none        :  std_logic_vector  (WAYS-1 downto 0);
    signal    i_req_valid       :  std_logic_vector  (WAYS-1 downto 0);
    signal    i_req_ready       :  std_logic_vector  (WAYS-1 downto 0);
    signal    i_flow_ready      :  std_logic_vector  (WAYS-1 downto 0);
    signal    i_flow_stop       :  std_logic_vector  (WAYS-1 downto 0);
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    function  SELECT_REQ_FLAG(SEL: std_logic_vector; VEC: std_logic_vector) return std_logic is
        variable req_flag  :  std_logic;
    begin
        req_flag := '0';
        for i in VEC'range loop
            if (SEL(i) = '1') then
                req_flag := req_flag or VEC(i);
            end if;
        end loop;
        return req_flag;
    end function;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    function  SELECT_REQ_ADDR(SEL: std_logic_vector; VEC: REQ_ADDR_VECTOR) return std_logic_vector is
        variable v_req_addr  :  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
    begin
        v_req_addr := (others => '0');
        for i in VEC'range loop
            if (SEL(i) = '1') then
                v_req_addr := v_req_addr or VEC(i);
            end if;
        end loop;
        return v_req_addr;
    end function;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    function  SELECT_REQ_SIZE(SEL: std_logic_vector; VEC: REQ_SIZE_VECTOR) return std_logic_vector is
        variable v_req_size  :  std_logic_vector(REQ_SIZE_BITS-1 downto 0);
    begin
        v_req_size := (others => '0');
        for i in VEC'range loop
            if (SEL(i) = '1') then
                v_req_size := v_req_size or VEC(i);
            end if;
        end loop;
        return v_req_size;
    end function;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    function  SELECT_REQ_MODE(SEL: std_logic_vector; VEC: REQ_MODE_VECTOR) return std_logic_vector is
        variable v_req_mode  :  std_logic_vector(REQ_MODE_BITS-1 downto 0);
    begin
        v_req_mode := (others => '0');
        for i in VEC'range loop
            if (SEL(i) = '1') then
                v_req_mode := v_req_mode or VEC(i);
            end if;
        end loop;
        return v_req_mode;
    end function;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    function  SELECT_REQ_BUF_PTR(SEL: std_logic_vector; VEC: REQ_BUF_PTR_VECTOR) return std_logic_vector is
        variable v_req_buf_ptr :  std_logic_vector(BUF_DEPTH-1 downto 0);
    begin
        v_req_buf_ptr := (others => '0');
        for i in VEC'range loop
            if (SEL(i) = '1') then
                v_req_buf_ptr := v_req_buf_ptr or VEC(i);
            end if;
        end loop;
        return v_req_buf_ptr;
    end function;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    AXI_IF: AXI4_MASTER_READ_INTERFACE                   -- 
        generic map (                                    -- 
            AXI4_ADDR_WIDTH     => AXI_ADDR_WIDTH      , -- 
            AXI4_DATA_WIDTH     => AXI_DATA_WIDTH      , -- 
            AXI4_ID_WIDTH       => AXI_ID_WIDTH        , -- 
            VAL_BITS            => WAYS                , -- 
            REQ_SIZE_BITS       => REQ_SIZE_BITS       , -- 
            REQ_SIZE_VALID      => 1                   , -- 
            FLOW_VALID          => 1                   , -- 
            BUF_DATA_WIDTH      => BUF_DATA_BITS       , -- 
            BUF_PTR_BITS        => BUF_DEPTH           , --
            ALIGNMENT_BITS      => ALIGNMENT_BITS      , --
            XFER_SIZE_BITS      => XFER_SIZE_BITS      , -- 
            XFER_MIN_SIZE       => AXI_XFER_SIZE       , -- 
            XFER_MAX_SIZE       => AXI_XFER_SIZE       , -- 
            QUEUE_SIZE          => AXI_QUEUE_SIZE      , --
            RDATA_REGS          => AXI_RDATA_REGS      , --
            ACK_REGS            => AXI_ACK_REGS          -- 
        )                                                -- 
        port map (                                       -- 
        --------------------------------------------------------------------------
        -- Clock and Reset Signals.
        --------------------------------------------------------------------------
            CLK                 => CLK                 , -- In  :
            CLR                 => CLR                 , -- In  :
            RST                 => RST                 , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Read Address Channel Signals.
        --------------------------------------------------------------------------
            ARID                => AXI_ARID            , -- Out :
            ARADDR              => AXI_ARADDR          , -- Out :
            ARLEN               => AXI_ARLEN           , -- Out :
            ARSIZE              => AXI_ARSIZE          , -- Out :
            ARBURST             => AXI_ARBURST         , -- Out :
            ARLOCK              => AXI_ARLOCK          , -- Out :
            ARCACHE             => AXI_ARCACHE         , -- Out :
            ARPROT              => AXI_ARPROT          , -- Out :
            ARQOS               => AXI_ARQOS           , -- Out :
            ARREGION            => AXI_ARREGION        , -- Out :
            ARVALID             => AXI_ARVALID         , -- Out :
            ARREADY             => AXI_ARREADY         , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Read Data Channel Signals.
        --------------------------------------------------------------------------
            RID                 => AXI_RID             , -- In  :
            RDATA               => AXI_RDATA           , -- In  :
            RRESP               => AXI_RRESP           , -- In  :
            RLAST               => AXI_RLAST           , -- In  :
            RVALID              => AXI_RVALID          , -- In  :
            RREADY              => AXI_RREADY          , -- Out :
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
            REQ_ADDR            => req_addr            , -- In  :
            REQ_SIZE            => req_size            , -- In  :
            REQ_ID              => req_id              , -- In  :
            REQ_BURST           => AXI4_ABURST_INCR    , -- In  :
            REQ_LOCK            => REQ_LOCK            , -- In  :
            REQ_CACHE           => req_cache           , -- In  :
            REQ_PROT            => req_prot            , -- In  :
            REQ_QOS             => REQ_QOS             , -- In  :
            REQ_REGION          => REQ_REGION          , -- In  :
            REQ_BUF_PTR         => req_buf_ptr         , -- In  :
            REQ_FIRST           => req_first           , -- In  :
            REQ_LAST            => req_last            , -- In  :
            REQ_SPECULATIVE     => req_speculative     , -- In  :
            REQ_SAFETY          => req_safety          , -- In  :
            REQ_VAL             => req_valid           , -- In  :
            REQ_RDY             => req_ready           , -- Out :
            XFER_SIZE_SEL       => "1"                 , -- In  :
        ---------------------------------------------------------------------------
        -- Response Signals.
        ---------------------------------------------------------------------------
            ACK_VAL             => ack_valid           , -- Out :
            ACK_ERROR           => ack_error           , -- Out :
            ACK_NEXT            => ack_next            , -- Out :
            ACK_LAST            => ack_last            , -- Out :
            ACK_STOP            => ack_stop            , -- Out :
            ACK_NONE            => ack_none            , -- Out :
            ACK_SIZE            => ack_size            , -- Out :
        ---------------------------------------------------------------------------
        -- Transfer Status Signal.
        ---------------------------------------------------------------------------
            XFER_BUSY           => xfer_busy           , -- Out :
            XFER_DONE           => xfer_done           , -- Out :
            XFER_ERROR          => xfer_error          , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_PAUSE          => flow_pause          , -- In  :
            FLOW_STOP           => flow_stop           , -- In  :
            FLOW_LAST           => flow_last           , -- In  :
            FLOW_SIZE           => flow_size           , -- In  :
        ---------------------------------------------------------------------------
        -- Reserve Size Signals.
        ---------------------------------------------------------------------------
            PUSH_RSV_VAL        => open                , -- Out :
            PUSH_RSV_SIZE       => open                , -- Out :
            PUSH_RSV_LAST       => open                , -- Out :
            PUSH_RSV_ERROR      => open                , -- Out :
        ---------------------------------------------------------------------------
        -- Push Size Signals.
        ---------------------------------------------------------------------------
            PUSH_FIN_VAL        => push_fin_valid      , -- Out :
            PUSH_FIN_SIZE       => push_fin_size       , -- Out :
            PUSH_FIN_LAST       => push_fin_last       , -- Out :
            PUSH_FIN_ERROR      => push_fin_error      , -- Out :
        ---------------------------------------------------------------------------
        -- Push Size Signals.
        ---------------------------------------------------------------------------
            PUSH_BUF_RESET      => push_buf_reset      , -- Out :
            PUSH_BUF_VAL        => push_buf_valid      , -- Out :
            PUSH_BUF_SIZE       => push_buf_size       , -- Out :
            PUSH_BUF_LAST       => push_buf_last       , -- Out :
            PUSH_BUF_ERROR      => push_buf_error      , -- Out :
            PUSH_BUF_RDY        => push_buf_ready      , -- In  :
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_WEN             => buf_wen             , -- Out :
            BUF_BEN             => buf_ben             , -- Out :
            BUF_DATA            => buf_wdata           , -- Out :
            BUF_PTR             => buf_wptr              -- Out :
        );                                               --
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    REQ_MODE_BLK: block
        function  GEN_REQ_ID(AID:std_logic_vector) return std_logic_vector is
            variable  id              :  integer;
        begin
            id := AXI_ID_BASE + to_integer(to_01(unsigned(AID)));
            return std_logic_vector(to_unsigned(id, AXI_ID_WIDTH));
        end function;
    begin 
        process (CLK, RST) begin
            if (RST = '1') then
                    AXI_ARUSER <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    AXI_ARUSER <= (others => '0');
                elsif (req_valid /= REQ_VALID_ALL0 and req_ready = '1') then
                    AXI_ARUSER <= std_logic_vector(resize(unsigned(req_mode(REQ_MODE_FIELD.AUSER.HI downto REQ_MODE_FIELD.AUSER.LO)), AXI_AUSER_WIDTH));
                end if;
            end if;
        end process;
        req_id          <= GEN_REQ_ID(req_mode(REQ_MODE_FIELD.AID.HI downto REQ_MODE_FIELD.AID.LO));
        req_cache       <= req_mode(REQ_MODE_FIELD.CACHE.HI downto REQ_MODE_FIELD.CACHE.LO);
        req_prot        <= req_mode(REQ_MODE_FIELD.APROT.HI downto REQ_MODE_FIELD.APROT.LO);
        req_speculative <= req_mode(REQ_MODE_FIELD.SPECUL.POS);
        req_safety      <= req_mode(REQ_MODE_FIELD.SAFETY.POS);
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    REQ: block
        constant  ARB_NULL          :  std_logic_vector  (WAYS-1 downto 0) := (others => '0');
        signal    arb_request       :  std_logic_vector  (0 to WAYS-1);
        signal    arb_grant         :  std_logic_vector  (0 to WAYS-1);
        signal    arb_valid         :  std_logic;
        signal    arb_shift         :  std_logic;
        type      STATE_TYPE        is (IDLE_STATE, REQ_STATE, ACK_STATE);
        signal    curr_state        :  STATE_TYPE;
        signal    arb_sel           :  std_logic_vector  (WAYS-1 downto 0);
        signal    curr_val          :  std_logic_vector  (WAYS-1 downto 0);
        function  REVERSE_VECTOR(A: in std_logic_vector) return std_logic_vector is
            variable  reserved_a :  std_logic_vector(A'reverse_range);
        begin
            for i in reserved_a'range loop
                reserved_a(i) := A(i);
            end loop;
            return reserved_a;
        end function;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ARB: QUEUE_TREE_ARBITER                  -- 
            generic map (                        -- 
                MIN_NUM     => 0              ,  -- 
                MAX_NUM     => WAYS-1         , -- 
                NODE_NUM    => ARB_NODE_NUM   ,  --
                PIPELINE    => ARB_PIPELINE      -- 
            )                                    -- 
            port map (                           -- 
                CLK         => CLK            ,  -- In  :
                RST         => RST            ,  -- In  :
                CLR         => CLR            ,  -- In  :
                REQUEST     => arb_request    ,  -- In  :
                GRANT       => arb_grant      ,  -- Out :
                VALID       => arb_valid      ,  -- Out :
                SHIFT       => arb_shift         -- In  :
            );                                   --
        arb_request <= REVERSE_VECTOR(i_req_valid);
        arb_sel     <= REVERSE_VECTOR(arb_grant);
        arb_shift   <= '1' when ((ack_valid and curr_val) /= ARB_NULL) else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if (RST = '1') then
                    curr_state  <= IDLE_STATE;
                    curr_val    <= (others => '0');
                    req_addr    <= (others => '0');
                    req_size    <= (others => '0');
                    req_buf_ptr <= (others => '0');
                    req_mode    <= (others => '0');
                    req_first   <= '0';
                    req_last    <= '0';
                    req_none    <= '0';
                    flow_stop   <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    curr_state  <= IDLE_STATE;
                    curr_val    <= (others => '0');
                    req_addr    <= (others => '0');
                    req_size    <= (others => '0');
                    req_buf_ptr <= (others => '0');
                    req_mode    <= (others => '0');
                    req_first   <= '0';
                    req_last    <= '0';
                    req_none    <= '0';
                    flow_stop   <= '0';
                else
                    case curr_state is
                        when IDLE_STATE =>
                            if (arb_valid = '1') then
                                curr_state <= REQ_STATE;
                                curr_val   <= arb_sel;
                            else
                                curr_state <= IDLE_STATE;
                                curr_val   <= (others => '0');
                            end if;
                            req_addr    <= SELECT_REQ_ADDR(   arb_sel, i_req_addr   );
                            req_size    <= SELECT_REQ_SIZE(   arb_sel, i_req_size   );
                            req_buf_ptr <= SELECT_REQ_BUF_PTR(arb_sel, i_req_buf_ptr);
                            req_mode    <= SELECT_REQ_MODE(   arb_sel, i_req_mode   );
                            req_first   <= SELECT_REQ_FLAG(   arb_sel, i_req_first  );
                            req_last    <= SELECT_REQ_FLAG(   arb_sel, i_req_last   );
                            req_none    <= SELECT_REQ_FLAG(   arb_sel, i_req_none   );
                            flow_stop   <= SELECT_REQ_FLAG(   arb_sel, i_flow_stop  );
                        when REQ_STATE =>
                            if    (REQ_READY = '0') then
                                curr_state <= REQ_STATE;
                            elsif (arb_shift = '1') then
                                curr_state <= IDLE_STATE;
                                curr_val   <= (others => '0');
                                flow_stop  <= '0';
                            else
                                curr_state <= ACK_STATE;
                            end if;
                        when ACK_STATE =>
                            if (arb_shift = '1') then
                                curr_state <= IDLE_STATE;
                                curr_val   <= (others => '0');
                                flow_stop  <= '0';
                            else
                                curr_state <= ACK_STATE;
                            end if;
                        when others => 
                                curr_state <= IDLE_STATE;
                                curr_val   <= (others => '0');
                                flow_stop  <= '0';
                    end case;
                end if;
            end if;
        end process;
        req_valid   <= curr_val;
        flow_pause  <= '0';
        flow_last   <= '0';
        flow_size   <= std_logic_vector(to_unsigned(MAX_XFER_BYTES, FLOW_SIZE'length));
        i_req_ready <= (others => '1');
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    MRG: for channel in 0 to WAYS-1 generate 
        signal    reg_load          :  std_logic_vector(MRG_REG_PARAM.BITS-1 downto 0);
        signal    reg_wbit          :  std_logic_vector(MRG_REG_PARAM.BITS-1 downto 0);
        signal    reg_rbit          :  std_logic_vector(MRG_REG_PARAM.BITS-1 downto 0);
        signal    mrg_in_data       :  std_logic_vector(WORDS*WORD_BITS   -1 downto 0);
        signal    mrg_in_none       :  std_logic_vector(WORDS             -1 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        reg_load <= MRG_REG_L((channel+1)*MRG_REG_PARAM.BITS-1 downto channel*MRG_REG_PARAM.BITS);
        reg_wbit <= MRG_REG_D((channel+1)*MRG_REG_PARAM.BITS-1 downto channel*MRG_REG_PARAM.BITS);
        MRG_REG_Q((channel+1)*MRG_REG_PARAM.BITS-1 downto channel*MRG_REG_PARAM.BITS) <= reg_rbit;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        READER:  Merge_Reader                                    -- 
            generic map (                                        --
                CHANNEL             => channel                 , -- 
                WORDS               => WORDS                   , -- 
                WORD_BITS           => WORD_BITS               , --   
                REG_PARAM           => MRG_REG_PARAM           , --
                REQ_ADDR_BITS       => AXI_ADDR_WIDTH          , --   
                REQ_SIZE_BITS       => REQ_SIZE_BITS           , --   
                BUF_DATA_BITS       => BUF_DATA_BITS           , --   
                BUF_DEPTH           => BUF_DEPTH               , --   
                MAX_XFER_SIZE       => AXI_XFER_SIZE           , --   
                ARB_NODE_NUM        => ARB_NODE_NUM            , --   
                ARB_PIPELINE        => ARB_PIPELINE              --   
            )                                                    -- 
            port map (                                           -- 
            -----------------------------------------------------------------------
            -- Clock/Reset Signals.
            -----------------------------------------------------------------------
                CLK                 => CLK                     , --  In  :
                RST                 => RST                     , --  In  :
                CLR                 => CLR                     , --  In  :
            -----------------------------------------------------------------------
            -- Register Interface
            -----------------------------------------------------------------------
                REG_L               => reg_load                , --  In  :
                REG_D               => reg_wbit                , --  In  :
                REG_Q               => reg_rbit                , --  Out :
            -----------------------------------------------------------------------
            -- Transaction Command Request Signals.
            -----------------------------------------------------------------------
                REQ_VALID           => i_req_valid   (channel) , --  Out :
                REQ_ADDR            => i_req_addr    (channel) , --  Out :
                REQ_SIZE            => i_req_size    (channel) , --  Out :
                REQ_BUF_PTR         => i_req_buf_ptr (channel) , --  Out :
                REQ_MODE            => i_req_mode    (channel) , --  Out :
                REQ_FIRST           => i_req_first   (channel) , --  Out :
                REQ_LAST            => i_req_last    (channel) , --  Out :
                REQ_NONE            => i_req_none    (channel) , --  Out :
                REQ_READY           => i_req_ready   (channel) , --  In  :
            -----------------------------------------------------------------------
            -- Transaction Command Acknowledge Signals.
            -----------------------------------------------------------------------
                ACK_VALID           => ack_valid     (channel) , --  In  :
                ACK_SIZE            => ack_size                , --  In  :
                ACK_ERROR           => ack_error               , --  In  :
                ACK_NEXT            => ack_next                , --  In  :
                ACK_LAST            => ack_last                , --  In  :
                ACK_STOP            => ack_stop                , --  In  :
                ACK_NONE            => ack_none                , --  In  :
            -----------------------------------------------------------------------
            -- Transfer Status Signals.
            -----------------------------------------------------------------------
                XFER_BUSY           => xfer_busy     (channel) , --  In  :
                XFER_DONE           => xfer_done     (channel) , --  In  :
                XFER_ERROR          => xfer_error    (channel) , --  In  :
            -----------------------------------------------------------------------
            -- Intake Flow Control Signals.
            -----------------------------------------------------------------------
                FLOW_READY          => open                    , --  Out :
                FLOW_PAUSE          => open                    , --  Out :
                FLOW_STOP           => i_flow_stop   (channel) , --  Out :
                FLOW_LAST           => open                    , --  Out :
                FLOW_SIZE           => open                    , --  Out :
                PUSH_FIN_VALID      => push_fin_valid(channel) , --  In  :
                PUSH_FIN_LAST       => push_fin_last           , --  In  :
                PUSH_FIN_ERROR      => push_fin_error          , --  In  :
                PUSH_FIN_SIZE       => push_fin_size           , --  In  :
                PUSH_BUF_RESET      => push_buf_reset(channel) , --  In  :
                PUSH_BUF_VALID      => push_buf_valid(channel) , --  In  :
                PUSH_BUF_LAST       => push_buf_last           , --  In  :
                PUSH_BUF_ERROR      => push_buf_error          , --  In  :
                PUSH_BUF_SIZE       => push_buf_size           , --  In  :
                PUSH_BUF_READY      => push_buf_ready(channel) , --  Out :
            -----------------------------------------------------------------------
            -- Buffer Interface Signals.
            -----------------------------------------------------------------------
                BUF_WEN             => buf_wen       (channel) , --  In  :
                BUF_BEN             => buf_ben                 , --  In  :
                BUF_DATA            => buf_wdata               , --  In  :
                BUF_PTR             => buf_wptr                , --  In  :
            -----------------------------------------------------------------------
            -- Merge Outlet Signals.
            -----------------------------------------------------------------------
                MRG_DATA            => mrg_in_data             , --  Out :
                MRG_NONE            => mrg_in_none             , --  Out :
                MRG_EBLK            => MRG_EBLK      (channel) , --  Out :
                MRG_LAST            => MRG_LAST      (channel) , --  Out :
                MRG_VALID           => MRG_VALID     (channel) , --  Out :
                MRG_READY           => MRG_READY     (channel) , --  In  :
                MRG_LEVEL           => MRG_LEVEL     (channel) , --  In  :
            -----------------------------------------------------------------------
            -- Status Output.
            -----------------------------------------------------------------------
                BUSY                => BUSY          (channel) , --  Out :
                DONE                => DONE          (channel)   --  Out :
            );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        MRG_DATA((channel+1)*(WORDS*WORD_BITS)-1 downto channel*(WORDS*WORD_BITS)) <= mrg_in_data;
        MRG_NONE((channel+1)*(WORDS          )-1 downto channel*(WORDS          )) <= mrg_in_none;
    end generate;
end RTL;

