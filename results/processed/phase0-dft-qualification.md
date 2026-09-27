# POWER-000 — pinned SKY130HD DFT/scan capability

Qualification date: 2026-09-28

## Result

Classification: **A**.

The pinned OpenROAD build executes scan replacement and scan-chain planning/stitching, and the actual pinned ORFS SKY130HD platform provides compatible scan-cell Liberty, LEF, and CDL views with the metadata consumed by OpenROAD. Project-owned ORFS scan integration is technically testable. This is a capability qualification, not an ATPG, coverage, timing, DRC/LVS, or production-DFT result.

Pinned revisions:

- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Execution: native Apple-Silicon host, Linux/arm64 Docker, no-GUI image `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109` (arm64 image ID `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`)
- OpenROAD self-version banner: `unknown`; source and image provenance above are pinned.

## Supported interface and source evidence

The pinned `tools/OpenROAD/src/dft/README.md` and `src/dft/src/dft.tcl` document and expose:

```tcl
set_dft_config [-max_length <int>] [-max_chains <int>] \
  [-clock_mixing <no_mix|clock_mix>] \
  [-scan_enable_name_pattern <pattern>] \
  [-scan_in_name_pattern <pattern>] \
  [-scan_out_name_pattern <pattern>]
report_dft_config
scan_replace
report_dft_plan [-verbose]
execute_dft_plan
scan_opt
```

The README says `scan_replace` replaces flops with equivalent scan flops before placement; `report_dft_plan` previews chains without modifying the design after replacement and global placement; `execute_dft_plan` architects and connects chains after placement and replacement. `scan_opt` is explicitly documented as not implemented and a no-op. The documented limitations are no scan-chain optimization, no user-defined scan path, no reuse of existing scan ports, and one-bit cells only.

The implementation corroborates this boundary: `src/dft/src/utils/Utils.cpp` identifies a scan cell through Liberty `test_cell` metadata with scan-in and scan-enable signals; `ScanReplace.cpp` checks functional and power/ground port equivalence and allows only extra scan-signals; `OneBitScanCell.cpp` returns one bit and connects scan enable, scan in, and scan out. No source/README conflict was found.

## Actual ORFS SKY130HD library inventory

The platform files inspected were:

- `flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib`
- `flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef`
- `flow/platforms/sky130hd/cdl/sky130hd.cdl`

The Liberty contains 24 scan-capable `test_cell` masters. Every one has Liberty + LEF + CDL views and none is in the effective SKY130HD `DONT_USE_CELLS` list. The families and direct normal-cell candidates are:

| Scan family | Normal-cell family | Variants present |
| --- | --- | --- |
| `sdfbbn` / `sdfbbp` | `dfbbn` / `dfbbp` | 1, 2 |
| `sdfrbp` / `sdfrtn` / `sdfrtp` | `dfrbp` / `dfrtn` / `dfrtp` | 1, 2, 4 where present |
| `sdfsbp` / `sdfstp` | `dfsbp` / `dfstp` | 1, 2, 4 where present |
| `sdfxbp` / `sdfxtp` | `dfxbp` / `dfxtp` | 1, 2, 4 where present |
| `sedfxbp` / `sedfxtp` | `edfxbp` / `edfxtp` | 1, 2, 4 where present |

Representative required candidate `sky130_fd_sc_hd__sdfsbp_1`:

- normal candidate: `sky130_fd_sc_hd__dfsbp_1`; the executable one-cell test replaces `sky130_fd_sc_hd__dfstp_1` with it because the functional equations and port behavior are equivalent under the pinned Liberty data;
- area: `36.2848` Liberty area units;
- scan pins: `SCD` = `test_scan_in`, `SCE` = `test_scan_enable`, `Q` = `test_scan_out`, `Q_N` = `test_scan_out_inverted`;
- functional pins: `CLK`, `D`, `SET_B`, `Q`, `Q_N`; clocked on rising `CLK`, preset `!SET_B`;
- scan next-state equation: `(D&!SCE) | (SCD&SCE)`;
- views: Liberty, merged LEF, and CDL all present;
- `DONT_USE_CELLS`: not excluded.

