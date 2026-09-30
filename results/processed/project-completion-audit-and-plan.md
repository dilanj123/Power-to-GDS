# Power-to-GDS deep project audit and completion plan

Audit date: 2026-09-30

Scope: repository/evidence review, read-only fixed-database STA sensitivity,
Gate-0 disposition, PMU/power-analysis gap analysis, imported-RTL readiness,
and adversarial review. No A/B/C/D implementation experiment was started.

## 1. Executive status

The repository is clean on `main` and points to the public origin
`https://github.com/dilanj123/Power-to-GDS`. The frozen ORFS/OpenROAD/Yosys
source revisions are present locally and the native Apple-Silicon Linux/arm64
Docker flow has produced substantial capability evidence.

The project is not complete and Gate 0 is not yet defensibly closed. The
current state is:

- the pinned backend is execution-qualified for the recorded UPF isolation,
  power-switch semantics, DFT/scan, scan physical-routing, and conventional
  Ibex flow experiments;
- the conventional Ibex result is fully technology mapped and routed, with
  open-deck GDS/DRC/LVS evidence in the preserved reference workspace, but
  the 10.00 ns, 10.20 ns, and 10.30 ns timing baselines are not timing-clean;
- power reporting exists in the pinned flow and vectorless reports were
  emitted, but no controlled activity-based A/B/C/D power comparison exists;
- the pinned SKY130HD platform has no valid physical power-switch master;
  this is a declared classification-B library limitation;
- the project has no PMU RTL, PMU simulation, PMU assertions, project formal
  harness, or imported portfolio RTL;
- the source portfolio candidate is ready for a separate immutable-commit
  acceptance gate, but has not been imported.

Shortest defensible strategy: close the remaining backend/documentation and
baseline gaps with one controlled margin-baseline task, accept one immutable
portfolio RTL commit, then run A/B/C/D with fixed geometry and explicit
intent/abstraction wording for configuration C. Do not make a physical
power-gating claim on this SKY130HD snapshot.

## 2. Authority audit

The following authority order was inspected:

| Authority file | Status | Finding |
|---|---|---|
| `00_MASTER_PROJECT_PLAN.md` | present | Defines evidence vocabulary, MVP scope, Gate 0–6 gates, fixed-core fairness, PMU contract, and non-claims. |
| `01_CHATGPT_PROJECT_OPERATING_INSTRUCTIONS.md` | present | Reinforces the authority order, claim boundaries, frozen toolchain, separate mission/scan timing, and power-estimate labels. |
| `docs/REQUIREMENTS.md` | created during Prompt A | Minimum project contract and non-claim boundaries recorded; observed results remain in processed evidence. |
| `docs/MICROARCHITECTURE.md` | created during Prompt A | Proposed imported boundary and PMU/domain contract recorded; not an RTL or formal-proof claim. |
| `docs/POWER_INTENT.md` | absent | Must be created before the C experiment to define the supported UPF subset and switch abstraction. |
| `docs/VERIFICATION_PLAN.md` | absent | Must be created before Gate 1 to bind simulations, formal assumptions, and pass criteria. |
| `docs/FORMAL.md` | absent | Must be created before PMU formal work; it is not a current proof record. |
| `docs/TIMING.md` | created during Prompt A | Timing target/evaluation distinction and acceptance criteria recorded; 10.50 ns remains unrun. |
| `docs/DFT.md` | absent | Must be created before D to freeze the supported scan scope and limitations. |
| `docs/DECISIONS.md` | created during Prompt A | Evidence-supported switch, DFT, timing, PMU-scope, and fairness decisions recorded. |
| `docs/PROJECT_STATE.md` | present | Lower-authority state summary; correctly keeps Gate 0 open. |
| `docs/EVIDENCE_INDEX.md` | present | Lower-authority evidence index; raw evidence is intentionally local/ignored. |

