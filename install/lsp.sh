# LSP servers and formatters into ~/lsp/bin.
#
# Every tool is individually selectable under "lsp" in preferences.json; the
# step runs when any of them is true. Names below are the preference keys.
#
# The Neovim config installs many of these again through mason-tool-installer,
# so ~/lsp/bin is mostly redundant with Mason unless you also use these servers
# from another editor. fnlfmt (which conform.lua invokes as a bare command),
# ols/odinfmt and zls are the ones Mason does not cover.

CLOJURE_LSP_VERSION='2026.02.20-16.08.58'
KOTLIN_LSP_VERSION='262.2310.0'
OLS_VERSION='dev-2026-03'
ZLS_VERSION='0.15.1'
CLJFMT_VERSION='0.16.3'
KTLINT_VERSION='1.8.0'

LSP="$HOME/lsp"

lsp_on()   { [[ "$(pref_member lsp "$1")" == "true" ]]; }
lsp_link() { link_bin "$1" "$2" "$LSP/bin"; }

# npm_server <pref-key> <subdir> <bin-name> <npm-pkg...>
npm_server() {
  local key="$1" subdir="$2" binname="$3"; shift 3
  lsp_on "$key" || { skip "$key disabled"; return 0; }
  have npm || die "npm not found — run the nodejs step first"
  local dir="$LSP/$subdir" target
  target="$dir/node_modules/.bin/$binname"
  if [[ -x $target ]]; then
    skip "$binname already installed"
  else
    info "installing $binname"
    mkdir -p "$dir"
    npm install --prefix "$dir" "$@"
  fi
  lsp_link "$target" "$binname"
}

# release_server <pref-key> <subdir> <relative-path-to-check> <url> [tar opts...]
release_server() {
  local key="$1" subdir="$2" check="$3" url="$4"; shift 4
  lsp_on "$key" || { skip "$key disabled"; return 1; }
  local dir="$LSP/$subdir"
  if [[ -e "$dir/$check" ]]; then
    skip "$subdir already installed"
  else
    info "installing $subdir"
    extract_to "$dir" "$url" "$@"
    chmod +x "$dir/$check" 2>/dev/null || true
  fi
}

# Nothing selected is a no-op rather than an empty ~/lsp/bin and a stray
# PATH entry. Reachable when the step is forced on the command line.
enabled_count="$(jq -r '[(.lsp // {}) | .[] | select(. == true)] | length' "$PREFS")"
if [[ $enabled_count == 0 ]]; then
  warn "no entries enabled under \"lsp\" in preferences.json — nothing to do"
  return 0
fi
info "$enabled_count of $(jq -r '(.lsp // {}) | length' "$PREFS") tools selected"

mkdir -p "$LSP/bin"

# --- npm-based servers and formatters -----------------------------------

npm_server typescript-language-server typescript-language-server typescript-language-server \
  typescript-language-server typescript
npm_server pyright                pyright                pyright-langserver          pyright
npm_server bash-language-server   bash-language-server   bash-language-server        bash-language-server
npm_server svelte-language-server svelte-language-server svelteserver                svelte-language-server
npm_server yaml-language-server   yaml-language-server   yaml-language-server        yaml-language-server
npm_server json-language-server   json-language-server   vscode-json-language-server vscode-langservers-extracted
npm_server prettier               prettier               prettier                    prettier prettier-plugin-svelte

# --- packaged on Arch ---------------------------------------------------
#
# Symlinked into ~/lsp/bin like the rest so the PATH contract is unchanged.

if lsp_on lua-language-server; then
  pkg lua-language-server
  lsp_link /usr/bin/lua-language-server lua-language-server
else
  skip "lua-language-server disabled"
fi

if lsp_on stylua; then
  pkg stylua
  lsp_link /usr/bin/stylua stylua
else
  skip "stylua disabled"
fi

# --- upstream release binaries ------------------------------------------

if release_server clojure-lsp clojure-lsp clojure-lsp \
  "https://github.com/clojure-lsp/clojure-lsp/releases/download/$CLOJURE_LSP_VERSION/clojure-lsp-native-linux-amd64.zip"; then
  lsp_link "$LSP/clojure-lsp/clojure-lsp" clojure-lsp
fi

if release_server kotlin-lsp kotlin-lsp kotlin-lsp.sh \
  "https://download-cdn.jetbrains.com/kotlin-lsp/$KOTLIN_LSP_VERSION/kotlin-lsp-$KOTLIN_LSP_VERSION-linux-x64.zip"; then
  lsp_link "$LSP/kotlin-lsp/kotlin-lsp.sh" kotlin-lsp
fi

if release_server ols ols ols-x86_64-unknown-linux-gnu \
  "https://github.com/DanielGavin/ols/releases/download/$OLS_VERSION/ols-x86_64-unknown-linux-gnu.zip"; then
  lsp_link "$LSP/ols/ols-x86_64-unknown-linux-gnu" ols
  lsp_link "$LSP/ols/odinfmt-x86_64-unknown-linux-gnu" odinfmt
fi

if release_server zls zls zls \
  "https://github.com/zigtools/zls/releases/download/$ZLS_VERSION/zls-x86_64-linux.tar.xz"; then
  lsp_link "$LSP/zls/zls" zls
fi

if release_server jdtls jdtls bin/jdtls \
  "https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz"; then
  lsp_link "$LSP/jdtls/bin/jdtls" jdtls
fi

if release_server cljfmt cljfmt cljfmt \
  "https://github.com/weavejester/cljfmt/releases/download/$CLJFMT_VERSION/cljfmt-$CLJFMT_VERSION-linux-amd64.tar.gz"; then
  lsp_link "$LSP/cljfmt/cljfmt" cljfmt
fi

if lsp_on ktlint; then
  if [[ -x $LSP/ktlint/ktlint ]]; then
    skip "ktlint already installed"
  else
    info "installing ktlint"
    mkdir -p "$LSP/ktlint"
    curl -fsSL -o "$LSP/ktlint/ktlint" \
      "https://github.com/pinterest/ktlint/releases/download/$KTLINT_VERSION/ktlint"
    chmod +x "$LSP/ktlint/ktlint"
  fi
  lsp_link "$LSP/ktlint/ktlint" ktlint
else
  skip "ktlint disabled"
fi

# --- built from source --------------------------------------------------

if lsp_on fnlfmt; then
  if [[ -x $LSP/fnlfmt/fnlfmt ]]; then
    skip "fnlfmt already installed"
  else
    info "building fnlfmt"
    rm -rf "$LSP/fnlfmt"
    git clone --depth 1 https://git.sr.ht/~technomancy/fnlfmt "$LSP/fnlfmt"
    make -C "$LSP/fnlfmt"
  fi
  lsp_link "$LSP/fnlfmt/fnlfmt" fnlfmt
else
  skip "fnlfmt disabled"
fi

# --- PATH ---------------------------------------------------------------

# Older versions of this repo appended this as a bare line; drop it before
# writing the managed block so the two cannot both be live.
line_remove "$HOME/.bashrc" '^export PATH=.*lsp/bin'

block_set "$HOME/.bashrc" "LSP SERVERS" <<'BLOCK'
export PATH="$HOME/lsp/bin:$PATH"
BLOCK

ok "$(find "$LSP/bin" -maxdepth 1 -type l 2>/dev/null | wc -l) tools linked in $LSP/bin"
