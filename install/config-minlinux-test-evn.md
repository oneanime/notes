vim /etc/sysconfig/network-scripts/ifcfg-ens33
```
BOOTPROTO=static
ONBOOT=yes

GATEWAY=192.168.79.2
IPADDR=192.168.79.200
NETMASK=255.255.255.0
DNS1=8.8.8.8
DNS2=8.8.4.4
```
vim /etc/selinux/config
```
SELINUX=disabled
```
vim /etc/security/limits.conf 
```
* soft nofile 65536 
* hard nofile 131072 
* soft nproc 65536 
* hard nproc 65536
```
vim /etc/security/limits.d/20-nproc.conf
```
soft nproc 4096
```
vim /etc/sysctl.conf
```
vm.max_map_count=262144
```
vim /etc/sudoers
```
用户名      ALL=(ALL)       NOPASSWD: ALL
```
vim /etc/hosts
```
地址1 hostname1
```
> systemctl stop firewalld.service  
> systemctl disable firewalld.service  
> systemctl status firewalld.service  

> hostnamectl set-hostname [hostname]

