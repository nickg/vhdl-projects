library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axi_pkg.all;

-- finish
library std;
use std.env.all;

entity axis2mm_tb is
end entity axis2mm_tb;

-- for slv2hstr
use std.textio.all;

architecture behavioral of axis2mm_tb is

  function slv2bstr (bin_in: std_logic_vector) return string is
    variable b : string (1 to bin_in'length) := (others => NUL);
    variable stri : integer := 1;
    begin
        for i in bin_in'range loop
            b(stri) := std_logic'image(bin_in((i)))(2);
        stri := stri+1;
        end loop;
    return b;
  end function;

  -- Constants for generic parameters
  constant C_AXI_DATA_WIDTH : integer := 32;
  constant C_AXI_ADDR_WIDTH   : integer := 32;
  constant C_AXIL_DATA_WIDTH   : integer := 32;
  constant C_AXIL_ADDR_WIDTH   : integer := 32;

  -- Testbench signals
  signal clk          : std_logic := '0';
  signal rst          : std_logic;

  -- AXI-Lite master signals
  signal s_axi_awaddr   : std_logic_vector(C_AXIL_ADDR_WIDTH-1 downto 0);
  signal s_axi_awvalid  : std_logic := '0';
  signal s_axi_awready  : std_logic;
  signal s_axi_wdata    : std_logic_vector(C_AXIL_DATA_WIDTH-1 downto 0);
  signal s_axi_wstrb    : std_logic_vector((C_AXIL_DATA_WIDTH/8)-1 downto 0);
  signal s_axi_wvalid   : std_logic := '0';
  signal s_axi_wready   : std_logic;
  signal s_axi_bresp    : std_logic_vector(1 downto 0);
  signal s_axi_bvalid   : std_logic;
  signal s_axi_bready   : std_logic := '0';

  -- AXI-Stream slave signals
  signal m_axis_tdata   : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
  signal m_axis_tstrb   : std_logic_vector((C_AXI_DATA_WIDTH/8)-1 downto 0);
  signal m_axis_tvalid  : std_logic := '0';
  signal m_axis_tlast   : std_logic := '0';
  signal m_axis_tready  : std_logic;

  -- AXI4 master signals
  signal m_axi_awaddr   : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
  signal m_axi_awlen    : std_logic_vector(7 downto 0);
  signal m_axi_awsize   : std_logic_vector(2 downto 0);
  signal m_axi_awburst  : std_logic_vector(1 downto 0);
  signal m_axi_awvalid  : std_logic;
  signal m_axi_awready  : std_logic := '0';
  signal m_axi_wdata    : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
  signal m_axi_wstrb    : std_logic_vector((C_AXI_DATA_WIDTH/8)-1 downto 0);
  signal m_axi_wlast    : std_logic;
  signal m_axi_wvalid   : std_logic;
  signal m_axi_wready   : std_logic := '0';
  signal m_axi_bresp    : std_logic_vector(1 downto 0) := "00";
  signal m_axi_bvalid   : std_logic := '0';
  signal m_axi_bready   : std_logic;
  signal m_axi_arvalid  : std_logic;
  signal m_axi_arready  : std_logic := '0';
  signal m_axi_rdata    : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
  signal m_axi_rresp    : std_logic_vector(1 downto 0);
  signal m_axi_rvalid   : std_logic := '0';
  signal m_axi_rready   : std_logic;

  constant axil_o_init_c: axil_o_t := (AWADDR => (others => '0'), WDATA => (others => '0'), WSTRB => (others => '0'), ARADDR => (others => '0'), awvalid => '0',
    wvalid  => '0',
    bready  => '0',
    arvalid => '0',
    rready  => '0'
    );

  signal axil_i: axil_i_t;
  signal axil_o: axil_o_t := axil_o_init_c;

   -- AXI4-Lite registers from axis2mm.
    signal AXIL_ADDR_BASE     : std_logic_vector(C_AXIL_ADDR_WIDTH-1 downto 0) := x"0000_0010";
    constant AXIL_ADDR_LEN      : std_logic_vector(C_AXIL_ADDR_WIDTH-1 downto 0) := x"0000_0018";
    constant AXIL_ADDR_CTRL     : std_logic_vector(C_AXIL_ADDR_WIDTH-1 downto 0) := x"0000_0000";
    signal addr        : std_logic_vector(32-1 downto 0) := x"0000_1000";
    signal data        : std_logic_vector(32-1 downto 0) := x"0000_1000";

  -- Test data
  constant DATA_SIZE    : integer := 16;
  type data_array is array(0 to DATA_SIZE-1) of std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
  constant test_data    : data_array := (
    x"11223344", x"55667788", x"aabbccdd", x"eeff0011",
    x"22334455", x"66778899", x"aabccdee", x"ff112233",
    x"33445566", x"778899aa", x"bbccddff", x"11223344",
    x"55667788", x"aabbccdd", x"eeff0011", x"22334455"
  );

  -- Component declaration for the Verilog module
  component axis2mm is
    generic (
        C_AXI_ADDR_WIDTH      : integer := 32;
        C_AXI_DATA_WIDTH      : integer := 32;
      C_AXIL_ADDR_WIDTH       : integer := 32;
      C_AXIL_DATA_WIDTH       : integer := 32;
        C_AXI_ID_WIDTH        : integer := 1;
        C_AXIS_TUSER_WIDTH    : integer := 0 -- for 0 and non-zero, the port definition is different
        -- OPT_AXIS_SKIDBUFFER   : std_logic := '1';
        -- OPT_AXIS_SKIDREGISTER : std_logic := '0';
        -- OPT_TLAST_SYNC        : std_logic := '1';
        -- OPT_TREADY_WHILE_IDLE : std_logic := '1';
        -- ABORT_KEY             : std_logic_vector(7 downto 0) := x"26";
        -- LGFIFO                : integer := 9;
        -- LGLEN                 : integer := 31;
        -- AXI_ID                : std_logic_vector(0 downto 0) := (others => '0');
        -- OPT_LOWPOWER          : std_logic := '0';
        -- OPT_ASYNCMEM          : std_logic := '1'
    );
    port (
        S_AXI_ACLK      : in  std_logic;
        S_AXI_ARESETN   : in  std_logic;

        S_AXIS_TVALID   : in  std_logic;
        S_AXIS_TREADY   : out std_logic;
        S_AXIS_TDATA    : in  std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
        S_AXIS_TLAST    : in  std_logic;
        S_AXIS_TUSER    : in  std_logic_vector(0 downto 0);

        S_AXIL_AWVALID  : in  std_logic;
        S_AXIL_AWREADY  : out std_logic;
        S_AXIL_AWADDR   : in  std_logic_vector(C_AXIL_ADDR_WIDTH-1 downto 0);
        S_AXIL_AWPROT   : in  std_logic_vector(2 downto 0);
        S_AXIL_WVALID   : in  std_logic;
        S_AXIL_WREADY   : out std_logic;
        S_AXIL_WDATA    : in  std_logic_vector(C_AXIL_DATA_WIDTH-1 downto 0);
        S_AXIL_WSTRB    : in  std_logic_vector(3 downto 0);
        S_AXIL_BVALID   : out std_logic;
        S_AXIL_BREADY   : in  std_logic;
        S_AXIL_BRESP    : out std_logic_vector(1 downto 0);
        S_AXIL_ARVALID  : in  std_logic;
        S_AXIL_ARREADY  : out std_logic;
        S_AXIL_ARADDR   : in  std_logic_vector(C_AXIL_ADDR_WIDTH-1 downto 0);
        S_AXIL_ARPROT   : in  std_logic_vector(2 downto 0);
        S_AXIL_RVALID   : out std_logic;
        S_AXIL_RREADY   : in  std_logic;
        S_AXIL_RDATA    : out std_logic_vector(C_AXIL_DATA_WIDTH-1 downto 0);
        S_AXIL_RRESP    : out std_logic_vector(1 downto 0);

        M_AXI_AWVALID   : out std_logic;
        M_AXI_AWREADY   : in  std_logic;
        M_AXI_AWID      : out std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
        M_AXI_AWADDR    : out std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
        M_AXI_AWLEN     : out std_logic_vector(7 downto 0);
        M_AXI_AWSIZE    : out std_logic_vector(2 downto 0);
        M_AXI_AWBURST   : out std_logic_vector(1 downto 0);
        M_AXI_AWLOCK    : out std_logic;
        M_AXI_AWCACHE   : out std_logic_vector(3 downto 0);
        M_AXI_AWPROT    : out std_logic_vector(2 downto 0);
        M_AXI_AWQOS     : out std_logic_vector(3 downto 0);
        M_AXI_WVALID    : out std_logic;
        M_AXI_WREADY    : in  std_logic;
        M_AXI_WDATA     : out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
        M_AXI_WSTRB     : out std_logic_vector(C_AXI_DATA_WIDTH/8-1 downto 0);
        M_AXI_WLAST     : out std_logic;
        M_AXI_WUSER     : out std_logic_vector(0 downto 0);
        M_AXI_BVALID    : in  std_logic;
        M_AXI_BREADY    : out std_logic;
        M_AXI_BID       : in  std_logic_vector(C_AXI_ID_WIDTH-1 downto 0);
        M_AXI_BRESP     : in  std_logic_vector(1 downto 0);
        o_int           : out std_logic
    );
  end component axis2mm;

  begin

    s_axi_awaddr  <= axil_o.awaddr ;
    s_axi_awvalid <= axil_o.awvalid;
    s_axi_wdata   <= axil_o.wdata  ;
    s_axi_wstrb   <= axil_o.wstrb  ;
    s_axi_wvalid  <= axil_o.wvalid ;
    s_axi_bready  <= axil_o.bready ;
    -- s_axi_araddr  <= axil_o.araddr ;
    -- s_axi_arvalid <= axil_o.arvalid;
    -- s_axi_rready  <= axil_o.rready ;

    axil_i.clk      <= clk;
    axil_i.awready  <= s_axi_awready;
    axil_i.wready   <= s_axi_wready ;
    axil_i.bresp    <= s_axi_bresp  ;
    axil_i.bvalid   <= s_axi_bvalid ;
    -- axil_i.arready  <= s_axi_arready;
    -- axil_i.rdata    <= s_axi_rdata  ;
    -- axil_i.rresp    <= s_axi_rresp  ;
    -- axil_i.rvalid   <= s_axi_rvalid ;

  -- Clock process
  process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process;

  -- Testbench main process
  process
    variable data_counter  : integer := 0;
    variable num_words     : integer := 0;
  begin
    -- 1. Reset
    rst <= '0';
    wait for 100 ns;
    rst <= '1';
    wait for 100 ns;

    m_axis_tdata <= (others => '0');
    m_axis_tvalid <= '0';
    m_axis_tlast <= '0';

    addr <= AXIL_ADDR_BASE;
    data <= x"0000_1000";
    wait for 1 ps;
    axilwrite(axil_o, axil_i, addr, data);

    addr <= AXIL_ADDR_LEN;
    data <= std_logic_vector(to_unsigned(DATA_SIZE*4, C_AXIL_DATA_WIDTH));
    wait for 1 ps;
    axilwrite(axil_o, axil_i, addr, data);

    addr <= AXIL_ADDR_CTRL;
    data <= x"C000_0000";
    wait for 1 ps;
    axilwrite(axil_o, axil_i, addr, data);

    -- 3. Send AXI-Stream Data
    report "Sending AXI-Stream data" severity note;
    m_axis_tstrb <= (others => '1');

    num_words := DATA_SIZE;
    for iii in 0 to DATA_SIZE-1 loop
      -- wait until rising_edge(clk);
      m_axis_tdata <= test_data(iii);
      -- commenting this line fix the segfault
      m_axis_tvalid <= '1';

      if iii = DATA_SIZE-1 then
        m_axis_tlast <= '1';
      end if;

      wait until rising_edge(clk);
      -- wait until m_axis_tready = '1';
      if (m_axis_tready /= '1') then
        wait until (m_axis_tready = '1');
      end if;

    end loop;
    -- wait until rising_edge(clk);
    m_axis_tvalid <= '0';
    m_axis_tlast <= '0';
    wait for 100 ns;

    -- -- 4. Monitor AXI4 Master Interface
    report "Monitoring AXI4 write transfers" severity note;
    m_axi_awready <= '1';
    m_axi_bready <= '1';

    -- Check address and length of first write burst
    if (m_axi_awvalid /= '1') then
      wait until (m_axi_awvalid = '1');
    end if;
    assert m_axi_awaddr = x"0000_1000" report "AXI4 Base Address mismatch" severity failure;
    assert m_axi_awlen  = std_logic_vector(to_unsigned(num_words-1, 8)) report "AXI4 Length mismatch" severity failure;
    report "AXI4 Burst Address/Length OK" severity note;
    m_axi_awready <= '0';

    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);

    -- Check data
    for i in 0 to DATA_SIZE-1 loop
      m_axi_wready <= '1';
      if (m_axi_wvalid /= '1') then
        wait until (m_axi_wvalid = '1');
      end if;
      wait for 1 ps;
      report "Received data word " & integer'image(i) & " at AXI4: " & slv2bstr(m_axi_wdata) severity note;
      assert m_axi_wdata = test_data(i) report "Data word " & integer'image(i) & " mismatch" severity error;
      wait until rising_edge(clk);
      if i = DATA_SIZE-1 then
        assert m_axi_wlast = '1' report "tlast signal not asserted" severity error;
        report "AXI4 tlast signal OK" severity note;
      else
        assert m_axi_wlast = '0' report "tlast signal asserted early" severity error;
      end if;
    end loop;


    -- 5. End Simulation
    report "Simulation finished" severity note;
    -- wait;
    finish(0);
  end process;

