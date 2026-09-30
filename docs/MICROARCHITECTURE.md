# Power-to-GDS Microarchitecture Contract

Status: proposed comparison boundary and control contract. This document does
not modify or yet accept the portfolio RTL.

## Comparison boundary

The selected source block will remain immutable across A/B/C/D. Wrappers,
clock-gating logic, PMU/control logic, UPF, SDC, and scan hooks are tracked as
explicit experiment deltas. The intended boundary is one functional block
partitioned into an always-on control domain (`PD_AON`) and one logical
switchable domain (`PD_SW`).

The candidate imported source is the verified
`rtl_to_pixels_top_pipelined` interface from the immutable source repository.
The final import remains contingent on the clean-checkout regression recorded
by Prompt A.

## Proposed domain/control contract

Control sequence:

`ACTIVE -> QUIESCE -> CLOCK_GATED -> ISOLATE -> POWER_OFF -> POWER_ON_WAIT -> DEISOLATE -> ACTIVE`

The minimum interface to be frozen before configuration C is:

- request input: `power_down_req`;
- functional-domain quiesce indication/assumption: `functional_quiescent`;
- clock control: `func_clk_en` and a technology-appropriate clock-gate point;
- isolation control: `isolation_en`, active-high isolation;
- logical power state: `power_off`;
- wake control/status: `power_on_ack` and `wake_done`;
- reset assumptions: control logic reset is always-on; functional reset is
  asserted for initialization and wake sequencing.

Names are contract placeholders until matched to the accepted RTL wrapper;
they are not claims that these signals already exist.

## Safety ordering

The proposed PMU must ensure that quiescence precedes clock gating, clock
gating precedes isolation, isolation precedes logical power-off, logical
power-on precedes wake completion, and de-isolation occurs only after wake
completion. The wake delay and reset release policy must be explicit in the
later formal harness.

## Physical limitation

The pinned SKY130HD platform has no valid physical power-switch master. Thus
`POWER_OFF` is a logical/power-intent state for this project. No supply
interruption, electrical wake behavior, IR-drop result, or physical power
gating is implied. The existing POWER-000 classification B remains in force.

## Planned formal properties

Prompt B should prove, under stated quiescence and reset assumptions:

- isolation is asserted before logical power-off;
- the functional clock is disabled before logical power-off;
- de-isolation cannot occur while logically off;
- wake delay is observed before de-isolation;
- only legal state transitions occur;
- return to `ACTIVE` occurs only after the wake sequence.

These properties are specified, not formally checked by this document.
