--------------------------------------------------------------------------------
-- saa5050.vhd                                                                --
-- SAA5050 compatible teletext character generator.                           --
--------------------------------------------------------------------------------
-- (C) Copyright 2022 Adam Barnes <ambarnes@gmail.com>                        --
-- This file is part of The Tyto Project. The Tyto Project is free software:  --
-- you can redistribute it and/or modify it under the terms of the GNU Lesser --
-- General Public License as published by the Free Software Foundation,       --
-- either version 3 of the License, or (at your option) any later version.    --
-- The Tyto Project is distributed in the hope that it will be useful, but    --
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public     --
-- License for more details. You should have received a copy of the GNU       --
-- Lesser General Public License along with The Tyto Project. If not, see     --
-- https://www.gnu.org/licenses/.                                             --
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

package saa5050_pkg is

  component saa5050 is
    port (
      rsta      : in    std_logic;
      debug     : in    std_logic;
      chr_clk   : in    std_logic;
      chr_clken : in    std_logic;
      chr_rst   : in    std_logic;
      chr_f     : in    std_logic;
      chr_vs    : in    std_logic;
      chr_hs    : in    std_logic;
      chr_gp    : in    std_logic;
      chr_de    : in    std_logic;
      chr_d     : in    std_logic_vector(6 downto 0);
      pix_clk   : in    std_logic;
      pix_clken : in    std_logic;
      pix_rst   : in    std_logic;
      pix_gp    : out   std_logic;
      pix_de    : out   std_logic;
      pix_d     : out   std_logic_vector(2 downto 0)
    );
  end component saa5050;

end package saa5050_pkg;

--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.saa5050_rom_data_pkg.all;

entity saa5050 is
  port (
    rsta      : in    std_logic;                    -- asynchronous (global) reset
    debug     : in    std_logic;                    -- debug enable (display attributes)
    chr_clk   : in    std_logic;                    -- character clock        } normally
    chr_clken : in    std_logic;                    -- character clock enable }  1MHz
    chr_rst   : in    std_logic;                    -- character clock synchronous reset
    chr_f     : in    std_logic;                    -- field (0 = 1st/odd/upper, 1 = 2nd/even/lower)
    chr_vs    : in    std_logic;                    -- CRTC vertical sync
    chr_hs    : in    std_logic;                    -- CRTC horizontal sync
    chr_gp    : in    std_logic;                    -- CRTC general purpose
    chr_de    : in    std_logic;                    -- CRTC display enable
    chr_d     : in    std_logic_vector(6 downto 0); -- CRTC character code (0..127)
    pix_clk   : in    std_logic;                    -- pixel clock        } normally
    pix_clken : in    std_logic;                    -- pixel clock enable }  12MHz
    pix_rst   : in    std_logic;                    -- pixel clock synchronous reset
    pix_gp    : out   std_logic;                    -- pixel general purpose
    pix_de    : out   std_logic;                    -- pixel enable
    pix_d     : out   std_logic_vector(2 downto 0)  -- pixel data (3 bit BGR)
  );
end entity saa5050;

