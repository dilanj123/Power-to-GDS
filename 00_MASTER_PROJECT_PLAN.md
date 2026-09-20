# Power-to-GDS — Multi-Domain Low-Power ASIC Implementation Study
## 00 — Master Project Plan

**Planning research snapshot:** 2026-09-20  
**Status:** planning only; no portfolio RTL has been modified and no project ASIC flow has been executed.  
**Readiness:** **READY WITH PHASE-0 CONDITIONS**.

---

## 1. Project purpose

Power-to-GDS is an evidence-driven ASIC physical-implementation portfolio study. It starts from already verified original RTL and asks:

> **What timing, area, physical-design, clock-network and test overhead is introduced when an already verified RTL subsystem is transformed from a conventional single-power-domain implementation into a clock-gated, power-domain-partitioned and scan-enabled ASIC implementation?**

The portfolio value is not a screenshot of OpenROAD. It is the controlled sequence of:
1. qualifying a reproducible toolchain;
2. preserving a known-good functional RTL baseline;
3. creating a conventional ASIC implementation baseline;
4. adding one implementation concern at a time;
5. re-verifying;
6. re-implementing under controlled conditions;
7. measuring differences;
8. recording whether each change is retained, modified, rejected or inconclusive.

### Explicit non-claims

This project does **not** by itself establish:
- production tapeout experience;
- foundry sign-off;
- Apple/NVIDIA-scale sign-off methodology;
- silicon measurement;
- post-silicon debug;
- ATPG coverage;
- DFT sign-off;
- timing closure;
- DRC/LVS cleanliness;
- power reduction;
- generated GDS;
- fabricated silicon.

Any of those states may be claimed only after corresponding tool or physical evidence exists.

---

## 2. Authority and evidence model

Future repository documents are authoritative in this order:

1. `00_MASTER_PROJECT_PLAN.md`
2. `01_CHATGPT_PROJECT_OPERATING_INSTRUCTIONS.md`
3. `docs/REQUIREMENTS.md`
4. `docs/MICROARCHITECTURE.md`
5. `docs/POWER_INTENT.md`
6. `docs/VERIFICATION_PLAN.md`
7. `docs/FORMAL.md`
8. `docs/TIMING.md`
9. `docs/DFT.md`
10. `docs/DECISIONS.md`
11. `docs/PROJECT_STATE.md`
12. `docs/EVIDENCE_INDEX.md`
13. implementation/build files

If two sources conflict, stop, identify the conflict, and resolve it in `docs/DECISIONS.md` before proceeding.

### Evidence-state vocabulary

Use these labels precisely:

| State | Meaning |
|---|---|
| `SPECIFIED` | Required by a reviewed project document. |
| `DOCS-RESEARCHED` | Supported by current upstream documentation/source, but not run in this project. |
| `EXECUTION-QUALIFIED` | Capability reproduced on the project backend with archived output. |
| `SIMULATED` | Functional simulation produced evidence. |
| `FORMALLY-CHECKED` | Formal tool completed the stated property set under stated assumptions. |
| `SYNTHESISED` | Synthesis completed; no physical implication. |
| `PLACED` | Placement completed. |
| `CTS-IMPLEMENTED` | Clock-tree synthesis completed. |
| `ROUTED` | Detailed routing completed. |
| `TIMING-ANALYSED` | STA report exists for named mode/corner. |
| `TIMING-CLEAN` | Defined timing acceptance criteria pass for all required analyses. |
| `POWER-ESTIMATE-VECTORLESS` | Tool estimate from assumed/probabilistic activity. |
| `POWER-ESTIMATE-VCD` | Tool estimate from VCD activity. |
| `POWER-ESTIMATE-SAIF` | Tool estimate from SAIF activity. |
| `GDS-GENERATED` | GDS artifact was produced. |
| `DRC-CHECKED` / `DRC-CLEAN` | DRC ran / passed defined rule set. |
| `LVS-CHECKED` / `LVS-CLEAN` | LVS ran / passed defined comparison. |
| `FABRICATED` | A foundry manufactured the design. |
| `SILICON-MEASURED` | Result came from physical silicon measurement. |

Do not collapse one state into another.

---

## 3. Current research findings

### 3.1 ORFS / OpenROAD / Yosys / OpenSTA

