# Vagrant и VMware команды

## Vagrant
`vagrant version` - Проверим версию Vagrant

`vagrant up` - старт и создание вм из файла описания

`vagrant status` - проверить состояние

`vagrant global-status` проверить состояние всех ВМ

`vagrant ssh name` - подключиться по ssh

`vagrant ssh-config` - отобраить настройки ssh

`vagrant halt` — выключить ВМ

`vagrant suspend` — приостановить ВМ

`vagrant reload` — перезагрузить ВМ и применить конфигурацию из VagrantFile

`vagrant destroy <имя машины>` — удалить ВМ (Если ВМ одна можно писать просто vagrant destroy)

`vagrant destroy -f` — удалить все виртуальные машины

`vagrant destroy --force && rm -rf .vagrant/ && vagrant up` - "по быстрому перестроить вм"

`vagrant box list` - список скачанных боксов

`vagrant box remove name` - удалить бокс

Получить Vagrantfile

`vagrant init almalinux/9 --box-version 9.5.20241203` - almalinux

`vagrant init bento/ubuntu-24.04` - ubuntu-24.04


## VMware

Запустить в терминале комманду `vmrun` чтобы посмотреть возможные опции

[Use the vmrun Utility](https://docs.vmware.com/en/VMware-Fusion/11/com.vmware.fusion.using.doc/GUID-7700DDB9-AE60-41C0-B638-9A0527795C8C.html)
