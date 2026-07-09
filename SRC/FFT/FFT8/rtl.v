module fft8 (
    input wire clk,
    input wire rst,
    input wire start,
    output reg done,

    // Complex inputs
    input wire signed [31:0] x0_re,
    input wire signed [31:0] x0_im,
    input wire signed [31:0] x1_re,
    input wire signed [31:0] x1_im,

    // Outputs: butterfly results
    output reg signed [31:0] X0_re,
    output reg signed [31:0] X0_im,
    output reg signed [31:0] X1_re,
    output reg signed [31:0] X1_im
);

    // Internal wires
    wire signed [31:0] bf_s_re, bf_s_im;
    wire signed [31:0] bf_d_re, bf_d_im;

    // Instantiate butterfly module
    butterfly2 bf_inst (
        .a_re(x0_re), .a_im(x0_im),
        .b_re(x1_re), .b_im(x1_im),
        .s_re(bf_s_re), .s_im(bf_s_im),
        .d_re(bf_d_re), .d_im(bf_d_im)
    );

    always @(posedge clk) begin
        if (rst) begin
            done <= 1'b0;

            X0_re <= 32'sd0; X0_im <= 32'sd0;
            X1_re <= 32'sd0; X1_im <= 32'sd0;
        
        end else begin
            done <= 1'b0;

            if (start) begin
                // Use butterfly outputs as FFT outputs
                X0_re <= bf_s_re; X0_im <= bf_s_im; // x0 + x1
                X1_re <= bf_d_re; X1_im <= bf_d_im; // x0 - x1
                done <= 1'b1;
            end  
        end
    end
endmodule 

module butterfly2 (
    input wire signed [31:0] a_re,
    input wire signed [31:0] a_im,
    input wire signed [31:0] b_re,
    input wire signed [31:0] b_im,

    output wire signed [31:0] s_re,
    output wire signed [31:0] s_im,
    output wire signed [31:0] d_re,
    output wire signed [31:0] d_im
);

    // Summing
    assign s_re = a_re + b_re;
    assign s_im = a_im + b_im;

    // Difference
    assign d_re = a_re - b_re;
    assign d_im = a_im - b_im;
endmodule