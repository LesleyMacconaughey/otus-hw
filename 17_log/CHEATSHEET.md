# Docker

## Docker команды
`docker ps` - просмотреть список запущенных контейнеров <br>
`docker ps -a` - просмотреть список всех контейнеров<br>
`docker run -d -p port:port container_name` - запуск нового контейнера с пробросом портов<br>
`docker stop container_name` - остановка контейнера<br>
`docker logs container_name` - вывод логов контейнеров<br>
`docker inspect container_name` - информация по запущенному контейнеру<br>
`docker build -t dockerhub_login/reponame:ver` - билд нового образа<br>
`docker push/pull` - отправка/получение образа из docker-registry<br>
`docker exec -it container_name bash` - выполнить команду внутри оболочки контейнера (в данном примере мы выполняем команду “bash” внутри контейнера и попадаем в оболочку, внутрь контейнера)<br>

## Ссылки

Yandex cloud

[Yandex Compute Cloud](https://yandex.cloud/ru/docs/compute/)

[yc compute instance create](https://yandex.cloud/ru/docs/cli/cli-ref/compute/cli-ref/instance/create)


```yaml
# Загрузка правил аудита по одному
- name: Set audit rules for Nginx
  command: "auditctl {{ item }}"
  with_items:
    - "-w /etc/nginx/ -p wa -k nginx_config"
    - "-w /etc/nginx/nginx.conf -p wa -k nginx_config"
    - "-w /etc/nginx/conf.d/ -p wa -k nginx_config"
    - "-w /etc/nginx/sites-available/ -p wa -k nginx_config"
    - "-w /etc/nginx/sites-enabled/ -p wa -k nginx_config"
    - "-w /usr/sbin/nginx -p x -k nginx_exec"
  register: audit_rules
  ignore_errors: yes  # Продолжить даже если некоторые правила не сработают
```

```yaml
- name: Add hosts to known_hosts
  hosts: all
  connection: local
  tasks:
    - name: Trust SSH fingerprints
      ansible.builtin.shell: |
        ssh-keyscan -H "{{ ansible_host }}" >> ~/.ssh/known_hosts
      changed_when: false
```
