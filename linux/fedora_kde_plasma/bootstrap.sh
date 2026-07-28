#!/bin/bash

set -euo pipefail

sudo dnf install -y ansible-core

ansible-playbook -i inventory.yml playbooks/ansible_galaxy.yml
ansible-playbook -i inventory.yml playbooks/bootstrap.yml --ask-become-pass

# Load profile
set +u
source ~/.bashrc
set -u

# Install development tools
mise install