# Configuration A — conventional ASIC baseline

Status: **FAIL_TIMING — Configuration A is not accepted or frozen as the
A/B/C/D comparison baseline.** Gate 0 and Gate 1 remain PASS; the first
portfolio Configuration A failed the frozen mission timing requirement.
Configurations B/C/D are not authorized by this result.

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
- Platform/library: pinned ORFS SKY130HD, `sky130_fd_sc_hd`, TT 0.025 C,
  1.80 V. Platform input hashes are in
  `results/processed/runtime-platform-manifest.md`.
- Implementation target: 10.30 ns. Mission evaluation period: 10.50 ns.
- SDC: physical `core_clock` and virtual `vclk_core_clock`; 2.06 ns input and
  output delays; 1.095 ns virtual-clock latency; 72 constrained input ports,
  46 constrained output ports; no exceptions.
- SKY130HD `DONT_USE_CELLS` policy is inherited unchanged from the pinned
  platform; no DONT_USE override was added.
- Floorplan policy: `CORE_UTILIZATION=50`,
  `PLACE_DENSITY_LB_ADDON=0.25`. Generated DIEAREA is 263.770 x 263.770 um;
  placement rows span 261.28 x 258.40 um (core area 67,514.752 um^2).
  Geometry is recorded for this failed A run and is not frozen for B/C/D.
- Random seed: `FLOW_DEFAULT / UNCONTROLLED`.
- Common generated input frame: source test's `rgb(f)` formula with `f=0`,
  row-major RGB888 bytes (2,304 bytes), SHA-256
  `849d123431b6d407345ffc82b34a426016b5b333058ad874e26d850bfb527f25`.
  The exact binary is retained as
  `results/raw/phase1-config-a/artifacts/activity_frame_32x24_rgb888.bin`.
- No RTL, SDC, library/PDK, tool, timing, or optimization correction was
  applied after the failure.

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
physical timing repair; these are measured outputs, not fixed inputs for later
comparisons because A failed.

## Timing

At the 10.30 ns implementation target, ORFS final report recorded WNS
`-1.04735 ns`, TNS `-10.1545 ns`, 18 setup violations and zero hold
violations. At the 10.50 ns mission evaluation period, read-only STA on the
exact final ODB/SPEF recorded:

- WNS: `-0.847352445126 ns`
- TNS: `-6.786191463470 ns`
- setup violations: 16 distinct endpoints
- hold violations: 0
- max-slew violations: 0
- max-capacitance violations: 0

The worst path is input-to-register from `s_tdata[12]` to
`u_functional_top.u_arithmetic_elastic.m_data[22]$_DFFE_PP_`, in path group
`core_clock`. The other failing endpoints are in the same arithmetic elastic
register cone. This is a measured logic-depth/cell-delay failure, not an I/O
path that was removed from analysis. The read-only mission SDC differs from
`6_final.sdc` only in the two clock periods (10.30 to 10.50 ns); I/O delays,
latency, propagated physical core clock, and exceptions are unchanged. The STA
report includes timed reg-to-output paths to `m_tdata`, `m_tvalid`, and `prdata`
in `vclk_core_clock`.

ORFS logged `STA-0450 virtual clock vclk_core_clock can not be propagated`.
This is expected for a virtual clock with no physical network. It does not
remove I/O constraints: both input-to-register paths and reg-to-output paths
are reported. No false paths or multicycle paths were used.

## Physical finishing and power boundary

The ORFS `all` target's `finish` dependency generated
`results/raw/phase1-config-a/artifacts/6_final.gds` before the separate 10.50 ns
mission STA was run. This was an automatic make-target consequence; the GDS is
retained as raw evidence and is not accepted as successful baseline finishing.
Its SHA-256 is
`f1b206d44b83de2751b649c701e8a2e4beb0609c37161b657017ea180121c9b6` and file
size is 4,125,536 bytes. Since mission timing failed, KLayout DRC and LVS were
not run. GDS existence is not a physical-clean or sign-off claim.

The 14.0082 mW `report_power` result uses default/vectorless activity at the
flow's TT/1.80 V corner. No VCD/SAIF was supplied. It is an estimate, not
measured power and not evidence of power reduction.

## Disposition

Configuration A **fails the frozen 10.50 ns mission timing acceptance** and is
not the comparison baseline. The route itself completed with zero detailed
route and antenna violations, and the functional tests pass, but those facts
do not override setup timing failure. No clearly justified project-owned
integration/configuration correction can fix the measured deep datapath path
without changing a frozen constraint/implementation control or the imported
RTL, so no correction was attempted. Stop before B/C/D and return for a new
engineering decision on an allowed timing strategy.

The physical SKY130HD switch-master limitation, PMU behavior, activity-based
power reduction, DFT/ATPG, scan-mode timing, and production/foundry sign-off
remain unproven or explicitly out of scope.
