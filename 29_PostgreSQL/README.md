# Домашнее задание Vagrant-стенд c Postgres

Цель домашнего задания

Научиться настраивать репликацию и создавать резервные копии в СУБД PostgreSQL

Создадим три виртуальные машины `node1`, `node2` и `barman`:

```sh
vagrant up
```

Вместе с созданием на `node1`, `node2` будут установлены `postgresql` и `postgresql-contrib`.

## Настройка hot_standby репликации с использованием слотов

### На хосте node1: 
1) Заходим в psql:

```sh
sudo -u postgres psql
```

2) В psql создаём пользователя replicator c правами репликации и паролем «Otus2022!»

```sql
CREATE USER replicator WITH REPLICATION Encrypted PASSWORD 'Otus2022!';
```
3) В файле /etc/postgresql/14/main/postgresql.conf указываем следующие параметры:

```conf
#Указываем ip-адреса, на которых postgres будет слушать трафик на порту 5432 (параметр port)
listen_addresses = 'localhost, 192.168.57.11'
#Указываем порт порт postgres
port = 5432 
#Устанавливаем максимально 100 одновременных подключений
max_connections = 100
log_directory = 'log' 
log_filename = 'postgresql-%a.log' 
log_rotation_age = 1d 
log_rotation_size = 0 
log_truncate_on_rotation = on 
max_wal_size = 1GB
min_wal_size = 80MB
log_line_prefix = '%m [%p] ' 
#Указываем часовой пояс для Москвы
log_timezone = 'UTC+3'
timezone = 'UTC+3'
datestyle = 'iso, mdy'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8' 
lc_numeric = 'en_US.UTF-8' 
lc_time = 'en_US.UTF-8' 
default_text_search_config = 'pg_catalog.english'
#можно или нет подключаться к postgresql для выполнения запросов в процессе восстановления; 
hot_standby = on
#Включаем репликацию
wal_level = replica
#Количество планируемых слейвов
max_wal_senders = 3
#Максимальное количество слотов репликации
max_replication_slots = 3
#будет ли сервер slave сообщать мастеру о запросах, которые он выполняет.
hot_standby_feedback = on
#Включаем использование зашифрованных паролей
password_encryption = scram-sha-256
```

4) Настраиваем параметры подключения в файле /etc/postgresql/14/main/pg_hba.conf:

```conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# "local" is for Unix domain socket connections only
local   all                  all                                                peer
# IPv4 local connections:
host    all                  all             127.0.0.1/32              scram-sha-256
# IPv6 local connections:
host    all                  all             ::1/128                       scram-sha-256
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                                peer
host    replication     all           127.0.0.1/32            scram-sha-256
host    replication     all           ::1/128                 scram-sha-256
host    replication     replicator    192.168.57.11/32        scram-sha-256
host    replication     replicator    192.168.57.12/32        scram-sha-256
```

Две последние строки в файле разрешают репликацию пользователю replication. 

5) Перезапускаем postgresql-server: systemctl restart postgresql

    sudo systemctl status postgresql
    ● postgresql.service - PostgreSQL RDBMS
        Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
        Active: active (exited) since Fri 2025-09-05 08:53:04 UTC; 8s ago
        Process: 4901 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
    Main PID: 4901 (code=exited, status=0/SUCCESS)
            CPU: 3ms

    Sep 05 08:53:04 node1 systemd[1]: Starting PostgreSQL RDBMS...
    Sep 05 08:53:04 node1 systemd[1]: Finished PostgreSQL RDBMS.

### На хосте node2: 

1) Останавливаем postgresql-server:

```sh
sudo systemctl stop postgresql
```

    ○ postgresql.service - PostgreSQL RDBMS
        Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
        Active: inactive (dead) since Fri 2025-09-05 08:56:01 UTC; 8s ago
        Process: 4662 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
    Main PID: 4662 (code=exited, status=0/SUCCESS)
            CPU: 4ms

    Sep 05 08:30:01 node2 systemd[1]: Starting PostgreSQL RDBMS...
    Sep 05 08:30:01 node2 systemd[1]: Finished PostgreSQL RDBMS.
    Sep 05 08:56:01 node2 systemd[1]: postgresql.service: Deactivated successfully.
    Sep 05 08:56:01 node2 systemd[1]: Stopped PostgreSQL RDBMS.

2) С помощью утилиты pg_basebackup копируем данные с node1:

```sh
pg_basebackup -h 192.168.57.11 -U replicator -D /var/lib/postgresql/14/main/ -R -P
```

3) В файле  `/etc/postgresql/14/main/postgresql.conf` меняем параметр:

```conf
listen_addresses = 'localhost, 192.168.57.12'
```

4) Запускаем службу postgresql-server:

```sh
systemctl start postgresql
```

### Проверка репликации: 

На хосте node1 в psql создадим базу otus_test и выведем список БД:

```sql
postgres=# CREATE DATABASE otus_test;
```

        postgres=# \l
                                    List of databases
        Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
        -----------+----------+----------+---------+---------+-----------------------
        otus_test | postgres | UTF8     | C.UTF-8 | C.UTF-8 | 
        postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 | 
        template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
                |          |          |         |         | postgres=CTc/postgres
        template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
                |          |          |         |         | postgres=CTc/postgres
        (4 rows)


На хосте node2 созданная база данных появилась.

## Настройка hot_standby репликации с использованием слотов с помощью ansible

Для настройки hot_standby репликации с использованием слотов требуется из папки `ansible` запустить плейбук:

```sh
ansible-playbook provision.yml
```

## Настройка резервного копирования с помощью утилиты Barman

Роль для настройки с помощью `ansible` расположена в папке `ansible/install_barman`.
