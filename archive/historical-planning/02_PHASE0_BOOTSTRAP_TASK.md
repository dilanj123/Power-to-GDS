# Power-to-GDS
## 02 — Phase-0 Bootstrap Task

**Task ID:** `POWER-000`  
**Objective:** qualify the implementation backend and the narrow OpenROAD/ORFS capabilities required by the project.  
**Prohibition:** do **not** modify portfolio RTL in Phase 0.

---

## 1. Acceptance criterion

Gate 0 closes only when a fresh engineer can start from the recorded environment instructions and reproduce the required smoke tests with the same pinned source revisions.

This task converts current `DOCS-RESEARCHED` feasibility into `EXECUTION-QUALIFIED` evidence.

---

## 2. Frozen bootstrap inputs

Use initially:

```text
ORFS     3a964e13f11a4e435aac01ffa14db0a7d2853720
OpenROAD 4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca
Yosys    a5af9d690a43744bf6b2cc3dea2717c16b54621c  # release 0.68
Platform sky130hd
Library  sky130_fd_sc_hd
Liberty  sky130_fd_sc_hd__tt_025C_1v80.lib
```

Do not pull/update after checkout.

If any mandatory capability is impossible on this snapshot, stop and write a decision proposal before trying another revision.

---

## 3. Phase-0 outputs

Create:

```text
results/raw/phase0/
  host/
  versions/
  ibex_sky130hd/
  upf/
  dft/
  low_power_cells/
  power/
  drc_lvs/
results/processed/phase0/
  host_summary.md
  toolchain_manifest.json
  platform_hashes.sha256
  ibex_summary.json
  upf_summary.md
  dft_summary.md
  low_power_cell_summary.md
  power_summary.md
  backend_decision.md
docs/DECISIONS.md
docs/PROJECT_STATE.md
docs/EVIDENCE_INDEX.md
```

Raw logs are never rewritten to make them look cleaner.

---

## 4. P0.1 — Host inventory

Record:
- Mac model and CPU/ISA;
- macOS version;
- RAM;
- free disk;
- available container runtime and version;
- Docker architecture/emulation settings;
- shell;
- Git version.

Acceptance:
- `results/processed/phase0/host_summary.md` contains exact values and commands used.

No inference from “Apple Silicon” is sufficient.

---

## 5. P0.2 — Pin and verify source tree

Suggested source-control sequence:

```bash
git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts.git
cd OpenROAD-flow-scripts
git checkout 3a964e13f11a4e435aac01ffa14db0a7d2853720
git submodule update --init --recursive
git rev-parse HEAD
git submodule status
```

Verify that the OpenROAD and Yosys submodule SHAs match the bootstrap manifest.

Inside the qualified environment, record at least:

```bash
openroad -version || openroad -help
yosys -V
klayout -v
python3 --version
```

Archive command output.

Acceptance:
- exact source SHAs match;
- executable versions are recorded;
- no untracked patch is required to make the tools run, or every patch is separately documented.

---

## 6. P0.3 — Conventional ORFS smoke flow

Use the official ORFS tutorial reference path: **ibex / sky130hd**.

From `flow/`, use the pinned repository's documented invocation. At the current tutorial shape this is based on:

```bash
make DESIGN_CONFIG=./designs/sky130hd/ibex/config.mk
```

Do not assume success from an existing cached result.

Record:
- elapsed time;
- peak memory if available;
- disk footprint before/after;
- synthesis, floorplan, placement, CTS, route and finish return status;
- WNS/TNS reports;
- final cell area/count;
- route/DRC/LVS report presence;
- whether a GDS artifact is produced.

Important:
- artifact existence is not DRC/LVS cleanliness;
- “flow completed” is not “timing clean” unless acceptance criteria prove timing;
- this reference run is tool qualification, not portfolio evidence.

Acceptance:
- same frozen snapshot can be rerun from a clean results directory;
- processed summary is generated from reports, not hand-typed values.

---

## 7. P0.4 — UPF command/regression qualification

On the frozen OpenROAD revision, verify help/syntax for the project-needed commands, including:

```text
read_upf
create_power_domain
create_logic_port
create_power_switch
set_isolation
use_interface_cell
set_domain_area
map_power_switch
set_domain_voltage
```

Run the upstream UPF regression or the smallest reproducible upstream example that demonstrates:
- multiple domains;
- switch intent;
- isolation;
- SKY130 isolation cells if the regression uses them.

Archive:
- command line;
- UPF file;
- stdout/stderr;
- output netlist/database/report;
- return code.

Acceptance:
- commands execute on the frozen binary;
- isolation strategy can be read/represented;
- no unsupported level-shifter or retention feature is required.

Fail condition:
- if isolation strategy is parsed but cannot be materialized as cells in a useful physical flow, record capability as **intent-only** and do not close the low-power-cell subtest.

---

## 8. P0.5 — SKY130 isolation-cell qualification

This is mandatory because frozen `sky130hd/config.mk` places `sky130_fd_sc_hd__lpflow_*` cells in `DONT_USE_CELLS`.

Design a tiny throwaway test, not portfolio RTL, with:
- parent/AON logic;
- switchable child;
- one or more crossing outputs;
- isolation strategy;
- only the exact isolation cells required by the UPF regression.

Prove:
1. required cell Liberty/LEF/GDS views exist;
2. the chosen ORFS override does not globally enable unrelated LP cells;
3. OpenROAD inserts/uses the intended isolation cell;
4. placement succeeds;
5. routing succeeds far enough to validate connectivity;
6. timing reads the cells;
7. physical checks do not fail for a known structural reason.