Current upstream material supports the project concept, but execution remains unqualified.

- ORFS remains an RTL-to-GDS flow using Yosys and OpenROAD, with floorplanning, placement, CTS, routing and finishing stages. Its official tutorial currently uses **ibex on `sky130hd`** and recommends Docker for an efficient setup.
- OpenROAD's UPF utility documents commands for power domains, logic ports, power switches, isolation, interface cells, domain area, switch mapping and domain voltage. This is a **supported subset**, not a basis for claiming full IEEE 1801 coverage.
- The same UPF documentation exposes level-shifter commands, but parts remain incompletely documented. Level shifting is therefore excluded from the MVP.
- OpenROAD DFT documents scan replacement, plan reporting and scan-chain execution. It also states that scan optimization is currently a no-op and that user-defined scan paths and reuse of existing scan ports are not supported.
- A current OpenROAD DFT regression file uses SKY130HD LEF/Liberty, then runs `scan_replace`, `report_dft_plan`, and `execute_dft_plan`. This is upstream feasibility evidence, not project execution evidence.
- OpenSTA documents `report_power`, probabilistic activity with `set_power_activity`, VCD activity with `read_vcd`, and SAIF activity with `read_saif`. These are estimation methods only.
- OpenSTA's current multi-mode support can represent mission and scan modes separately. The project should still keep human-readable `constraints/mission.sdc` and `constraints/scan.sdc`.

### 3.2 SKY130HD

SKY130HD is the primary platform candidate because it has:
- active ORFS platform support and an official ibex tutorial path;
- open timing/LEF/GDS collateral in the ORFS platform;
- scan-capable cells in the standard-cell library;
- documented OpenROAD DFT regression usage;
- SKY130 `lpflow` isolation cells referenced by an OpenROAD UPF regression;
- KLayout DRC/LVS collateral in the ORFS platform;
- a clock-gate technology mapping file in the ORFS platform.

**Critical qualification issue:** the current ORFS `sky130hd/config.mk` explicitly places the `sky130_fd_sc_hd__lpflow_*` multi-power-domain cells, including isolation and level-shifter-related cells, in `DONT_USE_CELLS`. The project must therefore prove a deliberate, controlled way to enable only the required isolation cells without corrupting synthesis/placement/routing assumptions.

### 3.3 Apple Silicon

Upstream code contains macOS paths, but 2026 issues show recent Apple-Silicon build/setup failures. Therefore:
- Apple Silicon is a **developer-host candidate**, not an assumed canonical implementation backend.
- Gate 0 time-boxes a native/container qualification.
- If the complete required smoke-test set does not pass reproducibly, the canonical backend becomes x86-64 Linux.

### 3.4 Optional fabrication

Tiny Tapeout and similar shuttles remain a possible future extension. Fabrication is not part of the project critical path. A CV-ready project must be complete before any paid submission.

---

## 4. Tool/platform feasibility matrix

| Area | Research finding | Project decision | Evidence now | Gate-0 action |
|---|---|---|---|---|
| ORFS RTL-to-GDS | Current upstream flow and SKY130 tutorial exist | Use ORFS as integration flow | `DOCS-RESEARCHED` | Reproduce ibex/SKY130HD smoke flow |
| Yosys | ORFS pins its own Yosys submodule | Use ORFS-pinned Yosys, no independent upgrade | source-researched | Record `yosys -V` |
| OpenROAD/OpenSTA | ORFS pins OpenROAD; OpenSTA is integrated | Use ORFS-pinned OpenROAD | source-researched | Record `openroad -version`; run timing smoke |
| Docker | Officially recommended path | Preferred qualification path | `DOCS-RESEARCHED` | Verify CPU architecture, image/build, mounted results |
| Apple Silicon native | Supported in parts but recent failures exist | Optional convenience backend only until qualified | `DOCS-RESEARCHED` | Time-box complete smoke tests |
| x86-64 Linux | Lowest-risk canonical fallback | Mandatory fallback | planned | Reproduce same hashes and reports |
| `sky130hd` | Mature ORFS path; tutorial, DRC/LVS files, scan and LP collateral | Primary PDK/platform candidate | `DOCS-RESEARCHED` | Pin platform collateral; hash files |
| ASAP7 | Strong implementation research platform but not needed for primary LP proof | Not primary | researched at high level | no action unless SKY130 blocks |
| Nangate45 | Mature tutorial/benchmark platform but weaker relevance to SKY130 LP cells | Fallback debug/reference only | researched at high level | no action unless required |
| GF180/SG13G2 | ORFS supports broader open platforms | Not primary | `DOCS-RESEARCHED` | revisit only if a blocker is proven |
| DRC/LVS | ORFS SKY130 platform includes KLayout collateral | Run as finishing evidence if flow reaches that stage | `DOCS-RESEARCHED` | verify test design checks; never pre-claim pass |
| Power analysis | OpenSTA vectorless, VCD and SAIF activity paths exist | Estimation only | `DOCS-RESEARCHED` | execute one reproducible example |

