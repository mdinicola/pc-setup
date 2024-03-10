sudo apt update
sudo apt install pipx -y
pipx install ansible-core
ansible-playbook -i inventory.yml ansible-galaxy.yml
ansible-playbook -i inventory.yml provision.yml