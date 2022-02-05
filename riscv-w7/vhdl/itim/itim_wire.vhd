-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;

package itim_wire is

	type itim_tag_in_type is record
		raddr : integer range 0 to 2**itim_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**itim_sets-1;
		wdata : std_logic_vector(60-(itim_sets+itim_words) downto 0);
	end record;

	type itim_tag_out_type is record
		rdata : std_logic_vector(60-(itim_sets+itim_words) downto 0);
	end record;

	type itim_data_in_type is record
		raddr : integer range 0 to 2**itim_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**itim_sets-1;
		wdata : std_logic_vector((2**itim_words)*64-1 downto 0);
	end record;

	type itim_data_out_type is record
		rdata : std_logic_vector((2**itim_words)*64-1 downto 0);
	end record;

	type itim_lock_in_type is record
		raddr : integer range 0 to 2**itim_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**itim_sets-1;
		wdata : std_logic;
	end record;

	type itim_lock_out_type is record
		rdata : std_logic;
	end record;

	type itim_ctrl_in_type is record
		tag_o  : itim_tag_out_type;
		data_o : itim_data_out_type;
		lock_o : itim_lock_out_type;
	end record;

	type itim_ctrl_out_type is record
		tag_i  : itim_tag_in_type;
		data_i : itim_data_in_type;
		lock_i : itim_lock_in_type;
	end record;

end package;