---

## 5. UPF / DFT capability matrix

| Capability | Upstream state | MVP status | Project rule |
|---|---|---|---|
| Power domains | documented | **Required** | qualify exact syntax and hierarchy |
| Supply/logic ports and domain metadata | documented subset | **Required as needed** | keep file minimal |
| Power switch intent | documented | **Required as intent** | physical switch mapping must be separately proven |
| Physical power-switch cell mapping | command exists; cell availability/mapping not yet proven for chosen platform | **Conditional** | no “real power gating” claim unless mapped/placed/routed |
| Isolation strategy | documented | **Required** | output isolation around switchable domain |
| SKY130 isolation cells | referenced in upstream UPF regression | **Required if qualified** | explicitly override default `dont_use` only for proven cells |
| Domain area | documented | **Required when partitioning physically** | freeze region/floorplan rule |
| Level shifting | partial/incomplete documentation; single-voltage study does not require it | **Deferred** | no MVP claim |
| Retention | not required and not independently proven | **Deferred** | do not add before CV-ready gate |
| DVFS / complex PST | outside narrow supported scope | **Deferred** | no MVP claim |
| Scan replacement | documented | **Required for D** | one-bit supported cells only |
| Scan planning/stitching | documented | **Required for D** | record chains, lengths, ports created |
| Scan optimization/reorder | documented as not implemented | **Out of scope** | do not claim |
| User-defined scan paths | documented limitation | **Out of scope** | do not build scope around them |
| Existing scan port selection | documented limitation | **Out of scope** | accept generated interface or adapt wrapper |
| ATPG/fault coverage | not supplied by this scope | **Out of scope** | never equate scan insertion with coverage |

---

## 6. Configuration-control freeze for bootstrap

The planning package freezes an **exact bootstrap snapshot** so Phase 0 is reproducible. It is not yet an execution-qualified toolchain.

| Item | Bootstrap freeze |
|---|---|
| ORFS | `3a964e13f11a4e435aac01ffa14db0a7d2853720` |
| OpenROAD submodule at that ORFS revision | `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca` |
| Yosys submodule at that ORFS revision | `a5af9d690a43744bf6b2cc3dea2717c16b54621c` |
| Yosys release represented by that pin | `0.68` |
| KLayout dependency target in that ORFS snapshot | `0.30.12` |
| Platform | `sky130hd` |
| Standard-cell library | `sky130_fd_sc_hd` |
| Nominal Liberty used by platform | `sky130_fd_sc_hd__tt_025C_1v80.lib` |
| Platform collateral | exactly the files under `flow/platforms/sky130hd/` at the frozen ORFS revision |
| Canonical fallback OS/ISA | Ubuntu 22.04 x86-64 |
| Source control policy | no silent upgrade after Gate 0 |

Gate 0 must record actual runtime version strings and SHA-256 hashes of critical platform collateral. If the snapshot fails a mandatory capability, changing it requires a decision record and a full Gate-0 rerun.

---

## 7. Backend decision tree

1. Inventory the user's exact Apple-Silicon Mac: model/ISA, macOS version, RAM, disk free space, Docker/OrbStack/Colima availability.
2. Attempt the **same frozen snapshot** through the least fragile documented local path.
3. The Mac path passes only if it can reproduce:
   - the official ibex/SKY130HD flow to the chosen Gate-0 stopping point;
   - required OpenROAD UPF commands/regression;
   - SKY130 isolation-cell experiment;
   - DFT scan regression;
   - static timing report;
   - a power-estimation smoke test.
