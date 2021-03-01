# Ansible

## Quick Start

1. Install Ansible.

   ```sh
   brew install ansible
   ```

2. Edit [inventory.yml](inventory.yml) to suit your environment.
3. Run your playbook of choice.

   ```sh
   # Install Docker
   ansible-playbook playbooks/install-docker.yml
   ```
