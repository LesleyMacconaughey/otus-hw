# Домашнее задание Vagrant
Выполнено задание по методичке, а также задание сборки ядра из исходников

## Занятие 1. Vagrant-стенд для обновления ядра и создания образа системы
Действия выполняем в папке `basic_task`

Создадим ВМ с помощью Vagrantfile из методички. Заменим `box_name` `generic/centos8s` на `bento/centos-stream-9`

Запустим ВМ:
```sh
vagrant up
```
Подключимся
```
vagrant ssh
```
Проверим версию ядра
```
uname -r
```
5.14.0-479.el9.aarch64

Дальнейишие действия будем выполнять от суперюзера
```
sudo su
```
Импортируем ключи
```
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm --import https://www.elrepo.org/RPM-GPG-KEY-v2-elrepo.org
```
Подключим репозиторий ELRepo для RHEL-9:
```
yum install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm
```
Установим последнее ядро из репозитория elrepo-kernel:
```
yum --enablerepo elrepo-kernel install kernel-ml -y
```
После установки получим вывод
```
Installed:
  kernel-ml-6.12.9-1.el9.elrepo.aarch64                kernel-ml-core-6.12.9-1.el9.elrepo.aarch64                kernel-ml-modules-6.12.9-1.el9.elrepo.aarch64   
```
Обновим параметры GRUB
```
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
```
Перезагрузимся с новым ядром и проверим версию
```
reboot
```
и проверим версию
```
uname -r
```
6.12.9-1.el9.elrepo.x86_64

Видим, что ядро обновилось до более новой версии.

## Занятие 2. Сборка ядра из исходников
Действия выполняем в папке `advanced_task`

Для этого нам понадобится виртуальная машина с большим количеством ядер и увеличенным диском.

Запустим ВМ:
```sh
vagrant up
```
Подключимся
```
vagrant ssh
```
Проверим версию ядра
```
uname -r
```
5.4.0-176-generic

Скачаем более свежую версию с сайта [kernel.org](https://kernel.org)
```
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.232.tar.xz
```
Распаковываем и проходим в дирректорию
```
tar xvf linux-5.10.232.tar.xz && cd linux-5.10.232
```

Копируем файл настроек

```
cp /boot/config-5.4.0-176-generic .config
```

Актуализируем файл настроек, пока не появится `configuration written to .config`
```
make oldconfig
```

Дополнительную ручную настройку можно выполнить с помощью команды
```
make menuconfig
```

Для исключения ошибок при сборке отключим сертификаты
```
scripts/config --disable SYSTEM_TRUSTED_KEYS
```
```
scripts/config --disable SYSTEM_REVOCATION_KEYS
```
Производим сборку. Для выполнения в несколько потоков задействуем опцию -j8 (по количеству ядер ВМ)

```
make -j8
```

Вылезла ошибка
`Failed to generate BTF for vmlinux
Try to disable CONFIG_DEBUG_INFO_BTF`.
Исправил на `n` и снова запустил сборку

После производим сборку модулей
```
make modules
```

Устанавливаем ядро предварительно переключившись `sudo su`
```
make modules_install
```
затем
```
make install
```
После завершения перезапускаем ВМ. К сожалению,
ВМ не стартовала с ошибкой `..No rule to make target 'localmodulesconfig'. Stop...`

Попробуем другим способом
```
make -j8 deb-pkg
```
После генерации пакетов установим их
```
dpkg -i ../*.deb
```
и перезагрузим ВМ
```
reboot
```
ВМ успешно перезагрузилась

Проверим версию ядра
```
uname -r
```
Ядро обновилось и стало версии 5.10.10

## Полезные ссылки
[elrepo.org](https://elrepo.org/wiki/doku.php?id=start)
<br>
[Репозиторий vagrant_kernel_update](https://github.com/Nickmob/vagrant_kernel_update)