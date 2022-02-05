-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;

package dtim_wire is

	type dtim_tag_in_type is record
		raddr : integer range 0 to 2**dtim_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dtim_sets-1;
		wdata : std_logic_vector(60-(dtim_sets+dtim_words) downto 0);
	end record;

	type dtim_tag_out_type is record
		rdata : std_logic_vector(60-(dtim_sets+dtim_words) downto 0);
	end record;

	type dtim_data_in_type is record
		raddr : integer range 0 to 2**dtim_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dtim_sets-1;
		wdata : std_logic_vector((2**itim_words)*64-1 downto 0);
	end record;

	type dtim_data_out_type is record
		rdata : std_logic_vector((2**itim_words)*64-1 downto 0);
	end record;

	type dtim_lock_in_type is record
		raddr : integer range 0 to 2**dtim_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dtim_sets-1;
		wdata : std_logic;
	end record;

	type dtim_lock_out_type is record
		rdata : std_logic;
	end record;

	type dtim_valid_in_type is record
		raddr : integer range 0 to 2**dtim_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dtim_sets-1;
		wdata : std_logic;
	end record;

	type dtim_valid_out_type is record
		rdata : std_logic;
	end record;

	type dtim_ctrl_in_type is record
		tag_o   : dtim_tag_out_type;
		data_o  : dtim_data_out_type;
		lock_o  : dtim_lock_out_type;
		valid_o : dtim_valid_out_type;
	end record;

	type dtim_ctrl_out_type is record
		tag_i   : dtim_tag_in_type;
		data_i  : dtim_data_in_type;
		lock_i  : dtim_lock_in_type;
		valid_i : dtim_valid_in_type;
	end record;

end package;
