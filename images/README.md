# Image provenance

All visuals use this repository’s saved implementation evidence. No image was copied from another project or fabricated as a tool screenshot.

## Routed GDS captures

`config_a_layout.png` and `config_b_layout.png` were rendered from the final routed GDS files using KLayout **0.30.12** (`/usr/local/klayout`) in the pinned ARM64 container `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109`, image digest `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`.

Both use the repository script [`scripts/klayout_gds_capture.py`](../scripts/klayout_gds_capture.py), SHA-256 `17eed9d5fe118f302d768042eef922ad551f55002259e35f1f7e0d6a9b48437a`, 1440×1080 output, SKY130HD layer properties, the same zoom-to-layout behavior, and the same visible drawing layers (met3, met4, met5). The dense-hatched prBoundary display layer is hidden for legibility. The captures are view images of the saved GDS, not new implementation results.

The committed images were independently regenerated on 2026-11-03 into `/tmp/ptg-image-audit/` from read-only mounts of the raw archive. Exact commands (run from the repository root):

```sh
docker run --rm -e QT_QPA_PLATFORM=offscreen \
  -e GDS_INPUT=/repo/results/raw/phase1-config-a/artifacts/6_final.gds \
  -e PNG_OUTPUT=/regen/a.png -e LYP_PATH=/tech/sky130hd.lyp \
  -v "$PWD:/repo:ro" -v /tmp/ptg-image-audit:/regen \
  -v "$HOME/.local/share/power-to-gds/OpenROAD-flow-scripts/flow/platforms/sky130hd/sky130hd.lyp:/tech/sky130hd.lyp:ro" \
  -v "$PWD/scripts/klayout_gds_capture.py:/tmp/klayout_gds_capture.py:ro" \
  openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109 \
  sh -lc '/usr/local/klayout -v; /usr/local/klayout -b -r /tmp/klayout_gds_capture.py'

docker run --rm -e QT_QPA_PLATFORM=offscreen \
  -e GDS_INPUT=/repo/results/raw/phase1-config-b/artifacts/checkpoints/6_final.gds \
  -e PNG_OUTPUT=/regen/b.png -e LYP_PATH=/tech/sky130hd.lyp \
  -v "$PWD:/repo:ro" -v /tmp/ptg-image-audit:/regen \
  -v "$HOME/.local/share/power-to-gds/OpenROAD-flow-scripts/flow/platforms/sky130hd/sky130hd.lyp:/tech/sky130hd.lyp:ro" \
  -v "$PWD/scripts/klayout_gds_capture.py:/tmp/klayout_gds_capture.py:ro" \
  openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109 \
  /usr/local/klayout -b -r /tmp/klayout_gds_capture.py
```

Both commands printed `KLayout 0.30.12` (queried in the first container) and the expected top cell (`config_a_top` / `config_b_top`). The regenerated A and B PNGs were each 1440×1080. Their SHA-256 values exactly matched the committed PNGs above; since the PNG byte streams match, pixel content, geometry rendering, layer visibility and viewport/crop match exactly. A pixel-library comparison was unnecessary. The images are nonblank routed-metal views.

| Image | Source artifact | Source SHA-256 |
|---|---|---|
| `config_a_layout.png` | `results/raw/phase1-config-a/artifacts/6_final.gds` | `f1b206d44b83de2751b649c701e8a2e4beb0609c37161b657017ea180121c9b6` |
| `config_b_layout.png` | `results/raw/phase1-config-b/artifacts/checkpoints/6_final.gds` | `988a6303047741c1d32862f537d2d118788943298fde9f4407a6cc84a71c0d3b` |

PNG SHA-256 values: A `5579dc17d0778600c2a849503e08efcb6e2bdfdaa5389576c5d6f7aec96a1be7`; B `0591ee822bf58913756192efacc193a81ac9a9ed13b7c0d3c9767d1390406b58`. The reproducible renderer script SHA-256 is recorded in the repository commit and can be checked with `shasum -a 256 scripts/klayout_gds_capture.py`.

## Clock-gating evidence panel

