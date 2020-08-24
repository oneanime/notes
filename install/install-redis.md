## redis安装
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