>IDEA中读写hive时可能会有访问权限问题出现  
>解决方案：System.setProperty("HADOOP_USER_NAME","bigdata")

>sparksql的数仓默认是没有被设置的spark.sql.warehouse.dir，没有设置回去读hive-site.xml中的默认数仓，拷到spark 的conf/下的hive-site.xml 要加上
```
<property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
</property>
```
>spark3.0.0中定义udaf函数要object类继承Aggregator，注册使用spark.udf.register("remark",functions.udaf(AreaClickUDAF))

```
# 测试圆周率
bin/spark-submit  --class  org.apache.spark.examples.SparkPi  --deploy-mode cluster --master yarn examples/jars/spark-examples_2.12-3.0.1.jar
```

