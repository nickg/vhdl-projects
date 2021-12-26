library ieee;
use ieee.std_logic_1164.all;
use work.gpio_pack.all;
entity gpio is port (
  clk : in std_logic;
  rst : in std_logic;
  reg : in gpio_register;
  d_i : in reg8x4_fixed_i;
  d_o : out reg8x4_fixed_o;
  irq : out std_logic;
  p_i : in gpio_data;
  p_o : out gpio_data);
end entity;
architecture a of gpio is
  signal this_c : gpio_reg;
  signal this_r : gpio_reg := GPIO_RESET;
begin
  p : process(this_r, reg, d_i, p_i)
    variable this : gpio_reg;
    variable zero : reg8x4_data := (others => '0');
  begin
     this := this_r;
    this.p_i2 := this.p_i;
    this.p_i := p_i;
    -- handle reads and writes
    this.d_o.ack := d_i.en;
    if d_i.en = '1' then
      if d_i.wr = '1' then
        case reg is
          when REG_DATA =>
            -- support write enable for DATA writes
            this.p_o := we_write(this.p_o, d_i.d, d_i.we);
          when REG_MASK =>
            this.mask := d_i.d;
          when REG_EDGE =>
            this.edge := d_i.d;
          when REG_CHANGES =>
            -- ignore writes to CHANGES
        end case;
      else
        case reg is
          when REG_DATA =>
            this.d_o.d := this.p_i;
          when REG_MASK =>
            this.d_o.d := this.mask;
          when REG_EDGE =>
            this.d_o.d := this.edge;
          when REG_CHANGES =>
            this.d_o.d := this.changes;
            -- reading CHANGES clears it
            this.changes := (others => '0');
        end case;
      end if;
    end if;
    -- edge detect
    -- TODO: Should the edge detection go before the reg read/write?
    for i in reg8x4_data'low to reg8x4_data'high loop
      if this.p_i2(i) = '0' and this.p_i(i) = '1' then
        this.changes(i) := '1';
      elsif this.p_i2(i) = '1' and this.p_i(i) = '0' then
        if this.edge(i) = '1' then
          this.changes(i) := '1';
        end if;
      end if;
    end loop;
    if (this.mask and this.changes) = zero then
      this.irq := '0';
    else
      this.irq := '1';
    end if;
    -- TODO: old pio only raised IRQ for one cycle at rising edge of above.
    -- Instead this new entity assumes something outside will do the edge
    -- detect.
    this_c <= this;
  end process;
  p_r0 : process(clk, rst)
  begin
     if rst = '1' then
        this_r <= GPIO_RESET;
     elsif clk = '1' and clk'event then
        this_r <= this_c;
     end if;
  end process;
  d_o <= this_r.d_o;
  irq <= this_r.irq;
  p_o <= this_r.p_o;
end architecture;
