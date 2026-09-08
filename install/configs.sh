# Deploy the configs this branch still installs.
#
# Configs for tools Omarchy installs on request (VS Code, kitty, ghostty,
# WezTerm, tmux) are kept in configs/soeren/ as reference but not deployed.

# --- herdr --------------------------------------------------------------

install_file "$CONFIGS_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# --- Neovim -------------------------------------------------------------
#
# omarchy-nvim owns ~/.config/nvim. This copies over it rather than replacing
# it, so files omarchy-nvim ships that our config does not name
# (remote_clipboard.lua, all-themes.lua, omarchy-theme-hotreload.lua) stay in
# place and keep working.

nvim_dir="$HOME/.config/nvim"
theme_link="$nvim_dir/lua/plugins/theme.lua"

# Omarchy ships that path as a symlink to
# ~/.local/state/omarchy/current/theme/neovim.lua, which omarchy-theme-set
# rewrites on every theme switch and which pins colorscheme = "aether".
# lazy.nvim merges specs for the same plugin in filename order, so our
# theme.lua only wins once the link is gone and it lands as a real file.
if [[ -L $theme_link ]]; then
  backup "$theme_link"
  rm "$theme_link"
  ok "removed Omarchy's generated theme.lua symlink"
fi

# Every file the repo ships must be present and identical. Files that exist
# only in the destination belong to omarchy-nvim and are deliberately ignored.
nvim_in_sync() {
  local rel
  while IFS= read -r -d '' rel; do
    cmp -s "$CONFIGS_DIR/nvim/$rel" "$nvim_dir/$rel" || return 1
  done < <(cd "$CONFIGS_DIR/nvim" && find . -type f -print0)
  return 0
}

if [[ -d $nvim_dir ]] && nvim_in_sync; then
  skip "neovim config unchanged"
else
  backup "$nvim_dir"
  mkdir -p "$nvim_dir"
  cp -R "$CONFIGS_DIR/nvim/." "$nvim_dir/"
  ok "neovim config deployed over omarchy-nvim"
  info "theme.lua is now a real file, so 'omarchy theme set' no longer retints Neovim"
  info "run nvim once to let lazy.nvim install the extras in lazyvim.json"
fi
