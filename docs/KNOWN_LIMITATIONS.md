# Known limitations

- **Original full scope is incomplete.** Original Gate 4 required physical C
  and D; C was not accepted and portfolio D was not run. Original Gate 5 is
  not declared complete. The reduced-scope CV verdict is separate.
- **C physical implementation failed.** The final authorized fixed-core
  attempt completed global placement but detailed placement left 268
  legalization violations. C did not reach CTS, routing, extracted STA, GDS,
  DRC, or LVS. Evidence does not establish one exclusive root cause.
- **No physical power switch.** The selected SKY130HD platform has no valid
  physical switch master. C's POWER_OFF is logical power intent; physical
  supply interruption and silicon power gating are not demonstrated.
- **Formal scope is bounded.** C's 18-step SAT checks are bounded checks, not
  an unbounded proof of the PMU protocol.
- **No portfolio scan implementation.** A separate 12-flop smoke proves a
  limited scan insertion/routing capability only. Portfolio D is NOT RUN;
  ATPG, fault simulation, fault coverage, scan-shift timing closure, and
  production DFT were not qualified.
- **Power is not compared by workload.** The available report_power totals
  are vectorless estimates with unannotated activity. Activity-based power
  comparison is not qualified; no power-reduction or measured-power claim is
  made.
- **Timing periods matter.** A and B pass the common 12.00 ns mission STA.
  Historical failures at the 10.30 ns implementation target remain in their
  reports. A also failed its earlier 10.50 ns mission attempt. The project
  does not claim timing closure at 10.30 or 10.50 ns.
- **Open decks are not sign-off.** A/B DRC/LVS results use the pinned
  open-source SKY130HD decks. They are not foundry or production sign-off.
- **Physical replay boundary.** Closeout freshly replayed A/B simulations and
  verified archived physical SHA256 manifests, but did not freshly rerun the
  A/B physical implementation. Reproduction instructions are provided for a
  future fresh run.
- **No fabrication.** No tapeout, fabricated silicon, or silicon measurement
  is claimed.
