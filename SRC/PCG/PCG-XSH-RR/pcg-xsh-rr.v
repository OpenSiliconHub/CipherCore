module pcg #(
    parameter [63:0] A = 64'd6364136223846793005,
    parameter [63:0] C = 64'd1442695040888963407
)(
    input             clk,
    input             rst,
    input             en,
    input      [63:0] Seed,
    output reg [31:0] out
);

    reg [63:0] state;

    wire [31:0] xorshifted;
    wire [4:0]  rot;
    wire [31:0] rnd;

    assign xorshifted = ((state >> 18) ^ state) >> 27;
    assign rot        = state[63:59];

    assign rnd =
        (xorshifted >> rot) |
        (xorshifted << ((5'd32 - rot) & 5'd31));

    always @(posedge clk) begin
        if (rst) begin
            state <= (Seed == 64'd0) ? 64'd1 : Seed;
            out   <= 32'd0;
        end
        else if (en) begin
            out   <= rnd;
            state <= state * A + C;
        end
    end

endmodule
