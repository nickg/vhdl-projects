-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;
use work.plic_wire.all;

package plic_lib is

	component plic_gw
		generic(
			plic_sources     : integer := plic_sources;
			plic_contexts    : integer := plic_contexts;
			plic_max_pending : integer := plic_max_pending;
			plic_level       : std_logic := plic_level;
			plic_edge        : std_logic := plic_edge
		);
		port(
			reset                 : in  std_logic;
			clock                 : in  std_logic;
			plic_gw_irq_src       : in  std_logic;
			plic_gw_irq_leveledge : in  std_logic;
			plic_gw_irq_claim     : in  std_logic;
			plic_gw_irq_complete  : in  std_logic;
			plic_gw_irq_request   : out std_logic
		);
	end component;

	component plic_core
		generic(
			plic_sources     : integer := plic_sources;
			plic_contexts    : integer := plic_contexts;
			plic_priorities  : integer := plic_priorities;
			plic_max_pending : integer := plic_max_pending
		);
		port(
			reset            : in  std_logic;
			clock            : in  std_logic;
			plic_core_irq_sp : in  irq_sp_type;
			plic_core_irq_pb : in  irq_pb_type;
			plic_core_irq_eb : in  irq_eb_type;
			plic_core_irq_pt : in  irq_pt_type;
			plic_core_irq_cl : out irq_cl_type;
			plic_core_irq_ip : out std_logic_vector(2**plic_contexts-1 downto 0)
		);
	end component;

end package;
