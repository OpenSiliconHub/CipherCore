`timescale 1ns/1ps

// ============================================================================
// ChaCha20 Testbench
// Purpose : Validates ChaCha20 core against RFC 8439 test vectors
//           This test uses the Cipher Example from RFC 8439, Section 2.4.2
//           ("Example and Test Vector for the ChaCha20 Cipher")
// Author  : MrAbhi19
// ============================================================================
module chacha20_tb;

  // DUT inputs
  reg clk;
  reg rst;
  reg en;
  reg  [255:0] key;
  reg   [95:0] nonce;
  reg   [31:0] block_count;

  // DUT outputs
  wire [511:0] out;

  // Instantiate DUT (default ITERATIONS=10 for ChaCha20)
  chacha20 #(.ITERATIONS(10)) dut (
      .clk(clk),
      .rst(rst),
      .en(en),
      .key(key),
      .nonce(nonce),
      .block_count(block_count),
      .out(out)
  );

  // Clock generation: 100 MHz (10 ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // ============================================================
  // RFC 8439 Section 2.4.2 expected keystream (64 bytes / 512-bit)
  // ============================================================
  localparam [511:0] EXPECTED = {
    32'h224f51f3, 32'h401bd9e1, 32'h2fde276f, 32'hb8631ded,
    32'h8c131f82, 32'h3d2c06e2, 32'h7e4fcaec, 32'h9ef3cf78,
    32'h8a3b0aa3, 32'h72600a92, 32'hb57974cd, 32'hed2b9334,
    32'h794cba40, 32'hc63e34cd, 32'hea212c4c, 32'hf07d41b7
  };

  // ============================================================
  // Waveform dump setup
  // ============================================================
  initial begin
    $dumpfile("chacha20_tb.vcd");   // VCD output file
    $dumpvars(0, chacha20_tb);      // Dump all signals in testbench + DUT
  end

  // ============================================================
  // Test Sequence
  // ============================================================
  initial begin
    $display("=== ChaCha20 Testbench (RFC 8439 Section 2.4.2 Cipher Example) ===");

    // Initialize signals
    rst = 1;
    en  = 0;

    // RFC 8439 Section 2.4.2 inputs
    key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
    nonce = 96'h000000000000004a00000000;   // 12-byte nonce
    block_count = 32'h00000001;            // Initial counter = 1

    // Release reset and enable FSM
    #30 rst = 0;
    #20 en  = 1;

    // Wait until DUT reaches DONE state
    wait(dut.state == dut.DONE);

    // Capture and check output
    $display("\nGenerated keystream:");
    $display("%h", out);

    if(out === EXPECTED) begin
        $display("\n*** PASS: RFC 8439 Section 2.4.2 test vector matched ***\n");
    end else begin
        $display("\n*** FAIL: Output does NOT match expected ***");
        $display("Expected:\n%h\n", EXPECTED);
        $display("Got:\n%h\n", out);
    end

    $finish;
  end

endmodule
