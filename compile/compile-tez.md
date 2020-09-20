1.      tar -zxvf protobuf-2.5.0.tar.gz
2.      cd protobuf-2.5.0
3.      ./configure
4.      make
5.      make install
6.      protoc --version    #验证是否安装成功
7.      修改pom文件中的hadoop版本，如果编译到tez-api报错DistributedFileSystem没有找到，是因为hadoop3中这个类在hadoop-hdfs-client中，所以要在tez-api模块中的pom添加依赖hadoop-hdfs-client，并指定hadoop版本
8.      mvn -X clean package -DskipTests=true -Dmaven.javadoc.skip=true
