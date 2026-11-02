# Gate-1 engineering contract

Status: **PASS — engineering intent frozen, with later scope amendments
D-011 through D-014**. Configuration A is now accepted at the D-014 12.00 ns
mission evaluation period. The next sequential B-gate task may begin; C/D
remain gated on their preceding configuration reviews. None was implemented
as part of the timing-recovery work.

## Frozen source and boundary

- Source repository: `https://github.com/dilanj123/from-rtl-to-pixels.git`
- Immutable source: `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`
- Selected top: `rtl_to_pixels_top_pipelined`
- Public interface: synchronous active-high reset, ready/valid RGB stream
  with SOF/EOL, and same-clock APB-style configuration. The clean detached
  source regression passed; see `results/processed/imported-rtl-acceptance.md`.
- AON boundary: project wrapper/PMU/quiesce and safe-interface control.
- Switchable boundary: selected functional pixel-processing top (`PD_SW`).
  Source RTL is identical in A/B/C/D. Configuration is reinitialized after
  logical off; no retention is provided.

Scope amendment D-011 retains the source's 640x480 defaults and regression,
but parameterizes the ASIC A/B/C/D study to 32x24 (768 pixels; 512 bits in
the two 8-bit line buffers before mapping). Existing parameterized top and
streaming tests pass at this size. The ASIC activity workload is a deterministic
generated 32x24 frame; the historical 640x480 activity workload is not used
for these smaller physical comparisons. See `docs/DECISIONS.md` D-011.

## Frozen low-power contract

- Domains: one `PD_AON`, one `PD_SW`; no additional islands.
- PMU sequence: `ACTIVE -> QUIESCE -> CLOCK_GATED -> ISOLATE -> POWER_OFF ->
  POWER_ON_WAIT -> DEISOLATE -> ACTIVE`.
- No-timeout policy: rely on explicit environment fairness that accepted
  pixels eventually drain. If not drained, stay in `QUIESCE`; never discard
  accepted work to force shutdown.
- Request races: sleep is accepted only in `ACTIVE`; out-of-state sleep is
  ignored. Wake is latched in any non-active state and never skips ordering.
  APB accesses outside `ACTIVE`, including same-cycle sleep entry, are
  terminated by AON with `PREADY=1`, `PSLVERR=1`, `PRDATA=0`; sleep wins a
  same-cycle APB conflict.
- Reset in any PMU state removes logical off intent, asserts isolation,
  enables the functional clock, holds reset for two functional cycles, then
  de-isolates into `ACTIVE`.
- Wake sequencing: four AON guard cycles after removing logical off intent,
  then two functional reset cycles with isolation held, then de-isolate.
  These are logical cycle guards, not electrical rail-stabilization claims.
- Isolation: parent-side, output clamp zero, `iso_en_n` active low. Qualified
  master family `sky130_fd_sc_hd__lpflow_inputiso0n_1`; select it through
  explicit UPF `use_interface_cell` while preserving the platform-wide
  DONT_USE list unchanged.
- Switch semantics: logical switch intent only. POWER-000 classification B
  remains; no physical SKY130HD switch master or physical power-gating claim.
- Clock gate: pinned ORFS `cells_clkgate_hd.v` maps
  `OPENROAD_CLKGATE(CK,E,GCK)` to `sky130_fd_sc_hd__dlclkp_1`. Wrapper gate
  enable is active high; scan-test bypass is ORed into E because the mapped
  cell has no separate test-enable port. Configuration B must verify the
  mapped instance and gated-clock STA/CTS treatment before proceeding.
- UPF: use the already qualified OpenROAD subset for domains, domain area,
  output isolation, interface-cell selection, and logical switch intent.
  Exclude retention, DVFS, level shifting, complex PST, and full industrial
  IEEE 1801 portability claims.

## Verification and DFT contract

- Scoreboard/reference: accepted source regression reference; compare accepted
  stream transactions, output data/metadata/order, APB behavior, frame status,
  and completion.
- Directed cases: active operation; idle sleep; in-flight drain; block new
  accepts; gate/isolate/logical-off ordering; wake; repeated cycles; reset in
  each PMU state; configuration races; illegal requests. The precise list and
  acceptance behavior are in `docs/VERIFICATION_PLAN.md`.
