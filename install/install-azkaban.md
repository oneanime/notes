1. 编译<br>
build.gradle文件-->allprojects-->repositories 添加 maven { url 'https://maven.aliyun.com/repository/public/' }<br>
./gradlew build -x test
2. 版本3.x中有一个轻量单机版的azkaban-solo-server开箱即用，只需修改时区为default.timezone.id=Asia/Shanghai
3. 集群版
```
create database azkaban;
use azkaban;
source create-all-sql-2.5.0.sql
```
```
配置web-server/conf下的azkaban.properties
default.timezone.id=Asia/Shanghai
配置mysql
mysql.port=3306
mysql.host=192.168.79.200
mysql.database=azkaban
mysql.user=root
mysql.password=123456sql
mysql.numconnections=100
```
```
配置exec-server/conf下的azkaban.properties
default.timezone.id=Asia/Shanghai
web.resource.dir=web-server下的web目录
user.manager.xml.file=web-server下的conf/azkaban-users.xml
配置mysql
mysql.port=3306
mysql.host=192.168.79.200
mysql.database=azkaban
mysql.user=root
mysql.password=123456sql
```
> 先启动exec-server,后启动web-server