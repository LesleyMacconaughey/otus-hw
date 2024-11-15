# Практика с SELinux. Домашнее задание

## Задание 1. Запустить nginx на нестандартном порту 3-мя разными способами

Для выполнения задания будем использовать almalinux/9 версии 9.4.20240805

```bash
vagrant init almalinux/9 --box-version 9.4.20240805
```

```bash
vagrant up
```

```bash
vagrant ssh
```

Действия выполняем под root

```bash
sudo su
```

Для работы с SElinux Установим необходимые пакеты

```bash
yum install -y setroubleshoot-server selinux-policy-mls setools-console policycoreutils-newrole policycoreutils-python-utils
```

```bash
dnf -y install setroubleshoot-server
```

Для выполнения задания установим nginx

```bash
yum install -y nginx
```

Проверим режим работы SELinux

```bash
getenforce
```

![alt text](images/image-1.png)

### Способ 1. Переключатели setsebool

После установки проверим файл настроек и запустим nginx

```bash
nginx -t && systemctl start nginx.service
```

Убедимся что nginx запустился

```bash
systemctl status nginx.service
```

![alt text](image-2.png)

Изменим порт и отключим IPv6

```bash
vi /etc/nginx/nginx.conf
```

![alt text](image-10.png)

Проверим файл настроек и перезапустим nginx

```bash
nginx -t && systemctl restart nginx.service
```

![alt text](image-11.png)

Настройки корректны, но nginx не запустился

Находим в логах (/var/log/audit/audit.log) информацию о блокировании порта

```bash
cat /var/log/audit/audit.log | grep type=AVC
```

![alt text](image-12.png)

Копируем время, в которое был записан этот лог, и, с помощью утилиты audit2why смотрим причину

```bash
grep 1729236508.383:910 /var/log/audit/audit.log | audit2why
```

![alt text](image-13.png)

Исходя из вывода утилиты, мы видим, что нам нужно поменять параметр nis_enabled. Выыод команды пустой, возможно прошло успешно. Проверим

```
nginx -t && systemctl restart nginx.service
```
![alt text](image-1.png)

```
systemctl status nginx.service
```
![alt text](image-14.png)

Проверим с помощью curl

```
curl localhost:4881
```
![alt text](image-15.png)

Проверить статус параметра можно с помощью команды
```
getsebool -a | grep nis_enabled
```
![alt text](image-16.png)

Вернём запрет работы nginx на порту 4881 обратно. Для этого отключим nis_enabled
```
setsebool -P nis_enabled off
```
![alt text](image-17.png)

После отключения nis_enabled служба nginx снова не запустилась.

### Способ 2. добавление нестандартного порта в имеющийся тип
Поиск имеющегося типа, для http трафика
```
semanage port -l | grep http
```
![alt text](image-18.png)

Добавим порт в тип http_port_t (если все успешно, вывод комманды пустой)
```
semanage port -a -t http_port_t -p tcp 4881
```
Проверим, что порт добавлен
```
semanage port -l | grep  http_port_t
```
![alt text](image-19.png)

Перезапустим nginx
```
nginx -t && systemctl restart nginx.service
```
![alt text](image-20.png)

Убедимся, что служба запущена
![alt text](image-21.png)

Удалить нестандартный порт из имеющегося типа можно с помощью команды
```
semanage port -d -t http_port_t -p tcp 4881
```
Перезапуск завершится с ошибкой
```
nginx -t && systemctl restart nginx.service
```
![alt text](image-22.png)

### Способ 3. формирование и установка модуля SELinux.

Попробуем запустить nginx

```
systemctl start nginx.service
```

Посмотрим логи SELinux, которые относятся к nginx

```
grep nginx /var/log/audit/audit.log
```
![alt text](image-23.png)

Воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту

```
grep nginx /var/log/audit/audit.log | audit2allow -M nginx
```
![alt text](image-24.png)

Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль

```
semodule -i nginx.pp
```
После выполнения комманды попробуем снова запустить nginx

```
systemctl start nginx.service
```
Проверим
```
systemctl status nginx.service
```
![alt text](image-25.png)

Просмотр всех установленных модулей
```
semodule -l
```

Для удаления модуля воспользуемся командой
```
semodule -r nginx
```





К сдаче:
README с описанием каждого решения (скриншоты и демонстрация приветствуются).

2. Обеспечить работоспособность приложения при включенном selinux.
развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
выяснить причину неработоспособности механизма обновления зоны (см. README);
предложить решение (или решения) для данной проблемы;
выбрать одно из решений для реализации, предварительно обосновав выбор;
реализовать выбранное решение и продемонстрировать его работоспособность.