The bootstrap freeze file still says `TOOL EXECUTION NOT YET QUALIFIED`, while
later processed evidence records execution-qualified capability. This is a
temporal/staleness conflict, not a tool result conflict: the freeze file is an
initial source snapshot, while later qualification records are newer evidence.
Gate 0 closure should replace this ambiguity with a dated runtime manifest and
a decision record rather than silently treating the stale bootstrap label as
current.

## 3. Evidence matrix

`PASS` below means the named evidence exists; it does not imply that every
claim in the topic is complete. `—` means no evidence was found.

| Topic | Specified | Simulated | Formally checked | Synthesized | Placed | CTS | Routed | Timing-clean | Power-estimated | DRC | LVS | GDS | Remaining limitation |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Conventional Ibex baseline | inherited 10 ns example; not hard project requirement | — | — | PASS, mapped | PASS | PASS | PASS | FAIL at 10.00/10.20/10.30 | vectorless report exists | PASS open deck | PASS open deck | PASS in preserved reference workspace | no timing-clean frozen comparison baseline |
| ABC synthesis behavior | toolchain pinned | — | — | PASS_WITH_KNOWN_TOOL_WARNING | — | — | — | — | — | — | — | — | deterministic ABC9 abort remains |
| UPF parsing/intent | supported OpenROAD subset | — | — | PASS in smoke | — | — | — | — | — | — | — | — | no complete IEEE 1801 claim |
| Isolation | required candidate concept | — | — | PASS | PASS | PASS | PASS | not cleanly constrained | vectorless only | bounded smoke, not sign-off | — | — | DRT-0349 and incomplete timing/PDN limitations |
| Power-switch intent/mapping | required as intent | — | — | PASS, classification B | synthetic regression only | synthetic regression only | synthetic regression only | — | — | — | — | — | no valid physical SKY130HD switch master |
| Physical power switching | conditional only | — | — | NOT_REQUIRED for chosen platform claim; B limitation | NOT_DONE | NOT_DONE | NOT_DONE | — | — | — | — | — | do not claim physical gating |
| Scan/DFT capability | required for D within supported scope | — | — | PASS, classification A | PASS project smoke | PASS | PASS | mission timing only | — | bounded routing only | — | — | no scan-shift timing, ATPG, or coverage |
| PMU/control | specified in master plan | NOT_DONE | NOT_DONE | — | — | — | — | — | — | — | — | — | no PMU RTL, scenarios, assertions, or formal harness |
| Timing | SDC/mode rationale required | — | — | PASS reports | PASS | PASS | PASS | FAIL for current baselines | — | — | — | — | missing timing authority and clean baseline |
| Activity/power | estimates only, tagged by source | — | — | — | — | — | — | — | vectorless only | — | — | — | no VCD/SAIF comparative workload |
| Imported portfolio RTL | immutable commit and regression required | PASS in source repo | PASS selected formal set in source repo | source repo only | — | — | — | source repo timing only | — | — | — | — | not yet accepted/imported into Power-to-GDS |

## 4. Current proven and unproven claims

### Proven or bounded

- ORFS/OpenROAD/Yosys pins are exactly `3a964e13f11a4e435aac01ffa14db0a7d2853720`,
  `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`, and
  `a5af9d690a43744bf6b2cc3dea2717c16b54621c`.
- Native Apple-Silicon host, Linux/arm64 Docker, SKY130HD, and no-GUI flow
  were used for the recorded qualifications. The pinned image ID was
  `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`.
- UPF isolation intent, isolation materialization, placement, CTS, routing,
  scan replacement/stitching, scan BTerm placement, scan routing, and
  synthetic power-switch mapping have bounded evidence.
- Conventional Ibex synthesis is reproducible and fully technology mapped
  despite the deterministic Yosys/ABC9 return-134 warning.
- The preserved conventional reference generated GDS and passed the pinned
  open-deck KLayout DRC/LVS checks. This is not foundry sign-off and the
  timing result is not clean.
