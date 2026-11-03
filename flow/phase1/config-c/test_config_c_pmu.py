import numpy as np
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer, ValueChange, with_timeout
from tb.reference.sobel_reference import compare_gray, sobel_rgb

W, H, N = 32, 24, 32 * 24
ACTIVE, QUIESCE, CLOCK_GATED, ISOLATE, POWER_OFF, POWER_ON_WAIT, DEISOLATE = range(7)


def packed(rgb):
    return (int(rgb[0]) << 16) | (int(rgb[1]) << 8) | int(rgb[2])


async def wait_state(d, state, limit=30):
    for _ in range(limit):
        if int(d.power_state.value) == state:
            return
        await RisingEdge(d.clk)
        await Timer(1, unit="ps")
        await Timer(1, unit="ps")
    raise AssertionError(f"timeout waiting for PMU state {state}; got {int(d.power_state.value)}")


async def reset_recover(d):
    d.rst.value = 1
    await Timer(1, unit="ps")
    assert int(d.iso_en_n.value) == 0
    assert int(d.power_off_intent.value) == 0
    for _ in range(2):
        await RisingEdge(d.clk)
    d.rst.value = 0
    await wait_state(d, DEISOLATE, limit=6)
    await wait_state(d, ACTIVE, limit=3)
    assert int(d.wake_done.value) == 1 and int(d.iso_en_n.value) == 1


async def apb_write(d, addr, value):
    d.psel.value = 1
    d.penable.value = 0
    d.pwrite.value = 1
    d.paddr.value = addr
    d.pwdata.value = value
    await RisingEdge(d.clk)
    d.penable.value = 1
    await Timer(1, unit="ns")
    assert int(d.pready.value) == 1 and int(d.pslverr.value) == 0
    await RisingEdge(d.clk)
    d.psel.value = 0
    d.penable.value = 0
    d.pwrite.value = 0


async def send_frame(d, frame, sleep_mid_frame=False, stall_drain=False):
    accepted = 0
    output = []
    eol_errors = []
    request_sent = False
    stall_cycles = 0
    blocked_new_sof_checked = False
    for _ in range(100 * N + 3000):
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
        d.m_tready.value = 0 if stall_drain and accepted == N and stall_cycles < 8 else 1
        if sleep_mid_frame and accepted >= N // 2 and not request_sent:
            d.power_down_req.value = 1
            request_sent = True
        await Timer(1, unit="ns")
        input_fire = int(d.s_tvalid.value) and int(d.s_tready.value)
        output_fire = int(d.m_tvalid.value) and int(d.m_tready.value)
        if output_fire:
            idx = len(output)
            row, col = divmod(idx, W)
            assert int(d.m_tuser.value) == int(idx == 0), f"SOF mismatch idx={idx} accepted={accepted} state={int(d.power_state.value)}"
            if int(d.m_tlast.value) != int(col == W - 1):
                eol_errors.append((idx, row, col, int(d.m_tlast.value), accepted, int(d.power_state.value), int(d.frame_active_q.value), int(d.input_frame_done_q.value), int(d.sleep_pending_q.value)))
            output.append(int(d.m_tdata.value))
        await RisingEdge(d.clk)
        if input_fire:
            accepted += 1
        if accepted == N and stall_drain and len(output) < N and stall_cycles < 8:
            stall_cycles += 1
            if sleep_mid_frame and not blocked_new_sof_checked and int(d.power_state.value) == ACTIVE:
                await Timer(1, unit="ps")
                assert int(d.s_tready.value) == 0, (f"new frame must be blocked while prior output drains: input_done={int(d.input_frame_done_q.value)} pending={int(d.sleep_pending_q.value)} frame={int(d.frame_active_q.value)} row_in={int(d.input_eol_count_q.value)} row_out={int(d.output_eol_count_q.value)}")
                blocked_new_sof_checked = True
        if request_sent:
            d.power_down_req.value = 0
        if accepted == N and len(output) == N:
            break
    else:
        raise AssertionError(f"frame transfer timed out accepted={accepted} output={len(output)} state={int(d.power_state.value)} frame={int(d.frame_active_q.value)} in_done={int(d.input_frame_done_q.value)} out_done={int(d.output_frame_done_q.value)} pending={int(d.sleep_pending_q.value)} input_ready={int(d.s_tready.value)} output_valid={int(d.m_tvalid.value)} sleep_req={int(d.power_down_req.value)} eol_errors={eol_errors[-8:]}")
    actual = np.asarray(output, dtype=np.uint8).reshape(H, W)
    expected = sobel_rgb(frame, threshold=128, bypass_threshold=False)
    result = compare_gray(expected, actual)
    print(f"CONFIG_C_FRAME accepted={accepted} output={len(output)} mismatch={result['mismatch_count']} eol_errors={eol_errors[:8]}")
    assert accepted == N and len(output) == N and result["mismatch_count"] == 0
    assert not eol_errors, f"EOL metadata mismatches: {eol_errors}"
    if sleep_mid_frame:
        assert request_sent and blocked_new_sof_checked


async def enter_power_off(d):
    d.power_down_req.value = 1
    await RisingEdge(d.clk)
    d.power_down_req.value = 0
    await wait_state(d, POWER_OFF, limit=12)
    assert int(d.iso_en_n.value) == 0 and int(d.power_off_intent.value) == 1
    assert int(d.sleep_ack.value) == 1 and int(d.func_clk.value) == 0


