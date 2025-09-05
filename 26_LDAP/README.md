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
```

Для дальнейшей настройки FreeIPA нам потребуется, чтобы DNS-сервер хранил запись о нашем LDAP-сервере. добавим запись в файл `/etc/hosts`

```sh
vi /etc/hosts
```

    127.0.0.1   localhost localhost.localdomain 
    127.0.1.1 ipa.otus.lan ipa
    192.168.57.10 ipa.otus.lan ipa

```sh
dnf install ipa-server
ipa-server-install
```

Отвечаем на вопросы и после начнется процесс конфигурации. После его завершения мы увидим подсказку со следующими шагами:

    ==============================================================================
    Setup complete

    Next steps:
            1. You must make sure these network ports are open:
                    TCP Ports:
                    * 80, 443: HTTP/HTTPS
                    * 389, 636: LDAP/LDAPS
                    * 88, 464: kerberos
                    * 53: bind
                    UDP Ports:
                    * 88, 464: kerberos
                    * 53: bind
                    * 123: ntp

            2. You can now obtain a kerberos ticket using the command: 'kinit admin'
            This ticket will allow you to use the IPA tools (e.g., ipa user-add)
            and the web user interface.


## Ansible playbook для конфигурации клиента

Для настройки клиентов выполним плейбук `provision.yml` из папки `ansible`

### Проверка работы

Авторизируемся на сервере:
```sh
kinit admin
```
Создадим пользователя otus-user
```sh
ipa user-add otus-user --first=Otus --last=User --password
```

    ----------------------
    Added user "otus-user"
    ----------------------
    User login: otus-user
    First name: Otus
    Last name: User
    Full name: Otus User
    Display name: Otus User
    Initials: OU
    Home directory: /home/otus-user
    GECOS: Otus User
    Login shell: /bin/sh
    Principal name: otus-user@OTUS.LAN
    Principal alias: otus-user@OTUS.LAN
    User password expiration: 20250905080150Z
    Email address: otus-user@otus.lan
    UID: 979400003
    GID: 979400003
    Password: True
    Member of groups: ipausers
    Kerberos keys available: True

На хосте client1 выполним команду
```sh
kinit otus-user
```

Система просит поменять пароль

    Password for otus-user@OTUS.LAN: 
    Password expired.  You must change it now.
    Enter new password: 
    Enter it again: 

После смены пароля настройка завершена.