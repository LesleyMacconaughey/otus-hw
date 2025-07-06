# Домашнее задание VPN
Цель домашнего задания:
- Создать домашнюю сетевую лабораторию. Научится настраивать VPN-сервер в Linux-based системах.

Описание домашнего задания:
- Настроить VPN между двумя ВМ в tun/tap режимах, замерить скорость в туннелях, сделать вывод об отличающихся показателях;
- Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на ВМ.

## Настройка тестового окружения

Для выоплнения задания создадим стенд из двух виртуальных машин `server` и `client`.

```sh
vagrant up
```
## TUN/TAP режимы VPN

Для настройки openvpn соединения `server`-`client` в режиме TAP запустим плейбук:

```sh
ansible-playbook provision-tap.yml
```

Замерим скорость с помощью утилиты `ipref3`.

На сервере запустим: 

```sh
iperf3 -s
```

На клиенте запустим

```sh
iperf3 -c 10.10.10.1 -t 40 -i 5
```

Скорость в режиме TAP
server
```sh
Accepted connection from 10.10.10.2, port 53658
[  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 53662
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec  2.06 MBytes  17.3 Mbits/sec                  
[  5]   1.00-2.00   sec  1.92 MBytes  16.1 Mbits/sec                  
[  5]   2.00-3.00   sec  2.59 MBytes  21.8 Mbits/sec                  
[  5]   3.00-4.00   sec  2.85 MBytes  23.9 Mbits/sec                  
[  5]   4.00-5.00   sec  4.04 MBytes  33.9 Mbits/sec                  
[  5]   5.00-6.00   sec  3.79 MBytes  31.8 Mbits/sec                  
[  5]   6.00-7.00   sec  3.65 MBytes  30.6 Mbits/sec                  
[  5]   7.00-8.00   sec  3.71 MBytes  31.1 Mbits/sec                  
[  5]   8.00-9.00   sec  1.62 MBytes  13.6 Mbits/sec                  
[  5]   9.00-10.00  sec   845 KBytes  6.92 Mbits/sec                  
[  5]  10.00-11.00  sec  2.89 MBytes  24.2 Mbits/sec                  
[  5]  11.00-12.00  sec  4.31 MBytes  36.2 Mbits/sec                  
[  5]  12.00-13.00  sec  3.60 MBytes  30.2 Mbits/sec                  
[  5]  13.00-14.00  sec  2.01 MBytes  16.9 Mbits/sec                  
[  5]  14.00-15.00  sec   802 KBytes  6.57 Mbits/sec                  
[  5]  15.00-16.00  sec   762 KBytes  6.25 Mbits/sec                  
[  5]  16.00-17.00  sec   817 KBytes  6.69 Mbits/sec                  
[  5]  17.00-18.00  sec   742 KBytes  6.08 Mbits/sec                  
[  5]  18.00-19.00  sec   853 KBytes  6.99 Mbits/sec                  
[  5]  19.00-20.00  sec   740 KBytes  6.07 Mbits/sec                  
[  5]  20.00-21.00  sec   712 KBytes  5.84 Mbits/sec                  
[  5]  21.00-22.00  sec  2.40 MBytes  20.1 Mbits/sec                  
[  5]  22.00-23.00  sec  2.09 MBytes  17.6 Mbits/sec                  
[  5]  23.00-24.00  sec  2.97 MBytes  24.9 Mbits/sec                  
[  5]  24.00-25.00  sec  3.68 MBytes  30.9 Mbits/sec                  
[  5]  25.00-26.00  sec  3.76 MBytes  31.5 Mbits/sec                  
[  5]  26.00-27.00  sec  4.00 MBytes  33.5 Mbits/sec                  
[  5]  27.00-28.00  sec  3.46 MBytes  29.1 Mbits/sec                  
[  5]  28.00-29.00  sec  3.88 MBytes  32.6 Mbits/sec                  
[  5]  29.00-30.00  sec  3.43 MBytes  28.8 Mbits/sec                  
[  5]  30.00-31.00  sec  3.77 MBytes  31.6 Mbits/sec                  
[  5]  31.00-32.00  sec  4.16 MBytes  34.8 Mbits/sec                  
[  5]  32.00-33.00  sec  3.80 MBytes  31.9 Mbits/sec                  
[  5]  33.00-34.00  sec  3.89 MBytes  32.6 Mbits/sec                  
[  5]  34.00-35.00  sec  2.36 MBytes  19.8 Mbits/sec                  
[  5]  35.00-36.00  sec  1.64 MBytes  13.7 Mbits/sec                  
[  5]  36.00-37.00  sec   681 KBytes  5.58 Mbits/sec                  
[  5]  37.00-38.00  sec  1.27 MBytes  10.6 Mbits/sec                  
[  5]  38.00-39.00  sec  3.38 MBytes  28.3 Mbits/sec                  
[  5]  39.00-40.00  sec  1.26 MBytes  10.6 Mbits/sec                  
[  5]  40.00-40.17  sec   765 KBytes  36.4 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-40.17  sec   102 MBytes  21.3 Mbits/sec                  receiver
```

