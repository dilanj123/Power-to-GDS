# Power-to-GDS Requirements

Status: minimum authority contract for Gate 0 and later controlled studies.
Observed results are recorded separately in `docs/PROJECT_STATE.md` and
`results/processed/`; this document defines requirements and boundaries.

## Mandatory project requirements

1. Freeze the ORFS/OpenROAD/Yosys revisions, runtime image, platform inputs,
   and accepted RTL commit before controlled comparisons.
2. Accept an immutable, regression-tested source RTL baseline before importing
   or transforming it.
3. Establish a conventional implementation baseline with reproducible source,
   constraints, platform, and physical-flow settings.
4. For every later configuration, hold the functional source and relevant
   implementation variables constant except for the documented experiment
   delta.
5. Preserve raw implementation evidence locally and publish concise processed
   evidence with bounded claims.
6. Report timing, physical implementation, DFT, UPF, power-estimation, DRC,
   and LVS results only at the evidence level actually executed.

For every gate-defining physical experiment, local raw retention must include,
at minimum, the synthesis ODB, final routed ODB, SPEF, final SDC, final DEF,
major timing reports, complete flow log, exact configuration, and a SHA-256
artifact manifest. Raw artifacts remain ignored by Git; processed evidence
must name the raw directory and artifact manifest.

## Experimental objectives

The planned study compares a conventional design (A), clock-gated design (B),
power-domain/isolation design (C), and scan-enabled design (D). The exact
transformation, interface, and comparison period are frozen only after the
conventional baseline is accepted.

The minimum low-power contract is one always-on control domain and one logical
switchable functional domain, with quiescence, clock gating, isolation, and
supported OpenROAD UPF intent. Physical power switching is conditional on a
valid platform cell and is not assumed.

## Explicit out-of-scope work

The project does not require or claim tapeout, fabrication, silicon
measurement, foundry sign-off, production DRC/LVS, production timing closure,
ATPG, fault coverage, tester qualification, retention, DVFS, or complete
industrial IEEE 1801 support. These may be future extensions only with new
authority and evidence.

No power reduction claim is valid without a controlled activity-based or
otherwise explicitly bounded power comparison. Vectorless reports remain
estimates.
