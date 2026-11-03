#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_tree="${1:-$HOME/Projects/from-rtl-to-pixels}"
raw_dir="${2:-$repo_root/results/raw/phase1-config-c/sim}"
expected_commit="ad35514c990f6e1c9eb9fa18aee9d906f9df7721"

actual_commit="$(git -C "$source_tree" rev-parse HEAD)"
[[ "$actual_commit" == "$expected_commit" ]] || { echo "source commit mismatch: $actual_commit" >&2; exit 2; }
[[ -z "$(git -C "$source_tree" status --porcelain=v1)" ]] || { echo "source checkout is not clean" >&2; exit 2; }
command -v verilator >/dev/null
command -v make >/dev/null
test -x "$source_tree/.venv/bin/cocotb-config"
mkdir -p "$raw_dir/pmu"
export PATH="$source_tree/.venv/bin:$PATH"

make -f "$repo_root/flow/phase1/config-c/Makefile.sim" \
  SOURCE_ROOT="$source_tree" COCOTB_TEST_MODULES=test_config_c_pmu \
  SIM_BUILD="$raw_dir/pmu/build" \
  COCOTB_RESULTS_FILE="$raw_dir/pmu/results.xml" \
  | tee "$raw_dir/pmu.log"
