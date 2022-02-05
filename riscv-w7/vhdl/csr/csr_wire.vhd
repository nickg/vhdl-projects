-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.int_wire.all;
use work.bit_wire.all;
use work.fp_wire.all;

package csr_wire is

	type csr_pmp_type is record
		L : std_logic;
		A : std_logic_vector(1 downto 0);
		X : std_logic;
		W : std_logic;
		R : std_logic;
	end record;

	constant init_csr_pmp_reg : csr_pmp_type := (
		L => '0',
		A => (others => '0'),
		X => '0',
		W => '0',
		R => '0'
	);

	type csr_pmpcfg_type is array (0 to 15) of csr_pmp_type;

	constant init_csr_pmpcfg_reg : csr_pmpcfg_type := (others => init_csr_pmp_reg);

	type csr_pmpaddr_type is array (0 to 15) of std_logic_vector(63 downto 0);

	constant init_csr_pmpaddr_reg : csr_pmpaddr_type := (others => (others => '0'));

	type csr_read_in_type is record
		rden  : std_logic;
		raddr : std_logic_vector(11 downto 0);
	end record;

	type csr_write_in_type is record
		wren  : std_logic;
		waddr : std_logic_vector(11 downto 0);
		wdata : std_logic_vector(63 downto 0);
	end record;

	type csr_out_type is record
		data : std_logic_vector(63 downto 0);
	end record;

	type csr_exception_in_type is record
		d_epc   : std_logic_vector(63 downto 0);
		e_epc   : std_logic_vector(63 downto 0);
		m_epc   : std_logic_vector(63 downto 0);
		w_epc   : std_logic_vector(63 downto 0);
		d_valid : std_logic;
		e_valid : std_logic;
		m_valid : std_logic;
		w_valid : std_logic;
		etval   : std_logic_vector(63 downto 0);
		ecause  : std_logic_vector(3 downto 0);
		exc     : std_logic;
		ecall   : std_logic;
		ebreak  : std_logic;
		mret    : std_logic;
		meip    : std_logic;
		msip    : std_logic;
		mtip    : std_logic;
		mtime   : std_logic_vector(63 downto 0);
	end record;

	type csr_counter_in_type is record
		flags     : std_logic_vector(4 downto 0);
		int_op    : int_operation_type;
		bit_op    : bit_operation_type;
		fpu_op    : fp_operation_type;
		int       : std_logic;
		bitm      : std_logic;
		fpu       : std_logic;
		csr       : std_logic;
		comp      : std_logic;
		atom      : std_logic;
		load      : std_logic;
		store     : std_logic;
	end record;

	type csr_exception_out_type is record
		fs      : std_logic_vector(1 downto 0);
		tvec    : std_logic_vector(63 downto 0);
		epc     : std_logic_vector(63 downto 0);
		frm     : std_logic_vector(2 downto 0);
		pmpcfg  : csr_pmpcfg_type;
		pmpaddr : csr_pmpaddr_type;
		mode    : std_logic_vector(1 downto 0);
		exc     : std_logic;
		mret    : std_logic;
	end record;

	type csr_alu_in_type is record
		rs1   : std_logic_vector(63 downto 0);
		imm   : std_logic_vector(63 downto 0);
		data  : std_logic_vector(63 downto 0);
		funct : std_logic_vector(2 downto 0);
	end record;

	type csr_alu_out_type is record
		result : std_logic_vector(63 downto 0);
	end record;

	type csr_unit_in_type is record
		csr_ri       : csr_read_in_type;
		csr_wi       : csr_write_in_type;
		csr_ei       : csr_exception_in_type;
		csr_ci       : csr_counter_in_type;
		csr_alu_i    : csr_alu_in_type;
	end record;

	type csr_unit_out_type is record
		csr_o        : csr_out_type;
		csr_eo       : csr_exception_out_type;
		csr_alu_o    : csr_alu_out_type;
	end record;

	type csr_isa_type is record
		a   : std_logic;
		b   : std_logic;
		c   : std_logic;
		d   : std_logic;
		e   : std_logic;
		f   : std_logic;
		g   : std_logic;
		h   : std_logic;
		i   : std_logic;
		k   : std_logic;
		j   : std_logic;
		l   : std_logic;
		m   : std_logic;
		n   : std_logic;
		o   : std_logic;
		p   : std_logic;
		q   : std_logic;
		r   : std_logic;
		s   : std_logic;
		t   : std_logic;
		u   : std_logic;
		v   : std_logic;
		w   : std_logic;
		x   : std_logic;
		y   : std_logic;
		z   : std_logic;
		mxl : std_logic_vector(1 downto 0);
	end record;

	constant init_csr_isa_reg : csr_isa_type := (
		a   => '0',
		b   => '0',
		c   => '1',
		d   => '1',
		e   => '0',
		f   => '1',
		g   => '0',
		h   => '0',
		i   => '1',
		k   => '0',
		j   => '0',
		l   => '0',
		m   => '1',
		n   => '0',
		o   => '0',
		p   => '0',
		q   => '0',
		r   => '0',
		s   => '0',
		t   => '0',
		u   => '0',
		v   => '0',
		w   => '0',
		x   => '0',
		y   => '0',
		z   => '0',
		mxl => "10"
	);

	type csr_status_type is record
		sd   : std_logic;
		uxl  : std_logic_vector(1 downto 0);
		mprv : std_logic;
		fs   : std_logic_vector(1 downto 0);
		mpp  : std_logic_vector(1 downto 0);
		mpie : std_logic;
		upie : std_logic;
		mie  : std_logic;
		uie  : std_logic;
	end record;

	constant init_csr_status_reg : csr_status_type := (
		sd   => '0',
		uxl  => "10",
		mprv => '0',
		fs   => "00",
		mpp  => "00",
		mpie => '0',
		upie => '0',
		mie  => '0',
		uie  => '0'
	);

	type csr_ip_type is record
		meip : std_logic;
		ueip : std_logic;
		mtip : std_logic;
		utip : std_logic;
		msip : std_logic;
		usip : std_logic;
	end record;

	constant init_csr_ip_reg : csr_ip_type := (
		meip => '0',
		ueip => '0',
		mtip => '0',
		utip => '0',
		msip => '0',
		usip => '0'
	);

	type csr_ie_type is record
		meie : std_logic;
		ueie : std_logic;
		mtie : std_logic;
		utie : std_logic;
		msie : std_logic;
		usie : std_logic;
	end record;

	constant init_csr_ie_reg : csr_ie_type := (
		meie => '0',
		ueie => '0',
		mtie => '0',
		utie => '0',
		msie => '0',
		usie => '0'
	);

	type csr_cause_type is record
		irpt : std_logic;
		code : std_logic_vector(62 downto 0);
	end record;

	constant init_csr_cause_reg : csr_cause_type := (
		irpt => '0',
		code => (others => '0')
	);

	type csr_tvec_type is record
		base : std_logic_vector(61 downto 0);
		mode : std_logic_vector(1 downto 0);
	end record;

	constant init_csr_tvec_reg : csr_tvec_type := (
		base => (others => '0'),
		mode => (others => '0')
	);

	type csr_machine_register is record
		misa       : csr_isa_type;
		mstatus    : csr_status_type;
		mip        : csr_ip_type;
		mie        : csr_ie_type;
		mcause     : csr_cause_type;
		mtvec      : csr_tvec_type;
		mtval      : std_logic_vector(63 downto 0);
		mepc       : std_logic_vector(63 downto 0);
		mscratch   : std_logic_vector(63 downto 0);
		mideleg    : std_logic_vector(63 downto 0);
		medeleg    : std_logic_vector(63 downto 0);
		mcounteren : std_logic_vector(63 downto 0);
		mcycle     : std_logic_vector(63 downto 0);
		minstret   : std_logic_vector(63 downto 0);
		pmpcfg     : csr_pmpcfg_type;
		pmpaddr    : csr_pmpaddr_type;
	end record;

	constant init_csr_machine_reg : csr_machine_register := (
		misa       => init_csr_isa_reg,
		mstatus    => init_csr_status_reg,
		mip        => init_csr_ip_reg,
		mie        => init_csr_ie_reg,
		mcause     => init_csr_cause_reg,
		mtvec      => init_csr_tvec_reg,
		mtval      => (others => '0'),
		mepc       => (others => '0'),
		mscratch   => (others => '0'),
		mideleg    => (others => '0'),
		medeleg    => (others => '0'),
		mcounteren => (others => '0'),
		mcycle     => (others => '0'),
		minstret   => (others => '0'),
		pmpcfg     => init_csr_pmpcfg_reg,
		pmpaddr    => init_csr_pmpaddr_reg
	);

	type csr_user_register is record
		fflags   : std_logic_vector(4 downto 0);
		frm      : std_logic_vector(2 downto 0);
	end record;

	constant init_csr_user_reg : csr_user_register := (
		fflags   => (others => '0'),
		frm      => (others => '0')
	);

end package;
