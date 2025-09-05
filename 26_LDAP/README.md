# Домашнее задание Vagrant-стенд c LDAP на базе FreeIPA

Цель домашнего задания:

Научиться настраивать LDAP-сервер и подключать к нему LDAP-клиентов

Запустим виртуальные машины командой 
```sh
vagrant up
```

## Установка FreeIPA сервера

Подключимся к нему по SSH с помощью команды: `vagrant ssh ipa.otus.lan` и перейдём в root-пользователя: `sudo -i`

Начнем настройку FreeIPA-сервера:
```sh
vagrant ssh ipa.otus.lan
sudo -i
timedatectl set-timezone Europe/Moscow
yum install -y chrony
systemctl enable chronyd --now
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
dnf install ipa-server
ipa-server-install
```

Отвечаем на вопросы и после начнется процесс конфигурации. После его завершения мы увидим подсказку со следующими шагами: