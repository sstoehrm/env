# Neovim itself and the LazyVim base come from Omarchy's omarchy-nvim package.
# base-devel, ripgrep, fzf, luarocks, imagemagick and wl-clipboard are already
# present, so this is only the extras the config expects.

pkg fish tectonic

# Omarchy ships ttf-jetbrains-mono-nerd-basic; the other families come from
# [extra] rather than GitHub zips.
pkg ttf-firacode-nerd ttf-hack-nerd ttf-jetbrains-mono-nerd ttf-meslo-nerd

if have mmdc; then
  skip "mermaid-cli already installed"
else
  have npm || die "npm not found — run the nodejs step first"
  info "installing mermaid-cli"
  npm install -g @mermaid-js/mermaid-cli
  ok "mermaid-cli installed"
fi

info "$(fc-list | grep -ci nerd) Nerd Fonts installed"
