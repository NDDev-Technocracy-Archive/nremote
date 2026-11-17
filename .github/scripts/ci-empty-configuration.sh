#!/usr/bin/env bash
set -euo pipefail
configured=$(python3 scripts/configure.py --check)
printf '%s\n' "$configured"
if ! grep -qx 'RENDEZVOUS_SERVERS = &\[\]' <<< "$configured"; then
  echo "a rendezvous server is compiled into this repository" >&2
  exit 1
fi
if ! grep -qx 'RS_PUB_KEY         = (empty)' <<< "$configured"; then
  echo "a server public key is compiled into this repository" >&2
  exit 1
fi
