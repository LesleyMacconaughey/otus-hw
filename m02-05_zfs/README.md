# Практические навыки работы c ZFS
## Определение алгоритма с наилучшим сжатием
Смотрим список всех дисков, которые есть в виртуальной машине
```sh
lsblk
```
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT<br>
sda      8:0    0   40G  0 disk <br>
`-sda1   8:1    0   40G  0 part /<br>
sdb      8:16   0  512M  0 disk <br>
sdc      8:32   0  512M  0 disk <br>
sdd      8:48   0  512M  0 disk <br>
sde      8:64   0  512M  0 disk <br>
sdf      8:80   0  512M  0 disk <br>
sdg      8:96   0  512M  0 disk <br>
sdh      8:112  0  512M  0 disk <br>
sdi      8:128  0  512M  0 disk <br>
Создаём пул из двух дисков в режиме RAID 1
```sh
zpool create otus1 mirror /dev/sdb /dev/sdc
```
и еще три пула
```sh
zpool create otus2 mirror /dev/sdd /dev/sde; \
zpool create otus3 mirror /dev/sdf /dev/sdg; \
zpool create otus4 mirror /dev/sdh /dev/sdi
```
Смотрим информацию о пулах
```
zpool list
```
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT<br>
otus1   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -<br>
otus2   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -<br>
otus3   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -<br>
otus4   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -<br>
<br>Команда zpool status показывает информацию о каждом диске, состоянии сканирования и об ошибках чтения, записи и совпадения хэш-сумм
```sh
zpool status
```
<br>Команда zpool list показывает информацию о размере пула, количеству занятого и свободного места, дедупликации и т.д.
```sh
zpool list
```
Для получения большего объема информации можно использовать
```sh
zfs get all
```
<br>Добавим разные алгоритмы сжатия в каждую файловую систему:<br>
Алгоритм lzjb: 
```sh
zfs set compression=lzjb otus1
```
Алгоритм lz4:
```sh
zfs set compression=lz4 otus2
```
Алгоритм gzip:
```sh
zfs set compression=gzip-9 otus3
```
Алгоритм zle:
```sh
zfs set compression=zle otus4
```
Проверим, что все файловые системы имеют разные методы сжатия
```sh
zfs get all | grep compression
```
otus1  compression           lzjb                   local<br>
otus2  compression           lz4                    local<br>
otus3  compression           gzip-9                 local<br>
otus4  compression           zle                    local<br>
Сжатие файлов будет работать только с файлами, которые были добавлены после включение настройки сжатия. 
Скачаем один и тот же текстовый файл во все пулы: 
```sh
for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
```
Проверим, что файл был скачан во все пулы:
```sh
ls -l /otus*
```
/otus1:<br>
total 22075<br>
-rw-r--r--. 1 root root 41034307 Apr  2 07:54 pg2600.converter.log<br>
<br>
/otus2:<br>
total 17997<br>
-rw-r--r--. 1 root root 41034307 Apr  2 07:54 pg2600.converter.log<br>
<br>
/otus3:<br>
total 10961<br>
-rw-r--r--. 1 root root 41034307 Apr  2 07:54 pg2600.converter.log<br>
<br>
/otus4:<br>
total 40100<br>
-rw-r--r--. 1 root root 41034307 Apr  2 07:54 pg2600.converter.log<br>
Проверим, сколько места занимает один и тот же файл в разных пулах и проверим степень сжатия файлов:
```sh
zfs list
```
NAME    USED  AVAIL     REFER  MOUNTPOINT<br>
otus1  21.7M   330M     21.6M  /otus1<br>
otus2  17.7M   334M     17.6M  /otus2<br>
otus3  10.8M   341M     10.7M  /otus3<br>
otus4  39.3M   313M     39.2M  /otus4<br>
```sh
zfs get all | grep compressratio | grep -v ref
```
otus1  compressratio         1.82x                  -<br>
otus2  compressratio         2.23x                  -<br>
otus3  compressratio         3.66x                  -<br>
otus4  compressratio         1.00x                  -<br>
Из проделанных экспериментов следует, что алгоритм gzip-9 самый эффективный по сжатию.
## Определение настроек пула








<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>




Что нужно сделать?

Определить алгоритм с наилучшим сжатием:
Определить какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);
создать 4 файловых системы на каждой применить свой алгоритм сжатия;
для сжатия использовать либо текстовый файл, либо группу файлов.
Определить настройки пула.
С помощью команды zfs import собрать pool ZFS.
Командами zfs определить настройки:
   
- размер хранилища;
    
- тип pool;
    
- значение recordsize;
   
- какое сжатие используется;
   
- какая контрольная сумма используется.
Работа со снапшотами:
скопировать файл из удаленной директории;
восстановить файл локально. zfs receive;
найти зашифрованное сообщение в файле secret_message.
