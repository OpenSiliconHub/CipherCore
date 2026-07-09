// ==============================================================================
// Chacha20 key-stream Generator
// Author: MrAbhi19
// ------------------------------------------------------------------------------
// Purpose: Implements the ChaCha20 block function as defined in RFC 8439.
//          This module accepts a 256-bit secret key, a 96-bit nonce, and a
//          32-bit block counter as inputs. It performs the ChaCha20 algorithm
//          (20 rounds of quarter-round operations, feed-forward addition, and
//          serialization) to produce one 64-byte keystream block per counter.
//          A double round is executed on each clock cycle, so it takes
//          10 clock cycles to compute one keystream block.
//
// Inputs:
//   clk                - System clock
//   rst                - Active-high reset
//   en                 - Enable signal to start computation
//   key[255:0]         - 256-bit secret key
//   nonce[95:0]        - 96-bit nonce (unique per message)
//   block_count[31:0]  - 32-bit block counter
//
// Outputs:
//   out[511:0]         - 512-bit keystream block (64 bytes)
//
// Parameters:
//   ITERATIONS - Number of double-rounds per block computation
//                Set ITERATIONS = 4  for ChaCha8
//                Set ITERATIONS = 6  for ChaCha12
//                Set ITERATIONS = 10 for ChaCha20
//

module chacha20 #(
  parameter ITERATIONS = 10
)(
  input        clk,          // System clock
  input        rst,          // Active-high reset
  input        en,           // Enable signal
  input  [255:0] key,        // 256-bit secret key
  input   [95:0] nonce,      // 96-bit nonce (unique per message)
  input   [31:0] block_count,// 32-bit block counter
  output reg [511:0] out     // 512-bit keystream block (64 bytes)
);

  function [511:0] STATE_INIT;
    input [255:0] key;
    input [95:0] nonce;
    input [31:0] block_count;
    reg [31:0] s0, s1, s2, s3;
    reg [31:0] s4, s5, s6, s7, s8, s9, s10, s11;
    reg [31:0] s12, s13, s14, s15;
    integer w;
    begin
      // Constants (ASCII "expand 32-byte k")
      s0 = 32'h61707865; // "expa"
      s1 = 32'h3320646e; // "nd 3"
      s2 = 32'h79622d32; // "2-by"
      s3 = 32'h6b206574; // "te k"

      // Build key words s4..s11 from the 256-bit key literal.
      // The key literal 256'h00_01_02... places byte0 at key[255:248], byte1 at key[247:240], ...
      // RFC expects each 32-bit word to be little-endian formed from consecutive bytes:
      //   word = byte0 + (byte1<<8) + (byte2<<16) + (byte3<<24)
      // That corresponds to concatenation: {byte3,byte2,byte1,byte0}.
      for (w = 0; w < 8; w = w + 1) begin
        // byte indices for word w:
        //  byte0 at key[255 - (w*32 + 0) -: 8]
        //  byte1 at key[255 - (w*32 + 8) -: 8]
        //  byte2 at key[255 - (w*32 +16) -: 8]
        //  byte3 at key[255 - (w*32 +24) -: 8]
        case (w)
          0: s4  = { key[255 - (0*32 +24) -:8], key[255 - (0*32 +16) -:8],
                    key[255 - (0*32 +8)  -:8], key[255 - (0*32 +0)  -:8] };
          1: s5  = { key[255 - (1*32 +24) -:8], key[255 - (1*32 +16) -:8],
                    key[255 - (1*32 +8)  -:8], key[255 - (1*32 +0)  -:8] };
          2: s6  = { key[255 - (2*32 +24) -:8], key[255 - (2*32 +16) -:8],
                    key[255 - (2*32 +8)  -:8], key[255 - (2*32 +0)  -:8] };
          3: s7  = { key[255 - (3*32 +24) -:8], key[255 - (3*32 +16) -:8],
                    key[255 - (3*32 +8)  -:8], key[255 - (3*32 +0)  -:8] };
          4: s8  = { key[255 - (4*32 +24) -:8], key[255 - (4*32 +16) -:8],
                    key[255 - (4*32 +8)  -:8], key[255 - (4*32 +0)  -:8] };
          5: s9  = { key[255 - (5*32 +24) -:8], key[255 - (5*32 +16) -:8],
                    key[255 - (5*32 +8)  -:8], key[255 - (5*32 +0)  -:8] };
          6: s10 = { key[255 - (6*32 +24) -:8], key[255 - (6*32 +16) -:8],
                    key[255 - (6*32 +8)  -:8], key[255 - (6*32 +0)  -:8] };
          7: s11 = { key[255 - (7*32 +24) -:8], key[255 - (7*32 +16) -:8],
                    key[255 - (7*32 +8)  -:8], key[255 - (7*32 +0)  -:8] };
        endcase
      end

      // Counter (word 12) - block_count is a 32-bit scalar; RFC uses it as a little-endian word.
      s12 = block_count;

      // Nonce: 12 bytes -> words s13, s14, s15 (same little-endian per-word assembly)
      // nonce[95:88] is byte0, nonce[87:80] byte1, ... nonce[7:0] byte11
      s13 = { nonce[95 - 24 -:8], nonce[95 - 16 -:8], nonce[95 - 8 -:8], nonce[95 - 0 -:8] };
      s14 = { nonce[95 - 56 -:8], nonce[95 - 48 -:8], nonce[95 - 40 -:8], nonce[95 - 32 -:8] };
      s15 = { nonce[95 - 88 -:8], nonce[95 - 80 -:8], nonce[95 - 72 -:8], nonce[95 - 64 -:8] };

      // Pack into 512-bit state in the same order you already use:
      // {s15, s14, ..., s0} so that x0 = state[31:0] == s0
      STATE_INIT = {s15,s14,s13,s12,s11,s10,s9,s8,s7,s6,s5,s4,s3,s2,s1,s0};
    end
  endfunction

      
  function [31:0] ROTL;
    input [31:0] x;
    input [4:0] n;
    begin
      
      ROTL = (x << n ) | (x >> (32 - n));
    end
    
  endfunction
  
