library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axi_pkg is

  constant AXIL_ADDR_W: integer := 32;
  constant AXIL_DATA_W: integer := 32;

  -- AXI4-Lite bus records
  type axil_o_t is record
    awaddr   : std_logic_vector(AXIL_ADDR_W-1 downto 0);
    awvalid  : std_logic;
    wdata    : std_logic_vector(AXIL_DATA_W-1 downto 0);
    wstrb    : std_logic_vector(AXIL_DATA_W/8-1 downto 0);
    wvalid   : std_logic;
    bready   : std_logic;
    araddr   : std_logic_vector(AXIL_ADDR_W-1 downto 0);
    arvalid  : std_logic;
    rready   : std_logic;
  end record;

  type axil_i_t is record
    clk      : std_logic;
    awready  : std_logic;
    wready   : std_logic;
    bresp    : std_logic_vector(1 downto 0);
    bvalid   : std_logic;
    arready  : std_logic;
    rdata    : std_logic_vector(AXIL_DATA_W-1 downto 0);
    rresp    : std_logic_vector(1 downto 0);
    rvalid   : std_logic;
  end record;

procedure axilwrite(
    signal axil_o: out axil_o_t;
    signal axil_i: in axil_i_t;
    signal addr: in std_logic_vector;
    signal data: in std_logic_vector);

end axi_pkg;

package body axi_pkg is

procedure axilwrite(
    signal axil_o: out axil_o_t;
    signal axil_i: in axil_i_t;
    signal addr: in std_logic_vector;
    signal data: in std_logic_vector
  ) is
  begin

    report "AXI-Lite Write: Setting AXI4 Base Address" severity note;
    axil_o.awaddr  <= addr;
    axil_o.wdata   <= data;
    axil_o.wstrb   <= (others => '1');
    axil_o.awvalid <= '1';
    axil_o.wvalid  <= '1';
    if (axil_i.awready /= '1' or axil_i.wready /= '1') then
        wait until (axil_i.awready = '1' and axil_i.wready = '1');
    end if;
    wait until rising_edge(axil_i.clk);
    
    axil_o.bready  <= '1';
    wait until rising_edge(axil_i.clk);
    axil_o.awvalid <= '0';
    axil_o.wvalid  <= '0';
    if (axil_i.bvalid /= '1') then
        wait until (axil_i.bvalid = '1');
    end if;
    wait until rising_edge(axil_i.clk);
    -- wait until axil_i.bvalid = '1';
    axil_o.bready  <= '0';

  end procedure;

end axi_pkg;