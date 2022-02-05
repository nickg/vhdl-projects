-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use work.configure.all;
use work.constants.all;
use work.functions.all;
use work.fp_wire.all;
use work.wire.all;

entity cpu is
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		mem_o   : in  mem_out_type;
		mem_i   : out mem_in_type;
		meip_i  : in  std_logic;
		msip_i  : in  std_logic;
		mtip_i  : in  std_logic;
		mtime_i : in  std_logic_vector(63 downto 0)
	);
end entity cpu;

architecture behavior of cpu is

	component core
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			ibus_o  : in  mem_out_type;
			ibus_i  : out mem_in_type;
			dbus_o  : in  mem_out_type;
			dbus_i  : out mem_in_type;
			meip_i  : in  std_logic;
			msip_i  : in  std_logic;
			mtip_i  : in  std_logic;
			mtime_i : in  std_logic_vector(63 downto 0)
		);
	end component;

	component arbiter
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
	end component;

	signal ibus_i : mem_in_type;
	signal ibus_o : mem_out_type;
	signal dbus_i : mem_in_type;
	signal dbus_o : mem_out_type;

begin

	core_comp : core
		port map(
			reset   => reset,
			clock   => clock,
			ibus_o  => ibus_o,
			ibus_i  => ibus_i,
			dbus_o  => dbus_o,
			dbus_i  => dbus_i,
			meip_i  => meip_i,
			msip_i  => msip_i,
			mtip_i  => mtip_i,
			mtime_i => mtime_i
		);

	arbiter_comp : arbiter
		port map(
			reset  => reset,
			clock  => clock,
			ibus_i => ibus_i,
			ibus_o => ibus_o,
			dbus_i => dbus_i,
			dbus_o => dbus_o,
			mem_o  => mem_o,
			mem_i  => mem_i
		);

end architecture;
