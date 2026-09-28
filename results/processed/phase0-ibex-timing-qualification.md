# Ibex SKY130HD 10 ns timing-baseline diagnosis

## Disposition

Recommended disposition: **KEEP_10NS_AS_NONCLOSING_STRESS_POINT**.

The 10 ns target is present in the pinned ORFS Ibex SKY130HD example
constraint, but no project authority document defining 10 ns/100 MHz as a
hard requirement was found. `docs/REQUIREMENTS.md`,
`docs/MICROARCHITECTURE.md`, and `docs/TIMING.md` are not present in this
repository. Therefore 10 ns is treated as an inherited reference target, not
silently relaxed or declared closed. Retain it as a stress point and establish
a separately documented timing-clean period in a later experiment before using
timing-sensitive A/B/C/D comparisons.

## Pinned reference and reports

- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Yosys: `a5af9d690a43744bf6b2cc3dea2717c16b54621c`
- design/platform: Ibex / SKY130HD
- functional clock target: 10.000 ns
- final timing report: `results/raw/phase0-ibex-sky130hd-reference/reports/6_finish.rpt`
- final extracted database/checkpoint: `results/raw/phase0-ibex-sky130hd-reference/results/6_final.odb`
- final extracted parasitics: `results/raw/phase0-ibex-sky130hd-reference/results/6_final.spef`

The read-only path inventory loaded the final ODB, final SDC, final SPEF, and
pinned SKY130HD Liberty; it did not rerun implementation or alter any design
data.

## Exact final SDC

The final checkpoint SDC contains:

```tcl
create_clock -name core_clock -period 10.0000 [get_ports {clk_i}]
set_propagated_clock [get_clocks {core_clock}]
create_clock -name vclk_core_clock -period 10.0000
set_clock_latency 1.0950 [get_clocks {vclk_core_clock}]
```

The source ORFS constraint expresses the same I/O scheme as 20% of the clock
period. The final expanded SDC contains `157` input-delay commands and `106`
output-delay commands, all at `2.0000 ns` against `vclk_core_clock`:

```tcl
set_input_delay 2.0000 -clock [get_clocks {vclk_core_clock}] -add_delay [get_ports {...}]
set_output_delay 2.0000 -clock [get_clocks {vclk_core_clock}] -add_delay [get_ports {...}]
```

The source form is `set_input_delay 2.0 ... [all_inputs -no_clocks]` and
`set_output_delay 2.0 ... [all_outputs]`. Reset and all other non-clock
inputs are included by that broad existing input-delay assignment.

No `create_generated_clock`, `set_clock_uncertainty`,
`set_clock_transition`, `set_false_path`, `set_multicycle_path`,
`set_clock_groups`, `set_max_delay`, or `set_min_delay` commands are present
in the final SDC. No documented exception rationale exists because there are
no timing exceptions.

There are two clocks: propagated functional `core_clock` on `clk_i`, and the
virtual `vclk_core_clock` used for I/O delay modeling. The final report emits
`STA-0450 virtual clock vclk_core_clock can not be propagated`. This is
expected for a virtual clock with no source port: its I/O timing uses the
declared ideal latency rather than a propagated physical clock tree. The
warning affects interpretation of virtual-clock input/output paths, including
the two failing reg-to-output paths below; it does not explain the failing
`core_clock` reg-to-reg path.

No unconstrained functional input or output is implied by the current SDC:
all non-clock inputs and all outputs receive delays. The preserved reports do
not provide a separate scalar count of unconstrained endpoints; the existing
`report_checks -unconstrained` sections show recovery and virtual-clock I/O
path classes rather than an unmodeled functional-port class.

## Final setup failures

Final totals are WNS `-0.11 ns`, TNS `-1.93 ns`, `38` setup violations, `0`
hold violations, `24` max-slew violations, and `2` max-capacitance
violations.

The extracted path inventory accounts for all 38 setup failures:

| Count | Path group/type | Representative endpoints | Slack distribution |
|---:|---|---|---|
| 36 | `core_clock`, reg-to-reg | `if_stage_i.instr_rdata_id_o[21]$_DFFE_PP_` → `gen_regfile_ff.register_file_i.rf_reg[184]$_DFFE_PN0P_` | `-0.11` to `-0.01 ns`; buckets: 1 at -0.11, 1 at -0.10, 1 at -0.09, 5 at -0.08, 8 at -0.07, 3 at -0.06, 1 at -0.05, 6 at -0.04, 1 at -0.03, 5 at -0.02, 4 at -0.01 |
| 1 | `vclk_core_clock`, reg-to-output | `if_stage_i.instr_rdata_id_o[17]$_DFFE_PP_` → `instr_addr_o[16]` | `-0.04 ns` |
| 1 | `vclk_core_clock`, reg-to-output | `if_stage_i.instr_rdata_id_o[21]$_DFFE_PP_` → `instr_addr_o[9]` | `-0.02 ns` |

Thus the setup failures are dominated by one repeated reg-to-reg cone, not 38
independent endpoints. The worst path has data arrival `11.15 ns`, required
time `11.04 ns`, `0.14 ns` final setup skew, and `-0.08 ns` library setup time.
Its data cone traverses the Ibex instruction/ALU logic and many SKY130HD
combinational cells before the register-file endpoint; the report also shows
substantial routed net-delay increments between cells. The measured evidence
supports a mixed logic-depth/cell-delay plus routed-interconnect cause, with
clock skew a smaller contributor.

