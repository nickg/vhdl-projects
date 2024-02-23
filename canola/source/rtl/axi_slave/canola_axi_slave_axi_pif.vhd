library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi_pkg.all;
use work.canola_axi_slave_pif_pkg.all;

entity canola_axi_slave_axi_pif is

  generic (
    -- AXI Bus Interface Generics
    g_axi_baseaddr        : std_logic_vector(31 downto 0) := 32X"0");
  port (    
    -- AXI Bus Interface Ports
    axi_rw_regs    : out t_canola_axi_slave_rw_regs    := c_canola_axi_slave_rw_regs;
    axi_ro_regs    : in  t_canola_axi_slave_ro_regs    := c_canola_axi_slave_ro_regs;
    axi_pulse_regs : out t_canola_axi_slave_pulse_regs := c_canola_axi_slave_pulse_regs;
    
    -- bus signals
    clk            : in  std_logic;
    areset_n       : in  std_logic;
    awaddr         : in  t_canola_axi_slave_addr;
    awvalid        : in  std_logic;
    awready        : out std_logic;
    wdata          : in  t_canola_axi_slave_data;
    wvalid         : in  std_logic;
    wready         : out std_logic;
    bresp          : out std_logic_vector(1 downto 0);
    bvalid         : out std_logic;
    bready         : in  std_logic;
    araddr         : in  t_canola_axi_slave_addr;
    arvalid        : in  std_logic;
    arready        : out std_logic;
    rdata          : out t_canola_axi_slave_data;
    rresp          : out std_logic_vector(1 downto 0);
    rvalid         : out std_logic;
    rready         : in  std_logic
    );
end canola_axi_slave_axi_pif;

architecture behavior of canola_axi_slave_axi_pif is

  constant C_BASEADDR : t_axi_addr := g_axi_baseaddr;

  -- internal signal for readback
  signal axi_rw_regs_i    : t_canola_axi_slave_rw_regs := c_canola_axi_slave_rw_regs;
  signal axi_pulse_regs_i : t_canola_axi_slave_pulse_regs := c_canola_axi_slave_pulse_regs;
  signal axi_pulse_regs_cycle : t_canola_axi_slave_pulse_regs := c_canola_axi_slave_pulse_regs;

  -- internal bus signals for readback
  signal awaddr_i      : t_canola_axi_slave_addr;
  signal awready_i     : std_logic;
  signal wready_i      : std_logic;
  signal bresp_i       : std_logic_vector(1 downto 0);
  signal bvalid_i      : std_logic;
  signal araddr_i      : t_canola_axi_slave_addr;
  signal arready_i     : std_logic;
  signal rdata_i       : t_canola_axi_slave_data;
  signal rresp_i       : std_logic_vector(1 downto 0);
  signal rvalid_i      : std_logic;
  
  signal slv_reg_rden : std_logic;
  signal slv_reg_wren : std_logic;
  signal reg_data_out : t_canola_axi_slave_data;
  -- signal byte_index   : integer; -- unused
  
