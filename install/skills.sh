# Claude Code and Codex plugins.
#
# Both entries are plugin marketplaces on GitHub carrying manifests for both
# agents — .claude-plugin/marketplace.json and .agents/plugins/marketplace.json
# — each shipping one plugin of the same name. The two CLIs mirror each other:
#
#   claude plugin marketplace add <owner/repo>   codex plugin marketplace add <owner/repo>
#   claude plugin install <plugin>@<market>      codex plugin add <plugin>@<market>
#
# Every enabled entry is installed into whichever agents are present, so a
# machine with only one of them still works. Selectable individually under
# "skills" in preferences.json.

# marketplace key -> "<owner/repo> <plugin name>". Both repos happen to name the
# plugin after the marketplace; keep the pair explicit rather than assuming it.
declare -A SKILL_PLUGINS=(
  [blend]="sstoehrm/blend blend"
  [simpleviz]="sstoehrm/simpleviz simpleviz"
)

agents=()
have claude && agents+=(claude)
have codex && agents+=(codex)
((${#agents[@]})) || die "neither claude nor codex found — both are installed through mise on this machine"
info "agents: ${agents[*]}"

# Snapshot what each agent already has, once, so the loop makes no extra calls.
claude_marketplaces=""; claude_plugins=""
codex_marketplaces="";  codex_plugins=""
if have claude; then
  claude_marketplaces="$(claude plugin marketplace list --json 2>/dev/null | jq -r '.[].name // empty' || true)"
  # .name is null in this output; the identity lives in .id as "<plugin>@<marketplace>".
  claude_plugins="$(claude plugin list --json 2>/dev/null | jq -r '.[].id // empty' || true)"
fi
if have codex; then
  codex_marketplaces="$(codex plugin marketplace list --json 2>/dev/null | jq -r '.marketplaces[].name // empty' || true)"
  codex_plugins="$(codex plugin list --json 2>/dev/null | jq -r '.installed[] | select(.installed) | .pluginId' || true)"
fi

changed=0

# install_plugin <agent> <repo> <plugin> <marketplace>
install_plugin() {
  local agent="$1" repo="$2" plugin="$3" marketplace="$4"
  local markets plugins

  case "$agent" in
    claude) markets="$claude_marketplaces"; plugins="$claude_plugins" ;;
    codex)  markets="$codex_marketplaces";  plugins="$codex_plugins" ;;
  esac

  if grep -qxF "$marketplace" <<<"$markets"; then
    skip "$agent: marketplace $marketplace already added"
  else
    info "$agent: adding marketplace $repo"
    case "$agent" in
      claude) claude plugin marketplace add "$repo" ;;
      codex)  codex plugin marketplace add "$repo" ;;
    esac
    changed=1
  fi

  if grep -qxF "$plugin@$marketplace" <<<"$plugins"; then
    skip "$agent: plugin $plugin@$marketplace already installed"
  else
    info "$agent: installing plugin $plugin@$marketplace"
    case "$agent" in
      # --yes: a non-TTY run cannot answer the confirmation prompt.
      claude) claude plugin install "$plugin@$marketplace" --scope user --yes ;;
      codex)  codex plugin add "$plugin@$marketplace" ;;
    esac
    changed=1
  fi
}

any=0
for key in "${!SKILL_PLUGINS[@]}"; do
  if [[ "$(pref_member skills "$key")" != "true" ]]; then
    skip "$key disabled"
    continue
  fi
  any=1
  read -r repo plugin <<<"${SKILL_PLUGINS[$key]}"
  for agent in "${agents[@]}"; do
    install_plugin "$agent" "$repo" "$plugin" "${repo##*/}"
  done
done

if ((any == 0)); then
  warn "no entries enabled under \"skills\" in preferences.json — nothing to do"
elif ((changed == 1)); then
  info "restart ${agents[*]} for the new plugins to load"
fi
