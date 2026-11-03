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

## D-011 — reduced ASIC experiment dimensions

Keep the accepted source's 640x480 defaults, RTL, and full-size regression
unchanged. For the physical A/B/C/D study, instantiate the same parameterized
top at 32x24 (768 pixels and 512 pre-mapping line-buffer storage bits). The
existing source regression was run from a clean detached checkout and passed;
the existing top and streaming tests also pass at 32x24 with reference-exact
outputs. This is an ASIC study scope amendment, not a claim that 32x24 is the
source product's intended/default resolution. Use the same deterministic
32x24 activity frame for each configuration; the prior 640x480 power-workload
contract is superseded for this experiment only. Gate-1 history is retained.
Evidence: `results/raw/phase0-config-a/source-regression.log` and
`results/raw/phase0-config-a/sim-32x24/`.

## D-012 — sleep request at frame boundaries

Latch a sleep request while a frame is active, let that accepted frame and its
final output transfer complete, prevent admission of the next frame, and only
then enter PMU QUIESCE. No functional input is accepted after QUIESCE begins.
This clarifies the frozen PMU contract to match the selected streaming top's
frame-completion behavior. It defines future implementation intent only; no
PMU is implemented or proven by this decision.

## D-013 — provisional scan chain length for reduced design

The historical Gate-1 DFT default remains `-max_length 8 -clock_mixing no_mix`.
For D, evaluate a maximum chain length of 64 only if supported by the pinned
tool after Configuration A's mapped flop count is known. Freeze the actual D
policy before scan insertion. No DFT configuration has changed in A.

## D-014 — portfolio mission-period amendment to 12.00 ns

The earlier Gate-1 contract selected 10.50 ns as the portfolio mission
evaluation period; no external product requirement mandates that value. The
first conventional portfolio A implementation, built at the unchanged 10.30 ns
implementation target, failed read-only 10.50 ns mission STA with WNS
`-0.847352445126 ns`, TNS `-6.786191463470 ns`, and 16 setup endpoints. On the
same final ODB and SPEF, evaluation at the single proposed 12.00 ns period
passes with WNS `+0.652646839619 ns`, TNS `0`, zero setup/hold violations, and
zero slew/capacitance violations. Its existing GDS passed the pinned open-deck
DRC (zero items) and LVS (`Netlists match`).

Therefore, for the portfolio A/B/C/D comparison only, retain the 10.30 ns
implementation target and amend the common mission/evaluation period to
12.00 ns (83.33 MHz). Preserve 2.06 ns input/output delays, 1.095 ns
virtual-clock latency, all other constraints, implementation settings, and
the physical database. This is a reviewed comparison-method decision based on
the measured A result, not an external product specification, an optimization
claim, or a claim that A passed at 10.50 ns. The historical 10.50 ns failure
and the separate Gate-0 Ibex 10.30/10.50 evidence remain unchanged. All later
variants must independently pass mission STA at 12.00 ns; the change does not
claim any B/C/D result. Evidence: `results/processed/config-a-timing-recovery.md`.

## D-015 — measured, site-aligned PD_SW region proposal for one C retry

The frozen A core is `(1.380, 2.720)` to `(262.660, 261.120)` µm: 568
`unithd` site columns at 0.46 µm and 95 rows at 2.72 µm. The C floorplan ODB
contains 34,506.845 µm² of `PD_SW` mapped cells and 2,014.432 µm² of top-level
cells, including 37 parent-side `sky130_fd_sc_hd__lpflow_inputiso0n_1` cells
(231.472 µm²). The later global-placement initialization reports, after its
port-buffer and pin-density adjustments, region demands of 35,341.185 µm² for
`PD_SW` and 3,465.875 µm² for AON/top-level cells. Fixed tap-cell overlap for
the proposed split is 970.931 µm² on the `PD_SW` side and 121.366 µm² on AON.

The prior explicit region `{1.840, 5.440, 262.200, 258.400}` µm was aligned
to the placement grid and inside the core, but occupied 65,860.666 µm²
(97.55% of core), leaving only 1,654.086 µm² outside it—less than half the
3,465.875 µm² measured AON/top-level placement demand. This is evidence of an
overconstrained domain partition/capacity problem, not evidence of bad
site/row alignment. Separately, the no-area diagnostic reached global
placement and failed with `GPL-0324`/`GPL-0307` and extreme timing-repair area
growth; that remains a distinct placer numerical failure mode.

For one authorized controlled C retry only, propose
`PD_SW = {1.380, 2.720, 233.220, 261.120}` µm. This is exactly 504 site
columns by all 95 rows; the remaining right-side AON strip is 64 columns,
`{233.220, 2.720, 262.660, 261.120}` µm. `PD_SW` area is 59,907.456 µm²;
after measured tap overlap, its calculated utilization is 59.965% for the
35,341.185 µm² placement demand. AON area is 7,607.296 µm²; after tap overlap,
its calculated utilization is 46.299%, giving 1.296× the measured placement
demand capacity at the unchanged 0.60 density. A 503-column `PD_SW` region
would exceed 60% after the same measured fixed-cell overlap, so 504 is the
smallest site-aligned width meeting the frozen density target while reserving
usable AON capacity. This proposal does not change the outer core,
utilization, placement settings, source, timing, or library. It is **not a C
pass**; the single retry must validate region legality and placement. If it
fails, no further placement tuning is authorized by D-015.
Raw source evidence: `results/raw/phase1-config-c/inspect-upf-groups.log`,
`area-capacity-inspect.log`, `domain-capacity-inspect.log`, and the retained
ORFS placement logs under `results/raw/phase1-config-c/work/logs/`.
