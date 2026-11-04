# Power-to-GDS
## 04 — Master Checklist

Checkboxes represent evidence-backed completion, not intent.

---

# Phase A — Planning package

- [x] Central engineering question defined.
- [x] A/B/C/D experiment structure defined.
- [x] Evidence taxonomy defined.
- [x] Current OpenROAD UPF scope researched.
- [x] Current OpenROAD DFT scope researched.
- [x] Current OpenSTA power-analysis path researched.
- [x] SKY130HD selected as primary platform candidate.
- [x] Bootstrap source revisions pinned.
- [x] Apple-Silicon contingency defined.
- [x] Adversarial review performed.
- [x] Scope reduced where upstream support is weak.
- [ ] Previously referenced RTL-to-Pixels/CPU planning docs directly cross-reviewed — **not available in current project/library search**.

---

# Gate 0 — Backend qualification

## Host
- [ ] Exact Mac model/CPU/ISA recorded.
- [ ] macOS version recorded.
- [ ] RAM/free disk recorded.
- [ ] Container runtime/version recorded.

## Toolchain
- [ ] ORFS checkout equals frozen SHA.
- [ ] OpenROAD submodule equals frozen SHA.
- [ ] Yosys submodule equals frozen SHA.
- [ ] `openroad -version` captured.
- [ ] `yosys -V` captured.
- [ ] `klayout -v` captured.
- [ ] platform collateral SHA-256 manifest captured.

## Conventional reference flow
- [ ] Clean ibex/SKY130HD reference run completed.
- [ ] Synthesis report archived.
- [ ] Placement report archived.
- [ ] CTS report archived.
- [ ] Route report archived.
- [ ] STA report archived.
- [ ] GDS presence/absence recorded.
- [ ] DRC execution/result recorded.
- [ ] LVS execution/result recorded.
- [ ] runtime/resource use recorded.
- [ ] clean rerun performed.

## UPF
- [ ] `read_upf` capability demonstrated.
- [ ] power domain command demonstrated.
- [ ] power-switch intent demonstrated.
- [ ] isolation command demonstrated.
- [ ] interface-cell mapping demonstrated.
- [ ] domain-area command demonstrated.
- [ ] unsupported features listed.
- [ ] no full-IEEE-1801 claim made.

## SKY130 low-power cells
- [ ] frozen platform `dont_use` behavior documented.
- [ ] required isolation views verified.
- [ ] exact override mechanism scripted.
- [ ] isolation instance insertion demonstrated.
- [ ] isolation instance placed.
- [ ] isolation instance routed.
- [ ] timing model read successfully.
- [ ] physical-check implications recorded.

## Physical power switch
- [ ] candidate real switch cell searched.
- [ ] Liberty/LEF/GDS views verified if candidate exists.
- [ ] `map_power_switch` tested if applicable.
- [ ] status declared: PASS / INTENT-ONLY / BLOCKED.

## DFT
- [ ] upstream SKY130 scan regression executed.
- [ ] scan replacement recorded.
- [ ] scan plan recorded.
- [ ] scan stitching recorded.
- [ ] chain metrics recorded.
- [ ] limitations recorded.

## Power estimation
- [ ] vectorless/probabilistic report reproduced.
- [ ] VCD report reproduced.
- [ ] SAIF tested or explicitly deferred.
- [ ] all numbers labelled estimates.

## Backend decision
- [ ] one canonical backend frozen.
- [ ] launch command documented.
- [ ] fallback documented.
- [ ] **Gate 0 PASS**.

---

# Gate 1 — Contract frozen

## Input IP
- [ ] Candidate blocks enumerated.
- [ ] Original portfolio authorship established.
- [ ] stable interfaces confirmed.
- [ ] source commit recorded.
- [ ] source regression evidence exists.
- [ ] synthesis suitability established.
- [ ] size/runtime suitability established.
- [ ] chosen IP recorded in `DECISIONS`.

## Requirements / microarchitecture
- [ ] `docs/REQUIREMENTS.md` reviewed.
- [ ] `docs/MICROARCHITECTURE.md` reviewed.
- [ ] AON/SW boundaries frozen.
- [ ] transaction acceptance semantics frozen.
- [ ] in-flight accounting frozen.
- [ ] timeout/fairness policy frozen.
- [ ] reset in every PMU state frozen.
- [ ] wake sequence frozen.
- [ ] status/config interface frozen.

## Power intent
- [ ] `docs/POWER_INTENT.md` reviewed.
- [ ] supported OpenROAD UPF subset stated.
- [ ] isolation polarity/clamp/location frozen.
- [ ] power switch physical status stated.
- [ ] level shifting deferred.
- [ ] retention deferred.
- [ ] DVFS deferred.

## Clock gating
- [ ] inference/mapping/instantiation method frozen.
- [ ] exact intended ICG mapping documented.
- [ ] test bypass strategy documented.
- [ ] STA relation documented.

## Timing
- [ ] `docs/TIMING.md` reviewed.
- [ ] `constraints/mission.sdc` drafted.
- [ ] `constraints/scan.sdc` drafted.
- [ ] each clock has rationale.
- [ ] I/O delays have rationale.
- [ ] uncertainty has rationale.
- [ ] every false path has rationale.
- [ ] every multicycle path has rationale.
- [ ] scan/mission separation frozen.

