# Systemd

Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner:

- Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig или в /etc/default);<br>
- Установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi);<br>
- Дополнить unit-файл httpd (он же apache2) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.<br>
---
## Создание стенда
Создадим ВМ на основе бокса generic/centos8s версии 4.3.12.
```bash
cat << EOF >> Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "generic/centos8s"
  config.vm.box_version = "4.3.12"
  config.vm.provider :virtualbox
  config.vm.hostname = "centos8-hw09"
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
     vb.memory = "1024"
     vb.cpus = 2
     end
  end
EOF
```
Запустим ВМ, подключимся и перейдем в root:
```sh
vagrant up
```
```bash
vagrant ssh
```
```bash
sudo su
```
