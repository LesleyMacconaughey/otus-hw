# Домашнее задание Vagrant
Текст

## Задание по методичке
Текст

## Сборка ядра из исходников
Запустим ВМ
```
vagratt up
```
Подключимся
```
vagratt ssh
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

## Ansible
Установку Ansible выполнил по [инструкции](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible) на сайте.

## Полезные ссылки

[Vagrant and VMWare Fusion 13 Player on Apple M1 Pro](https://gist.github.com/sbailliez/2305d831ebcf56094fd432a8717bed93)

[Discover Vagrant Boxes](https://portal.cloud.hashicorp.com/vagrant/discover?architectures=arm64)

[Vagrant Documentation](https://developer.hashicorp.com/vagrant/docs)