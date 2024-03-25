sudo ls > /dev/null
ansible-playbook -i inventory.yml playbooks/ansible_galaxy.yml
ansible-playbook -i inventory.yml playbooks/provision.yml
