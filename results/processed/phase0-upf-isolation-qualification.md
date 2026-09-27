# Gate-0 UPF Isolation Qualification

## Scope

Bounded two-domain UPF isolation qualification smoke; not a complete Gate-0
sign-off.

Environment: native Apple-Silicon host, Linux/arm64 Docker, SKY130HD, and
OpenROAD no-GUI flow.

Pinned revisions:

- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`

## Evidence

1. Pinned upstream SKY130HD UPF isolation regression: **PASS**.
2. Upstream generated isolation cells: **19 x**
   `sky130_fd_sc_hd__lpflow_inputiso0n_1`.
3. Project-owned ORFS UPF integration: `POST_SYNTH_TCL` successfully executes
   `read_upf`.
4. UPF intent persisted in `1_synth.odb`: **PASS**.
5. Project `PD_SW` power-domain area: `30 30 60 60 um`.
6. Isolation materialized during floorplan initialization: **PASS**.
7. Isolation instance count: **1**.
8. Isolation cell: `sky130_fd_sc_hd__lpflow_inputiso0n_1`.
9. Detailed placement: **PASS**; the isolation instance is legally placed.
10. CTS survival: **PASS**.
11. Global-route survival: **PASS**.
12. Detailed route: **PASS for this qualification smoke**.
13. Final TritonRoute violation count: **0**.
14. Functional isolation pins: `A`, `SLEEP_B`, `X`.
15. Routed functional isolation connections: **3 / 3** have dbWire geometry.
16. Final antenna checks: **0 net violations; 0 pin violations**.
17. SKY130HD default `DONT_USE_CELLS`: **unchanged throughout**.

## Limitations

- DRT-0349 reports unsupported `LEF58_ENCLOSURE`-without-`CUTCLASS`
  constructs. This is **not** a production/foundry sign-off DRC claim.
- The tiny qualification smoke has incomplete I/O timing constraints. It is
  not timing-clean and does not establish timing closure.
- Earlier smoke PDN generation emitted PDN-0110. This smoke is not
  PDN-clean.
- Physical power-switch-cell realization remains unproven.
- Project PMU behavior remains unproven.
- DFT/scan remains unqualified.
- Activity-based power reduction remains unproven.
- Full industrial IEEE 1801 support is not established.
- OpenROAD hierarchical mode reports a development-status warning.

This evidence does not claim tapeout, silicon measurement, production
sign-off, full UPF support, physical power gating, power reduction, or
scan/ATPG success.
