module daisy_arbiter #(
    parameter N = 4
)(
    input  wire         clk,
    input  wire         rst_n,
    input  wire [N-1:0] req,
    input  wire         done,

    output reg  [N-1:0] grant
);

integer i;
reg found;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        grant <= 0;
    end
    else begin

        // Keep current owner
        if(|grant && !done) begin
            grant <= grant;
        end
        else begin

            grant <= 0;
            found = 0;

            for(i = 0; i < N; i = i + 1) begin
                if(req[i] && !found) begin
                    grant[i] <= 1'b1;
                    found = 1;
                end
            end
        end
    end
end

endmodule
