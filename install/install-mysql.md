## 1. mysql安装
```
# 环境准备
yum remove mariadb-libs-5.5.60-1.el7_5.x86_64 -y
rpm -qa |grep mariadb
sudo yum install ncurses-compat-libs
useradd -s /sbin/nologin mysql  # 创建用户
```
```
# 设置环境变量
vim /etc/profile
export PATH=路径
source /etc/profile
mysql -V
```
```
# 挂载新的磁盘
mkfs.xfs /dev/sdc
mkdir /data
blkid
vim /etc/fstab
UUID="b7fde522-aa37-412a-9584-8313a673c5cc" /data xfs defaults 0 0
mount -a
df -h
```
```
# 授权
 chown -R mysql.mysql /application/*
 chown -R mysql.mysql /data
```
```
# 初始化数据库
5.6 版本 初始化命令  /application/mysql/scripts/mysql_install_db 
5.7 版本
mkdir /data/mysql/data -p 
chown -R mysql.mysql /data
mysqld --initialize --user=mysql --basedir=/opt/module/mysql --datadir=/opt/module/mysql/data
```
```
# 配置文件
vim /etc/my.cnf
[mysqld]
user=mysql
basedir=/opt/module/mysql
datadir=/opt/module/mysql/data
log-error = /opt/module/mysql/data/error.log
pid-file = /opt/module/mysql/data/mysql.pid
socket=/tmp/mysql.sock
server_id=6
port=3306
bind-address = 0.0.0.0
default-time_zone = '+8:00'
[client]
port=3306
socket=/tmp/mysql.sock

[mysqld]
character-set-server=utf8
collation-server=utf8_general_ci
[client]
default-character-set=utf8
[mysql]
default-character-set=utf8
```
```
# 启动g关闭数据库
$MYSQL_HOME/support-files/mysql.server  /etc/init.d/mysqld 
service mysqld restart

/etc/init.d/mysqld stop
```
```
# 修改密码
配置文件中添加skip-grant-tables
alter user root@'localhost' identified by '123456sql';
flush privileges;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456';
```
> ### 精简配置  
```
mysql 安装
rpm -qa |grep mariadb，yum remove .... -y
root用户下创建mysql用户，useradd -s /sbin/nologin mysql

1.tar
2.mkdir data
3.vim /etc/my.cnf
-------------------------------------
[mysqld]
user=mysql
basedir=/opt/module/mysql
datadir=/opt/module/mysql/data
socket=/tmp/mysql.sock
server_id=6
port=3306
bind-address = 0.0.0.0
default-time_zone = '+8:00'
skip-grant-tables
[client]
port=3306
socket=/tmp/mysql.sock
---------------------------------------
3.mysqld --initialize --user=mysql --basedir=/opt/module/mysql --datadir=/opt/module/mysql/data
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
4.重启服务
5.mysql -uroot -p
6.mysql> use mysql; 
  update mysql.user set authentication_string=PASSWORD('123456sql') where user='root';
  flush privileges;
  quit;
  vim /etc/my.cof 删除skip-grant-tables
7.SET PASSWORD = PASSWORD('123456sql');
   ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER;
   FLUSH PRIVILEGES;
   grant all privileges  on *.* to root@'%' identified by "123456sql";
   flush privileges;
   delete from user where host='localhost' and user='root';

useSSL=false&useUnicode=true&characterEncoding=UTF-8
```
> ### yum安装 mysql8
```
1. 在https://dev.mysql.com/downloads/repo/yum/ 中下载对应系统的rpm
   yum localinstall 下载的文件
2. 验证yum search mysql
3. yum install mysql-community-server
   如果比较慢，会在/var/cache/yum/x86_64/7/mysql80-community/packages路径下生成对应要下载的缓存文件，手动下载，放到路径下
   注：https://mirrors.ustc.edu.cn/mysql-ftp/downloads/或http://uni.mirrors.163.com/mysql/downloads/
4. service mysqld start
   service mysqld status
5. cat /var/log/mysqld.log | grep password
6. mysql -u root -p
7. flush privileges;
8. update user set plugin='mysql_native_password' where user ='root'; #修改密码规则
9. update mysql.user set grant_priv='Y', super_priv='Y' where user='root'; flush privileges;
10. set global validate_password.policy=0;
    set global validate_password.length=1;
    show variables like 'validate_password%';
    set global validate_password.policy=low;
    注：设置支持简单密码
11. select host, user, authentication_string, plugin from user; #查看root信息
12. update user set authentication_string='' where user='root'; #置空密码
13. alter user 'root'@'%' identified with mysql_native_password by '123456sql';flush privileges; #重新设置密码
14. select host,user from user;
    update user set host= '%' where user = 'root';
    vim /etc/my.cnf  中添加
    port=3306
    bind-address = 0.0.0.0
    default-time_zone = '+8:00'
```

```
#开启binlog
server-id= 1
#日志的前缀
log-bin=mysql-bin
binlog_format=row
#监控的数据库
binlog-do-db=gmallXXXXX

```
>报错 Access denied for user 'root'@'hadoop-master' (using password: YES)  
>在用root给某个账户赋权限时，报这个错  
>select Host,User,Grant_priv,Super_priv from user;  
>UPDATE mysql.user SET Grant_priv='Y', Super_priv='Y' WHERE User='root';
>FLUSH PRIVILEGES;
>
>一定要重启mysql

>报错 mysqld: error while loading shared libraries: libaio.so.1: cannot open shared object file: No such file or directory  
解决：yum install -y libaio-devel