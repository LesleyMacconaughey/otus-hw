#!/bin/bash

#создаем NAT-шлюз
yc vpc gateway create --name nat-gateway --description "NAT Gateway"

# Настраиваем таблицу маршрутизации
yc vpc route-table create \
  --name nat-route \
  --network-name default \
  --route destination=0.0.0.0/0,gateway-id=$(yc vpc gateway get --name nat-gateway --format json | jq -r '.id')

# Применение таблицы маршрутов к подсети
yc vpc subnet update \
  --name default-ru-central1-b \
  --route-table-name nat-route

# Создаем виртуальнуюмашину backup_server
VM_NAME="backup-server"
yc compute instance create \
  --name $VM_NAME \
  --hostname $VM_NAME \
  --zone ru-central1-b \
  --network-interface subnet-name=default-ru-central1-b,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts \
  --create-disk size=2G,type=network-ssd,auto-delete=true \
  --memory 2G \
  --cores 2 \
  --core-fraction 5 \
  --preemptible \
  --metadata-from-file user-data=<(cat <<EOF
#cloud-config
users:
  - name: yc-user
    ssh-authorized-keys:
      - $(cat ~/.ssh/id_rsa.pub)
    groups: sudo
    shell: /bin/bash

packages:
  - borgbackup

runcmd:
  # Настройка sudo без пароля для пользователя yc-user
  - echo "yc-user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/yc-user-nopasswd
  - chmod 440 /etc/sudoers.d/yc-user-nopasswd
  
  # Настройка диска для бэкапов
  - mkfs.ext4 /dev/vdb
  - mkdir -p /var/backup
  - mount /dev/vdb /var/backup
  - echo "/dev/vdb /var/backup ext4 defaults 0 0" >> /etc/fstab
  
  # Создание пользователя для бэкапов
  - useradd -m -s /bin/bash borg
  - mkdir -p /home/borg/.ssh
  - touch /home/borg/.ssh/authorized_keys
  - chown -R borg:borg /home/borg/.ssh
  - chmod 700 /home/borg/.ssh
  - chmod 600 /home/borg/.ssh/authorized_keys
  - chown borg:borg /var/backup
EOF
)
EXTERNAL_IP=$(yc compute instance get $VM_NAME --format json | jq -r '.network_interfaces[].primary_v4_address.one_to_one_nat.address')

# Создаем виртуальнуюмашину client
VM_NAME="client"
yc compute instance create \
  --name $VM_NAME \
  --hostname $VM_NAME \
  --zone ru-central1-b \
  --network-interface subnet-name=default-ru-central1-b \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts \
  --memory 2G \
  --cores 2 \
  --core-fraction 5 \
  --preemptible \
  --metadata-from-file user-data=<(cat <<EOF
#cloud-config
users:
  - name: yc-user
    ssh-authorized-keys:
      - $(cat ~/.ssh/id_rsa.pub)
    groups: sudo
    shell: /bin/bash

packages:
  - borgbackup

runcmd:
  # Настройка sudo без пароля для пользователя yc-user
  - echo "yc-user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/yc-user-nopasswd
  - chmod 440 /etc/sudoers.d/yc-user-nopasswd
    
EOF
)

echo "Для удаленного доступа к виртуальной машине backup-server используйте команду:"
echo "ssh yc-user@$EXTERNAL_IP"
echo "Для удаленного доступа к виртуальной машине client используйте команду:"
echo "ssh -J yc-user@$EXTERNAL_IP yc-user@client"