4. If any required item fails for platform reasons, stop debugging after the Phase-0 time budget and move to Ubuntu 22.04 x86-64.
5. Freeze exactly one canonical backend before Gate 1. A Mac may remain a convenience frontend even when Linux is canonical.

A backend is selected for reproducibility, not prestige.

---

## 8. Input RTL selection gate

Do not create a new large accelerator. Select one existing original portfolio block only after evidence is available.

### Required evidence for selection

The candidate must have:
- a repository and immutable source commit;
- original authorship or clear attribution;
- stable top-level interface;
- independent functional regression evidence at that commit;
- clean synthesis capability;
- no unresolved functional correctness issue;
- enough sequential/combinational logic to make placement, CTS and scan meaningful;
- short enough runtime for repeated A/B/C/D experiments;
- a transaction boundary that supports a meaningful quiesce protocol.

### Preferred selection attributes

Prefer a block with:
- one principal mission clock;
- explicit valid/ready or request/response semantics;
- a bounded definition of “in flight”;
- no dependence on proprietary memories or hard macros;
- state that may safely be lost on power-off, avoiding retention in the MVP.

### Gate output

`docs/DECISIONS.md` must record:
- candidates considered;
- source repository and commit;
- regression command and evidence;
- chosen top and wrapper boundary;
- why the block is large enough and repeatable enough.

No low-power modification begins before this gate and Gate 2 baseline requirements are satisfied.

---

## 9. Proposed architecture

### Always-on domain `PD_AON`

Contains:
- PMU/power-state controller;
- sleep/wake request synchronisation if required;
- configuration/status;
- accepted-transaction accounting needed for quiescence;
- safe interface logic that must remain valid while compute is unavailable;
- isolation control;
- switch/clock-gate control.

### Switchable domain `PD_SW`

Contains:
- selected verified compute/fabric IP;
- local non-retained state allowed to be lost during true power-off;
- optional technology wrapper required for clean domain boundary.

### Domain policy

The MVP is one always-on domain plus one switchable domain. No third domain is added unless a specific engineering hypothesis requires it.

The initial study is single-voltage. Therefore level shifters are not required.

---

## 10. Power-state machine contract

The exact encoding is an implementation decision, but the observable semantics are fixed.

| State | New work accepted? | Clock | Isolation | Switch intent | Key exit condition |
|---|---:|---|---|---|---|
| `ACTIVE` | yes | running | deasserted | on | sleep request |
| `QUIESCE` | no | running | deasserted | on | in-flight count reaches zero |
| `CLOCK_GATED` | no | gated | deasserted initially | on | sequencing guard complete |
| `ISOLATE` | no | gated | asserted | on | isolation observed/stable |
| `POWER_OFF` | no | gated | asserted | off | wake request |
| `POWER_ON_WAIT` | no | gated | asserted | on request | documented power-on wait/ack |
| `DEISOLATE` | no | gated/running as defined | deassert only when safe | on | restart/reset complete |
| `ACTIVE` | yes | running | deasserted | on | normal operation |

### Mandatory semantics

- Once quiesce begins, no new transaction is accepted.
- Every transaction accepted before quiesce either completes before shutdown or is handled by a deliberately specified abort/error protocol. The MVP should prefer drain-to-completion.
- Clock gating occurs only after all required work has drained.
- Isolation is asserted before switch-off intent.
- Isolation remains asserted through power-off and initial wake.
- Isolation is removed only after the switchable domain has a valid reset/restart state.
- Reset behavior is specified for every PMU state.
- A stuck in-flight transaction must have a documented timeout/error policy; timeout must not silently discard accepted work.
- If no physically meaningful power-switch implementation exists, the RTL/UPF model may still exercise sequencing, but the project must label the switch as **intent/abstraction**, not a physically inserted switch network.

### Initial timeout policy

Before RTL implementation, `docs/MICROARCHITECTURE.md` must choose one:
1. no timeout, requiring environment fairness that all accepted operations complete; or
2. a timeout that enters an explicit `ERROR_SAFE` state with isolation/power kept safe.

Do not implement a timeout that silently forces power-off.

---

## 11. Clock-gating methodology

Clock gating is Configuration B's sole intended transformation relative to A.

