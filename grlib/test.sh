#!/bin/bash

cd $(dirname $0)
. ../functions.sh

STD=2002
TOP=leon3mp
STOP_TIME=

A_OPTS=
E_OPTS=
R_OPTS=

GHDL_OPTS="-P.ghdl -P.ghdl/grlib -fsynopsys -fexplicit"

WORK=grlib analyse lib/grlib/stdlib/version.vhd \
        lib/grlib/stdlib/config_types.vhd \
        lib/grlib/stdlib/config.vhd \
        lib/grlib/stdlib/stdlib.vhd \
        lib/grlib/stdlib/stdio.vhd \
        lib/grlib/stdlib/testlib.vhd \
        lib/grlib/util/util.vhd \
        lib/grlib/sparc/sparc.vhd \
        lib/grlib/sparc/sparc_disas.vhd \
        lib/grlib/sparc/cpu_disas.vhd \
	lib/grlib/riscv/riscv.vhd \
	lib/grlib/riscv/riscv_disas.vhd \
	lib/grlib/riscv/cpu_disas.vhd \
	lib/grlib/modgen/multlib.vhd \
	lib/grlib/modgen/leaves.vhd \
	lib/grlib/amba/amba.vhd \
	lib/grlib/amba/devices.vhd \
	lib/grlib/amba/defmst.vhd \
	lib/grlib/amba/apbctrl.vhd \
	lib/grlib/amba/apbctrlx.vhd \
	lib/grlib/amba/apbctrldp.vhd \
	lib/grlib/amba/apbctrlsp.vhd \
	lib/grlib/amba/ahbctrl.vhd \
	lib/grlib/amba/dma2ahb_pkg.vhd \
	lib/grlib/amba/dma2ahb.vhd \
	lib/grlib/amba/ahbmst.vhd \
	lib/grlib/amba/ahblitm2ahbm.vhd \
	lib/grlib/amba/dma2ahb_tp.vhd \
	lib/grlib/amba/amba_tp.vhd \
	lib/grlib/dftlib/dftlib.vhd \
	lib/grlib/dftlib/trstmux.vhd \
	lib/grlib/dftlib/synciotest.vhd \
	lib/grlib/generic_bm/generic_bm_pkg.vhd \
	lib/grlib/generic_bm/ahb_be.vhd \
	lib/grlib/generic_bm/axi4_be.vhd \
	lib/grlib/generic_bm/bmahbmst.vhd \
	lib/grlib/generic_bm/bm_fre.vhd \
	lib/grlib/generic_bm/bm_me_rc.vhd \
	lib/grlib/generic_bm/bm_me_wc.vhd \
	lib/grlib/generic_bm/fifo_control_rc.vhd \
	lib/grlib/generic_bm/fifo_control_wc.vhd \
	lib/grlib/generic_bm/generic_bm_ahb.vhd \
	lib/grlib/generic_bm/generic_bm_axi.vhd

if [ "$SIM" != "ghdl" ]; then
  # Needs VITAL
  WORK=ec analyse lib/tech/ec/orca/orcacomp.vhd \
      lib/tech/ec/orca/global.vhd \
      lib/tech/ec/orca/orca.vhd \
      lib/tech/ec/orca/orca_ecmem.vhd
fi

WORK=eclipse analyse lib/tech/eclipsee/simprims/eclipse.vhd

WORK=simprim analyse lib/tech/simprim/vcomponents/vcomponents.vhd

WORK=virage analyse lib/tech/virage/vcomponents/virage_vcomponents.vhd \
    lib/tech/virage/simprims/virage_simprims.vhd

WORK=atc18 analyse lib/tech/atc18/components/atmel_components.vhd \
    lib/tech/atc18/components/atmel_simprims.vhd

WORK=umc18 analyse lib/tech/umc18/components/umc_components.vhd \
    lib/tech/umc18/components/umc_simprims.vhd

