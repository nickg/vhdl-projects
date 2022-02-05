-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package int_types is

	type div_state_type is (DIV0, DIV1, DIV2);
	type mul_state_type is (MUL0, MUL1, MUL2);

end package;
