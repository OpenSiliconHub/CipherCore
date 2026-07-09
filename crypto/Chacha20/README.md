# ChaCha20 Key Stream Generator (Verilog 2001)

## Overview
This repository contains a **Verilog 2001 implementation** of the **ChaCha family key stream generator** (ChaCha8, ChaCha12, ChaCha20), designed as a reference RTL core.  
The implementation is fully verified against **RFC 8439**, ensuring correctness and compliance with the standard specification.

## Source Files
- [`chacha20.v`](./Chacha20/chacha20.v)  
  Contains the RTL design of the ChaCha implementation in Verilog 2001.

- Testbenches and a detailed **technical paper** are included to validate and explain the design methodology.

## Verification
- Verified against **RFC 8439 test vectors**  
- Includes **testbenches** for functional validation  
- Supported by a **technical paper** documenting the design, verification process, and results

## Design Purpose
The sole purpose of this implementation is to serve as a **reference design** for ChaCha in hardware.  
It is intended for educational, research, and benchmarking use.

## Resource Utilization
Based on synthesis results:
- **LUTs:** 2949  
- **Flip-Flops (FFs):** 1928  
- **Carry Chains:** 1493  

---

## Finite State Machine (FSM)
The design uses a **six-state FSM** to control the flow of operations:

| State          | Description |
|----------------|-------------|
| **IDLE**         | Waits for input key/nonce setup |
| **LOAD**         | Loads constants, key, counter, and nonce into the state matrix |
| **ROUND_LOOP**   | Iteratively performs the rounds (parameterized: 8, 12, or 20) |
| **FINAL_ADD**    | Adds the transformed state back to the original state (ChaCha core step) |
| **SERIALIZE_S**  | Serializes the 16×32-bit state words into a 512-bit keystream block |
| **DONE**         | Signals completion and readiness for the next block |

This FSM ensures clarity, modularity, and predictable sequencing of operations.

---

## Parameterized Iterations (Uniqueness)
Unlike fixed-round implementations, this design allows **user selection of iteration count** at module instantiation:
- **ChaCha8** → 8 rounds (lightweight, faster, lower resource usage)  
- **ChaCha12** → 12 rounds (balanced security and performance)  
- **ChaCha20** → 20 rounds (full-strength cipher as per RFC 8439)  

This parameterization is the **main uniqueness** of the design, enabling flexibility for different applications:
- **Research/benchmarking**: Compare area, speed, and security trade-offs.  
- **Educational use**: Demonstrate how round count impacts cipher strength.  
- **Practical deployment**: Choose reduced-round variants for constrained environments.  

---

## Design Highlights
- **Strict Verilog 2001 compliance**: No SystemVerilog constructs, ensuring portability across tools.  
- **Modular helpers**: Rotation, addition, and XOR are parameterized for reuse.  
- **Balanced resource usage**: Achieves ~2949 LUTs and ~1928 FFs, optimized for FPGA deployment.  
- **Readable and reusable**: Designed as a teaching/reference core, not just a black-box implementation.  
- **RFC-verified**: Directly validated against official test vectors, ensuring correctness.  
- **Configurable rounds**: Supports ChaCha8, ChaCha12, and ChaCha20 in a single unified design.  

---

## Notes
- Designed with modularity and clarity in mind to support reuse and further exploration.  
- Intended as a **reference design**, not a production-optimized cipher core.  
