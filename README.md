![Overview](./assets/overview.png)

# Overview of this project

## What we should learn

This project is about 3 important ideas: Infrastructure as Code (IaC), Idempotency, and Proving reproducibility. Together they answer one question: how do we automate the installation and configuration of a VM so that anyone can rebuild it?

- **Infrastructure as Code (IaC):** the whole idea of the project. The server is described in files kept in git and built by a program, not by a person clicking. If a setting is not in the repository, it does not exist.
- **Idempotency:** running the provisioning twice leaves the machine in the same state as running it once, with no errors and nothing duplicated.
- **Proving reproducibility:** we destroy the VM and rebuild it from code, then run `verify.sh` to check that everything we built before still works.

## Build Steps
```
1. preseed/preseed.cfg    Installs the OS unattended, including the LVM partitioning

2. provision/linux.sh     Configures what the installer doesn't: static IP, systemd service, LV extend

3. provision/login.sh     Applies your login policy: users, sudoers, PAM, ACLs, SSH

4. verify.sh              Proves the policy holds (from login, unchanged)

5. Vagrantfile            Ties everything together: which box, which scripts, vagrant up
```

### 1. Configuring `preseed.cfg`

I started with an expert installation of Debian. For each question I encountered during the installation, I researched the corresponding preseed directive and how to use it to automate that step. I then added the necessary directives to `preseed.cfg` until the installation process could run unattended, including the LVM partitioning.

And what helped me to configure it [Deiban Documentation about automating installation](https://www.debian.org/releases/stable/amd64/apb.en.html)

And to install Packer to use this configuration file
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install packer
```

some commands you can use to work with vitrual box envirment

```
With this commmand we can show all the vms we have in our machine 
- VBoxManage list vms
With this command we can delet some vm 
- VBoxManage unregistervm <UUID>
With this command we can show all the VMs we have on our machine
- VBoxManage list vms
With this command we can show only the VMs that are running now
- VBoxManage list runningvms
With this command we can delete a VM (use the name, or the UUID for an `<inaccessible>` one)
- VBoxManage unregistervm <name or UUID> --delete
```

And for us we need to have the iso to configure it right so to have it good we need the hash of the file
```
sha256sum ~/Downloads/debian-13.7.0-amd64-netinst.iso
```

and to start you need to configure the packer which is gonna provide the installation of the vm with the config we have setted up
with those commands
```
packer init debian.pkr.hcl
packer validate debian.pkr.hcl
packer build -force debian.pkr.hcl
```
**init** downloads the VirtualBox and Vagrant plugins that the first block asks for.  
**validate** checks the syntax, and should print “The configuration is valid.”  
**build** creates the VM, types your boot_command into the installer, and serves preseed.cfg over HTTP. Packer waits for SSH on 10.0.2.8, shuts the VM down, and packages debian-custom.box.  

And some times if there is a problem in the installation it may be from a service running from the first virtual box procces which is still running and it can't run both  
so we need to make sure that is stopped 
```
pkill VBoxSVC; pkill VBoxXPCOMIPCD
```
or restart it
```
sudo systemctl restart vboxdrv
sudo systemctl daemon-reload
```
And better run with normal terminal so you activate the virtual box directly no sandbox of vsCode  

