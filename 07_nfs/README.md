# Vagrant стенд для NFS
Цель:
Развернуть сервис NFS и подключить к нему клиента.

---
## Создание стенда
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
## Настройка сервера
Заходим на сервер
```bash
vagrant ssh nfss
```
Переходим в root
```bash
sudo su
```
Установим утилиты для отладки
```bash
yum install -y nfs-utils
```
Включаем firewall
```bash
systemctl enable firewalld --now; systemctl status firewalld
```
Разрешаем в firewall доступ к сервисам NFS
```bash
firewall-cmd --add-service="nfs3" \
             --add-service="rpc-bind" \
             --add-service="mountd" \
             --permanent & firewall-cmd --reload
```
Запускаем сервер NFS
```bash
systemctl enable nfs --now
```
Проверяем наличие слушаемых портов 2049/udp, 2049/tcp, 20048/udp, 20048/tcp, 111/udp, 111/tcp
```bash
ss -tnplu
```
Cоздаём и настраиваем директорию, которая будет экспортирована в будущем
```bash
mkdir -p /srv/share/upload & \
chown -R nfsnobody:nfsnobody /srv/share & \
chmod 0777 /srv/share/upload
```
Cоздаём в файле `/etc/exports` структуру, которая позволит экспортировать ранее созданную директорию
```bash
cat << EOF > /etc/exports
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF
```
Экспортируем ранее созданную директорию
```bash
exportfs -r
```
Проверяем экспортированную директорию командой
```bash
exportfs -s
```
## Настройка клиента
Заходим на сервер
```bash
vagrant ssh nfsс
```
Переходим в root
```bash
sudo su
```
Установим утилиты для отладки
```bash
yum install -y nfs-utils
```
Включаем firewall
```bash
systemctl enable firewalld --now; systemctl status firewalld
```
Добавляем в `/etc/fstab` строку
```bash
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
```
и выполняем
```bash
systemctl daemon-reload; systemctl restart remote-fs.target
```
В данном случае происходит автоматическая генерация systemd units в каталоге `/run/systemd/generator/`, которые производят монтирование при первом обращении к каталогу `/mnt/`.<br>
Заходим в директорию `/mnt/` и проверяем успешность монтирования
```bash
mount | grep mnt
```
## Автоматическая настройка NFS при создании ВМ
Добавим в Vagrantfile строки запуска скриптов `nfss.vm.provision "shell", path: "nfss_script.sh"`, `nfsc.vm.provision "shell", path: "nfsc_script.sh"` и создадим сами скрипты.
Cоздадим ВМ.
```bash
vagrant up
```
Зайдем на машину клиент и убедимся, что NFS смонтирована
```
vagrant ssh nfsc
```
```bash
ls -l /mnt
```
В случае успеха увидим папку `upload`.
