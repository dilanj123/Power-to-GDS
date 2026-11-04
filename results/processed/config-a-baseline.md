# Configuration A — conventional ASIC baseline

Current status: **PASS_AT_12NS_MISSION — Configuration A is accepted and
frozen as the conventional portfolio baseline at the reviewed 12.00 ns mission
evaluation period.** Its earlier 10.50 ns evaluation failure remains
historical and is detailed below. Gate 0 and Gate 1 remain PASS. No B/C/D
implementation was run in the timing-recovery task.

## Scope, source, and functional acceptance

- Source repository: `https://github.com/dilanj123/from-rtl-to-pixels`
- Immutable source commit: `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`
- Top: `rtl_to_pixels_top_pipelined`, unchanged source RTL.
- ASIC parameters: `IMG_WIDTH=32`, `IMG_HEIGHT=24`; 768 pixels; 512 bits of
  two 8-bit line-buffer storage before mapping.
- The source's 640x480 defaults and accepted regression remain unchanged.
- Imported RTL is byte-identical to the accepted source; file hashes and the
  upstream copyright/provenance notice are in
  `rtl/imported/from-rtl-to-pixels-ad35514/`.
- Project-owned `config_a_top` is only a parameter-setting port wrapper. A has
  one functional clock, reset, RGB ready/valid, edge output and APB interface;
  it has no clock gating, UPF, isolation, PMU, or scan.
- Full clean-detached source regression passed at the accepted immutable
  commit: lint, unit, integration, 640x480 real-image, and selected formal
  targets. Both original source tops processed 307,200 input and output pixels
  with zero reference mismatches.
- Existing parameterized 32x24 top tests passed 4/4; existing streaming tests
  passed 5/5. Every frame transferred 768 pixels with zero reference
  mismatches; tests exercised reset, APB, SOF/EOL, final-output stall, source
  gaps and randomized downstream backpressure. The project-owned simulation
  runner was run successfully.
- Functional raw evidence:
  `results/raw/phase0-config-a/source-regression.log`,
  `results/raw/phase0-config-a/sim-32x24/`, and
  `results/raw/phase1-config-a/sim-runner-verify.log`.

## Frozen implementation inputs and configuration

- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Yosys: `a5af9d690a43744bf6b2cc3dea2717c16b54621c`
- Image: `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`
  (`sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`)
- Container architecture: Linux/aarch64; KLayout 0.30.12 at
  `/usr/local/klayout`.
- Platform/library: pinned ORFS SKY130HD, `sky130_fd_sc_hd`, TT 25 °C,
  1.80 V. Platform input hashes are in
  `results/processed/runtime-platform-manifest.md`.
- Implementation target: 10.30 ns. Current mission evaluation period:
  12.00 ns under reviewed decision D-014. The prior 10.50 ns mission failure
  is retained as historical evidence.
- SDC: physical `core_clock` and virtual `vclk_core_clock`; 2.06 ns input and
  output delays; 1.095 ns virtual-clock latency; 72 constrained input ports,
  46 constrained output ports; no exceptions.
- SKY130HD `DONT_USE_CELLS` policy is inherited unchanged from the pinned
  platform; no DONT_USE override was added.
- Floorplan policy: `CORE_UTILIZATION=50`,
  `PLACE_DENSITY_LB_ADDON=0.25`. Generated DIEAREA is 263.770 x 263.770 um;
  core area is 67,514.752 um^2 and its row extent is 261.28 x 258.40 um.
  Freeze this exact geometry and resolved settings for B/C/D.
- Random seed: `FLOW_DEFAULT / UNCONTROLLED`.
- Common generated input frame: source test's `rgb(f)` formula with `f=0`,
  row-major RGB888 bytes (2,304 bytes), SHA-256
  `849d123431b6d407345ffc82b34a426016b5b333058ad874e26d850bfb527f25`.
  The exact binary is retained as
  `results/raw/phase1-config-a/artifacts/activity_frame_32x24_rgb888.bin`.
- No RTL, implementation SDC, library/PDK, tool, or optimization setting was
  changed after the failure. The later read-only mission evaluation SDC
  changes only the two clock periods as documented below.

The exact project config, wrapper, mission SDC, source hashes, generated
checkpoints, reports, GDS and raw logs are retained in
`results/raw/phase1-config-a/`. Artifact hashes are in
`results/raw/phase1-config-a/artifacts/SHA256SUMS`.

## Implementation results

The pinned ORFS flow completed synthesis through detailed route, extraction,
final STA, and GDS generation. The first `make all` attempt stopped at the
KLayout executable lookup after the physical stages; the same work directory
was resumed with the already-present pinned `/usr/local/klayout`. ORFS then
completed without rerunning synthesis, placement, CTS or routing.

