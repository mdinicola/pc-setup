sudo ls > /dev/null
ansible-playbook -i inventory.yml playbooks/ansible_galaxy.yml
ansible-playbook -i inventory.yml playbooks/update_aws_tools.yml

