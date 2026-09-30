# Phase-0 Power-Analysis Qualification

Status: methodology qualification only. No power-reduction claim is made.

## Pinned analysis

- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Image: `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`
- Checkpoint: preserved conventional Ibex/SKY130HD 10.30 ns final ODB,
  SDC, and SPEF
- Library: `sky130_fd_sc_hd__tt_025C_1v80.lib`

## Executed command

The pinned no-GUI OpenROAD binary reopened the final ODB, SDC, and SPEF, then
ran:

```tcl
report_activity_annotation
report_power
report_power -format json
```

Return code: `0`. Raw output is retained locally at
`results/raw/phase0-power-report-qualification.log` and is intentionally not
committed.

## Observed result

The report identified `58656` unannotated objects and emitted a vectorless
estimate:

| Group | Internal (W) | Switching (W) | Leakage (W) | Total (W) |
|---|---:|---:|---:|---:|
| Sequential | 9.87e-03 | 1.87e-03 | 2.46e-08 | 1.17e-02 |
| Combinational | 8.87e-03 | 1.82e-02 | 3.41e-08 | 2.71e-02 |
| Clock | 4.04e-03 | 3.79e-03 | 3.36e-09 | 7.83e-03 |
| Total | 2.28e-02 | 2.38e-02 | 6.21e-08 | 4.66e-02 |

The unannotated count and absence of a VCD/SAIF input mean this is a
`POWER-ESTIMATE-VECTORLESS` result, not measured activity and not evidence of
power reduction.

## Fair A/B/C/D methodology

Later comparisons must hold constant the accepted RTL, tool/image/platform
hashes, corner/library, voltage, evaluation period, geometry, utilization,
timing constraints, reporting stage, and analysis script. They must use one
identical workload/activity source. If VCD or SAIF is later used, the exact
supported import command, stimulus provenance, annotation coverage, and
unannotated count must be recorded for every configuration. If vectorless
analysis is used, default activity assumptions must remain identical and the
result must be labeled an estimate.

The pinned executable supports the OpenSTA activity interfaces in source, but
this qualification did not invent or import an activity file. Activity-based
comparison remains unproven.
