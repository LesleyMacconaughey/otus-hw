# Работа с ВМ созданными в Vagrant

`scp -P 2222 -i .vagrant/machines/default/virtualbox/private_key vagrant@127.0.0.1:/boot/config-5.4.0-176-generic ./local_files/` - копирование файла из ВМ на локальный хост
