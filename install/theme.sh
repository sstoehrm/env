# Omarchy theme and background.
#
# The Neovim colorscheme is not set here: it is pinned in the repo's
# nvim/lua/plugins/theme.lua and deployed by the configs step.

THEME_NAME="oxocarbon"
THEME_REPO="https://github.com/HANCORE-linux/omarchy-oxocarbon-theme"
THEME_BACKGROUND="BG44.jpg"

theme_dir="$HOME/.config/omarchy/themes/$THEME_NAME"
state_dir="$HOME/.local/state/omarchy/current"

# omarchy-theme-install deletes and re-clones unconditionally, then applies the
# theme, so only call it when the theme is missing or cloned from elsewhere.
if [[ -d $theme_dir/.git ]] &&
  [[ "$(git -C "$theme_dir" remote get-url origin 2>/dev/null)" == "$THEME_REPO" ]]; then
  skip "theme $THEME_NAME already installed"
else
  info "installing theme $THEME_NAME"
  omarchy-theme-install "$THEME_REPO"
fi

# theme.name holds the raw name; omarchy-theme-current prettifies it.
if [[ "$(cat "$state_dir/theme.name" 2>/dev/null)" == "$THEME_NAME" ]]; then
  skip "theme $THEME_NAME already active"
else
  omarchy-theme-set "$THEME_NAME"
  ok "theme set to $THEME_NAME"
fi

# omarchy-theme-set picks the next background in the theme's folder, so this
# has to run after it. The path points into the staged copy under
# ~/.local/state, which is what theme-set itself links to, so reruns compare
# equal.
background="$state_dir/theme/backgrounds/$THEME_BACKGROUND"
[[ -f $background ]] || die "background not found: $background"
if [[ "$(readlink -f "$state_dir/background")" == "$(readlink -f "$background")" ]]; then
  skip "background $THEME_BACKGROUND already set"
else
  omarchy-theme-bg-set "$background"
  ok "background set to $THEME_BACKGROUND"
fi
