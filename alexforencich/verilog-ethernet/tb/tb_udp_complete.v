/*

Pure-Verilog self-checking testbench for udp_complete.

Methodology:
  * Drive an Ethernet IPv4/UDP frame into the DUT and check the decoded
    UDP header and payload.
  * Drive a UDP frame into the DUT transmit interface.  Check the emitted
    ARP request, inject an ARP reply, then check the emitted IPv4/UDP
    Ethernet frame.
  * Verify no DUT error outputs are asserted.
  * Print PASS or FAIL at end and $finish.

Run with iverilog:
    iverilog -g2012 -o sim_tb_udp_complete \
        ../rtl/udp_complete.v ../rtl/ip_complete.v ../rtl/ip.v \
        ../rtl/ip_eth_rx.v ../rtl/ip_eth_tx.v ../rtl/ip_arb_mux.v \
        ../rtl/eth_arb_mux.v ../rtl/arp.v ../rtl/arp_eth_rx.v \
        ../rtl/arp_eth_tx.v ../rtl/arp_cache.v ../rtl/lfsr.v \
        ../rtl/udp.v ../rtl/udp_ip_rx.v ../rtl/udp_ip_tx.v \
        ../../verilog-axis/rtl/arbiter.v \
        ../../verilog-axis/rtl/priority_encoder.v tb_udp_complete.v
    vvp sim_tb_udp_complete

UDP checksum generation is disabled here to keep the transmit test focused on
the udp_complete wrapper, IP framing, and ARP lookup path.

*/

