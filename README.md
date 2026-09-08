# env — Omarchy branch

This branch is the `main` playbook set reduced to **only what Omarchy does not
already ship**, with every remaining install rewritten to Arch/Omarchy
mechanisms (pacman, the AUR via `yay`, `mise`, and Omarchy's own `omarchy-*`
helpers).

`main` targets Debian/Ubuntu and Fedora via `apt`/`dnf`/`snap`/`flatpak`. None
of that applies here. `main.yml` on this branch refuses to run if
`/etc/os-release` does not report `ID=omarchy`.

Verified against **Omarchy 4.0.2-1**.

## Usage

```bash
./install-ansible.sh                  # pacman -S ansible (bundles community.general)
cp preferences.example.json preferences.json
$EDITOR preferences.json

sudo -v                               # see "AUR steps and sudo" below
ansible-playbook main.yml --ask-become-pass
```

Tags still work: `ansible-playbook main.yml --ask-become-pass --tags ghostty`.
There is also a `mise` tag covering every language toolchain.

### AUR steps and sudo

Two steps install from the AUR (`visual-studio-code-bin` and `ttf-symbola`) via
`omarchy-pkg-aur-add`. `yay` refuses to run as root and escalates on its own, so
Ansible's `become` cannot drive it. Run `sudo -v` immediately before the
playbook so those steps land inside a live sudo timestamp. Everything else uses
the `community.general.pacman` module and is handled by `--ask-become-pass`.

## Dropped — Omarchy already provides it

| Removed from `main` | Provided by Omarchy as |
| --- | --- |
| `playbooks/base/packages.yml` | `curl`, `git` |
| `playbooks/development/nvm.yml` | `mise-bin`, activated in `/usr/share/omarchy/default/bash/init` |
| `playbooks/development/sdkman.yml` | same — `mise` is the one version manager |
| `playbooks/development/neovim.yml` | `omarchy-nvim` |
| `playbooks/development/lazyvim.yml` | `omarchy-nvim` (pre-built LazyVim with cached plugins) |
| `playbooks/development/lazygit.yml` | `lazygit` |
| `playbooks/development/fd.yml` | `fd` |
| `playbooks/development/starship.yml` | `starship` + a themed `~/.config/starship.toml` |
| `playbooks/development/herdr.yml` | `herdr` package, plus the `h` alias and `hdl`/herdr functions in Omarchy's bash defaults |
| `playbooks/applications/chromium.yml` | `chromium` |
| `playbooks/development/rocm.yml` | not applicable — that playbook hard-fails off Ubuntu 24.04, and ROCm on Arch is an unrelated path |

Also dropped: the `configs/soeren/doom/doom-tool-deps.yml` import. That file does
not exist anywhere in the repo, so on `main` it breaks any run with both
`copy_soeren_configs` and `install_doom_emacs` enabled.

Per the "only drop exact matches" rule, things Omarchy merely *covers* were
kept: `speedcrunch` (Omarchy has `omacalc`), `gcolor3` (`hyprpicker`),
`portainer` (`lazydocker`), and kitty/wezterm/ghostty (`foot`). Those binaries
genuinely are not on the system.

## Reduced — Omarchy provides part of it

| Playbook | What is left to do |
| --- | --- |
| `development/docker.yml` | `docker`, `docker-buildx`, `docker-compose` are installed but the daemon is disabled and the user is not in the `docker` group. Only that activation remains. |
| `development/tmux.yml` | `tmux` is installed; only `tpm` is missing. **No `.bashrc` autostart** — herdr is Omarchy's multiplexer and both claiming the shell would nest them. |
| `development/nerdfonts.yml` | `ttf-jetbrains-mono-nerd-basic` ships; FiraCode/Hack/JetBrainsMono/Meslo come from `[extra]` instead of GitHub zips. |
| `development/neovim-deps.yml` | `base-devel`, `ripgrep`, `fzf`, `luarocks`, `imagemagick` and `wl-clipboard` are present. Left: `fish`, `tectonic`, `mermaid-cli`, the WezTerm terminfo entry. |
| `configs/soeren/lsp/install-lsp-servers.yml` | `lua-language-server` and `stylua` now come from `[extra]` and are symlinked into `~/lsp/bin`, so the `~/lsp/bin` PATH contract is unchanged. The rest still installs from upstream releases. |

## Rewritten for Arch/Omarchy

- **pacman (`community.general.pacman`)** — signal-desktop, ghostty, kitty,
  wezterm, zellij, ast-grep, rlwrap, gcolor3, speedcrunch, visualvm, rustup,
  emacs, fish, tectonic, the Nerd Font families, `ttf-nerd-fonts-symbols-mono`.
- **Omarchy's own repo** — `opencode` is packaged there, so it upgrades with the
  system instead of via the upstream curl installer.
- **AUR (`omarchy-pkg-aur-add`)** — `visual-studio-code-bin` (the Marketplace
  extensions this repo installs are only served to the Microsoft-branded build,
  not the OSS `code` package) and `ttf-symbola`.
- **mise** — java, kotlin, maven, gradle, node and clojure, matching what
  `omarchy install dev-env <lang>` does.
- **`omarchy-install-terminal`** — ghostty and kitty are installed by pacman
  first, so the helper skips its own sudo call and only registers the desktop
  entry and `~/.config/xdg-terminals.list`. It seeds `~/.config/<terminal>` only
  when that directory is missing, and `copy-config-soeren.yml` runs earlier, so
  the configs in `configs/soeren/` stay authoritative.

Unchanged because they were already distro-agnostic and install under
`~/.local` (which Omarchy has on `PATH`): babashka, odin, blockbench,
portainer, git-config, the VS Code extension list, and the remaining LSP
servers and formatters.

## Gotchas

- **Terminal default.** `omarchy-install-terminal` rewrites
  `~/.config/xdg-terminals.list`, so whichever terminal runs last wins
  Super+Return. `main.yml` runs kitty before ghostty for that reason.
- **VS Code settings.** `copy-config-soeren.yml` writes
  `~/.config/Code/User/settings.json`, overwriting what
  `omarchy-install-editor-vscode` and `omarchy-theme-set-vscode` put there. A
  backup is taken; re-run `omarchy-theme-set-vscode` if you want the Omarchy
  theme back.
- **Emacs.** This installs plain `emacs` from `[extra]`, not Omarchy's themed
  `omarchy-emacs` AUR package, because that ships its own config and Doom owns
  `~/.config/emacs`.
- **Docker group.** Log out and back in (or `newgrp docker`) after the first run.
