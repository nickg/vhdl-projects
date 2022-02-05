-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package bit_types is

	type clmul_state_type is (CLMUL0, CLMUL1, CLMUL2);

end package;