- The imported source repository is clean at `ad35514`, tag
  `v1.0.1-dependency-ready`, with source-level simulation/formal evidence in
  its own repository.

### Unproven or out of scope

PMU sequencing, quiescence for the selected imported block, logical
sleep/wake verification, PMU formal invariants, VCD/SAIF comparative power,
scan-shift timing, ATPG, fault coverage, tester qualification, production
DFT sign-off, real SKY130HD physical power switching, electrical switch
correctness, silicon, foundry sign-off, and a timing-clean conventional
A/B/C/D baseline remain unproven.

## 5. True Gate-0 disposition

The master plan's mandatory Gate-0 list is backend/capability qualification;
PMU RTL and imported RTL belong to later gates. The current classification is:

| Gate-0 item | Status | Required closure action |
|---|---|---|
| Exact backend/host/ISA/image | PASS_WITH_DECLARED_LIMITATION | Runtime manifest created; keep Linux/arm64 as the qualified backend and document that x86-64 fallback was not selected. |
| Frozen source revisions | PASS | Preserve pins; no upgrades. |
| Critical platform hashes | RECORDED_PENDING_COMMIT | SHA-256 hashes are in `results/processed/runtime-platform-manifest.md`. |
| Known reference flow | PASS_WITH_DECLARED_LIMITATION | Preserve conventional Ibex GDS/open-deck DRC/LVS and its timing failure. |
| Required UPF commands | PASS | Keep supported-subset wording. |
| SKY130 isolation handling | PASS_WITH_DECLARED_LIMITATION | Keep exact-cell policy and DRT-0349/PDN limitations. |
| Physical switch mapping status | PASS_WITH_DECLARED_LIMITATION | Classification B; no physical switch claim. |
| DFT scan commands | PASS | Capability A and project scan routing smoke are recorded. |
| Power-report path | PASS_WITH_DECLARED_LIMITATION | Existing vectorless `report_power` evidence exists; Prompt A must still qualify one reproducible command and units. |
| Reproducible rerun | NOT_YET_CLOSED | Re-run a bounded Gate-0 manifest/smoke bundle from the frozen image and archive return codes; do not rerun A/B/C/D. |
| Timing-clean conventional baseline | NOT_REQUIRED for backend capability, but required before fair timing QoR comparison | Run one margin-baseline experiment, not a period sweep. |

The real Gate-0 blockers are therefore: committed runtime/platform and
authority documents, a bounded reproducibility bundle including power
reporting, immutable RTL acceptance, and the one authorized 10.50 ns baseline
decision. The lack of physical power switching, ATPG, retention, DVFS, silicon,
and production sign-off are resolved scope limitations, not Gate-0 blockers for
this project.

## 6. Timing non-monotonicity diagnosis

The three final implementations were compared from existing reports; no
implementation was rerun for this audit.

| Metric | 10.00 ns | 10.20 ns | 10.30 ns |
|---|---:|---:|---:|
| Synthesized `ibex_core` cells | 14,065 | 14,065 | 14,065 |
| Synthesized local cells | 13,515 | 13,515 | 13,515 |
| Synthesized area | 129,405.36 | 129,405.36 | 129,405.36 |
| Final sequential cells | 1,939 | 1,939 | 1,939 |
| Final multi-input combinational cells | 12,052 | 12,051 | 12,053 |
| Final timing-repair buffers | 1,415 | 1,361 | 1,256 |
| Final clock buffers | 213 | 229 | 226 |
| Final clock inverters | 146 | 139 | 145 |
| Final route wirelength (um) | 649,244 | 651,590 | 655,948 |
| Final vias | 133,325 | 133,638 | 133,807 |
| Final setup skew | 0.142 ns | 0.20 ns | -0.20 ns |
| Final WNS | -0.1068 ns | -0.10 ns | -0.14 ns |
| Final TNS | -1.93 ns | -2.74 ns | -7.83 ns |

