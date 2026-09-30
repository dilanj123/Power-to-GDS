# Ibex 10.50 ns conventional baseline experiment

Status: `FAIL_TIMING`; this run is not frozen as the conventional comparison
baseline and is a hard stop for further period-only experiments.

## Reproducibility boundary

The fresh run used the pinned ORFS/OpenROAD/Yosys revisions, native Linux/arm64
Docker image, SKY130HD platform, RTL, floorplan, utilization, placement/CTS/
routing settings, DONT_USE policy, I/O delays, timing exceptions, and PDN
configuration of the 10.30 ns experiment. The only intended configuration
change was in the SDC:

```diff
-set clk_period 10.3
+set clk_period 10.5
```

The `config.mk` files were identical. Generated outputs were written under
`results/raw/phase0-ibex-10p5ns-baseline/` and are intentionally excluded from
Git.

## Flow result

The synthesis-to-extraction flow returned `0` and produced the normal
checkpoints through `6_final.odb`, `6_final.def`, `6_final.spef`, and final
STA reports. The run completed synthesis, floorplan, placement, CTS, global
route, detailed route, and extraction. Completion of those stages is not a
timing-pass claim.

| Stage | WNS (ns) | TNS (ns) | Setup | Hold |
|---|---:|---:|---:|---:|
| global placement | -0.1323 | -0.3861 | — | 0 |
| detailed placement | -0.1117 | -2.7227 | 67 | 0 |
| CTS | +0.0404 | 0 | 0 | 0 |
| global route | 0 | 0 | 0 | 0 |
| final extraction | -0.0588 | -0.0588 | 1 | 0 |

Final metrics:

- WNS: `-0.0588205 ns`
- TNS: `-0.0588205 ns`
- setup violations: `1`
- hold violations: `0`
- max-slew violations: `2`
- max-capacitance violations: `0`
- CTS setup skew: approximately `0.1835 ns` in the final metrics
- functional CTS sinks: `1,939` register sinks plus one macro sink
- CTS-created clock buffers: `200`; two delay buffers were also inserted
- final standard-cell count: `19,220`
- final standard-cell area: `152,828 um^2`
- utilization: `59.48%`
- detailed-route wire length: approximately `650,736 um`
- detailed-route vias: approximately `131,787`
- detailed-route violations: `0`
- final antenna net violations: `0`
- final antenna pin violations: `0`

## Failing path

The final worst violation is a reg-to-output path in path group
`vclk_core_clock`, not the prior register-file endpoint:

- startpoint: `if_stage_i.instr_rdata_id_o[19]$_DFFE_PP_`
- endpoint: `instr_addr_o[31]`
- data arrival: approximately `9.55 ns`
- data required: approximately `9.49 ns`
- slack: approximately `-0.06 ns`

The path contains deep arithmetic/control logic and output buffering. The
final report also retains `STA-0450 virtual clock vclk_core_clock can not be
propagated`. No false path, multicycle path, uncertainty change, or other
constraint workaround was added. The fixed-database path suggests roughly
`10.56 ns` would be needed for this particular endpoint, but that is an
analytical observation, not authorization for another period run.

## Decision

`GATE0_BASELINE_TIMING = FAIL`.

Do not run 10.6 ns, 10.7 ns, 11.0 ns, or a period sweep. The next strategy
decision must be made between an implementation-margin experiment and a
timing-repair-configuration experiment, with a new controlled authorization.
No A/B/C/D low-power implementation is authorized by this result.

GDS generation and KLayout DRC/LVS were not run for this candidate because the
primary routed timing acceptance failed. Existing open-deck DRC/LVS evidence
for other conventional runs remains separate and does not make this timing
candidate clean.
