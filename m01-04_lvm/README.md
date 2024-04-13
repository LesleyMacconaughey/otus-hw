# Задание 4. работа с lvm

## Уменьшить том под / до 8G

Установим пакет xfsdump - он будет необходим для снятия копии тома.
```sh
yum update && yum install xfsdump
```
Complete!

Посмотрим, какие есть в распоряжении блочные устройства
```sh
lsblk
```
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk
├─sda1                    8:1    0    1M  0 part
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk
sdc                       8:32   0    2G  0 disk
sdd                       8:48   0    1G  0 disk
sde                       8:64   0    1G  0 disk

выделить том под /home
выделить том под /var (/var - сделать в mirror)
для /home - сделать том для снэпшотов
прописать монтирование в fstab (попробовать с разными опциями и разными файловыми системами на выбор)
Работа со снапшотами:
сгенерировать файлы в /home/
снять снэпшот
удалить часть файлов
восстановиться со снэпшота