The synthesis mapping is effectively identical across all three runs. The
non-monotonic result is therefore not supported as a synthesis-mapping
relaxation effect. The direct evidence supports `MIXED`, ranked as:

1. physical timing-repair relaxation/redistribution: fewer timing-repair
   buffers were inserted as the target relaxed, but the final design changed;
2. clock-tree variability: clock-buffer/inverter counts and setup skew changed;
3. routing variability: wirelength and vias increased across the runs;
4. the same broad instruction/register-file cone remained critical, but the
   exact worst endpoint moved from `rf_reg[184]` to `rf_reg[668]` to
   `rf_reg[549]`.

A complete drive-strength histogram was not present in the processed evidence,
so no stronger claim about individual synthesis drive choices is made. The
available path reports show different physical repair cells and the same
logic family/cone, which is consistent with mixed physical optimization and
routing variability.

## 7. Fixed-database STA sensitivity

Read-only OpenROAD STA reloaded the existing final ODB, final SPEF, final SDC,
and pinned SKY130HD Liberty for each database. Temporary analysis clocks were
changed to `10.00`, `10.20`, `10.30`, `10.50`, `10.75`, and `11.00 ns`; no
implementation checkpoint was changed. The virtual clock was changed with
the same analysis period while the existing I/O-delay values remained from
the stored SDC. This is analysis/evaluation, not a new implementation target.

| Existing physical database | 10.00 | 10.20 | 10.30 | 10.50 | 10.75 | 11.00 | Approximate clean analysis period |
|---|---:|---:|---:|---:|---:|---:|---|
| 10.00 ns reference | -0.11/-1.87 | 0.00/0.00 | 0.00/0.00 | 0.00/0.00 | 0.00/0.00 | 0.00/0.00 | about 10.20 ns |
| 10.20 ns implementation | -0.30/-12.01 | -0.10/-2.74 | -0.00/-0.01 | 0.00/0.00 | 0.00/0.00 | 0.00/0.00 | about 10.50 ns |
| 10.30 ns implementation | -0.44/-83.45 | -0.24/-18.98 | -0.14/-7.83 | 0.00/0.00 | 0.00/0.00 | 0.00/0.00 | about 10.50 ns |

Entries are `WNS/TNS` in ns. At 10.30 ns on the 10.20 ns database, the
reported negative values are rounded to `-0.00/-0.01` and four displayed paths
had zero-rounded violated slack; it is not treated as clean. At 10.50 ns the
10.30 ns database had no displayed violated slack in a 1,000-path report, but
the result remains fixed-database analysis and not a physical implementation
qualification.

The evidence supports strategy **B — IMPLEMENTATION_MARGIN**: choose one
documented implementation target with margin above the fixed-database
threshold, then evaluate all variants at one frozen mission period. Do not
use fixed-database sensitivity as a substitute for the margin implementation.
Do not sweep further periods without an approved single experiment.

## 8. PMU and control gap analysis

The repository contains only tiny UPF isolation smoke RTL and UPF. It has no
PMU module, state machine, quiescence counter, power-good input, wake/reset
sequencer, PMU simulation, assertions, or PMU formal harness.

The minimum PMU package for the imported streaming Sobel block is:

- an always-on wrapper with explicit `sleep_req`, `busy/in_flight`,
  `clk_enable`, `isolation_enable`, `power_switch_intent`, `power_good`,
  `wake_done`, `state`, and `error_safe` signals;
- states `ACTIVE -> QUIESCE -> CLOCK_GATED -> ISOLATE -> POWER_OFF ->
  POWER_ON_WAIT -> DEISOLATE -> ACTIVE`;
- drain-to-completion semantics: no new frame after quiesce begins, and the
  switchable block is not declared safe until its accepted work and output
  drain are complete;
- reset and isolation behavior for every state;
- a wrapper-level power-off abstraction that invalidates or resets switchable
  state logically, without pretending a physical SKY130 switch was inserted;
