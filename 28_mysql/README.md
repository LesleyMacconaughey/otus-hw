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
mysql_native_password = ON
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

```sql
CREATE USER 'repl'@'%' IDENTIFIED BY '12345';
```
```sql
SELECT user,host FROM mysql.user where user='repl';
```

    +------+------+
    | user | host |
    +------+------+
    | repl | %    |
    +------+------+

```sql
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
```
Проверка

```sql
SHOW GRANTS FOR 'repl'@'%';
```

    mysql> SHOW GRANTS FOR 'repl'@'%';
    +------------------------------------------------------------------+
    | Grants for repl@%                                                |
    +------------------------------------------------------------------+
    | GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO `repl`@`%` |
    +------------------------------------------------------------------+
    1 row in set (0.00 sec)

Дампим базу длā последующего залива на сдейв и игнорируем таблицы по заданию:

```sh
mysqldump --all-databases --triggers --routines --source-data --set-gtid-purged=OFF --ignore-table=bet.events_on_demand --ignore-table=bet.v_same_event -uroot -p > master.sql
```
Копируем полученный файл дампа на гипервизор и переносим на `db2`

```sh
scp -i .vagrant/machines/db1/virtualbox/private_key -P 2222 vagrant@127.0.0.1:/home/vagrant/master.sql .
scp -i .vagrant/machines/db2/virtualbox/private_key -P 2200 master.sql vagrant@127.0.0.1:/home/vagrant/
```
Настраиваем `replica` сервер

```sh
vi /etc/mysql/mysql.conf.d/mysqld.cnf
```

Добавим
```conf
[mysqld]
...
server-id = 2
log_bin = mysql-bin
binlog_format = row
gtid_mode = ON
enforce-gtid-consistency = ON
log-replica-updates = ON
```

Заливаем дамп мастера и убеждаемся, что база есть и она без лишних таблиц:
```sql
SOURCE /home/vagrant/master.sql
SHOW DATABASES LIKE 'bet';
```
    +----------------+
    | Database (bet) |
    +----------------+
    | bet            |
    +----------------+

```sql
USE bet;
SHOW TABLES;
```
    +---------------+
    | Tables_in_bet |
    +---------------+
    | bookmaker     |
    | competition   |
    | market        |
    | odds          |
    | outcome       |
    +---------------+
    5 rows in set (0.01 sec)

Подключаем и запускаем слейв:

```sql
CHANGE REPLICATION SOURCE TO SOURCE_HOST = "192.168.56.11", SOURCE_PORT = 3306, SOURCE_USER = "repl", SOURCE_PASSWORD = "12345", SOURCE_AUTO_POSITION = 1;
START REPLICA;
SHOW REPLICA STATUS\G
```
    *************************** 1. row ***************************
                Replica_IO_State: Waiting for source to send event
                    Source_Host: 192.168.56.11
                    Source_User: repl
                    Source_Port: 3306
                    Connect_Retry: 60
                Source_Log_File: mysql-bin.000003
            Read_Source_Log_Pos: 1058
                Relay_Log_File: db2-relay-bin.000002
                    Relay_Log_Pos: 93332
            Relay_Source_Log_File: mysql-bin.000001
            Replica_IO_Running: Yes
            Replica_SQL_Running: No
                Replicate_Do_DB: 
            Replicate_Ignore_DB: 
            Replicate_Do_Table: 
        Replicate_Ignore_Table: bet.events_on_demand,bet.v_same_event