-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lzc_wire.all;
use work.atom_constants.all;
use work.atom_wire.all;

package atom_library is

	component atom_decode
		port(
			atom_decode_i : in  atom_decode_in_type;
			atom_decode_o : out atom_decode_out_type
		);
	end component;

	component atom_alu
		port(
			atom_alu_i : in  atom_alu_in_type;
			atom_alu_o : out atom_alu_out_type
		);
	end component;

end package;