- simulation scenarios for idle sleep, in-flight drain, repeated wake/sleep,
  reset in every state, isolation behavior, configuration races, and illegal
  requests;
- assertions/formal properties for legal transitions, no accepts during
  quiesce/off, isolation-before-off, no deisolation-before-reset/power-good,
  and eventual wake under an explicit fairness assumption.

Recommended initial timeout decision: no automatic timeout; remain in
`QUIESCE` until the accepted work drains under an explicit environment
fairness assumption, and never silently force power-off. If the selected
interface requires bounded error recovery, add an explicit `ERROR_SAFE` state
before implementation rather than inventing a silent discard policy.

Because classification B rules out a real pinned-platform switch, C must be
described as a supported UPF/isolation and switch-intent abstraction with
logical sequencing. It cannot be called physical power gating.

## 9. Power-analysis methodology

The pinned flow exposes `report_power`, `set_power_activity`, `read_vcd`, and
`read_saif`. Existing conventional final reports include vectorless power
components and a total, for example approximately `0.0482599 W` in the
preserved 10.00 ns reference. This is an estimate, not measured power and not
a controlled low-power result.

The fair methodology is:

1. freeze one mission clock/evaluation period, Liberty corner, nominal voltage,
   SPEF stage, geometry, tool pins, synthesis settings, P&R settings, seed,
   report parser, and source RTL commit;
2. use the same RTL-level workload for A, B, C, and D: reset, idle, one or
   more complete image frames, controlled stalls, sleep request, wake, and
   repeated frame activity;
3. generate VCD or SAIF from the same simulation harness and time window for
   each configuration; use vectorless output only as a separately labelled
   smoke/reference;
4. load the final netlist, Liberty, SPEF where supported, and the matching
   SDC/mode into the pinned OpenROAD/OpenSTA binary; run `read_vcd` or
   `read_saif`, `report_activity_annotation`, and `report_power`;
5. report internal, switching, leakage, total, clock contribution when
   available, activity source, time window, corner, netlist/layout stage, and
   annotation coverage;
6. compare estimates only when the workload and analysis conditions match.

For C and D, the power-off interval is a logical/RTL abstraction because the
selected platform has no physical switch master. Report that as an estimated
activity scenario, not as measured rail-off power or physical power savings.
No result may say “power reduced” unless a matched activity-based estimate
demonstrates it; even then it must say “estimated power.”

## 10. Imported RTL readiness and Gate-1 handoff

`$HOME/Projects/from-rtl-to-pixels` is clean on `main` at commit `ad35514`,
tagged `v1.0.1-dependency-ready`, with origin
`https://github.com/dilanj123/from-rtl-to-pixels.git`. Its own state reports
Gate 5 closed for a CV-ready MVP, with passing simulation and selected formal
evidence, but no FPGA measurement.

The candidate is the pipelined top `rtl_to_pixels_top_pipelined` at that
immutable commit: one clock, synchronous active-high reset, RGB ready/valid
stream, APB-style configuration, frame drain, and an existing Architecture-B
timing result. Gate 1 must still re-run the source regression at the exact
commit and freeze the wrapper boundary before importing anything.

Gate-1 acceptance criteria:

- clean clone at the exact commit and recorded source SHA;
- source regression, lint, and selected formal commands return zero with
  archived logs and tool versions;
- top-level port map and reset/clock assumptions are frozen;
- canonical dimensions/workload and transaction boundary are recorded;
- quiescence is defined in terms of accepted frames, output drain, and APB
  configuration behavior;
- no source repository modification is required for import;
- attribution and license/provenance are recorded;
- a Power-to-GDS wrapper compiles and simulates without changing the imported
  functional RTL.

## 11. Missing authority-document plan

Prompt A creates the four minimum documents required before the next baseline
and source-acceptance steps. The remaining documents are intentionally deferred
until the gates that need them, with only decisions supported by evidence:

