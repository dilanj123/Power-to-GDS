# Configuration A scope qualification

## Scope decision

The A/B/C/D ASIC study uses the immutable `rtl_to_pixels_top_pipelined`
source at `IMG_WIDTH=32`, `IMG_HEIGHT=24`. The source default and accepted
640x480 regression remain unchanged. The reduced frame contains 768 pixels;
the two 8-bit line buffers store 512 bits before mapping. This size is used
only to make the repeated physical study manageable and preserves stream,
Sobel, APB, and frame-boundary behavior.

The 640x480 source regression does not define the ASIC comparison activity
workload. A deterministic generated 32x24 RGB frame is to be frozen with A
(generator, seed, and frame hash) and replayed identically for A/B/C/D.

## Immutable source regression

- Repository: `https://github.com/dilanj123/from-rtl-to-pixels`
- Commit: `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`
- Checkout: fresh detached clone at that commit; initially clean.
- Regression procedure: `make doctor`, `make lint`, `make test-unit`,
  `make test`, `make test-real-image`, and `make formal`.
- Results: release lint, unit, integration, real-image, and selected formal
  regression all passed. Full-image tests processed 307,200 inputs and outputs
  with zero reference mismatches for both source tops.
- Raw stdout/stderr: `results/raw/phase0-config-a/source-regression.log`.

## 32x24 parameterized simulation

The existing source top test and streaming test were run against the exact
immutable source checkout with Verilator 5.052, cocotb 2.1.0, and the source
Python reference. No RTL or testbench changes were made.

| Existing test group | Result | Evidence |
|---|---:|---|
| Main top: four tests covering reset, APB, deterministic full frames, status/frame count, final-output stall and next-frame admission | 4/4 PASS | `results/raw/phase0-config-a/sim-32x24/one-frame.log` |
| Streaming: source gaps, randomized output backpressure, combined gaps/stalls, SOF/EOL stall stability, end-of-frame drain backpressure | 5/5 PASS | `results/raw/phase0-config-a/sim-32x24/streaming.log` |

Each frame accepted and produced 768 pixels with `mismatch_count=0`; observed
SOF/EOL metadata matched expected frame/line positions. No lost, duplicated,
or reordered outputs were reported. The original testbench's APB assertions
passed. This is functional parameter qualification, not PMU verification.

## Contract clarifications

- D-012: latch a sleep request during an active frame, allow that frame and
  final output transfer to complete, block admission of the next frame, then
  enter QUIESCE; no functional input is accepted after QUIESCE starts. PMU
  remains unimplemented.
- D-013: the historical Gate-1 `-max_length 8 -clock_mixing no_mix` policy is
  unchanged. A maximum length of 64 is only a proposal for D, conditional on
  A's mapped flop count and pinned-tool support; freeze before D insertion.
- The 640x480 activity contract in the historical Gate-1 decision is retained
  as history and superseded only for the reduced ASIC experiment by D-011.

## Imported RTL provenance

Twelve required RTL modules are copied byte-for-byte under
`rtl/imported/from-rtl-to-pixels-ad35514/`; per-file SHA-256 values are in
`SHA256SUMS`. Provenance and the upstream copyright notice are recorded in
`PROVENANCE.md`. The source repository grants no general redistribution
license; this project import is owner-authorized and must not be described as
open-source licensed.

Configuration A uses a project-owned parameter-only wrapper. No algorithm,
source RTL, PDK, library, or tool changes are made by this scope decision.
