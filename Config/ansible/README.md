1- create role for preparing server
2- add ssh-key to all server
3- creat manual vms
4- ansible-playbook playbook.yml -l monitoring --tags "docker,preparing" -i inventory.ini --user=deploy --become --become-method=su -Kk