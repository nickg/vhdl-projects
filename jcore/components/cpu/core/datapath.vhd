library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu2j0_pack.all;
use work.cpu2j0_components_pack.all;
use work.datapath_pack.all;
use work.decode_pack.all;
entity datapath is
 port (
       clk : in std_logic;
       rst : in std_logic;
       debug : in std_logic;
       enter_debug : out std_logic;
       slot : out std_logic;
       reg : in reg_ctrl_t;
       func : in func_ctrl_t;
       sr_ctrl : in sr_ctrl_t;
       mac : in mac_ctrl_t;
       mem : in mem_ctrl_t;
       instr : in instr_ctrl_t;
       pc_ctrl : in pc_ctrl_t;
       buses : in buses_ctrl_t;
       coproc : in coproc_ctrl_t;
       db_lock : out std_logic;
       db_o : out cpu_data_o_t;
       db_i : in cpu_data_i_t;
       inst_o : out cpu_instruction_o_t;
       inst_i : in cpu_instruction_i_t;
       debug_o : out cpu_debug_o_t;
       debug_i : in cpu_debug_i_t;
       macin1 : out std_logic_vector(31 downto 0);
       macin2 : out std_logic_vector(31 downto 0);
       mach : in std_logic_vector(31 downto 0);
       macl : in std_logic_vector(31 downto 0);
       mac_s : out std_logic;
       t_bcc : out std_logic;
       ibit : out std_logic_vector(3 downto 0);
       if_dr : out std_logic_vector(15 downto 0);
       if_stall : out std_logic;
       mask_int : out std_logic;
       illegal_delay_slot : out std_logic;
       illegal_instr : out std_logic;
       copreg : in std_logic_vector(7 downto 0);
       cop_i : in cop_i_t;
       cop_o : out cop_o_t
      );
