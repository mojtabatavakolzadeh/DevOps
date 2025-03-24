1- create role for preparing server
2- add ssh-key to all server
3- creat manual vms
4- ansible-playbook playbook.yml -l monitoring --tags "docker,preparing" -i inventory.ini --user=deploy --become --become-method=su -Kk
5- ordering tasks preparing server 
6- add private registry to preparing server
7- i remove tags of playbook and tags to every tasks . if use task . i select via tags for example `ansible-playbook playbook.yml -i inventory.ini -l monitoring --tags "docker,config-docker" --skip-tags "install-docker" --user=deploy --become -Kk`
8- add config networks for first vm