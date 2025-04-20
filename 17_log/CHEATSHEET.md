# log

## ansible команды

Запустить плейбук с указанием инвентаря
```bash
ansible-playbook -i hw/inventory/hosts hw/playbook.yml
```
Чтобы запустить конкретную роль нужно использовать команду
```bash
ansible-playbook playbook.yml --tags logserver
```
или
```bash
ansible-playbook playbook.yml --tags webserver
```

## Плейбуки

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
- name: Добавить хосты в known_hosts
  hosts: all
  connection: local
  tasks:
    - name: Trust SSH fingerprints
      ansible.builtin.shell: |
        ssh-keyscan -H "{{ ansible_host }}" >> ~/.ssh/known_hosts
      changed_when: false
```
