# Configuration C placement failure — independent review pack

## Status and scope

- Repository HEAD reviewed: `4d95d99d866352a61ae7f475987d80fd99ea5c85` (`main`).
- Current disposition: Gate 0 PASS with declared switch-intent limitation; Gate 1 PASS; A/B accepted; **C NOT ACCEPTED; D NOT STARTED**.
- Reduced portfolio verdict remains `REDUCED_SCOPE_CV_READY_WITH_LIMITATIONS`; original full A/B/C/D scope remains incomplete.
- Investigation only. No synthesis, global placement, detailed placement, optimization, recovery, or D run was performed. Read-only ODB queries and a read-only `check_placement` were run on preserved copies/checkpoints.

## Frozen identity and provenance

- RTL source: `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`.
- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`.
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca` (self-version prints `unknown` in this image).
- Yosys: `a5af9d690a43744bf6b2cc3dea2717c16b54621c`.
- Image: `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`, immutable digest `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`, Linux/aarch64 container on Apple Silicon.
- SKY130HD `unithd` site: 0.46 × 2.72 µm; TT Liberty `sky130_fd_sc_hd__tt_025C_1v80.lib`. Platform hashes are in `results/processed/runtime-platform-manifest.md`.
- Verified manifests: A archive 55/55; B 45/45; D-015 50/50; earlier capacity diagnosis 28/28; D-016 62/62; D-016 input snapshot 8/8. Transcript: `results/raw/config-c-root-cause-audit/final-provenance.log`.
- D-016 key ODB hashes: `1_synth.odb` `613fbfa6c2a55fc25cf6e5efef729bddfc9615d2a19858ef7ff8bf59b7887ca3`; `2_1_floorplan.odb` `8c60633042e62dbbc66951d9a3b43bdf873163e49662c930503b1e0b2b8fa58c`; `3_3_place_gp.odb` and `3_4_place_resized.odb` `c310fd279b41c835a94f80575a37f030aac2759215145487b533443b4067d4fb`; failed saved DPL ODB `d3b636cc10ed4d37a29140970fb1d46b57ab7a9991df050678ffba11d44be5f2`.
- The original explicit-area attempt has only its log, no retained ODB/manifest. Its work directory was reused. Do not attribute no-area diagnostic checkpoints to it.

## Failure timeline

| Attempt | PD_SW region (µm) | Stage/result | First meaningful failure and interpretation |
|---|---|---|---|
| Original explicit region | `{1.840,5.440,262.200,258.400}` | `3_1_place_gp_skip_io`, RC 2; failed ODB missing | `global_place_skip_io.tcl:19 domain error: argument not in valid range`. Region plus default margin plausibly leaves no valid rows, but this is inference because exact ODB is missing. |
| No-area diagnostic | No PD_SW area | Full GP, RC 2 | GPL-0324 / GPL-0307 RePlAce divergence with pathological timing-repair area (delta 210,385,924.27 µm²; final reported area −81,562,282,250.93 µm²). Separate numerical failure, not evidence about original explicit-region attempt. |
| D-015 | `{1.380,2.720,233.220,261.120}` | skip-I/O and IOP pass; density guard RC 2 before full GPL | FLW-0024; AON adjusted lower bound 1.04999995, helper target 1.04749996 exceeds 1.0. Not DPL or RePlAce failure. |
| D-016 | `{1.380,2.720,230.920,261.120}` | GPL completes at iteration 509; resize stage unchanged; DPL fails | DPL-0701: 268 legalization violations. Later `improve_placement` check fails; `bad_optional_access` follows during optimize-mirroring sequence. No CTS/GRT/route/SPEF/STA/GDS/DRC/LVS. |

D-015 has a failed GPL guard snapshot but no full GPL/DPL. D-016 has floorplan, skip-I/O, IOP, GP, resized and failed-DPL ODBs. No valid post-DPL checkpoint exists.

## 36-site gap: source and ODB agree

Pinned `src/ifp/src/InitFloorplan.cc::updateVoltageDomain()` defaults the domain gap to six minimum site heights when `-gap` is absent, then snaps the adjacent row origin to the placement-site grid. Pinned `flow/scripts/floorplan.tcl` supplies no gap override in this run; it passes die/core/site plus `ADDITIONAL_SITES`.

- Six site heights = `6 × 2.72 = 16.32 µm`.
- D-016 PD_SW xmax = 230.920 µm; unsnapped right-row start = 247.240 µm.
- Site-grid snapped row start = 247.480 µm; actual gap = 16.560 µm = 36 × 0.46 µm.
- Extra 0.24 µm is site-grid rounding. This is default power-domain separation plus rounding, not a tap-cell gap.
- Lost legal sites = `36 × 95 = 3,420`; area = `3,420 × 1.2512 = 4,279.104 µm²`.

