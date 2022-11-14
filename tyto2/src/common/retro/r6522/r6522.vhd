--------------------------------------------------------------------------------
-- r6522.vhd                                  --
-- 6522 Versatile Interface Adapter.                      --
--------------------------------------------------------------------------------
-- (C) Copyright 2022 Adam Barnes <ambarnes@gmail.com>              --
-- This file is part of The Tyto Project. The Tyto Project is free software:  --
-- you can redistribute it and/or modify it under the terms of the GNU Lesser --
-- General Public License as published by the Free Software Foundation,     --
-- either version 3 of the License, or (at your option) any later version.    --
-- The Tyto Project is distributed in the hope that it will be useful, but    --
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public   --
-- License for more details. You should have received a copy of the GNU     --
-- Lesser General Public License along with The Tyto Project. If not, see   --
-- https://www.gnu.org/licenses/.                       --
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package r6522_pkg is

  -- 6522 register addresses
  constant R6522_RA_ORB   : std_logic_vector(3 downto 0) := x"0";
  constant R6522_RA_ORA   : std_logic_vector(3 downto 0) := x"1";
  constant R6522_RA_DDRB  : std_logic_vector(3 downto 0) := x"2";
  constant R6522_RA_DDRA  : std_logic_vector(3 downto 0) := x"3";
  constant R6522_RA_T1C_L : std_logic_vector(3 downto 0) := x"4";
  constant R6522_RA_T1C_H : std_logic_vector(3 downto 0) := x"5";
  constant R6522_RA_T1L_L : std_logic_vector(3 downto 0) := x"6";
  constant R6522_RA_T1L_H : std_logic_vector(3 downto 0) := x"7";
  constant R6522_RA_T2C_L : std_logic_vector(3 downto 0) := x"8";
  constant R6522_RA_T2C_H : std_logic_vector(3 downto 0) := x"9";
  constant R6522_RA_SR    : std_logic_vector(3 downto 0) := x"A";
  constant R6522_RA_ACR   : std_logic_vector(3 downto 0) := x"B";
  constant R6522_RA_PCR   : std_logic_vector(3 downto 0) := x"C";
  constant R6522_RA_IFR   : std_logic_vector(3 downto 0) := x"D";
  constant R6522_RA_IER   : std_logic_vector(3 downto 0) := x"E";
  constant R6522_RA_ORA_N : std_logic_vector(3 downto 0) := x"F";
  alias    R6522_RA_T2L_L : std_logic_vector(3 downto 0) is R6522_RA_T2C_L;
  alias    R6522_RA_IRB   : std_logic_vector(3 downto 0) is R6522_RA_ORB;
  alias    R6522_RA_IRA   : std_logic_vector(3 downto 0) is R6522_RA_ORA;
  alias    R6522_RA_IRA_N : std_logic_vector(3 downto 0) is R6522_RA_ORA_N;

  component r6522 is
    port (
      -- register interface
      cpu_clk    : in  std_logic;
      cpu_clken  : in  std_logic;
      cpu_rst    : in  std_logic;
      cpu_cs     : in  std_logic;
      cpu_we     : in  std_logic;
      cpu_rs     : in  std_logic_vector(3 downto 0);
      cpu_dw     : in  std_logic_vector(7 downto 0);
      cpu_dr     : out std_logic_vector(7 downto 0);
      cpu_irq    : out std_logic;
      -- I/O
      io_clk     : in  std_logic;
      io_clken   : in  std_logic;
      io_rst     : in  std_logic;
      io_pa_i    : in  std_logic_vector(7 downto 0);
      io_pa_o    : out std_logic_vector(7 downto 0);
      io_pa_dir  : out std_logic_vector(7 downto 0);
      io_ca1     : in  std_logic;
      io_ca2_i   : in  std_logic;
      io_ca2_o   : out std_logic;
      io_ca2_dir : out std_logic;
      io_pb_i    : in  std_logic_vector(7 downto 0);
      io_pb_o    : out std_logic_vector(7 downto 0);
      io_pb_dir  : out std_logic_vector(7 downto 0);
      io_cb1_i   : in  std_logic;
      io_cb1_o   : out std_logic;
      io_cb1_dir : out std_logic;
      io_cb2_i   : in  std_logic;
      io_cb2_o   : out std_logic;
      io_cb2_dir : out std_logic
    );
  end component r6522;