`resetall
`timescale 1ns / 1ps
`default_nettype none

module tb_udp_complete;

localparam MAX_FRAME = 2048;

localparam [47:0] LOCAL_MAC  = 48'h020000000001;
localparam [47:0] REMOTE_MAC = 48'h020000000002;
localparam [31:0] LOCAL_IP   = 32'hc0a80180; // 192.168.1.128
localparam [31:0] REMOTE_IP  = 32'hc0a80181; // 192.168.1.129

reg clk = 1'b0;
reg rst = 1'b1;

always #4 clk = ~clk;  // 125 MHz

// ---------------------------------------------------------------------------
//  DUT ports
// ---------------------------------------------------------------------------

reg         s_eth_hdr_valid = 1'b0;
wire        s_eth_hdr_ready;
reg  [47:0] s_eth_dest_mac = 48'd0;
reg  [47:0] s_eth_src_mac = 48'd0;
reg  [15:0] s_eth_type = 16'd0;
reg  [7:0]  s_eth_payload_axis_tdata = 8'd0;
reg         s_eth_payload_axis_tvalid = 1'b0;
wire        s_eth_payload_axis_tready;
reg         s_eth_payload_axis_tlast = 1'b0;
reg         s_eth_payload_axis_tuser = 1'b0;

wire        m_eth_hdr_valid;
reg         m_eth_hdr_ready = 1'b1;
wire [47:0] m_eth_dest_mac;
wire [47:0] m_eth_src_mac;
wire [15:0] m_eth_type;
wire [7:0]  m_eth_payload_axis_tdata;
wire        m_eth_payload_axis_tvalid;
reg         m_eth_payload_axis_tready = 1'b1;
wire        m_eth_payload_axis_tlast;
wire        m_eth_payload_axis_tuser;

reg         s_ip_hdr_valid = 1'b0;
wire        s_ip_hdr_ready;
reg  [5:0]  s_ip_dscp = 6'd0;
reg  [1:0]  s_ip_ecn = 2'd0;
reg  [15:0] s_ip_length = 16'd0;
reg  [7:0]  s_ip_ttl = 8'd0;
reg  [7:0]  s_ip_protocol = 8'd0;
reg  [31:0] s_ip_source_ip = 32'd0;
reg  [31:0] s_ip_dest_ip = 32'd0;
reg  [7:0]  s_ip_payload_axis_tdata = 8'd0;
reg         s_ip_payload_axis_tvalid = 1'b0;
wire        s_ip_payload_axis_tready;
reg         s_ip_payload_axis_tlast = 1'b0;
reg         s_ip_payload_axis_tuser = 1'b0;

wire        m_ip_hdr_valid;
reg         m_ip_hdr_ready = 1'b1;
wire [47:0] m_ip_eth_dest_mac;
wire [47:0] m_ip_eth_src_mac;
wire [15:0] m_ip_eth_type;
wire [3:0]  m_ip_version;
wire [3:0]  m_ip_ihl;
wire [5:0]  m_ip_dscp;
wire [1:0]  m_ip_ecn;
wire [15:0] m_ip_length;
wire [15:0] m_ip_identification;
wire [2:0]  m_ip_flags;
wire [12:0] m_ip_fragment_offset;
wire [7:0]  m_ip_ttl;
wire [7:0]  m_ip_protocol;
wire [15:0] m_ip_header_checksum;
wire [31:0] m_ip_source_ip;
wire [31:0] m_ip_dest_ip;
wire [7:0]  m_ip_payload_axis_tdata;
wire        m_ip_payload_axis_tvalid;
reg         m_ip_payload_axis_tready = 1'b1;
wire        m_ip_payload_axis_tlast;
wire        m_ip_payload_axis_tuser;

reg         s_udp_hdr_valid = 1'b0;
wire        s_udp_hdr_ready;
reg  [5:0]  s_udp_ip_dscp = 6'd0;
reg  [1:0]  s_udp_ip_ecn = 2'd0;
reg  [7:0]  s_udp_ip_ttl = 8'd0;
reg  [31:0] s_udp_ip_source_ip = 32'd0;
reg  [31:0] s_udp_ip_dest_ip = 32'd0;
reg  [15:0] s_udp_source_port = 16'd0;
reg  [15:0] s_udp_dest_port = 16'd0;
reg  [15:0] s_udp_length = 16'd0;
reg  [15:0] s_udp_checksum = 16'd0;
reg  [7:0]  s_udp_payload_axis_tdata = 8'd0;
reg         s_udp_payload_axis_tvalid = 1'b0;
wire        s_udp_payload_axis_tready;
reg         s_udp_payload_axis_tlast = 1'b0;
reg         s_udp_payload_axis_tuser = 1'b0;

wire        m_udp_hdr_valid;
reg         m_udp_hdr_ready = 1'b1;
wire [47:0] m_udp_eth_dest_mac;
wire [47:0] m_udp_eth_src_mac;
wire [15:0] m_udp_eth_type;
wire [3:0]  m_udp_ip_version;
wire [3:0]  m_udp_ip_ihl;
wire [5:0]  m_udp_ip_dscp;
wire [1:0]  m_udp_ip_ecn;
wire [15:0] m_udp_ip_length;
wire [15:0] m_udp_ip_identification;
wire [2:0]  m_udp_ip_flags;
wire [12:0] m_udp_ip_fragment_offset;
wire [7:0]  m_udp_ip_ttl;
wire [7:0]  m_udp_ip_protocol;
wire [15:0] m_udp_ip_header_checksum;
wire [31:0] m_udp_ip_source_ip;
wire [31:0] m_udp_ip_dest_ip;
wire [15:0] m_udp_source_port;
wire [15:0] m_udp_dest_port;
wire [15:0] m_udp_length;
wire [15:0] m_udp_checksum;
wire [7:0]  m_udp_payload_axis_tdata;
wire        m_udp_payload_axis_tvalid;
reg         m_udp_payload_axis_tready = 1'b1;
wire        m_udp_payload_axis_tlast;
wire        m_udp_payload_axis_tuser;

wire        ip_rx_busy;
wire        ip_tx_busy;
wire        udp_rx_busy;
wire        udp_tx_busy;
wire        ip_rx_error_header_early_termination;
wire        ip_rx_error_payload_early_termination;
wire        ip_rx_error_invalid_header;
wire        ip_rx_error_invalid_checksum;
wire        ip_tx_error_payload_early_termination;
wire        ip_tx_error_arp_failed;
wire        udp_rx_error_header_early_termination;
wire        udp_rx_error_payload_early_termination;
wire        udp_tx_error_payload_early_termination;

udp_complete #(
    .ARP_CACHE_ADDR_WIDTH(2),
    .ARP_REQUEST_RETRY_COUNT(2),
    .ARP_REQUEST_RETRY_INTERVAL(2048),
    .ARP_REQUEST_TIMEOUT(4096),
    .UDP_CHECKSUM_GEN_ENABLE(0)
)
dut (
    .clk(clk),
    .rst(rst),

    .s_eth_hdr_valid(s_eth_hdr_valid),
    .s_eth_hdr_ready(s_eth_hdr_ready),
    .s_eth_dest_mac(s_eth_dest_mac),
    .s_eth_src_mac(s_eth_src_mac),
    .s_eth_type(s_eth_type),
    .s_eth_payload_axis_tdata(s_eth_payload_axis_tdata),
    .s_eth_payload_axis_tvalid(s_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(s_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast(s_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser(s_eth_payload_axis_tuser),

    .m_eth_hdr_valid(m_eth_hdr_valid),
    .m_eth_hdr_ready(m_eth_hdr_ready),
    .m_eth_dest_mac(m_eth_dest_mac),
    .m_eth_src_mac(m_eth_src_mac),
    .m_eth_type(m_eth_type),
    .m_eth_payload_axis_tdata(m_eth_payload_axis_tdata),
    .m_eth_payload_axis_tvalid(m_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(m_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast(m_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser(m_eth_payload_axis_tuser),

    .s_ip_hdr_valid(s_ip_hdr_valid),
    .s_ip_hdr_ready(s_ip_hdr_ready),
    .s_ip_dscp(s_ip_dscp),
    .s_ip_ecn(s_ip_ecn),
    .s_ip_length(s_ip_length),
    .s_ip_ttl(s_ip_ttl),
    .s_ip_protocol(s_ip_protocol),
    .s_ip_source_ip(s_ip_source_ip),
    .s_ip_dest_ip(s_ip_dest_ip),
    .s_ip_payload_axis_tdata(s_ip_payload_axis_tdata),
    .s_ip_payload_axis_tvalid(s_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready(s_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast(s_ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser(s_ip_payload_axis_tuser),

    .m_ip_hdr_valid(m_ip_hdr_valid),
    .m_ip_hdr_ready(m_ip_hdr_ready),
    .m_ip_eth_dest_mac(m_ip_eth_dest_mac),
    .m_ip_eth_src_mac(m_ip_eth_src_mac),
    .m_ip_eth_type(m_ip_eth_type),
    .m_ip_version(m_ip_version),
    .m_ip_ihl(m_ip_ihl),
    .m_ip_dscp(m_ip_dscp),
    .m_ip_ecn(m_ip_ecn),
    .m_ip_length(m_ip_length),
    .m_ip_identification(m_ip_identification),
    .m_ip_flags(m_ip_flags),
    .m_ip_fragment_offset(m_ip_fragment_offset),
    .m_ip_ttl(m_ip_ttl),
    .m_ip_protocol(m_ip_protocol),
    .m_ip_header_checksum(m_ip_header_checksum),
    .m_ip_source_ip(m_ip_source_ip),
    .m_ip_dest_ip(m_ip_dest_ip),
    .m_ip_payload_axis_tdata(m_ip_payload_axis_tdata),
    .m_ip_payload_axis_tvalid(m_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready(m_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast(m_ip_payload_axis_tlast),
    .m_ip_payload_axis_tuser(m_ip_payload_axis_tuser),

    .s_udp_hdr_valid(s_udp_hdr_valid),
    .s_udp_hdr_ready(s_udp_hdr_ready),
    .s_udp_ip_dscp(s_udp_ip_dscp),
    .s_udp_ip_ecn(s_udp_ip_ecn),
    .s_udp_ip_ttl(s_udp_ip_ttl),
    .s_udp_ip_source_ip(s_udp_ip_source_ip),
    .s_udp_ip_dest_ip(s_udp_ip_dest_ip),
    .s_udp_source_port(s_udp_source_port),
    .s_udp_dest_port(s_udp_dest_port),
    .s_udp_length(s_udp_length),
    .s_udp_checksum(s_udp_checksum),
    .s_udp_payload_axis_tdata(s_udp_payload_axis_tdata),
    .s_udp_payload_axis_tvalid(s_udp_payload_axis_tvalid),
    .s_udp_payload_axis_tready(s_udp_payload_axis_tready),
    .s_udp_payload_axis_tlast(s_udp_payload_axis_tlast),
    .s_udp_payload_axis_tuser(s_udp_payload_axis_tuser),

    .m_udp_hdr_valid(m_udp_hdr_valid),
    .m_udp_hdr_ready(m_udp_hdr_ready),
    .m_udp_eth_dest_mac(m_udp_eth_dest_mac),
    .m_udp_eth_src_mac(m_udp_eth_src_mac),
    .m_udp_eth_type(m_udp_eth_type),
    .m_udp_ip_version(m_udp_ip_version),
    .m_udp_ip_ihl(m_udp_ip_ihl),
    .m_udp_ip_dscp(m_udp_ip_dscp),
    .m_udp_ip_ecn(m_udp_ip_ecn),
    .m_udp_ip_length(m_udp_ip_length),
    .m_udp_ip_identification(m_udp_ip_identification),
    .m_udp_ip_flags(m_udp_ip_flags),
    .m_udp_ip_fragment_offset(m_udp_ip_fragment_offset),
    .m_udp_ip_ttl(m_udp_ip_ttl),
    .m_udp_ip_protocol(m_udp_ip_protocol),
    .m_udp_ip_header_checksum(m_udp_ip_header_checksum),
    .m_udp_ip_source_ip(m_udp_ip_source_ip),
    .m_udp_ip_dest_ip(m_udp_ip_dest_ip),
    .m_udp_source_port(m_udp_source_port),
    .m_udp_dest_port(m_udp_dest_port),
    .m_udp_length(m_udp_length),
    .m_udp_checksum(m_udp_checksum),
    .m_udp_payload_axis_tdata(m_udp_payload_axis_tdata),
    .m_udp_payload_axis_tvalid(m_udp_payload_axis_tvalid),
    .m_udp_payload_axis_tready(m_udp_payload_axis_tready),
    .m_udp_payload_axis_tlast(m_udp_payload_axis_tlast),
    .m_udp_payload_axis_tuser(m_udp_payload_axis_tuser),

    .ip_rx_busy(ip_rx_busy),
    .ip_tx_busy(ip_tx_busy),
    .udp_rx_busy(udp_rx_busy),
    .udp_tx_busy(udp_tx_busy),
    .ip_rx_error_header_early_termination(ip_rx_error_header_early_termination),
    .ip_rx_error_payload_early_termination(ip_rx_error_payload_early_termination),
    .ip_rx_error_invalid_header(ip_rx_error_invalid_header),
    .ip_rx_error_invalid_checksum(ip_rx_error_invalid_checksum),
    .ip_tx_error_payload_early_termination(ip_tx_error_payload_early_termination),
    .ip_tx_error_arp_failed(ip_tx_error_arp_failed),
    .udp_rx_error_header_early_termination(udp_rx_error_header_early_termination),
    .udp_rx_error_payload_early_termination(udp_rx_error_payload_early_termination),
    .udp_tx_error_payload_early_termination(udp_tx_error_payload_early_termination),

    .local_mac(LOCAL_MAC),
    .local_ip(LOCAL_IP),
    .gateway_ip(LOCAL_IP),
    .subnet_mask(32'hffffff00),
    .clear_arp_cache(1'b0)
);

// ---------------------------------------------------------------------------
//  Reference data and helpers
// ---------------------------------------------------------------------------

reg [7:0] tx_eth_payload_mem [0:MAX_FRAME-1];
reg [7:0] cap_eth_payload_mem [0:MAX_FRAME-1];
reg [47:0] cap_eth_dest_mac;
reg [47:0] cap_eth_src_mac;
reg [15:0] cap_eth_type;
integer cap_eth_len = 0;
integer error_count = 0;

reg eth_frame_active = 1'b0;
reg eth_frame_done = 1'b0;

reg rx_udp_expect_valid = 1'b0;
reg rx_udp_header_seen = 1'b0;
reg rx_udp_done = 1'b0;
integer rx_udp_exp_payload_len = 0;
reg [7:0] rx_udp_exp_start_val = 8'd0;
reg [15:0] rx_udp_exp_source_port = 16'd0;
reg [15:0] rx_udp_exp_dest_port = 16'd0;
reg [15:0] rx_udp_exp_checksum = 16'd0;
integer rx_udp_payload_idx = 0;

function [15:0] fold_checksum;
    input [31:0] sum_in;
    reg [31:0] sum;
    begin
        sum = sum_in;
        sum = (sum & 32'h0000ffff) + (sum >> 16);
        sum = (sum & 32'h0000ffff) + (sum >> 16);
        fold_checksum = ~sum[15:0];
    end
endfunction

function [15:0] ipv4_checksum;
    input [7:0]  dscp_ecn;
    input [15:0] length;
    input [15:0] identification;
    input [15:0] flags_fragment;
    input [7:0]  ttl;
    input [7:0]  protocol;
    input [31:0] source_ip;
    input [31:0] dest_ip;
    reg [31:0] sum;
    begin
        sum = {8'h45, dscp_ecn} + length + identification + flags_fragment +
              {ttl, protocol} + source_ip[31:16] + source_ip[15:0] +
              dest_ip[31:16] + dest_ip[15:0];
        ipv4_checksum = fold_checksum(sum);
    end
endfunction

task check8;
    input [511:0] name;
    input [7:0] got;
    input [7:0] exp;
    begin
        if (got !== exp) begin
            $display("[%0t] ERROR %0s: got %02h expected %02h",
                     $time, name, got, exp);
            error_count = error_count + 1;
        end
    end
endtask

task check16;
    input [511:0] name;
    input [15:0] got;
    input [15:0] exp;
    begin
        if (got !== exp) begin
            $display("[%0t] ERROR %0s: got %04h expected %04h",
                     $time, name, got, exp);
            error_count = error_count + 1;
        end
    end
endtask

task check32;
    input [511:0] name;
    input [31:0] got;
    input [31:0] exp;
    begin
        if (got !== exp) begin
            $display("[%0t] ERROR %0s: got %08h expected %08h",
                     $time, name, got, exp);
            error_count = error_count + 1;
        end
    end
endtask

task check48;
    input [511:0] name;
    input [47:0] got;
    input [47:0] exp;
    begin
        if (got !== exp) begin
            $display("[%0t] ERROR %0s: got %012h expected %012h",
                     $time, name, got, exp);
            error_count = error_count + 1;
        end
    end
endtask

task build_ipv4_udp_payload;
    input integer payload_len;
    input [7:0] start_val;
    input [15:0] source_port;
    input [15:0] dest_port;
    input [15:0] checksum;
    integer i;
    reg [15:0] ip_len;
    reg [15:0] udp_len;
    reg [15:0] ip_sum;
    begin
        udp_len = payload_len + 8;
        ip_len = payload_len + 28;
        ip_sum = ipv4_checksum(8'h05, ip_len, 16'h1234, 16'h4000, 8'h40, 8'h11,
                               REMOTE_IP, LOCAL_IP);

        tx_eth_payload_mem[0]  = 8'h45;
        tx_eth_payload_mem[1]  = 8'h05;
        tx_eth_payload_mem[2]  = ip_len[15:8];
        tx_eth_payload_mem[3]  = ip_len[7:0];
        tx_eth_payload_mem[4]  = 8'h12;
        tx_eth_payload_mem[5]  = 8'h34;
        tx_eth_payload_mem[6]  = 8'h40;
        tx_eth_payload_mem[7]  = 8'h00;
        tx_eth_payload_mem[8]  = 8'h40;
        tx_eth_payload_mem[9]  = 8'h11;
        tx_eth_payload_mem[10] = ip_sum[15:8];
        tx_eth_payload_mem[11] = ip_sum[7:0];
        tx_eth_payload_mem[12] = REMOTE_IP[31:24];
        tx_eth_payload_mem[13] = REMOTE_IP[23:16];
        tx_eth_payload_mem[14] = REMOTE_IP[15:8];
        tx_eth_payload_mem[15] = REMOTE_IP[7:0];
        tx_eth_payload_mem[16] = LOCAL_IP[31:24];
        tx_eth_payload_mem[17] = LOCAL_IP[23:16];
        tx_eth_payload_mem[18] = LOCAL_IP[15:8];
        tx_eth_payload_mem[19] = LOCAL_IP[7:0];

        tx_eth_payload_mem[20] = source_port[15:8];
        tx_eth_payload_mem[21] = source_port[7:0];
        tx_eth_payload_mem[22] = dest_port[15:8];
        tx_eth_payload_mem[23] = dest_port[7:0];
        tx_eth_payload_mem[24] = udp_len[15:8];
        tx_eth_payload_mem[25] = udp_len[7:0];
        tx_eth_payload_mem[26] = checksum[15:8];
        tx_eth_payload_mem[27] = checksum[7:0];

        for (i = 0; i < payload_len; i = i + 1)
            tx_eth_payload_mem[28+i] = start_val + i[7:0];
    end
endtask

task build_arp_reply_payload;
    begin
        tx_eth_payload_mem[0]  = 8'h00;
        tx_eth_payload_mem[1]  = 8'h01;
        tx_eth_payload_mem[2]  = 8'h08;
        tx_eth_payload_mem[3]  = 8'h00;
        tx_eth_payload_mem[4]  = 8'h06;
        tx_eth_payload_mem[5]  = 8'h04;
        tx_eth_payload_mem[6]  = 8'h00;
        tx_eth_payload_mem[7]  = 8'h02;
        tx_eth_payload_mem[8]  = REMOTE_MAC[47:40];
        tx_eth_payload_mem[9]  = REMOTE_MAC[39:32];
        tx_eth_payload_mem[10] = REMOTE_MAC[31:24];
        tx_eth_payload_mem[11] = REMOTE_MAC[23:16];
        tx_eth_payload_mem[12] = REMOTE_MAC[15:8];
        tx_eth_payload_mem[13] = REMOTE_MAC[7:0];
        tx_eth_payload_mem[14] = REMOTE_IP[31:24];
        tx_eth_payload_mem[15] = REMOTE_IP[23:16];
        tx_eth_payload_mem[16] = REMOTE_IP[15:8];
        tx_eth_payload_mem[17] = REMOTE_IP[7:0];
        tx_eth_payload_mem[18] = LOCAL_MAC[47:40];
        tx_eth_payload_mem[19] = LOCAL_MAC[39:32];
        tx_eth_payload_mem[20] = LOCAL_MAC[31:24];
        tx_eth_payload_mem[21] = LOCAL_MAC[23:16];
        tx_eth_payload_mem[22] = LOCAL_MAC[15:8];
        tx_eth_payload_mem[23] = LOCAL_MAC[7:0];
        tx_eth_payload_mem[24] = LOCAL_IP[31:24];
        tx_eth_payload_mem[25] = LOCAL_IP[23:16];
        tx_eth_payload_mem[26] = LOCAL_IP[15:8];
        tx_eth_payload_mem[27] = LOCAL_IP[7:0];
    end
endtask

// ---------------------------------------------------------------------------
//  Stream drivers and checkers
// ---------------------------------------------------------------------------

task expect_udp_rx_start;
    input integer payload_len;
    input [7:0] start_val;
    input [15:0] source_port;
    input [15:0] dest_port;
    input [15:0] checksum;
    begin
        rx_udp_exp_payload_len = payload_len;
        rx_udp_exp_start_val = start_val;
        rx_udp_exp_source_port = source_port;
        rx_udp_exp_dest_port = dest_port;
        rx_udp_exp_checksum = checksum;
        rx_udp_payload_idx = 0;
        rx_udp_done = 1'b0;
        rx_udp_header_seen = 1'b0;
        rx_udp_expect_valid = 1'b1;
    end
endtask

task wait_udp_rx_done;
    begin
        while (!rx_udp_done)
            @(posedge clk);
        #1;
        rx_udp_done = 1'b0;
    end
endtask

task wait_eth_frame_done;
    begin
        while (!eth_frame_done)
            @(posedge clk);
        #1;
        eth_frame_done = 1'b0;
    end
endtask

task send_eth_frame_from_mem;
    input [47:0] dest_mac;
    input [47:0] src_mac;
    input [15:0] eth_type;
    input integer length;
    integer sent;
    begin
        @(posedge clk);
        #1;
        s_eth_dest_mac = dest_mac;
        s_eth_src_mac = src_mac;
        s_eth_type = eth_type;
        s_eth_hdr_valid = 1'b1;

        @(posedge clk);
        while (!s_eth_hdr_ready)
            @(posedge clk);

        #1;
        s_eth_hdr_valid = 1'b0;

        sent = 0;
        s_eth_payload_axis_tdata = tx_eth_payload_mem[0];
        s_eth_payload_axis_tvalid = 1'b1;
        s_eth_payload_axis_tlast = (length == 1);
        s_eth_payload_axis_tuser = 1'b0;

        while (sent < length) begin
            @(posedge clk);
            if (s_eth_payload_axis_tready) begin
                sent = sent + 1;
                #1;
                if (sent < length) begin
                    s_eth_payload_axis_tdata = tx_eth_payload_mem[sent];
                    s_eth_payload_axis_tlast = (sent == length - 1);
                end else begin
                    s_eth_payload_axis_tvalid = 1'b0;
                    s_eth_payload_axis_tlast = 1'b0;
                end
            end
        end
    end
endtask

task start_udp_frame;
    input integer payload_len;
    input [15:0] source_port;
    input [15:0] dest_port;
    input [15:0] checksum;
    begin
        @(posedge clk);
        #1;
        s_udp_ip_dscp = 6'h15;
        s_udp_ip_ecn = 2'h2;
        s_udp_ip_ttl = 8'h40;
        s_udp_ip_source_ip = LOCAL_IP;
        s_udp_ip_dest_ip = REMOTE_IP;
        s_udp_source_port = source_port;
        s_udp_dest_port = dest_port;
        s_udp_length = payload_len + 8;
        s_udp_checksum = checksum;
        s_udp_hdr_valid = 1'b1;

        @(posedge clk);
        while (!s_udp_hdr_ready)
            @(posedge clk);

        #1;
        s_udp_hdr_valid = 1'b0;
    end
endtask

task send_udp_payload;
    input integer payload_len;
    input [7:0] start_val;
    integer sent;
    begin
        sent = 0;
        s_udp_payload_axis_tdata = start_val;
        s_udp_payload_axis_tvalid = 1'b1;
        s_udp_payload_axis_tlast = (payload_len == 1);
        s_udp_payload_axis_tuser = 1'b0;

        while (sent < payload_len) begin
            @(posedge clk);
            if (s_udp_payload_axis_tready) begin
                sent = sent + 1;
                #1;
                if (sent < payload_len) begin
                    s_udp_payload_axis_tdata = start_val + sent[7:0];
                    s_udp_payload_axis_tlast = (sent == payload_len - 1);
                end else begin
                    s_udp_payload_axis_tvalid = 1'b0;
                    s_udp_payload_axis_tlast = 1'b0;
                end
            end
        end
    end
endtask

task send_udp_frame;
    input integer payload_len;
    input [7:0] start_val;
    input [15:0] source_port;
    input [15:0] dest_port;
    input [15:0] checksum;
    begin
        start_udp_frame(payload_len, source_port, dest_port, checksum);
        send_udp_payload(payload_len, start_val);
    end
endtask

task check_udp_rx_header;
    begin
        check48("rx udp eth dest mac", m_udp_eth_dest_mac, LOCAL_MAC);
        check48("rx udp eth src mac", m_udp_eth_src_mac, REMOTE_MAC);
        check16("rx udp eth type", m_udp_eth_type, 16'h0800);
        check8("rx udp ip version", {4'd0, m_udp_ip_version}, 8'h04);
        check8("rx udp ip ihl", {4'd0, m_udp_ip_ihl}, 8'h05);
        check8("rx udp ip dscp", {2'd0, m_udp_ip_dscp}, 8'h01);
        check8("rx udp ip ecn", {6'd0, m_udp_ip_ecn}, 8'h01);
        check16("rx udp ip length", m_udp_ip_length, rx_udp_exp_payload_len + 28);
        check16("rx udp ip identification", m_udp_ip_identification, 16'h1234);
        check8("rx udp ip flags", {5'd0, m_udp_ip_flags}, 8'h02);
        check16("rx udp ip fragment offset", {3'd0, m_udp_ip_fragment_offset}, 16'h0000);
        check8("rx udp ip ttl", m_udp_ip_ttl, 8'h40);
        check8("rx udp ip protocol", m_udp_ip_protocol, 8'h11);
        check16("rx udp ip checksum", m_udp_ip_header_checksum,
                ipv4_checksum(8'h05, rx_udp_exp_payload_len + 28, 16'h1234, 16'h4000,
                              8'h40, 8'h11, REMOTE_IP, LOCAL_IP));
        check32("rx udp ip source", m_udp_ip_source_ip, REMOTE_IP);
        check32("rx udp ip dest", m_udp_ip_dest_ip, LOCAL_IP);
        check16("rx udp source port", m_udp_source_port, rx_udp_exp_source_port);
        check16("rx udp dest port", m_udp_dest_port, rx_udp_exp_dest_port);
        check16("rx udp length", m_udp_length, rx_udp_exp_payload_len + 8);
        check16("rx udp checksum", m_udp_checksum, rx_udp_exp_checksum);
    end
endtask

task check_arp_request;
    begin
        check48("arp request eth dest", cap_eth_dest_mac, 48'hffffffffffff);
        check48("arp request eth src", cap_eth_src_mac, LOCAL_MAC);
        check16("arp request eth type", cap_eth_type, 16'h0806);
        check16("arp request length", cap_eth_len[15:0], 16'd28);
        check8("arp htype 0", cap_eth_payload_mem[0], 8'h00);
        check8("arp htype 1", cap_eth_payload_mem[1], 8'h01);
        check8("arp ptype 0", cap_eth_payload_mem[2], 8'h08);
        check8("arp ptype 1", cap_eth_payload_mem[3], 8'h00);
        check8("arp hlen", cap_eth_payload_mem[4], 8'h06);
        check8("arp plen", cap_eth_payload_mem[5], 8'h04);
        check8("arp oper 0", cap_eth_payload_mem[6], 8'h00);
        check8("arp oper 1", cap_eth_payload_mem[7], 8'h01);
        check48("arp sha", {cap_eth_payload_mem[8], cap_eth_payload_mem[9],
                            cap_eth_payload_mem[10], cap_eth_payload_mem[11],
                            cap_eth_payload_mem[12], cap_eth_payload_mem[13]},
                LOCAL_MAC);
        check32("arp spa", {cap_eth_payload_mem[14], cap_eth_payload_mem[15],
                            cap_eth_payload_mem[16], cap_eth_payload_mem[17]},
                LOCAL_IP);
        check48("arp tha", {cap_eth_payload_mem[18], cap_eth_payload_mem[19],
                            cap_eth_payload_mem[20], cap_eth_payload_mem[21],
                            cap_eth_payload_mem[22], cap_eth_payload_mem[23]},
                48'h000000000000);
        check32("arp tpa", {cap_eth_payload_mem[24], cap_eth_payload_mem[25],
                            cap_eth_payload_mem[26], cap_eth_payload_mem[27]},
                REMOTE_IP);
    end
endtask

task check_udp_tx_frame;
    input integer payload_len;
    input [7:0] start_val;
    input [15:0] source_port;
    input [15:0] dest_port;
    input [15:0] checksum;
    integer i;
    reg [15:0] ip_len;
    reg [15:0] udp_len;
    begin
        ip_len = payload_len + 28;
        udp_len = payload_len + 8;

        check48("tx ip eth dest", cap_eth_dest_mac, REMOTE_MAC);
        check48("tx ip eth src", cap_eth_src_mac, LOCAL_MAC);
        check16("tx ip eth type", cap_eth_type, 16'h0800);
        check16("tx ip payload length", cap_eth_len[15:0], ip_len);

        check8("tx ip version/ihl", cap_eth_payload_mem[0], 8'h45);
        check8("tx ip dscp/ecn", cap_eth_payload_mem[1], 8'h56);
        check16("tx ip length", {cap_eth_payload_mem[2], cap_eth_payload_mem[3]}, ip_len);
        check16("tx ip identification", {cap_eth_payload_mem[4], cap_eth_payload_mem[5]}, 16'h0000);
        check16("tx ip flags/fragment", {cap_eth_payload_mem[6], cap_eth_payload_mem[7]}, 16'h4000);
        check8("tx ip ttl", cap_eth_payload_mem[8], 8'h40);
        check8("tx ip protocol", cap_eth_payload_mem[9], 8'h11);
        check16("tx ip checksum", {cap_eth_payload_mem[10], cap_eth_payload_mem[11]},
                ipv4_checksum(8'h56, ip_len, 16'h0000, 16'h4000,
                              8'h40, 8'h11, LOCAL_IP, REMOTE_IP));
        check32("tx ip source", {cap_eth_payload_mem[12], cap_eth_payload_mem[13],
                                 cap_eth_payload_mem[14], cap_eth_payload_mem[15]},
                LOCAL_IP);
        check32("tx ip dest", {cap_eth_payload_mem[16], cap_eth_payload_mem[17],
                               cap_eth_payload_mem[18], cap_eth_payload_mem[19]},
                REMOTE_IP);

        check16("tx udp source port", {cap_eth_payload_mem[20], cap_eth_payload_mem[21]}, source_port);
        check16("tx udp dest port", {cap_eth_payload_mem[22], cap_eth_payload_mem[23]}, dest_port);
        check16("tx udp length", {cap_eth_payload_mem[24], cap_eth_payload_mem[25]}, udp_len);
        check16("tx udp checksum", {cap_eth_payload_mem[26], cap_eth_payload_mem[27]}, checksum);

        for (i = 0; i < payload_len; i = i + 1)
            check8("tx udp payload byte", cap_eth_payload_mem[28+i], start_val + i[7:0]);

        if (m_eth_payload_axis_tuser) begin
            $display("[%0t] ERROR tx ip frame: tuser asserted", $time);
            error_count = error_count + 1;
        end
    end
endtask

always @(posedge clk) begin
    if (rst) begin
        eth_frame_active = 1'b0;
        eth_frame_done = 1'b0;
        cap_eth_len = 0;
    end else begin
        if (m_eth_hdr_valid && m_eth_hdr_ready && !eth_frame_active) begin
            cap_eth_dest_mac = m_eth_dest_mac;
            cap_eth_src_mac = m_eth_src_mac;
            cap_eth_type = m_eth_type;
            cap_eth_len = 0;
            eth_frame_active = 1'b1;
        end

        if ((eth_frame_active || (m_eth_hdr_valid && m_eth_hdr_ready)) &&
            m_eth_payload_axis_tvalid && m_eth_payload_axis_tready) begin
            if (cap_eth_len < MAX_FRAME)
                cap_eth_payload_mem[cap_eth_len] = m_eth_payload_axis_tdata;
            cap_eth_len = cap_eth_len + 1;

            if (m_eth_payload_axis_tlast) begin
                eth_frame_active = 1'b0;
                eth_frame_done = 1'b1;
            end
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        rx_udp_expect_valid <= 1'b0;
        rx_udp_header_seen <= 1'b0;
        rx_udp_done <= 1'b0;
        rx_udp_payload_idx <= 0;
    end else begin
        if (m_udp_hdr_valid && m_udp_hdr_ready) begin
            if (!rx_udp_expect_valid || rx_udp_header_seen) begin
                $display("[%0t] ERROR rx udp: unexpected header", $time);
                error_count = error_count + 1;
            end else begin
                check_udp_rx_header();
                rx_udp_header_seen <= 1'b1;
                rx_udp_payload_idx <= 0;
            end
        end

        if (m_udp_payload_axis_tvalid && m_udp_payload_axis_tready) begin
            if (!rx_udp_expect_valid || !rx_udp_header_seen) begin
                $display("[%0t] ERROR rx udp payload: unexpected byte %02h",
                         $time, m_udp_payload_axis_tdata);
                error_count = error_count + 1;
            end else begin
                if (rx_udp_payload_idx >= rx_udp_exp_payload_len) begin
                    $display("[%0t] ERROR rx udp payload: extra byte %02h at idx %0d",
                             $time, m_udp_payload_axis_tdata, rx_udp_payload_idx);
                    error_count = error_count + 1;
                end else begin
                    check8("rx udp payload byte", m_udp_payload_axis_tdata,
                           rx_udp_exp_start_val + rx_udp_payload_idx[7:0]);
                end

                if (m_udp_payload_axis_tuser) begin
                    $display("[%0t] ERROR rx udp payload: tuser asserted", $time);
                    error_count = error_count + 1;
                end

                rx_udp_payload_idx <= rx_udp_payload_idx + 1;

                if (m_udp_payload_axis_tlast) begin
                    if (rx_udp_payload_idx + 1 != rx_udp_exp_payload_len) begin
                        $display("[%0t] ERROR rx udp payload length: got %0d expected %0d",
                                 $time, rx_udp_payload_idx + 1, rx_udp_exp_payload_len);
                        error_count = error_count + 1;
                    end
                    rx_udp_expect_valid <= 1'b0;
                    rx_udp_header_seen <= 1'b0;
                    rx_udp_done <= 1'b1;
                end
            end
        end
    end
end

always @(posedge clk) begin
    if (!rst) begin
        if (ip_rx_error_header_early_termination) begin
            $display("[%0t] ERROR: ip_rx_error_header_early_termination asserted", $time);
            error_count = error_count + 1;
        end
        if (ip_rx_error_payload_early_termination) begin
            $display("[%0t] ERROR: ip_rx_error_payload_early_termination asserted", $time);
            error_count = error_count + 1;
        end
        if (ip_rx_error_invalid_header) begin
            $display("[%0t] ERROR: ip_rx_error_invalid_header asserted", $time);
            error_count = error_count + 1;
        end
        if (ip_rx_error_invalid_checksum) begin
            $display("[%0t] ERROR: ip_rx_error_invalid_checksum asserted", $time);
            error_count = error_count + 1;
        end
        if (ip_tx_error_payload_early_termination) begin
            $display("[%0t] ERROR: ip_tx_error_payload_early_termination asserted", $time);
            error_count = error_count + 1;
        end
        if (ip_tx_error_arp_failed) begin
            $display("[%0t] ERROR: ip_tx_error_arp_failed asserted", $time);
            error_count = error_count + 1;
        end
        if (udp_rx_error_header_early_termination) begin
            $display("[%0t] ERROR: udp_rx_error_header_early_termination asserted", $time);
            error_count = error_count + 1;
        end
        if (udp_rx_error_payload_early_termination) begin
            $display("[%0t] ERROR: udp_rx_error_payload_early_termination asserted", $time);
            error_count = error_count + 1;
        end
        if (udp_tx_error_payload_early_termination) begin
            $display("[%0t] ERROR: udp_tx_error_payload_early_termination asserted", $time);
            error_count = error_count + 1;
        end
    end
end

// ---------------------------------------------------------------------------
//  Test sequence
// ---------------------------------------------------------------------------

initial begin : main
    repeat (16) @(posedge clk);
    rst <= 1'b0;
    repeat (8) @(posedge clk);

    $display("[%0t] RX test: Ethernet IPv4/UDP to UDP interface", $time);
    build_ipv4_udp_payload(32, 8'h80, 16'h1234, 16'h5678, 16'h0000);
    expect_udp_rx_start(32, 8'h80, 16'h1234, 16'h5678, 16'h0000);
    send_eth_frame_from_mem(LOCAL_MAC, REMOTE_MAC, 16'h0800, 60);
    wait_udp_rx_done();

    repeat (16) @(posedge clk);

    $display("[%0t] TX test: UDP interface through ARP to Ethernet IPv4/UDP", $time);
    eth_frame_done = 1'b0;
    start_udp_frame(24, 16'h1111, 16'h2222, 16'h3333);
    wait_eth_frame_done();
    check_arp_request();

    eth_frame_done = 1'b0;
    build_arp_reply_payload();
    send_eth_frame_from_mem(LOCAL_MAC, REMOTE_MAC, 16'h0806, 28);
    send_udp_payload(24, 8'ha0);
    wait_eth_frame_done();
    check_udp_tx_frame(24, 8'ha0, 16'h1111, 16'h2222, 16'h3333);

    repeat (200) @(posedge clk);

    if (error_count == 0)
        $display("[%0t] PASS", $time);
    else
        $display("[%0t] FAIL: %0d errors", $time, error_count);

    $finish;
end

initial begin
    #5_000_000;
    $display("[%0t] ERROR: timeout", $time);
    $finish;
end

endmodule

`resetall
