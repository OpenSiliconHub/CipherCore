<pre align="center">
 ██████╗ ███████╗██╗  ██╗
██╔═══██╗██╔════╝██║  ██║
██║   ██║███████╗███████║
██║   ██║╚════██║██╔══██║
╚██████╔╝███████║██║  ██║
 ╚═════╝ ╚══════╝╚═╝  ╚═╝

 OSH-LIBRARY
</pre>

<p align="center"><i>A growing collection of reusable Verilog hardware cores</i></p>

OSH-Library is an open collection of parameterized, reusable HDL cores — built for learning, prototyping, and dropping into your own digital design projects. Right now the focus is on **cryptographic cores**, **PRNGs**, and small **clock-domain-crossing (CDC)** building blocks.

Whether you're just getting started with Verilog or you've been doing this for years, contributions are welcome!

---

## Getting Started

Each core in this repo is self-contained — you can explore, simulate, and integrate them one at a time.

### Prerequisites
- A Verilog simulator (e.g., Icarus Verilog, Verilator, or similar)
- GTKWave or another waveform viewer (optional, for inspecting signals)

### Simulation Flow
1. Navigate to the core you're interested in.
2. Compile the RTL source alongside its testbench.
3. Run the simulation with your simulator of choice.
4. Check the logs or waveform to confirm it behaves as expected.

Most cores already include a pre-run simulation log and waveform screenshot in their folder, so you can see expected output before running anything yourself.

---

## What's Inside

### Cryptographic Cores
- **[ChaCha20](./crypto/Chacha20/)** — stream cipher, verified against RFC 8439 test vectors, includes a technical paper
- **[Trivium](./crypto/trivium/)** — stream cipher core

---

## Verification Status

All cores here are checked with simulation-based testbenches. **Formal verification hasn't been added yet — it's on our roadmap and something we're actively working on.** Until then, treat these cores as simulation-verified, not formally proven.

---

## Contributing

Got a core to add, a bug to report, or an improvement in mind? Check out the [Contribution Guidelines](./Contribution.md) or start a [Discussion](../../discussions) — we'd love to hear from you.

---

## Contact / Discussions

For module requests, ideas, or collaboration, head over to the **GitHub Discussions** tab.

---

## License

This project is licensed under the **Apache License 2.0** — see [LICENSE](./LICENSE) for details.
