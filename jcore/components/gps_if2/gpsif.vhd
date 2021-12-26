library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_pkg.all;
use work.rf_pack.all;
use work.memory_pack.all;
use work.bist_pack.all;
use work.ring_bus_pack.all;
use work.rbus_pack.all;
use work.cpu2j0_pack.all;
use work.gpsif_pack.all;
use work.gpsif_sub_pack.all;
entity gpsif is
generic ( GPSIF_NC : integer := 7;
     ANGLE_INI_OLD : boolean := false );
port (
  clk : in std_logic;
  rst : in std_logic;
  bi : in bist_scan_t;
  bo : out bist_scan_t;
-- for debug on FPGA (from here)
  ring_i : in rbus_9b; -- to monitor ring bus
  ring_o : in rbus_9b; -- to monitor ring bus
-- for debug on FPGA (to here)
  tgt_o : out cpu_data_i_t;
  tgt_i : in gpsif_tgt_i_t;
  dev_o : out rbus_dev_o_t;
  dev_i : in rbus_dev_i_t;
  buf_io : in gpsif_buf_i_t;
  time_i : in gpsif_time_t;
  ra_io : out gpsif_buf_ct_t;
  buf_bus : in gpsif_i_t;
  gpsif_o : out gpsif_o_t;
  dma : out dma_req_t );
end gpsif;
architecture beh of gpsif is
signal this_c : gpsif_reg_t;
signal this_r : gpsif_reg_t := GPSIF_REG_RESET;
signal regfile_i : gpsif_regfile_i_t;
signal regfile_o : gpsif_regfile_o_t;
-- for debug on FPGA (from here)
type dbg_d_t is array (integer range 0 to 2) of std_logic_vector(31 downto 0);
signal dbg_w : std_logic;
signal dbg_a : std_logic_vector( 7 downto 0);
signal dbg_wd,dbg_rd : dbg_d_t;
begin
    dbg0h : ram_1rw
      generic map ( SUBWORD_WIDTH => 8, SUBWORD_NUM => 2, ADDR_WIDTH => 8 )
      port map ( clk => clk, en => '1', we => "11", a => dbg_a, dw => dbg_wd(0)(31 downto 16),
                 rst => rst, wr => dbg_w, margin => "00", dr => dbg_rd(0)(31 downto 16));
    dbg0l : ram_1rw
      generic map ( SUBWORD_WIDTH => 8, SUBWORD_NUM => 2, ADDR_WIDTH => 8 )
      port map ( clk => clk, en => '1', we => "11", a => dbg_a, dw => dbg_wd(0)(15 downto 0),
                 rst => rst, wr => dbg_w, margin => "00", dr => dbg_rd(0)(15 downto 0));
    dbg1h : ram_1rw
      generic map ( SUBWORD_WIDTH => 8, SUBWORD_NUM => 2, ADDR_WIDTH => 8 )
      port map ( clk => clk, en => '1', we => "11", a => dbg_a, dw => dbg_wd(1)(31 downto 16),
                 rst => rst, wr => dbg_w, margin => "00", dr => dbg_rd(1)(31 downto 16));
    dbg1l : ram_1rw
      generic map ( SUBWORD_WIDTH => 8, SUBWORD_NUM => 2, ADDR_WIDTH => 8 )
      port map ( clk => clk, en => '1', we => "11", a => dbg_a, dw => dbg_wd(1)(15 downto 0),
                 rst => rst, wr => dbg_w, margin => "00", dr => dbg_rd(1)(15 downto 0));
    dbg2h : ram_1rw
      generic map ( SUBWORD_WIDTH => 8, SUBWORD_NUM => 2, ADDR_WIDTH => 8 )
      port map ( clk => clk, en => '1', we => "11", a => dbg_a, dw => dbg_wd(2)(31 downto 16),
                 rst => rst, wr => dbg_w, margin => "00", dr => dbg_rd(2)(31 downto 16));
    dbg2l : ram_1rw
      generic map ( SUBWORD_WIDTH => 8, SUBWORD_NUM => 2, ADDR_WIDTH => 8 )
      port map ( clk => clk, en => '1', we => "11", a => dbg_a, dw => dbg_wd(2)(15 downto 0),
                 rst => rst, wr => dbg_w, margin => "00", dr => dbg_rd(2)(15 downto 0));
