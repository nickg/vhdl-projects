module convround_tb;
  localparam  IWID=39, OWID=17, SHIFT=4;

  reg	i_clk, i_ce;
  reg	signed [(IWID-1):0]   i_val;
  wire	signed [(OWID-1):0] o_val;

  convround #(IWID, OWID, SHIFT) dut (i_clk, i_ce, i_val, o_val);

  initial begin
    i_clk = 1'b0;
    forever #5 i_clk = ~i_clk;
  end

  integer rnd;

  initial begin
    i_ce = 1;
    rnd = 123;
    i_val = 0;

    repeat (100) begin
      @(posedge i_clk);
      i_val <= $random(rnd);
    end

    $finish;
  end

  always @(posedge i_clk) begin
    $display("%t %x | %x", $time, i_val, o_val);
  end

endmodule // convround_tb
