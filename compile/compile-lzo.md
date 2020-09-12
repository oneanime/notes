```
1. 下载lzo
yum -y install gcc-c++ lzo-devel zlib-devel autoconf automake libtool
tar -zxvf lzo-2.10.tar.gz
cd lzo-2.10
./configure -prefix=/usr/local/hadoop/lzo/
make
make install
2. 下载hadoop-lzo的源码
export C_INCLUDE_PATH=/usr/local/hadoop/lzo/include
export LIBRARY_PATH=/usr/local/hadoop/lzo/lib
mvn package -Dmaven.test.skip=true
```