architecture synth of saa5050 is

  signal rst_sc       : std_logic_vector(0 to 1);     -- rsta synchroniser to character clock
  signal rst_sp       : std_logic_vector(0 to 1);     -- rsta synchroniser to pixel clock

  signal chr_vs1      : std_logic;                    -- chr_vs, registered
  signal chr_gp1      : std_logic;                    -- chr_gp, registered
  signal chr_de1      : std_logic;                    -- chr_de, registered
  signal chr_di       : integer range 0 to 127;       -- integer version of input data
  signal chr_d1       : std_logic_vector(6 downto 0); -- character code, registered
  signal chr_di1      : integer range 0 to 127;       -- integer version of above

  -- attribute states                                                                         SET             CLEAR
  signal attr_gfx     : std_logic;                    -- graphics (not text)                  after 11..17    after 01..07
  signal attr_fgcol   : std_logic_vector(2 downto 0); -- current foreground colour, BGR       after 11..17      n/a
  signal attr_flash   : std_logic;                    -- flash (not steady)                   after 08           at 09
  signal attr_dbl     : std_logic;                    -- double height text                   after 0D           at 0C
  signal attr_hide    : std_logic;                    -- conceal characters                      at 18        after 01..07/11..17
  signal attr_sep     : std_logic;                    -- separate (not contiguous) graphics      at 1A           at 19
  signal attr_bgcol   : std_logic_vector(2 downto 0); -- current background colour, BGR          at 1C,1D
  signal attr_hold    : std_logic;                    -- graphics hold                           at 1E        after 1F
  signal attr_gfx1    : std_logic;                    -- graphics (not text)                } registered
  signal attr_fgcol1  : std_logic_vector(2 downto 0); -- current foreground colour, BGR     }
  signal attr_flash1  : std_logic;                    -- flash (not steady)                 }
  signal attr_dbl1    : std_logic;                    -- double height text                 }
  signal attr_hide1   : std_logic;                    -- conceal characters                 }
  signal attr_sep1    : std_logic;                    -- separate (not contiguous) graphics }
  signal attr_bgcol1  : std_logic_vector(2 downto 0); -- current background colour, BGR     }
  signal attr_hold1   : std_logic;                    -- graphics hold                      }

  signal dbl_top      : std_logic;                    -- latches occurence of top half of double height characters
  signal dbl_bot      : std_logic;                    -- bottom half of double height characters
  signal count_flash  : unsigned(5 downto 0);         -- counter for flashing characters
  signal flash_state  : std_logic;                    -- current flash state

  signal row_sd       : unsigned(3 downto 0);         -- row within std def character (0..9)
  signal row_hd       : unsigned(4 downto 0);         -- row within high def (smoothed) character (0..19)
  signal col_hd       : unsigned(3 downto 0);         -- col within high def (smoothed) character (0..11)

  signal rom_row_cur  : unsigned(3 downto 0);         -- current row within ROM character pattern (0..9)
  signal rom_row_adj  : unsigned(3 downto 0);         -- adjacent row within ROM character pattern (0..9) (above or below current row for rounding)
  signal rom_data_cur : std_logic_vector(4 downto 0); -- pixels for current row from ROM
  signal rom_data_adj : std_logic_vector(4 downto 0); -- pixels for adjacent row from ROM
  signal held_c       : std_logic_vector(6 downto 0); -- held graphics character code
  signal held_s       : std_logic;                    -- held graphics separate state
  signal held_c1      : std_logic_vector(6 downto 0); -- held graphics character code, registered
  signal held_s1      : std_logic;                    -- held graphics separate state, registered
  signal chr_g        : std_logic_vector(6 downto 0); -- graphics character code (latest or held)
  signal chr_s        : std_logic;                    -- graphics separate (latest or held)
  signal gfx_row      : unsigned(3 downto 0);         -- row within graphics character (0..9)
  signal gfx_data     : std_logic_vector(5 downto 0); -- pixels for graphics pattern
  signal pix_sr_cur   : std_logic_vector(6 downto 0); -- pixel output shift register (current row)
  signal pix_sr_adj   : std_logic_vector(6 downto 0); -- pixel output shift register (adjacent row for character rounding)