-- for debug on FPGA (to here)
  regfile : gpsif_regfile port map ( rst => rst, clk => clk, bi => bi, bo => bo, a => regfile_i, y => regfile_o);
  p0 : process(this_r, buf_io, buf_bus, tgt_i, dev_i, time_i, regfile_o, ring_i, ring_o)
    variable this : gpsif_reg_t;
    variable active, acm_lst, acm_done, acm_strt, acm_now, acm_nxt, sft_we, stall, mns_inc : boolean;
    variable cntl : gpsif_cntl_t;
    variable carrmix_i : gpsif_carrmix_i_t;
    variable carrmix_o : gpsif_carrmix_o_t;
    variable angle, delta : gpsif_angle_t;
    variable delta_slv : std_logic_vector(delta'range);
    variable next_cnt1ms : ufixed(gpsif_cnt1ms_t'high+1 downto 0);
    variable next_ch : gpsif_ch_t;
    variable rbus_ch : integer range 0 to GPSIF_NC_MAX;
    variable wbus_ch : integer range 0 to GPSIF_NC_MAX;
    variable nn_ch : integer range 0 to GPSIF_NC_MAX;
    variable n_ch : integer range 0 to GPSIF_NC_MAX;
    variable ch : integer range 0 to GPSIF_NC_MAX;
    variable ra_range : natural range 64 to GPSIF_RW_MAX+1;
    variable nd_range : natural range 4 to GPSIF_ND_MAX+1;
    variable wa : integer range 0 to GPSIF_ND_MAX;
    variable carrmix : gpsif_sum_t;
    variable sum : gpsif_sum_d_t;
    variable acm : gpsif_acm_d_t;
    variable code, g1sft0, g2sft0 : std_logic;
    variable sft_chg : gpsif_sft_chg_t;
    variable sft_1ms : gpsif_cnt1ms_t;
    variable sft_now : gpsif_sft_t;
    variable sft_tmp_h : ufixed(sft_now'high -5 downto 0); -- to absorb carry
    variable sft_nxt_h : ufixed(sft_now'high -6 downto 0);
    constant sft_dec_h : ufixed(sft_now'high -6 downto 0) := (others => '1');
    variable sft_nxt_l : ufixed(6 downto 0); -- to absorb carry
    variable sft_inc : integer range 1 to 63;
    variable pnco_now : ufixed(delta'high-10 downto 0);
    variable pnco_nxt : ufixed(pnco_now'high+1 downto pnco_now'low); -- to absorb carry
    variable pnco_inc : natural range 1 to 256;
    variable reg_i : gpsif_regfile_i_t;
    variable devo : rbus_dev_o_t;
    variable tgt_rd : std_logic_vector(31 downto 0);
-- for debug on FPGA (from here)
    variable dbg_b,dbg_r,dbg_v : boolean; -- 1ms boundary, CPU read debug info., dump debug info.
    variable dbg_i,dbg_q : gpsif_sum_d_t;
-- for debug on FPGA (to here)
  begin
     this := this_r;
-- select input source, and set up parameters
    case this.src is
    when IO_PIN =>
         carrmix_i.d := buf_io.d; wa := buf_io.wa; ra_range := 64; nd_range := 4;
    when CPU_BUS =>
         carrmix_i.d := buf_bus.d; wa := buf_bus.wa; ra_range := GPSIF_RW_MAX+1; nd_range := GPSIF_ND_MAX+1;
    when others => -- ((BITL_BUS1 or BITL_BUS2)
         carrmix_i.d := time_i.d; wa := time_i.wa; ra_range := 64; nd_range := 4;
    end case;
    if GPSIF_NC = 7 then
-- channel update with 3b LFSR (only two ENOR gates for next & next-next channel numbers)
-- 000 -> 001 -> 011 -> 110 -> 101 -> 010 -> 100
        next_ch := this.ch(1) & this.ch(0) & not (this.ch(2) xor this.ch(1));
        nn_ch := vtoui(next_ch(1) & next_ch(0) & not (next_ch(2) xor next_ch(1)));
        n_ch := vtoui(next_ch);
    else -- use incrementer for arbitary GPSIF_NC (1 to 6)
        n_ch :=(vtoui(this.ch)+1) mod GPSIF_NC;
        nn_ch := (n_ch +1) mod GPSIF_NC;
        next_ch := itov(n_ch, next_ch'length);
    end if;
        ch := vtoui(this.ch);
    if this.sft.chg = MNS and this.scp_chg then nn_ch := n_ch; end if;
    if this.sft.typ = AGN then nn_ch := n_ch; n_ch := ch; end if;
    active := this.ready and this.st(n_ch).run and
        not(this.scp_chg and this.sft.chg = PLS); -- skip for scope change
    acm_lst:= this.st(n_ch).mode(2 downto 1) /= "00" and this.ready and this.bndry;
-- Accumulate for 1ms with C/A code --------------------------------------------
                        reg_i.acm.a := ch * (GPSIF_REG_PER_CH/2); -- not to add rd for 6,7 to avoid boudary check error
    case this.rd is
        when 6 => reg_i.sftca.ra := n_ch;
        when 7 => reg_i.sftca.ra := nn_ch + (GPSIF_NC_MAX + 1);
        when others => reg_i.sftca.ra := ch + (GPSIF_NC_MAX + 1);
                        reg_i.acm.a := reg_i.acm.a + this.rd/2;
    end case;
                        reg_i.sftca.wa := reg_i.sftca.ra; -- ra & wa are the same for internal operations
    if this.rd mod 2 = 0 then
         reg_i.acm.bs := '0'; sum := this.sum.i; -- I
    else reg_i.acm.bs := '1'; sum := this.sum.q; -- Q
    end if;
    case this.rd is
        when 0 | 1 => code := this.code(2); -- E
        when 2 | 3 => code := this.code(1); -- P
        when others => code := this.code(0); -- L
    end case;
    if code = '1' then acm := vtoi(regfile_o.acm) + sum;
    else acm := vtoi(regfile_o.acm) - sum;
    end if;
    if this.acm_lst then
         reg_i.acm.wd := (others => '0');
    else reg_i.acm.wd := itov(acm,GPSIF_ACMREG_MAX+1); end if;
         reg_i.buf.wd := itov(acm,GPSIF_ACMREG_MAX+1);
    case this.rd is
        when 6 | 7 => acm_nxt := false;
                        acm_now := false;
        when others => acm_nxt := this.ready and this.acm_lst;
                        acm_now := this.ready and (this.acm_lst or this.acm_en);
    end case;
    if acm_nxt then reg_i.buf.we := '1'; else reg_i.buf.we := '0'; end if;
    if acm_now then reg_i.acm.we := '1'; else reg_i.acm.we := '0'; end if;
-- RING bus --------------------------------------------------------------------
-- Assuming bus is always available,
-- output signals are generated without response from the bus.
-- The first data is used at the 3rd cycle. (cmd and ch are output at 1st and 2nd cycles)
-- keep devo.v true while sending. (BUSY insersion is another way.)
    case this.rd is
        when 2 | 6 => devo.d := itov(this.sum.i, 9); -- lower 9 bits
        when 3 | 7 => devo.d := itov(this.sum.i,18)(17 downto 9); -- higher bits w/ sign ext.
        when 4 | 0 => devo.d := itov(this.sum.q, 9);
        when 5 | 1 => devo.d := itov(this.sum.q,18)(17 downto 9);
    end case;
    devo.v := false;
    if this.ready and this.st(ch).mode(2 downto 1) = "01" and this.st(ch).run then case this.rd is -- ACQ
            when 0 | 1 | 2 | 3 | 4 | 5 => devo.v := true;
            when others =>
    end case; end if;
    devo.bsy := false; -- Currently, fixed to false (currently not used)
    devo.ch := RNG_CH_DSP; -- Currently, fixed to DSP
-- Carrier NCO Multply & Accumulate for 8 cycles--------------------------------
    delta := to_ufixed(regfile_o.pnco, gpsif_angle_t'high,gpsif_angle_t'low);
    angle := to_ufixed(regfile_o.angle,gpsif_angle_t'high,gpsif_angle_t'low);
    carrmix_i.angle := angle(GPSIF_ANGLE_BITS-1 downto GPSIF_ANGLE_BITS-GPSIF_ANGLE_INDX);
    carrmix_o := gpsif_carrmix(carrmix_i);
    if active then case this.rd is
        when 0 => this.add.i := carrmix_o.i;
                        this.add.q := carrmix_o.q;
        when 7 => this.sum.i := carrmix_o.i + this.add.i; -- update after use
                        this.sum.q := carrmix_o.q + this.add.q;
        when others => this.add.i := carrmix_o.i + this.add.i;
                        this.add.q := carrmix_o.q + this.add.q; end case;
         reg_i.angle.we := '1';
    else reg_i.angle.we := '0';
    end if;
    reg_i.pnco.a := n_ch;
    reg_i.angle.a := n_ch;
    reg_i.angle.wd := to_slv(resize(angle + delta, gpsif_angle_t'high, gpsif_angle_t'low));
-- PNCO update data (It is not always used, but must be defined to avoide inferred latch)
    reg_i.pnco.wd := regfile_o.pnco; -- to make LS 9 bits unchanged (It is fit to current TB)
    --reg_i.pnco.wd := (others => '0'); -- Zero clear is enough to scan.
    case this.inc.pnco is
        when "000" => pnco_inc := 1; -- 8Hz (7.8048)
        when "001" => pnco_inc := 2; -- 16Hz (15.6096)
        when "010" => pnco_inc := 4; -- 31Hz (31.2192)
        when "011" => pnco_inc := 8; -- 62Hz (62.4384)
        when "100" => pnco_inc := 16; -- 125Hz (124.9)
        when "101" => pnco_inc := 32; -- 250Hz (249.8)
        when "110" => pnco_inc := 64; -- 500Hz (499.5)
        when "111" => pnco_inc := 128; -- 1 KHz (999)
        when others =>
    end case;
    if regfile_o.pnco(20 downto 19) & regfile_o.pnco(17) = "011" then -- PNCO is +10kHz
         reg_i.pnco.wd(delta'high-1 downto delta'low+17) := X"7fb"; -- rwind to -10kHz
    else pnco_now := delta(delta'high-1 downto delta'low+9);
        pnco_nxt := pnco_now + pnco_inc;
        reg_i.pnco.wd(delta'high-1 downto delta'low+9) := to_slv(pnco_nxt(pnco_now'range));
    end if;
-- C/A code upfdate at RD = 6 for next RD period of 8 cycles--------------------
    g1sft0 := regfile_o.sftca(19) xor regfile_o.sftca(12);
    g2sft0 := regfile_o.sftca( 9) xor regfile_o.sftca( 8) xor regfile_o.sftca(7) xor
              regfile_o.sftca( 5) xor regfile_o.sftca( 2) xor regfile_o.sftca(1);
    reg_i.sftca.wd := regfile_o.sftca(18 downto 10) & g1sft0 &
                      regfile_o.sftca( 8 downto 0) & g2sft0;
    reg_i.sftca.we := '0';
    if this.rd = 6 and active then
        this.code(2) := regfile_o.sftca(19) xor regfile_o.sftca(9);
        this.code(0) := regfile_o.sftca(18) xor regfile_o.sftca(8);
 -- 2 * 1.023 MHz sample CA code ganeration
        if this.even then this.code(1) := this.code(2);
        else reg_i.sftca.we := '1'; this.code(1) := this.code(0); end if;
    end if;
    if((this.cnt1ms(10) = '0') and (this.cnt1ms(9) = '1')) or
      ( this.inittm(1) = '1') then
         this.inittm := "10"; -- suppress 2nd init command
    elsif(std_logic_vector(this.cnt1ms) = "000" & x"20") and
         (this.inittm(1) = '0') then
                               -- synchronize gps_tm
         this.inittm := "01";
    else this.inittm := "00"; -- keep
    end if;
-- Next states -----------------------------------------------------------------
-- range of cnt1ms is 0 to 2045 (skip 2046,2047)
-- Increment higher bits (other than lower 2 bits) every 4 ND+CH periods, but 2 periods for 2044/4 to skip the 2046,2047.
    next_cnt1ms := this.cnt1ms + 4;
-- Channel State transition w/ checking 1 ms period (before 1ms counter update)
    -- IDL: Channel is idle.
    -- ACQ: Channel is Acquisition. (send carrier mix data to DSP)
    -- RDY: Channel is Tracking.
    -- VLD: Channel is Tracking, and result is valid.
                  acm_done := false; -- default
                  acm_strt := false; -- default
                  cntl := (vld => '0', ovr => '0', others => false); -- default
    case this.rd is
        when 5 => acm_done := this.ready and this.acm_lst and this.acm_en;
        when 7 => acm_strt := this.ready and this.acm_lst;
        when others =>
    end case;
    this.dma_req(this.dma_req'high) := '0'; -- default
    if acm_done and this.st(ch).run and this.st(ch).mode(2) = '1' then -- TRK
        this.dma_req := '1' & regfile_o.sftca(19 downto 14);
        case this.odd_ms is
            when 1 => this.st(ch).mode(1) := '1'; cntl.vld := '1'; cntl.ovr := this.st(ch).mode(0); -- VLD in odd period
            when 0 => this.st(ch).mode(0) := '1'; cntl.vld := '1'; cntl.ovr := this.st(ch).mode(1); -- VLD in even period
        end case; end if;
    if acm_strt and this.st(ch).mode(2 downto 1) /= "00" then this.st(ch).run := true; end if;
-- Count-up speed of nd and cnt1ms are the same, but cnt1ms skips 2046 and 2047 to count 0 to 2045 (not 2047).
    reg_i.pnco.we := '0';
    stall := false;
    sft_now := to_ufixed(regfile_o.sftca(sft_now'range),sft_now'high,sft_now'low);
    sft_1ms := sft_now(sft_now'high downto sft_now'high - gpsif_cnt1ms_t'high);
    if this.ready then
        if this.rd = GPSIF_RD_MAX then
            this.acm_en := active; -- Skip is done by controlling state (Clearing acm_en is not enough)
            this.acm_lst := acm_lst;
-- Next channel
-- Do extra channel processing if the same scope is to be used for sft -1 correction.
-- register output is not for the extra, it is already for next channel.
            if this.sft.typ /= AGN then this.ch := next_ch; end if; -- use current AGN
            if this.sft.typ = SKP then this.st(ch).run := false; end if;
                                                 this.sft.typ := NOP;
            case this.sft.chg is
                when INC => if this.scp_chg then this.sft.typ := SKP; end if;
                when MNS => if this.scp_chg then this.sft.typ := AGN; end if; reg_i.angle.we := '0'; -- Do next channel twice
                when others =>
            end case;
            if this.sft.typ /= AGN and this.ch = GPSIF_NC_END then -- use next AGN
                if this.nd mod 2 = 1 then this.sft.ext := false; end if; -- clear every 2 ND processing
                this.nd := (this.nd + 1) mod nd_range; -- update input data scope
                if((next_cnt1ms(next_cnt1ms'high) or this.cnt1ms(1)) and this.cnt1ms(0)) = '1' then
                    this.cnt1ms(this.cnt1ms'high downto 2) :=
                    next_cnt1ms(this.cnt1ms'high downto 2); end if;
                this.cnt1ms(1 downto 0) := ((this.cnt1ms(1) xor this.cnt1ms(0)) and not next_cnt1ms(next_cnt1ms'high)) & not this.cnt1ms(0);
                cntl.bndry := (next_cnt1ms(next_cnt1ms'high) and this_r.cnt1ms(0)) = '1';
-- for DEBUG (from here)
                if cntl.bndry and this.odd_ms = 1 then this.dbg2ms := (this.dbg2ms + 1) mod (DBG_2MS_MAX+1); end if; -- count 2ms
-- for DEBUG (to here)
                if cntl.bndry then this.odd_ms := 1 - this.odd_ms; end if; end if;
-- sft_now is used here for the current input scope.
            this.bndry := this.cnt1ms = sft_1ms;
            this.even := this.cnt1ms(0) = sft_1ms(0);
            this.ra := (this.nd * 8 + to_integer(sft_now(2 downto 0))) mod ra_range; -- use next nd
-- Update sft & check input scope change
-- Note: Logic can be simpler by removing INC 1,4, further by removing minus INC logic
            sft_we := false; sft_inc := 1; mns_inc := false; -- default
            case this.st(nn_ch).sft is
                when INC => if this.bndry then -- for serial acquisition
                  case this.inc.sft is
                            when "100" => sft_inc := 4;
                            when "001" => sft_inc := 8;
                            when "010" => sft_inc := 16;
                            when "011" => sft_inc := 24;
                            when "101" => sft_inc := 64 - 24; mns_inc := true;
                            when "110" => sft_inc := 64 - 16; mns_inc := true;
                            when "111" => sft_inc := 64 - 8; mns_inc := true;
                            when others =>
                  end case; sft_we := true; end if;
                when PLS => sft_we := true;
                when MNS => sft_we := true; sft_inc := 64 - 1; mns_inc := true;
                when others =>
            end case;
            sft_nxt_h := sft_now(sft_now'high downto 6);
            sft_nxt_l := sft_now(5 downto 0) + sft_inc;
            if mns_inc then
                   sft_tmp_h := sft_nxt_h + sft_dec_h;
              if sft_nxt_l(6) = '0' then sft_nxt_h := sft_tmp_h(sft_nxt_h'range); -- change higher part
                if sft_tmp_h(sft_tmp_h'high) = '0' then sft_nxt_l := sft_nxt_l(5 downto 0) - 16; end if; end if; -- skip 1023 (2b dec.)
            else sft_tmp_h := sft_nxt_h + 1;
              if ((sft_tmp_h(sft_tmp_h'high) and sft_nxt_l(5) and sft_nxt_l(4)) or sft_nxt_l(6)) = '1'
                                                   then sft_nxt_h := sft_tmp_h(sft_nxt_h'range); -- change higher part
                if sft_tmp_h(sft_tmp_h'high) = '1' then sft_nxt_l := sft_nxt_l(5 downto 0) + 16; end if; end if; -- skip 1023 (2b inc.)
            end if;
            this.scp_chg := sft_nxt_l(5 downto 3) /= sft_now(5 downto 3) and sft_we;
-- Only one extra processing per 7*2 8-cycle is possible. (10 < (125000/1023 - 8*7*2) < 11)
-- Postpone extra processing if another extra processing is already done.
                                                                      this.sft.chg := NOP; -- defaut
            if sft_we then case this.st(nn_ch).sft is
              when INC => this.sft.chg := INC;
              when PLS => stall := true; this.sft.chg := PLS;
              when MNS => if not (this.sft.ext and this.scp_chg) then this.sft.chg := MNS;
                                  this.sft.ext := this.scp_chg or this.sft.ext;
                          else sft_we := false; end if;
              when others =>
            end case; end if;
-- Clear sft state if new sft is written.
            if sft_we then reg_i.sftca.we := '1'; this.st(nn_ch).sft := NOP; end if;
            reg_i.sftca.wd := regfile_o.sftca; -- This is necessary to keep dma info as is.
            reg_i.sftca.wd(sft_now'range) := to_slv(sft_nxt_h) & to_slv(sft_nxt_l(5 downto 0));
-- Update PNCO
            if this.st(n_ch).pnco and this.acm_lst then
               this.st(n_ch).pnco := false;
                                     reg_i.pnco.we := '1';
                                     reg_i.angle.we := '1';
               if ANGLE_INI_OLD then reg_i.angle.wd := reg_i.pnco.wd; -- Angle should be pnco here for old expected values.
                                else reg_i.angle.wd := (others => '0'); end if;
            end if;
        else this.ra := (this.ra + 1) mod ra_range; end if;
             this.rd := (this.rd + 1) mod 8;
    elsif this.sft.chg = PLS then reg_i.angle.we := '1'; end if; -- update during inserted stall
-- Is input data ready ? -------------------------------------------------------
    this.ready := not stall and (wa /= ((this.nd +1) mod nd_range)); -- use next nd
    -- Write pointer wrap round is limited at the last ND states
    -- to avoid overwriting of unused data
    -- This is only for CPU bus input that can be faster than the gpsif.
    -- Direct input never overwrite unused data.
    cntl.lst := this.nd = GPSIF_ND_MAX; -- use next nd
-- CPU bus ---------------------------------------------------------------------
    dbg_r := false; -- defaut (It becomes true if CPU read the debug info. Then the pointer is updated.)
    delta_slv := '0' & not tgt_i.d(delta'high-1)
                     & tgt_i.d(delta'high-2 downto 0);
    reg_i.sftca_obs.ra := vtoui(tgt_i.a(5 downto 2) and ("11" & not to_bit(tgt_i.a(5 downto 4) = "11") & "1")); -- cdef -> cd to avoid out of range
                    wbus_ch := vtoui(tgt_i.a(4 downto 2));
                    rbus_ch := vtoui(tgt_i.a(7 downto 5) and ("11" & not to_bit(tgt_i.a(7 downto 6) = "11"))); -- 67 -> 6
    reg_i.buf.a := rbus_ch*3 +(vtoui(tgt_i.a(4 downto 3) and ( "1" & not tgt_i.a(4) ))); -- 23 -> 2
    reg_i.buf.bs := tgt_i.a(2);
                                                       this.ack := '0'; -- defaut for no bus operation
    if tgt_i.en = '1' and this_r.ack = '0' then this.ack := '1'; -- defaut for bus operation
      if tgt_i.wr = '1' then -- reg write
          case tgt_i.a(8 downto 5) is
            when b"00_00" => if tgt_i.d(tgt_i.d'high) = '0' then
                                if reg_i.sftca.we = '1' then this.ack := '0'; -- delay to avoid port conflict
                                else reg_i.sftca.we := '1';
                                     reg_i.sftca.wd := tgt_i.d(gpsif_sftca_reg_t'range);
                                     reg_i.sftca.wa := wbus_ch + (GPSIF_NC_MAX + 1); end if;
                             end if;
                   sft_chg := gpsif_sft_chg_t'val(vtoui(tgt_i.d(gpsif_sft_fld_t'range)));
                if sft_chg /= NOP then this.st(wbus_ch).sft := sft_chg; end if;
                if tgt_i.d(gpsif_sft_fld_t'low -1) = '1' then this.st(wbus_ch).pnco := true;    end if;
                if tgt_i.d(gpsif_sft_inc_t'high+1) = '1' then this.inc.sft  := tgt_i.d(gpsif_sft_inc_t'range); end if;
                if tgt_i.d(gpsif_pncoinc_t'high+1) = '1' then this.inc.pnco := tgt_i.d(gpsif_pncoinc_t'range); end if;
            when b"00_01" => if reg_i.sftca.we = '1' then this.ack := '0'; -- delay to avoid port conflict
                             else reg_i.sftca.we := '1';
                                  reg_i.sftca.wd := "0111111111" & tgt_i.d(9 downto 0);
                                  reg_i.sftca.wa := wbus_ch;
                               if tgt_i.d(31) = '1' then this.st(wbus_ch).mode := "010"; -- ACQ
                                                        else this.st(wbus_ch).mode := "100"; end if; -- TRK
                                                             this.st(wbus_ch).run := false; end if;
            when b"00_10" => if reg_i.pnco.we = '1' then this.ack := '0'; -- delay to avoid port conflict
                             else reg_i.pnco.we := '1';
                                  reg_i.pnco.wd := delta_slv;
                                  reg_i.pnco.a := wbus_ch;
-- The angle can be any value at init., but must be "delta" for the old expected values.
                                if this_r.st(wbus_ch).mode(2 downto 1) = "00" then -- IDL
                                                        reg_i.angle.a := wbus_ch;
                                                        reg_i.angle.we := '1';
                                  if ANGLE_INI_OLD then reg_i.angle.wd := delta_slv;
                                                   else reg_i.angle.wd := (others => '0'); end if; end if; end if;
            when b"00_11" => if tgt_i.d(31) = '0' then this.rst_en := true;
                              if tgt_i.d(1 downto 0) = "00" then this.src := IO_PIN; -- input from IO pin
                              elsif tgt_i.d(1 downto 0) = "01" then this.src := CPU_BUS; -- input from CPU bus
                              elsif tgt_i.d(1 downto 0) = "10" and tgt_i.d(8) = '0' then this.src := BITL_BUS2; -- input from BL(2b/spl) bus
                              elsif tgt_i.d(1 downto 0) = "10" and tgt_i.d(8) = '1' then this.src := BITL_BUS1; end if; -- input from BL(1b/spl) bus
                             end if;
                             this.int_en := tgt_i.d(5 downto 2);
-- for debug on FPGA (from here)
                             if tgt_i.d(30) = '1' then -- debug enabled
                                this.dbg_strt := vtoui(tgt_i.d(29 downto 6));
                                this.dbg_st := DBG_RDY;
                             end if;
-- for debug on FPGA (to here)
            when others =>
          end case;
      else -- reg read
        -- Clear valid flag after read.
        if tgt_i.a(8) = '1' and tgt_i.a(4 downto 2) = "101" then
               if this.st(rbus_ch).mode(1 downto 0) = "11" then cntl.err := true; end if;
                  this.st(rbus_ch).mode(1 downto 0) := "00"; end if; -- clear VLD
      end if; -- tgt_i.wr
    end if;
    if tgt_i.a(8) = '1' then
      if tgt_i.a(9) = '0' then -- 0x100-1fc
         tgt_rd := (others => regfile_o.buf(regfile_o.buf'high)); -- signed
         tgt_rd(regfile_o.buf'range) := regfile_o.buf;
      else -- --------------- -- 0x300-3fc
         tgt_rd := (others => '0'); -- unsigned -- || 0x300
         tgt_rd(regfile_o.sftca_obsv'range) := regfile_o.sftca_obsv; -- || 0x300
      end if;
-- for debug on FPGA (from here)
    else case tgt_i.a(6 downto 5) is -- read dumped signals
      when "00" => tgt_rd := dbg_rd(0);
      when "01" => tgt_rd := dbg_rd(1);
      when "10" => tgt_rd := dbg_rd(2); dbg_r := this.ack = '1';
      when others =>
    end case;
-- for debug on FPGA (to here)
    end if;
-- Reset -----------------------------------------------------------------------
    if this_r.rst_en then this := GPSIF_REG_RESET;
                                 this.int_en := this_r.int_en;
-- for debug on FPGA (from here)
                                 this.dbg_st := this_r.dbg_st;
                                 this.dbg_strt := this_r.dbg_strt;
-- for debug on FPGA (to here)
      if this_r.src = CPU_BUS then this.src := CPU_BUS; end if;-- input from CPU bus
      if this_r.src = BITL_BUS1 then this.src := BITL_BUS1; end if;-- input from BL(1b)
      if this_r.src = BITL_BUS2 then this.src := BITL_BUS2; end if;-- input from BL(2b)
    end if;
--------------------------------------------------------------------------------
-- connect output
    gpsif_o.cntl <= cntl;
    gpsif_o.odd <= this.odd_ms = 1; -- output before latch
    gpsif_o.rst <= this_r.rst_en;
    gpsif_o.sr <= this_r.st(6).mode(1 downto 0)
                & this_r.st(5).mode(1 downto 0)
                & this_r.st(4).mode(1 downto 0)
                & this_r.st(3).mode(1 downto 0)
                & this_r.st(2).mode(1 downto 0)
                & this_r.st(1).mode(1 downto 0)
                & this_r.st(0).mode(1 downto 0) & '0'
            & to_bit(this_r.st(6).run)
            & to_bit(this_r.st(5).run)
            & to_bit(this_r.st(4).run)
            & to_bit(this_r.st(3).run)
            & to_bit(this_r.st(2).run)
            & to_bit(this_r.st(1).run)
            & to_bit(this_r.st(0).run);
    gpsif_o.int_en<= this_r.int_en;
    gpsif_o.ra <= this_r.ra;
    ra_io.ra <= this_r.ra mod 32;
    ra_io.inittm <= this_r.inittm(0);
    if(this_r.src = BITL_BUS1) then ra_io.blsp1bit <= '1';
                                      else ra_io.blsp1bit <= '0'; end if;
    if(this_r.src = BITL_BUS2) then ra_io.blsp2bit <= '1';
                                      else ra_io.blsp2bit <= '0'; end if;
    tgt_o.d <= tgt_rd;
    tgt_o.ack <= this_r.ack;
    dma.req <= this_r.dma_req;
-- for debug on FPGA (from here)
-- Read the same data until actual read request.
    if this_r.rd = 7 then dbg_b := this.bndry or this.acm_lst; dbg_i := this.sum.i; dbg_q := this.sum.q;
    else dbg_b := false; dbg_i := this.add.i; dbg_q := this.add.q; end if;
    dbg_v := (dbg_b or devo.v or reg_i.angle.we = '1' or this_r.rd = 6) and
                                                         this_r.dbg_st = DBG_RUN;
    if vtoi(itov(this_r.dbg2ms,12) &
            itov(this_r.odd_ms, 1) &
          to_slv(this_r.cnt1ms)) = this_r.dbg_strt
             and this_r.dbg_st = DBG_RDY then this.dbg_st := DBG_RUN; end if;
    if dbg_v or dbg_r then if this.dbg_a = 255 then this.dbg_st := DBG_IDL;
                              this.dbg_a := 0;
                         else this.dbg_a := this.dbg_a +1; end if; end if;
    dbg_a <= itov(this.dbg_a,8);
    dbg_w <= to_bit(dbg_v);
    dbg_wd(0) <= itov(this_r.ra,8)
                & itov(dbg_i,12)
                & itov(dbg_q,12);
    dbg_wd(1) <= buf_bus.d -- & to_bit(devo.v) & devo.d
                & regfile_o.angle(regfile_o.angle'high downto 14)
                & to_slv(this_r.cnt1ms)
                & itov(this_r.rd,3);
    dbg_wd(2) <= reg_i.angle.we & ring_i.stall & ring_o.word.fr & ring_o.word.d
                & itov(this_r.dbg2ms,7) & itov(this_r.odd_ms,1)
-- & itov(this.dbg_a,4)
-- & itov(wa,4)
                & this_r.st(1).mode(1 downto 0)
                & this_r.st(0).mode(1 downto 0)
                & to_bit(this_r.st(1).run)
                & to_bit(this_r.st(0).run)
                & to_bit(dbg_v) & to_bit(dbg_r)
                & this_r.ch
                & to_bit(wa = 0 and this.nd /= GPSIF_ND_MAX);
-- for debug on FPGA (to here)
    regfile_i <= reg_i;
    dev_o <= devo;
    this_c <= this;
  end process;
  p0_r0 : process(clk, rst)
  begin
     if clk = '1' and clk'event then
        if rst = '1' then
           this_r <= GPSIF_REG_RESET;
        else
           this_r <= this_c;
        end if;
     end if;
  end process;
end beh;
