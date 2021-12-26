-- UART implementation.
-- Compatible with uartlite

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.uart_pack.all;

entity uartlite is generic (
   intcfg : integer := 1;
   fclk : real := 31.25e6;
   bps : real := 115.2e3);
                   port (
   rst : in std_logic;
   clk : in std_logic;
   a : in uart_i_t;
   y : out uart_o_t;
   -- The actual serial signals
   rx : in std_logic;
   tx : out std_logic);
end uartlite;

architecture beh of uartlite is

signal this_c : uart_reg_t ;
signal this_r : uart_reg_t ;
signal rxf : uart_rx_fifo_t;
signal rxfw : uart_rx_fifo_w_t;
signal txf : uart_tx_fifo_t;
signal txfw : uart_tx_fifo_w_t;

constant uart_baud : natural := integer ( 4096.0 / ( fclk / (bps * 16.0) ) );


begin
   u : process(this_r,rxf,txf,a,rx)
   variable this : uart_reg_t ;
   variable rfc : uart_rx_fifo_w_t;
   variable tfc : uart_tx_fifo_w_t;
   variable txe : std_logic;
   variable rxe : std_logic;

   variable rv, wv : std_logic_vector(4 downto 0);

   begin
      this := this_r;

      rfc := ( 0, (others => '0'), '0');
      tfc := ( 0, (others => '0'), '0');

      wv := std_logic_vector(to_unsigned(this.rxp.wa, 5));
      rv := std_logic_vector(to_unsigned(this.rxp.ra, 5));

      -- calculate tx and rx empty
      rxe := '0';
      txe := '0';
      if this.rxp.wa = this.rxp.ra and this.rx.full = '0' then rxe := '1'; end if;
      if this.txp.wa = this.txp.ra and this.tx.full = '0' then txe := '1'; end if;

      -- interrupt only once, so clear it every cycle
      this.y.int := '0';

      -- reset the ack from any previous bus cycle.
      this.y.ack := '0';

      -- at the 16x baud clock rate...
      if this.dds(this.dds'left) = '1' then

         -- transmitter
         if this.tx.phs = 15 then

         -- transmitter datapath
            case this.tx.s is
            when IDLE => this.txo := '1';
            when START =>
               this.txo := '0';
               this.tx.sr := txf(this.txp.ra);
               if this.txp.ra = UART_TX_FIFO_LEN-1 then -- pop the tx fifo
                  this.txp.ra := 0;
               else
                  this.txp.ra := this.txp.ra + 1;
               end if;
               this.tx.full := '0';
               if this.txp.wa = this.txp.ra and this.ien = '1' then this.y.int := '1'; end if;
            when DATA =>
               this.txo := this.tx.sr(0);
               this.tx.sr := '0' & this.tx.sr(7 downto 1);
            when STOP =>
               this.txo := '1';
            end case;

         -- transmitter state machine. only changes state in phase 15.
            case this.tx.s is
            when IDLE =>
               if this.txp.wa /= this.txp.ra or this.tx.full = '1' then
                  this.tx.s := START;
                  this.tx.phs := 0;
               end if;
            when START =>
               this.tx.s := DATA;
               this.tx.phs := 0;
               this.tx.b := 0;
            when DATA =>
               if this.tx.b = 7 then
                  this.tx.s := STOP;
               else
                  this.tx.b := this.tx.b + 1;
               end if;
               this.tx.phs := 0;
            when STOP =>
               if this.txp.wa /= this.txp.ra or this.tx.full = '1' then
                  this.tx.s := START;
                  this.tx.phs := 0;
               else
                  this.tx.s := IDLE;
               end if;
            end case;

         else
            this.tx.phs := this.tx.phs + 1; -- phase will stay at 15 when idle
         end if;

         -- receiver
         if this.rx.phs = 7 or this.rx.phs = 8 or this.rx.phs = 9 then
         -- receiver majority voting input bit sampling, at 3 independent 16x baudclock times
            if this.rx.a(1) = '1' then this.rx.m := this.rx.m + 1; end if;
            this.rx.phs := this.rx.phs + 1;

         elsif this.rx.phs = 10 and this.rx.s = STOP then
         -- receiver end of frame
            this.rx.s := IDLE;
            this.rx.phs := 15;

            if this.rx.m > 1 then -- good framing, try to push into the rx fifo
               if this.rx.full = '1' then
                  this.rx.ovr := '1';
               else

        -- choose between interrupt at RX non-empty and half full
           if (intcfg = 1) then
                     if this.rxp.wa = this.rxp.ra and this.ien = '1' then
        this.y.int := '1';
       end if;
    elsif wv(3 downto 0) = rv(3 downto 0) and (wv(4) xor rv(4)) = '1' and this.ien = '1' then
                    this.y.int := this.rxint; -- '1';
   this.rxint := '0';
                  end if;


                  rfc.d := this.rx.sr;
                  rfc.a := this.rxp.wa;
                  rfc.we := '1';
                  if this.rxp.wa = UART_RX_FIFO_LEN-1 then
                     this.rxp.wa := 0;
                  else
                     this.rxp.wa := this.rxp.wa + 1;
                  end if;
                  if this.rxp.wa = this.rxp.ra then this.rx.full := '1'; end if;
               end if;
            else
               this.rx.ferr := '1';
            end if;

         elsif this.rx.phs = 15 then
         -- receiver end-of-bit time processing
            if this.rx.s = DATA then -- shift in the bit
               if this.rx.m > 1 then this.rx.sr := '1' & this.rx.sr(7 downto 1);
               else this.rx.sr := '0' & this.rx.sr(7 downto 1);
               end if;
            end if;

         -- receiver state machine. phase will stay at 15 when idle
            case this.rx.s is
            when IDLE =>
               if this.rx.a(1) = '0' then
                  this.rx.phs := 0;
                  this.rx.s := START;
               end if;
            when START =>
               if this.rx.m > 1 then
                  this.rx.s := IDLE; -- false start
               else
                  this.rx.phs := 0;
                  this.rx.b := 0;
                  this.rx.s := DATA;
               end if;
            when DATA =>
               this.rx.phs := 0;
               if this.rx.b = 7 then
                  this.rx.s := STOP;
               else
                  this.rx.b := this.rx.b + 1;
               end if;
            when others =>
            end case;

            this.rx.m := 0;
         else
            this.rx.phs := this.rx.phs + 1;
         end if;

  -- interrupt with timeout when rx buffer is not empty, but stop/idle receiving data
         if ( intcfg = 0 and this.ien = '1' and rxe = '0') then
     if (this.rx.s = IDLE ) then
                if ( this.itimeout = UART_RX_INT_TIMEOUT-1) then
         this.y.int := this.rxint; --'1';
        this.rxint := '0'; -- timer out only once as long as in IDLE state
        this.itimeout := 0;
               else
       this.itimeout := this.itimeout + 1;
         end if;
            else -- clear timer if a new character received
         this.itimeout := 0;
            end if;
  else
    this.itimeout := 0;
    this.rxint := '1';
  end if;

      end if; -- 16x baud rate

      -- 16x baud clock DDS
      this.dds := ('0' & this.dds(this.dds'left-1 downto 0)) + to_unsigned(uart_baud, 13);

      -- cpu side read interface
      if this.en = '0' and a.en = '1' and a.we = '0' then
         if a.dc = DATA then
            if this.rxp.wa /= this.rxp.ra or this.rx.full = '1' then
               this.y.d := rxf(this.rxp.ra);
               if this.rxp.ra = UART_RX_FIFO_LEN-1 then
                  this.rxp.ra := 0;
               else
                  this.rxp.ra := this.rxp.ra + 1;
               end if;
               this.rx.full := '0';
            else
            -- fifo underrun, oops! unhandled.
            end if;
         else
            -- status reg read
            this.y.d := '0' & this.rx.ferr & this.rx.ovr & this.ien & this.tx.full & txe & this.rx.full & not rxe;

            this.rx.ferr := '0';
            this.rx.ovr := '0';
         end if;
         this.y.ack := '1';
      end if;

      -- cpu side write interface
      if this.en = '0' and a.en = '1' and a.we = '1' then
         if a.dc = DATA then
            if this.tx.full = '1' then
               this.tx.ovr := '1';
            else
               tfc.d := a.d;
               tfc.a := this.txp.wa;
               tfc.we := '1';
               if this.txp.wa = UART_TX_FIFO_LEN-1 then
                  this.txp.wa := 0;
               else
                  this.txp.wa := this.txp.wa + 1;
               end if;
               if this.txp.wa = this.txp.ra then this.tx.full := '1'; end if;
            end if;
         else
            -- control reg write
            if a.d(0) = '1' then this.txp.wa := 0; this.txp.ra := 0; this.tx.full := '0'; end if;
            if a.d(1) = '1' then this.rxp.wa := 0; this.rxp.ra := 0; this.rx.full := '0'; end if;
            this.ien := a.d(4);
         end if;
         this.y.ack := '1';
      end if;

      -- one bus cycle per en
      this.en := a.en;

      -- input metastable buffer
      this.rx.a := this.rx.a(0) & rx;

      -- fifo storage write controls
      rxfw <= rfc;
      txfw <= tfc;

      this_c <= this;
   end process;

   u_r0 : process(clk, rst)
   begin
      if rst = '1' then
         this_r <= UART_REG_RESET;
      elsif clk = '1' and clk'event then
         this_r <= this_c;
      end if;
   end process;

   -- Xilinx can't infer RAMs properly in 2 process...
   rp : process(clk)
   begin
      if clk = '1' and clk'event then
         if txfw.we = '1' then txf(txfw.a) <= txfw.d; end if;
         if rxfw.we = '1' then rxf(rxfw.a) <= rxfw.d; end if;
      end if;

   end process;

   -- connect up the outputs
   y <= this_r.y;
   tx <= this_r.txo;
end beh;
