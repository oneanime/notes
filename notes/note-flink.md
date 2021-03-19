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