client

```sh
Connecting to host 10.10.10.1, port 5201
[  5] local 10.10.10.2 port 53662 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-5.00   sec  14.6 MBytes  24.5 Mbits/sec    0    757 KBytes       
[  5]   5.00-10.00  sec  14.8 MBytes  24.9 Mbits/sec    4   1023 KBytes       
[  5]  10.00-15.00  sec  13.8 MBytes  23.1 Mbits/sec  388    329 KBytes       
[  5]  15.00-20.00  sec  5.00 MBytes  8.39 Mbits/sec    0    344 KBytes       
[  5]  20.00-25.00  sec  11.2 MBytes  18.9 Mbits/sec   94    360 KBytes       
[  5]  25.00-30.00  sec  18.8 MBytes  31.5 Mbits/sec    0    375 KBytes       
[  5]  30.00-35.00  sec  17.5 MBytes  29.4 Mbits/sec    0    561 KBytes       
[  5]  35.00-40.00  sec  7.50 MBytes  12.6 Mbits/sec    0   1.14 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-40.00  sec   103 MBytes  21.6 Mbits/sec  486             sender
[  5]   0.00-40.17  sec   102 MBytes  21.3 Mbits/sec                  receiver
```

Для настройки openvpn соединения `server`-`client` в режиме TUN запустим плейбук:

```sh
ansible-playbook provision-tun.yml
```

Замерим скорость с помощью утилиты `ipref3`.

Скорость в режиме TUN

server

```sh
[  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 60542
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec   944 KBytes  7.73 Mbits/sec                  
[  5]   1.00-2.00   sec  1.08 MBytes  9.07 Mbits/sec                  
[  5]   2.00-3.00   sec   926 KBytes  7.59 Mbits/sec                  
[  5]   3.00-4.00   sec  2.45 MBytes  20.6 Mbits/sec                  
[  5]   4.00-5.00   sec  2.50 MBytes  20.9 Mbits/sec                  
[  5]   5.00-6.00   sec  2.33 MBytes  19.6 Mbits/sec                  
[  5]   6.00-7.00   sec  2.76 MBytes  23.1 Mbits/sec                  
[  5]   7.00-8.00   sec  2.70 MBytes  22.7 Mbits/sec                  
[  5]   8.00-9.00   sec  2.71 MBytes  22.7 Mbits/sec                  
[  5]   9.00-10.00  sec  2.74 MBytes  23.0 Mbits/sec                  
[  5]  10.00-11.00  sec  3.04 MBytes  25.5 Mbits/sec                  
[  5]  11.00-12.00  sec  3.03 MBytes  25.4 Mbits/sec                  
[  5]  12.00-13.00  sec  2.82 MBytes  23.6 Mbits/sec                  
[  5]  13.00-14.00  sec  2.31 MBytes  19.4 Mbits/sec                  
[  5]  14.00-15.00  sec  2.93 MBytes  24.6 Mbits/sec                  
[  5]  15.00-16.00  sec  2.39 MBytes  20.1 Mbits/sec                  
[  5]  16.00-17.00  sec  2.87 MBytes  24.0 Mbits/sec                  
[  5]  17.00-18.00  sec  2.56 MBytes  21.5 Mbits/sec                  
[  5]  18.00-19.00  sec  2.36 MBytes  19.8 Mbits/sec                  
[  5]  19.00-20.00  sec  2.24 MBytes  18.8 Mbits/sec                  
[  5]  20.00-21.00  sec  2.85 MBytes  23.9 Mbits/sec                  
[  5]  21.00-22.00  sec  2.58 MBytes  21.6 Mbits/sec                  
[  5]  22.00-23.00  sec  2.93 MBytes  24.7 Mbits/sec                  
[  5]  23.00-24.00  sec  3.11 MBytes  26.1 Mbits/sec                  
[  5]  24.00-25.00  sec  3.05 MBytes  25.6 Mbits/sec                  
[  5]  25.00-26.00  sec  3.20 MBytes  26.8 Mbits/sec                  
[  5]  26.00-27.00  sec  2.32 MBytes  19.4 Mbits/sec                  
[  5]  27.00-28.00  sec  2.36 MBytes  19.8 Mbits/sec                  
[  5]  28.00-29.00  sec  3.15 MBytes  26.5 Mbits/sec                  
[  5]  29.00-30.00  sec  2.97 MBytes  24.9 Mbits/sec                  
[  5]  30.00-31.00  sec  3.16 MBytes  26.5 Mbits/sec                  
[  5]  31.00-32.00  sec  2.81 MBytes  23.6 Mbits/sec                  
[  5]  32.00-33.00  sec  2.70 MBytes  22.7 Mbits/sec                  
[  5]  33.00-34.00  sec  2.10 MBytes  17.6 Mbits/sec                  
[  5]  34.00-35.00  sec  2.84 MBytes  23.8 Mbits/sec                  
[  5]  35.00-36.00  sec  1.53 MBytes  12.8 Mbits/sec                  
[  5]  36.00-37.01  sec  1.21 MBytes  10.1 Mbits/sec                  
[  5]  37.01-38.00  sec  1.80 MBytes  15.1 Mbits/sec                  
[  5]  38.00-39.00  sec  2.11 MBytes  17.7 Mbits/sec                  
[  5]  39.00-40.00  sec  1.46 MBytes  12.2 Mbits/sec                  
[  5]  40.00-40.14  sec   159 KBytes  9.28 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-40.14  sec  98.0 MBytes  20.5 Mbits/sec                  receiver
```