end entity datapath;
architecture stru of datapath is
 subtype reg_t is std_logic_vector(31 downto 0);
 signal gpf_zwd, pc, reg_x, reg_y, reg_0, xbus, ybus, ybus_temp, zbus, wbus : std_logic_vector(31 downto 0);
 signal sr : sr_t;
 signal sfto : std_logic;
 -- alu ports
 signal aluiny, aluinx : std_logic_vector(31 downto 0);
 signal reg_wr_data_o : std_logic_vector(31 downto 0);
 signal ybus_override : bus_val_t;
 signal slot_o : std_logic;
        signal div1_arith_func : arith_func_t;
        signal arith_func : arith_func_t;
        signal arith_out : std_logic_vector(32 downto 0);
        signal logic_out : std_logic_vector(31 downto 0);
 signal this_c : datapath_reg_t;
 signal this_r : datapath_reg_t := DATAPATH_RESET;
        -- The functions to_sr and to_slv convert between the sr record and its CPU register representation.
        function to_sr(a : std_logic_vector(31 downto 0)) return sr_t is
          variable r : sr_t;
        begin
          r.m := a(M); r.q := a(Q); r.int_mask := a(I3 downto I0); r.s := a(S); r.t := a(T);
          return r;
        end to_sr;
        function to_slv(sr : sr_t) return std_logic_vector is
          variable r : std_logic_vector(31 downto 0) := (others => '0');
        begin
          r(M) := sr.m; r(Q) := sr.q; r(I3 downto I0) := sr.int_mask; r(S) := sr.s; r(T) := sr.t;
          return r;
        end to_slv;
 -- A bit vector from a single bit
 function to_slv(b : std_logic; s : integer) return std_logic_vector is
   variable r : std_logic_vector(s-1 downto 0);
 begin
   r := (others => b);
 return r;
 end to_slv;
        function to_data_o(mem : mem_ctrl_t; coproc : coproc_ctrl_t;
                           addr : std_logic_vector(31 downto 0);
                           data : std_logic_vector(31 downto 0))
        return cpu_data_o_t is
          variable r : cpu_data_o_t := NULL_DATA_O;
        begin
          if mem.issue = '1' then
            r.en := '1';
            r.wr := mem.wr;
            r.rd := not mem.wr;
            r.a := addr;
            -- for writes, prepare we and d signals
            if mem.wr = '1' then
              case mem.size is
                when LONG =>
                  r.d := data; r.we := "1111";
                when WORD =>
                  if addr(1) = '0' then r.we := "1100";
                  else r.we := "0011"; end if;
                  r.d := data(15 downto 0) & data(15 downto 0);
                when BYTE =>
                  -- TODO: Use shift or rotate operator instead of case?
                  case addr(1 downto 0) is
                    when "00" => r.we := "1000";
                    when "01" => r.we := "0100";
                    when "10" => r.we := "0010";
                    when others => r.we := "0001";
                  end case;
                  r.d := data(7 downto 0) & data(7 downto 0) & data(7 downto 0) & data(7 downto 0);
              end case;
            end if;
          elsif coproc.coproc_cmd = LDS then
                  r.d := data;
          end if;
          return r;
        end to_data_o;
        function to_inst_o(instr : instr_ctrl_t; addr : std_logic_vector(31 downto 0);
                           -- default to jump=1 unless caller knows address is incremented PC
                           jp : std_logic := '1')
        return cpu_instruction_o_t is
          variable r : cpu_instruction_o_t := NULL_INST_O;
        begin
          if instr.issue = '1' then
            r.en := '1';
            r.a := addr(31 downto 1);
            r.jp := jp;
          end if;
          return r;
        end to_inst_o;
        function align_read_data(d : std_logic_vector(31 downto 0); bus_o : cpu_data_o_t; size : mem_size_t)
        return std_logic_vector is
          variable r : std_logic_vector(31 downto 0);
        begin
          case size is
            when BYTE =>
              case bus_o.a(1 downto 0) is
                when "00" => r := to_slv(d(31), 24) & d(31 downto 24);
                when "01" => r := to_slv(d(23), 24) & d(23 downto 16);
                when "10" => r := to_slv(d(15), 24) & d(15 downto 8);
                when others => r := to_slv(d( 7), 24) & d( 7 downto 0);
              end case;
            when WORD =>
              case bus_o.a(1) is
                when '0' => r := to_slv(d(31), 16) & d(31 downto 16);
                when others => r := to_slv(d(15), 16) & d(15 downto 0);
              end case;
            when others => r := d;
          end case;
          return r;
        end align_read_data;
begin
 -- Multiplexors for the internal buses
 with buses.x_sel select xbus <= reg_x when SEL_REG, pc when SEL_PC, buses.imm_val when others;
 with buses.y_sel select ybus_temp <= reg_y when SEL_REG, pc when SEL_PC, mach when SEL_MACH, macl when SEL_MACL, to_slv(sr) when SEL_SR, buses.imm_val when others;
 ybus <= ybus_override.d when ybus_override.en = '1' else ybus_temp;
 gpf_zwd <= pc when pc_ctrl.wrpr = '1' else zbus;
 u_regfile : register_file
          generic map (ADDR_WIDTH => 5,
                       NUM_REGS => 21,
                       REG_WIDTH => 32)
          port map(clk => clk, rst => rst, ce => slot_o, addr_ra => reg.num_x, dout_a => reg_x,
                   addr_rb => reg.num_y, dout_b => reg_y, dout_0 => reg_0,
                   we_wb => reg.wr_w, w_addr_wb => reg.num_w, din_wb => wbus,
                   we_ex => reg.wr_z, w_addr_ex => reg.num_z, din_ex => gpf_zwd,
                   wr_data_o => reg_wr_data_o);
