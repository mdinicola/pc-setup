#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

sudo dnf install -y ansible-core

ansible-playbook -i "$SCRIPT_DIR/inventory.yml" "$SCRIPT_DIR/playbooks/ansible_galaxy.yml"
ansible-playbook -i "$SCRIPT_DIR/inventory.yml" "$SCRIPT_DIR/playbooks/bootstrap.yml" --ask-become-pass

export PATH="$HOME/.local/bin:$PATH"

# Install development tools
mise install