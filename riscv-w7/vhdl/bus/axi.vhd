-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;
use work.functions.all;

entity axi is
	port(
		reset         : in  std_logic;
		clock         : in  std_logic;
		mem_i         : in  mem_in_type;
		mem_o         : out mem_out_type;
		-- Master interface write address
		m_axi_awvalid : out std_logic;
		m_axi_awready : in  std_logic;
		m_axi_awaddr  : out std_logic_vector(63 downto 0);
		m_axi_awprot  : out std_logic_vector(2 downto 0);
		-- Master interface write data
		m_axi_wvalid  : out std_logic;
		m_axi_wready  : in  std_logic;
		m_axi_wdata   : out std_logic_vector(63 downto 0);
		m_axi_wstrb   : out std_logic_vector(7 downto 0);
		-- Master interface write response
		m_axi_bvalid  : in  std_logic;
		m_axi_bready  : out std_logic;
		-- Master interface read address
		m_axi_arvalid : out std_logic;
		m_axi_arready : in  std_logic;
		m_axi_araddr  : out std_logic_vector(63 downto 0);
		m_axi_arprot  : out std_logic_vector(2 downto 0);
		-- Master interface read data return
		m_axi_rvalid  : in  std_logic;
		m_axi_rready  : out std_logic;
		m_axi_rdata   : in  std_logic_vector(63 downto 0)
	);
end axi;

architecture behavior of axi is

	type state_type is (IDLE, SEND, GET);

	type register_type is record
		state       : state_type;
		axi_awvalid : std_logic;
		axi_awaddr  : std_logic_vector(63 downto 0);
		axi_awprot  : std_logic_vector(2 downto 0);
		axi_arvalid : std_logic;
		axi_araddr  : std_logic_vector(63 downto 0);
		axi_arprot  : std_logic_vector(2 downto 0);
		axi_wvalid  : std_logic;
		axi_wdata   : std_logic_vector(63 downto 0);
		axi_wstrb   : std_logic_vector(7 downto 0);
		axi_bready  : std_logic;
		axi_rready  : std_logic;
	end record;

	constant init_register : register_type := (
		state       => IDLE,
		axi_awvalid => '0',
		axi_awaddr  => (others => '0'),
		axi_awprot  => (others => '0'),
		axi_arvalid => '0',
		axi_araddr  => (others => '0'),
		axi_arprot  => (others => '0'),
		axi_wvalid  => '0',
		axi_wdata   => (others => '0'),
		axi_wstrb   => (others => '0'),
		axi_bready  => '0',
		axi_rready  => '0'
	);

	signal r,rin : register_type := init_register;

begin

	process(r,mem_i,m_axi_bvalid,m_axi_rvalid,m_axi_awready,m_axi_arready,m_axi_wready)

	variable v : register_type;

	begin

		v := r;

		case r.state is
			when IDLE =>
				if mem_i.mem_valid = '1' then
					v.state := SEND;
				end if;
			when SEND =>
				if (m_axi_awready or m_axi_arready or m_axi_wready) = '1' then
					v.state := GET;
				end if;
			when GET =>
				if (m_axi_bvalid or m_axi_rvalid) = '1' then
					v.state := IDLE;
				end if;
			when others =>
				null;
		end case;

		case r.state is
			when IDLE =>
				v.axi_awvalid := mem_i.mem_valid and mem_i.mem_write;
				v.axi_awaddr := mem_i.mem_addr;
				v.axi_awprot := "000";

				v.axi_arvalid := mem_i.mem_valid and not(mem_i.mem_write);
				v.axi_araddr := mem_i.mem_addr;
				v.axi_arprot := mem_i.mem_instr & "00";

				v.axi_wvalid := mem_i.mem_valid and mem_i.mem_write;
				v.axi_wdata := mem_i.mem_wdata;
				v.axi_wstrb := mem_i.mem_strb;

				v.axi_bready := mem_i.mem_valid and mem_i.mem_write;
				v.axi_rready := mem_i.mem_valid and not(mem_i.mem_write);
			when GET =>
				v.axi_awvalid := '0';
				v.axi_awaddr := (others => '0');
				v.axi_awprot := (others => '0');

				v.axi_arvalid := '0';
				v.axi_araddr := (others => '0');
				v.axi_arprot := (others => '0');

				v.axi_wvalid := '0';
				v.axi_wdata := (others => '0');
				v.axi_wstrb := (others => '0');
			when others =>
				null;
		end case;

		m_axi_awvalid <= v.axi_awvalid;
		m_axi_awaddr <= v.axi_awaddr;
		m_axi_awprot <= v.axi_awprot;

		m_axi_arvalid <= v.axi_arvalid;
		m_axi_araddr <= v.axi_araddr;
		m_axi_arprot <= v.axi_arprot;

		m_axi_wvalid <= v.axi_wvalid;
		m_axi_wdata <= v.axi_wdata;
		m_axi_wstrb <= v.axi_wstrb;

		m_axi_bready <= v.axi_bready;
		m_axi_rready <= v.axi_rready;

		rin <= v;

	end process;

	mem_o.mem_flush <= '0';
	mem_o.mem_error <= '0';
	mem_o.mem_busy <= '0';
	mem_o.mem_ready <= m_axi_bvalid or m_axi_rvalid;
	mem_o.mem_rdata <= m_axi_rdata;

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
