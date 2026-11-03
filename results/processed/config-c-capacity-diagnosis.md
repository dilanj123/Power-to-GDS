# Configuration C — fixed-core placement-capacity diagnosis

**Original diagnosis: `FEASIBLE_REGION_IDENTIFIED`.** Its one row/site-aligned
`PD_SW` split had an area-based capacity case, but the estimate did not prove
placement feasibility. The region was later tested under D-016 and failed
detailed placement; see `results/processed/config-c-final-recovery.md`. C
remains **NOT ACCEPTED** and D remains **NOT STARTED**. The D-016 recovery
budget is exhausted.

## Scope and provenance

This was a read-only diagnosis. No synthesis or placement stage was run, and
no RTL, UPF, domain coordinates, density setting, core geometry, or tool input
was changed. The recovered C retry logs and checkpoints were checked against
the 50-entry manifest at `results/raw/phase1-config-c-recovery/SHA256SUMS`;
all entries verified. The earlier C attempt had no contemporaneous checksum
manifest, so the relevant older logs and ODBs are now hashed in
`results/raw/phase1-config-c-capacity-diagnosis/SHA256SUMS`.

The pinned ORFS checkout is clean at
`3a964e13f11a4e435aac01ffa14db0a7d2853720`; OpenROAD is
`4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`. The arm64 image ID is
`sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`.
The failed-retry ODB hash is
`324dae30e4fa614a15e9d1e0469317ff2bb2b537137e2048f0cca7a07b061739`.
Read-only OpenROAD Tcl query scripts and their outputs are in the same
diagnostic raw directory. Source and raw evidence hashes are recorded in its
two manifests.

## Pinned density rule and exact failure value

Pinned `flow/scripts/util.tcl`, procedure `place_density_with_lb_addon`,
computes:

```text
target = lower_bound + (1 - lower_bound) * PLACE_DENSITY_LB_ADDON + 0.01
```

It raises `FLW-0024` when `target > 1.0`. The retry used the unchanged
`PLACE_DENSITY_LB_ADDON=0.25`. The skip-I/O run had lower bound
`0.7599999904632568`, target `0.8299999928474426`, and completed. After
port-buffer processing, the saved failed ODB was queried with the pinned
`gpl::get_global_placement_uniform_density -pad_left 0 -pad_right 0` API.
That query returned the exact lower bound `1.0499999523162842`; the formula
then gives target `1.0474999642372131`, so the guard fails. No
`global_placement` command or placement optimization was run for this query.

This is a density-capacity guard, not a RePlAce divergence. The separate
no-area diagnostic's `GPL-0324`/`GPL-0307` failure remains a distinct result.
Reducing the addon is not considered an acceptable fix here.

## Measured area and row capacity

The frozen core is `(1.380, 2.720)` to `(262.660, 261.120)` µm: 568 sites
across and 95 rows. A SKY130HD `unithd` site is 0.46 × 2.72 µm, or
1.2512 µm². The retry region used 504 `PD_SW` columns; its geometric
right-side complement was 64 columns.

| Quantity | Measured value | Evidence interpretation |
|---|---:|---|
| `PD_SW` mapped cell area at floorplan | 34,506.845 µm² | ODB master-area sum |
| AON/top raw movable cell area before port-buffer stage | 2,014.432 µm² | `3_2_place_iop.odb` master-area sum, excluding fixed taps |
| `PD_SW` movable area at skip-I/O GPL | 35,640.280 µm² | GPL placement area after its sizing/pin-density adjustments |
| `PD_SW` available area at skip-I/O GPL | 58,936.525 µm² | GPL reported free area; lower bound 0.61 |
| AON/top movable area at skip-I/O GPL, before port-buffer step | 2,498.525 µm² | GPL placement area, not raw ODB area |
| AON/top available area before port-buffer step | 3,328.192 µm² | GPL reported free area; lower bound 0.76 |
| Whole-design pin-density area adjustment at skip-I/O | 1,617.528 µm² | GPL-0035; placement-dimension adjustment, not physical ODB cell area |
| AON/top raw movable area in failed post-buffer ODB | 2,979.107 µm² | ODB master-area sum, buffers included |
| `PD_SW` raw cell area in failed post-buffer ODB | 34,036.394 µm² | ODB master-area sum after buffer removal |
| Port buffers inserted | 104; 1,040.998 µm² | 51 input + 53 output `sky130_fd_sc_hd__clkdlybuf4s50_1` cells |
| Earlier buffers removed in that step | 117 | Exact count from RSZ-0026; removed-cell area is not separately logged |