The scan metadata is explicit Liberty `test_cell`/`signal_type` metadata, not a name-only inference. The platform policy in `flow/platforms/sky130hd/config.mk` excludes probe and `lpflow` cells, not these scan masters; no DONT_USE policy was changed.

## Executed regression evidence

### One-cell

`tools/OpenROAD/src/dft/test/one_cell_sky130.tcl` returned **0**. Both golden comparisons printed `No differences found.` It performed:

- `sky130_fd_sc_hd__dfstp_1` → `sky130_fd_sc_hd__sdfsbp_1` replacement;
- one chain, one scan cell/bit;
- generated `scan_enable_0` and `scan_in_0` inputs;
- generated Verilog contains `sky130_fd_sc_hd__sdfsbp_1` with `SCD(scan_in_0)` and `SCE(scan_enable_0)`;
- generated DEF contains `SCANCHAINS 1`, start pin `scan_in_0`, cell `ff1 (IN SCD) (OUT Q)`, and stop pin `output1`.

The upstream test resolves `sky130hd` to the OpenROAD test-library copy. The independent disposable smoke loaded the actual ORFS SKY130HD Liberty and LEF and reproduced the same replacement, ports, and `SCANCHAINS 1` output; the actual platform CDL was independently present.

### Multi-cell architecture

`tools/OpenROAD/src/dft/test/scan_architect_no_mix_sky130.tcl` returned **0**. Both preview/final golden comparisons printed `No differences found.` The report preview created four no-mix chains of five cells/five bits each (20 cells total), split across clock1/clock2 and rising/falling edges. The before-preview and after-preview Verilog files were identical, proving `report_dft_plan` did not modify the netlist. The final Verilog contains stitched intermediate `SCD` connections, four `scan_in_*` ports, and shared `scan_enable_0`, proving `execute_dft_plan` changed the connectivity.

Raw captures are retained but ignored by Git:

- `results/raw/phase0-dft-one-cell-regression.log`
- `results/raw/phase0-dft-scan-architect-regression.log`

## ORFS integration inventory (not executed)

Pinned ORFS exposes the generic hook mechanism `source_step_tcl`, implemented in `flow/scripts/util.tcl` as `${hook_type}_${step_name}_TCL`, and documented in `flow/scripts/variables.json`.

- `scan_replace`: candidate hook `POST_SYNTH_TCL`, after `load_design 1_2_yosys.v 1_2_yosys.sdc` and before `orfs_write_db .../1_synth.odb` in `synth_odb.tcl`. This is before placement and its mutation persists in the `1_synth.odb` checkpoint.
- `report_dft_plan` / `execute_dft_plan`: candidate hook `POST_GLOBAL_PLACE_TCL`, after global placement and before `orfs_write_db .../3_3_place_gp.odb` in `global_place.tcl`; placement information exists at this point. The later `POST_DETAIL_PLACE_TCL` and `POST_CTS_TCL` hooks are also real, but the DFT README specifically calls for planning after global placement and execution after placement.

The flow ordering in `flow/scripts/flow.tcl` is synthesis → floorplan → placement (`global_place` then resize/detail place) → CTS → route. These hooks permit a project-owned experiment without patching frozen ORFS, but no project scan insertion was run in this qualification.

## Proven and not proven

Proven with this qualification: scan-cell replacement, Liberty-driven scan equivalence detection, scan-chain architecture, scan-chain stitching, scan ports, DEF `SCANCHAINS` metadata, and actual-platform one-cell realization.

Not proven or provided: ATPG, stuck-at or transition-fault analysis, fault simulation, any test coverage, pattern generation, tester qualification, manufacturing coverage, production DFT sign-off, physical implementation survival of a project scan experiment, or scan optimization (`scan_opt` is a no-op). No project RTL or main design was modified.

Next smallest experiment: a disposable project-owned ORFS hook test on an existing synthesized checkpoint using `POST_SYNTH_TCL` for `scan_replace`, followed by a separate placement-stage hook test using `POST_GLOBAL_PLACE_TCL` for plan/report/execute and checkpoint inspection. This should remain isolated from the main design until separately authorized.
