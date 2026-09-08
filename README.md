# env — Omarchy branch

Development environment setup for **Omarchy**, reduced to only what Omarchy
does not already ship and written in bash, in the same idiom Omarchy itself
uses (`install/*.sh` steps, `omarchy-pkg-add` for packages).

`main` is the Ansible version that targets Debian/Ubuntu and Fedora via
`apt`/`dnf`/`snap`/`flatpak`. None of that applies here, and once the
distro-abstraction layer was gone, Ansible was wrapping `pacman -S` in five
lines of YAML for no return. This branch drops it.

Verified against **Omarchy 4.0.2-1**.

## Usage

```bash
cp preferences.example.json preferences.json
$EDITOR preferences.json

./install.sh                 # run every step enabled in preferences.json
./install.sh nodejs clojure  # run just these steps, ignoring preferences
./install.sh --list          # show every step and whether it is enabled
```

No bootstrap step: bash, `jq`, `git` and `curl` all ship with Omarchy.

**Nothing here calls `sudo` directly.** Package installs go through
`omarchy-pkg-add`, so whatever sudo implementation Omarchy supports is the one
this inherits — which is also why a switch to `sudo-rs` is Omarchy's problem
rather than this repo's. Everything else writes under `$HOME`.

Replaced files are backed up under `~/.local/state/env-install/backup-<timestamp>/`,
and the path is printed at the end of a run that touched anything.

## Steps

| Step | Preference key | Installs | How |
| --- | --- | --- | --- |
| `git-config` | `configure_git` | global `user.name` / `user.email` | `git config` |
| `jvm` | `install_jvm` | Java temurin-25, Kotlin, Maven, Gradle · VisualVM | mise · pacman |
| `nodejs` | `install_nodejs` | Node 26 | mise |
| `rust` | `install_rust` | rustup + stable toolchain | pacman |
| `clojure` | `install_clojure` | rlwrap · Clojure CLI · babashka | pacman · mise · upstream installer |
| `neovim` | `install_neovim` | fish, tectonic · Nerd Fonts (FiraCode, Hack, JetBrainsMono, Meslo) · mermaid-cli | pacman · npm |
| `ast-grep` | `install_ast_grep` | ast-grep | pacman |
| `game-dev` | `install_game_dev` | Odin · Blockbench | upstream releases → `~/.local` |
| `gcolor3` | `install_gcolor3` | gcolor3 | pacman |
| `signal` | `install_signal` | signal-desktop | pacman |
| `simpleviz` | `install_simpleviz` | simpleviz (+ babashka) | upstream installer |
| `skills` | `skills` (group) | the Claude Code plugins you select | `claude plugin` |
| `configs` | `copy_soeren_configs` | herdr config · Neovim config | file copy |
| `lsp` | `lsp` (group) | the LSP servers and formatters you select, into `~/lsp/bin` | npm · pacman · upstream releases |

Steps run in the order listed. `nodejs` deliberately comes before `lsp`, which
needs mise's npm — the Ansible version had these the other way round, so on a
fresh machine its LSP step would have run before Node existed.

## Claude Code plugins

`"skills"` in `preferences.json` is a group, same shape as `"lsp"`: the step
runs when any member is true.

```json
"skills": {
  "blend": true,
  "simpleviz": true
}
```

Both entries are plugin marketplaces on GitHub, each shipping one plugin of the
same name. The step runs `claude plugin marketplace add <owner/repo>` and then
`claude plugin install <plugin>@<marketplace> --scope user --yes` — `--yes`
because a non-interactive run cannot answer the confirmation prompt. Restart
Claude Code afterwards; the step says so only when it actually installed
something.

To add another, extend `SKILL_PLUGINS` in `install/skills.sh` and add the key to
the group. The marketplace name is taken from the repo name, and the plugin name
is given separately rather than assumed to match.

`simpleviz` is also a real tool, installed by its own step from the upstream
release into `~/.simpleviz` with a launcher at `~/.local/bin/simpleviz`. It needs
babashka >= 1.3.0, so that step installs babashka itself rather than relying on
the `clojure` step being enabled.

## Selecting LSP servers

Every server and formatter is individually optional. `"lsp"` in
`preferences.json` is a group: the step runs when any member is true, and each
member gates its own install.

```json
"lsp": {
  "fnlfmt": true,
  "zls": true,
  "clojure-lsp": false
}
```

The default is everything off, because the Neovim config already installs most
of the same tools through `mason-tool-installer`. Turn one on here when you want
it on `PATH` or reachable from another editor. `fnlfmt` — which `conform.lua`
invokes as a bare command — plus `ols`/`odinfmt` and `zls` are the ones Mason
does not cover.

With nothing selected the step is a no-op: no `~/lsp/bin`, no `PATH` entry.

## Dropped — Omarchy already provides it