The floorplan ODB has 37 parent-side isolation cells, totaling 231.472 µm²;
these are part of AON/top-level logic. The reported AON raw area includes the
post-buffer design state. Comparing the skip-I/O adjusted area to the failed
ODB raw area directly would mix unlike area measures.

The failed ODB contains 190 row segments: two segments at each of the 95 row
heights. The site query found 532 usable sites per row: 504 in the
`PD_SW`-aligned segment and 28 in the right-side AON segment. Thus 36 sites
(16.56 µm) per row are absent from the row objects between those segments:
3,420 sites or 4,279.104 µm² across the core. The current right-side AON row
capacity is exactly `28 × 95 × 1.2512 = 3,328.192 µm²`, matching GPL's
reported free area. The ODB proves this row/site exclusion; it does not
identify why OpenROAD produced that gap. No additional row-height loss was
observed. Macro area is zero. The recorded global-placement calls used
`-pad_left 0 -pad_right 0`; cell padding does not account for the 36-site gap.
Tap/fixed-cell overlap is included in the recorded GPL free-area values where
reported; do not subtract it a second time from those values.

The exact post-buffer lower bound is higher than the raw cell-area ratio
`2,979.107 / 3,328.192 = 0.895`. GPL's lower bound accounts for its
placement-adjusted cell dimensions; the pinned source extends eligible cells
for average signal-pin density. The measured lower bound corresponds to an
area-equivalent placement demand of about 3,494.601 µm² at the current AON
capacity. This is a derived density-equivalent value, not additional physical
standard-cell area.

## One area-supported candidate (not tested)

Propose only this candidate for any separately authorized future decision:

```text
PD_SW = {1.380, 2.720, 230.920, 261.120} um
```

This is 499 site columns and all 95 rows, inside the unchanged core. It moves
the existing boundary left by five sites. If the observed 36-site row gap
persists, the 69-column geometric complement leaves 33 actual AON row sites
per row, or `33 × 95 × 1.2512 = 3,922.512 µm²` of AON row area.

The area-only capacity check is:

| Domain | Estimated available area | Measured placement demand | Estimated occupancy |
|---|---:|---:|---:|
| `PD_SW` | 58,342.205 µm² (`59,313.136` gross less 970.931 fixed overlap) | 35,640.280 µm² GPL-adjusted | 61.09% |
| AON | 3,922.512 µm² from 33 row sites/row | 2,979.107 µm² raw post-buffer cells | 75.95% |

For AON, scaling the measured density-equivalent demand from the failed
28-site region gives a projected lower bound of about `0.8909` and an ORFS
helper target of about `0.9282`. The unadjusted raw-cell area leaves about
943.405 µm² (24.05%) of row-area headroom; the density-equivalent estimate
leaves about 427.911 µm² (10.91%). The PD_SW area estimate remains close to
the retry's measured minimum-feasible density (`0.61`). These values provide
a defensible **area-based** split for both domains without changing the A/B
core or frozen placement settings.

This calculation assumes the 36-site gap stays constant when the boundary
moves and that GPL's pin-density adjustment scales similarly. Neither has
been validated for the proposed boundary, and a feasible area budget does
not prove RePlAce convergence, legal placement, timing, or routability.

## Decision and limits

`FEASIBLE_REGION_IDENTIFIED` means the proposed split was supported by
measured row/cell-area accounting; that estimate was not a C pass. At the
time, this diagnosis did not authorize an implementation. D-016 later
authorized one test, which failed detailed placement. C remains **NOT
ACCEPTED**; D remains **NOT STARTED**. Physical power switching, routed C
isolation, mission timing, GDS/DRC/LVS for C, and matched activity-based
power remain unproven.

The original recommendation to review whether to test this region was
superseded by D-016. That single attempt is now exhausted; do not reduce the
density addon, resize the core, change the region or seed, or tune the placer.
Any further C work requires a new reviewed scope decision.

## Follow-up — D-016 physical test

D-016 later authorized one fresh attempt using the candidate region described
above. Skip-I/O placement, I/O placement, and full global placement completed;
detailed placement did not converge and failed its placement check. The final
attempt record and raw logs are linked above. This outcome supersedes the
original “not physically tested” status without changing the measured
read-only analysis in this diagnosis.

The master-plan and operating-instruction status summaries were updated when
D-016 was authorized and again after the final attempt result.
