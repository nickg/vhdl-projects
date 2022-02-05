-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.bit_types.all;
use work.bit_wire.all;

entity bit_clmul is
	port(
		reset       : in  std_logic;
		clock       : in  std_logic;
		bit_clmul_i : in  bit_clmul_in_type;
		bit_clmul_o : out bit_clmul_out_type
	);
end bit_clmul;

architecture behavior of bit_clmul is

	signal r : bit_clmul_reg_type := init_bit_clmul_reg;
	signal rin : bit_clmul_reg_type := init_bit_clmul_reg;

begin

	process(r, bit_clmul_i)

		variable v : bit_clmul_reg_type;

	begin
		v := r;

		case r.state is
			when CLMUL0 =>
				if (bit_clmul_i.enable and (bit_clmul_i.op.bit_clmul or bit_clmul_i.op.bit_clmulh or
						bit_clmul_i.op.bit_clmulr)) = '1' then
					v.state := CLMUL1;
				end if;
				v.ready := '0';
				if bit_clmul_i.clear = '1' then
					v.state := CLMUL0;
				end if;
			when CLMUL1 =>
				case r.counter is
					when 63 =>
						v.state := CLMUL2;
					when others =>
						v.counter := v.counter + 1;
				end case;
				v.ready := '0';
				if bit_clmul_i.clear = '1' then
					v.state := CLMUL0;
				end if;
			when others =>
				v.state := CLMUL0;
				v.ready := '1';
				if bit_clmul_i.clear = '1' then
					v.ready := '0';
				end if;
		end case;

		case r.state is
			when CLMUL0 =>
				v.data1 := bit_clmul_i.data1;
				v.data2 := bit_clmul_i.data2;
				v.op := bit_clmul_i.op;
				v.counter := 0;
				if v.op.bit_clmulh = '1' then
					v.index := 64;
				elsif v.op.bit_clmulr = '1' then
					v.index := 63;
				end if;
				v.swap := (others => '0');
				v.result := (others => '0');
			when CLMUL1 =>
				if v.data2(r.counter) = '1' then
					if v.op.bit_clmul = '1' then
						v.swap := std_logic_vector(shift_left(unsigned(v.data1),r.counter));
					elsif v.op.bit_clmulh = '1' or v.op.bit_clmulr = '1' then
						v.swap := std_logic_vector(shift_right(unsigned(v.data1),r.index-r.counter));
					end if;
					v.result := v.result xor v.swap;
				end if;
			when others =>
				null;
		end case;

		bit_clmul_o.result <= v.result;
		bit_clmul_o.ready <= v.ready;

		rin <= v;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = reset_active then

				r <= init_bit_clmul_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
