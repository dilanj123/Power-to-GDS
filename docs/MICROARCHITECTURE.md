# Power-to-GDS Microarchitecture Contract

Status: this is the frozen Gate-1 comparison boundary and logical-control
contract; it does not modify the imported RTL. The C PMU wrapper was later
implemented and exercised with directed simulation and bounded SAT checks,
but C failed physical detailed placement. See `docs/RESULTS.md` for executed
evidence; the proposed protocol below is not evidence of physical power
gating or a fully proven PMU.

## Comparison boundary

The selected source block will remain immutable across A/B/C/D. Wrappers,
clock-gating logic, PMU/control logic, UPF, SDC, and scan hooks are tracked as
explicit experiment deltas. The intended boundary is one functional block
partitioned into an always-on control domain (`PD_AON`) and one logical
switchable domain (`PD_SW`).

The accepted immutable source is
`ad35514c990f6e1c9eb9fa18aee9d906f9df7721`; selected top is
`rtl_to_pixels_top_pipelined`. The clean-checkout regression is recorded in
`results/processed/imported-rtl-acceptance.md`. A/B/C/D keep this functional
RTL commit and the module's public stream/APB interface identical. Project
wrappers and PMU logic are explicit deltas. The selected top's synchronous
active-high `rst` must be asserted and clocked before functional clock gating
and during restart.

## Proposed domain/control contract

Control sequence:

`ACTIVE -> QUIESCE -> CLOCK_GATED -> ISOLATE -> POWER_OFF -> POWER_ON_WAIT -> DEISOLATE -> ACTIVE`

The minimum project-owned control interface is:

- request inputs: `power_down_req` and `wake_req`;
- quiesce indication: `functional_quiescent`, true only after new accepts are
  blocked and all accepted pixels, pipeline-valid entries, and pending frame
  completion have drained;
- clock control: active-high `func_clk_en`; scan test mode bypasses gating;
- isolation control: `iso_en_n`, asserted low; crossings from `PD_SW` are
  clamped to zero at the parent boundary;
- logical switch intent/status: `power_off_intent` and `power_state`;
- wake status: `wake_done` after the restart sequence;
- reset: the AON PMU reset is independent; functional reset is synchronous,
  active-high, and held through shutdown and functional restart.

These are project wrapper signals, not existing source RTL ports. The external
stream and APB interfaces remain the accepted top's interface. APB and stream
responses from the switchable block are isolated while it is logically off;
software must reinitialize the block after wake because retention is out of
scope.

## Safety ordering

The PMU must enforce the fixed sequence
`ACTIVE -> QUIESCE -> CLOCK_GATED -> ISOLATE -> POWER_OFF -> POWER_ON_WAIT ->
DEISOLATE -> ACTIVE`. `power_down_req` is accepted only in `ACTIVE`; elsewhere
it is ignored. `wake_req` is latched in any non-`ACTIVE` state and cannot skip
ordering. If it arrives during shutdown, the PMU completes drain, gate, and
isolation ordering and then honors wake after logical off. APB requests
concurrent with entry to `QUIESCE` or made in any non-`ACTIVE` state are
answered at the AON wrapper with `PREADY=1`, `PSLVERR=1`, and `PRDATA=0`; they
do not reach `PD_SW`. `power_down_req` has priority over a same-cycle APB
request. There is no shutdown timeout: the environment is assumed fair so
every accepted pixel eventually drains. If it does not, the PMU remains in
`QUIESCE` and does not gate the clock or assert off intent.

On wake, the logical off intent is removed, isolation remains asserted for a
four-AON-cycle guard, then the functional clock runs for two reset cycles
while the functional reset remains asserted. After reset release, isolation
may be deasserted and the PMU returns to `ACTIVE`. A reset request in any PMU
state removes logical off intent, asserts isolation, enables the functional
clock, holds functional reset for two cycles, then de-isolates into `ACTIVE`.
These are protocol-cycle guards only; they do not model rail ramp, power-good,
or electrical wake time.

## Physical limitation

The pinned SKY130HD platform has no valid physical power-switch master. Thus
`POWER_OFF` is a logical/power-intent state for this project. No supply
interruption, electrical wake behavior, IR-drop result, or physical power
gating is implied. The existing POWER-000 classification B remains in force.

## Planned formal properties

The later formal harness must prove, under explicit fairness and reset
assumptions:

- isolation is asserted before logical power-off;
- the functional clock is disabled before logical power-off;
- de-isolation cannot occur while logically off;
- wake delay is observed before de-isolation;
- only legal state transitions occur;
- functional reset is held for the restart cycles before de-isolation;
- return to `ACTIVE` occurs only after the wake sequence.

The wrapper must also expose a meaningful quiescence predicate for the
streaming pipeline and prove that the scoreboard sees no dropped, duplicated,
or reordered output transactions across a sleep/wake boundary.

These properties are specified, not formally checked by this document.

## ASIC experiment sizing

Per D-011, the original 640x480 source remains unchanged and is retained as
source-regression evidence. The A/B/C/D ASIC experiments parameterize this
same top as 32x24. This reduces the image to 768 pixels and the two 8-bit
line buffers to 512 storage bits before synthesis, while retaining the full
streaming, Sobel, APB, and frame-boundary behavior. Configuration A simulation
at 32x24 is required before the physical baseline is accepted.

## Frame-boundary sleep clarification (D-012)

A sleep request received during `PROCESS`, `DRAIN`, or `WAIT_SOF` is latched.
The current accepted frame is allowed to finish, including its final output
transfer. The wrapper then prevents admission of a new frame and begins PMU
`QUIESCE`; from that point, no new functional input is accepted. This avoids
stranding a partial frame when the source top stops accepting pixels only at
frame boundaries. This clarification defines later PMU behavior; it does not
claim that PMU logic exists or has been verified.
