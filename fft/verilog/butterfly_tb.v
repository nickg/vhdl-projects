module butterfly_tb;

    // Parameters (match DUT)
    localparam IWIDTH = 16;
    localparam CWIDTH = 20;
    localparam OWIDTH = 17;

    // Clock and control
    reg i_clk;
    reg i_reset;
    reg i_ce;

    // Inputs
    reg [(2*CWIDTH-1):0] i_coef;
    reg [(2*IWIDTH-1):0] i_left;
    reg [(2*IWIDTH-1):0] i_right;
    reg                  i_aux;

    // Outputs
    wire [(2*OWIDTH-1):0] o_left;
    wire [(2*OWIDTH-1):0] o_right;
    wire                  o_aux;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------
    butterfly #(
        .IWIDTH(IWIDTH),
        .CWIDTH(CWIDTH),
        .OWIDTH(OWIDTH)
    ) dut (
        .i_clk   (i_clk),
        .i_reset (i_reset),
        .i_ce    (i_ce),
        .i_coef  (i_coef),
        .i_left  (i_left),
        .i_right (i_right),
        .i_aux   (i_aux),
        .o_left  (o_left),
        .o_right (o_right),
        .o_aux   (o_aux)
    );

    // ------------------------------------------------------------
    // Clock generation: 100 MHz
    // ------------------------------------------------------------
    initial begin
        i_clk = 1'b0;
        forever #5 i_clk = ~i_clk;
    end

    // ------------------------------------------------------------
    // Stimulus
    // ------------------------------------------------------------
    integer k;
    integer rnd;

    initial begin
        // Init
        i_reset = 1'b1;
        i_ce    = 1'b0;
        i_left  = 1'b0;
        i_right = 1'b0;
        i_coef  = 1'b0;
        i_aux   = 1'b0;
        rnd = 123;

        // Hold reset
        repeat (5) @(posedge i_clk);
        i_reset = 1'b0;

        // Drive random inputs
        for (k = 0; k < 50; k = k + 1) begin
            @(posedge i_clk);
            i_ce   <= 1'b1;
            i_aux  <= $random(rnd);
            i_left <= $random(rnd);
            i_right<= $random(rnd);
            i_coef <= $random(rnd);
        end

        // Stop driving CE
        @(posedge i_clk);
        i_ce <= 1'b0;

        // Let pipeline flush
        repeat (1) @(posedge i_clk);

        $finish;
    end

    // ------------------------------------------------------------
    // Monitor outputs
    // ------------------------------------------------------------
    always @(posedge i_clk) begin
        if (!i_reset) begin
            $display("%t %x %x | L=%x R=%x C=%x -> oL=%x oR=%x oA=%x",
                $time, i_ce, i_aux,
                i_left, i_right, i_coef,
                o_left, o_right, o_aux
            );
        end
    end

endmodule
