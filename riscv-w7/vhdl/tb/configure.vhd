-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package configure is

	constant reset_active      : std_logic := '0';

	constant number_of_cores   : integer := 0;
	constant reservation_depth : integer := 0;

	constant bram_depth        : integer := 15;
	constant bram_latency      : integer := 0;

	constant bus_words         : integer := 2;

	constant icache_enable     : boolean := true;
	constant icache_sets       : integer := 10;
	constant icache_ways       : integer := 1;
	constant icache_words      : integer := 2;

	constant dcache_enable     : boolean := true;
	constant dcache_sets       : integer := 9;
	constant dcache_ways       : integer := 2;
	constant dcache_words      : integer := 2;

	constant itim_enable       : boolean := true;
	constant itim_sets         : integer := 11;
	constant itim_words        : integer := 2;

	constant dtim_enable       : boolean := true;
	constant dtim_sets         : integer := 11;
	constant dtim_words        : integer := 2;

	constant bp_enable         : boolean := true;
	constant btb_depth         : integer := 6;
	constant bht_depth         : integer := 6;
	constant ras_depth         : integer := 2;

	constant fetchbuffer_depth : integer := 4;
	constant storebuffer_depth : integer := 4;

	constant fpu_enable        : boolean := true;
	constant fpu_performance   : boolean := true;
	constant mul_performance   : boolean := true;

	constant pmp_enable        : boolean := true;
	constant pmp_regions       : integer := 8;

	constant clint_contexts    : integer := number_of_cores;

	constant plic_sources      : integer := 5;
	constant plic_contexts     : integer := number_of_cores;
	constant plic_priorities   : integer := 3;
	constant plic_max_pending  : integer := 4;
	constant plic_level        : std_logic := '0';
	constant plic_edge         : std_logic := '1';

	constant bram_base_addr    : std_logic_vector(63 downto 0) := X"0000000000000000";
	constant bram_top_addr     : std_logic_vector(63 downto 0) := X"0000000000040000";

	constant print_base_addr   : std_logic_vector(63 downto 0) := X"0000000000100000";
	constant print_top_addr    : std_logic_vector(63 downto 0) := X"0000000000100004";

	constant clint_base_addr   : std_logic_vector(63 downto 0) := X"0000000002000000";
	constant clint_top_addr    : std_logic_vector(63 downto 0) := X"000000000200C000";

	constant plic_base_addr    : std_logic_vector(63 downto 0) := X"000000000C000000";
	constant plic_top_addr     : std_logic_vector(63 downto 0) := X"0000000010000000";

	constant itim_base_addr    : std_logic_vector(63 downto 0) := X"0000000010000000";
	constant itim_top_addr     : std_logic_vector(63 downto 0) := X"0000000100000000";

	constant dtim_base_addr    : std_logic_vector(63 downto 0) := X"0000000010000000";
	constant dtim_top_addr     : std_logic_vector(63 downto 0) := X"0000000100000000";

	constant icache_base_addr  : std_logic_vector(63 downto 0) := X"0000000100000000";
	constant icache_top_addr   : std_logic_vector(63 downto 0) := X"0000001000000000";

	constant dcache_base_addr  : std_logic_vector(63 downto 0) := X"0000000100000000";
	constant dcache_top_addr   : std_logic_vector(63 downto 0) := X"0000001000000000";

	constant clk_divider_pll   : integer := 1;
	constant clk_divider_rtc   : integer := 1;

end configure;
