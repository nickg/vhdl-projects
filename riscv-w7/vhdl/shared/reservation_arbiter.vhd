-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.reservation_wire.all;
use work.reservation_func.all;

entity reservation_arbiter is
	generic(
		number_of_cores : in integer
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		arbiter_i : in  arbiter_in_type;
		arbiter_o : out arbiter_out_type
	);
end reservation_arbiter;

architecture behavior of reservation_arbiter is

	type register_type is record
		req : std_logic_vector(2**number_of_cores-1 downto 0);
		pri : std_logic_vector(2**number_of_cores-1 downto 0);
		red : std_logic_vector(2**number_of_cores-1 downto 0);
		upd : std_logic_vector(2**number_of_cores-1 downto 0);
		gnt : std_logic_vector(2**number_of_cores-1 downto 0);
		th  : thermometer_type;
		ag  : std_logic;
		en  : std_logic;
	end record;

	constant init_register : register_type := (
		req => (others => '0'),
		pri => (others => '1'),
		red => (others => '0'),
		upd => (others => '0'),
		gnt => (others => '0'),
		th  => (others => (others => '0')),
		ag  => '0',
		en  => '0'
	);

	signal r,rin : register_type := init_register;

begin

	process(r,arbiter_i)

	variable v : register_type;

	begin

		v := r;

		v.req := arbiter_i.requests;
		v.en := arbiter_i.enable;

		v.th := thermometer(v.req,v.pri);

		v.red := reduction(v.th);

		v.gnt := fixed_priority(v.red);

		v.ag := or_reduce(v.gnt);

		v.upd := v.gnt(0) & v.gnt(2**number_of_cores-1 downto 1);

		if (v.ag and v.en) = '1' then
			v.pri := v.upd;
		end if;

		rin <= v;

		arbiter_o.grants <= v.gnt;

	end process;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then
				r <= init_register;
			else
				r <= rin;
			end if;

		end if;

	end process;

end architecture;
