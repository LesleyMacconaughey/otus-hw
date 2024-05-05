# Работа с загрузчиком
Цель:<br>
Научиться попадать в систему без пароля;<br>
Устанавливать систему с LVM и переименовывать в VG;<br>
Добавлять модуль в initrd.<br>

---
## Настройка вм
Образ для домашнего задания возьмем отсюда: 
https://mirror.yandex.ru/centos/7.9.2009/isos/x86_64/
<br>
Я взял этот:
```sh
https://mirror.yandex.ru/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Everything-2207-02.iso
```
Производим устаовку ВМ Centos 7 из образа и перезагружаем.

---
## Попасть в систему без пароля. Способ 1. init=/bin/sh
Во время загрузки, при появлении меню загрузчика grub нажимаем `e`.<br>
В строке, начитающейся с linux16, добавляем init=/bin/sh и нажимаем сtrl-x для загрузки.<br>
Нам становится доступна оболочка `sh-4.2#`. Но чтобы иметь возможность вносить изменения нужно перемонтировать корневую файловую систему в режим `rw`. Это делается командой:
```sh
mount -o remount,rw /
```
Убедиться можем выполнив команду:
```sh
mount | grep root
```
Атрибут `ro` сменился на `rw`. Теперь можем внести необходимые изменения, например, сменить пароль, и сохранить их.<br>

## Попасть в систему без пароля. Способ 2. rd.break
Во время загрузки, при появлении меню загрузчика grub нажимаем `e`.<br>
В строке, начитающейся с linux16, добавляем `rd.break` и нажимаем сtrl-x для загрузки.<br>
Получили уведомление, что вошли в `Emergency mode`<br>
Перемонтируем `/sysroot` в режим `rw`, сменим карневой каталог и поменяем пароль `root`:
```sh
mount -o remount,rw /sysroot
```
```sh
chroot /sysroot
```
```sh
passwd root
```
```sh
touch /.autorelabel
```
Теперь можно перезагрузиться и войти в систему с новым паролем root.

## Попасть в систему без пароля. Способ 3. rw init=/sysroot/bin/sh
Во время загрузки, при появлении меню загрузчика grub нажимаем `e`.<br>
В строке, начитающейся с linux16, заменяем `ro` на `rw init=/sysroot/bin/sh` и нажимаем сtrl-x для загрузки.<br>
После загрузки файловая система сразу смонтирована в ржиме `rw` и можем выполнять необходимые действия. 

## Переименовывание VG в системе с LVM
Посмотрим текущее состояние:
```sh
vgs
```
  VG     #PV #LV #SN Attr   VSize  VFree<br>
  centos   1   2   0 wz--n- <9,00g    0 <br>
Приступим к переименованию:
```sh
vgrename centos OtusRoot
```
  Volume group "centos" successfully renamed to "OtusRoot"<br>
Чтобы система определила новое название после перезагрузки правим `/etc/fstab`, `/etc/default/grub`, `/boot/grub2/grub.cfg` и пересоздаем `initrd image`.
```sh
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
```
Executing: /sbin/dracut -f -v /boot/initramfs-3.10.0-1160.118.1.el7.x86_64.img 3.10.0-1160.118.1.el7.x86_64<br>
...<br>
*** Creating initramfs image file '/boot/initramfs-3.10.0-1160.118.1.el7.x86_64.img' done ***<br>
Перезагружаемся
```sh
reboot
```
После перезагрузки проверяем
```sh
vgs
```
  VG       #PV #LV #SN Attr   VSize  VFree<br>
  OtusRoot   1   2   0 wz--n- <9,00g    0 <br>
VG успешно переименована.

## Добавление модулей в initrd
Скрипты модулей хранятся в каталоге /usr/lib/dracut/modules.d/. Для того, чтобы добавить свой модуль, создаем там папку с именем 01test:
```sh
mkdir /usr/lib/dracut/modules.d/01test
```
В нее поместим два скрипта.<br>
module-setup.sh
```
#!/bin/bash

check() {
    return 0
}

depends() {
    return 0
}

install() {
    inst_hook cleanup 00 "${moddir}/test.sh"
}
```
и test.sh
```
#!/bin/bash

exec 0<>/dev/console 1<>/dev/console 2<>/dev/console
cat <<'msgend'
Hello! You are in dracut module!
 ___________________
< I'm dracut module >
 -------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
msgend
sleep 10
echo " continuing...."
```
Пересобираем образ initrd
```sh
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
```
или
```sh
dracut -f -v
```
Я использовал dracut.<br>
...<br>
*** Creating initramfs image file '/boot/initramfs-3.10.0-1160.118.1.el7.x86_64.img' done ***<br>
Проверим, какие модули загружены в образ:
```sh
lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
```
test<br>
Перезагрузимся и руками выключим опции `rghb` и `quiet`, после чего увидим результат.


  







