library ieee;
use ieee.std_logic_1164.all;
use work.fixed_pkg.all;
use ieee.numeric_std.all;
use work.gpsif_pack.all;
use work.gpsif_sub_pack.all;
use work.rf_pack.all;
use work.bist_pack.all;
entity gpsif_time is port (
   clk : in std_logic;
   rst : in std_logic;
   -- port
   gps_clk : in std_logic;
   gps_d : in std_logic_vector(1 downto 0);
   a : in gpsif_buf_ct_t;
   waf : in gpsif_buf_rw_t;
   blgps : in blgps_t;
   ppsdds : in std_logic;
   y : out gpsif_time_t );
end gpsif_time;
architecture beh of gpsif_time is
    signal this_c : gpsif_time_reg_t ;
    signal this_r : gpsif_time_reg_t := gpsif_time_reg_RESET;
    signal this_sync_c : gpsif_time_sync_t;
    signal this_sync_r : gpsif_time_sync_t := gpsif_time_sync_RESET;
    signal a_ra_mod_8 : integer range 0 to 7 := 0;
    signal a_ra_mod_16 : integer range 0 to 15 := 0;
    signal regf_rd : std_logic_vector(15 downto 0);
    signal regf_ra : integer range 0 to 31 := 0;
begin
    pg : process(this_r,this_sync_r,gps_d,a,waf,ppsdds)
    variable nsec_upcond_60 : boolean;
    variable nsec_upcond_61 : boolean;
    variable nsec_upcond_62 : boolean;
    variable incr_cnt1ms : ufixed(gpsif_cnt1ms_t'high+1 downto 0);
    variable this : gpsif_time_reg_t ;
    begin
       this := this_r;
        if(this.rt.pps_dly(2) /= this.rt.pps_dly(1)) then
            this.rt.nsec_cap := this.rt.nsec;
        end if;
        this.rt.pps_dly := this.rt.pps_dly(2 downto 0) & ppsdds;
        nsec_upcond_60 := false;
        nsec_upcond_61 := false;
        nsec_upcond_62 := false;
        if (this.rt.round_s = 0) or (this.rt.round_s = 10) then
            if(this.rt.round_l = 1) then
                 nsec_upcond_61 := true;
            else nsec_upcond_62 := true; end if;
        else
            if(this.rt.round_l = 1) then
                 nsec_upcond_60 := true;
            else nsec_upcond_61 := true; end if;
        end if;
        -- reset command from clk_sys domain ,
        -- reset value = 61.09481 * (34 * 8 + 4) = 16862.217 [ns]
        -- clk_sys side 32 x gps_clk, gps_clk side 34 x gps_clk
        if(this.rt.inittm = '1') and ((waf mod 8) = 3) then
                                   this.rt.nsec := to_unsigned(16862, 24);
                                       -- reset gps_is2 sys_clk engine
        elsif(waf mod 8 = 7) and
             (std_logic_vector(this.rt.cnt1ms_g) = "111" & x"fd") then
                                   this.rt.nsec := (others => '0');
                                       -- 1ms boundary
        elsif(nsec_upcond_62) then this.rt.nsec := this.rt.nsec + 62;
        elsif(nsec_upcond_61) then this.rt.nsec := this.rt.nsec + 61;
        else this.rt.nsec := this.rt.nsec + 60;
        end if;
        case this.rt.round_s is
            when 20 => this.rt.round_s := 0;
            when others => this.rt.round_s := this.rt.round_s + 1;
        end case;
        case this.rt.round_l is
            when 2386 => this.rt.round_l := 0;
            when others => this.rt.round_l := this.rt.round_l + 1;
        end case;
        -- math -- (61 + 2/21 - 1/2387) = (1e6 / 16368)
        -- -- hint : 16368 = (16 * 3 * 341)
        -- 1023 counter (nsec count and 1ms count = dual counter) --
        if(this.rt.inittm = '1') and ((waf mod 8) = 3) then
                 this.rt.cnt1ms_g := (5 => '1', 1 => '1', others => '0');
                                 -- | |
                                 -- memo 2^5 + 2^1 = hex 22 (dec 34)
        elsif(waf mod 8 = 7) then
            if(std_logic_vector(this.rt.cnt1ms_g) = "111" & x"fd") then
                 this.rt.cnt1ms_g := (others => '0');
                 this.rt.cnt1msup_g := not this.rt.cnt1msup_g;
            else incr_cnt1ms := this.rt.cnt1ms_g + 1;
                 this.rt.cnt1ms_g := incr_cnt1ms(gpsif_cnt1ms_t'high downto 0);
            end if;
        end if;
        this.rt.inittm := a.inittm;
        this_c <= this;
    end process;
    pg_r0 : process(gps_clk, rst)
    begin
       if gps_clk = '1' and gps_clk'event then
          if rst = '1' then
             this_r <= gpsif_time_reg_RESET;
          else
             this_r <= this_c;
          end if;
       end if;
    end process;
    r : bist_RF1
    generic map ( WIDTH => 16, DEPTH => 32 )
      port map
       (clk => clk,
        rst => rst,
        bi => ( ctrl => '0', d => '0', en => '0', bist => '0', cmd => "00"),
        bo => open,
        D => this_sync_r.packetwd,
        WA => this_sync_r.packetwa,
        WE => this_sync_r.packetwe,
        RA0 => regf_ra,
        Q0 => regf_rd);
    a_ra_mod_8 <= a.ra mod 8;
    a_ra_mod_16 <= a.ra mod 16;
    ps : process(this_sync_r,this_r, a, blgps)
    variable nsec_upcond_60 : boolean;
    variable nsec_upcond_61 : boolean;
    variable nsec_upcond_62 : boolean;
    variable incr_cnt1ms : ufixed(gpsif_cnt1ms_t'high+1 downto 0);
    variable wa_comm_cntup : std_logic;
    variable this_sync : gpsif_time_sync_t;
    begin
       this_sync := this_sync_r;
        if(a.blsp1bit = '0') and (a.blsp2bit = '0') then -- pin direct case
          if(this_sync.ppss_dly(1) /=
             this_sync.ppss_dly(2)) then
            this_sync.nsec := this_r.rt.nsec_cap;
            this_sync.cnt1msup_g := this_r.rt.cnt1msup_g;
            this_sync.setnsec := '1';
          else
            this_sync.setnsec := '0';
          end if;
        else -- <-> if{(a.blsp1bit = '1') or (a.blsp2bit = '1')}
                                                       -- GPS over bitlink case
          if(blgps.en = '1') and (blgps.a = "000010") and
            (blgps.tick = '1') then
            this_sync.nsec := this_sync.rt.nsec;
            this_sync.cnt1msup_g := this_sync.rt.cnt1msup_g;
            this_sync.setnsec := '1';
          else
            this_sync.setnsec := '0';
          end if;
        end if;
        this_sync.ppss_dly :=
        this_sync.ppss_dly(1 downto 0) & this_r.rt.pps_dly(3);
        nsec_upcond_60 := false;
        nsec_upcond_61 := false;
        nsec_upcond_62 := false;
        if (this_sync.rt.round_s = 0) or (this_sync.rt.round_s = 10) then
            if(this_sync.rt.round_l = 1) then
                 nsec_upcond_61 := true;
            else nsec_upcond_62 := true; end if;
        else
            if(this_sync.rt.round_l = 1) then
                 nsec_upcond_60 := true;
            else nsec_upcond_61 := true; end if;
        end if;
        this_sync.packetwa := to_integer(unsigned(blgps.a(5 downto 1)));
        if(blgps.en = '1') then
          if (blgps.a(0) = '0') then
               this_sync.packetwd(15 downto 8) := blgps.d;
          else this_sync.packetwd( 7 downto 0) := blgps.d; end if;
        end if;
        if(blgps.en = '1') and (blgps.a(0) = '1') then
             this_sync.packetwe := '1';
        else this_sync.packetwe := '0';
        end if;
        -- regfile read address (from a.ra and this_sync.wa_comm)
        if ((((a.ra / 8) mod 4) = 1) and (this_sync.wa_comm mod 4 < 1)) or
           ((((a.ra / 8) mod 4) = 2) and (this_sync.wa_comm mod 4 < 2)) or
           ((((a.ra / 8) mod 4) = 3) and (this_sync.wa_comm mod 4 < 3)) then
          if (a.blsp1bit = '0') then
            regf_ra <= ((this_sync.wa_comm / 4) * 4 + (a.ra / 8) + 28) mod 32;
          else
            regf_ra <= ((this_sync.wa_comm / 4) * 2 + (a.ra / 16) + 30) mod 32;
          end if;
        else
          if (a.blsp1bit = '0') then
            regf_ra <= ((this_sync.wa_comm / 4) * 4 + (a.ra / 8) ) mod 32;
          else
            regf_ra <= ((this_sync.wa_comm / 4) * 2 + (a.ra / 16) ) mod 32;
          end if;
        end if;
        -- wa_comm state machine
        wa_comm_cntup := '0';
        if(blgps.en = '1') and (blgps.a = "000000") then
                  this_sync.wa_comm := 0;
                  this_sync.wa_commwait := 0;
                  if(this_sync.pon_state = '1') then
                    this_sync.pon_state := '0';
                  else
                    wa_comm_cntup := '1'; end if;
        elsif(this_sync.wa_commwait = 42) then
               -- gps over bitlink, magic number 5ch * 8cycl + other 2cyc = 42
                  this_sync.wa_comm := this_sync.wa_comm + 1;
                  this_sync.wa_commwait := 0;
            if((this_sync_r.wa_comm /= 31) and (a.blsp1bit = '0')) or
              ((this_sync_r.wa_comm /= 63) and (a.blsp1bit = '1')) then
                  wa_comm_cntup := '1';
            end if;
        elsif( this_sync.wa_comm = 64) or
             ((this_sync.wa_comm = 32) and (a.blsp1bit = '0')) then
          -- no count up
        else -- update wait
          if(this_sync.wa_commwait = 63) then
                  this_sync.wa_commwait := 0;
          else this_sync.wa_commwait := this_sync.wa_commwait + 1; end if;
        end if;
        if(a.inittm = '1') and (this_sync_r.wa_commwait = 39) then
            this_sync.inittmc1(0) := '1';
            this_sync.inittmc2 := this_sync_r.wa_comm;
        elsif(blgps.en = '1') and (blgps.a = "000000") then
            this_sync.inittmc1(1 downto 0) :=
            this_sync.inittmc1(0) & '0';
        end if;
-- if(blgps.en = '1') and (blgps.a(0) = '0') then
        if(wa_comm_cntup = '1') then
        -- reset command from clk_sys domain ,
        -- reset value = 61.09481 * (35 * 8 + 0) = 17106.549 [ns]
        -- -> nearest 8ns x n -> 17104 [ns ] (2138 * 8)
          if(this_sync.inittmc3 = '1') then
                                   this_sync.rt.nsec := to_unsigned(17104, 24);
                                         -- reset gps_is2 sys_clk engine
          elsif(this_sync.rt.nsec > 999295) then
                              -- dec999296 = 0xfcf80 -- 1ms boundary
                                   this_sync.rt.nsec := (others => '0');
          elsif(nsec_upcond_62) then
               this_sync.rt.nsec := this_sync.rt.nsec + 62 * 8;
          elsif(nsec_upcond_61) then
               this_sync.rt.nsec := this_sync.rt.nsec + 61 * 8;
          else this_sync.rt.nsec := this_sync.rt.nsec + 60 * 8;
          end if;
          -- 1023 counter (nsec count and 1ms count = dual counter) --
          if(this_sync.inittmc3 = '1') then
                   this_sync.rt.cnt1ms_g := (5 => '1', 1 => '1', 0 => '1',
                                            others => '0');
                                   -- | |
                              -- memo 2^5 + 2^1 + 2^0= hex 23 (dec 35)
          else
              if(std_logic_vector(this_sync.rt.cnt1ms_g) = "111" & x"fd") then
                   this_sync.rt.cnt1ms_g := (others => '0');
                   this_sync.rt.cnt1msup_g := not this_sync.rt.cnt1msup_g;
              else incr_cnt1ms := this_sync.rt.cnt1ms_g + 1;
                   this_sync.rt.cnt1ms_g := incr_cnt1ms(gpsif_cnt1ms_t'high downto 0);
              end if;
          end if;
          case this_sync.rt.round_s is
              when 20 => this_sync.rt.round_s := 0;
              when others => this_sync.rt.round_s := this_sync.rt.round_s + 1;
          end case;
          case this_sync.rt.round_l is
              when 2386 => this_sync.rt.round_l := 0;
              when others => this_sync.rt.round_l := this_sync.rt.round_l + 1;
          end case;
        end if;
        if(this_sync_r.wa_commwait = 39) then
            this_sync.inittmc3 := a.inittm;
        end if;
this_sync_c <= this_sync;
    end process;
    ps_r0 : process(clk, rst)
    begin
       if clk = '1' and clk'event then
          if rst = '1' then
             this_sync_r <= gpsif_time_sync_RESET;
          else
             this_sync_r <= this_sync_c;
          end if;
       end if;
    end process;
   -- connect outputs
    y.nsec <= this_sync_r.nsec;
    y.seq <= (others => '0');
    y.mscnt <= this_sync_r.cnt1msup_g;
    y.setnsec <= this_sync_r.setnsec;
    y.d <= regf_rd((15 - 2 * a_ra_mod_8) downto
                         (14 - 2 * a_ra_mod_8))
                 when (a.blsp1bit = '0') else
                 (regf_rd(15 - a_ra_mod_16) & "0"); -- 1b form -> 2b form
    y.wa <= this_sync_r.wa_comm mod 4;
end beh;
