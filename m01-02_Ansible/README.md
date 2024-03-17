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



