

### 一、docker常用命令

###### 1. 帮助命令

```
docker version
docker info
docker --help
```

###### 2. 镜像列表、搜素、拉取命、详情令

```
docker images [options]
	-a 列出本地所有的镜像(含中间映射层)
	-q 只显示镜像ID
	--digests 显示镜像的摘要信息
	--no-trunc 显示完整的镜像信息
```

```
docker search [options]镜像名
	--no-trun 显示完整的镜像描述
	-s 列出收藏数不小于指定值的镜像
	--automated 只列出 automated build类型的镜像
```

```
# 下载镜像，不加tag默认为最新的
docker pull 镜像名[:tag]
```

```
# 查看镜像详情
docker image inspect 镜像id
# 查看容器进程
docker ps -a
# 查看容器日志
docker logs -f -t --tail 容器ID
	-t 是加入时间戳
	-f 跟随最新的日志打印
	--tail 数字显示最后多少条
# 查看容器内的进程
docker top 容器ID
```

###### 3. 容器创建启动命令

```
# 创建不启动
docker create -it 镜像名 command
docker create -it centos /bin/bash
# 创建并运行镜像
docker run [OPTIONS] IMAGE [COMMAND][ARG]
	--name="容器新名字":为容器指定一个名称;
	--restart=always:容器随docker engine⾃启动，因为在重启docker的时候默认容器都会被关闭 
	-d:后台运行容器，并返回容器ID， 也即启动守护式容器;
	-i:以交互模式运行容器，通常与-t同时使用;
	-t:为容器重新分配一个伪输入终端，通常与-i同时使用;
	-v:  宿主机路径：容器中的路径，共享文件夹
	-P:随机端口映射;
	-p:指定端口映射，有以下四种格式
		ip:hostPort:containerPort
		ip::containerPort
		hostPort:containerPort
		containerPort
```

###### 4. 删除镜像/容器

```
# 删除单个镜像，强制删除：--force
docker rmi 镜像id
# 删除多个镜像空格隔开
docker rm -f 镜像id/镜像名1:TAG 镜像id/镜像名2:TAG
# 删除多个镜像
docker rmi -f ${docker images -qa}
# 删除多有镜像
docker rmi $(docker images -q)
# 批量删镜像
docker rmi -f $(docker images | grep "   " | awk '{print $3}') 
```

###### 5. 容器启动、停止、重启

```
# 退出容器
exit 容器停止退出
ctrl+P+Q 容器不停止退出
# 启动、停止、重启容器
docker start/stop/restart 容器ID(前三个字符即可)或容器签名
# 强制停止容器
docker kill 容器ID或容器签名
```

###### 6. 容器交互

```
# 进入正在运行的容器并以命令行交互
docker exec -it 容器ID bashShell
# 例子：
docker exec -it 容器ID ls -l /tmp
docker exec -it 容器ID /bin/bash

# 从容器内拷文件到主机
docker cp 容器ID:容器内路径 目的主机路径
```

###### 7. 数据卷

```
docker volume create 数据卷名 // 创建一个自定义容器卷
docker volume ls // 查看所有容器卷
docker volume inspect edc-nginx-vol // 查看指定容器卷详情信息
```

###### 8. 镜像打标签

```
# 给镜像打tag
docker tag daocloud.io/ubuntu daocloud.io/ubuntu:v1
```

###### 9. 镜像制作

```
### 容器制做 ####
# 导出宿主机
docker export -o 容器名.tar 容器名
# 容器有变化，更新容器
docker commit 容器id 容器名
# 导入宿主机
docker import 容器.tar 容器名:v1

### 镜像迁移 ###
docker save -o nginx.tar nginx / docker save > nginx.tar nginx
docker load < nginx.tar


注：
	1. docker save保存的是镜像（image），docker export保存的是容器（container）；
	2. docker load用来载入镜像包，docker import用来载入容器包，但两者都会恢复为镜像；
	3. docker load不能对载入的镜像重命名，而docker import可以为镜像指定新名称
```

### 二 、通过Dockerfile创建镜像

```
# 创建文件夹，在文件夹下创建Dockerfile，在Dockerfile所在路径先执行命令, . 表示Dockerfile所在路径
docker build -t 新镜像名字:TAG .
```

### 三、docker-compose

```
#### 以拉取gitlab为例 ####
mkdir -p /opt/docker_gitlab
cd /opt/docker_gitlab
mdkir config
mkdir data
mkdir logs
vim docker-compose.yml      # 文件名必须是docker-compose
############# copy ############################
version: '3.1'
services:
  gitlab:
    image: 'gitlab/gitlab-ce'
    container_name: 'gitlab'
    restart: 'no'
    privileged: true
    hostname: 'gitlab'
    environment:
      TZ: 'Asia/Shanghai'
      GITLAB_OMNIBUS_CONFIG:
        external_url 'http://192.168.79.202'
    ports:
     - 8880:80
     - 8443:443
     - 8822:22
    volumes:
     - /opt/docker_gitlab/config:/etc/gitlab
     - /opt/docker_gitlab/data:/var/opt/gitlab
     - /opt/docker_gitlab/logs:/var/log/gitlab
############################################
docker-compose up -d    # 必须在docker-compose.yml所在路径下执行
docker-compose logs -f  # 查看启动日志
docker-compose -p [name] down --remove-orphans  #删除

```



### 四、报错分析

>docker run -d centos后台启动后docker ps -a查看，**发现容器状态为exit**
>
>原因：**Docker容器后台运行,就必须有一个前台进程**，如果不是会一直挂起，之后会自动退出
>
>解决：运行程序一前台进程的形式运行