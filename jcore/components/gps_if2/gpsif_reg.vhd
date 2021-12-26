library ieee;
use ieee.std_logic_1164.all;
use work.rf_pack.all;
use work.bist_pack.all;
use work.gpsif_pack.all;
entity gpsif_regfile is port (
  clk : in std_logic;
  rst : in std_logic;
  bi : in bist_scan_t;
  bo : out bist_scan_t;
  a : in gpsif_regfile_i_t;
  y : out gpsif_regfile_o_t);
end gpsif_regfile;
architecture beh of gpsif_regfile is
signal acm_d0 : gpsif_acm_reg_t;
signal acm_d1 : gpsif_acm_reg_t;
signal we0a : std_logic;
signal we1a : std_logic;
signal bs0 : bist_scan_t;
signal bs1 : bist_scan_t;
signal bs2 : bist_scan_t;
signal bs3 : bist_scan_t;
signal bs4 : bist_scan_t;
signal bs5 : bist_scan_t;
signal bs6 : bist_scan_t;
signal buf_d0 : gpsif_acm_reg_t;
signal buf_d1 : gpsif_acm_reg_t;
signal we0b : std_logic;
signal we1b : std_logic;
begin
    sftca_bank : bist_RF1
    generic map ( WIDTH => GPSIF_CA_BITS * 2, DEPTH => (GPSIF_NC_MAX + 1) * 2 )
    port map
     (clk => clk,
      rst => rst,
      bi => bi,
      bo => bs1,
      D => a.sftca.wd,
      WA => a.sftca.wa,
      WE => a.sftca.we,
      RA0 => a.sftca.ra,
      Q0 => y.sftca);
    -- observe sftca ----------
    sftca_observe : bist_RF1
    generic map ( WIDTH => GPSIF_CA_BITS * 2, DEPTH => (GPSIF_NC_MAX + 1) * 2 )
    port map
     (clk => clk,
      rst => rst,
      bi => bi,
      bo => open,
      D => a.sftca.wd,
      WA => a.sftca.wa,
      WE => a.sftca.we,
      RA0 => a.sftca_obs.ra,
      Q0 => y.sftca_obsv);
    pnco_bank : bist_RF1
    generic map ( WIDTH => GPSIF_ANGLE_BITS, DEPTH => GPSIF_NC_MAX + 1 )
    port map
     (clk => clk,
      rst => rst,
      bi => bs1,
      bo => bs2,
      D => a.pnco.wd,
      WA => a.pnco.a,
      WE => a.pnco.we,
      RA0 => a.angle.a,
      Q0 => y.pnco);
    angle_bank : bist_RF1
    generic map ( WIDTH => GPSIF_ANGLE_BITS, DEPTH => GPSIF_NC_MAX + 1 )
    port map
     (clk => clk,
      rst => rst,
      bi => bs2,
      bo => bs3,
      D => a.angle.wd,
      WA => a.angle.a,
      WE => a.angle.we,
      RA0 => a.angle.a,
      Q0 => y.angle);
    we0a <= a.acm.we when (a.acm.bs = '0') else '0';
    we1a <= a.acm.we when (a.acm.bs = '1') else '0';
    we0b <= a.buf.we and a.acm.we when (a.acm.bs = '0') else '0';
    we1b <= a.buf.we and a.acm.we when (a.acm.bs = '1') else '0';
    acm_bank0 : bist_RF1
    generic map ( WIDTH => GPSIF_ACMREG_MAX+1, DEPTH => GPSIF_ACMREG_NUM/2 )
    port map
     (clk => clk,
      rst => rst,
      bi => bs3,
      bo => bs4,
      D => a.acm.wd,
      WA => a.acm.a,
      WE => we0a,
      RA0 => a.acm.a,
      Q0 => acm_d0);
    acm_bank1 : bist_RF1
    generic map ( WIDTH => GPSIF_ACMREG_MAX+1, DEPTH => GPSIF_ACMREG_NUM/2 )
    port map
     (clk => clk,
      rst => rst,
      bi => bs4,
      bo => bs5,
      D => a.acm.wd,
      WA => a.acm.a,
      WE => we1a,
      RA0 => a.acm.a,
      Q0 => acm_d1);
    buf_bank0 : bist_RF1
    generic map ( WIDTH => GPSIF_ACMREG_MAX+1, DEPTH => GPSIF_ACMREG_NUM/2 )
    port map
     (clk => clk,
      rst => rst,
      bi => bs5,
      bo => bs6,
      D => a.buf.wd,
      WA => a.acm.a,
      WE => we0b,
      RA0 => a.buf.a,
      Q0 => buf_d0);
    buf_bank1 : bist_RF1
    generic map ( WIDTH => GPSIF_ACMREG_MAX+1, DEPTH => GPSIF_ACMREG_NUM/2 )
    port map
     (clk => clk,
      rst => rst,
      bi => bs6,
      bo => bo,
      D => a.buf.wd,
      WA => a.acm.a,
      WE => we1b,
      RA0 => a.buf.a,
      Q0 => buf_d1);
-- connect outputs
    y.acm <= acm_d0 when (a.acm.bs = '0') else
             acm_d1 ;
    y.buf <= buf_d0 when (a.buf.bs = '0') else
             buf_d1 ;
end beh;
