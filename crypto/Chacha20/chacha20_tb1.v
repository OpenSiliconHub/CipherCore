`timescale 1ns/1ps

// ============================================================================
// ChaCha20 Testbench
// Purpose : Validates ChaCha20 core against RFC 8439 test vectors
//           Specifically, this test uses the Block Function example
//           from RFC 8439, Section 2.3.2 ("Test Vector for the ChaCha20 Block Function")
// Author  : MrAbhi19
// ============================================================================
module chacha20_tb1;

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
  // RFC 8439 first-block expected keystream (64 bytes / 512-bit)
  // ============================================================
  localparam [511:0] EXPECTED = {
    32'h10f1e7e4, 32'hd13b5915, 32'h500fdd1f, 32'ha32071c4,
    32'hc7d1f4c7, 32'h33c06803, 32'h0422aa9a, 32'hc3d46c4e,
    32'hd2826446, 32'h079faa09, 32'h14c2d705, 32'hd98b02a2,
    32'hb5129cd1, 32'hde164eb9, 32'hcbd083e8, 32'ha2503c4e
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
    $display("=== ChaCha20 Testbench (RFC 8439 Sunscreen Example) ===");

    // Initialize signals
    rst = 1;
    en  = 0;

    // RFC 8439 inputs (Sunscreen example)
    key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
    nonce = 96'h000000090000004a00000000;   // 12-byte nonce
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
        $display("\n*** PASS: RFC 8439 test vector matched ***\n");
    end else begin
        $display("\n*** FAIL: Output does NOT match expected ***");
        $display("Expected:\n%h\n", EXPECTED);
        $display("Got:\n%h\n", out);
    end

    $finish;
  end

endmodule
