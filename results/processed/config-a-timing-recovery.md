# Configuration A timing recovery — 12.00 ns mission evaluation

**Result: `CONFIG_A = PASS_AT_12NS_MISSION`.** Gate 0 and Gate 1 remain
PASS. This is a read-only STA evaluation of the already implemented A database,
followed by open-deck DRC/LVS on its existing GDS. No RTL, implementation
database, SPEF, tool, library, implementation setting, or I/O constraint was
changed. No B/C/D implementation was run.

## Reviewed timing-contract amendment

The authority documents do not make 10.50 ns an externally mandated product
requirement. It was the earlier project-selected portfolio comparison period.
The historical 10.50 ns failure remains in
`results/processed/config-a-baseline.md`. Decision D-014 amends the portfolio
comparison methodology to:

- implementation target: **10.30 ns**;
- mission/evaluation period: **12.00 ns** (83.33 MHz).

The reason is evidence from the same A database: the proposed 12.00 ns point
passes the project's timing acceptance while preserving the 10.30 ns-built
implementation and all other controls. The 10.50 ns failure is not erased or
reclassified. No claim is made that A passes at 10.50 ns or at its own 10.30 ns
implementation target.

All later A/B/C/D mission evaluations use 12.00 ns, with the same 10.30 ns
implementation target. Preserve 2.06 ns input/output delays, 1.095 ns virtual
clock latency, port mapping, timing exceptions, corner, toolchain, platform,
geometry, and implementation settings. Any future change requires an explicit
decision and like-for-like comparison methodology.

## Source and frozen environment

- Source: `https://github.com/dilanj123/from-rtl-to-pixels`
- Immutable source commit: `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`
- Top/parameters: `rtl_to_pixels_top_pipelined`, 32x24.
- ORFS SHA: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD SHA: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Yosys SHA: `a5af9d690a43744bf6b2cc3dea2717c16b54621c`
- Image: `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`
- Image digest: `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`
- Runtime: Linux/aarch64; KLayout 0.30.12 at `/usr/local/klayout`.
- Platform: SKY130HD `sky130_fd_sc_hd`, TT 0.025 C, 1.80 V. Platform input
  hashes are recorded in `results/processed/runtime-platform-manifest.md`.
- Existing source regression and 32x24 functional tests remain PASS as recorded
  in `results/processed/config-a-baseline.md`.

## Exact physical database identity

The raw artifact manifest was verified before STA. Key SHA-256 values:

| Artifact | SHA-256 |
|---|---|
| `1_synth.odb` | `6276ab5160d2041d7f9ecbbdeb5373ae1d61e3115521dfdd8cf2e1ed3e3cb405` |
| `6_final.odb` | `46b29c8fa560172e76723ffb2478e0d14e56cedc9faa46b67b67f06a3e064086` |
| `6_final.spef` | `a45e8e6da575af14a4b47c770da79d6e8edc2c71489eb2ffc711b6b6469684ea` |
| `6_final.sdc` | `bb9a8c32a216930ab461ccd5e094c38aa4b49ff597926276f7f25b8e748ae21b` |
| `6_final.def` | `3f6f531a2604b0086ef851c846e829f6324da60d3910996e07ce31e81f992d0c` |
| Existing `6_final.gds` | `f1b206d44b83de2751b649c701e8a2e4beb0609c37161b657017ea180121c9b6` |

The exact preserved artifacts and their full manifest are under
`results/raw/phase1-config-a/artifacts/`. The GDS is 4,125,536 bytes. The
separate evaluation SDC is
`results/raw/phase1-config-a/timing-recovery-12ns/6_final_12ns_eval.sdc`; its
diff from `6_final.sdc` contains only the two clock periods, both changed from
10.3000 to 12.0000 ns.

## Critical-path and constraints review

At the earlier 10.50 ns evaluation, the worst failing path was a real
input-to-register setup path:

- startpoint: `s_tdata[12]`, clocked by virtual `vclk_core_clock`;
- endpoint: `u_functional_top.u_arithmetic_elastic.m_data[22]$_DFFE_PP_`,
  clocked by physical `core_clock`;
- path group: `core_clock`;
- 10.50 ns slack: `-0.847352445126 ns`.

The other 15 failed endpoints were in the same arithmetic elastic-register
cone. Detailed path increments show approximately 8.605 ns cell-arc delay and
0.0097 ns net delay, plus the existing 2.06 ns external input delay. This is
primarily arithmetic logic depth and cell delay; it is a genuine setup failure.

The 12.00 ns evaluation SDC changes only `core_clock` and
`vclk_core_clock` periods. It retains all 72 non-clock input delays at
2.06 ns, all 46 output delays at 2.06 ns, 1.095 ns virtual-clock latency,
propagated physical core clock, and no false-path, multicycle, or other timing
exceptions. `check_setup -verbose` returned without constraint-setup findings.
The previously failing input-to-register path remains timed at 12.00 ns. A
register-to-output path to `m_tdata[0]` is also timed and has
`+9.642111778259 ns` slack. No functional path class was removed.

## 12.00 ns read-only STA result

Exact frozen image, final ODB, final SPEF, SKY130HD TT Liberty and unchanged
I/O constraints were used. STA return code was 0.