WORK=techmap analyse lib/techmap/gencomp/gencomp.vhd \
    lib/techmap/gencomp/netcomp.vhd \
    lib/techmap/alltech/allclkgen.vhd \
    lib/techmap/alltech/allddr.vhd \
    lib/techmap/alltech/allmem.vhd \
    lib/techmap/alltech/allmul.vhd \
    lib/techmap/alltech/allpads.vhd \
    lib/techmap/alltech/alltap.vhd \
    lib/techmap/inferred/memory_inferred.vhd \
    lib/techmap/inferred/ddr_inferred.vhd \
    lib/techmap/inferred/mul_inferred.vhd \
    lib/techmap/inferred/ddr_phy_inferred.vhd \
    lib/techmap/inferred/ddrphy_datapath.vhd \
    lib/techmap/inferred/fifo_inferred.vhd \
    lib/techmap/inferred/sim_pll.vhd \
    lib/techmap/inferred/lpddr2_phy_inferred.vhd \
    lib/techmap/ec/memory_ec.vhd \
    lib/techmap/ec/ddr_ec.vhd \
    lib/techmap/unisim/memory_kintex7.vhd \
    lib/techmap/unisim/memory_ultrascale.vhd \
    lib/techmap/unisim/memory_unisim.vhd \
    lib/techmap/unisim/buffer_unisim.vhd \
    lib/techmap/unisim/pads_unisim.vhd \
    lib/techmap/unisim/clkgen_unisim.vhd \
    lib/techmap/unisim/tap_unisim.vhd \
    lib/techmap/unisim/ddr_unisim.vhd \
    lib/techmap/unisim/ddr_phy_unisim.vhd \
    lib/techmap/unisim/sysmon_unisim.vhd \
    lib/techmap/unisim/mul_unisim.vhd \
    lib/techmap/unisim/spictrl_unisim.vhd \
    lib/techmap/virtex/memory_virtex.vhd \
    lib/techmap/virtex/clkgen_virtex.vhd \
    lib/techmap/virtex5/serdes_unisim.vhd \
    lib/techmap/altera_mf/memory_altera_mf.vhd \
    lib/techmap/altera_mf/clkgen_altera_mf.vhd \
    lib/techmap/altera_mf/tap_altera_mf.vhd \
    lib/techmap/stratixii/stratixii_ddr_phy.vhd \
    lib/techmap/stratixii/clkgen_stratixii.vhd \
    lib/techmap/eclipsee/memory_eclipse.vhd \
    lib/techmap/cycloneiii/alt/apll.vhd \
    lib/techmap/cycloneiii/alt/aclkout.vhd \
    lib/techmap/cycloneiii/alt/actrlout.vhd \
    lib/techmap/cycloneiii/alt/adqsout.vhd \
    lib/techmap/cycloneiii/alt/adqout.vhd \
    lib/techmap/cycloneiii/alt/admout.vhd \
    lib/techmap/cycloneiii/alt/adqin.vhd \
    lib/techmap/cycloneiii/ddr_phy_cycloneiii.vhd \
    lib/techmap/cycloneiii/cycloneiii_clkgen.vhd \
    lib/techmap/stratixiii/clkgen_stratixiii.vhd \
    lib/techmap/stratixiii/alt/apll.vhd \
    lib/techmap/stratixiii/alt/aclkout.vhd \
    lib/techmap/stratixiii/alt/actrlout.vhd \
    lib/techmap/stratixiii/alt/adqsout.vhd \
    lib/techmap/stratixiii/alt/adqout.vhd \
    lib/techmap/stratixiii/alt/admout.vhd \
    lib/techmap/stratixiii/alt/adqsin.vhd \
    lib/techmap/stratixiii/alt/adqin.vhd \
    lib/techmap/stratixiii/adq_dqs/dq_dqs_inst.vhd \
    lib/techmap/stratixiii/adq_dqs/bidir_dq_iobuf_inst.vhd \
    lib/techmap/stratixiii/adq_dqs/output_dqs_iobuf_inst.vhd \
    lib/techmap/stratixiii/adq_dqs/bidir_dqs_iobuf_inst.vhd \
    lib/techmap/stratixiii/ddr_phy_stratixiii.vhd \
    lib/techmap/stratixiii/serdes_stratixiii.vhd \
    lib/techmap/stratixiv/ddr_uniphy.vhd \
    lib/techmap/virage/memory_virage.vhd \
    lib/techmap/atc18/pads_atc18.vhd \
    lib/techmap/umc18/memory_umc18.vhd \
    lib/techmap/umc18/pads_umc18.vhd \
    lib/techmap/saed32/clkgen_saed32.vhd \
    lib/techmap/saed32/pads_saed32.vhd \
    lib/techmap/saed32/memory_saed32.vhd \
    lib/techmap/maps/techbuf.vhd \
    lib/techmap/maps/clkgen.vhd \
    lib/techmap/maps/clkmux.vhd \
    lib/techmap/maps/clkinv.vhd \
    lib/techmap/maps/clkand.vhd \
    lib/techmap/maps/grgates.vhd \
    lib/techmap/maps/ddr_ireg.vhd \
    lib/techmap/maps/ddr_oreg.vhd \
    lib/techmap/maps/clkpad.vhd \
    lib/techmap/maps/clkpad_ds.vhd \
    lib/techmap/maps/inpad.vhd \
    lib/techmap/maps/inpad_ds.vhd \
    lib/techmap/maps/iodpad.vhd \
    lib/techmap/maps/iopad.vhd \
    lib/techmap/maps/iopad_ds.vhd \
    lib/techmap/maps/lvds_combo.vhd \
    lib/techmap/maps/odpad.vhd \
    lib/techmap/maps/outpad.vhd \
    lib/techmap/maps/outpad_ds.vhd \
    lib/techmap/maps/toutpad.vhd \
    lib/techmap/maps/toutpad_ds.vhd \
    lib/techmap/maps/skew_outpad.vhd \
    lib/techmap/maps/ddrphy.vhd \
    lib/techmap/maps/syncram.vhd \
    lib/techmap/maps/syncram64.vhd \
    lib/techmap/maps/syncram_2p.vhd \
    lib/techmap/maps/syncram_dp.vhd \
    lib/techmap/maps/syncfifo_2p.vhd \
    lib/techmap/maps/regfile_3p.vhd \
    lib/techmap/maps/tap.vhd \
    lib/techmap/maps/nandtree.vhd \
    lib/techmap/maps/grlfpw_net.vhd \
    lib/techmap/maps/grfpw_net.vhd \
    lib/techmap/maps/leon3_net.vhd \
    lib/techmap/maps/leon4_net.vhd \
    lib/techmap/maps/mul_61x61.vhd \
    lib/techmap/maps/cpu_disas_net.vhd \
    lib/techmap/maps/ringosc.vhd \
    lib/techmap/maps/grpci2_phy_net.vhd \
    lib/techmap/maps/system_monitor.vhd \
    lib/techmap/maps/inpad_ddr.vhd \
    lib/techmap/maps/outpad_ddr.vhd \
    lib/techmap/maps/iopad_ddr.vhd \
    lib/techmap/maps/syncram128bw.vhd \
    lib/techmap/maps/syncram256bw.vhd \
    lib/techmap/maps/syncram128.vhd \
    lib/techmap/maps/syncram156bw.vhd \
    lib/techmap/maps/techmult.vhd \
    lib/techmap/maps/spictrl_net.vhd \
    lib/techmap/maps/scanreg.vhd \
    lib/techmap/maps/syncrambw.vhd \
    lib/techmap/maps/syncram_2pbw.vhd \
    lib/techmap/maps/sdram_phy.vhd \
    lib/techmap/maps/syncreg.vhd \
    lib/techmap/maps/serdes.vhd \
    lib/techmap/maps/iopad_tm.vhd \
    lib/techmap/maps/toutpad_tm.vhd \
    lib/techmap/maps/memrwcol.vhd \
    lib/techmap/maps/cdcbus.vhd

