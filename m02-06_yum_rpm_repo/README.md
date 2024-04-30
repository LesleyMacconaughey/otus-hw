# Размещаем свой RPM в своем репозитории
---
Цель:<br>
Научиться создавать свой RPM;<br>
Научится создавать свой репозиторий с RPM;<br>
Что нужно сделать?<br>
создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями);<br>
создать свой репо и разместить там свой RPM;<br>
реализовать это все в вагранте.<br>
---
## Создание ВМ
Будем использовать образ CentOS 8 Stream.<br>
Создаем Vagranyfile сдедующего содержания:<br>
```ryby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "generic/centos8s"
  config.vm.box_version = "4.3.12"
  config.vm.provider :virtualbox
  config.vm.hostname = "centos8-hw06"
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
     vb.memory = "1024"
     vb.cpus = 4
     end
  end
```
Разворачиваем образ:
```bash
vagrant up
```
