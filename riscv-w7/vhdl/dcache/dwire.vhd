-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;

package dwire is

	type ddata_in_type is record
		raddr : integer range 0 to 2**dcache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dcache_sets-1;
		wdata : std_logic_vector((2**dcache_words)*64-1 downto 0);
	end record;

	type ddata_out_type is record
		rdata : std_logic_vector((2**dcache_words)*64-1 downto 0);
	end record;

	type dtag_in_type is record
		raddr : integer range 0 to 2**dcache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dcache_sets-1;
		wdata : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
	end record;

	type dtag_out_type is record
		rdata :  std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
	end record;

	type ddata_o is array (0 to 2**dcache_ways-1) of ddata_out_type;
	type ddata_i is array (0 to 2**dcache_ways-1) of ddata_in_type;

	type dtag_o is array (0 to 2**dcache_ways-1) of dtag_out_type;
	type dtag_i is array (0 to 2**dcache_ways-1) of dtag_in_type;

	type dvalid_in_type is record
		raddr : integer range 0 to 2**dcache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dcache_sets-1;
		wdata : std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dvalid_out_type is record
		rdata :  std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dirty_in_type is record
		raddr : integer range 0 to 2**dcache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dcache_sets-1;
		wdata : std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dirty_out_type is record
		rdata :  std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dlock_in_type is record
		raddr : integer range 0 to 2**dcache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dcache_sets-1;
		wdata : std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dlock_out_type is record
		rdata :  std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type drandom_in_type is record
		miss  : std_logic;
	end record;

	type drandom_out_type is record
		wid   : integer range 0 to 2**dcache_ways-1;
	end record;

	type tag_array is array(0 to 2**dcache_ways-1) of std_logic_vector(60-(dcache_sets+dcache_words) downto 0);

	type dhit_in_type is record
		tag   : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
		tag_a : tag_array;
		valid : std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dhit_out_type is record
		hit   : std_logic;
		miss  : std_logic;
		wid   : integer range 0 to 2**dcache_ways-1;
	end record;

	type dctrl_in_type is record
		data_o  : ddata_o;
		tag_o   : dtag_o;
		valid_o : dvalid_out_type;
		dirty_o : dirty_out_type;
		lock_o  : dlock_out_type;
		rand_o  : drandom_out_type;
		hit_o   : dhit_out_type;
	end record;

	type dctrl_out_type is record
		data_i  : ddata_i;
		tag_i   : dtag_i;
		valid_i : dvalid_in_type;
		dirty_i : dirty_in_type;
		lock_i  : dlock_in_type;
		rand_i  : drandom_in_type;
		hit_i   : dhit_in_type;
	end record;

end package;
