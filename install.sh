#!/usr/bin/env bash
#
# Development environment setup for Omarchy.
#
# This installs only what Omarchy does not already ship; see README.md for what
# was dropped and why. Nothing here calls sudo directly — package installs go
# through omarchy-pkg-add.
#
#   ./install.sh                 run every step enabled in preferences.json
#   ./install.sh nodejs clojure  run just these steps, ignoring preferences
#   ./install.sh --list          show every step and whether it is enabled

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$REPO_DIR/install"
CONFIGS_DIR="$REPO_DIR/configs/soeren"
PREFS="$REPO_DIR/preferences.json"

source "$INSTALL_DIR/helpers.sh"

# step name -> preferences.json key that enables it.
# Order matters: toolchains come before the steps that use them (the LSP step
# needs mise's npm), and configs land before anything that reads them.
STEPS=(
  "git-config:configure_git"
  "jvm:install_jvm"
  "nodejs:install_nodejs"
  "rust:install_rust"
  "clojure:install_clojure"
  "neovim:install_neovim"
  "ast-grep:install_ast_grep"
  "herdr:install_herdr"
  "game-dev:install_game_dev"
  "gcolor3:install_gcolor3"
  "signal:install_signal"
  "configs:copy_soeren_configs"
  "lsp:copy_soeren_configs"
)

step_name() { printf '%s' "${1%%:*}"; }
step_key()  { printf '%s' "${1##*:}"; }

require_omarchy() {
  local id=""
  [[ -r /etc/os-release ]] && id="$(. /etc/os-release; printf '%s' "${ID:-}")"
  [[ $id == omarchy ]] || die "this repo targets Omarchy (/etc/os-release reports ID=${id:-unknown})"
}

require_prefs() {
  [[ -f $PREFS ]] || die "preferences.json not found. Copy it first:
    cp preferences.example.json preferences.json"
  have jq || die "jq not found — it ships with Omarchy; is this an Omarchy host?"
  jq -e . "$PREFS" >/dev/null 2>&1 || die "preferences.json is not valid JSON"
}

# pref <key> — read a boolean out of preferences.json; absent means off.
# Uses has() rather than //, because jq's // treats an explicit false as absent
# and would silently flip a disabled key back on.
pref() {
  jq -r --arg k "$1" 'if has($k) then (.[$k] | tostring) else "false" end' "$PREFS"
}

# pref_str <key> — read a string out of preferences.json.
pref_str() {
  jq -r --arg k "$1" '.[$k] // ""' "$PREFS"
}

enabled() { [[ "$(pref "$1")" == "true" ]]; }

list_steps() {
  local entry name key state
  printf '%-12s %-24s %s\n' STEP KEY ENABLED
  for entry in "${STEPS[@]}"; do
    name="$(step_name "$entry")"; key="$(step_key "$entry")"
    state="$(pref "$key")"
    printf '%-12s %-24s %s\n' "$name" "$key" "$state"
  done
}

run_step() {
  local name="$1" script="$INSTALL_DIR/$1.sh"
  [[ -f $script ]] || die "no such step: $name"
  step_header "$name"
  # Each step runs in a subshell so a stray cd or variable cannot leak forward.
  ( source "$script" )
}

main() {
  require_omarchy

  if [[ ${1:-} == --list ]]; then
    require_prefs; list_steps; return 0
  fi

  require_prefs

  if (($# > 0)); then
    # Explicit steps override preferences.
    local name
    for name in "$@"; do run_step "$name"; done
  else
    local entry name key seen=()
    for entry in "${STEPS[@]}"; do
      name="$(step_name "$entry")"; key="$(step_key "$entry")"
      if enabled "$key"; then
        run_step "$name"
        seen+=("$name")
      fi
    done
    if ((${#seen[@]} == 0)); then
      warn "nothing enabled in preferences.json"
    fi
  fi

  if [[ -n ${BACKUP_DIR:-} ]]; then
    log ""
    log "Backups of replaced files: $BACKUP_DIR"
  fi
  log ""
  log "${GREEN}Done.${RESET}"
}

main "$@"
