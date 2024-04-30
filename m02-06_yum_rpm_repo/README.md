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
После выполнения команды увидим список обновленных и установленных пакетов с их зависимостями:<br>
Upgraded:<br>
  ...<br>   
Installed:<br>
  ...<br>
Загрузим SRPM пакет NGINX для дальнейшей работы над ним:
```sh
wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm
```
... - 'nginx-1.20.2-1.el8.ngx.src.rpm' saved [1086865/1086865]<br>
Установим пакет (при установке такого пакета в домашней директории создается древо каталогов для сборки):
```sh
rpm -i nginx-1.*
```
Возникнет предупреждение `warning: group builder does not exist - using root` - игнорируем<br>
Скачаем и разархивируем последний исходник для openssl (он потребуется при сборке):
```sh
wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip
```
...- 'OpenSSL_1_1_1-stable.zip' saved [11924330]
```sh
 unzip OpenSSL_1_1_1-stable.zip
```
Имеем:
```sh
ls -l
```
-rw-r--r--.  1 root root 11924330 Apr 30 16:04 OpenSSL_1_1_1-stable.zip<br>
-rw-r--r--.  1 root root  1086865 Nov 16  2021 nginx-1.20.2-1.el8.ngx.src.rpm<br>
drwxr-xr-x. 19 root root     4096 Sep 11  2023 openssl-OpenSSL_1_1_1-stable<br>
drwxr-xr-x.  4 root root       34 Apr 30 16:02 rpmbuild<br>
Поставим все зависимости, чтобы в процессе сборки не было ошибок:
```sh
yum-builddep rpmbuild/SPECS/nginx.spec
```
Предложит установить - соглашаемся:<br>
Install  4 Packages<br>
Upgrade  7 Packages<br>
Total download size: 13 M<br>
Is this ok [y/N]:<br>
Поправим spec файл, чтобы NGINX собирался с необходимыми нам опциями:
```sh
vi rpmbuild/SPECS/nginx.spec
```
В нашем случае добавим в секцию `%build` не забывая про `\` пареметр `--with-openssl=/root/openssl-OpenSSL_1_1_1-stable/`<br>
После чего запустим сборку RPM пакета:
```sh
rpmbuild -bb rpmbuild/SPECS/nginx.spec
```
После завершения проверим код возврата:
```sh
echo $?
```
а также, что пакеты создались:
```sh
ls -la /root/rpmbuild/RPMS/x86_64/
```
-rw-r--r--. 1 root root 2249516 Apr 30 16:40 nginx-1.20.2-1.el8.ngx.x86_64.rpm<br>
-rw-r--r--. 1 root root 2534064 Apr 30 16:40 nginx-debuginfo-1.20.2-1.el8.ngx.x86_64.rpm<br>
Установим наш созданный пакет nginx, запустим и проверим его работу :
```sh
yum localinstall /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm
```
Installed:<br>
  nginx-1:1.20.2-1.el8.ngx.x86_64    <br>                                                             
Complete!<br>
```sh
systemctl start nginx
```
```sh
systemctl status nginx
```
● nginx.service - nginx - high performance web server<br>
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)<br>
   Active: active (running) since Tue 2024-04-30 16:43:09 UTC; 5s ago<br>
     Docs: http://nginx.org/en/docs/<br>
  Process: 50752 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCES><br>
 Main PID: 50753 (nginx)<br>
    Tasks: 9 (limit: 4684)<br>
   Memory: 8.7M<br>
   CGroup: /system.slice/nginx.service<br>
           ├─50753 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf<br>
           ├─50754 nginx: worker process<br>
           ├─50755 nginx: worker process<br>
           ├─50756 nginx: worker process<br>
           ├─50757 nginx: worker process<br>
           ├─50758 nginx: worker process<br>
           ├─50759 nginx: worker process<br>
           ├─50760 nginx: worker process<br>
           └─50761 nginx: worker process<br>
<br>
Apr 30 16:43:09 centos8-hw06 systemd[1]: Starting nginx - high performance web server...<br>
Apr 30 16:43:09 centos8-hw06 systemd[1]: Started nginx - high performance web server.<br>

---
## Создем свой репозиторий и размещаем там ранее собранный RPM

Директория для статики у NGINX по умолчанию /usr/share/nginx/html. Создадим там каталог repo:
```sh
mkdir /usr/share/nginx/html/repo
```
Копируем туда наш собранный RPM и, например, RPM для установки репозитория Percona-Server:
```sh
cp /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/
```
```sh
wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm
```
Инициализируем репозиторий:
```sh
createrepo /usr/share/nginx/html/repo/
```
Directory walk started<br>
Directory walk done - 2 packages<br>
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/<br>
Preparing sqlite DBs<br>
Pool started (with 5 workers)<br>
Pool finished<br>
Настроим в NGINX доступ к листингу каталога:
В `location /` в файле `/etc/nginx/conf.d/default.conf` добавим директиву `autoindex on`.
В результате `location` будет выглядеть так:
```sh
location / {
root /usr/share/nginx/html;
index index.html index.htm;
autoindex on;
}
```
Проверяем синтаксис и перезапускаем NGINX:
```sh
nginx -t
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok<br>
nginx: configuration file /etc/nginx/nginx.conf test is successful<br>
```sh
nginx -s reload
```
Можно убедиться в доступности репозитория:
```sh
curl -a http://localhost/repo/
```
... -<br>
<a href="repodata/">repodata/</a>                                          30-Apr-2024 16:51                   -<br>
<a href="nginx-1.20.2-1.el8.ngx.x86_64.rpm">nginx-1.20.2-1.el8.ngx.x86_64.rpm</a>                  30-Apr-2024 16:51             2249516<br>
<a href="percona-orchestrator-3.2.6-2.el8.x86_64.rpm">percona-orchestrator-3.2.6-2.el8.x86_64.rpm</a>        16-Feb-2022 15:57             5222976<br>
...<br>
Добавим созданный репозиторий в `/etc/yum.repos.d`
```sh
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
```
Убедимся, что репозиторий подключился и посмотрим, что в нем есть:
```sh
yum repolist enabled | grep otus
```






