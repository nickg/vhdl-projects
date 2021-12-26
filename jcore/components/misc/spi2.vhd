-- SPI controller. Supports SPI transactions that send, and simultaneously
-- receive, 1 byte of data. Chip select lines, cs, control which SPI slave is
-- active. Generates an spi_clk at a configurable frequency.
--
-- SPI mode can be chosen at synthesis time using generics, but could move this
-- choice to register accessible from software.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.cpu2j0_pack.all;
use work.attr_pack.all;
entity spi2 is
  generic (
    NUM_CS : integer range 2 to 5 := 2;
    CLK_FREQ : real range 25.0e6 to 125.0e6;
    LOW_SPEED_FREQ : real := 400.0e3;
    HIGH_SPEED_FREQ : real := 25.0e6
    );
  port (
    clk : in std_logic;
    rst : in std_logic;
    db_i : in cpu_data_o_t;
    db_o : out cpu_data_i_t;
    spi_clk : out std_logic;
    cs : out std_logic_vector(NUM_CS - 1 downto 0);
    miso : in std_logic;
    mosi : out std_logic;
    busy : out std_logic;
    cpha : in std_logic;
    cpol : in std_logic );
  attribute soc_port_local_name of spi_clk : signal is "clk";
end entity;
architecture arch of spi2 is
  -- This entity outputs a spi clock divided down from the system clock. The
  -- spi clock frequency is configurable from software.
  -- The maximum clock rate is 20MHz for MMC, 25MHz for SDC. Use rate
  -- between 100kHz and 400kHz during initialization
  -- SW sets the 5 bit div setting to 0-31 and we need to map those onto the
  -- range 100kHz-25MHz or 400kHz-25MHz
  -- Existing bootloader only uses 0 or 31 and comments suggest it
  -- expects 31 to be 400kHz and 0 to be 12.5MHz. The spi kernel driver
  -- sets speed using (12500000/F)-1 where F is the desired frequency, so
  -- 400kHZ is 30 and 12.5MHz is 0.
  -- So let's try to map [31, 0] to [400kHz, 12.5MHz], ensuring that 30 and
  -- 31 are both 400kHz and 0 is 12.5MHz.
  constant MIN_SPI_CLK_FREQ : real := 400.0e3;
  constant MAX_SPI_CLK_FREQ : real := 25.0e6;
  -- If we flip the spi clk once every N clock cycles at a freq_sys
  -- frequency, then the spi clk freq is:
  -- freq_spi = freq_sys / (2 * N)
  -- solving for N gives
  -- N = freq_sys / (2 * freq_spi)
  -- N needs to be an integer, and we should err on the side of slower, so
  -- take the ceil
  -- N = ceil(freq_sys / (2 * freq_spi))
  -- freq_sys [N for 400kHz, N for 12.5MHz]
  ------------------------------------------
  -- 25MHz [32,1]
  -- 31.25MHz [40,2]
  -- 50MHz [63,2]
  -- 62.5MHz [79,3]
  -- 75MHz [94,3]
  -- 125MHz [157,5]
  -- N is the number of cycles of the system clock in one half-period of the
  -- spi clock.
  -- Half-period cycle counts for min and max speeds.
  -- -1 because even with a count of 0 there is still a 1 cycle delay
  constant MAX_HALF_PERIOD : integer := integer(ceil(CLK_FREQ / (2.0 * LOW_SPEED_FREQ))) - 1;
  constant MIN_HALF_PERIOD : integer := integer(ceil(CLK_FREQ / (2.0 * HIGH_SPEED_FREQ))) - 1;
  --constant HALF_PERIOD_STEP : integer := floor((MAX_HALF_PERIOD - MIN_HALF_PERIOD + 1) / 32);
  -- number of bits needed to represent the maximum cycle count between changing
  -- the spi clk
  constant CYCLE_COUNT_BITS : integer := integer(floor(log2(real(MAX_HALF_PERIOD)))) + 1;
  subtype cycle_count_t is unsigned(CYCLE_COUNT_BITS-1 downto 0);
  type state_t is (IDLE, LEAD_EDGE, TRAIL_EDGE, WAITING);
  type spi_reg_t is record
    state : state_t;
    clk : std_logic;
