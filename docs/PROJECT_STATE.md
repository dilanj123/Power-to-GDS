# Power-to-GDS Project State

## Current gate snapshot — 2026-11-03

**Gate 0: PASS WITH DECLARED SWITCH-INTENT LIMITATION.** The re-established
10.30 ns implementation passes read-only mission STA at 10.50 ns with WNS
`+0.061130657792 ns`, TNS `0`, and zero setup/hold violations. It has
electrical residuals on two data nets: three violating slew pin checks and one
capacitance check. GDS was generated from the accepted final database; the
pinned SKY130HD open-deck DRC returned zero violations, and open-deck LVS
reported `Netlists match`. These are not foundry/production sign-off.

**Gate 1: PASS — engineering contract frozen and amended by D-014.** The
accepted immutable `rtl_to_pixels_top_pipelined` source, domain boundary, logical PMU sequence,
clock-gating mapping, UPF/isolation subset, DFT scope, timing methodology,
metrics, fairness controls, and verification/formal plan are recorded in
`results/processed/gate1-engineering-contract.md` and the Gate-1 authority
documents. D-011 through D-013 set the ASIC study to 32x24, clarify
frame-boundary sleep handling, and keep the D scan-chain length provisional
until A's mapped flop count is known. D-014 sets the portfolio mission
evaluation period to 12.00 ns while retaining the 10.30 ns implementation
target and all other comparison controls.

**Configuration A: PASS_AT_12NS_MISSION.** The immutable portfolio source
passed the accepted source regression and 32x24 parameterized tests. The
existing implementation database, built at 10.30 ns, passes exact read-only
STA at 12.00 ns: WNS `+0.652646839619 ns`, TNS `0`, setup `0`, hold `0`, and
zero slew/capacitance violations. The same GDS passed the pinned open-deck
DRC with zero items and open-deck LVS with `Netlists match`. A's geometry and
resolved comparison settings are frozen for later variants. The earlier
10.50 ns failure remains visible in `results/processed/config-a-baseline.md`.

**Configuration B: PASS_AT_12NS_MISSION — clock-gating only.** One
`sky130_fd_sc_hd__dlclkp_1` mapped from the qualified `OPENROAD_CLKGATE`
flow. Functional/reference tests pass (4/4 frame, 5/5 streaming, 1/1 directed
clock-gate test); a mid-frame sleep request drains all 24 lines and output
transfers before gating, and wake processes a second frame. At 12.00 ns
mission STA: WNS `+1.492426633835 ns`, TNS `0`, setup/hold `0/0`, slew/cap
violations `0/0`. At its 10.30 ns implementation target B is non-closing
(WNS `-0.207571744919 ns`, TNS `-0.905369162560 ns`) and this remains
reported. Detailed-route violations are zero; GDS was generated; pinned
open-deck DRC returned zero and open-deck LVS reported `Netlists match`.
Vectorless power is estimated at 14.5 mW and is not activity-qualified.
Evidence: `results/processed/config-b-clock-gating.md`; raw artifacts and
hashes are retained under `results/raw/phase1-config-b/artifacts/`.

**Configuration C: NOT ACCEPTED — physical placement gate failed.** The
project-owned PMU/domain wrapper passes directed simulation and bounded
18-step safety assertions; the UPF flow retains two domains and a logical
switch intent and inserts 37 SKY130HD isolation cells during floorplan
initialization. The prior near-whole-core region failed at
`3_1_place_gp_skip_io` with a domain-area range error; a no-area diagnostic
failed full global placement with `GPL-0307` RePlAce divergence. The single
D-015 row/site-aligned retry loaded its exact region and completed skip-I/O
placement and I/O pin placement, but full `3_3_place_gp` stopped with
`FLW-0024 Place density exceeds 1.0` after port buffering. No full global
placement, CTS, routing, final STA, GDS, DRC, or LVS result exists for C. The
effective AON region capacity reported by GPL is materially smaller than the
area-only estimate; its exact source remains unresolved. No further retry is
authorized by D-015. See
`results/processed/config-c-isolation.md` and raw attempts under
`results/raw/phase1-config-c/`.

**Configuration D: NOT STARTED / BLOCKED** until C is accepted. No scan was
added to C.

