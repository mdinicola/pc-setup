#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

sudo dnf install -y ansible-core

ansible-playbook -i "$SCRIPT_DIR/inventory.yml" "$SCRIPT_DIR/playbooks/ansible_galaxy.yml"
ansible-playbook -i "$SCRIPT_DIR/inventory.yml" "$SCRIPT_DIR/playbooks/kde_plasma.yml" "$@" --skip-tags common_setup --ask-become-pass