-- db_o : cpu_data_i_t;
    -- number of pairs of clk edges output in the current transaction thus far
    edge_pair_cnt : unsigned(2 downto 0);
    cyc_cnt : cycle_count_t;
    speed : unsigned(4 downto 0); -- spi speed setting from sw. higher is slower.
    cs : std_logic_vector(NUM_CS - 1 downto 0);
    loopback : boolean;
    rx : std_logic_vector(7 downto 0);
    tx : std_logic_vector(7 downto 0);
    tx_shift : std_logic_vector(8 downto 0);
    rx_shift : std_logic_vector(7 downto 0);
  end record;
  constant SPI_RESET : spi_reg_t := (
    state => IDLE,
    clk => '0',
-- db_o => (d => (others => '0'), ack => '0'),
    edge_pair_cnt => (others => '0'),
    cyc_cnt => (others => '0'),
    speed => (others => '1'),
    -- TODO: Why does old spi.vhd negate all but one of the cs
    cs => (0 => '1', others => '0'),
    loopback => false,
    rx => (others => '0'),
    tx => (others => '0'),
    tx_shift => (others => '1'), -- rst to '1' so mosi floats high during idle
    rx_shift => (others => '0'));
  signal this_c : spi_reg_t;
  signal this_r : spi_reg_t := SPI_RESET;
  function to_bit(b : boolean) return std_logic is
  begin
    if b then
      return '1';
    else
      return '0';
    end if;
  end;
