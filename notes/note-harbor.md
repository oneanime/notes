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
