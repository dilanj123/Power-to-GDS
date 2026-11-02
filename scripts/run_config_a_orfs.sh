#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image="openroad/flow-ubuntu22.04-builder-nogui:26Q3-2276-g4a7cf9b22a-35f109"
work_rel="${PTG_WORK_HOME_REL:-results/raw/phase1-config-a/work}"
flow_log="${PTG_FLOW_LOG:-$repo_root/results/raw/phase1-config-a/orfs-flow.log}"
[[ "$work_rel" != /* && "$work_rel" != *..* ]] || {
  echo "PTG_WORK_HOME_REL must be a relative path inside the repository" >&2
  exit 2
}
mkdir -p "$repo_root/$work_rel" "$(dirname "$flow_log")"

# ORFS and all EDA executables are supplied by the pinned Linux/arm64 image.
# The repo is mounted at /ptg; the image's frozen ORFS checkout is used in place.
docker run --rm --platform linux/arm64 \
  -v "$repo_root:/ptg" \
  -w /OpenROAD-flow-scripts/flow \
  "$image" \
  bash -lc 'make DESIGN_CONFIG=/ptg/flow/phase1/config-a/config.mk WORK_HOME=/ptg/'"$work_rel"' KLAYOUT_CMD=/usr/local/klayout all' \
  2>&1 | tee "$flow_log"
