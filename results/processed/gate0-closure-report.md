# Gate-0 closure disposition

Status: **NOT CLOSED**. The required 10.50 ns conventional baseline failed
final routed STA, so the project remains at a qualified-but-open Gate 0.

## Proven in Prompt A

- Runtime and platform identity are recorded in
  `results/processed/runtime-platform-manifest.md`, including image digest and
  SHA-256 hashes of canonical SKY130HD and flow inputs.
- Minimum authority documents were created for requirements,
  microarchitecture, timing, and supported decisions. Other expected authority
  files remain absent and are explicitly not fabricated.
- The immutable source baseline
  `ad35514c990f6e1c9eb9fa18aee9d906f9df7721` was tested from a fresh detached
  clone. The documented lint, unit, integration, real-image, and formal
  targets all returned `0`.
- The bounded reproducibility bundle passed the tool smoke, pinned UPF
  isolation regression, pinned DFT regression, and report-power capability
  check.
- `report_power` is qualified only as a vectorless estimate in the pinned
  image/checkpoint. It is not measured power and does not support a power
  reduction claim by itself.
- The minimum PMU/domain contract is frozen as a proposed interface and
  sequencing boundary for later verification; no PMU RTL or formal proof is
  claimed.

## Conventional baseline decision

The fresh 10.50 ns run changed only the clock-period setting from the 10.30 ns
configuration and completed through extraction with flow RC `0`. Final STA
failed with WNS/TNS `-0.0588205 ns`, one setup violation, and zero hold
violations. Max-slew violations were `2`; max-capacitance violations were `0`.
The detailed route and antenna checks were zero, but no GDS/DRC/LVS was run for
this failed timing candidate.

Therefore 10.50 ns is **not** frozen as the conventional A/B/C/D baseline.
Period-only experiments are hard-stopped. A/B/C/D work is not authorized.

## Existing bounded limitations

- POWER-000 power-switch qualification remains classification B: OpenROAD
  supports intent, mapping, and PDN insertion, but the pinned SKY130HD library
  has no valid physical switch master.
- DFT remains bounded to demonstrated scan replacement, stitching, physical
  scan routing, and integration; ATPG, coverage, and production DFT are not
  proven.
- Open-deck DRC/LVS is not foundry sign-off.
- No silicon, production timing closure, retention, DVFS, full industrial
  IEEE-1801 support, or measured power reduction is claimed.

## Required next decision

Before any later low-power study, authorize one evidence-based timing strategy:
implementation margin or timing-repair configuration. Do not treat the
analytical approximately `10.56 ns` requirement of the observed output path as
a new implementation target without a separate decision.
