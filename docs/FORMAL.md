# PMU Formal Contract

Status: property and assumption plan only. None of these properties is
FORMALLY-CHECKED by this document.

## Safety properties for later execution

- PMU state transitions follow only the specified sequence.
- Once `QUIESCE` begins, no new stream transaction is accepted.
- `CLOCK_GATED` is unreachable while functional work remains in flight.
- Logical power-off intent is never asserted before the clock is gated.
- Isolation is asserted before logical off and held through `POWER_OFF` and
  `POWER_ON_WAIT`.
- De-isolation cannot occur before logical off is removed, the four-cycle AON
  wake guard completes, and two functional reset cycles complete.
- A logically off or isolated functional block cannot emit an externally
  valid response.
- Reset in every PMU state leaves clock/isolation/off controls in the
  documented safe condition.
- Out-of-state sleep requests are ignored; latched wake requests cannot skip
  drain, gate, isolation, or reset ordering; a same-cycle sleep/APB conflict
  rejects the APB request at the AON wrapper.
- No accepted transaction is dropped, duplicated, or reordered across
  quiesce/wake, under the interface protocol assumptions.

## Liveness and assumptions

The design has no quiesce timeout. Liveness properties require an explicit
fairness assumption that each accepted transaction eventually completes and
that the AON clock continues toggling. Under those assumptions, a permitted
sleep request eventually reaches logical off after drain, and a wake request
eventually returns the PMU to `ACTIVE` after the defined guard/reset sequence.
These are logical sequencing assumptions; no physical power-good or rail
stabilization is modeled.

The harness must constrain reset release, APB handshakes, stream valid/ready
stability, and legal request timing. Every proof must review assumptions for
overconstraint/vacuity and include cover traces for sleep, off, wake, and
return to active. Bounded checks must state their bound.

Formal PMU control does not establish analog power behavior, physical switch
correctness, UPF tool completeness, or physical power gating.
