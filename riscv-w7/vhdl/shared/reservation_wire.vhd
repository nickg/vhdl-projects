-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;

package reservation_wire is

	type set_in_type is record
		raddr : integer range 0 to 2**reservation_depth-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**reservation_depth-1;
		wdata : std_logic_vector(7 downto 0);
	end record;

	type set_out_type is record
		rdata : std_logic_vector(7 downto 0);
	end record;

	type pid_in_type is record
		raddr : integer range 0 to 2**reservation_depth-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**reservation_depth-1;
		wdata : integer range 0 to 2**number_of_cores-1;
	end record;

	type pid_out_type is record
		rdata : integer range 0 to 2**number_of_cores-1;
	end record;

	type tag_in_type is record
		raddr : integer range 0 to 2**reservation_depth-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**reservation_depth-1;
		wdata : std_logic_vector(60 downto 0);
	end record;

	type tag_out_type is record
		rdata : std_logic_vector(60 downto 0);
	end record;

	type arbiter_in_type is record
		requests : std_logic_vector(2**number_of_cores-1 downto 0);
		enable   : std_logic;
	end record;

	type arbiter_out_type is record
		grants : std_logic_vector(2**number_of_cores-1 downto 0);
	end record;

	type thermometer_type is array (0 to 1) of std_logic_vector(2**number_of_cores-1 downto 0);

end package;