begin

  axi_rw_regs <= axi_rw_regs_i;
  axi_pulse_regs <= axi_pulse_regs_i;

  awready <= awready_i;
  wready  <= wready_i;
  bresp   <= bresp_i;
  bvalid  <= bvalid_i;
  arready <= arready_i;
  rdata   <= rdata_i;
  rresp   <= rresp_i;
  rvalid  <= rvalid_i;
  
  p_awready : process(clk, areset_n)
  begin
    if areset_n = '0' then
      awready_i <= '0';
    elsif rising_edge(clk) then
      if (awready_i = '0' and awvalid = '1'  and wvalid = '1') then
        awready_i <= '1';
      else
        awready_i <= '0';
      end if;
    end if;
  end process p_awready;

  p_awaddr : process(clk, areset_n)
  begin
    if areset_n = '0' then
      awaddr_i <= (others => '0');
    elsif rising_edge(clk) then
      if (awready_i = '0' and awvalid = '1' and wvalid = '1') then
        awaddr_i <= awaddr;
      end if;
    end if;
  end process p_awaddr;

  p_wready : process(clk, areset_n)
  begin
    if areset_n = '0' then
      wready_i <= '0';
    elsif rising_edge(clk) then
      if (wready_i = '0' and awvalid = '1' and wvalid = '1') then
        wready_i <= '1';
      else
        wready_i <= '0';
      end if;
    end if;
  end process p_wready;

  slv_reg_wren <= wready_i and wvalid and awready_i and awvalid;

  p_mm_select_write : process(clk, areset_n)
  begin
    if areset_n = '0' then
      
      axi_rw_regs_i <= c_canola_axi_slave_rw_regs;
      
      axi_pulse_regs_cycle <= c_canola_axi_slave_pulse_regs;
  
    elsif rising_edge(clk) then
      
      -- Return PULSE registers to reset value every clock cycle
      axi_pulse_regs_cycle <= c_canola_axi_slave_pulse_regs;
      
      
      if (slv_reg_wren = '1') then
      
          if unsigned(awaddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_CONTROL), 32) then
          
            axi_pulse_regs_cycle.CONTROL.TX_START <= wdata(0);
            axi_pulse_regs_cycle.CONTROL.RESET_TX_MSG_SENT_COUNTER <= wdata(1);
            axi_pulse_regs_cycle.CONTROL.RESET_TX_FAILED_COUNTER <= wdata(2);
            axi_pulse_regs_cycle.CONTROL.RESET_TX_ACK_ERROR_COUNTER <= wdata(3);
            axi_pulse_regs_cycle.CONTROL.RESET_TX_ARB_LOST_COUNTER <= wdata(4);
            axi_pulse_regs_cycle.CONTROL.RESET_TX_BIT_ERROR_COUNTER <= wdata(5);
            axi_pulse_regs_cycle.CONTROL.RESET_TX_RETRANSMIT_COUNTER <= wdata(6);
            axi_pulse_regs_cycle.CONTROL.RESET_RX_MSG_RECV_COUNTER <= wdata(7);
            axi_pulse_regs_cycle.CONTROL.RESET_RX_CRC_ERROR_COUNTER <= wdata(8);
            axi_pulse_regs_cycle.CONTROL.RESET_RX_FORM_ERROR_COUNTER <= wdata(9);
            axi_pulse_regs_cycle.CONTROL.RESET_RX_STUFF_ERROR_COUNTER <= wdata(10);
          
          end if;
      
          if unsigned(awaddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_CONFIG), 32) then
          
            axi_rw_regs_i.CONFIG.TX_RETRANSMIT_EN <= wdata(0);
            axi_rw_regs_i.CONFIG.BTL_TRIPLE_SAMPLING_EN <= wdata(1);
          
          end if;
      
          if unsigned(awaddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_BTL_PROP_SEG), 32) then
          
            axi_rw_regs_i.BTL_PROP_SEG <= wdata(15 downto 0);
          
          end if;
      
          if unsigned(awaddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_BTL_PHASE_SEG1), 32) then
          
            axi_rw_regs_i.BTL_PHASE_SEG1 <= wdata(15 downto 0);
          
          end if;
      
          if unsigned(awaddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_BTL_PHASE_SEG2), 32) then
          
            axi_rw_regs_i.BTL_PHASE_SEG2 <= wdata(15 downto 0);
          
          end if;
      
          if unsigned(awaddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_BTL_SYNC_JUMP_WIDTH), 32) then
          
            axi_rw_regs_i.BTL_SYNC_JUMP_WIDTH <= wdata(2 downto 0);
          
          end if;
      
          if unsigned(awaddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TIME_QUANTA_CLOCK_SCALE), 32) then
          
            axi_rw_regs_i.TIME_QUANTA_CLOCK_SCALE <= wdata(7 downto 0);
          
          end if;
      
          if unsigned(awaddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_MSG_ID), 32) then
          
            axi_rw_regs_i.TX_MSG_ID.EXT_ID_EN <= wdata(0);
            axi_rw_regs_i.TX_MSG_ID.RTR_EN <= wdata(1);
            axi_rw_regs_i.TX_MSG_ID.ARB_ID_B <= wdata(19 downto 2);
            axi_rw_regs_i.TX_MSG_ID.ARB_ID_A <= wdata(30 downto 20);
          
          end if;
      
          if unsigned(awaddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_PAYLOAD_LENGTH), 32) then
          
            axi_rw_regs_i.TX_PAYLOAD_LENGTH <= wdata(3 downto 0);
          
          end if;
      
          if unsigned(awaddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_PAYLOAD_0), 32) then
          
            axi_rw_regs_i.TX_PAYLOAD_0.PAYLOAD_BYTE_0 <= wdata(7 downto 0);
            axi_rw_regs_i.TX_PAYLOAD_0.PAYLOAD_BYTE_1 <= wdata(15 downto 8);
            axi_rw_regs_i.TX_PAYLOAD_0.PAYLOAD_BYTE_2 <= wdata(23 downto 16);
            axi_rw_regs_i.TX_PAYLOAD_0.PAYLOAD_BYTE_3 <= wdata(31 downto 24);
          
          end if;
      
          if unsigned(awaddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_PAYLOAD_1), 32) then
          
            axi_rw_regs_i.TX_PAYLOAD_1.PAYLOAD_BYTE_4 <= wdata(7 downto 0);
            axi_rw_regs_i.TX_PAYLOAD_1.PAYLOAD_BYTE_5 <= wdata(15 downto 8);
            axi_rw_regs_i.TX_PAYLOAD_1.PAYLOAD_BYTE_6 <= wdata(23 downto 16);
            axi_rw_regs_i.TX_PAYLOAD_1.PAYLOAD_BYTE_7 <= wdata(31 downto 24);
          
          end if;
      
      end if;
  
    end if;
  end process p_mm_select_write;