Record the exact override. Never edit the global platform file in-place for an experiment.

Acceptance:
- one clean, scripted reproduction identifies isolation cells by instance and master name.

If this fails:
- classify physical isolation insertion as a **Gate-0 blocker**;
- do not move to portfolio Configuration C until resolved or the project scope is formally changed.

---

## 9. P0.6 — Physical power-switch qualification

Separate UPF switch intent from actual switch cells.

Investigate the frozen SKY130HD collateral for a suitable, characterized, physically usable switch cell and test `map_power_switch` only if such a cell is supported.

Pass:
- switch intent maps to a real cell/macro with required views;
- physical implementation is reproducible;
- supply connectivity is inspectable.

Conditional pass:
- UPF switch object/controls work, but no credible physical switch cell can be mapped. In this case:
  - keep switch behavior as **intent/abstraction**;
  - project may continue with domain partitioning + isolation;
  - no “physical power gating” or switch-count claim.

Do not invent a switch cell from an ordinary logic gate.

---

## 10. P0.7 — DFT qualification

Use the frozen OpenROAD SKY130 DFT regression path as the first proof.

The pinned upstream regression script reads SKY130HD LEF/Liberty and executes:

```text
scan_replace
report_dft_plan -verbose
execute_dft_plan
```

Run the official regression mechanism from the frozen tree and archive:
- before/after flop counts;
- scan cell masters;
- chain count;
- chain lengths;
- scan ports;
- output netlist;
- any warnings/limitations.

Confirm the frozen tool's documented limitations:
- no scan optimization;
- no user-defined scan path;
- no supported selection of pre-existing scan ports;
- one-bit cell scope.

Acceptance:
- scan replacement and stitching execute on a SKY130 test;
- generated netlist is readable back into the tool;
- limitation list is captured.

Do not perform portfolio scan insertion yet.

---

## 11. P0.8 — Power-estimation qualification

Run at least one frozen-tool example for each method intended for the project:

### Required
- vectorless/probabilistic activity + `report_power`;
- VCD activity + `read_vcd` + `report_power`.

### Optional but preferred
- SAIF + `read_saif` + `report_power`.

Record:
- Liberty;
- SPEF presence;
- design/netlist stage;
- activity source;
- VCD/SAIF scope and time range;
- internal/switching/leakage/total report fields.

Acceptance:
- one repeatable report per adopted activity method;
- `power_summary.md` explicitly labels every number as an estimate.

If SAIF integration is awkward, VCD remains sufficient for the MVP; do not spend disproportionate Phase-0 time on it.

---

## 12. P0.9 — DRC/LVS path qualification

For the known ORFS reference design:
- identify the exact KLayout DRC command/report;
- identify the exact KLayout LVS command/report;
- confirm whether the normal flow runs them automatically or requires an explicit target;
- archive the actual result.

This proves only the reference flow. It does not pre-certify the portfolio design.

---

## 13. P0.10 — Backend decision

### Mac passes

The Mac path may become canonical only if all mandatory P0.2–P0.9 tests pass reproducibly on the same architecture without fragile manual repair.

Record:
- container/native mode;
- architecture;
- any emulation;
- exact launch command.

### Mac fails or becomes a time sink

Move to:
- Ubuntu 22.04 x86-64;
- the same frozen source SHAs;
- Docker or source build using upstream-documented method.

Repeat mandatory qualification on the final canonical backend. A partial Mac pass is not enough.

---

## 14. Gate-0 closure checklist

Gate 0 is **PASS** only when all are true:

- [ ] exact host recorded;
- [ ] ORFS SHA recorded and clean;
- [ ] OpenROAD SHA recorded;
- [ ] Yosys SHA/version recorded;
- [ ] KLayout version recorded;
- [ ] SKY130HD platform hashes recorded;
- [ ] ibex/SKY130HD reference flow reproduced;
- [ ] timing report collected;
- [ ] required UPF commands executed;
- [ ] SKY130 isolation cells physically qualified;
- [ ] physical switch status explicitly PASS / INTENT-ONLY / BLOCKED;
- [ ] DFT scan regression reproduced;
- [ ] power-estimation method reproduced;
- [ ] DRC/LVS path characterized;
- [ ] canonical backend selected;
- [ ] clean rerun instructions recorded;
- [ ] `docs/PROJECT_STATE.md` updated with facts only;
- [ ] `docs/EVIDENCE_INDEX.md` points to raw evidence.

No portfolio RTL modification occurs before this checklist is reviewed.

---

## 15. Gate-0 stop conditions

Stop and escalate rather than improvising if:
- the pinned ORFS snapshot cannot build/run on both candidate backends;
- required isolation cells lack a complete physical/timing view;
- enabling isolation requires broad uncontrolled platform edits;
- UPF syntax exists but does not materially affect implementation;
- DFT output is structurally unusable;
- project disk/runtime becomes unreasonable for repeated A/B/C/D experiments.

A blocker should produce a small decision document, not an unbounded debugging session.

---

## 16. Phase-0 final report format

Return:

1. **Backend chosen**
2. **Exact tool/PDK/library pins**
3. **Reference flow evidence**
4. **UPF capability evidence**
5. **Isolation-cell evidence**
6. **Physical switch status**
7. **DFT capability evidence**
8. **Power-estimation evidence**
9. **DRC/LVS path evidence**
10. **Remaining blockers**
11. **Gate-0 verdict**
12. **Next smallest task**

Allowed verdicts:
- `GATE 0 PASS`
- `GATE 0 PASS WITH DECLARED SWITCH-INTENT LIMITATION`
- `GATE 0 FAIL`
