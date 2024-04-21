# Практические навыки работы c ZFS
---
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
Из проделанных экспериментов следует, что алгоритм gzip-9 самый эффективный по сжатию.<br>

---
## Определение настроек пула
Скачиваем архив в домашний каталог: 
```bash
wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
```
Saving to: 'archive.tar.gz'<br>
100%[=======================================================================>] 7,275,140   3.60MB/s   in 1.9s   <br>
2024-04-21 13:04:18 (3.60 MB/s) - 'archive.tar.gz' saved [7275140/7275140]<br>
Разархивируем его:
```bash
tar -xzvf archive.tar.gz
```
zpoolexport/<br>
zpoolexport/filea<br>
zpoolexport/fileb<br>
Проверим, возможно ли импортировать данный каталог в пул:
```bash
zpool import -d zpoolexport/
```
   pool: otus<br>
     id: 6554193320433390805<br>
  state: ONLINE<br>
 action: The pool can be imported using its name or numeric identifier.<br>
 config:<br>
<br>
        otus                          ONLINE<br>
          mirror-0                    ONLINE<br>
            /otus1/zpoolexport/filea  ONLINE<br>
            /otus1/zpoolexport/fileb  ONLINE<br>
Данный вывод показывает нам имя пула, тип raid и его состав. <br>
Сделаем импорт данного пула к нам в ОС:<br>
```bash
zpool import -d zpoolexport/ otus
```
```bash
zpool status
```
  pool: otus<br>
 state: ONLINE<br>
  scan: none requested<br>
config:<br>
<br>
        NAME                          STATE     READ WRITE CKSUM<br>
        otus                          ONLINE       0     0     0<br>
          mirror-0                    ONLINE       0     0     0<br>
            /otus1/zpoolexport/filea  ONLINE       0     0     0<br>
            /otus1/zpoolexport/fileb  ONLINE       0     0     0<br>
<br>
errors: No known data errors<br>
Команда `zpool status` выдаст нам информацию о составе импортированного пула.<br>
Если у Вас уже есть пул с именем otus, то можно поменять его имя во время импорта: `zpool import -d zpoolexport/ otus newotus`<br>
Далее нам нужно определить настройки: `zpool get all otus`<br>
Запрос сразу всех параметром файловой системы: `zfs get all otus`<br>
```bash
zfs get all otus
```
Размер: `zfs get available otus`<br>
```bash
zfs get available otus
```
NAME  PROPERTY   VALUE  SOURCE<br>
otus  available  350M   -<br>
Тип: `zfs get readonly otus`
```bash
zfs get readonly otus
```
NAME  PROPERTY  VALUE   SOURCE<br>
otus  readonly  off     default<br>
По типу FS мы можем понять, что позволяет выполнять чтение и запись<br>
Значение recordsize: `zfs get recordsize otus`<br>
```bash
zfs get recordsize otus
```
NAME  PROPERTY    VALUE    SOURCE<br>
otus  recordsize  128K     local<br>
Тип сжатия (или параметр отключения): `zfs get compression otus`
```bash
zfs get compression otus
```
NAME  PROPERTY     VALUE     SOURCE<br>
otus  compression  zle       local<br>
Тип контрольной суммы: `zfs get checksum otus`
```bash
zfs get checksum otus
```
NAME  PROPERTY  VALUE      SOURCE<br>
otus  checksum  sha256     local<br>

---
## Работа со снапшотом, поиск сообщения от преподавателя
Скачаем файл, указанный в задании:
```bash
wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download
```
Saving to: 'otus_task2.file'<br>
100%[=======================================================================>] 5,432,736   2.52MB/s   in 2.1s   <br>
2024-04-21 13:18:07 (2.52 MB/s) - 'otus_task2.file' saved [5432736/5432736]<br>
Восстановим файловую систему из снапшота:
```bash
zfs receive otus/test@today < otus_task2.file
```
[1]+  Done                    wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI <br>
Далее, ищем в каталоге /otus/test файл с именем “secret_message”:
```bash
find /otus/test -name "secret_message"
```
/otus/test/task1/file_mess/secret_message<br>
Смотрим содержимое найденного файла:
```bash
cat /otus/test/task1/file_mess/secret_message
```
https://otus.ru/lessons/linux-hl/<br>
Инфраструктура высоконагруженных систем<br>
Продвинутый практический курс по инфраструктуре высоконагруженных и кластеризированных систем<br>
