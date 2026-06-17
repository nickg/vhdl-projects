#!/bin/bash

cd $(dirname $0)
. ../../functions.sh

STD=2008
TOP=tb_eth_mac_1g

A_OPTS=
E_OPTS=
R_OPTS="--exit-severity=error --ieee-warnings=off"

analyse rtl/eth_mac_1g.v \
        rtl/axis_gmii_rx.v \
        rtl/axis_gmii_tx.v \
        rtl/lfsr.v \
        tb/tb_eth_mac_1g.v

elaborate
run
