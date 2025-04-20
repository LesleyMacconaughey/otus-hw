#!/bin/bash

# Удаление ВМ
yc compute instance delete backup-server
yc compute instance delete client

# Отвязка таблицы маршрутизации от подсети
yc vpc subnet update \
  --name default-ru-central1-b \
  --route-table-name ""

# Удаление таблиц маршрутизации
route_table_ids=$(yc vpc route-table list --format json | jq -r '.[] | select(.name == "nat-route") | .id')

if [ -z "$route_table_ids" ]; then
    echo "Таблиц маршрутизации с именем 'nat-route' не найдено."
else
    # Удаление каждой найденной таблицы
    for id in $route_table_ids; do
        echo "Удаление таблицы маршрутизации с ID: $id"
        yc vpc route-table delete $id
    done
fi

# Удаление NAT-шлюзов
gateway_ids=$(yc vpc gateway list --format json | jq -r '.[] | select(.name == "nat-gateway") | .id')

if [ -z "$gateway_ids" ]; then
    echo "Шлюзов с именем 'nat-gateway' не найдено."
else
    # Удаление каждого найденного шлюза
    for id in $gateway_ids; do
        echo "Удаление шлюза с ID: $id"
        yc vpc gateway delete $id
    done
fi

echo "Все компоненты инфраструктуры успешно удалены."