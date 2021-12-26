-- The gpsif_db connects the gpsif to the CPU data bus.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gpsif_pack.all;
use work.cpu2j0_pack.all;
use work.rf_pack.all;
use work.bist_pack.all;
entity gpsif_db is port (
    clk : in std_logic;
    rst : in std_logic;
    bi : in bist_scan_t;
    bo : out bist_scan_t;
    db_i : in cpu_data_o_t;
    db_o : out cpu_data_i_t;
    tgt_o : in cpu_data_i_t;
    tgt_i : out gpsif_tgt_i_t;
    time_i : in gpsif_time_t;
    intrpt : out std_logic;
    a : in gpsif_o_t;
    y : out gpsif_i_t);
end entity;
architecture beh of gpsif_db is
  type state_t is (
    FILL, -- Let CPU write gps data
    BUSY -- Wait for gpsif input buffer available
  );
  constant BUF_ADDR_WIDTH : integer := 4;
  subtype buf_ptr_t is integer range 0 to 2**BUF_ADDR_WIDTH-1;
  type gpsif_db_reg_t is record
    state : state_t;
    ms : std_logic_vector(1 downto 0);
    tm : std_logic_vector(1 downto 0);
    int : gpsif_int_t; -- interrupt status
    intrpt : std_logic; -- interrupt occurs
    err : std_logic;
    wa : buf_ptr_t;
    ack : std_logic;
    tgt_i : gpsif_tgt_reg_t;
  end record;
  constant GPSIF_DB_RESET : gpsif_db_reg_t := ( state => FILL, wa => 0, intrpt => '0', err => '0', ack => '0',
                                                tgt_i => ('0', others => (others => '0')),
                                                               others => (others => '0'));
  signal this_c : gpsif_db_reg_t;
  signal this_r : gpsif_db_reg_t := GPSIF_DB_RESET;
  type mem_loc_t is (GPSIF_REG, INPUT_BUF, GPSTM_REG, NONE );
  signal mem_loc : mem_loc_t := NONE;
  signal buf_db_o : cpu_data_i_t;
  signal gps_db_o : cpu_data_i_t;
  signal tim_db_o : cpu_data_i_t;
  signal buf_we : std_logic;
  signal buf_re : std_logic;
  signal tim_re : std_logic;
  signal buf_ra : buf_ptr_t;
  signal buf_rd : std_logic_vector(31 downto 0);
  -- memory map:
  -- 0x000 - 018 shift to ajust C/A code
  -- 0x020 - 038 g2 init. of C/A code
  -- 0x040 - 058 PNCO
  -- 0x060 GPSIF control (write only) reset, INT, debug
  -- 0x080 - 088 Dump signals for Debug
  -- 0x100 - 1d4 ch0-6,E/P/L,I/Q -- 7*3*2 registers
  -- 0x200 - 204 GPSIF status (read only)
  -- 0x200 - 204 input sink
  -- 0x210 - 214 gps time register
  function decode_addr(a : std_logic_vector( 9 downto 2))
  return mem_loc_t is
  begin
    -- IF_REG = for debug enlarging : {0x000 - 0x1fc, 0x300 - 0x3fc}
    ------
    if (a(9) = '0') or
       (a(8) = '1') then return GPSIF_REG;
    else case a(8 downto 3) is
        when "000000" => return INPUT_BUF;
        when "000010" => return GPSTM_REG;
        when others => return NONE;
    end case; end if;
  end function;
begin
-------- handle CPU data bus --------
  mem_loc <= decode_addr(this_r.tgt_i.a);
-- select appropriate outgoing data bus
  with mem_loc select
    db_o <=
    gps_db_o when GPSIF_REG,
    buf_db_o when INPUT_BUF,
    tim_db_o when GPSTM_REG,
    ((others => '0'), '0') when others;
-- connect gpsif bus
  tgt_i <= ( this_r.ack and to_bit(mem_loc = GPSIF_REG),
                       this_r.tgt_i.wr, this_r.tgt_i.a, this_r.tgt_i.d);
  gps_db_o <= (tgt_o.d,this_r.ack);
