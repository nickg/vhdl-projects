library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decode_pack.all;
use work.cpu2j0_pack.all;
entity decode_core is
  generic (
    decode_type : cpu_decode_type_t;
    reset_vector : decode_core_reg_t);
  port (
    clk : in std_logic;
    delay_jump : in std_logic;
    dispatch : in std_logic;
    event_ack_0 : in std_logic;
    event_i : in cpu_event_i_t;
    ex : in pipeline_ex_t;
    ex_stall : in pipeline_ex_stall_t;
    ibit : in std_logic_vector(3 downto 0);
    id : in pipeline_id_t;
    if_dr : in std_logic_vector(15 downto 0);
    if_stall : in std_logic;
    ilevel_cap : in std_logic;
    illegal_delay_slot : in std_logic;
    illegal_instr : in std_logic;
    mac_busy : in std_logic;
    mac_stall_sense : in std_logic;
    maskint_next : in std_logic;
    p : in pipeline_t;
    rst : in std_logic;
    slot : in std_logic;
    t_bcc : in std_logic;
    debug : in std_logic;
    enter_debug : in std_logic;
    event_ack : out std_logic;
    if_issue : out std_logic;
    ifadsel : out std_logic;
    ilevel : out std_logic_vector(3 downto 0);
    incpc : out std_logic;
    op : out operation_t;
    next_id_stall : out std_logic
    );
end;
architecture arch of decode_core is
  signal mac_stall : std_logic;
  signal reg_conf : std_logic;
  signal next_op : operation_t;
  signal instr_state_sel : std_logic;
  signal next_id_stall_a : std_logic;
  signal maskint : std_logic;
  signal delay_slot : std_logic;
  signal this_c : decode_core_reg_t;
  signal this_r : decode_core_reg_t := reset_vector;
  function system_op (code : std_logic_vector(15 downto 0); instr : system_instr_t)
  return operation_t is
    variable op : operation_t;
  begin
    op.plane := SYSTEM_INSTR;
    op.code := code;
    if decode_type = ROM then
      -- Microcode-based decoder requires an address into the ROM that is different
      -- for each system instruction
      op.addr := system_instr_rom_addrs(instr);
    else
      op.addr := x"00";
    end if;
    return op;
  end;
  function system_op (instr : system_instr_t)
  return operation_t is
    variable cd : std_logic_vector(15 downto 0);
  begin
    cd := x"0" & system_instr_codes(instr) & x"00";
    return system_op(cd, instr);
  end;
  function system_op (event : cpu_event_i_t)
  return operation_t is
    variable code : std_logic_vector(15 downto 0);
  begin
    code := x"0" & system_event_codes(event.cmd) & event.vec;
    return system_op(code, system_event_instrs(event.cmd));
  end;
  function normal_op (instr : std_logic_vector(15 downto 0))
  return operation_t is
    variable op : operation_t;
  begin
    op.plane := NORMAL_INSTR;
    op.code := instr;
    if decode_type = ROM then
      -- ROM-based decoder requires a first stage decode from the instruction
      -- to the address in the ROM where the microcode starts for the instruction
      op.addr := predecode_rom_addr(instr);
    else
      op.addr := x"00";
    end if;
    return op;
  end;
begin
  decode_core : process(this_r,next_id_stall_a,ilevel_cap,dispatch,maskint_next,delay_jump,event_i,next_op)
    variable this : decode_core_reg_t;
  begin
     this := this_r;
    this.maskint := maskint_next;
    if ilevel_cap = '1' then
      this.ilevel := event_i.lvl;
    end if;
    if this.id_stall = '0' and this.instr_seq_zero = '1' then
      this.op := next_op;
    end if;
    this.id_stall := next_id_stall_a;
    if next_id_stall_a = '0' then
      this.delay_slot := delay_jump;
      this.instr_seq_zero := dispatch;
      this.op.addr := std_logic_vector(unsigned(this.op.addr) + 1);
    end if;
    this_c <= this;
  end process;
  decode_core_r0 : process(clk, rst)
  begin
     if rst='1' then
        this_r <= reset_vector;
     elsif clk='1' and slot='1' and clk'event then
        this_r <= this_c;
     end if;
  end process;
  maskint <= this_r.maskint;
  delay_slot <= this_r.delay_slot;
  ilevel <= this_r.ilevel;
  mac_stall <= mac_stall_sense and (p.wb1.mac_busy or p.wb2.mac_busy or
                                    p.wb3.mac_busy or p.ex1.mac_busy or mac_busy);
  -- Next ID STALL
  next_id_stall_a <= reg_conf or if_stall or mac_stall;
  next_id_stall <= next_id_stall_a;
  incpc <= id.incpc and not(next_id_stall_a);
  ifadsel <= id.ifadsel;
  if_issue <= id.if_issue and not(reg_conf) and not(mac_stall);
  -- Detect Exception Events
  next_op <=
    system_op(event_i)
    -- Interrupts, (address) errors, reset and break
      when delay_slot = '0' and event_i.en = '1' and (
           ( maskint = '0' and event_i.cmd = INTERRUPT and ( ibit < event_i.lvl or event_i.msk = '1' ) ) or
           ( event_i.cmd = ERROR or event_i.cmd = RESET_CPU or event_i.cmd = BREAK ) ) else
    -- Slot Illegal Instruction
    system_op(SLOT_ILLEGAL)
      when delay_slot = '1' and (illegal_delay_slot or illegal_instr) = '1' else
    -- General Illegal Instruction
    system_op(GENERAL_ILLEGAL)
      when illegal_instr = '1' else
    -- Break Instruction
    system_op(BREAK)
      when delay_slot = '0' and enter_debug = '1' else
    -- Normal instruction
    normal_op(if_dr);
    event_ack <= '1' when slot = '1' and (event_ack_0 = '1' or (event_i.en = '1' and event_i.cmd = BREAK and debug = '1') ) else '0';
    op <= this_r.op when this_r.id_stall = '1' or this_r.instr_seq_zero = '0'
          else next_op;
    -- Detect register conflict
    reg_conf <=
      '1' when
               -- W bus write to register
               (p.wb1_stall.wrreg_w = '1' and
                ((ex.xbus_sel = SEL_REG and ex.regnum_x = p.wb1.regnum_w) or
                 (ex.ybus_sel = SEL_REG and ex.regnum_y = p.wb1.regnum_w) or
                 (ex_stall.wrreg_z = '1' and ex.regnum_z = p.wb1.regnum_w) or
                 -- write to R0
                 (ex.aluiny_sel = SEL_R0 and p.wb1.regnum_w = "00000")))
      else '0';
end;
