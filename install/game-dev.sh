# Odin and Blockbench: both upstream releases, both into ~/.local, which
# Omarchy already has on PATH.

local_bin="$HOME/.local/bin"
mkdir -p "$local_bin"

# --- Odin ---------------------------------------------------------------

odin_dir="$HOME/.local/odin"
odin_tag="$(github_latest_tag odin-lang/Odin)"
odin_have="$("$odin_dir/odin" version 2>/dev/null || true)"

if [[ $odin_have == *"$odin_tag"* ]]; then
  skip "odin $odin_tag already installed"
else
  info "installing odin $odin_tag"
  rm -rf "$odin_dir"
  extract_to "$odin_dir" \
    "https://github.com/odin-lang/Odin/releases/download/$odin_tag/odin-linux-amd64-$odin_tag.tar.gz" \
    --strip-components=1
  ok "odin $odin_tag installed"
fi

link_bin "$odin_dir/odin" odin

# Older versions of this repo appended this as a bare line; drop it before
# writing the managed block so the two cannot both be live.
line_remove "$HOME/.bashrc" '^export ODIN_HOME='

block_set "$HOME/.bashrc" "ODIN" <<BLOCK
export ODIN_HOME="$odin_dir"
BLOCK

# --- Blockbench ---------------------------------------------------------

bb_appimage="$local_bin/blockbench.AppImage"
bb_stamp="$local_bin/.blockbench-version"
bb_tag="$(github_latest_tag JannisX11/blockbench)"

if [[ -f $bb_appimage && "$(cat "$bb_stamp" 2>/dev/null)" == "$bb_tag" ]]; then
  skip "blockbench $bb_tag already installed"
else
  info "installing blockbench $bb_tag"
  curl -fsSL -o "$bb_appimage" \
    "https://github.com/JannisX11/blockbench/releases/download/$bb_tag/Blockbench_${bb_tag#v}.AppImage"
  chmod +x "$bb_appimage"
  printf '%s' "$bb_tag" >"$bb_stamp"
  ok "blockbench $bb_tag installed"
fi

# AppArmor restricts unprivileged user namespaces on this kernel, so Electron's
# namespace sandbox is unavailable and it falls back to the bundled SUID
# chrome-sandbox, which isn't setuid root inside the /tmp-mounted AppImage and
# aborts. Launch with --no-sandbox via a wrapper so both the desktop entry and
# terminal `blockbench` start correctly.
cat >"$local_bin/blockbench" <<WRAPPER
#!/bin/sh
exec "$bb_appimage" --no-sandbox "\$@"
WRAPPER
chmod +x "$local_bin/blockbench"

apps_dir="$HOME/.local/share/applications"
mkdir -p "$apps_dir"
cat >"$apps_dir/blockbench.desktop" <<DESKTOP
[Desktop Entry]
Name=Blockbench
Comment=3D model editor for low-poly and boxy models
Exec=$local_bin/blockbench
Icon=blockbench
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;Development;
DESKTOP
ok "blockbench launcher and desktop entry written"