client

```sh
Connecting to host 10.10.10.1, port 5201
[  5] local 10.10.10.2 port 60542 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-5.00   sec  8.75 MBytes  14.7 Mbits/sec    0    453 KBytes       
[  5]   5.00-10.00  sec  14.0 MBytes  23.5 Mbits/sec  264    657 KBytes       
[  5]  10.00-15.00  sec  14.7 MBytes  24.7 Mbits/sec  301    392 KBytes       
[  5]  15.00-20.00  sec  12.2 MBytes  20.5 Mbits/sec  247    143 KBytes       
[  5]  20.00-25.00  sec  14.7 MBytes  24.7 Mbits/sec    0    199 KBytes       
[  5]  25.00-30.00  sec  13.8 MBytes  23.2 Mbits/sec   50    160 KBytes       
[  5]  30.00-35.00  sec  13.9 MBytes  23.3 Mbits/sec   69    123 KBytes       
[  5]  35.00-40.00  sec  7.78 MBytes  13.0 Mbits/sec    9    138 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-40.00  sec  99.9 MBytes  20.9 Mbits/sec  940             sender
[  5]   0.00-40.14  sec  98.0 MBytes  20.5 Mbits/sec                  receiver

iperf Done.
```

Можно следать вывод, что режим `TAP` немного быстрее, чем `TUN`, но несущественно.

## RAS на базе OpenVPN

Пересоздаем стенд (достаточно одной ВМ) и дальше настраиваем из консоли.

**Устанавливаем необходимые пакеты**

```sh
sudo apt update && sudo apt install openvpn easy-rsa
```

Далее настраиваем из под `root`

```sh
sudo -i
```

**Переходим в директорию /etc/openvpn и инициализируем PKI**

```sh
cd /etc/openvpn && /usr/share/easy-rsa/easyrsa init-pki
```

**Генерируем необходимые ключи и сертификаты для сервера**

```sh
echo 'rasvpn' | /usr/share/easy-rsa/easyrsa gen-req server nopass
echo 'yes' | /usr/share/easy-rsa/easyrsa sign-req server server 
/usr/share/easy-rsa/easyrsa gen-dh
openvpn --genkey secret ca.key
```

**Генерируем необходимые ключи и сертификаты для клиента**

```sh
echo 'client' | /usr/share/easy-rsa/easyrsa gen-req client nopass
echo 'yes' | /usr/share/easy-rsa/easyrsa sign-req client client
```

**Создаем конфигурационный файл сервера**

```sh
vim /etc/openvpn/server.conf
```

**Зададим параметр iroute для клиента**

```sh
echo 'iroute 10.10.10.0 255.255.255.0' > /etc/openvpn/client/client
```

**Содержимое файла server.conf**

```sh
port 1207 
proto udp 
dev tun 
ca /etc/openvpn/pki/ca.crt 
cert /etc/openvpn/pki/issued/server.crt 
key /etc/openvpn/pki/private/server.key 
dh /etc/openvpn/pki/dh.pem 
server 10.10.10.0 255.255.255.0 
ifconfig-pool-persist ipp.txt 
client-to-client 
client-config-dir /etc/openvpn/client 
keepalive 10 120 
comp-lzo 
persist-key 
persist-tun 
status /var/log/openvpn-status.log 
log /var/log/openvpn.log 
verb 3
```

**Запускаем сервис**

```sh
systemctl start openvpn@server
systemctl enable openvpn@server
```

На хост-машине: 

Создаем файл client.conf со следующим содержимым: 
```sh
dev tun 
proto udp 
remote 192.168.56.10 1207 
client 
resolv-retry infinite 
remote-cert-tls server 
ca ./ca.crt 
cert ./client.crt 
key ./client.key 
route 192.168.56.0 255.255.255.0 
persist-key 
persist-tun 
comp-lzo 
verb 3 
```

Копируем в одну директорию с client.conf файлы с сервера (с помощью `scp`)

```sh
/etc/openvpn/pki/ca.crt 
/etc/openvpn/pki/issued/client.crt 
/etc/openvpn/pki/private/client.key
```
Проверяем подключение:

```sh
openvpn --config client.conf
```

Проверяем сетевую связанность: 

```sh
ping -c 4 10.10.10.1
```
