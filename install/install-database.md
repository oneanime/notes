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
```
#开启binlog
server-id= 1
#日志的前缀
log-bin=mysql-bin
binlog_format=row
#监控的数据库
binlog-do-db=gmallXXXXX

```

>报错 mysqld: error while loading shared libraries: libaio.so.1: cannot open shared object file: No such file or directory  
解决：yum install -y libaio-devel

## 2. redis安装
```
yum -y install gcc gcc-c++ libstdc++-devel
make
make install
make PREFIX=/opt/module/redis install
版本6要更新gcc++
```
```
配置
bind：127.0.0.0改为0.0.0.0
把protected-modea改为no
daemonize yes后台启动
requirepass 密码
```
```
启动
$REDIS_HOME/bin/redis-server $REDIS_HOME/conf/redis.conf
停止
$REDIS_HOME/bin/redis-cli -h 127.0.0.1 -p 6379 -a 123456sql shutdown
进入cli
$REDIS_HOME/bin/redis-cli -a 123456sql --raw
```
## 3. nginx
```
./configure   --prefix=/opt/module/nginx
make && make install
sudo setcap cap_net_bind_service=+eip /opt/module/nginx/sbin/nginx
```
## 4. [postgresql](https://www.postgresql.org/download/)
- 按步骤安装  
>PostgreSQL会创建一个默认的linux用户postgres

- 改密码  
命令行进入  
sudo -u postgres psql;  
ALTER USER postgres WITH PASSWORD 'postgres';  改密码 

- 密码有要求：
```
/etc/pam.d/system-auth
password requisite pam_cracklib.so try_first_pass retry=3
password sufficient pam_unix.so md5 shadow nullok try_first_pass use_authtok
password required pam_deny.so
注释掉
添加password sufficient pam_unix.so nullok md5 shadow
```
- 远程连接
```
pg_hba.conf
host    all             all             0.0.0.0/0 all
postgresql.conf
listen_addresses = '*'
```
## 5.es
```
1. 修改配置文件config/elasticsearch.yml
    cluster.name
    node.name 每个节点都要不同
    bootstrap.memory_lock: false
    network.host 绑定每个节点的ip
    discovery.seed_hosts: ["ip1","ip2"...]
    cluster.initial_master_nodes: ["ip"]  指定master
2. 虚拟机中配置
vim /etc/security/limits.conf 
    * soft nofile 65536 
    * hard nofile 131072 
    * soft nproc 2048 
    * hard nproc 65536
vim /etc/security/limits.d/90-nproc.conf
    soft nproc 4096
vim /etc/sysctl.conf
    vm.max_map_count=262144
vim config/jvm.options
-Xms256m
-Xmx256m
```