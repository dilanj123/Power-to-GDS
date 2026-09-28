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
- real SKY130HD physical power-switch implementation
- project-owned scan integration into the main design
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

## POWER-000 power-switch qualification — classification B

POWER-000 is qualified as **B** for the pinned ORFS/OpenROAD/SKY130HD
combination.

Pinned OpenROAD supports UPF power-switch intent, library-cell mapping, and
physical PDN insertion. The pinned upstream `power_switch_upf_daisy`
regression passed with return code `0` and reported `No differences found.`
Its generated DEF contained `751` components and `140` fixed
`POWER_SWITCH` instances with `VDDG`, `VPWR`, `VGND`, `SLEEP`, and
`SLEEP_OUT` connectivity.

That regression uses a synthetic test-only `POWER_SWITCH` macro from the
OpenROAD test tree. The macro is not present in the actual pinned SKY130HD
platform. All `33` exact SKY130HD `lpflow` cells have Liberty, LEF, and CDL
views, but none has evidence establishing it as a physical header/footer
power-switch cell. All `33` remain in the unchanged SKY130HD
`DONT_USE_CELLS` list.

Therefore the switch-feasibility branch is closed with classification B:
OpenROAD supports the mechanism, but the selected open SKY130HD platform does
not contain a valid physical power-switch master. This is a physical-library
limitation, not a failure of UPF support. No synthetic physical-switch
implementation was added and no physical power gating is claimed.

Evidence:
- `results/raw/phase0-power-switch-capability.log`
- `results/processed/phase0-power-switch-qualification.md`

Gate 0 remains open because other backend qualification items remain
unresolved.

## POWER-000 DFT/scan qualification — classification A

POWER-000 DFT/scan capability is qualified as **A** for the pinned
ORFS/OpenROAD/SKY130HD combination.

The pinned OpenROAD build executes `scan_replace`, `report_dft_plan`, and
`execute_dft_plan`; `scan_opt` remains an implemented no-op. The actual pinned
ORFS SKY130HD platform contains 24 Liberty `test_cell` scan masters, including
`sky130_fd_sc_hd__sdfsbp_1`, with compatible Liberty, merged LEF, and CDL
views. The scan masters are not in the effective SKY130HD `DONT_USE_CELLS`
list, which was not modified.

The pinned one-cell regression and multi-cell no-mix scan-architecture
regression both returned `0` with `No differences found.` The one-cell test
replaced `sky130_fd_sc_hd__dfstp_1` with
`sky130_fd_sc_hd__sdfsbp_1`, created one one-bit chain, and emitted scan ports
and `SCANCHAINS 1` in DEF. The multi-cell test previewed four five-bit chains;
the preview netlists were identical, while the executed plan stitched scan
connections. A disposable smoke using the actual ORFS SKY130HD Liberty and
LEF reproduced the one-cell replacement and DEF scan-chain metadata.

This proves scan-cell replacement, scan-chain architecture, scan-chain
stitching, scan ports, and database scan-chain metadata. It does not prove
ATPG, fault simulation, any test coverage, pattern generation, tester or
manufacturing qualification, production DFT sign-off, scan optimization, or
physical survival of a project scan experiment. No project RTL or main design
was modified. The DFT capability branch is closed with classification A, but
Gate 0 remains open.

Evidence:
- `results/raw/phase0-dft-one-cell-regression.log`
- `results/raw/phase0-dft-scan-architect-regression.log`
- `results/processed/phase0-dft-qualification.md`

## POWER-000 project-owned ORFS scan-integration smoke — PASS

The separate project-owned `flow/phase0/dft-scan-smoke/` design passed the
pinned ORFS scan-integration smoke without changing imported portfolio RTL,
the UPF qualification, PDK/library settings, or `DONT_USE_CELLS`.

The original mapped netlist contained 12
`sky130_fd_sc_hd__dfxtp_1` flops. `POST_SYNTH_TCL` applied `scan_replace`
before `1_synth.odb`; reopening that checkpoint found 12
`sky130_fd_sc_hd__sdfxtp_1` scan flops. After global placement,
`POST_GLOBAL_PLACE_TCL` reported and executed one 12-cell chain. The reopened
`3_3_place_gp.odb` contained `scan_in_0`, `scan_enable_0`, and `scan_out_0`,
and DEF `SCANCHAINS 1` metadata. The reopened `3_5_place_dp.odb` retained the
same topology with all 12 scan cells placed.

Detailed placement returned `0` with zero wrong-region, row-alignment,
site-alignment, overlap, edge-spacing, and padding violations. DPL-0387 did
report the three scan BTerms as unplaced. Therefore this smoke does not claim
scan-I/O physical placement or routability, routed scan connectivity, scan-mode
timing, ATPG, fault coverage, or production DFT sign-off. The SDC used only the
functional clock and added no broad false paths.

This closes the project-owned scan-integration smoke as a bounded PASS, but
Gate 0 remains open.

Evidence:
- `results/raw/phase0-dft-project-scan-smoke.log`
- `results/raw/phase0-dft-scan-work/`
- `results/processed/phase0-dft-project-integration.md`

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
