# POWER-000: scan BTerm placement and CTS/routing survival

## Result

**PASS for this integration smoke.** The project-owned 12-cell scan network
was physically placed after scan-port creation, survived detailed placement
and CTS, and completed global and detailed routing with routed geometry in the
final OpenDB.

This is not a scan-mode timing, ATPG, fault-coverage, or production DFT
qualification.

## Frozen environment

- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Runtime: native Apple-Silicon host, Linux/arm64 Docker
- Image: `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`
- OpenROAD self-version banner: `unknown` in this image
- Platform: pinned ORFS SKY130HD; DONT_USE policy unchanged

## Changed integration behavior

Only `flow/phase0/dft-scan-smoke/post_global_place_dft.tcl` was changed.
After `execute_dft_plan`, it reuses the pinned ORFS I/O-placement operation:

```tcl
place_pins \
  -hor_layers $::env(IO_PLACER_H) \
  -ver_layers $::env(IO_PLACER_V) \
  {*}[env_var_or_empty PLACE_PINS_ARGS]
```

For SKY130HD, `IO_PLACER_H=met3` and `IO_PLACER_V=met2`. The hook markers
confirm entry and application of scan-port placement.

## Checkpoint evidence

- `3_3_place_gp.odb`: 12 `sky130_fd_sc_hd__sdfxtp_1` scan cells; one chain;
  all three scan BTerms `PLACED`.
- Scan BTerms in `3_3_place_gp.odb` and `3_5_place_dp.odb`:
  - `scan_in_0`: input/SCAN, `met2`, bbox `(55360,0)-(55500,485)` dbu
  - `scan_enable_0`: input/SCAN, `met3`, bbox `(119200,45070)-(120000,45370)` dbu
  - `scan_out_0`: output/SCAN, `met3`, bbox `(119200,47790)-(120000,48090)` dbu
- `3_5_place_dp.odb`: 12/12 scan cells placed; one scan chain preserved.
- Detailed placement return code: 0.
- Detailed-placement violations: wrong regions 0; row alignment 0; site
  alignment 0; overlaps 0; edge-spacing 0; padding 0.
- No `DPL-0387` scan-BTerm warning remained in the detailed-placement log.
- `4_1_cts.odb`: CTS completed; 12 functional clock sinks and 3 inserted
  clock buffers. The 12 scan cells and 3 placed scan BTerms remained.
- `5_1_grt.odb`: global route completed; total congestion 1.53%, maximum
  horizontal/vertical congestion 0/0, 46 routed nets, and 0 global-route
  antenna violations.
- `5_2_route.odb`: detailed route return code 0; final TritonRoute violations
  0; antenna net violations 0; antenna pin violations 0.

## Final routed-database proof

Reopening `5_2_route.odb` and querying the OpenDB shows:

| Quantity | Result |
|---|---:|
| Scan chain count | 1 |
| Scan cell count | 12 |
| Routed scan-port nets | 3 / 3 |
| Internal scan-net count | 11 |
| Routed internal scan nets | 11 / 11 |

The three scan-port nets had regular `dbWire` objects. Each of the 11 nets
connecting a scan-cell `Q` to the next scan-cell `SCD` also had a regular
`dbWire` object. The written final DEF contains `SCANCHAINS 1` with `scan_in_0`
as the start pin and `scan_out_0` as the stop pin, as well as the internal
scan-net connections.

## Timing boundary and limitations

The functional-clock SDC was retained. No broad false paths or scan-mode
exceptions were added. This smoke does not qualify scan-shift timing; any
unconstrained scan-mode behavior remains outside its claim. It also does not
prove routed scan I/O sign-off, ATPG, fault coverage, production DFT, or
manufacturing qualification.

Raw stage logs and disposable checkpoint inspections are preserved under
`results/raw/phase0-dft-scan-route-work/`. The aggregate raw-capture log is
`results/raw/phase0-dft-scan-route-smoke.log`.
