# Домашнее задание "Репликация mysql"

Что нужно сделать?

Базу развернуть на мастере и настроить так, чтобы реплицировались таблицы:

    bookmaker
    competition
    market
    odds
    outcome

Настроить GTID репликацию

Сделаем простой Vagrantfile, который поднимет тестовый стенд из двух VM на базе Ubuntu 22.04 (jammy) для проверки репликации MySQL.

```sh
vagrant up
```

С помощью `scp` скопируем тестовый дамп `bet-224190-d906e5.dmp` на гипервизор и загрузим в ВМ `source` - `db1`

Смотрим, где находитя ssh ключ ВМ 

```sh
vagrant ssh-config db1
```

И также, с помощью `scp` загружаем в вм `db1` дамп

```sh
scp -i .vagrant/machines/db1/virtualbox/private_key -P 2222 bet-224190-d906e5.dmp vagrant@127.0.0.1:/home/vagrant/
```

Подключаемся к `db1` и ставим `percona server` по инструкции https://docs.percona.com/percona-server/8.4/apt-repo.html#unattended-installations

Настраиваем `source` сервер

```sh
vi /etc/mysql/mysql.conf.d/mysqld.cnf
```

Добавим
```conf
[mysqld]
...
server-id = 1
log_bin = mysql-bin
binlog_format = row
gtid_mode = ON
enforce-gtid-consistency = ON
log-replica-updates = ON
```

Перезапустим mysql
```sh
systemctl restart mysql.service
```

Проверим server-id

```sql
SELECT @@server_id;
```
    +-------------+
    | @@server_id |
    +-------------+
    |           1 |
    +-------------+

Убеждаемся что GTID включён:

```sql
SHOW VARIABLES LIKE 'gtid_mode';
```

    +---------------+-------+
    | Variable_name | Value |
    +---------------+-------+
    | gtid_mode     | ON    |
    +---------------+-------+

Создадим тестовую базу bet, загрузим в нее дамп и проверим:

```sql
CREATE DATABASE bet;
```

```sh
mysql -uroot -p -D bet < /home/vagrant/bet-224190-d906e5.dmp 
```

```sql
USE bet;
```
```sql
mysql> SHOW TABLES;
```

    +------------------+
    | Tables_in_bet    |
    +------------------+
    | bookmaker        |
    | competition      |
    | events_on_demand |
    | market           |
    | odds             |
    | outcome          |
    | v_same_event     |
    +------------------+
    7 rows in set (0.00 sec)

Создадим пользователя для репликациии и даем ему права на эту самую репликацию:

