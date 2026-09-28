# POWER-000 — project-owned ORFS scan-integration smoke

Qualification date: 2026-09-28

## Result

**PASS**, limited to project-owned scan replacement, placement-stage chain
stitching, ODB/Verilog/DEF persistence, and detailed placement of the scan
cells. This is not an ATPG, fault-coverage, timing, routing, or production-DFT
qualification.

Pinned revisions:

- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Image: `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`, Linux/arm64, no-GUI

## Smoke design and hooks

The isolated design is `flow/phase0/dft-scan-smoke/ptg_dft_scan_smoke.v`:
one clocked 12-bit observable register, reset, serial input, and parallel
observable output. It is not imported portfolio RTL and no existing UPF smoke
was changed.

The SDC contains only:

```tcl
create_clock -name clk -period 10.0 [get_ports clk]
```

`POST_SYNTH_TCL` runs `set_dft_config -max_length 8 -clock_mixing no_mix`,
`report_dft_config`, and `scan_replace` before ORFS writes `1_synth.odb`.
`POST_GLOBAL_PLACE_TCL` runs `report_dft_config`,
`report_dft_plan -verbose`, and `execute_dft_plan` after global placement and
before ORFS writes `3_3_place_gp.odb`. `scan_opt` was not run.

## Checkpoint evidence

| Checkpoint | Evidence after reopening |
| --- | --- |
| `1_synth.odb` | 12 scan flops, 0 normal flops, master `sky130_fd_sc_hd__sdfxtp_1`; replacement persisted; no scan ports yet |
| `3_3_place_gp.odb` | 12 scan flops, all placed; `scan_in_0`, `scan_enable_0`, `scan_out_0`; DEF `SCANCHAINS 1` with 12 ordered cells |
| `3_5_place_dp.odb` | 12 scan flops, all placed; same three scan ports; same 12-cell `SCANCHAINS 1` topology |

The original mapped netlist contained 12 `sky130_fd_sc_hd__dfxtp_1` flops.
The synthesis checkpoint contains 12 actual SKY130HD scan masters:
`sky130_fd_sc_hd__sdfxtp_1`. No normal sequential master remained.

The reopened global-placement and detailed-placement DEFs both contain:

- `SCANCHAINS 1`;
- chain start `scan_in_0`;
- 12 ordered scan cells using `(IN SCD) (OUT Q)`;
- chain stop `scan_out_0`;
- shared scan enable net `scan_enable_0` connected to `SCE`.

The post-global-placement and post-detailed-placement Verilog files contain
the same scan master, `SCD` chain connections, `SCE` scan-enable connections,
and `scan_out_0` termination.

## Detailed-placement result

The ORFS `3_5_place_dp` stage returned `0`. Placement analysis reported zero:

- cells in wrong regions;
- row-alignment problems;
- site-alignment problems;
- overlaps;
- edge-spacing violations;
- padding violations.

OpenROAD emitted DPL-0387 warnings that the three new scan BTerms were
unplaced. This smoke did not run I/O placement; the 12 scan cells themselves
were all `PLACED`, and this result must not be read as proof of scan-port
physical routability.

## Timing handling

No timing exception was added. The smoke SDC defines only the functional clock;
scan ports are created after synthesis, and the flow reports missing I/O
delays/unconstrained endpoints after insertion. Adding a broad false path would
mask behavior rather than qualify it, so no `set_false_path` was used. Scan-
mode timing and test-mode timing closure remain unproven.

## Scope

This proves that a separate project-owned ORFS design can persist scan-cell
replacement into synthesis, carry the actual SKY130HD scan masters through
global placement, report and execute a one-chain plan at the placement hook,
persist scan ports/connectivity and DEF scan-chain metadata into reopened
checkpoints, and retain the topology through detailed placement.

It does not prove ATPG, stuck-at or transition-fault analysis, fault
simulation, test coverage, pattern generation, tester qualification,
manufacturing coverage, production DFT sign-off, scan-port placement/routing,
CTS/routing survival, or timing closure.

Raw evidence and working implementation data are retained under ignored paths:

- `results/raw/phase0-dft-project-scan-smoke.log`
- `results/raw/phase0-dft-scan-work/`