u_axis2mm : axis2mm
    generic map (
      C_AXI_DATA_WIDTH   => C_AXI_DATA_WIDTH,
      C_AXI_ADDR_WIDTH   => C_AXI_ADDR_WIDTH,
      C_AXIL_DATA_WIDTH   => C_AXIL_DATA_WIDTH,
      C_AXIL_ADDR_WIDTH   => C_AXIL_ADDR_WIDTH,
        C_AXI_ID_WIDTH        => 4,
        C_AXIS_TUSER_WIDTH    => 0
        -- OPT_AXIS_SKIDBUFFER   => '1',
        -- OPT_AXIS_SKIDREGISTER => '0',
        -- OPT_TLAST_SYNC        => '1',
        -- OPT_TREADY_WHILE_IDLE => '1',
        -- ABORT_KEY             => x"26",
        -- LGFIFO                => 9,
        -- LGLEN                 => 31,
        -- AXI_ID                => (others => '0'),
        -- OPT_LOWPOWER          => '0',
        -- OPT_ASYNCMEM          => '1'
    )
    port map (
        S_AXI_ACLK      => clk,
        S_AXI_ARESETN   => rst,

        S_AXIS_TVALID   => m_axis_tvalid,
        S_AXIS_TREADY   => m_axis_tready,
        S_AXIS_TDATA    => m_axis_tdata,
        S_AXIS_TLAST    => m_axis_tlast,
        S_AXIS_TUSER    => (others => '0'),

        S_AXIL_AWVALID  => S_AXI_AWVALID,
        S_AXIL_AWREADY  => S_AXI_AWREADY,
        S_AXIL_AWADDR   => S_AXI_AWADDR ,
        S_AXIL_AWPROT   => (others => '0') ,
        S_AXIL_WVALID   => S_AXI_WVALID ,
        S_AXIL_WREADY   => S_AXI_WREADY ,
        S_AXIL_WDATA    => S_AXI_WDATA  ,
        S_AXIL_WSTRB    => S_AXI_WSTRB  ,
        S_AXIL_BVALID   => S_AXI_BVALID ,
        S_AXIL_BREADY   => S_AXI_BREADY ,
        S_AXIL_BRESP    => S_AXI_BRESP  ,
        S_AXIL_ARVALID  => '0',
        S_AXIL_ARREADY  => open,
        S_AXIL_ARADDR   => (others => '0'),
        S_AXIL_ARPROT   => (others => '0'),
        S_AXIL_RVALID   => open,
        S_AXIL_RREADY   => '0',
        S_AXIL_RDATA    => open,
        S_AXIL_RRESP    => open,

        M_AXI_AWVALID   => m_axi_awvalid,
        M_AXI_AWREADY   => m_axi_awready,
        -- M_AXI_AWID      => m_axi_awid   ,
        M_AXI_AWADDR    => m_axi_awaddr ,
        M_AXI_AWLEN     => m_axi_awlen  ,
        M_AXI_AWSIZE    => m_axi_awsize ,
        M_AXI_AWBURST   => m_axi_awburst,
        M_AXI_AWLOCK    => open ,
        -- M_AXI_AWCACHE   => m_axi_awcache,
        -- M_AXI_AWPROT    => m_axi_awprot ,
        M_AXI_AWQOS     => open  ,
        M_AXI_WVALID    => m_axi_wvalid ,
        M_AXI_WREADY    => m_axi_wready ,
        M_AXI_WDATA     => m_axi_wdata  ,
        M_AXI_WSTRB     => m_axi_wstrb  ,
        M_AXI_WLAST     => m_axi_wlast  ,
        M_AXI_WUSER     => open         ,
        M_AXI_BVALID    => m_axi_bvalid ,
        M_AXI_BREADY    => m_axi_bready ,
        M_AXI_BID       => (others => '0'),
        M_AXI_BRESP     => m_axi_bresp  ,
        o_int           => open
    );

end behavioral;
