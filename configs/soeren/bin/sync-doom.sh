#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOOM_REPO_DIR="$SCRIPT_DIR/../doom"
DOOM_CONFIG_DIR="$HOME/.config/doom"

files=(init.el config.el packages.el lsp.el)

for file in "${files[@]}"; do
  if [[ -f "$DOOM_CONFIG_DIR/$file" ]]; then
    cp "$DOOM_CONFIG_DIR/$file" "$DOOM_REPO_DIR/$file"
    echo "Synced $file"
  else
    echo "Skipping $file (not found in $DOOM_CONFIG_DIR)"
  fi
done
