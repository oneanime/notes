1. 在presto目录下创建存储数据的data目录 
2. 创建配置文件目录etc
3. cd etc
4. vim jvm.config
```
-Xmx16G
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+UseGCOverheadLimit
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+ExitOnOutOfMemoryError
```
5. vim node.properties
```
node.environment=production
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff   #每个节点需要不同
node.data-dir=/opt/module/presto/data
```
6. vim config.properties
```
coordinator=true #集群的worker节点为false
node-scheduler.include-coordinator=true   #单机版为true，集群版为false
http-server.http.port=8085
query.max-memory=50GB
query.max-memory-per-node=1GB
query.max-total-memory-per-node=2GB
discovery-server.enabled=true
discovery.uri=http://192.168.79.200:8085
```
7. vim log.properties
```
com.facebook.presto=INFO
```
8. etc下mkdir catalog
9. vim catalog/hive.properties
```
connector.name=hive-hadoop2
hive.metastore.uri=thrift://192.168.79.200:9083
hive.config.resources=/opt/module/hadoop/etc/hadoop/core-site.xml,/opt/module/hadoop/etc/hadoop/hdfs-site.xml
```
10. cp presto-cli-0.239.1-executable.jar 到presto根目录
11. java -jar presto-cli-0.239.1-executable.jar --server 192.168.79.200:8085 --catalog hive --schema default