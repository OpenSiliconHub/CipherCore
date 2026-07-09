// ============================================================================
// Testbench for SplitMix64 PRNG with Waveform Dump
// ----------------------------------------------------------------------------
// This testbench initializes the SplitMix64 module with a seed, then
// generates a sequence of pseudo-random numbers on each clock cycle.
// Outputs are printed to the console AND waveform data is dumped for viewing.
// ============================================================================

`timescale 1ns/1ps

module splitmix64_tb;

  // Testbench signals
  reg clk;
  reg rst;
  reg en;
  reg [63:0] seed;
  wire [63:0] rand_out;

  // Instantiate the DUT (Device Under Test)
  splitmix64 uut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .data_in(seed),
    .out(rand_out)
  );

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  initial begin
    // Initialize signals
    clk  = 0;
    rst  = 0;
    en   = 0;
    seed = 64'h123456789ABCDEF0;  // Example seed

    // Apply reset
    $display("Applying reset...");
    rst = 1;
    #10;
    rst = 0;

    // Enable PRNG
    en = 1;

    // Generate a few random numbers
    $display("Generating random numbers:");
    repeat (10) begin
      @(posedge clk);
      $display("Random Output = %h", rand_out);
    end

    // Finish simulation
    $display("Simulation complete.");
    $finish;
  end

  // Waveform dump setup
  initial begin
    $dumpfile("splitmix64_tb.vcd");   // VCD file for waveform
    $dumpvars(0, tb_splitmix64);      // Dump all signals in testbench
  end

endmodule
