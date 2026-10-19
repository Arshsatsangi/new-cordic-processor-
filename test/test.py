import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

async def load_angle_32bit(dut, val):
    for b in range(4):
        dut.ui_in.value = (val >> (8 * b)) & 0xFF
        dut.uio_in.value = (1 << 2) | (b & 0x03)  # WE=1, byte_sel=b
        await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0

async def read_word_32bit(dut, select_sin):
    word = 0
    for b in range(4):
        dut.uio_in.value = ((1 if select_sin else 0) << 4) | (b & 0x03)
        await ClockCycles(dut.clk, 1)
        word |= (int(dut.uo_out.value) & 0xFF) << (8 * b)
    return word

@cocotb.test()
async def test_cordic_30deg(dut):
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Load 30 degrees in Q2.30 (0.5235987756 rad -> 0x2182A470)
    await load_angle_32bit(dut, 0x2182A470)

    # Pulse start (uio_in[3] = 1) for 1 clock
    dut.uio_in.value = (1 << 3)
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0

    # Wait for completion (done flag on uio_out[7])
    for _ in range(30):
        await ClockCycles(dut.clk, 1)
        if (int(dut.uio_out.value) >> 7) & 1:
            break

    # Read back cosine (out_sel = 0) and sine (out_sel = 1)
    cos_val = await read_word_32bit(dut, select_sin=False)
    sin_val = await read_word_32bit(dut, select_sin=True)

    dut._log.info(f"CORDIC 30 deg result: cos=0x{cos_val:08x}, sin=0x{sin_val:08x}")

    # Golden values for 30 degrees in Q2.30:
    # cos(30 deg) ~ 0x376CD741 (0.866018)
    # sin(30 deg) ~ 0x200034EC (0.500013)
    assert cos_val == 0x376CD741, f"Expected cos 0x376CD741, got 0x{cos_val:08x}"
    assert sin_val == 0x200034EC, f"Expected sin 0x200034EC, got 0x{sin_val:08x}"