Current limits: physical SKY130HD power switching, physical power gating,
accepted C physical integration (current C placement failure), unbounded PMU
formal proof beyond the bounded checks recorded for C, activity-based power
reduction, scan ATPG/fault
coverage, production timing/DFT sign-off, and foundry sign-off are unproven or
out of scope. The pinned power-switch qualification remains classification B;
power reporting is vectorless only. The ABC9 deterministic assertion remains
`PASS_WITH_KNOWN_TOOL_WARNING`. Configuration A's actual vectorless power
report is an estimate only and provides no reduction evidence.

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

Tool execution is qualified only for the bounded capabilities recorded in the
processed evidence below. Runtime identity and canonical platform-input
hashes are recorded in `results/processed/runtime-platform-manifest.md`.

Evidence:
`results/processed/phase0-toolchain-freeze.txt`

## Source RTL status

Reference RTL-to-Pixels HEAD observed during current bootstrap:
`8c83fdfccbba72b786efbca3f0a3ae0b3cf2a55f`

An earlier planning observation recorded:
`fd332d1d0ee978047ea3bb6889d8b1861ca3aa10`

Therefore the RTL-to-Pixels project has advanced.

The immutable source baseline
`ad35514c990f6e1c9eb9fa18aee9d906f9df7721` was accepted from a fresh detached
clone. Its documented lint, unit, integration, real-image, and formal targets
all returned `0`. This accepts a source baseline for later work; it does not
claim ASIC suitability or physical implementation success.

## Current evidence summary

Proven at the bounded evidence level: conventional Ibex physical flow through
GDS; 10.50 ns mission timing acceptance for the exact margin-built database;
zero-violation pinned open-deck DRC and matching open-deck LVS; immutable
source regression acceptance; portfolio Configuration A accepted at its
amended 12.00 ns mission period with open-deck DRC/LVS; bounded UPF isolation
and routed scan smokes; and vectorless `report_power` execution.

Not proven: foundry sign-off, physical SKY130HD power switching, accepted C
physical integration, unbounded PMU formal proof, activity-based power
reduction, ATPG/fault
coverage, scan-shift timing closure, production timing sign-off, or accepted
C/D implementation. B's bounded clock-gating implementation is accepted.

The portfolio Configuration A history includes an initial 10.50 ns mission
failure on a deep input-to-register arithmetic path and the subsequent
read-only 12.00 ns mission pass on the exact same physical database. The
existing GDS was then checked: open-deck DRC zero items and LVS `Netlists
match`. The current disposition is D-014 and the full record is
`results/processed/config-a-timing-recovery.md`; the raw logs and hashes are
under `results/raw/phase1-config-a/`.

The dated evidence notes below preserve what was known at each earlier stage.
Statements that Gate 0 was open, KLayout was unavailable, or GDS/DRC/LVS had
not yet run are historical and are superseded by the current snapshot above.

Historical note: the fresh 10.50 ns baseline attempt additionally failed final STA: WNS/TNS
were `-0.0588205 ns`, with one setup violation, zero hold violations, two
max-slew violations, and zero max-capacitance violations. Its worst failing
path was a `vclk_core_clock` reg-to-output path ending at `instr_addr_o[31]`.
The final report retained `STA-0450` for virtual-clock propagation. The run is
`GATE0_BASELINE_TIMING = FAIL`. At that historical snapshot, further
period-only work and portfolio implementation awaited a reviewed timing
strategy. D-014 later amends the portfolio Configuration A/B/C/D mission
evaluation method; A now passes at 12.00 ns and the next sequential B-gate
task may begin. No further Ibex period experiment is authorized.

The later re-established 10.30 ns Ibex implementation is a separate retained
candidate, not a correction of the historical run. Its exact artifacts and
SHA-256 manifest are under
`results/raw/phase0-ibex-10p3ns-reestablished/artifacts/`. It passes the
10.50 ns mission STA using the implementation-margin methodology, but it is
not yet a complete Gate-0 baseline because GDS/DRC/LVS remain unavailable in
the pinned runtime.

Qualified in a bounded smoke only:
- Linux/arm64 Docker execution on the native Apple-Silicon host
- pinned OpenROAD upstream SKY130HD UPF isolation regression
- project-owned two-domain UPF isolation intent through synthesis,
  floorplan, placement, CTS, global route, and detailed-route smoke