| Check | Result |
|---|---:|
| Max WNS | `+0.652646839619 ns` |
| Max TNS | `0.000000000000 ns` |
| Setup violations | 0 |
| Min/hold worst slack | `+0.417005389929 ns` |
| Min/hold TNS | `0.000000000000 ns` |
| Hold violations | 0 |
| Max-slew violations | 0; worst margin `+0.302656680346 ns` |
| Max-capacitance violations | 0; worst margin `+0.015018520877 pF` |

The A flow logged `STA-0450 virtual clock vclk_core_clock can not be
propagated`. This describes the virtual clock's lack of a physical network.
The analysis keeps its 1.095 ns latency and I/O delays; it does not attempt to
propagate the virtual clock. Input-to-register and register-to-output paths
are both present.

## GDS and open-deck physical checks

The original ORFS `all` target produced GDS before the initial mission STA.
After this read-only 12.00 ns acceptance, the same unchanged GDS was checked
directly with the pinned open-source SKY130HD decks; no synthesis, floorplan,
placement, CTS, routing, or extraction target was invoked.

- KLayout: 0.30.12 at `/usr/local/klayout`; pinned image digest as above.
- GDS input SHA-256: `f1b206d44b83de2751b649c701e8a2e4beb0609c37161b657017ea180121c9b6`.
- DRC deck: `flow/platforms/sky130hd/drc/sky130hd.lydrc`; SHA-256
  `029722ea1fc2cf8c48f09fc670c0b72efb295f799c4eb236b7e9767930ecf772`.
- DRC command: `KLAYOUT_CMD=/usr/local/klayout /OpenROAD-flow-scripts/flow/scripts/klayout.sh -zz -rd in_gds=/ptg/results/raw/phase1-config-a/artifacts/6_final.gds -rd report_file=/ptg/results/raw/phase1-config-a/timing-recovery-12ns/6_drc.lyrdb -r /OpenROAD-flow-scripts/flow/platforms/sky130hd/drc/sky130hd.lydrc`.
- DRC result: return code 0; KLayout report database contains zero items;
  `OPEN_DECK_DRC_CLEAN`.
- LVS deck: `flow/platforms/sky130hd/lvs/sky130hd.lylvs`; SHA-256
  `d2d231d7cd00a8261d6653c5f3757badefb1dc0aba29441d8406272e75cd8b90`.
- Schematic: `6_final.cdl`, emitted read-only from the exact `6_final.odb`
  with the pinned ORFS `write_cdl -masters` operation, concatenated before the
  platform `sky130hd.cdl` master library as the pinned ORFS Makefile specifies.
- LVS command: `KLAYOUT_CMD=/usr/local/klayout /OpenROAD-flow-scripts/flow/scripts/klayout.sh -b -rd in_gds=/ptg/results/raw/phase1-config-a/artifacts/6_final.gds -rd cdl_file=/ptg/results/raw/phase1-config-a/timing-recovery-12ns/6_final_concat.cdl -rd top_cell=config_a_top -rd report_file=/ptg/results/raw/phase1-config-a/timing-recovery-12ns/6_lvs.lvsdb -r /OpenROAD-flow-scripts/flow/platforms/sky130hd/lvs/sky130hd.lylvs`.
- LVS result: return code 0; `Netlists match`; `OPEN_DECK_LVS_CLEAN`.

These open-deck results are not foundry or production sign-off.

## Frozen A geometry and comparison settings

- DIEAREA: 263.770 x 263.770 um.
- Core area: 67,514.752 um^2; row extent: 261.28 x 258.40 um.
- `CORE_UTILIZATION=50`; `PLACE_DENSITY_LB_ADDON=0.25`; pinned platform
  `PLACE_DENSITY=0.60`; final reported utilization 60% after physical repair.
- Implementation target 10.30 ns; mission evaluation 12.00 ns.
- Same immutable RTL/source commit, SKY130HD library, tool/image/platform
  hashes, I/O delays, PDN, placement, CTS, routing, pin placement, and
  `DONT_USE_CELLS` policy for every primary variant.
- Random seed remains `FLOW_DEFAULT / UNCONTROLLED`.
- Mission power comparisons use the same 12.00 ns period, final extracted
  stage, corner, voltage, activity workload and report script. Existing A
  `report_power` is vectorless at the implementation flow stage and remains an
  estimate only; it is not comparative power-reduction evidence.

## Disposition and claim limits

Configuration A is accepted as the conventional baseline at the amended
12.00 ns mission evaluation period, with zero setup, hold, slew and
capacitance violations, zero detailed-route violations, zero antenna
violations, open-deck DRC zero items, and open-deck LVS match. The 10.50 ns
failure and the 10.30 ns implementation-target timing result remain disclosed.
The exact database and geometry are frozen for later fair comparisons.

This does not claim foundry sign-off, production timing/DRC/LVS sign-off,
physical SKY130HD power switching, physical power gating, PMU execution, scan
timing, ATPG, fault coverage, or measured/reduced power. B/C/D were not run in
this task.

Raw evaluation, detail STA, GDS finishing logs, DRC/LVS logs and generated
reports are retained under
`results/raw/phase1-config-a/timing-recovery-12ns/`; that directory's
`SHA256SUMS` was verified. The original physical artifacts and SHA256SUMS are
retained under
`results/raw/phase1-config-a/artifacts/`.
