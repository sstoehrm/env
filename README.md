# Env

## Installation

Install Ansible:
```bash
./install-ansible.sh
```

## Usage

Execute the playbooks in order:
```bash
ansible-playbook 01_packages.yml --ask-become-pass
ansible-playbook 02_enviromnent.yml --ask-become-pass
ansible-playbook 03_dev-tools.yml --ask-become-pass
```