- Formal targets: legal transitions, quiesce/no-new-accept, no off while
  active, gate/isolation ordering, held isolation, reset-safe wake, no invalid
  responses, and conditional liveness under fairness. Review assumptions,
  vacuity, and covers. No property is yet formally checked.
- DFT: `scan_replace`, `report_dft_plan`, `execute_dft_plan`, generated scan
  ports, physical BTerm placement, and routed chain; initial chain policy is
  `-max_length 8 -clock_mixing no_mix`. `scan_opt` is a no-op.
  ATPG, fault simulation/coverage, compression, tester qualification, and
  production DFT sign-off are excluded.
- Mission and scan timing are separate. The portfolio implementation target
  is `10.30 ns`; the reviewed common mission evaluation period is `12.00 ns`
  under D-014. The earlier 10.50 ns A failure remains documented. Scan shift
  has no timing-closure claim.

## Frozen comparison controls

| Control | Contract |
|---|---|
| Functional RTL | Same immutable source commit for A/B/C/D |
| ORFS/OpenROAD/Yosys/image | Exact revisions and image digest in `results/processed/runtime-platform-manifest.md` |
| Platform/library | SKY130HD `sky130_fd_sc_hd`; compare platform-input hashes before every run |
| Implementation/evaluation timing | 10.30 ns implementation target; 12.00 ns mission evaluation under D-014; 10.50 ns A failure retained historically |
| I/O timing | 2.06 ns input/output delay from the frozen 10.30 ns / 20% convention; virtual I/O clock latency 1.095 ns; propagated core clock; no exceptions; port mapping recorded in A and copied unchanged |
| Core geometry | Frozen from accepted A: DIEAREA 263.770 x 263.770 um; core area 67,514.752 um^2; row extent 261.28 x 258.40 um. Primary variants cannot resize it. Any capacity rescue is separately labeled and excluded from the primary comparison |
| Density controls | `CORE_UTILIZATION=50`, `PLACE_DENSITY_LB_ADDON=0.25`, pinned SKY130HD default `PLACE_DENSITY=0.60`; record resolved A settings and copy them unchanged to B/C/D |
| Synthesis/placement/CTS/routing | Pinned ORFS defaults and platform settings; only documented experiment deltas |
| Random seed | `FLOW_DEFAULT / UNCONTROLLED`; do not invent a seed after baseline |
| PDN and pins | Pinned `sky130hd/pdn.tcl`; platform horizontal/vertical pin layers met3/met2; any scan BTerms follow the already qualified explicit placement operation |
| Activity workload | D-011 amendment: deterministic generated 32x24 RGB frame (768 pixels), APB control `0x00=1`, threshold `0x04=128`, bypass `0`; exact generator/seed/frame hash are frozen with A, then 1,000 drained idle cycles. The 640x480 image workload remains source-regression evidence only. Archive the emitted waveform and annotation coverage before comparative power claims |
| Power analysis | SKY130HD TT 0.025 C / 1.80 V library, 12.00 ns mission evaluation, final extracted stage. Create and hash one project report script/parser before power comparison, then reuse unchanged. Until common VCD/SAIF annotation is qualified, vectorless results are estimates and cannot support a reduction claim |
| Metrics | Cell/sequence/ICG/isolation counts, area/utilization, stage and final WNS/TNS/setup/hold/slew/cap, CTS sinks/buffers/skew, wire/vias, route/antenna, GDS/open-deck DRC/LVS, and bounded power report fields |

The effective core dimensions and resolved floorplan controls are now recorded
and frozen from accepted A. No silently resized primary comparison is
permitted. A's exact ODB/DEF/SPEF/GDS hashes and read-only 12.00 ns acceptance
are in `results/processed/config-a-timing-recovery.md`.

## Configuration sequence and gate decision

- **A:** conventional implementation only; source-level baseline and geometry
  must pass and be frozen before B.
- **B:** A plus the specified clock-gate wrapper/mapping.
- **C:** B plus PMU, `PD_AON`/`PD_SW`, and isolation with logical switch intent.
- **D:** C plus the supported scan transformation; scan timing reported
  separately.

Gate 1 passes because source/top selection, domain boundary, PMU behavior and
fairness policy, clock-gating mapping, UPF/isolation subset, mission/scan
timing intent, DFT scope, metrics, and verification/formal strategy are now
specified in authority documents. Execution remains required at later gates.
Prompt B may start with A; B/C/D changes remain gated on A acceptance and each
preceding configuration's verification/evidence review.
