
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

#### 脚本中杀进程
> ps -ef | grep 进程名 | grep -v grep | awk '{print $2}' | xargs kill 
>
> ps -ef|grep ${kibana_home} |grep -v grep|awk '{print $2}'|xargs kill

#### linux物理断电，有时候会出现generating “/run/initramfs/rdsosreport.txt”.....这种错误
>xfs_repair /dev/mapper/centos-root或xfs_repair /dev/mapper/centos-root -L  
>reboot

#### 如果ifconfig没有地址出现
>systemctl stop NetworkManager
>systemctl disable NetworkManager
>systemctl restart network

#### 硬盘挂载
```
fdisk -l             # 查看系统分区情况（sdb是挂载的硬盘）
fdisk /dev/sdb       # 进入分区模式
在 command（m for help）：后输入 m 进行帮助
输入 n 增加一个新的分区，输入p，输入1，两次回车，输入w
fdisk -l             # 查看系统分区情况
mkfs.ext3 /dev/sdb1  # 格式化分区，出现Proceed anyway？（y，n）时，这时输入“y”回车。  
mount /dev/sdb1 /mnt # 挂载分区
df -h                # 查看分区挂载情况
blkid /dev/sdb1  ---> uuid type
vim /etc/fstab
# 末尾添加 
uuid 挂载的目录[如：/mnt] type defaults 0 2
```