WORK=spw analyse lib/spw/comp/spwcomp.vhd \
    lib/spw/wrapper/grspw_gen.vhd \
    lib/spw/wrapper/grspw2_gen.vhd \
    lib/spw/wrapper/grspw_codec_gen.vhd

WORK=eth analyse lib/eth/comp/ethcomp.vhd \
    lib/eth/core/greth_pkg.vhd \
    lib/eth/core/eth_rstgen.vhd \
    lib/eth/core/eth_edcl_ahb_mst.vhd \
    lib/eth/core/eth_ahb_mst.vhd \
    lib/eth/core/greth_tx.vhd \
    lib/eth/core/greth_rx.vhd \
    lib/eth/core/grethc.vhd \
    lib/eth/wrapper/greth_gen.vhd

WORK=opencores analyse lib/opencores/can/cancomp.vhd \
    lib/opencores/can/can_top.vhd \
    lib/opencores/i2c/i2c_master_bit_ctrl.vhd \
    lib/opencores/i2c/i2c_master_byte_ctrl.vhd \
    lib/opencores/i2c/i2coc.vhd \
    lib/opencores/ge_1000baseX/ge_1000baseX_comp.vhd
    
WORK=gaisler analyse lib/gaisler/arith/arith.vhd \
    lib/gaisler/arith/mul32.vhd \
    lib/gaisler/arith/div32.vhd \
    lib/gaisler/memctrl/memctrl.vhd \
    lib/gaisler/memctrl/sdctrl.vhd \
    lib/gaisler/memctrl/sdctrl64.vhd \
    lib/gaisler/memctrl/sdmctrl.vhd \
    lib/gaisler/memctrl/srctrl.vhd \
    lib/gaisler/srmmu/mmuconfig.vhd \
    lib/gaisler/srmmu/mmuiface.vhd \
    lib/gaisler/srmmu/libmmu.vhd \
    lib/gaisler/srmmu/mmutlbcam.vhd \
    lib/gaisler/srmmu/mmulrue.vhd \
    lib/gaisler/srmmu/mmulru.vhd \
    lib/gaisler/srmmu/mmutlb.vhd \
    lib/gaisler/srmmu/mmutw.vhd \
    lib/gaisler/srmmu/mmu.vhd \
    lib/gaisler/leon3/leon3.vhd \
    lib/gaisler/leon3/grfpushwx.vhd \
    lib/gaisler/leon3v3/tbufmem.vhd \
    lib/gaisler/leon3v3/tbufmem_2p.vhd \
    lib/gaisler/leon3v3/dsu3x.vhd \
    lib/gaisler/leon3v3/dsu3.vhd \
    lib/gaisler/leon3v3/dsu3_mb.vhd \
    lib/gaisler/leon3v3/libfpu.vhd \
    lib/gaisler/leon3v3/libiu.vhd \
    lib/gaisler/leon3v3/libcache.vhd \
    lib/gaisler/leon3v3/libleon3.vhd \
    lib/gaisler/leon3v3/regfile_3p_l3.vhd \
    lib/gaisler/leon3v3/mmu_acache.vhd \
    lib/gaisler/leon3v3/mmu_icache.vhd \
    lib/gaisler/leon3v3/mmu_dcache.vhd \
    lib/gaisler/leon3v3/cachemem.vhd \
    lib/gaisler/leon3v3/mmu_cache.vhd \
    lib/gaisler/leon3v3/grfpwx.vhd \
    lib/gaisler/leon3v3/grlfpwx.vhd \
    lib/gaisler/leon3v3/iu3.vhd \
    lib/gaisler/leon3v3/proc3.vhd \
    lib/gaisler/leon3v3/grfpwxsh.vhd \
    lib/gaisler/leon3v3/leon3x.vhd \
    lib/gaisler/leon3v3/leon3cg.vhd \
    lib/gaisler/leon3v3/leon3s.vhd \
    lib/gaisler/leon3v3/leon3sh.vhd \
    lib/gaisler/leon3v3/l3stat.vhd \
    lib/gaisler/leon3v3/cmvalidbits.vhd \
    lib/gaisler/leon4/leon4.vhd \
    lib/gaisler/irqmp/irqmp.vhd \
    lib/gaisler/irqmp/irqamp.vhd \
    lib/gaisler/irqmp/irqmp_bmode.vhd \
    lib/gaisler/l2cache/pkg/l2cache.vhd \
    lib/gaisler/can/can.vhd \
    lib/gaisler/can/can_mod.vhd \
    lib/gaisler/can/can_oc.vhd \
    lib/gaisler/can/can_mc.vhd \
    lib/gaisler/can/canmux.vhd \
    lib/gaisler/can/can_rd.vhd \
    lib/gaisler/misc/misc.vhd \
    lib/gaisler/misc/rstgen.vhd \
    lib/gaisler/misc/gptimer.vhd \
    lib/gaisler/misc/ahbram.vhd \
    lib/gaisler/misc/ahbdpram.vhd \
    lib/gaisler/misc/ahbtrace_mmb.vhd \
    lib/gaisler/misc/ahbtrace_mb.vhd \
    lib/gaisler/misc/ahbtrace.vhd \
    lib/gaisler/misc/grgpio.vhd \
    lib/gaisler/misc/ahbstat.vhd \
    lib/gaisler/misc/logan.vhd \
    lib/gaisler/misc/apbps2.vhd \
    lib/gaisler/misc/charrom_package.vhd \
    lib/gaisler/misc/charrom.vhd \
    lib/gaisler/misc/apbvga.vhd \
    lib/gaisler/misc/svgactrl.vhd \
    lib/gaisler/misc/grsysmon.vhd \
    lib/gaisler/misc/gracectrl.vhd \
    lib/gaisler/misc/grgpreg.vhd \
    lib/gaisler/misc/ahb_mst_iface.vhd \
    lib/gaisler/misc/grgprbank.vhd \
    lib/gaisler/misc/grversion.vhd \
    lib/gaisler/misc/apb3cdc.vhd \
    lib/gaisler/misc/ahbsmux.vhd \
    lib/gaisler/misc/ahbmmux.vhd \
    lib/gaisler/misc/grtachom.vhd \
    lib/gaisler/net/net.vhd \
    lib/gaisler/pci/pci.vhd \
    lib/gaisler/pci/pcipads.vhd \
    lib/gaisler/pci/grpci2/pcilib2.vhd \
    lib/gaisler/pci/grpci2/grpci2_ahb_mst.vhd \
    lib/gaisler/pci/grpci2/grpci2_phy.vhd \
    lib/gaisler/pci/grpci2/grpci2_phy_wrapper.vhd \
    lib/gaisler/pci/grpci2/grpci2_cdc_gate.vhd \
    lib/gaisler/pci/grpci2/grpci2.vhd \
    lib/gaisler/pci/grpci2/wrapper/grpci2_gen.vhd \
    lib/gaisler/pci/ptf/pt_pkg.vhd \
    lib/gaisler/pci/ptf/pt_pci_master.vhd \
    lib/gaisler/pci/ptf/pt_pci_target.vhd \
    lib/gaisler/pci/ptf/pt_pci_arb.vhd \
    lib/gaisler/uart/uart.vhd \
    lib/gaisler/uart/libdcom.vhd \
    lib/gaisler/uart/apbuart.vhd \
    lib/gaisler/uart/dcom.vhd \
    lib/gaisler/uart/dcom_uart.vhd \
    lib/gaisler/uart/ahbuart.vhd \
    lib/gaisler/sim/sim.vhd \
    lib/gaisler/sim/sram.vhd \
    lib/gaisler/sim/sram16.vhd \
    lib/gaisler/sim/phy.vhd \
    lib/gaisler/sim/ser_phy.vhd \
    lib/gaisler/sim/ahbrep.vhd \
    lib/gaisler/sim/delay_wire.vhd \
    lib/gaisler/sim/pwm_check.vhd \
    lib/gaisler/sim/slavecheck_slv.vhd \
    lib/gaisler/sim/ddrram.vhd \
    lib/gaisler/sim/ddr2ram.vhd \
    lib/gaisler/sim/ddr3ram.vhd \
    lib/gaisler/sim/sdrtestmod.vhd \
    lib/gaisler/sim/ahbram_sim.vhd \
    lib/gaisler/sim/aximem.vhd \
    lib/gaisler/sim/axirep.vhd \
    lib/gaisler/sim/axixmem.vhd \
    lib/gaisler/sim/sramtestmod.vhd \
    lib/gaisler/sim/uartprint.vhd \
    lib/gaisler/jtag/jtag.vhd \
    lib/gaisler/jtag/libjtagcom.vhd \
    lib/gaisler/jtag/jtagcom.vhd \
    lib/gaisler/jtag/bscanregs.vhd \
    lib/gaisler/jtag/bscanregsbd.vhd \
    lib/gaisler/jtag/jtagcom2.vhd \
    lib/gaisler/jtag/ahbjtag.vhd \
    lib/gaisler/jtag/ahbjtag_bsd.vhd \
    lib/gaisler/jtag/jtagcomrv.vhd \
    lib/gaisler/jtag/ahbjtagrv.vhd \
    lib/gaisler/jtag/jtagtst.vhd \
    lib/gaisler/jtag/jtag_rv.vhd \
    lib/gaisler/greth/ethernet_mac.vhd \
    lib/gaisler/greth/greth.vhd \
    lib/gaisler/greth/greth_mb.vhd \
    lib/gaisler/greth/greth_gbit.vhd \
    lib/gaisler/greth/greths.vhd \
    lib/gaisler/greth/greth_gbit_mb.vhd \
    lib/gaisler/greth/greths_mb.vhd \
    lib/gaisler/greth/grethm.vhd \
    lib/gaisler/greth/grethm_mb.vhd \
    lib/gaisler/greth/adapters/rgmii.vhd \
    lib/gaisler/greth/adapters/rgmii_kc705.vhd \
    lib/gaisler/greth/adapters/rgmii_series7.vhd \
    lib/gaisler/greth/adapters/rgmii_series6.vhd \
    lib/gaisler/greth/adapters/comma_detect.vhd \
    lib/gaisler/greth/adapters/sgmii.vhd \
    lib/gaisler/greth/adapters/elastic_buffer.vhd \
    lib/gaisler/greth/adapters/gmii_to_mii.vhd \
    lib/gaisler/greth/adapters/word_aligner.vhd \
    lib/gaisler/spacewire/spacewire.vhd \
    lib/gaisler/spacefibre/spacefibre.vhd \
    lib/gaisler/usb/grusb.vhd \
    lib/gaisler/ddr/ddrpkg.vhd \
    lib/gaisler/ddr/ddrintpkg.vhd \
    lib/gaisler/ddr/ddrphy_wrap.vhd \
    lib/gaisler/ddr/ddr2spax_ahb.vhd \
    lib/gaisler/ddr/ddr2spax_ddr.vhd \
    lib/gaisler/ddr/ddr2buf.vhd \
    lib/gaisler/ddr/ddr2spax.vhd \
    lib/gaisler/ddr/ddr2spa.vhd \
    lib/gaisler/ddr/ddr1spax.vhd \
    lib/gaisler/ddr/ddr1spax_ddr.vhd \
    lib/gaisler/ddr/ddrspa.vhd \
    lib/gaisler/ddr/ahb2mig_7series_pkg.vhd \
    lib/gaisler/ddr/ahb2mig_7series.vhd \
    lib/gaisler/ddr/ahb2mig_7series_ddr2_dq16_ad13_ba3.vhd \
    lib/gaisler/ddr/ahb2mig_7series_ddr3_dq16_ad15_ba3.vhd \
    lib/gaisler/ddr/ahb2mig_7series_cpci_xc7k.vhd \
    lib/gaisler/ddr/ahb2avl_async.vhd \
    lib/gaisler/ddr/ahb2avl_async_be.vhd \
    lib/gaisler/gr1553b/gr1553b_pkg.vhd \
    lib/gaisler/gr1553b/gr1553b_pads.vhd \
    lib/gaisler/gr1553b/gr1553b_nlw.vhd \
    lib/gaisler/gr1553b/gr1553b_stdlogic.vhd \
    lib/gaisler/gr1553b/simtrans1553.vhd \
    lib/gaisler/i2c/i2c.vhd \
    lib/gaisler/i2c/i2cmst.vhd \
    lib/gaisler/i2c/i2cmst_gen.vhd \
    lib/gaisler/i2c/i2cslv.vhd \
    lib/gaisler/i2c/i2c2ahbx.vhd \
    lib/gaisler/i2c/i2c2ahb.vhd \
    lib/gaisler/i2c/i2c2ahb_apb.vhd \
    lib/gaisler/i2c/i2c2ahb_gen.vhd \
    lib/gaisler/i2c/i2c2ahb_apb_gen.vhd \
    lib/gaisler/spi/spi.vhd \
    lib/gaisler/spi/spimctrl.vhd \
    lib/gaisler/spi/spictrlx.vhd \
    lib/gaisler/spi/spictrl.vhd \
    lib/gaisler/spi/spi2ahbx.vhd \
    lib/gaisler/spi/spi2ahb.vhd \
    lib/gaisler/spi/spi2ahb_apb.vhd \
    lib/gaisler/spi/spi_flash.vhd \
    lib/gaisler/grdmac/grdmac_pkg.vhd \
    lib/gaisler/grdmac/apbmem.vhd \
    lib/gaisler/grdmac/grdmac_ahbmst.vhd \
    lib/gaisler/grdmac/grdmac_alignram.vhd \
    lib/gaisler/grdmac/grdmac.vhd \
    lib/gaisler/grdmac/grdmac_1p.vhd \
    lib/gaisler/subsys/subsys.vhd \
    lib/gaisler/subsys/leon_dsu_stat_base.vhd \
    lib/gaisler/noelv/pkg/noelv_cfg.vhd \
    lib/gaisler/noelv/pkg/noelv.vhd \
    lib/gaisler/noelv/core/noelvint.vhd \
    lib/gaisler/noelv/core/utilnv.vhd \
    lib/gaisler/noelv/core/mmuconfig.vhd \
    lib/gaisler/noelv/core/bhtnv.vhd \
    lib/gaisler/noelv/core/btbnv.vhd \
    lib/gaisler/noelv/core/rasnv.vhd \
    lib/gaisler/noelv/core/tbufmemnv.vhd \
    lib/gaisler/noelv/core/cachememnv.vhd \
    lib/gaisler/noelv/core/mul64.vhd \
    lib/gaisler/noelv/core/div64.vhd \
    lib/gaisler/noelv/core/regfile64sramnv.vhd \
    lib/gaisler/noelv/core/regfile64dffnv.vhd \
    lib/gaisler/noelv/core/progbuf.vhd \
    lib/gaisler/noelv/core/cpucorenv.vhd \
    lib/gaisler/noelv/core/rvdmx.vhd \
    lib/gaisler/noelv/core/rvdm.vhd \
    lib/gaisler/noelv/core/cctrlnv.vhd \
    lib/gaisler/noelv/core/fakefpunv.vhd \
    lib/gaisler/noelv/core/nanofpunv.vhd \
    lib/gaisler/noelv/clint/clint.vhd \
    lib/gaisler/noelv/clint/clint_ahb.vhd \
    lib/gaisler/plic/plic.vhd \
    lib/gaisler/plic/grplic.vhd \
    lib/gaisler/plic/plic_encoder.vhd \
    lib/gaisler/plic/plic_gateway.vhd \
    lib/gaisler/plic/plic_target.vhd \
    lib/gaisler/plic/grplic_ahb.vhd \
    lib/gaisler/noelv/subsys/noelvcpu.vhd \
    lib/gaisler/noelv/subsys/dummy_pnp.vhd \
    lib/gaisler/noelv/subsys/noelvsys.vhd \
    lib/gaisler/leon5/leon5.vhd \
    lib/gaisler/leon5v0/leon5int.vhd \
    lib/gaisler/leon5v0/itbufmem5.vhd \
    lib/gaisler/leon5v0/bht_pap.vhd \
    lib/gaisler/leon5v0/btb.vhd \
    lib/gaisler/leon5v0/inst_text.vhd \
    lib/gaisler/leon5v0/cctrl5.vhd \
    lib/gaisler/leon5v0/cachemem5.vhd \
    lib/gaisler/leon5v0/regfile5_ram.vhd \
    lib/gaisler/leon5v0/regfile5_dff.vhd \
    lib/gaisler/leon5v0/nanofpu.vhd \
    lib/gaisler/leon5v0/cpucore5.vhd \
    lib/gaisler/leon5v0/tbufmem5.vhd \
    lib/gaisler/leon5v0/dbgmod5.vhd \
    lib/gaisler/leon5v0/irqmp5.vhd \
    lib/gaisler/leon5v0/leon5sys.vhd

if [ "$SIM" != "ghdl" ]; then
  # The following have errors with GHDL
  WORK=gaisler analyse lib/gaisler/axi/axi.vhd \
      lib/gaisler/axi/ahbm2axi.vhd \
      lib/gaisler/axi/ahbm2axi3.vhd \
      lib/gaisler/axi/ahbm2axi4.vhd \
      lib/gaisler/axi/axinullslv.vhd \
      lib/gaisler/axi/ahb2axib.vhd \
      lib/gaisler/axi/ahb2axi3b.vhd \
      lib/gaisler/axi/ahb2axi4b.vhd \
      lib/gaisler/grdmac2/grdmac2_pkg.vhd \
      lib/gaisler/grdmac2/grdmac2_apb.vhd \
      lib/gaisler/grdmac2/mem2buf.vhd \
      lib/gaisler/grdmac2/buf2mem.vhd \
      lib/gaisler/grdmac2/grdmac2_ctrl.vhd \
      lib/gaisler/grdmac2/grdmac2.vhd \
      lib/gaisler/grdmac2/grdmac2_ahb.vhd \
      lib/gaisler/grdmac2/grdmac2_acc.vhd \
      lib/gaisler/ambatest/ahbtbp.vhd \
      lib/gaisler/ambatest/ahbtbm.vhd \
      lib/gaisler/ddr/ahb2axi_mig_7series.vhd \
      lib/gaisler/ddr/axi_mig_7series.vhd \
      lib/gaisler/noelv/core/iunv.vhd \
      lib/gaisler/leon5v0/iu5.vhd
fi
      
WORK=esa analyse lib/esa/memoryctrl/memoryctrl.vhd \
    lib/esa/memoryctrl/mctrl.vhd \
    lib/esa/pci/pcicomp.vhd \
    lib/esa/pci/pci_arb_pkg.vhd \
    lib/esa/pci/pci_arb.vhd \
    lib/esa/pci/pciarb.vhd

if [ "$SIM" != "ghdl" ]; then
  # Needs VITAL
  WORK=fmf analyse lib/fmf/utilities/conversions.vhd \
      lib/fmf/utilities/gen_utils.vhd \
      lib/fmf/flash/flash.vhd \
      lib/fmf/flash/s25fl064a.vhd \
      lib/fmf/flash/m25p80.vhd \
      lib/fmf/fifo/idt7202.vhd
fi

WORK=gsi analyse lib/gsi/ssram/functions.vhd \
    lib/gsi/ssram/core_burst.vhd \
    lib/gsi/ssram/g880e18bt.vhd

WORK=micron analyse \
    lib/micron/sdram/components.vhd \
    lib/micron/sdram/mt48lc16m16a2.vhd

WORK=cypress analyse \
    lib/cypress/ssram/components.vhd \
    lib/cypress/ssram/package_utility.vhd \
    lib/cypress/ssram/cy7c1354b.vhd \
    lib/cypress/ssram/cy7c1380d.vhd

analyse lib/work/debug/debug.vhd \
	lib/work/debug/grtestmod.vhd \
	lib/work/debug/cpu_disas.vhd

analyse designs/leon3-ahbfile/config.vhd \
        designs/leon3-ahbfile/ahbfile.vhd \
        designs/leon3-ahbfile/leon3mp.vhd \
        designs/leon3-ahbfile/testbench.vhd

elaborate
run
