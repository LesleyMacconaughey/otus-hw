# Задание 2 Первые шаги с Ansible
Подготовим стенд на Vagrant с одним сервером

Запустим ВМ:
```sh
vagrant up
```
Убедимся, что ВМ запущена, должна иметь статус (running):

```sh
vagrant status
```
Убедимся, что управляемая ВМ доступна:
```sh
ansible nginx -m ping
```
Если получен положительный результат ("ping": "pong"), можем приступать к запуску плейбука:
```sh
ansible-playbook playbooks/nginx_setup.yml
```
После успешного завершения работы плейбука подключимся к ВМ и проверим результат:
```sh
vagrant ssh
```
Работу веб сервера на порту 8080 проверим с помощью curl
```sh
curl 192.168.11.150:8080
```
В случае положительного результата увидим примерно следующее:
```sh
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
Выйдем из ВМ:
```sh
exit
```
Остановим ВМ:
```sh
vagrant halt
```
После всех проверок удалим ВМ:
```sh
vagrant destroy
```

