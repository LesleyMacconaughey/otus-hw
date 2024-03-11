# Занятие 1. Vagrant-стенд для обновления ядра и создания образа системы
После создания Vagrantfile, запустим виртуальную машину командой vagrant up
В процессе работы встроенного в Vagrantfile скрипта будут выполнены команды
- uname -a > /vagrant/old.ver # запись версии старого ядра
- dnf install langpacks-en glibc-all-langpacks -y # установка языкового пакета
- yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
- yum --enablerepo elrepo-kernel install kernel-ml -y
- grub2-mkconfig -o /boot/grub2/grub.cfg
- grub2-set-default 0
- reboot
- uname -a > /vagrant/new.ver # запись версии нового ядра

Результатом выполнения команд является запись версии старого ядра в файл /vagrant/old.ver и обновление ядра вм до новой версии kernel-ml-6.7.9