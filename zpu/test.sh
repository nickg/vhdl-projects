#!/bin/bash

STD=1993
TOP=fpga_top
A_OPTS=
E_OPTS=
R_OPTS="--stop-time=4910us"

_nvc () {
  echo ${NVC:-nvc} $*
  ${NVC:-nvc} $*
  [ $? = 0 ] || exit 1
}

_ghdl () {
  echo ${GHDL:-ghdl} $*
  ${GHDL:-ghdl} $*
  [ $? = 0 ] || exit 1
}

analyse () {
  local _files=$*
  _nvc --std=${STD:-1993} -a $A_OPTS $_files
}

elaborate () {
  local _top=${TOP:-$1}
  _nvc --std=${STD:-1993} -e $_top
}

run () {
  local _top=${TOP:-$1}
  _nvc --std=${STD:-1993} -r $_top --stats $R_OPTS
}

analyse example_medium/zpu_config_trace.vhd \
	zpu4/core/zpupkg.vhd \
	zpu4/src/txt_util.vhd \
	example_medium/sim_fpga_top.vhd \
	zpu4/core/zpu_core.vhd \
	example_medium/dram_hello.vhd \
	zpu4/src/timer.vhd \
	zpu4/src/io.vhd \
	zpu4/src/trace.vhd

elaborate
run


