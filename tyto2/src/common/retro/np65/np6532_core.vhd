--------------------------------------------------------------------------------
-- np6532_core.vhd                                                            --
-- np65 6502 compatible CPU core with 32 bit RAM interfaces.                  --
--------------------------------------------------------------------------------
-- (C) Copyright 2022 Adam Barnes <ambarnes@gmail.com>                        --
-- This file is part of The Tyto Project. The Tyto Project is free software:  --
-- you can redistribute it and/or modify it under the terms of the GNU Lesser --
-- General Public License as published by the Free Software Foundation,       --
-- either version 3 of the License, or (at your option) any later version.    --
-- The Tyto Project is distributed in the hope that it will be useful, but    --
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public     --
-- License for more details. You should have received a copy of the GNU       --
-- Lesser General Public License along with The Tyto Project. If not, see     --
-- https://www.gnu.org/licenses/.                                             --
--------------------------------------------------------------------------------
-- todo:
-- test races between NMI, IRQ and BRK

library ieee;
  use ieee.std_logic_1164.all;

package np6532_core_pkg is

  component np6532_core is
    generic (
      jmp_rst   : std_logic_vector(15 downto 0);
      vec_nmi   : std_logic_vector(15 downto 0) := x"FFFA";
      vec_irq   : std_logic_vector(15 downto 0) := x"FFFE";
      vec_brk   : std_logic_vector(15 downto 0) := x"FFFE"
    );
    port (

      clk       : in    std_logic;

      rst       : in    std_logic;
      hold      : in    std_logic;
      nmi       : in    std_logic;
      irq       : in    std_logic;

      if_a      : out   std_logic_vector(15 downto 0);
      if_en     : out   std_logic;
      if_brk    : out   std_logic;
      if_d      : in    std_logic_vector(31 downto 0);

      ls_a      : out   std_logic_vector(15 downto 0);
      ls_en     : out   std_logic;
      ls_re     : out   std_logic;
      ls_we     : out   std_logic;
      ls_sz     : out   std_logic_vector(1 downto 0);
      ls_dw     : out   std_logic_vector(31 downto 0);
      ls_dr     : in    std_logic_vector(31 downto 0);

      cz_a      : out   std_logic_vector(7 downto 0);
      cz_d      : in    std_logic_vector(31 downto 0);

      cs_a      : out   std_logic_vector(7 downto 0);
      cs_d      : in    std_logic_vector(31 downto 0);

      trace_stb : out   std_logic;
      trace_nmi : out   std_logic;
      trace_irq : out   std_logic;
      trace_op  : out   std_logic_vector(23 downto 0);
      trace_pc  : out   std_logic_vector(15 downto 0);
      trace_s   : out   std_logic_vector(7 downto 0);
      trace_p   : out   std_logic_vector(7 downto 0);
      trace_a   : out   std_logic_vector(7 downto 0);
      trace_x   : out   std_logic_vector(7 downto 0);
      trace_y   : out   std_logic_vector(7 downto 0)

    );
  end component np6532_core;

end package np6532_core_pkg;

--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.tyto_utils_pkg.all;
  use work.np65_decoder_pkg.all;

entity np6532_core is
  generic (
    jmp_rst   : std_logic_vector(15 downto 0);            -- reset jump address
    vec_nmi   : std_logic_vector(15 downto 0) := x"FFFA"; -- NMI vector address
    vec_irq   : std_logic_vector(15 downto 0) := x"FFFE"; -- IRQ vector address
    vec_brk   : std_logic_vector(15 downto 0) := x"FFFE"  -- BRK vector address
  );
  port (

    clk       : in    std_logic;                          -- clock

    rst       : in    std_logic;                          -- reset
    hold      : in    std_logic;                          -- pause execution on this cycle
    nmi       : in    std_logic;                          -- NMI
    irq       : in    std_logic;                          -- IRQ

    if_a      : out   std_logic_vector(15 downto 0);      -- instruction fetch address (byte aligned!)
    if_en     : out   std_logic;                          -- instruction fetch enable
    if_brk    : out   std_logic;                          -- instruction fetch force BRK
    if_d      : in    std_logic_vector(31 downto 0);      -- instruction fetch data

    ls_a      : out   std_logic_vector(15 downto 0);      -- load/store address (byte aligned!)
    ls_en     : out   std_logic;                          -- load/store enable
    ls_re     : out   std_logic;                          -- load/store read enable
    ls_we     : out   std_logic;                          -- load/store write enable
    ls_sz     : out   std_logic_vector(1 downto 0);       -- load/store transfer size (bytes) = 1+ls_sz
    ls_dw     : out   std_logic_vector(31 downto 0);      -- load/store write data
    ls_dr     : in    std_logic_vector(31 downto 0);      -- load/store read data

    cz_a      : out   std_logic_vector(7 downto 0);       -- zero page cache read address
    cz_d      : in    std_logic_vector(31 downto 0);      -- zero page cache read data

    cs_a      : out   std_logic_vector(7 downto 0);       -- stack cache read address
    cs_d      : in    std_logic_vector(31 downto 0);      -- stack cache read data

    trace_stb : out   std_logic;                          -- trace: instruction strobe (complete)
    trace_nmi : out   std_logic;                          -- trace: in NMI handler
    trace_irq : out   std_logic;                          -- trace: in IRQ handler
    trace_op  : out   std_logic_vector(23 downto 0);      -- trace opcode and operand
    trace_pc  : out   std_logic_vector(15 downto 0);      -- trace register PC
    trace_s   : out   std_logic_vector(7 downto 0);       -- trace register S
    trace_p   : out   std_logic_vector(7 downto 0);       -- trace register P
    trace_a   : out   std_logic_vector(7 downto 0);       -- trace register A
    trace_x   : out   std_logic_vector(7 downto 0);       -- trace register X
    trace_y   : out   std_logic_vector(7 downto 0)        -- trace register Y

  );
end entity np6532_core;