- `docs/POWER_INTENT.md`: exact supported UPF subset, domains, isolation,
  control polarity, physical-switch classification B, and C wording.
- `docs/VERIFICATION_PLAN.md`: simulation scenarios, scoreboards, formal
  properties, assumptions, and evidence locations.
- `docs/FORMAL.md`: actual PMU/interface proof records, engines, depth,
  assumptions, vacuity/cover review, and limitations.
- `docs/TIMING.md`: mission/scan SDCs, I/O assumptions, clock relations,
  exceptions and rationale; no broad false paths. The current file records
  the baseline contract; dedicated scan SDC detail remains deferred.
- `docs/DFT.md`: supported scan replacement/planning/stitching scope, chain
  metrics, mission-vs-scan timing boundary, and excluded ATPG/coverage.
- `docs/DECISIONS.md`: selected RTL, baseline period, backend manifest,
  classification-B switch limitation, timeout policy, and any rejected
  alternatives.

These are not permission to invent requirements. Missing source requirements
must be resolved as explicit decisions before implementation begins.

## 12. Gate-0 to Gate-7 completion plan

### Gate 0 — backend, capability, and conventional baseline freeze

Objective: close the remaining backend evidence without starting A/B/C/D.

Inputs: current qualification records, pinned image, Ibex raw workspaces,
platform files, and source pins.

Allowed changes: documentation, runtime/hash manifest, a bounded vectorless
power-report smoke, and one conventional margin-baseline run. No RTL, UPF,
PDK, DONT_USE, frozen tool source, or A/B/C/D variant.

Required verification/physical work: rerun the frozen capability bundle as a
reproducibility check; run one conventional implementation at a margin target
selected from the fixed-database result (recommended `10.50 ns`), then run
STA and, only if timing passes, GDS/open-deck DRC/LVS.

Measurements: stage WNS/TNS/setup/hold, area/cells, CTS, route, DRC/LVS/GDS,
and one documented vectorless `report_power` output.

Artifacts: runtime manifest, platform hashes, baseline config diff, processed
baseline summary, power smoke log, decision record, and updated evidence index.

Pass: frozen manifest is reproducible; baseline configuration is unchanged
except the approved margin target; timing acceptance is explicit; power is
labelled vectorless; no forbidden claim is made. Stop if the image/tool
identity differs, the baseline fails in a way requiring tuning, or the power
command cannot be reproduced.

Expected commit: `Close Gate 0 backend and baseline qualification`.

### Gate 1 — imported RTL acceptance

Objective: accept exactly one verified portfolio RTL commit.

Inputs: `from-rtl-to-pixels` commit `ad35514` and its source regression.

Allowed changes: a project-owned wrapper, manifests, and documentation; no
modification of imported functional RTL.

Required verification: clean-clone source tests, selected formal rerun,
wrapper compile/simulation, interface/provenance review, and PMU boundary
definition.

Pass: immutable source commit, regression evidence, stable top interface,
transaction/quiescence definition, and no unresolved functional issue.
Stop on source regression failure or an ambiguous quiescence contract.

Expected commit: `Freeze imported RTL and PMU boundary`.

### Gate 2 — conventional A baseline

Objective: implement the imported design conventionally before low-power or
scan changes.

Allowed changes: wrapper integration, mission SDC, conventional config, and
report scripts only.

Required: synthesis through the agreed physical stage, functional simulation,
STA, route, GDS/open-deck DRC/LVS if the agreed criteria pass, and machine-
readable metrics.

Pass: source regression and physical flow are reproducible; A contains no
low-power/scan transformation; baseline status is explicitly timing-clean or
non-closing. Stop if source, geometry, or tool pins drift.

Expected commit: `Freeze conventional configuration A`.

### Gate 3 — clock-gated B

Objective: add only the glitch-safe technology-aware clock-gating change.

