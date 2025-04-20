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

# Создаем виртуальнуюмашину web
VM_NAME="web"
yc compute instance create \
  --name $VM_NAME \
  --hostname $VM_NAME \
  --zone ru-central1-b \
  --network-interface subnet-name=default-ru-central1-b,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts \
  --memory 2G \
  --cores 2 \
  --core-fraction 5 \
  --preemptible \
  --ssh-key ~/.ssh/id_rsa.pub

EXTERNAL_IP=$(yc compute instance get $VM_NAME --format json | jq -r '.network_interfaces[].primary_v4_address.one_to_one_nat.address')

VM_NAME="log"
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
  --ssh-key ~/.ssh/id_rsa.pub

# Внесение изменений в инвентори
yq -i ".all.hosts.webserver.ansible_host = \"$EXTERNAL_IP\"" hw/inventory/hosts
yq -i '.all.hosts.logserver.ansible_ssh_common_args = "-o ProxyJump=yc-user@'"$EXTERNAL_IP"'"' hw/inventory/hosts
echo "Ожидание создания виртуальных машин..."
sleep 60
echo "Запуск ansible-playbook..."
ansible-playbook -i hw/inventory/hosts hw/playbook.yml
echo "Ansible-playbook завершен."
echo "Создано 2 виртуальные машины web и log в Yandex Cloud."
echo "Для удаленного доступа к виртуальной машине web используйте команду:"
echo "ssh yc-user@$EXTERNAL_IP"
echo "Для удаленного доступа к виртуальной машине log используйте команду:"
echo "ssh -J yc-user@$EXTERNAL_IP yc-user@log"