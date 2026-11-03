# Power-to-GDS

A small SKY130HD ASIC study of an already verified Sobel streaming pipeline. The functional source is imported unchanged from [`from-rtl-to-pixels`](https://github.com/dilanj123/from-rtl-to-pixels), commit [`ad35514c990f6e1c9eb9fa18aee9d906f9df7721`](rtl/imported/from-rtl-to-pixels-ad35514/PROVENANCE.md), with 32×24 parameters for a manageable physical experiment.

The goal was to compare a conventional implementation (A) with a clock-gated version (B), then document a PMU/UPF isolation attempt (C). The pinned flow uses ORFS/OpenROAD/Yosys and the SKY130HD platform.

## Routed layouts

A and B are actual final routed GDS captures rendered with the same KLayout 0.30.12 settings. See [image provenance and source hashes](images/README.md).

| A — conventional | B — one integrated clock gate |
|---|---|
| ![Configuration A routed SKY130HD layout](images/config_a_layout.png) | ![Configuration B routed SKY130HD layout](images/config_b_layout.png) |

Both accepted configurations pass the reviewed 12.00 ns mission STA and pinned open-deck DRC/LVS. The comparison below reports measured run outcomes; it does not imply that every physical difference was caused by clock gating.

| Metric | A | B |
|---|---:|---:|
| Final standard-cell area | 40,508.9 µm² | 41,745 µm² |
| Reported utilization | 60% | 62% |
| Mission WNS / TNS at 12.00 ns | +0.6526 / 0 ns | +1.4924 / 0 ns |
| Setup / hold violations | 0 / 0 | 0 / 0 |
| Mapped ICGs | 0 | 1 (`sky130_fd_sc_hd__dlclkp_1`) |
| CTS clock buffers | 71 | 77 |
| Detailed-route wire / vias | 71,488 µm / 19,639 | 73,342 µm / 20,721 |
| Open-deck DRC / LVS | 0 items / match | 0 items / match |

B’s directed simulation drains a frame before sleeping, holds the gated clock low during idle, then wakes and processes another frame. It checks gated-clock edge alignment in the simulation model. The visual below documents the mapped ICG and that test evidence; **it is not a waveform**. No B VCD was retained.

![Configuration B ICG and clock-gating evidence (not a waveform)](images/config_b_clock_gating.png)

## C: a documented placement limit

C added a small PMU and two-domain UPF/isolation intent. Functional tests and bounded 18-step SAT checks passed, and a floorplan contained 37 qualified isolation cells. The final fixed-core attempt completed global placement but detailed placement reported 268 legalization violations. At the saved checkpoint, post-repair movable AON area was 4,262.8384 µm² against 3,862.4544 µm² of available legal row area: a 400.3840 µm² deficit. The default domain margin removed legal row space, while timing-driven buffering/resizing increased cell demand. A later `bad_optional_access` followed the legalization violations; its exact software callsite is unknown.

C did not reach CTS, routing, extracted STA, GDS, DRC, or LVS and remains **not accepted**. This image is an ODB-derived floorplan record, not a routed layout.

![Configuration C incomplete floorplan and placement outcome](images/config_c_floorplan.png)

## Scope and limitations

- A and B are accepted at a 12.00 ns mission evaluation period. Their 10.30 ns implementation-target STA was not clean; the project does not claim closure at 10.30 ns.
- Power reports are vectorless estimates with unannotated activity. Activity-based comparison and measured power reduction are not established.
- The selected SKY130HD platform has no valid physical power-switch master. C’s power-off state is logical intent; physical power gating is not demonstrated.
- Portfolio scan D was **not run**. A separate 12-flop scan smoke qualifies limited tool capability only; it does not establish ATPG, fault coverage, or production DFT.
- Open-deck DRC/LVS are not foundry or production sign-off. No fabrication or silicon measurement is claimed.
- The original full A/B/C/D scope is incomplete. The project’s reduced-scope verdict is CV-ready with limitations; see [results and scope](docs/RESULTS.md) and [known limitations](docs/KNOWN_LIMITATIONS.md).

## Reproduce

Start with [the reproduction guide](docs/REPRODUCE.md) for immutable source provenance, pinned tool/image identity, fresh A/B simulation commands, and physical runner commands. Closeout replayed A/B simulations and verified archived physical artifact manifests; it did not freshly rerun the physical implementations. Source copyright and redistribution terms are recorded in the imported RTL provenance. No blanket project license is asserted.
