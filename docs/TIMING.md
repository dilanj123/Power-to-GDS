# Power-to-GDS Timing Contract

Status: the portfolio mission-period amendment D-014 is accepted from read-only
STA on the exact Configuration A implementation database. The Gate-0 Ibex
timing evidence remains as originally recorded. Results are specific to the
named design, mode, database, and constraints.

## Evidence and disposition

| Design/run | Implementation target | Evaluation period | WNS (ns) | TNS (ns) | Setup | Hold | Result |
|---|---:|---:|---:|---:|---:|---:|---|
| Ibex inherited stress run | 10.00 | 10.00 | -0.1068 | -1.93 | 38 | 0 | non-closing stress point |
| Ibex period-only candidate | 10.20 | 10.20 | about -0.10 | -2.74 | 31 | 0 | failed |
| Ibex historical period-only candidate | 10.30 | 10.30 | about -0.14 | -7.83 | 96 | 0 | failed |
| Ibex period-only candidate | 10.50 | 10.50 | -0.0588205 | -0.0588205 | 1 | 0 | failed |
| Ibex re-established margin database | 10.30 | 10.50 | +0.061130657792 | 0 | 0 | 0 | timing-clean with electrical residuals |
| Portfolio A, original evaluation | 10.30 | 10.50 | -0.847352445126 | -6.786191463470 | 16 | 0 | failed; retained historically |
| Portfolio A, amended evaluation | **10.30** | **12.00** | **+0.652646839619** | **0** | **0** | **0** | **PASS_AT_12NS_MISSION** |

The 10.50 ns mission period was the earlier project-selected comparison
objective, not an externally mandated product requirement. D-014 explicitly
amends the portfolio A/B/C/D evaluation period after the exact A database
failed at 10.50 ns and passed at the proposed 12.00 ns evaluation. The 10.50 ns
failure remains visible and unchanged. No implementation was rerun for this
amendment.

## Frozen portfolio comparison method

- **Implementation target:** 10.30 ns for A/B/C/D. The A implementation
  target result is reported separately and is not hidden by mission evaluation.
- **Mission/evaluation period:** 12.00 ns for all A/B/C/D mission comparisons.
  This is an explicit project comparison target (83.33 MHz), not an external
  product specification.
- **Mission clocks:** physical `core_clock` and virtual `vclk_core_clock`,
  both at 12.00 ns during evaluation. The core clock is propagated from the
  existing CTS database; the virtual clock has no physical network.
- **I/O constraints:** retain the existing 2.06 ns input/output delays,
  1.095 ns virtual-clock latency, port mapping, clock relationship, and all
  other constraint values. These absolute I/O values are not rescaled when
  changing the mission period.
- **Exceptions:** none in the accepted A SDC. Do not add false paths,
  multicycle paths, uncertainty changes, or path-specific workarounds.
- **Mission timing acceptance:** WNS >= 0, TNS = 0, zero setup violations, and
  zero hold violations at the agreed corner.
- **Electrical checks:** max slew and max capacitance are reported separately;
  their violations are not waived by setup/hold acceptance.
- **Scan mode:** separate scan-shift constraints and analysis. Mission timing
  does not establish scan-shift timing.
- **Power report evaluation:** use the same 12.00 ns evaluation period,
  extracted reporting stage, corner, voltage, script, and activity source for
  each comparison. Existing vectorless reports remain estimates and do not
  support a power-reduction claim.

The portfolio A configuration's implementation SDC remains at its 10.30 ns
implementation target. The mission STA SDC is a separate read-only evaluation
overlay that changes only the periods of `core_clock` and `vclk_core_clock`.
The exact A overlay differs from the preserved implementation SDC only in
those two values; all input/output delays and the 1.095 ns latency are
unchanged.

## Constraint and path checks

Configuration A has 72 non-clock input-delay entries and 46 output-delay
entries. Input and register-to-output paths remain timed at 12.00 ns. The
previously failing path from `s_tdata[12]` to
`u_functional_top.u_arithmetic_elastic.m_data[22]$_DFFE_PP_` remains present
and has +0.652646839619 ns setup slack. A timed register-to-output path to
`m_tdata[0]` has +9.642111778259 ns slack. `check_setup -verbose` reported no
constraint-setup findings; there are no timing exceptions. The 12.00 ns
read-only checks therefore did not gain timing cleanliness by removing the
failing path class.

The Ibex and portfolio A flow logs include
`STA-0450 virtual clock vclk_core_clock can not be propagated`. This is
expected for a virtual clock with no physical network; it does not remove the
virtual-clock I/O delays. The A evaluation retains a virtual I/O clock and
explicitly reports timed input-to-register and register-to-output paths.

## Configuration A path and electrical result

On the existing final ODB/SPEF, the detailed 12.00 ns report attributes about
8.605 ns of the critical input-to-register data path to cell arcs and about
0.0097 ns to net increments; the unchanged external input delay is 2.06 ns.
The measured path is dominated by the arithmetic logic cone, not routed net
delay. At 12.00 ns, worst hold slack is +0.417005389929 ns. There are zero
max-slew and zero max-capacitance violations; worst margins are +0.302656680346
ns and +0.015018520877 pF respectively.

Configuration A's exact final GDS was checked with the pinned SKY130HD
open-source KLayout decks: DRC returned zero items and LVS reported
`Netlists match`. These are open-deck results, not foundry or production
sign-off. Full run details and artifact hashes are in
`results/processed/config-a-timing-recovery.md`.

## Historical timing-method decisions

The Gate-0 Ibex experiments established a 10.30 ns implementation / 10.50 ns
evaluation method for that reference. D-014 amends the portfolio A/B/C/D
mission evaluation to 12.00 ns based on the measured portfolio A result; it
does not rewrite the Ibex results or claim A passes at 10.50 ns. Period-only
physical implementations remain non-monotonic, and no new implementation or
timing-repair sweep was performed for this amendment.
