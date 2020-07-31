1.      tar -zxvf protobuf-2.5.0.tar.gz
2.      cd protobuf-2.5.0
3.      ./configure
4.      make
5.      make install
6.      protoc --version    #验证是否安装成功
7.      mvn -X clean package -DskipTests=true -Dmaven.javadoc.skip=true
