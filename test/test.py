# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

TEST = "01100101101"

@cocotb.test()
async def test_project(dut):

    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 3
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 0
    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    for s in TEST:
        for i in s:
            dut.ui_in[0].value = int(i)
            dut.ui_in[1].value = 0
            await ClockCycles(dut.clk, 1)
            dut.ui_in[1].value = 1
            await ClockCycles(dut.clk, 1)

    await ClockCycles(dut.clk, 5)
    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    #assert dut.uo_out.value == 50
    out_val = dut.uo_out.value
    assert out_val == TEST[::-1][2:-1]

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
