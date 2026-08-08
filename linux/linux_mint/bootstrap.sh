#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

sudo apt update
sudo apt install pipx -y
pipx install ansible-core
pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"

ansible-playbook -i "$SCRIPT_DIR/inventory.yml" "$SCRIPT_DIR/playbooks/ansible_galaxy.yml"
ansible-playbook -i "$SCRIPT_DIR/inventory.yml" "$SCRIPT_DIR/playbooks/bootstrap.yml" "$@" --ask-become-pass

# Install development tools
mise install