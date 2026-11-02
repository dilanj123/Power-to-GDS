#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_tree="${1:?usage: run_config_a_sim.sh /path/to/clean/source-checkout [raw-output-dir]}"
raw_dir="${2:-$repo_root/results/raw/phase1-config-a/sim}"
expected_commit="ad35514c990f6e1c9eb9fa18aee9d906f9df7721"
actual_commit="$(git -C "$source_tree" rev-parse HEAD)"
[[ "$actual_commit" == "$expected_commit" ]] || { echo "source commit mismatch: $actual_commit" >&2; exit 2; }

while read -r expected file; do
  [[ -n "$expected" ]] || continue
  actual="$(shasum -a 256 "$source_tree/rtl/$file" | awk '{print $1}')"
  [[ "$actual" == "$expected" ]] || { echo "source RTL hash mismatch: $file" >&2; exit 2; }
done < <(awk '{print $1, $2}' "$repo_root/rtl/imported/from-rtl-to-pixels-ad35514/SHA256SUMS")

command -v verilator >/dev/null
command -v cocotb-config >/dev/null
mkdir -p "$raw_dir/frame" "$raw_dir/streaming"
export IMG_WIDTH=32 IMG_HEIGHT=24
make -C "$source_tree" -f tb/tests/Makefile.rtl_to_pixels_top_pipelined \
  SIM_BUILD="$raw_dir/frame/build" COCOTB_RESULTS_FILE="$raw_dir/frame/results.xml"
make -C "$source_tree" -f tb/tests/Makefile.rtl_to_pixels_top_pipelined_streaming \
  SIM_BUILD="$raw_dir/streaming/build" COCOTB_RESULTS_FILE="$raw_dir/streaming/results.xml"
