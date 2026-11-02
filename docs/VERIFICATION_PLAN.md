# A/B/C/D Verification Plan

Status: frozen verification requirements. No low-power simulation or PMU
formal result is claimed by this document.

## Immutable functional reference

Use source commit `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`, top
`rtl_to_pixels_top_pipelined`, and its existing reference model/scoreboard.
The source project's clean-checkout regression evidence is
`results/processed/imported-rtl-acceptance.md`.

The scoreboard compares output pixel data, valid/ready transfers, SOF/EOL
metadata, APB reads/writes/status, ordering, and frame completion. It detects
lost, duplicated, reordered, or corrupted output transactions. Every A/B/C/D
variant must produce the same functional result for the same accepted input
and configuration sequence.

## Required directed scenarios

1. Normal active operation and reset/startup.
2. Idle sleep request after full drain.
3. Sleep with in-flight pixels and pipeline stages occupied.
4. Quiesce blocks every new accept while prior accepted work drains.
5. Clock-gate transition occurs only after quiescence.
6. Isolation asserts after clock gating and before logical off intent.
7. Logical off holds isolation and blocks functional service.
8. Wake removes logical off, observes the four-AON-cycle guard, clocks two
   functional reset cycles, then de-isolates.
9. Repeated sleep/wake with scoreboard continuity and required software
   reinitialization after each logical off.
10. Reset assertion in every PMU state, with safe isolation/clock behavior.
11. APB request races against quiesce/sleep: AON returns `PREADY=1`,
    `PSLVERR=1`, `PRDATA=0`; the access does not reach the functional block.
    A same-cycle sleep request takes priority.
12. `power_down_req` outside `ACTIVE` is ignored. `wake_req` in any non-active
    state is latched and honored only after mandatory ordering. Reset in any
    state restarts safely through isolation and two functional reset cycles.

The no-timeout policy is conditional on fairness: accepted work eventually
completes. A blocked operation must leave the PMU safely in `QUIESCE`; it may
not be discarded to force shutdown.

## Activity workload and power stimulus

The common functional activity source is the accepted source regression's
640x480 real-image workload, using
`tb/images/Tokinokane2005-1-4.jpg` at SHA-256
`8331a2d0edb64057fdf31b1b1385430c58b2698942ef7d29e00e392b7350d5e4` and the
documented `run_real_image_regression.sh` driver. The same APB setup and stream
sequence is used for all variants. A fixed drained idle interval of 1,000
functional-clock cycles follows the frame for the clock/power experiment; the
stimulus harness, APB values, waveform, hashes, and annotation coverage must
be archived before power numbers are accepted. Sleep/wake directed cases use
separate named tests and are not mixed into the active-frame power window.

Configuration D's primary power report is mission mode with scan enable
inactive. Scan-shift activity/timing is a separate mode and must be labeled
separately.

## Power report admissibility

The common activity stimulus, corner, voltage, evaluation period, final
analysis stage, tool/library hashes, report script, and parser are held
constant. VCD/SAIF activity may be used only after its exact import mechanism
and comparable annotation coverage are demonstrated on all variants. Until
then, report only bounded vectorless estimates and make no power-reduction
claim.
