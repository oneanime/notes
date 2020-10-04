1. 编译
```
mvn clean -DskipTests install
版本冲突造成的编译报错，修改源码，一般是由于组件版本不同，方法被弃用，由新的方法代替
```
2. 环境准备
```
jdk、hadoop、zookeeper、kafka、hbase、solr、hive、atlas
```
3. 集成hbase
```
vim atlas-application.properties 
添加atlas.graph.storage.hostname=host1:2181,host2:2181,host3:2181

进到$ATLAS_HOME/conf/hbase
ln -s $HBASE_HOME/conf/ $ATLAS_HOME/conf/hbase/

vim atlas-env.sh
添加export HBASE_CONF_DIR=$ATLAS_HOME/conf/hbase/conf
```
4. 集成solr
```
vim atlas-application.properties
添加atlas.graph.index.search.solr.zookeeper-url=host1:2181,host2:2181,host3:2181
cp -r $ATLAS_HOME/conf/solr $SOLR_HOME/   
mv solr atlas_conf
再分发到每个节点

bin/solr create -c vertex_index -d $SOLR_HOME/atlas_conf -shards 3 -replicationFactor 2
bin/solr create -c edge_index -d $SOLR_HOME/atlas_conf -shards 3 -replicationFactor 2
bin/solr create -c fulltext_index -d $SOLR_HOME/atlas_conf -shards 3 -replicationFactor 2

注：如果要删除
bin/solr delete -c ${collection_name}
```
5. 集成kafka
```
创建topic ATLAS_HOOK和ATLAS_ENTITIES

vim atlas-application.properties

#########  Notification Configs  #########
atlas.notification.embedded=false
atlas.kafka.zookeeper.connect=host1:2181,host2:2181,host3:2181
atlas.kafka.bootstrap.servers=host1:9092,host2:9092,host3:9092
atlas.kafka.zookeeper.session.timeout.ms=4000
atlas.kafka.zookeeper.connection.timeout.ms=2000
atlas.kafka.enable.auto.commit=true
```
6. 其他配置
```
atlas.rest.address=http://host:21000
atlas.server.run.setup.on.start=false
atlas.audit.hbase.zookeeper.quorum=host1:2181,host2:2181,host3:2181
```
7. 集成hive
```
vim atlas-application.properties
######### Hive Hook Configs #######
atlas.hook.hive.synchronous=false
atlas.hook.hive.numRetries=3
atlas.hook.hive.queueSize=10000
atlas.cluster.name=primary

cp atlas-application.properties $HIVE_HOME/conf

在hive-site.xml中添加
<property>
      <name>hive.exec.post.hooks</name>
      <value>org.apache.atlas.hive.hook.HiveHook</value>
</property>

在hive-env.xml
HIVE_AUX_JARS_PATH中添加atlas-plugin-classloader-xxx和hive-bridge-shim-xxx
```
8. 记录性能指标(atlas-log4j.xml)
```
#去掉如下代码的注释
<appender name="perf_appender" class="org.apache.log4j.DailyRollingFileAppender">
    <param name="file" value="${atlas.log.dir}/atlas_perf.log" />
    <param name="datePattern" value="'.'yyyy-MM-dd" />
    <param name="append" value="true" />
    <layout class="org.apache.log4j.PatternLayout">
        <param name="ConversionPattern" value="%d|%t|%m%n" />
    </layout>
</appender>

<logger name="org.apache.atlas.perf" additivity="false">
    <level value="debug" />
    <appender-ref ref="perf_appender" />
</logger>
```
9. 启动停止命令：bin/atlas_stop.py、atlas_stop.py
10. 导入元数据
```
启动atlas
导入hive元数据：bin/import-hive.sh
```