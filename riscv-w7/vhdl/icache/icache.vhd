-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;
use work.iwire.all;

entity icache is
	generic(
		cache_enable : boolean;
		cache_sets   : integer;
		cache_ways   : integer;
		cache_words  : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		cache_i : in  mem_in_type;
		cache_o : out mem_out_type;
		mem_o   : in  mem_out_type;
		mem_i   : out mem_in_type
	);
end icache;

architecture behavior of icache is

	component idata
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			data_i : in  idata_in_type;
			data_o : out idata_out_type
		);
	end component;

	component itag
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			tag_i : in  itag_in_type;
			tag_o : out itag_out_type
		);
	end component;

	component ivalid
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			valid_i : in  ivalid_in_type;
			valid_o : out ivalid_out_type
		);
	end component;

	component irandom
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset    : in  std_logic;
			clock    : in  std_logic;
			random_i : in  irandom_in_type;
			random_o : out irandom_out_type
		);
	end component;

	component ihit
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			hit_i : in  ihit_in_type;
			hit_o : out ihit_out_type
		);
	end component;

	component ictrl
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			ctrl_i  : in  ictrl_in_type;
			ctrl_o  : out ictrl_out_type;
			cache_i : in  mem_in_type;
			cache_o : out mem_out_type;
			mem_o   : in  mem_out_type;
			mem_i   : out mem_in_type
		);
	end component;

	signal ctrl_i : ictrl_in_type;
	signal ctrl_o : ictrl_out_type;

begin

	CACHE_ENABLED : if cache_enable = true generate

		DATA : for i in 0 to 2**cache_ways-1 generate
			data_comp : idata generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, data_i => ctrl_o.data_i(i), data_o => ctrl_i.data_o(i));
		end generate DATA;

		TAG : for i in 0 to 2**cache_ways-1 generate
			tag_comp : itag generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, tag_i => ctrl_o.tag_i(i), tag_o => ctrl_i.tag_o(i));
		end generate TAG;

		valid_comp : ivalid generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, valid_i => ctrl_o.valid_i, valid_o => ctrl_i.valid_o);

		hit_comp : ihit generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, hit_i => ctrl_o.hit_i, hit_o => ctrl_i.hit_o);

		random_comp : irandom generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, random_i => ctrl_o.rand_i, random_o => ctrl_i.rand_o);

		ictrl_comp : ictrl generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map (reset => reset, clock => clock, ctrl_i => ctrl_i, ctrl_o => ctrl_o, cache_i => cache_i, cache_o => cache_o, mem_o => mem_o, mem_i => mem_i);

	end generate CACHE_ENABLED;

	CACHE_DISABLED : if cache_enable = false generate

		mem_i <= cache_i;

		cache_o <= mem_o;

	end generate CACHE_DISABLED;

end architecture;