Preferred method:
- keep the selected functional IP source unchanged;
- add a controlled wrapper/gating intent;
- use the ORFS/Yosys technology clock-gate mapping path;
- verify the exact mapped integrated clock-gating cell in synthesis output;
- provide a test/scan bypass path if required by Configuration D.

Phase 0 / Gate 1 must confirm:
- the exact mapped cell;
- polarity and test-enable semantics;
- whether the flow infers or technology-maps the ICG;
- generated/gated clock representation in STA;
- CTS treatment.

Functional tests must show that disabled cycles do not corrupt state and that wake/re-enable resumes correctly.

No claim of power reduction is made from cell count alone.

---

## 12. SDC contract

This project treats constraints as reviewed engineering artifacts.

Required files:
- `constraints/mission.sdc`
- `constraints/scan.sdc`

Every clock, I/O delay, clock group, false path, multicycle path and mode exception must have a rationale in `docs/TIMING.md`.

### Mission mode

Must define, where applicable:
- primary mission clock;
- real generated/gated clock relation if the implementation creates one;
- input/output delays representing an explicit interface assumption;
- clock uncertainty;
- reset/test/config timing policy;
- no blanket false paths.

### Scan mode

Must define:
- scan shift clock or mode;
- scan-enable case analysis if required;
- scan input/output timing;
- mission-clock behavior during shift;
- only architecture-justified exceptions.

### Fair comparison

The **mission-mode** clock target and I/O assumptions are frozen after baseline qualification and used for A/B/C/D mission QoR. Configuration D's scan-shift timing is a separate result and must not be mixed with mission WNS/TNS.

If OpenSTA's multi-mode feature is adopted, the two human-reviewed SDC files remain separate and are loaded as distinct modes.

---

## 13. DFT contract

Configuration D adds only the DFT scope that the chosen OpenROAD version can demonstrate.

Required:
- scan-capable flop replacement;
- scan configuration;
- scan plan report;
- scan-chain stitching;
- scan enable and generated scan I/O as supported;
- post-scan structural report;
- functional mission-mode re-verification;
- post-scan physical implementation;
- chain count and length reporting;
- area/timing/placement overhead.

Not claimed unless an independent future tool is deliberately added:
- ATPG;
- stuck-at coverage;
- transition coverage;
- scan compression;
- production DFT sign-off.

Known OpenROAD limitations are part of the report, not hidden defects in the portfolio.

---

## 14. UPF contract

The MVP uses only the exact subset that Gate 0 demonstrates.

Required candidate concepts:
- `PD_AON` and `PD_SW`;
- domain elements;
- isolation strategy for switchable-domain outputs;
- isolation control;
- approved isolation interface cells;
- domain physical area;
- power-switch intent and control;
- domain voltage metadata only if useful.

Conditional:
- physical switch mapping.

Deferred:
- level shifters;
- retention;
- DVFS;
- complex power-state tables;
- multiple switchable islands;
- claims of broad IEEE 1801 portability.

All public wording should say **“supported OpenROAD UPF subset”**.

---

## 15. Functional and formal verification

### Imported baseline

Before physical work, re-run the source project's known-good regression at the exact imported commit. Archive command, environment and summary.

### Low-power functional scenarios

At minimum:
- sleep while idle;
- sleep with one or more operations in flight;
- block new requests during quiesce;
- normal power-off and wake;
- repeated sleep/wake;
- reset in every PMU state;
- clock-gate disable/enable boundaries;
- isolation output behavior;
- configuration races;
- illegal/unsupported request handling;
- timeout/error behavior if implemented.

Where the open flow cannot simulate real power collapse, use an RTL-level power-state abstraction. State explicitly that this is sequencing verification, not transistor-level power simulation.

### Formal properties

Target the PMU and interface contract, not physical UPF:
- `power_off -> isolation_asserted`;
- quiesce prevents new accepts;
- shutdown is unreachable while `in_flight != 0`;
- clock gate is not asserted before quiescence;
- isolation deassertion is impossible before wake/reset conditions;
- no response is emitted from an invalid/off switchable domain;
- only legal state transitions occur;
- eventual return to `ACTIVE` under documented wake/power-good/fairness assumptions.

