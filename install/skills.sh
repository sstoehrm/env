# Claude Code plugins.
#
# Both entries are plugin marketplaces on GitHub, each shipping one plugin of
# the same name. `claude plugin marketplace add` clones the marketplace;
# `claude plugin install <plugin>@<marketplace>` enables it for the user scope.
#
# Selectable individually under "skills" in preferences.json.

have claude || die "claude not found — it is installed through mise on this machine (mise use --global claude)"

# marketplace -> plugin. Both repos happen to name the plugin after the
# marketplace; keep the pair explicit rather than assuming that holds.
declare -A SKILL_PLUGINS=(
  [blend]="sstoehrm/blend blend"
  [simpleviz]="sstoehrm/simpleviz simpleviz"
)

installed_marketplaces="$(claude plugin marketplace list --json 2>/dev/null | jq -r '.[].name' || true)"
# `claude plugin list --json` leaves .name null and carries the identity in
# .id as "<plugin>@<marketplace>", so match on that.
installed_plugins="$(claude plugin list --json 2>/dev/null | jq -r '.[].id // empty' || true)"

any=0
changed=0
for key in "${!SKILL_PLUGINS[@]}"; do
  if [[ "$(pref_member skills "$key")" != "true" ]]; then
    skip "$key disabled"
    continue
  fi
  any=1
  read -r repo plugin <<<"${SKILL_PLUGINS[$key]}"
  marketplace="${repo##*/}"

  if grep -qxF "$marketplace" <<<"$installed_marketplaces"; then
    skip "marketplace $marketplace already added"
  else
    info "adding marketplace $repo"
    claude plugin marketplace add "$repo"
    changed=1
  fi

  if grep -qxF "$plugin@$marketplace" <<<"$installed_plugins"; then
    skip "plugin $plugin@$marketplace already installed"
  else
    info "installing plugin $plugin@$marketplace"
    # --yes because a non-TTY run cannot answer the confirmation prompt.
    claude plugin install "$plugin@$marketplace" --scope user --yes
    changed=1
  fi
done

if ((any == 0)); then
  warn "no entries enabled under \"skills\" in preferences.json — nothing to do"
elif ((changed == 1)); then
  info "restart Claude Code for the new plugins to load"
fi
