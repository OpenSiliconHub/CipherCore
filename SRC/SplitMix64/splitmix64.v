// ============================================================================
// SplitMix64 Pseudo-Random Number Generator (PRNG)
// Author: MrAbhi19
// ----------------------------------------------------------------------------
// This module implements the SplitMix64 algorithm in hardware (Verilog).
// SplitMix64 is a fast, non-cryptographic PRNG widely used for seeding other
// generators (like xorshift or PCG). It produces 64-bit pseudo-random outputs
// with excellent statistical properties.
//
// Key design choices:
// 1. Increment constant: 0x9E3779B97F4A7C15
//    - Derived from the golden ratio scaled to 64 bits.
//    - Ensures the state cycles through the entire 64-bit space uniformly.
//    - Prevents short repeating cycles and distributes values evenly.
//
// 2. Multiplication constants:
//    - 0xBF58476D1CE4E5B9
//    - 0x94D049BB133111EB
//    - These are large odd numbers chosen empirically to maximize bit mixing.
//    - Multiplication by odd constants ensures invertibility modulo 2^64.
//    - They create avalanche effects: small changes in input produce large,
//      unpredictable changes in output.
//
// 3. XOR-shift steps:
//    - XOR with shifted versions of the state scrambles high/low bits.
//    - Combined with multiplication, this produces high-quality randomness.
//
// ----------------------------------------------------------------------------
// Limitations:
// - Not cryptographically secure (predictable if state is known).
// - Best used for simulations, randomized algorithms, or seeding other PRNGs.
// ============================================================================

module splitmix64 (
    input         clk,
    input         rst,
    input         en,
    input  [63:0] data_in,
    output reg [63:0] out
);

    reg [63:0] state;

    wire [63:0] z1;
    wire [63:0] z2;
    wire [63:0] z3;
    wire [63:0] result;

    assign z1 = state + 64'h9E3779B97F4A7C15;
    assign z2 = (z1 ^ (z1 >> 30)) * 64'hBF58476D1CE4E5B9;
    assign z3 = (z2 ^ (z2 >> 27)) * 64'h94D049BB133111EB;
    assign result = z3 ^ (z3 >> 31);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= data_in;
            out   <= 64'd0;
        end
        else if (en) begin
            state <= z1;
            out   <= result;
        end
    end

endmodule
