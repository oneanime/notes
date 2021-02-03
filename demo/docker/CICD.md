#### 1. 安装gitlab

```shell
mkdir -p /opt/docker_gitlab
cd /opt/docker_gitlab
mkdir config
mkdir data
mkdir logs
vim docker-compose.yml
docker-compose up -d
```

```yaml
# gitlab docker-compose.yml
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
```

####  2. 安装gitlab-runner

```shell
kdir /opt/docker_gitlab-runner
cd /opt/docker_gitlab-runner
mkdir config
mkdir environment     #在文件夹environment放jdk、maven、maven的settings(添加镜像源)
cp /etc/docker/daemon.json /opt/docker_gitlab-runner/environment
cp /usr/local/bin/docker-compose /opt/docker_gitlab-runner/environment
vim Dockerfile
cd /opt/docker_gitlab-runner
vim docker-compose.yml
sudo chown root:root /var/run/docker.sock # 如果重启过docker，重新执行命令
docker-compose up -d --build
docker exec -it gitlab-runner usermod -aG root gitlab-runner

# 在gitlab中新建项目，点击新的项目中的设置下的CI\CD
# 展开Runner栏，手动设置specific Runner下可以看到Runner 设置时指定以下 URL和在安装过程中使用以下注册令牌
# 在注册Runner信息时需要以上两项
# 注册Runner信息到gitlab
docker exec -it gitlab-runner gitlab-runner register

```

![注册信息](https://github.com/oneanime/notes/blob/master/img/gitlab-runner-register.png)

```dockerfile
# gitlab-runner Dockerfile
FROM gitlab/gitlab-runner

RUN curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun

COPY daemon.json /etc/docker/daemon.json


# 安装 Docker Compose
WORKDIR /usr/local/bin
# RUN curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
COPY docker-compose /usr/local/bin
RUN chmod +x /usr/local/bin/docker-compose

# 安装 Java
RUN mkdir -p /usr/local/java
WORKDIR /usr/local/java
COPY jdk-8u281-linux-x64.tar.gz /usr/local/java
RUN tar -zxvf jdk-8u281-linux-x64.tar.gz && \
    rm -fr jdk-8u281-linux-x64.tar.gz

# 安装 Maven
RUN mkdir -p /usr/local/maven
WORKDIR /usr/local/maven
# RUN wget https://raw.githubusercontent.com/topsale/resources/master/maven/apache-maven-3.5.3-bin.tar.gz
COPY apache-maven-3.6.3-bin.tar.gz /usr/local/maven
RUN tar -zxvf apache-maven-3.6.3-bin.tar.gz && \
    rm -fr apache-maven-3.6.3-bin.tar.gz
COPY settings.xml /usr/local/maven/apache-maven-3.6.3/conf/settings.xml

# 配置环境变量
ENV JAVA_HOME /usr/local/java/jdk1.8.0_281
ENV MAVEN_HOME /usr/local/maven/apache-maven-3.6.3
ENV DOCKER_COMPOSE /usr/local/maven/apache-maven-3.6.3
ENV PATH $PATH:$JAVA_HOME/bin:$MAVEN_HOME/bin:$DOCKER_COMPOSE

WORKDIR /
```

```yaml
# gitlab-runner docker-compose.yml
version: '3.1'
services:
  gitlab-runner:
    build: environment
    restart: always
    container_name: gitlab-runner
    privileged: true
    volumes:
      - ./config:/etc/gitlab-runner
      - /var/run/docker.sock:/var/run/docker.sock
```

#### 3. 安装jenkins

```sh
mkdir -p /opt/docker_jenkins/data
sudo chmod 777 -R /opt/docker_jenkins/data
cd /opt/docker_jenkins
vim docker-compose.yml
docker-compose up -d
```

```yaml
# jenkins docker-compose.yml

version: '3.1'
services:
  jenkins:
    image: jenkins/jenkins
    container_name: jenkins
    ports:
     - 8888:8080
     - 5000:5000
    volumes:
     - ./data:/var/jenkins_home
```

```
# 代码发布到gitlab---->jenkins拉取代码---->jenkins发布到目标服务器
# 系统设置/系统配置/Publish over SSH(安装插件)，填写name、目标服务器 ip、密码、路径（没有需要手动创建）
# Jenkins下配置免密码，登录gitlab
# 进入Jenkins容器
docker exec -it 容器id bash
ssh-key -t rsa -C "邮箱"     # 会映射到宿主机中
exit     # 退出容器
cd /opt/docker_jenkins/data
ll -a
cd .ssh
cat id_rsa.pub   #复制内容
# 在gitlab中年找到用户设置/SSH密钥,粘贴上去
```





#### 4. 部署案例