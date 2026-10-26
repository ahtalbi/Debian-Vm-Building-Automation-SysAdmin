packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

source "virtualbox-iso" "debian" {
  guest_os_type        = "Debian_64"
  vm_name              = "debian-base-vm1"
  disk_size            = 20480
  memory               = 2048
  cpus                 = 2
  
  iso_url      = "file:///home/obetox/Downloads/debian-13.7.0-amd64-netinst.iso"
  iso_checksum = "none"
  # Tells Packer where your preseed.cfg is located locally
  http_directory       = "preseed"

  # Automates the boot menu keystrokes to pass your preseed file URL
  boot_command = [
    "<esc><wait>",
    "install auto=true ",
    "priority=critical ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "netcfg/get_hostname=ahmed ",
    "--- <enter>"
  ]

  ssh_username         = "ahmed"
  ssh_password         = "123"
  ssh_timeout          = "20m"

  shutdown_command     = "echo '123' | sudo -S shutdown -P now"
}

build {
  sources = ["source.virtualbox-iso.debian"]

  # Exports the finished VM into a Vagrant box file
  post-processor "vagrant" {
    output = "debian-custom.box"
  }
}