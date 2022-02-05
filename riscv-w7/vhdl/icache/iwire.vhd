-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;

package iwire is

	type idata_in_type is record
		raddr : integer range 0 to 2**icache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**icache_sets-1;
		wdata : std_logic_vector((2**icache_words)*64-1 downto 0);
	end record;

	type idata_out_type is record
		rdata : std_logic_vector((2**icache_words)*64-1 downto 0);
	end record;

	type itag_in_type is record
		raddr : integer range 0 to 2**icache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**icache_sets-1;
		wdata : std_logic_vector(60-(icache_sets+icache_words) downto 0);
	end record;

	type itag_out_type is record
		rdata :  std_logic_vector(60-(icache_sets+icache_words) downto 0);
	end record;

	type idata_o is array (0 to 2**icache_ways-1) of idata_out_type;
	type idata_i is array (0 to 2**icache_ways-1) of idata_in_type;

	type itag_o is array (0 to 2**icache_ways-1) of itag_out_type;
	type itag_i is array (0 to 2**icache_ways-1) of itag_in_type;

	type ivalid_in_type is record
		raddr : integer range 0 to 2**icache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**icache_sets-1;
		wdata : std_logic_vector(2**icache_ways-1 downto 0);
	end record;

	type ivalid_out_type is record
		rdata :  std_logic_vector(2**icache_ways-1 downto 0);
	end record;

	type irandom_in_type is record
		miss  : std_logic;
	end record;

	type irandom_out_type is record
		wid   : integer range 0 to 2**icache_ways-1;
	end record;

	type tag_array is array(0 to 2**icache_ways-1) of std_logic_vector(60-(icache_sets+icache_words) downto 0);

	type ihit_in_type is record
		tag   : std_logic_vector(60-(icache_sets+icache_words) downto 0);
		tag_a : tag_array;
		valid : std_logic_vector(2**icache_ways-1 downto 0);
	end record;

	type ihit_out_type is record
		hit   : std_logic;
		miss  : std_logic;
		wid   : integer range 0 to 2**icache_ways-1;
	end record;

	type ictrl_in_type is record
		data_o  : idata_o;
		tag_o   : itag_o;
		valid_o : ivalid_out_type;
		rand_o  : irandom_out_type;
		hit_o   : ihit_out_type;
	end record;

	type ictrl_out_type is record
		data_i  : idata_i;
		tag_i   : itag_i;
		valid_i : ivalid_in_type;
		rand_i  : irandom_in_type;
		hit_i   : ihit_in_type;
	end record;

end package;
