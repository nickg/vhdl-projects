-----------------------------------------------------------------------------------
--!     @file    merge_axi_writer.vhd
--!     @brief   Merge Sorter Merge AXI Writer Module :
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
entity  Merge_AXI_Writer is
    generic (
        WORDS           :  integer :=  1;
        WORD_BITS       :  integer := 64;
        AXI_ID_BASE     :  integer :=  0;
        AXI_ID_WIDTH    :  integer :=  8;
        AXI_AUSER_WIDTH :  integer :=  4;
        AXI_WUSER_WIDTH :  integer :=  4;
        AXI_BUSER_WIDTH :  integer :=  4;
        AXI_ADDR_WIDTH  :  integer := 32;
        AXI_DATA_WIDTH  :  integer := 64;
        AXI_XFER_SIZE   :  integer := 11;
        AXI_BUF_DEPTH   :  integer := 12;
        AXI_QUEUE_SIZE  :  integer :=  4;
        AXI_REQ_REGS    :  integer range 0 to 1 :=  1;
        AXI_ACK_REGS    :  integer range 0 to 1 :=  1;
        AXI_RESP_REGS   :  integer range 0 to 1 :=  1;
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
    -- AXI Master Writer Address Channel Signals.
    -------------------------------------------------------------------------------
        AXI_AWID        :  out std_logic_vector(AXI_ID_WIDTH     -1 downto 0);
        AXI_AWADDR      :  out std_logic_vector(AXI_ADDR_WIDTH   -1 downto 0);
        AXI_AWLEN       :  out std_logic_vector(7 downto 0);
        AXI_AWSIZE      :  out std_logic_vector(2 downto 0);
        AXI_AWBURST     :  out std_logic_vector(1 downto 0);
        AXI_AWLOCK      :  out std_logic_vector(0 downto 0);
        AXI_AWCACHE     :  out std_logic_vector(3 downto 0);
        AXI_AWPROT      :  out std_logic_vector(2 downto 0);
        AXI_AWQOS       :  out std_logic_vector(3 downto 0);
        AXI_AWREGION    :  out std_logic_vector(3 downto 0);
        AXI_AWUSER      :  out std_logic_vector(AXI_AUSER_WIDTH  -1 downto 0);
        AXI_AWVALID     :  out std_logic;
        AXI_AWREADY     :  in  std_logic;
    ------------------------------------------------------------------------------
    -- AXI Master Write Data Channel Signals.
    ------------------------------------------------------------------------------
        AXI_WID         :  out std_logic_vector(AXI_ID_WIDTH     -1 downto 0);
        AXI_WDATA       :  out std_logic_vector(AXI_DATA_WIDTH   -1 downto 0);
        AXI_WSTRB       :  out std_logic_vector(AXI_DATA_WIDTH/8 -1 downto 0);
        AXI_WUSER       :  out std_logic_vector(AXI_WUSER_WIDTH  -1 downto 0);
        AXI_WLAST       :  out std_logic;
        AXI_WVALID      :  out std_logic;
        AXI_WREADY      :  in  std_logic;
    ------------------------------------------------------------------------------
    -- AXI Write Response Channel Signals.
    ------------------------------------------------------------------------------
        AXI_BID         :  in  std_logic_vector(AXI_ID_WIDTH     -1 downto 0);
        AXI_BRESP       :  in  std_logic_vector(1 downto 0);
        AXI_BUSER       :  in  std_logic_vector(AXI_BUSER_WIDTH  -1 downto 0);
        AXI_BVALID      :  in  std_logic;
        AXI_BREADY      :  out std_logic;
    -------------------------------------------------------------------------------
    -- Merge Writer Control Register Interface.
    -------------------------------------------------------------------------------
        MRG_REG_L       :  in  std_logic_vector(MRG_REG_PARAM.BITS   -1 downto 0);
        MRG_REG_D       :  in  std_logic_vector(MRG_REG_PARAM.BITS   -1 downto 0);
        MRG_REG_Q       :  out std_logic_vector(MRG_REG_PARAM.BITS   -1 downto 0);
    -------------------------------------------------------------------------------
    -- Merge Intake Signals.
    -------------------------------------------------------------------------------
        MRG_DATA        :  in  std_logic_vector(WORDS*WORD_BITS  -1 downto 0);
        MRG_STRB        :  in  std_logic_vector(WORDS            -1 downto 0);
        MRG_LAST        :  in  std_logic;
        MRG_VALID       :  in  std_logic;
        MRG_READY       :  out std_logic;
    -------------------------------------------------------------------------------
    -- Status Output.
    -------------------------------------------------------------------------------
        BUSY            :  out std_logic;
        DONE            :  out std_logic
    );
