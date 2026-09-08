# Mirrors `omarchy install dev-env clojure` (rlwrap + mise), plus babashka,
# which is packaged nowhere convenient and installs itself into ~/.local/bin.

pkg rlwrap
mise_use clojure latest

ensure_babashka
