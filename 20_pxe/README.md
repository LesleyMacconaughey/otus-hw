# Настройка PXE сервера для автоматической установки

Цель: Отработать навыки установки и настройки DHCP, TFTP, PXE загрузчика и автоматической загрузки

## Разворачивание хостов и настройка загрузки по сети

Подготовим Vagrantfile в котором будут описаны 2 виртуальные машины:

- pxeserver (хост к которому будут обращаться клиенты для установки ОС)
- pxeclient (хост, на котором будет проводиться установка)

Команда `vagrant up` запустит создание необходимых виртуальных машин. В процессе создания будет выполнен `provision` кототый запустит ansible-playbook для настройки `PXE-сервера`. После этого `PXE-клиент` сможет автоматически загрузиться по сети и установить операционную систему с заданными параметрами.