async def wake_to_active(d):
    d.wake_req.value = 1
    await RisingEdge(d.clk)
    d.wake_req.value = 0
    await Timer(1, unit="ps")
    assert int(d.power_state.value) == POWER_ON_WAIT
    assert int(d.power_off_intent.value) == 0 and int(d.iso_en_n.value) == 0
    # Four AON guard cycles with functional clock disabled.
    for guard_cycle in range(4):
        await FallingEdge(d.clk)
        await Timer(1, unit="ps")
        assert int(d.func_clk.value) == 0, f"func clock active before AON guard edge {guard_cycle}: state={int(d.power_state.value)} en={int(d.func_clk_en.value)} count={int(d.u_pmu.wait_count_q.value)}"
        await RisingEdge(d.clk)
        await Timer(1, unit="ps")
        if guard_cycle < 3:
            assert int(d.func_clk.value) == 0, f"func clock advanced during AON guard edge {guard_cycle}: state={int(d.power_state.value)} en={int(d.func_clk_en.value)} count={int(d.u_pmu.wait_count_q.value)}"
    # Reset must be asserted across two generated-clock rising edges. The
    # state can deassert reset immediately after the second edge's NBA update.
    await with_timeout(RisingEdge(d.func_clk), 100, "ns")
    assert int(d.func_rst.value) == 1
    await FallingEdge(d.clk)
    await Timer(1, unit="ps")
    assert int(d.func_rst.value) == 1
    await with_timeout(RisingEdge(d.func_clk), 100, "ns")
    await wait_state(d, DEISOLATE, limit=4)
    assert int(d.iso_en_n.value) == 1 and int(d.func_rst.value) == 0
    await wait_state(d, ACTIVE, limit=3)
    assert int(d.wake_done.value) == 1


@cocotb.test()
async def pmu_frame_drain_power_intent_wake_and_reset_all_states(d):
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
    d.power_down_req.value = 0
    d.wake_req.value = 0
    d.test_mode.value = 0
    cocotb.start_soon(Clock(d.clk, 10, unit="ns").start())
    await RisingEdge(d.clk)
    await RisingEdge(d.clk)
    d.rst.value = 0
    await wait_state(d, ACTIVE, limit=8)

    await apb_write(d, 0x00, 1)
    await apb_write(d, 0x04, 128)
    frame = np.random.default_rng(0xC03224).integers(0, 256, size=(H, W, 3), dtype=np.uint8)
    await send_frame(d, frame)
    await send_frame(d, frame, sleep_mid_frame=True, stall_drain=True)
    await wait_state(d, POWER_OFF, limit=12)
    assert int(d.iso_en_n.value) == 0 and int(d.power_off_intent.value) == 1
    assert int(d.s_tready.value) == 0 and int(d.m_tvalid.value) == 0 and int(d.m_tdata.value) == 0

    # APB requests while logically off are answered by the AON side.
    d.psel.value = 1
    d.penable.value = 1
    d.pwrite.value = 0
    d.paddr.value = 0x0C
    await Timer(1, unit="ns")
    assert int(d.pready.value) == 1 and int(d.pslverr.value) == 1 and int(d.prdata.value) == 0
    d.psel.value = 0
    d.penable.value = 0

    # A test-mode gate bypass opens the function clock but isolation remains.
    d.test_mode.value = 1
    await RisingEdge(d.clk)
    assert int(d.iso_en_n.value) == 0 and int(d.power_off_intent.value) == 1
    d.test_mode.value = 0
    await FallingEdge(d.clk)
    await Timer(1, unit="ps")
    assert int(d.func_clk.value) == 0
    await wake_to_active(d)

    # After logical off, software reinitializes the non-retained function.
    await apb_write(d, 0x00, 1)
    await apb_write(d, 0x04, 128)
    await send_frame(d, frame)

    # Repeated idle sleep/wake and the frozen same-cycle APB priority.
    d.psel.value = 1
    d.penable.value = 1
    d.pwrite.value = 1
    d.power_down_req.value = 1
    d.paddr.value = 0x04
    d.pwdata.value = 64
    await Timer(1, unit="ns")
    assert int(d.pready.value) == 1 and int(d.pslverr.value) == 1 and int(d.prdata.value) == 0
    await RisingEdge(d.clk)
    d.power_down_req.value = 0
    d.psel.value = 0
    d.penable.value = 0
    d.pwrite.value = 0
    await wait_state(d, POWER_OFF, limit=12)
    await wake_to_active(d)

    # Reset in every state must restart with the clock enabled, logical off
    # removed and isolation asserted, then complete two reset cycles.
    for target in (ACTIVE, QUIESCE, CLOCK_GATED, ISOLATE, POWER_OFF, POWER_ON_WAIT, DEISOLATE):
        if target == ACTIVE:
            await wait_state(d, ACTIVE)
        elif target in (QUIESCE, CLOCK_GATED, ISOLATE, POWER_OFF):
            d.power_down_req.value = 1
            await RisingEdge(d.clk)
            await Timer(1, unit="ps")
            d.power_down_req.value = 0
            await wait_state(d, target, limit=8)
        elif target in (POWER_ON_WAIT, DEISOLATE):
            await enter_power_off(d)
            d.wake_req.value = 1
            await RisingEdge(d.clk)
            d.wake_req.value = 0
            await wait_state(d, POWER_ON_WAIT, limit=3)
            if target == DEISOLATE:
                await wait_state(d, DEISOLATE, limit=8)
        assert int(d.power_state.value) == target
        await reset_recover(d)

    print("CONFIG_C_PMU_SCENARIOS PASS reset_in_each_state=7 repeated_sleep_wake=PASS")