begin
  p : process(this_r, db_i, miso, cpol, cpha)
    variable this : spi_reg_t;
    variable db_o_d : std_logic_vector(31 downto 0);
    variable is_clk_edge : boolean;
    variable start_txn : boolean;
    variable ack_cycle : std_logic;
    variable shift : boolean;
    variable sample : boolean;
    -- extra bit for underflow
    variable cyc_cnt : unsigned(cycle_count_t'length downto 0);
    variable miso2 : std_logic;
  begin
     this := this_r;
    start_txn := false;
    -- Step 1: Handle data bus writes and reads. Requests are acked the cycle
    -- after they are received.
-- ack_cycle := this.db_o.ack;
-- this.db_o.ack := '0';
    db_o_d := (others => '0');
    -- spi2 busy
    if(this.state = IDLE) then busy <= '0';
    else busy <= '1'; end if;
    -- end of spi2 busy
    if db_i.en = '1' then
      if db_i.wr = '1' then
        if db_i.a(2) = '0' then
          -- ctrl
          this.cs(0) := db_i.d(0);
          start_txn := db_i.d(1) = '1';
          this.cs(1) := db_i.d(2);
          this.loopback := db_i.d(3) = '1';
          for i in 2 to NUM_CS-1 loop
            this.cs(i) := db_i.d(2+i);
          end loop;
          this.speed := unsigned(db_i.d(31 downto 27));
        else
          -- tx data
          this.tx := db_i.d(7 downto 0);
        end if;
      else
        if db_i.a(2) = '0' then
          -- status
          db_o_d(0) := this.cs(0);
          db_o_d(1) := to_bit(this.state /= IDLE); -- busy?
          db_o_d(2) := this.cs(1);
          db_o_d(3) := to_bit(this.loopback);
          for i in 2 to NUM_CS-1 loop
            db_o_d(2+i) := this.cs(i);
          end loop;
          -- TODO: Old spi.vhd did not support reading speed
          --db_o.d(31 downto 27) := std_logic_vector(this.speed);
        else
          -- rx data
          db_o_d(7 downto 0) := this.rx;
        end if;
      end if;
 -- this.db_o.ack := '1';
    end if;
    db_o.d <= db_o_d;
    db_o.ack <= db_i.en;
    -- Step 2: Decide if spi clock needs an edge
    cyc_cnt := ('1' & this.cyc_cnt) - 1; -- decrement with borrow in
    is_clk_edge := cyc_cnt(cyc_cnt'left) = '0'; -- underflow occurred
    if this.state = IDLE or is_clk_edge then
      -- Reset the cycle count.
      -- Setting the initial cyc_cnt determines when it will next underflow, and
      -- thus controls the frequency of the SPI clock.
      -- Interpolate between the max 12.5MHz and 400MHz based on this.speed.
      -- speed=0 is 12.5MHz.
      -- speed=31 is 400kHz
      if this.speed = 31 or this.speed = 30 then -- is this.speed(4 downto 1) = "1111" better?
        -- also make speed=30 be 400kHz to match how kernel driver calculates speed
        this.cyc_cnt := to_unsigned(MAX_HALF_PERIOD, cycle_count_t'length);
      else
        -- TODO: This simple interpolation ensures speed=0 is 12.5MHz, but
        -- there can be a big gap between the frequency of speed=29 and the
        -- 400kHz of speeds 30 and 31. One way to fix this would be to increase,
        -- likely by left-shifting, the contribution of this.speed in the following
        -- equation if the difference between MIN_HALF_PERIOD and
        -- MAX_HALF_PERIOD is large enough. See HALF_PERIOD_STEP above for ideas.
        this.cyc_cnt := to_unsigned(to_integer(this.speed) + MIN_HALF_PERIOD, cycle_count_t'length);
      end if;
    else
      this.cyc_cnt := cyc_cnt(cycle_count_t'range);
    end if;
    -- squash clk edges if in idle
    if this.state = IDLE then
      is_clk_edge := false;
    end if;
    -- Step 3: Update state and decide whether to sample miso or shift new mosi or neither
    sample := false;
    shift := false;
    case this.state is
      when IDLE =>
        this.clk := cpol;
        if start_txn then
          this.state := LEAD_EDGE;
          this.tx_shift := '1' & this.tx;
          shift := cpha = '0';
        end if;
      when LEAD_EDGE =>
        if is_clk_edge then
          this.clk := not cpol;
          this.state := TRAIL_EDGE;
          shift := cpha = '1';
          sample := cpha = '0';
        end if;
      when TRAIL_EDGE =>
        if is_clk_edge then
          this.clk := cpol;
          if this.edge_pair_cnt = 7 then
            -- transaction is almost complete, stop changing the spi clk
            this.state := WAITING;
          else
            this.state := LEAD_EDGE;
          end if;
          shift := cpha = '0';
          sample := cpha = '1';
          this.edge_pair_cnt := this.edge_pair_cnt + 1; -- rolls over
        end if;
      when WAITING =>
        if is_clk_edge then
          this.state := IDLE;
          shift := true;
          this.rx := this.rx_shift;
        end if;
    end case;
    -- Step 4: Sample or output new mosi
    -- support looping back mosi as miso so that we receive exactly what is sent
    if this.loopback then
      miso2 := this.tx_shift(8);
    else
      miso2 := miso;
    end if;
    if sample then
      this.rx_shift := this.rx_shift(6 downto 0) & miso2;
    end if;
    if shift then
      -- shift in '1' so mosi floats high
      this.tx_shift := this.tx_shift(7 downto 0) & '1';
    end if;
    this_c <= this;
  end process;
  p_r0 : process(clk, rst)
  begin
     if rst = '1' then
        this_r <= SPI_RESET;
     elsif clk = '1' and clk'event then
        this_r <= this_c;
     end if;
  end process;
  spi_clk <= this_r.clk ;
  mosi <= this_r.tx_shift(8);
  cs <= this_r.cs(NUM_CS-1 downto 0);
end architecture;
