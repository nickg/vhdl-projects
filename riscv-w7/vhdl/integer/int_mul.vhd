-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.lzc_wire.all;
use work.int_constants.all;
use work.int_wire.all;
use work.int_types.all;

entity int_mul is
	generic(
		mul_performance : boolean := mul_performance
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		int_mul_i : in  int_mul_in_type;
		int_mul_o : out int_mul_out_type;
		lzc_o     : in  lzc_64_out_type;
		lzc_i     : out lzc_64_in_type
	);
end int_mul;

architecture behavior of int_mul is

	signal r : int_mul_reg_type := init_int_mul_reg;

	signal rin : int_mul_reg_type := init_int_mul_reg;

begin

	FAST : if mul_performance = true generate

		process(int_mul_i)
			variable data1      : std_logic_vector(64 downto 0);
			variable data2      : std_logic_vector(64 downto 0);
			variable result     : std_logic_vector(129 downto 0);
			variable op         : mul_operation_type;
			variable op1_signed : std_logic;
			variable op2_signed : std_logic;
			variable word       : std_logic;
			variable ready      : std_logic;

		begin
			data1 := '0' & int_mul_i.data1;
			data2 := '0' & int_mul_i.data2;
			op    := int_mul_i.op;
			word  := int_mul_i.word;

			op1_signed := op.alu_mul or
										op.alu_mulh or
										op.alu_mulhsu;
			op2_signed := op.alu_mul or
										op.alu_mulh;
			ready := int_mul_i.enable and
								(op.alu_mul or
								 op.alu_mulh or
								 op.alu_mulhu or
								 op.alu_mulhsu);

			if op1_signed = '1' then
				if word = '1' then
					data1(64 downto 32) := (others => data1(31));
				else
					data1(64) := data1(63);
				end if;
			end if;
			if op2_signed = '1' then
				if word = '1' then
					data2(64 downto 32) := (others => data2(31));
				else
					data2(64) := data2(63);
				end if;
			end if;

			result := std_logic_vector(signed(data1) * signed(data2));

			if word = '1' then
				result(63 downto 32) := (others => result(31));
			end if;

			if op.alu_mul = '1' then
				int_mul_o.result <= result(63 downto 0);
			else
				int_mul_o.result <= result(127 downto 64);
			end if;

			if int_mul_i.clear = '1' then
				int_mul_o.ready <= '0';
			else
				int_mul_o.ready <= ready;
			end if;

			lzc_i.a <= X"0000000000000000";

		end process;

	end generate FAST;

	SLOW : if mul_performance = false generate

		process(r, int_mul_i,lzc_o)
			variable v : int_mul_reg_type;

		begin
			v := r;

			case r.state is
				when MUL0 =>
					if (int_mul_i.enable and (int_mul_i.op.alu_mul or int_mul_i.op.alu_mulh or
							int_mul_i.op.alu_mulhu or int_mul_i.op.alu_mulhsu)) = '1' then
						v.state := MUL1;
					end if;
					v.ready := '0';
					if int_mul_i.clear = '1' then
						v.state := MUL0;
					end if;
				when MUL1 =>
					case r.counter is
						when 0 =>
							v.state := MUL2;
						when others =>
							v.counter := v.counter - 1;
					end case;
					v.ready := '0';
					if int_mul_i.clear = '1' then
						v.state := MUL0;
					end if;
				when others =>
					v.state := MUL0;
					v.ready := '1';
					if int_mul_i.clear = '1' then
						v.ready := '0';
					end if;
			end case;

			case r.state is
				when MUL0 =>
					v.op := int_mul_i.op;
					v.word := int_mul_i.word;
					v.neg := '0';
					if v.op.alu_mulhu = '1' then
						v.aa := int_mul_i.data1;
					else
						if int_mul_i.data1(63) = '1' then
							v.aa := std_logic_vector(-signed(int_mul_i.data1));
							v.neg := not v.neg;
						else
							v.aa := int_mul_i.data1;
						end if;
					end if;
					if (v.op.alu_mulhu or v.op.alu_mulhsu) = '1' then
						v.bb := int_mul_i.data2;
					else
						if int_mul_i.data2(63) = '1' then
							v.bb := std_logic_vector(-signed(int_mul_i.data2));
							v.neg := not v.neg;
						else
							v.bb := int_mul_i.data2;
						end if;
					end if;
					lzc_i.a <= v.aa;
					if (int_mul_i.op.alu_mul or int_mul_i.op.alu_mulh or
							int_mul_i.op.alu_mulhu or int_mul_i.op.alu_mulhsu) = '1' then
						v.counter := to_integer(unsigned(not(lzc_o.c)));
					end if;
					v.counter := 63 - v.counter;
					v.rr := (others => '0');
				when MUL1 =>
					lzc_i.a <= X"0000000000000000";
					v.rr := v.rr(126 downto 0) & '0';
					if v.aa(r.counter) = '1' then
						v.rr := std_logic_vector(unsigned(v.rr) + unsigned(v.bb));
					end if;
				when others =>
					lzc_i.a <= X"0000000000000000";
					if v.neg = '1' then
						v.rr := std_logic_vector(-signed(v.rr));
					end if;
					if v.op.alu_mul = '1' then
						v.result := v.rr(63 downto 0);
					else
						v.result := v.rr(127 downto 64);
					end if;
					if v.word = '1' then
						v.result(63 downto 32) := (others => v.result(31));
					end if;
			end case;

			int_mul_o.result <= v.result;
			int_mul_o.ready <= v.ready;

			rin <= v;

		end process;

		process(clock)
		begin
			if rising_edge(clock) then

				if reset = reset_active then

					r <= init_int_mul_reg;

				else

					r <= rin;

				end if;

			end if;

		end process;

	end generate SLOW;

end architecture;
