import os
import numpy as np
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer, ValueChange
from tb.reference.sobel_reference import compare_gray, sobel_rgb

W = 32
H = 24
N = W * H


async def apb_write(d, addr, value):
    d.psel.value = 1
    d.penable.value = 0
    d.pwrite.value = 1
    d.paddr.value = addr
    d.pwdata.value = value
    await RisingEdge(d.clk)
    d.penable.value = 1
    await Timer(1, unit="ns")
    assert int(d.pready.value) == 1
    assert int(d.pslverr.value) == 0
    await RisingEdge(d.clk)
    d.psel.value = 0
    d.penable.value = 0
    d.pwrite.value = 0
    d.paddr.value = 0
    d.pwdata.value = 0


def packed(rgb):
    return (int(rgb[0]) << 16) | (int(rgb[1]) << 8) | int(rgb[2])


async def send_frame(d, frame, request_sleep_at=None):
    accepted = 0
    output = []
    sleep_sent = False
    for _ in range(100 * N + 2000):
        await FallingEdge(d.clk)
        if accepted < N:
            row, col = divmod(accepted, W)
            d.s_tdata.value = packed(frame[row, col])
            d.s_tvalid.value = 1
            d.s_tuser.value = int(accepted == 0)
            d.s_tlast.value = int(col == W - 1)
        else:
            d.s_tvalid.value = 0
            d.s_tuser.value = 0
            d.s_tlast.value = 0
        d.m_tready.value = 1
        if request_sleep_at is not None and accepted >= request_sleep_at and not sleep_sent:
            d.sleep_req.value = 1
            sleep_sent = True
        await Timer(1, unit="ns")
        input_fire = int(d.s_tvalid.value) and int(d.s_tready.value)
        output_fire = int(d.m_tvalid.value) and int(d.m_tready.value)
        if output_fire:
            index = len(output)
            row, col = divmod(index, W)
            assert int(d.m_tuser.value) == int(index == 0), "SOF mismatch"
            assert int(d.m_tlast.value) == int(col == W - 1), "EOL mismatch"
            output.append(int(d.m_tdata.value))
        await RisingEdge(d.clk)
        if input_fire:
            accepted += 1
        if accepted == N and len(output) == N:
            break
    else:
        raise AssertionError("frame transfer timed out")

    actual = np.asarray(output, dtype=np.uint8).reshape(H, W)
    expected = sobel_rgb(frame, threshold=128, bypass_threshold=False)
    result = compare_gray(expected, actual)
    print(f"CONFIG_B_FRAME accepted={accepted} output={len(output)} mismatch={result['mismatch_count']}")
    assert accepted == N and len(output) == N
    assert result["mismatch_count"] == 0
    return sleep_sent


@cocotb.test()
async def frame_drain_idle_gate_wake_and_reference(d):
    d.rst.value = 1
    d.s_tvalid.value = 0
    d.s_tdata.value = 0
    d.s_tuser.value = 0
    d.s_tlast.value = 0
    d.m_tready.value = 0
    d.psel.value = 0
    d.penable.value = 0
    d.pwrite.value = 0
    d.paddr.value = 0
    d.pwdata.value = 0
    d.sleep_req.value = 0
    d.wake_req.value = 0
    d.test_mode.value = 0
    cocotb.start_soon(Clock(d.clk, 10, unit="ns").start())
    await RisingEdge(d.clk)
    await RisingEdge(d.clk)
    d.rst.value = 0
    await apb_write(d, 0x00, 1)
    await apb_write(d, 0x04, 128)

    frame = np.random.default_rng(0xB03224).integers(0, 256, size=(H, W, 3), dtype=np.uint8)
    # Request during the frame: all remaining pixels and the final output
    # transfer must complete before the functional clock can stop.
    sent = await send_frame(d, frame, request_sleep_at=N // 2)
    await Timer(1, unit="ns")
    assert sent and int(d.sleep_ack.value) == 1, "sleep did not follow full-frame drain"

    gated_clk = d.u_func_clk_gate.GCK
    async def check_gate_edges():
        while True:
            await ValueChange(gated_clk)
            await Timer(1, unit="ps")
            assert int(gated_clk.value) == int(d.clk.value), "gated clock changed outside parent clock edge"
    gate_checker = cocotb.start_soon(check_gate_edges())

    # The test-mode bypass is intentionally independent of functional input.
    d.test_mode.value = 1
    await RisingEdge(d.clk)
    await Timer(1, unit="ps")
    assert int(d.sleep_ack.value) == 1
    assert int(gated_clk.value) == int(d.clk.value)
    d.test_mode.value = 0
    await FallingEdge(d.clk)
    await Timer(1, unit="ps")
    assert int(gated_clk.value) == 0
    for _ in range(5):
        await RisingEdge(d.clk)
        await Timer(1, unit="ps")
        assert int(gated_clk.value) == 0, "functional clock toggled during drained idle"

    d.s_tvalid.value = 1
    d.s_tuser.value = 1
    d.s_tlast.value = 0
    for _ in range(3):
        await FallingEdge(d.clk)
        await Timer(1, unit="ps")
        assert int(d.s_tready.value) == 0, "new frame accepted while clock is gated"
        await RisingEdge(d.clk)
    d.s_tvalid.value = 0
    d.s_tuser.value = 0

    d.sleep_req.value = 0
    d.wake_req.value = 1
    await RisingEdge(d.clk)
    await Timer(1, unit="ns")
    assert int(d.sleep_ack.value) == 0, "wake did not re-enable functional clock"
    d.wake_req.value = 0
    await FallingEdge(d.clk)

    await send_frame(d, frame)
    # The source APB frame counter is a simple end-to-end check that both
    # frames completed once; APB remains functional after wake.
    d.psel.value = 1
    d.penable.value = 0
    d.pwrite.value = 0
    d.paddr.value = 0x0C
    await RisingEdge(d.clk)
    d.penable.value = 1
    await Timer(1, unit="ns")
    assert int(d.pready.value) == 1 and int(d.pslverr.value) == 0
    assert int(d.prdata.value) == 2, "APB frame count did not match completed frames"
    await RisingEdge(d.clk)
    d.psel.value = 0
    d.penable.value = 0
    d.sleep_req.value = 1
    await RisingEdge(d.clk)
    await Timer(1, unit="ns")
    assert int(d.sleep_ack.value) == 1, "idle sleep request did not gate the clock"
    d.sleep_req.value = 0
    gate_checker.cancel()
