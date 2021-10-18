*Dummy Plug*
============

## What's *Dummy Plug*

*Dummy Plug* is a simple bus functional model library written by VHDL Only.  

This models corresponds to the master and slave model of AXI4 and AXI4-Stream. 

*Dummy Plug* sequentially reads the scenario file that is written in a format like YAML, 
and outputs the signal pattern.

For example, when the master performs a write transaction will write the scenario, as follows.

```YAML
--- # AXI DUMMU-PLUG SAMPLE SCENARIO 1    # Start Scenario. Synchronize All Dummy Plug.
- - MASTER                                # Name of Dummy Plug AXI Master Player.
  - SAY: >                                # SAY Operation. Print String to STDOUT
    AXI DUMMU-PLUG SAMPLE SCENARIO 1 RUN  # 
  - AW:                                   # Write Address Channel Action.
    - VALID  : 0                          # AWVALID <= 0
      ADDR   : 0x00000000                 # AWADDR  <= 32'h00000000
      SIZE   : 0                          # AWSIZE  <= 3'b000
      LEN    : 1                          # AWLEN   <= 8'h00
      AID    : 0                          # AWID    <= 0
    - WAIT   : 10                         # wait for 10 clocks.
    - ADDR   : 0x00000010                 # AWADDR  <= 32'h00000010
      SIZE   : 4                          # AWSIZE  <= 3'b010
      LEN    : 1                          # AWLEN   <= 8'h00
      ID     : 7                          # AWID    <= 7
      VALID  : 1                          # AWVALID <= 1
    - WAIT   : {VALID : 1, READY : 1}     # wait until AWVALID = 1 and AWREADY = 1
    - VALID  : 0                          # AWVALID <= 0
    - WAIT   : {BVALID: 1, BREADY: 1}     # wait until BVALID = 1 and BREADY = 1
  - W:                                    # Write Data Channel Action.
    - DATA   : 0                          # WDATA  <= 32'h00000000
      STRB   : 0                          # WSTRB  <= 4'b0000
      LAST   : 0                          # WLAST  <= 'b0
      ID     : 0                          # WID    <= 0
      VALID  : 0                          # WVALID <= 'b0;
    - WAIT   : {AWVALID: 1, ON: on}       # wait until AWVALID = 1 
    - DATA   : "32'h76543210"             # WDATA  <= 32'h76543210
      STRB   : "4'b1111"                  # WSTRB  <= 4'b1111
      LAST   : 1                          # WLAST  <= 1
      ID     : 7                          # WID    <= 7
      VALID  : 1                          # WVALID <= 1
    - WAIT   : {VALID: 1, READY: 1}       # wait until WVALID = 1 and WREADY = 1
    - WVALID : 0                          # WVALID <= 0
  - B:                                    # Write Responce Channel Action.
    - READY  : 0                          # BREADY <= 0
    - WAIT   : {AWVALID: 1, AWREADY: 1}   # wait until AWVALID = 1 and AWREADY = 1
    - READY  : 1                          # BREADY <= 1
    - WAIT   : {VALID: 1, READY: 1}       # wait until BVALID = 1 and BREADY = 1
    - CHECK  :                            # check 
        RESP   : EXOKAY                   #    BRESP = 'b01
        ID     : 7                        #    BID   = 7
    - READY  : 0                          # BREADY <= 0
- - SLAVE                                 # Name of Dummy Plug AXI Slave Player.
  - AW:                                   # Write Address Channel Action.
    - READY  : 0                          # AWREADY <= 0
    - WAIT   : {VALID: 1, TIMEOUT: 10}    # wait until AWVALID = 1
    - READY  : 1                          # AWREADY <= 1
    - WAIT   : {VALID: 1, READY: 1}       # wait until AWVALID = 1 and AWREADY = 1
    - CHECK  :                            # check 
        ADDR   : "32'h00000010"           #   AWADDR = 0x00000010
        SIZE   : 4                        #   AWSIZE = 3'b010
        LEN    : 1                        #   AWLEN  = 8'h00
        ID     : 7                        #   AWID   = 7
    - READY  : 0                          #   AWREADY <= 0
  - W:                                    # Write Data Channel Action.
    - READY  : 0                          # WREADY <= 0
    - WAIT   : {AWVALID: 1, AWREADY: 1}   # wait until AWVALID = 1 and AWREADY = 1
    - READY  : 1                          # WREADY <= 1
    - WAIT   : {VALID: 1, READY: 1}       # wait until WVALID = 1 and WREADY = 1
    - CHECK  :                            # check
        DATA   : "32'h76543210"           #   WDATA  = 32'h76543210
        STRB   : "4'b1111"                #   WSTRB  = 4'b1111
        LAST   : 1                        #   WLAST  = 1
        ID     : 7                        #   WID    = 7
    - READY  : 0                          # WREADY <= 0
  - B:                                    # Write Responce Channel Action.
    - VALID  : 0                          # BVALID <= 0
    - WAIT   : {WVALID: 1, WREADY: 1}     # wait until WVALID = 1 and WREADY = 1
    - VALID  : 1                          # BVALID <= 1
      RESP   : EXOKAY                     # BRESP  <= 'b01
      ID     : 7                          # BID    <= 7
    - WAIT   : {VALID: 1, READY: 1}       # wait until BVALID = 1 and BREADY = 1
    - VALID  : 0                          # BVALID <= 1
      RESP   : OKAY                       # BRESP  <= 'b00
---                                       # 
- - MASTER                                # Name of Dummy Plug AXI Master Player.
  - SAY: >                                # SAY Operation. Print String to STDOUT
    AXI DUMMU-PLUG SAMPLE SCENARIO 1 DONE
---
```

## Trial

The operation of *Dummy Plug* is confirmed with the following simulator.

 - GHDL 0.29
 - [GHDL 0.35](https://github.com/ghdl/ghdl)
 - [nvc](https://github.com/nickg/nvc)
 - [Vivado 2017.2 Xilinx](https://www.xilinx.com/products/design-tools/vivado/simulator.html)

### GHDL 0.29

```console
shell$ cd sim/ghdl-0.29/axi4
shell$ make
```

### GHDL 0.35

```console
shell$ cd sim/ghdl-0.35/axi4
shell$ make
```

### nvc

#### Build nvc

```console
shell$ git clone https://github.com/nickg/nvc
shell$ cd nvc
shell$ git checkout fc0546c2e1d0b3168511523ad2d11f3d8018db3e
shell$ ./autogen.sh
shell$ mkdir build && cd build
shell$ ../configure
shell$ make
shell$ sudo make install
```

#### Simulate

```console
shell$ cd sim/nvc/axi4
shell$ make
```

### Vivado 2017.2

```console
Vivado% cd sim/vivado/axi4
Vivado% vivado -mode batch -source simulate_axi4_test_1_1.tcl
Vivado% vivado -mode batch -source simulate_axi4_test_1_2.tcl
Vivado% vivado -mode batch -source simulate_axi4_test_1_3.tcl
Vivado% vivado -mode batch -source simulate_axi4_test_1_4.tcl
```

## License

2-clause BSD license


