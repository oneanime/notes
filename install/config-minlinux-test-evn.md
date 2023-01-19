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

阿里云镜像https://developer.aliyun.com/mirror/centos?spm=a2c6h.13651102.0.0.3e221b11kt2Zye
>下载源后，执行下面命令，再 yum makecache
>sudo sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
>sudo sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

