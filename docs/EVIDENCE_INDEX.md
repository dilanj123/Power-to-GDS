# Power-to-GDS Evidence Index

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