function [127:0] QUARTERROUND;
    input [31:0] a, b, c, d;
    reg [31:0] ta, tb, tc, td;
    begin
        ta = a; tb = b; tc = c; td = d;

        ta = ta + tb; td = ROTL(td ^ ta, 16);
        tc = tc + td; tb = ROTL(tb ^ tc, 12);
        ta = ta + tb; td = ROTL(td ^ ta, 8);
        tc = tc + td; tb = ROTL(tb ^ tc, 7);

        QUARTERROUND = {ta, tb, tc, td};
    end
endfunction

// One ChaCha round = 4 column QuarterRounds + 4 diagonal QuarterRounds
function [511:0] ROUND;
    input [511:0] state;
    reg [31:0] x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15;
    reg [127:0] qr_out;
    begin
        // Unpack 512-bit state into 16 words
        x0  = state[ 31:  0];
        x1  = state[ 63: 32];
        x2  = state[ 95: 64];
        x3  = state[127: 96];
        x4  = state[159:128];
        x5  = state[191:160];
        x6  = state[223:192];
        x7  = state[255:224];
        x8  = state[287:256];
        x9  = state[319:288];
        x10 = state[351:320];
        x11 = state[383:352];
        x12 = state[415:384];
        x13 = state[447:416];
        x14 = state[479:448];
        x15 = state[511:480];

        // Column rounds
        qr_out = QUARTERROUND(x0, x4, x8,  x12); {x0, x4, x8,  x12} = qr_out;
        qr_out = QUARTERROUND(x1, x5, x9,  x13); {x1, x5, x9,  x13} = qr_out;
        qr_out = QUARTERROUND(x2, x6, x10, x14); {x2, x6, x10, x14} = qr_out;
        qr_out = QUARTERROUND(x3, x7, x11, x15); {x3, x7, x11, x15} = qr_out;

        // Diagonal rounds
        qr_out = QUARTERROUND(x0, x5, x10, x15); {x0, x5, x10, x15} = qr_out;
        qr_out = QUARTERROUND(x1, x6, x11, x12); {x1, x6, x11, x12} = qr_out;
        qr_out = QUARTERROUND(x2, x7, x8,  x13); {x2, x7, x8,  x13} = qr_out;
        qr_out = QUARTERROUND(x3, x4, x9,  x14); {x3, x4, x9,  x14} = qr_out;

        // Pack back into 512-bit state
        ROUND = {x15,x14,x13,x12,
                 x11,x10,x9,x8,
                 x7,x6,x5,x4,
                 x3,x2,x1,x0};
    end