end package r6522_pkg;

--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.r6522_pkg.all;

entity r6522 is
  port (
    -- register interface
    cpu_clk    : in  std_logic;                     -- clock
    cpu_clken  : in  std_logic;                     -- clock enable
    cpu_rst    : in  std_logic;                     -- reset
    cpu_cs     : in  std_logic;                     -- chip select
    cpu_we     : in  std_logic;                     -- write enable
    cpu_rs     : in  std_logic_vector(3 downto 0);  -- register select
    cpu_dw     : in  std_logic_vector(7 downto 0);  -- write data
    cpu_dr     : out std_logic_vector(7 downto 0);  -- read data
    cpu_irq    : out std_logic;                     -- interrupt request
    -- I/O
    io_clk     : in  std_logic;                     -- clock      } typically
    io_clken   : in  std_logic;                     -- clock enable }  1MHz
    io_rst     : in  std_logic;                     -- reset
    io_pa_i    : in  std_logic_vector(7 downto 0);  -- port A inputs
    io_pa_o    : out std_logic_vector(7 downto 0);  -- port A outputs
    io_pa_dir  : out std_logic_vector(7 downto 0);  -- port A directions (1 = out)
    io_ca1     : in  std_logic;                     --
    io_ca2_i   : in  std_logic;                     --
    io_ca2_o   : out std_logic;                     --
    io_ca2_dir : out std_logic;                     --
    io_pb_i    : in  std_logic_vector(7 downto 0);  -- port B inputs
    io_pb_o    : out std_logic_vector(7 downto 0);  -- port B outputs
    io_pb_dir  : out std_logic_vector(7 downto 0);  -- port B directions (1 = out)
    io_cb1_i   : in  std_logic;                     --
    io_cb1_o   : out std_logic;                     --
    io_cb1_dir : out std_logic;                     --
    io_cb2_i   : in  std_logic;                     --
    io_cb2_o   : out std_logic;                     --
    io_cb2_dir : out std_logic                      --
  );
end entity r6522;

