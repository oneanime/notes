#### 修改hadoop版本或者添加
```
<profile>
      <id>hadoop-版本</id>
      <properties>
        <hadoop.version>版本</hadoop.version>
        <curator.version>版本</curator.version>
      </properties>
</profile>
```

#### 把\<repository>和\<pluginRepository>的gcs-maven-central-mirror注释掉，或者把url改为[aliyun](https://maven.aliyun.com/repository/public)

> make-distribution.sh中  
注释掉原来的，编译之前会检查版本，耗时间，手动指定版本。spark项目版本、scala版本、hadoop版本  
VERSION=3.3.0  
SCALA_VERSION=2.12  
SPARK_HADOOP_VERSION=2.10.0  
SPARK_HIVE=0  
表示要不要hive，返回0表示不要，1为要  

#### 修改maven目录为自定义安装的，spark自带的会去找pom中的中央仓库的url

#### 编译
```
./dev/make-distribution.sh --name "hadoop3-without-hive" --tgz "-Pyarn,hadoop-provided,hadoop-3.3,parquet-provided"

./dev/make-distribution.sh --name without-hive --tgz -Pyarn -Phadoop-2.10 -Dhadoop.version=2.10.0 -Pparquet-provided -Porc-provided -Phadoop-provided

```