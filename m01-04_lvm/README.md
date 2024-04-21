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
vgcreate vg_root /dev/sdb
```
  Volume group "temp_root" successfully created
```
lvcreate -n lv_root -l +100%FREE /dev/vg_root
```
  Logical volume "lv_root" created.<br> 
Создадим на нем файловую систему и смонтируем его
```
mkfs.xfs /dev/vg_root/lv_root
```
meta-data=/dev/vg_root/lv_root isize=512    agcount=4, agsize=655104 blks<br> 
         =                       sectsz=512   attr=2, projid32bit=1<br> 
         =                       crc=1        finobt=0, sparse=0<br> 
data     =                       bsize=4096   blocks=2620416, imaxpct=25<br> 
         =                       sunit=0      swidth=0 blks<br> 
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1<br> 
log      =internal log           bsize=4096   blocks=2560, version=2<br> 
         =                       sectsz=512   sunit=0 blks, lazy-count=1<br> 
realtime =none                   extsz=4096   blocks=0, rtextents=0<br> 
```
mount /dev/vg_root/lv_root /mnt
```
Копируем все данные с / раздела в /mnt
```sh
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
```
xfsdump: Dump Status: SUCCESS<br>
xfsrestore: restore complete: 119 seconds elapsed<br>
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
Generating grub configuration file ...<br>
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
/boot/grub2/grub.cfg заменим rd.lvm.lv=VolGroup00/LogVol00 на rd.lvm.lv=vg_root/lv_root
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
Do you really want to remove active logical volume VolGroup00/LogVol00? [y/n]: y<br>
  Logical volume "LogVol00" successfully removed<br>
== (у меня без перезагрузки удалить не получилось, писал, что файловая система занята) == <br>
Создаем новый LV<br>
```sh
lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
```
  Logical volume "LogVol00" created.<br>
Создаем на нем файловую систему<br>
```sh
mkfs.xfs /dev/VolGroup00/LogVol00
```
meta-data=/dev/VolGroup00/LogVol00 isize=512    agcount=4, agsize=524288 blks<br>
         =                       sectsz=512   attr=2, projid32bit=1<br>
         =                       crc=1        finobt=0, sparse=0<br>
data     =                       bsize=4096   blocks=2097152, imaxpct=25<br>
         =                       sunit=0      swidth=0 blks<br>
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1<br>
log      =internal log           bsize=4096   blocks=2560, version=2<br>
         =                       sectsz=512   sunit=0 blks, lazy-count=1<br>
realtime =none                   extsz=4096   blocks=0, rtextents=0<br>
Монтируем в /mnt <br>
```sh
mount /dev/VolGroup00/LogVol00 /mnt
```
Переносим содержимое <br>
```sh
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
```
xfsdump: dump complete: 76 seconds elapsed<br>
xfsdump: Dump Status: SUCCESS<br>
xfsrestore: restore complete: 76 seconds elapsed<br>
xfsrestore: Restore Status: SUCCESS<br>
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
Generating grub configuration file ...<br>
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64<br>
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img<br>
done<br>
```sh
cd /boot ; for i in `ls initramfs-*img`; \
 do dracut -v $i `echo $i|sed "s/initramfs-//g; \
> s/.img//g"` --force; done
```
...<br>
*** Creating image file ***<br>
*** Creating image file done ***<br>
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***<br>
Не перезагружаемся и не выходим из под chroot, перенесем /var на зеркало<br>
## Выделить том под /var в зеркало<br>
Создаем зеркало на свободных дисках
```sh
pvcreate /dev/sdc /dev/sdd
```
  Physical volume "/dev/sdc" successfully created.<br>
  Physical volume "/dev/sdd" successfully created.<br>
```sh
vgcreate vg_var /dev/sdc /dev/sdd
```
  Volume group "vg_var" successfully created<br>
```sh
lvcreate -L 950M -m1 -n lv_var vg_var
```
  Rounding up size to full physical extent 952.00 MiB<br>
  Logical volume "lv_var" created.<br>
Создаем на нем ФС и перемещаем туда /var <br>
```sh
mkfs.ext4 /dev/vg_var/lv_var
```
Filesystem label=<br>
OS type: Linux<br>
Block size=4096 (log=2)<br>
Fragment size=4096 (log=2)<br>
Stride=0 blocks, Stripe width=0 blocks<br>
60928 inodes, 243712 blocks<br>
12185 blocks (5.00%) reserved for the super user<br>
First data block=0<br>
Maximum filesystem blocks=249561088<br>
8 block groups<br>
32768 blocks per group, 32768 fragments per group<br>
7616 inodes per group<br>
Superblock backups stored on blocks: <br>
        32768, 98304, 163840, 229376<br>
<br>
Allocating group tables: done                            <br>
Writing inode tables: done                            <br>
Creating journal (4096 blocks): done<br>
Writing superblocks and filesystem accounting information: done<br>
```sh
mount /dev/vg_var/lv_var /mnt
```
Cохраняем содержимое старого var<br>
```sh
mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
```
Монтируем новый var в каталог /var
```sh
mount /dev/vg_var/lv_var /var
```
Правим fstab для автоматического монтирования /var
```sh
echo "`blkid | grep var: | awk '{print $2}'` \
 /var ext4 defaults 0 0" >> /etc/fstab