The two virtual-clock output failures are separate I/O timing paths, with
arrivals `9.13 ns` and `9.11 ns` against required time `9.09 ns`. They are
not the source of the worst WNS.

## Slew and capacitance violations

The final report identifies two dominant data nets, both non-clock nets:

- `_05988_`, driven by `_17496_/Y` (`sky130_fd_sc_hd__nor2_1`): 10 load pins,
  driver slew `1.65` versus `1.49` limit, `-0.15` slack. The same net causes
  the other ten listed `1.65`-slew load-pin violations on
  `_18210_/A`, `_18178_/A`, `_18185_/A`, `_18147_/B2`, `_18164_/B2`,
  `_18171_/B2`, `_18038_/B1`, `_18096_/A1`, `_18101_/A`, and `_18059_/A3`.
  `_17496_/Y` also violates max capacitance: `0.10` versus `0.09` limit,
  `-0.01` slack.
- `_08864_`, driven by `_20403_/Y` (`sky130_fd_sc_hd__nand3_1`): 13 load
  pins, driver slew `1.52` versus `1.50` limit, approximately `-0.02`
  slack. Its listed violating loads include the `_2040x_`, `_2472x_`, and
  `place3171`–`place3173` pins. `_20403_/Y` also violates max capacitance at
  `0.15` versus `0.15` limit, approximately `-0.00` slack.

The remaining slew violations are the loads on those same two high-fanout
nets; the final report lists `24` violating pins total. These are broad
fanout/residual physical violations, not clock-net violations. The violating
pins do not appear on the documented worst setup path, so they are correlated
with implementation loading but are not proven to be the direct cause of the
`-0.11 ns` WNS.

## Timing evolution

The available JSON/report checkpoints show this progression for the same
10 ns reference flow:

| Stage | WNS setup (ns) | TNS setup (ns) | Setup count | Hold count |
|---|---:|---:|---:|---:|
| Floorplan | -16.2477 | -22386.7 | not reported in stage JSON | 0 |
| Global placement | -0.4888 | -26.3098 | not reported in stage JSON | 0 |
| Detailed placement | -0.4877 | -26.3782 | 167 | 0 |
| CTS | +0.0017 | 0.0000 | 0 | 0 |
| Global route | -0.0305 | -0.0915 | 6 | 0 |
| Final extracted report | -0.1068 / reported -0.11 | -1.9292 / reported -1.93 | 38 | 0 |

The raw floorplan and placement estimates are not directly comparable to the
final extracted result, but they show the problem existed before routing.
CTS repaired the estimated setup violations. Global routing reintroduced a
small negative margin, and detailed-route extraction worsened the final result
to `-0.11 ns`. The final disposition is therefore primarily a deep logic/cell
delay problem exposed and worsened by routed parasitics, not a hold problem.

## Clock quality

Pinned CTS reports:

- root buffer: `sky130_fd_sc_hd__clkbuf_16`
- sink buffer: `sky130_fd_sc_hd__clkbuf_16`
- clock nets: `3`
- register clock sink groups: `clk_i_regs` with `1074` sinks and `_05563_`
  with `1030` sinks; `clk_i` has one macro sink
- clock-tree path depth: `2–3` for register trees, `2` for the macro tree
- CTS setup skew: `0.114 ns`
- final extracted setup skew: `0.142 ns`
- final extracted hold skew: `0.142 ns`
- final cell report clock buffers: `213`

The worst path's `0.14 ns` setup skew consumes margin, but the data arrival is
`11.15 ns` against an approximately `11.04 ns` required time. Clock skew is a
secondary contributor, not the dominant root cause.

## Analytical period estimate

The final report gives:

- current period: `10.00 ns`
- critical setup period estimate: `10.11 ns`
- reported core-clock Fmax: `98.94 MHz`
- WNS-based zero-slack estimate: approximately `10.11 ns`, or `98.94 MHz`

This is an analytical estimate for this exact routed database, not a timing
closure result. It does not remove the separate slew/capacitance violations or
prove that a future implementation at another period will be clean.

## Classification and remaining uncertainty

Root-cause classification, ranked by measured evidence:

1. `LOGIC_DEPTH` / `CELL_DELAY` — one long instruction/ALU-to-register cone
   dominates all 36 reg-to-reg setup failures.
2. `ROUTING_DELAY` — final extraction changes a CTS-clean estimate to
   `-0.11 ns`; the worst path contains many routed net-delay increments.
3. `CLOCK_SKEW` — final setup skew is `0.142 ns`, measurable but not dominant.
4. `SLEW_CAP_RESIDUALS` — two high-fanout data nets create all 24 driver/load
   violations, but their direct effect on the worst setup path is unproven.

Overall classification: **MIXED**, with no demonstrated `CONSTRAINT_ISSUE`.
The virtual-clock propagation warning is a modeling limitation for I/O paths,
not evidence that the core reg-to-reg failure is false or multicycle. No
constraint correction is justified by the existing evidence, and no SDC or
implementation setting was changed.

## Next smallest experiment

Run a separately documented timing-only baseline experiment at a period above
the analytical `10.11 ns` threshold, retaining the same RTL, SDC structure,
library, floorplan, and implementation settings. Validate setup, hold, slew,
capacitance, and I/O timing together. Until that is done, keep 10 ns as a
non-closing stress point and do not claim timing closure.

Raw diagnostic capture:
`results/raw/phase0-ibex-timing-diagnosis.log`

