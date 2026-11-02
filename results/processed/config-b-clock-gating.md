# Configuration B — clock-gating qualification

Status: **PASS at the 12.00 ns mission evaluation period** for the bounded
clock-gating scope. B adds one mapped clock gate to accepted Configuration A
while holding the functional RTL, 32x24 parameters, floorplan geometry,
library, absolute I/O delays, and pinned toolchain fixed. B has no PMU, UPF,
isolation, or scan.

## Frozen inputs and B-only delta

- Functional source: `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`, top
  `rtl_to_pixels_top_pipelined`, `IMG_WIDTH=32`, `IMG_HEIGHT=24`.
- Project wrapper: `flow/phase1/config-b/config_b_top.sv`. Input and output
  EOL handshakes are counted independently; `m_tlast` is treated as EOL, not
  frame completion. A pending sleep request lets the active frame finish and
  waits for all 24 input and 24 output lines to transfer before gating. A
  pending request blocks admission of a new frame.
- `OPENROAD_CLKGATE` maps to exactly one
  `sky130_fd_sc_hd__dlclkp_1`. Control/wake logic remains on the ungated
  clock. `test_mode` bypasses the sleep gate for future scan use.
- No imported functional RTL, timing exception, I/O delay, PDK/library,
  `DONT_USE` policy, synthesis/physical setting, or tool revision changed.
- Implementation target: 10.30 ns; mission evaluation: 12.00 ns. Input and
  output delays remain 2.06 ns; virtual-clock latency remains 1.095 ns. The
  ICG output is declared as generated `func_clock`.
- Die: 263.770 x 263.770 µm. Core: `(1.380, 2.720)` to
  `(262.660, 261.120)` µm; area 67,514.752 µm². A's explicit geometry is
  retained. Pinned ORFS treats explicit DIE/CORE geometry and
  `CORE_UTILIZATION` as exclusive floorplan initialization methods. B
  therefore uses the fixed geometry with `PLACE_DENSITY=0.60` and
  `PLACE_DENSITY_LB_ADDON=0.25`; A's `CORE_UTILIZATION=50` derived the frozen
  geometry and is not an additional initializer. Random seed remains
  `FLOW_DEFAULT / UNCONTROLLED`.
- Runtime: pinned Linux/arm64 image
  `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`,
  image ID `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`.
  Tool revisions and platform input hashes are in
  `results/processed/runtime-platform-manifest.md`.

## Functional verification

The existing source tests were reused, with one project-owned clock-gate
test:

- Source frame tests: 4/4 pass; each frame transferred 768 input and output
  pixels with zero reference mismatches. Tests exercised reset, APB setup,
  output stalls, and consecutive frames.
- Source streaming tests: 5/5 pass; source gaps and downstream backpressure
  transferred 768/768 pixels with zero mismatch.
- B test: 1/1 pass. A sleep request arrives mid-frame; the frame completes
  with all 768 inputs and outputs and zero reference mismatches before the
  gate stops. New SOF is not accepted while asleep. Test-mode bypass toggles
  the gated clock; the clock stops again after test mode exits. Wake processes
  a second complete 768-pixel frame; APB frame count reads 2.
- A simulation-only latch ICG model checks that gated-clock transitions
  align with the source-clock phase. This is functional simulation evidence,
  not a physical glitch-immunity proof.

Logs are retained in `results/raw/phase1-config-b/artifacts/simulation/`.

## Implementation and timing

Pinned ORFS completed synthesis, floorplan, placement, CTS, global route,
detailed route, extraction, final STA, and GDS generation with return code 0.
The synthesis and final netlists contain the mapped ICG. CTS recognized
separate roots: `clk` with one ICG clock-pin sink, `clk_regs` with 15
controller-register sinks, and generated `func_clk` with 696 functional
register sinks. CTS inserted 2 + 3 + 72 = 77 clock buffers; the final
cell-type inventory counts 102 clock-buffer cells after subsequent physical
stages. Mission STA reports the ICG clock-gating setup path and functional
register paths on `func_clock`.

| Metric | A | B |
|---|---:|---:|
| Mapped functional flops | 696 | 696 |
| Additional ungated controller flops | 0 | 15 |
| Mapped ICG cells | 0 | 1 |
| Final non-fill physical instances (including taps) | 3,494 | 3,641 |
| Final reported cell area (includes tap cells) | 40,508.9 µm² | 41,745 µm² |
| Final reported utilization | 60% | 62% |
| CTS-created clock buffers | 71 | 77 |
| Detailed-route wire length | 71,488 µm | 73,342 µm |
| Detailed-route vias | 19,639 | 20,721 |

B's final inventory also reports 4,737 fill cells, 873 tap cells, 102 clock
buffers, 284 timing-repair buffers, 134 inverters, 35 clock inverters, one
clock gate, 711 sequential cells, and 1,501 multi-input combinational cells.
Total inventory including fill is 8,378 instances. Area/utilization include
implementation repair and tap-cell area.

At the 10.30 ns implementation target, final-database STA reports WNS
`-0.207571744919 ns`, TNS `-0.905369162560 ns`, worst hold slack
`+0.416919410229 ns`, and hold TNS `0`. This implementation-target result is
non-closing and remains visible.

At the common 12.00 ns mission period, read-only STA on B's exact final ODB,
SPEF, Liberty, and SDC reports:

- WNS `+1.492426633835 ns`; TNS `0.000000000000 ns`.
- Setup violations `0`; hold violations `0`; worst hold slack
  `+0.416919410229 ns`.
- Max-slew violations `0`; max-capacitance violations `0`.
- `core_clock` controller paths and generated `func_clock` paths are timed.
  The ICG clock-gating setup path is reported; the explicit gating-violator
  query found no violating paths. The virtual-clock I/O constraints remain
  active. No timing exceptions were added.

## Routing and physical checks

- Detailed route completed with final TritonRoute violations `0`; the
  iterative route reduced its initial violation count to zero.
- Global-route antenna check reported zero antenna violations. Final logs
  report zero antenna net violations; no separate final pin-violation count
  is claimed.
- Detailed-route wire length: 73,342 µm; vias: 20,721.
- GDS: `results/raw/phase1-config-b/artifacts/checkpoints/6_final.gds`,
  4,212,848 bytes, SHA-256
  `988a6303047741c1d32862f537d2d118788943298fde9f4407a6cc84a71c0d3b`.
- Pinned KLayout 0.30.12 open-deck DRC returned 0; report count is 0.
- Pinned KLayout open-deck LVS returned 0 and reported
  `Congratulations! Netlists match.`

These are open-deck results, not foundry/production sign-off. The router's
`DRT-0349` LEF58 enclosure warning remains a known limitation.

## Power estimate and limitations

The final `report_power` vectorless estimate is 14.5 mW at the pinned TT,
1.80 V corner, using tool-default activity without VCD/SAIF annotation. This
is not an activity-qualified idle/sleep estimate, measured power, or evidence
of power reduction. Shared A/B/C/D activity comparison remains pending.

B demonstrates bounded functional clock gating with one mapped SKY130HD ICG
and clean 12 ns mission setup/hold STA. It does not establish PMU sequencing,
power-domain behavior, physical power switching, activity-based power
reduction, scan operation, ATPG, fault coverage, production DFT, production
timing closure, or foundry sign-off.

Raw flow, simulation, DRC/LVS and STA logs; checkpoints; reports; and exact
configuration are preserved in `results/raw/phase1-config-b/artifacts/`.
Per-file hashes are in `results/raw/phase1-config-b/artifacts/SHA256SUMS`.
