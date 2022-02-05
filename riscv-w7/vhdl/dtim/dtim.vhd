-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.dtim_wire.all;

entity dtim is
	generic(
		dtim_enable : boolean;
		dtim_sets   : integer;
		dtim_words  : integer
	);
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		dtim_i : in  mem_in_type;
		dtim_o : out mem_out_type;
		dmem_o : in  mem_out_type;
		dmem_i : out mem_in_type
	);
end dtim;

architecture behavior of dtim is

	component dtim_tag is
		generic(
			dtim_sets  : integer;
			dtim_words : integer
		);
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			dtag_i : in  dtim_tag_in_type;
			dtag_o : out dtim_tag_out_type
		);
	end component;

	component dtim_data is
		generic(
			dtim_sets  : integer;
			dtim_words : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			ddata_i : in  dtim_data_in_type;
			ddata_o : out dtim_data_out_type
		);
	end component;

	component dtim_lock
		generic(
			dtim_sets : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			dlock_i : in  dtim_lock_in_type;
			dlock_o : out dtim_lock_out_type
		);
	end component;

	component dtim_valid
		generic(
			dtim_sets : integer
		);
		port(
			reset    : in  std_logic;
			clock    : in  std_logic;
			dvalid_i : in  dtim_valid_in_type;
			dvalid_o : out dtim_valid_out_type
		);
	end component;

	component dtim_ctrl is
		generic(
			dtim_sets  : integer;
			dtim_words : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			dctrl_i : in  dtim_ctrl_in_type;
			dctrl_o : out dtim_ctrl_out_type;
			dtim_i  : in  mem_in_type;
			dtim_o  : out mem_out_type;
			dmem_o  : in  mem_out_type;
			dmem_i  : out mem_in_type
		);
	end component;

	signal dctrl_i : dtim_ctrl_in_type;
	signal dctrl_o : dtim_ctrl_out_type;

begin

	DTIM_ENABLED : if dtim_enable = true generate

		dtim_tag_comp : dtim_tag generic map (dtim_sets  => dtim_sets, dtim_words  => dtim_words) port map(reset => reset, clock => clock, dtag_i => dctrl_o.tag_i, dtag_o => dctrl_i.tag_o);

		dtim_data_comp : dtim_data generic map (dtim_sets  => dtim_sets, dtim_words  => dtim_words) port map(reset => reset, clock => clock, ddata_i => dctrl_o.data_i, ddata_o => dctrl_i.data_o);

		dtim_lock_comp : dtim_lock generic map (dtim_sets  => dtim_sets) port map(reset => reset, clock => clock, dlock_i => dctrl_o.lock_i, dlock_o => dctrl_i.lock_o);

		dtim_valid_comp : dtim_valid generic map (dtim_sets  => dtim_sets) port map(reset => reset, clock => clock, dvalid_i => dctrl_o.valid_i, dvalid_o => dctrl_i.valid_o);

		dtim_ctrl_comp : dtim_ctrl generic map (dtim_sets  => dtim_sets, dtim_words  => dtim_words) port map (reset => reset, clock => clock, dctrl_i => dctrl_i, dctrl_o => dctrl_o, dtim_i => dtim_i, dtim_o => dtim_o, dmem_o => dmem_o, dmem_i => dmem_i);

	end generate DTIM_ENABLED;

	DTIM_DISABLED : if dtim_enable = false generate

		dmem_i <= dtim_i;

		dtim_o <= dmem_o;

	end generate DTIM_DISABLED;

end architecture;
