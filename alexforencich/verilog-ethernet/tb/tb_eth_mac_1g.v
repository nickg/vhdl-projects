/*

Pure-Verilog self-checking loopback testbench for eth_mac_1g.

Methodology:
  * Loop GMII TX output back to GMII RX input (same clock domain).
  * Push a set of frames into the AXI TX interface.
  * Capture bytes from the AXI RX interface and compare against an
    expected reference (input bytes, zero-padded for sub-minimum frames).
  * Verify no bad-frame / bad-FCS / underflow errors are flagged.
  * Print PASS or FAIL at end and $finish.

Run with iverilog:
    iverilog -g2012 -o sim_tb_eth_mac_1g \
        ../../rtl/eth_mac_1g.v ../../rtl/axis_gmii_rx.v \
        ../../rtl/axis_gmii_tx.v ../../rtl/lfsr.v tb_eth_mac_1g.v
    vvp sim_tb_eth_mac_1g

PAUSE / PFC are disabled here, so the mac_ctrl_* / mac_pause_ctrl_* sources
are not needed to elaborate.

*/

`resetall
`timescale 1ns / 1ps
`default_nettype none

module tb_eth_mac_1g;

localparam DATA_WIDTH    = 8;
localparam PTP_TS_WIDTH  = 96;
localparam TX_USER_WIDTH = 1;
localparam RX_USER_WIDTH = 1;

reg clk = 1'b0;
reg rst = 1'b1;

always #4 clk = ~clk;  // 125 MHz

// ---------------------------------------------------------------------------
//  DUT + GMII loopback
// ---------------------------------------------------------------------------

reg  [DATA_WIDTH-1:0]    tx_axis_tdata  = 0;
reg                      tx_axis_tvalid = 1'b0;
wire                     tx_axis_tready;
reg                      tx_axis_tlast  = 1'b0;
reg  [TX_USER_WIDTH-1:0] tx_axis_tuser  = 0;

wire [DATA_WIDTH-1:0]    rx_axis_tdata;
wire                     rx_axis_tvalid;
wire                     rx_axis_tlast;
wire [RX_USER_WIDTH-1:0] rx_axis_tuser;

wire [DATA_WIDTH-1:0]    gmii_txd;
wire                     gmii_tx_en;
wire                     gmii_tx_er;

// Loopback: feed TX GMII straight back into RX GMII
wire [DATA_WIDTH-1:0]    gmii_rxd   = gmii_txd;
wire                     gmii_rx_dv = gmii_tx_en;
wire                     gmii_rx_er = gmii_tx_er;

wire                     tx_start_packet;
wire                     tx_error_underflow;
wire                     rx_start_packet;
wire                     rx_error_bad_frame;
wire                     rx_error_bad_fcs;

eth_mac_1g #(
    .DATA_WIDTH(DATA_WIDTH),
    .ENABLE_PADDING(1),
    .MIN_FRAME_LENGTH(64),
    .PTP_TS_ENABLE(0),
    .PTP_TS_WIDTH(PTP_TS_WIDTH),
    .TX_USER_WIDTH(TX_USER_WIDTH),
    .RX_USER_WIDTH(RX_USER_WIDTH),
    .PFC_ENABLE(0),
    .PAUSE_ENABLE(0)
) dut (
    .rx_clk(clk),
    .rx_rst(rst),
    .tx_clk(clk),
    .tx_rst(rst),

    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),

    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),

    .gmii_rxd(gmii_rxd),
    .gmii_rx_dv(gmii_rx_dv),
    .gmii_rx_er(gmii_rx_er),
    .gmii_txd(gmii_txd),
    .gmii_tx_en(gmii_tx_en),
    .gmii_tx_er(gmii_tx_er),

    .tx_ptp_ts({PTP_TS_WIDTH{1'b0}}),
    .rx_ptp_ts({PTP_TS_WIDTH{1'b0}}),
    .tx_axis_ptp_ts(),
    .tx_axis_ptp_ts_tag(),
    .tx_axis_ptp_ts_valid(),

    .tx_lfc_req(1'b0),
    .tx_lfc_resend(1'b0),
    .rx_lfc_en(1'b0),
    .rx_lfc_req(),
    .rx_lfc_ack(1'b0),

    .tx_pfc_req(8'd0),
    .tx_pfc_resend(1'b0),
    .rx_pfc_en(8'd0),
    .rx_pfc_req(),
    .rx_pfc_ack(8'd0),

    .tx_lfc_pause_en(1'b0),
    .tx_pause_req(1'b0),
    .tx_pause_ack(),

    .rx_clk_enable(1'b1),
    .tx_clk_enable(1'b1),
    .rx_mii_select(1'b0),
    .tx_mii_select(1'b0),

    .tx_start_packet(tx_start_packet),
    .tx_error_underflow(tx_error_underflow),
    .rx_start_packet(rx_start_packet),
    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),
    .stat_tx_mcf(),
    .stat_rx_mcf(),
    .stat_tx_lfc_pkt(),
    .stat_tx_lfc_xon(),
    .stat_tx_lfc_xoff(),
    .stat_tx_lfc_paused(),
    .stat_tx_pfc_pkt(),
    .stat_tx_pfc_xon(),
    .stat_tx_pfc_xoff(),
    .stat_tx_pfc_paused(),
    .stat_rx_lfc_pkt(),
    .stat_rx_lfc_xon(),
    .stat_rx_lfc_xoff(),
    .stat_rx_lfc_paused(),
    .stat_rx_pfc_pkt(),
    .stat_rx_pfc_xon(),
    .stat_rx_pfc_xoff(),
    .stat_rx_pfc_paused(),

    .cfg_ifg(8'd12),
    .cfg_tx_enable(1'b1),
    .cfg_rx_enable(1'b1),
    .cfg_mcf_rx_eth_dst_mcast(48'h0180c2000001),
    .cfg_mcf_rx_check_eth_dst_mcast(1'b0),
    .cfg_mcf_rx_eth_dst_ucast(48'd0),
    .cfg_mcf_rx_check_eth_dst_ucast(1'b0),
    .cfg_mcf_rx_eth_src(48'd0),
    .cfg_mcf_rx_check_eth_src(1'b0),
    .cfg_mcf_rx_eth_type(16'h8808),
    .cfg_mcf_rx_opcode_lfc(16'h0001),
    .cfg_mcf_rx_check_opcode_lfc(1'b0),
    .cfg_mcf_rx_opcode_pfc(16'h0101),
    .cfg_mcf_rx_check_opcode_pfc(1'b0),
    .cfg_mcf_rx_forward(1'b0),
    .cfg_mcf_rx_enable(1'b0),
    .cfg_tx_lfc_eth_dst(48'h0180c2000001),
    .cfg_tx_lfc_eth_src(48'd0),
    .cfg_tx_lfc_eth_type(16'h8808),
    .cfg_tx_lfc_opcode(16'h0001),
    .cfg_tx_lfc_en(1'b0),
    .cfg_tx_lfc_quanta(16'hffff),
    .cfg_tx_lfc_refresh(16'h7fff),
    .cfg_tx_pfc_eth_dst(48'h0180c2000001),
    .cfg_tx_pfc_eth_src(48'd0),
    .cfg_tx_pfc_eth_type(16'h8808),
    .cfg_tx_pfc_opcode(16'h0101),
    .cfg_tx_pfc_en(1'b0),
    .cfg_tx_pfc_quanta({8{16'hffff}}),
    .cfg_tx_pfc_refresh({8{16'h7fff}}),
    .cfg_rx_lfc_opcode(16'h0001),
    .cfg_rx_lfc_en(1'b0),
    .cfg_rx_pfc_opcode(16'h0101),
    .cfg_rx_pfc_en(1'b0)
);

// ---------------------------------------------------------------------------
//  Reference frame + checker
// ---------------------------------------------------------------------------

localparam MAX_FRAME = 2048;

reg [7:0]  expected_mem [0:MAX_FRAME-1];
integer    expected_len    = 0;
integer    expected_idx    = 0;
integer    error_count     = 0;
integer    frame_count     = 0;

always @(posedge clk) begin
    if (rst) begin
        expected_idx <= 0;
    end else begin
        if (rx_axis_tvalid) begin
            if (expected_idx >= expected_len) begin
                $display("[%0t] ERROR frame %0d: extra byte %02h at idx %0d (expected_len=%0d)",
                         $time, frame_count, rx_axis_tdata, expected_idx, expected_len);
                error_count = error_count + 1;
            end else if (rx_axis_tdata !== expected_mem[expected_idx]) begin
                $display("[%0t] ERROR frame %0d: byte %0d got %02h expected %02h",
                         $time, frame_count, expected_idx, rx_axis_tdata,
                         expected_mem[expected_idx]);
                error_count = error_count + 1;
            end
            expected_idx <= expected_idx + 1;

            if (rx_axis_tlast) begin
                if ((expected_idx + 1) !== expected_len) begin
                    $display("[%0t] ERROR frame %0d: length %0d, expected %0d",
                             $time, frame_count, expected_idx + 1, expected_len);
                    error_count = error_count + 1;
                end
                if (rx_axis_tuser[0]) begin
                    $display("[%0t] ERROR frame %0d: rx_axis_tuser[0] (bad frame) set",
                             $time, frame_count);
                    error_count = error_count + 1;
                end
                frame_count  <= frame_count + 1;
                expected_idx <= 0;
            end
        end

        if (rx_error_bad_frame) begin
            $display("[%0t] ERROR: rx_error_bad_frame asserted (frame_count=%0d)",
                     $time, frame_count);
            error_count = error_count + 1;
        end
        if (rx_error_bad_fcs) begin
            $display("[%0t] ERROR: rx_error_bad_fcs asserted (frame_count=%0d)",
                     $time, frame_count);
            error_count = error_count + 1;
        end
        if (tx_error_underflow) begin
            $display("[%0t] ERROR: tx_error_underflow asserted (frame_count=%0d)",
                     $time, frame_count);
            error_count = error_count + 1;
        end
    end
end

// ---------------------------------------------------------------------------
//  Stimulus
// ---------------------------------------------------------------------------

task send_frame;
    input integer length;
    input [7:0]   start_val;
    integer i, padded_len, sent, target_count;
    begin
        padded_len = (length < 60) ? 60 : length;

        for (i = 0; i < length; i = i + 1)
            expected_mem[i] = start_val + i[7:0];
        for (i = length; i < padded_len; i = i + 1)
            expected_mem[i] = 8'h00;

        expected_len  = padded_len;
        target_count  = frame_count + 1;

        $display("[%0t] sending frame: payload=%0d (padded=%0d) start=%02h",
                 $time, length, padded_len, start_val);

        sent = 0;
        @(posedge clk);
        tx_axis_tdata  <= expected_mem[0];
        tx_axis_tvalid <= 1'b1;
        tx_axis_tlast  <= (length == 1);
        tx_axis_tuser  <= {TX_USER_WIDTH{1'b0}};

        while (sent < length) begin
            @(posedge clk);
            if (tx_axis_tready) begin
                sent = sent + 1;
                if (sent < length) begin
                    tx_axis_tdata <= expected_mem[sent];
                    tx_axis_tlast <= (sent == length - 1);
                end else begin
                    tx_axis_tvalid <= 1'b0;
                    tx_axis_tlast  <= 1'b0;
                end
            end
        end

        wait (frame_count == target_count);
        repeat (24) @(posedge clk);
    end
endtask

initial begin : main
    // hold reset
    repeat (16) @(posedge clk);
    rst <= 1'b0;
    repeat (8) @(posedge clk);

    send_frame(60,   8'h10);  // exactly min payload
    send_frame(64,   8'h20);
    send_frame(100,  8'h30);
    send_frame(256,  8'h40);
    send_frame(1500, 8'h50);
    send_frame(16,   8'h60);  // short payload, expect zero-padding

    repeat (200) @(posedge clk);

    if (frame_count !== 6) begin
        $display("[%0t] ERROR: %0d frames received (expected 6)",
                 $time, frame_count);
        error_count = error_count + 1;
    end

    if (error_count == 0)
        $display("[%0t] PASS: %0d frames OK", $time, frame_count);
    else
        $display("[%0t] FAIL: %0d errors", $time, error_count);

    $finish;
end

// safety timeout
initial begin
    #5_000_000;
    $display("[%0t] ERROR: timeout", $time);
    $finish;
end

endmodule

`resetall