Record assumptions and boundedness. `FORMALLY-CHECKED` PMU control does not imply the physical power-domain implementation is correct.

---

## 16. Controlled A/B/C/D experiment

### A — conventional baseline

- selected verified IP;
- single power domain;
- normal mission clock;
- no scan;
- no low-power isolation/switch infrastructure.

### B — clock gated

- A plus controlled ICG/clock-gating implementation;
- no power-domain split;
- no scan.

### C — power domain

- B plus `PD_AON` / `PD_SW`;
- PMU/quiescence;
- supported isolation;
- domain area;
- power-switch intent;
- actual physical switch cells only if Gate 0 proves them.

### D — power domain + scan

- C plus supported scan replacement/planning/stitching;
- mission and scan analyses separated.

### Intentional changes

The selected **functional IP commit is identical** in A/B/C/D. Wrapper/PMU/UPF/scan transformations are the independent variables. They must be enumerated per configuration.

### Primary fairness controls

Freeze before A/B/C/D comparison:
- ORFS/OpenROAD/Yosys snapshot;
- platform/library;
- functional IP commit;
- top-level interface boundary;
- mission clock target;
- I/O delay assumptions;
- uncertainty;
- synthesis strategy except the intended transformation;
- fixed die/core geometry for the primary comparison;
- pin-placement strategy;
- PDN baseline where technically applicable;
- routing layer policy;
- placement/CTS/routing knobs;
- random seed when controllable;
- report parsers.

**Primary physical comparison uses fixed die/core geometry.** Standard-cell area and actual utilization then reveal overhead naturally. If a configuration becomes infeasible because overhead exceeds capacity, run a separately labelled **capacity-rescue** experiment with expanded core area. Do not silently mix rescue results into the primary table.

---

## 17. Metrics

Collect machine-readable values for every configuration and stage where available:

### Structure
- standard-cell area;
- total cell count;
- sequential count;
- ICG count;
- isolation-cell count;
- physical switch count, only when real cells are inserted;
- scan flop count;
- scan chain count;
- max/mean chain length.

### Physical
- die/core area;
- actual utilization;
- placement density;
- total wirelength;
- routed wirelength where reported;
- congestion metrics;
- clock-buffer count;
- clock-tree wirelength;
- clock latency/skew;
- route violations.

### Timing
- WNS;
- TNS;
- violating endpoint count if available;
- critical path startpoint/endpoint/type;
- setup and hold separately;
- mission and scan mode separately.

### Physical verification
- GDS artifact existence;
- DRC check command/result;
- LVS check command/result.

Never infer `DRC-CLEAN` or `LVS-CLEAN` from successful routing.

### Power
Use only after methodology qualification:
- leakage;
- internal;
- switching;
- total;
- activity source and time window;
- whether report is vectorless, VCD or SAIF;
- clock-network contribution if the tool can isolate it reproducibly.

Power remains an estimate. A result is not “measured power”.

---

## 18. Hypotheses registered before implementation

H1. Clock gating may increase cell area and clock-path complexity even if it later reduces switching activity.

H2. Power-domain isolation and physical partitioning may increase cell area, wirelength or congestion.

H3. Scan replacement/stitching may alter cell area, placement and mission-mode timing.

H4. A fixed-core implementation may expose congestion or timing sensitivity that a variable-area comparison would hide.

H5. The critical path may move between A/B/C/D.

H6. A vectorless power estimate may not reliably represent the relative dynamic-power effect of gating; activity-based estimates may differ materially.

Each hypothesis ends as `RETAIN`, `MODIFY`, `REJECT`, or `INCONCLUSIVE`, with evidence.

---

## 19. Gate plan

### Gate 0 — backend and capability qualification

Must prove with archived output:
- exact host/backend;
- ORFS/OpenROAD/Yosys/KLayout versions and commit pins;
- platform hashes;
- known reference design flow;
- required UPF commands;
- SKY130 isolation-cell handling;
- physical switch mapping status;
- DFT scan commands;
- power-report path;
- reproducible rerun.

No portfolio RTL modification.

### Gate 1 — engineering contract frozen

Must freeze:
- selected IP or explicit selection evidence;
- domain boundary;
- PMU semantics;
- clock-gating method;
- supported UPF subset;
- mission and scan SDC intent;
- DFT scope;
- metrics;
- A/B/C/D fairness controls;
- simulation/formal strategy.

