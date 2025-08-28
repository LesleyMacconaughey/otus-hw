#!/bin/bash

# Конфигурационные переменные
REMOTE_USER="ansible"           # Пользователь на удаленном сервере
REMOTE_HOST="192.168.90.3"    # Адрес удаленного сервера
REMOTE_DIR="/opt"   # Путь к директории на удаленном сервере
LOCAL_DIR="/backup"          # Локальная директория для резервных копий
LOG_FILE="/var/log/backup.log"  # Файл для логов

# Настройки MySQL
MYSQL_HOST="192.168.90.4"              # Хост MySQL
MYSQL_USER="backup"                # Пользователь MySQL
MYSQL_PASS="12345"               # Пароль MySQL (рекомендуется использовать .my.cnf)
MYSQL_DATABASES=("seafile_db" "ccnet_db" "seahub_db")  # 
SSH_KEY="/root/.ssh/id_rsa"

# Создаем директорию для бэкапа если не существует
mkdir -p "$LOCAL_DIR"

# Форматируем дату для имени папки
BACKUP_NAME="backup_$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_PATH="$LOCAL_DIR/$BACKUP_NAME"

# Функция для логирования
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Выполняем резервное копирование
log "Начало резервного копирования $REMOTE_DIR"
rsync -avz --delete \
    -e "ssh -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa" \
    --rsync-path="sudo rsync" \
    "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/" \
    "$BACKUP_PATH/" 2>&1 | tee -a "$LOG_FILE"

# Проверяем код возврата rsync
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    log "Резервное копирование файлов успешно завершено"
    # Дополнительные действия при успехе (например, удаление старых бэкапов)
else
    log "Ошибка при выполнении резервного копирования файлов!"
    exit 1
fi

# Создаем директорию для бэкапов БД
mkdir -p "$BACKUP_PATH/mysql"

# Выполняем резервное копирование баз данных
log "Начало резервного копирования баз данных"
for db in "${MYSQL_DATABASES[@]}"; do
    log "Резервное копирование базы данных: $db"
    
    # Выполняем дамп базы данных на удаленном сервере
    ssh -i "$SSH_KEY" "$REMOTE_USER@$MYSQL_HOST" \
        "/usr/bin/mysqldump --single-transaction --set-gtid-purged=OFF -h $MYSQL_HOST -u $MYSQL_USER -p'$MYSQL_PASS' $db" \
        > "$BACKUP_PATH/mysql/$db" 2>> "$LOG_FILE"
    
    # Проверяем успешность выполнения дампа
    if [ $? -eq 0 ]; then
        log "База данных $db успешно скопирована"
        
        # # Сжимаем дамп для экономии места
        # gzip "$BACKUP_PATH/mysql/$db.sql"
        # log "Дамп базы данных $db сжат"
    else
        log "Ошибка при резервном копировании базы данных $db!"
        # Удаляем пустой или поврежденный файл
        rm -f "$BACKUP_PATH/mysql/$db.sql"
    fi
done

# Создаем символьную ссылку на последний бэкап
ln -sfn "$BACKUP_PATH" "$LOCAL_DIR/latest"
log "Создана ссылка на последний бэкап: $LOCAL_DIR/latest"
log "Резервное копирование полностью завершено"
log "Файлы сохранены в: $BACKUP_PATH/files"
log "Дампы баз данных сохранены в: $BACKUP_PATH/mysql"