| On `main` | Provided by Omarchy as |
| --- | --- |
| base packages | `curl`, `git` |
| `nvm`, `sdkman` | `mise-bin`, activated in `/usr/share/omarchy/default/bash/init` |
| `neovim`, `lazyvim` | `omarchy-nvim` (Neovim + pre-built LazyVim with cached plugins) |
| `lazygit`, `fd`, `starship`, `chromium` | the same packages |
| `rocm` | not applicable — that playbook hard-fails off Ubuntu 24.04 |
| `kitty`, `ghostty`, `wezterm` | `omarchy install terminal <alacritty\|foot\|ghostty\|kitty>` |
| `tmux`, `zellij` | `herdr`, which Omarchy packages and gives an `h` alias |
| `vscode` (+ plugins) | `omarchy install editor vscode` |
| `opencode` | `opencode` in Omarchy's pacman repo |
| `doom-emacs` (+ deps) | `omarchy install editor emacs` |
| `speedcrunch` | `omacalc` |
| `docker`, `portainer` | see below |

Also dropped: the `configs/soeren/doom/doom-tool-deps.yml` import, which points
at a file that does not exist anywhere in the repo — on `main` it breaks any run
with both `copy_soeren_configs` and `install_doom_emacs` enabled.

`gcolor3` stayed: Omarchy covers the need with `hyprpicker`, but the binary is
genuinely not installed.

Configs for the removed tools (`configs/soeren/vscode/`, `wezterm.lua`,
`kitty/`, `ghostty/`, `tmux/`) are kept as reference; nothing deploys them.

### Why docker and portainer are gone

Omarchy deliberately does **not** add the user to the `docker` group. From
`/usr/share/omarchy/install/config/docker.sh`:

> The Docker daemon runs as root and its socket is root-owned, so membership in
> the docker group is equivalent to passwordless root: any process in it can
> `docker run -v /:/host` and rewrite the host as root.

It enables `docker.socket` and leaves `docker.service` disabled, routing the CLI
through a polkit or sudo prompt. The `main` playbook did `usermod -aG docker`
plus `systemctl enable --now docker`, silently reversing that. If you want
sudoless Docker, take Omarchy's opt-in, which warns first and records the reboot
that group membership needs:

```bash
omarchy-setup-security-sudoless-docker   # Setup > Security > Sudoless Docker
```

Portainer went with it: it assumed a user-reachable socket.

## The Neovim config

`omarchy-nvim` owns `~/.config/nvim`. The `configs` step copies this repo's
config **over** it rather than replacing the directory, so files omarchy-nvim
ships that our config does not name — `remote_clipboard.lua`, `all-themes.lua`,
`omarchy-theme-hotreload.lua` — stay in place and keep working.

Two conflicts needed handling:

**`theme.lua`.** Omarchy ships `~/.config/nvim/lua/plugins/theme.lua` as a
symlink to `~/.local/state/omarchy/current/theme/neovim.lua`, regenerated by
`omarchy-theme-set` on every theme switch, pinning `colorscheme = "aether"`.
lazy.nvim merges specs for the same plugin in filename order, so this repo's old
`colorscheme.lua` always lost and its `carbonfox` pin silently never applied.
The file is now named `theme.lua`, and the step deletes Omarchy's symlink before
copying so it lands as a real file.

Consequence: **`omarchy theme set` no longer retints Neovim.** And
`omarchy-nvim-refresh` / `omarchy-reinstall-configs` recreate the symlink with
`ln -snf`, so re-run `./install.sh configs` after either.

**`options.lua`.** Omarchy's version calls
`require("config.remote_clipboard").setup()`, which is what makes yank leave the
machine over SSH and inside herdr panes. This repo's `options.lua` replaces that
file, so the call was added here, wrapped in `pcall` so the config still loads on
a host without omarchy-nvim.

## Notes

- **Reruns are safe and are the way to apply changes.** Every step is
  idempotent: `pkg` skips installed packages, `install_file` compares content,
  the `.bashrc` blocks are replaced in place, and the download steps check for
  the binary first. `mise_use` compares against the version recorded in
  `~/.config/mise/config.toml`, so bumping a pin here (say Java 21 → 25) takes
  effect on the next run rather than being skipped as "already installed" —
  which also means a stale pin will move a toolchain *backwards*, so keep the
  versions in `install/jvm.sh` and `install/nodejs.sh` current.
- **Mason overlap.** The Neovim config installs most of `~/lsp/`'s servers again
  through `mason-tool-installer`. `fnlfmt` — which `conform.lua` invokes as a
  bare command — plus `ols`/`odinfmt` and `zls` are what only the `lsp` step
  provides.
- **First nvim launch.** `lazyvim.json` enables 21 extras against omarchy-nvim's
  one, so the first `nvim` after deploying does a large plugin install.
- **No multiplexer autostart.** Nothing here claims your interactive shells.
  herdr is packaged by Omarchy and starts with its `h` alias; the `configs` step
  deploys `~/.config/herdr/config.toml` for when you do. If you are migrating
  from `main`, it left a `# BEGIN TMUX AUTOSTART` block in your `.bashrc` — this
  branch does not touch it, so remove it by hand if you don't want it.
- **`.bashrc` blocks.** `ODIN_HOME` and the `~/lsp/bin` PATH entry live in
  `# BEGIN … / # END …` blocks — the same marker format Ansible's `blockinfile`
  used, so blocks left by the Ansible version are replaced rather than
  duplicated, and the bare `export` lines it appended are removed.
