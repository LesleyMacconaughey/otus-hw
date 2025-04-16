# Домашнее задание. Настраиваем центральный сервер для сбора логов

## Настраиваем центральный сервер для сбора логов

Что нужно сделать?

в вагранте поднимаем 2 машины web и log

на web поднимаем nginx

на log настраиваем центральный лог сервер на любой системе на выбор
journald;
rsyslog;
elk.

настраиваем аудит, следящий за изменением конфигов нжинкса

Реализовано в Yandex Cloud (для проверки потребуется настроенный `cli`)

Для создания тестовой виртуальной машины использовать скрипт
```bash
./vm-test-up.sh
```
При выполнении этого скрипта будут созданы две виртуальные машыны `web` и `log`. Они будут разположены в одной подсети и могут быть поступны по `hostname`. Но внешний ip адрес будет только у `web`. Она же будет выступать в качестве `jumphost` для доступа к `log`. Чтобы подключиться по ssh к `log` используем команду:
```bash
ssh -J yc-user@vm_web_ip yc-user@log
```
Чтобы подключиться к `web` используем команду
```bash
ssh -l yc-user vm_web_ip
```

ansible-playbook -i hw/inventory/hosts hw/playbook.yml

Чтобы запустить конкретную роль нужно использовать команду
```bash
ansible-playbook playbook.yml --tags logserver
```
или
```bash
ansible-playbook playbook.yml --tags webserver
```



Структура проекта

project/
├── inventory.yml
├── playbook.yml
└── roles/
    ├── web/
    │   ├── tasks/
    │   │   └── main.yml
    │   ├── handlers/
    │   │   └── main.yml
    │   └── templates/
    │       └── nginx.conf.j2
    └── log/
        ├── tasks/
        │   └── main.yml
        └── handlers/
            └── main.yml


Для выполнения задания 1 нужно из папки `hw` запустить ansible-playbook
```
ansible-playbook hw_pam.yml
```

Для выполнения задания 2 нужно из папки `hw` запустить ansible-playbook
```
ansible-playbook dev-docker.yml
```

После проверки задания виртуальную машину можно удалить с помощью

```
./vm-test-down.sh
```