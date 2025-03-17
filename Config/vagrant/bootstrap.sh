#!/bin/bash

# Update /etc/hosts file
echo -e "192.168.1.3\trepo.tavakolzadeh.ir" | sudo tee -a /etc/hosts
echo -e "192.168.1.3\tregistry.tavakolzadeh.ir" | sudo tee -a /etc/hosts
echo -e "192.168.1.100\tmaster-node1" | sudo tee -a /etc/hosts
echo -e "192.168.1.101\tworker-node1" | sudo tee -a /etc/hosts
echo -e "192.168.1.102\tworker-node2" | sudo tee -a /etc/hosts

# Add keyring kubernetes
# curl --proxy 192.168.1.3:2334 -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# echo -e "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] http://repo.tavakolzadeh.ir/repository/pkg-k8s/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list 

# Update /etc/apt/sources.list
echo -e "
deb [trusted=yes] http://repo.tavakolzadeh.ir/repository/debian/ bookworm main contrib non-free non-free-firmware
deb-src [trusted=yes] http://repo.tavakolzadeh.ir/repository/debian/ bookworm main contrib non-free non-free-firmware

deb [trusted=yes] http://repo.tavakolzadeh.ir/repository/debian/ bookworm-updates main contrib non-free non-free-firmware
deb-src [trusted=yes] http://repo.tavakolzadeh.ir/repository/debian/ bookworm-updates main contrib non-free non-free-firmware

deb [trusted=yes] http://repo.tavakolzadeh.ir/repository/debian/ bookworm-backports main contrib non-free non-free-firmware
deb-src [trusted=yes] http://repo.tavakolzadeh.ir/repository/debian/ bookworm-backports main contrib non-free non-free-firmware

deb [trusted=yes] http://repo.tavakolzadeh.ir/repository/debian-security/ bookworm-security main contrib non-free non-free-firmware
deb-src [trusted=yes] http://repo.tavakolzadeh.ir/repository/debian-security/ bookworm-security main contrib non-free non-free-firmware
" | sudo tee /etc/apt/sources.list

sudo apt-get update
# Install packages
sudo apt-get install vim -y

# Disable swap
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab