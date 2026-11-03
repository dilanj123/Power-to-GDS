# Results and portfolio summary

## A/B physical comparison

Both configurations use source commit
`ad35514c990f6e1c9eb9fa18aee9d906f9df7721`, top
`rtl_to_pixels_top_pipelined`, 32×24 parameters, SKY130HD, a 10.30 ns
implementation target, and 12.00 ns mission evaluation. Geometry and timing
constraints are held to the accepted comparison contract. Values below are
from the preserved reports; mission timing is read-only STA on the exact
final ODB/SPEF.

The outer die/core and I/O constraints match. The pinned ORFS flow treats
`CORE_UTILIZATION` and explicit DIE/CORE geometry as alternative floorplan
initializers: A uses its accepted 50% core-utilization initializer, while B
uses the same frozen explicit geometry with `PLACE_DENSITY=0.60` and the same
0.25 lower-bound addon. This resolved-flow distinction is part of the
recorded configurations. Read the area/utilization and physical deltas as
measured outcomes of this accepted pair, not as a perfectly isolated causal
estimate of clock-gating overhead.

| Metric | A: conventional | B: clock-gated |
|---|---:|---:|
| Final non-fill physical instances | 3,494 | 3,641 |
| Final standard-cell area | 40,508.9 µm² | 41,745 µm² |
| Final reported utilization | 60% | 62% |
| Mapped functional flops | 696 | 696 |
| Additional ungated control flops | 0 | 15 |
| Mapped integrated clock gates | 0 | 1 (`sky130_fd_sc_hd__dlclkp_1`) |
| 10.30 ns target WNS / TNS | −1.04735 / −10.1545 ns | −0.207571744919 / −0.905369162560 ns |
| CTS-created clock buffers | 71 | 77 |
| Detailed-route wire length | 71,488 µm | 73,342 µm |
| Detailed-route vias | 19,639 | 20,721 |
| Mission WNS at 12.00 ns | +0.652646839619 ns | +1.492426633835 ns |
| Mission TNS | 0 | 0 |
| Mission setup / hold violations | 0 / 0 | 0 / 0 |
| Mission max-slew / max-cap violations | 0 / 0 | 0 / 0 |
| Detailed-route violations | 0 | 0 |
| GDS generated | Yes | Yes |
| Pinned open-deck DRC | 0 report items | 0 report items |
| Pinned open-deck LVS | Netlists match | Netlists match |
| Vectorless report_power | 14.0082 mW | 14.5 mW |

The vectorless power totals use tool-default activity and are not an
activity-qualified comparison. Do not interpret their difference as power
reduction. Area, buffers, and routing are outcomes of these two physical
runs; this single pair does not isolate clock gating as the cause of every
QoR difference.

The 10.30 ns implementation target is not the mission acceptance period.
Both runs retain their historical non-closing 10.30 ns implementation-target
STA results (A had 18 setup violations; B's cited target report records
negative WNS/TNS). A also failed its earlier 10.50 ns mission attempt with
WNS/TNS `−0.847352445126 / −6.786191463470 ns` and 16 setup endpoints. D-014
reviewed the mission period to 12.00 ns without altering the accepted
physical database or I/O constraints. See the detailed A and B reports for
those failures and path context.

## C: useful verification, incomplete physical implementation

The imported Sobel RTL remains unchanged. The project-owned C wrapper passed
directed tests including three 32×24 frames, frame completion during a
pending sleep request, output draining, wake sequencing, reset/state cases,
and APB behavior. Bounded 18-step SAT checks passed; this is not an
unbounded proof. Prior floorplan evidence showed two UPF domains, one logical
switch intent, and 37 parent-side
`sky130_fd_sc_hd__lpflow_inputiso0n_1` isolation cells.

The physical investigation found several distinct failures: the initial
domain rectangle was rejected as out of range; a diagnostic without an area
encountered RePlAce divergence; a later region triggered the pinned flow's
density guard; and the one final D-016 region completed global placement but
left 268 detailed-placement legalization violations, including site
alignment, overlap, spacing, and padding problems. Evidence does not isolate
one single root cause. The fixed-core domain partition could not be completed
within the authorized scope. C did not reach CTS, routing, extracted STA, GDS,
DRC, or LVS. C remains **NOT ACCEPTED**.

## DFT/scan scope

Separate pinned OpenROAD regressions and a project-owned 12-flop smoke passed
scan replacement, chain planning/stitching, BTerm placement, CTS survival,
and routed scan connectivity. This is DFT capability evidence only.
Portfolio D was **NOT RUN**. ATPG, fault simulation, fault coverage, tester
qualification, production DFT, and scan-shift timing closure were not
performed.

## Power classification

Power results are **VECTORLESS ESTIMATES ONLY**. The qualified report method
found unannotated objects and did not use a matched VCD/SAIF activity input.
Activity-based power comparison is **NOT QUALIFIED**; no power-reduction
claim is made. The pinned platform also has no valid physical SKY130HD
power-switch master, so C's switch is logical intent only.

## CV project entry

**Power-to-GDS — SKY130HD RTL-to-GDS study:** Implemented and compared
conventional and clock-gated configurations of an immutable Sobel streaming
pipeline using a pinned OpenROAD flow; completed synthesis through detailed
routing, extracted STA, GDS generation, and open-deck DRC/LVS for A/B. Added
and verified a bounded PMU/UPF isolation experiment, then diagnosed a fixed-
core placement limitation that prevented physical C acceptance. Separately
qualified a small OpenROAD scan-routing smoke; portfolio scan was not run.

## Short interview explanation

“I took an already verified Sobel pipeline, kept its RTL fixed, and built a
conventional and a clock-gated SKY130HD implementation. Both passed the
project’s 12 ns mission STA and the pinned open-deck DRC/LVS checks. I also
verified a small PMU/isolation design logically and with bounded SAT, but its
power-domain partition could not be legalized in the fixed core, so I stopped
instead of presenting it as a successful physical implementation. A separate
small scan smoke qualified the tool capability; I did not claim portfolio
ATPG or power savings.”

## Detailed evidence

- [Configuration A baseline](../results/processed/config-a-baseline.md) and
  [A 12 ns timing/finishing qualification](../results/processed/config-a-timing-recovery.md)
- [Configuration B clock-gating qualification](../results/processed/config-b-clock-gating.md)
- [Configuration C final placement recovery](../results/processed/config-c-final-recovery.md)
- [Earlier C functional/UPF qualification](../results/processed/config-c-isolation.md)
- [Separate scan physical-routing smoke](../results/processed/phase0-dft-scan-route-qualification.md)
- [Pinned runtime/platform hashes](../results/processed/runtime-platform-manifest.md)
