# Configuration Files

This directory contains default configuration files that will be copied to their target locations.

## Usage

Configuration files are automatically copied when running the main playbook:

```bash
ansible-playbook main.yml
```

Or run the configuration copy playbook directly:

```bash
ansible-playbook playbooks/base/copy-default-configurations.yml
```

## Adding New Configurations

1. Add your configuration file(s) to this directory
2. Edit `playbooks/base/copy-default-configurations.yml` and add an entry to the `config_files` list:

```yaml
- source: "myconfig.conf"
  target: "{{ user_home }}/.config/myconfig.conf"
  create_backup: yes
```

## Backup

By default, existing configuration files are backed up before being overwritten. Backup files are created with a timestamp suffix.
