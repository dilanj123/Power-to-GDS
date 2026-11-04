# Power-to-GDS

## Objective

This project compares conventional and clock-gated ASIC implementations of an already verified Sobel streaming pipeline. The functional RTL is imported unchanged from [`from-rtl-to-pixels`](https://github.com/dilanj123/from-rtl-to-pixels), immutable commit `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`, and parameterized to 32×24 pixels for a small SKY130HD physical study. Source ownership and redistribution terms are documented in the [import provenance record](rtl/imported/from-rtl-to-pixels-ad35514/PROVENANCE.md).

## A/B routed layouts

These are captures from the saved final routed GDS files, rendered at identical scale with pinned KLayout. Only met3, met4 and met5 drawing layers are displayed; they are not all-layer views. The [image record](images/README.md) gives source artifact hashes and renderer details.

| A — conventional | B — one integrated clock gate |
|---|---|
| ![Configuration A routed layout, met3–met5](images/config_a_layout.png) | ![Configuration B routed layout, met3–met5](images/config_b_layout.png) |

## Physical comparison

Both runs used a 10.30 ns implementation target and passed read-only mission STA at 12.00 ns. The figures below are measured implementation outcomes, not proof that clock gating caused every difference.

| Metric | A | B |
|---|---:|---:|
| Final standard-cell area | 40,508.9 µm² | 41,745 µm² |
| Reported utilization | 60% | 62% |
| Mission WNS / TNS at 12.00 ns | +0.6526 / 0 ns | +1.4924 / 0 ns |
| Setup / hold violations | 0 / 0 | 0 / 0 |
| Mapped ICGs | 0 | 1 (`sky130_fd_sc_hd__dlclkp_1`) |
| CTS clock buffers | 71 | 77 |
| Routed wire / vias | 71,488 µm / 19,639 | 73,342 µm / 20,721 |
| Open-deck DRC / LVS | 0 report items / match | 0 report items / match |

## Clock gating in B

B maps one SKY130HD integrated clock gate. The directed test requests sleep during a frame, drains all 768 accepted pixels, checks the gated clock remains low across five parent-clock edges, then wakes and processes a second frame. It also checks gated-clock edge alignment in the simulation model, test-mode bypass, and APB frame count.

![B mapped ICG and saved directed-test evidence; this is not a waveform](images/config_b_clock_gating.png)

The panel is an engineering evidence summary, not a captured simulation waveform. No B VCD was retained.

## C placement case study

C added PMU and two-domain UPF/isolation intent. Directed functional tests and bounded 18-step SAT checks passed. The saved floorplan contains 37 isolation cells. In the final fixed-core attempt, global placement completed but detailed placement reported 268 legalization violations. Post-repair movable AON area was 4,262.8384 µm² against 3,862.4544 µm² of legal row area, a 400.3840 µm² deficit. The default power-domain margin and site snapping removed legal row space; timing-driven buffering and resizing increased demand. A later `bad_optional_access` followed the legalization failure, but its exact software callsite is unknown.

C did not reach CTS, routing, extracted STA, GDS, DRC or LVS. It remains **not physically accepted**. The panel is derived from the saved D-016 ODB; it is not a routed layout.

![C incomplete floorplan and measured placement-capacity result](images/config_c_floorplan.png)

See the [C root-cause report](results/processed/config-c-root-cause-audit.md) for the stage-by-stage evidence and limits of the diagnosis.

## Source and implementation structure

- `rtl/imported/` — immutable imported functional RTL and provenance.
- `flow/phase1/config-a/` and `flow/phase1/config-b/` — physical-flow configurations.
- `constraints/` — mission timing constraints.
- `scripts/run_config_a_*` and `scripts/run_config_b_*` — simulation and ORFS entry points.
- `formal/` and `upf/` — bounded C checks and power-intent inputs.
- `docs/RESULTS.md` — detailed comparison, CV entry and interview summary.
- `results/processed/` — bounded reports; raw databases and logs remain local under ignored `results/raw/`.

## Reproduction

Start with [docs/REPRODUCE.md](docs/REPRODUCE.md) for the immutable source, pinned tool and platform identities, successful A/B simulation commands, and physical runner commands. Closeout replayed A/B simulations and verified archived physical SHA256 manifests, but did not freshly rerun the physical implementations. Do not run C recovery or portfolio D from the reproduction instructions.

## Known limitations

- A and B are accepted at 12.00 ns mission evaluation; their 10.30 ns implementation-target timing was not clean. No claim of timing closure at 10.30 ns is made.
- Power reports are vectorless estimates with unannotated activity. Activity-based comparison and measured power reduction are not established.
- SKY130HD has no valid physical power-switch master in the pinned platform. C power-off is logical intent; physical supply interruption is not demonstrated.
- Portfolio C was not physically accepted and portfolio scan D was not run. A separate 12-flop scan smoke qualifies limited tool capability only; no ATPG or fault coverage was established.
- DRC/LVS used pinned open-source decks, not foundry sign-off. No fabrication or silicon measurement is claimed.
- The original full A/B/C/D scope is incomplete. The reduced portfolio disposition is CV-ready with limitations; see [detailed results](docs/RESULTS.md) and [known limitations](docs/KNOWN_LIMITATIONS.md).
