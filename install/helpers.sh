# Shared helpers, sourced by install.sh before any step runs.
#
# Escalation policy: nothing in this repo calls sudo directly. Package installs
# go through omarchy-pkg-add, which is what the rest of the system uses, so
# whatever sudo implementation Omarchy supports is the one we inherit.
# Everything else writes under $HOME.

BOLD=$'\e[1m'; DIM=$'\e[2m'; RED=$'\e[31m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RESET=$'\e[0m'

log()  { printf '%s\n' "$*"; }
info() { printf '  %s\n' "$*"; }
skip() { printf '  %s%s%s\n' "$DIM" "$*" "$RESET"; }
ok()   { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$RED" "$RESET" "$*" >&2; exit 1; }

step_header() { printf '\n%s==>%s %s%s%s\n' "$GREEN" "$RESET" "$BOLD" "$*" "$RESET"; }

have() { command -v "$1" >/dev/null 2>&1; }

# --- packages -------------------------------------------------------------

# Install repo packages if missing. Delegates escalation to Omarchy.
pkg() {
  local missing=()
  local p
  for p in "$@"; do
    pacman -Q "$p" >/dev/null 2>&1 || missing+=("$p")
  done
  if ((${#missing[@]} == 0)); then
    skip "packages already installed: $*"
    return 0
  fi
  info "installing: ${missing[*]}"
  omarchy-pkg-add "${missing[@]}"
}

# --- mise -----------------------------------------------------------------

# mise_use <tool> <version-or-latest> — make <version> the global one.
#
# Compares against the spec recorded in ~/.config/mise/config.toml (column 4 of
# `mise ls`), which is exactly what `mise use --global` writes. Checking only
# whether the tool is installed at *some* version would silently ignore a
# version bump in this repo, which is the whole reason to pin one here.
mise_use() {
  local tool="$1" version="${2:-latest}"
  have mise || die "mise not found — it ships with Omarchy; is this an Omarchy host?"

  local row declared resolved
  row="$(mise ls --global --installed "$tool" 2>/dev/null | head -n1)"

  if [[ -n $row ]]; then
    declared="$(awk '{print $4}' <<<"$row")"
    resolved="$(awk '{print $2}' <<<"$row")"
    if [[ ${declared:-$resolved} == "$version" || $resolved == "$version"* ]]; then
      skip "mise: $tool@$version already global"
      return 0
    fi
    info "mise: $tool is pinned to ${declared:-$resolved}, switching to $version"
  fi

  info "mise: installing $tool@$version"
  mise use --global "$tool@$version"
}

# --- files ----------------------------------------------------------------

# One backup directory per run, created only if something is actually backed up.
backup_root() {
  if [[ -z ${BACKUP_DIR:-} ]]; then
    BACKUP_DIR="$HOME/.local/state/env-install/backup-$(date +%Y%m%d-%H%M%S)"
  fi
  mkdir -p "$BACKUP_DIR"
  printf '%s' "$BACKUP_DIR"
}

# backup <path> — snapshot a file or directory before we overwrite it.
backup() {
  local path="$1" dest
  [[ -e $path || -L $path ]] || return 0
  dest="$(backup_root)/$(basename "$path")"
  cp -a "$path" "$dest"
  info "backed up $path -> $dest"
}

# install_file <src> <dest> — copy if the content differs, backing up first.
install_file() {
  local src="$1" dest="$2"
  [[ -f $src ]] || { warn "missing source: $src"; return 0; }
  if [[ -f $dest ]] && cmp -s "$src" "$dest"; then
    skip "unchanged: $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  backup "$dest"
  cp "$src" "$dest"
  ok "wrote $dest"
}

# --- .bashrc blocks -------------------------------------------------------
#
# Same marker format the old Ansible blockinfile tasks used
# ("# BEGIN NAME" / "# END NAME"), so blocks written by previous runs of the
# Ansible version are found and replaced rather than duplicated.

block_remove() {
  local file="$1" marker="$2"
  [[ -f $file ]] || return 0
  grep -q "^# BEGIN ${marker}\$" "$file" || return 0
  sed -i "/^# BEGIN ${marker}\$/,/^# END ${marker}\$/d" "$file"
  ok "removed '${marker}' block from $(basename "$file")"
}

# block_set <file> <marker> — body on stdin.
block_set() {
  local file="$1" marker="$2" body existing
  body="$(cat)"
  touch "$file"
  existing="$(sed -n "/^# BEGIN ${marker}\$/,/^# END ${marker}\$/p" "$file")"
  if [[ $existing == "# BEGIN ${marker}"$'\n'"$body"$'\n'"# END ${marker}" ]]; then
    skip "'${marker}' block already current in $(basename "$file")"
    return 0
  fi
  [[ -n $existing ]] && sed -i "/^# BEGIN ${marker}\$/,/^# END ${marker}\$/d" "$file"
  printf '# BEGIN %s\n%s\n# END %s\n' "$marker" "$body" "$marker" >>"$file"
  ok "set '${marker}' block in $(basename "$file")"
}

# Drop bare lines an older version of this repo appended with Ansible's
# lineinfile, so they don't shadow the managed blocks that replace them.
# Lines inside a managed block are skipped: the block itself often contains
# the very export this is meant to clean up, and stripping it there would make
# every run rewrite the block.
line_remove() {
  local file="$1" regex="$2"
  [[ -f $file ]] || return 0
  awk -v re="$regex" '
    /^# BEGIN / { inblock = 1; print; next }
    /^# END /   { inblock = 0; print; next }
    inblock     { print; next }
    $0 ~ re     { removed++; next }
                { print }
    END { exit (removed > 0 ? 0 : 1) }
  ' "$file" >"$file.tmp" || { rm -f "$file.tmp"; return 0; }
  mv "$file.tmp" "$file"
  ok "removed legacy line matching /$regex/ from $(basename "$file")"
}

# --- downloads ------------------------------------------------------------

# github_latest_tag <owner/repo>
github_latest_tag() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" | jq -r '.tag_name'
}

# extract_to <dest-dir> <url> — handles .zip, .tar.gz, .tar.xz.
# Extra args after the url are passed to tar (e.g. --strip-components=1).
#
# Cleanup is explicit rather than a RETURN trap: such a trap is not local to
# the function that sets it, so it stays armed and fires again when the sourced
# step script finishes — by which point `local tmp` is gone and `set -u` kills
# the run, blaming the `source` line in install.sh.
extract_to() {
  local dest="$1" url="$2"; shift 2
  local tmp file rc=0
  tmp="$(mktemp -d)"
  file="$tmp/${url##*/}"
  mkdir -p "$dest"

  # The work runs inside a conditional so `set -e` cannot skip the cleanup.
  if curl -fsSL -o "$file" "$url"; then
    case "$file" in
      *.zip)          unzip -q -o "$file" -d "$dest" || rc=$? ;;
      *.tar.gz|*.tgz) tar -xzf "$file" -C "$dest" "$@" || rc=$? ;;
      *.tar.xz)       tar -xJf "$file" -C "$dest" "$@" || rc=$? ;;
      *) rc=1; warn "don't know how to extract ${file##*/}" ;;
    esac
  else
    rc=1
    warn "download failed: $url"
  fi

  rm -rf "$tmp"
  ((rc == 0)) || die "could not install from $url"
}

# link_bin <target> <name> — symlink into the given bin dir (default ~/.local/bin).
link_bin() {
  local target="$1" name="$2" bindir="${3:-$HOME/.local/bin}"
  mkdir -p "$bindir"
  ln -snf "$target" "$bindir/$name"
}

# --- babashka -------------------------------------------------------------

# Needed by the Clojure step and by simpleviz, which refuses to run without it.
# Packaged nowhere convenient on Arch; the upstream installer drops a single
# binary into ~/.local/bin, which Omarchy already has on PATH.
ensure_babashka() {
  if have bb; then
    skip "babashka $(bb --version | grep -oE '[0-9.]+' | head -n1) already installed"
    return 0
  fi
  info "installing babashka"
  mkdir -p "$HOME/.local/bin"
  local tmp
  tmp="$(mktemp -d)"
  if curl -fsSL -o "$tmp/install" https://raw.githubusercontent.com/babashka/babashka/master/install; then
    chmod +x "$tmp/install"
    "$tmp/install" --dir "$HOME/.local/bin" || { rm -rf "$tmp"; die "babashka install failed"; }
  else
    rm -rf "$tmp"
    die "could not download the babashka installer"
  fi
  rm -rf "$tmp"
  ok "babashka installed"
}
