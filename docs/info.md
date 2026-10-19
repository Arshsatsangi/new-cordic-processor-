<!---
This file is used to generate your project datasheet.
-->

# 32-Bit CORDIC Processor

## How it works

This project implements a 32-bit iterative CORDIC (COordinate Rotation DIgital Computer) processor operating in rotation mode using Q2.30 signed fixed-point arithmetic. It calculates the sine and cosine of an input angle between $-\pi/2$ and $+\pi/2$ radians (where $1.0 = 2^{30} = \text{0x40000000}$).

### Key Architecture Features
- **Gain Compensation**: Pre-scaled initial X register with $K = 0.6072529351$ (`0x26DD3B6A`), avoiding post-scaling hardware multipliers.
- **Micro-rotations**: Computes 16 successive micro-rotations using an internal 16-entry arctangent lookup table (`cordic_atan_lut.v`).
- **Multiplier-less Datapath**: Implemented using only arithmetic barrel shifters, adders, and subtractors.
- **Tiny Tapeout 24-Pin Interface**: A 4-byte multiplexed I/O scheme enables full 32-bit angle loading and 32-bit cosine/sine readout through standard 8-bit Tiny Tapeout bidirectional and output pins.

### Pin Interface
- `ui_in[7:0]`: 8-bit input data byte.
- `uio_in[1:0]`: Byte select (`2'b00` = byte 0 [7:0], `2'b01` = byte 1 [15:8], `2'b10` = byte 2 [23:16], `2'b11` = byte 3 [31:24]).
- `uio_in[2]`: Write enable (`we = 1`) to load `ui_in` into the selected byte of `angle_reg`.
- `uio_in[3]`: Start pulse (1 clock cycle) to begin CORDIC calculation.
- `uio_in[4]`: Output select (`0` = cosine, `1` = sine).
- `uio_out[7]`: Done signal (asserted high when computation is complete after 16 cycles).
- `uo_out[7:0]`: 8-bit output data byte selected by `uio_in[1:0]` and `uio_in[4]`.

## How to test

1. Apply active-low reset (`rst_n = 0`) for 5 cycles, then release (`rst_n = 1`).
2. Load the 32-bit input angle byte-by-byte into `angle_reg`:
   - Set `ui_in` to byte 0 and `uio_in` to `0x04` (`we=1, byte_sel=0`).
   - Clock for 1 cycle.
   - Repeat for bytes 1, 2, and 3 (`byte_sel = 1, 2, 3`).
3. Set `uio_in = 0x08` (`start = 1`) for 1 clock cycle to trigger computation, then set `uio_in = 0`.
4. Monitor `uio_out[7]` until it goes high (takes 16 clock cycles).
5. Read the 32-bit cosine result:
   - Set `out_sel = 0` (`uio_in[4] = 0`).
   - Read bytes 0 through 3 from `uo_out` by setting `byte_sel = 0, 1, 2, 3`.
6. Read the 32-bit sine result:
   - Set `out_sel = 1` (`uio_in[4] = 1`).
   - Read bytes 0 through 3 from `uo_out` by setting `byte_sel = 0, 1, 2, 3`.

## External hardware

No external hardware required. Can be connected to a microcontroller or FPGA via the standard Tiny Tapeout PMOD headers.
