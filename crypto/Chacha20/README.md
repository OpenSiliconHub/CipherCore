# ChaCha20 Key Stream Generator 

## Overview

This directory contains a **Verilog implementation** of the **ChaCha family key stream generator** (**ChaCha8**, **ChaCha12**, and **ChaCha20**).

## Simulation-Based Verification

The core is validated using simulation-based testing with a total of **four reference test vectors**:

* **ChaCha20**

  * RFC 8439 Test Vector 2.3.2
  * RFC 8439 Test Vector 2.4.2

* **ChaCha12**

  * One reference test vector from the *ChaCha Test Vectors* Internet-Draft by Martin Storsjö and Joachim Strömbergson.

* **ChaCha8**

  * One reference test vector from the *ChaCha Test Vectors* Internet-Draft by Martin Storsjö and Joachim Strömbergson.

Reference documents:

* RFC 8439 — *ChaCha20 and Poly1305 for IETF Protocols*
* Draft: *ChaCha Test Vectors* (draft-strombergson-chacha-test-vectors-00)
  https://datatracker.ietf.org/doc/html/draft-strombergson-chacha-test-vectors-00

## Formal Verification

Formal verification for this core is currently **work in progress** and has not yet been completed.

Formal properties, proofs, and verification results will be added in a future update.
