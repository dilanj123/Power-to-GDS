# Power-to-GDS Evidence Index

Raw tool logs and implementation databases are retained locally under
`results/raw/` and intentionally excluded from Git. Reproducible processed
evidence and bounded conclusions are stored under `results/processed/`.

| Evidence | File | Classification |
|---|---|---|
| Host/path/tool bootstrap inventory | `results/raw/phase0-bootstrap-inventory.log` | EXECUTION OBSERVATION |
| Frozen ORFS/OpenROAD/Yosys source revisions | `results/processed/phase0-toolchain-freeze.txt` | SOURCE REVISION VERIFIED |
| Docker first-start failure | `results/raw/phase0-docker-amd64-smoke-attempt1-daemon-not-running.log` | EXECUTION FAILURE — daemon unavailable |
| Docker arm64 / amd64 smoke | `results/raw/phase0-docker-amd64-smoke.log` | CONTAINER EXECUTION QUALIFIED |
| Pinned ORFS build-interface inspection | `results/raw/phase0-orfs-build-interface-inspection.log` | SOURCE / INTERFACE INSPECTION |
| ORFS native-build host preflight | `results/raw/phase0-orfs-native-build-preflight.log` | HOST BUILD PREFLIGHT PASS |
| ORFS arm64 build attempt 1 | `results/raw/phase0-orfs-native-arm64-build-attempt1-host-bash.log` | EXECUTION FAILURE — host Bash compatibility |
| Tool smoke after failed build | `results/raw/phase0-orfs-native-arm64-tool-smoke-attempt1-no-image.log` | EXPECTED FAILURE — image absent |
| ORFS arm64 build attempt 2 | `results/raw/phase0-orfs-native-arm64-build-attempt2.log` | RESOURCE-LIMITED DEPENDENCY BUILD FAILURE |
| ORFS arm64 attempt-2 summary | `results/processed/phase0-native-arm64-attempt2-summary.md` | PROCESSED EVIDENCE |
| Pinned upstream SKY130HD UPF isolation regression | `results/raw/phase0-upf-isolation-regression.log` | PASS — 19 generated isolation cells |
| Project ORFS UPF integration hooks | `results/raw/phase0-orfs-upf-integration-hooks.log` | `read_upf` integration evidence |
| Project two-domain UPF synthesis | `results/raw/phase0-upf-two-domain-synth-smoke.log` | UPF persisted in `1_synth.odb` |
| Project two-domain UPF floorplan | `results/raw/phase0-upf-two-domain-floorplan-smoke.log` | ISOLATION MATERIALIZED |
| Project two-domain UPF placement | `results/raw/phase0-upf-two-domain-place-smoke.log` | DETAILED PLACEMENT PASS |
| Project two-domain UPF CTS | `results/raw/phase0-upf-two-domain-cts-smoke.log` | CTS SURVIVAL PASS |
| Project two-domain UPF global route | `results/raw/phase0-upf-two-domain-global-route-smoke.log` | GLOBAL ROUTE SURVIVAL PASS |
| Project two-domain UPF detailed route | `results/raw/phase0-upf-two-domain-detailed-route-smoke.log` | QUALIFICATION SMOKE PASS |
| Gate-0 UPF isolation qualification | `results/processed/phase0-upf-isolation-qualification.md` | PROCESSED EVIDENCE — BOUNDED |
| POWER-000 power-switch capability capture | `results/raw/phase0-power-switch-capability.log` | CLASSIFICATION B — RAW CAPTURE |
| POWER-000 power-switch qualification | `results/processed/phase0-power-switch-qualification.md` | CLASSIFICATION B — PROCESSED EVIDENCE |
| POWER-000 DFT one-cell regression | `results/raw/phase0-dft-one-cell-regression.log` | PASS — scan replacement and SCANCHAINS |
| POWER-000 DFT scan-architecture regression | `results/raw/phase0-dft-scan-architect-regression.log` | PASS — four chains, 20 scan cells |
| POWER-000 DFT/scan qualification | `results/processed/phase0-dft-qualification.md` | CLASSIFICATION A — PROCESSED EVIDENCE |
| POWER-000 project-owned scan-integration raw capture | `results/raw/phase0-dft-project-scan-smoke.log` | PASS — bounded integration smoke |
| POWER-000 project-owned scan-integration work data | `results/raw/phase0-dft-scan-work/` | IGNORED RAW IMPLEMENTATION DATA |
| POWER-000 project-owned scan-integration qualification | `results/processed/phase0-dft-project-integration.md` | PASS — bounded, DPL-0387 limitation |
| POWER-000 scan physical-routing raw capture | `results/raw/phase0-dft-scan-route-smoke.log` | PASS — raw capture, ignored |
| POWER-000 scan physical-routing work data | `results/raw/phase0-dft-scan-route-work/` | IGNORED RAW IMPLEMENTATION DATA |
| POWER-000 scan physical-routing qualification | `results/processed/phase0-dft-scan-route-qualification.md` | PASS — bounded physical integration |
| Ibex SKY130HD ABC synthesis reproduction | `results/raw/phase0-ibex-abc-reproduction.log` | PASS_WITH_KNOWN_TOOL_WARNING — deterministic ABC9 assertion, mapped output retained |
| Ibex ABC9 debug inputs and direct reproduction | `results/raw/phase0-ibex-abc-debug/` | RAW — direct return 134 and `giaTim.c:799` assertion |
| Ibex ABC synthesis qualification | `results/processed/phase0-ibex-abc-qualification.md` | PASS_WITH_KNOWN_TOOL_WARNING — reproducible, fully technology mapped |
| Ibex 10 ns timing diagnosis raw capture | `results/raw/phase0-ibex-timing-diagnosis.log` | DIAGNOSTIC RAW — ignored |
| Ibex 10 ns timing qualification | `results/processed/phase0-ibex-timing-qualification.md` | KEEP_10NS_AS_NONCLOSING_STRESS_POINT — MIXED |

