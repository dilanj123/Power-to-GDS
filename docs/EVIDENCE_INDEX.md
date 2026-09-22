# Power-to-GDS Evidence Index

| Evidence | File | Classification |
|---|---|---|
| Host/path/tool bootstrap inventory | `results/raw/phase0-bootstrap-inventory.log` | EXECUTION OBSERVATION |
| Frozen ORFS/OpenROAD/Yosys source revisions | `results/processed/phase0-toolchain-freeze.txt` | SOURCE REVISION VERIFIED |
| Docker first-start failure | `results/raw/phase0-docker-amd64-smoke-attempt1-daemon-not-running.log` | EXECUTION FAILURE — daemon unavailable |
| Docker arm64 / amd64 smoke | `results/raw/phase0-docker-amd64-smoke.log` | CONTAINER EXECUTION QUALIFIED |
| Pinned ORFS build-interface inspection | `results/raw/phase0-orfs-build-interface-inspection.log` | SOURCE / INTERFACE INSPECTION |

No ASIC implementation result is currently claimed.
Gate 0 remains open.
| ORFS native-build host preflight | `results/raw/phase0-orfs-native-build-preflight.log` | HOST BUILD PREFLIGHT PASS |
| ORFS arm64 build attempt 1 | `results/raw/phase0-orfs-native-arm64-build-attempt1-host-bash.log` | EXECUTION FAILURE — host Bash compatibility |
| Tool smoke after failed build | `results/raw/phase0-orfs-native-arm64-tool-smoke-attempt1-no-image.log` | EXPECTED FAILURE — image absent |
| ORFS arm64 build attempt 2 | `results/raw/phase0-orfs-native-arm64-build-attempt2.log` | RESOURCE-LIMITED DEPENDENCY BUILD FAILURE |
| ORFS arm64 attempt-2 summary | `results/processed/phase0-native-arm64-attempt2-summary.md` | PROCESSED EVIDENCE |
