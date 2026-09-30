# Power-to-GDS Timing Contract

## Existing evidence

The inherited ORFS Ibex 10.00 ns target is retained as a non-closing stress
point, not as a timing-clean Power-to-GDS requirement. Existing routed results
are:

| Implementation target | WNS (ns) | TNS (ns) | Setup | Hold |
|---:|---:|---:|---:|---:|
| 10.00 | -0.1068 | -1.93 | 38 | 0 |
| 10.20 | approximately -0.10 | -2.74 | 31 | 0 |
| 10.30 | -0.14 | -7.83 | 96 | 0 |

The 10.50 ns implementation is authorized as the next and only period-only
experiment. It is not predeclared successful.

## Definitions

- **Implementation target:** the clock period used by timing-driven synthesis
  and physical implementation.
- **Evaluation period:** the period used for a documented read-only STA
  analysis of an existing database; it does not create a new implementation.
- **Comparison baseline:** a frozen conventional implementation only after its
  routed STA meets the acceptance criteria below.

## Timing acceptance

A timing-clean comparison baseline requires, for the named mode/corner:

- WNS >= 0;
- TNS = 0;
- zero setup violations;
- zero hold violations.

Max-slew and max-capacitance violations are reported independently. A result
with clean setup/hold but residual slew/capacitance is not called physically
clean.

No false paths, multicycle paths, uncertainty changes, or broad timing
exceptions may be added to rescue a failing comparison. Scan-shift timing is a
separate unqualified mode unless a dedicated scan SDC is executed.

## Boundaries

The approximate zero-slack periods from existing fixed-database analysis are
analytical only. They are not implementation results and do not predeclare
the outcome of 10.50 ns.
