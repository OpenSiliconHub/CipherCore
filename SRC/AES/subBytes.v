`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// SubBytes
// Author: Meghana
// Create Date: 12/09/2025 12:05:09 PM
//////////////////////////////////////////////////////////////////////////////////
// Description:
//     -It is a non-linear transformation where byte is replaced with a value in S-box. 
//    -The S-box is predetermined for using it in the algorithm.
//    -This substitution is done in a way that a byte is never substituted by itself 
//    and also not substituted by another byte which is a compliment of the current byte.
//    -The result of this step is a 16-byte (4 x 4 ) matrix like before.
// 
//////////////////////////////////////////////////////////////////////////////////


module subBytes(in,out);
    input [127:0]in; //input state matrix
    output [127:0] out; // new output state matrix
    
    genvar i;
    generate
    for(i=0;i<128;i=i+8) begin :sub_Bytes
        sbox s(in[i +:8],out[i +:8]);
    // each byte has been substituted according to the S-Box.
    end
    endgenerate
endmodule
