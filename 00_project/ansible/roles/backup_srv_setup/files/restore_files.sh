#!/bin/bash

# Конфигурационные переменные (должны соответствовать скрипту бэкапа)
REMOTE_USER="ansible"
REMOTE_HOST="192.168.90.3"
REMOTE_DIR="/opt"
LOCAL_DIR="/backup"
MYSQL_HOST="m"
MYSQL_USER="backup"
MYSQL_PASS="12345"
MYSQL_DATABASES=("seafile_db" "ccnet_db" "seahub_db")
SSH_KEY="/root/.ssh/id_rsa"
LOG_FILE="/var/log/restore.log"

# Функция для логирования
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Автоматическое использование последнего бэкапа
BACKUP_PATH="$LOCAL_DIR/latest"

# Проверка существования директории бэкапа
if [ ! -d "$BACKUP_PATH" ]; then
    log "Ошибка: Директория бэкапа $BACKUP_PATH не существует!"
    exit 1
fi

log "Начало восстановления из последнего бэкапа: $BACKUP_PATH"

# Восстановление файлов
log "Начало восстановления файлов из $BACKUP_PATH"
rsync -avz --delete \
    -e "ssh -o StrictHostKeyChecking=no -i $SSH_KEY" \
    --rsync-path="sudo rsync" \
    "$BACKUP_PATH/" \
    "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/" 2>&1 | tee -a "$LOG_FILE"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    log "Восстановление файлов успешно завершено"
else
    log "Ошибка при восстановлении файлов!"
    exit 1
fi

# # Восстановление баз данных
# log "Начало восстановления баз данных"
# for db in "${MYSQL_DATABASES[@]}"; do
#     if [ -f "$BACKUP_PATH/mysql/$db" ]; then
#         log "Восстановление базы данных: $db"
        
#         # Передача дампа на сервер и восстановление
#         ssh -i "$SSH_KEY" "$REMOTE_USER@$MYSQL_HOST" \
#             "mysql -h $MYSQL_HOST -u $MYSQL_USER -p'$MYSQL_PASS' $db" \
#             < "$BACKUP_PATH/mysql/$db" 2>> "$LOG_FILE"
        
#         if [ $? -eq 0 ]; then
#             log "База данных $db успешно восстановлена"
#         else
#             log "Ошибка при восстановлении базы данных $db!"
#         fi
#     else
#         log "Предупреждение: Файл бэкапа для базы $db не найден"
#     fi
# done

log "Процесс восстановления из последнего бэкапа завершен"