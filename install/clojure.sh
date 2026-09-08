# Mirrors `omarchy install dev-env clojure` (rlwrap + mise), plus babashka,
# which is packaged nowhere convenient and installs itself into ~/.local/bin.

pkg rlwrap
mise_use clojure latest

if have bb; then
  skip "babashka already installed"
else
  info "installing babashka"
  mkdir -p "$HOME/.local/bin"
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/install" https://raw.githubusercontent.com/babashka/babashka/master/install
  chmod +x "$tmp/install"
  "$tmp/install" --dir "$HOME/.local/bin"
  rm -rf "$tmp"
  ok "babashka installed"
fi
