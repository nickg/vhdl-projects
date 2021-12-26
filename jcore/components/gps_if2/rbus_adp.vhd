---------------------------- GPS digital part (ring bus adaptor) ----------------------------
-- written on 2016/12/14 by F. Arakawa --
---------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.ring_bus_pack.all;
use work.rbus_pack.all;
entity rbus_adp is
  generic (OWN_CH : integer := RNG_CH_GPS); -- default
  port (clk : in std_logic;
        rst : in std_logic;
-- sw_rst : in boolean;
        ring_i : in rbus_9b;
        ring_o : out rbus_9b;
        dev_o : in rbus_dev_o_t; -- from device
        dev_i : out rbus_dev_i_t); -- to device
end rbus_adp;
architecture beh of rbus_adp is
type rbus_in_t is -- input word type
   (BC, -- input word is BROADCAST cmd
    BSY, -- input word is BUSY cmd
    FW, -- input word is to be forwarded to successor
    WT, -- input word is to be written to device
    DTI);-- input word is data
type rbus_wd_t is (CM, CH, DT); -- command, broadcast channel, or data
type rbus_fwd_t is (FWD, SND); -- forward or send
type rbus_typ_t is array (rbus_in_t range BC to DTI) of boolean;
type rbus_reg_t is record
  snd,rcv : rbus_wd_t;
  fwd : rbus_fwd_t;
  dly,ring_o : rbus_word_9b;
  dly_v : boolean;
end record;
constant rbus_reg_RESET : rbus_reg_t := (
    snd => CM, dly => IDLE_9b, dly_v => false,
    rcv => CM, ring_o => IDLE_9b, fwd => FWD
);
signal this_c : rbus_reg_t;
signal this_r : rbus_reg_t := rbus_reg_RESET;
begin
    p0 : process(this_r,ring_i,dev_o)
    variable this : rbus_reg_t;
    variable dev_dt,cmd_nop,stall_wt,stall_fw,dev_i_v,dev_i_ack : boolean;
    variable typ : rbus_typ_t;
    variable dev_i_wd, dev_o_wd : rbus_word_9b;
    variable cmd : rbus_cmd;
    variable hop : cmd_hops;
    begin
       this := this_r;
-- device output setup ( add fr bit and packet of cmd,hop and channel)
        dev_dt := this.snd = DT and dev_o.v;
        if dev_o.v then case this.snd is
            when CM => dev_o_wd := cmd_word_9b(BROADCAST,1); this.snd := CH;
            when CH => dev_o_wd := data_word_9b(2**dev_o.ch); this.snd := DT;
            when DT => dev_o_wd := data_word_9b(dev_o.d); this.snd := DT;
        end case; else dev_o_wd := data_word_9b(dev_o.d); this.snd := CM; end if;
-- input select
        if this.dly_v then dev_i_wd := this.dly;
        else dev_i_wd := ring_i.word; end if;
-- input cmd type & hop count check
        if dev_i_wd.fr = '1' then
            cmd := to_cmd (dev_i_wd.d);
            hop := to_hops(dev_i_wd.d);
            typ(BC) := cmd = BROADCAST;
            typ(BSY):= cmd = BUSY;
            typ(FW) := cmd /= IDLE and hop/2 /= 0; -- hop>1
            typ(WT) :=((cmd /= IDLE and hop = 1) or typ(BC)); -- hop=1
-- decrement hop after the check
            if hop /= 0 then hop := hop -1; dev_i_wd := cmd_word_9b(cmd,hop); end if;
        else typ := (others => false); end if;
        typ(DTI) := typ(BSY) or dev_i_wd.fr = '0'; -- data words
-- to device (check cmd and channel, and send data)
        dev_i_v := false;
        case this.rcv is
            when CM => if typ(WT) then if typ(BC) then this.rcv := CH;
                                                  else this.rcv := DT; end if; end if;
            when CH => if dev_i_wd.d(OWN_CH)= '1' then this.rcv := DT;
                                                  else this.rcv := CM; end if;
            when DT => if not typ(DTI) then this.rcv := CM; end if;
                       dev_i_v := dev_i_wd.fr = '0'; -- Input is valid data.
        end case;
        stall_wt := dev_i_v and dev_o.bsy; -- So stall occurs if device is busy.
-- to successor
-- output cmd type check
        if this.ring_o.fr = '1' then
             cmd := to_cmd(this.ring_o.d);
             cmd_nop := cmd = IDLE or cmd = BUSY;
        else cmd_nop := false; end if;
-- Toggle output mode if possible: FWD <=> SND
        stall_fw := false;
        dev_i_ack := false;
        if ring_i.stall = '0' or cmd_nop then case this.fwd is -- ring_o can be updated
            when FWD => if typ(DTI) then if stall_wt then this.ring_o := cmd_word_9b(BUSY,0);
                                                       else this.ring_o := dev_i_wd; end if; -- continue
                        elsif dev_o.v then this.fwd := SND; this.ring_o := dev_o_wd; stall_fw := typ(FW); -- mode toggle
                        elsif typ(FW) then this.ring_o := dev_i_wd; -- new forward
                                      else this.fwd := SND; this.ring_o := IDLE_9b; end if; -- send mode check valid
            when SND => if dev_dt then dev_i_ack:=true; this.ring_o := dev_o_wd; stall_fw := typ(FW); -- continue, data is sent
                        elsif typ(FW) then this.fwd := FWD; this.ring_o := dev_i_wd; -- mode toggle
                        elsif dev_o.v then this.fwd := SND; this.ring_o := dev_o_wd; stall_fw := typ(FW); -- new send
                                      else this.ring_o := IDLE_9b; end if; end case;
        else stall_fw := typ(FW); end if; -- to be forwarded, but cannot
-- keep ring_i if it is not used yet
        if not this.dly_v and (stall_wt or stall_fw) then this.dly := ring_i.word; end if;
               this.dly_v := stall_wt or stall_fw;
        dev_i.d <= dev_i_wd.d;
        dev_i.v <= dev_i_v;
        dev_i.ack <= dev_i_ack;
-- SW reset
-- if sw_rst then this := rbus_reg_RESET; end if;
this_c <= this;
    end process;
    p0_r0 : process(clk, rst)
    begin
       if clk = '1' and clk'event then
          if rst = '1' then
             this_r <= rbus_reg_RESET;
          else
             this_r <= this_c;
          end if;
       end if;
    end process;
-- stall ring_i if the previous value is kept in this.dly
    ring_o.stall <= '1' when this_r.dly_v else '0';
    ring_o.word <= this_r.ring_o;
end beh;
