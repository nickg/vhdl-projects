module longbimpy_tb;

  localparam IAW=8;
  localparam IBW=12;

  localparam AW = (IAW<IBW) ? IAW : IBW,
	     BW = (IAW<IBW) ? IBW : IAW;

  reg i_clk;
  reg [(IAW-1):0] i_a_unsorted;
  reg [(IBW-1):0] i_b_unsorted;
  wire [(AW+BW-1):0] o_r;

  longbimpy #(IAW, IBW) dut (i_clk, 1'b1, i_a_unsorted, i_b_unsorted, o_r);

  initial begin
    i_clk = 1'b0;
    forever #5 i_clk = ~i_clk;
  end

  integer rnd;

  initial begin
    i_a_unsorted = 0;
    i_b_unsorted = 0;
    rnd = 123;

    repeat (100) begin
      @(posedge i_clk);
      i_a_unsorted <= $random(rnd);
      i_b_unsorted <= $random(rnd);
    end

    $finish;
  end // initial begin

  always @(posedge i_clk) begin
    $display("%t %x %x | %x", $time, i_a_unsorted, i_b_unsorted, o_r);
  end

endmodule // longbimpy_tb

