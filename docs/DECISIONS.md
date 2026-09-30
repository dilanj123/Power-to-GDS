# Power-to-GDS Decisions

This file records decisions already supported by repository evidence. Proposed
methodology is labeled as such and is not presented as an observed result.

## D-001 — frozen implementation stack

Retain ORFS `3a964e13f11a4e435aac01ffa14db0a7d2853720`, OpenROAD
`4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`, Yosys
`a5af9d690a43744bf6b2cc3dea2717c16b54621c`, the pinned native Linux/arm64
image, and SKY130HD until a new decision authorizes a rerun.

## D-002 — SKY130HD power-switch limitation

POWER-000 is classification B. The pinned OpenROAD stack supports power-switch
intent, mapping semantics, and PDN insertion, but the exact SKY130HD platform
has no valid physical power-switch master. The project therefore does not
claim physical power gating and does not add a synthetic macro.

## D-003 — bounded DFT scope

The pinned DFT capability and project scan-routing smoke are qualified only for
scan-cell replacement, chain stitching, scan-port placement/routing, and
physical integration at the demonstrated scope. ATPG, fault coverage, scan
timing closure, tester qualification, and production DFT sign-off are outside
the accepted claim.

## D-004 — conventional timing disposition

10.00 ns is retained as a non-closing stress point. The existing 10.20 ns and
10.30 ns implementations are failed timing candidates. The reviewed next
period-only experiment is 10.50 ns; its result is not predetermined.

## D-005 — PMU contract scope

The minimum one-`PD_AON`/one-`PD_SW` control sequence in
`docs/MICROARCHITECTURE.md` is the proposed architecture boundary for the
later C experiment. It freezes control semantics for verification planning;
it does not claim PMU RTL or formal proof exists yet.

## D-006 — comparison discipline

Later A/B/C/D work must keep source RTL, pinned toolchain/platform, analysis
corner, evaluation period, geometry, utilization, constraints, activity
stimulus, and reporting stage constant unless the experiment explicitly
documents a necessary delta.

## D-007 — 10.50 ns baseline hard stop

The fresh 10.50 ns conventional experiment completed the physical flow but
failed final extracted STA: WNS/TNS were `-0.0588205 ns` with one setup
violation. It is not a frozen comparison baseline. Period-only experiments are
stopped; no 10.6 ns run or period sweep is authorized. The next timing
decision must explicitly choose implementation margin or timing-repair
configuration before A/B/C/D work can begin.
