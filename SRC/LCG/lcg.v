module lcg #(
    parameter [30:0] A = 31'd214013,
    parameter [30:0] C = 31'd2531011
)(
    input             clk,
    input             rst,
    input      [30:0] seed,
    output reg [30:0] out
);

    reg  [30:0] state;
    wire [30:0] next_state;

    assign next_state = (state * A + C) & 31'h7FFFFFFF;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= seed;
            out   <= seed;
        end
        else begin
            state <= next_state;
            out   <= next_state;
        end
    end

endmodule
