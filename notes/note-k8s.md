命令
```
# 查看节点信息
kubectl get nodes

# 查看所有pod
kubectl get pod -A

# 删除pod
kubectl delete pod <podname> -n <namespace>

# 查看deployment信息
kubectl get deployment -n <namespace>
```