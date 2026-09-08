# env — Omarchy branch

This branch is the `main` playbook set reduced to **only what Omarchy does not
already ship**, with every remaining install rewritten to Arch/Omarchy
mechanisms (pacman, `mise`, and Omarchy's own `omarchy-*` helpers). Nothing
here needs the AUR.

`main` targets Debian/Ubuntu and Fedora via `apt`/`dnf`/`snap`/`flatpak`. None
of that applies here. `main.yml` refuses to run if `/etc/os-release` does not
report `ID=omarchy`.

Verified against **Omarchy 4.0.2-1**.

## Usage

```bash
./install-ansible.sh                  # pacman -S ansible (bundles community.general)
cp preferences.example.json preferences.json
$EDITOR preferences.json
ansible-playbook main.yml --ask-become-pass
```

Tags still work: `ansible-playbook main.yml --ask-become-pass --tags configs`.
There is also a `mise` tag covering every language toolchain.

## What it installs

| Flag | Installs | How |
| --- | --- | --- |
| `install_signal` | signal-desktop | pacman |
| `copy_soeren_configs` | herdr config, the Neovim config, and the LSP servers/formatters in `~/lsp/bin` | file copy · upstream releases |
| `configure_git` | global `user.name` / `user.email` | git_config |
| `install_jvm` | Java temurin-21, Kotlin, Maven, Gradle · VisualVM | mise · pacman |
| `install_nodejs` | Node 24 | mise |
| `install_rust` | rustup + stable toolchain | pacman |
| `install_neovim` | fish, tectonic · mermaid-cli · Nerd Fonts (FiraCode, Hack, JetBrainsMono, Meslo) | pacman · npm · pacman |
| `install_docker` | docker group + daemon enabled · Portainer | systemd · `docker run` |
| `install_ast_grep` | ast-grep | pacman |
| `install_herdr` | herdr autostart in `.bashrc` (herdr itself is packaged by Omarchy) | blockinfile |
| `install_clojure` | rlwrap · babashka · Clojure CLI | pacman · upstream installer · mise |
| `install_game_dev` | Odin · Blockbench | GitHub releases → `~/.local` |
| `install_gcolor3` | gcolor3 | pacman |

## Dropped — Omarchy already provides it

| Removed from `main` | Provided by Omarchy as |
| --- | --- |
| `base/packages.yml` | `curl`, `git` |
| `development/nvm.yml`, `development/sdkman.yml` | `mise-bin`, activated in `/usr/share/omarchy/default/bash/init` |
| `development/neovim.yml`, `development/lazyvim.yml` | `omarchy-nvim` (Neovim + pre-built LazyVim with cached plugins) |
| `development/lazygit.yml` | `lazygit` |
| `development/fd.yml` | `fd` |
| `development/starship.yml` | `starship` + a themed `~/.config/starship.toml` |
| `development/rocm.yml` | not applicable — hard-fails off Ubuntu 24.04, and ROCm on Arch is an unrelated path |
| `applications/chromium.yml` | `chromium` |
| `development/kitty.yml`, `development/ghostty.yml`, `development/wezterm.yml` | `omarchy install terminal <alacritty\|foot\|ghostty\|kitty>` |
| `development/tmux.yml`, `development/zellij.yml` | `herdr`, which this branch autostarts instead |
| `development/vscode.yml` (+ plugins) | `omarchy install editor vscode` |
| `development/opencode.yml` | `opencode` in Omarchy's pacman repo |
| `development/doom-emacs.yml` (+ deps) | `omarchy install editor emacs` |
| `applications/speedcrunch.yml` | `omacalc` |

Also dropped: the `configs/soeren/doom/doom-tool-deps.yml` import. That file does
not exist anywhere in the repo, so on `main` it breaks any run with both
`copy_soeren_configs` and `install_doom_emacs` enabled.

`gcolor3` and `portainer` stayed: Omarchy covers the same needs with
`hyprpicker` and `lazydocker`, but those two binaries are genuinely not
installed.

The configs for the removed tools (`configs/soeren/vscode/`, `wezterm.lua`,
`kitty/`, `ghostty/`, `tmux/`) are kept in the repo as reference, but nothing
deploys them any more.

## Reduced — Omarchy provides part of it

| Playbook | What is left to do |
| --- | --- |
| `development/docker.yml` | `docker`, `docker-buildx`, `docker-compose` are installed but the daemon is disabled and the user is not in the `docker` group. Only that activation remains. |
| `development/herdr.yml` | herdr is packaged and its `h` alias and `hdl` functions are already in Omarchy's bash defaults; only the autostart block is added (and any tmux/zellij autostart removed). |
| `development/nerdfonts.yml` | `ttf-jetbrains-mono-nerd-basic` ships; the other families come from `[extra]` instead of GitHub zips. |
| `development/neovim-deps.yml` | `base-devel`, `ripgrep`, `fzf`, `luarocks`, `imagemagick` and `wl-clipboard` are present. Left: `fish`, `tectonic`, `mermaid-cli`. |
| `configs/soeren/lsp/install-lsp-servers.yml` | `lua-language-server` and `stylua` come from `[extra]` and are symlinked into `~/lsp/bin`, so that PATH contract is unchanged. The rest still installs from upstream releases. |

## The Neovim config

`omarchy-nvim` owns `~/.config/nvim`. `copy-config-soeren.yml` copies this
repo's config **over** it rather than replacing the directory, so files
omarchy-nvim ships that this config does not name — `remote_clipboard.lua`,
`all-themes.lua`, `omarchy-theme-hotreload.lua` — stay in place and keep
working.

Two things needed care:

**`theme.lua`.** Omarchy ships `~/.config/nvim/lua/plugins/theme.lua` as a
symlink to `~/.local/state/omarchy/current/theme/neovim.lua`, regenerated by
`omarchy-theme-set` on every theme switch, pinning `colorscheme = "aether"`.
lazy.nvim merges specs for the same plugin in filename order, so this repo's
old `colorscheme.lua` would always have lost to `theme.lua` and its `carbonfox`
pin would have silently never applied. The file is therefore named `theme.lua`,
and the playbook deletes Omarchy's symlink before copying so it lands as a real
file. Omarchy keeps writing `neovim.lua` under `~/.local/state`; nothing reads
it any more.

Consequence: **`omarchy theme set` no longer retints Neovim.** Also,
`omarchy-nvim-refresh` and `omarchy-reinstall-configs` recreate the symlink with
`ln -snf`, so re-run `--tags configs` after either of those.

**`options.lua`.** Omarchy's version calls
`require("config.remote_clipboard").setup()`, which is what makes yank leave the
machine over SSH and inside herdr panes. This repo's `options.lua` replaces that
file, so the call was added here (wrapped in `pcall`, so the config still loads
on a host without omarchy-nvim).

## Gotchas

- **Mason overlap.** The Neovim config installs most of `~/lsp/`'s servers again
  through `mason-tool-installer` (bash-language-server, clojure-lsp, jdtls,
  kotlin-lsp, lua-language-server, prettier, stylua, svelte-language-server,
  ktlint). `install-lsp-servers.yml` is still worth running for `fnlfmt` — which
  `conform.lua` invokes as a bare command — plus `ols`/`odinfmt` and `zls`.
- **Docker group.** Log out and back in (or `newgrp docker`) after the first run.
- **First nvim launch.** `lazyvim.json` enables 21 extras against omarchy-nvim's
  one, so the first `nvim` after deploying does a large plugin install.
