# Systemd

Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner:

- Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig или в /etc/default);<br>
- Установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi;<br>
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
Запустим ВМ:
```sh
vagrant up
```
## Создание сервиса watchlog
Из директории с Vagrantfile запустим playbook
```bash
ansible-playbook playbooks/find_alert_setup.yml
```
После успешного завершения работы плейбука подключимся
```bash
vagrant ssh
```
и убедимся в результате:
```bash
tail -f /var/log/messages
```
Регулярное появление сообщения `centos8s root[6827]: ... : I found word, Master!` говорит о корректной работе созданных таймера и сервиса.<br>
После проверки можно выйти из консоли ВМ и создать ВМ заново.
```bash
vagrant destroy -f && rm -R .vagrant/ && vagrant up
```
## Установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi
