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

# --- text size ----------------------------------------------------------
#
# Enlarges text without scaling the rest of the desktop, through Omarchy's own
# knob: it sets the shell's base size, GTK's text-scaling-factor and the
# terminal font together, with 12px (the default) matching a 9pt terminal font.

text_size="$(pref_str display_text_size)"

# An earlier version of this step appended its own font-size to the Ghostty
# config. omarchy-display-text-size rewrites every font-size line there anyway,
# so the block would only duplicate it.
block_remove "$HOME/.config/ghostty/config" "ENV FONT SIZE"

if [[ -z $text_size ]]; then
  skip "display_text_size not set, leaving text size alone"
elif [[ "$(omarchy-display-text-size | awk '/^text size:/ {print $3}')" == "$text_size" ]]; then
  skip "text size already ${text_size}px"
else
  omarchy-display-text-size "$text_size"
  ok "text size set to ${text_size}px (shell, GTK and terminals)"
fi
