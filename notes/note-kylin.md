正常启动，web UI进不去查看日志
```
com.fasterxml.jackson.datatype.jsr310.JavaTimeModule cannot be cast to com.fasterxml.jackson.databind.Module
# 结局方案：下载jackson-datatype-jsr310-2.11.2.jar，kylin.war解压后的项目jar包的文件夹下

# 检查环境是报错
hbase-common lib not found
vim ${HBASE_HOME}/bin/hbase
找到CLASSPATH=${CLASSPATH}:$JAVA_HOME/lib/tools.jar
末尾添加:$HBASE_HOME/lib/*
```

