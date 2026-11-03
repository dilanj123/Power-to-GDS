#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image="openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109"
raw_dir="${1:-$repo_root/results/raw/phase1-config-c/formal}"
mkdir -p "$raw_dir"

docker run --rm --platform linux/arm64 \
  -v "$repo_root:/ptg" \
  "$image" bash -lc '
    set -euo pipefail
    yosys=/OpenROAD-flow-scripts/tools/install/yosys/bin/yosys
    "$yosys" -V
    "$yosys" -Q -p "read_verilog -formal -sv /ptg/flow/phase1/config-c/config_c_pmu.sv /ptg/formal/phase1/config-c/config_c_pmu_formal.sv; prep -top config_c_pmu_formal -flatten; async2sync; opt; sat -seq 18 -set-init-zero -prove-asserts -verify -show power_state,rst,quiesce_req,functional_quiescent,wake_req,func_clk_en,func_rst,iso_en_n,power_off_intent"'
  2>&1 | tee "$raw_dir/safety.log"

# Generate a bounded sleep-to-wake trace with deterministic request placement.
docker run --rm --platform linux/arm64 \
  -v "$repo_root:/ptg" \
  "$image" bash -lc '
    set -euo pipefail
    yosys=/OpenROAD-flow-scripts/tools/install/yosys/bin/yosys
    "$yosys" -Q -p "read_verilog -formal -sv /ptg/flow/phase1/config-c/config_c_pmu.sv /ptg/formal/phase1/config-c/config_c_pmu_formal.sv; prep -top config_c_pmu_formal -flatten; async2sync; opt; sat -seq 22 -set-init-zero -set-at 1 rst 1 -set-at 2 rst 0 -set functional_quiescent 1 -set-at 6 quiesce_req 1 -set-at 10 wake_req 1 -set-at 22 power_state 0 -dump_vcd /ptg/results/raw/phase1-config-c/formal/sleep-wake-cover.vcd -show power_state,rst,quiesce_req,functional_quiescent,wake_req,func_clk_en,func_rst,iso_en_n,power_off_intent"'
  2>&1 | tee "$raw_dir/sleep-wake-cover.log"
