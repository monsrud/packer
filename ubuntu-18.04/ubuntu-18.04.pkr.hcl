variable "vcenter_server" {
  description = "vcenter server url"
  type = string
}

variable "vcenter_username" {
  description = "vcenter username"
  default = "Administrator@vsphere.local"
  type = string
}

variable "vcenter_password" { 
  description = "vcenter password" 
  type = string
}

variable "esxi_host" { 
  description = "the esx host on which to create VM" 
  type = string
}

variable "CPUs" { 
  description = "number of CPUs for VM"
  default = 2
  type = number
}

variable "RAM" { 
  description = "amount of RAM for the VM" 
  default = 2048
  type = number
}

variable "datastore" { 
  description = "name of the datastore for VM" 
  type = string
}

variable "disk_controller_type" { 
  description = "disk controller type" 
  default = ["pvscsi"]
  type = list(string)
}

variable "insecure_connection" { 
  description = "allow unsigned ssl cert" 
  default = true
  type = bool
}

variable "iso_urls" { 
  description = "path to install ISO" 
  default = ["http://cdimage.ubuntu.com/releases/18.04/release/ubuntu-18.04.5-server-amd64.iso"]
  type = list(string)
}

variable "iso_checksum" { 
  description = "checksum of iso" 
  default = "sha256:8c5fc24894394035402f66f3824beb7234b757dd2b5531379cb310cedfdf0996"
  type = string
}

variable "network_name" { 
  description = "name of vmware network to assign to VM" 
  type = string
}

variable "network_card" { 
  description = "type of network card for VM" 
  default = "vmxnet3"
  type = string
}

variable "ssh_username" { 
  description = "a user that will be created that can log in via ssh" 
  type = string
}

variable "ssh_password" { 
  description = "the password for the user" 
  type = string
}

variable "ssh_pty" { 
  description = "run a pseudo terminal"
  default = true 
  type = bool
}

variable "disk_size" { 
  description = "the size of the virual machine's disk" 
  default = 10240
  type = number
}

variable "disk_thin_provisioned" { 
  description = "thin provision the VM's disk" 
  default = true
  type = bool
}

variable "vm_name" { 
  description = "the name for the virtual machine" 
  type = string
}

variable "boot_command" {
  type = list(string)
  default = ["<enter><wait><f6><wait><esc><wait>", 
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", 
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", 
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", 
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", 
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", 
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", 
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", 
                          "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", 
                          "<bs><bs><bs>", 
                          "/install/vmlinuz", 
                          " initrd=/install/initrd.gz", 
                          " priority=critical", 
                          " locale=en_US", 
                          " file=/media/preseed.cfg", 
                          "<enter>"
  ]
}




source "vsphere-iso" "ubuntu-18-04" {



  CPUs                 = var.CPUs
  RAM                  = var.RAM
  boot_command         = var.boot_command
  datastore            = var.datastore
  disk_controller_type = var.disk_controller_type
  floppy_files         = ["./preseed.cfg"]
  guest_os_type        = "ubuntu64Guest"
  host                 = var.esxi_host
  insecure_connection  = "true"
  iso_checksum         = var.iso_checksum
  iso_urls             = var.iso_urls
  network_adapters {
    network      = var.network_name
    network_card = var.network_card
  }
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_pty      = "true"
  storage {
    disk_size             = var.disk_size
    disk_thin_provisioned = true
  }
  username       = var.vcenter_username
  vcenter_server = var.vcenter_server
  password       = var.vcenter_password
  vm_name        = var.vm_name
}

build {
  sources = ["source.vsphere-iso.ubuntu-18-04"]

  provisioner "file" {
    destination = "/tmp/script.sh"
    source      = "script.sh"
  }

  provisioner "shell" {
    inline = ["echo labuser | sudo -S bash /tmp/script.sh"]
  }

}
