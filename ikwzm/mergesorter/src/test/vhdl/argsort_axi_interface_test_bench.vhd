-----------------------------------------------------------------------------------
--!     @file    argsort_axi_interface_test_bench.vhd
--!     @brief   Merge Sorter ArgSort AXI Interface Test Bench :
--!     @version 0.2.0
--!     @date    2018/8/28
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018 Ichiro Kawazome
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
entity  ArgSort_AXI_Interface_Test_Bench is
    generic (
        NAME            :  STRING  := "TEST";
        SCENARIO_FILE   :  STRING  := "test.snr";
        AXI_ADDR_WIDTH  :  integer := 32;
        AXI_DATA_WIDTH  :  integer := 32;
        MAX_XFER_SIZE   :  integer := 12;
        MRG_IN_NUM      :  integer :=  4;
        MRG_DATA_BITS   :  integer := 64;
        STM_FEEDBACK    :  integer :=  1;
        STM_INDEX_LO    :  integer :=  0;
        STM_INDEX_HI    :  integer := 31;
        STM_COMP_LO     :  integer := 32;
        STM_COMP_HI     :  integer := 63;
        FINISH_ABORT    :  boolean := FALSE
    );
end ArgSort_AXI_Interface_Test_Bench;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library Merge_Sorter;
use     Merge_Sorter.Interface_Components.ArgSort_AXI_Interface;
library PIPEWORK;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_REGISTER_INTERFACE;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SLAVE_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_SLAVE_PLAYER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
architecture Model of ArgSort_AXI_Interface_Test_Bench is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant  PERIOD            :  time    := 10 ns;
    constant  DELAY             :  time    :=  1 ns;
    constant  SYNC_WIDTH        :  integer :=  2;
    constant  GPO_WIDTH         :  integer :=  8;
    constant  GPI_WIDTH         :  integer :=  GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal    CLOCK             :  std_logic;
    signal    ARESETn           :  std_logic;
    signal    RESET             :  std_logic;
    constant  CLEAR             :  std_logic := '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  REG_ADDR_BITS     :  integer := 64;
    constant  REG_SIZE_BITS     :  integer := 32;
    constant  REG_MODE_BITS     :  integer := 32;
    signal    reg_rd_addr_load  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_rd_addr_wbit  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_rd_addr_data  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_wr_addr_load  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_wr_addr_wbit  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_wr_addr_data  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_t0_addr_load  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_t0_addr_wbit  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_t0_addr_data  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_t1_addr_load  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_t1_addr_wbit  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_t1_addr_data  :  std_logic_vector(REG_ADDR_BITS-1 downto 0);
    signal    reg_size_load     :  std_logic_vector(REG_SIZE_BITS-1 downto 0);
    signal    reg_size_wbit     :  std_logic_vector(REG_SIZE_BITS-1 downto 0);
    signal    reg_size_data     :  std_logic_vector(REG_SIZE_BITS-1 downto 0);
    signal    reg_rd_mode_load  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_rd_mode_wbit  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_rd_mode_data  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_wr_mode_load  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_wr_mode_wbit  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_wr_mode_data  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_t0_mode_load  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_t0_mode_wbit  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_t0_mode_data  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_t1_mode_load  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_t1_mode_wbit  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_t1_mode_data  :  std_logic_vector(REG_MODE_BITS-1 downto 0);
    signal    reg_start_load    :  std_logic;
    signal    reg_start_wbit    :  std_logic;
    signal    reg_start_data    :  std_logic;
    signal    reg_reset_load    :  std_logic;
    signal    reg_reset_wbit    :  std_logic;
    signal    reg_reset_data    :  std_logic;
    signal    irq               :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    stm_req_valid     :  std_logic;
    signal    stm_req_ready     :  std_logic;
    signal    stm_res_valid     :  std_logic;
    signal    stm_res_ready     :  std_logic;
    signal    mrg_req_valid     :  std_logic;
    signal    mrg_req_ready     :  std_logic;
    signal    mrg_res_valid     :  std_logic;
    signal    mrg_res_ready     :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  CSR_WIDTH         :  AXI4_SIGNAL_WIDTH_TYPE := (
                                       ID          => 4,
                                       AWADDR      => AXI_ADDR_WIDTH,
                                       ARADDR      => AXI_ADDR_WIDTH,
                                       ALEN        => AXI4_ALEN_WIDTH,
                                       ALOCK       => AXI4_ALOCK_WIDTH,
                                       WDATA       => 32,
                                       RDATA       => 32,
                                       ARUSER      => 1,
                                       AWUSER      => 1,
                                       WUSER       => 1,
                                       RUSER       => 1,
                                       BUSER       => 1
                                   );
    signal    csr_araddr        :  std_logic_vector(CSR_WIDTH.ARADDR -1 downto 0);
    signal    csr_arwrite       :  std_logic;
    signal    csr_arlen         :  std_logic_vector(CSR_WIDTH.ALEN   -1 downto 0);
    signal    csr_arsize        :  AXI4_ASIZE_TYPE;
    signal    csr_arburst       :  AXI4_ABURST_TYPE;
    signal    csr_arlock        :  std_logic_vector(CSR_WIDTH.ALOCK  -1 downto 0);
    signal    csr_arcache       :  AXI4_ACACHE_TYPE;
    signal    csr_arprot        :  AXI4_APROT_TYPE;
    signal    csr_arqos         :  AXI4_AQOS_TYPE;
    signal    csr_arregion      :  AXI4_AREGION_TYPE;
    signal    csr_aruser        :  std_logic_vector(CSR_WIDTH.ARUSER -1 downto 0);
    signal    csr_arid          :  std_logic_vector(CSR_WIDTH.ID     -1 downto 0);
    signal    csr_arvalid       :  std_logic;
    signal    csr_arready       :  std_logic;
    signal    csr_rvalid        :  std_logic;
    signal    csr_rlast         :  std_logic;
    signal    csr_rdata         :  std_logic_vector(CSR_WIDTH.RDATA  -1 downto 0);
    signal    csr_rresp         :  AXI4_RESP_TYPE;
    signal    csr_ruser         :  std_logic_vector(CSR_WIDTH.RUSER  -1 downto 0);
    signal    csr_rid           :  std_logic_vector(CSR_WIDTH.ID     -1 downto 0);
    signal    csr_rready        :  std_logic;
    signal    csr_awaddr        :  std_logic_vector(CSR_WIDTH.AWADDR -1 downto 0);
    signal    csr_awlen         :  std_logic_vector(CSR_WIDTH.ALEN   -1 downto 0);
    signal    csr_awsize        :  AXI4_ASIZE_TYPE;
    signal    csr_awburst       :  AXI4_ABURST_TYPE;
    signal    csr_awlock        :  std_logic_vector(CSR_WIDTH.ALOCK  -1 downto 0);
    signal    csr_awcache       :  AXI4_ACACHE_TYPE;
    signal    csr_awprot        :  AXI4_APROT_TYPE;
    signal    csr_awqos         :  AXI4_AQOS_TYPE;
    signal    csr_awregion      :  AXI4_AREGION_TYPE;
    signal    csr_awuser        :  std_logic_vector(CSR_WIDTH.AWUSER -1 downto 0);
    signal    csr_awid          :  std_logic_vector(CSR_WIDTH.ID     -1 downto 0);
    signal    csr_awvalid       :  std_logic;
    signal    csr_awready       :  std_logic;
    signal    csr_wlast         :  std_logic;
    signal    csr_wdata         :  std_logic_vector(CSR_WIDTH.WDATA  -1 downto 0);
    signal    csr_wstrb         :  std_logic_vector(CSR_WIDTH.WDATA/8-1 downto 0);
    signal    csr_wuser         :  std_logic_vector(CSR_WIDTH.WUSER  -1 downto 0);
    signal    csr_wid           :  std_logic_vector(CSR_WIDTH.ID     -1 downto 0);
    signal    csr_wvalid        :  std_logic;
    signal    csr_wready        :  std_logic;
    signal    csr_bresp         :  AXI4_RESP_TYPE;
    signal    csr_buser         :  std_logic_vector(CSR_WIDTH.BUSER  -1 downto 0);
    signal    csr_bid           :  std_logic_vector(CSR_WIDTH.ID     -1 downto 0);
    signal    csr_bvalid        :  std_logic;
    signal    csr_bready        :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  STM_AXI_ID        :  integer := 1;
    constant  STM_AXI_WIDTH     :  AXI4_SIGNAL_WIDTH_TYPE := (
                                       ID          => 4,
                                       AWADDR      => AXI_ADDR_WIDTH,
                                       ARADDR      => AXI_ADDR_WIDTH,
                                       ALEN        => AXI4_ALEN_WIDTH,
                                       ALOCK       => AXI4_ALOCK_WIDTH,
                                       WDATA       => AXI_DATA_WIDTH,
                                       RDATA       => AXI_DATA_WIDTH,
                                       ARUSER      => 1,
                                       AWUSER      => 1,
                                       WUSER       => 1,
                                       RUSER       => 1,
                                       BUSER       => 1
                                  );
    signal    stm_axi_araddr    :  std_logic_vector(STM_AXI_WIDTH.ARADDR -1 downto 0);
    signal    stm_axi_arlen     :  std_logic_vector(STM_AXI_WIDTH.ALEN   -1 downto 0);
    signal    stm_axi_arsize    :  AXI4_ASIZE_TYPE;
    signal    stm_axi_arburst   :  AXI4_ABURST_TYPE;
    signal    stm_axi_arlock    :  std_logic_vector(STM_AXI_WIDTH.ALOCK  -1 downto 0);
    signal    stm_axi_arcache   :  AXI4_ACACHE_TYPE;
    signal    stm_axi_arprot    :  AXI4_APROT_TYPE;
    signal    stm_axi_arqos     :  AXI4_AQOS_TYPE;
    signal    stm_axi_arregion  :  AXI4_AREGION_TYPE;
    signal    stm_axi_aruser    :  std_logic_vector(STM_AXI_WIDTH.ARUSER -1 downto 0);
    signal    stm_axi_arid      :  std_logic_vector(STM_AXI_WIDTH.ID     -1 downto 0);
    signal    stm_axi_arvalid   :  std_logic;
    signal    stm_axi_arready   :  std_logic;
    signal    stm_axi_rvalid    :  std_logic;
    signal    stm_axi_rlast     :  std_logic;
    signal    stm_axi_rdata     :  std_logic_vector(STM_AXI_WIDTH.RDATA  -1 downto 0);
    signal    stm_axi_rresp     :  AXI4_RESP_TYPE;
    signal    stm_axi_ruser     :  std_logic_vector(STM_AXI_WIDTH.RUSER  -1 downto 0);
    signal    stm_axi_rid       :  std_logic_vector(STM_AXI_WIDTH.ID     -1 downto 0);
    signal    stm_axi_rready    :  std_logic;
    signal    stm_axi_awaddr    :  std_logic_vector(STM_AXI_WIDTH.AWADDR -1 downto 0);
    signal    stm_axi_awlen     :  std_logic_vector(STM_AXI_WIDTH.ALEN   -1 downto 0);
    signal    stm_axi_awsize    :  AXI4_ASIZE_TYPE;
    signal    stm_axi_awburst   :  AXI4_ABURST_TYPE;
    signal    stm_axi_awlock    :  std_logic_vector(STM_AXI_WIDTH.ALOCK  -1 downto 0);
    signal    stm_axi_awcache   :  AXI4_ACACHE_TYPE;
    signal    stm_axi_awprot    :  AXI4_APROT_TYPE;
    signal    stm_axi_awqos     :  AXI4_AQOS_TYPE;
    signal    stm_axi_awregion  :  AXI4_AREGION_TYPE;
    signal    stm_axi_awuser    :  std_logic_vector(STM_AXI_WIDTH.AWUSER -1 downto 0);
    signal    stm_axi_awid      :  std_logic_vector(STM_AXI_WIDTH.ID     -1 downto 0);
    signal    stm_axi_awvalid   :  std_logic;
    signal    stm_axi_awready   :  std_logic;
    signal    stm_axi_wlast     :  std_logic;
    signal    stm_axi_wdata     :  std_logic_vector(STM_AXI_WIDTH.WDATA  -1 downto 0);
    signal    stm_axi_wstrb     :  std_logic_vector(STM_AXI_WIDTH.WDATA/8-1 downto 0);
    signal    stm_axi_wuser     :  std_logic_vector(STM_AXI_WIDTH.WUSER  -1 downto 0);
    signal    stm_axi_wid       :  std_logic_vector(STM_AXI_WIDTH.ID     -1 downto 0);
    signal    stm_axi_wvalid    :  std_logic;
    signal    stm_axi_wready    :  std_logic;
    signal    stm_axi_bresp     :  AXI4_RESP_TYPE;
    signal    stm_axi_buser     :  std_logic_vector(STM_AXI_WIDTH.BUSER  -1 downto 0);
    signal    stm_axi_bid       :  std_logic_vector(STM_AXI_WIDTH.ID     -1 downto 0);
    signal    stm_axi_bvalid    :  std_logic;
    signal    stm_axi_bready    :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  MRG_AXI_ID        :  integer := 2;
    constant  MRG_AXI_WIDTH     :  AXI4_SIGNAL_WIDTH_TYPE := (
                                       ID          => 4,
                                       AWADDR      => AXI_ADDR_WIDTH,
                                       ARADDR      => AXI_ADDR_WIDTH,
                                       ALEN        => AXI4_ALEN_WIDTH,
                                       ALOCK       => AXI4_ALOCK_WIDTH,
                                       WDATA       => AXI_DATA_WIDTH,
                                       RDATA       => AXI_DATA_WIDTH,
                                       ARUSER      => 1,
                                       AWUSER      => 1,
                                       WUSER       => 1,
                                       RUSER       => 1,
                                       BUSER       => 1
                                  );
    signal    mrg_axi_araddr    :  std_logic_vector(MRG_AXI_WIDTH.ARADDR -1 downto 0);
    signal    mrg_axi_arlen     :  std_logic_vector(MRG_AXI_WIDTH.ALEN   -1 downto 0);
    signal    mrg_axi_arsize    :  AXI4_ASIZE_TYPE;
    signal    mrg_axi_arburst   :  AXI4_ABURST_TYPE;
    signal    mrg_axi_arlock    :  std_logic_vector(MRG_AXI_WIDTH.ALOCK  -1 downto 0);
    signal    mrg_axi_arcache   :  AXI4_ACACHE_TYPE;
    signal    mrg_axi_arprot    :  AXI4_APROT_TYPE;
    signal    mrg_axi_arqos     :  AXI4_AQOS_TYPE;
    signal    mrg_axi_arregion  :  AXI4_AREGION_TYPE;
    signal    mrg_axi_aruser    :  std_logic_vector(MRG_AXI_WIDTH.ARUSER -1 downto 0);
    signal    mrg_axi_arid      :  std_logic_vector(MRG_AXI_WIDTH.ID     -1 downto 0);
    signal    mrg_axi_arvalid   :  std_logic;
    signal    mrg_axi_arready   :  std_logic;
    signal    mrg_axi_rvalid    :  std_logic;
    signal    mrg_axi_rlast     :  std_logic;
    signal    mrg_axi_rdata     :  std_logic_vector(MRG_AXI_WIDTH.RDATA  -1 downto 0);
    signal    mrg_axi_rresp     :  AXI4_RESP_TYPE;
    signal    mrg_axi_ruser     :  std_logic_vector(MRG_AXI_WIDTH.RUSER  -1 downto 0);
    signal    mrg_axi_rid       :  std_logic_vector(MRG_AXI_WIDTH.ID     -1 downto 0);
    signal    mrg_axi_rready    :  std_logic;
    signal    mrg_axi_awaddr    :  std_logic_vector(MRG_AXI_WIDTH.AWADDR -1 downto 0);
    signal    mrg_axi_awlen     :  std_logic_vector(MRG_AXI_WIDTH.ALEN   -1 downto 0);
    signal    mrg_axi_awsize    :  AXI4_ASIZE_TYPE;
    signal    mrg_axi_awburst   :  AXI4_ABURST_TYPE;
    signal    mrg_axi_awlock    :  std_logic_vector(MRG_AXI_WIDTH.ALOCK  -1 downto 0);
    signal    mrg_axi_awcache   :  AXI4_ACACHE_TYPE;
    signal    mrg_axi_awprot    :  AXI4_APROT_TYPE;
    signal    mrg_axi_awqos     :  AXI4_AQOS_TYPE;
    signal    mrg_axi_awregion  :  AXI4_AREGION_TYPE;
    signal    mrg_axi_awuser    :  std_logic_vector(MRG_AXI_WIDTH.AWUSER -1 downto 0);
    signal    mrg_axi_awid      :  std_logic_vector(MRG_AXI_WIDTH.ID     -1 downto 0);
    signal    mrg_axi_awvalid   :  std_logic;
    signal    mrg_axi_awready   :  std_logic;
    signal    mrg_axi_wlast     :  std_logic;
    signal    mrg_axi_wdata     :  std_logic_vector(MRG_AXI_WIDTH.WDATA  -1 downto 0);
    signal    mrg_axi_wstrb     :  std_logic_vector(MRG_AXI_WIDTH.WDATA/8-1 downto 0);
    signal    mrg_axi_wuser     :  std_logic_vector(MRG_AXI_WIDTH.WUSER  -1 downto 0);
    signal    mrg_axi_wid       :  std_logic_vector(MRG_AXI_WIDTH.ID     -1 downto 0);
    signal    mrg_axi_wvalid    :  std_logic;
    signal    mrg_axi_wready    :  std_logic;
    signal    mrg_axi_bresp     :  AXI4_RESP_TYPE;
    signal    mrg_axi_buser     :  std_logic_vector(MRG_AXI_WIDTH.BUSER  -1 downto 0);
    signal    mrg_axi_bid       :  std_logic_vector(MRG_AXI_WIDTH.ID     -1 downto 0);
    signal    mrg_axi_bvalid    :  std_logic;
    signal    mrg_axi_bready    :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  STM_WR_NUM        :  integer := 1;
    signal    stm_wr_data       :  std_logic_vector(STM_WR_NUM*MRG_DATA_BITS  -1 downto 0);
    signal    stm_wr_strb       :  std_logic_vector(STM_WR_NUM*MRG_DATA_BITS/8-1 downto 0);
    signal    stm_wr_last       :  std_logic;
    signal    stm_wr_valid      :  std_logic;
    signal    stm_wr_ready      :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  STM_RD_NUM        :  integer := 1;
    signal    stm_rd_data       :  std_logic_vector(STM_RD_NUM*MRG_DATA_BITS  -1 downto 0);
    signal    stm_rd_strb       :  std_logic_vector(STM_RD_NUM*MRG_DATA_BITS/8-1 downto 0);
    signal    stm_rd_last       :  std_logic;
    signal    stm_rd_valid      :  std_logic;
    signal    stm_rd_ready      :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  MRG_WR_NUM        :  integer := 1;
    signal    mrg_wr_data       :  std_logic_vector(MRG_WR_NUM*MRG_DATA_BITS  -1 downto 0);
    signal    mrg_wr_strb       :  std_logic_vector(MRG_WR_NUM*MRG_DATA_BITS/8-1 downto 0);
    signal    mrg_wr_last       :  std_logic;
    signal    mrg_wr_valid      :  std_logic;
    signal    mrg_wr_ready      :  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    mrg_rd_data       :  std_logic_vector(MRG_IN_NUM*MRG_DATA_BITS-1 downto 0);
    signal    mrg_rd_none       :  std_logic_vector(MRG_IN_NUM-1 downto 0);
    signal    mrg_rd_eblk       :  std_logic_vector(MRG_IN_NUM-1 downto 0);
    signal    mrg_rd_level      :  std_logic_vector(MRG_IN_NUM-1 downto 0);
    signal    mrg_rd_last       :  std_logic_vector(MRG_IN_NUM-1 downto 0);
    signal    mrg_rd_valid      :  std_logic_vector(MRG_IN_NUM-1 downto 0);
    signal    mrg_rd_ready      :  std_logic_vector(MRG_IN_NUM-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    SYNC              :  SYNC_SIG_VECTOR (SYNC_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    csr_gpi           :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    csr_gpo           :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    stm_axi_gpi       :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    stm_axi_gpo       :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal    mrg_axi_gpi       :  std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal    mrg_axi_gpo       :  std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    N_REPORT          :  REPORT_STATUS_TYPE;
    signal    CSR_REPORT        :  REPORT_STATUS_TYPE;
    signal    STM_AXI_REPORT    :  REPORT_STATUS_TYPE;
    signal    MRG_AXI_REPORT    :  REPORT_STATUS_TYPE;
    signal    STM_WR_REPORT     :  REPORT_STATUS_TYPE;
    signal    STM_RD_REPORT     :  REPORT_STATUS_TYPE;
    signal    MRG_WR_REPORT     :  REPORT_STATUS_TYPE;
    signal    MRG_RD_REPORT     :  REPORT_STATUS_VECTOR(MRG_IN_NUM-1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal    N_FINISH          :  std_logic;
    signal    CSR_FINISH        :  std_logic;
    signal    STM_AXI_FINISH    :  std_logic;
    signal    MRG_AXI_FINISH    :  std_logic;
    signal    STM_WR_FINISH     :  std_logic;
    signal    STM_RD_FINISH     :  std_logic;
    signal    MRG_WR_FINISH     :  std_logic;
    signal    MRG_RD_FINISH     :  std_logic_vector(MRG_IN_NUM-1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    DUT:  ArgSort_AXI_Interface 
        generic map (
            MRG_AXI_ID          => MRG_AXI_ID          , -- 
            MRG_AXI_ID_WIDTH    => MRG_AXI_WIDTH.ID    , --   
            MRG_AXI_AUSER_WIDTH => MRG_AXI_WIDTH.ARUSER, --   
            MRG_AXI_ADDR_WIDTH  => AXI_ADDR_WIDTH      , --   
            MRG_AXI_DATA_WIDTH  => AXI_DATA_WIDTH      , --   
            MRG_MAX_XFER_SIZE   => MAX_XFER_SIZE       , --   
            STM_AXI_ID          => STM_AXI_ID          , --   
            STM_AXI_ID_WIDTH    => STM_AXI_WIDTH.ID    , --   
            STM_AXI_AUSER_WIDTH => STM_AXI_WIDTH.ARUSER, --   
            STM_AXI_WUSER_WIDTH => STM_AXI_WIDTH.WUSER , --   
            STM_AXI_BUSER_WIDTH => STM_AXI_WIDTH.BUSER , --   
            STM_AXI_ADDR_WIDTH  => AXI_ADDR_WIDTH      , --   
            STM_AXI_DATA_WIDTH  => AXI_DATA_WIDTH      , --   
            STM_MAX_XFER_SIZE   => MAX_XFER_SIZE       , --   
            MRG_IN_NUM          => MRG_IN_NUM          , --   
            MRG_WR_NUM          => MRG_WR_NUM          , --   
            MRG_DATA_BITS       => MRG_DATA_BITS       , --   
            STM_FEEDBACK        => STM_FEEDBACK        , --   
            STM_RD_NUM          => STM_RD_NUM          , --   
            STM_RD_DATA_BITS    => MRG_DATA_BITS       , --   
            STM_WR_NUM          => STM_WR_NUM          , --   
            STM_WR_DATA_BITS    => MRG_DATA_BITS       , --   
            STM_INDEX_LO        => STM_INDEX_LO        , --   
            STM_INDEX_HI        => STM_INDEX_HI        , --   
            STM_COMP_LO         => STM_COMP_LO         , --   
            STM_COMP_HI         => STM_COMP_HI         , --   
            REG_ADDR_BITS       => REG_ADDR_BITS       , --   
            REG_SIZE_BITS       => REG_SIZE_BITS       , --   
            REG_MODE_BITS       => REG_MODE_BITS         --   
        )                                                -- 
        port map (                                       -- 
        ---------------------------------------------------------------------------
        -- Clock/Reset Signals.
        ---------------------------------------------------------------------------
            CLK                 => CLOCK               , -- In  :
            RST                 => RESET               , -- In  :
            CLR                 => CLEAR               , -- In  :
        ---------------------------------------------------------------------------
        -- Register Interface
        ---------------------------------------------------------------------------
            REG_RD_ADDR_L       => reg_rd_addr_load    , -- In  :
            REG_RD_ADDR_D       => reg_rd_addr_wbit    , -- In  :
            REG_RD_ADDR_Q       => reg_rd_addr_data    , -- Out :
            REG_WR_ADDR_L       => reg_wr_addr_load    , -- In  :
            REG_WR_ADDR_D       => reg_wr_addr_wbit    , -- In  :
            REG_WR_ADDR_Q       => reg_wr_addr_data    , -- Out :
            REG_T0_ADDR_L       => reg_t0_addr_load    , -- In  :
            REG_T0_ADDR_D       => reg_t0_addr_wbit    , -- In  :
            REG_T0_ADDR_Q       => reg_t0_addr_data    , -- Out :
            REG_T1_ADDR_L       => reg_t1_addr_load    , -- In  :
            REG_T1_ADDR_D       => reg_t1_addr_wbit    , -- In  :
            REG_T1_ADDR_Q       => reg_t1_addr_data    , -- Out :
            REG_SIZE_L          => reg_size_load       , -- In  :
            REG_SIZE_D          => reg_size_wbit       , -- In  :
            REG_SIZE_Q          => reg_size_data       , -- Out :
            REG_RD_MODE_L       => reg_rd_mode_load    , -- In  :
            REG_RD_MODE_D       => reg_rd_mode_wbit    , -- In  :
            REG_RD_MODE_Q       => reg_rd_mode_data    , -- Out :
            REG_WR_MODE_L       => reg_wr_mode_load    , -- In  :
            REG_WR_MODE_D       => reg_wr_mode_wbit    , -- In  :
            REG_WR_MODE_Q       => reg_wr_mode_data    , -- Out :
            REG_T0_MODE_L       => reg_t0_mode_load    , -- In  :
            REG_T0_MODE_D       => reg_t0_mode_wbit    , -- In  :
            REG_T0_MODE_Q       => reg_t0_mode_data    , -- Out :
            REG_T1_MODE_L       => reg_t1_mode_load    , -- In  :
            REG_T1_MODE_D       => reg_t1_mode_wbit    , -- In  :
            REG_T1_MODE_Q       => reg_t1_mode_data    , -- Out :
            REG_START_L         => reg_start_load      , -- In  :
            REG_START_D         => reg_start_wbit      , -- In  :
            REG_START_Q         => reg_start_data      , -- Out :
            REG_RESET_L         => reg_reset_load      , -- In  :
            REG_RESET_D         => reg_reset_wbit      , -- In  :
            REG_RESET_Q         => reg_reset_data      , -- Out :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Read Address Channel Signals.
        ---------------------------------------------------------------------------
            STM_AXI_ARID        => stm_axi_arid        , -- Out :
            STM_AXI_ARADDR      => stm_axi_araddr      , -- Out :
            STM_AXI_ARLEN       => stm_axi_arlen       , -- Out :
            STM_AXI_ARSIZE      => stm_axi_arsize      , -- Out :
            STM_AXI_ARBURST     => stm_axi_arburst     , -- Out :
            STM_AXI_ARLOCK      => stm_axi_arlock      , -- Out :
            STM_AXI_ARCACHE     => stm_axi_arcache     , -- Out :
            STM_AXI_ARPROT      => stm_axi_arprot      , -- Out :
            STM_AXI_ARQOS       => stm_axi_arqos       , -- Out :
            STM_AXI_ARREGION    => stm_axi_arregion    , -- Out :
            STM_AXI_ARUSER      => stm_axi_aruser      , -- Out :
            STM_AXI_ARVALID     => stm_axi_arvalid     , -- Out :
            STM_AXI_ARREADY     => stm_axi_arready     , -- In  :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Read Data Channel Signals.
        ---------------------------------------------------------------------------
            STM_AXI_RID         => stm_axi_rid         , -- In  :
            STM_AXI_RDATA       => stm_axi_rdata       , -- In  :
            STM_AXI_RRESP       => stm_axi_rresp       , -- In  :
            STM_AXI_RLAST       => stm_axi_rlast       , -- In  :
            STM_AXI_RVALID      => stm_axi_rvalid      , -- In  :
            STM_AXI_RREADY      => stm_axi_rready      , -- Out :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Writer Address Channel Signals.
        ---------------------------------------------------------------------------
            STM_AXI_AWID        => stm_axi_awid        , -- Out :
            STM_AXI_AWADDR      => stm_axi_awaddr      , -- Out :
            STM_AXI_AWLEN       => stm_axi_awlen       , -- Out :
            STM_AXI_AWSIZE      => stm_axi_awsize      , -- Out :
            STM_AXI_AWBURST     => stm_axi_awburst     , -- Out :
            STM_AXI_AWLOCK      => stm_axi_awlock      , -- Out :
            STM_AXI_AWCACHE     => stm_axi_awcache     , -- Out :
            STM_AXI_AWPROT      => stm_axi_awprot      , -- Out :
            STM_AXI_AWQOS       => stm_axi_awqos       , -- Out :
            STM_AXI_AWREGION    => stm_axi_awregion    , -- Out :
            STM_AXI_AWUSER      => stm_axi_awuser      , -- Out :
            STM_AXI_AWVALID     => stm_axi_awvalid     , -- Out :
            STM_AXI_AWREADY     => stm_axi_awready     , -- In  :
        ---------------------------------------------------------------------------
        -- Stream AXI Master Write Data Channel Signals.
        ---------------------------------------------------------------------------
            STM_AXI_WID         => stm_axi_wid         , -- Out :
            STM_AXI_WDATA       => stm_axi_wdata       , -- Out :
            STM_AXI_WSTRB       => stm_axi_wstrb       , -- Out :
            STM_AXI_WUSER       => stm_axi_wuser       , -- Out :
            STM_AXI_WLAST       => stm_axi_wlast       , -- Out :
            STM_AXI_WVALID      => stm_axi_wvalid      , -- Out :
            STM_AXI_WREADY      => stm_axi_wready      , -- In  :
        ---------------------------------------------------------------------------
        -- Stream AXI Write Response Channel Signals.
        ---------------------------------------------------------------------------
            STM_AXI_BID         => stm_axi_bid         , -- In  :
            STM_AXI_BRESP       => stm_axi_bresp       , -- In  :
            STM_AXI_BUSER       => stm_axi_buser       , -- In  :
            STM_AXI_BVALID      => stm_axi_bvalid      , -- In  :
            STM_AXI_BREADY      => stm_axi_bready      , -- Out :
        ---------------------------------------------------------------------------
        -- Stream Reader Outlet Signals.
        ---------------------------------------------------------------------------
            STM_RD_DATA         => stm_rd_data         , -- Out :
            STM_RD_STRB         => stm_rd_strb         , -- Out :
            STM_RD_LAST         => stm_rd_last         , -- Out :
            STM_RD_VALID        => stm_rd_valid        , -- Out :
            STM_RD_READY        => stm_rd_ready        , -- In  :
        ---------------------------------------------------------------------------
        -- Stream Writer Intake Signals.
        ---------------------------------------------------------------------------
            STM_WR_DATA         => stm_wr_data         , -- In  :
            STM_WR_STRB         => stm_wr_strb         , -- In  :
            STM_WR_LAST         => stm_wr_last         , -- In  :
            STM_WR_VALID        => stm_wr_valid        , -- In  :
            STM_WR_READY        => stm_wr_ready        , -- Out :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Read Address Channel Signals.
        ---------------------------------------------------------------------------
            MRG_AXI_ARID        => mrg_axi_arid        , -- Out :
            MRG_AXI_ARADDR      => mrg_axi_araddr      , -- Out :
            MRG_AXI_ARLEN       => mrg_axi_arlen       , -- Out :
            MRG_AXI_ARSIZE      => mrg_axi_arsize      , -- Out :
            MRG_AXI_ARBURST     => mrg_axi_arburst     , -- Out :
            MRG_AXI_ARLOCK      => mrg_axi_arlock      , -- Out :
            MRG_AXI_ARCACHE     => mrg_axi_arcache     , -- Out :
            MRG_AXI_ARPROT      => mrg_axi_arprot      , -- Out :
            MRG_AXI_ARQOS       => mrg_axi_arqos       , -- Out :
            MRG_AXI_ARREGION    => mrg_axi_arregion    , -- Out :
            MRG_AXI_ARUSER      => mrg_axi_aruser      , -- Out :
            MRG_AXI_ARVALID     => mrg_axi_arvalid     , -- Out :
            MRG_AXI_ARREADY     => mrg_axi_arready     , -- In  :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Read Data Channel Signals.
        ---------------------------------------------------------------------------
            MRG_AXI_RID         => mrg_axi_rid         , -- In  :
            MRG_AXI_RDATA       => mrg_axi_rdata       , -- In  :
            MRG_AXI_RRESP       => mrg_axi_rresp       , -- In  :
            MRG_AXI_RLAST       => mrg_axi_rlast       , -- In  :
            MRG_AXI_RVALID      => mrg_axi_rvalid      , -- In  :
            MRG_AXI_RREADY      => mrg_axi_rready      , -- Out :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Writer Address Channel Signals.
        ---------------------------------------------------------------------------
            MRG_AXI_AWID        => mrg_axi_awid        , -- Out :
            MRG_AXI_AWADDR      => mrg_axi_awaddr      , -- Out :
            MRG_AXI_AWLEN       => mrg_axi_awlen       , -- Out :
            MRG_AXI_AWSIZE      => mrg_axi_awsize      , -- Out :
            MRG_AXI_AWBURST     => mrg_axi_awburst     , -- Out :
            MRG_AXI_AWLOCK      => mrg_axi_awlock      , -- Out :
            MRG_AXI_AWCACHE     => mrg_axi_awcache     , -- Out :
            MRG_AXI_AWPROT      => mrg_axi_awprot      , -- Out :
            MRG_AXI_AWQOS       => mrg_axi_awqos       , -- Out :
            MRG_AXI_AWREGION    => mrg_axi_awregion    , -- Out :
            MRG_AXI_AWUSER      => mrg_axi_awuser      , -- Out :
            MRG_AXI_AWVALID     => mrg_axi_awvalid     , -- Out :
            MRG_AXI_AWREADY     => mrg_axi_awready     , -- In  :
        ---------------------------------------------------------------------------
        -- Merge AXI Master Write Data Channel Signals.
        ---------------------------------------------------------------------------
            MRG_AXI_WID         => mrg_axi_wid         , -- Out :
            MRG_AXI_WDATA       => mrg_axi_wdata       , -- Out :
            MRG_AXI_WSTRB       => mrg_axi_wstrb       , -- Out :
            MRG_AXI_WUSER       => mrg_axi_wuser       , -- Out :
            MRG_AXI_WLAST       => mrg_axi_wlast       , -- Out :
            MRG_AXI_WVALID      => mrg_axi_wvalid      , -- Out :
            MRG_AXI_WREADY      => mrg_axi_wready      , -- In  :
        ---------------------------------------------------------------------------
        -- Merge AXI Write Response Channel Signals.
        ---------------------------------------------------------------------------
            MRG_AXI_BID         => mrg_axi_bid         , -- In  :
            MRG_AXI_BRESP       => mrg_axi_bresp       , -- In  :
            MRG_AXI_BUSER       => mrg_axi_buser       , -- In  :
            MRG_AXI_BVALID      => mrg_axi_bvalid      , -- In  :
            MRG_AXI_BREADY      => mrg_axi_bready      , -- Out :
        ---------------------------------------------------------------------------
        -- Merge Reader Outlet Signals.
        ---------------------------------------------------------------------------
            MRG_RD_DATA         => mrg_rd_data         , -- Out :
            MRG_RD_NONE         => mrg_rd_none         , -- Out :
            MRG_RD_EBLK         => mrg_rd_eblk         , -- Out :
            MRG_RD_LAST         => mrg_rd_last         , -- Out :
            MRG_RD_VALID        => mrg_rd_valid        , -- Out :
            MRG_RD_READY        => mrg_rd_ready        , -- In  :
            MRG_RD_LEVEL        => mrg_rd_level        , -- In  :
        ---------------------------------------------------------------------------
        -- Merge Writer Intake Signals.
        ---------------------------------------------------------------------------
            MRG_WR_DATA         => mrg_wr_data         , -- In  :
            MRG_WR_STRB         => mrg_wr_strb         , -- In  :
            MRG_WR_LAST         => mrg_wr_last         , -- In  :
            MRG_WR_VALID        => mrg_wr_valid        , -- In  :
            MRG_WR_READY        => mrg_wr_ready        , -- Out :
        ---------------------------------------------------------------------------
        -- Merge Sorter Core Control Interface Signals.
        ---------------------------------------------------------------------------
            STM_REQ_VALID       => stm_req_valid       , -- Out :
            STM_REQ_READY       => stm_req_ready       , -- In  :
            STM_RES_VALID       => stm_res_valid       , -- In  :
            STM_RES_READY       => stm_res_ready       , -- Out :
            MRG_REQ_VALID       => mrg_req_valid       , -- Out :
            MRG_REQ_READY       => mrg_req_ready       , -- In  :
            MRG_RES_VALID       => mrg_res_valid       , -- In  :
            MRG_RES_READY       => mrg_res_ready       , -- Out :
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
            IRQ                 => irq                   -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    REGS: block
        constant REGS_ADDR_WIDTH    :  integer := 6;
        constant REGS_DATA_BITS     :  integer := (2**REGS_ADDR_WIDTH)*8;
        signal   regs_load          :  std_logic_vector(REGS_DATA_BITS   -1 downto 0);
        signal   regs_wbit          :  std_logic_vector(REGS_DATA_BITS   -1 downto 0);
        signal   regs_rbit          :  std_logic_vector(REGS_DATA_BITS   -1 downto 0);
        signal   regs_req           :  std_logic;
        signal   regs_write         :  std_logic;
        signal   regs_ack           :  std_logic;
        signal   regs_err           :  std_logic;
        signal   regs_addr          :  std_logic_vector(REGS_ADDR_WIDTH  -1 downto 0);
        signal   regs_ben           :  std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
        signal   regs_wdata         :  std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
        signal   regs_rdata         :  std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant RD_ADDR_REGS_ADDR  :  integer := 16#00#;
        constant RD_ADDR_REGS_LO    :  integer := 8*RD_ADDR_REGS_ADDR;
        constant RD_ADDR_REGS_HI    :  integer := 8*RD_ADDR_REGS_ADDR + REG_ADDR_BITS;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant WR_ADDR_REGS_ADDR  :  integer := 16#08#;
        constant WR_ADDR_REGS_LO    :  integer := 8*WR_ADDR_REGS_ADDR;
        constant WR_ADDR_REGS_HI    :  integer := 8*WR_ADDR_REGS_ADDR + REG_ADDR_BITS;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant T0_ADDR_REGS_ADDR  :  integer := 16#10#;
        constant T0_ADDR_REGS_LO    :  integer := 8*T0_ADDR_REGS_ADDR;
        constant T0_ADDR_REGS_HI    :  integer := 8*T0_ADDR_REGS_ADDR + REG_ADDR_BITS;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant T1_ADDR_REGS_ADDR  :  integer := 16#18#;
        constant T1_ADDR_REGS_LO    :  integer := 8*T1_ADDR_REGS_ADDR;
        constant T1_ADDR_REGS_HI    :  integer := 8*T1_ADDR_REGS_ADDR + REG_ADDR_BITS;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant RD_MODE_REGS_ADDR  :  integer := 16#20#;
        constant RD_MODE_REGS_LO    :  integer := 8*RD_MODE_REGS_ADDR;
        constant RD_MODE_REGS_HI    :  integer := 8*RD_MODE_REGS_ADDR + REG_MODE_BITS;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant WR_MODE_REGS_ADDR  :  integer := 16#24#;
        constant WR_MODE_REGS_LO    :  integer := 8*WR_MODE_REGS_ADDR;
        constant WR_MODE_REGS_HI    :  integer := 8*WR_MODE_REGS_ADDR + REG_MODE_BITS;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant T0_MODE_REGS_ADDR  :  integer := 16#28#;
        constant T0_MODE_REGS_LO    :  integer := 8*T0_MODE_REGS_ADDR;
        constant T0_MODE_REGS_HI    :  integer := 8*T0_MODE_REGS_ADDR + REG_MODE_BITS;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant T1_MODE_REGS_ADDR  :  integer := 16#2C#;
        constant T1_MODE_REGS_LO    :  integer := 8*T1_MODE_REGS_ADDR;
        constant T1_MODE_REGS_HI    :  integer := 8*T1_MODE_REGS_ADDR + REG_MODE_BITS;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        constant SIZE_REGS_ADDR     :  integer := 16#30#;
        constant SIZE_REGS_LO       :  integer := 8*SIZE_REGS_ADDR;
        constant SIZE_REGS_HI       :  integer := 8*SIZE_REGS_ADDR    + REG_SIZE_BITS;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        AXI4: AXI4_REGISTER_INTERFACE                  --
            generic map (                              -- 
                AXI4_ADDR_WIDTH => CSR_WIDTH.ARADDR  , --
                AXI4_DATA_WIDTH => CSR_WIDTH.RDATA   , --
                AXI4_ID_WIDTH   => CSR_WIDTH.ID      , --
                REGS_ADDR_WIDTH => REGS_ADDR_WIDTH   , --
                REGS_DATA_WIDTH => REGS_DATA_WIDTH     --
            )                                          -- 
            port map (                                 -- 
            -----------------------------------------------------------------------
            -- Clock and Reset Signals.
            -----------------------------------------------------------------------
                CLK             => CLOCK             , -- In  :
                RST             => RESET             , -- In  :
                CLR             => CLEAR             , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Read Address Channel Signals.
            -----------------------------------------------------------------------
                ARID            => csr_arid          , -- In  :
                ARADDR          => csr_araddr        , -- In  :
                ARLEN           => csr_arlen         , -- In  :
                ARSIZE          => csr_arsize        , -- In  :
                ARBURST         => csr_arburst       , -- In  :
                ARVALID         => csr_arvalid       , -- In  :
                ARREADY         => csr_arready       , -- Out :
            -----------------------------------------------------------------------
            -- AXI4 Read Data Channel Signals.
            -----------------------------------------------------------------------
                RID             => csr_rid           , -- Out :
                RDATA           => csr_rdata         , -- Out :
                RRESP           => csr_rresp         , -- Out :
                RLAST           => csr_rlast         , -- Out :
                RVALID          => csr_rvalid        , -- Out :
                RREADY          => csr_rready        , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Write Address Channel Signals.
            -----------------------------------------------------------------------
                AWID            => csr_awid          , -- In  :
                AWADDR          => csr_awaddr        , -- In  :
                AWLEN           => csr_awlen         , -- In  :
                AWSIZE          => csr_awsize        , -- In  :
                AWBURST         => csr_awburst       , -- In  :
                AWVALID         => csr_awvalid       , -- In  :
                AWREADY         => csr_awready       , -- Out :
            -----------------------------------------------------------------------
            -- AXI4 Write Data Channel Signals.
            -----------------------------------------------------------------------
                WDATA           => csr_wdata         , -- In  :
                WSTRB           => csr_wstrb         , -- In  :
                WLAST           => csr_wlast         , -- In  :
                WVALID          => csr_wvalid        , -- In  :
                WREADY          => csr_wready        , -- Out :
            -----------------------------------------------------------------------
            -- AXI4 Write Response Channel Signals.
            -----------------------------------------------------------------------
                BID             => csr_bid           , -- Out :
                BRESP           => csr_bresp         , -- Out :
                BVALID          => csr_bvalid        , -- Out :
                BREADY          => csr_bready        , -- In  :
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
                RST             => RESET             , -- In  :
                I_CLK           => CLOCK             , -- In  :
                I_CLR           => CLEAR             , -- In  :
                I_CKE           => '1'               , -- In  :
                I_REQ           => regs_req          , -- In  :
                I_SEL           => '1'               , -- In  :
                I_WRITE         => regs_write        , -- In  :
                I_ADDR          => regs_addr         , -- In  :
                I_BEN           => regs_ben          , -- In  :
                I_WDATA         => regs_wdata        , -- In  :
                I_RDATA         => regs_rdata        , -- Out :
                I_ACK           => regs_ack          , -- Out :
                I_ERR           => regs_err          , -- Out :
                O_CLK           => CLOCK             , -- In  :
                O_CLR           => CLEAR             , -- In  :
                O_CKE           => '1'               , -- In  :
                O_WDATA         => regs_wbit         , -- Out :
                O_WLOAD         => regs_load         , -- Out :
                O_RDATA         => regs_rbit           -- In  :
            );                                         -- 
        ---------------------------------------------------------------------------
        -- reg_rd_addr
        ---------------------------------------------------------------------------
        reg_rd_addr_load <= regs_load(RD_ADDR_REGS_HI downto RD_ADDR_REGS_LO);
        reg_rd_addr_wbit <= regs_wbit(RD_ADDR_REGS_HI downto RD_ADDR_REGS_LO);
        regs_rbit(RD_ADDR_REGS_HI downto RD_ADDR_REGS_LO) <= regs_rd_addr_data;
        ---------------------------------------------------------------------------
        -- reg_wr_addr
        ---------------------------------------------------------------------------
        reg_wr_addr_load <= regs_load(127 downto  64);
        reg_wr_addr_wbit <= regs_wbit(127 downto  64);
        regs_rbit(127 downto  64) <= regs_wr_addr_data;
        ---------------------------------------------------------------------------
        -- reg_t0_addr
        ---------------------------------------------------------------------------
        reg_t0_addr_load <= regs_load(191 downto 128);
        reg_t0_addr_wbit <= regs_wbit(191 downto 128);
        regs_rbit(191 downto  64) <= regs_t0_addr_data;
        ---------------------------------------------------------------------------
        -- reg_t1_addr
        ---------------------------------------------------------------------------
        reg_t0_addr_load <= regs_load(255 downto 192);
        reg_t0_addr_wbit <= regs_wbit(255 downto 192);
        regs_rbit(255 downto 192) <= regs_t0_addr_data;
    end block;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL                                   -- 
        generic map(                             -- 
            SCENARIO_FILE   => SCENARIO_FILE,    -- 
            NAME            => "MARCHAL",        -- 
            SYNC_PLUG_NUM   => 1,                -- 
            SYNC_WIDTH      => SYNC_WIDTH,       -- 
            FINISH_ABORT    => FALSE             -- 
        )                                        -- 
        port map(                                -- 
            CLK             => CLOCK           , -- In  :
            RESET           => RESET           , -- Out :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );                                       -- 
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    CSR: AXI4_MASTER_PLAYER                      -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , -- 
            NAME            => "CSR"           , -- 
            READ_ENABLE     => TRUE            , -- 
            WRITE_ENABLE    => TRUE            , -- 
            OUTPUT_DELAY    => DELAY           , -- 
            WIDTH           => CSR_WIDTH       , -- 
            SYNC_PLUG_NUM   => 2               , -- 
            SYNC_WIDTH      => SYNC_WIDTH      , -- 
            GPI_WIDTH       => GPI_WIDTH       , -- 
            GPO_WIDTH       => GPO_WIDTH       , -- 
            FINISH_ABORT    => FALSE             -- 
        )                                        -- 
        port map(                                -- 
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => csr_araddr      , -- I/O : 
            ARLEN           => csr_arlen       , -- I/O : 
            ARSIZE          => csr_arsize      , -- I/O : 
            ARBURST         => csr_arburst     , -- I/O : 
            ARLOCK          => csr_arlock      , -- I/O : 
            ARCACHE         => csr_arcache     , -- I/O : 
            ARPROT          => csr_arprot      , -- I/O : 
            ARQOS           => csr_arqos       , -- I/O : 
            ARREGION        => csr_arregion    , -- I/O : 
            ARUSER          => csr_aruser      , -- I/O : 
            ARID            => csr_arid        , -- I/O : 
            ARVALID         => csr_arvalid     , -- I/O : 
            ARREADY         => csr_arready     , -- In  :    
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => csr_rlast       , -- In  :    
            RDATA           => csr_rdata       , -- In  :    
            RRESP           => csr_rresp       , -- In  :    
            RUSER           => csr_ruser       , -- In  :    
            RID             => csr_rid         , -- In  :    
            RVALID          => csr_rvalid      , -- In  :    
            RREADY          => csr_rready      , -- I/O : 
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => csr_awaddr      , -- I/O : 
            AWLEN           => csr_awlen       , -- I/O : 
            AWSIZE          => csr_awsize      , -- I/O : 
            AWBURST         => csr_awburst     , -- I/O : 
            AWLOCK          => csr_awlock      , -- I/O : 
            AWCACHE         => csr_awcache     , -- I/O : 
            AWPROT          => csr_awprot      , -- I/O : 
            AWQOS           => csr_awqos       , -- I/O : 
            AWREGION        => csr_awregion    , -- I/O : 
            AWUSER          => csr_awuser      , -- I/O : 
            AWID            => csr_awid        , -- I/O : 
            AWVALID         => csr_awvalid     , -- I/O : 
            AWREADY         => csr_awready     , -- In  :    
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => csr_wlast       , -- I/O : 
            WDATA           => csr_wdata       , -- I/O : 
            WSTRB           => csr_wstrb       , -- I/O : 
            WUSER           => csr_wuser       , -- I/O : 
            WID             => csr_wid         , -- I/O : 
            WVALID          => csr_wvalid      , -- I/O : 
            WREADY          => csr_wready      , -- In  :    
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => csr_bresp       , -- In  :    
            BUSER           => csr_buser       , -- In  :    
            BID             => csr_bid         , -- In  :    
            BVALID          => csr_bvalid      , -- In  :    
            BREADY          => csr_bready      , -- I/O : 
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => csr_gpi         , -- In  :
            GPO             => csr_gpo         , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => CSR_REPORT      , -- Out :
            FINISH          => CSR_FINISH        -- Out :
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    STM: AXI4_SLAVE_PLAYER                       -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , -- 
            NAME            => "STM"           , -- 
            READ_ENABLE     => TRUE            , -- 
            WRITE_ENABLE    => FALSE           , -- 
            OUTPUT_DELAY    => DELAY           , -- 
            WIDTH           => STM_AXI_WIDTH   , -- 
            SYNC_PLUG_NUM   => 3               , -- 
            SYNC_WIDTH      => SYNC_WIDTH      , -- 
            GPI_WIDTH       => GPI_WIDTH       , -- 
            GPO_WIDTH       => GPO_WIDTH       , -- 
            FINISH_ABORT    => FALSE             -- 
        )                                        -- 
        port map(                                -- 
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => stm_axi_araddr  , -- In  :    
            ARLEN           => stm_axi_arlen   , -- In  :    
            ARSIZE          => stm_axi_arsize  , -- In  :    
            ARBURST         => stm_axi_arburst , -- In  :    
            ARLOCK          => stm_axi_arlock  , -- In  :    
            ARCACHE         => stm_axi_arcache , -- In  :    
            ARPROT          => stm_axi_arprot  , -- In  :    
            ARQOS           => stm_axi_arqos   , -- In  :    
            ARREGION        => stm_axi_arregion, -- In  :    
            ARUSER          => stm_axi_aruser  , -- In  :    
            ARID            => stm_axi_arid    , -- In  :    
            ARVALID         => stm_axi_arvalid , -- In  :    
            ARREADY         => stm_axi_arready , -- I/O : 
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => stm_axi_rlast   , -- I/O : 
            RDATA           => stm_axi_rdata   , -- I/O : 
            RRESP           => stm_axi_rresp   , -- I/O : 
            RUSER           => stm_axi_ruser   , -- I/O : 
            RID             => stm_axi_rid     , -- I/O : 
            RVALID          => stm_axi_rvalid  , -- I/O : 
            RREADY          => stm_axi_rready  , -- In  :    
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            AWADDR          => stm_axi_awaddr  , -- In  :    
            AWLEN           => stm_axi_awlen   , -- In  :    
            AWSIZE          => stm_axi_awsize  , -- In  :    
            AWBURST         => stm_axi_awburst , -- In  :    
            AWLOCK          => stm_axi_awlock  , -- In  :    
            AWCACHE         => stm_axi_awcache , -- In  :    
            AWPROT          => stm_axi_awprot  , -- In  :    
            AWQOS           => stm_axi_awqos   , -- In  :    
            AWREGION        => stm_axi_awregion, -- In  :    
            AWUSER          => stm_axi_awuser  , -- In  :    
            AWID            => stm_axi_awid    , -- In  :    
            AWVALID         => stm_axi_awvalid , -- In  :    
            AWREADY         => stm_axi_awready , -- I/O : 
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
            WLAST           => stm_axi_wlast   , -- In  :    
            WDATA           => stm_axi_wdata   , -- In  :    
            WSTRB           => stm_axi_wstrb   , -- In  :    
            WUSER           => stm_axi_wuser   , -- In  :    
            WID             => stm_axi_wid     , -- In  :    
            WVALID          => stm_axi_wvalid  , -- In  :    
            WREADY          => stm_axi_wready  , -- I/O : 
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => stm_axi_bresp   , -- I/O : 
            BUSER           => stm_axi_buser   , -- I/O : 
            BID             => stm_axi_bid     , -- I/O : 
            BVALID          => stm_axi_bvalid  , -- I/O : 
            BREADY          => stm_axi_bready  , -- In  :    
        ---------------------------------------------------------------------------
        -- シンクロ用信号
        ---------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => stm_axi_gpi     , -- In  :
            GPO             => stm_axi_gpo     , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => STM_AXI_REPORT  , -- Out :
            FINISH          => STM_AXI_FINISH    -- Out :
        );
    stm_axi_gpi <= (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    MRG: AXI4_SLAVE_PLAYER                       -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , -- 
            NAME            => "MRG"           , -- 
            READ_ENABLE     => TRUE            , -- 
            WRITE_ENABLE    => FALSE           , -- 
            OUTPUT_DELAY    => DELAY           , -- 
            WIDTH           => MRG_AXI_WIDTH   , -- 
            SYNC_PLUG_NUM   => 4               , -- 
            SYNC_WIDTH      => SYNC_WIDTH      , -- 
            GPI_WIDTH       => GPI_WIDTH       , -- 
            GPO_WIDTH       => GPO_WIDTH       , -- 
            FINISH_ABORT    => FALSE             -- 
        )                                        -- 
        port map(                                -- 
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => mrg_axi_araddr  , -- In  :    
            ARLEN           => mrg_axi_arlen   , -- In  :    
            ARSIZE          => mrg_axi_arsize  , -- In  :    
            ARBURST         => mrg_axi_arburst , -- In  :    
            ARLOCK          => mrg_axi_arlock  , -- In  :    
            ARCACHE         => mrg_axi_arcache , -- In  :    
            ARPROT          => mrg_axi_arprot  , -- In  :    
            ARQOS           => mrg_axi_arqos   , -- In  :    
            ARREGION        => mrg_axi_arregion, -- In  :    
            ARUSER          => mrg_axi_aruser  , -- In  :    
            ARID            => mrg_axi_arid    , -- In  :    
            ARVALID         => mrg_axi_arvalid , -- In  :    
            ARREADY         => mrg_axi_arready , -- I/O : 
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => mrg_axi_rlast   , -- I/O : 
            RDATA           => mrg_axi_rdata   , -- I/O : 
            RRESP           => mrg_axi_rresp   , -- I/O : 
            RUSER           => mrg_axi_ruser   , -- I/O : 
            RID             => mrg_axi_rid     , -- I/O : 
            RVALID          => mrg_axi_rvalid  , -- I/O : 
            RREADY          => mrg_axi_rready  , -- In  :    
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            AWADDR          => mrg_axi_awaddr  , -- In  :    
            AWLEN           => mrg_axi_awlen   , -- In  :    
            AWSIZE          => mrg_axi_awsize  , -- In  :    
            AWBURST         => mrg_axi_awburst , -- In  :    
            AWLOCK          => mrg_axi_awlock  , -- In  :    
            AWCACHE         => mrg_axi_awcache , -- In  :    
            AWPROT          => mrg_axi_awprot  , -- In  :    
            AWQOS           => mrg_axi_awqos   , -- In  :    
            AWREGION        => mrg_axi_awregion, -- In  :    
            AWUSER          => mrg_axi_awuser  , -- In  :    
            AWID            => mrg_axi_awid    , -- In  :    
            AWVALID         => mrg_axi_awvalid , -- In  :    
            AWREADY         => mrg_axi_awready , -- I/O : 
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
            WLAST           => mrg_axi_wlast   , -- In  :    
            WDATA           => mrg_axi_wdata   , -- In  :    
            WSTRB           => mrg_axi_wstrb   , -- In  :    
            WUSER           => mrg_axi_wuser   , -- In  :    
            WID             => mrg_axi_wid     , -- In  :    
            WVALID          => mrg_axi_wvalid  , -- In  :    
            WREADY          => mrg_axi_wready  , -- I/O : 
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => mrg_axi_bresp   , -- I/O : 
            BUSER           => mrg_axi_buser   , -- I/O : 
            BID             => mrg_axi_bid     , -- I/O : 
            BVALID          => mrg_axi_bvalid  , -- I/O : 
            BREADY          => mrg_axi_bready  , -- In  :    
        ---------------------------------------------------------------------------
        -- シンクロ用信号
        ---------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => mrg_axi_gpi     , -- In  :
            GPO             => mrg_axi_gpo     , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => MRG_AXI_REPORT  , -- Out :
            FINISH          => MRG_AXI_FINISH    -- Out :
        );
    mrg_axi_gpi <= (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    STM_WR: block
        constant  WIDTH :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                               ID    => 4,
                               USER  => 4,
                               DEST  => 4,
                               DATA  => STM_WR_NUM*MRG_DATA_BITS
                           );
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        PLAYER: AXI4_STREAM_MASTER_PLAYER            -- 
            generic map (                            -- 
                SCENARIO_FILE   => SCENARIO_FILE   , --
                NAME            => "STM_WR"        , --
                OUTPUT_DELAY    => DELAY           , --
                SYNC_PLUG_NUM   => 5               , --
                WIDTH           => WIDTH           , --
                SYNC_WIDTH      => SYNC_WIDTH      , --
                GPI_WIDTH       => 2               , --
                GPO_WIDTH       => 2               , --
                FINISH_ABORT    => FALSE             --
            )                                        -- 
            port map (                               -- 
                ACLK            => CLOCK           , -- In  :
                ARESETn         => ARESETn         , -- In  :
                TDATA           => stm_wr_data     , -- Out :
                TSTRB           => stm_wr_strb     , -- Out :
                TKEEP           => open            , -- Out :
                TUSER           => open            , -- Out :
                TDEST           => open            , -- Out :
                TID             => open            , -- Out :
                TLAST           => stm_wr_last     , -- Out :
                TVALID          => stm_wr_valid    , -- Out :
                TREADY          => stm_wr_ready    , -- In  :
                SYNC            => SYNC            , -- I/O :
                GPI(0)          => stm_req_valid   , -- In  :
                GPI(1)          => stm_res_ready   , -- In  :
                GPO(0)          => stm_res_ready   , -- Out :
                GPO(1)          => stm_res_valid   , -- Out :
                REPORT_STATUS   => STM_WR_REPORT   , -- Out :
                FINISH          => STM_WR_FINISH     -- Out :
            );                                       -- 
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    STM_RD: block
        constant  WIDTH :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                               ID    => 4,
                               USER  => 4,
                               DEST  => 4,
                               DATA  => STM_RD_NUM*MRG_DATA_BITS
                           );
        constant  tuser :  std_logic_vector(WIDTH.USER  -1 downto 0) := (others => '0');
        constant  tstrb :  std_logic_vector(WIDTH.DATA/8-1 downto 0) := (others => '1');
        constant  tkeep :  std_logic_vector(WIDTH.DATA/8-1 downto 0) := (others => '1');
        constant  tdest :  std_logic_vector(WIDTH.DEST  -1 downto 0) := (others => '0');
        constant  tid   :  std_logic_vector(WIDTH.ID    -1 downto 0) := (others => '0');
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        PLAYER: AXI4_STREAM_SLAVE_PLAYER             -- 
            generic map (                            -- 
                SCENARIO_FILE   => SCENARIO_FILE   , --
                NAME            => "STM_RD"        , --
                OUTPUT_DELAY    => DELAY           , --
                SYNC_PLUG_NUM   => 6               , --
                WIDTH           => WIDTH           , --
                SYNC_WIDTH      => SYNC_WIDTH      , --
                GPI_WIDTH       => 1               , --
                GPO_WIDTH       => 1               , --
                FINISH_ABORT    => FALSE             --
            )                                        -- 
            port map (                               -- 
                ACLK            => CLOCK           , -- In  :
                ARESETn         => ARESETn         , -- In  :
                TDATA           => stm_rd_data     , -- In  :
                TSTRB           => stm_rd_strb     , -- In  :
                TKEEP           => tkeep           , -- In  :
                TUSER           => tuser           , -- In  :
                TDEST           => tdest           , -- In  :
                TID             => tid             , -- In  :
                TLAST           => stm_rd_last     , -- In  :
                TVALID          => stm_rd_valid    , -- In  :
                TREADY          => stm_rd_ready    , -- Out :
                SYNC            => SYNC            , -- I/O :
                GPI(0)          => stm_req_valid   , -- In  :
                GPO             => open            , -- Out :
                REPORT_STATUS   => STM_RD_REPORT   , -- Out :
                FINISH          => STM_RD_FINISH     -- Out :
            );                                       -- 
    end block;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    MRG_WR: block
        constant  WIDTH :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                               ID    => 4,
                               USER  => 4,
                               DEST  => 4,
                               DATA  => MRG_WR_NUM*MRG_DATA_BITS
                           );
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        PLAYER: AXI4_STREAM_MASTER_PLAYER            -- 
            generic map (                            -- 
                SCENARIO_FILE   => SCENARIO_FILE   , --
                NAME            => "MRG_WR"        , --
                OUTPUT_DELAY    => DELAY           , --
                SYNC_PLUG_NUM   => 7               , --
                WIDTH           => WIDTH           , --
                SYNC_WIDTH      => SYNC_WIDTH      , --
                GPI_WIDTH       => 2               , --
                GPO_WIDTH       => 2               , --
                FINISH_ABORT    => FALSE             --
            )                                        -- 
            port map (                               -- 
                ACLK            => CLOCK           , -- In  :
                ARESETn         => ARESETn         , -- In  :
                TDATA           => mrg_wr_data     , -- Out :
                TSTRB           => mrg_wr_strb     , -- Out :
                TKEEP           => open            , -- Out :
                TUSER           => open            , -- Out :
                TDEST           => open            , -- Out :
                TID             => open            , -- Out :
                TLAST           => mrg_wr_last     , -- Out :
                TVALID          => mrg_wr_valid    , -- Out :
                TREADY          => mrg_wr_ready    , -- In  :
                SYNC            => SYNC            , -- I/O :
                GPI(0)          => mrg_req_valid   , -- In  :
                GPI(1)          => mrg_res_ready   , -- In  :
                GPO(0)          => mrg_req_ready   , -- Out :
                GPO(1)          => mrg_res_valid   , -- Out :
                REPORT_STATUS   => MRG_WR_REPORT   , -- Out :
                FINISH          => MRG_WR_FINISH     -- Out :
            );                                       --
    end block;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    MRG_RD: for i in 0 to MRG_IN_NUM-1 generate
        constant  name  :  string(1 to 7) := string'("MRG_RD") & HEX_TO_STRING(i,8);
        constant  WIDTH :  AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                               ID    => 4,
                               USER  => 4,
                               DEST  => 4,
                               DATA  => MRG_DATA_BITS
                           );
        signal    tdata :  std_logic_vector(WIDTH.DATA  -1 downto 0);
        signal    tuser :  std_logic_vector(WIDTH.USER  -1 downto 0);
        constant  tstrb :  std_logic_vector(WIDTH.DATA/8-1 downto 0) := (others => '1');
        constant  tkeep :  std_logic_vector(WIDTH.DATA/8-1 downto 0) := (others => '1');
        constant  tdest :  std_logic_vector(WIDTH.DEST  -1 downto 0) := (others => '0');
        constant  tid   :  std_logic_vector(WIDTH.ID    -1 downto 0) := (others => '0');
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        PLAYER: AXI4_STREAM_SLAVE_PLAYER             -- 
            generic map (                            -- 
                SCENARIO_FILE   => SCENARIO_FILE   , --
                NAME            => name            , --
                OUTPUT_DELAY    => DELAY           , --
                SYNC_PLUG_NUM   => 8+i             , --
                WIDTH           => WIDTH           , --
                SYNC_WIDTH      => SYNC_WIDTH      , --
                GPI_WIDTH       => 1               , --
                GPO_WIDTH       => 1               , --
                FINISH_ABORT    => FALSE             --
            )                                        -- 
            port map (                               -- 
                ACLK            => CLOCK           , -- In  :
                ARESETn         => ARESETn         , -- In  :
                TDATA           => tdata           , -- In  :
                TSTRB           => tstrb           , -- In  :
                TKEEP           => tkeep           , -- In  :
                TUSER           => tuser           , -- In  :
                TDEST           => tdest           , -- In  :
                TID             => tid             , -- In  :
                TLAST           => mrg_rd_last  (i), -- In  :
                TVALID          => mrg_rd_valid (i), -- In  :
                TREADY          => mrg_rd_ready (i), -- Out :
                SYNC            => SYNC            , -- I/O :
                GPI(0)          => mrg_req_valid   , -- In  :
                GPO(0)          => mrg_rd_level (i), -- Out :
                REPORT_STATUS   => MRG_RD_REPORT(i), -- Out :
                FINISH          => MRG_RD_FINISH(i)  -- Out :
            );                                       -- 
        tdata    <= mrg_rd_data((i+1)*MRG_DATA_BITS-1 downto i*MRG_DATA_BITS);
        tuser(0) <= mrg_rd_none (i);
        tuser(1) <= '0';
        tuser(2) <= '0';
        tuser(3) <= mrg_rd_eblk (i);
    end generate;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process begin
        loop
            CLOCK  <= '0'; wait for PERIOD / 2;
            CLOCK  <= '1'; wait for PERIOD / 2;
            exit when(N_FINISH = '1');
        end loop;
        CLOCK  <= '0';
        wait;
    end process;

    ARESETn <= '1' when (RESET = '0') else '0';
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
        variable mrg_rd_repo_s :  REPORT_STATUS_TYPE;
    begin
        wait until (N_FINISH'event and N_FINISH = '1');
        wait for DELAY;
        mrg_rd_repo_s := MARGE_REPORT_STATUS(MRG_RD_REPORT);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                                WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ CSR ]");                                             WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,CSR_REPORT.error_count   );    WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,CSR_REPORT.mismatch_count);    WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,CSR_REPORT.warning_count );    WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ STM AXI]");                                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,STM_AXI_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,STM_AXI_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,STM_AXI_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ MRG AXI]");                                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,MRG_AXI_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,MRG_AXI_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,MRG_AXI_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ STM_RD ]");                                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,STM_RD_REPORT.error_count   ); WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,STM_RD_REPORT.mismatch_count); WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,STM_RD_REPORT.warning_count ); WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ STM_WR ]");                                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,STM_WR_REPORT.error_count   ); WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,STM_WR_REPORT.mismatch_count); WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,STM_WR_REPORT.warning_count ); WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ MRG_RD ]");                                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,mrg_rd_repo_s.error_count   ); WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,mrg_rd_repo_s.mismatch_count); WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,mrg_rd_repo_s.warning_count ); WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ MRG_WR ]");                                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,MRG_WR_REPORT.error_count   ); WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,MRG_WR_REPORT.mismatch_count); WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,MRG_WR_REPORT.warning_count ); WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                         WRITELINE(OUTPUT,L);
        assert (CSR_REPORT    .error_count = 0 and
                STM_AXI_REPORT.error_count = 0 and
                MRG_AXI_REPORT.error_count = 0 and
                STM_WR_REPORT .error_count = 0 and
                STM_RD_REPORT .error_count = 0 and
                MRG_WR_REPORT .error_count = 0 and
                mrg_rd_repo_s .error_count = 0)
            report "Simulation complete(error)."    severity FAILURE;
        assert (CSR_REPORT    .mismatch_count = 0 and
                STM_AXI_REPORT.mismatch_count = 0 and
                MRG_AXI_REPORT.mismatch_count = 0 and
                STM_WR_REPORT .mismatch_count = 0 and
                STM_RD_REPORT .mismatch_count = 0 and
                MRG_WR_REPORT .mismatch_count = 0 and
                mrg_rd_repo_s .mismatch_count = 0)
            report "Simulation complete(mismatch)." severity FAILURE;
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete(success)."  severity FAILURE;
        else
            assert FALSE report "Simulation complete(success)."  severity NOTE;
        end if;
        wait;
    end process;
end Model;
