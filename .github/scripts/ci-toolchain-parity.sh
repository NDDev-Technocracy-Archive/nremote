#!/usr/bin/env bash
set -euo pipefail
for key in RUST_VERSION CARGO_EXPAND_VERSION FLUTTER_RUST_BRIDGE_VERSION; do
  build=$(grep -E "^  ${key}: " .github/workflows/build.yml | head -1)
  ui=$(grep -E "^  ${key}: " .github/workflows/ui.yml | head -1)
  if [ -z "${build}" ] || [ -z "${ui}" ]; then
    echo "${key} is missing from one of the two workflows" >&2
    exit 1
  fi
  if [ "${build}" != "${ui}" ]; then
    echo "${key} differs: build.yml has '${build}', ui.yml has '${ui}'" >&2
    exit 1
  fi
done
echo "build.yml and ui.yml agree on the pinned toolchain"
