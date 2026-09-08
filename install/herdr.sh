# Omarchy packages herdr and already wires up its `h` alias and hdl/herdr shell
# functions, but does not autostart it. This makes herdr the multiplexer that
# claims interactive shells, and strips the tmux and zellij autostart blocks
# earlier versions of this repo installed, so the three cannot nest.

have herdr || die "herdr not found — it ships with Omarchy; is this an Omarchy host?"

bashrc="$HOME/.bashrc"

block_remove "$bashrc" "TMUX AUTOSTART"
block_remove "$bashrc" "ZELLIJ AUTOSTART"

block_set "$bashrc" "HERDR AUTOSTART" <<'BLOCK'
# Attach to (or start) the persistent herdr session for interactive shells.
# HERDR_ENV is set inside herdr-managed panes; the TMUX guard keeps herdr from
# starting inside a tmux pane, since Omarchy still ships tmux.
if command -v herdr &> /dev/null && [ -z "$HERDR_ENV" ] && [ -z "$TMUX" ]; then
    herdr
fi
BLOCK