endfunction

// Final addition: word-wise modulo 2^32
function [511:0] FINAL_ADDITION;
    input [511:0] x;
    input [511:0] y;
    reg [31:0] x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15;
    reg [31:0] y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15;
    reg [31:0] s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15;
    begin
        // Unpack x
        x0  = x[ 31:  0];   x1  = x[ 63: 32];   x2  = x[ 95: 64];   x3  = x[127: 96];
        x4  = x[159:128];   x5  = x[191:160];   x6  = x[223:192];   x7  = x[255:224];
        x8  = x[287:256];   x9  = x[319:288];   x10 = x[351:320];   x11 = x[383:352];
        x12 = x[415:384];   x13 = x[447:416];   x14 = x[479:448];   x15 = x[511:480];

        // Unpack y
        y0  = y[ 31:  0];   y1  = y[ 63: 32];   y2  = y[ 95: 64];   y3  = y[127: 96];
        y4  = y[159:128];   y5  = y[191:160];   y6  = y[223:192];   y7  = y[255:224];
        y8  = y[287:256];   y9  = y[319:288];   y10 = y[351:320];   y11 = y[383:352];
        y12 = y[415:384];   y13 = y[447:416];   y14 = y[479:448];   y15 = y[511:480];

        // Word-wise addition (no endianness change)
        s0  = x0  + y0;   s1  = x1  + y1;   s2  = x2  + y2;   s3  = x3  + y3;
        s4  = x4  + y4;   s5  = x5  + y5;   s6  = x6  + y6;   s7  = x7  + y7;
        s8  = x8  + y8;   s9  = x9  + y9;   s10 = x10 + y10;  s11 = x11 + y11;
        s12 = x12 + y12;  s13 = x13 + y13;  s14 = x14 + y14;  s15 = x15 + y15;

        // Pack back into 512-bit result (use the same ordering you used elsewhere)
        FINAL_ADDITION = {s15,s14,s13,s12,
                          s11,s10,s9,s8,
                          s7,s6,s5,s4,
                          s3,s2,s1,s0};
    end
endfunction

  function [511:0] SERIALIZE;
    input [511:0] state; // 16 words
    reg [31:0] w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15;
    reg   [511:0] out;
    integer i;
    begin

        w0  = state[ 31:  0];
        w1  = state[ 63: 32];
        w2  = state[ 95: 64];
        w3  = state[127: 96];
        w4  = state[159:128];
        w5  = state[191:160];
        w6  = state[223:192];
        w7  = state[255:224];
        w8  = state[287:256];
        w9  = state[319:288];
        w10 = state[351:320];
        w11 = state[383:352];
        w12 = state[415:384];
        w13 = state[447:416];
        w14 = state[479:448];
        w15 = state[511:480];

        out[  7:  0] = w15[31:24]; out[ 15: 8] = w15[23:16];  out[ 23:16] = w15[15:8];   out[ 31:24] = w15[7:0];
        out[ 39: 32] = w14[31:24]; out[47: 40] = w14[23:16];  out[ 55:48] = w14[15:8];   out[ 63:56] = w14[7:0];
        out[ 71: 64] = w13[31:24]; out[79: 72] = w13[23:16];  out[ 87:80] = w13[15:8];   out[ 95:88] = w13[7:0];
        out[103: 96] = w12[31:24]; out[111:104] = w12[23:16]; out[119:112] = w12[15:8];  out[127:120] = w12[7:0];
        out[135:128] = w11[31:24]; out[143:136] = w11[23:16]; out[151:144] = w11[15:8];  out[159:152] = w11[7:0];
        out[167:160] = w10[31:24]; out[175:168] = w10[23:16]; out[183:176] = w10[15:8];  out[191:184] = w10[7:0];
        out[199:192] = w9[31:24];  out[207:200] = w9[23:16];  out[215:208] = w9[15:8];   out[223:216] = w9[7:0];
        out[231:224] = w8[31:24];  out[239:232] = w8[23:16];  out[247:240] = w8[15:8];   out[255:248] = w8[7:0];
        out[263:256] = w7[31:24];  out[271:264] = w7[23:16];  out[279:272] = w7[15:8];   out[287:280] = w7[7:0];
        out[295:288] = w6[31:24];  out[303:296] = w6[23:16];  out[311:304] = w6[15:8];   out[319:312] = w6[7:0];
        out[327:320] = w5[31:24];  out[335:328] = w5[23:16];  out[343:336] = w5[15:8];   out[351:344] = w5[7:0];
        out[359:352] = w4[31:24];  out[367:360] = w4[23:16];  out[375:368] = w4[15:8];   out[383:376] = w4[7:0];
        out[391:384] = w3[31:24];  out[399:392] = w3[23:16];  out[407:400] = w3[15:8];   out[415:408] = w3[7:0];
        out[423:416] = w2[31:24];  out[431:424] = w2[23:16];  out[439:432] = w2[15:8];   out[447:440] = w2[7:0];
        out[455:448] = w1[31:24];  out[463:456] = w1[23:16];  out[471:464] = w1[15:8];   out[479:472] = w1[7:0];
        out[487:480] = w0[31:24];  out[495:488] = w0[23:16];  out[503:496] = w0[15:8];   out[511:504] = w0[7:0];

      SERIALIZE = out; 
    end
