# Image provenance

All visuals use this repository’s saved implementation evidence. No image was copied from another project or fabricated as a tool screenshot.

## Routed GDS captures

`config_a_layout.png` and `config_b_layout.png` were rendered from the final routed GDS files using KLayout **0.30.12** (`/usr/local/klayout`) in the pinned ARM64 container `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`, image digest `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`.

Both use the repository script [`scripts/klayout_gds_capture.py`](../scripts/klayout_gds_capture.py), SHA-256 `17eed9d5fe118f302d768042eef922ad551f55002259e35f1f7e0d6a9b48437a`, 1440×1080 output, SKY130HD layer properties, the same zoom-to-layout behavior, and the same visible drawing layers (met3, met4, met5). The dense-hatched prBoundary display layer is hidden for legibility. The captures are view images of the saved GDS, not new implementation results.

| Image | Source artifact | Source SHA-256 |
|---|---|---|
| `config_a_layout.png` | `results/raw/phase1-config-a/artifacts/6_final.gds` | `f1b206d44b83de2751b649c701e8a2e4beb0609c37161b657017ea180121c9b6` |
| `config_b_layout.png` | `results/raw/phase1-config-b/artifacts/checkpoints/6_final.gds` | `988a6303047741c1d32862f537d2d118788943298fde9f4407a6cc84a71c0d3b` |

PNG SHA-256 values: A `5579dc17d0778600c2a849503e08efcb6e2bdfdaa5389576c5d6f7aec96a1be7`; B `0591ee822bf58913756192efacc193a81ac9a9ed13b7c0d3c9767d1390406b58`. The reproducible renderer script SHA-256 is recorded in the repository commit and can be checked with `shasum -a 256 scripts/klayout_gds_capture.py`.

## Clock-gating evidence panel

`config_b_clock_gating.png` combines the authentic B GDS capture above with documented design and simulation facts. Its physical references are the same B GDS (SHA-256 above) and `results/raw/phase1-config-b/artifacts/checkpoints/6_final.def`; the DEF places `u_func_clk_gate.latch` as `sky130_fd_sc_hd__dlclkp_1` at (132.020, 141.440) µm. The directed test source is `results/raw/phase1-config-b/artifacts/config/test_config_b_clock_gate.py`; the saved log is `results/raw/phase1-config-b/artifacts/simulation/clock-gate.log`, SHA-256 `0615df21e046e5987b0a1e96c0de9238631b20d37b8769bbe3284436aadd14b4`.

The test evidence covers a mid-frame sleep request, draining 768 accepted pixels to 768 outputs, five parent-clock rising edges with gated clock held low, gated-edge alignment assertions, test-mode bypass/wake, a second 768-pixel frame, and APB count checks. The test source SHA-256 is `073ff10e44a3ce96177ce0b4d7942636b1a5e9c6a55f09207017197592c3e173`; the final DEF SHA-256 is `a73b517145046b4eaa086bc7c9e0190135c8b8d2fc8be6becc9dc256c7d2794f`. The panel PNG SHA-256 is `e0cf94a454d082e6b00a1348fa7783b2ebac2600c6ba18a34f144f3a0a373f87`. This image is a summary panel, **not a waveform**. No B clock-gating VCD is present in the retained artifacts.

## Incomplete C floorplan

`config_c_floorplan.png` is a diagram rendered from the saved D-016 OpenDB floorplan checkpoint and processed failure measurements. It is not a GDS rendering and does not depict routed C. Its source checkpoint is `results/raw/phase1-config-c-final-recovery/work/results/sky130hd/config_c/base/2_1_floorplan.odb`, SHA-256 `8c60633042e62dbbc66951d9a3b43bdf873163e49662c930503b1e0b2b8fa58c`. The failed detailed-placement checkpoint is `.../3_5_place_dp-failed.odb`, SHA-256 `d3b636cc10ed4d37a29140970fb1d46b57ab7a9991df050678ffba11d44be5f2`.

The measurements and uncertainty are described in the [C root-cause audit](../results/processed/config-c-root-cause-audit.md). The C image SHA-256 is `795f8a485ba1bc15b75aab8ebd0ba8fc2ecc7c7ca6e9d6a8ce086b3287603c6c`. Raster image dimensions are 1440×1080 for A/B and 1800×1120 for the explanatory B/C panels. The B/C panel rasterization used the host `sips` utility (reported as `sips-316`); only the underlying verified artifact facts are presented.