Allowed change: PMU/wrapper clock-enable integration and required test/scan
bypass; no power-domain split or scan insertion.

Required: idle/in-flight/wake simulation, PMU assertions/formal properties,
mapped ICG-cell proof, mission STA/CTS, physical implementation, and same
metrics as A.

Pass: functional state is preserved across legal gating, exact ICG mapping and
clock relation are proven, and the A/B delta is attributable. Stop if a manual
AND gate or broad timing exception appears.

Expected commit: `Qualify clock-gated configuration B`.

### Gate 4 — power-domain/isolation C

Objective: add one `PD_AON`/`PD_SW` boundary, quiescence, isolation, and
supported switch intent.

Allowed change: UPF/PMU/isolation wrapper only; no synthetic switch macro and
no PDK/library change.

Required: low-power scenarios/formal properties, UPF persistence, exact
isolation placement/routing, domain area, mission STA, and clear classification
of physical switch availability.

Pass: isolation and sequencing are proven; C is reported as intent/
abstraction because classification B blocks a physical switch claim. Stop if
the report implies real rail-off gating or silently changes DONT_USE.

Expected commit: `Qualify power-domain isolation configuration C`.

### Gate 5 — power-domain plus scan D

Objective: add only the supported scan transformation to C.

Allowed change: scan replacement, plan/stitch hooks, generated scan ports, and
scan SDC/mode; mission SDC remains separate.

Required: chain metrics, scan BTerm placement, routed scan network, mission
STA, separate scan-shift STA if constraints are available, and functional
mission re-verification.

Pass: scan topology and physical routing survive; no ATPG/coverage claim.
Stop if scan and mission constraints are mixed or scan insertion changes more
than the declared delta.

Expected commit: `Qualify scan-enabled configuration D`.

### Gate 6 — fair comparison and conclusions

Objective: compare A/B/C/D under fixed conditions.

Freeze: source commit, tool/image, platform hashes, mission period, I/O
assumptions, geometry, utilization, seed, routing policy, activity workload,
and parsers. Capacity-rescue runs are separate and never replace primary
fixed-core results.

Measurements: area/cells, ICG/isolation/scan counts, utilization, congestion,
wire/vias, CTS, mission timing, scan timing, DRC/LVS/GDS states, and tagged
vectorless/VCD/SAIF estimates.

Pass: every delta is attributable and every hypothesis is RETAIN/MODIFY/
REJECT/INCONCLUSIVE. Stop if a variant requires an undeclared setting or
non-comparable workload.

Expected commit: `Record controlled A-B-C-D comparison`.

### Gate 7 — portfolio/reproduction/final claim audit

Objective: make the public project reproducible and recruiter-readable.

Required: clean-clone reproduction on the canonical backend, source/tool
manifest, diagrams, tables generated from machine-readable reports, exact
commands, evidence index, limitations, third-party notices, and claim review.

Pass: no stale authority conflict, no raw bulk tracked, no timing/power/
sign-off overclaim, and public repository reproduces the documented processed
results. Stop if reproduction depends on undocumented local paths.

Expected commit: `Finalize portfolio evidence and reproduction package`.

## 13. Minimal future Codex-task structure

Three additional major execution prompts are credible, but only with strict
stop points:

### Prompt A — close Gate 0 and Gate 1

Create the runtime/platform manifest, reproducibility bundle, vectorless power
smoke, one margin-baseline experiment, missing authority documents, and
immutable imported-RTL acceptance. Do not begin B/C/D. If the 10.50 ns
baseline is not clean, stop and classify it; do not sweep.

### Prompt B — execute controlled A/B/C/D

Implement the PMU/wrapper and verification package, then run A, B, C, and D in
order under the frozen controls. Preserve each raw workspace, generate
processed metrics, and stop at any failed gate rather than silently rescuing
the primary comparison.

### Prompt C — final audit and portfolio packaging

