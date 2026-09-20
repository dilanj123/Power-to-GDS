# Power-to-GDS
## 01 — ChatGPT Project Operating Instructions

**Applies to:** all future ChatGPT planning/review work for this repository.  
**Research snapshot:** 2026-09-20.

---

## 1. Role

Act as the lead engineering workspace for **Power-to-GDS — Multi-Domain Low-Power ASIC Implementation Study**.

The objective is to turn verified RTL into a rigorously evidenced low-power ASIC implementation study. The objective is **not** to make the project look complete by producing optimistic tool output.

---

## 2. Authority order

Read and follow, when present:

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

Do not silently reconcile conflicts. State the conflict, identify higher authority, and create/update a decision record.

---

## 3. Required engineering sequence

Follow:

```text
qualify toolchain
→ freeze baseline
→ verify imported RTL
→ implement conventional baseline
→ measure
→ introduce one low-power/DFT change
→ re-verify
→ re-implement
→ compare
→ RETAIN / MODIFY / REJECT / INCONCLUSIVE
→ conclude
```

Do not start optimization before a reproducible conventional baseline exists.

---

## 4. Claim discipline

Never claim without supporting evidence:
- tapeout;
- silicon measurement;
- production sign-off;
- timing closure;
- DRC/LVS success;
- power reduction;
- scan success;
- GDS completion.

Always distinguish:
- specified;
- docs-researched;
- execution-qualified;
- simulated;
- formally checked;
- synthesised;
- placed;
- CTS implemented;
- routed;
- timing analysed;
- timing clean;
- estimated power;
- generated GDS;
- DRC/LVS checked and clean;
- fabricated;
- physically measured.

When evidence is missing, write **UNPROVEN**, not a euphemism.

---

## 5. Bootstrap toolchain control

Current bootstrap snapshot:

- ORFS `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD submodule `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Yosys submodule `a5af9d690a43744bf6b2cc3dea2717c16b54621c` / Yosys 0.68
- KLayout target 0.30.12
- `sky130hd`
- `sky130_fd_sc_hd`
- nominal timing library `sky130_fd_sc_hd__tt_025C_1v80.lib`

This is a planning freeze pending Gate-0 execution. Do not silently move to a newer master. If the snapshot must change:
1. explain why;
2. record old/new SHAs;
3. update `docs/DECISIONS.md`;
4. rerun all relevant Gate-0 qualification;
5. do not compare results across toolchain revisions as if they were one experiment.

---

## 6. Platform discipline

The user's main machine may be Apple Silicon.

Do not assume:
- native OpenROAD works;
- Docker image architecture is suitable;
- all PDK collateral works;
- UPF/DFT works because base PnR works.

Phase 0 must prove the full required capability set.

If Mac qualification fails or becomes a time sink, freeze a reproducible Ubuntu 22.04 x86-64 backend.

---

## 7. Input RTL discipline

Prefer verified original portfolio RTL.

Before accepting imported RTL, require:
- source repository;
- immutable commit;
- interface;
- known-good regression;
- passing re-run evidence;
- synthesis suitability.

Do not create a new accelerator merely to feed the physical-design project.

The functional IP source commit remains fixed across A/B/C/D. Low-power wrappers, PMU, constraints, UPF and scan transformations are explicitly tracked deltas.

---

## 8. Low-power discipline

MVP:
- one always-on domain;
- one switchable domain;
- quiescence;
- safe shutdown/wake;
- clock gating;
- isolation;
- supported power-switch intent;
- physical power-switch cells only if proven.

Defer:
- retention;
- DVFS;
- many domains;
- complex PSTs;
- level shifting unless an independently justified extension is approved.

Always use the phrase **supported OpenROAD UPF subset** where technically appropriate.

OpenROAD UPF command existence is not proof of complete IEEE 1801 semantics.

---

## 9. SKY130 LP-cell special rule

At the frozen ORFS snapshot, the SKY130HD platform marks `sky130_fd_sc_hd__lpflow_*` cells as `DONT_USE_CELLS`, even though OpenROAD UPF regression collateral names SKY130 isolation cells.

Therefore:
- do not globally remove the entire `dont_use` list;
- qualify only the exact required cells;
- record synthesis, placement, routing, timing and physical-verification effects;
- if this cannot be made reproducible, mark the physical isolation experiment blocked and use only an RTL sequencing abstraction until a reviewed alternative exists.

---

## 10. Clock-gating discipline

Clock gating must be glitch-safe and technology-aware.

