# Vagrant стенд для NFS
Цель:
Развернуть сервис NFS и подключить к нему клиента.

---
Для выполнения задания создадим стенд (Vagrantfile) из двух виртуальных машин:
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.vm.box_version = "2004.01"
config.vm.provider "virtualbox" do |v|
  v.memory = 256
  v.cpus = 1
end
config.vm.define "nfss" do |nfss|
  nfss.vm.network "private_network", ip: "192.168.50.10",
virtualbox__intnet: "net1"
  nfss.vm.hostname = "nfss"
end
config.vm.define "nfsc" do |nfsc|
  nfsc.vm.network "private_network", ip: "192.168.50.11",
virtualbox__intnet: "net1" 
  nfsc.vm.hostname = "nfsc"
end
end
```
Первая nfss - NFS-server с адресом 192.168.50.10, вторая nfsc - NFS-client с адресом 192.168.50.11