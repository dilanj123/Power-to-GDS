# Power-to-GDS Timing Contract

Status: frozen conventional implementation-margin methodology. Results are
specific to the named mode, database, and constraints.

## Evidence and disposition

| Run/database | Implementation target | Evaluation period | WNS (ns) | TNS (ns) | Setup | Hold | Result |
|---|---:|---:|---:|---:|---:|---:|---|
| inherited Ibex stress run | 10.00 | 10.00 | -0.1068 | -1.93 | 38 | 0 | non-closing stress point |
| period-only candidate | 10.20 | 10.20 | about -0.10 | -2.74 | 31 | 0 | failed |
| historical period-only candidate | 10.30 | 10.30 | about -0.14 | -7.83 | 96 | 0 | failed |
| period-only candidate | 10.50 | 10.50 | -0.0588205 | -0.0588205 | 1 | 0 | failed |
| re-established accepted margin database | **10.30** | **10.50** | **+0.061130657792** | **0** | **0** | **0** | timing-clean with electrical residuals |

The accepted database is the explicitly re-established 10.30 ns implementation
with its own-target setup failures retained and disclosed. It is evaluated at
10.50 ns without changing its physical database or parasitics.

## Frozen comparison method

- **Implementation target:** 10.30 ns for all primary A/B/C/D configurations.
- **Mission/evaluation period:** 10.50 ns for all primary configurations.
- **Mission SDC:** same functional clock, 10.50 ns virtual I/O clock, existing
  2.06 ns input/output delays, clock relationships, uncertainty, latency, and
  exceptions. Any source-interface-specific mapping of ports must be recorded
  before the A implementation and held constant across variants.
- **Mission timing acceptance:** WNS >= 0, TNS = 0, zero setup violations, and
  zero hold violations at the agreed corner.
- **Electrical checks:** max slew and max capacitance are reported separately;
  their violations are not waived by setup/hold acceptance.
- **Scan mode:** separate scan-shift SDC and analysis. Mission timing does not
  establish scan-shift timing.
- **Exceptions:** no broad false paths, multicycle paths, uncertainty changes,
  or path-specific workarounds. Any mode-specific exception requires a
  documented architectural reason and consistent application.

The implementation target is reported for transparency. A design that fails
at its implementation target but passes the common 10.50 ns mission analysis
must be labeled accordingly; the implementation-target failure is not hidden.

## Constraints and virtual clock

The accepted conventional Ibex SDC has a physical `core_clock` and a virtual
`vclk_core_clock`, both evaluated at 10.50 ns in the mission analysis. The
10.30 ns implementation SDC derived 2.06 ns I/O delays from the 20% setting;
the mission SDC retained those exact values. Its virtual I/O clock has
1.095 ns source latency; the physical core clock is propagated through the
CTS network in the database. No false-path or multicycle exceptions are
present. `STA-0450 virtual clock vclk_core_clock can not be propagated` is
expected because a virtual clock has no physical clock network.
It does not remove I/O delays: reg-to-output paths, including
`instr_addr_o[*]`, remain timed in the accepted report.

The mission STA has WNS `+0.061130657792 ns`, TNS `0`, setup `0`, and hold `0`.
High-precision checks find electrical residuals on data nets; see
`results/processed/phase0-ibex-10p3ns-reestablished.md`. These make the result
**TIMING_CLEAN_WITH_ELECTRICAL_RESIDUALS**, not fully physically clean.

## Historical decision context

Period-only implementations were physically non-monotonic. The 10.50 ns
implementation-target database failed one reg-to-output path; a separate
10.30 ns-built database passed the 10.50 ns read-only mission evaluation.
Decision D-008 records the implementation-margin method. No additional period
sweep or timing-repair setting is authorized by this timing contract.
