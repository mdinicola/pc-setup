#!/bin/bash

set -euo pipefail

sudo dnf install -y ansible-core

ansible-playbook -i inventory.yml playbooks/ansible_galaxy.yml
ansible-playbook --inventory inventory.yml playbooks/bootstrap.yml
source ~/.bashrc
mise install