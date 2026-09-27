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
- complete ASIC implementation flow
- Yosys execution through a complete production flow
- KLayout sign-off flow
- ibex reference implementation
- physical power-switch mapping
- scan insertion
- timing cleanliness
- DRC/LVS cleanliness
- power reduction
- GDS generation

Qualified in a bounded smoke only:
- Linux/arm64 Docker execution on the native Apple-Silicon host
- pinned OpenROAD upstream SKY130HD UPF isolation regression
- project-owned two-domain UPF isolation intent through synthesis,
  floorplan, placement, CTS, global route, and detailed-route smoke
- one legally placed `sky130_fd_sc_hd__lpflow_inputiso0n_1` isolation cell

Evidence:
`results/processed/phase0-upf-isolation-qualification.md`

This does not complete Gate 0 or establish production/foundry sign-off,
timing cleanliness, PDN cleanliness, physical power gating, PMU behavior,
DFT/scan, activity-based power reduction, or complete industrial IEEE 1801
support.

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

## Gate-0 UPF isolation qualification — bounded milestone

Environment:
- native Apple-Silicon host
- Linux/arm64 Docker
- SKY130HD
- OpenROAD no-GUI flow

Pinned revisions:
- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`

The pinned upstream SKY130HD UPF isolation regression passed and generated
19 `sky130_fd_sc_hd__lpflow_inputiso0n_1` isolation cells. In the
project-owned two-domain qualification, `POST_SYNTH_TCL` successfully
executed `read_upf`; the UPF intent persisted in `1_synth.odb`; the
`PD_SW` power-domain area was `30 30 60 60 um`; and isolation materialized
during floorplan initialization.

The project smoke contained one
`sky130_fd_sc_hd__lpflow_inputiso0n_1` isolation instance. It was legally
detailed-placed, survived CTS and global route, and detailed route passed
for this qualification smoke. Final TritonRoute violations were `0`.
Functional isolation pins `A`, `SLEEP_B`, and `X` all had routed dbWire
geometry (`3 / 3`). Final antenna violations were `0` net and `0` pin.
The SKY130HD default `DONT_USE_CELLS` setting was unchanged throughout.

This milestone is bounded. DRT-0349 reports unsupported
LEF58_ENCLOSURE-without-CUTCLASS constructs, so this is not a
production/foundry sign-off DRC claim. The tiny smoke has incomplete I/O
timing constraints and is not timing-clean. An earlier smoke PDN generation
emitted PDN-0110 and must not be called PDN-clean. Physical power-switch-cell
realization, project PMU behavior, DFT/scan, and activity-based power
reduction remain unproven. Full industrial IEEE 1801 support is not
established, and OpenROAD hierarchical mode reports a development-status
warning.

This evidence does not claim tapeout, silicon measurement, production
sign-off, timing closure, full UPF support, physical power gating, power
reduction, or scan/ATPG success.
