# Configuration C — PMU and UPF isolation attempt

Status: **NOT ACCEPTED**. Directed functional scenarios and bounded PMU safety
checks pass, and the UPF flow inserts isolation cells during floorplan
initialization. The frozen physical flow does not complete global placement.
Configuration D was not started.

## Frozen comparison inputs

- Functional source: `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`, top
  `rtl_to_pixels_top_pipelined`, `IMG_WIDTH=32`, `IMG_HEIGHT=24`.
- Implementation target 10.30 ns; mission evaluation 12.00 ns; I/O delays
  2.06 ns; virtual-clock latency 1.095 ns.
- SKY130HD, A/B die and core geometry, and pinned ORFS/OpenROAD/Yosys/image
  are unchanged. Seed policy: `FLOW_DEFAULT / UNCONTROLLED`.
- ORFS `3a964e13f11a4e435aac01ffa14db0a7d2853720`, OpenROAD
  `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`, and Yosys
  `a5af9d690a43744bf6b2cc3dea2717c16b54621c`; image
  `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`
  (`sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`).
- The prior `PD_SW` area attempt was `{1.840 5.440 262.200 258.400}` µm.
  D-015 records that this grid-aligned region occupied 97.55% of the core and
  left insufficient measured capacity for AON placement. A did not record
  domain coordinates despite the original Gate-1 wording. D-015 proposed one
  replacement region for one controlled retry; that retry is complete and
  failed the full global-placement density guard as detailed below.

## Functional and bounded formal evidence

The project-owned PMU/domain wrapper passed its directed cocotb run:

- Three deterministic 32x24 frames transferred 768/768 pixels each with no
  reference mismatch or EOL error.
- A mid-frame sleep request was held until the current frame and stalled
  output drained; no new frame was accepted before sleep.
- Directed cases covered logical-off APB rejection, gate test bypass,
  wake-up guard/reset sequence, repeated sleep/wake, APB/sleep race, and reset
  in each of seven PMU states.

The pinned Yosys SAT run returned success for the encoded safety assertions at
18 steps. A constrained 22-step sleep/wake trace was emitted. This is bounded
evidence only, not induction, an unbounded proof, or a proof of the full
functional accelerator. Raw simulation and formal logs/VCD are under
`results/raw/phase1-config-c/`.

## UPF and physical result

The project UPF was read; the synthesis ODB retained two power domains and one
unmapped logical power-switch intent. The floorplan-initialization ODB contains
37 instances of `sky130_fd_sc_hd__lpflow_inputiso0n_1` in the floorplan
initialization checkpoint
`results/raw/phase1-config-c/work/results/sky130hd/config_c/base/2_1_floorplan.odb`.
The platform-wide `DONT_USE` policy was not changed. No physical switch
master is mapped or claimed.

The original explicit near-whole-core `PD_SW` area made
`3_1_place_gp_skip_io` fail with `domain error: argument not in valid range`.
A separate diagnostic run with the area omitted warned `UPF-0021 No area
specified for PD_SW`; skip-I/O placement completed, but full `3_3_place_gp`
terminated with `GPL-0307 RePlAce divergence detected` (preceded by
`GPL-0324` divergence and large timing-repair area growth). The no-area run
was diagnostic, not an acceptable implementation configuration. The single
controlled D-015 retry and its distinct density-guard failure are recorded
below.

Consequently C has no accepted placement checkpoint and did not reach CTS,
global route, detailed route, mission STA, GDS, DRC, or LVS. There are no final
physical metrics to compare with A/B. No activity-qualified power result or
power-reduction claim is available. Logical `POWER_OFF` intent does not
represent physical supply interruption.

## Disposition

`CONFIG_C = NOT_ACCEPTED` because the mandatory physical flow fails at global
placement. Functional simulation and bounded formal checks do not waive
physical acceptance. `CONFIG_D = NOT_STARTED` and remains blocked until a
reviewed C recovery decision establishes a valid domain-area/placement method
and C passes its required gates. No scan, ATPG, fault coverage, physical power
gating, or production sign-off is claimed.

Raw run directories and logs are intentionally excluded from Git. The original
attempts are retained under `results/raw/phase1-config-c/`; the controlled
retry and its stage ODBs/configuration evidence are retained under
`results/raw/phase1-config-c-recovery/` with `SHA256SUMS`.

## D-015 single-retry outcome

The single controlled retry used `PD_SW = {1.380, 2.720, 233.220, 261.120}`
µm (504 site columns × 95 rows), leaving 64 columns for AON. The floorplan ODB
retained two domains, one logical switch object, 37 parent-side
`sky130_fd_sc_hd__lpflow_inputiso0n_1` cells, and this exact region. Region
coordinates align with the core's 0.46 µm site and 2.72 µm row grid. Skip-I/O
global placement and I/O pin placement returned successfully.

Full `3_3_place_gp` then failed before the global-placement call. ORFS had
removed 117 buffers and inserted 51 input plus 53 output delay buffers; its
density helper raised `FLW-0024 Place density exceeds 1.0` with the unchanged
`PLACE_DENSITY_LB_ADDON=0.25`. The preceding GPL accounting showed only
3,328.192 µm² available for 2,498.525 µm² of AON movable cells before these
port buffers. This contradicts the simpler region-complement estimate in the
original D-015 proposal: exclusive-region accounting and buffer demand leave
insufficient effective capacity. The exact additional area exclusion is not
isolated. No further physical attempt, density change, or D scan was made.
Raw retry logs and ODB checkpoints are under
`results/raw/phase1-config-c-recovery/`; see D-015 in `docs/DECISIONS.md`.
