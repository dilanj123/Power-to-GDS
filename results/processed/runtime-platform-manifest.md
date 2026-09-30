# Runtime and Platform Manifest

Status: execution freeze for Prompt A; this manifest records observed inputs,
not a claim that every later experiment has passed.

## Host and container

| Item | Observed value |
|---|---|
| Host OS | macOS 26.4.1, build 25E253 |
| Host kernel/architecture | Darwin 25.4.0, arm64 |
| Host logical CPUs | 12 |
| Host physical memory | 17,179,869,184 bytes (16 GiB) |
| Docker client/server | 29.8.0 / 29.8.0 |
| Docker server | Linux, aarch64 |
| Container allocation | 2 CPUs; 8,320,565,248 bytes reported by Docker |
| Container execution mode | native Linux/arm64 Docker on Apple Silicon |

## Image and tools

| Item | Value |
|---|---|
| Image tag | `openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109` |
| Image digest | `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c` |
| ORFS source SHA | `3a964e13f11a4e435aac01ffa14db0a7d2853720` |
| OpenROAD source SHA | `4a7cf9b22a5f24f32ce4f4eb1448fef4d2a367ca` |
| Yosys source SHA | `a5af9d690a43744bf6b2cc3dea2717c16b54621c` |
| OpenROAD executable | `/OpenROAD-flow-scripts/tools/install/OpenROAD/bin/openroad` |
| Yosys executable | `/OpenROAD-flow-scripts/tools/install/yosys/bin/yosys` |
| KLayout | Not present in the pinned image (`command -v klayout` and `klayout -v` unavailable); no host substitution was used |
| OpenROAD self-identification | `unknown` in this image; source SHA above is authoritative |
| Yosys self-identification | `Yosys 0.68+post`, embedded git SHA reported as `UNKNOWN`; source SHA above is authoritative |

The source revisions and immutable image digest are the primary tool identity.
Self-identification limitations are intentional and must not be silently
filled with host-installed tools.

## Platform

Platform: ORFS `sky130hd`, standard-cell library `sky130_fd_sc_hd`, nominal
timing library `sky130_fd_sc_hd__tt_025C_1v80.lib`. The canonical source
checkout is the frozen ORFS tree at the ORFS SHA above.

### SHA-256 of canonical inputs

| Input | SHA-256 |
|---|---|
| `flow/platforms/sky130hd/config.mk` | `1a36b8fbd58ee4b6b961bc14f3ca44e7b44a4ea47faf6f116f827eb5177509d5` |
| `flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib` | `ec0e1067a35c8bf20b11e58d1e8ac53326067e4dac84a125cc1b917a3518d0d9` |
| `flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef` | `8e99b4e8b016db0713029ebcae6b2cc2aedd9c2c49682e2f23521dd0b1a2085e` |
| `flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef` | `44180aaa0068b1fcb0789f128b090304c01ad48f511d3f7afa66c90b3e176ec5` |
| `flow/platforms/sky130hd/cdl/sky130hd.cdl` | `7fe13f045cdab9574e977a7c7cb02c3a4fb3f1db39cbd6ff11047fc8e0542107` |
| `flow/platforms/sky130hd/drc/sky130hd.lydrc` | `029722ea1fc2cf8c48f09fc670c0b72efb295f799c4eb236b7e9767930ecf772` |
| `flow/platforms/sky130hd/lvs/sky130hd.lylvs` | `d2d231d7cd00a8261d6653c5f3757badefb1dc0aba29441d8406272e75cd8b90` |
| `flow/platforms/sky130hd/setRC.tcl` | `6aeade350bf498177ea61506db8849a064a71848b05c18ad6a6e1fc5d62c962a` |

### SHA-256 of flow-defining scripts

| Input | SHA-256 |
|---|---|
| `flow/scripts/flow.tcl` | `f7e3d557024b46478e0ec47a26b57ae2dabded7236cc0a18dfd3715258676e68` |
| `flow/scripts/synth.tcl` | `06461ef1c3dc77bbf62a623f5347ee2cfc42d65a79600eb90cc1bda4652461f5` |
| `flow/scripts/synth_odb.tcl` | `13caa49b68d08d89aaf3ca1eac812365d07f50015b59d3f3d2d1de1aa3caa347` |
| `flow/scripts/io_placement.tcl` | `95c9b5a0901c52a586407b7601c6dd6d4f3f14c0057e99a16da140d3f165517e` |
| `flow/scripts/global_place.tcl` | `05a7a124580f8a023113ad1f4d56c15e61c3640142f4581c27d5ebaa6aa59e33` |
| `flow/scripts/cts.tcl` | `b94284bdc896e52af1747ca4924677f4d774f00cd6ff7003dea83bb2adc49ca6` |
| `flow/scripts/global_route.tcl` | `aeeb5c3aa3bdef64ba569cb650fd119c3389d0f0bf7478a7e440dca3f6b50447` |
| `flow/scripts/report_metrics.tcl` | `b314571634205e7f739126bc9e6923f7f65ea510307ed2b92ee4e4a7d890f329` |

This manifest hashes the physical platform inputs rather than generated ODB,
GDS, or SPEF outputs. A future run must compare these hashes before treating
results as like-for-like.
