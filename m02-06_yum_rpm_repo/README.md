# Размещаем свой RPM в своем репозитории

## Цель:<br>
Научиться создавать свой RPM;<br>
Научится создавать свой репозиторий с RPM.<br>

---
## Создание ВМ
Будем использовать образ CentOS 8 Stream.<br>
Создаем Vagranyfile следующего содержания (по возможности использовать большеее количество ядер для ускорения процесса компиляции):<br>
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
     vb.cpus = 8
     end
  end
```
Разворачиваем образ:
```bash
vagrant up
```
Подключаемся:
```sh
vagrant ssh
```
Переходим под root:
```sh
sudo su
```
Дальнейшие действия будем производить из домашнего каталога root:
```sh
cd ~
```
Устанавливаем необходимые пакеты:
```sh
yum install -y redhat-lsb-core \wget rpmdevtools rpm-build createrepo yum-utils gcc
```
Загрузим SRPM пакет NGINX для дальнейшей работы над ним:
```sh
wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm
```
Установим пакет (при установке такого пакета в домашней директории создается древо каталогов для сборки):
```sh
rpm -i nginx-1.*
```
Скачаем и разархивируем последний исходник для openssl (он потребуется при сборке):
```sh
wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip
```
```sh
 unzip OpenSSL_1_1_1-stable.zip
```
Поставим все зависимости, чтобы в процессе сборки не было ошибок:
```sh
yum-builddep rpmbuild/SPECS/nginx.spec
```
Поправим spec файл, чтобы NGINX собирался с необходимыми нам опциями:
```sh
vi rpmbuild/SPECS/nginx.spec
```
В нашем случае добавим --with-openssl=/<br>
После чего запустим сборку RPM пакета:
```sh
rpmbuild -bb rpmbuild/SPECS/nginx.spec
```
После завершения проверим, что пакеты создались:
```sh
ls -la /root/rpmbuild/RPMS/x86_64/
```
Установим наш созданный пакет nginx, запустим и проверим его работу :
```sh
yum localinstall /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm
```
```sh
systemctl start nginx
```
```sh
systemctl status nginx
```
---
## Создем свой репозиторий и размещаем там ранее собранный RPM

```sh
mkdir /usr/share/nginx/html/repo
```
```sh
cp /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/
```



