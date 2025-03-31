terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "~> 0.2"
    }
  }
}

provider "virtualbox" {}

variable "vm_count" {
  default = 3
}

variable "vm_name_prefix" {
  default = "my-vm"
}

variable "hostonly_interface" {
  default = "vboxnet0"
}

variable "vm_ips" {
  type    = list(string)
  default = ["192.168.56.101", "192.168.56.102", "192.168.56.103"]
}

resource "virtualbox_vm" "vm" {
  count  = var.vm_count
  name   = "${var.vm_name_prefix}-${count.index + 1}"
  image  = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-vagrant.box"
  cpus   = 2
  memory = "2048 mib"

  network_adapter {
    type           = "hostonly"
    host_interface = var.hostonly_interface
  }

  storage_controller {
    name   = "SATA"
    type   = "sata"
    bus    = 0
    port   = 0
    device = 0
    disk {
      size = "20G"
    }
  }

  cloud_init {
    user_data = <<-EOF
      #cloud-config
      network:
        version: 2
        ethernets:
          enp0s3:
            dhcp4: no
            addresses:
              - ${var.vm_ips[count.index]}/24
            gateway4: 192.168.56.1
            nameservers:
              addresses:
                - 8.8.8.8
                - 8.8.4.4
    EOF
  }

  provisioner "local-exec" {
    command = "echo VM ${self.name} created with IP ${var.vm_ips[count.index]}"
  }
}

output "vm_ips" {
  value = var.vm_ips
}