| Metric | Result |
|---|---:|
| Mapped sequential cells | 696 (`145 dfxtp_1`, `551 edfxtp_1`) |
| Synthesized SKY130HD mapped cell area | 34,261.61 um^2 |
| Final standard-cell instances | 3,494 |
| Final sequential cells | 696 |
| Final standard-cell area | 40,508.9 um^2 |
| Final reported utilization | 60% (50% target) |
| CTS initial functional sequential sinks | 696 |
| CTS-created clock buffers | 71 |
| Clock-tree depth | 2–3 levels; maximum level 3 |
| Final setup skew | 0.0321729 ns |
| Detailed-route wire length | 71,488 um |
| Detailed-route vias | 19,639 |
| Final TritonRoute violations | 0 |
| Final antenna net / pin violations | 0 / 0 |
| Vectorless report_power total | 0.0140082 W (estimate only) |

Final DEF die area is 263.770 x 263.770 um. The final count/area includes
physical timing repair. This exact geometry and all resolved comparison
settings are frozen for B/C/D.

## Timing

At the 10.30 ns implementation target, ORFS final report recorded WNS
`-1.04735 ns`, TNS `-10.1545 ns`, 18 setup violations and zero hold
violations. The original 10.50 ns mission evaluation on the exact final
ODB/SPEF failed with WNS/TNS `-0.847352445126 / -6.786191463470 ns`, 16 setup
endpoints, and zero hold violations. The worst path is input-to-register from
`s_tdata[12]` to `u_functional_top.u_arithmetic_elastic.m_data[22]$_DFFE_PP_`,
in path group `core_clock`; the other failing endpoints are in the same
arithmetic elastic-register cone.

Detailed path reporting attributes approximately 8.605 ns to cell arcs and
0.0097 ns to net increments, in addition to the unchanged 2.06 ns external
input delay. This is a real setup failure dominated by arithmetic logic depth
and cell delay, not a missing or disabled input constraint.

The reviewed D-014 read-only mission STA changes only the physical
`core_clock` and virtual `vclk_core_clock` periods from 10.30 to 12.00 ns in a
temporary evaluation SDC. On the same final ODB and SPEF it records:

- WNS: `+0.652646839619 ns`
- TNS: `0.000000000000 ns`
- setup/hold violations: `0 / 0`
- worst hold slack: `+0.417005389929 ns`
- max-slew/max-capacitance violations: `0 / 0`
- worst max-slew/max-capacitance margins: `+0.302656680346 ns` and
  `+0.015018520877 pF`

The evaluated SDC retains 72 input delays at 2.06 ns, 46 output delays at
2.06 ns, virtual-clock latency 1.095 ns, propagated physical `core_clock`,
and no exceptions. `check_setup -verbose` reports no constraint-setup
findings. The previously failing input-to-register path remains present and
has +0.652646839619 ns slack. Register-to-output paths remain timed; the
checked `m_tdata[0]` path has +9.642111778259 ns slack. No functional path
class was removed to obtain timing acceptance.

The A flow's `STA-0450 virtual clock vclk_core_clock can not be propagated`
warning is expected for a virtual clock with no physical network. It does not
remove the virtual I/O constraints. A retains active virtual-clock input and
output delays.

## Physical finishing and power boundary

The ORFS `all` target generated
`results/raw/phase1-config-a/artifacts/6_final.gds` before the original 10.50 ns
mission STA. After the 12.00 ns timing evaluation passed, the same GDS was
checked with the pinned SKY130HD open-source decks without rerunning any
implementation stage. GDS SHA-256 is
`f1b206d44b83de2751b649c701e8a2e4beb0609c37161b657017ea180121c9b6` and file
size is 4,125,536 bytes. Open-deck DRC returned 0 with zero report items;
open-deck LVS returned 0 and reported `Netlists match`. These are not foundry
or production sign-off.

The 14.0082 mW `report_power` result was generated during the 10.30 ns
implementation flow using default/vectorless activity at TT/1.80 V. No
VCD/SAIF was supplied. It is an estimate, not measured power or evidence of
power reduction, and is not a 12.00 ns comparative power result.

## Disposition

Configuration A **passes the reviewed 12.00 ns mission evaluation** on its
existing implementation. The 10.50 ns failure remains visible. Decision D-014
sets 12.00 ns as the common portfolio mission period and retains 10.30 ns as
the implementation target; all absolute I/O constraints and physical settings
remain unchanged. A is accepted, and its geometry/settings are frozen for
later comparisons. No implementation, RTL, or timing-repair change was made
during this read-only evaluation; B/C/D were not run.

The physical SKY130HD switch-master limitation, PMU behavior, activity-based
power reduction, DFT/ATPG, scan-mode timing, and production/foundry sign-off
remain unproven or explicitly out of scope.
