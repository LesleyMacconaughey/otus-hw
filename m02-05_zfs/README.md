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
