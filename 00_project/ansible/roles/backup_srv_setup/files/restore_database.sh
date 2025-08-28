#!/bin/bash
set -euo pipefail

SOURCE_HOST="192.168.90.4"
SOURCE_SSH="root@192.168.90.4"
REPLICA_HOST="192.168.90.5"
REPL_USER="repl"
REPL_PASS="12345"
MYSQL_ROOT_PASS="12345"

# базы, которые нужно восстановить
DATABASES=("seafile_db" "ccnet_db" "seahub_db")
SCHEMA_DUMP_DIR="/backup/latest/mysql"  # дампы по базе: seafile_db.sql и т.д.

echo "=== Останавливаю репликацию на реплике ==="
mysql -h $REPLICA_HOST -u root -p$MYSQL_ROOT_PASS -e "STOP REPLICA; RESET REPLICA ALL;"

echo "=== Чищу данные на source для выбранных баз ==="
for db in "${DATABASES[@]}"; do
    ssh $SOURCE_SSH "mysql -u root -p$MYSQL_ROOT_PASS -e \"DROP DATABASE IF EXISTS $db; CREATE DATABASE $db;\""
done

echo "=== Заливаю дампы выбранных баз на source ==="
for db in "${DATABASES[@]}"; do
    mysql -h $SOURCE_HOST -u root -p$MYSQL_ROOT_PASS $db < "$SCHEMA_DUMP_DIR/$db.sql"
done

echo "=== Сбрасываю GTID на source ==="
ssh $SOURCE_SSH "mysql -u root -p$MYSQL_ROOT_PASS -e 'RESET MASTER;'"

echo "=== Настраиваю репликацию на replica ==="
mysql -h $REPLICA_HOST -u root -p$MYSQL_ROOT_PASS -e "
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='$SOURCE_HOST',
  SOURCE_USER='$REPL_USER',
  SOURCE_PASSWORD='$REPL_PASS',
  SOURCE_AUTO_POSITION=1;
START REPLICA;
"

echo "=== Проверяю статус репликации ==="
mysql -h $REPLICA_HOST -u root -p$MYSQL_ROOT_PASS -e "SHOW REPLICA STATUS\G"