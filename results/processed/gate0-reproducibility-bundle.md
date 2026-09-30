# Gate-0 Reproducibility and Capability Bundle

Status: bounded capability evidence; not a full rerun of every historical
experiment.

## Runtime

- Host: Apple Silicon arm64/macOS 26.4.1
- Container: Linux/aarch64, Docker 29.8.0, 2 CPUs, ~7.75 GiB allocation
- Image digest: `sha256:fe2b24e96c6e4088b1ac6d68c83c5089dfdc61d90b00b43361ede064bb37174c`
- ORFS/OpenROAD/Yosys pins are recorded in
  `results/processed/runtime-platform-manifest.md`.

## Executed capability checks

| Capability | Executed input | Return code | Result |
|---|---|---:|---|
| OpenROAD/Yosys image smoke | pinned no-GUI image; OpenROAD self-version and Yosys identity | 0 | PASS, OpenROAD self-version is `unknown`, Yosys reports `0.68+post` with embedded SHA `UNKNOWN` |
| UPF isolation | pinned `tools/OpenROAD/src/upf/test/isolation.tcl` with exact SKY130HD inputs staged into disposable raw work | 0 | PASS; golden Verilog comparison reported `No differences found.` |
| DFT scan | pinned `tools/OpenROAD/src/dft/test/one_cell_sky130.tcl` with exact SKY130HD inputs staged into disposable raw work | 0 | PASS; one chain and golden Verilog/DEF comparisons reported `No differences found.` |
| Power reporting | pinned OpenROAD reopened preserved 10.30 ns final ODB/SDC/SPEF | 0 | PASS; vectorless report emitted, see power qualification |

Raw logs remain ignored under `results/raw/`, including the disposable staged
test inputs and generated outputs. The checks do not modify frozen ORFS or
OpenROAD sources.

## Boundary

This bundle proves the named capabilities execute in the pinned environment.
It does not prove timing closure, physical power gating, activity-based power
reduction, ATPG, fault coverage, or production sign-off.
