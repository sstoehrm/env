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

# Sync lsp-bridge server configs
for dir in langserver multiserver; do
  if [[ -d "$DOOM_CONFIG_DIR/$dir" ]]; then
    mkdir -p "$DOOM_REPO_DIR/$dir"
    cp "$DOOM_CONFIG_DIR/$dir/"*.json "$DOOM_REPO_DIR/$dir/" 2>/dev/null && echo "Synced $dir/" || echo "No files in $dir/"
  fi
done