No complete Gate-0 sign-off is claimed. The UPF milestone is limited to the
documented two-domain isolation qualification smoke and its stated limitations.
POWER-000 separately closes the switch-feasibility branch as a pinned
physical-library limitation; it does not establish physical power gating or
complete Gate-0 sign-off.

POWER-000 DFT/scan closes the capability branch as classification A: the
pinned OpenROAD DFT regressions pass and the actual pinned ORFS SKY130HD
platform contains usable scan-cell views and Liberty metadata. This does not
establish ATPG, fault simulation, test coverage, manufacturing qualification,
production DFT sign-off, or main-design scan integration.

The project-owned ORFS scan-integration smoke passed through detailed
placement: replacement persisted in `1_synth.odb`, one 12-cell chain and scan
ports persisted in `3_3_place_gp.odb`, and the same topology persisted in
`3_5_place_dp.odb`. DPL-0387 reported unplaced scan BTerms, so no scan-I/O
placement/routability or scan-mode timing claim is made. Gate 0 remains open.

The follow-on project-owned scan physical-routing qualification explicitly
placed the three scan BTerms, removed the DPL-0387 unplaced-BTerm condition,
and preserved one 12-cell chain through CTS, global route, and detailed route.
The final routed ODB contained dbWire geometry for 3/3 scan-port nets and
11/11 internal scan nets; detailed-route and antenna violations were zero.
This remains bounded to physical integration and does not establish scan-mode
timing, ATPG, fault simulation, fault coverage, tester qualification,
production DFT sign-off, or foundry-signoff routing/DRC.

The conventional Ibex SKY130HD synthesis result is reproducible and fully
technology mapped, but the pinned ABC9 flow emits a deterministic internal
assertion/abort that Yosys tolerates because a valid `output.aig` is present.
The affected module is `ibex_core`; both original and reproduced ABC return
code `134`, while the direct helper aborts at `giaTim.c:799` on assertion
`Gia_ObjIsAnd(pObj)`. No OOM evidence was found. The synthesis target returned
`0`, the reproduced `1_2_yosys.v` was byte-identical, and the resulting
`1_synth.odb` was fully SKY130HD mapped and was the checkpoint consumed by the
physical flow. This is
`PASS_WITH_KNOWN_TOOL_WARNING`: ABC did not succeed without error, the
underlying ABC algorithmic defect remains in the pinned toolchain, and no
warning-free synthesis or ABC-fix claim is made. Gate 0 remains open.
