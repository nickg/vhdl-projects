-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.functions.all;
use work.lzc_wire.all;
use work.int_constants.all;
use work.int_wire.all;
use work.int_types.all;

entity int_div is
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		int_div_i : in  int_div_in_type;
		int_div_o : out int_div_out_type;
		lzc_o     : in  lzc_64_out_type;
		lzc_i     : out lzc_64_in_type
	);
end int_div;

architecture behavior of int_div is

	signal r   : int_div_reg_type := init_int_div_reg;
	signal rin : int_div_reg_type := init_int_div_reg;

begin

	process(r, int_div_i,lzc_o)
		variable v : int_div_reg_type;

	begin
		v := r;

		case r.state is
			when DIV0 =>
				if (int_div_i.enable and (int_div_i.op.alu_div or int_div_i.op.alu_divu or
						int_div_i.op.alu_rem or int_div_i.op.alu_remu)) = '1' then
					v.state := DIV1;
				end if;
				v.ready := '0';
				if int_div_i.clear = '1' then
					v.state := DIV0;
				end if;
			when DIV1 =>
				case r.counter is
					when 0 =>
						v.state := DIV2;
					when others =>
						v.counter := v.counter - 1;
				end case;
				v.ready := '0';
				if int_div_i.clear = '1' then
					v.state := DIV0;
				end if;
			when others =>
				v.state := DIV0;
				v.ready := '1';
				if int_div_i.clear = '1' then
					v.ready := '0';
				end if;
		end case;

		case r.state is
			when DIV0 =>
				v.dividend := int_div_i.data1;
				v.op := int_div_i.op;
				v.word := int_div_i.word;
				v.data1 := int_div_i.data1;
				v.data2 := int_div_i.data2;
				v.negdiv := '0';
				v.negrem := '0';
				v.overflow := '0';
				v.divbyzero := to_std_logic(v.data2 = zero);
				if (v.op.alu_div or v.op.alu_rem) = '1' then
					v.negdiv := v.data1(63) xor v.data2(63);
					if v.data1(63) = '1' then
						v.data1 := std_logic_vector(-signed(v.data1));
						v.negrem := '1';
					end if;
					if v.data2(63) = '1' then
						v.data2 := std_logic_vector(-signed(v.data2));
					end if;
					v.overflow := to_std_logic(v.data1 = overflow_sign and v.data2 = overflow);
				end if;
				lzc_i.a <= v.data1;
				if (int_div_i.op.alu_div or int_div_i.op.alu_divu or
						int_div_i.op.alu_rem or int_div_i.op.alu_remu) = '1' then
					v.counter := to_integer(unsigned(not(lzc_o.c)));
					v.data1 := std_logic_vector(shift_left(unsigned(v.data1),v.counter));
				end if;
				v.counter := 63 - v.counter;
				v.aq := (128 downto 64 => '0') & v.data1;
				v.m := '0' & v.data2;
			when DIV1 =>
				lzc_i.a <= X"0000000000000000";
				v.aq := v.aq(127 downto 0) & '0';
				v.a := std_logic_vector(signed(v.aq(128 downto 64)) - signed(v.m));
				if v.a(64) = '0' then
					v.aq(0) := '1';
					v.aq(128 downto 64) := v.a;
				end if;
			when others =>
				lzc_i.a <= X"0000000000000000";
				if v.negdiv = '1' then
					v.aq(63 downto 0) := std_logic_vector(-signed(v.aq(63 downto 0)));
				end if;
				if v.negrem = '1' then
					v.aq(127 downto 64) := std_logic_vector(-signed(v.aq(127 downto 64)));
				end if;
				if v.divbyzero = '1' then
					v.aq(63 downto 0) := overflow;
					v.aq(127 downto 64) := v.dividend;
				end if;
				if v.overflow = '1' then
					v.aq(63 downto 0) := overflow_sign;
					v.aq(127 downto 64) := (others => '0');
				end if;
				if (v.op.alu_div or v.op.alu_divu) = '1' then
					v.result := v.aq(63 downto 0);
				else
					v.result := v.aq(127 downto 64);
				end if;
				if v.word = '1' then
					v.result(63 downto 32) := (others => v.result(31));
				end if;
		end case;

		int_div_o.result <= v.result;
		int_div_o.ready <= v.ready;

		rin <= v;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = reset_active then

				r <= init_int_div_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
