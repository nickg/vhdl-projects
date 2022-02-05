-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.itim_wire.all;

entity itim is
	generic(
		itim_enable : boolean;
		itim_sets   : integer;
		itim_words  : integer
	);
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		itim_i : in  mem_in_type;
		itim_o : out mem_out_type;
		imem_o : in  mem_out_type;
		imem_i : out mem_in_type
	);
end itim;

architecture behavior of itim is

	component itim_tag is
		generic(
			itim_sets  : integer;
			itim_words : integer
		);
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			itag_i : in  itim_tag_in_type;
			itag_o : out itim_tag_out_type
		);
	end component;

	component itim_data is
		generic(
			itim_sets  : integer;
			itim_words : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			idata_i : in  itim_data_in_type;
			idata_o : out itim_data_out_type
		);
	end component;

	component itim_lock
		generic(
			itim_sets : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			ilock_i : in  itim_lock_in_type;
			ilock_o : out itim_lock_out_type
		);
	end component;

	component itim_ctrl is
		generic(
			itim_sets  : integer;
			itim_words : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			ictrl_i : in  itim_ctrl_in_type;
			ictrl_o : out itim_ctrl_out_type;
			itim_i  : in  mem_in_type;
			itim_o  : out mem_out_type;
			imem_o  : in  mem_out_type;
			imem_i  : out mem_in_type
		);
	end component;

	signal ictrl_i : itim_ctrl_in_type;
	signal ictrl_o : itim_ctrl_out_type;

begin

	ITIM_ENABLED : if itim_enable = true generate

		itim_tag_comp : itim_tag generic map (itim_sets  => itim_sets, itim_words  => itim_words) port map(reset => reset, clock => clock, itag_i => ictrl_o.tag_i, itag_o => ictrl_i.tag_o);

		itim_data_comp : itim_data generic map (itim_sets  => itim_sets, itim_words  => itim_words) port map(reset => reset, clock => clock, idata_i => ictrl_o.data_i, idata_o => ictrl_i.data_o);

		itim_lock_comp : itim_lock generic map (itim_sets  => itim_sets) port map(reset => reset, clock => clock, ilock_i => ictrl_o.lock_i, ilock_o => ictrl_i.lock_o);

		itim_ctrl_comp : itim_ctrl generic map (itim_sets  => itim_sets, itim_words  => itim_words) port map (reset => reset, clock => clock, ictrl_i => ictrl_i, ictrl_o => ictrl_o, itim_i => itim_i, itim_o => itim_o, imem_o => imem_o, imem_i => imem_i);

	end generate ITIM_ENABLED;

	ITIM_DISABLED : if itim_enable = false generate

		imem_i <= itim_i;

		itim_o <= imem_o;

	end generate ITIM_DISABLED;

end architecture;
