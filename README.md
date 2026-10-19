# 32-Bit CORDIC Processor on Tiny Tapeout

A 32-bit iterative Q2.30 fixed-point CORDIC processor for sine and cosine implemented for Tiny Tapeout.

- **Architecture**: 16 micro-rotations in rotation mode using a 16-entry arctangent LUT (`cordic_atan_lut.v`).
- **Precision**: 32-bit signed fixed point ($Q2.30$, 1 sign bit, 1 integer bit, 30 fractional bits).
- **Interface**: 24-pin Tiny Tapeout wrapper (`project.v` -> `tt_um_cordic_processor`) multiplexing 32-bit angles and results over 8-bit buses.
- **Tiles**: 2x2.

## Verification
Simulated using [cocotb](https://www.cocotb.org/) and Icarus Verilog (`iverilog`).
```bash
cd test
make
```
