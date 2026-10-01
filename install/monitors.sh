# Deploy a monitor layout to ~/.config/hypr/monitors.lua.
#
# "monitor_layout" in preferences.json names a file under
# configs/soeren/hypr/monitors/ (without .lua), one per machine/desk setup.

layout="$(pref_str monitor_layout)"
[[ -n $layout ]] || die "set \"monitor_layout\" in preferences.json, e.g. \"main-setup\""

src="$CONFIGS_DIR/hypr/monitors/$layout.lua"
[[ -f $src ]] || die "no monitor layout '$layout' (expected $src)"

install_file "$src" "$HOME/.config/hypr/monitors.lua"

# Hyprland reloads on save; this only reports what it made of the file.
if have hyprctl && hyprctl monitors >/dev/null 2>&1; then
  hyprctl reload >/dev/null
  errors="$(hyprctl configerrors)"
  if [[ -n ${errors//[[:space:]]/} ]]; then
    warn "Hyprland reports config errors:"
    printf '%s\n' "$errors" >&2
  fi
fi
