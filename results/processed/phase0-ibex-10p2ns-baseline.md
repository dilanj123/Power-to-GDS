# Ibex 10.20 ns conventional comparison baseline

## Scope

This is a separate conventional Ibex/SKY130HD implementation using the
pinned native ARM64 no-GUI flow. The preserved 10.000 ns implementation was
not modified. The only functional configuration change was the clock-period
variable in the copied SDC:

```diff
-set clk_period 10.0
+set clk_period 10.2
```

The virtual I/O clock period and its derived I/O delays continue to derive
from that same variable. RTL, PDK/library, frozen tool revisions, synthesis
options, floorplan, utilization target, placement, CTS, routing, I/O delay
ratio, DONT_USE policy, and timing exceptions were unchanged. The copied
config redirects `SDC_FILE` to the isolated raw workspace; it otherwise
matches the conventional Ibex config.

Pinned revisions:

- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Yosys: `a5af9d690a43744bf6b2cc3dea2717c16b54621c`
- image: `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`
- execution architecture: `aarch64`

## Flow result

The run completed synthesis, floorplan, placement, CTS, global route,
detailed route, extraction, and final STA. The final routed artifacts include
`6_final.odb`, `6_final.spef`, and `6_final.def`.

- synthesis: completed; `1_synth.odb` produced
- CTS: completed; final report setup skew `0.20 ns`; functional clock tree had
  995 and 944 register sinks plus one macro sink, and CTS inserted 2 + 94 +
  99 clock buffers across the three clock nets
- global route: completed; final congestion report had zero overflow and the
  global router reported zero final antenna violations before detailed route
- detailed route: completed; final TritonRoute violations `0`; final antenna
  net violations `0`; final antenna pin violations `0`
- extraction/final STA: completed; virtual-clock warning `STA-0450` remained

## Final timing acceptance

- clock period: `10.200 ns`
- WNS: `-0.10 ns`
- TNS: `-2.74 ns`
- setup violations: `31`
- hold violations: `0`
- max-slew violations: `12`
- max-capacitance violations: `0`
- final clock report estimate: `core_clock period_min = 10.30 ns`,
  `fmax = 97.05 MHz`

The primary failing endpoint remains the register-file cone, including
`gen_regfile_ff.register_file_i.rf_reg[668]$_DFFE_PN0P_`; the 10.20 ns result
therefore does not establish a timing-clean comparison baseline. The report's
approximately `10.30 ns` period is an analytical next experiment, not a
timing-closure result.

## Comparison with the preserved 10 ns stress point

| Metric | 10.000 ns | 10.200 ns |
|---|---:|---:|
| WNS | -0.1068 ns | -0.10 ns |
| TNS | -1.93 ns | -2.74 ns |
| setup violations | 38 | 31 |
| hold violations | 0 | 0 |
| max-slew violations | 24 | 12 |
| max-cap violations | 2 | 0 |
| final total cells | 41,682 | 41,646 |
| final area | 154,711 um² | 154,019 um² |
| utilization | 60% | 60% |
| final setup skew | 0.142 ns | 0.20 ns |
| final routed wire length | 649,244 um | 651,590 um |
| final routed vias | 133,325 | 133,638 |

The altered period changed timing-driven buffering/resizing and the resulting
placement/routing, so the implementation is not numerically identical despite
holding the stated configuration variables constant. Setup and physical
residual counts improved in some categories, but WNS/TNS remained failing and
the setup skew increased.

## Classification and boundary

Classification: **FAIL_TIMING**.

The 10.20 ns implementation is not suitable as a timing-clean conventional
A/B/C/D comparison target. No GDS, KLayout DRC, or KLayout LVS was run after
the failed timing acceptance. This result makes no claim of timing closure,
physical cleanliness, foundry sign-off, low-power improvement, ATPG, fault
coverage, or production qualification.

Raw implementation logs and databases are retained locally under:
`results/raw/phase0-ibex-10p2ns-baseline/` and are intentionally excluded from
Git. The next single experiment recommended by the measured result is a
separate `10.30 ns` clock-period run, subject to approval; no period sweep was
performed.
