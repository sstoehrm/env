# Env

## Installation

Install Ansible:
```bash
./install-ansible.sh
```

## Usage

### Run Complete Setup

Execute all playbooks:
```bash
ansible-playbook main.yml
```

### Run Specific Sections

Use tags to run specific categories:
```bash
# Base system (packages, Signal, Java/JVM, Node.js, Docker, VSCode, Chromium)
ansible-playbook main.yml --tags "base"

# Soeren's personal tools (Neovim, LazyVim, lazygit, tmux, starship, etc.)
ansible-playbook main.yml --tags "soeren"

# Clojure development tools
ansible-playbook main.yml --tags "clojure"

# Game development tools
ansible-playbook main.yml --tags "gamedev"

# Specific tools
ansible-playbook main.yml --tags "java"
ansible-playbook main.yml --tags "nodejs"
ansible-playbook main.yml --tags "docker"
ansible-playbook main.yml --tags "lazyvim"
```

### Available Tags

- **base**: Core development environment including packages, Signal, SDKMAN, NVM, Java/JVM tools (kotlin, maven, gradle, visualvm), Node.js, VSCode, OpenCode, Docker, Chromium, keyboard shortcuts
- **soeren**: Personal tooling including Neovim, LazyVim, Portainer, lazygit, fd, ast-grep, tmux, starship, and Clojure tools
- **clojure**: Clojure development tools (rlwrap, babashka, clojure-cli)
- **gamedev**: Game development tools (Odin, Blockbench)
- **Individual tool tags**: `packages`, `signal`, `sdkman`, `nvm`, `java`, `kotlin`, `maven`, `gradle`, `visualvm`, `nodejs`, `vscode`, `opencode`, `neovim`, `neovim-deps`, `lazyvim`, `docker`, `portainer`, `lazygit`, `fd`, `ast-grep`, `tmux`, `starship`, `rlwrap`, `babashka`, `clojure-cli`, `odin`, `blockbench`, `chromium`, `keyboard-shortcuts`

## Important Notes

### LazyVim Installation

The `lazyvim` playbook will **not overwrite** existing LazyVim configurations. If `~/.config/nvim` already exists, the playbook will skip installation and preserve your current configuration. This ensures that re-running the setup won't lose your customizations.

To force a fresh LazyVim installation, manually remove or backup `~/.config/nvim` before running the playbook.
