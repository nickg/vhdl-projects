-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;

entity ahb is
	port(
		reset           : in  std_logic;
		clock           : in  std_logic;
		mem_i           : in  mem_in_type;
		mem_o           : out mem_out_type;
		-- Master AHB-Lite interface
		m_ahb_haddr     : out std_logic_vector(63 downto 0);
		m_ahb_hburst    : out std_logic_vector(2 downto 0);
		m_ahb_hmastlock : out std_logic;
		m_ahb_hprot     : out std_logic_vector(3 downto 0);
		m_ahb_hrdata    : in  std_logic_vector(63 downto 0);
		m_ahb_hready    : in  std_logic;
		m_ahb_hresp     : in  std_logic;
		m_ahb_hsize     : out std_logic_vector(2 downto 0);
		m_ahb_htrans    : out std_logic_vector(1 downto 0);
		m_ahb_hwdata    : out std_logic_vector(63 downto 0);
		m_ahb_hwrite    : out std_logic
	);
end ahb;

architecture behavior of ahb is

	function size (
		byteenable : in std_logic_vector(7 downto 0)
	)
	return std_logic_vector is
		variable result : integer range 0 to 8;
	begin
		result := 0;
		for i in 0 to 7 loop
			if byteenable(i) = '1' then
				result := result + 1;
			end if;
		end loop;
		case result is
			when 1 => return "000";
			when 2 => return "001";
			when 4 => return "010";
			when 8 => return "011";
			when others => return "000";
		end case;
	end function size;

	function increment (
		byteenable : in std_logic_vector(7 downto 0)
	)
	return integer is
	begin
		if byteenable = X"01" or byteenable = X"03" or byteenable = X"0F" or byteenable = X"FF" then
			return 0;
		elsif byteenable = X"02" then
			return 1;
		elsif byteenable = X"04" or byteenable = X"0C" then
			return 2;
		elsif byteenable = X"08" then
			return 3;
		elsif byteenable = X"10" or byteenable = X"30" or byteenable = X"F0" then
			return 4;
		elsif byteenable = X"20" then
			return 5;
		elsif byteenable = X"40" or byteenable = X"C0" then
			return 6;
		elsif byteenable = X"80" then
			return 7;
		else
			return 0;
		end if;
	end function increment;

	function transform (
		addr : in std_logic_vector(63 downto 0);
		incr : in integer range 0 to 7
	)
	return std_logic_vector is
	begin
		return std_logic_vector(unsigned(addr) + incr);
	end function transform;

	type state_type is (IDLE, ACTIVE);

	type register_type is record
		state      : state_type;
		ahb_haddr  : std_logic_vector(63 downto 0);
		ahb_hprot  : std_logic_vector(3 downto 0);
		ahb_hrdata : std_logic_vector(63 downto 0);
		ahb_hready : std_logic;
		ahb_hresp  : std_logic;
		ahb_hsize  : std_logic_vector(2 downto 0);
		ahb_htrans : std_logic_vector(1 downto 0);
		ahb_hwdata : std_logic_vector(63 downto 0);
		ahb_hwrite : std_logic;
	end record;

	constant init_register : register_type := (
		state      => IDLE,
		ahb_haddr  => (others => '0'),
		ahb_hprot  => (others => '0'),
		ahb_hrdata => (others => '0'),
		ahb_hready => '0',
		ahb_hresp  => '0',
		ahb_hsize  => (others => '0'),
		ahb_htrans => (others => '0'),
		ahb_hwdata => (others => '0'),
		ahb_hwrite => '0'
	);

	signal r,rin : register_type := init_register;

begin

	process(r,mem_i,m_ahb_hready,m_ahb_hresp,m_ahb_hrdata)

	variable v : register_type;

	begin

		v := r;

		case r.state is
			when IDLE =>
				if mem_i.mem_valid = '1' and m_ahb_hready = '1' then
					v.state := ACTIVE;
				end if;
			when ACTIVE =>
				if m_ahb_hready = '1' then
					v.state := IDLE;
				end if;
			when others =>
				null;
		end case;

		case r.state is
			when IDLE =>
				v.ahb_haddr  := transform(mem_i.mem_addr,increment(mem_i.mem_strb));
				v.ahb_hprot  := "001" & mem_i.mem_write;
				v.ahb_hsize  := size(mem_i.mem_strb);
				v.ahb_htrans := mem_i.mem_valid & "0";
				v.ahb_hwdata := mem_i.mem_wdata;
				v.ahb_hwrite := mem_i.mem_write;
				v.ahb_hrdata := (others => '0');
				v.ahb_hready := '0';
				v.ahb_hresp  := '0';
			when ACTIVE =>
				v.ahb_hrdata := m_ahb_hrdata;
				v.ahb_hready := m_ahb_hready;
				v.ahb_hresp  := m_ahb_hresp;
			when others =>
				v.ahb_hrdata := (others => '0');
				v.ahb_hready := '0';
				v.ahb_hresp  := '0';
		end case;

		rin <= v;

		m_ahb_haddr <= v.ahb_haddr;
		m_ahb_hburst <= "000";
		m_ahb_hmastlock <= '0';
		m_ahb_hprot <= v.ahb_hprot;
		m_ahb_hsize <= v.ahb_hsize;
		m_ahb_htrans <= v.ahb_htrans;
		m_ahb_hwdata <= v.ahb_hwdata;
		m_ahb_hwrite <= v.ahb_hwrite;

		mem_o.mem_flush <= '0';
		mem_o.mem_error <= '0';
		mem_o.mem_busy <= '0';
		mem_o.mem_rdata <= r.ahb_hrdata;
		mem_o.mem_ready <= r.ahb_hready and not(r.ahb_hresp);

	end process;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = reset_active) then
				r <= init_register;
			else
				r <= rin;
			end if;

		end if;

	end process;

end architecture;
