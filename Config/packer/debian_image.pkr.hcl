packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "name" {
  type    = string
  default = "debian-12"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "release" {
  type    = string
  default = "${env("release")}"
}

variable "disk_size" {
  type    = string
  default = "20480"
}
variable "iso_urls" {
  type    = list(string)
  default = ["iso/debian-12.10.0-amd64-netinst.iso"]
}

variable "iso_checksum" {
  type    = string
  default = "sha256:ee8d8579128977d7dc39d48f43aec5ab06b7f09e1f40a9d98f2a9d149221704a"
}

source "virtualbox-iso" "efi" {
  boot_command          = [
                           "c",
                           "linux /install.amd/vmlinuz ",
                           "auto=true preseed/url=http://192.168.56.1:{{ .HTTPPort }}/preseed.cfg ",
                           "priority=critical ",
                          #  "--- netcfg/choose_interface=enp0s3 netcfg/disable_autoconfig=true netcfg/get_ipaddress=192.168.56.10 netcfg/get_netmask=255.255.255.0 netcfg/get_gateway=192.168.56.1 netcfg/get_nameservers=8.8.8.8 8.8.4.4 netcfg/disable_dhcp_ipv6=true netcfg/disable_autoconfig_ipv6=true",
                          #  "netcfg/no_default_route=true ",
                          #  "--- netcfg/choose_interface=eth1",
                           "--- net.ifnames=0 biosdevname=0<enter>",
                           "initrd /install.amd/initrd.gz<enter><wait>",
                           "boot<enter>"
                          ]
  boot_wait             = "10s"
  communicator          = "ssh"
  vm_name               = "packer-${var.name}"
  cpus                  = "${var.cpus}"
  memory                = "${var.memory}"
  disk_size             = "${var.disk_size}"
  iso_urls              = "${var.iso_urls}"
  iso_checksum          = "${var.iso_checksum}"
  iso_interface         = "sata"
  headless              = false
  http_directory        = "http"
  ssh_username          = "vagrant"
  ssh_password          = "vagrant"
  ssh_port              = 22
  ssh_timeout           = "3600s"
  firmware              = "efi"
  vboxmanage            = [
                            ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],    
                            ["modifyvm", "{{.Name}}", "--vram", "64"]
                            # ["modifyvm", "{{.Name}}", "--nic1", "nat"],
                            # ["modifyvm", "{{.Name}}", "--nic2", "hostonly"],
                            # ["modifyvm", "{{.Name}}", "--hostonlyadapter2", "vboxnet0"]
                          ]
  guest_os_type         = "Debian_64"
  guest_additions_mode  = "disable"
  hard_drive_interface  = "sata"
  output_directory      = "builds/${var.name}-${source.name}-${source.type}"
  shutdown_command      = "echo 'vagrant' | sudo -S /usr/sbin/shutdown -P now"
}

build {
  sources = ["virtualbox-iso.efi"]

  provisioner "shell" {
    environment_vars  = ["DEBIAN_RELEASE=${var.release}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E /bin/bash -eu '{{ .Path }}'"
    scripts           = ["scripts/update.sh"]
    expect_disconnect = true
  }
  provisioner "shell" {
    pause_before      = "120s"
    environment_vars  = ["HOME_DIR=/home/vagrant", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E /bin/bash -eu '{{ .Path }}'"
    scripts           = ["scripts/setup.sh", "scripts/vagrant.sh", "scripts/cleanup.sh"]
    expect_disconnect = true
  }
#  post-processors {
#    post-processor "vagrant" {
#      output = "builds/${var.name}-{{.Provider}}.box"
#    }
#    post-processor "vagrant-cloud" {
#      box_tag = "mojtaba/${var.name}"
#      version = "${local.version}"
#    }
#  }
}