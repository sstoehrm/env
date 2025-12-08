#!/bin/bash

# Detect the Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot detect distribution"
    exit 1
fi

echo "Detected distribution: $OS"

# Install pipx based on distribution
if command -v apt-get &> /dev/null; then
    echo "Installing pipx via apt..."
    sudo apt-get update
    sudo apt-get install pipx -y
elif command -v dnf &> /dev/null; then
    echo "Installing pipx via dnf..."
    sudo dnf install pipx -y
else
    echo "Unsupported package manager. Please install pipx manually."
    exit 1
fi

# Ensure pipx path is set up
pipx ensurepath

# Install ansible with dependencies
echo "Installing Ansible via pipx..."
pipx install --include-deps ansible

echo "Ansible installation complete!"
echo "You may need to restart your shell or run: source ~/.bashrc"
