# Gate-0 closure report

Status: **PASS WITH DECLARED SWITCH-INTENT LIMITATION**.

Gate 0 qualifies the pinned runtime and backend capabilities and freezes the
conventional Ibex margin baseline. The accepted physical implementation used
a 10.30 ns implementation target and passes read-only mission STA at 10.50 ns.
GDS generation and pinned SKY130HD open-deck DRC/LVS also pass. The exact
baseline, finish artifacts, and hashes are recorded in
`results/processed/phase0-ibex-10p3ns-reestablished.md` and retained locally
under `results/raw/phase0-ibex-10p3ns-reestablished/`.

## Gate-0 evidence

- Pinned environment and platform input hashes: PASS; see
  `results/processed/runtime-platform-manifest.md`.
- Immutable source acceptance: PASS at
  `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`; clean detached checkout and
  documented regressions passed.
- Bounded tool/UPF/DFT/report-power reproducibility bundle: PASS; power is
  vectorless estimation only.
- Conventional margin baseline: implementation target `10.30 ns`, mission
  evaluation `10.50 ns`; WNS `+0.061130657792 ns`, TNS `0`, setup `0`, hold
  `0`. Classification is **TIMING_CLEAN_WITH_ELECTRICAL_RESIDUALS**.
- Electrical residual characterization: two data nets show max-slew pin
  violations (three violating pins total), and one of those nets also has a
  max-capacitance violation. No repair was made.
- GDS: generated from the exact accepted final ODB, SHA-256
  `8f21765f53f65769b6b36996c4dc51c715606c11ce70900293a8852a8a7b8bb0`.
- Open-deck DRC: return code `0`, violation count `0`.
- Open-deck LVS: return code `0`, `Netlists match`.
- POWER-000 physical switch feasibility: classification **B**. OpenROAD
  switch intent/mapping/insertion is supported, but the pinned SKY130HD
  platform has no valid physical switch master.
- DFT/scan capability and project scan-routing smoke: passed within the
  bounded documented scope.
- `report_power`: only vectorless estimation is qualified; no activity-based
  power comparison or reduction is proven.

## Frozen baseline method

- Implementation target: `10.30 ns`.
- Mission/evaluation period: `10.50 ns`.
- The 10.00 ns result remains a non-closing stress point. The 10.20 ns and
  10.30 ns period-only runs and the 10.50 ns implementation-target run remain
  historical failed candidates. The accepted baseline is a separate,
  explicitly re-established 10.30 ns physical database evaluated at 10.50 ns.
- The 10.50 ns mission STA changed only the two clock periods; input/output
  delay assumptions, clock relationships, uncertainty, latency, exceptions,
  and parasitics were held fixed. Reg-to-output paths remain timed.
- `STA-0450` is retained and interpreted as the expected warning that a
  virtual clock has no physical network to propagate. The output path group
  and `instr_addr_o[*]` endpoints remain present in STA.
- Open-deck DRC/LVS results are not foundry or production sign-off.

## Proven, not claimed

Gate 0 proves the selected open-tool workflow can execute the named source,
UPF/isolation, scan, timing, GDS, open-deck DRC/LVS, and vectorless power
capability checks. It does not prove physical SKY130HD power switching,
physical power gating, PMU behavior, formal PMU properties, scan ATPG/fault
coverage, measured power reduction, production timing/sign-off, or foundry
sign-off. The pinned ABC9 synthesis assertion remains a known tool warning
with reproducible fully mapped synthesis output.

Raw tool logs and databases are intentionally excluded from Git and retained
locally under `results/raw/`. Processed evidence identifies the raw paths and
finish hash manifest. No low-power configuration B/C/D implementation was
run as part of Gate-0 closure.
