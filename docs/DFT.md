# DFT Contract

Status: frozen supported OpenROAD scan scope and later acceptance criteria.
No ATPG, fault-coverage, or production DFT result is claimed.

## Supported scope

The pinned OpenROAD flow supports and the project has exercised:

- `scan_replace`;
- `report_dft_plan`;
- `execute_dft_plan`;
- project policy `-max_length 8 -clock_mixing no_mix` remains the historical
  Gate-1 default. For the smaller ASIC scope, a maximum chain length of 64 is
  proposed for D only if the pinned tool accepts it. Final D chain policy is
  frozen only after Configuration A's mapped flop count is known; no scan
  insertion policy has changed and no D implementation is claimed;
- generated scan input, enable, and output ports;
- explicit physical scan BTerm placement;
- a stitched scan chain with routed connectivity through detailed route.

The project smoke evidence is
`results/processed/phase0-dft-scan-route-qualification.md`. OpenROAD
`scan_opt` is a no-op in the pinned revision. Scan mode must force the
technology clock gate open through its wrapper test-mode enable.

## Timing and exclusions

Mission and scan-shift timing are separate analyses. Under D-014, portfolio
mission evaluation is 12.00 ns; the historical A failure at 10.50 ns remains
recorded. Passing mission timing does not imply scan-shift timing closure.
Later D configuration must report scan ports, chain count/length, scan-cell
count, BTerm placement, routing, and mission/scan timing separately.

Out of scope: ATPG, fault simulation, fault coverage, compression, tester
qualification, manufacturing test qualification, and production DFT sign-off.
