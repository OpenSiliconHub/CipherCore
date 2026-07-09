`timescale 1ns/1ps

module tb_pcg();

    // DUT inputs
    reg         clk;
    reg         rst;
    reg         en;
    reg [63:0]  Seed;

    // DUT output
    wire [31:0] out;

    // Instantiate the PCG DUT
    pcg uut (
        .clk(clk),
        .en(en),
        .rst(rst),
        .Seed(Seed),
        .out(out)
    );

    // Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    initial begin

        //-------------------------------------------------------
        //              WAVEFORM DUMP ADDITION
        //-------------------------------------------------------
        $dumpfile("pcg_wave.vcd");   // output VCD file
        $dumpvars(0, tb_pcg);        // dump all signals in testbench + DUT
        //-------------------------------------------------------

        // Initial conditions
        clk  = 0;
        rst  = 1;
        en   = 0;
        Seed = 64'hD4E12F77CAFEBABE;

        // Apply reset
        #20 rst = 0;

        // Enable PCG
        #10 en = 1;

        // Generate 20 outputs
        repeat (20) begin
            @(posedge clk);
            $display("Time=%0t  Random Output = %h", $time, out);
        end

        en = 0;

        #20;
        $finish;
    end

endmodule
