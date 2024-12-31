# Установка и настройка окружения
Задания будут выполняться на компьютере MacBook Pro с чипом Apple M2 Pro, соответственно программное обеспечение требуется выбирать для архитектуры  процессоров arm.

## Среда виртуализации
В качестве среды виртуализации выбран VMware Fusion Professional Version 13.6.1 (24319021) как наиболее стабильно работающий на таких компьютерах  [VMware](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion).

## Vagrant
Установить vagrant можно либо используя 'brew', либо из пакета.
```
brew install vagrant@2.4.1
```

Я устанавливал из пакета версию Vagrant 2.4.1

После установки Vagrant для работы с VMware Fusion требуется установить плагин
```
vagrant plugin install vagrant-vmware-desktop
```
