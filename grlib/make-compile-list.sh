#!/bin/bash

cat_file () {
  local _f=$1
  local _d=$(dirname $1)
  while IFS= read -r line || [ -n "$line" ]; do
    if [ -n "$line" ]; then
      set $line
      if [ -f "$_d/$1" ]; then
        echo $_d/$1
      fi
    fi
  done < $_f
}

cat_dir () {
  local _d=$1
  if [ -f $_d/vhdlsyn.txt ]; then
    cat_file $_d/vhdlsyn.txt;
  fi
  if [ -f $_d/vhdlsim.txt ]; then
    cat_file $_d/vhdlsim.txt;
  fi
}

{
  cat_dir lib/grlib/stdlib
  cat_dir lib/grlib/util
  cat_dir lib/grlib/sparc
  cat_dir lib/grlib/riscv
  cat_dir lib/grlib/modgen
  cat_dir lib/grlib/amba
  cat_dir lib/grlib/gaisler
  cat_dir lib/grlib/dftlib
} > grlib.txt

{
  cat_dir lib/techmap/gencomp
  cat_dir lib/techmap/alltech
  cat_dir lib/techmap/inferred
} > techmap.txt

{
  cat_dir lib/eth/comp
  cat_dir lib/eth/core
  cat_dir lib/eth/wrapper
} > eth.txt

{
  cat_dir lib/spw/comp
  cat_dir lib/spw/wrapper
} > spw.txt

{
  cat_dir lib/opencores/can
  cat_dir lib/opencores/i2c
  cat_dir lib/opencores/ge_1000baseX
} > opencores.txt

{
  cat_dir lib/gaisler/arith
  cat_dir lib/gaisler/memctrl
  cat_dir lib/gaisler/srmmu
  cat_dir lib/gaisler/leon3
  cat_dir lib/gaisler/leon3v3
  cat_dir lib/gaisler/leon4
  cat_dir lib/gaisler/can
  #cat_dir lib/gaisler/misc
  cat_dir lib/gaisler/irqmp
  cat_dir lib/gaisler/l2cache
  cat_dir lib/gaisler/net
  cat_dir lib/gaisler/pci
  #cat_dir lib/gaisler/uart
  cat_dir lib/gaisler/sim
  cat_dir lib/gaisler/jtag
  cat_dir lib/gaisler/devices
  #cat_dir lib/gaisler/greth
  cat_dir lib/gaisler/spacewire
  cat_dir lib/gaisler/spacefibre
  cat_dir lib/gaisler/usb
  #cat_dir lib/gaisler/ddr
  cat_dir lib/gaisler/gr1553b
  cat_dir lib/gaisler/i2c
  cat_dir lib/gaisler/spi
  cat_dir lib/gaisler/grdmac
  cat_dir lib/gaisler/subsys
  #cat_dir lib/gaisler/noelv
  cat_dir lib/gaisler/plic
  #cat_dir lib/gaisler/leon5
  #cat_dir lib/gaisler/leon5v0
} > gaisler.txt

{
#  cat_dir lib/esa/memoryctrl
  cat_dir lib/esa/pci
} > esa.txt

{
  cat_dir lib/fmf/utilities
  cat_dir lib/fmf/fifo
  cat_dir lib/fmf/flash
} > fmf.txt

{
  cat_dir lib/gsi/ssram
} > gsi.txt

{
  cat_dir lib/micron/sdram
} > micron.txt

{
  cat_dir lib/cypress/ssram
} > cypress.txt

{
  cat_dir lib/work/debug
} > work.txt
