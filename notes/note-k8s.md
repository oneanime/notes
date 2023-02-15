常用命令
1. 查看所有的资源信息
```
kubectl get all

# 指定资源类型
kubectl get [pod、node、services、deployments等]

# 指定命名空间下的资源类型
kubectl get [pod、node、services、deployments等] -n example_namespace
#
```
2. pod
```
# 查看pod列表
kubectl get pod

# 显示pod节点的标签信息
kubectl get pod --show-labels

# 根据指定标签匹配到具体的pod
kubectl get pods -l app=example

# 查看pod详细信息，也就是可以查看pod具体运行在哪个节点上（ip地址信息）
kubectl get pod -o wide

# 查看所有pod所属的命名空间
kubectl get pod --all-namespaces

# 查看所有pod所属的命名空间并且查看都在哪些节点上运行
kubectl get pod --all-namespaces  -o wide

#查看命名空间kube-system下的coredns
kubectl get pods -n kube-system |grep coredns
```
3. node
```
# 查看node节点列表
kubectl get nodes

# 显示node节点的标签信息
kubectl get node --show-labels
```
4. svc
```
kubectl get svc
```
5. namespaces
```
# 查看命名空间
kubectl get ns

# 查看所有pod所属的命名空间
kubectl get pod --all-namespaces

# 查看所有pod所属的命名空间并且查看都在哪些节点上运行
kubectl get pod --all-namespaces  -o wide
```
6. 副本
```
# 查看目前所有的replica set，显示了所有的pod的副本数，以及他们的可用数量以及状态等信息
kubectl get rs
```
7. deployment
```
# 查看目前所有的deployment
kubectl get deployment

# 查看已经部署了的所有应用，可以看到容器，以及容器所用的镜像，标签等信息
kubectl get deploy -o wide
```
8. lable
```
# 给名为foo的Pod添加label unhealthy=true
kubectl label pods foo unhealthy=true

# 给名为foo的Pod修改label 为 'status' / value 'unhealthy'，且覆盖现有的value
kubectl label --overwrite pods foo status=unhealthy

# 给 namespace 中的所有 pod 添加 label
kubectl label  pods --all status=unhealthy

# 仅当resource-version=1时才更新 名为foo的Pod上的label
kubectl label pods foo status=unhealthy --resource-version=1

# 删除名为“bar”的label 。（使用“ - ”减号相连）
kubectl label pods foo bar-
```
9. log
```
kubectl logs [-f] [-p] POD [-c CONTAINER]

# 返回仅包含一个容器的pod nginx的日志快照
kubectl logs nginx

# 返回pod ruby中已经停止的容器web-1的日志快照
kubectl logs -p -c ruby web-1

# 持续输出pod ruby中的容器web-1的日志
kubectl logs -f -c ruby web-1

# 仅输出pod nginx中最近的20条日志
kubectl logs --tail=20 nginx

# 输出pod nginx中最近一小时内产生的所有日志
kubectl logs --since=1h nginx
```
10. describe
```
kubectl describe TYPE NAME_PREFIX
kubectl describe pod [pod_name]

语法： kubectl describe node [node_name]

语法： kubectl describe deployment [deployment_name]

kubectl  describe pod nginx-86546d6646-h7m2l 

#查看my-nginx pod的详细状态
kubectl describe po my-nginx
```
11. 执行配置文件
```
kubectl apply -f 配置文件
```