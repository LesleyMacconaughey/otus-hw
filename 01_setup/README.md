# Установка и настройка окружения
Задания будут выполняться на компьютере MacBook Pro с чипом Apple M2 Pro, соответственно программное обеспечение требуется выбирать для архитектуры  процессоров arm.

## Среда виртуализации
В качестве среды виртуализации выбран VMware Fusion Professional Version 13.6.1 (24319021) как наиболее стабильно работающий на таких компьютерах  [VMware](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion).

## Vagrant
Установить vagrant можно либо используя `brew`, либо из пакета.
```
brew install vagrant@2.4.1
```

Я устанавливал из пакета версию Vagrant 2.4.1

После установки Vagrant для работы с VMware Fusion требуется установить плагин
```
vagrant plugin install vagrant-vmware-desktop
```

## Установка базовых программ
Установим программы для анализа сетевого трафика
```
brew install traceroute net-tools tcpdump
```

Установим утилиты для передачи файлов
```
brew install curl wget
```

В качестве редакторам кода я выбрал [Visual Studio Code](https://code.visualstudio.com/download)

## Ansible
Установку Ansible выполнил по [инструкции](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible) на сайте.

## Полезные ссылки

[Vagrant and VMWare Fusion 13 Player on Apple M1 Pro](https://gist.github.com/sbailliez/2305d831ebcf56094fd432a8717bed93)

[Discover Vagrant Boxes](https://portal.cloud.hashicorp.com/vagrant/discover?architectures=arm64)

[Vagrant Documentation](https://developer.hashicorp.com/vagrant/docs)