`config_b_clock_gating.png` combines the authentic B GDS capture above with documented design and simulation facts. The saved B final ODB is `results/raw/phase1-config-b/artifacts/checkpoints/6_final.odb`, SHA-256 `227cae9e01f4e803c57a57355d7959002748b0f2ad81fabe6cdf143d88c95f81`. The final DEF is `results/raw/phase1-config-b/artifacts/checkpoints/6_final.def`; it places `u_func_clk_gate.latch` as `sky130_fd_sc_hd__dlclkp_1` at (132.020, 141.440) µm. The directed test source is `results/raw/phase1-config-b/artifacts/config/test_config_b_clock_gate.py`; the saved log is `results/raw/phase1-config-b/artifacts/simulation/clock-gate.log`, SHA-256 `0615df21e046e5987b0a1e96c0de9238631b20d37b8769bbe3284436aadd14b4`.

The test evidence covers a mid-frame sleep request, draining 768 accepted pixels to 768 outputs, five parent-clock rising edges with gated clock held low, gated-edge alignment assertions, test-mode bypass/wake, a second 768-pixel frame, and APB count checks. The test source SHA-256 is `073ff10e44a3ce96177ce0b4d7942636b1a5e9c6a55f09207017197592c3e173`; the final DEF SHA-256 is `a73b517145046b4eaa086bc7c9e0190135c8b8d2fc8be6becc9dc256c7d2794f`. Its DEF instance line confirms `sky130_fd_sc_hd__dlclkp_1` at DBU coordinates `(132020,141440)`, or `(132.020,141.440) µm`, orientation `FS`; the net section connects `func_clk` to its `GCLK`. The panel PNG SHA-256 is `e0cf94a454d082e6b00a1348fa7783b2ebac2600c6ba18a34f144f3a0a373f87`. This is an engineering evidence panel, **not an actual simulation waveform**. No B clock-gating VCD is present in the retained artifacts.

## Incomplete C floorplan

`config_c_floorplan.png` is a diagram rendered from the saved D-016 OpenDB floorplan checkpoint and processed failure measurements. It is not a GDS rendering and does not depict routed C. Its source checkpoint is `results/raw/phase1-config-c-final-recovery/work/results/sky130hd/config_c/base/2_1_floorplan.odb`, SHA-256 `8c60633042e62dbbc66951d9a3b43bdf873163e49662c930503b1e0b2b8fa58c`. The failed detailed-placement checkpoint is `.../3_5_place_dp-failed.odb`, SHA-256 `d3b636cc10ed4d37a29140970fb1d46b57ab7a9991df050678ffba11d44be5f2`.

The floorplan query record shows the D-016 core `(1.380, 2.720)` to `(262.660, 261.120) µm`; `PD_SW` spans x=`1.380..230.920 µm` with 499 sites per row, and the AON row segment spans x=`247.480..262.660 µm` with 33 sites per row. Between them is the measured 36-site gap (`16.560 µm` after site-grid snapping), over 95 rows. The audited legal AON area is `3,862.4544 µm²`; post-repair movable area is `4,262.8384 µm²`, deficit `400.3840 µm²`. The D-016 floorplan ODB SHA-256 is `8c60633042e62dbbc66951d9a3b43bdf873163e49662c930503b1e0b2b8fa58c`; the failed detailed-placement ODB SHA-256 is `d3b636cc10ed4d37a29140970fb1d46b57ab7a9991df050678ffba11d44be5f2`. The exact saved row and region query logs are `d16_floorplan.log` (SHA-256 `203a6df10eb9d2308ef8a5f11cae4bdc4b1855562346732991ff377aa12e1541`), `regions-d16_2_1.log` (SHA-256 `62e07fe8f275ab0ddbf5fea0ed4835a6b95f74d0571803991aace1fc3d7014de`), and `d16_dp_failed.log` (SHA-256 `7b45cbec738c6226fcec156065d34246d6509d68b60b496ae31b97d42d1155bc`); the compiled diagnosis is the linked C root-cause audit.

The measurements and uncertainty are described in the [C root-cause audit](../results/processed/config-c-root-cause-audit.md). The C image SHA-256 is `795f8a485ba1bc15b75aab8ebd0ba8fc2ecc7c7ca6e9d6a8ce086b3287603c6c`. Raster image dimensions are 1440×1080 for A/B and 1800×1120 for the explanatory B/C panels. The B/C panel rasterization used the host `sips` utility (reported as `sips-316`); only the underlying verified artifact facts are presented. The composition source script was not retained, so its layout and data facts are independently checked against the cited source evidence, but the panel itself is not independently regenerated from a retained script.
