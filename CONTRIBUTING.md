# Contribution Guidelines

## 📌 What You Can Contribute

- **Modules**  
  - New Verilog modules (parameterized, reusable).
  - Improvements to existing modules (optimization, bug fixes, or feature additions).

- **Test Benches**  
  - Comprehensive test benches for verifying modules.
  - Edge-case scenarios and randomized testing for robustness.

- **Waveforms**  
  - Simulation waveforms that demonstrate module behavior.
  - Annotated waveform captures for educational clarity.

- **Documentation**  
  - Clear explanations of module functionality and usage.
  - Tutorials, examples, and integration notes for beginners.
  - Contributor guides and onboarding materials.

- **Others**  
  - Scripts for synthesis, automation, or CI/CD workflows.
  - Educational resources (diagrams, references, or guides).
  - Bug reports, feature requests, and discussions.

---

## 🛠 How to Contribute

1. **Fork the repository.**  
2. **Create a new branch** and add your module or changes.  
   - Linting will be automatically checked — no extra setup required.  
3. **Send a Pull Request (PR)** after verification.  

For **test benches**, you need to manually add the following block of code into the Verilog simulation workflow to verify:

```yaml
- name: Compile and run testbench MAC
  run: |
    iverilog -g2012 -o simv RTL/MAC.v Testbenches/MAC_tb.sv
    vvp simv
```
## 💬 Need Help?

If you face any difficulties while contributing, feel free to reach out through the [Discussions page](../../discussions) — especially for contribution-related questions.  
The community and maintainers are happy to help!