- one legally placed `sky130_fd_sc_hd__lpflow_inputiso0n_1` isolation cell

Evidence:
`results/processed/phase0-upf-isolation-qualification.md`

Prompt-A evidence:
- `results/processed/runtime-platform-manifest.md`
- `results/processed/imported-rtl-acceptance.md`
- `results/processed/gate0-reproducibility-bundle.md`
- `results/processed/phase0-power-analysis-qualification.md`
- `results/processed/phase0-ibex-10p5ns-baseline.md`
- `results/processed/gate0-closure-report.md`

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

## POWER-000 Ibex conventional timing baselines

The preserved 10.000 ns Ibex result remains a non-closing stress point, not a
timing-clean baseline. The separately run 10.200 ns and 10.300 ns experiments
both failed routed setup timing. The 10.300 ns run used only the clock-period
change from 10.200 ns and completed detailed route with zero route and antenna
violations, but final extracted STA reported WNS `-0.14 ns`, TNS `-7.83 ns`,
and `96` setup violations with `0` hold violations. Its worst path remained an
instruction-stage-to-register-file cone. Therefore no timing-clean
conventional A/B/C/D baseline is established by these experiments, and no
GDS/DRC/LVS run was performed for 10.300 ns.

The 10.300 ns report gives `core_clock period_min = 10.44 ns` and `95.80 MHz`
as an analytical estimate for that exact implementation only. No period sweep
or implementation workaround was performed. The next period is not selected
automatically.

Evidence:
- `results/processed/phase0-ibex-timing-qualification.md`
- `results/processed/phase0-ibex-10p2ns-baseline.md`
- `results/processed/phase0-ibex-10p3ns-baseline.md`

Gate 0 remains open.

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

## POWER-000 project-owned ORFS scan-integration placement smoke — PASS

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

## POWER-000 project-owned scan physical-routing qualification — PASS

The follow-on project-owned scan smoke explicitly placed the scan BTerms after
`execute_dft_plan` using the pinned ORFS operation:

```tcl
place_pins -hor_layers met3 -ver_layers met2 \
  {*}[env_var_or_empty PLACE_PINS_ARGS]
```

The reopened `3_3_place_gp.odb` and `3_5_place_dp.odb` showed all three scan
BTerms physically placed: `scan_in_0` on `met2`, and `scan_enable_0` and
`scan_out_0` on `met3`. DPL-0387 was absent after explicit scan-port
placement. All 12 scan cells remained placed, and all detailed-placement
violation categories were zero.

CTS passed with 12 functional clock sinks and 3 inserted clock buffers. Global
route passed with zero congestion overflow and zero antenna violations.
Detailed route passed with final TritonRoute violations `0`; final antenna net
and pin violations were both `0`.

The final routed ODB proved one scan chain, 12 scan cells, 3/3 routed scan-port
nets, and 11/11 routed internal scan nets. The final DEF emitted `SCANCHAINS
1`, spanning `scan_in_0` to `scan_out_0`.

This is a bounded PASS for supported project-owned scan physical integration.
Scan-shift-mode timing remains unqualified. No ATPG, fault simulation, fault
coverage, tester qualification, production DFT sign-off, or foundry-signoff
routing/DRC claim is made.

Evidence:
- `results/raw/phase0-dft-scan-route-smoke.log`
- `results/raw/phase0-dft-scan-route-work/`
- `results/processed/phase0-dft-scan-route-qualification.md`

Gate 0 remains open because other backend qualification items remain
unresolved.

## POWER-000 Ibex conventional synthesis qualification — PASS_WITH_KNOWN_TOOL_WARNING

The pinned conventional Ibex SKY130HD synthesis result is reproducible and
fully technology mapped, but the pinned ABC9 flow emits a deterministic
internal assertion/abort that Yosys tolerates because a valid `output.aig` is
present.

The `yosys-abc -s -f <tempdir>/abc.script` invocation failed while mapping
`ibex_core` with return code `134` in both the original and synthesis-only
reproduction. Direct execution aborted at `giaTim.c:799` on assertion
`Gia_ObjIsAnd(pObj)`, preceded by repeated `Tim_ManGetCiArrival()` messages.
No OOM evidence was found; container OOM counters were zero.