Run clean-clone/reproduction checks, finalize machine-readable comparison
tables, diagrams, evidence links, limitations, public README wording, and
claim audit. No new architecture or optimization is introduced.

This three-prompt plan is credible only if Prompt A accepts the imported RTL
without a source regression failure and the margin baseline is either clean or
explicitly retained as a bounded non-closing baseline. If either fails, split
Prompt A into a recovery task before Prompt B; do not compress a failure into
the A/B/C/D study.

## 14. Adversarial review and plan revisions

### Reproducibility review

Weakness: the repository has pins and an image tag, but the bootstrap manifest
does not contain runtime version strings, platform hashes, or one command that
replays all required capability checks.

Revision: Prompt A must commit a dated runtime/hash manifest and rerun a
bounded capability bundle. The OpenROAD self-version banner is `unknown`, so
source/image provenance must be reported alongside that limitation.

### Experiment-fairness review

Weakness: changing the timing target changes timing repair, CTS, and routing;
fixed-database STA cannot substitute for a fair implementation baseline.

Revision: use one margin implementation target and one frozen mission
evaluation period for A/B/C/D; retain fixed-core geometry; label capacity
rescue separately; never compare the 10.00/10.20/10.30 experiments as a
monotonic sweep.

### Claim-boundary review

Weakness: existing power totals and routed GDS could be misread as power
reduction or sign-off.

Revision: every report must include evidence-state labels. Use “vectorless
power estimate,” “open-deck DRC/LVS,” “supported UPF subset,” and “switch
intent abstraction.” Never use measured power, physical gating, timing
closure, ATPG coverage, or foundry sign-off without new evidence.

### Scope-control review

Weakness: PMU, retention, DVFS, full IEEE 1801, ATPG, and silicon could expand
the project beyond a portfolio study.

Revision: one always-on/one switchable domain, no retention/DVFS/level shifting
in the MVP, no ATPG, and no synthetic switch macro. The PMU contract is only
the minimum drain/isolate/wake sequencing package.

### Failure-mode review

Weaknesses: baseline timing may remain non-clean; the imported block may have
an ambiguous quiescence boundary; C may fail physically; power annotation may
be incomplete; runtime resources may make reruns non-repeatable.

Revision: each gate has a stop criterion, a bounded failure classification,
and preserved raw evidence. A failed baseline is not repaired by changing
constraints; a failed C is retained as a controlled result; incomplete power
annotation blocks a power conclusion; resource failure triggers backend
reproduction recovery rather than a silent tool change.

## 15. Revised final plan and next action

The revised plan is: first close the evidence/documentation gaps and accept
the immutable Sobel RTL; second implement the minimum PMU and controlled
variants; third perform the comparison and final public audit. Configuration C
will be a logically verified, physically isolated, switch-intent abstraction,
not claimed physical power gating, because the selected SKY130HD platform is
classification B.

The next exact execution task is **Prompt A**:

1. create the missing authority documents without inventing requirements;
2. record ORFS/OpenROAD/Yosys/image/runtime identity and the captured SKY130HD
   platform hashes;
3. run the bounded frozen capability/power-report reproducibility bundle;
4. run exactly one 10.50 ns conventional margin-baseline implementation from
   fresh synthesis using the current Ibex settings;
5. if timing is clean, run the same open-deck GDS/DRC/LVS checks; otherwise
   stop with `FAIL_TIMING` and do not sweep;
6. clean-clone and execute the `from-rtl-to-pixels` regression at `ad35514`;
7. record the imported top/wrapper boundary and PMU decision, but do not begin
   A/B/C/D.

No current evidence justifies declaring Gate 0 closed today. The completion
estimate is requirement-based: UPF, isolation, switch-semantics, DFT/scan,
and conventional-flow capabilities are qualified; runtime/hash manifest,
reproducibility bundle, explicit PMU boundary documentation, and a defensible
margin baseline remain. Three further major execution prompts are credible
with the stop conditions above.
