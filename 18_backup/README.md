# Домашнее задание. Настраиваем бэкапы

## Описание задания

Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client.


Настроить удаленный бекап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:

Директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB;

Репозиторий дле резервных копий должен быть зашифрован ключом или паролем - на ваше усмотрение;

Имя бекапа должно содержать информацию о времени снятия бекапа;

Глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех.

Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов;

Резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации;

Написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на ваше усмотрение;

## Решение

Реализовано в Yandex Cloud (для проверки потребуется настроенный `cli`)

Для создания и предварительной настройки тестовой среды использовать скрипт

```bash
./up-vm.sh
```

Дальнейшие действия производим с помощью консоли

## Настройка соединения с сервером
На сервере пропишем ssh ключ клиента. Для этого на клиенте сгенерируем

```bash
ssh-keygen -f ~/.ssh/id_rsa -N ""
```

Скопируем через буфер на клиенте

```bash
cat .ssh/id_rsa.pub
```

и вставим на сервер

```bash
sudo vi /home/borg/.ssh/authorized_keys
```

Проверим, что соединение c клиента может быть установлено

```bash
ssh borg@backup-server
```

## Инициализация и проверка работы

Инициализируем borg repo на сервере с клиента

```bash
borg init -e none borg@backup-server:MyBorgRepo
```

Запустим создание первого бэкапа каталога `/etc`

```bash
borg create --stats --list borg@backup-server:MyBorgRepo::"MyFirstBackup-{now:%Y-%m-%d_%H:%M:%S}" /etc
```

Проверим, что получилось

```bash
borg list borg@backup-server:MyBorgRepo
```

Вывод комманды: `MyFirstBackup-2025-04-20_09:09:26    Sun, 2025-04-20 09:09:27 [8cbc9ad284d7a7b924d68e5e5a9767135f3bae3326f7e1071da8426e830d7dc6]`

Смотрим список файлов

```bash
borg extract borg@backup-server:MyBorgRepo::MyFirstBackup-2025-04-20_09:09:26 etc/hostname
```

Достаем файл из бекапа

```bash
borg list borg@backup-server:MyBorgRepo::MyFirstBackup-2025-04-20_09:09:26
```

## Команды для инициализации репозитория с шифрованием

Пример 1: Режим repokey

```bash
borg init -e repokey /path/to/repo
```

После выполнения команды Borg запросит пароль для защиты ключа.

Ключ будет сохранён внутри репозитория (в файле repo/config).

Важно: Если злоумышленник получит доступ к репозиторию, он сможет попытаться взломать пароль.

Пример 2: Режим keyfile

```bash
borg init -e keyfile /path/to/repo
```

Ключ сохраняется на клиенте в ~/.config/borg/keys/.

Для восстановления данных потребуется как репозиторий, так и файл ключа.

Пароль также запрашивается при инициализации.

## Автоматизируем создание бэкапов с помощью systemd

Создаем сервис и таймер в каталоге `/etc/systemd/system/`

```bash
vim /etc/systemd/system/borg-backup.service
```

Содержимое сервиса

```bash
[Unit]
Description=Borg Backup

[Service]
Type=oneshot

# Парольная фраза
Environment="BORG_PASSPHRASE=123456"
# Репозиторий
Environment=REPO=borg@backup-server:/var/backup/
# Что бэкапим
Environment=BACKUP_TARGET=/etc

# Создание бэкапа
ExecStart=/bin/borg create \
    --stats                \
    ${REPO}::etc-{now:%%Y-%%m-%%d_%%H:%%M:%%S} ${BACKUP_TARGET}

# Проверка бэкапа
ExecStart=/bin/borg check ${REPO}

# Очистка старых бэкапов
ExecStart=/bin/borg prune \
    --keep-daily  90      \
    --keep-monthly 12     \
    --keep-yearly  1       \
    ${REPO}
```
Теперь создаем таймер
```bash
vim /etc/systemd/system/borg-backup.service
```
Содержимое таймера
```bash
[Unit]
Description=Borg Backup

[Timer]
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
```

Чтобы включить таймер

```bash
systemctl enable borg-backup.timer 
```

Чтобы запустить таймер

```bash
systemctl start borg-backup.timer
```

После проверки задания компоненты инфраструктуры можно удалить с помощью команды

```bash
./down-vm.sh
```
