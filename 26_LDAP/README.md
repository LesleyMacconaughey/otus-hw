

vagrant ssh ipa.otus.lan
sudo -i
timedatectl set-timezone Europe/Moscow
yum install -y chrony
systemctl enable chronyd --now
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
vi /etc/selinux/config

dnf install ipa-server

ipa-server-install