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

### Run Complete Setup

Execute all playbooks:

```bash
ansible-playbook main.yml --ask-become-pass
```

## Important Noteso

### Sudo and prompts

Prompts and sudo are currently not supported from ansible [issues](https://github.com/ansible/ansible/issues/85837) in distros with sudo-rs like ubuntu 25.10.

The workaround is to configure sudo-ws:

```bash
sudo update-alternatives --config sudo
```

## TODO

- [ ] ripgrep
- [ ] claude code
- [ ] clojure mcp (bhauman/clojure-mcp)
- [ ] ~/.clojure/deps.edn
- [ ] Formatter (nvim)
- [ ] parinfer (nvim)
