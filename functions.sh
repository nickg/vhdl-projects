#!/bin/bash

_nvc () {
  local _opts="--std=${STD:-1993} ${WORK+--work=.nvc/$WORK} -L.nvc"
  mkdir -p .nvc
  echo ${NVC:-nvc} $_opts $*
  ${NVC:-nvc} $_opts  $*
  [ $? = 0 ] || exit 1
}

_ghdl () {
  local _cmd=$1
  shift
  mkdir -p .ghdl
  local _opts="--workdir=.ghdl ${WORK+--work=$WORK} --std=${STD: -2}"
  echo ${GHDL:-ghdl} $_cmd $_opts $*
  ${GHDL:-ghdl} $_cmd $_opts $*
  [ $? = 0 ] || exit 1
}

analyse () {
  local _files=$*
  case ${SIM:-nvc} in
    ghdl) _ghdl -a $GHDL_OPTS $_files ;;
    nvc)  _nvc -a $A_OPTS $_files ;;
  esac
}

elaborate () {
  local _top=${TOP:-$1}
  case ${SIM:-nvc} in
    ghdl) _ghdl -e --std=${STD: -2} $GHDL_OPTS $_top ;;
    nvc)  _nvc --std=${STD:-1993} -e $E_OPTS $_top ;;
  esac
}

run () {
  local _top=${TOP:-$1}
  case ${SIM:-nvc} in
    ghdl)
      time _ghdl -r $GHDL_OPTS $_top ${STOP_TIME+--stop-time=$STOP_TIME}
      ;;
    nvc)
      _nvc -r $_top --stats $R_OPTS \
	   ${STOP_TIME+--stop-time=$STOP_TIME}
      ;;
  esac
}
