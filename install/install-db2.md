1. 解压安装包后，进入执行./db2_install,选择SERER,DB2 pureScale Feature不用安装

2. 创建组和用户

   ```
   groupadd db2adm4
   groupadd db2fen4
   useradd -d /home/db2inst4 -m db2inst4 -g db2adm4
   useradd -d /home/db2fenc4 -m db2fenc4 -g db2fen4
   passwd db2inst4
   passwd db2fenc4
   ```

3. 创建实例，实例名为db2inst4

   ```
   cd /opt/ibm/db2/V11.5/instance
   ./db2icrt -u db2fenc4 db2inst4
   su db2inst4
   db2start
   ```

4. 创建数据库

   ```
   # 创建样例库
   db2sampl
   # 创建数据库
   db2 create db 数据库名
   #查看是否创建成功
   db2 list db directory
   #连接到数据库
   db2 connect to 数据库
   # 查看表空间
   db2 list tablespaces
   ```

5. 远程连接(服务端配置)

   ```
   db2set DB2COMM=TCPIP
   db2 get dbm cfg | grep -i service 
   # 修改端口
   vim /etc/service
   db2stop
   db2start
   ```

6.客户端配置

```
安装db2 client,打开控制台
# 添加编目节点
db2 catalog tcpip node DBSVR remote 192.168.79.210 server 50000
db2 terminate
db2 list node directory
# 如果要删除
db2 uncatalog node DBSVR 
# 添加远程编目数据库
db2 catalog db SAMPLE as SAMPLE at node DBSVR  authentication SERVER
#如果要删除
db2 uncatalog database SAMPLE
#测试连接，linux用户和密码
db2 connect to SAMPLE user db2inst4 using 1
```

