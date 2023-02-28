1. 下载地址 https://github.com/goharbor/harbor/releases 
2. 解压，修改配置文件
```
hostname修改为本机地址
https的配置都注释掉
其他根据具体情况修改
```
3. 执行./install.sh
```
# 在harbor文件夹中执行，安装完后会有一个docker-compose.yml文件在harbor文件夹中
docker-compose stop
docker-compose up -d
```
4. 添加域名
```
192.168.79.104 harbor.od.com
```
5. docker主机登录
```
vim /etc/docker/daemon.json
# 添加
"insecure-registries":["本机地址1:端口"]
docker login 地址1
```
6. 上传
```
# 获取镜像IMAGE ID
docker images 
docker tag [IMAGE ID] 192.168.79.104:8089/library/mysql:latest
docker push 192.168.79.104:8089/library/mysql:latest
```
7. 批量脚本
```
#!/bin/bash

# 批量打标签
g1="192"

arr1=`docker images | grep $g1 | awk '{gsub(/k8s/,"registry.k8s.io");print "docker#tag#"$3"#"$1":"$2}'`

for a1 in $arr1
do
    `echo $a1 | awk '{gsub(/#/," ");print $0}'`
     echo $a1 | awk '{gsub(/#/," ");print $0}'
done
```
```
#!/bin/bash

# 批量push
g1="registry.k8s.io"

arr1=`docker images | grep $g1 | awk '{print "docker#push#"$1":"$2}'`
echo $arr1
for a1 in $arr1
do
    `echo $a1 | awk '{gsub(/#/," ");print $0}'`
     echo $a1 | awk '{gsub(/#/," ");print $0}'
done
```
