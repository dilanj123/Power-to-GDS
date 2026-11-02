# Re-established Ibex 10.30 ns implementation-margin baseline

Status: the fresh physical run completed and passed exact 10.50 ns mission
STA. GDS generation, SKY130HD open-deck DRC, and open-deck LVS were completed
from the exact accepted final database in the pinned Linux/arm64 image.

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
- max-slew violator pins: `3` on `2` distinct signal nets in the later
  high-precision all-violators query
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

This is timing-clean at the mission period but has electrical residuals. A
high-precision `report_check_types -max_slew -max_capacitance -violators`
recheck found three violating pin checks across two signal nets, and one
max-capacitance check. The earlier one-row summary represented the primary
reported slew pin rather than an all-violators enumeration.

| Net | Driver and loads | Check | Actual | Limit | Excess | Kind |
|---|---|---|---:|---:|---:|---|
| `_08516_` | `_20055_/Y` (`sky130_fd_sc_hd__a221oi_1`) to `_20078_/A2` and `ANTENNA_39/DIODE` | max slew | `1.509077787399 ns` | `1.500000000000 ns` | `0.009077849798 ns` | data; both load pins report the same net transition |
| `_03458_` | `_14965_/Y` (`sky130_fd_sc_hd__o21ai_0`) to `_14968_/A`, `_16008_/B2`, `_14967_/A` | max slew | `1.490454435349 ns` | `1.484313964844 ns` | `0.006140532903 ns` | data |
| `_03458_` | same driver and loads | max capacitance | `0.051504734904 pF` | `0.050363998860 pF` | `0.001140736509 pF` | data |

Neither violating net is a clock net. These checks were characterized only;
the accepted ODB was not repaired. High-precision output is retained in
`results/raw/phase0-ibex-10p3ns-reestablished/mission_residual_detail.log`.

## GDS/open-deck status

The exact pinned image was verified as
`openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`,
image/repo digest
`sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`,
Linux/arm64. `/usr/local/klayout` exists in the image, is an AArch64 ELF,
and reports KLayout `0.30.12`. The shell `PATH` omits it, which explains the
original GDS-target error. No package was installed and no host KLayout was
used. Runtime inspection is in
`results/raw/phase0-ibex-10p3ns-reestablished/pinned-image-klayout-runtime.log`.

GDS finishing used the ORFS `do-gds` target with the existing copied work
directory and explicit `KLAYOUT_CMD=/usr/local/klayout`; no synthesis or
physical implementation stage was rerun. The exact command and log are in
`pinned-image-gds.log`. Final and merged GDS are byte-identical:

- path: `results/raw/phase0-ibex-10p3ns-reestablished/work-pinned-image-finish/results/sky130hd/ibex/base/6_final.gds`
- size: `21,035,086` bytes
- SHA-256: `8f21765f53f65769b6b36996c4dc51c715606c11ce70900293a8852a8a7b8bb0`
- `GDS_GENERATED = PASS`

The input `6_final.odb` remains SHA-256
`fb6739691461f0b136b44de19ad6e9bbc507cf6b66169adbc165c11a1282c49a`.
The five accepted physical artifact hashes above remain unchanged.

During finishing, an initial `make drc` invocation against a disposable copy
unexpectedly traversed a synthesis prerequisite and entered Yosys/ABC. The
container was stopped before that invocation completed; none of its outputs
were used. The accepted preserved artifacts were re-hashed afterward and
remained unchanged. The successful finish described here used `do-gds` and
direct pinned-deck DRC/LVS invocations, with no synthesis or physical
implementation stages. The incident and stop evidence are retained in
`results/raw/phase0-ibex-10p3ns-reestablished/pinned-image-finish-audit.md`.

Open-deck checks used KLayout 0.30.12 and the pinned ORFS SKY130HD decks:

| Check | Deck and SHA-256 | Result | Raw report |
|---|---|---|---|
| DRC | `flow/platforms/sky130hd/drc/sky130hd.lydrc`; `029722ea1fc2cf8c48f09fc670c0b72efb295f799c4eb236b7e9767930ecf772` | RC `0`; `0` violations; **OPEN-DECK DRC-CLEAN** | `work-pinned-image-finish/reports/sky130hd/ibex/base/6_drc.lyrdb`, count in `6_drc_count.rpt`; command/log `pinned-image-drc.log` |
| LVS | `flow/platforms/sky130hd/lvs/sky130hd.lylvs`; `d2d231d7cd00a8261d6653c5f3757badefb1dc0aba29441d8406272e75cd8b90` | RC `0`; `INFO : Congratulations! Netlists match.`; **OPEN-DECK LVS-CLEAN** | `work-pinned-image-finish/results/sky130hd/ibex/base/6_lvs.lvsdb`; command/log `pinned-image-lvs.log` |

The CDL was generated from the exact accepted final ODB using pinned OpenROAD
and concatenated with pinned SKY130HD platform CDL. Commands and input hashes
are retained in `pinned-image-cdl.log`, `pinned-image-cdl-concat.log`, and
`pinned-image-lvs-inputs.sha256`. Finish artifact hashes are in
`results/raw/phase0-ibex-10p3ns-reestablished/finish-SHA256SUMS`.

These are bounded open-deck results, not foundry or production sign-off. The
original `gds_target.log` KLayout-PATH failure remains as historical evidence.

The exact in-container finish commands were:

```sh
make DESIGN_CONFIG=/run-work/config.mk \
  WORK_HOME=/run-work/work-pinned-image-finish \
  KLAYOUT_CMD=/usr/local/klayout do-gds

KLAYOUT_CMD=/usr/local/klayout \
  /OpenROAD-flow-scripts/flow/scripts/klayout.sh -zz \
  -rd in_gds=/run-work/work-pinned-image-finish/results/sky130hd/ibex/base/6_final.gds \
  -rd report_file=/run-work/work-pinned-image-finish/reports/sky130hd/ibex/base/6_drc.lyrdb \
  -r /OpenROAD-flow-scripts/flow/platforms/sky130hd/drc/sky130hd.lydrc

KLAYOUT_CMD=/usr/local/klayout \
  /OpenROAD-flow-scripts/flow/scripts/klayout.sh -b \
  -rd in_gds=/run-work/work-pinned-image-finish/results/sky130hd/ibex/base/6_final.gds \
  -rd cdl_file=/run-work/work-pinned-image-finish/objects/sky130hd/ibex/base/6_final_concat.cdl \
  -rd top_cell=ibex_core \
  -rd report_file=/run-work/work-pinned-image-finish/results/sky130hd/ibex/base/6_lvs.lvsdb \
  -r /OpenROAD-flow-scripts/flow/platforms/sky130hd/lvs/sky130hd.lylvs
```

The first command was run as the pinned-image Docker command recorded in
`pinned-image-gds.log`; the DRC and LVS commands were run inside that same
image. The LVS database SHA-256 is
`b4766a99d953ed0ff3a1f1a9a11677e68ebd660a3c568dfc676a362231c8eceb`, the DRC
report database SHA-256 is
`e56db947d8b93a3606af011f8c096b6de1fb4ebd5eef08c1c2431ee8b8b44633`, and
the concatenated CDL SHA-256 is
`bf19587121c8ca7d2598d58a41a566722adcf184afc0bf48bcdb13c365d55ae5`.
