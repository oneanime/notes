### 常用函数


|  函数   | 用法  |
|:------:|:------:|
| RANK() | 排序相同时会重复，总数不会变 |
| DENSE_RANK()  | 排序相同时会重复，总数会减少 |
| ROW_NUMBER()  | 会根据顺序计算 |
| get_json_object(字段，"$.json中的字段")   | 提取json中的数据，只处理一条 |
| lateral viewjson_tuple(字段，json中的字段1，json中的字段2.....)  | 处理多条数据  {{a:1,b:1}，{a:2,b:2}} |
| datediff(string enddate, string startdate) | 返回结束日期减去开始日期的天数 |
| date_add(日期,偏移的日期)  | 可以为负 |
| date_sub(string startdate, int days) | 返回开始日期startdate减少days天后的日期 |
| *add_months*(日期，偏移的月份) | 当前日期的下n或上n个月，求年的话相当于乘12 |
|next_day(日期,'MO')   |取下周一 ，以此推算这周的|
|date_format(日期,'yyyy-MM)|格式化日期|
|to_date(string timestamp)|返回日期时间字段中的日期部分|
|year(string date)、month(string date)、day(string date)、hour(string date)、minute(string date)、second(string date)|返回日期中的年、月、日、小时、分钟、秒（格式：2011-12-08 10:03:01）|
|weekofyear(string date)|返回日期在当前的周数|
|dayofyear(string date)|返回日期在所在年的第几天|
|dayofmonth(string date)|返回日期在所在月的第几天|
|from_unixtime(时间戳,'yyyyMMdd')|把时间戳转换为日期|
|unix_timestamp(string date)|转换格式为“yyyy-MM-dd HH:mm:ss“的日期到UNIX时间戳。如果转化失败，则返回0。不加参数，返回当前时间的时间戳。|
|LAG(col,n,DEFAULT) |向下移动|
|LEAD(col,n,DEFAULT) |向上移动|
|FIRST_VALUE()|取分组内排序后，截止到当前行，第一个值|
|LAST_VALUE()|取分组内排序后，截止到当前行，最后一个值|
|TRUNC（date[,fmt]）|定元素而截去的日期值|

```sql
如果当日日期是：2011-3-18
select trunc(sysdate) --2011-3-18 今天的日期为2011-3-18
select trunc(sysdate, 'mm') --2011-3-1 返回当月第一天.
select trunc(sysdate,'yy')  --2011-1-1 返回当年第一天
select trunc(sysdate,'dd')  --2011-3-18 返回当前年月日
select trunc(sysdate,'yyyy')  --2011-1-1 返回当年第一天
select trunc(sysdate,'d')  --2011-3-13 (星期天)返回当前星期的第一天
select trunc(sysdate, 'hh')  --2011-3-18 14:00:00 当前时间为14:41
select trunc(sysdate, 'mi')  --2011-3-18 14:41:00 TRUNC()函数没有秒的精确
```



```
# 求近n个月
add_month(日期，-n)
# 求近n年
add_month(日期，-n*12)
# 求近

#连续问题：rank（）over（），等差数列-等差数列
```

```
insert overwrite table a1 parttion(随便写字段，hdfs的目录上的分区名)
select
...，
分区字段
from b1；

// 比如b1中有21个字段，在写insert的字段时，实际要写22个，最后一个字段默认是分区字段,实际在建a1表时，字段是21+1个
```





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
>distribute by 可以解决小文件问题，相当于shuffle中的分区字段，指定字段发送到reduce