architecture behavioural of r6522 is

  -- registers
  signal irb   : std_logic_vector(7 downto 0);
  signal ira   : std_logic_vector(7 downto 0);
  signal orb   : std_logic_vector(7 downto 0);
  signal ora   : std_logic_vector(7 downto 0);
  signal ddrb  : std_logic_vector(7 downto 0);
  signal ddra  : std_logic_vector(7 downto 0);
  signal t1c   : std_logic_vector(15 downto 0);
  signal t1l   : std_logic_vector(15 downto 0);
  signal t2c   : std_logic_vector(15 downto 0);
  signal t2l_l : std_logic_vector(7 downto 0);
  signal sr    : std_logic_vector(7 downto 0);
  signal acr   : std_logic_vector(7 downto 0);
  signal pcr   : std_logic_vector(7 downto 0);
  signal ifr   : std_logic_vector(7 downto 0);
  signal ier   : std_logic_vector(7 downto 0);

  -- register byte and bit field aliases
  alias  t1c_l   : std_logic_vector(7 downto 0) is t1c(7 downto 0);
  alias  t1c_h   : std_logic_vector(7 downto 0) is t1c(15 downto 8);
  alias  t1l_l   : std_logic_vector(7 downto 0) is t1l(7 downto 0);
  alias  t1l_h   : std_logic_vector(7 downto 0) is t1l(15 downto 8);
  alias  t2c_l   : std_logic_vector(7 downto 0) is t2c(7 downto 0);
  alias  t2c_h   : std_logic_vector(7 downto 0) is t2c(15 downto 8);
  alias  pcr_cb2 : std_logic_vector(2 downto 0) is pcr(7 downto 5);
  alias  pcr_cb1 : std_logic                    is pcr(4);
  alias  pcr_ca2 : std_logic_vector(2 downto 0) is pcr(3 downto 1);
  alias  pcr_ca1 : std_logic                    is pcr(0);
  alias  acr_t1c : std_logic_vector(1 downto 0) is acr(7 downto 6);
  alias  acr_t2c : std_logic                    is acr(5);
  alias  acr_src : std_logic_vector(2 downto 0) is acr(4 downto 2);
  alias  acr_pbl : std_logic                    is acr(1);
  alias  acr_pal : std_logic                    is acr(0);
  alias  ifr_ca2 : std_logic                    is ifr(0);
  alias  ifr_ca1 : std_logic                    is ifr(1);
  alias  ifr_sr  : std_logic                    is ifr(2);
  alias  ifr_cb2 : std_logic                    is ifr(3);
  alias  ifr_cb1 : std_logic                    is ifr(4);
  alias  ifr_t2  : std_logic                    is ifr(5);
  alias  ifr_t1  : std_logic                    is ifr(6);
  alias  ier_ca2 : std_logic                    is ier(0);
  alias  ier_ca1 : std_logic                    is ier(1);
  alias  ier_sr  : std_logic                    is ier(2);
  alias  ier_cb2 : std_logic                    is ier(3);
  alias  ier_cb1 : std_logic                    is ier(4);
  alias  ier_t2  : std_logic                    is ier(5);
  alias  ier_t1  : std_logic                    is ier(6);

  -- register bit field constants
  constant PCR_C2_I_IRQN : std_logic_vector(2 downto 0) := "000";
  constant PCR_C2_I_INDN : std_logic_vector(2 downto 0) := "001";
  constant PCR_C2_I_IRQP : std_logic_vector(2 downto 0) := "010";
  constant PCR_C2_I_INDP : std_logic_vector(2 downto 0) := "011";
  constant PCR_C2_O_HSHK : std_logic_vector(2 downto 0) := "100";
  constant PCR_C2_O_PULS : std_logic_vector(2 downto 0) := "101";
  constant PCR_C2_O_LO   : std_logic_vector(2 downto 0) := "110";
  constant PCR_C2_O_HI   : std_logic_vector(2 downto 0) := "111";
  constant PCR_C1_N      : std_logic                    := '0';
  constant PCR_C1_P      : std_logic                    := '0';
  constant ACR_LE        : std_logic                    := '1';
  constant ACR_SRC_DIS   : std_logic_vector(2 downto 0) := "000";
  constant ACR_SRC_ICT2  : std_logic_vector(2 downto 0) := "001";
  constant ACR_SRC_ISCK  : std_logic_vector(2 downto 0) := "010";
  constant ACR_SRC_ICB2  : std_logic_vector(2 downto 0) := "011";
  constant ACR_SRC_OFT2  : std_logic_vector(2 downto 0) := "100";
  constant ACR_SRC_OCT2  : std_logic_vector(2 downto 0) := "101";
  constant ACR_SRC_OSCK  : std_logic_vector(2 downto 0) := "110";
  constant ACR_SRC_OCB1  : std_logic_vector(2 downto 0) := "111";
  constant ACR_T2_TIRQ   : std_logic                    := '0';
  constant ACR_T2_CPB6   : std_logic                    := '1';
  constant ACR_T1_ONCE   : std_logic_vector(1 downto 0) := "00";
  constant ACR_T1_CONT   : std_logic_vector(1 downto 0) := "01";
  constant ACR_T1_TPB7   : std_logic_vector(1 downto 0) := "10";
  constant ACR_T1_CPB7   : std_logic_vector(1 downto 0) := "11";

  -- register latches
  signal irb_lp : std_logic_vector(7 downto 0); -- PB inputs and active outputs latched by rising CB1
  signal irb_ln : std_logic_vector(7 downto 0); -- PB inputs and active outputs latched by falling CB1
  signal ira_lp : std_logic_vector(7 downto 0); -- PA inputs latched by rising CA1
  signal ira_ln : std_logic_vector(7 downto 0); -- PA inputs latched by falling CA1

  -- register access strobes
  signal ora_access : std_logic;
  signal orb_access : std_logic;
  signal t1c_l_read : std_logic;

  -- external interrupt sources
  signal irq_ca1_p : std_logic;
  signal irq_ca1_n : std_logic;
  signal irq_ca2_p : std_logic;
  signal irq_ca2_n : std_logic;
  signal irq_cb1_p : std_logic;
  signal irq_cb1_n : std_logic;
  signal irq_cb2_p : std_logic;
  signal irq_cb2_n : std_logic;

  -- interrupt clear strobes
  signal clr     : std_logic_vector(7 downto 0);
  alias  clr_ca2 : std_logic is clr(0);
  alias  clr_ca1 : std_logic is clr(1);
  alias  clr_sr  : std_logic is clr(2);
  alias  clr_cb2 : std_logic is clr(3);
  alias  clr_cb1 : std_logic is clr(4);
  alias  clr_t2  : std_logic is clr(5);
  alias  clr_t1  : std_logic is clr(6);

  -- shift register
  signal sr_load  : std_logic;
  signal sr_empty : std_logic;
  signal sr_clk   : std_logic;
  signal sr_clko  : std_logic;
  signal sr_dato  : std_logic;