-- setup arithmetic inputs function
 with func.alu.inx_sel select
   aluinx <= xbus(31 downto 2) & "00" when SEL_FC,
             xbus(30 downto 0) & sr.t when SEL_ROTCL, -- used for DIV1
                    (others => '0') when SEL_ZERO,
                    xbus when others;
 with func.alu.iny_sel select
   aluiny <= buses.imm_val when SEL_IMM,
             reg_0 when SEL_R0,
      ybus when others;
        -- DIV1 decides the arith function at runtime based on m=q. Override
        -- the arith func set by decoder when DIV1.
        div1_arith_func <= SUB when sr.m = sr.q else ADD;
        arith_func <= div1_arith_func when func.arith.sr = DIV1 else func.arith.func;
        arith_out <= arith_unit(aluinx, aluiny, arith_func, func.arith.ci_en and sr.t);
        logic_out <= logic_unit(aluinx, aluiny, func.logic_func);
        with buses.z_sel select zbus <=
          arith_out(31 downto 0) when SEL_ARITH,
          logic_out when SEL_LOGIC,
          bshifter(xbus, ybus(31) & ybus(4 downto 0),
                   sr.t, func.shift) when SEL_SHIFT,
          manip(xbus, ybus, func.alu.manip) when SEL_MANIP,
          ybus when SEL_YBUS,
          wbus when SEL_WBUS;
 sfto <= xbus(xbus'left) when ybus(31) = '0' else xbus(xbus'right);
 with mac.sel1 select macin1 <= xbus when SEL_XBUS, zbus when SEL_ZBUS, wbus when others;
 with mac.sel2 select macin2 <= ybus when SEL_YBUS, zbus when SEL_ZBUS, wbus when others;
 ibit <= sr.int_mask;
 datapath : process(this_r,pc_ctrl,wbus,zbus,sr_ctrl, xbus, ybus, mac,mem, instr, db_i, inst_i, debug, debug_i,reg_wr_data_o, logic_out, arith_out, arith_func, func, sfto, coproc, cop_i)
   variable this : datapath_reg_t;
          variable if_ad : std_logic_vector(31 downto 0);
          variable ma_ad, ma_dw : std_logic_vector(31 downto 0);
          variable next_state : debug_state_t;
        begin
           this := this_r;
          this.debug_o.ack := '0';
          next_state := this.debug_state;
          if this.old_debug = '0' and debug = '1' and -- debug input rose
                                                      -- meaning BREAK
                                                      -- instruction ran
            (this.debug_state = RUN or this.debug_state = AWAIT_BREAK) then
            next_state := AWAIT_IF;
            -- stop requesting debug mode once we're in debug mode
            this.enter_debug := (others => '0');
          elsif this.debug_state = RUN and debug_i.en = '1' and debug_i.cmd = BREAK then
            -- schedule entering debug mode
            -- TODO: we could probably set enter_debug(0) = '1' to
            -- immediately enter, but need to be careful that mask_int is
            -- set early enough to avoid an interrupt during debugging.
            this.enter_debug(this.enter_debug'left) := '1';
            next_state := AWAIT_BREAK;
          end if;
          this.old_debug := debug;
          -- check if data bus transaction finished
          if this.data_o.en = '1' and db_i.ack = '1' then
            -- FIXME: Drop en, unless keep_cyc='1'
            this.m_dr_next := align_read_data(db_i.d, this.data_o, this.data_o_size);
            this.m_en := '1';
            this.data_o := NULL_DATA_O;
          end if;
          -- check if instruction bus transaction finished
          if this.inst_o.en = '1' and inst_i.ack = '1' then
            this.if_dr_next := inst_i.d;
            this.if_en := '1';
            this.inst_o := NULL_INST_O;
          elsif this.debug_state = READY and debug_i.en = '1' then
            -- handle debug command
            case debug_i.cmd is
              when BREAK =>
                -- A BREAK cmd when already in the READY state does nothing
                this.debug_o.ack := '1';
              when INSERT =>
                -- use the instruction from the debug register
                this.if_dr_next := debug_i.ir;
                this.if_en := '1';
                this.stop_pc_inc := '1';
                -- latch the y-bus override into start of pipeline
                this.ybus_override(this.ybus_override'left) := ( en => debug_i.d_en, d => debug_i.d );
                -- await instruction fetch before processing next debug command
                next_state := AWAIT_IF;
              when STEP =>
                -- fetch a real instruction to execute next
                this.inst_o := to_inst_o(instr, this.pc);
                -- leave debug mode but schedule an enter_debug to get back into debug mode
                this.enter_debug(this.enter_debug'left) := '1';
                next_state := AWAIT_BREAK;
              when CONTINUE =>
                -- fetch a real instruction to execute next
                this.inst_o := to_inst_o(instr, this.pc);
                this.enter_debug(this.enter_debug'left) := '0';
                next_state := RUN;
            end case;
          end if;
          if this.stop_pc_inc = '1' then
            this.pc_inc := this.pc;
          end if;
          if this.slot = '1' then
            -- Shift enter_debug pipeline along. The left-most bit is duplicated.
            -- The right-most bit becomes the enter_debug output.
            this.enter_debug := this.enter_debug(this.enter_debug'left) &
                                this.enter_debug(this.enter_debug'left downto 1);
          end if;
          if this.data_o.en = '0' and this.inst_o.en = '0' and this.debug_state /= READY then
            -- present data read by completed transactions
            if this.m_en = '1' then
              this.m_dr := this.m_dr_next;
              this.m_en := '0';
            elsif coproc.cpu_data_mux /= DBUS then
              this.m_dr := cop_i.d;
            end if;
            if this.if_en = '1' then
              this.if_dr := this.if_dr_next;
              this.illegal_delay_slot := check_illegal_delay_slot(this.if_dr);
              this.illegal_instr := check_illegal_instruction(this.if_dr);
              this.if_en := '0';
            end if;
            this.slot := '1';
          else
            -- Slot is output as a combinatorial signal. Other blocks use it to
            -- determine if a rising clock edge is the start of a new CPU slot
            -- or whether the current slot is stretched into the next cycle.
            this.slot := '0';
          end if;
          if this.slot = '1' then
            -- start new memory transactions
            if (mem.issue = '1' and this.data_o.en = '0') or
               (coproc.coproc_cmd = LDS) then
              -- start new data request
              case mem.addr_sel is
                when SEL_XBUS => ma_ad := xbus;
                when SEL_YBUS => ma_ad := ybus;
                when SEL_ZBUS => ma_ad := zbus;
              end case;
              case mem.wdata_sel is
                when SEL_YBUS => ma_dw := ybus;
                when SEL_ZBUS => ma_dw := zbus;
              end case;
              this.data_o_size := mem.size;
              this.data_o := to_data_o(mem, coproc, ma_ad, ma_dw);
            end if;
            if instr.issue = '1' then
              if this.debug_state = RUN or this.debug_state = AWAIT_BREAK then
                if this.inst_o.en = '0' then
                  -- start new instruction request
                  if instr.addr_sel = '0' then if_ad := this.pc_inc;
                  else if_ad := zbus;
                  end if;
                  this.inst_o := to_inst_o(instr, if_ad, instr.addr_sel);
                end if;
              elsif this.debug_state = AWAIT_IF or next_state = AWAIT_IF then
                -- In debug mode, an instruction fetch issue is our signal to
                -- pause the CPU. Later we will either allow the instruction
                -- fetch from memory to proceed or we'll insert an instruction.
                -- Also check for next_state=AWAIT_IF to skip AWAIT_IF state
                -- when decoder is already requesting an instruction.
                next_state := READY;
                -- Move y-bus override through its pipeline to use in EX
                -- stage. Currently the pipeline is short such that the INSERT
                -- value used in an instruction has to come in the subsequent
                -- INSERT command. Will likely increase pipeline size.
                for i in 1 to this.ybus_override'left loop
                  this.ybus_override(i-1) := this.ybus_override(i);
                end loop;
                this.ybus_override(this.ybus_override'left) := BUS_VAL_RESET;
              end if;
            end if;
            -- update PC
            if pc_ctrl.wr_z = '1' then this.pc := zbus;
            elsif pc_ctrl.inc = '1' then this.pc := this.pc_inc; end if;
            -- update SR
            case sr_ctrl.sel is
              when SEL_PREV =>
                -- leave sr unchanged
              when SEL_WBUS =>
                this.sr := to_sr(wbus);
              when SEL_ZBUS =>
                this.sr := to_sr(zbus);
              when SEL_DIV0U =>
                this.sr.m := '0';
                this.sr.q := '0';
                this.sr.t := '0';
              when SEL_ARITH =>
                this.sr := arith_update_sr(
                  this.sr,
                  -- although it feels like aluinx and aluiny have the proper
                  -- MSB bits here, for DIV1 aluinx has already been shifted
                  -- left one and the MSB we want is lost. Use xbus instead
                  -- (and use ybus for symmetry).
                  -- aluinx(aluinx'left),
                  -- aluiny(aluiny'left),
                  xbus(xbus'left),
                  ybus(ybus'left),
                  arith_out(31 downto 0),
                  arith_out(arith_out'left),
                  arith_func,
                  func.arith.sr);
              when SEL_LOGIC =>
                this.sr := logic_update_sr(this.sr, logic_out, func.logic_sr);
              when SEL_INT_MASK =>
                this.sr.int_mask := sr_ctrl.ilevel;
              when SEL_SET_T =>
                -- leave most of sr unchanged, but set the T bit
                case sr_ctrl.t is
                  when SEL_CLEAR =>
                    this.sr.t := '0';
                  when SEL_SET =>
                    this.sr.t := '1';
                  when SEL_SHIFT =>
                    this.sr.t := sfto;
                  when SEL_CARRY =>
                    this.sr.t := arith_out(arith_out'left);
                end case;
            end case;
            if mac.s_latch = '1' then this.mac_s := this.sr.s; end if;
            this.data_o_lock := mem.lock;
          end if;
          this.pc_inc := std_logic_vector(unsigned(this.pc)+2);
          -- all debug commands are ACKed when either the RUN or READY state are
          -- reached.
          if (next_state = RUN or next_state = READY) then
            if this.debug_o.ack = '0' and debug_i.en = '1' then
              if debug_i.cmd = INSERT then
                -- latch the value being written to the register file for the debug
                -- output.
                this.debug_o.d := reg_wr_data_o;
              else
                -- latch the PC value to simplify debugging and profiling.
                -- Without this multiple inserts, including a JSR and RTS are
                -- needed to get the PC.
                this.debug_o.d := this.pc;
              end if;
            end if;
            this.debug_o.ack := debug_i.en;
            this.stop_pc_inc := '0';
          end if;
          this.debug_state := next_state;
          if this.debug_state = READY then
            this.debug_o.rdy := '1';
          else
            this.debug_o.rdy := '0';
          end if;
          this_c <= this;
 end process;
 datapath_r0 : process(clk, rst)
 begin
    if rst='1' then
       this_r <= DATAPATH_RESET;
    elsif clk='1' and clk'event then
       this_r <= this_c;
    end if;
 end process;
 pc <= this_r.pc;
 sr <= this_r.sr;
 mac_s <= this_r.mac_s;
        db_lock <= this_r.data_o_lock;
        db_o <= this_r.data_o;
        inst_o <= this_r.inst_o;
        if_dr <= this_r.if_dr;
        illegal_delay_slot <= this_r.illegal_delay_slot;
        illegal_instr <= this_r.illegal_instr;
        cop_o.rna <= copreg(7 downto 4);
        cop_o.rnb <= copreg(3 downto 0);
        cop_o.op <= "11101" when coproc.coproc_cmd = LDS else
                    "11111" when coproc.coproc_cmd = STS else
                    "10001" when coproc.coproc_cmd = CLDS else
                    "10000" when coproc.coproc_cmd = CSTS else
                    "00000";
        cop_o.en <= '0' when coproc.coproc_cmd = NOP else '1';
        cop_o.stallcp <= not slot_o;
        cop_o.d <= this_r.data_o.d;
        wbus <= this_r.m_dr;
        slot_o <= this_c.slot;
        -- Need to output T combinatorially so that decoder can make
        -- conditional branch decisions
        t_bcc <= this_c.sr.t;
        enter_debug <= this_r.enter_debug(0);
        mask_int <= '0' when this_r.debug_state = RUN and this_r.enter_debug = (this_r.enter_debug'range => '0') else '1';
        debug_o <= this_c.debug_o;
        ybus_override <= this_r.ybus_override(0);
        if_stall <= '0';
        slot <= slot_o;
end architecture stru;
