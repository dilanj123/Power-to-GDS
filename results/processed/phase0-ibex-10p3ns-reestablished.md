# Re-established Ibex 10.30 ns implementation-margin baseline

Status: the fresh physical run completed and passed exact 10.50 ns mission
STA, but Gate 0 remains open because the pinned runtime cannot generate GDS or
run the required KLayout open-deck checks.

## Provenance

`ORIGINAL_10P3_ARTIFACT_RECOVERY = FAIL`: the historical 10.30 ns processed
result remains valid historical evidence, but its original ODB/SPEF/SDC were
not retained. This result is a new, explicitly authorized implementation.

Frozen inputs:

- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Yosys: `a5af9d690a43744bf6b2cc3dea2717c16b54621c`
- image: `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`
- platform: SKY130HD
- random seed: `FLOW_DEFAULT / UNCONTROLLED`; the flow reported its internal
  default seed, but no project-controlled seed was introduced.

The 10.20-to-10.30 configuration diff was exactly:

```diff
-set clk_period 10.2
+set clk_period 10.3
```

The fresh run returned flow RC `0` and produced synthesis through final
extraction. Retained raw work and copied artifacts are under:

`results/raw/phase0-ibex-10p3ns-reestablished/`

The preserved artifact directory is:

`results/raw/phase0-ibex-10p3ns-reestablished/artifacts/`

Its complete SHA-256 manifest is `artifacts/SHA256SUMS`.

Key artifact hashes:

| Artifact | SHA-256 |
|---|---|
| `1_synth.odb` | `a7a2a49538ecc2ebe510dd195ccc1ee623f5ad605c4f33abc95771d5a3a0a10e` |
| `6_final.odb` | `fb6739691461f0b136b44de19ad6e9bbc507cf6b66169adbc165c11a1282c49a` |
| `6_final.spef` | `271335d703475c134b9af188a3b4f42bfd1ba0865857ed87b37e9befde2d5985` |
| `6_final.sdc` | `675d9f7c2fe5504c27413df4b2d6cf0f55e6ab2e670200c0ab62cb915ed8763a` |
| `6_final.def` | `6d1d35c43186fbacd26ac09731a3aa4ca41eea384bc39e8d9a09070d1201c01e` |

## Fresh 10.30 ns implementation result

At its own implementation target:

- WNS: `-0.138869 ns`
- TNS: `-7.82503 ns`
- setup violations: `96`
- hold violations: `0`
- max-slew violations: `3`
- max-capacitance violations: `1`
- worst path: `if_stage_i.instr_rdata_id_o[24]$_DFFE_PP_` to
  `gen_regfile_ff.register_file_i.rf_reg[549]$_DFFE_PN0P_`
- worst path group: `core_clock`
- standard-cell instances: `19,322`
- total instances: `41,519`
- standard-cell area: `153,113 um^2`
- utilization: `60%`
- CTS register sinks: `995` and `944`, plus one macro sink
- CTS setup skew: approximately `0.204815 ns`
- CTS clock-buffer class count: `226`
- final detailed-route wire length: `655,948 um`
- final detailed-route vias: `133,807`
- final detailed-route violations: `0`
- final antenna net/pin violations: `0 / 0`

Compared with the historical approximate 10.30 ns result (`-0.14 ns` WNS,
`-7.83 ns` TNS, `96` setup, `0` hold, `3` slew, `1` cap), this is classified
`REPRODUCED_CLOSELY`. The comparison uses timing, violation counts, route
quality, and physical metrics rather than WNS alone.

## Exact 10.50 ns mission STA

The exact preserved `6_final.odb`, `6_final.spef`, SKY130HD Liberty, and final
SDC were reloaded. The disposable mission SDC changed only the two clock
periods from `10.3000` to `10.5000 ns`; input/output delays, latency,
relationships, uncertainty, exceptions, and parasitics were unchanged.

OpenSTA/OpenROAD precise reports returned:

- WNS: `+0.061130657792 ns`
- TNS: `0.000000000000 ns`
- setup violations: `0`
- hold violations: `0`
- max-slew violations: `1`
- max-capacitance violations: `1`
- mission STA return code: `0`

`report_checks` still contains reg-to-output paths in path group
`vclk_core_clock`, including `instr_addr_o[*]` endpoints. Thus the output path
class remains timed; it was not removed to obtain the positive slack.

The flow's original final-report log retained
`STA-0450 virtual clock vclk_core_clock can not be propagated`. This is
consistent with the virtual clock having no physical clock network to
propagate; it does not remove the virtual-clock I/O constraints. The mission
reload preserved the output paths and input-delay constraints and did not add
propagation to the virtual clock. The warning is therefore recorded as an
expected virtual-clock modeling warning, not hidden or used as a constraint
exception.

Classification: **TIMING_CLEAN_WITH_ELECTRICAL_RESIDUALS** for the
implementation-margin methodology:

- implementation target: `10.30 ns`
- mission/evaluation period: `10.50 ns`

This is timing-clean at the mission period but not fully physically clean
because one slew and one capacitance violation remain.

## GDS/open-deck status

The exact ORFS `gds` target was invoked against the preserved work directory.
It failed with RC `2` because the pinned image has no KLayout executable:

`Error: KLayout not found. Install KLayout or set KLAYOUT_CMD.`

No host substitution or installation was used. No GDS artifact was generated;
KLayout DRC and LVS were therefore not run. Gate 0 cannot close on this
evidence alone. This is an environment/tool-availability blocker, not a DRC or
LVS result.
