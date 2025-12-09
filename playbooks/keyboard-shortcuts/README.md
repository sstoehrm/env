# Keyboard Shortcuts Configuration

This directory contains Ansible playbooks for configuring keyboard shortcuts across different desktop environments and window managers.

## Available Playbooks

### GNOME (`gnome.yml`)
For **Ubuntu GNOME** and **Fedora GNOME** desktops.

- **Terminal**: `gnome-terminal`
- **File Manager**: `nautilus`
- **Configuration Method**: dconf

```bash
ansible-playbook playbooks/keyboard-shortcuts/gnome.yml
```

### Budgie (`budgie.yml`)
For **Ubuntu Budgie** desktop.

- **Terminal**: `tilix`
- **File Manager**: `nemo`
- **Configuration Method**: dconf (Budgie is built on GNOME technologies)

```bash
ansible-playbook playbooks/keyboard-shortcuts/budgie.yml
```

### i3 (`i3.yml`)
For **Fedora i3 Spin** or any **i3 window manager** installation.

- **Terminal**: `urxvt` (Fedora), `gnome-terminal` (Ubuntu/Debian)
- **File Manager**: `nautilus`
- **Configuration Method**: i3 config file (`~/.config/i3/config`)

```bash
ansible-playbook playbooks/keyboard-shortcuts/i3.yml
```

## Configured Shortcuts

All playbooks configure the same set of shortcuts for consistency across environments:

| Shortcut | Action |
|----------|--------|
| `Super+Return` | Launch Terminal |
| `Super+Shift+B` | Launch Browser (Chromium) |
| `Super+Shift+F` | Launch File Manager |
| `Super+Shift+N` | Launch Neovim |
| `Super+Shift+G` | Launch Lazygit |
| `Super+W` | Close window |
| `Super+F` | Toggle fullscreen |
| `Super+1/2/3/4` | Switch to workspace 1/2/3/4 |
| `Super+Shift+1/2/3/4` | Move window to workspace 1/2/3/4 |

*Note: For i3, `Super` key is `Mod4` (Windows key)*

## Distribution-Specific Details

### Ubuntu GNOME / Fedora GNOME
- Uses `dconf` to set GNOME keyboard shortcuts
- Chromium is installed via `snap` (Ubuntu) or `flatpak` (Fedora)
- No restart required - shortcuts are applied immediately

### Ubuntu Budgie
- Uses `dconf` (Budgie is based on GNOME)
- Default terminal is Tilix (tiling terminal emulator)
- Default file manager is Nemo
- No restart required - shortcuts are applied immediately

### Fedora i3 Spin
- Modifies `~/.config/i3/config` file
- Uses `urxvt` (rxvt-unicode) as default terminal
- Creates backup of config before modification
- **Requires i3 reload**: Press `Mod4+Shift+R` after running the playbook

## Notes

- All playbooks automatically detect your distribution and adapt accordingly
- Backups are created for i3 config files before modification
- For GNOME/Budgie, shortcuts are applied immediately via dconf
- For i3, you must reload the configuration after running the playbook
