### 常用函数
|  函数   | 用法  |
|:------:|:------:|
| RANK() | 排序相同时会重复，总数不会变 |
| DENSE_RANK()  | 排序相同时会重复，总数会减少 |
| ROW_NUMBER()  | 会根据顺序计算 |
| get_json_object(字段，"$.json中的字段")   | 提取json中的数据，只处理一条 |
| lateral viewjson_tuple(字段，json中的字段1，json中的字段2.....)  | 处理多条数据  {{a:1,b:1}，{a:2,b:2}} |
| date_add(日期,偏移的日期)  | 可以为负 |
|next_day(日期,'MO')   |取下周一 ，以此推算这周的|
|date_format(日期,'yyyy-MM)|格式化日期|
|LAG(col,n,DEFAULT) |向下移动|
|LEAD(col,n,DEFAULT) |向上移动|
|FIRST_VALUE()|取分组内排序后，截止到当前行，第一个值|
|LAST_VALUE()|取分组内排序后，截止到当前行，最后一个值|

### 常用设置
```
set hive.exec.dynamic.partition.mode=nonstrict/strict
set mapred.reduce.tasks=数

# 推测执行，有多个reduce执行的时候，如果有一个一直没有结束，就会kill掉，重新启动一个reduce，缺点：重新启动的reduce并不能保证一定执行完。
set hive.mapred.map.tasks.speculative.execution=false
set hive.mapred.reduce.tasks.speculative.execution=false

# 并发执行
set hive.exec.parallel=true;
set hive.exec.parallel.thread.number=最大并发job数;

# 按压缩文件导出insert overwrite directory
set hive.exec.compress.output=true;
set mapred.output.compression.type=BLOCK;
set mapreduce.output.fileoutputformat.compress=true;
set mapreduce.output.fileoutputformat.compress.codec=压缩类 
```
### 扩展自定义方法
```
# 放入lib/下重启服务
add jar /opt/module/hive/gmall_hive-1.0-SNAPSHOT.jar;
create temporary function base_analizer as 'com.gmall.udf.BaseFieldUDF';
create temporary function flat_analizer as 'com.gmall.udtf.EventJsonUDTF';

# 可以传到hadoop上（不用重启服务）  
hadoop fs -mkdir -p /user/hive/jars
create function base_analizer as 'com.gmall.udf.BaseFieldUDF' using jar'hdfs://192.168.79.200:9000/user/hive/jars/hive-func-1.0-SNAPSHOT-jar-with-dependencies.jar';
create function flat_analizer as 'com.gmall.udtf.EventJsonUDTF' using jar'hdfs://192.168.79.200:9000/user/hive/jars/hive-func-1.0-SNAPSHOT-jar-with-dependencies.jar';
```

> 排错
>1. 如果报谷歌的类方法找不到，hadoop中的guava与hive中的冲突，删低版本，高版本拷过去  
>2. tez如果报错，很有可能是yarn资源分配不够，配置yarn-site.xml内存  
>3. hive 服务oom挂了hive-env.xml中 export HADOOP_HEAPSIZE=2048

### 配置core-site.xml,赋予权限
```
<property>
        <name>hadoop.proxyuser.用户名.hosts</name>
        <value>*</value>
</property>
<property>
        <name>hadoop.proxyuser.用户名.groups</name>
        <value>*</value>
</property>
```
### 可能会用到的命令
```
hadoop fs -chown -R root:root /tmp
schematool -dbType mysql -initSchema
hive -hiveconf hive.root.logger=DEBUG,console
```
### 笔记
>一般分区都是按时间地区分  
>大表分桶，当最小粒度的数据量还是很大  
>分区多个子目录，分桶存为多个文件（按hash打散）  
>场景：抽样、join提高效率  
>分桶之后，桶与桶join，减少join次数  
>合理分桶  