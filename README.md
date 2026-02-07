# Env

Ansible-based development environment setup that works across multiple Linux distributions.

## Supported Distributions

- **Ubuntu/Debian**: Uses apt, snap for package management
- **Fedora/RHEL**: Uses dnf, Flatpak for package management

The playbooks automatically detect your distribution and use the appropriate package manager.

## Installation

Install Ansible:

```bash
./install-ansible.sh
```

## Usage

### Configure Preferences

Before running the playbook, create your preferences file:

```bash
cp preferences.example.json preferences.json
```

Edit `preferences.json` to customize what gets installed. See `preferences.example.json` for all available options.

### Run Complete Setup

Execute all playbooks:

```bash
ansible-playbook main.yml --ask-become-pass
```

The playbook will read your preferences from `preferences.json` and install accordingly.

### Update Preferences

Simply edit `preferences.json` and re-run the playbook. Ansible's idempotency ensures only new/changed items are installed.

## Important Noteso

### Sudo and prompts

Prompts and sudo are currently not supported from ansible [issues](https://github.com/ansible/ansible/issues/85837) in distros with sudo-rs like ubuntu 25.10.

The workaround is to configure sudo-ws:

```bash
sudo update-alternatives --config sudo
```

## Features

- Multi-distro support (Ubuntu/Debian, Fedora/RHEL)
- Terminal multiplexers (tmux, Zellij)
- Development tools (Docker, VSCode, Neovim, etc.)
- JVM tools (Java, Kotlin, Maven, Gradle via SDKMAN)
- Node.js via NVM
- Clojure tools (Babashka, Clojure CLI, rlwrap)
- Custom keyboard shortcuts for GNOME

## TODO

- [ ] ripgrep
- [ ] claude code
- [ ] clojure mcp (bhauman/clojure-mcp)
- [ ] ~/.clojure/deps.edn
- [ ] Formatter (nvim)
- [ ] parinfer (nvim)
