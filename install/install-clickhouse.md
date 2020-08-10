### [clickhouse离线安装](https://repo.clickhouse.tech/tgz/)

```
tar -xzvf clickhouse-common-static-$LATEST_VERSION.tgz
sudo clickhouse-common-static-$LATEST_VERSION/install/doinst.sh

tar -xzvf clickhouse-common-static-dbg-$LATEST_VERSION.tgz
sudo clickhouse-common-static-dbg-$LATEST_VERSION/install/doinst.sh

tar -xzvf clickhouse-server-$LATEST_VERSION.tgz
sudo clickhouse-server-$LATEST_VERSION/install/doinst.sh
sudo /etc/init.d/clickhouse-server start

tar -xzvf clickhouse-client-$LATEST_VERSION.tgz
sudo clickhouse-client-$LATEST_VERSION/install/doinst.sh
```
```
添加密码
修改/etc/clickhouse-server/users.xml
找到 users --> default --> 标签下的 <password></password>

/etc/clickhouse-server/config.xml
把注释掉的<listen_host>::</listen_host>取消注释，然后重启服务
```