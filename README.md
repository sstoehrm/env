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
# Base system packages and Signal
ansible-playbook main.yml --tags "base"

# Development environment (all dev tools)
ansible-playbook main.yml --tags "development"

# Applications only
ansible-playbook main.yml --tags "applications"

# Specific tools
ansible-playbook main.yml --tags "java"
ansible-playbook main.yml --tags "nodejs"
ansible-playbook main.yml --tags "docker"
ansible-playbook main.yml --tags "clojure"
ansible-playbook main.yml --tags "gamedev"
```

### Available Tags

- **base**: System packages, Signal
- **development**: All development tools and IDEs
- **applications**: Chromium, keyboard shortcuts
- Specific tool tags: `sdkman`, `nvm`, `java`, `kotlin`, `maven`, `gradle`, `visualvm`, `nodejs`, `vscode`, `opencode`, `neovim`, `neovim-deps`, `lazyvim`, `docker`, `portainer`, `lazygit`, `fd`, `ast-grep`, `starship`, `clojure`, `rlwrap`, `babashka`, `clojure-cli`, `odin`, `blockbench`, `chromium`, `keyboard-shortcuts`
