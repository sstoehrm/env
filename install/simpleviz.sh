# simpleviz — EDN-driven graph visualisation, the tool the simpleviz skill
# drives. Upstream installer puts the release in ~/.simpleviz and a launcher in
# ~/.local/bin/simpleviz, which Omarchy already has on PATH.
#
# It refuses to run without babashka >= 1.3.0, so make sure that is there first
# even when the clojure step is disabled.

ensure_babashka

installed="$(cat "$HOME/.simpleviz/VERSION" 2>/dev/null || true)"
latest="$(github_latest_tag sstoehrm/simpleviz)"

if [[ -n $installed && $installed == "$latest" ]]; then
  skip "simpleviz $installed already installed"
  return 0
fi

if [[ -n $installed ]]; then
  info "updating simpleviz $installed -> $latest"
else
  info "installing simpleviz $latest"
fi

# The upstream installer manages ~/.simpleviz wholesale (a reinstall rm -rf's
# it), so there is nothing of ours in there to back up.
tmp="$(mktemp -d)"
if curl -fsSL -o "$tmp/install.sh" https://raw.githubusercontent.com/sstoehrm/simpleviz/main/install.sh; then
  bash "$tmp/install.sh" || { rm -rf "$tmp"; die "simpleviz installer failed"; }
else
  rm -rf "$tmp"
  die "could not download the simpleviz installer"
fi
rm -rf "$tmp"

ok "simpleviz $(cat "$HOME/.simpleviz/VERSION" 2>/dev/null || echo "$latest") installed"
info "try: simpleviz ~/.simpleviz/examples/demo.edn"