p_pulse_CONTROL : process(clk)
variable cnt : natural range 0 to 0 := 0;
begin
  if rising_edge(clk) then
    if areset_n = '0' then
      axi_pulse_regs_i.CONTROL <= c_canola_axi_slave_pulse_regs.CONTROL;
    else
      if axi_pulse_regs_cycle.CONTROL /= c_canola_axi_slave_pulse_regs.CONTROL then
        cnt := 0;
        axi_pulse_regs_i.CONTROL <= axi_pulse_regs_cycle.CONTROL;
      else
        if cnt > 0 then
          cnt := cnt - 1;
        else
          axi_pulse_regs_i.CONTROL <= c_canola_axi_slave_pulse_regs.CONTROL;
        end if;
      end if;

    end if;
  end if;
end process p_pulse_CONTROL;

  p_write_response : process(clk, areset_n)
  begin
    if areset_n = '0' then
      bvalid_i <= '0';
      bresp_i  <= "00";
    elsif rising_edge(clk) then
      if (awready_i = '1' and awvalid = '1' and wready_i = '1' and wvalid = '1' and bvalid_i = '0') then
        bvalid_i <= '1';
        bresp_i  <= "00";
      elsif (bready = '1' and bvalid_i = '1') then
        bvalid_i <= '0';
      end if;
    end if;
  end process p_write_response;

  p_arready : process(clk, areset_n)
  begin
    if areset_n = '0' then
      arready_i <= '0';
      araddr_i  <= (others => '0');
    elsif rising_edge(clk) then
      if (arready_i = '0' and arvalid = '1') then
        arready_i <= '1';
        araddr_i  <= araddr;
      else
        arready_i <= '0';
      end if;
    end if;
  end process p_arready;

  p_arvalid : process(clk, areset_n)
  begin
    if areset_n = '0' then
      rvalid_i <= '0';
      rresp_i  <= "00";
    elsif rising_edge(clk) then
      if (arready_i = '1' and arvalid = '1' and rvalid_i = '0') then
        rvalid_i <= '1';
        rresp_i  <= "00";
      elsif (rvalid_i = '1' and rready = '1') then
        rvalid_i <= '0';
      end if;
    end if;
  end process p_arvalid;

  slv_reg_rden <= arready_i and arvalid and (not rvalid_i);

  p_mm_select_read : process(all)
  begin
  
    reg_data_out <= (others => '0');
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_STATUS), 32) then
    
      reg_data_out(0) <= axi_ro_regs.STATUS.RX_MSG_VALID;
      reg_data_out(1) <= axi_ro_regs.STATUS.TX_BUSY;
      reg_data_out(2) <= axi_ro_regs.STATUS.TX_DONE;
      reg_data_out(3) <= axi_ro_regs.STATUS.TX_FAILED;
      reg_data_out(5 downto 4) <= axi_ro_regs.STATUS.ERROR_STATE;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_CONFIG), 32) then
    
      reg_data_out(0) <= axi_rw_regs_i.CONFIG.TX_RETRANSMIT_EN;
      reg_data_out(1) <= axi_rw_regs_i.CONFIG.BTL_TRIPLE_SAMPLING_EN;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_BTL_PROP_SEG), 32) then
    
      reg_data_out(15 downto 0) <= axi_rw_regs_i.BTL_PROP_SEG;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_BTL_PHASE_SEG1), 32) then
    
      reg_data_out(15 downto 0) <= axi_rw_regs_i.BTL_PHASE_SEG1;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_BTL_PHASE_SEG2), 32) then
    
      reg_data_out(15 downto 0) <= axi_rw_regs_i.BTL_PHASE_SEG2;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_BTL_SYNC_JUMP_WIDTH), 32) then
    
      reg_data_out(2 downto 0) <= axi_rw_regs_i.BTL_SYNC_JUMP_WIDTH;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TIME_QUANTA_CLOCK_SCALE), 32) then
    
      reg_data_out(7 downto 0) <= axi_rw_regs_i.TIME_QUANTA_CLOCK_SCALE;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TRANSMIT_ERROR_COUNT), 32) then
    
      reg_data_out(15 downto 0) <= axi_ro_regs.TRANSMIT_ERROR_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_RECEIVE_ERROR_COUNT), 32) then
    
      reg_data_out(15 downto 0) <= axi_ro_regs.RECEIVE_ERROR_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_MSG_SENT_COUNT), 32) then
    
      reg_data_out(31 downto 0) <= axi_ro_regs.TX_MSG_SENT_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_FAILED_COUNT), 32) then
    
      reg_data_out(31 downto 0) <= axi_ro_regs.TX_FAILED_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_ACK_ERROR_COUNT), 32) then
    
      reg_data_out(31 downto 0) <= axi_ro_regs.TX_ACK_ERROR_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_ARB_LOST_COUNT), 32) then
    
      reg_data_out(31 downto 0) <= axi_ro_regs.TX_ARB_LOST_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_BIT_ERROR_COUNT), 32) then
    
      reg_data_out(31 downto 0) <= axi_ro_regs.TX_BIT_ERROR_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_RETRANSMIT_COUNT), 32) then
    
      reg_data_out(31 downto 0) <= axi_ro_regs.TX_RETRANSMIT_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_RX_MSG_RECV_COUNT), 32) then
    
      reg_data_out(31 downto 0) <= axi_ro_regs.RX_MSG_RECV_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_RX_CRC_ERROR_COUNT), 32) then
    
      reg_data_out(31 downto 0) <= axi_ro_regs.RX_CRC_ERROR_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_RX_FORM_ERROR_COUNT), 32) then
    
      reg_data_out(31 downto 0) <= axi_ro_regs.RX_FORM_ERROR_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_RX_STUFF_ERROR_COUNT), 32) then
    
      reg_data_out(31 downto 0) <= axi_ro_regs.RX_STUFF_ERROR_COUNT;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_MSG_ID), 32) then
    
      reg_data_out(0) <= axi_rw_regs_i.TX_MSG_ID.EXT_ID_EN;
      reg_data_out(1) <= axi_rw_regs_i.TX_MSG_ID.RTR_EN;
      reg_data_out(19 downto 2) <= axi_rw_regs_i.TX_MSG_ID.ARB_ID_B;
      reg_data_out(30 downto 20) <= axi_rw_regs_i.TX_MSG_ID.ARB_ID_A;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_PAYLOAD_LENGTH), 32) then
    
      reg_data_out(3 downto 0) <= axi_rw_regs_i.TX_PAYLOAD_LENGTH;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_PAYLOAD_0), 32) then
    
      reg_data_out(7 downto 0) <= axi_rw_regs_i.TX_PAYLOAD_0.PAYLOAD_BYTE_0;
      reg_data_out(15 downto 8) <= axi_rw_regs_i.TX_PAYLOAD_0.PAYLOAD_BYTE_1;
      reg_data_out(23 downto 16) <= axi_rw_regs_i.TX_PAYLOAD_0.PAYLOAD_BYTE_2;
      reg_data_out(31 downto 24) <= axi_rw_regs_i.TX_PAYLOAD_0.PAYLOAD_BYTE_3;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_TX_PAYLOAD_1), 32) then
    
      reg_data_out(7 downto 0) <= axi_rw_regs_i.TX_PAYLOAD_1.PAYLOAD_BYTE_4;
      reg_data_out(15 downto 8) <= axi_rw_regs_i.TX_PAYLOAD_1.PAYLOAD_BYTE_5;
      reg_data_out(23 downto 16) <= axi_rw_regs_i.TX_PAYLOAD_1.PAYLOAD_BYTE_6;
      reg_data_out(31 downto 24) <= axi_rw_regs_i.TX_PAYLOAD_1.PAYLOAD_BYTE_7;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_RX_MSG_ID), 32) then
    
      reg_data_out(0) <= axi_ro_regs.RX_MSG_ID.EXT_ID_EN;
      reg_data_out(1) <= axi_ro_regs.RX_MSG_ID.RTR_EN;
      reg_data_out(19 downto 2) <= axi_ro_regs.RX_MSG_ID.ARB_ID_B;
      reg_data_out(30 downto 20) <= axi_ro_regs.RX_MSG_ID.ARB_ID_A;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_RX_PAYLOAD_LENGTH), 32) then
    
      reg_data_out(3 downto 0) <= axi_ro_regs.RX_PAYLOAD_LENGTH;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_RX_PAYLOAD_0), 32) then
    
      reg_data_out(7 downto 0) <= axi_ro_regs.RX_PAYLOAD_0.PAYLOAD_BYTE_0;
      reg_data_out(15 downto 8) <= axi_ro_regs.RX_PAYLOAD_0.PAYLOAD_BYTE_1;
      reg_data_out(23 downto 16) <= axi_ro_regs.RX_PAYLOAD_0.PAYLOAD_BYTE_2;
      reg_data_out(31 downto 24) <= axi_ro_regs.RX_PAYLOAD_0.PAYLOAD_BYTE_3;
    
    end if;
    
    if unsigned(araddr_i) = resize(unsigned(C_BASEADDR) + unsigned(C_ADDR_RX_PAYLOAD_1), 32) then
    
      reg_data_out(7 downto 0) <= axi_ro_regs.RX_PAYLOAD_1.PAYLOAD_BYTE_4;
      reg_data_out(15 downto 8) <= axi_ro_regs.RX_PAYLOAD_1.PAYLOAD_BYTE_5;
      reg_data_out(23 downto 16) <= axi_ro_regs.RX_PAYLOAD_1.PAYLOAD_BYTE_6;
      reg_data_out(31 downto 24) <= axi_ro_regs.RX_PAYLOAD_1.PAYLOAD_BYTE_7;
    
    end if;
    
  end process p_mm_select_read;

  p_output : process(clk, areset_n)
  begin
    if areset_n = '0' then
      rdata_i <= (others => '0');
    elsif rising_edge(clk) then
      if (slv_reg_rden = '1') then
        rdata_i <= reg_data_out;
      end if;
    end if;
  end process p_output;

end behavior;