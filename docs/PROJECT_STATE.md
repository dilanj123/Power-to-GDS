# Power-to-GDS Project State

## Current gate

Gate 0 — backend qualification.

Gate 0 is NOT complete.

## Workspace

Power-to-GDS repository:
`$HOME/Projects/Power-to-GDS`

Reference RTL-to-Pixels repository:
`$HOME/Projects/from-rtl-to-pixels`

External ASIC tool workspace:
`$HOME/.local/share/power-to-gds`

ORFS checkout:
`$HOME/.local/share/power-to-gds/OpenROAD-flow-scripts`

## Host observed

- Apple Silicon / arm64
- macOS 26.4.1
- 12 logical CPUs
- 16 GiB physical RAM
- approximately 533 GiB free disk at bootstrap observation
- Homebrew available
- Docker not installed at bootstrap observation
- OpenROAD not globally installed
- Yosys not globally installed
- KLayout not globally installed

Evidence:
`results/raw/phase0-bootstrap-inventory.log`

## Toolchain source freeze

ORFS:
`3a964e13f11a4e435aac01ffa14db0a7d2853720`

OpenROAD submodule:
`4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`

Yosys submodule:
`a5af9d690a43744bf6b2cc3dea2717c16b54621c`

Classification:
`SOURCE REVISION VERIFIED`

Tool execution is NOT yet qualified.

Evidence:
`results/processed/phase0-toolchain-freeze.txt`

## Source RTL status

Reference RTL-to-Pixels HEAD observed during current bootstrap:
`8c83fdfccbba72b786efbca3f0a3ae0b3cf2a55f`

An earlier planning observation recorded:
`fd332d1d0ee978047ea3bb6889d8b1861ca3aa10`

Therefore the RTL-to-Pixels project has advanced.

No Power-to-GDS input RTL commit has been selected or imported yet.
The future IP-selection gate must freeze an exact known-good commit and
associated regression evidence before import.

## Current claims

Proven:
- Power-to-GDS workspace exists.
- ORFS source checkout exists.
- planned ORFS/OpenROAD/Yosys source revisions match exactly.

Not proven:
- Docker/container flow
- OpenROAD execution
- Yosys execution through ORFS
- KLayout execution
- SKY130HD availability
- ibex reference implementation
- UPF execution
- isolation-cell insertion
- physical power-switch mapping
- scan insertion
- timing cleanliness
- DRC/LVS cleanliness
- power reduction
- GDS generation

## Gate-0 container qualification update — 2026-09-20

Docker Desktop:
- version 4.91.0
- Docker Engine 29.8.0
- server architecture linux/arm64

Docker VM resources observed:
- 12 CPUs
- approximately 7.7 GiB RAM
- 1 GiB swap

Execution evidence:
- Ubuntu 22.04 native arm64 container: PASS
- Ubuntu 22.04 linux/amd64 container: PASS
- `AMD64_CONTAINER_SMOKE=PASS`

Evidence:
`results/raw/phase0-docker-amd64-smoke.log`

Classification:
`CONTAINER EXECUTION QUALIFIED`

This qualifies container execution only.

It does NOT yet qualify:
- ORFS execution
- OpenROAD execution
- SKY130HD
- ibex implementation
- UPF
- DFT
- timing
- power
- DRC/LVS
- GDS generation

The Apple-Silicon Mac therefore remains a candidate container host.
It is not yet the frozen canonical ASIC backend.

## ORFS native-arm64 build attempt 1

Pinned ORFS source:
`3a964e13f11a4e435aac01ffa14db0a7d2853720`

Host build preflight:
PASS

First Docker-source-build attempt:
FAIL before Docker image construction.

Observed failure:
`build_openroad.sh` terminated while expanding the empty
`OPENROAD_APP_USER_ARGS` array under nounset handling.

This is currently classified as a host Bash compatibility failure.
It is NOT evidence of an OpenROAD, Yosys, SKY130HD, or Linux/arm64
execution failure.

No ORFS builder image was produced, so the subsequent tool smoke
correctly failed with "No such image".

Remediation:
qualify a modern Homebrew Bash and retry the unchanged pinned source.
Do not patch the ORFS source tree.

Evidence:
- `results/raw/phase0-orfs-native-build-preflight.log`
- `results/raw/phase0-orfs-native-arm64-build-attempt1-host-bash.log`
- `results/raw/phase0-orfs-native-arm64-tool-smoke-attempt1-no-image.log`

## ORFS native-arm64 build attempt 2

Result:
FAIL

The modern-Bash remediation passed the previous host-wrapper blocker.
The build progressed into native linux/arm64 dependency-image
construction and compiled KLayout 0.30.12.

The build then failed due to Docker/BuildKit memory exhaustion while
compiling KLayout:
`ResourceExhausted: cannot allocate memory`.

Classification:
`RESOURCE-LIMITED DEPENDENCY BUILD FAILURE`

This is not an OpenROAD, Yosys, SKY130HD, UPF or physical-flow result.

Next controlled change:
limit Docker Desktop to 2 CPUs while holding its memory allocation
constant, then repeat the same pinned native-arm64 build.

Evidence:
- `results/raw/phase0-orfs-native-arm64-build-attempt2.log`
- `results/processed/phase0-native-arm64-attempt2-summary.md`
