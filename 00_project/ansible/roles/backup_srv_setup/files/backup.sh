#!/bin/bash

# Конфигурационные переменные
REMOTE_USER="ansible"           # Пользователь на удаленном сервере
REMOTE_HOST="192.168.90.3"    # Адрес удаленного сервера
REMOTE_DIR="/opt"   # Путь к директории на удаленном сервере
LOCAL_DIR="/backup"          # Локальная директория для резервных копий
LOG_FILE="/var/log/backup.log"  # Файл для логов

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
    log "Резервное копирование успешно завершено"
    # Дополнительные действия при успехе (например, удаление старых бэкапов)
else
    log "Ошибка при выполнении резервного копирования!"
    exit 1
fi