## DFT
- [ ] `docs/DFT.md` reviewed.
- [ ] scan scope frozen.
- [ ] chain-length/count policy frozen.
- [ ] post-scan verification strategy frozen.
- [ ] no ATPG/coverage claim.

## Verification/formal
- [ ] `docs/VERIFICATION_PLAN.md` reviewed.
- [ ] `docs/FORMAL.md` reviewed.
- [ ] sleep/wake matrix frozen.
- [ ] PMU properties frozen.
- [ ] assumptions/fairness documented.

## Experiment
- [ ] primary fixed die/core geometry frozen.
- [ ] mission clock target frozen.
- [ ] PDK/library frozen.
- [ ] synthesis/PnR knobs frozen.
- [ ] seed policy frozen.
- [ ] metrics schema frozen.
- [ ] capacity-rescue policy frozen.
- [ ] **Gate 1 PASS**.

---

# Gate 2 — Conventional baseline

- [ ] imported source regression rerun passes.
- [ ] regression command archived.
- [ ] Configuration A synthesised.
- [ ] Configuration A placed.
- [ ] Configuration A CTS implemented.
- [ ] Configuration A routed to defined acceptance stage.
- [ ] mission STA collected.
- [ ] area/cell metrics collected.
- [ ] physical metrics collected.
- [ ] DRC/LVS state accurately classified.
- [ ] result reproducible from clean build.
- [ ] no low-power optimization included.
- [ ] **Gate 2 PASS**.

---

# Gate 3 — Low-power behavior verified

- [ ] PMU implemented.
- [ ] no new accepts after quiesce.
- [ ] accepted transactions drain correctly.
- [ ] idle sleep tested.
- [ ] in-flight sleep tested.
- [ ] clock gating tested.
- [ ] isolation abstraction tested.
- [ ] wake tested.
- [ ] repeated sleep/wake tested.
- [ ] reset in each PMU state tested.
- [ ] illegal/race cases tested.
- [ ] required formal safety properties pass.
- [ ] liveness assumptions documented.
- [ ] formal result not misrepresented as physical UPF proof.
- [ ] **Gate 3 PASS**.

---

# Gate 4 — Physical engineering depth

## Configuration B
- [ ] clock-gated netlist verified.
- [ ] ICG count recorded.
- [ ] placement/CTS/routing run.
- [ ] mission timing recorded.
- [ ] clock-tree effects recorded.
- [ ] power estimate recorded only if qualified.

## Configuration C
- [ ] UPF read/applied.
- [ ] power domains inspectable.
- [ ] isolation cell count recorded.
- [ ] switch status accurately classified.
- [ ] domain area implemented.
- [ ] placement/routing run.
- [ ] mission timing recorded.
- [ ] physical overhead recorded.

## Configuration D
- [ ] scan replacement executes.
- [ ] scan plan recorded.
- [ ] scan chains stitched.
- [ ] chain metrics recorded.
- [ ] mission functionality rechecked.
- [ ] mission timing recorded.
- [ ] scan timing recorded separately.
- [ ] placement/routing run.
- [ ] scan overhead recorded.

## Comparison
- [ ] common tool/PDK/library verified.
- [ ] common IP commit verified.
- [ ] common primary floorplan verified.
- [ ] common mission constraints verified.
- [ ] intended deltas enumerated.
- [ ] machine-readable comparison table generated.
- [ ] hypotheses resolved RETAIN/MODIFY/REJECT/INCONCLUSIVE.
- [ ] rescue runs separated from primary data.
- [ ] **Gate 4 PASS**.

---

# Gate 5 — Public/CV-ready

- [ ] README makes evidence boundaries explicit.
- [ ] original architecture diagram.
- [ ] original power-sequence diagram.
- [ ] UPF published with supported-subset wording.
- [ ] SDC published with rationale.
- [ ] DFT method/limitations published.
- [ ] timing table generated from reports.
- [ ] physical/area table generated from reports.
- [ ] power table, if any, says estimate and activity source.
- [ ] screenshots are generated from project runs.
- [ ] `docs/TRADEOFFS.md` complete.
- [ ] `docs/KNOWN_LIMITATIONS.md` complete.
- [ ] `docs/EVIDENCE_INDEX.md` complete.
- [ ] `docs/THIRD_PARTY_MANIFEST.md` complete.
- [ ] `docs/THIRD_PARTY_NOTICES.md` complete.
- [ ] exact reproduction commands tested.
- [ ] fresh clean reproduction succeeds on canonical backend.
- [ ] no production tapeout implication.
- [ ] **Gate 5 PASS**.

---

# Gate 6 — Optional fabrication

- [ ] Gate 5 already complete.
- [ ] shuttle/process terms researched afresh.
- [ ] submitted GDS separately classified.
- [ ] submission acceptance separately classified.
- [ ] returned die/package separately classified.
- [ ] silicon measurements separately classified.
- [ ] no fabrication claim before physical receipt/evidence.
