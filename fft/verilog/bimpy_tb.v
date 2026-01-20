module bimpy_tb;

  localparam BW=18;
  localparam LUTB=2;

  reg i_clk, i_reset;
  reg [(LUTB-1):0] i_a;
  reg [(BW-1):0] i_b;
  wire [(BW+LUTB-1):0] o_r;

  bimpy #(BW) dut (i_clk, i_reset, 1'b1, i_a, i_b, o_r);

  initial begin
    i_clk = 1'b0;
    forever #5 i_clk = ~i_clk;
  end

  integer rnd;

  initial begin
    i_reset = 1'b1;
    i_a = 0;
    i_b = 0;
    rnd = 123;

    repeat (5) @(posedge i_clk);
    i_reset = 1'b0;

    repeat (100) begin
      @(posedge i_clk);
      i_a <= $random(rnd);
      i_b <= $random(rnd);
    end

    $finish;
  end // initial begin

  always @(posedge i_clk) begin
    if (!i_reset)
      $display("%t %x %x | %x", $time, i_a, i_b, o_r);
  end

endmodule // bimpy_tb
