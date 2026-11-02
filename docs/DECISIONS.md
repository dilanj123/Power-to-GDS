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

## D-004 — conventional timing disposition (historical baseline decision)

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

## D-007 — 10.50 ns period-only candidate hard stop

The fresh 10.50 ns conventional experiment completed the physical flow but
failed final extracted STA: WNS/TNS were `-0.0588205 ns` with one setup
violation. It is not a frozen comparison baseline. Period-only experiments are
stopped; no 10.6 ns run or period sweep is authorized. The next timing
decision must explicitly choose implementation margin or timing-repair
configuration before A/B/C/D work can begin.

## D-008 — implementation-margin timing methodology

The exact re-established 10.30 ns physical database passes precise read-only
mission STA at 10.50 ns with WNS `+0.061130657792 ns`, TNS `0`, and zero
setup/hold violations. The 10.50 ns implementation-target database failed by
one reg-to-output setup path. Period-only physical results were non-monotonic;
therefore the conventional comparison method uses a 10.30 ns implementation
target and a common 10.50 ns mission/evaluation period. The accepted database
also has reported max-slew and max-capacitance residuals; they remain visible
and unmodified. No extra timing-repair knob or constraint exception was
introduced. Evidence: `results/processed/phase0-ibex-10p3ns-reestablished.md`.

## D-009 — Gate-0 closure with declared switch-intent limitation

Gate 0 passes after exact-database 10.50 ns timing acceptance, GDS generation,
zero-violation pinned open-deck DRC, and matching pinned open-deck LVS. The
baseline is timing-clean with electrical residuals. The POWER-000
classification-B physical-switch limitation remains explicit; no physical
power-gating claim is made. Open-deck checks are not foundry/production
sign-off. Evidence: `results/processed/gate0-closure-report.md`.

## D-010 — Gate-1 functional, PMU, DFT, and comparison contract

Freeze the immutable source at
`ad35514c990f6e1c9eb9fa18aee9d906f9df7721`, top
`rtl_to_pixels_top_pipelined`, one `PD_AON` wrapper/control domain and one
logical `PD_SW` processing domain. The PMU uses a no-timeout drain policy
under explicit environment fairness, the specified four-AON-cycle wake guard
and two functional reset cycles, active-low parent-side zero-clamp isolation,
and the documented logical switch intent. Clock gating uses the pinned ORFS
SKY130HD `OPENROAD_CLKGATE` mapping to `sky130_fd_sc_hd__dlclkp_1`; functional
and scan-test enables have the documented semantics. DFT is limited to the
proven scan replacement/planning/stitching/physical integration scope, with
initial chain policy `-max_length 8 -clock_mixing no_mix`. No PMU
simulation/formal execution or A/B/C/D implementation is claimed by this
decision.

Primary comparisons hold source, tools/image/platform hashes, mission period,
I/O delays, floorplan geometry, utilization target, synthesis/placement/CTS/
routing settings, PDN, pin placement, activity stimulus, analysis corner,
power-report stage/script, and parsers constant. Configuration A is completed
and frozen before changes for B, C, or D. The primary power analysis uses
the shared deterministic source workload; power numbers remain estimates and
are inadmissible as comparative reduction evidence until activity annotation
is qualified and coverage is reported. The planned workload is the pinned
640x480 real image, accepted APB setup, and fixed drained idle window. Evidence:
`docs/POWER_INTENT.md`,
`docs/VERIFICATION_PLAN.md`, `docs/FORMAL.md`, `docs/DFT.md`, and
`results/processed/gate1-engineering-contract.md`.