endfunction

  //FSM states
  localparam IDLE       = 3'd0;
  localparam LOAD       = 3'd1;
  localparam ROUND_LOOP = 3'd2;
  localparam FINAL_ADD  = 3'd3;
  localparam SERIALIZE_S= 3'd4;
  localparam DONE       = 3'd5;

  reg [2:0] state, next_state;

  // internal registers
  reg [511:0] init_state;      // the initial state (constant during rounds)
  reg [511:0] work_state;      // working state that gets transformed by ROUND
  reg [511:0] add_result;      // result of FINAL_ADDITION
  reg [3:0] round_counter;     // need 4 bits for up to 10
  reg valid;                   // internal valid flag (optional)

  always@(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
      init_state <= 512'd0;
      work_state <= 512'd0;
      add_result <= 512'd0;
      round_counter <= 4'd0;
      out <= 512'd0;
      valid <= 1'b0;
    end else begin
      state <= next_state;
      case (state)
        IDLE: begin
          valid <= 1'b0;
        end

        LOAD: begin
          // capture the initial state once (STATE_INIT is combinational)
          // use non-blocking to avoid race issues
          init_state <= STATE_INIT(key, nonce, block_count);
          work_state <= STATE_INIT(key, nonce, block_count); // start working state = init
          round_counter <= 4'd0;
        end

        ROUND_LOOP: begin
          // iterate ROUND each clock until ITERATIONS reached
          // use the combinational function ROUND to compute next working state
          // store result in work_state
          work_state <= ROUND(work_state);
          round_counter <= round_counter + 4'd1;
        end

        FINAL_ADD: begin
          // add initial state and working state (word-wise modulo 2^32)
          add_result <= FINAL_ADDITION(init_state, work_state);
        end

        SERIALIZE_S: begin
          // produce final serialized output
          out <= SERIALIZE(add_result);
          valid <= 1'b1;
        end

        DONE: begin
          // hold output until next en pulse resets machine to LOAD
        end

        default: begin end
      endcase
    end
  end

  // Next-state logic (simple)
  always @(*) begin
    next_state = state; // default
    case (state)
      IDLE: begin
        if (en) next_state = LOAD;
      end

      LOAD: begin
        // go to ROUND_LOOP immediately next cycle
        next_state = ROUND_LOOP;
      end

      ROUND_LOOP: begin
        if (round_counter + 4'd1 >= ITERATIONS) begin
          next_state = FINAL_ADD;
        end else begin
          next_state = ROUND_LOOP;
        end
      end

      FINAL_ADD: begin
        next_state = SERIALIZE_S;
      end

      SERIALIZE_S: begin
        next_state = DONE;
      end

      DONE: begin
        // stay done until en is deasserted then asserted again (simple handshake)
        if (!en) next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase
  end

  // Optional: expose a 'ready/valid' handshake if you want (not in original port list).
  // You can add output reg ready if you want to signal completion externally.

endmodule
