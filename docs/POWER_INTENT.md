# Power Intent Contract

Status: frozen configuration-C intent for the Gate-1 engineering contract.
This file specifies a supported subset and does not claim a PMU or C
implementation has been run.

## Domain boundary

- `PD_AON`: project wrapper, PMU, request acceptance/quiesce accounting,
  isolation controls, external safe-interface logic, and always-available
  reset/control.
- `PD_SW`: the accepted `rtl_to_pixels_top_pipelined` functional processing
  block at source commit `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`.
- Single nominal supply/voltage for this MVP. The primary A/B/C/D physical
  comparison uses the same source commit, platform, core geometry, and
  constraints.
- The Gate-1 contract originally stated that `PD_SW` coordinates were
  recorded with A; audit found that A did not record a power-domain region.
  D-015 proposes a row/site-aligned `PD_SW` region within A's unchanged core,
  derived from C's measured domain/AON placement demands. It is a C-only
  proposed experiment and becomes frozen for later variants only if the
  controlled C placement passes. The tiny Gate-0 smoke coordinates are not
  reused as portfolio-area evidence.

The wrapper blocks new stream accepts during quiescence. Every crossing from
`PD_SW` to the AON boundary is clamped to zero while isolation is asserted;
inputs into `PD_SW` are held safe. APB and stream service from the functional
block is unavailable while off. Since retention is excluded, software
reinitializes functional configuration after wake.

## Isolation strategy

- Scope: outputs from `PD_SW` to its parent/AON boundary.
- Clamp: logic zero for this MVP.
- Control: `iso_en_n` active low means isolation asserted, corresponding to
  the qualified UPF `-isolation_sense low` polarity.
- Location: parent side of the boundary (`-location parent`).
- Qualified cell family: `sky130_fd_sc_hd__lpflow_inputiso0n_1`, with
  functional pins `A`, `SLEEP_B`, and `X`.
- Qualification evidence: `results/processed/phase0-upf-isolation-qualification.md`.
  This is a bounded physical integration smoke, not production/foundry DRC.

The cell remains in the platform's default DONT_USE list. The qualified UPF
flow selects it explicitly with `use_interface_cell`; the platform-wide
DONT_USE list is not changed. No global DONT_USE policy change is authorized
by this contract.

## Power-state and switch intent

The PMU sequence and no-timeout fairness policy are defined in
`docs/MICROARCHITECTURE.md`. UPF may describe one logical switch intent for
`PD_SW`; the pinned upstream mapping regression proves mapping/PDN mechanics
using a synthetic test-only master. POWER-000 is classification B: the exact
pinned ORFS SKY130HD platform contains no valid physical header/footer switch
master. Therefore `POWER_OFF` is a logical state only. Configuration C means
**logical switch intent plus a physically implemented isolation/domain
structure**. It does not mean physically power-gated silicon.

## Explicit exclusions

- retention;
- DVFS;
- level shifting for this single-voltage MVP;
- complex power-state tables;
- full IEEE 1801 portability or complete industrial UPF support;
- electrical supply interruption or physical switch-cell implementation.
