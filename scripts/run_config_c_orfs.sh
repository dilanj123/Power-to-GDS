#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image="openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109"
work_rel="${PTG_WORK_HOME_REL:-results/raw/phase1-config-c/work}"
flow_log="${PTG_FLOW_LOG:-$repo_root/results/raw/phase1-config-c/orfs-flow.log}"
target="${1:-all}"
[[ "$work_rel" != /* && "$work_rel" != *..* ]] || { echo "PTG_WORK_HOME_REL must be a relative path inside the repository" >&2; exit 2; }
mkdir -p "$repo_root/$work_rel" "$(dirname "$flow_log")"

docker run --rm --platform linux/arm64 \
  -v "$repo_root:/ptg" \
  -w /OpenROAD-flow-scripts/flow \
  "$image" \
  bash -lc 'make DESIGN_CONFIG=/ptg/flow/phase1/config-c/config.mk WORK_HOME=/ptg/'"$work_rel"' KLAYOUT_CMD=/usr/local/klayout '"$target" \
  2>&1 | tee "$flow_log"
