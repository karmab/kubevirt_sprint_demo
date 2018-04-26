# -*- mode: ruby -*-
# vi: set ft=ruby :
#
Vagrant.configure(2) do |config|
  config.vm.box = "generic/rhel7"
  # config.vm.box_url = "http://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1802_01.Libvirt.box"

  if Vagrant.has_plugin?("vagrant-cachier") then
      config.cache.scope = :machine
      config.cache.auto_detect = false
      config.cache.enable :dnf
      config.cache.synced_folder_opts = {
      type: :nfs,
      mount_options: ['rw', 'vers=4', 'tcp']
    }
  end

  if Vagrant.has_plugin?('vagrant-registration') then
      config.registration.org = 'foo'
      config.registration.activationkey = 'bar'
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provider :libvirt do |domain|
      domain.cpus = 2
      domain.nested = true  # enable nested virtualization
      domain.cpu_mode = "host-model"
  end
 
  config.vm.define "master01" do |master|
      master.vm.hostname = "master01"
      master.vm.network "private_network", ip: "192.168.201.2"
      master.vm.provider :libvirt do |domain|
          domain.memory = 8192
      end
      master.vm.provision "openshift", type: "ansible" do |ansible|
        ansible.playbook = "openshift.yml"
        ansible.groups = {
          "master" => ["master01","master02","master03"],
        }
      end
      master.vm.provision "kubevirt", type: "ansible" do |ansible|
        ansible.playbook = "deploy.yml"
        ansible.groups = {
          "master" => ["master01"],
        }
      end
  end
  config.vm.define "master02" do |master|
      master.vm.hostname = "master02"
      master.vm.network "private_network", ip: "192.168.201.3"
      master.vm.provider :libvirt do |domain|
          domain.memory = 8192
      end
  end
  config.vm.define "master03" do |master|
      master.vm.hostname = "master03"
      master.vm.network "private_network", ip: "192.168.201.4"
      master.vm.provider :libvirt do |domain|
          domain.memory = 8192
      end
  end
end
