# SSH key for this machine, registered with GitHub.
#
# An existing key is never replaced. ssh-keygen runs interactively so it can ask
# for a passphrase; leave it empty for none.

key="$HOME/.ssh/id_ed25519"

if [[ -f $key ]]; then
  skip "ssh key already present: $key"
else
  email="$(pref_str git_user_email)"
  [[ -n $email && $email != "your.email@example.com" ]] || email="$USER@$(hostname)"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  info "generating $key (ssh-keygen will ask for a passphrase)"
  ssh-keygen -t ed25519 -C "$email" -f "$key"
  ok "ssh key created: $key"
fi

# Upload to GitHub through gh, which needs the admin:public_key scope.
# gh ssh-key list prints the key as its second column, so compare type + key and
# ignore the comment.
if ! have gh || ! gh auth status >/dev/null 2>&1; then
  skip "gh is not logged in, not adding the key to GitHub (run: gh auth login)"
  info "public key: $(cat "$key.pub")"
else
  pub="$(awk '{print $1" "$2}' "$key.pub")"
  if gh ssh-key list 2>/dev/null | grep -qF "$pub"; then
    skip "ssh key already on GitHub"
  elif gh ssh-key add "$key.pub" --title "$(hostname)"; then
    ok "ssh key added to GitHub as '$(hostname)'"
  else
    warn "could not add the key to GitHub; gh may lack the admin:public_key scope:"
    warn "  gh auth refresh -s admin:public_key"
  fi
fi
