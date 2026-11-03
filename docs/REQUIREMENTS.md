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
power-domain/isolation design (C), and scan-enabled design (D). Gate 1 freezes
the source boundary, transformation semantics, and mission/evaluation timing
method. Configuration A then establishes and freezes its concrete core
geometry, resolved implementation settings, and port constraints before any
B/C/D transformation. Later configurations must use those same values.

The minimum low-power contract is one always-on control domain and one logical
switchable functional domain, with quiescence, clock gating, isolation, and
supported OpenROAD UPF intent. Physical power switching is conditional on a
valid platform cell and is not assumed.

## ASIC experiment sizing amendment (D-011)

The immutable source project's original 640x480 configuration and regression
remain intact. The physical A/B/C/D study uses the same source top parameterized
to `IMG_WIDTH=32`, `IMG_HEIGHT=24` (768 pixels; 512 bits of line-buffer state
before mapping). This is an experiment-size choice, not a change to the source
design's canonical dimensions or RTL. The 32x24 setting is accepted only after
the existing parameterized source testbench passes at those dimensions. All
variants use the same dimensions and activity workload.

## Explicit out-of-scope work

The project does not require or claim tapeout, fabrication, silicon
measurement, foundry sign-off, production DRC/LVS, production timing closure,
ATPG, fault coverage, tester qualification, retention, DVFS, or complete
industrial IEEE 1801 support. These may be future extensions only with new
authority and evidence.

No power reduction claim is valid without a controlled activity-based or
otherwise explicitly bounded power comparison. Vectorless reports remain
estimates.

## Reduced-scope portfolio deliverable (D-017)

The original A/B/C/D study remains the full project objective. Its original
Gate 4 requires physical C and D, and its original Gate 5 requirements remain
historical acceptance criteria; neither gate is retroactively marked passed.

For a bounded CV portfolio deliverable, D-017 permits a separate
`REDUCED_SCOPE_PORTFOLIO_STUDY` consisting of:

1. accepted conventional A and clock-gated B physical implementations;
2. C functional, bounded-formal, and UPF evidence plus the placement-failure
   investigation, with C explicitly not physically accepted;
3. the previously qualified small DFT/scan capability smoke, with no
   portfolio D scan implementation;
4. public, evidence-linked results, limitations, and exact reproduction
   instructions; and
5. clean A/B simulation replays using the existing runners, plus verified
   source identity and archived A/B physical artifact manifests.

This reduced deliverable does not require another C or D implementation and
does not claim a clean A/B physical replay during closeout. Its acceptance is
reported separately from original Gate 4/5. It does not change RTL, product
requirements, or the original full-scope acceptance criteria.
