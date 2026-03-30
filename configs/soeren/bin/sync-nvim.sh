#!/usr/bin/env bash
# Sync current Neovim config into the repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_NVIM="$SCRIPT_DIR/../nvim"

src="$HOME/.config/nvim"

if [[ ! -d "$src" ]]; then
  echo "SKIP  $src (not found)"
  exit 1
fi

rsync -a --delete \
  --exclude '.git/' \
  --exclude '.neoconf.json' \
  "$src/" "$REPO_NVIM/"

echo "SYNC  nvim/"
