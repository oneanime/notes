
>whoamis  获取主机名

>ps -ef|grep logger-0.0.1-SNAPSHOT.jar | grep -v grep|awk '{print \$2}'|xargs kill >/dev/null 2>&1

>查看文件夹大小 du -h --max-depth=1 文件夹

>date -d "-1 day" 一天前（时间偏移）

#### 单双引号的区别
>（1）单引号不取变量值  
>（2）双引号取变量值  
>（3）反引号`，执行引号中命令  
>（4）双引号内部嵌套单引号，取出变量值  
>（5）单引号内部嵌套双引号，不取出变量值

>ifconfig后地址是127.的本地地址，和ifen33中的地址不同
>先systemctl status network.service查看状态，发现Failed to start LSB: Bring up/down
>解决方法
>1. systemctl stop NetworkManager
>2. systemctl disable NetworkManager
>3.service network restart


#### 目录
>/usr/src：系统级的源码目录。  
>/usr/local/src：用户级的源码目录。  
>/usr：系统级的目录，可以理解为C:/Windows/，/usr/lib理解为C:/Windows/System32。  
>/usr/local：用户级的程序目录，可以理解为C:/Progrem Files/。用户自己编译的软件默认会安装到这>个目录下。  
>/opt：用户级的程序目录，可以理解为D:/Software。  

#### 开机启动或关闭 
>systemctl list-unit-files | grep enable  
>systemctl disabled/enable/is-enabled

#### 防护墙
>1. systemctl status firewalld.service
>2. systemctl start firewalld.service
>3. systemctl stop firewalld.service
>4. systemctl enable firewalld.service
>5. systemctl disable firewalld.service