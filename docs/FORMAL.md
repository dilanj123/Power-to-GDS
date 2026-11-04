# PMU formal contract and bounded evidence

## Status

This file preserves the planned PMU property contract and records the bounded checks that were actually run. It is not an unbounded proof, an induction result, or a proof of the Sobel datapath.

## Bounded checks that ran

The pinned Yosys SAT command in `scripts/run_config_c_pmu_formal.sh` ran the PMU and `formal/phase1/config-c/config_c_pmu_formal.sv` for 18 steps with `-prove-asserts -verify`. The run completed successfully with no counterexample to the assertions encoded in that harness. A separate 22-step constrained SAT run emitted `sleep-wake-cover.vcd`, a bounded example trace through sleep and wake. The archived transcript is `results/raw/phase1-config-c/formal-runner.log`; the VCD is under `results/raw/phase1-config-c/formal/`.

The harness instantiates `config_c_pmu` alone. Its assertions check the encoded state range and legal next-state sequence, quiescent indication before entering `CLOCK_GATED`, clock disable before isolation/off, isolation and reset controls in off/wake states, and return to `ACTIVE` after `DEISOLATE`. `functional_quiescent` is an unconstrained harness input. It is not connected to live stream or pipeline state, so these checks do not establish that real accepted work has drained.

## Planned properties not established by those runs

The broader contract remains a verification target, not an executed proof of each item:

- The stream interface blocks new accepts during quiesce and preserves every accepted transaction without loss, duplication, reordering, or invalid response.
- PMU shutdown is safe against the real Sobel pipeline's in-flight work and output backpressure.
- Reset, APB races, and illegal requests satisfy the complete interface-level contract in all reachable states.
- Liveness holds under explicit fairness assumptions; no induction or unbounded liveness proof was run.
- Formal cover properties establish all required sleep/off/wake scenarios. The saved 22-step VCD is one constrained trace, not a cover-property suite.

The directed simulation scenarios are recorded separately in `results/processed/config-c-isolation.md`. C remains physically unaccepted because detailed placement failed; bounded formal results do not change that disposition.

## Assumptions and boundaries

The 18-step harness assumes reset at its initial step and leaves the PMU request and `functional_quiescent` inputs otherwise symbolic. It has no model of analog power-good, supply stabilization, or a physical switch. The actual SKY130HD platform has no qualified physical switch master, so `POWER_OFF` is logical intent only. These checks do not establish UPF completeness, physical power gating, ATPG, fault coverage, or production sign-off.
