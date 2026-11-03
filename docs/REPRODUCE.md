# Reproduction

## Frozen source and implementation environment

- Source repository: <https://github.com/dilanj123/from-rtl-to-pixels>
- Source commit: `ad35514c990f6e1c9eb9fa18aee9d906f9df7721`
- Top and parameters: `rtl_to_pixels_top_pipelined`, 32×24
- ORFS: `3a964e13f11a4e435aac01ffa14db0a7d2853720`
- OpenROAD: `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca`
- Yosys: `a5af9d690a43744bf6b2cc3dea2717c16b54621c`
- Image: `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`
- Image digest: `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`
- Platform: ORFS SKY130HD, `sky130_fd_sc_hd`, TT 0.025 °C / 1.80 V.

The exact platform and flow-script input hashes are in
[`runtime-platform-manifest.md`](../results/processed/runtime-platform-manifest.md).
The immutable RTL files are copied under `rtl/imported/` with their own
`SHA256SUMS` and provenance notice.

## Fresh functional replay

Use a clean checkout of the exact source commit. The checked closeout checkout
was `$HOME/Projects/from-rtl-to-pixels`; it was clean at that commit. With
Verilator and that checkout's Cocotb virtual environment available:

```sh
cd "$HOME/Projects/Power-to-GDS"
git clone https://github.com/dilanj123/from-rtl-to-pixels "$HOME/Projects/from-rtl-to-pixels-clean"
git -C "$HOME/Projects/from-rtl-to-pixels-clean" checkout --detach ad35514c990f6e1c9eb9fa18aee9d906f9df7721
cd "$HOME/Projects/from-rtl-to-pixels-clean"
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
```

The source project's README documents this environment setup. The closeout
replay used the existing `.venv` and host Verilator 5.052 / Cocotb 2.1.0. It
did not modify source RTL. Review the source repository's
`THIRD_PARTY_NOTICES.md` for provenance and license details.

```sh
cd "$HOME/Projects/Power-to-GDS"
PATH="$HOME/Projects/from-rtl-to-pixels-clean/.venv/bin:$PATH" \
  scripts/run_config_a_sim.sh "$HOME/Projects/from-rtl-to-pixels-clean" \
  "$PWD/results/raw/reduced-scope/repro-a-sim"
scripts/run_config_b_sim.sh "$HOME/Projects/from-rtl-to-pixels-clean" \
  "$PWD/results/raw/reduced-scope/repro-b-sim"
```

Closeout replay result: A source/frame suite 4/4 and streaming suite 5/5
passed. B source/frame 4/4, streaming 5/5, and directed clock-gating test 1/1
passed. Fresh logs and Cocotb XML are under
`results/raw/reduced-scope/`. The first A invocation without adding the
source virtual environment to `PATH` exited before tests because
`cocotb-config` was not on the host path; the command above is the successful
invocation.

## Physical flow commands

The existing project runners are the canonical entry points. Run each in a
fresh workspace; do not reuse the retained evidence directories:

```sh
cd "$HOME/Projects/Power-to-GDS"
PTG_WORK_HOME_REL=results/raw/reproduction/config-a-work \
PTG_FLOW_LOG="$PWD/results/raw/reproduction/config-a-flow.log" \
  scripts/run_config_a_orfs.sh
PTG_WORK_HOME_REL=results/raw/reproduction/config-b-work \
PTG_FLOW_LOG="$PWD/results/raw/reproduction/config-b-flow.log" \
  scripts/run_config_b_orfs.sh all
```

These runners use the project's pinned Docker image and project configurations.
For accepted physical evidence, A and B artifact manifests are retained at
`results/raw/phase1-config-a/artifacts/SHA256SUMS` and
`results/raw/phase1-config-b/artifacts/SHA256SUMS`; every listed file
verified during closeout. The current host did not run a fresh physical
replay. Therefore the archived physical results are hash-verified evidence,
not a claim that the complete physical flow was independently reproduced
during this closeout.

The accepted mission STA uses read-only evaluation at 12.00 ns on each exact
final ODB/SPEF with the preserved I/O assumptions. Detailed commands and
GDS/open-deck DRC/LVS invocations are included in
`results/processed/config-a-timing-recovery.md` and
`results/processed/config-b-clock-gating.md`.

Do not run C or portfolio D from these instructions. C's single fixed-core
recovery budget is exhausted; D was blocked by C and remains unimplemented.