architecture synth of np6532_core is

  --------------------------------------------------------------------------------
  -- constants for readability (mux select values)

  constant SEL_LOGIC_NOP    : std_logic_vector(2 downto 0) := "000";
  constant SEL_LOGIC_AND_M  : std_logic_vector(2 downto 0) := "001";
  constant SEL_LOGIC_OR_M   : std_logic_vector(2 downto 0) := "010";
  constant SEL_LOGIC_EOR_M  : std_logic_vector(2 downto 0) := "011";
  constant SEL_LOGIC_AND_I  : std_logic_vector(2 downto 0) := "100";
  constant SEL_LOGIC_OR_I   : std_logic_vector(2 downto 0) := "101";
  constant SEL_LOGIC_EOR_I  : std_logic_vector(2 downto 0) := "110";

  constant SEL_FLAG_C_NOP   : std_logic_vector(1 downto 0) := "00";
  constant SEL_FLAG_C_ADD   : std_logic_vector(1 downto 0) := "01";
  constant SEL_FLAG_C_SHF_A : std_logic_vector(1 downto 0) := "10";
  constant SEL_FLAG_C_SHF_M : std_logic_vector(1 downto 0) := "11";

  constant SEL_FLAG_ZN_NOP  : std_logic_vector(2 downto 0) := "000";
  constant SEL_FLAG_ZN_ADD  : std_logic_vector(2 downto 0) := "010";
  constant SEL_FLAG_ZN_RMW  : std_logic_vector(2 downto 0) := "011";
  constant SEL_FLAG_ZN_A    : std_logic_vector(2 downto 0) := "100";
  constant SEL_FLAG_ZN_X    : std_logic_vector(2 downto 0) := "101";
  constant SEL_FLAG_ZN_Y    : std_logic_vector(2 downto 0) := "110";
  constant SEL_FLAG_ZN_BIT  : std_logic_vector(2 downto 0) := "111";

  constant SEL_FLAG_V_NOP   : std_logic_vector(1 downto 0) := "00";
  constant SEL_FLAG_V_ADD   : std_logic_vector(1 downto 0) := "10";
  constant SEL_FLAG_V_BIT   : std_logic_vector(1 downto 0) := "11";

  constant SEL_REG_A_NOP    : std_logic_vector(2 downto 0) := "000";   -- NOP should really be OTHER or NOT_MEM
  constant SEL_REG_A_MEM    : std_logic_vector(2 downto 0) := "100";
  constant SEL_REG_A_ADD    : std_logic_vector(2 downto 0) := "101";
  constant SEL_REG_A_LOG    : std_logic_vector(2 downto 0) := "110";
  constant SEL_REG_A_SHF    : std_logic_vector(2 downto 0) := "111";

  constant SEL_REG_X_NOP    : std_logic_vector(0 downto 0) := "0";     -- NOP should really be OTHER or NOT_MEM
  constant SEL_REG_X_MEM    : std_logic_vector(0 downto 0) := "1";

  constant SEL_REG_Y_NOP    : std_logic_vector(0 downto 0) := "0";     -- NOP should really be OTHER or NOT_MEM
  constant SEL_REG_Y_MEM    : std_logic_vector(0 downto 0) := "1";

  --------------------------------------------------------------------------------
  -- execution control

  signal   fif              : std_logic;                               -- first instruction fetch
  signal   run              : std_logic;                               -- asserts and stays asserted after first instruction fetch
  signal   advex            : std_logic;                               -- advance execution (instruction complete)
  signal   cycle            : std_logic;                               -- cycle (slow instructions)
  signal   smack            : std_logic;                               -- self modifying code (write collision with instruction fetch)

  --------------------------------------------------------------------------------
  -- interrupts and vectors

  signal   nmi_1            : std_logic;                               -- NMI delayed by 1 instruction fetch (for edge detect)

  signal   vc_nmi           : std_logic_vector(15 downto 0);           -- cached NMI vector
  signal   vc_nmi_en        : std_logic_vector(1 downto 0);            -- address decode for above
  signal   vc_irq           : std_logic_vector(15 downto 0);           -- cached IRQ vector
  signal   vc_irq_en        : std_logic_vector(1 downto 0);            -- address decode for above
  signal   vc_brk           : std_logic_vector(15 downto 0);           -- cached BRK vector
  signal   vc_brk_en        : std_logic_vector(1 downto 0);            -- address decode for above
  signal   vc_dw            : std_logic_vector(7 downto 0);            -- delayed write data
  signal   vc_we            : std_logic;                               -- delayed write enable

  --------------------------------------------------------------------------------
  -- pipeline stage 0

  signal   s0_if_a_brk      : std_logic_vector(15 downto 0);           -- instruction address (break)
  signal   s0_if_a_next     : std_logic_vector(15 downto 0);           -- instruction address (next)
  signal   s0_if_a_bxx      : std_logic_vector(15 downto 0);           -- instruction address (branch)
  signal   s0_if_a_rts      : std_logic_vector(15 downto 0);           -- instruction address (RTS)
  signal   s0_if_a          : std_logic_vector(15 downto 0);           -- instruction address

  --------------------------------------------------------------------------------
  -- pipeline stage 1

  signal   s1_nmi           : std_logic;                               -- NMI
  signal   s1_irq           : std_logic;                               -- IRQ
  signal   s1_int           : std_logic;                               -- NMI or IRQ
  signal   s1_force_brk     : std_logic;                               -- force BRK opcode
  signal   s1_flag_i_clr    : std_logic;                               -- I flag is being cleared by this instruction (CLI or PLP or RTI)
  signal   s1_flag_i_set    : std_logic;                               -- I flag is being set by this instruction (SEI or BRK or PLP)

  -- instruction decoder outputs
  signal   s1_id_valid      : std_logic;
  signal   s1_id_fast       : std_logic;
  signal   s1_id_isize      : std_logic_vector(ID_ISIZE_1'range);
  signal   s1_id_iaddr      : std_logic_vector(ID_IADDR_NXT'range);
  signal   s1_id_branch     : std_logic;
  signal   s1_id_bfsel      : std_logic_vector(ID_BFSEL_C'range);
  signal   s1_id_bfval      : std_logic;
  signal   s1_id_sdelta     : std_logic_vector(ID_SDELTA_0'range);
  signal   s1_id_dop        : std_logic_vector(ID_DOP_NOP'range);
  signal   s1_id_daddr      : std_logic_vector(ID_DADDR_IMM'range);
  signal   s1_id_zpx        : std_logic;
  signal   s1_id_dsize      : std_logic_vector(ID_DSIZE_1'range);
  signal   s1_id_wdata      : std_logic_vector(ID_WDATA_A'range);
  signal   s1_id_sreg       : std_logic_vector(ID_SREG_A'range);
  signal   s1_id_cmp        : std_logic;
  signal   s1_id_incdec     : std_logic;
  signal   s1_id_addsub     : std_logic;
  signal   s1_id_logic      : std_logic_vector(ID_LOGIC_AND'range);
  signal   s1_id_shift      : std_logic_vector(ID_SHIFT_ASL'range);
  signal   s1_id_rmw        : std_logic;
  signal   s1_id_reg_s      : std_logic;
  signal   s1_id_reg_p      : std_logic;
  signal   s1_id_reg_a      : std_logic_vector(ID_REG_A_NOP'range);
  signal   s1_id_reg_x      : std_logic_vector(ID_REG_X_NOP'range);
  signal   s1_id_reg_y      : std_logic_vector(ID_REG_Y_NOP'range);
  signal   s1_id_flag_c     : std_logic_vector(ID_FLAG_C_NOP'range);
  signal   s1_id_flag_zn    : std_logic_vector(ID_FLAG_ZN_NOP'range);
  signal   s1_id_flag_i     : std_logic_vector(ID_FLAG_I_NOP'range);
  signal   s1_id_flag_d     : std_logic_vector(ID_FLAG_D_NOP'range);
  signal   s1_id_flag_v     : std_logic_vector(ID_FLAG_V_NOP'range);

  -- instruction fetch
  signal   s1_if_bxx        : std_logic;
  signal   s1_opcode        : std_logic_vector(7 downto 0);            -- signal not alias for convenience in simulation
  signal   s1_operand_16    : std_logic_vector(15 downto 0);           -- "
  signal   s1_operand_8     : std_logic_vector(7 downto 0);            -- "

  -- load/store
  signal   s1_ls_a          : std_logic_vector(15 downto 0);
  signal   s1_ls_en         : std_logic;
  signal   s1_ls_re         : std_logic;
  signal   s1_ls_we         : std_logic;
  signal   s1_ls_dw         : std_logic_vector(31 downto 0);

  -- ALU/RMW related
  signal   s1_rmw_r         : std_logic_vector(7 downto 0);            -- read data into RMW operation
  signal   s1_rmw_w         : std_logic_vector(7 downto 0);            -- write data out of RMW operation
  signal   s1_rmw_z         : std_logic;                               -- RMW result is zero

  -- registers
  signal   s1_reg_pc        : std_logic_vector(15 downto 0);
  signal   s1_reg_pc1       : std_logic_vector(15 downto 0);
  signal   s1_reg_pc2       : std_logic_vector(15 downto 0);

  --------------------------------------------------------------------------------
  -- pipeline stage 2

  -- instruction decoder outputs
  signal   s2_id_addsub     : std_logic;
  signal   s2_id_shift      : std_logic_vector(1 downto 0);

  -- instruction fetch
  signal   s2_operand_16    : std_logic_vector(15 downto 0);           -- instruction operand(s) (1 or 2 bytes)
  alias    s2_operand_8     : std_logic_vector(7 downto 0) is s2_operand_16(7 downto 0);

  -- load/store
  alias    s2_ls_dr         : std_logic_vector(31 downto 0) is ls_dr;
  alias    s2_ls_dr_16      : std_logic_vector(15 downto 0) is ls_dr(15 downto 0);
  alias    s2_ls_dr_8       : std_logic_vector(7 downto 0) is ls_dr(7 downto 0);

  -- ALU/RMW related
  signal   s2_adder_ci      : std_logic;
  signal   s2_adder_i0      : std_logic_vector(7 downto 0);
  signal   s2_adder_i1      : std_logic_vector(7 downto 0);
  signal   s2_adder_t1      : std_logic_vector(4 downto 0);
  signal   s2_adder_t2      : std_logic_vector(3 downto 0);
  signal   s2_adder_t3      : std_logic_vector(1 downto 0);
  signal   s2_adder_bs      : std_logic_vector(7 downto 0);            -- binary sum
  signal   s2_adder_ds      : std_logic_vector(7 downto 0);            -- decimal sum
  signal   s2_adder_bc3     : std_logic;
  signal   s2_adder_dc3     : std_logic;
  signal   s2_adder_hc      : std_logic;
  signal   s2_adder_bc6     : std_logic;
  signal   s2_adder_bc7     : std_logic;
  signal   s2_adder_dc7     : std_logic;
  signal   s2_adder         : std_logic_vector(7 downto 0);            -- result (i0 +/- i1)
  signal   s2_adder_c       : std_logic;
  signal   s2_adder_z       : std_logic;
  signal   s2_adder_v       : std_logic;
  signal   s2_adder_n       : std_logic;
  signal   s2_logic         : std_logic_vector(7 downto 0);
  signal   s2_logic_z       : std_logic;
  signal   s2_shift_a       : std_logic_vector(7 downto 0);
  signal   s2_shift_a_c     : std_logic;
  signal   s2_shift_m_c     : std_logic;
  signal   s2_rmw_z         : std_logic;                               -- RMW result is zero
  signal   s2_rmw_n         : std_logic;                               -- RMW result is negative
  signal   s2_imm           : std_logic;                               -- source data is immediate
  signal   s2_bcd           : std_logic;                               -- operation should use BCD arithmetic
  signal   s2_sel_logic     : std_logic_vector(SEL_LOGIC_NOP'range);   -- data mux select for logical operations
  signal   s2_sel_flag_c    : std_logic_vector(SEL_FLAG_C_NOP'range);  -- C flag mux select
  signal   s2_sel_flag_zn   : std_logic_vector(SEL_FLAG_ZN_NOP'range); -- Z & N flags mux select
  signal   s2_sel_flag_v    : std_logic_vector(SEL_FLAG_V_NOP'range);  -- V flag mux select
  signal   s2_sel_reg_a     : std_logic_vector(SEL_REG_A_NOP'range);   -- A register mux select
  signal   s2_sel_reg_x     : std_logic_vector(SEL_REG_X_NOP'range);   -- X register mux select
  signal   s2_sel_reg_y     : std_logic_vector(SEL_REG_Y_NOP'range);   -- Y register mux select

  -- registers
  signal   s2_reg_s         : std_logic_vector(7 downto 0);            -- stack pointer (S)
  signal   s2_reg_s1        : std_logic_vector(7 downto 0);            -- S+1
  signal   s2_reg_p         : std_logic_vector(7 downto 0);
  alias    s2_flag_c        : std_logic is s2_reg_p(0);                -- signal not alias for convenience in simulation
  alias    s2_flag_z        : std_logic is s2_reg_p(1);
  alias    s2_flag_i        : std_logic is s2_reg_p(2);
  alias    s2_flag_d        : std_logic is s2_reg_p(3);
  alias    s2_flag_b        : std_logic is s2_reg_p(4);
  alias    s2_flag_x        : std_logic is s2_reg_p(5);
  alias    s2_flag_v        : std_logic is s2_reg_p(6);
  alias    s2_flag_n        : std_logic is s2_reg_p(7);
  signal   s2_reg_p_next    : std_logic_vector(7 downto 0);
  alias    s2_flag_c_next   : std_logic is s2_reg_p_next(0);
  alias    s2_flag_z_next   : std_logic is s2_reg_p_next(1);
  alias    s2_flag_i_next   : std_logic is s2_reg_p_next(2);
  alias    s2_flag_d_next   : std_logic is s2_reg_p_next(3);
  alias    s2_flag_b_next   : std_logic is s2_reg_p_next(4);
  alias    s2_flag_x_next   : std_logic is s2_reg_p_next(5);
  alias    s2_flag_v_next   : std_logic is s2_reg_p_next(6);
  alias    s2_flag_n_next   : std_logic is s2_reg_p_next(7);
  signal   s2_reg_a         : std_logic_vector(7 downto 0);
  signal   s2_reg_a_next    : std_logic_vector(7 downto 0);
  signal   s2_reg_a_z       : std_logic;                               -- s2_reg_a is zero
  signal   s2_reg_x         : std_logic_vector(7 downto 0);
  signal   s2_reg_x_next    : std_logic_vector(7 downto 0);
  signal   s2_reg_x_z       : std_logic;                               -- s2_reg_x is zero
  signal   s2_reg_y         : std_logic_vector(7 downto 0);
  signal   s2_reg_y_next    : std_logic_vector(7 downto 0);
  signal   s2_reg_y_z       : std_logic;                               -- s2_reg_y is zero

  --------------------------------------------------------------------------------
  -- signals for simulation visibility only

  signal   sim_opcode       : std_logic_vector(7 downto 0);
  signal   sim_operand_8    : std_logic_vector(7 downto 0);
  signal   sim_operand_16   : std_logic_vector(15 downto 0);
  signal   sim_nmi          : std_logic;
  signal   sim_irq          : std_logic;
  signal   sim_reg_pc       : std_logic_vector(15 downto 0);
  signal   sim_reg_s        : std_logic_vector(7 downto 0);
  signal   sim_reg_a        : std_logic_vector(7 downto 0);
  signal   sim_reg_x        : std_logic_vector(7 downto 0);
  signal   sim_reg_y        : std_logic_vector(7 downto 0);
  signal   sim_flag_c       : std_logic;
  signal   sim_flag_z       : std_logic;
  signal   sim_flag_i       : std_logic;
  signal   sim_flag_d       : std_logic;
  signal   sim_flag_b       : std_logic;
  signal   sim_flag_x       : std_logic;
  signal   sim_flag_v       : std_logic;
  signal   sim_flag_n       : std_logic;

  --------------------------------------------------------------------------------
  -- Xilinx synthesis attributes

  attribute keep_hierarchy : string;
  attribute keep_hierarchy of DECODER : label is "yes";

  --------------------------------------------------------------------------------
  -- functions

  -- convert std_logic to 1-bit unsigned, useful in ALU
  function s2u (b : std_logic) return unsigned is
  begin
    if b = '1' then
      return "1";
    else
      return "0";
    end if;
  end function s2u;

--------------------------------------------------------------------------------

begin

  -- helpful signal names for simulation only

  sim_opcode     <= s1_opcode;
  sim_operand_8  <= s1_operand_8;
  sim_operand_16 <= s1_operand_16;
  sim_nmi        <= s1_nmi;
  sim_irq        <= s1_irq;
  sim_reg_pc     <= s1_reg_pc;
  sim_reg_s      <= s2_reg_s;
  sim_reg_a      <= s2_reg_a;
  sim_reg_x      <= s2_reg_x;
  sim_reg_y      <= s2_reg_y;
  sim_flag_c     <= s2_reg_p(0);
  sim_flag_z     <= s2_reg_p(1);
  sim_flag_i     <= s2_reg_p(2);
  sim_flag_d     <= s2_reg_p(3);
  sim_flag_b     <= s2_reg_p(4);
  sim_flag_x     <= s2_reg_p(5);
  sim_flag_v     <= s2_reg_p(6);
  sim_flag_n     <= s2_reg_p(7);

  -- signals as aliases

  s1_opcode     <= if_d(7 downto 0);
  s1_operand_16 <= if_d(23 downto 8);
  s1_operand_8  <= if_d(15 downto 8);

  -- misc outputs

  if_en  <= (run and s1_id_valid and (s1_id_fast or cycle) and not hold) or fif;
  if_brk <= s1_force_brk;
  if_a   <= s0_if_a;
  ls_a   <= s1_ls_a;
  ls_en  <= s1_ls_en;
  ls_re  <= s1_ls_re;
  ls_we  <= s1_ls_we;
  ls_sz  <= s1_id_dsize;
  ls_dw  <= s1_ls_dw;
  cz_a   <= s1_operand_8+s2_reg_x when s1_id_zpx = '1' else s1_operand_8;
  cs_a   <= s2_reg_s1;

  -- trace: conditions at start of instruction

  trace_stb <= advex;
  trace_nmi <= s1_nmi;
  trace_irq <= s1_irq;
  trace_op  <= s1_operand_16 & s1_opcode;
  trace_pc  <= s1_reg_pc;
  trace_s   <= s2_reg_s;
  trace_p   <= s2_reg_p;
  trace_a   <= s2_reg_a;
  trace_x   <= s2_reg_x;
  trace_y   <= s2_reg_y;

  -- instruction decoder

  DECODER: component np65_decoder
    port map (
      opcode  => s1_opcode,
      valid   => s1_id_valid, -- opcode is valid
      fast    => s1_id_fast,  -- this is a single cycle instruction
      isize   => s1_id_isize, -- instruction length (0..3 => 1..4 bytes)
      iaddr   => s1_id_iaddr,
      branch  => s1_id_branch,
      bfsel   => s1_id_bfsel,
      bfval   => s1_id_bfval,
      sdelta  => s1_id_sdelta,
      dop     => s1_id_dop,
      daddr   => s1_id_daddr,
      zpx     => s1_id_zpx,
      dsize   => s1_id_dsize,
      wdata   => s1_id_wdata,
      sreg    => s1_id_sreg,
      cmp     => s1_id_cmp,
      incdec  => s1_id_incdec,
      addsub  => s1_id_addsub,
      logic   => s1_id_logic,
      shift   => s1_id_shift,
      rmw     => s1_id_rmw,
      reg_s   => s1_id_reg_s,
      reg_p   => s1_id_reg_p,
      reg_a   => s1_id_reg_a,
      reg_x   => s1_id_reg_x,
      reg_y   => s1_id_reg_y,
      flag_c  => s1_id_flag_c,
      flag_zn => s1_id_flag_zn,
      flag_i  => s1_id_flag_i,
      flag_d  => s1_id_flag_d,
      flag_v  => s1_id_flag_v
    );

  -- execution control
  --  almost all instructions are fast / single cycle
  --  exceptions are RMW (non zero page) and JMP indirect; these take 2 cycles and always start with a load
  advex <= run and s1_id_valid and (s1_id_fast or cycle) and not hold and not smack;

  -- I flag will be cleared by this instruction (CLI, RTI or PLP)
  s1_flag_i_clr <= (s1_id_flag_i = ID_FLAG_I_CLR) or (s1_id_reg_p and not cs_d(2));

  -- I flag will be set by this instruction (SEI or BRK or PLP)
  s1_flag_i_set <= (s1_id_flag_i = ID_FLAG_I_SET) or (s1_id_flag_i = ID_FLAG_I_BRK) or (s1_id_reg_p and cs_d(2));

  MAIN: process (clk) is
  begin
    if rising_edge(clk) then

      if rst = '1' then

        cycle <= '0';
        fif   <= '0';
        run   <= '0';
        smack <= '0';

        nmi_1        <= '0';
        s1_nmi       <= '0';
        s1_irq       <= '0';
        s1_int       <= '0';
        s1_force_brk <= '0';

        s2_rmw_z       <= '0';
        s2_rmw_n       <= '0';
        s2_reg_p_next  <= x"14";                                                                                       -- X flag starts off clear to inhibit NMI during init
        s2_reg_a_next  <= x"00";
        s2_reg_x_next  <= x"00";
        s2_reg_y_next  <= x"00";
        s2_id_addsub   <= '0';
        s2_imm         <= '0';
        s2_bcd         <= '0';
        s2_id_shift    <= (others => '0');
        s2_operand_16  <= (others => '0');
        s2_sel_logic   <= (others => '0');
        s2_sel_reg_a   <= (others => '0');
        s2_sel_reg_x   <= (others => '0');
        s2_sel_reg_y   <= (others => '0');
        s2_sel_flag_c  <= (others => '0');
        s2_sel_flag_zn <= (others => '0');
        s2_sel_flag_v  <= (others => '0');
        s2_adder_ci    <= '0';
        s2_adder_i0    <= (others => '0');
        s2_shift_a     <= (others => '0');
        s2_shift_m_c   <= '0';

      else

        cycle <= ((not hold and not s1_id_fast) or cycle) and not advex;
        smack <= '0';

        s2_id_addsub   <= '0';
        s2_id_shift    <= (others => '0');
        s2_operand_16  <= (others => '0');
        s2_imm         <= '0';
        s2_bcd         <= '0';
        s2_sel_logic   <= (others => '0');
        s2_sel_reg_a   <= (others => '0');
        s2_sel_reg_x   <= (others => '0');
        s2_sel_reg_y   <= (others => '0');
        s2_sel_flag_c  <= (others => '0');
        s2_sel_flag_zn <= (others => '0');
        s2_sel_flag_v  <= (others => '0');
        s2_adder_ci    <= '0';
        s2_adder_i0    <= (others => '0');
        s2_shift_a     <= (others => '0');
        s2_reg_p_next  <= s2_reg_p;
        s2_reg_a_next  <= s2_reg_a;
        s2_reg_x_next  <= s2_reg_x;
        s2_reg_y_next  <= s2_reg_y;

        if fif = '0' and run = '0' and hold = '0' then
          fif <= '1';
        elsif fif = '1' and hold = '0' then
          fif <= '0';
          run <= '1';
        end if;

        if s1_ls_we = '1' and (
                               (s1_ls_a = s0_if_a) or
                               (s1_ls_a = s0_if_a+1) or
                               (s1_ls_a = s0_if_a+2)
                             ) then                                                                                    -- self modifying code - write collision with instruction fetch
          smack <= '1';
        end if;

        if advex = '1' then

          if s1_id_iaddr =  ID_IADDR_RTI then
            if s1_nmi = '1' then
              s1_nmi <= '0';
              s1_int <= s1_irq;
            elsif s1_irq = '1' then
              s1_irq <= '0';
              s1_int <= '0';
            end if;
          end if;

          nmi_1        <= nmi and s2_flag_x;
          s1_force_brk <= '0';
          if nmi = '1' and s2_flag_x = '1' and nmi_1 = '0' then
            s1_nmi       <= '1';
            s1_int       <= '1';
            s1_force_brk <= '1';
          elsif irq = '1' and (s1_flag_i_clr = '1' or (s2_flag_i = '0' and s1_flag_i_set = '0')) and s1_irq = '0' then
            s1_irq       <= '1';
            s1_int       <= '1';
            s1_force_brk <= '1';
          end if;

          s2_id_addsub  <= s1_id_addsub;
          s2_id_shift   <= s1_id_shift;
          s2_operand_16 <= s1_operand_16;
          s2_rmw_z      <= s1_rmw_z;
          s2_rmw_n      <= s1_rmw_w(7);
          s2_imm        <= s1_id_daddr = ID_DADDR_IMM;
          s2_bcd        <= s2_flag_d and not s1_id_cmp;

          -- synchronous selects drive asynchronous muxes

          s2_sel_logic <= SEL_LOGIC_NOP;
          if    s1_id_daddr /= ID_DADDR_IMM and s1_id_logic = ID_LOGIC_AND then s2_sel_logic <= SEL_LOGIC_AND_M;
          elsif s1_id_daddr /= ID_DADDR_IMM and s1_id_logic = ID_LOGIC_OR  then s2_sel_logic <= SEL_LOGIC_OR_M;
          elsif s1_id_daddr /= ID_DADDR_IMM and s1_id_logic = ID_LOGIC_EOR then s2_sel_logic <= SEL_LOGIC_EOR_M;
          elsif s1_id_daddr =  ID_DADDR_IMM and s1_id_logic = ID_LOGIC_AND then s2_sel_logic <= SEL_LOGIC_AND_I;
          elsif s1_id_daddr =  ID_DADDR_IMM and s1_id_logic = ID_LOGIC_OR  then s2_sel_logic <= SEL_LOGIC_OR_I;
          elsif s1_id_daddr =  ID_DADDR_IMM and s1_id_logic = ID_LOGIC_EOR then s2_sel_logic <= SEL_LOGIC_EOR_I;
          end if;

          s2_sel_reg_a <= SEL_REG_A_NOP;
          if    s1_id_reg_a = ID_REG_A_IMM then s2_reg_a_next <= s1_operand_8;
          elsif s1_id_reg_a = ID_REG_A_MEM then s2_sel_reg_a <= SEL_REG_A_MEM;
          elsif s1_id_reg_a = ID_REG_A_ADD then s2_sel_reg_a <= SEL_REG_A_ADD;
          elsif s1_id_reg_a = ID_REG_A_LOG then s2_sel_reg_a <= SEL_REG_A_LOG;
          elsif s1_id_reg_a = ID_REG_A_SHF then s2_sel_reg_a <= SEL_REG_A_SHF;
          elsif s1_id_reg_a = ID_REG_A_TXA then s2_reg_a_next <= s2_reg_x;
          elsif s1_id_reg_a = ID_REG_A_TYA then s2_reg_a_next <= s2_reg_y;
          end if;

          s2_sel_reg_x <= SEL_REG_X_NOP;
          if    s1_id_reg_x = ID_REG_X_IMM then s2_reg_x_next <= s1_operand_8;
          elsif s1_id_reg_x = ID_REG_X_MEM then s2_sel_reg_x <= SEL_REG_X_MEM;
          elsif s1_id_reg_x = ID_REG_X_INX then s2_reg_x_next <= s2_reg_x+1;
          elsif s1_id_reg_x = ID_REG_X_DEX then s2_reg_x_next <= s2_reg_x-1;
          elsif s1_id_reg_x = ID_REG_X_TAX then s2_reg_x_next <= s2_reg_a;
          elsif s1_id_reg_x = ID_REG_X_TSX then s2_reg_x_next <= s2_reg_s;
          else
          end if;

          s2_sel_reg_y <= SEL_REG_Y_NOP;
          if    s1_id_reg_y = ID_REG_Y_IMM then s2_reg_y_next <= s1_operand_8;
          elsif s1_id_reg_y = ID_REG_Y_MEM then s2_sel_reg_y <= SEL_REG_Y_MEM;
          elsif s1_id_reg_y = ID_REG_Y_INY then s2_reg_y_next <= s2_reg_y+1;
          elsif s1_id_reg_y = ID_REG_Y_DEY then s2_reg_y_next <= s2_reg_y-1;
          elsif s1_id_reg_y = ID_REG_Y_TAY then s2_reg_y_next <= s2_reg_a;
          end if;

          s2_sel_flag_c <= SEL_FLAG_C_NOP;
          if    s1_id_flag_c = ID_FLAG_C_CLR then                             s2_flag_c_next <= '0';                   -- CLC
          elsif s1_id_flag_c = ID_FLAG_C_SET then                             s2_flag_c_next <= '1';                   -- SEC
          elsif s1_id_flag_c = ID_FLAG_C_SHF and s1_id_rmw /= ID_RMW_SHF then s2_sel_flag_c <= SEL_FLAG_C_SHF_A;
          elsif s1_id_flag_c = ID_FLAG_C_SHF and s1_id_rmw =  ID_RMW_SHF then s2_sel_flag_c <= SEL_FLAG_C_SHF_M;
          elsif s1_id_flag_c = ID_FLAG_C_ADD then                             s2_sel_flag_c <= SEL_FLAG_C_ADD;
          end if;

          s2_sel_flag_zn <= SEL_FLAG_ZN_NOP;
          if    s1_id_flag_zn = ID_FLAG_ZN_BIT then s2_sel_flag_zn <= SEL_FLAG_ZN_BIT;
          elsif s1_id_flag_zn = ID_FLAG_ZN_ADD then s2_sel_flag_zn <= SEL_FLAG_ZN_ADD;
          elsif s1_id_flag_zn = ID_FLAG_ZN_RMW then s2_sel_flag_zn <= SEL_FLAG_ZN_RMW;
          elsif s1_id_flag_zn = ID_FLAG_ZN_A then   s2_sel_flag_zn <= SEL_FLAG_ZN_A;
          elsif s1_id_flag_zn = ID_FLAG_ZN_X then   s2_sel_flag_zn <= SEL_FLAG_ZN_X;
          elsif s1_id_flag_zn = ID_FLAG_ZN_Y then   s2_sel_flag_zn <= SEL_FLAG_ZN_Y;
          end if;

          if    s1_id_flag_i = ID_FLAG_I_CLR then s2_flag_i_next <= '0';
          elsif s1_id_flag_i = ID_FLAG_I_SET then s2_flag_i_next <= '1';
          elsif s1_id_flag_i = ID_FLAG_I_BRK then s2_flag_i_next <= '1';
          end if;

          if    s1_id_flag_d = ID_FLAG_D_CLR then s2_flag_d_next <= '0';
          elsif s1_id_flag_d = ID_FLAG_D_SET then s2_flag_d_next <= '1';
          end if;

          s2_sel_flag_v <= SEL_FLAG_V_NOP;
          if    s1_id_flag_v = ID_FLAG_V_CLR then s2_flag_v_next <= '0';
          elsif s1_id_flag_v = ID_FLAG_V_ADD then s2_sel_flag_v <= SEL_FLAG_V_ADD;
          elsif s1_id_flag_v = ID_FLAG_V_BIT then s2_sel_flag_v <= SEL_FLAG_V_BIT;
          end if;

          -- PLP/RTI

          if s1_id_reg_p = '1' then
            s2_reg_p_next  <= cs_d(7 downto 0);
            s2_flag_b_next <= '1';
            if s2_flag_x = '1' then
              s2_flag_x_next <= '1';                                                                                   -- setting X flag cannot be undone
            end if;
          end if;

          -- misc sync

          s2_adder_ci <= s2_flag_c or s1_id_cmp;

          if    s1_id_sreg = ID_SREG_A then s2_adder_i0 <= s2_reg_a;
          elsif s1_id_sreg = ID_SREG_X then s2_adder_i0 <= s2_reg_x;
          elsif s1_id_sreg = ID_SREG_Y then s2_adder_i0 <= s2_reg_y;
          else                              s2_adder_i0 <= (others => '0');
          end if;

          if    s1_id_shift = ID_SHIFT_ASL then s2_shift_a <= s2_reg_a(6 downto 0) & '0';
          elsif s1_id_shift = ID_SHIFT_LSR then s2_shift_a <= '0' & s2_reg_a(7 downto 1);
          elsif s1_id_shift = ID_SHIFT_ROL then s2_shift_a <= s2_reg_a(6 downto 0) & s2_flag_c;
          elsif s1_id_shift = ID_SHIFT_ROR then s2_shift_a <= s2_flag_c & s2_reg_a(7 downto 1);
          else                                  s2_shift_a <= (others => '0');
          end if;

          case s1_id_shift is
            when ID_SHIFT_ASL => s2_shift_m_c <= s1_rmw_r(7);
            when ID_SHIFT_LSR => s2_shift_m_c <= s1_rmw_r(0);
            when ID_SHIFT_ROL => s2_shift_m_c <= s1_rmw_r(7);
            when ID_SHIFT_ROR => s2_shift_m_c <= s1_rmw_r(0);
            when others => null;
          end case;

        end if;                                                                                                        -- advex
      end if;                                                                                                          -- rst = '1'
    end if;                                                                                                            -- rising_edge(clk)
  end process MAIN;

  -- instruction fetch address generation

  s1_if_bxx <= ((s1_id_bfsel = ID_BFSEL_C) and (s1_id_bfval = s2_flag_c)) or
               ((s1_id_bfsel = ID_BFSEL_Z) and (s1_id_bfval = s2_flag_z)) or
               ((s1_id_bfsel = ID_BFSEL_V) and (s1_id_bfval = s2_flag_v)) or
               ((s1_id_bfsel = ID_BFSEL_N) and (s1_id_bfval = s2_flag_n));

  s0_if_a_bxx <= s1_reg_pc2 when s1_if_bxx = '0' else
                 std_logic_vector(unsigned(s1_reg_pc2)+unsigned(resize(signed(s1_operand_8), 16)));

  s0_if_a_brk <= jmp_rst when fif = '1' else
                 vc_nmi when s1_nmi = '1' else
                 vc_irq when s1_irq = '1' else
                 vc_brk;

  s0_if_a_next <= s1_reg_pc+s1_id_isize+1 when smack = '0' else s1_reg_pc;

  s0_if_a_rts <= cs_d(15 downto 0)+1;

  s0_if_a <= s1_reg_pc         when advex = '0'                else
             s0_if_a_brk       when s1_id_iaddr = ID_IADDR_BRK else -- reset, IRQ, BRK, NMI
             s0_if_a_next      when s1_id_iaddr = ID_IADDR_NXT else -- next instruction
             s0_if_a_bxx       when s1_id_iaddr = ID_IADDR_BRX else -- branch
             s1_operand_16     when s1_id_iaddr = ID_IADDR_JMP else -- JMP/JSR absolute
             s0_if_a_rts       when s1_id_iaddr = ID_IADDR_RTS else -- RTS
             cs_d(23 downto 8) when s1_id_iaddr = ID_IADDR_RTI else -- RTI
             s2_ls_dr_16       when s1_id_iaddr = ID_IADDR_IND else -- JMP indirect
             x"0000";

  -- load/store address generation

  with s1_id_daddr select s1_ls_a <=
        x"01" & s2_reg_s1               when ID_DADDR_PULL,  -- stack pull (not needed because of stack cache)
        x"01" & s2_reg_s                when ID_DADDR_PUSH1, -- stack push 1 byte (PHA, PHP)
        x"01" & (s2_reg_s-1)            when ID_DADDR_PUSH2, -- stack push 2 bytes (JSR)
        x"01" & (s2_reg_s-2)            when ID_DADDR_PUSH3, -- stack push 3 bytes (BRK/IRQ/NMI)
        x"00" & s1_operand_8            when ID_DADDR_ZP,    -- ZP
        x"00" & (s1_operand_8+s2_reg_x) when ID_DADDR_ZP_X,  -- ZP,X
        x"00" & (s1_operand_8+s2_reg_y) when ID_DADDR_ZP_Y,  -- ZP,Y
        s1_operand_16                   when ID_DADDR_ABS,   -- absolute
        s1_operand_16+s2_reg_x          when ID_DADDR_ABS_X, -- absolute,X
        s1_operand_16+s2_reg_y          when ID_DADDR_ABS_Y, -- absolute,Y
        cz_d(15 downto 0)               when ID_DADDR_IIX,   -- (ZP,X)
        cz_d(15 downto 0)+s2_reg_y      when ID_DADDR_IIY,   -- (ZP),Y
        x"0000"                         when others;

  -- load/store strobes

  s1_ls_en <= run and not hold and (s1_id_dop /= ID_DOP_NOP);
  s1_ls_re <= run and not hold and ((s1_id_dop = ID_DOP_R) or ((s1_id_dop = ID_DOP_RMW) and cycle = '0'));
  s1_ls_we <= run and not hold and ((s1_id_dop = ID_DOP_W) or ((s1_id_dop = ID_DOP_RMW) and cycle = '1'));

  -- store (write) data

  with s1_id_wdata select
      s1_ls_dw(7 downto 0) <=
        s1_rmw_w                                                 when ID_WDATA_RMW, -- RMW
        s2_reg_a                                                 when ID_WDATA_A,   -- STA, PHA
        s2_reg_x                                                 when ID_WDATA_X,   -- STX
        s2_reg_y                                                 when ID_WDATA_Y,   -- STY
        s2_reg_p                                                 when ID_WDATA_P,   -- PHP
        s1_reg_pc2(7 downto 0)                                   when ID_WDATA_JSR, -- JSR
        s2_reg_p(7 downto 5) & not s1_int & s2_reg_p(3 downto 0) when ID_WDATA_BRK, -- BRK/IRQ/NMI
        x"00"                                                    when others;

  s1_ls_dw(15 downto 8) <=
                           s1_reg_pc2(15 downto 8) when s1_id_wdata = ID_WDATA_JSR else                  -- JSR
                           s1_reg_pc(7 downto 0)   when s1_id_wdata = ID_WDATA_BRK and s1_int = '1' else -- IRQ/NMI
                           s1_reg_pc2(7 downto 0)  when s1_id_wdata = ID_WDATA_BRK else                  -- BRK
                           x"00";

  s1_ls_dw(23 downto 16) <=
                            s1_reg_pc(15 downto 8)  when s1_id_wdata = ID_WDATA_BRK and s1_int = '1' else -- IRQ/NMI
                            s1_reg_pc2(15 downto 8) when s1_id_wdata = ID_WDATA_BRK else                  -- BRK
                            x"00";

  s1_ls_dw(31 downto 24) <= (others => '0');

  -- adder (ADC/SBC)

  s2_adder_i1 <=
                 s2_operand_8     when s2_imm = '1' and s2_id_addsub = ID_ADDSUB_ADD else
                 not s2_operand_8 when s2_imm = '1' and s2_id_addsub = ID_ADDSUB_SUB else
                 s2_ls_dr_8       when s2_imm = '0' and s2_id_addsub = ID_ADDSUB_ADD else
                 not s2_ls_dr_8   when s2_imm = '0' and s2_id_addsub = ID_ADDSUB_SUB else
                 x"00";

  s2_adder_t1             <= std_logic_vector(
                                              unsigned('0' & s2_adder_i0(3 downto 0)) +
                                              unsigned('0' & s2_adder_i1(3 downto 0)) +
                                              s2u(s2_adder_ci)
                                            );
  s2_adder_bc3            <= s2_adder_t1(4);
  s2_adder_bs(3 downto 0) <= s2_adder_t1(3 downto 0);

  s2_adder_dc3 <= '1' when unsigned(s2_adder_bc3 & s2_adder_bs(3 downto 0)) > "01001" else '0';

  s2_adder_hc <= s2_adder_bc3 or (s2_bcd and not s2_id_addsub and s2_adder_dc3);

  s2_adder_ds(3 downto 0) <=
                             s2_adder_bs(3 downto 0)+"0110" when s2_bcd = '1' and s2_id_addsub = ID_ADDSUB_ADD and s2_adder_dc3 = '1' else
                             s2_adder_bs(3 downto 0)+"1010" when s2_bcd = '1' and s2_id_addsub = ID_ADDSUB_SUB and s2_adder_bc3 = '0' else
                             s2_adder_bs(3 downto 0);

  s2_adder_t2             <= std_logic_vector(
                                              unsigned('0' & s2_adder_i0(6 downto 4)) +
                                              unsigned('0' & s2_adder_i1(6 downto 4)) +
                                              s2u(s2_adder_hc)
                                            );
  s2_adder_bc6            <= s2_adder_t2(3);
  s2_adder_bs(6 downto 4) <= s2_adder_t2(2 downto 0);

  s2_adder_t3    <= std_logic_vector(
                                     unsigned'('0' & s2_adder_i0(7)) +
                                     unsigned'('0' & s2_adder_i1(7)) +
                                     s2u(s2_adder_bc6)
                                   );
  s2_adder_bc7   <= s2_adder_t3(1);
  s2_adder_bs(7) <= s2_adder_t3(0);

  s2_adder_dc7 <= '1' when unsigned(s2_adder_bc7 & s2_adder_bs(7 downto 4)) > "01001" else '0';

  s2_adder_c <= s2_adder_bc7 or (s2_bcd and not s2_id_addsub and s2_adder_dc7);

  s2_adder_ds(7 downto 4) <=
                             s2_adder_bs(7 downto 4)+"0110" when s2_bcd = '1' and s2_id_addsub = ID_ADDSUB_ADD and s2_adder_dc7 = '1' else
                             s2_adder_bs(7 downto 4)+"1010" when s2_bcd = '1' and s2_id_addsub = ID_ADDSUB_SUB and s2_adder_bc7 = '0' else
                             s2_adder_bs(7 downto 4);

  s2_adder_z <= '1' when s2_adder_bs = x"00" else '0';

  s2_adder_v <= not (((s2_adder_i0(7) nor s2_adder_i1(7)) and s2_adder_bc6) nor ((s2_adder_i0(7) nand s2_adder_i1(7)) nor s2_adder_bc6));

  s2_adder_n <= s2_adder_bs(7);

  s2_adder <= s2_adder_ds;

  -- logic (AND/OR/EOR)

  with s2_sel_logic select s2_logic <=
        s2_reg_a_next and s2_ls_dr_8   when SEL_LOGIC_AND_M,
        s2_reg_a_next or  s2_ls_dr_8   when SEL_LOGIC_OR_M,
        s2_reg_a_next xor s2_ls_dr_8   when SEL_LOGIC_EOR_M,
        s2_reg_a_next and s2_operand_8 when SEL_LOGIC_AND_I,
        s2_reg_a_next or  s2_operand_8 when SEL_LOGIC_OR_I,
        s2_reg_a_next xor s2_operand_8 when SEL_LOGIC_EOR_I,
        x"00"                          when others;

  s2_logic_z <= '1' when s2_logic = x"00" else '0';

  -- bit shifter (ASL/LSR/ROL/ROR)

  with s2_id_shift select s2_shift_a_c <=
        s2_reg_a_next(7) when ID_SHIFT_ASL,
        s2_reg_a_next(0) when ID_SHIFT_LSR,
        s2_reg_a_next(7) when ID_SHIFT_ROL,
        s2_reg_a_next(0) when ID_SHIFT_ROR,
        '0'              when others;

  -- read/modify/write (RMW) modified data

  s1_rmw_r <= cz_d(7 downto 0) when s1_id_fast ='1' else s2_ls_dr_8;

  s1_rmw_w <=
              s1_rmw_r(6 downto 0) & '0'       when s1_id_rmw = ID_RMW_SHF and s1_id_shift = ID_SHIFT_ASL  else
              '0' & s1_rmw_r(7 downto 1)       when s1_id_rmw = ID_RMW_SHF and s1_id_shift = ID_SHIFT_LSR  else
              s1_rmw_r(6 downto 0) & s2_flag_c when s1_id_rmw = ID_RMW_SHF and s1_id_shift = ID_SHIFT_ROL  else
              s2_flag_c & s1_rmw_r(7 downto 1) when s1_id_rmw = ID_RMW_SHF and s1_id_shift = ID_SHIFT_ROR  else
              s1_rmw_r+1                       when s1_id_rmw = ID_RMW_ID and s1_id_incdec = ID_INCDEC_INC else
              s1_rmw_r-1                       when s1_id_rmw = ID_RMW_ID and s1_id_incdec = ID_INCDEC_DEC else
              x"00";

  s1_rmw_z <= '1' when s1_rmw_w = x"00" else '0';

  -- register PC (program counter)

  REG_PC: process (clk) is
  begin
    if rising_edge(clk) then
      if rst = '1' then
        s1_reg_pc  <= jmp_rst;
        s1_reg_pc1 <= jmp_rst+1;
        s1_reg_pc2 <= jmp_rst+2;
      elsif advex = '1' or (fif = '1' and hold = '0') then
        s1_reg_pc  <= s0_if_a;
        s1_reg_pc1 <= s0_if_a+1;
        s1_reg_pc2 <= s0_if_a+2;
      end if;
    end if;
  end process REG_PC;

  -- register S (stack pointer)

  REG_S: process (clk) is
  begin
    if rising_edge(clk) then
      if rst = '1' then
        s2_reg_s  <= x"00";
        s2_reg_s1 <= x"01";
      elsif advex = '1' then
        if s1_id_reg_s = '1' then -- TXS
          s2_reg_s  <= s2_reg_x;
          s2_reg_s1 <= s2_reg_x+1;
        else
          s2_reg_s  <= std_logic_vector(unsigned(s2_reg_s)+unsigned(resize(signed(s1_id_sdelta), 8)));
          s2_reg_s1 <= std_logic_vector(unsigned(s2_reg_s)+unsigned(resize(signed(s1_id_sdelta), 8))+1);
        end if;
      end if;
    end if;
  end process REG_S;

  -- register P (status flags)

  with s2_sel_flag_c select s2_flag_c <=
        s2_adder_c     when SEL_FLAG_C_ADD,
        s2_shift_a_c   when SEL_FLAG_C_SHF_A, -- ASL/LSR/ROL/ROR A
        s2_shift_m_c   when SEL_FLAG_C_SHF_M, -- ASL/LSR/ROL/ROR mem
        s2_flag_c_next when others;           -- NOP/clr/set/PLP/RTI

  with s2_sel_flag_zn select s2_flag_z <=
        s2_adder_z     when SEL_FLAG_ZN_ADD,
        s2_rmw_z       when SEL_FLAG_ZN_RMW,
        s2_reg_a_z     when SEL_FLAG_ZN_A,
        s2_reg_x_z     when SEL_FLAG_ZN_X,
        s2_reg_y_z     when SEL_FLAG_ZN_Y,
        s2_logic_z     when SEL_FLAG_ZN_BIT,
        s2_flag_z_next when others; -- NOP/PLP/RTI

  s2_flag_i <= s2_flag_i_next;

  s2_flag_d <= s2_flag_d_next;

  s2_flag_b <= '1';

  s2_flag_x <= s2_flag_x_next;

  with s2_sel_flag_v select s2_flag_v <=
        s2_adder_v     when SEL_FLAG_V_ADD,
        s2_ls_dr_8(6)  when SEL_FLAG_V_BIT,
        s2_flag_v_next when others; -- NOP/clr/PLP/RTI

  with s2_sel_flag_zn select s2_flag_n <=
        s2_adder_n     when SEL_FLAG_ZN_ADD,
        s2_rmw_n       when SEL_FLAG_ZN_RMW,
        s2_reg_a(7)    when SEL_FLAG_ZN_A,
        s2_reg_x(7)    when SEL_FLAG_ZN_X,
        s2_reg_y(7)    when SEL_FLAG_ZN_Y,
        s2_ls_dr_8(7)  when SEL_FLAG_ZN_BIT,
        s2_flag_n_next when others; -- NOP/clr/set/PLP/RTI

  -- register A

  with s2_sel_reg_a select s2_reg_a <=
        s2_ls_dr_8    when SEL_REG_A_MEM, -- LDA mem
        s2_adder      when SEL_REG_A_ADD, -- ADC/SBC
        s2_logic      when SEL_REG_A_LOG, -- AND/OR/EOR
        s2_shift_a    when SEL_REG_A_SHF, -- ASL/LSR/ROL/ROR A
        s2_reg_a_next when others;        -- no change/LDA imm/TXA/TYA

  s2_reg_a_z <= '1' when s2_reg_a = x"00" else '0';

  -- register X

  with s2_sel_reg_x select s2_reg_x <=
        s2_ls_dr_8    when SEL_REG_X_MEM, -- LDX mem
        s2_reg_x_next when others;        -- no change/LDX imm/TAX/TSX

  s2_reg_x_z <= '1' when s2_reg_x = x"00" else '0';

  -- register Y

  with s2_sel_reg_y select s2_reg_y <=
        s2_ls_dr_8    when SEL_REG_Y_MEM, -- LDY mem
        s2_reg_y_next when others;        -- no change/LDY imm/TAY

  s2_reg_y_z <= '1' when s2_reg_y = x"00" else '0';

  -- interrupt vector cacheing
  -- 1 cycle delayed write timing is OK here because this happens
  -- under controlled circumstances (pre-reset code)

  VC: process (clk) is
  begin
    if rising_edge(clk) then
      if rst = '1' then
        vc_nmi_en <= (others => '0');
        vc_irq_en <= (others => '0');
        vc_brk_en <= (others => '0');
        vc_dw     <= (others => '0');
        vc_we     <= '0';
        vc_nmi    <= (others => '0');
        vc_irq    <= (others => '0');
        vc_brk    <= (others => '0');
      elsif advex = '1' then
        vc_nmi_en <= (others => '0');
        vc_irq_en <= (others => '0');
        vc_brk_en <= (others => '0');
        vc_dw     <= s1_ls_dw(7 downto 0);
        vc_we     <= s1_ls_we;
        if s1_ls_a = vec_nmi   then vc_nmi_en(0) <= '1'; end if;
        if s1_ls_a = vec_nmi+1 then vc_nmi_en(1) <= '1'; end if;
        if s1_ls_a = vec_irq   then vc_irq_en(0) <= '1'; end if;
        if s1_ls_a = vec_irq+1 then vc_irq_en(1) <= '1'; end if;
        if s1_ls_a = vec_brk   then vc_brk_en(0) <= '1'; end if;
        if s1_ls_a = vec_brk+1 then vc_brk_en(1) <= '1'; end if;
        if vc_we = '1' then
          if vc_nmi_en(0) = '1' then vc_nmi(7 downto 0) <= vc_dw; end if;
          if vc_nmi_en(1) = '1' then vc_nmi(15 downto 8) <= vc_dw; end if;
          if vc_irq_en(0) = '1' then vc_irq(7 downto 0) <= vc_dw; end if;
          if vc_irq_en(1) = '1' then vc_irq(15 downto 8) <= vc_dw; end if;
          if vc_brk_en(0) = '1' then vc_brk(7 downto 0) <= vc_dw; end if;
          if vc_brk_en(1) = '1' then vc_brk(15 downto 8) <= vc_dw; end if;
        end if;
      end if;
    end if;
  end process VC;

end architecture synth;
