-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_cons.all;

package fp_typ is

	type f_state_type is (F0, F1, F2, F3, F4);

end package;
