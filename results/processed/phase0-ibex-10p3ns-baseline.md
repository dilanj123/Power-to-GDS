# Ibex 10.30 ns conventional comparison-baseline experiment

## Scope and fairness

This was one fresh conventional Ibex/SKY130HD implementation using the pinned
native ARM64 no-GUI flow. The 10.000 ns stress point and 10.200 ns candidate
baseline were preserved. The only source/configuration change from the 10.200
ns experiment was:

```diff
-set clk_period 10.2
+set clk_period 10.3
```

The virtual I/O clock and derived I/O delays continue to derive from the same
clock-period variable. RTL, PDK/library, frozen tool revisions, synthesis and
implementation settings, geometry, utilization target, I/O delay values,
timing exceptions, DONT_USE policy, and power-grid settings were unchanged.

Pinned revisions:

- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Yosys: `a5af9d690a43744bf6b2cc3dea2717c16b54621c`
- image: `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`
- execution architecture: `aarch64`

## Flow and stage timing

The fresh run completed synthesis, floorplan, placement, CTS, global route,
detailed route, extraction, and final STA. The synthesis checkpoint was
`1_synth.odb`; the final routed checkpoint was `6_final.odb`.

| Stage | WNS (ns) | TNS (ns) | Setup | Hold |
|---|---:|---:|---:|---:|
| Floorplan | -15.95 | -21775.57 | not reported | not reported |
| Global placement | -0.30 | -6.95 | not reported | not reported |
| Detailed placement | -0.34 | -8.16 | 68 | 0 |
| CTS | 0.00 | 0.00 | 0 | 0 |
| Global route | -0.02 | -0.02 | 1 | 0 |
| Final extracted STA | -0.14 | -7.83 | 96 | 0 |

The reported stage values are not interchangeable with the final extracted
result: timing-driven buffering, routing, antenna repair, and extraction
changed the implementation between checkpoints.

## Final result

- clock period: `10.300 ns`
- WNS: `-0.14 ns`
- TNS: `-7.83 ns`
- setup violations: `96`
- hold violations: `0`
- max-slew violations: `3`
- max-capacitance violations: `1`
- setup skew: `-0.20 ns`
- final cell count: `41,519`
- standard-cell area: `153,113 um^2`
- utilization: `60%`
- CTS sinks: `1` macro sink, `995` and `944` register sinks
- CTS-created buffers: `2 + 93 + 101 = 196`
- detailed-route violations: `0`
- final antenna net violations: `0`
- final antenna pin violations: `0`
- final routed wire length: `655,948 um`
- final routed vias: `133,807`

The final routed database and open detailed-route checks are valid artifacts,
but the timing acceptance criteria were not met.

## Critical-path characterization

The worst reported setup path is in path group `core_clock`:

- startpoint: `if_stage_i.instr_rdata_id_o[24]$_DFFE_PP_`
- endpoint: `gen_regfile_ff.register_file_i.rf_reg[549]$_DFFE_PN0P_`
- path type: reg-to-reg
- data arrival: `11.37 ns`
- data required: `11.24 ns`
- slack: `-0.14 ns`
- setup skew: `-0.20 ns`

The path traverses a deep instruction/control combinational cone and remains
dominated by the register-file endpoint, as in the 10.000 ns and 10.200 ns
runs. The reports do not provide a separately normalized cell-delay versus
net-delay total for this path; the path listing shows both many cell-delay
increments and routed interconnect increments. The final extracted result
therefore supports a mixed logic/cell-delay and routing-delay diagnosis, with
clock skew also measurable. The 10.30 ns run does not establish timing
closure.

The three max-slew and one max-capacitance violations are physical residuals
separate from setup acceptance. The final route and antenna checks were clean,
but that does not make the implementation timing-clean.

## Three-way comparison

| Metric | 10.000 ns | 10.200 ns | 10.300 ns |
|---|---:|---:|---:|
| WNS | -0.1068 ns | -0.10 ns | -0.14 ns |
| TNS | -1.93 ns | -2.74 ns | -7.83 ns |
| setup violations | 38 | 31 | 96 |
| hold violations | 0 | 0 | 0 |
| slew violations | 24 | 12 | 3 |
| cap violations | 2 | 0 | 1 |
| CTS skew | 0.142 ns | 0.20 ns | -0.20 ns |
| final cell count | 41,682 | 41,646 | 41,519 |
| area | 154,711 um² | 154,019 um² | 153,113 um² |
| utilization | 60% | 60% | 60% |
| route wire length | 649,244 um | 651,590 um | 655,948 um |
| vias | 133,325 | 133,638 | 133,807 |

Timing did not improve monotonically with the relaxed period. The 10.30 ns
implementation had fewer slew violations and slightly fewer cells/area, but
its extracted setup result was worse and its TNS/setup count increased. These
differences are measured implementation consequences, not low-power results.

The final report gives `core_clock period_min = 10.44 ns` and `fmax = 95.80
MHz`. This is an analytical estimate for this exact implementation, not a
timing-clean result. No 10.40 ns or other follow-up period was run.

## Classification and boundary

Classification: **FAIL_TIMING**.

The 10.30 ns experiment is not suitable to freeze as the conventional
timing-clean A/B/C/D comparison target. Because setup timing failed, no GDS,
KLayout DRC, or KLayout LVS was run for this experiment. The detailed-route
and antenna zeros are reported independently and are not foundry-signoff
claims.

The raw implementation workspace and log are retained locally under
`results/raw/phase0-ibex-10p3ns-baseline/` and intentionally excluded from
Git. No RTL, SDC, implementation setting, frozen tool source, or prior
experiment was modified.
