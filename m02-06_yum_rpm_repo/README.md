# Размещаем свой RPM в своем репозитории

## Цель:<br>
Научиться создавать свой RPM;<br>
Научится создавать свой репозиторий с RPM.<br>

---
## Создание ВМ
Будем использовать образ CentOS 8 Stream.<br>
Создаем `Vagrantfile` следующего содержания (по возможности использовать большеее количество ядер для ускорения процесса компиляции):<br>
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
yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc
```
`Upgraded:
  cpp-8.5.0-22.el8.x86_64                             dnf-plugins-core-4.0.21-25.el8.noarch      
  gcc-8.5.0-22.el8.x86_64                             gcc-c++-8.5.0-22.el8.x86_64                
  libgcc-8.5.0-22.el8.x86_64                          libgomp-8.5.0-22.el8.x86_64                
  libstdc++-8.5.0-22.el8.x86_64                       libstdc++-devel-8.5.0-22.el8.x86_64        
  python3-dnf-plugins-core-4.0.21-25.el8.noarch       yum-utils-4.0.21-25.el8.noarch             
Installed:
  annobin-11.13-2.el8.x86_64                     at-3.1.20-12.el8.x86_64                         
  avahi-libs-0.7-27.el8.x86_64                   bc-1.07.1-5.el8.x86_64                          
  createrepo_c-0.17.7-6.el8.x86_64               createrepo_c-libs-0.17.7-6.el8.x86_64           
  cups-client-1:2.2.6-57.el8.x86_64              cups-libs-1:2.2.6-57.el8.x86_64                 
  drpm-0.4.1-3.el8.x86_64                        dwz-0.12-10.el8.x86_64                          
  ed-1.14.2-4.el8.x86_64                         efi-srpm-macros-3-3.el8.noarch                  
  elfutils-0.190-2.el8.x86_64                    esmtp-1.2-15.el8.x86_64                         
  gc-7.6.4-3.el8.x86_64                          gcc-plugin-annobin-8.5.0-22.el8.x86_64          
  gdb-headless-8.2-20.el8.x86_64                 ghc-srpm-macros-1.4.2-7.el8.noarch              
  go-srpm-macros-2-17.el8.noarch                 guile-5:2.0.14-7.el8.x86_64                     
  libatomic_ops-7.6.2-3.el8.x86_64               libbabeltrace-1.5.4-4.el8.x86_64                
  libesmtp-1.0.6-18.el8.x86_64                   libipt-1.6.1-8.el8.x86_64                       
  liblockfile-1.14-2.el8.x86_64                  libtool-ltdl-2.4.6-25.el8.x86_64                
  mailx-12.5-29.el8.x86_64                       ncurses-compat-libs-6.1-10.20180224.el8.x86_64  
  nspr-4.35.0-1.el8.x86_64                       nss-3.90.0-7.el8.x86_64                         
  nss-softokn-3.90.0-7.el8.x86_64                nss-softokn-freebl-3.90.0-7.el8.x86_64          
  nss-sysinit-3.90.0-7.el8.x86_64                nss-util-3.90.0-7.el8.x86_64                    
  ocaml-srpm-macros-5-4.el8.noarch               openblas-srpm-macros-2-2.el8.noarch             
  perl-srpm-macros-1-25.el8.noarch               python-rpm-macros-3-45.el8.noarch               
  python-srpm-macros-3-45.el8.noarch             python3-rpm-macros-3-45.el8.noarch              
  qt5-srpm-macros-5.15.3-1.el8.noarch            redhat-lsb-core-4.1-47.el8.x86_64               
  redhat-lsb-submod-security-4.1-47.el8.x86_64   redhat-rpm-config-131-1.el8.noarch              
  rpm-build-4.14.3-31.el8.x86_64                 rpmdevtools-8.10-8.el8.noarch                   
  rust-srpm-macros-5-2.el8.noarch                spax-1.5.3-13.el8.x86_64                        
  time-1.9-3.el8.x86_64                          unzip-6.0-46.el8.x86_64                         
  util-linux-user-2.32.1-43.el8.x86_64           zip-3.0-23.el8.x86_64                           
  zstd-1.4.4-1.el8.x86_64                       `


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



