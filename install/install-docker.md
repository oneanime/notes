docker官网：https://docs.docker.com/get-docker/

docker阿里云镜像加速：https://developer.aliyun.com/article/110806

```
# 环境centos7下
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# step 1: 安装必要的一些系统工具
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3: 更新并安装 Docker-CE
sudo yum makecache fast
sudo yum -y install docker-ce
# 安装指定版本https://docs.docker.com/engine/release-notes/20.10/
sudo yum -y install docker-ce-20.10.23 -y
# Step 4: 开启Docker服务
sudo service docker start
# 开机启动
sudo systemctl enable docker

#配置阿里云源  https://help.aliyun.com/document_detail/60750.html
登录阿里云账号根据步骤操作即可
{
  "registry-mirrors": ["https://xxxx.mirror.aliyuncs.com",
                       "https://docker.mirrors.ustc.edu.cn",
                       "https://registry.docker-cn.com",
                       "http://hub-mirror.c.163.com"],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
#配置远程连接
vim /lib/systemd/system/docker.service
找到ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
添加-H tcp://0.0.0.0:2375
systemctl daemon-reload
service docker restart
```
```
wsl2中的镜像模式中配置docker的代理
镜像模式中，使用clash代理
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo vim /etc/systemd/system/docker.service.d/http-proxy.conf
##添加以下内容
[Service]
Environment="HTTP_PROXY=http://代理服务器:端口"
Environment="HTTPS_PROXY=http://代理服务器:端口"
Environment="NO_PROXY=localhost,127.0.0.1"


sudo systemctl daemon-reload
sudo systemctl restart docker

```

安装docker-compose

```
# https://github.com/docker/compose/tags
# https://docs.docker.com/compose/install/
# python2版本下载docker-compose1.24.1之前的版本
https://github.com/docker/compose/releases/tag/v2.4.1
mv docker-compose /usr/local/bin
chmod +x /usr/local/bin/docker-compose
docker-compose version
```

window安装 [ 具体步骤见官网,以下为一些可选步骤 ]

```
# 安装docker后，docker会自动创建2个发行版docker-desktop和docker-desktop-data会比较占C盘（%LOCALAPPDATA%/Docker/wsl/data/）
# cmd查看发行版本
wsl -l -v
### 迁移操作 ###
# Setp 1: 关闭docker
# Setp 2: cmd下关闭wsl
wsl --shutdown
# Setp 3：将docker-desktop-data导出到指定路径（注意，原有的docker images不会一起导出）
wsl --export docker-desktop-data F:\OS\docker-desktop-data\docker-desktop-data.tar
# Setp 4: 注销docker-desktop-data
wsl --unregister docker-desktop-data
# Setp 5: 重新导入docker-desktop-data到要存放的文件夹
wsl --import docker-desktop-data F:\OS\docker-desktop-data F:\OS\docker-desktop-data\docker-desktop-data.tar --version 2

# 注：
docker-desktop-data占用空间比较大，另一个比较小可以忽略

```

window docker下安装k8s

```
# 手动下载以加速，具体文档在以下链接中
https://github.com/AliyunContainerService/k8s-for-docker-desktop
```