begin

  chr_di  <= to_integer(unsigned(chr_d));
  chr_di1 <= to_integer(unsigned(chr_d1));

  -- character clock domain
  CHAR: process (chr_clk) is
  begin
    if rising_edge(chr_clk) then
      rst_sc(0 to 1) <= rsta & rst_sc(0);
    end if;
    if rising_edge(chr_clk) then
      if chr_rst = '1' or rst_sc(1) = '1' then
        chr_vs1     <= '0';
        chr_gp1     <= '0';
        chr_de1     <= '0';
        chr_d1      <= (others => '0');
        row_sd      <= (others => '0');
        attr_gfx    <= '0';
        attr_fgcol  <= "111";
        attr_flash  <= '0';
        attr_dbl    <= '0';
        attr_hide   <= '0';
        attr_sep    <= '0';
        attr_bgcol  <= "000";
        attr_hold   <= '0';
        attr_gfx1   <= '0';
        attr_fgcol1 <= "000";
        attr_flash1 <= '0';
        attr_dbl1   <= '0';
        attr_hide1  <= '0';
        attr_sep1   <= '0';
        attr_bgcol1 <= "000";
        attr_hold1  <= '0';
        dbl_top     <= '0';
        dbl_bot     <= '0';
        held_c      <= (others => '0');
        held_s      <= '0';
        held_c1     <= (others => '0');
        held_s1     <= '0';
        count_flash <= (others => '0');
        flash_state <= '1';
      elsif chr_clken = '1' then
        chr_vs1     <= chr_vs;
        chr_gp1     <= chr_gp;
        chr_de1     <= chr_de;
        chr_d1      <= chr_d;
        held_c1     <= held_c;
        held_s1     <= held_s;
        attr_gfx1   <= attr_gfx;
        attr_fgcol1 <= attr_fgcol;
        attr_flash1 <= attr_flash;
        attr_dbl1   <= attr_dbl;
        attr_hide1  <= attr_hide;
        attr_sep1   <= attr_sep;
        attr_bgcol1 <= attr_bgcol;
        attr_hold1  <= attr_hold;
        -- handle set-at codes
        if chr_di = 16#09# then attr_flash1 <= '0'; end if;
        if chr_di = 16#0C# then attr_dbl1 <= '0'; end if;
        if chr_di = 16#18# then attr_hide1 <= '1'; end if;
        if chr_di = 16#1A# then attr_sep1 <= '1'; elsif chr_di = 15#19# then attr_sep1 <= '0'; end if;
        if chr_di = 16#1C# then attr_bgcol1 <= "000"; elsif chr_di = 16#1D# then attr_bgcol1 <= attr_fgcol; end if;
        if chr_di = 16#1E# then attr_hold1 <= '1'; end if;
        if chr_vs = '1' then                                                                                        -- beginning of field
          row_sd  <= (others => '0');
          dbl_top <= '0';
          dbl_bot <= '0';
          if chr_vs1 = '0' then
            count_flash <= count_flash+1;
            flash_state <= count_flash(5) or count_flash(4);
          end if;
        end if;
        if chr_hs = '1' then                                                                                        -- beginning of row
          attr_fgcol <= (others => '1');
          attr_bgcol <= (others => '0');
          attr_flash <= '0';
          attr_dbl   <= '0';
          attr_gfx   <= '0';
          attr_sep   <= '0';
          attr_hold  <= '0';
          attr_hide  <= '0';
          held_c     <= (others => '0');
          held_s     <= '0';
        end if;
        if chr_de = '1' then
          -- handle codes
          case chr_di is
            when 16#01# to 16#07# =>                                                                                -- text (alpha) colour (set-after)
              attr_gfx   <= '0';
              attr_fgcol <= chr_d(2 downto 0);
              attr_hide  <= '0';
              attr_hold  <= '0';
              held_c     <= (others => '0');
              held_s     <= '0';
            when 16#08# =>                                                                                          -- flash (set-after)
              attr_flash <= '1';
            when 16#09# =>                                                                                          -- steady (set-at)
              attr_flash <= '0';
            when 16#0C# =>                                                                                          -- normal size (set-at)
              attr_dbl <= '0';
              if attr_dbl = '1' then                                                                                -- change of height
                attr_hold <= '0';
                held_c    <= (others => '0');
                held_s    <= '0';
              end if;
            when 16#0D# =>                                                                                          -- double height (set-after)
              attr_dbl <= '1';
              if attr_dbl = '0' then                                                                                -- change of height
                attr_hold <= '0';
                held_c    <= (others => '0');
                held_s    <= '0';
              end if;
              dbl_top <= not dbl_bot;
              held_c  <= (others => '0');
              held_s  <= '0';
            when 16#10# to 16#17# =>                                                                                -- graphics (mosaic) colour (set-after)
              attr_gfx   <= '1';
              attr_fgcol <= chr_d(2 downto 0);
              attr_hide  <= '0';
            when 16#18# =>                                                                                          -- conceal (set-at)
              attr_hide <= '1';
            when 16#19# =>                                                                                          -- contiguous graphics (set-at)
              attr_sep <= '0';
            when 16#1A# =>                                                                                          -- separated graphics (set-at)
              attr_sep <= '1';
            when 16#1C# =>                                                                                          -- black background colour (set-at)
              attr_bgcol <= "000";
            when 16#1D# =>                                                                                          -- new background colour (set-at)
              attr_bgcol <= attr_fgcol;
            when 16#1E# =>                                                                                          -- graphics hold (set-at)
              attr_hold <= '1';
            when 16#1F# =>                                                                                          -- graphics release (set_after)
              attr_hold <= '0';
            when others => null;
          end case;
          -- held graphics character
          if attr_gfx = '1' and ((chr_di >= 32 and chr_di <= 63) or (chr_di >= 96 and chr_di <= 127)) then
            held_c <= chr_d;
            held_s <= attr_sep;
          end if;
          if attr_hold = '0' and chr_di <= 31 and chr_di /= 16#1E# then                                             -- SAA5050 hold bug
            held_c <= (others => '0');
            held_s <= '0';
          end if;
        elsif chr_de1 = '1' then                                                                                    -- trailing edge of de
          if row_sd = 9 then
            row_sd  <= (others => '0');
            dbl_bot <= dbl_top;
            dbl_top <= '0';
          else
            row_sd <= row_sd+1;
          end if;
        end if;                                                                                                     -- chr_de = '1'
      end if;                                                                                                       -- chr_rst = '1' or rst_sc(1) = '1'
    end if;                                                                                                         -- rising_edge(chr_clk) and chr_clken = '1'
  end process CHAR;

  row_hd <=                                                              -- row within rounded (hi-def) character (0..19)
            row_sd & chr_f when debug = '1' and chr_di <= 31 else        -- attribute debug - always normal height
            ('0' & row_sd)+10 when attr_dbl = '1' and dbl_bot = '1' else -- bottom half of double height
            '0' & row_sd      when attr_dbl = '1' else                   -- top half of double height
            row_sd & chr_f;                                              -- normal height

  rom_row_cur <= row_hd(4 downto 1);                                                  -- row in character pattern
  rom_row_adj <= row_hd(4 downto 1)-1 when row_hd(0) = '0' else row_hd(4 downto 1)+1; -- correct adjacent row for rounding

  -- text character pixel data (dual port synchronous ROM)
  ROM: process (chr_clk) is
  begin
    if rising_edge(chr_clk) and chr_clken = '1' then
      rom_data_cur <= rom_data(to_integer(unsigned(chr_d) & rom_row_cur));
      rom_data_adj <= rom_data(to_integer(unsigned(chr_d) & rom_row_adj));
    end if;
  end process ROM;

  -- graphics character code / separation depends on hold
  chr_g <= held_c1 when attr_hold1 = '1' and chr_di1 <= 31 else chr_d1;
  chr_s <= held_s1 when attr_hold1 = '1' and chr_di1 <= 31 else attr_sep1;

  -- graphics character pixel data
  gfx_row  <=
              ('0' & row_sd(3 downto 1))+5 when attr_dbl = '1' and dbl_bot = '1' else -- bottom half of double height
              ('0' & row_sd(3 downto 1))   when attr_dbl = '1' else                   -- top half of double height
              row_sd;                                                                 -- normal height
  gfx_data <=
              (others => '0') when chr_s = '1' and (gfx_row = 2 or gfx_row = 6 or gfx_row = 9) else
              (chr_g(0) and not chr_s) & chr_g(0) & chr_g(0) & (chr_g(1) and not chr_s) & chr_g(1) & chr_g(1) when gfx_row >= 0 and gfx_row <= 2 else
              (chr_g(2) and not chr_s) & chr_g(2) & chr_g(2) & (chr_g(3) and not chr_s) & chr_g(3) & chr_g(3) when gfx_row >= 3 and gfx_row <= 6 else
              (chr_g(4) and not chr_s) & chr_g(4) & chr_g(4) & (chr_g(6) and not chr_s) & chr_g(6) & chr_g(6);

  -- pixel clock domain
  PIX: process (pix_clk) is
    variable nn_d, nn_v, nn_h : std_logic; -- nearest neighbour pixels
  begin
    if rising_edge(pix_clk) then
      rst_sp(0 to 1) <= rsta & rst_sp(0);
    end if;
    if rising_edge(pix_clk) then
      pix_gp <= '1';
      if pix_rst = '1' or rst_sp(1) = '1' then
        col_hd     <= (others => '0');
        pix_sr_cur <= (others => '0');
        pix_sr_adj <= (others => '0');
        pix_gp     <= '0';
        pix_de     <= '0';
        pix_d      <= (others => '0');
      elsif pix_clken = '1' then
        pix_gp <= chr_gp1;
        pix_de <= '0';
        pix_d  <= (others => '0');
        if chr_de1 = '1' then
          pix_de <= '1';
          pix_d  <= attr_bgcol1;
          if debug = '1' and chr_d1(6 downto 5) = "00" then
            pix_d <= (others => '0');
          end if;
          if col_hd = 0 then                                                                                      -- first pixel of 12
            pix_sr_cur <= (others => '0');
            pix_sr_adj <= (others => '0');
            if (chr_di1 >= 32 or debug = '0') and (
                                                   (attr_hide1 = '1') or                                          -- conceal
                                                   (attr_flash1 = '1' and flash_state = '0') or                   -- flashing (off state)
                                                   (dbl_bot = '1' and attr_dbl1 = '0')                            -- bottom of double height row, without double height attribute
                                                 ) then
              null;
            elsif (attr_gfx1 = '1' and ((chr_di1 >= 32 and chr_di1 <= 63) or (chr_di1 >= 96 and chr_di1 <= 127)))
                  or (attr_hold1 = '1' and debug = '0' and chr_di1 <= 31)
                  then
              pix_sr_cur <= '0' & gfx_data;
              pix_sr_adj <= '0' & gfx_data;
              if gfx_data(5) = '1' then
                pix_d <= attr_fgcol1;
              end if;
            else
              if debug = '1' or chr_di1 >= 32 then
                pix_sr_cur <= "00" & rom_data_cur;
                pix_sr_adj <= "00" & rom_data_adj;
              else
                pix_sr_cur <= (others => '0');
                pix_sr_adj <= (others => '0');
              end if;
            end if;
            col_hd <= (col_hd+1) mod 12;
          else
            if pix_sr_cur(5) = '1' then                                                                           -- filled pixel
              pix_d <= attr_fgcol1;
              if debug = '1' and chr_d1(6 downto 5) = "00" then
                pix_d <= (others => '1');
              end if;
            else                                                                                                  -- empty pixel -> look at character rounding...
              nn_v := pix_sr_adj(5);
              if col_hd(0) = '0' then                                                                             -- left half pixel
                nn_d := pix_sr_adj(6);
                nn_h := pix_sr_cur(6);
              else                                                                                                -- right half pixels
                nn_d := pix_sr_adj(4);
                nn_h := pix_sr_cur(4);
              end if;
              if nn_d = '0' and nn_v = '1' and nn_h = '1' then                                                    -- rounding required
                pix_d <= attr_fgcol1;
              end if;
              if debug = '1' and chr_d1(6 downto 5) = "00" then
                pix_d <= (others => '0');
              end if;
            end if;
            if col_hd(0) = '1' then
              pix_sr_cur <= std_logic_vector(shift_left(unsigned(pix_sr_cur), 1));
              pix_sr_adj <= std_logic_vector(shift_left(unsigned(pix_sr_adj), 1));
            end if;
            col_hd <= (col_hd+1) mod 12;
          end if;
        end if;
      end if;
    end if;
  end process PIX;

end architecture synth;