end Merge_AXI_Writer;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library Merge_Sorter;
use     Merge_Sorter.Interface;
use     Merge_Sorter.Interface_Components.Merge_Writer;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_WRITE_INTERFACE;
architecture RTL of Merge_AXI_Writer is
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
    signal    req_valid         :  std_logic;
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
    signal    pull_fin_valid    :  std_logic;
    signal    pull_fin_error    :  std_logic;
    signal    pull_fin_last     :  std_logic;
    signal    pull_fin_size     :  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    signal    pull_rsv_valid    :  std_logic;
    signal    pull_rsv_error    :  std_logic;
    signal    pull_rsv_last     :  std_logic;
    signal    pull_rsv_size     :  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    signal    pull_buf_valid    :  std_logic;
    signal    pull_buf_ready    :  std_logic;
    signal    pull_buf_reset    :  std_logic;
    signal    pull_buf_error    :  std_logic;
    signal    pull_buf_last     :  std_logic;
    signal    pull_buf_size     :  std_logic_vector(XFER_SIZE_BITS -1 downto 0);
    signal    buf_rdata         :  std_logic_vector(BUF_DATA_BITS  -1 downto 0);
    signal    buf_rptr          :  std_logic_vector(BUF_DEPTH      -1 downto 0);
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    AXI_IF: AXI4_MASTER_WRITE_INTERFACE                  -- 
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
            REQ_REGS            => AXI_REQ_REGS        , -- 
            ACK_REGS            => AXI_ACK_REGS        , -- 
            QUEUE_SIZE          => AXI_QUEUE_SIZE      , -- 
            RESP_REGS           => AXI_RESP_REGS         -- 
        )                                                -- 
        port map (                                       -- 
        --------------------------------------------------------------------------
        -- Clock and Reset Signals.
        --------------------------------------------------------------------------
            CLK                 => CLK                 , -- In  :
            CLR                 => CLR                 , -- In  :
            RST                 => RST                 , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Write Address Channel Signals.
        --------------------------------------------------------------------------
            AWID                => AXI_AWID            , -- Out :
            AWADDR              => AXI_AWADDR          , -- Out :
            AWLEN               => AXI_AWLEN           , -- Out :
            AWSIZE              => AXI_AWSIZE          , -- Out :
            AWBURST             => AXI_AWBURST         , -- Out :
            AWLOCK              => AXI_AWLOCK          , -- Out :
            AWCACHE             => AXI_AWCACHE         , -- Out :
            AWPROT              => AXI_AWPROT          , -- Out :
            AWQOS               => AXI_AWQOS           , -- Out :
            AWREGION            => AXI_AWREGION        , -- Out :
            AWVALID             => AXI_AWVALID         , -- Out :
            AWREADY             => AXI_AWREADY         , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Write Data Channel Signals.
        --------------------------------------------------------------------------
            WID                 => AXI_WID             , -- Out :
            WDATA               => AXI_WDATA           , -- Out :
            WSTRB               => AXI_WSTRB           , -- Out :
            WLAST               => AXI_WLAST           , -- Out :
            WVALID              => AXI_WVALID          , -- Out :
            WREADY              => AXI_WREADY          , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Write Response Channel Signals.
        --------------------------------------------------------------------------
            BID                 => AXI_BID             , -- In  :
            BRESP               => AXI_BRESP           , -- In  :
            BVALID              => AXI_BVALID          , -- In  :
            BREADY              => AXI_BREADY          , -- Out :
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
            PULL_RSV_VAL        => open                , -- Out :
            PULL_RSV_SIZE       => open                , -- Out :
            PULL_RSV_LAST       => open                , -- Out :
            PULL_RSV_ERROR      => open                , -- Out :
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
                    AXI_AWUSER <= (others => '0');
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    AXI_AWUSER <= (others => '0');
                elsif (req_valid = '1' and req_ready = '1') then
                    AXI_AWUSER <= std_logic_vector(resize(unsigned(req_mode(REQ_MODE_FIELD.AUSER.HI downto REQ_MODE_FIELD.AUSER.LO)), AXI_AUSER_WIDTH));
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
    WRITER:  Merge_Writer                                -- 
        generic map (                                    -- 
            WORDS               => WORDS               , --   
            WORD_BITS           => WORD_BITS           , --   
            REG_PARAM           => MRG_REG_PARAM       , -- 
            REQ_ADDR_BITS       => AXI_ADDR_WIDTH      , --   
            REQ_SIZE_BITS       => REQ_SIZE_BITS       , --   
            BUF_DATA_BITS       => BUF_DATA_BITS       , --   
            BUF_DEPTH           => BUF_DEPTH           , --   
            MAX_XFER_SIZE       => AXI_XFER_SIZE         --   
        )                                                -- 
        port map (                                       -- 
        -------------------------------------------------------------------------------
        -- Clock/Reset Signals.
        -------------------------------------------------------------------------------
            CLK                 => CLK                 , --  In  :
            RST                 => RST                 , --  In  :
            CLR                 => CLR                 , --  In  :
        -------------------------------------------------------------------------------
        -- Register Interface
        -------------------------------------------------------------------------------
            REG_L               => MRG_REG_L           , --  In  :
            REG_D               => MRG_REG_D           , --  In  :
            REG_Q               => MRG_REG_Q           , --  Out :
        -------------------------------------------------------------------------------
        -- Transaction Command Request Signals.
        -------------------------------------------------------------------------------
            REQ_VALID           => req_valid           , --  Out :
            REQ_ADDR            => req_addr            , --  Out :
            REQ_SIZE            => req_size            , --  Out :
            REQ_BUF_PTR         => req_buf_ptr         , --  Out :
            REQ_MODE            => req_mode            , --  Out :
            REQ_FIRST           => req_first           , --  Out :
            REQ_LAST            => req_last            , --  Out :
            REQ_NONE            => req_none            , --  Out :
            REQ_READY           => req_ready           , --  In  :
        -------------------------------------------------------------------------------
        -- Transaction Command Acknowledge Signals.
        -------------------------------------------------------------------------------
            ACK_VALID           => ack_valid           , --  In  :
            ACK_SIZE            => ack_size            , --  In  :
            ACK_ERROR           => ack_error           , --  In  :
            ACK_NEXT            => ack_next            , --  In  :
            ACK_LAST            => ack_last            , --  In  :
            ACK_STOP            => ack_stop            , --  In  :
            ACK_NONE            => ack_none            , --  In  :
        -------------------------------------------------------------------------------
        -- Transfer Status Signals.
        -------------------------------------------------------------------------------
            XFER_BUSY           => xfer_busy           , --  In  :
            XFER_DONE           => xfer_done           , --  In  :
            XFER_ERROR          => xfer_error          , --  In  :
        -------------------------------------------------------------------------------
        -- Intake Flow Control Signals.
        -------------------------------------------------------------------------------
            FLOW_READY          => open                , --  Out :
            FLOW_PAUSE          => flow_pause          , --  Out :
            FLOW_STOP           => flow_stop           , --  Out :
            FLOW_LAST           => flow_last           , --  Out :
            FLOW_SIZE           => flow_size           , --  Out :
            PULL_FIN_VALID      => pull_fin_valid      , --  In  :
            PULL_FIN_LAST       => pull_fin_last       , --  In  :
            PULL_FIN_ERROR      => pull_fin_error      , --  In  :
            PULL_FIN_SIZE       => pull_fin_size       , --  In  :
            PULL_BUF_RESET      => pull_buf_reset      , --  In  :
            PULL_BUF_VALID      => pull_buf_valid      , --  In  :
            PULL_BUF_LAST       => pull_buf_last       , --  In  :
            PULL_BUF_ERROR      => pull_buf_error      , --  In  :
            PULL_BUF_SIZE       => pull_buf_size       , --  In  :
            PULL_BUF_READY      => pull_buf_ready      , --  Out :
        -------------------------------------------------------------------------------
        -- Buffer Interface Signals.
        -------------------------------------------------------------------------------
            BUF_DATA            => buf_rdata           , --  Out :
            BUF_PTR             => buf_rptr            , --  In  :
        -------------------------------------------------------------------------------
        -- Merge Outlet Signals.
        -------------------------------------------------------------------------------
            MRG_DATA            => MRG_DATA            , --  In  :
            MRG_STRB            => MRG_STRB            , --  In  :
            MRG_LAST            => MRG_LAST            , --  In  :
            MRG_VALID           => MRG_VALID           , --  In  :
            MRG_READY           => MRG_READY           , --  Out :
        -------------------------------------------------------------------------------
        -- Status Output.
        -------------------------------------------------------------------------------
            BUSY                => BUSY                , --  Out :
            DONE                => DONE                  --  Out :
        );
end RTL;
