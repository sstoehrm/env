# OpenSSH key agent, so a key's passphrase is asked once per login.
#
# Uses the ssh-agent.socket unit openssh ships, not gnome-keyring's
# gcr-ssh-agent: that one remembers passphrases by saving them in the default
# keyring, and Omarchy creates that keyring unencrypted, so the passphrase
# would sit on disk in plain text.

# --- agent ----------------------------------------------------------------

if systemctl --user is-enabled --quiet ssh-agent.socket &&
  systemctl --user is-active --quiet ssh-agent.socket; then
  skip "ssh-agent.socket already enabled"
else
  systemctl --user enable --now ssh-agent.socket
  ok "ssh-agent.socket enabled"
fi

# --- SSH_AUTH_SOCK --------------------------------------------------------
#
# environment.d feeds the systemd user manager, which the uwsm-run Hyprland
# and everything it launches inherit — GUI apps included, which a .bashrc
# export would miss. A .bashrc export would also clobber the agent sshd
# forwards into an incoming SSH session.

sock="$XDG_RUNTIME_DIR/ssh-agent.socket"
install_file "$CONFIGS_DIR/environment.d/ssh-agent.conf" "$HOME/.config/environment.d/ssh-agent.conf"

# daemon-reload reruns the environment generators, so terminals opened from
# now on get the variable without logging out.
if [[ "$(systemctl --user show-environment)" != *"SSH_AUTH_SOCK=$sock"* ]]; then
  systemctl --user daemon-reload
  if [[ "$(systemctl --user show-environment)" != *"SSH_AUTH_SOCK=$sock"* ]]; then
    systemctl --user set-environment "SSH_AUTH_SOCK=$sock"
  fi
  ok "SSH_AUTH_SOCK set for new processes"
  info "already-open terminals: export SSH_AUTH_SOCK=$sock (or open a new one)"
fi

# --- ~/.ssh/config --------------------------------------------------------
#
# ssh_config takes the first value it finds, so a Host * block at the end
# never overrides anything written above it.

mkdir -p -m 700 "$HOME/.ssh"
block_set "$HOME/.ssh/config" "SSH AGENT" <<'BLOCK'
Host *
  AddKeysToAgent yes
BLOCK
chmod 600 "$HOME/.ssh/config"
