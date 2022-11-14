--------------------------------------------------------------------------------
-- tb_saa5050d.vhd                                                            --
-- Simulation testbench for saa5050d.vhd.                                     --
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
  use ieee.numeric_std.all;

library std;
  use std.env.finish;

library work;
  use work.tyto_types_pkg.all;
  use work.tyto_sim_pkg.all;
  use work.saa5050d_pkg.all;
  use work.hd6845_pkg.all;

entity tb_saa5050d is
  generic (
    infile, outfile : string
  );
end entity tb_saa5050d;

architecture sim of tb_saa5050d is

  signal clk       : std_logic;                     -- base clock (12MHz)
  signal clk_count : integer range 0 to 11 := 0;    -- base clock divide counter

  signal pix_clk   : std_logic;                     -- pixel clock (12MHz)
  signal pix_rst   : std_logic;                     -- pixel reset

  signal reg_clk   : std_logic;                     -- CRTC register clock (2MHz)
  signal reg_rst   : std_logic;                     -- CRTC register reset
  signal reg_we    : std_logic;                     -- CRTC register write enable
  signal reg_rs    : std_logic;                     -- CRTC register select
  signal reg_dw    : std_logic_vector(7 downto 0);  -- CRTC register write data

  signal crt_clk   : std_logic;                     -- CRTC video (character) clock (1MHz)
  signal crt_rst   : std_logic;                     -- CRTC video reset
  signal crt_ma    : std_logic_vector(13 downto 0); -- CRTC memory address
  signal crt_ra    : std_logic_vector(4 downto 0);  -- CRTC raster (scan line) address within character
  signal crt_vs    : std_logic;                     -- CRTC vertical sync
  signal crt_hs    : std_logic;                     -- CRTC horizontal blank
  signal crt_vb    : std_logic;                     -- CRTC vertical blank
  signal crt_hb    : std_logic;                     -- CRTC horizontal blank
  signal crt_de    : std_logic;                     -- CRTC display enable

  signal ttx_chr   : std_logic_vector(7 downto 0);  -- character code (0..127)
  signal ttx_pix1  : std_logic_vector(2 downto 0);  -- pixel (3 bit BGR) (12 pixels per character) (upper line)
  signal ttx_pix2  : std_logic_vector(2 downto 0);  -- pixel (3 bit BGR) (12 pixels per character) (lower line)
  signal ttx_pixen : std_logic;                     -- pixel enable

  signal crt_hs_1  : std_logic;                     -- CRTC horizontal sync, delayed by 1 clock
  signal frame     : integer := 0;                  -- frame counter
  signal bmp       : bmp_t(0 to 479, 0 to 499);     -- bitmap data
  signal x         : integer;                       -- bitmap X position
  signal y         : integer;                       -- bitmap Y position
  signal act       : boolean;                       -- video active region

  signal ttx_data  : uint8_array_t(0 to 1023);