Source references: [pinned updateVoltageDomain gap](https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/src/ifp/src/InitFloorplan.cc#L577-L595) and [row removal/splitting and snapping](https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/src/ifp/src/InitFloorplan.cc#L608-L660).

## Capacity, by domain and attempt

Area is µm². “Free” means row area after fixed tap-cell area. AON means GPL `TOP`/always-on region. The no-area diagnostic has no meaningful AON/PD_SW split.

| Attempt/region | AON sites/row × rows; free area | PD_SW sites/row × rows; free area | Demand and result |
|---|---|---|---|
| D-015: SW 504 columns | AON 28×95; 0 AON taps; 3,328.1920 free | 504×95; 776 taps, 970.9312 area; 58,936.5248 free | After 104 port buffers AON raw area 2,979.1072; pin-adjusted 3,494.6016; lower bound 1.04999995; helper target 1.04749996 → FLW-0024 before full GPL. |
| D-016: SW 499 columns | AON 33×95; 48 taps, 60.0576 area; 3,862.4544 free | 499×95; 776 taps, 970.9312 area; 58,342.2048 free | Pre-repair AON raw 2,979.1072; adjusted demand 3,465.875; ratio .8973 rounded to .90. Post-GP AON raw master area 4,262.8384; adjusted GPL area 4,747.9548. |
| D-016 PD_SW after GP | — | 47,405 sites total; free 58,342.2048 | Raw movable area 34,068.9248; GPL adjusted 35,364.4070; ample aggregate area versus AON. |

D-016 transfers five site columns per row versus D-015: +594.3200 µm² gross AON; 48 taps consume 60.0576, leaving +534.2624 µm² net AON free area. The D-016 outer core remains `{1.380,2.720,262.660,261.120}`.

Machine-readable per-checkpoint values, including no-area and missing values, are in `results/processed/config-c-stage-capacity.csv`. It distinguishes raw master area, legal row area, GPL-adjusted area, density and stage; these are not interchangeable.

## What 4,747.9548 versus 3,862.4544 means

- GPL `Placed Cell Area` 4,747.9548 is its internal movable standard-cell demand statistic, pin-density adjusted; it is **not** raw sum of LEF master areas and not legalized area.
- GPL source `NesterovBase::getNesterovInstsArea()` returns standard-instance area plus density-weighted macro area; GPL-1002 reports it, GPL-1003 reports whitespace, GPL-1004 reports the initialization-time uniform target density. See [pinned area formula/report](https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/src/gpl/src/nesterovBase.cpp#L3349-L3354) and [report definitions](https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/src/gpl/src/nesterovBase.cpp#L4497-L4510). Pin-density expansion implementation: [placerBase.cpp](https://github.com/The-OpenROAD-Project/OpenROAD/blob/4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca/src/gpl/src/placerBase.cpp#L896-L921).
- It includes the movable TOP inventory at final GP reporting, including 37 isolation cells, 104 port buffers and 159 timing-repair buffers; fixed taps are excluded from movable area and reduce reported free area.
- Raw ODB master-area sum for 501 movable TOP cells = 4,262.8384. That alone exceeds legal free AON rows by 400.3840 (10.37%; occupancy 110.37%). GPL-adjusted demand exceeds by 885.5004 (22.92%; demand/free ratio 1.2292).
- GPL can finish with area demand greater than white space because GPL is a continuous placement optimization, not discrete-row legalization. It does not prove legal packing.
- The .90 minimum was computed at GPL initialization when adjusted demand was 3,465.875 / 3,862.4544 = .8973. Timing-driven repair subsequently increased inventory. The reported lower-bound field is not recomputed to certify the post-repair inventory. Thus the earlier .90 did not prevent the later capacity deficit.

## Port buffers and post-GP delta

- Port-buffer step removed 117 previous buffers (103 SW, 14 TOP) and added 51 input +53 output `sky130_fd_sc_hd__clkdlybuf4s50_1` buffers in TOP. Each LEF master is 3.680×2.720 µm =10.0096 µm², 8 sites; 104 total =1,040.9984 µm². Transient post-buffer TOP raw area 2,979.1072; no standalone ODB was saved for this exact point.
- Timing-driven GPL repair added 152 `buf_4` and 7 `buf_12` in TOP (159 total; 1,281.2288 µm²), resized one `nor2_1→nor2_2` (+2.5024). TOP raw delta +1,283.7312, ending at 4,262.8384.
- PD_SW repair resized six `nor3_1→nor3_2` and two `dfxtp_1→dfxtp_2` (+32.5312 µm²). GPL log’s net timing-driven area delta is +1,305.302 µm² after a later −21.821 pass; internal adjusted dimensions explain difference from raw ODB area deltas.
- `3_3_place_gp.odb` and `3_4_place_resized.odb` hashes and inventory are identical; `repair_design` at resize made no further changes. DPL did not create the deficit.

## Detailed placement, cell localization, exception

Pinned ORFS `detail_place.tcl` order: zero global detail padding; `detailed_placement`; `improve_placement -max_displacement "5 1"` (`ENABLE_DPO=1`); `optimize_mirroring`; `check_placement`. `DETAIL_PLACEMENT_ARGS` is unset; default `DPO_MAX_DISPLACEMENT` is `5 1`. Source: [pinned detail_place.tcl](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/blob/3a964e13f11a4e435aac01ffa14db0a7d2853720/flow/scripts/detail_place.tcl#L10-L39).

- `detailed_placement`: 1,399 iterations, DPL-0701 with 268 violations left; 35.88 s; displacement 20,661.4 µm; max 192.2 µm; HPWL +43%.
- `improve_placement`: DPL-0200 unexpected displacement; checks reported wrong-region 0, row-alignment 0, site-alignment 306, overlaps 186, edge-spacing 232, padding 24; then DPL-0201. Counts can overlap and are not additive unique cells.
- The 232 names printed for edge-spacing are distinct and all map to TOP/AON. Master counts: `buf_4` 76; `clkdlybuf4s50_1` 50; `and2_1` 19; `lpflow_inputiso0n_1` 17; `dfrtp_1` 10; `o21ai_0` 8; `ha_1`, `buf_12`, `nand2_1`, `a31oi_1` 4 each; `a21oi_1` 3; other masters 29 combined. Widths in that set are 4–20 sites; full TOP maximum is 22 sites, versus 33 sites/row. No single cell is too wide; aggregate capacity/packing is the issue.
- Among those 232 named entries, 117 saved positions are within 5 µm of the AON strip’s left edge. These are not proven pre-exception violation coordinates.
- `optimize_mirroring` starts independent-set matching (`DPL-0303`, `DPL-0301`), then Tcl catches `bad_optional_access` at `detail_place.tcl:39`, writes failed ODB and rethrows. The exception is after DPL-0701 and DPL-0201; it is secondary in the observed timeline. Exact inner C++ callsite/stack is **UNKNOWN**.
- Failed ODB is post-exception. Its 232 sample cells appear aligned/in-row; read-only `check_placement` reports 131 overlap pairs and 131 padding check names, not the earlier category counts. Pre-exception per-cell lists for site-alignment/overlap/padding are missing. Therefore exact unique affected cells, tap-intersection cause and precise pre-error coordinates are **UNKNOWN**.
- In the post-error snapshot, 22/232 are within one site of a fixed tap, 101 within 5 µm and 3 strictly intersect a tap bbox; these are proximity only, not causal proof. Full per-cell data is `config-c-violation-samples.csv`.

OpenROAD [DPL documentation](https://openroad.readthedocs.io/en/latest/main/src/dpl/README.html) describes fragmented-row support generally. Issue [#10677](https://github.com/The-OpenROAD-Project/OpenROAD/issues/10677) has similar `bad_optional_access`, but there `detailed_placement` first succeeded; D-016 had DPL-0701 first. Issue [#10951](https://github.com/The-OpenROAD-Project/OpenROAD/issues/10951) shares DPL-0701 but is a separate design. Neither proves this is the same tool defect.

## Ranked hypotheses

| Rank | Hypothesis | Evidence / contradiction | Confidence and role |
|---|---|---|---|
| 1 | H2: AON raw movable inventory exceeds legal area after repair | 4,262.8384 raw >3,862.4544 free by400.3840; 4,747.9548 adjusted. | HIGH; primary proximate physical infeasibility. |
| 2 | H4: port buffers and timing-driven GPL repair create demand growth | +1,040.9984 port buffer area; repair adds 159 TOP buffers and resizing; 3_4 adds none. | HIGH; contributing mechanism. |
| 3 | H1: default domain gap removes critical row capacity | Source default plus exact ODB 36 sites/row, 4,279.104 µm². | HIGH; structural capacity contributor. |
| 4 | H3: narrow/fragmented AON rows and spacing constrain legal packing | 33 sites/row, 48 taps, all 232 edge entries TOP; no cell individually too wide. | MEDIUM; interacting contributor; incomplete pre-error cell maps. |
| 5 | H5: legalizer/optimizer defect independent of infeasibility | `bad_optional_access` during optimize-mirroring, but after DPL-0701; no C++ stack. | LOW/UNKNOWN as primary cause; possible secondary defect. |

H6 (interaction) is the best overall explanation with HIGH confidence: structural row loss leaves a narrow AON strip; repair growth takes raw movable area beyond total free capacity; fragmentation/spacing further constrains placement; optimizer exception follows an already-illegal result. This explains observations without claiming an exact exception callsite.

## Unknowns, recommendation, references

Unknowns: original explicit-area ODB (lost); exact unique cells for the 268/306/186/24 categories; pre-exception coordinates for named edge violations; inner C++ exception stack; whether a revised row allocation would converge after capacity correction. No new experiment is justified under exhausted D-016 budget.

**Recommendation:** retain the reduced-scope disposition and document C as a functional/UPF/formal case study whose physical placement did not complete. If a future scope review reopens C, first make a new capacity/row-allocation decision or reduce TOP repair demand; either changes experiment inputs and requires explicit authorization. Do not infer a new rectangle, alter density/gap, tune the placer, or launch D from this diagnosis.

Detailed report: `results/processed/config-c-root-cause-audit.md`.
Machine tables: `results/processed/config-c-stage-capacity.csv` and `results/processed/config-c-violation-samples.csv`.
Raw read-only scripts/logs/checksums: `results/raw/config-c-root-cause-audit/` (ignored; not committed). The D-016 and D-015 preserved sources remain under `results/raw/phase1-config-c-final-recovery/` and `results/raw/phase1-config-c-recovery/`.
