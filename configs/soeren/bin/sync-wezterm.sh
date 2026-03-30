#!/usr/bin/env bash
# Sync current WezTerm config into the repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

src="$HOME/.wezterm.lua"
dest="$SCRIPT_DIR/wezterm.lua"

if [[ ! -f "$src" ]]; then
  echo "SKIP  $src (not found)"
  exit 1
fi

if cmp -s "$src" "$dest" 2>/dev/null; then
  echo "OK    wezterm.lua (unchanged)"
else
  cp "$src" "$dest"
  echo "SYNC  wezterm.lua"
fi