begin

  -- base clock (~12MHz)
  clk <=
         '1' after 41666 ps when clk = '0' else
         '0' after 41666 ps when clk = '1' else
         '0';

  DO_REG_CLK: process (clk) is
  begin
    if rising_edge(clk) then
      clk_count <= (clk_count+1) mod 12;
    end if;
    if rising_edge(clk) then
      pix_clk <= '1';
      case clk_count is
        when 3 => reg_clk <= '1';
        when 6 => reg_clk <= '0'; crt_clk <= '1';
        when 9 => reg_clk <= '1';
        when 0 => reg_clk <= '0'; crt_clk <= '0';
        when others => null;
      end case;
    elsif falling_edge(clk) then
      pix_clk <= '0';
    end if;
  end process DO_REG_CLK;

  -- main test process
  TEST: process is

    procedure crtc_poke_reg (
      constant a     : in  std_logic_vector(7 downto 0);
      constant d     : in  std_logic_vector(7 downto 0);
      signal   ck    : in  std_logic;
      signal   we    : out std_logic;
      signal   rs    : out std_logic;
      signal   wdata : out std_logic_vector(7 downto 0)
    ) is
    begin
      if ck = '1' then
        wait until falling_edge(ck);
      end if;
      we    <= '1';
      rs    <= '0';
      wdata <= a;
      wait until rising_edge(ck);
      wait until falling_edge(ck);
      rs    <= '1';
      wdata <= d;
      wait until rising_edge(ck);
      wait until falling_edge(ck);
      we    <= '0';
      rs    <= '0';
      wdata <= x"00";
    end procedure crtc_poke_reg;

  begin
    ttx_data <= read_bin(infile, 1024);
    reg_rst  <= '1';
    crt_rst  <= '1';
    pix_rst  <= '1';
    reg_we   <= '0';
    reg_rs   <= '0';
    reg_dw   <= (others => '0');
    wait until rising_edge(reg_clk);
    wait until rising_edge(crt_clk);
    reg_rst  <= '0';
    -- set up 6845 for teletext display timing
    crtc_poke_reg(x"00", x"3F", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"01", x"28", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"02", x"33", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"03", x"24", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"04", x"1E", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"05", x"02", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"06", x"19", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"07", x"1B", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"08", x"93", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"09", x"12", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"0A", x"72", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"0B", x"13", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"0C", x"20", reg_clk, reg_we, reg_rs, reg_dw);
    crtc_poke_reg(x"0D", x"00", reg_clk, reg_we, reg_rs, reg_dw);
    wait until rising_edge(pix_clk);
    pix_rst <= '0';
    wait until rising_edge(crt_clk);
    crt_rst <= '0';
    wait;
  end process TEST;

  -- teletext test data
  ttx_chr <= std_logic_vector(to_unsigned(ttx_data(to_integer(unsigned(crt_ma(9 downto 0)))), 8));

  -- bitmap capture
  CAPTURE: process (pix_clk) is
  begin
    if rising_edge(pix_clk) then
      if pix_rst = '1' then
        crt_hs_1 <= '0';
        x        <= 0;
        y        <= 0;
      else
        if crt_vs = '1' then
          y <= 0;
        end if;
        if crt_hs = '1' and crt_hs_1 = '0' then -- leading edge of h sync
          x <= 0;
          if act then
            y <= y+2;
          end if;
          act <= false;
        end if;
        crt_hs_1 <= crt_hs;
        if crt_de = '1' then
          act <= true;
        end if;
        if ttx_pixen = '1' then
          for j in 0 to 2 loop
            if ttx_pix1(j) = '1' then
              bmp(x,y)(j) <= 255;
            else
              bmp(x,y)(j) <= 0;
            end if;
            if ttx_pix2(j) = '1' then
              bmp(x,y+1)(j) <= 255;
            else
              bmp(x,y+1)(j) <= 0;
            end if;
          end loop;
          if x = 479 and y = 498 then
            write_bmp(outfile, bmp, 480, 500, false);
            if frame = 0 then
              report "*** DONE ***";
              finish;
            end if;
            frame <= frame+1;
          end if;
          x <= x+1;
        end if;
      end if;
    end if;
  end process CAPTURE;

  DUT: component saa5050d
    port map (
      rsta      => '0',
      debug     => '0',
      chr_clk   => crt_clk,
      chr_clken => '1',
      chr_rst   => crt_rst,
      chr_f     => crt_ra(0),
      chr_vs    => crt_vs,
      chr_hs    => crt_hs,
      chr_gp    => crt_hb,
      chr_de    => crt_vb nor crt_hb,
      chr_d     => ttx_chr(6 downto 0),
      pix_clk   => pix_clk,
      pix_clken => '1',
      pix_rst   => pix_rst,
      pix_d1    => ttx_pix1,
      pix_d2    => ttx_pix2,
      pix_gp    => open,
      pix_de    => ttx_pixen
    );

  CRTC: component hd6845
    port map (
      reg_clk   => reg_clk,
      reg_clken => '1',
      reg_rst   => reg_rst,
      reg_cs    => '1',
      reg_we    => reg_we,
      reg_rs    => reg_rs,
      reg_dw    => reg_dw,
      reg_dr    => open,
      crt_clk   => crt_clk,
      crt_clken => '1',
      crt_rst   => crt_rst,
      crt_ma    => crt_ma,
      crt_ra    => crt_ra,
      crt_f     => open,
      crt_vs    => crt_vs,
      crt_hs    => crt_hs,
      crt_vb    => crt_vb,
      crt_hb    => crt_hb,
      crt_de    => crt_de,
      crt_cur   => open,
      crt_lps   => '0'
    );

end architecture sim;
