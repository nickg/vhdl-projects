-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;

entity arbiter is
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		ibus_i : in  mem_in_type;
		ibus_o : out mem_out_type;
		dbus_i : in  mem_in_type;
		dbus_o : out mem_out_type;
		mem_o  : in  mem_out_type;
		mem_i  : out mem_in_type
	);
end arbiter;

architecture behavior of arbiter is

type state_type is (idle, instr, data);

type reg_type is record
	acc  : state_type;
	mem  : mem_in_type;
	imem : mem_in_type;
end record;

constant init_reg : reg_type := (
	acc  => idle,
	mem  => init_mem_in,
	imem => init_mem_in
);

signal r,rin : reg_type := init_reg;

begin

	process(r,ibus_i,dbus_i,mem_o)

	variable v : reg_type;

	begin

		v := r;

		if ibus_i.mem_valid = '1' then
			v.imem := ibus_i;
		end if;

		if r.acc = idle or mem_o.mem_ready = '1' then

			if dbus_i.mem_valid = '1' then
				v.acc := data;
				v.mem := dbus_i;
			elsif v.imem.mem_valid = '1' then
				v.acc := instr;
				v.mem := v.imem;
			else
				v.acc := idle;
				v.mem := init_mem_in;
			end if;

		end if;

		mem_i <= v.mem;

		rin <= v;

		if r.acc = instr then
			ibus_o  <= mem_o;
		else
			ibus_o <= init_mem_out;
		end if;

		if r.acc = data then
			dbus_o <= mem_o;
		else
			dbus_o <= init_mem_out;
		end if;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = reset_active then
				r <= init_reg;
			else
				r <= rin;
			end if;

		end if;

	end process;

end architecture;
