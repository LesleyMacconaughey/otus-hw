# YC работа с сетями

## Удаляем все подсети с лейблом hw=otus
```bash
echo "Удаление подсетей..."
SUBNET_IDS=$(yc vpc network list-subnets --name otus-hw --format json | jq -r '.[].id')
for SUBNET_ID in $SUBNET_IDS; do
    yc vpc subnet delete $SUBNET_ID
done
```
# Удаляем сеть с лейблом hw=otus
```bash
echo "Удаление сети..."
yc vpc network delete --name=otus-hw

echo "Все ресурсы удалены."
```


## Создание сетей и подсетей
```bash
ZONE="ru-central1-b" # Зона, в которой будут созданы ресурсы 

yc vpc network create --name otus-hw \
  --description "Сеть для домашнего задания" \
  --labels hw=otus

## используем подсети с маской /28 (минимальная допустимая в YC) вместо /30, чтобы обеспечить совместимость.
yc vpc subnet create --name transit \
  --network-name otus-hw \
  --range 192.168.255.0/28 \
  --zone $ZONE \
  --description "Подсеть для транзита интернета" \
  --labels hw=otus

# Создаем CentralRouter с тремя интерфейсами
yc compute instance create CentralRouter \
  --zone ru-central1-c \
  --network-interface subnet-name=transit-subnet,ipv4-address=192.168.255.2 \
  --network-interface subnet-name=central-directors,ipv4-address=192.168.0.1 \
  --network-interface subnet-name=central-hardware,ipv4-address=192.168.0.33 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts \
  --ssh-key ~/.ssh/id_rsa.pub
```