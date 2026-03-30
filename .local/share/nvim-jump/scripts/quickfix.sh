#!/usr/bin/env bash
set -euo pipefail

qf_file="${1:-/tmp/codex.qf}"
server="${NVIM_SERVER:-/tmp/nvimsocket}"

if [[ ! -f "$qf_file" ]]; then
  echo "quickfix file not found: $qf_file" >&2
  exit 1
fi

# Requires: nvr (neovim-remote)
nvr --servername "$server" -q "$qf_file"
