# Проектная работа

Веб проект с развертыванием нескольких виртуальных машин должен отвечать следующим требованиям:

- включен https;
- основная инфраструктура в DMZ зоне;
- файрволл на входе;
- сбор метрик и настроенный алертинг;
- везде включен selinux;
- организован централизованный сбор логов;
- организован backup.

## Настройка инженерной станции
Через web интерфейс гипервизора создадим виртуальную машину 2000 со статическим адресом 192.168.90.14/28

Настроим сеть через netplan

```sh
sudo bash -c 'cat > /etc/netplan/10-ens19.yaml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ens19:
      dhcp4: true             # DHCP IPv4
      dhcp6: false            # Отключить DHCP IPv6
      addresses:              # Статический IP
        - 192.168.90.14/28
      optional: true          # Не ждём поднятия интерфейса при загрузке
EOF'
```


## Настройка гипервизора
В качестве гипервизора виртуальных машин будем использовать Proxmox Virtual Environment

Для обеспечения возможности управлять гипервизором с инженерной станции создадим пользователя ansible на Proxmox и настроим SSH-доступ с возможностью выполнения команд от root (через sudo)

На proxmox сохдадим пользователя
```sh
adduser ansible
```

На инженерной станции (откуда будем подключаться) создадим ssh ключ
```
ssh-keygen -t ed25519 -C "ansible@eng"
```
Вручную добавим ключ на сервер Proxmox в ~/.ssh/authorized_keys:
```sh
mkdir -p /home/ansible/.ssh
echo "публичный_ключ" >> /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
```
Дадим пользователю права на выполнение любых команд от root без ввода пароля:
```sh
echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/ansible
sudo chmod 440 /etc/sudoers.d/ansible
```

Для работы будем использовать две сети
- внешняя сеть bridge proxmox куда будет смотреть веб сервер (80,443 порты)
- NAT сеть с помощью которой машины будут выходить в интернет, она же будет внутренняя сеть для обмена между вм и работы с инженерной станцией (192.168.90.0/28 - сеть на 14 хостов)

Для NAT сети будем использовать встроенный функционал Proxmox Software-Defined Network (SDN)

В GUI Proxmox, в разделе Datacenter ⇨ SDN ⇨ Zones. Добавляем новую зону типа Simple. Идём в Vnets, добавляем новую сеть, например `otus`. Имя этой сети будет задавать имя сетевого бриджа, который будет создан в системе. Выбираем созданную сеть и добавляем к ней подсеть. Например, 192.168.90.0/28, шлюз 192.168.90.1, в SNAT ставим галочку. После внесения настроек, возвращанмся в раздел SDN и нажимайте на кнопку Apply, чтобы изменения применились.

В качестве операционной системы для проекта выберем Debian 12. Проведем установку Debian на вновь созданную виртуальную машину и сделаем ее шаблоном, чтобы с помощью копирования быстро содать необходимое количество ВМ.

После установки операционной системы остановим ВМ и добавим образ cloud-init
```sh
qm set 9000 --ide2 local-lvm:cloudinit
```
После чего завершим создание шаблона ВМ

```sh
qm template 9000
```

Если выберем вариант создания вм из готового образа cloud-init, то шаги следующие:
Скачайте образ (например, debian-12-genericcloud-amd64.qcow2):
```sh
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2
```
Создайте ВМ и импортируйте образ:
```sh
qm create 9000 --name debian-12-cloud --memory 2048 --cores 2 --net0 virtio,bridge=otus
qm importdisk 9000 debian-12-genericcloud-amd64.qcow2 local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm resize 9000 scsi0 10G

```
Через веб интерфейс настроим пользователя ansible и ssh ключ инженерной станции. 
создадим шаблон
```sh
qm template 9000
```

Склонируем шаблон
```sh
qm clone 9000 102 --name web-proxy --full
```

Настроим ip адрес для вм
```sh
qm set 102 --ipconfig0 ip=192.168.90.2/28,gw=192.168.90.1
```

Запускаем вм

```sh
qm start 102
```

Чтобы остановить и удалить
 ```sh
 qm stop 102 --skiplock && qm destroy 102 --destroy-unreferenced-disks --purge
 ```



qm set 9000 --ciuser ansible --sshkeys ~/.ssh/id_ed25519.pub


Можно настроить cloud-init перед запуском ВМ через веб интерфейс или с помощью комманд
```sh
qm set <VMID> --ciuser admin
qm set <VMID> --cipassword "secure_password"
qm set <VMID> --sshkeys ~/.ssh/id_rsa.pub
qm set <VMID> --ipconfig0 ip=dhcp
# или статический IP:
qm set <VMID> --ipconfig0 ip=192.168.1.100/24,gw=192.168.1.1
```

Мы это сделаем с помощью файла user-data. Включаем возможность хранения snippets через веб интерфейс Proxmox разделы Datacenter/Storage. Создаем файл user-data.yaml (например, в /var/lib/vz/snippets/web-proxy.yaml):
```yaml
#cloud-config
users:
  - name: ansible
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2E...  # публичный SSH-ключ пользователя ansible
package_update: true
package_upgrade: true
packages:
  - sudo
  - python3
  - qemu-guest-agent
runcmd:
  - systemctl enable --now qemu-guest-agent
  - sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
  - sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  - systemctl restart ssh
  - |
  cat > /etc/netplan/50-cloud-init.yaml <<EOF
  network:
    version: 2
    ethernets:
      eth0:
        dhcp4: no
        addresses: [192.168.90.2/28]
        gateway4: 192.168.90.1
        nameservers:
          addresses: [8.8.8.8, 8.8.4.4]
  EOF
  - netplan apply
```

Развертываем новую ВМ из шаблона
```sh
qm clone 9000 102 --name "web-proxy" --full
```
Применяем конфиг user-data:
```sh
qm set 102 --cicustom "user=local:snippets/web-proxy.yaml"
```
Запускаем ВМ
```sh
qm start 102
```

Создадим необходимые ВМ с соответствующим функционалом а также присвоим им фиксированные ip адреса во внутренней сети:
- web-proxy (angie) 192.168.90.2/28
- web-01 (app) 192.168.90.3/28
- db-01 (master) 192.168.90.4/28
- db-02 (replica) 192.168.90.5/28
- log-srv 192.168.90.6/28
- backup-srv 192.168.90.7/28
- monitoring-srv 192.168.90.8/28

Для удобства добавить в /etc/hosts
192.168.90.2 web-proxy
192.168.90.3 web-01
192.168.90.4 db-01
192.168.90.5 db-02
192.168.90.6 log-srv
192.168.90.7 backup-srv
192.168.90.8 monitoring-srv


## Настройка web-01 (app) 192.168.90.3/28


