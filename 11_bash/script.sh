#!/bin/bash

# Путь к лог-файлу сервера
LOG_FILE="access-4560-644067.log"

# Почтовый адрес, на который отправлять письмо
EMAIL="your@email.com"

# Временной диапазон (последний час)
START_TIME=$(LANG=C date -d '1 hour ago' +'%d/%b/%Y:%H:%M:%S')

# Сбор данных
TOP_IPS=$(awk -v start="$START_TIME" '$4 > start {print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 10)
TOP_URLS=$(awk -v start="$START_TIME" '$4 > start {print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 10)
ERRORS=$(grep "$START_TIME" "$LOG_FILE" | grep '5[0-9][0-9]' | awk '{print $9}' | sort | uniq -c)
HTTP_CODES=$(awk -v start="$START_TIME" '$4 > start {print $9}' "$LOG_FILE" | sort | uniq -c)

# Отправка письма
{
    echo "Subject: Статистика запросов за последний час"
    echo
    echo "IP адреса с наибольшим количеством запросов:"
    echo "$TOP_IPS"
    echo
    echo "Запрашиваемые URL с наибольшим количеством запросов:"
    echo "$TOP_URLS"
    echo
    echo "Ошибки веб-сервера/приложения:"
    echo "$ERRORS"
    echo
    echo "Список HTTP кодов ответа:"
    echo "$HTTP_CODES"
}  | sendmail "$EMAIL"

# Запрет одновременного запуска (ввести свой путь до скрипта)
flock -n /tmp/script.lock -c "/home/dmitriy/hw/m02-10_bash/script.sh"

exit 0
