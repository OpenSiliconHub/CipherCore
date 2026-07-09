module Testbench;

    // Testbench signals
    logic clk = 0;
    logic rst = 1;
    logic start = 0;
    logic done; 

    logic signed [31:0] x0_re, x0_im;
    logic signed [31:0] x1_re, x1_im;

    logic signed [31:0] X0_re, X0_im;
    logic signed [31:0] X1_re, X1_im;

    integer k;
    integer seen_done;
    
    // Instantiate DUT
    fft8 dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),

        .x0_re(x0_re),
        .x0_im(x0_im),
        .x1_re(x1_re),
        .x1_im(x1_im),

        .X0_re(X0_re),
        .X0_im(X0_im),
        .X1_re(X1_re),
        .X1_im(X1_im)
    );

    // Clock generator: toggles every 5 time units -> 10 time unit period 
    always #5 clk = ~clk;

    // Helper task: wait for one rising clock edge
    task automatic tick;
        @(posedge clk);
    endtask

    initial begin
        x0_re = 0; x0_im = 0;
        x1_re = 0; x1_im = 0;
        start = 0;
        seen_done = 0;

        tick();
        tick();
        rst = 0;

        // Test case
        // x0 = 10 +j3, x1 = 4+j(-1)
        // sum = 14 + j2
        // diff = 6 + j4
        x0_re = 10; x0_im = 3;
        x1_re = 4;  x1_im = -1;

        // Pulse start for 1 cycle
        tick();
        start = 1;
        tick();
        start = 0;

        // Wait up to 5 cycles for done signal
        seen_done = 0;
        for (k = 0; k < 10; k = k + 1) begin
            tick();
            if (done === 1'b1) 
                seen_done = 1;
        end

        if (seen_done == 0) begin
            $display("Test Failed: done signal not asserted");
            $fatal;
        end

        // Check outputs
        if (X0_re !== 14 || X0_im !== 2) begin
            $display("Test Failed: Incorrect X0 output - got %0d + j%0d, expected 14 + j2", X0_re, X0_im);
            $fatal;
        end

        if (X1_re !== 6 || X1_im !== 4) begin
            $display("Test Failed: Incorrect X1 output - got %0d + j%0d, expected 6 + j4", X1_re, X1_im);
            $fatal;
        end

        $display("All tests passed!");
        $display("Butterfly outputs:");
        $display("  SUM  (X0) = %0d + j%0d", X0_re, X0_im);
        $display("  DIFF (X1) = %0d + j%0d", X1_re, X1_im);
        $finish;
    end

endmodule 