### Gate 2 — conventional ASIC baseline

Must show:
- source regression passes at imported commit;
- A synthesises and physically implements to the agreed stage;
- baseline reports are reproducible;
- no low-power optimization has yet contaminated the baseline.

### Gate 3 — low-power behavior verified

Must show:
- PMU RTL;
- quiesce;
- clock-gating behavior;
- isolation control abstraction;
- sleep/wake tests;
- formal property evidence.

### Gate 4 — physical engineering depth

Must show, as independently classified evidence:
- B implementation;
- C implementation;
- D scan implementation;
- mission-mode comparisons;
- scan-mode report;
- controlled physical overhead analysis;
- power estimates only if qualified.

### Gate 5 — public/CV-ready

Must contain:
- original architecture/power-sequence diagrams;
- reviewed SDC;
- reviewed supported-subset UPF;
- DFT method and limitations;
- implementation screenshots generated by the project;
- tables sourced from machine-readable results;
- exact reproduction commands;
- evidence index;
- known limitations;
- third-party notices;
- clean reproduction on the canonical backend.

### Gate 6 — optional fabrication

Only after Gate 5. Submitted GDS, accepted shuttle submission, returned silicon and measured silicon are separate evidence states.

---

## 20. Repository structure

```text
Power-to-GDS/
├── 00_MASTER_PROJECT_PLAN.md
├── 01_CHATGPT_PROJECT_OPERATING_INSTRUCTIONS.md
├── 02_PHASE0_BOOTSTRAP_TASK.md
├── 03_START_NEW_CHATGPT_PROJECT.md
├── 04_MASTER_CHECKLIST.md
├── MASTER_CHATGPT_HANDOFF_PROMPT.md
├── docs/
│   ├── REQUIREMENTS.md
│   ├── MICROARCHITECTURE.md
│   ├── POWER_INTENT.md
│   ├── VERIFICATION_PLAN.md
│   ├── FORMAL.md
│   ├── TIMING.md
│   ├── DFT.md
│   ├── TRADEOFFS.md
│   ├── DECISIONS.md
│   ├── PROJECT_STATE.md
│   ├── EVIDENCE_INDEX.md
│   ├── KNOWN_LIMITATIONS.md
│   ├── THIRD_PARTY_MANIFEST.md
│   └── THIRD_PARTY_NOTICES.md
├── constraints/
│   ├── mission.sdc
│   └── scan.sdc
├── upf/
├── rtl/
├── formal/
├── sim/
├── flow/
├── scripts/
├── tasks/
│   └── POWER-xxx.md
├── results/
│   ├── raw/
│   └── processed/
└── AGENTS.md
```

`results/raw/` is append-only evidence. `results/processed/` contains concise, reproducible extracts and tables.

---

## 21. Initial adversarial review

| Severity | Finding | Why it matters | Resolution |
|---|---|---|---|
| **BLOCKER until Gate 0** | No complete project toolchain has been executed yet | all feasibility is currently documentary | Phase 0 is mandatory |
| **BLOCKER until Gate 0** | SKY130 LP cells are default `dont_use` in ORFS | isolation may not drop into a normal flow automatically | explicit isolation-cell qualification |
| **BLOCKER for physical switch claim** | Mappable physical power-switch cell has not been established | UPF switch intent is not the same as a routed power-switch network | separate pass/fail switch-mapping experiment |
| **BLOCKER until IP gate** | source portfolio RTL is not yet selected | cannot define exact quiesce or timing interface | objective IP-selection gate |
| **MAJOR** | recent Apple-Silicon setup/build issues exist | local setup may absorb project time | strict time-box and x86-64 fallback |
| **MAJOR** | current OpenROAD DFT is deliberately limited | could tempt exaggerated scan claims | scope only to supported scan replacement/plan/stitch |
| **MAJOR** | scan and mission constraints can be accidentally mixed | invalid timing comparisons | separate SDC/mode reports |
| **MAJOR** | power estimate can be mislabeled as measured | destroys evidence credibility | mandatory power evidence tags |
| **MAJOR** | changing floorplan to fit later variants can bias A/B/C/D | confounds overhead | fixed-core primary experiment + separate rescue |
| **MINOR** | level-shifter support is not needed for a same-voltage MVP | unnecessary risk | deferred |
| **MINOR** | retention/DVFS would expand verification state space | scope dilution | deferred |
| **ACCEPTABLE RISK** | a low-power variant may fail physically | failed controlled experiment can still be valuable evidence | retain evidence and classify result |

