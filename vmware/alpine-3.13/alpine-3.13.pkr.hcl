
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
  default = ["https://dl-cdn.alpinelinux.org/alpine/v3.13/releases/x86_64/alpine-standard-3.13.5-x86_64.iso"]
  type = list(string)
}

variable "iso_checksum" { 
  description = "checksum of iso" 
  default = "sha256:61ff66f31276738f18508143ea082a831beca160ad1be8fc07e0cf1e31828aa5"
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
  default = 10000
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
  default = [ 
             "root<enter><wait>", 
             "mount -t vfat /dev/fd0 /media/floppy<enter><wait>",
             "setup-alpine -f /media/floppy/ANSWERS<enter>",
             "<wait10>", 
             "password<enter><wait>", 
             "password<enter><wait>", 
             "<wait10>y<enter>", 
             "<wait300>",
             "<enter>",
             "mount /dev/sda3 /mnt<enter>",
             "<wait2>",
             "echo 'PermitRootLogin yes' >> /mnt/etc/ssh/sshd_config<enter>",
             "echo 'http://dl-cdn.alpinelinux.org/alpine/v3.13/community' >> /mnt/etc/apk/repositories<enter>",
             "cd /mnt<enter>",
             "chroot .<enter>",
             "apk update<enter>",
             "<wait2>",
             "apk add open-vm-tools<enter>",
             "<wait2>",
             "apk add open-vm-tools-guestinfo<enter>",
             "<wait2>",
             "apk add open-vm-tools-deploypkg<enter>",
             "<wait2>",
             "ln -s /etc/init.d/open-vm-tools /etc/runlevels/default/open-vm-tools <enter>",
             "ln -s /etc/init.d/open-vm-tools /etc/runlevels/boot/open-vm-tools <enter>",
             "<wait2>",
             "exit<enter>",
             "cd /<enter>",
             "<wait2>",
             "umount /mnt<enter>",
             "<wait2>",
             "reboot<enter>"

  ]
}


source "vsphere-iso" "alpine-3-13" {

  CPUs                 = var.CPUs
  RAM                  = var.RAM
  boot_command         = var.boot_command
  boot_wait            = "30s"
  datastore            = var.datastore
  disk_controller_type = var.disk_controller_type
  floppy_files         = ["./answers"]
  guest_os_type        = "otherLinux64Guest"
  host                 = var.esxi_host
  insecure_connection  = "true"
  iso_checksum         = var.iso_checksum
  iso_urls             = var.iso_urls
  remove_cdrom = true
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
  sources = ["source.vsphere-iso.alpine-3-13"]

  provisioner "file" {
    destination = "/tmp/setup.sh"
    source      = "setup.sh"
  }

  provisioner "shell" {
    inline = [
      "/tmp/setup.sh"
      ]
  }

}
