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
  guest_os_type = "Debian_64"
  vm_name       = "debian-base-vm"
  disk_size     = 20480
  memory        = 2048
  cpus          = 2


  headless             = false
  guest_additions_mode = "disable"

  iso_url      = "file:///home/obetox/Downloads/debian-13.7.0-amd64-netinst.iso"
  iso_checksum = "sha256:a7ef94ac2fb9a7fec454552abd629b7cc9d5155c886165a45649f5ce6167e355"

  http_directory = "preseed"

  boot_command = [
    "<esc><wait>",
    "install auto=true priority=critical ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "debian-installer/locale=en_US keyboard-configuration/xkb-keymap=us ",
    "netcfg/disable_autoconfig=true ",
    "netcfg/get_ipaddress=10.0.2.8 ",
    "netcfg/get_netmask=255.255.255.0 ",
    "netcfg/get_gateway=10.0.2.2 ",
    "netcfg/get_nameservers=10.0.2.3 ",
    "netcfg/confirm_static=true ",
    "netcfg/get_hostname=ahmed netcfg/get_domain=local ",
    "--- <enter>"
  ]

  ssh_host_port_min = 2222
  ssh_host_port_max = 2222

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--natpf1", "delete", "packercomm"],
    ["modifyvm", "{{.Name}}", "--natpf1", "packercomm,tcp,127.0.0.1,2222,10.0.2.8,22"]
  ]

  ssh_username = "ahmed"
  ssh_password = "123"
  ssh_timeout  = "30m"

  shutdown_command = "echo '123' | sudo -S shutdown -P now"
}

build {
  sources = ["source.virtualbox-iso.debian"]

  post-processor "vagrant" {
    output = "debian-custom.box"
  }
}