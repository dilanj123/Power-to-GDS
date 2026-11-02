#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_tree="${1:-$HOME/Projects/from-rtl-to-pixels}"
raw_dir="${2:-$repo_root/results/raw/phase1-config-b/sim}"
expected_commit="ad35514c990f6e1c9eb9fa18aee9d906f9df7721"

actual_commit="$(git -C "$source_tree" rev-parse HEAD)"
[[ "$actual_commit" == "$expected_commit" ]] || {
  echo "source commit mismatch: $actual_commit" >&2
  exit 2
}
[[ -z "$(git -C "$source_tree" status --porcelain=v1)" ]] || {
  echo "source checkout is not clean" >&2
  exit 2
}

while read -r expected file; do
  [[ -n "$expected" ]] || continue
  actual="$(shasum -a 256 "$source_tree/rtl/$file" | awk '{print $1}')"
  [[ "$actual" == "$expected" ]] || {
    echo "source RTL hash mismatch: $file" >&2
    exit 2
  }
done < <(awk '{print $1, $2}' "$repo_root/rtl/imported/from-rtl-to-pixels-ad35514/SHA256SUMS")

command -v verilator >/dev/null
command -v make >/dev/null
test -x "$source_tree/.venv/bin/cocotb-config"
mkdir -p "$raw_dir/source-frame" "$raw_dir/source-streaming" "$raw_dir/clock-gate"
export PATH="$source_tree/.venv/bin:$PATH"

make -f "$repo_root/flow/phase1/config-b/Makefile.sim" \
  SOURCE_ROOT="$source_tree" COCOTB_TEST_MODULES=test_rtl_to_pixels_top \
  SIM_BUILD="$raw_dir/source-frame/build" \
  COCOTB_RESULTS_FILE="$raw_dir/source-frame/results.xml" \
  | tee "$raw_dir/source-frame.log"

make -f "$repo_root/flow/phase1/config-b/Makefile.sim" \
  SOURCE_ROOT="$source_tree" COCOTB_TEST_MODULES=test_rtl_to_pixels_top_streaming \
  SIM_BUILD="$raw_dir/source-streaming/build" \
  COCOTB_RESULTS_FILE="$raw_dir/source-streaming/results.xml" \
  | tee "$raw_dir/source-streaming.log"

make -f "$repo_root/flow/phase1/config-b/Makefile.sim" \
  SOURCE_ROOT="$source_tree" COCOTB_TEST_MODULES=test_config_b_clock_gate \
  SIM_BUILD="$raw_dir/clock-gate/build" \
  COCOTB_RESULTS_FILE="$raw_dir/clock-gate/results.xml" \
  | tee "$raw_dir/clock-gate.log"
