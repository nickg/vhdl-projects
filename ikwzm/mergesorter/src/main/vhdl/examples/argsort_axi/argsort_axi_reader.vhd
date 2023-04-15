-----------------------------------------------------------------------------------
--!     @file    argsort_axi_reader.vhd
--!     @brief   Merge Sorter ArgSort AXI Reader Module :
--!     @version 1.3.0
--!     @date    2021/7/14
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
entity  ArgSort_AXI_Reader is
    generic (
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        WORD_INDEX_LO   :  integer :=  0;
        WORD_INDEX_HI   :  integer := 31;
        WORD_COMP_LO    :  integer := 32;
        WORD_COMP_HI    :  integer := 63;
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
        STM_REG_PARAM   :  Interface.Regs_Field_Type := Interface.Default_Regs_Param
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
        AXI_ARID        :  out std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_ARADDR      :  out std_logic_vector(AXI_ADDR_WIDTH  -1 downto 0);
        AXI_ARLEN       :  out std_logic_vector(7 downto 0);
        AXI_ARSIZE      :  out std_logic_vector(2 downto 0);
        AXI_ARBURST     :  out std_logic_vector(1 downto 0);
        AXI_ARLOCK      :  out std_logic_vector(0 downto 0);
        AXI_ARCACHE     :  out std_logic_vector(3 downto 0);
        AXI_ARPROT      :  out std_logic_vector(2 downto 0);
        AXI_ARQOS       :  out std_logic_vector(3 downto 0);
        AXI_ARREGION    :  out std_logic_vector(3 downto 0);
        AXI_ARUSER      :  out std_logic_vector(AXI_AUSER_WIDTH -1 downto 0);
        AXI_ARVALID     :  out std_logic;
        AXI_ARREADY     :  in  std_logic;
    -------------------------------------------------------------------------------
    -- AXI Master Read Data Channel Signals.
    -------------------------------------------------------------------------------
        AXI_RID         :  in  std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_RDATA       :  in  std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        AXI_RRESP       :  in  std_logic_vector(1 downto 0);
        AXI_RLAST       :  in  std_logic;
        AXI_RVALID      :  in  std_logic;
        AXI_RREADY      :  out std_logic;
    -------------------------------------------------------------------------------
    -- Stream Reader Control Register Interface.
    -------------------------------------------------------------------------------
        STM_REG_L       :  in  std_logic_vector(STM_REG_PARAM.BITS  -1 downto 0);
        STM_REG_D       :  in  std_logic_vector(STM_REG_PARAM.BITS  -1 downto 0);
        STM_REG_Q       :  out std_logic_vector(STM_REG_PARAM.BITS  -1 downto 0);
    -------------------------------------------------------------------------------
    -- Stream Outlet Signals.
    -------------------------------------------------------------------------------
        STM_DATA        :  out std_logic_vector(WORDS*WORD_BITS  -1 downto 0);
        STM_STRB        :  out std_logic_vector(WORDS            -1 downto 0);
        STM_LAST        :  out std_logic;
        STM_VALID       :  out std_logic;
        STM_READY       :  in  std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end ArgSort_AXI_Reader;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library Merge_Sorter;
use     Merge_Sorter.Interface;
use     Merge_Sorter.ArgSort_AXI_Components.ArgSort_Reader;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_READ_INTERFACE;
architecture RTL of ArgSort_AXI_Reader is
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    constant  WORD_COMP_BITS    :  integer := WORD_COMP_HI  - WORD_COMP_LO  + 1;
    constant  WORD_INDEX_BITS   :  integer := WORD_INDEX_HI - WORD_INDEX_LO + 1;
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
    constant  ALIGNMENT_BITS    :  integer := MIN(      WORD_COMP_BITS, AXI_DATA_WIDTH);
    constant  BUF_DATA_BITS     :  integer := MAX(WORDS*WORD_COMP_BITS, AXI_DATA_WIDTH);
    constant  BUF_DEPTH         :  integer := AXI_BUF_DEPTH;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    constant  XFER_SIZE_BITS    :  integer := BUF_DEPTH+1;
    constant  REQ_SIZE_BITS     :  integer := STM_REG_PARAM.SIZE.BITS;
    constant  REQ_MODE_BITS     :  integer := STM_REG_PARAM.MODE.BITS;
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
    signal    req_valid         :  std_logic;
    signal    req_none          :  std_logic;
    signal    req_ready         :  std_logic;
    signal    xfer_busy         :  std_logic;
    signal    xfer_done         :  std_logic;
    signal    xfer_error        :  std_logic;
    signal    ack_valid         :  std_logic;
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
    signal    push_fin_valid    :  std_logic;
    signal    push_fin_error    :  std_logic;
    signal    push_fin_last     :  std_logic;
    signal    push_fin_size     :  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    signal    push_buf_valid    :  std_logic;
    signal    push_buf_ready    :  std_logic;
    signal    push_buf_reset    :  std_logic;
    signal    push_buf_error    :  std_logic;
    signal    push_buf_last     :  std_logic;
    signal    push_buf_size     :  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    signal    buf_wdata         :  std_logic_vector(BUF_DATA_BITS  -1 downto 0);
    signal    buf_ben           :  std_logic_vector(BUF_DATA_BITS/8-1 downto 0);
    signal    buf_wptr          :  std_logic_vector(BUF_DEPTH      -1 downto 0);
    signal    buf_wen           :  std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    AXI_IF: AXI4_MASTER_READ_INTERFACE                   -- 
        generic map (                                    -- 
            AXI4_ADDR_WIDTH     => AXI_ADDR_WIDTH      , -- 
            AXI4_DATA_WIDTH     => AXI_DATA_WIDTH      , -- 
            AXI4_ID_WIDTH       => AXI_ID_WIDTH        , -- 
            VAL_BITS            => 1                   , -- 
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
            REQ_VAL(0)          => req_valid           , -- In  :
            REQ_RDY             => req_ready           , -- Out :
            XFER_SIZE_SEL       => "1"                 , -- In  :
        ---------------------------------------------------------------------------
        -- Response Signals.
        ---------------------------------------------------------------------------
            ACK_VAL(0)          => ack_valid           , -- Out :
            ACK_ERROR           => ack_error           , -- Out :
            ACK_NEXT            => ack_next            , -- Out :
            ACK_LAST            => ack_last            , -- Out :
            ACK_STOP            => ack_stop            , -- Out :
            ACK_NONE            => ack_none            , -- Out :
            ACK_SIZE            => ack_size            , -- Out :
        ---------------------------------------------------------------------------
        -- Transfer Status Signal.
        ---------------------------------------------------------------------------
            XFER_BUSY(0)        => xfer_busy           , -- Out :
            XFER_DONE(0)        => xfer_done           , -- Out :
            XFER_ERROR(0)       => xfer_error          , -- Out :
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
                elsif (req_valid = '1' and req_ready = '1') then
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
    READER:  ArgSort_Reader                              -- 
        generic map (                                    -- 
            WORDS               => WORDS               , --   
            WORD_BITS           => WORD_BITS           , --   
            REG_PARAM           => STM_REG_PARAM       , -- 
            REQ_ADDR_BITS       => AXI_ADDR_WIDTH      , --   
            REQ_SIZE_BITS       => REQ_SIZE_BITS       , --   
            BUF_DATA_BITS       => BUF_DATA_BITS       , --   
            BUF_DEPTH           => BUF_DEPTH           , --   
            MAX_XFER_SIZE       => AXI_XFER_SIZE       , --   
            WORD_INDEX_LO       => WORD_INDEX_LO       , --   
            WORD_INDEX_HI       => WORD_INDEX_HI       , --   
            WORD_COMP_LO        => WORD_COMP_LO        , --   
            WORD_COMP_HI        => WORD_COMP_HI          --   
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        -- Clock/Reset Signals.
        ---------------------------------------------------------------------------
            CLK                 => CLK                 , --  In  :
            RST                 => RST                 , --  In  :
            CLR                 => CLR                 , --  In  :
        ---------------------------------------------------------------------------
        -- Register Interface
        ---------------------------------------------------------------------------
            REG_L               => STM_REG_L           , --  In  :
            REG_D               => STM_REG_D           , --  In  :
            REG_Q               => STM_REG_Q           , --  Out :
        ---------------------------------------------------------------------------
        -- Transaction Command Request Signals.
        ---------------------------------------------------------------------------
            REQ_VALID           => req_valid           , --  Out :
            REQ_ADDR            => req_addr            , --  Out :
            REQ_SIZE            => req_size            , --  Out :
            REQ_BUF_PTR         => req_buf_ptr         , --  Out :
            REQ_MODE            => req_mode            , --  Out :
            REQ_FIRST           => req_first           , --  Out :
            REQ_LAST            => req_last            , --  Out :
            REQ_NONE            => req_none            , --  Out :
            REQ_READY           => req_ready           , --  In  :
        ---------------------------------------------------------------------------
        -- Transaction Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            ACK_VALID           => ack_valid           , --  In  :
            ACK_SIZE            => ack_size            , --  In  :
            ACK_ERROR           => ack_error           , --  In  :
            ACK_NEXT            => ack_next            , --  In  :
            ACK_LAST            => ack_last            , --  In  :
            ACK_STOP            => ack_stop            , --  In  :
            ACK_NONE            => ack_none            , --  In  :
        ---------------------------------------------------------------------------
        -- Transfer Status Signals.
        ---------------------------------------------------------------------------
            XFER_BUSY           => xfer_busy           , --  In  :
            XFER_DONE           => xfer_done           , --  In  :
            XFER_ERROR          => xfer_error          , --  In  :
        ---------------------------------------------------------------------------
        -- Intake Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_READY          => open                , --  Out :
            FLOW_PAUSE          => flow_pause          , --  Out :
            FLOW_STOP           => flow_stop           , --  Out :
            FLOW_LAST           => flow_last           , --  Out :
            FLOW_SIZE           => flow_size           , --  Out :
            PUSH_FIN_VALID      => push_fin_valid      , --  In  :
            PUSH_FIN_LAST       => push_fin_last       , --  In  :
            PUSH_FIN_ERROR      => push_fin_error      , --  In  :
            PUSH_FIN_SIZE       => push_fin_size       , --  In  :
            PUSH_BUF_RESET      => push_buf_reset      , --  In  :
            PUSH_BUF_VALID      => push_buf_valid      , --  In  :
            PUSH_BUF_LAST       => push_buf_last       , --  In  :
            PUSH_BUF_ERROR      => push_buf_error      , --  In  :
            PUSH_BUF_SIZE       => push_buf_size       , --  In  :
            PUSH_BUF_READY      => push_buf_ready      , --  Out :
        ---------------------------------------------------------------------------
        -- Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_WEN             => buf_wen             , --  In  :
            BUF_BEN             => buf_ben             , --  In  :
            BUF_DATA            => buf_wdata           , --  In  :
            BUF_PTR             => buf_wptr            , --  In  :
        ---------------------------------------------------------------------------
        -- Stream Outlet Signals.
        ---------------------------------------------------------------------------
            STM_DATA            => STM_DATA            , --  Out :
            STM_STRB            => STM_STRB            , --  Out :
            STM_LAST            => STM_LAST            , --  Out :
            STM_VALID           => STM_VALID           , --  Out :
            STM_READY           => STM_READY           , --  In  :
        ---------------------------------------------------------------------------
        -- Status Output.
        ---------------------------------------------------------------------------
            BUSY                => BUSY                , --  Out :
            DONE                => DONE                  --  Out :
        );
end RTL;
