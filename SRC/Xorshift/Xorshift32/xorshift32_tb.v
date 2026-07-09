// -----------------------------------------------------------------------------
// Testbench: tb_xorshift32
// Author: MrAbhi19
// Description:
//   This testbench verifies the functionality of the Xorshift32 PRNG module.
//   It applies a seed, toggles reset and enable signals, and observes the
//   pseudo-random sequence generated.
//
// Features:
//   - Generates a clock signal.
//   - Applies asynchronous reset.
//   - Provides a seed value to initialize the generator.
//   - Enables the generator to produce random outputs.
//   - Displays the output sequence in the simulation console.
//   - Dumps waveform data to a VCD file for viewing in GTKWave.
//
// Notes:
//   - This testbench is non-synthesizable and intended for simulation only.
//   - The output sequence should be deterministic given the same seed.
// -----------------------------------------------------------------------------

`timescale 1ns/1ps

module xorshift32_tb;

  // Testbench signals
  reg clk;                 // Clock signal
  reg rst;                 // Reset signal
  reg en;                  // Enable signal
  reg [31:0] seed;         // Seed value
  wire [31:0] out;         // Output from DUT

  // Instantiate the Device Under Test (DUT)
  xorshift32 dut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .seed(seed),
    .out(out)
  );

  // Clock generation: 10ns period (100 MHz)
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    // Initialize signals
    clk  = 0;
    rst  = 0;
    en   = 0;
    seed = 32'h12345678;   // Example seed value

    // Setup waveform dump
    $dumpfile("xorshift32_tb.vcd"); // VCD output file
    $dumpvars(0, tb_xorshift32);    // Dump all signals in this testbench

    // Apply reset
    $display("Applying reset...");
    rst = 1;
    #10;
    rst = 0;

    // Enable generator
    $display("Starting PRNG sequence...");
    en = 1;

    // Run for several cycles
    repeat (20) begin
      @(posedge clk);
      $display("Time=%0t | Random Output = %h", $time, out);
    end

    // Disable generator
    en = 0;
    $display("Generator disabled.");

    // Finish simulation
    #20;
    $finish;
  end

endmodule