Pinned Yosys treats this nonzero ABC exit as a warning when `output.aig`
exists, then continues through XAIGER2, mapping, checks, and Verilog
generation. The synthesis target returned `0`; the reproduced `1_2_yosys.v`
was byte-identical to the original; generic/unmapped cell types were `0` and
SKY130HD-mapped cell lines numbered `15,658`. The resulting `1_synth.odb`
contained `14,043` total instances, all `14,043` using SKY130HD masters, and
the physical flow consumed that exact checkpoint.

This is **PASS_WITH_KNOWN_TOOL_WARNING**, not a warning-free synthesis claim
and not a claim that ABC succeeded. The underlying ABC algorithmic defect
remains in the pinned toolchain. Pinned revisions were ORFS
`3a964e13f11a4e435aac01ffa14db0a7d2853720`, OpenROAD
`4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`, and Yosys
`a5af9d690a43744bf6b2cc3dea2717c16b54621c`, using
`openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109` on
`aarch64`.

Evidence:
- `results/raw/phase0-ibex-abc-reproduction.log`
- `results/raw/phase0-ibex-abc-debug/`
- `results/processed/phase0-ibex-abc-qualification.md`

Gate 0 remains open until the remaining non-ABC qualifications are resolved.

## POWER-000 Ibex 10 ns timing diagnosis — non-closing stress point

The conventional Ibex SKY130HD reference retains `10.000 ns` as a
non-closing stress point inherited from the ORFS Ibex example. It is not a
timing-clean baseline and is not a demonstrated hard Power-to-GDS requirement.
The corresponding virtual I/O clock is also `10.000 ns`; the existing SDC has
157 input delays and 106 output delays, all `2.000 ns`, with no false paths,
multicycle paths, or other timing exceptions.

Final routed timing was WNS `-0.1068 ns`, TNS `-1.93 ns`, with 38 setup and
zero hold violations. Thirty-six failing reg-to-reg paths converge on one
register-file endpoint and two are reg-to-output paths. The failure is
dominated by one deep logic/cell-delay cone. Routed parasitics are the primary
stage at which closure is lost; CTS is essentially clean at 10 ns, with setup
skew `0.142 ns`, so skew is secondary. The 24 max-slew and 2 max-cap
violations are concentrated on two high-fanout data nets.

An analytical zero-slack estimate is approximately `10.11 ns` (`98.94 MHz`).
This is an estimate only and is not a timing-closure result. No SDC changes,
false paths, or multicycle workarounds were used.

The project authority documents `docs/REQUIREMENTS.md`,
`docs/MICROARCHITECTURE.md`, and `docs/TIMING.md` are currently absent; their
contents and intended requirements were not fabricated. The bounded
disposition is `KEEP_10NS_AS_NONCLOSING_STRESS_POINT`. Gate 0 remains open.

Evidence:
- `results/raw/phase0-ibex-timing-diagnosis.log`
- `results/processed/phase0-ibex-timing-qualification.md`

## POWER-000 Ibex 10.20 ns comparison baseline — FAIL_TIMING

A separate conventional Ibex/SKY130HD implementation changed only the copied
SDC clock-period variable from `10.000 ns` to `10.200 ns`; the virtual I/O
clock and derived delays followed that variable. The pinned RTL, library,
toolchain, flow settings, floorplan, utilization, DONT_USE policy, and timing
exceptions were otherwise held constant.

The run completed through extraction and final STA, with final WNS `-0.10 ns`,
TNS `-2.74 ns`, 31 setup violations, and zero hold violations. Max-slew
violations were `12` and max-capacitance violations `0`. Detailed route
completed with zero final TritonRoute violations and zero final antenna net or
pin violations, but the timing acceptance failed. The same register-file
critical cone remained dominant. The final report estimates approximately
`10.30 ns` for zero slack; that is a proposed next experiment, not a closure
result.

Classification is **FAIL_TIMING**. The 10.20 ns run is not a timing-clean
conventional A/B/C/D comparison target, and no GDS, KLayout DRC, or KLayout
LVS was run after the failed timing acceptance. The 10 ns result remains the
documented non-closing stress point. Gate 0 remains open.

Evidence:
- `results/raw/phase0-ibex-10p2ns-baseline/`
- `results/processed/phase0-ibex-10p2ns-baseline.md`

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