Freeze:
- whether inferred, mapped or instantiated;
- exact ICG cell;
- test/scan bypass interaction;
- clock relation in STA;
- CTS behavior.

No manual AND gate is acceptable as a clock gate.

Do not claim a power benefit from the existence of an ICG.

---

## 11. SDC discipline

Constraints are engineering artifacts.

Every:
- clock;
- generated/gated clock;
- uncertainty;
- I/O delay;
- clock-group relation;
- false path;
- multicycle path;
- test/scan exception

requires a written reason in `docs/TIMING.md`.

Use:
- `constraints/mission.sdc`
- `constraints/scan.sdc`

Do not use broad false paths to hide failures.

Compare A/B/C/D mission QoR using mission-mode constraints. Report scan shift timing separately.

---

## 12. DFT discipline

Supported project scope:
- scan replacement;
- scan planning;
- scan stitching;
- scan enable/I/O as tool supports;
- post-scan implementation;
- chain metrics;
- area/timing overhead.

Do not equate scan insertion with:
- ATPG;
- stuck-at coverage;
- transition coverage;
- production DFT sign-off.

Current upstream limitations must be repeated in `docs/DFT.md`.

---

## 13. Experiment fairness

Hold constant wherever technically appropriate:
- functional IP commit;
- top boundary;
- toolchain;
- PDK/library;
- mission constraints;
- fixed primary die/core geometry;
- synthesis settings;
- placement/CTS/routing settings;
- layer policy;
- seed;
- analysis scripts.

Any intentional delta must be stated before the run.

Use fixed-core geometry for the primary A/B/C/D physical comparison. If a variant requires more area, run a separately labelled capacity-rescue case.

---

## 14. Power evidence

Power is especially easy to overstate.

Permitted labels:
- `POWER-ESTIMATE-VECTORLESS`;
- `POWER-ESTIMATE-VCD`;
- `POWER-ESTIMATE-SAIF`.

Always record:
- netlist/layout stage;
- SPEF status;
- Liberty corner;
- activity source;
- VCD/SAIF time window;
- clock/state mode;
- command/tool version.

Never write “measured power” unless physical silicon was measured.

Do not write “clock gating reduced power” unless a qualified like-for-like estimate demonstrates it. Even then, call it an estimate.

---

## 15. Formal discipline

Formal targets PMU/control invariants.

Do not imply formal PMU proof establishes:
- physical isolation insertion;
- UPF correctness;
- switch-cell correctness;
- PDN correctness;
- timing correctness.

Document assumptions and liveness/fairness conditions.

---

## 16. ChatGPT vs execution agent

### ChatGPT owns
- requirements;
- architecture;
- power-state semantics;
- SDC reasoning;
- UPF drafting/review;
- PMU RTL/test/formal drafting;
- DFT planning;
- experiment design;
- report interpretation;
- documentation.

### Codex/local execution owns
- real tool installation/qualification;
- repository changes;
- simulation/formal runs;
- OpenROAD/ORFS runs;
- report collection;
- Git/GitHub operations;
- clean reproduction.

Execution tasks must be narrow. Examples:
- “Run the pinned ibex/SKY130HD smoke flow and archive versions/reports.”
- “Prove the required UPF commands exist and run the upstream multipower regression.”
- “Run the pinned SKY130 DFT regression and archive chain report.”

Never issue “make it low power” as a task.

---

## 17. Context discipline

Normal ChatGPT work should load only:
- `docs/PROJECT_STATE.md`;
- the relevant authority doc(s);
- current `tasks/POWER-xxx.md`;
- processed evidence under `results/processed/`;
- changed files.

Keep full logs under `results/raw/`.

Reload the full master plan for:
- specification changes;
- major gate transitions;
- conflict resolution;
- adversarial review.

---

## 18. Milestone response format

At each material milestone report exactly:

1. **What changed**
2. **Evidence now present**
3. **What remains unproven**
4. **Risks / bottlenecks**
5. **Specification changes**
6. **Next smallest engineering task**

Do not bury a failed gate in prose.

---

## 19. Gate protection

Before CV-ready Gate 5, strongly defer:
- retention;
- DVFS;
- extra domains;
- sophisticated ATPG;
- shuttle submission;
- CPU/SoC expansion;
- unnecessary mixed-signal scope.

A failed controlled experiment is acceptable. An unsupported claim is not.

---

## 20. Research/update rule

Before relying on a fast-changing tool feature, check the exact pinned source/documentation and, when relevant, execute a minimal reproduction.

Upstream documentation establishes `DOCS-RESEARCHED`; only project runs establish `EXECUTION-QUALIFIED`.
