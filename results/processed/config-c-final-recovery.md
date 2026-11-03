# Configuration C — final fixed-core recovery result

**Result: `CONFIG_C = NOT_ACCEPTED`; `CONFIG_D = NOT_STARTED`.** The sole
D-016 region attempt completed global placement but failed detailed-placement
legalization. The approved fixed-core recovery budget is exhausted. No CTS,
routing, extraction, mission STA, GDS, DRC/LVS, or scan work was run for this
attempt.

## Inputs and exact delta

- Source baseline: `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`; imported RTL
  SHA256 manifest verified. C wrapper, PMU, UPF, and SDC were unchanged from
  the prior C functional/formal qualification; current input hashes are in
  the raw input manifest.
- ORFS `3a964e13f11a4e435aac01ffa14db0a7d2853720`, OpenROAD
  `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`, Yosys
  `a5af9d690a43744bf6b2cc3dea2717c16b54621c`; native Linux/arm64 image
  `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`,
  image ID `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`.
- SKY130HD library: `sky130_fd_sc_hd__tt_025C_1v80.lib`; platform and
  `DONT_USE_CELLS` policy unchanged.
- Fixed die/core: `0 0 263.770 263.770` /
  `{1.380, 2.720, 262.660, 261.120}` µm. Clock target 10.30 ns, mission
  evaluation 12.00 ns, I/O delays 2.06 ns, virtual-clock latency 1.095 ns.
  `PLACE_DENSITY=0.60`, `PLACE_DENSITY_LB_ADDON=0.25`; seed policy
  `FLOW_DEFAULT / UNCONTROLLED`.
- Sole physical delta from D-015: `PD_SW` changed to
  `{1.380, 2.720, 230.920, 261.120}` µm (499 site columns × 95 rows). This
  supersedes the D-015 proposed region for this attempt. A/B geometry was
  untouched.

## Capacity and placement evidence

The fresh floorplan log records `read_upf` hook completion, 95 rows of 568
`unithd` sites, the unchanged core box, 67,514.752 µm² core area, and the
D-016 Tcl marker with the exact region. Global placement recognized both the
top-level region and `PD_SW`. The current attempt's floorplan ODB was not
requeried for logical-switch/isolation-cell counts after detailed placement
failed; the unchanged C wrapper/UPF hashes match the prior qualified C
floorplan evidence, which recorded one logical switch intent and 37
parent-side isolation cells. In skip-I/O global-placement accounting:

| Group | Available/free area | Placement cell area | Lower bound |
|---|---:|---:|---:|
| AON/top-level | 3,862.4544 µm² | 2,498.5253 µm² | 0.65 |
| `PD_SW` | 58,342.2048 µm² | 35,640.2796 µm² | 0.61 |

At skip-I/O, ORFS calculated density `0.7474999821186066` from lower bound
`0.6499999761581421` and addon 0.25. Port buffering then removed 117 buffers
and inserted 51 input plus 53 output `sky130_fd_sc_hd__clkdlybuf4s50_1`
buffers (104 inserted total). At the full-GP density calculation the lower
bound was `0.8999999761581421`, producing target density
`0.9349999821186066`. GPL's completed top-level region report listed placed
area 4,747.9548 µm² against 3,862.4544 µm² free; the `PD_SW` report listed
35,364.4070 µm² against 58,342.2048 µm² free (minimum-feasible density
0.61). The pinned density guard did not fire, and global placement completed
at iteration 509. This does not imply detailed-placement legality.

## Stop result

The detailed placer ran its negotiation legalizer to the limit. It reported
268 remaining violations (`DPL-0701`), then placement check found 0 wrong
regions, 0 row-alignment problems, 306 site-alignment problems, 186 overlaps,
232 edge-spacing violations, and 24 padding violations. `DPL-0201` reported
placement-check failure; the stage wrote `3_5_place_dp-failed.odb` and ended
with `detail_place.tcl, 39 bad_optional_access` / Make error 2. Therefore the
physical placement gate failed. No later physical stage was run.

The existing directed C simulation and bounded 18-step safety checks remain
historical, bounded evidence for unchanged C functional/PMU/UPF sources; they
do not waive this physical failure. Physical switching is still not
implemented or claimed. No scan was inserted, and no power-reduction claim is
made.

## Reproducibility artifacts

Raw run and failure checkpoints are retained locally under
`results/raw/phase1-config-c-final-recovery/`, including the exact input
snapshot, complete ORFS flow log, detailed-placement log, and generated ODBs.
`SHA256SUMS` in that directory covers the retained run files; the `input/`
subdirectory also has its own input hashes. Raw artifacts are intentionally
excluded from Git.

**Disposition:** this was the one D-016 attempt. Do not alter the density,
core, region, seed policy, or placer to retry. C remains **NOT ACCEPTED** and D
remains **NOT STARTED**. The next step is a reviewed scope/completion decision,
not another automatic implementation attempt.
