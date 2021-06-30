#!/bin/bash

# Generated with flopoco FPLog we=16 wf=46 TestBench n=10000

STD=1993
TOP=TestBench_FPLog_16_46_0_F400_uid2_F400_uid220
STOP_TIME=100240ns

A_OPTS="--relax=prefer-explicit"
E_OPTS=
R_OPTS="--exit-severity=failure"

GHDL_OPTS="-fexplicit -fsynopsys"

cd $(dirname $0)

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
  if [ -n "$USE_GHDL" ]; then
    _ghdl -a --std=${STD: -2} $GHDL_OPTS $_files
  else
    _nvc --std=${STD:-1993} -a $A_OPTS $_files
  fi
}

elaborate () {
  local _top=${TOP:-$1}
  if [ -n "$USE_GHDL" ]; then
    _ghdl -e --std=${STD: -2} $GHDL_OPTS $_top
  else
    _nvc --std=${STD:-1993} -e $E_OPTS $_top
  fi
}

run () {
  local _top=${TOP:-$1}
  if [ -n "$USE_GHDL" ]; then
    time _ghdl -r $GHDL_OPTS $_top ${STOP_TIME+--stop-time=$STOP_TIME}
  else
    _nvc --std=${STD:-1993} -r $_top --stats $R_OPTS \
	 ${STOP_TIME+--stop-time=$STOP_TIME}
  fi
}

analyse flopoco.vhdl

elaborate
run