### Changes made because of the review

1. Made the project **READY WITH PHASE-0 CONDITIONS**, not unconditionally ready.
2. Froze an exact bootstrap ORFS/submodule snapshot rather than “latest”.
3. Added explicit LP-cell `dont_use` qualification.
4. Split **power-switch intent** from **physically inserted switch cells**.
5. Removed level shifting, retention, DVFS and complex PSTs from MVP.
6. Reduced DFT scope to what current OpenROAD documents.
7. Required mission and scan timing to be reported separately.
8. Added fixed-core primary comparison plus separately labelled capacity rescue.
9. Made all power numbers explicitly estimated by activity source.
10. Kept fabrication outside the CV-ready path.

---

## 22. Open decisions

These are intentionally not guessed during planning:

1. exact source portfolio IP and commit;
2. exact Apple-Silicon host model/macOS/resources;
3. whether Mac can be canonical or only a frontend;
4. exact clock period and I/O assumptions, to be frozen after baseline feasibility work;
5. exact quiesce accounting mechanism for chosen IP;
6. timeout vs fairness-only shutdown policy;
7. exact SKY130 ICG cell produced by synthesis mapping;
8. exact supported isolation-cell override needed in ORFS;
9. whether a real SKY130 physical power-switch cell can be mapped and routed in the frozen flow;
10. scan chain target length/count for the chosen design;
11. whether VCD or SAIF activity is the preferred primary dynamic-power estimate.

---

## 23. Next smallest engineering task

Execute `02_PHASE0_BOOTSTRAP_TASK.md`.

Do not modify portfolio RTL. Do not draft final UPF for the portfolio block. Do not add scan to the portfolio block. First turn documentary feasibility into execution evidence.

---

## 24. Research sources used for this planning snapshot

Primary/current sources checked on 2026-09-20:

- OpenROAD UPF Utility: https://openroad.readthedocs.io/en/latest/main/src/upf/README.html
- OpenROAD DFT: https://openroad.readthedocs.io/en/latest/main/src/dft/README.html
- OpenSTA examples/power: https://openroad.readthedocs.io/en/latest/main/src/sta/doc/Examples.html
- OpenSTA release notes: https://openroad.readthedocs.io/en/latest/main/src/sta/doc/ChangeLog.html
- ORFS repository: https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts
- ORFS Flow Tutorial: https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/blob/master/docs/tutorials/FlowTutorial.md
- ORFS Docker build: https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/blob/master/docs/user/BuildWithDocker.md
- ORFS SKY130HD platform config: https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/blob/3a964e13f11a4e435aac01ffa14db0a7d2853720/flow/platforms/sky130hd/config.mk
- OpenROAD SKY130 DFT regression: https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/src/dft/test/sub_modules_sky130.tcl
- OpenROAD multi-power-domain UPF test: https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/test/upf/mpd_aes.upf
- 2026 Arm Mac OpenROAD issue: https://github.com/The-OpenROAD-Project/OpenROAD/issues/9529
- 2026 ORFS macOS issue: https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/issues/4022
- Frozen ORFS commit: https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/commit/3a964e13f11a4e435aac01ffa14db0a7d2853720
- Frozen OpenROAD commit: https://github.com/The-OpenROAD-Project/OpenROAD/commit/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca
- Frozen Yosys commit: https://github.com/The-OpenROAD-Project/yosys/commit/a5af9d690a43744bf6b2cc3dea2717c16b54621c

### Reference-document availability note

The planning brief requested direct review of previously supplied “RTL-to-Pixels” and earlier CPU/summer-project planning documents. Those named planning documents were not accessible in the conversation/project file index or in the allowed Library search during this planning pass. This package therefore preserves the authority hierarchy, evidence discipline, baseline preservation, gate model, controlled comparison and reproducibility requirements explicitly supplied in the Power-to-GDS brief, but it does **not** claim a line-by-line comparison against unavailable reference documents.
