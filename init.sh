#!/bin/bash

apt-get update && apt-get upgrade -y
apt-get install -y openssh-server lsof vim git gcc apache2-utils

mkdir -p /var/run/sshd
echo 'root:toor' | chpasswd
sed -e 's@^.*PermitRootLogin.*$@PermitRootLogin yes@ig' -i /etc/ssh/sshd_config
sed -e 's@session.*required.*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

mkdir -p /opt
gcc -Wno-format-truncation -Wall -O3 -o /opt/soc /app/src/soc.c
