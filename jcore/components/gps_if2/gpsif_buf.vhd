library ieee;
use ieee.std_logic_1164.all;
use work.gpsif_pack.all;
entity gpsif_buf is port (
   clk : in std_logic;
   rst : in std_logic;
   -- port
   gps_clk : in std_logic;
   gps_d : in std_logic_vector(1 downto 0);
   a : in gpsif_buf_ct_t;
   y : out gpsif_buf_i_t;
   waf : out gpsif_buf_rw_t );
end gpsif_buf;
architecture beh of gpsif_buf is
    signal this_c : gpsif_buf_reg_t ;
    signal this_r : gpsif_buf_reg_t := gpsif_buf_reg_RESET;
    signal this_sync_c : gpsif_buf_sync_t;
    signal this_sync_r : gpsif_buf_sync_t := gpsif_buf_sync_RESET;
begin
    pi : process(this_r,gps_d)
    variable wa : integer range 0 to 31;
    variable this : gpsif_buf_reg_t ;
    begin
       this := this_r;
        case this.wa/8 is -- MS 2 bits: 00=>01=>10=>11
            when 2 => wa := 24 + (this.wa mod 8);
            when 3 => wa := 16 + (this.wa mod 8);
            when others => wa := this.wa;
        end case;
        this.d(wa) := gps_d;
        case this.wa is -- MS 2 bits: 00=>01=>11=>10
            when 15 => this.wa := 24;
            when 31 => this.wa := 16;
            when 23 => this.wa := 0;
            when others => this.wa := (this.wa + 1) mod 32;
        end case;
        this_c <= this;
    end process;
    pi_r0 : process(gps_clk, rst)
    begin
       if gps_clk = '1' and gps_clk'event then
          if rst = '1' then
             this_r <= gpsif_buf_reg_RESET;
          else
             this_r <= this_c;
          end if;
       end if;
    end process;
    po : process(this_sync_r,this_r)
    variable wa : integer range 0 to 3;
    variable this_sync : gpsif_buf_sync_t;
    begin
       this_sync := this_sync_r;
        case this_sync.wa_out is
            when 2 => wa := 3;
            when 3 => wa := 2;
            when others => wa := this_sync.wa_out;
        end case;
        this_sync.wa_out := this_sync.wa_dly;
        this_sync.wa_dly := this_r.wa/8; -- other than lower 3 bits
        y.wa <= wa;
        this_sync_c <= this_sync;
    end process;
    po_r0 : process(clk, rst)
    begin
       if clk = '1' and clk'event then
          if rst = '1' then
             this_sync_r <= gpsif_buf_sync_RESET;
          else
             this_sync_r <= this_sync_c;
          end if;
       end if;
    end process;
   -- connect outputs
    y.d <= this_r.d(a.ra); -- data specified by a is stable
    waf <= this_r.wa;
end beh;