-------- Input Buffer connected to CPU bus --------
-- STATUS register (Read only)
  buf_db_o <= (this_r.ms & a.sr
             & this_r.tm
             & this_r.int
             & this_r.err & to_bit(this_r.state = FILL),
               this_r.ack);
  buf_we <= this_r.ack and this_r.tgt_i.wr and to_bit(mem_loc = INPUT_BUF and this_r.state = FILL);
  buf_re <= this_r.ack and not this_r.tgt_i.wr and to_bit(mem_loc = INPUT_BUF);
  tim_re <= this_r.ack and not this_r.tgt_i.wr and to_bit(mem_loc = GPSTM_REG);
  buf_ra <= a.ra/16;
  tim_db_o <= (time_i.seq & std_logic_vector(time_i.nsec),
               this_r.ack);
  intrpt <= this_r.intrpt;
-- Instantiate register file for input buffer and connect buffer bus to it.
-- Input tbl 256 pairs of sign/mag bits = 16*32
-- Use a 1R/1W register file.
  r : bist_RF1
  generic map ( WIDTH => 32, DEPTH => 2**BUF_ADDR_WIDTH )
  port map
   (clk => clk,
    rst => rst,
    bi => bi,
    bo => bo,
    D => db_i.d,
    WA => this_r.wa,
    WE => buf_we,
    RA0 => buf_ra,
    Q0 => buf_rd);
  p : process(this_r, a, db_i, tgt_o, buf_we, buf_re, tim_re, time_i)
    variable this : gpsif_db_reg_t;
    variable int : gpsif_int_t;
  begin
     this := this_r;
    this.ack := db_i.en and not this_r.ack;
    this.tgt_i := (db_i.wr, db_i.a(9 downto 2), db_i.d);
    if buf_we = '1' then this.wa := (this.wa + 1) mod 16; end if;
    if this.wa = 0 and not a.cntl.lst then this.state := BUSY;
    else this.state := FILL; end if;
-- Check if read is too late, set err, and clear status
    if a.cntl.err then this.err := '1'; end if; -- VLD (accumulate err)
    if tim_re = '1' then if this.tm(1 downto 0) = "11" then this.err := '1'; end if; -- Time (accumulate err)
                            this.tm(1 downto 0):= "00"; end if; -- Clear after time read
    if buf_re = '1' then this.err := this.ms(1) and this.ms(0); -- Clear old err after status read, and set new err.
                                     this.ms(1 downto 0):= "00"; -- Clear after status read
                         this.int := (others => '0'); end if; -- clear after status read
-- Uptate status, check interrupt condition, and assert intrpt
    int := a.cntl.ovr & "00" & a.cntl.vld;
    if time_i.setnsec = '1' then
      if time_i.mscnt = '1' then this.tm(1) := '1'; int(2) := '1'; int(3) := int(3) or this.tm(0); -- 1 pps is in odd region
      else this.tm(0) := '1'; int(2) := '1'; int(3) := int(3) or this.tm(1); end if; end if; -- 1 pps is in even region
    if a.cntl.bndry then if a.odd then this.ms(1) := '1'; int(1) := '1'; int(3) := int(3) or this.ms(0); -- in odd region now
                         else this.ms(0) := '1'; int(1) := '1'; int(3) := int(3) or this.ms(1); end if; end if; -- in even region now
    this.int := this.int or int; -- accumulte interrupt condition until read
    this.intrpt := to_bit((a.int_en and int) /= X"0");
-- SW reset
    if a.rst then this := GPSIF_DB_RESET; end if;
    this_c <= this;
  end process;
  p_r0 : process(clk, rst)
  begin
     if clk = '1' and clk'event then
        if rst = '1' then
           this_r <= GPSIF_DB_RESET;
        else
           this_r <= this_c;
        end if;
     end if;
  end process;
  -- Returns two neighbouring bits from a vector of 32 bits.
  -- The bits are addressed left to right.
  -- Address 0 = data(31 downto 30) and address 15 = data(1 downto 0)
  y.d <= buf_rd(31 - 2*(a.ra mod 16) downto 30 - 2*(a.ra mod 16));
  y.wa <= this_r.wa *2;
end beh;
