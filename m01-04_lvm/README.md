# Задание 4. работа с lvm

## Уменьшить том под / до 8G

Установим пакет xfsdump - он будет необходим для снятия копии тома.
```sh
yum install -y xfsdump
```
Complete!

Посмотрим, какие есть в распоряжении блочные устройства
```sh
lsblk
```
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT<br> 
sda                       8:0    0   40G  0 disk<br> 
├─sda1                    8:1    0    1M  0 part<br> 
├─sda2                    8:2    0    1G  0 part /boot<br> 
└─sda3                    8:3    0   39G  0 part<br> 
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /<br> 
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]<br> 
sdb                       8:16   0   10G  0 disk<br> 
sdc                       8:32   0    2G  0 disk<br> 
sdd                       8:48   0    1G  0 disk<br> 
sde                       8:64   0    1G  0 disk<br> 
Будем использовать диск sdb <br>  
Подготовим временный том для / раздела:
```sh
pvcreate /dev/sdb
```
Physical volume "/dev/sdb" successfully created.<br> 
```sh
vgcreate temp_root /dev/sdb
```
  Volume group "temp_root" successfully created
```
lvcreate -n lv_root -l +100%FREE /dev/temp_root
```
  Logical volume "lv_root" created.<br> 
Создадим на нем файловую систему и смонтируем его
```
mkfs.xfs /dev/temp_root/lv_root
```
meta-data=/dev/temp_root/lv_root isize=512    agcount=4, agsize=655104 blks<br> 
         =                       sectsz=512   attr=2, projid32bit=1<br> 
         =                       crc=1        finobt=0, sparse=0<br> 
data     =                       bsize=4096   blocks=2620416, imaxpct=25<br> 
         =                       sunit=0      swidth=0 blks<br> 
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1<br> 
log      =internal log           bsize=4096   blocks=2560, version=2<br> 
         =                       sectsz=512   sunit=0 blks, lazy-count=1<br> 
realtime =none                   extsz=4096   blocks=0, rtextents=0<br> 
```
mount /dev/temp_root/lv_root /mnt/
```
Копируем все данные с / раздела в /mnt
```sh
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
```
xfsrestore: Restore Status: SUCCESS<br>
Проверить что скопировалось можно командой ls /mnt.
Сконфигурируем grub для того, чтобы при старте перейти в новый /.<br>
Сымитируем текущий root, сделаем в него chroot и обновим grub:
```sh
for i in /proc/ /sys/ /dev/ /run/ /boot/; \
do mount --bind $i /mnt/$i; done
```
```sh
chroot /mnt/
```
```sh
grub2-mkconfig -o /boot/grub2/grub.cfg
```
Found linux image: /boot/vmlinuz-3.10.0-1160.114.2.el7.x86_64<br>
Found initrd image: /boot/initramfs-3.10.0-1160.114.2.el7.x86_64.img<br>
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64<br>
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img<br>
done<br>
Обновим образ initrd<br>
```sh
cd /boot ; for i in `ls initramfs-*img`; \
do dracut -v $i `echo $i|sed "s/initramfs-//g; \
> s/.img//g"` --force; done
```
...<br>
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***<br>
Для того, чтобы при загрузке был смонтирован нужный root в файле
/boot/grub2/grub.cfg заменить rd.lvm.lv=VolGroup00/LogVol00 на rd.lvm.lv=temp_root/lv_root
```sh
vi /boot/grub2/grub.cfg
```
Убедимся
```sh
lsblk
```
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT<br>
sda                       8:0    0   40G  0 disk<br>
├─sda1                    8:1    0    1M  0 part<br>
├─sda2                    8:2    0    1G  0 part /boot<br>
└─sda3                    8:3    0   39G  0 part<br>
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm<br>
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]<br>
sdb                       8:16   0   10G  0 disk<br>
└─temp_root-lv_root     253:2    0   10G  0 lvm  /<br>
sdc                       8:32   0    2G  0 disk<br>
sdd                       8:48   0    1G  0 disk<br>
sde                       8:64   0    1G  0 disk<br>
Изменим размер старой VG и вернем на него рут. Для этого удаляем старый LV размером в 40G и создаём новый на 8G:
```sh
lvremove /dev/VolGroup00/LogVol00
```


## Выделить том под /home
выделить том под /var (/var - сделать в mirror)
для /home - сделать том для снэпшотов
прописать монтирование в fstab (попробовать с разными опциями и разными файловыми системами на выбор)
Работа со снапшотами:
сгенерировать файлы в /home/
снять снэпшот
удалить часть файлов
восстановиться со снэпшота
