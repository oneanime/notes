1. 下载tar包，解压，在目录下创建data、conf、log文件夹
2. 在conf下创建mongodb.conf
- mongodb.conf
```
systemLog:
   destination: file        
   path: "/opt/server/mongodb/log/mongodb.log" 
   logAppend: true			

storage:
   journal:
      enabled: true
   dbPath: "/opt/server/mongodb/data"            

processManagement:
   fork: true              
net:			
   bindIp: 192.168.79.201,127.0.0.1
   port: 27017
   
security:
  authorization: enabled
```
3. 启动脚本
```
#!/bin/bash
case $1 in 
"start")
   $MONGODB_HOME/bin/mongod -f $MONGODB_HOME/conf/mongodb.conf
;;
"stop")
   $MONGODB_HOME/bin/mongod -f $MONGODB_HOME/conf/mongodb.conf --shutdown
;;
*)
   echo "please input start or stop"
esac
```
4. 配置用户和密码(使用mongo命令)
```

#创建管理员账户，admin用户用于管理账号，不能进行关闭数据库等操作。
use admin
db.createUser({ user: "admin", pwd: "password", roles: [{ role: "userAdminAnyDatabase", db: "admin" }] })
db.auth('admin','password')

#创建一个超级管理员root。角色：root,root角色用于关闭数据库。
use admin
db.createUser({user: "root",pwd: "password", roles: [ { role: "root", db: "admin" } ]})
db.auth('root','password')

#创建用户自己的数据库的管理角色
use DATABASE_NAME #如果不存在就会创建
db.createUser({user: "user_name",pwd: "password",roles: [ { role: "dbOwner", db: "DATABASE_NAME" } ]})

注：开启认证模式后，use 数据库之后，要db.auth('用户名','password')

```
5. 账户操作
```
切换到admin
删除单个数据库
db.system.users.remove({user:"XXXXXX"})
```