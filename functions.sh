#!/bin/bash

FLAMEGRAPH=$HOME/src/FlameGraph
PROF_LIBC=/opt/libc6-prof

_wrapper () {
  echo $*
  case "$TIME" in
    hyperfine)
      hyperfine -N -w 1 -m 5 -u millisecond -- "$*"
      ;;
    perf)
      perf stat -- $*
      ;;
    time)
      time -- $*
      ;;
    flamegraph)
      export LD_LIBRARY_PATH=$PROF_LIBC/lib
      perf record -F 5999 -e cycles:u -g -- $*
      unset LD_LIBRARY_PATH
      perf script | $FLAMEGRAPH/stackcollapse-perf.pl \
	| $FLAMEGRAPH/flamegraph.pl > flamegraph.svg
      x-www-browser flamegraph.svg &
      ;;
    "")
      $*
      ;;
    *)
      echo "invalid timer: $_time"
      exit 1
      ;;
  esac
  [ $? = 0 ] || exit 1
}

_nvc () {
  local _work=${WORK:-work}
  local _libdirs=(${LIBS[@]/#/-L..\/})
  local _libs=${_libdirs[@]/%/\/.nvc}
  local _opts="--std=${STD:-1993} --work=.nvc/$_work -L.nvc $_libs $NVC_OPTS"
  mkdir -p .nvc
  _wrapper ${NVC:-nvc} $_opts $*
}

_ghdl () {
  local _cmd=$1
  shift
  mkdir -p .ghdl
  local _opts="--workdir=.ghdl ${WORK+--work=$WORK} --std=${STD: -2} -O2"
  _wrapper ${GHDL:-ghdl} $_cmd $_opts $*
}

_vcom () {
  local _work=${WORK:-work}
  local _opts="-quiet -nologo -$STD -work .questa/$_work"
  if [ ! -d .questa/$_work ]; then
    mkdir -p .questa
    vlib .questa/$_work
    vmap $_work .questa/$_work
  fi
  echo vcom $_opts $*
  vcom $_opts $*
  [ $? = 0 ] || exit 1
}

_vsim () {
  local _opts="-quiet -batch -work .questa/${WORK:-work}"
  echo vsim $_opts $*
  vsim $_opts $* <<EOF
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run ${STOP_TIME:--all}
quit -f
EOF
  [ $? = 0 ] || exit 1
}

_filter_test () {
  local _top=$1
  [ -z "$TEST" ] && return 0
  grep -q "$TEST" <<< $_top
  return $?
}

analyse () {
  local _files=$*
  case ${SIM:-nvc} in
    ghdl) TIME= _ghdl -a -P.ghdl/ $GHDL_OPTS $_files ;;
    nvc)  TIME= _nvc -a $A_OPTS $_files ;;
    questa) _vcom $_files ;;
  esac
}

elaborate () {
  local _top=${TOP:-$1}
  _filter_test $_top || return
  case ${SIM:-nvc} in
    ghdl) TIME= _ghdl -e -P.ghdl/ $GHDL_OPTS $_top ;;
    nvc)  TIME= _nvc -e -V $E_OPTS $_top ;;
  esac
}

run () {
  local _top=${TOP:-$1}
  _filter_test $_top || return
  case ${SIM:-nvc} in
    ghdl)
      _ghdl -r -P.ghdl/ $GHDL_OPTS $_top \
	   ${STOP_TIME+--stop-time=$STOP_TIME} \
	   --max-stack-alloc=0 $GHDL_R_OPTS
      ;;
    questa)
      _vsim $_top
      ;;
    nvc)
      _nvc -r $_top --stats $R_OPTS \
	   ${STOP_TIME+--stop-time=$STOP_TIME}
      ;;
  esac
}

run_jit () {
  local _top=${TOP:-$1}
  _filter_test $_top || return
  case ${SIM:-nvc} in
    ghdl|questa)
      elaborate
      run
      ;;
    nvc)
      _nvc -e -V $E_OPTS $_top --no-save --jit -r --stats $R_OPTS \
	   ${STOP_TIME+--stop-time=$STOP_TIME}
      ;;
  esac
}

download_files () {
  for f in $*; do
    [ -f $f ] || wget https://github.com/nickg/vhdl-projects/releases/download/binaries/$f
  done
}
