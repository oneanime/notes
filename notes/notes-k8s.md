1. minikube安装

   https://minikube.sigs.k8s.io/docs/start/

   ```
   sudo groupadd docker
   sudo gpasswd -a $USER docker
   newgrp docker
   ```

   ```
   minikube start 安装时kicbase镜像会超时
   手动docker pull anjone/kicbase
   ```

   

2. 二进制包安装

   