begin

  --------------------------------------------------------------------------------
  -- register access

  process(cpu_clk)
  begin
    if rising_edge(cpu_clk) and cpu_clken = '1' then
      cpu_dr     <= (others => '0');
      orb_access <= '0';
      ora_access <= '0';
      t1c_l_read <= '0';
      clr        <= (others => '0');
      if cpu_rst = '1' then
        orb  <= (others => '0');
        ora  <= (others => '0');
        ddrb <= (others => '0');
        ddra <= (others => '0');
        acr  <= (others => '0');
        pcr  <= (others => '0');
        ifr  <= (others => '0');
        ier  <= (7 => '1', others => '0');
        clr  <= (others => '0');
      else
        if cpu_cs = '1' then
          case cpu_rs is
            when R6522_RA_ORB => orb_access <= '1';
            when R6522_RA_ORA => ora_access <= '0';
            when R6522_RA_T1C_L => t1c_l_read <= not cpu_we;
            when others => null;
          end case;
          if cpu_we = '1' then -- write
            case cpu_rs is
              when R6522_RA_ORB   => orb   <= cpu_dw;
              when R6522_RA_ORA   => ora   <= cpu_dw;
              when R6522_RA_DDRB  => ddrb  <= cpu_dw;
              when R6522_RA_DDRA  => ddra  <= cpu_dw;
              when R6522_RA_T1C_L => t1l_l <= cpu_dw;
              when R6522_RA_T1C_H => t1l_h <= cpu_dw; t1c_h <= cpu_dw; t1c_l <= t1l_l; clr_t1 <= '1';
              when R6522_RA_T1L_L => t1l_l <= cpu_dw;
              when R6522_RA_T1L_H => t1l_h <= cpu_dw;
              when R6522_RA_T2L_L => t2l_l <= cpu_dw;
              when R6522_RA_T2C_H => t2c_h <= cpu_dw; t2c_l <= t2l_l; clr_t2 <= '1';
              when R6522_RA_SR    => sr_load <= '1';
              when R6522_RA_ACR   => acr   <= cpu_dw;
              when R6522_RA_PCR   => pcr   <= cpu_dw;
              when R6522_RA_IFR   => clr   <= cpu_dw;
              when R6522_RA_IER   => ier   <= '1' & cpu_dw(6 downto 0);
              when R6522_RA_ORA_N => ora   <= cpu_dw;
              when others         => null;
            end case;
          else -- read
            case cpu_rs is
              when R6522_RA_IRB   => cpu_dr <= irb;
              when R6522_RA_IRA   => cpu_dr <= ira;
              when R6522_RA_DDRB  => cpu_dr <= ddrb;
              when R6522_RA_DDRA  => cpu_dr <= ddra;
              when R6522_RA_T1C_L => cpu_dr <= t1c_l; clr_t1 <= '1';
              when R6522_RA_T1C_H => cpu_dr <= t1c_h;
              when R6522_RA_T1L_L => cpu_dr <= t1l_l;
              when R6522_RA_T1L_H => cpu_dr <= t1l_h;
              when R6522_RA_T2C_L => cpu_dr <= t2c_l; clr_t2 <= '1';
              when R6522_RA_T2C_H => cpu_dr <= t2c_h;
              when R6522_RA_SR    => cpu_dr <= sr;
              when R6522_RA_ACR   => cpu_dr <= acr;
              when R6522_RA_PCR   => cpu_dr <= pcr;
              when R6522_RA_IFR   => cpu_dr <= clr;
              when R6522_RA_IER   => cpu_dr <= ier;
              when R6522_RA_IRA_N => cpu_dr <= ira;
              when others         => null;
            end case;
          end if;
         end if;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------------
  -- port A and B outputs

  io_pa_o <= ora;
  io_pa_dir <= ddra;

  process(orb,ddrb)
  begin
    io_pb_o <= orb;
    io_pb_dir <= ddrb;
    if acr_t1c = ACR_T1_TPB7 or acr_t1c = ACR_T1_CPB7 then
      io_pb_dir(7) <= '1';
      if ddrb(7) = '1'  then
        io_pb_o(7) <= '0'; -- TODO
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------------
  -- port A and B input registers with latching

  process(cpu_rst,io_ca1)
  begin
    if cpu_rst = '1' then
      ira_lp <= (others => '0');
    elsif rising_edge(io_ca1) then
      ira_lp <= io_pa_i;
    end if;
    if cpu_rst = '1' then
      ira_ln <= (others => '0');
    elsif falling_edge(io_ca1) then
      ira_ln <= io_pa_i;
    end if;
  end process;

  ira <=
    ira_lp when acr_pal = ACR_LE and pcr_ca1 = PCR_C1_P else
    ira_ln when acr_pal = ACR_LE and pcr_ca1 = PCR_C1_N else
    io_pa_i;

  process(cpu_rst,io_cb1_i)
  begin
    if cpu_rst = '1' then
      irb_lp <= (others => '0');
    elsif rising_edge(io_cb1_i) then
      irb_lp <= io_pb_i;
    end if;
    if cpu_rst = '1' then
      irb_ln <= (others => '0');
    elsif falling_edge(io_cb1_i) then
      irb_ln <= io_pb_i;
    end if;
  end process;

  gen_irb: for i in 0 to 7 generate
    irb(i) <=
      irb_lp(i) when acr_pbl = ACR_LE and pcr_cb1 = PCR_C1_P else
      irb_ln(i) when acr_pbl = ACR_LE and pcr_cb1 = PCR_C1_N else
      io_pb_i(i) when ddrb(i) = '0' else
      orb(i);
  end generate gen_irb;

  --------------------------------------------------------------------------------
  -- CA1

  process(io_ca1,clr_ca1,ora_access)
  begin
    if clr_ca1 = '1' or ora_access = '1' then
      irq_ca1_p <= '0';
    elsif rising_edge(io_ca1) then
      irq_ca1_p <= '1';
    end if;
    if clr_ca1 = '1' or ora_access = '1' then
      irq_ca1_n <= '0';
    elsif falling_edge(io_ca1) then
      irq_ca1_n <= '1';
    end if;
  end process;

  irq_ca1 <= irq_ca1_n when pcr_ca1 = PCR_C1_N else irq_ca1_p;

  --------------------------------------------------------------------------------
  -- CA2

  process(io_ca2_i,clr_ca2,ora_access)
  begin
    if clr_ca2 = '1' or (ora_access = '1' and (pcr_ca2 = PCR_C2_I_IRQN or pcr_ca2 = PCR_C2_I_IRQP)) then
      irq_ca2_p <= '0';
    elsif rising_edge(io_ca2_i) and (pcr_ca2 = PCR_C2_I_IRQP or pcr_ca2 = PCR_C2_I_INDP) then
      irq_ca2_p <= '1';
    end if;
    if clr_ca2 = '1' or (ora_access = '1' and (pcr_ca2 = PCR_C2_I_IRQN or pcr_ca2 = PCR_C2_I_IRQP)) then
      irq_ca2_n <= '0';
    elsif falling_edge(io_ca2_i) and (pcr_ca2 = PCR_C2_I_IRQN or pcr_ca2 = PCR_C2_I_INDN) then
      irq_ca2_n <= '1';
    end if;
  end process;

  irq_ca2 <=
    irq_ca2_n when (pcr_ca2 = PCR_C2_I_IRQN or pcr_ca2 = PCR_C2_I_INDN) else
    irq_ca2_p when (pcr_ca2 = PCR_C2_I_IRQP or pcr_ca2 = PCR_C2_I_INDP) else
    '0';

  io_ca2_dir <= '1' when
    pcr_ca2 = PCR_C2_O_HSHK or
    pcr_ca2 = PCR_C2_O_PULS or
    pcr_ca2 = PCR_C2_O_LO or
    pcr_ca2 = PCR_C2_O_HI
    else '0';

  io_ca2_o <=
    '0' when pcr_ca2 = PCR_C2_O_HSHK else -- TODO handshake
    '1' when pcr_ca2 = PCR_C2_O_PULS else -- TODO pulse
    '0' when pcr_ca2 = PCR_C2_O_LO   else
    '1' when pcr_ca2 = PCR_C2_O_HI   else
    '0';

  --------------------------------------------------------------------------------
  -- CB1

  process(io_cb1_i,clr_cb1,orb_access)
  begin
    if clr_cb1 = '1' or orb_access = '1' then
      irq_cb1_p <= '0';
    elsif rising_edge(io_cb1_i) then
      irq_cb1_p <= '1';
    end if;
    if clr_cb1 = '1' or orb_access = '1' then
      irq_cb1_n <= '0';
    elsif falling_edge(io_cb1_i) then
      irq_cb1_n <= '1';
    end if;
  end process;

  irq_cb1 <= irq_cb1_n when pcr_cb1 = PCR_C1_N else irq_cb1_p;

  io_cb1_o <= sr_clko when
    acr_src = ACR_SRC_ICT2  or
    acr_src = ACR_SRC_ISCK  or
    acr_src = ACR_SRC_OFT2  or
    acr_src = ACR_SRC_OCT2  or
    acr_src = ACR_SRC_OSCK
    else '0';

  io_cb1_dir <= '1' when
    acr_src = ACR_SRC_ICT2  or
    acr_src = ACR_SRC_ISCK  or
    acr_src = ACR_SRC_OFT2  or
    acr_src = ACR_SRC_OCT2  or
    acr_src = ACR_SRC_OSCK
    else '0';

   --------------------------------------------------------------------------------
  -- CB2

  process(io_cb2_i,clr_cb2,orb_access)
  begin
    if clr_cb2 = '1' or (orb_access = '1' and pcr(7) = '0' and pcr(5) = '1') then
      irq_cb2_p <= '0';
    elsif rising_edge(io_cb2_i) and pcr(7) = '0' then
      irq_cb2_p <= '1';
    end if;
    if clr_cb2 = '1' or (orb_access = '1' and pcr(7) = '0' and pcr(5) = '1') then
      irq_cb2_n <= '0';
    elsif falling_edge(io_cb2_i) and pcr(7) = '0' then
      irq_cb2_n <= '1';
    end if;
  end process;

  irq_cb2 <=
    irq_cb2_n when (pcr_cb2 = PCR_C2_I_IRQN or pcr_cb2 = PCR_C2_I_INDN) else
    irq_cb2_p when (pcr_cb2 = PCR_C2_I_IRQP or pcr_cb2 = PCR_C2_I_INDP) else
    '0';

  io_cb2_dir <= '1' when
    pcr_cb2 = PCR_C2_O_HSHK or
    pcr_cb2 = PCR_C2_O_PULS or
    pcr_cb2 = PCR_C2_O_LO or
    pcr_cb2 = PCR_C2_O_HI or
    acr_src = ACR_SRC_OFT2  or
    acr_src = ACR_SRC_OCT2  or
    acr_src = ACR_SRC_OSCK
    else '0';

  io_cb2_o <=
    '0'   when pcr_cb2 = PCR_C2_O_HSHK else -- TODO handshake
    '1'   when pcr_cb2 = PCR_C2_O_PULS else -- TODO pulse
    '0'   when pcr_cb2 = PCR_C2_O_LO   else
    '1'   when pcr_cb2 = PCR_C2_O_HI   else
    sr_dato when acr_src = ACR_SRC_OFT2  else
    sr_dato when acr_src = ACR_SRC_OCT2  else
    sr_dato when acr_src = ACR_SRC_OSCK  else
    '0';

  --------------------------------------------------------------------------------
  -- shift register
  -- mode 1: shift in on phi2 following rising CB1
  -- mode 2: ditto

  process(io_clk)
  begin
    if rising_edge(io_clk) and io_clken = '1' then
      case acr_src is

        when ACR_SRC_ICT2 => -- mode 1

        when ACR_SRC_ISCK => -- mode 2
          if sr_read = '1' then
            sr_busy <= '1';
          end if;
          if sr_read = '1' or sr_busy = '1' then
            sr_clko <= not sr_clko;
          end if;
          if sr_clko = '0' then
            sr_count = std_logic_vector(unsigned(sr_count)+1);
            if sr_count = "111" then
              sr_busy <= '0';
            end if;
          end if;

        when ACR_SRC_ICB2 =>
        when ACR_SRC_OFT2 =>
        when ACR_SRC_OCT2 =>
        when ACR_SRC_OSCK =>
        when ACR_SRC_OCB1 =>




    end if;
  end process;










  with acr_src select sr_clk <=
    io_cb1_i when ACR_SRC_DIS | ACR_SRC_ICB2 | ACR_SRC_OCB1,
    sr_clko  when others;




  process(io_clk)
  begin
    if falling_edge(io_clk) then
      if io_rst = '1' then

      elsif io_clken = '1' then
        sr_clk_1 <= sr_clk ;
        if sr_clk = '0' and sr_clk_1 = '1' then
        sr_dato <= sr(7); sr <= sr(6 downto 0) & '0';
        end if;

      end if;
    end if;

    if rising_edge(sr_clk) then
      sr_clko <=
      sr <= sr(6 downto 0) & io_cb2_i;
        when ACR_SRC_OFT2 | ACR_SRC_OCT2 | ACR_SRC_OSCK | ACR_SRC_OCB1 =>
          sr <= sr(6 downto 0) & '0';
          sr_dato <= sr(7)

    if falling_edge(sr_clk) then

    end if;

  end process;

  --------------------------------------------------------------------------------
  -- timer

  process(io_clk)
  begin
    if rising_edge(io_clk) and io_clken = '1' then

        t2 <= std_logic_vector(unsigned(t2)-1);
        if unsigned(not t2) = 0 then -- t2 = -1
          t2c <= t2l
        end if;



        if t1c = x"0000" then
          t1c <= t1l;
        else
          t1c <= std_logic_vector(unsigned(t1c)-1);
        end if;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------------
  -- IRQ

  cpu_irq <=
    ( ifr_ca2 and ier_ca2 ) or
    ( ifr_ca1 and ier_ca1 ) or
    ( ifr_sr  and ier_sr  ) or
    ( ifr_cb2 and ier_cb2 ) or
    ( ifr_cb1 and ier_cb1 ) or
    ( ifr_t2  and ier_t2  ) or
    ( ifr_t1  and ier_t1  );

  --------------------------------------------------------------------------------

end architecture behavioural;