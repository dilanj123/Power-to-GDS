# Configuration C placement root-cause audit

**Disposition unchanged:** A and B remain accepted; C remains **NOT
ACCEPTED**; D remains **NOT STARTED**. The reduced-scope portfolio verdict
remains `REDUCED_SCOPE_CV_READY_WITH_LIMITATIONS`. This is an evidence audit;
no synthesis, global placement, detailed placement, optimization, or C recovery
was run. The only OpenROAD operations used for this audit were read-only ODB
loads, database queries, and `check_placement` on the saved failed ODB.

## Executive diagnosis

The strongest demonstrated physical cause is insufficient AON/top legal row
capacity after D-016's timing-driven global-placement repair. The AON strip has
3,862.4544 µm² of free legal row area, but the saved post-GP ODB contains
4,262.8384 µm² of movable AON/top standard-cell master area: a 400.3840 µm²
or 10.37% deficit before any edge-spacing or legalization overhead. GPL's
internal pin-density-adjusted demand is still higher, 4,747.9548 µm². Thus the
completed global placement is not evidence that its cells can be legally
packed. Detailed placement first left 268 negotiation-legalizer violations;
its subsequent improvement/check reported illegal placement, concentrated in
the named AON/top edge-spacing list.

The 36-site row exclusion is independently explained by pinned OpenROAD's
default power-domain gap: six SKY130HD site heights is 16.32 µm, then the
right row start is snapped to a 0.46 µm site grid, giving 16.56 µm = 36 sites.
Across 95 rows that removes 4,279.104 µm² from legal row space. This is an
intended default domain-separation margin plus grid rounding, not tap cells.

`bad_optional_access` occurs after the legalizer has already failed. The log
places the C++ exception inside the `optimize_mirroring` command sequence, but
does not contain an inner stack/callsite. It may be a secondary tool defect;
it does not explain away the measured AON area deficit or prove the legalizer
could otherwise succeed. The evidence supports a physical-capacity failure
with a possible optimizer exception as a secondary issue, not a stand-alone
OpenROAD-bug conclusion.

## 1. Identity, provenance, and audit method

