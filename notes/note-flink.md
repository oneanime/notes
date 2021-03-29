1.安装配置yarn模式下需要配置hadoop环境变量

```
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export HADOOP_CLASSPATH=`${HADOOP_HOME}/bin/hadoop classpath`
```

2.设置检查点和重启策略

```scala
    env.enableCheckpointing(5000,CheckpointingMode.EXACTLY_ONCE)
    env.getCheckpointConfig.setCheckpointTimeout(60000)
    env.setStateBackend(new FsStateBackend("hdfs://192.168.79.200:8020/flink/checkpoint"))
    env.setRestartStrategy(RestartStrategies.fallBackRestart())
    System.setProperty("HADOOP_USER_NAME","hp")
```

3.flink1.12中的写法，1.11中默认为blink适配器

```
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
StreamTableEnvironment tEnv = StreamTableEnvironment.create(env);
String create_sql = "CREATE TABLE user_behavior (" +
                "  `userId` BIGINT," +
                "  `itemId` BIGINT," +
                "  `category` BIGINT," +
                "  `behavior` STRING," +
                "  `timestamp` STRING" +
                ") " + KafkaUtil.getKafkaJsonDDL("user_action", "test", "earliest-offset");
String query_sql = "select *from user_behavior";
TableResult tableResult = tEnv.executeSql(create_sql);
Table sqlQuery = tEnv.sqlQuery(query_sql);
tEnv.toRetractStream(sqlQuery, Row.class).print();
env.execute();

<!--1.9中的写法-->
val settings = EnvironmentSettings.newInstance().useBlinkPlanner().inStreamingMode().build()
val envTable = StreamTableEnvironment.create(env, settings)
```

