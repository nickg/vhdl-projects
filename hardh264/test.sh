#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=1993
TOP=h264top

A_OPTS="--relax=prefer-explicit"
E_OPTS=
R_OPTS="--exit-severity=failure"

GHDL_OPTS="-fexplicit -fsynopsys -frelaxed"

analyse src/h264buffer.vhd \
        src/h264cavlc.vhd \
        src/h264components.vhd \
        src/h264coretransform.vhd \
        src/h264dctransform.vhd \
        src/h264dequantise.vhd \
        src/h264header.vhd \
        src/h264intra4x4.vhd \
        src/h264intra8x8cc.vhd \
        src/h264invtransform.vhd \
        src/h264quantise.vhd \
        src/h264recon.vhd \
        src/h264tobytes.vhd \
        src/misc.vhd \
        src/h264topskeleton.vhd

analyse tests/h264topsim.vhd

if [ "$SIM" != ghdl ]; then
  analyse tests/cavlc_test2.vhd \
          tests/test_transform.vhd \
          tests/cavlc_test.vhd \
          tests/test_header.vhd \
          tests/test_transform2.vhd
fi

download_files sample_int.yuv

elaborate
run
