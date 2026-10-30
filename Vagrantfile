Vagrant.configure("2") do |config|
  config.vm.box = "debian-custom"
  config.vm.box_check_update = false
  config.vm.hostname = "ahmed"

  config.ssh.username = "ahmed"
  config.ssh.password = "123"
  config.ssh.insert_key = false

  config.vm.network "forwarded_port", guest: 22, host: 2222,
                    guest_ip: "10.0.2.8", id: "ssh"

  config.vm.provider "virtualbox" do |vb|
    vb.gui    = true
    vb.memory = 2048
    vb.cpus   = 2
  end

  config.vm.provision "shell", path: "provision/linux.sh"
  config.vm.provision "shell", path: "provision/login.sh"
end