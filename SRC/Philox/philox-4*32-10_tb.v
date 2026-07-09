// ============================================================================
// Testbench for Philox-4x32-10 PRNG with Waveform Dump
// ----------------------------------------------------------------------------
// This testbench initializes the philox4x32_10 module with a seed counter
// and key, then generates a sequence of pseudo-random numbers on each clock.
// Outputs are printed to the console AND waveform data is dumped for viewing.
// ============================================================================

`timescale 1ns/1ps

module tb_philox4x32_10;

  // Testbench signals
  reg clk;
  reg rst;
  reg en;
  reg [127:0] counter;
  reg [63:0] key;
  wire [127:0] rand_out;

  // Instantiate the DUT (Device Under Test)
  philox4x32_10 uut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .counter(counter),
    .key(key),
    .out(rand_out)
  );

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  initial begin
    // Initialize signals
    clk     = 0;
    rst     = 0;
    en      = 0;
    counter = 128'h00000000_00000000_00000000_00000001; // Example counter
    key     = 64'h00000000_00000000;                   // Example key

    // Apply reset
    $display("Applying reset...");
    rst = 1;
    #10;
    rst = 0;

    // Enable PRNG
    en = 1;

    // Generate a few random numbers
    $display("Generating random numbers:");
    repeat (5) begin
      @(posedge clk);
      $display("Random Output = %h", rand_out);
      counter = counter + 1; // Increment counter for next block
    end

    // Finish simulation
    $display("Simulation complete.");
    $finish;
  end

  // Waveform dump setup
  initial begin
    $dumpfile("philox4x32_10_tb.vcd");   // VCD file for waveform
    $dumpvars(0, tb_philox4x32_10);      // Dump all signals in testbench + DUT
  end

endmodule
