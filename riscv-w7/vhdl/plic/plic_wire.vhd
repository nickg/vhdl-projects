-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;

package plic_wire is

	type irq_sp_type is array (0 to 2**plic_sources-1) of std_logic_vector(31 downto 0);                              -- interrupt source priorities
	type irq_pb_type is array (0 to 2**plic_sources/32-1) of std_logic_vector(31 downto 0);                           -- interrupt pending bits
	type irq_eb_type is array (0 to 2**plic_contexts-1,0 to 2**plic_sources/32-1) of std_logic_vector(31 downto 0);   -- interrupt enable bits
	type irq_pt_type is array (0 to 2**plic_contexts-1) of std_logic_vector(31 downto 0);                             -- interrupt priority thresholds
	type irq_cl_type is array (0 to 2**plic_contexts-1) of std_logic_vector(31 downto 0);                             -- interrupt claim
	type irq_co_type is array (0 to 2**plic_contexts-1) of std_logic_vector(31 downto 0);                             -- interrupt completion

	type irq_mp_type is array (0 to 2**plic_contexts-1,0 to 2**plic_sources-1) of std_logic_vector(31 downto 0);      -- maximum priority
	type irq_mi_type is array (0 to 2**plic_contexts-1,0 to 2**plic_sources-1) of std_logic_vector(31 downto 0);      -- maximum id

end package;
