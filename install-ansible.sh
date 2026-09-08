#!/bin/bash

# Omarchy branch: this repo only targets Omarchy (Arch), so Ansible comes from
# [extra]. The `ansible` package (not `ansible-core`) bundles
# community.general, which the pacman tasks in these playbooks need.

set -euo pipefail

if [ ! -f /etc/os-release ]; then
    echo "Cannot detect distribution"
    exit 1
fi

. /etc/os-release

if [ "${ID:-}" != "omarchy" ]; then
    echo "This branch targets Omarchy; /etc/os-release reports ID=${ID:-unknown}."
    echo "Use the main branch for Debian/Ubuntu or Fedora."
    exit 1
fi

echo "Installing Ansible..."
omarchy-pkg-add ansible

echo "Ansible installation complete!"
ansible --version | head -n1