Repository HEAD at audit start: `4d95d99d866352a61ae7f475987d80fd99ea5c85`
(`main`, clean except for the audit's newly generated processed sample CSV).
The published origin is `https://github.com/dilanj123/Power-to-GDS`.

| Input | Frozen identity |
|---|---|
| Functional RTL source | `ad35514c990f6e1c9eb9fa18aee9d906f9df7721` |
| ORFS | `3a964e13f11a4e435aac01ffa14db0a7d2853720` |
| OpenROAD | `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca` |
| Yosys | `a5af9d690a43744bf6b2cc3dea2717c16b54621c` |
| Container | `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109` |
| Immutable image digest | `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c` |
| Runtime architecture | native Linux/aarch64 Docker on Apple Silicon |
| SKY130HD timing library | `sky130_fd_sc_hd__tt_025C_1v80.lib` |
| Placement site | `unithd`, 0.46 × 2.72 µm |

The source checkout is the pinned tree in
`$HOME/.local/share/power-to-gds/OpenROAD-flow-scripts`. OpenROAD's self
version prints `unknown` in this frozen image; the source SHA and immutable
image digest identify the tool. Platform hashes (config, Liberty, LEF, CDL,
DRC/LVS decks and flow scripts) are recorded in
`results/processed/runtime-platform-manifest.md`.

The audit verified these manifests from the repository root or their intended
working directory:

| Manifest | Entries checked | Result |
|---|---:|---|
| A physical archive | 55 | all match |
| B physical/simulation archive | 45 | all match |
| C D-015 recovery | 50 | all match |
| C prior read-only capacity diagnosis | 28 | all match |
| C D-016 full run | 62 | all match |
| C D-016 input snapshot | 8 | all match |

The verification transcript is
`results/raw/config-c-root-cause-audit/final-provenance.log`; the C manifest
check transcript is `provenance-check.log`. The A/B reports and immutable
platform/runtime manifest were reviewed. Their accepted outer geometry is
the same fixed core: `{1.380,2.720,262.660,261.120}` µm. A/B raw archives
remain unchanged.

### Checkpoint inventory

| Attempt | Available and verified | Missing / limitation |
|---|---|---|
| Original explicit-area attempt | Original failure log only; SHA-256 `0b00534da5a24ffd78f7dc87f8b7cfbc18519c2cfb4248cdeb16dd171d0dae3e` | No unambiguous contemporaneous ODB or per-run manifest. Its work directory was reused for the no-area diagnostic. Do not attribute the current no-area ODBs to this attempt. |
| No-area diagnostic | `2_floorplan.odb` `d4badcc…`; `3_2_place_iop.odb` `19f9a7…`; `3_3_place_gp-failed.odb` `0b93dc…`; full log preserved in capacity-diagnosis manifest | Represents no-area diagnostic, not original explicit region. Failure is a numerical divergence. |
| D-015 | `1_synth`, `2_1`, `2_2`, `2_3`, `2_4`, `2_floorplan`, `3_1`, `3_2`, and `3_3_place_gp-failed.odb`; SHA manifest validates | No successful full-GP, resized, DPL, CTS, route or extracted checkpoint. `3_3` is a density-guard snapshot before full `global_placement`. |
| D-016 | `1_synth.odb`, floorplan stages, `3_1`, `3_2`, `3_3`, `3_4`, and `3_5_place_dp-failed.odb`; 62-entry manifest validates | No valid `3_5_place_dp.odb`, CTS, GRT, route, SPEF, final STA, GDS, DRC or LVS. The failed DPL ODB is a valid readable database saved after an exception, but is not a legal placement. |

Key D-016 ODB SHA-256 values:

| Checkpoint | SHA-256 |
|---|---|
| `1_synth.odb` | `613fbfa6c2a55fc25cf6e5efef729bddfc9615d2a19858ef7ff8bf59b7887ca3` |
| `2_1_floorplan.odb` | `8c60633042e62dbbc66951d9a3b43bdf873163e49662c930503b1e0b2b8fa58c` |
| `2_floorplan.odb` | `33d468866e855e9f0ec6a0157844e496f4267f533e3692e4b79c60a842fb9f7f` |
| `3_1_place_gp_skip_io.odb` | `02fe12de284b4989743245f042b024687d19a79f7c3ea3d4cf6b57e70ee41301` |
| `3_2_place_iop.odb` | `881640e839fc0905519b37215865279c7df81e19b554dbf0ff589c7ba6f27761` |
| `3_3_place_gp.odb` | `c310fd279b41c835a94f80575a37f030aac2759215145487b533443b4067d4fb` |
| `3_4_place_resized.odb` | `c310fd279b41c835a94f80575a37f030aac2759215145487b533443b4067d4fb` |
| `3_5_place_dp-failed.odb` | `d3b636cc10ed4d37a29140970fb1d46b57ab7a9991df050678ffba11d44be5f2` |

The complete D-016 manifest is
`results/raw/phase1-config-c-final-recovery/SHA256SUMS`.

## 2. Failure timeline

The failures are separate events; they must not be collapsed into a single
“domain placement failure.”

| Attempt | `PD_SW` region | Reached / return | First significant failure | Last usable checkpoint | Mechanism |
|---|---|---|---|---|---|
| Original explicit region | `{1.840,5.440,262.200,258.400}` µm | `3_1_place_gp_skip_io`; Make RC 2 | `global_place_skip_io.tcl,19 domain error: argument not in valid range` | No exact failed ODB preserved | Likely zero surviving legal rows after the default domain margin; source/geometry inference only, exact ODB absent. |
| No-area diagnostic | `PD_SW` area unset | Full `3_3_place_gp`; RC 2 | `GPL-0324` divergence, then `GPL-0307` RePlAce divergence | `3_3_place_gp-failed.odb` | Numerical divergence with pathological timing-repair area; no assigned row split. Not the original-area attempt. |
| D-015 | `{1.380,2.720,233.220,261.120}` µm (504 sites ×95 rows) | `3_1` and `3_2` pass; full `3_3` guard; RC 2 | `FLW-0024 Place density exceeds 1.0` | `3_3_place_gp-failed.odb`, guard snapshot | AON adjusted lower bound 1.04999995, helper target 1.04749996. Guard ran before full GPL. Not a RePlAce or DPL failure. |
| D-016 | `{1.380,2.720,230.920,261.120}` µm (499 sites ×95 rows) | Full GPL completes at iteration 509; `3_4` passes; DPL fails; Make RC 2 | DPL-0701 268 legalization violations, then DPL-0201 check failure; exception later | `3_5_place_dp-failed.odb` | AON/top raw area over legal free row area; fragmented narrow rows and spacing compound. `bad_optional_access` is a later command exception. |

The original region's extended Y interval is `[5.440-16.320,
258.400+16.320]=[-10.880,274.720]`, which covers the core's full
`[2.720,261.120]` height. Its X bounds also leave no useful outside region.
That makes “no legal rows / invalid placement region” plausible, but because
the original ODB was overwritten, it is not claimed as the proven error
cause. Its original log SHA is noted above.

The no-area run logs `UPF-0021 No area specified for PD_SW`. Its row dump
contains 95 full rows ×568 sites, but the power-domain region bounds are
empty. GPL later reports an extreme artificial repair area and diverges. This
is a separate, numerically unstable diagnostic and cannot be used to explain
D-015's density guard or D-016's DPL failure.

## 3. Power-domain gap and legal row area

The exact pinned `InitFloorplan.cc::updateVoltageDomain()` sets the default
gap to `6 * min_site_dy` when `-gap` is not supplied, then removes rows
overlapped by the voltage/power domain plus that margin and snaps the right
row origin to the site grid. See [pinned OpenROAD
source](https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/src/ifp/src/InitFloorplan.cc#L577-L595)
and [row split and rightward snapping](https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/src/ifp/src/InitFloorplan.cc#L608-L660).

The ORFS `floorplan.tcl` explicit die/core path calls
`initialize_floorplan -die_area ... -core_area ... -site ...` with only
`ADDITIONAL_SITES` appended. The D-016 config contains no `-gap` override.
The saved row ODBs confirm the resulting geometry directly.

| Quantity | Value |
|---|---:|
| SKY130HD `unithd` site | 0.46 × 2.72 µm = 1.2512 µm² |
| Default gap | 6 × 2.72 = 16.32 µm |
| D-016 `PD_SW` xmax | 230.920 µm |
| Unsnapped right-row start | 230.920 +16.320 = 247.240 µm |
| Site-grid snapped right-row start | 247.480 µm |
| Actual row gap | 247.480 −230.920 = 16.560 µm =36 sites |
| Gap excluded over 95 rows | 36 ×95 =3,420 sites; 4,279.104 µm² |

Thus the observed 36-site gap is the default 16.32 µm domain-separation
margin plus 0.24 µm of site-grid rounding (rounded to 36 site pitches). It is
not tap-cell exclusion and was not explicitly set in the C config. The same
36-site gap appears in D-015 and D-016. The row ODBs show 532 usable sites
per row after the split, versus 568 before it. The missing 36 sites are not
available to either domain's standard-cell placement rows.

### D-015 versus D-016 capacity

The outer core remains unchanged. D-016 moved the `PD_SW` right edge five
site columns left, transferring five sites per row (475 sites gross) to the
right-side AON strip. The default gap remains 36 sites in each attempt.

| Measure | D-015 AON | D-016 AON | D-015 PD_SW | D-016 PD_SW |
|---|---:|---:|---:|---:|
| Usable sites / row | 28 | 33 | 504 | 499 |
| Usable sites, 95 rows | 2,660 | 3,135 | 47,880 | 47,405 |
| Gross row area | 3,328.1920 | 3,922.5120 | 59,907.4560 | 59,313.1360 |
| Fixed tap cells | 0 in AON row strip | 48 | 776 | 776 |
| Tap area in region | 0 | 60.0576 | 970.9312 | 970.9312 |
| GPL free legal row area | 3,328.1920 | 3,862.4544 | 58,936.5248 | 58,342.2048 |

D-016 gained 594.3200 µm² gross AON row area; 48 taps consume 60.0576 µm²
in that strip, so free AON row capacity grew by 534.2624 µm² compared with
D-015. The D-015 AON skip-I/O pin-adjusted demand was 2,498.5253 µm², but
after the 104-port-buffer step its lower bound became 1.04999995, yielding
the FLW-0024 stop. D-016's pre-repair full-GPL AON demand was 3,465.875 µm²
on 3,862.4544 µm² free, so it crossed the initial guard. Its later timing
repair grew the AON movable inventory past physical area capacity.

All D-016 legal row area and tap counts are from the read-only ODB row and
instance dumps under `results/raw/config-c-root-cause-audit/`; the machine
table is `results/processed/config-c-stage-capacity.csv`.

## 4. What GPL's 4,747.9548 µm² reports

The D-016 final global-placement log reports:

| GPL report | TOP/AON | PD_SW |
|---|---:|---:|
| `Placed Cell Area` | 4,747.9548 µm² | 35,364.4070 µm² |
| `Available Free Area` | 3,862.4544 µm² | 58,342.2048 µm² |
| Reported `Minimum Feasible Density` | 0.9000 | 0.6100 |

`NesterovBase::getNesterovInstsArea()` returns `stdInstsArea_` plus density-
weighted macro area. `GPL-1002` logs that value; `GPL-1003` logs
`whiteSpaceArea_`; `GPL-1004` logs `uniformTargetDensity_`. Sources:
[area formula](https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/src/gpl/src/nesterovBase.cpp#L3349-L3354)
and [report definitions](https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/src/gpl/src/nesterovBase.cpp#L4497-L4510).

For this standard-cell-only TOP region, 4,747.9548 µm² is the GPL internal
placement-demand area of its movable standard cells, including pin-density
cell-size inflation. It is not the sum of ODB master areas and not an actual
legalized-cell area. GPL's pin-density code grows eligible movable instances
with more than two signal pins using a bounded scale (0.95–1.20); it is an
internal placement/routability model, not a physical LEF resize. See [pinned
pin-density code](https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/src/gpl/src/placerBase.cpp#L896-L921).

The value includes movable TOP/AON cells present at GPL final reporting:
functional/controller logic, all 37 parent-side isolation cells, 104 port
buffers, and 159 timing-driven repair buffers. It excludes fixed tapcells
from movable `Placed Cell Area`; fixed tap area is accounted for by reducing
the `Available Free Area` from gross row area to 3,862.4544 µm². The 824 tap
cells total 1,030.9888 µm²: 776 in PD_SW and 48 in AON/top.

The saved post-GP ODB's **raw master-area sum** for 501 movable TOP cells is
4,262.8384 µm², not 4,747.9548. That raw area alone is 400.3840 µm² greater
than the free legal row area (110.37% occupancy). GPL's 4,747.9548 demand
exceeds free area by 885.5004 µm² (122.92%). These are different measures;
both indicate overcapacity. A legalizer only relocates cells, so the existing
TOP cell inventory cannot all be placed in that AON row region without
cell removal/area reduction or more legal capacity.

The `.90` lower-bound statistic did not protect DPL from this outcome because
it was computed during GPL initialization, before timing-driven repair. At
that point the TOP pin-adjusted demand was 3,465.875 µm² /3,862.4544 =0.8973,
rounded upward to `.90`. Afterward, timing-driven repair added and resized
cells. GPL's reporting uses updated `stdInstsArea_` for its placed-area line,
but `uniformTargetDensity_` was calculated at initialization and is not
recomputed in the report path. The pin-density/timing-driven target is a GPL
placement objective, not a guarantee that post-repair cells fit a fragmented
region at legalization time. This explains why GPL can complete with the
1.229 ratio and why the early `.90` does not contradict the later deficit.

## 5. Checkpoint deltas and timing repair

The pinned `global_place.tcl` loads `3_2_place_iop.odb`, removes buffers in
timing-driven mode, inserts port buffers, computes the density helper, and
calls `global_placement` with timing/routability options. The script allows
timing-driven resizer activity within GPL. See [pinned global placement
script](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/blob/3a964e13f11a4e435aac01ffa14db0a7d2853720/flow/scripts/global_place.tcl#L8-L43).

| Transition | Exact changes supported by logs/ODB | Effect on AON/top |
|---|---|---:|
| `3_2_place_iop` → port-buffer step | Removed 117 old buffers (14 TOP, 103 PD_SW); inserted 51 input +53 output `sky130_fd_sc_hd__clkdlybuf4s50_1` cells, all top-level. Each cell is 3.680 ×2.720 µm =10.0096 µm², 8 site columns. | Raw TOP rises 2,014.4320 →2,979.1072 µm² (derived transient; no intermediate ODB). Buffer insertion total 1,040.9984 µm²; removed old TOP buffers total76.3232 µm². |
| Full timing-driven GPL repair | Added 152 `buf_4` and 7 `buf_12` in TOP (159 buffers, 1,281.2288 µm²); resized one TOP `nor2_1→nor2_2` (+2.5024 µm²). | Raw TOP +1,283.7312 µm², reaching4,262.8384 µm². |
| Same GPL repair, PD_SW | Resized six `nor3_1→nor3_2` and two `dfxtp_1→dfxtp_2`. | Raw PD_SW +32.5312 µm², reaching34,068.9248 µm². |
| Total timing-driven area delta in GPL report | First repair iteration +1,327.123 µm²; later pass −21.821 µm²; net reported +1,305.302 µm². ODB raw area increases differ due to GPL's internal pin-density dimension accounting. | This repair is the decisive demand growth after the pre-repair density snapshot. |
| `3_3_place_gp` → `3_4_place_resized` | `resize.tcl` ran `repair_design -verbose -match_cell_footprint`; D-016 ODB SHA and all instance/master/group counts are identical. | No additional cell area/width change observed at this stage. |
| `3_4` → DPL entry / failed ODB | No instances added, deleted or resized; ODB delta script reports zero master/inventory changes. DPL performs placement/legalization only. | The area deficit already exists at DPL entry. |

The 104 port buffers are verified in the ODB and LEF as 3.680×2.720 µm
`clkdlybuf4s50_1` cells. The 159 GPL repair buffers are 152 `buf_4` and 7
`buf_12`; this inventory and area came from comparing the ODB instance
masters. GPL reports 159 new top repair buffers; it also removes/resizes
cells. The `3_4` `repair_design` stage did not introduce additional cells.

Detail-placement padding in the pinned flow is applied from
`CELL_PAD_IN_SITES_DETAIL_PLACEMENT`, whose ORFS default is 0; no project
override is in D-016 config. `DETAIL_PLACEMENT_ARGS` is unset, so the logged
command is bare `detailed_placement`. Yet check output reports 24 padding
violations. Their per-instance identities and exact padding constraint are
not recoverable from the pre-exception record; do not infer that nonzero
configured DPL padding caused them.

## 6. Detailed-placement violations and cell localization

The D-016 DPL log reports these distinct stages:

1. `detailed_placement` used the negotiation legalizer; after 1,399
   iterations it emitted DPL-0701 with 268 violations remaining. Runtime was
   35.88 s; total displacement 20,661.4 µm, maximum192.2 µm; legalized HPWL
   was 43% above original.
2. ORFS then called `improve_placement -max_displacement "5 1"` (`ENABLE_DPO`
   default1). That operation emitted DPL-0200 unexpected displacement;
   its placement check recorded 0 wrong regions, 0 row-alignment problems,
   306 site-alignment problems, 186 overlaps, 232 edge-spacing violations,
   and 24 padding violations, then DPL-0201.
3. ORFS called `optimize_mirroring`. Its log begins `DPL-0303 Running
   algorithm for independent set matching` / `DPL-0301 Pass 1`; then Tcl
   reports `detail_place.tcl,39 bad_optional_access`. The Tcl catch writes
   `3_5_place_dp-failed.odb` and rethrows the error.

The category totals are not additive unique cell counts. The 232 edge-spacing
names immediately precede the DPL-0312 summary and are all distinct; all 232
map to the AON/TOP group in the saved failed ODB. Master counts among these
232 named cells:

| Master | Count |
|---|---:|
| `buf_4` | 76 |
| `clkdlybuf4s50_1` | 50 |
| `and2_1` | 19 |
| `lpflow_inputiso0n_1` | 17 |
| `dfrtp_1` | 10 |
| `o21ai_0` | 8 |
| `ha_1`, `buf_12`, `nand2_1`, `a31oi_1` | 4 each |
| `a21oi_1` | 3 |
| remaining master types combined | 29 |

Every one of those 232 cells is in TOP/AON, and none is assigned PD_SW. Their
widths range from 4 to 20 sites in the named list. The widest top cell in the
full saved inventory is 22 sites, still narrower than a 33-site AON row
segment. No individual top cell is too wide to fit a row segment; aggregate
area and row packing/spacing remain the issue.

The 232 named cells are listed row-by-row with master, saved bbox, orientation,
row segment, site coordinate, displacement from `3_4`, and tap proximity in
[`config-c-violation-samples.csv`](config-c-violation-samples.csv). This
provides more than 20 inspectable instances. **Important snapshot boundary:**
the coordinates come from `3_5_place_dp-failed.odb`, written after the
exception. The category names and counts are emitted before/around the
exception; the saved coordinates are not proven to be the exact positions at
which those earlier checks fired. In this post-exception snapshot all 232
sample X origins are site aligned and their bboxes lie inside the AON row
segment, despite the earlier 306 site-alignment problems. That difference
shows why the saved ODB cannot be treated as a pre-exception placement dump.

From that saved snapshot only, 117/232 listed cells are within 5 µm of the
left edge of the AON strip; 22 are within one site pitch of a fixed tap bbox,
101 are within 5 µm, and 3 strictly intersect a tap bbox. These are
post-exception geometric proximity counts, not proven causes for the earlier
edge-spacing list. A separate read-only `check_placement` on the saved ODB
reported 131 overlap pairs and 131 padding check names; the overlap pairs did
not name tap cells. The pre-exception log does not provide unique per-cell
lists for the 306 site alignment or 186 overlap totals, so their exact unique
cell and domain counts are **UNKNOWN**.

All named sample cells fit the 33-site AON row width individually. The AON
strip has 95 rows with 48 fixed tap sites in the saved D-016 floorplan, and
the instance width distribution includes 5-, 8-, 16-, 20-site cells. A
one-dimensional width fit does not establish aggregate contiguous-site
feasibility. The post-GP raw cell area already exceeds total free area, so
row fragmentation and edge spacing can only worsen the capacity margin.

### Twenty informative named samples

These are bboxes from the post-exception ODB; `dx/dy` is displacement from
`3_4`. They characterize named edge-spacing instances but are not claimed as
their precise pre-exception violation locations.

| Instance | Master | Width sites | Saved bbox lower-left (µm) | Orientation | `3_4→failed` dx,dy (µm) | Nearest tap bbox gap (µm) |
|---|---|---:|---|---|---:|---:|
| `_2116__sw_prdata[24]...isolation` | `lpflow_inputiso0n_1` | 5 | 251.160,2.720 | R0 | −5.816,−6.773 | 7.820 |
| `output82` | `clkdlybuf4s50_1` | 8 | 253.460,2.720 | R0 | −4.474,−1.494 | 4.140 |
| `output91` | `clkdlybuf4s50_1` | 8 | 257.140,2.720 | R0 | +6.837,−1.494 | 0.460 |
| `_234_` | `and2_1` | 5 | 247.480,5.440 | MX | −2.986,−0.871 | 11.500 |
| `_232_` | `and2_1` | 5 | 249.780,5.440 | MX | −0.589,−8.967 | 9.200 |
| `_2112__sw_prdata[28]...isolation` | `lpflow_inputiso0n_1` | 5 | 252.080,5.440 | MX | +0.570,−10.171 | 6.900 |
| `output85` | `clkdlybuf4s50_1` | 8 | 253.000,5.440 | MX | −4.934,+1.226 | 4.600 |
| `output89` | `clkdlybuf4s50_1` | 8 | 256.680,5.440 | MX | +6.744,+1.226 | 0.920 |
| `output93` | `clkdlybuf4s50_1` | 8 | 249.780,8.160 | R0 | −8.154,+3.784 | 7.820 |
| `_230_` | `and2_1` | 5 | 253.460,8.160 | R0 | +2.919,−0.090 | 5.520 |
| `_235_` | `and2_1` | 5 | 255.760,8.160 | R0 | −2.634,−0.374 | 3.220 |
| `output84` | `clkdlybuf4s50_1` | 8 | 255.300,8.160 | R0 | −2.634,−8.300 | 2.300 |
| `input_frame_done_q` | `dfrtp_1` | 20 | 253.000,152.320 | MX | +2.636,−12.466 | 0.000 |
| `frame_active_q` | `dfrtp_1` | 20 | 252.080,176.800 | R0 | −0.341,+0.574 | 0.000 |
| `u_pmu.wake_pending_q` | `dfrtp_1` | 20 | 250.240,65.280 | MX | +1.588,−2.869 | 1.840 |
| `sleep_pending_q` | `dfrtp_1` | 20 | 250.240,141.440 | MX | −2.574,−0.483 | 1.840 |
| `input_eol_count_q[3]` | `dfrtp_1` | 20 | 250.240,198.560 | R0 | −0.309,+12.807 | 1.840 |
| `output_eol_count_q[1]` | `dfrtp_1` | 20 | 250.240,239.360 | MX | −2.791,+12.682 | 2.300 |
| `input_eol_count_q[4]` | `dfrtp_1` | 20 | 249.780,182.240 | R0 | −4.140,+2.191 | 2.300 |
| `output_eol_count_q[2]` | `dfrtp_1` | 20 | 249.780,228.480 | MX | −3.571,+2.592 | 2.300 |

The complete row segment for each sample is `x=[247.480,262.660] µm`, with
its displayed Y lower coordinate through `Y+2.720 µm`. The CSV contains the
full bboxes and exact instance names without ellipsis.

## 7. Legalizer failure versus a tool exception

Pinned ORFS `detail_place.tcl` executes:

1. `set_placement_padding -global -left 0 -right 0` (pinned default);
2. bare `detailed_placement` (`DETAIL_PLACEMENT_ARGS` unset);
3. `improve_placement -max_displacement "5 1"` because `ENABLE_DPO=1` and
   default `DPO_MAX_DISPLACEMENT=5 1`;
4. `optimize_mirroring`;
5. `check_placement -verbose`.

The exact script is [pinned `detail_place.tcl`](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/blob/3a964e13f11a4e435aac01ffa14db0a7d2853720/flow/scripts/detail_place.tcl#L10-L39).
The `bad_optional_access` is temporally after `optimize_mirroring` starts its
independent-set matching, so the command boundary implicates that operation.
No C++ stack trace or inner callsite was captured: exact C++ exception source
is **UNKNOWN**. The saved failure ODB is written in the Tcl catch, after the
error; it is not a snapshot before optimize-mirroring.

Before the exception, DPL-0701 proves `detailed_placement` had not produced a
legal placement. `improve_placement` then emitted DPL-0200 and DPL-0201. Thus
the exception cannot be treated as the primary reason an otherwise legal
placement failed. It remains possible that the pinned optimizer has an
independent defect, but it is not proven here.

A read-only placement check on the failed ODB reports DPL-0005 (131 overlap
pairs), DPL-0011 (131 padding-check names), and DPL-0033. It does not reproduce
the earlier 306/186/232/24 counts, consistent with the ODB having been saved
after the exception and potentially after partial optimizer changes.

The current upstream [DPL documentation](https://openroad.readthedocs.io/en/latest/main/src/dpl/README.html)
describes detailed placement as legalization after GPL and says fragmented
rows are supported. It is general documentation, not proof that this exact
highly constrained narrow AON split is feasible.

The user-supplied [issue #10677](https://github.com/The-OpenROAD-Project/OpenROAD/issues/10677)
reports `improve_placement`/`std::bad_optional_access` and an illegal result,
but its key precondition is that `detailed_placement` first returned a legal
placement. D-016 instead had DPL-0701 remaining violations before
`improve_placement`. The symptom is similar; the precondition and demonstrated
physical state differ, so it does not establish a matching bug. The
[DPL-0701 issue #10951](https://github.com/The-OpenROAD-Project/OpenROAD/issues/10951)
is a separate large contest design that reports negotiation nonconvergence;
that shared warning code is not proof of shared root cause.

## 8. Ranked root-cause hypotheses

| Rank / hypothesis | Evidence and contradiction | Confidence / role | What would disprove it |
|---|---|---|---|
| **1 — H2: AON/top over capacity after buffers and repair** | Final TOP raw ODB master area 4,262.8384 >3,862.4544 free row area by400.384; GPL adjusted demand4,747.9548. Post-port/pre-repair raw area2,979.1072 and adjusted area3,465.875 fit. ODB comparison proves 159 new GPL buffers and nine resized masters. | **HIGH; primary proximate physical infeasibility.** | An exact 3_4 inventory/area audit showing some counted TOP cells are not constrained to the AON rows, or a correct row-area recomputation yielding ≥4,262.8384 free legal area. Current ODB group and GPL region report argue against this. |
| **2 — H4: timing-driven GPL repair creates the deficit** | Net reported repair delta+1,305.302 µm²; ODB top raw area rises by1,283.7312 after port buffering; port buffer insertion adds another 1,040.9984 with 14 old AON buffers removed. `3_4` made no further change. | **HIGH; area-growth contributor, not DPL-stage resizing.** | A checkpoint comparison showing the buffers/resizes were already present in IOP or absent from TOP in 3_3. Current SHA/Odb diffs contradict that. |
| **3 — H1: default domain gap reduces capacity** | Pinned source sets default six site heights and snaps row start. ODB shows exactly36 removed site columns/row; area loss4,279.104 µm². | **HIGH; structural capacity contributor, not a separate tool failure.** | An ODB with the 36 sites retained, or evidence that a different explicit gap created the gap. Current source, config and ODB contradict this. |
| **4 — H3: 33-site narrow/fragmented AON strip and spacing constraints** | 33 sites/row ×95, with 48 fixed taps; 232 distinct named edge-spacing entries all TOP; 117 listed saved positions within5 µm of strip edge. No individual TOP master is wider than the 33-site segment. Pre-exception unique lists for all categories are missing. | **MEDIUM; contributor/interacting packing constraint.** | A reconstructed pre-exception legal placement proving the row fragment/edge spacing was not involved. Current evidence cannot completely test this. |
| **5 — H5: pinned legalizer/optimizer defect** | DPL-0701 and DPL-0200/0201 precede `bad_optional_access` during optimize-mirroring sequence; exact C++ callsite missing. Similar but non-identical upstream issue #10677; #10951 shares DPL-0701 only. | **LOW/UNKNOWN as independent cause; exception is secondary symptom.** | A pinned-source stack trace showing a deterministic code defect independent of capacity would strengthen; a legal input ODB followed by identical crash would be decisive. Neither is available and no reproduction was authorized. |

**H6 (interaction)** is the overall explanation with **HIGH** confidence:
the default domain split leaves a narrow 33-site AON stripe; timing-driven
buffers/resizing push its movable cell masters beyond total available area;
fragmentation and spacing add constraints; the legalizer reports nonconvergence
and the later optimizer throws. This synthesis is consistent with all
measured observations, but it does not identify the inner C++ exception
callsite.

## 9. GPL and DPL limits: exact answers

- GPL `4,747.9548` is internal adjusted demand, not raw ODB area. It includes
  pin-density expansion and movable standard cells after port and timing
  repair; it excludes fixed taps. Free area already subtracts fixed taps.
- It can be logged after global placement even when it exceeds free area:
  GPL is a continuous/global placement objective that can tolerate overlap;
  DPL is the stage that must legalize to discrete row sites. The report does
  not assert legal placement.
- It **does imply** a stronger problem than merely GPL-model inflation here:
  the actual raw AON movable master-area sum also exceeds free legal row area.
- The `.90` minimum is rounded from the initialization-time pre-repair ratio
  .8973. The later timing repair changes cell inventory/area, but the logged
  uniform lower-bound field remains from initialization.
- DPL violations overlap; `268`, `306`, `186`, `232`, and `24` are not
  additive unique-cell counts. The saved pre-exception log uniquely names the
  232 edge-spacing entries only. Domain/master counts for the other unique
  violating cells are not reconstructable from retained evidence.
- All 232 named edge-spacing entries resolve to TOP/AON and their post-error
  ODB cells fit individually in a 33-site row. Their sample positions are
  post-exception and must not be treated as exact pre-exception violator
  coordinates.
- 3_3→3_4 and 3_4→failed-3_5 show no cell master/count changes. DPL did not
  create the area deficit.

## 10. Simplest engineering recommendation

No additional C physical attempt is justified under the current project
decision: D-016 explicitly exhausted the fixed-core C recovery budget and the
reduced-scope portfolio verdict already records C as a bounded case study,
not a completed physical configuration.

If a future scope review reopens C, the smallest *class* of correction is to
provide more legal AON row capacity or reduce the AON/top repair-buffer/cell
demand before DPL. The measured raw deficit is at least400.384 µm², and
pin-density-adjusted demand is885.5004 µm² above free area, before spacing
headroom. A region edit would change the intended C domain-partition geometry
and therefore the C experiment input/fairness control; reducing buffer demand
would change implementation methodology/physical optimization behavior.
Neither change is authorized here. A precise row reallocation would require a
new capacity accounting, including tap placement and timing-repair forecast;
do not extrapolate D-015 or D-016 percentages into a new rectangle. Changing
the default gap or density settings is not recommended without an explicit
new decision, and no such modification was tested.

Recommended disposition: accept the documented physical-placement limitation
for the reduced-scope portfolio and do not run more C or D work.

## 11. Unknowns and evidence references

**Unknown / missing:**

1. Exact original-area failed ODB and manifest (lost through work-directory
   reuse); only the failure log and region from historical decision/config
   remain.
2. Exact unique cells behind DPL's 268 legalization violations and 306 site
   alignment /186 overlap /24 padding totals; only the 232 edge-spacing names
   are preserved. The failed ODB is post-exception.
3. Exact C++ `bad_optional_access` stack/callsite and whether that defect is
   independently reproducible on a legal input.
4. Whether any alternate D-016 row distribution could legalize after a
   reviewed capacity correction. No theoretical area split proves that.

**Detailed retained evidence:**

- D-016 full log, DPL log, input snapshot, all ODBs and SHA manifest:
  `results/raw/phase1-config-c-final-recovery/`.
- D-015 logs/checkpoints/manifest:
  `results/raw/phase1-config-c-recovery/`.
- Earlier no-area and initial-attempt logs:
  `results/raw/phase1-config-c/`.
- D-015 read-only ODB queries and source hash manifest:
  `results/raw/phase1-config-c-capacity-diagnosis/`.
- This task's exact pinned OpenROAD identity, ODB dumps, row/region queries,
  checkpoint diffs, sample rebuild script and outputs, provenance checks:
  `results/raw/config-c-root-cause-audit/`.
- Machine-readable all-stage capacity table:
  `results/processed/config-c-stage-capacity.csv`.
- All 232 named edge-spacing cells and saved ODB bboxes:
  `results/processed/config-c-violation-samples.csv`.

The original full A/B/C/D scope remains incomplete. Gate statuses and the
`REDUCED_SCOPE_CV_READY_WITH_LIMITATIONS` verdict are unchanged. No C
physical recovery and no D implementation is authorized by this audit.
