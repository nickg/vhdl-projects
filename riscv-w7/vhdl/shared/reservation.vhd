-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.reservation_wire.all;

entity reservation is
	generic(
		number_of_cores   : integer := number_of_cores;
		reservation_depth : integer := reservation_depth
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		soc_i : in  soc_in_type;
		soc_o : out soc_out_type;
		mem_o : in  mem_out_type;
		mem_i : out mem_in_type
	);
end reservation;

architecture behavior of reservation is

	component reservation_ctrl is
		generic(
			number_of_cores   : integer;
			reservation_depth : integer
		);
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			soc_i     : in  soc_in_type;
			soc_o     : out soc_out_type;
			mem_o     : in  mem_out_type;
			mem_i     : out mem_in_type;
			arbiter_o : in  arbiter_out_type;
			arbiter_i : out arbiter_in_type;
			set_o     : in  set_out_type;
			set_i     : out set_in_type;
			tag_o     : in  tag_out_type;
			tag_i     : out tag_in_type;
			pid_o     : in  pid_out_type;
			pid_i     : out pid_in_type
		);
	end component;

	component reservation_arbiter is
		generic(
			number_of_cores : in integer
		);
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			arbiter_i : in  arbiter_in_type;
			arbiter_o : out arbiter_out_type
		);
	end component;

	component reservation_set is
		generic(
			reservation_depth : integer
		);
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			set_i : in  set_in_type;
			set_o : out set_out_type
		);
	end component;

	component reservation_tag is
		generic(
			reservation_depth : integer
		);
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			tag_i : in  tag_in_type;
			tag_o : out tag_out_type
		);
	end component;

	component reservation_pid is
		generic(
			number_of_cores   : integer;
			reservation_depth : integer
		);
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			pid_i : in  pid_in_type;
			pid_o : out pid_out_type
		);
	end component;

	signal arbiter_i : arbiter_in_type;
	signal arbiter_o : arbiter_out_type;

	signal set_i : set_in_type;
	signal set_o : set_out_type;
	signal tag_i : tag_in_type;
	signal tag_o : tag_out_type;
	signal pid_i : pid_in_type;
	signal pid_o : pid_out_type;

begin

	reservation_ctrl_comp : reservation_ctrl
		generic map
		(
			number_of_cores   => number_of_cores,
			reservation_depth => reservation_depth
		)
		port map
		(
			reset     => reset,
			clock     => clock,
			soc_i     => soc_i,
			soc_o     => soc_o,
			mem_o     => mem_o,
			mem_i     => mem_i,
			arbiter_o => arbiter_o,
			arbiter_i => arbiter_i,
			set_o     => set_o,
			set_i     => set_i,
			tag_o     => tag_o,
			tag_i     => tag_i,
			pid_o     => pid_o,
			pid_i     => pid_i
		);

	reservation_arbiter_comp : reservation_arbiter
		generic map
		(
			number_of_cores => number_of_cores
		)
		port map
		(
			reset     => reset,
			clock     => clock,
			arbiter_i => arbiter_i,
			arbiter_o => arbiter_o
		);

	reservation_set_comp : reservation_set
		generic map
		(
			reservation_depth => reservation_depth
		)
		port map
		(
			reset => reset,
			clock => clock,
			set_i => set_i,
			set_o => set_o
		);

	reservation_tag_comp : reservation_tag
		generic map
		(
			reservation_depth => reservation_depth
		)
		port map
		(
			reset => reset,
			clock => clock,
			tag_i => tag_i,
			tag_o => tag_o
		);

	reservation_pid_comp : reservation_pid
		generic map
		(
			number_of_cores   => number_of_cores,
			reservation_depth => reservation_depth
		)
		port map
		(
			reset => reset,
			clock => clock,
			pid_i => pid_i,
			pid_o => pid_o
		);

end architecture;
