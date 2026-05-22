#!/usr/bin/env bash
# Recreates the wezterm.lua gui-startup / kitty startup.session layout in tmux.
# Idempotent: if the "env" session already exists, just attach.

set -euo pipefail

SESSION="env"
REPOS="$HOME/repos"
PRIVATE="$HOME/repos/private"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    exec tmux attach-session -t "$SESSION"
fi

# Tab 1 ("env") — 1 left, 2 stacked right
tmux new-session -d -s "$SESSION" -n "env" -c "$REPOS"
tmux split-window -h -t "${SESSION}:1" -c "$REPOS"
tmux split-window -v -t "${SESSION}:1" -c "$REPOS"
tmux select-pane -t "${SESSION}:1.1"

# Tab 2 ("dev 1") — 8 panes (approximated as a 4x2 tiled grid)
tmux new-window -t "${SESSION}:" -n "dev 1" -c "$PRIVATE"
for _ in 1 2 3 4 5 6 7; do
    tmux split-window -t "${SESSION}:2" -c "$PRIVATE"
    tmux select-layout -t "${SESSION}:2" tiled
done

# Tab 3 ("dev 2") — 1 left, 2 stacked right
tmux new-window -t "${SESSION}:" -n "dev 2" -c "$PRIVATE"
tmux split-window -h -t "${SESSION}:3" -c "$PRIVATE"
tmux split-window -v -t "${SESSION}:3" -c "$PRIVATE"
tmux select-pane -t "${SESSION}:3.1"

# Tab 4 ("stuff") — 2x2 grid
tmux new-window -t "${SESSION}:" -n "stuff"
for _ in 1 2 3; do
    tmux split-window -t "${SESSION}:4"
    tmux select-layout -t "${SESSION}:4" tiled
done

tmux select-window -t "${SESSION}:1"
exec tmux attach-session -t "$SESSION"