```
Перезагружаемся и удаляем временную Volume Group
```sh
lvremove /dev/vg_root/lv_root
```
```sh
vgremove /dev/vg_root
```
```sh
pvremove /dev/sdb
```

## Выделить том под /home
<br>Подготовим том для home
```sh
pvcreate /dev/sdc
```
  Physical volume "/dev/sdc" successfully created.<br>
Создаем группу томов
```sh
vgcreate vg_home /dev/sdc
```
  Volume group "vg_home" successfully created<br>
Создаем логический том LogVol_Home<br>
```sh
lvcreate -n LogVol_Home -L 1.9G vg_home
```
  Rounding up size to full physical extent 1.90 GiB<br>
  Logical volume "LogVol_Home" created.<br>
Создадим файловую систему и смонтируем диск<br>
```sh
mkfs.xfs /dev/vg_home/LogVol_Home
```
meta-data=/dev/vg_home/LogVol_Home isize=512    agcount=4, agsize=124672 blks<br>
         =                       sectsz=512   attr=2, projid32bit=1<br>
         =                       crc=1        finobt=0, sparse=0<br>
data     =                       bsize=4096   blocks=498688, imaxpct=25<br>
         =                       sunit=0      swidth=0 blks<br>
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1<br>
log      =internal log           bsize=4096   blocks=2560, version=2<br>
         =                       sectsz=512   sunit=0 blks, lazy-count=1<br>
realtime =none                   extsz=4096   blocks=0, rtextents=0<br>
```sh
mount /dev/vg_home/LogVol_Home /mnt/
```
Перенесем содержимое home
```sh
cp -aR /home/* /mnt/
```
Очистим
```sh
rm -rf /home/*
```
Перемонтируем из mnt в home
```sh
umount /mnt && mount /dev/vg_home/LogVol_Home /home
```
Правим fstab для автоматического монтирования /home
```sh
echo "`blkid | grep Home | awk '{print $2}'` \
 /home xfs defaults 0 0" >> /etc/fstab
```
## Работа со снапшотами
<br>Сгенерируем файлы
```sh
touch /home/file{1..20}
```
Сделаем снэпшот
```sh
 lvcreate -L 100MB -s -n home_snap /dev/vg_home/LogVol_Home
```
  Logical volume "home_snap" created.<br>
Удалим часть файлов
```sh
rm -f /home/file{11..20}
```
Восстановим из снапшота
```sh
umount /home
```
```sh
lvconvert --merge /dev/vg_home/home_snap
```
```sh
mount /home
```
